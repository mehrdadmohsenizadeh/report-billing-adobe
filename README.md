# report-billing-adobe

A beginner-friendly Power BI Pro tutorial for building a **Company Adobe License Billing Report** — the monthly artifact the CFO and Accounting team use to bill sub-companies for their share of the corporate Adobe account.

## Contents

- **[docs/Adobe-Billing-Report-Tutorial.md](docs/Adobe-Billing-Report-Tutorial.md)** — Full step-by-step guide:
  - Data Prep (Power Query): CSV import, splitting `Name` into `FirstName`/`LastName`, adding Status / Company / Product / Price / Notes columns, and Active-vs-Inactive logic for retained users.
  - Data Modeling (Calculations): `Total Price` calculated column plus a full set of CFO-grade DAX measures.
  - Visual Design (The Dashboard): report header with Contract ID / Billing Info / Due Date / Payment Method, KPI cards, slicers, and a drill-down matrix.
  - Professional add-ons: Department, Last Login Date, License Utilization %.
  - Publish, share, schedule refresh, and row-level security.
- **[templates/adobe-users-template.csv](templates/adobe-users-template.csv)** — Sample dataset matching the tutorial's column layout; load it straight into Power BI Desktop to follow along.

## Quick start

1. Install Power BI Desktop (free).
2. Open the tutorial and work through Parts 1 → 4 in order.
3. Use `templates/adobe-users-template.csv` as your starter dataset, or swap in your own Adobe Admin Console user export.

## Intended audience

Novice Power BI users. No prior DAX or Power Query knowledge assumed.
