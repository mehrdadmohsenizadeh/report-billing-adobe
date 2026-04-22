# report-billing-adobe

A beginner-friendly Power BI Pro tutorial for building a **Company Adobe License Billing Report** — the monthly artifact the CFO and Accounting team use to bill sub-companies for their share of the corporate Adobe account.

## Contents

- **[docs/Adobe-Billing-Report-Tutorial.md](docs/Adobe-Billing-Report-Tutorial.md)** — Full step-by-step guide with a **Fast Path** section for paste-and-go setup in ~10 minutes:
  - Data Prep (Power Query): CSV import, splitting `Name` into `FirstName`/`LastName`, adding Status / Company / Product / Price / Notes columns, and Active-vs-Inactive logic for retained users.
  - Data Modeling (Calculations): `Total Price` calculated column plus a full set of CFO-grade DAX measures.
  - Visual Design (The Dashboard): report header with Contract ID / Billing Info / Due Date / Payment Method, KPI cards, slicers, and a drill-down matrix.
  - Professional add-ons: Department, Last Login Date, License Utilization %.
  - Publish, share, schedule refresh, and row-level security.
- **[templates/adobe-users-blank-template.csv](templates/adobe-users-blank-template.csv)** — Empty template (headers + one example row). Open in Excel, replace the example row with your real Adobe export data, save.
- **[templates/adobe-users-template.csv](templates/adobe-users-template.csv)** — Pre-filled sample dataset (10 rows across 3 sub-companies) for previewing the report before you have real data.
- **[scripts/PowerQuery-Users.m](scripts/PowerQuery-Users.m)** — Paste into a Power BI *Blank Query* to build the `Users` table (handles the Name split and column types automatically).
- **[scripts/PowerQuery-BillingHeader.m](scripts/PowerQuery-BillingHeader.m)** — Paste into a *Blank Query* to build the disconnected `BillingHeader` table (Contract ID, Due Date, Payment Method, etc.).
- **[scripts/DAX-Measures.dax](scripts/DAX-Measures.dax)** — All KPI measures + the `Total Price` calculated column, with per-block copy-paste instructions.

## Why no `.pbix` file?

A `.pbix` is a proprietary binary format that only Power BI Desktop can safely author. Generating one outside Desktop produces files Power BI typically refuses to open. This repo takes the reliable alternative: **blank CSV + paste-and-go M and DAX scripts** reproduce the same report in minutes, and they live in source control as plain text.

## Quick start

1. Install Power BI Desktop (free).
2. Download **[templates/adobe-users-blank-template.csv](templates/adobe-users-blank-template.csv)**, fill it with your Adobe Admin Console export, save.
3. Open the tutorial and follow the **Fast Path** section, or work through Parts 1 → 4 in order for a full-depth walkthrough.

## Intended audience

Novice Power BI users. No prior DAX or Power Query knowledge assumed.
