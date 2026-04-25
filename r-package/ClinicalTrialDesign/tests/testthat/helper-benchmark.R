# Benchmark YAML loader used by anchor tests.
#
# Expected YAML shape (subset):
#   design:
#     effect: { ... }          # flat key/value per-case
#     alpha: ...
#     power: ...
#     sidedness: ...
#   expected:
#     sample_size_total: ...
#     tolerance: { sample_size_pct: ... }

bench_root <- function() {
  # Walks up from the test working directory to find benchmarks/
  cwd <- getwd()
  for (up in 0:6) {
    rel_parts <- if (up == 0) "." else rep("..", up)
    cand <- do.call(file.path, c(list(cwd), as.list(rel_parts), list("benchmarks")))
    if (isTRUE(dir.exists(cand))) return(normalizePath(cand))
  }
  fallback <- "/home/weiai/designr/benchmarks"
  if (dir.exists(fallback)) return(fallback)
  stop("could not locate benchmarks/ directory from working dir: ", cwd)
}

load_case <- function(family, id) {
  path <- file.path(bench_root(), family, "cases", paste0(id, ".yaml"))
  if (!file.exists(path)) stop("benchmark YAML not found: ", path)
  yaml::read_yaml(path)
}
