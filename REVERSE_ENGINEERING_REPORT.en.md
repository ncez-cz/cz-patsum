# REVERSE_ENGINEERING_REPORT.md

**Repository:** cz-patsum  
**URL:** https://github.com/ncez-cz/cz-patsum  
**Base branch analyzed:** master (commit 4248395233bca2d019e4f10e7195132440d7b742)  
**Target fork:** https://github.com/admeduardovieira/cz-patsum  
**Audit date:** 2026-11-08  
**Environment:** Windows, PowerShell 5.1, Git 2.49.0, Python 3.12.14  
**Agent:** Kilo (REA 6.7.0), Git identity admeduardovieira / admeduardovieira@users.noreply.github.com  

---

## A. General diagnosis

### Identified architecture
cz-patsum is an FHIR R4 Implementation Guide (IG) for the Czech Patient Summary (CZ PS / Pacientský souhrn), developed by Národní centrum elektronického zdravotnictví (NCEZ). The project is built with **SUSHI/FSH** (FHIR Shorthand) and published with the IG Publisher. It is not an executable application: there is no application source code, backend, frontend, API, or service.

Directory structure:
- `input/fsh/profiles/*.fsh` — 26 FHIR profiles (ex: CZ_CompositionPS, CZ_BundlePatientSummary, CZ_ConditionPS, CZ_MedicationRequestPS, pregnancy/alcohol/tobacco/results observations).
- `input/fsh/invariants/*.fsh` — 5 FHIR invariants (ips-1, ips-2, bdl-ips-1, hasComponentifValueStringEmpty, hasMemberOrComponent).
- `input/fsh/aliases.fsh` — aliases of valuesets/codesystems (LOINC, SNOMED, MKn-10, UV-IPS, etc.).
- `input/pagecontent/*.md` and `*.xml` — IG documentation pages (index, principles, design, profiles, knownIssues, etc.).
- `input/images/PS-composition.png`, `input/includes/img.html` — visual assets.
- `sushi-config.yaml` — SUSHI configuration (id, canonical, dependencies, menu, releaseLabel).
- `ig.ini` — IG Publisher configuration (points to generated resource `fsh-generated/resources/...`).
- `package-lock.json` — empty lockfile (only `name`, no packages).
- `.gitignore` — ignores `fsh-generated`, `input-cache`, `output`, `temp`, `template`.

### Technologies and dependencies
- FHIR R4 (4.0.1)
- SUSHI (FSH)
- HL7 UV-IPS (International Patient Summary) as base (profiles, valuesets, extensions)
- IG dependencies: `hl7.fhir.uv.ips: current`, `hl7.fhir.us.mcode: current`, `ncez.cz.fhir.core: current`, `ncez.cz.fhir.lab: current` (all with version `current`, not pinned).
- releaseLabel: `ci-build` (correct spelling, not `releaselabel`).

### Maintenance state
Last commit on analyzed base: `4248395` ("Update of the specification", 07/03/2023, author kruzikh). History shows conversion of IPS profiles to the Czech Patient Summary, with compiled draft versions and a revert. No recent activity visible on master branch beyond the analysis performed. No issues/PRs publicly verified in this snapshot.

### Existing test mechanisms
No automated tests were found in the repository:
- No `test/`, `__tests__/` folder, or test files.
- No `.github/workflows` (no CI/CD).
- No `package.json` (only empty `package-lock.json`).
- It is not possible to run `sushi` (not installed) to compile/validate the FSH.

### Investigation limitations
- SUSHI is not installed in the environment; impossible to compile `.fsh` files or generate the IG for functional validation.
- pandas/scipy/litellm/Maven/R not installed; numerical tests not executed.
- GitHub issues/PRs not accessed beyond the repository clone (scope limited to cloned content).
- No intrusive or offensive testing was performed against third-party services.

---

## B. Problems found

| ID | Title | Severity | Status | Location |
|----|-------|----------|--------|----------|
| REA-001 | Unpinned package dependencies (version `current`) | P2 | CONFIRMED | `sushi-config.yaml:33-37` |
| REA-002 | Absence of CI/CD and automated tests | P3 | CONFIRMED | Repository root (absence of `.github/workflows` and tests) |
| REA-003 | Empty/useless `package-lock.json` | P3 | CONFIRMED | `package-lock.json` (only `name`, no packages) |
| REA-004 | Section slicing in `open` mode reduces automatic instance validation | P2 | CONFIRMED | `input/fsh/profiles/CzComposition.fsh` (sections) and `knownIssues.md` item 3 |
| REA-005 | Commented-out section entry slices (not implemented) | P3 | HYPOTHESIS | `input/fsh/profiles/CzComposition.fsh` (commented lines ~93-101, 110-118, etc.) |

### Details

