# Data Engineering Documentation Standard

Reusable, platform-neutral documentation templates for data engineering portfolio projects.

## Contents

| Area | Purpose |
|---|---|
| [`templates/`](templates/) | Project README and eight focused design templates |
| [`guides/DOCUMENTATION_GUIDE.md`](guides/DOCUMENTATION_GUIDE.md) | Selection, placeholder, ownership, rationale, and maturity guidance |
| [`checklists/DOCUMENTATION_REVIEW_CHECKLIST.md`](checklists/DOCUMENTATION_REVIEW_CHECKLIST.md) | Pre-publication quality review |
| [`review/documentation_standard_analysis.md`](review/documentation_standard_analysis.md) | Design baseline for this standard |

## Recommended Sequence

1. Copy `templates/README_project_template.md` to the project root as `README.md`.
2. Select the applicable numbered templates using the guide.
3. Replace placeholders in copied project files and remove author instructions from those copies before final publication.
4. Keep each information type in its authoritative document and cross-reference it elsewhere.
5. Complete the review checklist before publishing.

When a document does not apply, list it as `Not Applicable` in the project README with a brief reason. The actual document file does not need to be created.

HTML comments remain in the reusable files under `documentation_standard/templates/`. Remove author instructions only from copies used as final project documentation.

## Core Principles

- Document decisions and rationale without overstating implementation maturity.
- Use platform-neutral concepts; introduce product names only when the project selects them.
- Keep inventories authoritative in one file and repeat only identifiers needed for readability.
- Support cloud, on-premises, hybrid, batch, micro-batch, streaming, and mixed architectures.
- Use only these maturity statuses: `Planned`, `In Progress`, `Implemented`, `Validated`, `Production-Ready`.
