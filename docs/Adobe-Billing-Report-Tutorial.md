# Company Adobe License Billing Report — Power BI Pro Tutorial

> **Audience:** Novice Power BI user
> **Purpose:** Build an enterprise-grade billing report that the CFO and Accounting team use to charge sub-companies for their share of the corporate Adobe account.
> **Tools:** Power BI Desktop (free) → publish to Power BI Pro workspace.

Welcome! This guide walks you through building a professional, CFO-ready report from scratch. You do **not** need prior Power BI experience — we will go one button at a time. By the end, you will have:

1. A clean data model sourced from your Adobe Admin user export.
2. Meaningful calculated columns and DAX measures.
3. A polished dashboard with a report header, KPI cards, slicers, and a drill-down table.

Take your time. If a step looks unfamiliar, pause and re-read — you are learning a tool used by Fortune 500 BI teams.

---

## Table of Contents

1. [Before You Start](#0-before-you-start)
2. [Part 1 — Data Prep (Power Query)](#part-1--data-prep-power-query)
3. [Part 2 — Data Modeling (Calculations)](#part-2--data-modeling-calculations)
4. [Part 3 — Visual Design (The Dashboard)](#part-3--visual-design-the-dashboard)
5. [Part 4 — Publish, Share, and Refresh](#part-4--publish-share-and-refresh)
6. [Appendix A — Professional Add-on Columns](#appendix-a--professional-add-on-columns)
7. [Appendix B — Full DAX Reference](#appendix-b--full-dax-reference)

---

## 0. Before You Start

### 0.1 What you need
- **Power BI Desktop** installed (free download from Microsoft).
- A **Power BI Pro** license to publish and share with your CFO/Accounting team.
- Your **Adobe Admin Console user export**. In the Adobe Admin Console, go to **Users → Users → ... (more options) → Export users list to CSV**. That will give you the same grid you see in the screenshot, but in CSV form — perfect for Power BI.
- The starter file in this repo: `templates/adobe-users-template.csv`. If you have not exported yet, use the template to follow along — the columns match what Adobe gives you, plus the billing fields we will add.

### 0.2 One-time setup
1. Open **Power BI Desktop**.
2. Save a new file as `Adobe-License-Billing.pbix` in a folder you control (ideally OneDrive or SharePoint, so it's backed up).
3. In **File → Options and settings → Options → Regional Settings**, set **Locale for import** to `English (United States)` so currency and dates behave predictably.

---

## Part 1 — Data Prep (Power Query)

Power Query is the "kitchen" where we clean raw ingredients before plating. Everything here is **repeatable** — next month's export will flow through the same recipe automatically.

### 1.1 Connect to your Adobe CSV

1. On the Home ribbon, click **Get data → Text/CSV**.
2. Browse to your CSV (either the Adobe export or `templates/adobe-users-template.csv`).
3. In the preview, click **Transform Data** (not Load). This opens the **Power Query Editor**.

> **Mentor tip:** Always click *Transform Data*, not *Load*. Loading first locks you into the raw shape; transforming first lets you clean before anything hits the model.

### 1.2 Rename the query

In the right-hand **Query Settings** pane, rename the query from `adobe-users-template` to **`Users`**. Clean naming pays off later when you write DAX.

### 1.3 Promote and type the headers

Usually Power Query detects headers automatically. If not:
1. **Home → Use First Row as Headers**.
2. Review each column's data type icon (left of the column name). Click the icon to change types where needed:
   - `Email`, `Name`, `ID type`, `Products`, `Company`, `Notes` → **Text**
   - `Status` → **Text** (we will standardize values below)
   - `Price1`, `Price2` → **Decimal Number** (or **Fixed Decimal Number** for currency)
   - `Last Login Date` → **Date**

### 1.4 Split the Name column into FirstName and LastName

This is the headline transform you asked about.

1. Click the **`Name`** column header to select it.
2. Ribbon: **Home → Split Column → By Delimiter**.
3. In the dialog:
   - **Select or enter delimiter:** `Space`
   - **Split at:** `Left-most delimiter` *(this is important — it correctly handles names like "Mary Jane Smith" by treating "Mary" as FirstName and "Jane Smith" as LastName)*
   - Click **OK**.
4. Power Query creates `Name.1` and `Name.2`. Double-click each to rename:
   - `Name.1` → **`FirstName`**
   - `Name.2` → **`LastName`**

> **Why left-most, not each occurrence?** "Each occurrence" would create 3+ columns for middle names and break next month's refresh. Left-most is resilient.

**Bonus clean-up** (highly recommended):
- Select `FirstName`, then **Transform → Format → Trim** and then **Capitalize Each Word**.
- Repeat for `LastName`.
- This fixes stray spaces and casing like `adriana` → `Adriana`.

### 1.5 Add the billing columns

Adobe does not export billing info, so we enrich the dataset. Add these columns in Power Query — either by editing the source CSV in Excel and re-importing, or by using **Add Column → Custom Column** for defaults and then overriding per-user in the source.

| Column       | Type      | Purpose                                                             | Example                       |
|--------------|-----------|---------------------------------------------------------------------|-------------------------------|
| `Status`     | Text      | `Active` or `Inactive` — see logic below                            | `Active`                      |
| `Company`    | Text      | Sub-entity that owns the user (drives the bill)                     | `Unicare 247`                 |
| `Product1`   | Text      | Primary Adobe license                                               | `Acrobat Pro`                 |
| `Price1`     | Decimal   | Monthly cost of Product1 in your billing currency                   | `23.99`                       |
| `Product2`   | Text      | Secondary license (blank if none)                                   | `Creative Cloud All Apps`     |
| `Price2`     | Decimal   | Monthly cost of Product2                                            | `59.99`                       |
| `Notes`      | Text      | Free text — contract exceptions, access carve-outs, etc.            | `Retained for legal archive`  |

#### 1.5.1 Active vs. Inactive logic (retain-but-don't-bill)

A former employee whose **files, forms, or signed PDFs must be retained** keeps their Adobe ID but should **not** be billed to a sub-company. Use this convention:

- `Active` → employee is currently with the company and the sub-company is billed.
- `Inactive` → user exists in Adobe for data retention only; **excluded from billing totals** via DAX (see §2.3).

Recommended workflow to flip a user to Inactive:
1. Leave the Adobe license in place (do **not** delete the user — you would lose document access).
2. In the source CSV, set `Status = Inactive` and clear `Price1`/`Price2` (or leave them — our measures will ignore them).
3. Add a `Notes` entry like `Offboarded 2026-03-15; retained for audit`.

### 1.6 Optional — automate Status from a Last Login Date

If you add a `Last Login Date` column (see Appendix A), you can derive Status automatically instead of maintaining it by hand.

1. **Add Column → Conditional Column**. Name it `Status (auto)`.
2. Rule: `if [Last Login Date] is null then "Inactive" else if [Last Login Date] < Date.AddDays(DateTime.LocalNow(), -90) then "Inactive" else "Active"`.
3. If you prefer, replace the manual `Status` column with this one.

### 1.7 Close & Apply

When your Power Query preview looks right:
- Click **Home → Close & Apply**.
- Power BI will load the `Users` table into the model. You now have a clean data foundation.

---

## Part 2 — Data Modeling (Calculations)

This is where we turn rows into business answers. Switch to the **Table view** (the grid icon on the left rail) and then the **Model view** to see relationships.

### 2.1 Total Price — calculated column vs. measure

You asked for a **Total Price**. There are two ways, and each has a right time to use it.

**Option A — Calculated Column (row-level total):**
Use this when you want Total Price to appear as a value on every row in a table visual.

```DAX
Total Price =
    COALESCE ( Users[Price1], 0 ) + COALESCE ( Users[Price2], 0 )
```

**Option B — Measure (aggregated total):**
Use this for Cards and slicer-reactive totals. This is the CFO-grade version.

```DAX
Total Billable =
    CALCULATE (
        SUMX (
            Users,
            COALESCE ( Users[Price1], 0 ) + COALESCE ( Users[Price2], 0 )
        ),
        Users[Status] = "Active"
    )
```

> **Mentor tip:** Create **both**. The calculated column gives row-level visibility in a table; the measure gives a filter-aware grand total for cards and matrices. They do not conflict.

### 2.2 KPI measures the CFO will actually care about

Create these in a dedicated measures table. In the Home ribbon: **Enter data → Table name `_Measures` → Load**. Put all measures here so they are easy to find.

```DAX
Active Users =
    CALCULATE ( COUNTROWS ( Users ), Users[Status] = "Active" )

Inactive Users =
    CALCULATE ( COUNTROWS ( Users ), Users[Status] = "Inactive" )

Total Licenses =
    SUMX (
        FILTER ( Users, Users[Status] = "Active" ),
        ( IF ( NOT ISBLANK ( Users[Product1] ), 1, 0 ) )
      + ( IF ( NOT ISBLANK ( Users[Product2] ), 1, 0 ) )
    )

Avg Cost per Active User =
    DIVIDE ( [Total Billable], [Active Users] )

Companies Billed =
    CALCULATE ( DISTINCTCOUNT ( Users[Company] ), Users[Status] = "Active" )
```

### 2.3 Why we exclude Inactive from billing (but keep them visible)

The pattern above applies `Users[Status] = "Active"` inside `CALCULATE`. That means:
- The **Inactive** users still appear in the table (for audit).
- Their costs are **excluded** from the invoice totals automatically.
- If Legal needs to prove a user was retained for records, the data is right there.

### 2.4 Relationships and the billing header

Create a tiny **disconnected table** to hold the header info so it renders cleanly in cards. In the Home ribbon: **Enter data**:

| Field            | Value                                     |
|------------------|-------------------------------------------|
| Contract ID      | `96XXXXXXXXXXX`                           |
| Billing Contact  | `accounting@yourcompany.com`              |
| Billing Due Date | `2026-05-01`                              |
| Payment Method   | `Card ending XXXX`                        |

Name the table **`BillingHeader`**. Do **not** relate it to `Users` — it is intentionally disconnected. Each field will power a single card in the report header.

---

## Part 3 — Visual Design (The Dashboard)

A great CFO report has three zones on one page:
1. **Header strip** (static admin info).
2. **KPI strip** (big numbers).
3. **Detail zone** (slicers + table for drill-down).

Switch to the **Report view** (the chart icon on the left rail).

### 3.1 Page setup

- **View → Page view → Actual size**.
- **Format page** (paint-roller icon, with nothing selected) → **Canvas settings → Type: 16:9**.
- Add a subtle background color (`#F7F7F9` is a good neutral).

### 3.2 Header strip (static admin info)

Place four **Card** visuals across the top. For each, drag the matching `BillingHeader` field into **Fields**.

| Card            | Field                   | Suggested label          |
|-----------------|-------------------------|--------------------------|
| Card 1          | `Contract ID`           | Adobe Contract ID        |
| Card 2          | `Billing Contact`       | Billing Contact          |
| Card 3          | `Billing Due Date`      | Next Invoice Due         |
| Card 4          | `Payment Method`        | Payment Method           |

Add a **Text box** above the cards with your report title, e.g. `Adobe License Billing — FY26`. Tuck today's date into a small text box on the right with the DAX snippet below in a measure card:

```DAX
Report As Of = "Report as of " & FORMAT ( TODAY (), "mmmm d, yyyy" )
```

### 3.3 KPI strip

Below the header, add five **Card** visuals. The CFO should see the invoice total within two seconds of opening the file.

1. **Total Billable** (format as currency).
2. **Active Users**.
3. **Inactive Users** (muted grey so it doesn't compete).
4. **Companies Billed**.
5. **Avg Cost per Active User** (format as currency).

Format each card: larger data label (36–44pt), subtle category label underneath.

### 3.4 Slicers (left rail)

Slicers are the filters your CFO will click. Add three slicers down the left side:
1. **Company** — dropdown style; this is the single most important filter.
2. **Status** — horizontal button style, default to `Active` selected.
3. **Product1** — dropdown; handy when Accounting needs "show me only Acrobat Pro seats."

> **Mentor tip:** In each slicer's format pane, turn on **Select all** and **Search**. Your CFO will thank you the first time the company list hits 20 rows.

### 3.5 Detail table (or matrix)

The centerpiece. Use a **Matrix** visual (better than a Table for billing because it supports subtotals).

- **Rows:** `Company`, then `LastName`, `FirstName` (nested).
- **Columns:** leave empty (or add `Product1` if you want a pivot).
- **Values:** `Email`, `Status`, `Product1`, `Price1`, `Product2`, `Price2`, `Total Price`, `Notes`.
- **Format → Row subtotals:** On. This gives each sub-company a subtotal row — exactly the invoice breakdown Accounting needs.
- **Format → Grand total:** On.
- Right-click the `Total Price` column header → **Conditional formatting → Background color** → a light gradient makes heavy users pop.

### 3.6 Supporting visuals (optional but polished)

- **Donut chart:** `Total Billable` by `Company` — instant "who owes the most" snapshot.
- **Bar chart:** `Active Users` by `Department` (see Appendix A).
- **Line chart:** `Total Billable` over time (requires a monthly refresh history — create a dated snapshot folder).

### 3.7 Export for Accounting

The CFO usually wants a PDF attached to a monthly email. From Power BI Desktop: **File → Export → Export to PDF**. Once published online, viewers can also **Export → PDF** directly from the browser.

---

## Part 4 — Publish, Share, and Refresh

1. **Home → Publish** → pick a Pro workspace (e.g. `Finance - Adobe Billing`).
2. In the Power BI Service, open the dataset → **Settings → Scheduled refresh**. Set a monthly cadence aligned with your Adobe invoice date.
3. Share via **Apps** (preferred for Accounting) or direct workspace access.
4. For row-level security (so each sub-company only sees its own rows), add a `Security` role:
   ```DAX
   [Company] = USERPRINCIPALNAME()
   ```
   Map that to a mapping table if emails don't match company names directly.

---

## Appendix A — Professional Add-on Columns

These three additions push the report from "good" to "enterprise-grade." Pick the ones that fit your operating rhythm.

### A.1 Department
- **What:** Which functional team the user belongs to (Marketing, Legal, Finance…).
- **Why:** Lets the CFO slice cost by function, not just sub-company. Great for budgeting.
- **How:** Add a `Department` text column in the source. In the report, add it as a second-level slicer or a bar chart.

### A.2 Last Login Date
- **What:** Most recent Adobe sign-in timestamp. Adobe Admin Console exposes this in usage reports.
- **Why:** Drives the auto-Status logic in §1.6 and exposes unused seats. The #1 money-saver.
- **How:** Import the usage CSV, merge on Email in Power Query, type as Date.

### A.3 License Utilization %
- **What:** Share of assigned seats that actually logged in in the last 30 days.
- **Why:** Shows the CFO where to reclaim licenses — every dormant seat is a refund opportunity.
- **How:** Add a measure:
  ```DAX
  License Utilization % =
      DIVIDE (
          CALCULATE (
              [Active Users],
              Users[Last Login Date] >= TODAY () - 30
          ),
          [Active Users]
      )
  ```
  Format as Percentage and drop on a KPI card.

### A.4 (Bonus) Cost Center / GL Code
- **What:** The Accounting code each sub-company uses in the ERP.
- **Why:** Lets Accounting paste the matrix straight into the journal entry.

---

## Appendix B — Full DAX Reference

All measures in one place, ready to copy into your `_Measures` table.

```DAX
Total Billable =
    CALCULATE (
        SUMX (
            Users,
            COALESCE ( Users[Price1], 0 ) + COALESCE ( Users[Price2], 0 )
        ),
        Users[Status] = "Active"
    )

Active Users =
    CALCULATE ( COUNTROWS ( Users ), Users[Status] = "Active" )

Inactive Users =
    CALCULATE ( COUNTROWS ( Users ), Users[Status] = "Inactive" )

Total Licenses =
    SUMX (
        FILTER ( Users, Users[Status] = "Active" ),
        ( IF ( NOT ISBLANK ( Users[Product1] ), 1, 0 ) )
      + ( IF ( NOT ISBLANK ( Users[Product2] ), 1, 0 ) )
    )

Avg Cost per Active User =
    DIVIDE ( [Total Billable], [Active Users] )

Companies Billed =
    CALCULATE ( DISTINCTCOUNT ( Users[Company] ), Users[Status] = "Active" )

License Utilization % =
    DIVIDE (
        CALCULATE (
            [Active Users],
            Users[Last Login Date] >= TODAY () - 30
        ),
        [Active Users]
    )

Report As Of = "Report as of " & FORMAT ( TODAY (), "mmmm d, yyyy" )
```

And the row-level calculated column:

```DAX
Total Price = COALESCE ( Users[Price1], 0 ) + COALESCE ( Users[Price2], 0 )
```

---

## You're Done!

You have just built the same style of report a Big 4 BI consultant would hand over. Refresh it monthly, review the Inactive bucket quarterly, and act on the Utilization % to keep Adobe spend honest.

If anything looks off, the fastest debug path is almost always **Power Query → View → Advanced Editor** to inspect the M script, or **Model view → Relationships** to confirm `BillingHeader` is disconnected. Happy reporting!
