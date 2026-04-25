#!/usr/bin/env Rscript
# designr R launcher — sources every file under designr/R/ and then
# hands stdin to designr_dispatch(). The MCP server invokes this
# instead of the installed package, so end users never need to run
# `remotes::install_local("r-package/designr")` after a plugin update.
# CRAN dependencies (gsDesign, gsDesign2, jsonlite) are still required
# in the user's R library; those are normal install-once hygiene.

# Locate own path to find sibling R/ source dir.
.designr_args <- commandArgs(trailingOnly = FALSE)
.designr_self <- sub("^--file=", "",
                     grep("^--file=", .designr_args, value = TRUE))
if (length(.designr_self) == 0L) {
  stop("designr launcher: could not determine own path from commandArgs()")
}
.designr_self <- normalizePath(.designr_self[1], mustWork = TRUE)
.designr_r_dir <- file.path(dirname(dirname(.designr_self)), "R")
if (!dir.exists(.designr_r_dir)) {
  stop(sprintf("designr launcher: R source dir not found at %s",
               .designr_r_dir))
}

# Source every R/*.R into the global environment. Order does not
# matter — `.tool_registry` references design_* functions through
# closures that resolve lazily at call time.
for (.designr_f in list.files(.designr_r_dir, pattern = "\\.R$",
                              full.names = TRUE)) {
  source(.designr_f, local = FALSE)
}

# Hand the JSON request on stdin to the dispatcher.
designr_dispatch(file("stdin", "r"))
