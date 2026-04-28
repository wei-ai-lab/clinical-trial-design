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

# Reasoning chain — structured citation trail attached to any design result.
# The package provides the *shape* (validated here); LLMs and users fill the
# *content*. Every entry: {decision, value, justification, source_type,
# source_ref?}. source_type is restricted to a small enum so downstream
# tooling (design_report, sponsor-redaction warning) can act on it.

REASONING_SOURCE_TYPES <- c(
  "llm_precedent",       # public-trial precedent surfaced by the LLM
  "fda_guidance",        # citation to a specific FDA guidance document
  "ich_guidance",        # citation to ICH E9 / E9-R1 / etc.
  "user_supplied",       # the user told the agent this value directly
  "package_default",     # fell out of a tool's default value
  "sponsor_confidential" # sponsor-internal data (Phase 2 readout, etc.)
)

check_reasoning_chain <- function(rc, field = "reasoning_chain") {
  if (is.null(rc)) return(NULL)
  if (!is.list(rc)) {
    designr_stop(field, "must be a list of reasoning entries (or NULL)")
  }
  if (length(rc) == 0L) return(list())
  required_keys <- c("decision", "value", "justification", "source_type")
  for (i in seq_along(rc)) {
    e <- rc[[i]]
    if (!is.list(e)) {
      designr_stop(field, sprintf("entry %d must be a named list", i))
    }
    missing <- setdiff(required_keys, names(e))
    if (length(missing) > 0L) {
      designr_stop(field, sprintf("entry %d missing required key(s): %s",
                                  i, paste(missing, collapse = ", ")))
    }
    if (!is.character(e$decision) || length(e$decision) != 1L ||
        !nzchar(e$decision)) {
      designr_stop(field,
                   sprintf("entry %d: 'decision' must be a non-empty string", i))
    }
    if (!is.character(e$justification) || length(e$justification) != 1L) {
      designr_stop(field,
                   sprintf("entry %d: 'justification' must be a string", i))
    }
    if (!is.character(e$source_type) || length(e$source_type) != 1L ||
        !(e$source_type %in% REASONING_SOURCE_TYPES)) {
      designr_stop(field,
                   sprintf("entry %d: 'source_type' must be one of: %s",
                           i, paste(REASONING_SOURCE_TYPES, collapse = ", ")))
    }
    if (!is.null(e$source_ref) &&
        (!is.character(e$source_ref) || length(e$source_ref) != 1L)) {
      designr_stop(field,
                   sprintf("entry %d: 'source_ref' must be a string when present", i))
    }
  }
  rc
}

# True if any reasoning_chain entry has source_type == "sponsor_confidential".
# design_report uses this to flag the report as "review before sharing".
reasoning_has_confidential <- function(rc) {
  if (is.null(rc) || length(rc) == 0L) return(FALSE)
  any(vapply(rc, function(e) identical(e$source_type, "sponsor_confidential"),
             logical(1)))
}
