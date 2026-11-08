# CORRECTIONS.md

**Repository:** cz-patsum  
**URL:** https://github.com/ncez-cz/cz-patsum  
**Base branch analyzed:** master (commit 4248395233bca2d019e4f10e7195132440d7b742)  
**Target fork:** https://github.com/admeduardovieira/cz-patsum  
**Date:** 2026-11-08  
**Agent:** Kilo (REA 6.7.0), Git identity admeduardovieira / admeduardovieira@users.noreply.github.com  

---

## Proposed corrections and status

| ID | Title | Severity | Status | Location | Risk | Suggested PR |
|----|-------|----------|--------|----------|------|--------------|
| REA-001 | Pin dependency versions (`current` → specific) | P2 | Proposal (not implemented yet in this audit) | `sushi-config.yaml:33-37` | Low | `fix/rea-001-pin-dependencies` |
| REA-002 | Add CI/CD and automated tests | P3 | Proposal (not implemented) | Repository root | Medium | `ci/rea-002-add-sushi-ci` |
| REA-003 | Remove or fill empty `package-lock.json` | P3 | Proposal (not implemented) | `package-lock.json` | Low | `chore/rea-003-clean-package-lock` |
| REA-004 | Review slicing `open` → `closed` in critical sections | P2 | Proposal (not implemented) | `input/fsh/profiles/CzComposition.fsh` | Medium | `fix/rea-004-strict-section-slicing` |
| REA-005 | Evaluate activation of commented slices | P3 | Hypothesis (not implemented) | `input/fsh/profiles/CzComposition.fsh` | Medium | `fix/rea-005-activate-section-slices` |

---

## Details per correction

### REA-001 — Pin dependency versions

**Problem:** `sushi-config.yaml` declares dependencies with version `current`, subjecting the build to uncontrolled upstream changes.

**Evidence:**
```yaml
dependencies:
  hl7.fhir.uv.ips: current
  hl7.fhir.us.mcode: current
  ncez.cz.fhir.core: current
  ncez.cz.fhir.lab: current
```

**Root cause:** versions not pinned in SUSHI configuration.

**Proposed fix:** replace `current` with specific stable versions (e.g. `1.1.0`) after verifying available versions in upstream repositories. Keep a comment justifying the choice.

**Files involved:** `sushi-config.yaml`

**Validation test:** validate YAML with a parser (e.g. Python `yaml.safe_load`) and confirm no `current` value remains in dependencies.

**Risk:** low.

**Benefit:** reproducible and predictable builds.

**Priority:** immediate.

---

### REA-002 — Add CI/CD and automated tests

**Problem:** absence of `.github/workflows` and FSH/IG validation tests.

**Evidence:** repository clone contains no `.github` directory nor test files.

**Root cause:** the IG has no continuous integration pipeline.

**Proposed fix:** add a GitHub Actions workflow that installs SUSHI and validates IG generation from the FSH.

**Files involved:** `.github/workflows/ci.yml` (new).

**Validation test:** run the workflow on fork/branch and confirm successful completion.

**Risk:** medium (requires SUSHI on CI runner).

**Benefit:** early detection of regressions in FSH profiles.

**Priority:** medium.

---

### REA-003 — Remove or fill empty `package-lock.json`

**Problem:** `package-lock.json` contains only `"name": "cz-patsum"` and `"packages": {}`, without function.

**Evidence:** file content (header only, no packages).

**Root cause:** lockfile generated without `package.json` nor installed dependencies.

**Proposed fix:** remove the empty file or add `package.json` with build dependencies if that is the intent.

**Files involved:** `package-lock.json` (removal) and, optionally, `package.json` (new).

**Validation test:** confirm build/lint does not depend on the empty `package-lock.json`.

**Risk:** low.

**Benefit:** clean repository, no confusion for contributors.

**Priority:** immediate.

---

### REA-004 — Review slicing `open` → `closed` in critical sections

**Problem:** slicing rules of sections defined as `#open` allow inadequate resources.

**Evidence:** `CzComposition.fsh:57` (`section ^slicing.rules = #open`) and `knownIssues.md` item 3.

**Root cause:** design decision for flexibility, at the expense of automatic validation.

**Proposed fix:** evaluate critical sections (medications, allergies, problems) and change slicing to `#closed` where clinical safety requires it, documenting the trade-off.

**Files involved:** `input/fsh/profiles/CzComposition.fsh`

**Validation test:** generate IG with SUSHI and validate example instances against profiles.

**Risk:** medium (changes clinical profile validation behavior).

**Benefit:** stricter and safer instance validation.

**Priority:** medium.

---

### REA-005 — Evaluate activation of commented slices

**Problem:** various entry slices of sections (medication, allergies, problems, procedures, etc.) are commented out in `CzComposition.fsh`.

**Evidence:** commented lines (~93-101, 110-118, 126-133, etc.).

**Root cause:** planned slices not activated.

**Proposed fix:** evaluate gradual activation of commented slices with instance tests.

**Files involved:** `input/fsh/profiles/CzComposition.fsh`

**Validation test:** generate IG and validate instances with and without active slices.

**Risk:** medium (depends on instance tests).

**Benefit:** stronger typing of section entries.

**Priority:** low.

---

## Uncorrected problems and residual risks

- All problems above are in "Proposal" or "Hypothesis" status at this audit stage (Phase 1 completed). No change has been applied to the source code yet.
- Residual risks: `current` dependencies still not pinned; absence of CI/CD; open slicing still active; commented-out slices still disabled.
- No security vulnerability confirmed by static analysis.

---

## Report records

- Base PT: `REVERSE_ENGINEERING_REPORT.md` and `CORRECTIONS.md` (this file).
- Translations: `REVERSE_ENGINEERING_REPORT.en.md`, `REVERSE_ENGINEERING_REPORT.uk.md`, `CORRECTIONS.en.md`, `CORRECTIONS.uk.md`.
- All at the root of the working clone / audit area, alongside the Portuguese base reports.

**Translation note (uk):** Machine-assisted technical translation; native speaker review recommended before use as a normative reference. No native review was obtained.
