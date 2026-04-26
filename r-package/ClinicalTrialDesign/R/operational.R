#' Solve the operational kernel for a designed trial
#'
#' Given the design's headline numbers (`target_n`, optionally
#' `target_events` for survival), and any 0-4 of the four operational
#' parameters
#' \code{\{accrual_rate, accrual_duration, follow_up_duration, total_trial_duration\}},
#' fill in the missing values and report which were supplied vs derived.
#'
#' The kernel:
#' \itemize{
#'   \item For all endpoints: `accrual_rate * accrual_duration = target_n`
#'         and `total_trial_duration = accrual_duration + follow_up_duration`.
#'   \item For survival: additionally
#'         `target_events = target_n * cumulative_event_rate(...)`,
#'         where `cumulative_event_rate` is the standard exponential-PH
#'         closed form used by `gsDesign::nSurv`.
#' }
#'
#' Cardinality of the supplied set:
#' \itemize{
#'   \item 4 supplied: validate consistency, echo all four as `given`.
#'   \item 3 supplied: solve for the one free parameter.
#'   \item 2 supplied: solve the system.
#'   \item 0-1 supplied: not enough constraints. Raises
#'         \code{designr_input_error: operational: must supply at least 2 of \{accrual_rate, accrual_duration, follow_up_duration, total_trial_duration\}}.
#' }
#'
#' @param target_n Target total sample size (from the design).
#' @param target_events Target events (survival only; NULL otherwise).
#' @param endpoint_type One of `"binary"`, `"continuous"`, `"survival"`.
#' @param accrual_rate Subjects accrued per unit time (typically months).
#' @param accrual_duration Length of accrual window.
#' @param follow_up_duration Minimum follow-up after last subject enrolled.
#' @param total_trial_duration Calendar time from first enrollment to study end.
#' @param control_median Required for survival.
#' @param hazard_ratio Required for survival.
#' @param allocation_ratio Treatment:control allocation; survival only.
#' @param dropout_rate_per_month Per-month exponential dropout hazard
#'   (survival only).
#' @return A list:
#'   \itemize{
#'     \item `accrual_rate`, `accrual_duration`, `follow_up_duration`,
#'           `total_trial_duration`
#'     \item `cumulative_event_rate` (survival only)
#'     \item `given` -- names of user-supplied parameters
#'     \item `derived` -- names solved by this function
#'   }
#' @keywords internal
solve_operational <- function(target_n,
                              target_events           = NULL,
                              endpoint_type           = c("binary", "continuous", "survival"),
                              accrual_rate            = NULL,
                              accrual_duration        = NULL,
                              follow_up_duration      = NULL,
                              total_trial_duration    = NULL,
                              control_median          = NULL,
                              hazard_ratio            = NULL,
                              allocation_ratio        = 1,
                              dropout_rate_per_month  = 0) {
  endpoint_type <- match.arg(endpoint_type)
  if (!is.numeric(target_n) || length(target_n) != 1L || is.na(target_n) ||
      target_n <= 0) {
    designr_stop("operational", "target_n must be a single positive numeric")
  }
  given <- c(
    if (!is.null(accrual_rate))         "accrual_rate",
    if (!is.null(accrual_duration))     "accrual_duration",
    if (!is.null(follow_up_duration))   "follow_up_duration",
    if (!is.null(total_trial_duration)) "total_trial_duration"
  )
  # Survival can solve with 1 op param + target_events (uniroot pins F).
  # Everything else needs at least 2 op params.
  min_required <- if (endpoint_type == "survival" && !is.null(target_events)) 1L else 2L
  if (length(given) < min_required) {
    designr_stop("operational",
                 "must supply at least 2 of {accrual_rate, accrual_duration, follow_up_duration, total_trial_duration}")
  }

  # Validate positivity on supplied scalars up front.
  if (!is.null(accrual_rate) && accrual_rate <= 0) {
    designr_stop("accrual_rate", "must be positive")
  }
  if (!is.null(accrual_duration) && accrual_duration <= 0) {
    designr_stop("accrual_duration", "must be positive")
  }
  if (!is.null(follow_up_duration) && follow_up_duration < 0) {
    designr_stop("follow_up_duration", "must be non-negative")
  }
  if (!is.null(total_trial_duration) && total_trial_duration <= 0) {
    designr_stop("total_trial_duration", "must be positive")
  }

  # Linear propagation pass: rate*A = N AND A + F = T. Repeat until no
  # progress, since each derivation can unlock the next.
  repeat {
    progress <- FALSE
    # rate*A = N
    if (!is.null(accrual_rate) && is.null(accrual_duration)) {
      accrual_duration <- target_n / accrual_rate
      progress <- TRUE
    } else if (is.null(accrual_rate) && !is.null(accrual_duration)) {
      accrual_rate <- target_n / accrual_duration
      progress <- TRUE
    }
    # A + F = T
    if (!is.null(accrual_duration) && !is.null(follow_up_duration) &&
        is.null(total_trial_duration)) {
      total_trial_duration <- accrual_duration + follow_up_duration
      progress <- TRUE
    } else if (!is.null(accrual_duration) && !is.null(total_trial_duration) &&
               is.null(follow_up_duration)) {
      follow_up_duration <- total_trial_duration - accrual_duration
      if (follow_up_duration < 0) {
        designr_stop("operational",
                     "inconsistent: total_trial_duration < accrual_duration")
      }
      progress <- TRUE
    } else if (is.null(accrual_duration) && !is.null(follow_up_duration) &&
               !is.null(total_trial_duration)) {
      accrual_duration <- total_trial_duration - follow_up_duration
      if (accrual_duration <= 0) {
        designr_stop("operational",
                     "inconsistent: total_trial_duration <= follow_up_duration")
      }
      progress <- TRUE
    }
    if (!progress) break
  }

  # Consistency checks on over-specified inputs.
  if ("accrual_rate" %in% given && "accrual_duration" %in% given) {
    .assert_n_consistency(accrual_rate, accrual_duration, target_n)
  }
  if (!is.null(accrual_duration) && !is.null(follow_up_duration) &&
      !is.null(total_trial_duration) &&
      length(intersect(given, c("accrual_duration", "follow_up_duration",
                                 "total_trial_duration"))) >= 2) {
    .assert_duration_consistency(accrual_duration, follow_up_duration,
                                 total_trial_duration)
  }

  # Non-survival can't proceed without a rate/duration anchor.
  if (endpoint_type != "survival" &&
      (is.null(accrual_rate) || is.null(accrual_duration))) {
    designr_stop("operational",
                 "for non-survival endpoints, supply at least one of {accrual_rate, accrual_duration}")
  }

  # Survival: jointly solve A and F when target_events ties them. This
  # only triggers if we still have unknowns after the linear
  # propagation above.
  cumulative_event_rate <- NULL
  if (endpoint_type == "survival") {
    if (is.null(control_median) || control_median <= 0) {
      designr_stop("control_median",
                   "required for survival operational solving")
    }
    if (is.null(hazard_ratio) || hazard_ratio <= 0) {
      designr_stop("hazard_ratio",
                   "required for survival operational solving")
    }
    lambdaC <- log(2) / control_median
    eta     <- dropout_rate_per_month
    hr      <- hazard_ratio

    # Survival joint solve: A is determined (linear pass), F still unknown,
    # target_events ties them via target_n * cum_event_rate(A, F) = target_events.
    # uniroot over F.
    if (!is.null(accrual_duration) && is.null(follow_up_duration)) {
      if (is.null(target_events)) {
        designr_stop("operational",
                     "survival follow_up_duration is unknown -- supply it directly or supply target_events to solve via uniroot")
      }
      f_target <- function(Fval) {
        p <- .event_prob_pooled(lambdaC, hr, eta, accrual_duration, Fval,
                                allocation_ratio)
        target_n * p - target_events
      }
      lo <- 0; hi <- 240
      while (f_target(hi) < 0 && hi < 600) hi <- hi + 60
      if (f_target(hi) < 0) {
        designr_stop("operational",
                     "cannot reach target_events within 600 months of follow-up")
      }
      if (f_target(lo) > 0) {
        designr_stop("operational",
                     "implied events at follow_up=0 already exceed target_events")
      }
      sol <- stats::uniroot(f_target, lower = lo, upper = hi,
                            tol = .Machine$double.eps^0.25)
      follow_up_duration <- sol$root
      total_trial_duration <- accrual_duration + follow_up_duration
    }

    # Compute the cumulative event rate now that A, F are known.
    if (!is.null(accrual_duration) && !is.null(follow_up_duration)) {
      cumulative_event_rate <- .event_prob_pooled(
        lambdaC, hr, eta, accrual_duration, follow_up_duration,
        allocation_ratio
      )
      # Consistency check vs target_events when supplied.
      if (!is.null(target_events)) {
        implied_events <- target_n * cumulative_event_rate
        rel <- abs(implied_events - target_events) /
                 max(target_events, 1)
        if (rel > 0.10) {
          designr_stop("operational",
                       sprintf("inconsistent: implied events %.1f vs target_events %.1f (relative diff %.1f%%)",
                               implied_events, target_events, 100 * rel))
        }
      }
    }
  }

  # Final sanity: every output should now be non-NULL.
  out <- list(
    accrual_rate           = accrual_rate,
    accrual_duration       = accrual_duration,
    follow_up_duration     = follow_up_duration,
    total_trial_duration   = total_trial_duration,
    cumulative_event_rate  = cumulative_event_rate
  )
  missing_out <- vapply(out[c("accrual_rate", "accrual_duration",
                              "follow_up_duration", "total_trial_duration")],
                        is.null, logical(1))
  if (any(missing_out)) {
    designr_stop("operational",
                 sprintf("solver could not determine: %s",
                         paste(names(missing_out)[missing_out], collapse = ", ")))
  }

  derived <- setdiff(c("accrual_rate", "accrual_duration",
                       "follow_up_duration", "total_trial_duration"), given)
  out$given   <- given
  out$derived <- derived
  out
}
