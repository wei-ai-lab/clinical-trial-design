# Example 01 — CAPTURE (1997)

## Trial

The CAPTURE Investigators (1997). *Randomised placebo-controlled trial of abciximab before and during coronary intervention in refractory unstable angina: the CAPTURE Study.* Lancet 349:1429-1435.

Phase 3 trial of abciximab vs placebo in refractory unstable angina patients planned for PCI. 30-day composite endpoint (death + MI + urgent reintervention).

## Published design

- α = 0.05 (two-sided), 80% power, 1:1 randomization, fixed-sample.
- Assumed 30-day event rate 15% (placebo) vs 9% (active). 
- **Planned N = 1,400** (sponsor inflated ~30% over textbook minimum for protocol-deviation buffer; the agent gets the textbook number).

## Reproduction

```bash
R -e 'source("examples/01_capture_binary/run.R")'
```

Expected: ~960–1,100 patients (textbook minimum at the published assumptions). The 1,400 published number reflects sponsor padding documented in the SAP.

## What this example demonstrates

- `design_binary` with `comparison = "superiority"` and `design_class = "fixed"`.
- Reasoning chain populated with two entries — one `fda_guidance` for alpha, one `llm_precedent` for the control event rate. Demonstrates the citation-trail pattern.
