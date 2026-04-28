#' Graphical multiplicity design (Maurer-Bretz alpha recycling)
#'
#' Compute a confirmatory design for two or more hypotheses controlled by a
#' graphical multiplicity procedure. Initial alpha weights split family-wise
#' alpha across hypotheses; a transition matrix re-allocates alpha to other
#' hypotheses upon rejection. The procedure controls family-wise type I error
#' under the closed-testing principle.
#'
#' This wrapper:
#' \enumerate{
#'   \item Validates the initial weights and transition matrix (Rule-3 check
#'     plus row sums \eqn{\le 1}). Raises \code{designr_input_error} on
#'     violation.
#'   \item Constructs the initial graph via \code{graphicalMCP::graph_create}.
#'   \item Sizes each hypothesis at a \strong{worst-case alpha} —
#'     \code{max(initial_weight_i, fallback_weight) * alpha} —
#'     where \code{fallback_weight} defaults to the smallest non-zero initial
#'     weight (the alpha a zero-weight hypothesis would receive in the
#'     simplest single-prerequisite-rejection path).
#'   \item Returns the total enrolled N as the maximum required across
#'     hypotheses.
#' }
#'
#' For non-trivial graphs the worst-case alpha may be smaller than the
#' default \code{fallback_weight} along a specific rejection path; review
#' the per-hypothesis alphas reported in the result and override
#' \code{worst_case_weights} if a different sizing is required.
#'
#' @param hypotheses A named list, one entry per hypothesis. Each entry is
#'   itself a list with \code{type ∈ \{"binary", "continuous", "survival"\}}
#'   and the parameters that the corresponding \code{design_<type>} wrapper
#'   would accept (effect, baseline parameters, etc.). The \code{alpha} for
#'   each hypothesis is computed from \code{initial_weights} and overridden
#'   in the dispatched call.
#' @param initial_weights Named numeric vector summing to \eqn{\le 1}. Names
#'   match \code{hypotheses}. Hypotheses with weight 0 start un-testable
#'   and require alpha to be recycled to them.
#' @param transition_matrix Square numeric matrix (with row/column names
#'   matching \code{hypotheses}). Row \code{i}, column \code{j} is the
#'   weight of alpha re-allocated from hypothesis \code{i} to hypothesis
#'   \code{j} upon rejection of \code{i}. Each row must sum to \eqn{\le 1}.
#' @param gate_prereqs Optional named list. Each entry is a character vector
#'   of hypothesis names that must be rejected before this hypothesis can
#'   be tested. Used by the Rule-3 validator to confirm transitions don't
#'   route alpha to already-rejected hypotheses.
#' @param alpha Family-wise type I error (default 0.025).
#' @param sided Sidedness (default 1).
#' @param power Per-hypothesis power (default 0.80).
#' @param allocation_ratio Treatment-to-control allocation ratio (default 1).
#' @param worst_case_weights Optional named numeric vector overriding the
#'   default per-hypothesis worst-case weight used for sample-size sizing.
#'
#' @return Unified result list with:
#'   \itemize{
#'     \item \code{sample_size_total} — max across hypotheses
#'     \item \code{hypotheses} — per-hypothesis design results, including
#'       the worst-case alpha used for sizing
#'     \item \code{multiplicity} — initial weights, transition matrix, the
#'       graphicalMCP graph object, and the validation result
#'     \item \code{driver} — name of the hypothesis that drove total N
#'   }
#'
#' @export
design_graphical_multiplicity <- function(hypotheses,
                                          initial_weights,
                                          transition_matrix,
                                          gate_prereqs       = NULL,
                                          alpha              = 0.025,
                                          sided              = 1,
                                          power              = 0.80,
                                          allocation_ratio   = 1,
                                          worst_case_weights = NULL) {

  if (!requireNamespace("graphicalMCP", quietly = TRUE)) {
    stop("designr_input_error: hypotheses: package 'graphicalMCP' is required for graphical multiplicity")
  }

  # --- input validation -----------------------------------------------------
  if (!is.list(hypotheses) || length(hypotheses) < 2L) {
    stop("designr_input_error: hypotheses: must be a named list of length >= 2")
  }
  hyp_names <- names(hypotheses)
  if (is.null(hyp_names) || any(!nzchar(hyp_names)) || anyDuplicated(hyp_names)) {
    stop("designr_input_error: hypotheses: must have unique non-empty names")
  }

  if (!is.numeric(initial_weights) || is.null(names(initial_weights))) {
    stop("designr_input_error: initial_weights: must be a named numeric vector")
  }
  if (!setequal(names(initial_weights), hyp_names)) {
    stop("designr_input_error: initial_weights: names must match hypotheses exactly")
  }
  initial_weights <- initial_weights[hyp_names]
  if (any(initial_weights < 0)) {
    stop("designr_input_error: initial_weights: weights must be non-negative")
  }
  if (sum(initial_weights) > 1 + 1e-9) {
    stop("designr_input_error: initial_weights: sum must be <= 1")
  }

  k <- length(hypotheses)
  if (!is.matrix(transition_matrix) ||
      nrow(transition_matrix) != k ||
      ncol(transition_matrix) != k) {
    stop(sprintf(
      "designr_input_error: transition_matrix: must be a %d x %d square matrix",
      k, k))
  }
  if (any(transition_matrix < 0)) {
    stop("designr_input_error: transition_matrix: weights must be non-negative")
  }
  row_sums <- rowSums(transition_matrix)
  if (any(row_sums > 1 + 1e-9)) {
    stop("designr_input_error: transition_matrix: each row sum must be <= 1")
  }
  # Rule-3: no transition from i to itself
  if (any(diag(transition_matrix) > 1e-9)) {
    stop("designr_input_error: transition_matrix: diagonal must be 0 (no self-loop)")
  }

  # Apply names to the matrix if missing
  if (is.null(rownames(transition_matrix))) {
    rownames(transition_matrix) <- hyp_names
  }
  if (is.null(colnames(transition_matrix))) {
    colnames(transition_matrix) <- hyp_names
  }
  # Reorder to match hyp_names
  transition_matrix <- transition_matrix[hyp_names, hyp_names, drop = FALSE]

  # Rule-3 validator with explicit gate_prereqs: a hypothesis cannot have
  # alpha routed to it after its prerequisites have already had their
  # alpha consumed. The basic check: if gate_prereqs[[h]] = c("A","B"),
  # then h's incoming weights from A and B are the only legitimate paths.
  validation <- list(passed = TRUE, warnings = character(0))
  if (!is.null(gate_prereqs)) {
    if (!is.list(gate_prereqs) ||
        !all(names(gate_prereqs) %in% hyp_names)) {
      stop("designr_input_error: gate_prereqs: names must be hypotheses")
    }
    for (h in names(gate_prereqs)) {
      prereqs <- gate_prereqs[[h]]
      if (!all(prereqs %in% hyp_names)) {
        stop(sprintf(
          "designr_input_error: gate_prereqs: '%s' references unknown hypotheses: %s",
          h, paste(setdiff(prereqs, hyp_names), collapse = ", ")))
      }
      # Hypothesis h's initial weight should be 0 (gated)
      if (initial_weights[h] > 1e-9) {
        validation$warnings <- c(validation$warnings,
          sprintf("'%s' has gate_prereqs but non-zero initial weight (%g) — gating may be moot",
                  h, initial_weights[h]))
      }
      # h must be reachable from at least one prereq
      reachable <- rownames(transition_matrix)[transition_matrix[, h] > 1e-9]
      missing <- setdiff(prereqs, reachable)
      if (length(missing) > 0) {
        validation$passed <- FALSE
        validation$warnings <- c(validation$warnings,
          sprintf("'%s' is gated on %s but transition_matrix routes no alpha from %s to '%s'",
                  h, paste(prereqs, collapse = "/"),
                  paste(missing, collapse = "/"), h))
      }
    }
  }
  if (!validation$passed) {
    stop(sprintf(
      "designr_input_error: transition_matrix: Rule-3 validation failed: %s",
      paste(validation$warnings, collapse = "; ")))
  }

  # --- determine worst-case weight per hypothesis --------------------------
  default_fallback <- {
    nz <- initial_weights[initial_weights > 1e-9]
    if (length(nz) > 0) min(nz) else 1 / k
  }
  if (is.null(worst_case_weights)) {
    worst_case_weights <- pmax(initial_weights, default_fallback)
    names(worst_case_weights) <- hyp_names
  } else {
    if (!setequal(names(worst_case_weights), hyp_names)) {
      stop("designr_input_error: worst_case_weights: names must match hypotheses exactly")
    }
    worst_case_weights <- worst_case_weights[hyp_names]
  }
  per_alpha <- alpha * worst_case_weights

  # --- design each hypothesis ---------------------------------------------
  per_hyp <- list()
  for (nm in hyp_names) {
    h <- hypotheses[[nm]]
    if (!is.list(h) || is.null(h$type)) {
      stop(sprintf(
        "designr_input_error: hypotheses: '%s' must be a list with a 'type' field",
        nm))
    }
    args <- h[setdiff(names(h), "type")]
    args$alpha            <- per_alpha[[nm]]
    args$sided            <- if (is.null(args$sided)) sided else args$sided
    args$power            <- if (is.null(args$power)) power else args$power
    args$allocation_ratio <- if (is.null(args$allocation_ratio))
      allocation_ratio else args$allocation_ratio
    args$comparison       <- if (is.null(args$comparison))
      "superiority" else args$comparison

    fn <- switch(h$type,
      binary     = design_binary,
      continuous = design_continuous,
      survival   = design_survival,
      stop(sprintf(
        "designr_input_error: hypotheses: '%s' has unsupported type '%s'",
        nm, h$type))
    )
    res <- tryCatch(
      do.call(fn, args),
      error = function(err) {
        msg <- conditionMessage(err)
        if (startsWith(msg, "designr_input_error:")) {
          stop(sprintf(
            "designr_input_error: hypotheses: '%s': %s", nm,
            sub("^designr_input_error:\\s*", "", msg)))
        }
        stop(err)
      }
    )
    res$worst_case_alpha  <- per_alpha[[nm]]
    res$worst_case_weight <- worst_case_weights[[nm]]
    res$initial_weight    <- initial_weights[[nm]]
    per_hyp[[nm]] <- res
  }

  # --- construct the graph ------------------------------------------------
  graph <- graphicalMCP::graph_create(
    hypotheses  = initial_weights,
    transitions = transition_matrix
  )

  # --- aggregate ----------------------------------------------------------
  ns <- vapply(per_hyp, `[[`, numeric(1), "sample_size_total")
  driver <- names(ns)[which.max(ns)]
  total_n <- max(ns)
  per_arm <- .per_arm(total_n, allocation_ratio)

  multiplicity <- list(
    strategy            = "graphical",
    initial_weights     = as.list(initial_weights),
    transition_matrix   = transition_matrix,
    worst_case_weights  = as.list(worst_case_weights),
    worst_case_alpha    = as.list(per_alpha),
    rule3_validation    = validation,
    family_alpha        = alpha,
    rationale           = "Graphical multiplicity (Maurer-Bretz). Each hypothesis sized at its worst-case alpha = alpha * worst_case_weight; total N = max across hypotheses."
  )

  inputs <- list(
    hypotheses          = lapply(hypotheses, function(h) h[setdiff(names(h), "type")]),
    hypothesis_types    = vapply(hypotheses, function(h) h$type, character(1)),
    initial_weights     = as.list(initial_weights),
    transition_matrix   = transition_matrix,
    gate_prereqs        = gate_prereqs,
    worst_case_weights  = as.list(worst_case_weights),
    alpha               = alpha,
    sided               = sided,
    power               = power,
    allocation_ratio    = allocation_ratio
  )

  .designr_result(
    sample_size_total   = total_n,
    sample_size_per_arm = per_arm,
    events_total        = NULL,
    boundaries          = NULL,
    timing              = NULL,
    operational         = NULL,
    inputs              = inputs,
    method              = "design_graphical_multiplicity[graphicalMCP]",
    package_version     = .pkg_version("graphicalMCP"),
    raw                 = list(
      hypotheses   = per_hyp,
      driver       = driver,
      graph        = list(
        hypotheses  = as.list(initial_weights),
        transitions = transition_matrix
      ),
      multiplicity = multiplicity
    )
  )
}