**REA-001 — Unpinned dependencies (CONFIRMED)**
- Problem: `sushi-config.yaml` declares all dependencies with version `current` (`hl7.fhir.uv.ips: current`, `hl7.fhir.us.mcode: current`, `ncez.cz.fhir.core: current`, `ncez.cz.fhir.lab: current`).
- Evidence: `sushi-config.yaml:33-37`.
- Root cause: configuration option that does not pin specific versions, subjecting the build to uncontrolled upstream changes.
- Impact: non-reproducible builds; risk of breakage by retroactively incompatible changes in dependencies (supply chain).
- Proposed fix: replace `current` with specific stable versions (or keep `current` only if intentional, documenting the decision).

**REA-002 — Absence of CI/CD and automated tests (CONFIRMED)**
- Problem: no GitHub Actions workflows, no FSH/IG validation tests, no serialization tests.
- Evidence: absence of `.github/workflows` directory and absence of test files in the clone.
- Root cause: the IG has no continuous integration pipeline.
- Impact: changes to FSH profiles are not automatically validated; regressions go unnoticed.
- Proposed fix: add a CI workflow that runs `sushi` (when available) and validates the generated IG.

**REA-003 — Empty/useless `package-lock.json` (CONFIRMED)**
- Problem: `package-lock.json` contains only `"name": "cz-patsum"` and `"packages": {}`, without dependencies declared.
- Evidence: file content (header only, no packages).
- Root cause: lockfile generated without corresponding `package.json` or installed dependencies.
- Impact: file without function; may confuse contributors.
- Proposed fix: remove the empty file or add `package.json` with build dependencies (ex: fhirtypes, sushi) if that is the intent.

**REA-004 — Section slicing in `open` mode (CONFIRMED, already documented)**
- Problem: all slicing rules for composition sections are defined as `open` (ex: `section ^slicing.rules = #open`), allowing inclusion of inadequate resources.
- Evidence: `CzComposition.fsh:57` (`section ^slicing.rules = #open`) and `knownIssues.md` item 3 ("All of the slicing rules defined for the section entries have been specified in this version as open...").
- Root cause: design decision for flexibility, at the expense of automatic validation capability.
- Impact: instances may contain inadequate resources without being rejected by validators.
- Proposed fix: review critical slices and consider `closed` where clinical safety requires it, documenting the trade-off.

**REA-005 — Commented-out entry slices (HYPOTHESIS)**
- Problem: various entry slices of sections (medication, allergies, problems, procedures, etc.) are commented out in `CzComposition.fsh`.
- Evidence: commented lines (~93-101, 110-118, 126-133, etc.).
- Root cause: planned slices not activated.
- Impact: weaker typing of section entries; less strict validation.
- Proposed fix: evaluate gradual activation of commented slices with instance tests.

---

## C. Recurring problems

The problems below are already recognized by the maintainers (documented in `input/pagecontent/knownIssues.md`) and still persist in the analyzed version:

1. **Lack of representation of summarization activities** (who did it, what was done (medication reconciliation, allergy reconciliation, medication allergy reconciliation, immunization/vaccination reconciliation, problem list/diagnosis reconciliation), what was the result, when and where was it done) — includes the "Nature of the IPS" element included in EN 17269 and ISO 27269. Future: use of Provenance resource.
2. **Profile specificity to be improved** — not all expected rules can be automatically validated, due to lack of representation in the specified profiles.
3. **Open slicing** — all slicing rules defined for section entries specified in this version as open. This choice was made to give more flexibility to the IPS, at the expense of the capability of fully and automatically validating the instances. In this sense the profile may technically allow the inclusion of inappropriate resources. Specifiers are encouraged to add further constraints or additional slices to mitigate this risk. Future versions may reconsider the current choice.
4. **More constrained vocabularies** — choices made in this version reflect the need of balancing expectations of reducing optionality, to improve interoperability; and of avoiding over-constraints, to facilitate local adoption. Moreover, it has been recognized the current lack, in some cases, of globally recognized and freely usable vocabularies (e.g. for medication identification); and the need, for specific concept domains, to extend value sets based on new SNOMED CT and SNOMED IPS Terminology content. For these reasons, binding is required only in a few cases; preferred or extensible bindings have been used instead.
5. **Synergy with International Patient Access IG** and adoption of Provenance (future development).

Source: `input/pagecontent/knownIssues.md` (Items 1-5 and Future Development).

---

## D. Undocumented errors

Errors identified by the audit that do not appear in `knownIssues.md` nor in project documentation:

- **REA-001**: dependencies with version `current` not pinned.
- **REA-002**: absence of CI/CD and tests.
- **REA-003**: empty `package-lock.json`.
- **REA-005**: commented-out slices not activated.

---

## E. Performance

There is no executable code nor runtime operations to measure. The project is a static IG generated by SUSHI. Performance opportunities relate to IG generation time (SUSHI build), not runtime:

