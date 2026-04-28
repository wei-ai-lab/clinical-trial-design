#' JSON dispatcher for the designr MCP bridge
#'
#' Reads one JSON message `\{tool, args\}` from `con`, runs the matching
#' exported design function, and writes a result JSON to stdout:
#' \preformatted{
#'   { "ok": true,  "result": {...} }
#'   { "ok": false, "error":  { "class": "...", "message": "...", "field": "..." } }
#' }
#'
#' Intended to be invoked one-shot per R subprocess:
#' \preformatted{
#'   Rscript -e 'ClinicalTrialDesign::designr_dispatch(file("stdin","r"))'
#' }
#'
#' @param con Text connection to read JSON from. Defaults to stdin.
#' @export
designr_dispatch <- function(con = file("stdin", "r")) {
  input <- paste(readLines(con, warn = FALSE), collapse = "\n")
  msg <- tryCatch(
    jsonlite::fromJSON(input, simplifyVector = TRUE, simplifyDataFrame = FALSE),
    error = function(e) {
      .emit_error("parse_error", conditionMessage(e))
      return(invisible(NULL))
    }
  )
  if (is.null(msg)) return(invisible(NULL))
  tool <- msg$tool
  args <- if (is.null(msg$args)) list() else msg$args
  if (!is.character(tool) || length(tool) != 1L) {
    .emit_error("bad_request", "missing or invalid 'tool' field")
    return(invisible(NULL))
  }
  fn <- .tool_registry[[tool]]
  if (is.null(fn)) {
    .emit_error("unknown_tool", sprintf("no tool named '%s'", tool))
    return(invisible(NULL))
  }
  res <- tryCatch(
    do.call(fn, as.list(args)),
    error = function(e) e
  )
  if (inherits(res, "error")) {
    .emit_designr_error(res)
  } else {
    .emit_ok(res)
  }
  invisible(NULL)
}

.emit_ok <- function(result) {
  out <- list(ok = TRUE, result = .json_friendly(result))
  cat(jsonlite::toJSON(out, auto_unbox = TRUE, null = "null",
                       na = "null", force = TRUE, digits = 10))
  cat("\n")
}

# jsonlite::toJSON drops the names of multi-element atomic vectors when
# auto_unbox=TRUE, emitting a bare array like [460,460] instead of the
# expected {"control":460,"treatment":460}. That breaks any downstream
# caller — including verify_design / design_report when chained through
# the MCP bridge — that indexes `sample_size_per_arm[["control"]]`. To
# preserve the keys we coerce any named atomic vector inside the result
# tree to a named list right before serialization. The R-side return
# shape (named integer vector) stays unchanged for direct R callers.
.json_friendly <- function(x) {
  if (is.list(x)) {
    return(lapply(x, .json_friendly))
  }
  if (is.atomic(x) && length(x) > 1L && !is.null(names(x))) {
    return(as.list(x))
  }
  x
}

.emit_error <- function(class, message, field = NULL) {
  err <- list(class = class, message = message)
  if (!is.null(field)) err$field <- field
  out <- list(ok = FALSE, error = err)
  cat(jsonlite::toJSON(out, auto_unbox = TRUE, null = "null", force = TRUE))
  cat("\n")
}

.emit_designr_error <- function(e) {
  m <- conditionMessage(e)
  if (startsWith(m, "designr_input_error:")) {
    parts <- strsplit(m, ":", fixed = TRUE)[[1]]
    field <- trimws(parts[2])
    why   <- trimws(paste(parts[-c(1, 2)], collapse = ":"))
    .emit_error("input_error", why, field = field)
  } else {
    .emit_error("r_error", m)
  }
}

.tool_registry <- list(
  design_binary              = function(...) design_binary(...),
  design_continuous          = function(...) design_continuous(...),
  design_survival            = function(...) design_survival(...),
  design_co_primary          = function(...) design_co_primary(...),
  validate_against_benchmark = function(...) validate_against_benchmark(...),
  verify_design              = function(...) verify_design(...),
  design_report              = function(...) design_report(...)
)
