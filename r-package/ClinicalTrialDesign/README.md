# designr (R package)

Core statistical computation engine. Wraps `gsDesign`, `gsDesign2`, `rpact`, `simtrial`, and others behind a consistent API.

## Install (from source)

```r
# pak::pak("wei-ai-lab/designr/r-package/designr")  # once published
devtools::install_local("r-package/designr")
```

## Development

```r
devtools::load_all("r-package/designr")
devtools::test("r-package/designr")
devtools::check("r-package/designr")
```

See `../docs/architecture.md` for how this package fits into the broader plugin.