- `current` dependencies may cause repeated downloads of unpinned packages (recommendation: pin versions for reproducible and faster builds via cache).
- No initial measurement possible (SUSHI not installed).

No percentage gains were declared without a reproducible benchmark.

---

## F. Technical improvements

| Area | Improvement | Justification |
|------|-------------|---------------|
| Supply chain | Pin dependency versions in `sushi-config.yaml` | Reproducible builds; avoids breakage by upstream changes |
| Quality | Add CI/CD (GitHub Actions) with SUSHI/IG validation | Early detection of regressions in FSH profiles |
| Quality | Remove or fill empty `package-lock.json` | Avoid confusion for contributors |
| Robustness | Review `open` slicing to `closed` in critical sections | Stricter validation of clinical instances |
| Testability | Add instance examples and validation tests | Coverage of important behaviors |
| Documentation | Update `knownIssues.md` with item status (fixed/pending) | Traceability of known problems |

---

## G. Execution plan

Independent corrections, can be separate PRs:

1. **REA-001** (P2, immediate): pin dependency versions in `sushi-config.yaml`. Low risk, reproducible test (verify YAML remains valid and specific versions are used).
2. **REA-003** (P3, immediate): remove empty `package-lock.json` or add corresponding `package.json`. Low risk.
3. **REA-002** (P3, medium): add CI workflow. Medium risk (requires SUSHI installed on runner).
4. **REA-004** (P2, medium): review `open` slicing to `closed` where justified. Medium risk (changes profile validation behavior).
5. **REA-005** (P3, low): evaluate activation of commented slices. Medium risk (depends on instance tests).

Recommended order: REA-001 → REA-003 → REA-002 → REA-004 → REA-005.

---

## H. Expected result

- Reproducible IG builds free of surprises due to dependency versions (REA-001).
- Clean repository, without vestigial files (REA-003).
- Automatic regression detection via CI (REA-002).
- Stricter and clinically safer instance validation (REA-004).
- Low-risk contributions, with tests and evidence, suitable for small reviewable PRs to original maintainers.

---

## Mandatory final questions

1. **Which critical bugs were confirmed?** None. No critical bug (P0/P1) confirmed. The project is a static IG without executable code; no critical functional failures identified.
2. **Which recurring problems have developers not yet solved?** Open slicing (knownIssues #3), profile specificity (#2), lack of summarization activity representation (#1), more constrained vocabularies (#4) — all documented in `knownIssues.md` and still present.
3. **Which important errors were not documented?** Unpinned `current` dependencies (REA-001), absence of CI/CD and tests (REA-002), empty `package-lock.json` (REA-003), commented-out slices not activated (REA-005).
4. **Which performance opportunities were found?** Pin dependency versions for faster and reproducible SUSHI builds (package cache). No initial measurement possible.
5. **Which security and reliability improvements are justifiable?** Pin dependencies (supply chain), CI/CD for regression detection, stricter slicing for clinical instance validation.
6. **Which corrections can be made quickly?** REA-001 (pin versions in YAML) and REA-003 (remove/fill package-lock.json).
7. **Which are the three contributions with highest potential technical value?** (1) Pin dependency versions (reproducibility), (2) Add CI/CD with SUSHI validation (regression detection), (3) Review `open` → `closed` slicing in critical sections (clinical validation safety).
8. **Which corrections should be avoided due to lack of evidence?** Changing clinical profiles (cardinality obligations, bindings) without real instance data or SUSHI validation; activating commented slices without instance testing.
9. **Which modifications do you recommend implementing first?** REA-001 and REA-003 (small, low risk, reproducible test, no unrelated scope).

---

## Malware and threat analysis (static)

Performed on all repository files (FSH, YAML, INI, MD, XML, PNG, HTML, JSON, .gitignore).

**Result: No indicator identified by the static analysis performed.**

- No executable scripts (.ps1, .sh, .bat, .cmd, .js, .ts, .py), nor binaries (.exe, .dll) outside `.git` directory (default Git hook samples, not part of the project).
- No `.github/workflows` (no custom or suspicious Action).
- URLs/domains present are legitimate FHIR aliases (hl7.org, loinc.org, snomed.org, ncez.mzcr.cz, mkn10.uzis.cz, etc.).
- No keys, credentials, tokens, or connection strings embedded.
- No obfuscation, packing, persistence, process execution, file write/remove, data collection/exfiltration, or configuration modification suspicious.
- `package-lock.json` is empty (no packages, no npm supply-chain risk).

**Limitation:** static analysis only; no samples were executed. It is not stated that the project is free of malware.

---

**Note:** This report is the Portuguese base version. Synchronized English (`.en.md`) and Ukrainian (`.uk.md`) versions accompany this document, preserving REA-IDs, P0–P3 severities, paths, commands, URLs, and code snippets unchanged.
