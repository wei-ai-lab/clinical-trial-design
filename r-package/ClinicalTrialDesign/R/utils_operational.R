#' Operational helpers — cumulative event probability under exponential PH
#'
#' Closed-form integral over a uniform-accrual / exponential-dropout window.
#' Mirrors the kernel `gsDesign::nSurv` uses internally so that operational-
#' solver outputs are consistent with the design-time event count.
#'
#' Per-arm event probability for a subject under exponential survival with
#' hazard \eqn{\lambda} and dropout hazard \eqn{\eta}, accruing uniformly
#' over [0, A] with study end at T = A + F:
#' \deqn{
#'   P(\text{event}) =
#'     \frac{\lambda}{\lambda + \eta}
#'     \left[
#'       1 - \frac{1}{A(\lambda+\eta)}
#'         \left(e^{-(\lambda+\eta) F} - e^{-(\lambda+\eta) T}\right)
#'     \right]
#' }
#'
#' @name utils_operational
#' @keywords internal
NULL

.event_prob_arm <- function(lambda, eta, A, F) {
  if (A <= 0) return(0)
  lp <- lambda + eta
  if (lp <= 0) return(0)
  T_total <- A + F
  (lambda / lp) *
    (1 - (1 / (A * lp)) * (exp(-lp * F) - exp(-lp * T_total)))
}

# Pooled event probability across both arms, weighted by the per-arm sample.
.event_prob_pooled <- function(lambdaC, hazard_ratio, eta, A, F,
                               allocation_ratio) {
  pC <- .event_prob_arm(lambdaC, eta, A, F)
  pT <- .event_prob_arm(lambdaC * hazard_ratio, eta, A, F)
  wC <- 1 / (1 + allocation_ratio)
  wT <- 1 - wC
  wC * pC + wT * pT
}

# Validate that `accrual_rate * accrual_duration ≈ N_target` within `tol`.
# Returns invisibly if consistent; raises designr_input_error otherwise.
.assert_n_consistency <- function(accrual_rate, accrual_duration, N_target,
                                  tol = 0.05) {
  implied_n <- accrual_rate * accrual_duration
  rel <- abs(implied_n - N_target) / max(N_target, 1)
  if (rel > tol) {
    designr_stop("operational",
                 sprintf("inconsistent: accrual_rate * accrual_duration = %.1f but design needs %.1f (relative diff %.1f%%)",
                         implied_n, N_target, 100 * rel))
  }
  invisible(NULL)
}

# Validate that `total_trial_duration ≈ accrual_duration + follow_up_duration`.
.assert_duration_consistency <- function(A, F, T_total, tol = 0.05) {
  implied <- A + F
  if (abs(implied - T_total) / max(T_total, 1) > tol) {
    designr_stop("operational",
                 sprintf("inconsistent: accrual_duration + follow_up_duration = %.2f but total_trial_duration = %.2f",
                         implied, T_total))
  }
  invisible(NULL)
}
