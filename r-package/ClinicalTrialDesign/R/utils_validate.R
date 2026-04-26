#' Shared input validation for designr
#'
#' Internal helpers. Every validation error raises
#' `designr_input_error: <field>: <why>` so the MCP bridge can classify it
#' as a 4xx-type problem rather than a 5xx R crash.
#'
#' @name utils_validate
#' @keywords internal
NULL

designr_stop <- function(field, why) {
  stop(sprintf("designr_input_error: %s: %s", field, why), call. = FALSE)
}

check_prob <- function(x, field, open = TRUE) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x)) {
    designr_stop(field, "must be a single finite numeric")
  }
  if (open) {
    if (x <= 0 || x >= 1) designr_stop(field, "must lie strictly in (0, 1)")
  } else {
    if (x < 0 || x > 1) designr_stop(field, "must lie in [0, 1]")
  }
  invisible(x)
}

check_pos <- function(x, field) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x <= 0) {
    designr_stop(field, "must be a single positive finite numeric")
  }
  invisible(x)
}

check_nonneg <- function(x, field) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 0) {
    designr_stop(field, "must be a single non-negative finite numeric")
  }
  invisible(x)
}

check_int <- function(x, field, lo = NA_integer_, hi = NA_integer_) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x)) {
    designr_stop(field, "must be a single integer")
  }
  if (abs(x - round(x)) > 1e-9) {
    designr_stop(field, "must be an integer")
  }
  x <- as.integer(round(x))
  if (!is.na(lo) && x < lo) designr_stop(field, sprintf("must be >= %d", lo))
  if (!is.na(hi) && x > hi) designr_stop(field, sprintf("must be <= %d", hi))
  x
}

check_alpha <- function(alpha) {
  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      alpha <= 0 || alpha >= 0.5) {
    designr_stop("alpha", "must lie strictly in (0, 0.5)")
  }
  invisible(alpha)
}

check_power <- function(power) {
  if (!is.numeric(power) || length(power) != 1L || is.na(power) ||
      power <= 0.5 || power >= 1) {
    designr_stop("power", "must lie strictly in (0.5, 1)")
  }
  invisible(power)
}

check_sided <- function(sided) {
  if (!is.numeric(sided) || length(sided) != 1L || is.na(sided) ||
      !(as.integer(sided) %in% c(1L, 2L))) {
    designr_stop("sided", "must be 1 or 2")
  }
  as.integer(sided)
}

check_comparison <- function(comparison) {
  if (!is.character(comparison) || length(comparison) != 1L ||
      !(comparison %in% c("superiority", "non-inferiority", "equivalence"))) {
    designr_stop("comparison",
                 "must be one of 'superiority', 'non-inferiority', 'equivalence'")
  }
  comparison
}

check_ratio <- function(ratio, field = "allocation_ratio") {
  if (!is.numeric(ratio) || length(ratio) != 1L || is.na(ratio) || ratio <= 0) {
    designr_stop(field, "must be a single positive finite numeric")
  }
  invisible(ratio)
}

check_spending_fn <- function(sf, field) {
  allowed <- c("OF", "Pocock", "HSD", "Power", "LDOF", "LDPocock", "none")
  if (!is.character(sf) || length(sf) != 1L || !(sf %in% allowed)) {
    designr_stop(field, paste0("must be one of ",
                               paste(allowed, collapse = ", ")))
  }
  sf
}

check_design_class <- function(design_class) {
  allowed <- c("fixed", "group-sequential")
  if (!is.character(design_class) || length(design_class) != 1L ||
      !(design_class %in% allowed)) {
    designr_stop("design_class",
                 paste0("must be one of ", paste(allowed, collapse = ", ")))
  }
  design_class
}

check_survival_model <- function(model) {
  allowed <- c("ph", "maxcombo", "rmst", "milestone", "wlr", "ahr")
  if (!is.character(model) || length(model) != 1L || !(model %in% allowed)) {
    designr_stop("model",
                 paste0("must be one of ", paste(allowed, collapse = ", ")))
  }
  model
}
