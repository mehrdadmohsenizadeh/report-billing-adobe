// ============================================================================
// PowerQuery-BillingHeader.m
// ----------------------------------------------------------------------------
// Paste this into Power BI Desktop:
//   1. Get data -> Blank Query
//   2. Home -> Advanced Editor
//   3. Delete the existing text, paste everything below, click Done
//   4. In the Query Settings pane, rename the query to:  BillingHeader
//   5. Edit the values below with your real contract info
//   6. Home -> Close & Apply
//
// IMPORTANT:
//   This table is intentionally DISCONNECTED from the Users table.
//   Do NOT create a relationship between BillingHeader and Users.
//   Each field powers a single Card visual in the report header strip.
// ============================================================================
let
    Source = #table(
        type table [Field = text, Value = text],
        {
            {"Contract ID",      "96XXXXXXXXXXX"},
            {"Billing Contact",  "accounting@yourcompany.com"},
            {"Billing Due Date", "2026-05-01"},
            {"Payment Method",   "Card ending XXXX"}
        }
    )
in
    Source
