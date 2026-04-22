// ============================================================================
// PowerQuery-Users.m
// ----------------------------------------------------------------------------
// Paste this into Power BI Desktop:
//   1. Get data -> Blank Query
//   2. Home -> Advanced Editor
//   3. Delete the existing text, paste everything below, click Done
//   4. In the Query Settings pane, rename the query to:  Users
//   5. Update the file path in Source (row below) to point to YOUR CSV
//   6. Home -> Close & Apply
//
// What this script does (matches the tutorial):
//   - Loads the Adobe users CSV (or the blank template)
//   - Promotes the header row
//   - Splits "Name" into FirstName + LastName using LEFT-MOST space
//     (so "Mary Jane Smith" -> FirstName="Mary", LastName="Jane Smith")
//   - Trims + title-cases FirstName and LastName
//   - Applies clean data types for every column
// ============================================================================
let
    // ---- EDIT THIS PATH ----------------------------------------------------
    SourcePath = "C:\Users\YOU\Documents\adobe-users-template.csv",
    // ------------------------------------------------------------------------

    Source = Csv.Document(
        File.Contents(SourcePath),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromoteHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // Split Name on the LEFT-MOST space -> Name.1 (FirstName) + Name.2 (LastName)
    SplitName = Table.SplitColumn(
        PromoteHeaders,
        "Name",
        Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, false),
        {"Name.1", "Name.2"}
    ),
    RenameFirst = Table.RenameColumns(SplitName, {{"Name.1", "FirstName"}, {"Name.2", "LastName"}}),

    // Clean up casing and stray spaces
    TrimFirst  = Table.TransformColumns(RenameFirst, {{"FirstName", Text.Trim, type text}, {"LastName", Text.Trim, type text}}),
    ProperCase = Table.TransformColumns(TrimFirst,  {{"FirstName", Text.Proper, type text}, {"LastName", Text.Proper, type text}}),

    // Apply column types
    Typed = Table.TransformColumnTypes(ProperCase, {
        {"FirstName",        type text},
        {"LastName",         type text},
        {"Email",            type text},
        {"ID type",          type text},
        {"Status",           type text},
        {"Company",          type text},
        {"Product1",         type text},
        {"Price1",           Currency.Type},
        {"Product2",         type text},
        {"Price2",           Currency.Type},
        {"Last Login Date",  type date},
        {"Department",       type text},
        {"Notes",            type text}
    })
in
    Typed
