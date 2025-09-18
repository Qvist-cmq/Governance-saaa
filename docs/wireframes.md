# Wireframes

## Dashboard
```
+----------------------------------------------------------------------------------+
|  Left Nav        | Dashboard                                                     |
|------------------+----------------------------------------------------------------|
| > Dashboard      |  [Tenant Logo] Governance Overview                             |
|   Documents      |  -----------------------------------------------------------  |
|   Questionnaires |  KPIs Row: [Controls Coverage 86%] [Upcoming Reviews 7]        |
|   Controls       |            [Questionnaires Due 3] [Incidents 0]               |
|   Mappings       |  -----------------------------------------------------------  |
|   Reports        |  Cards grid (2x2):                                            |
|   Tasks          |   [Review Queue] [Active Questionnaires]                      |
|   Data Admin     |   [Control Effectiveness] [Open Tasks]                        |
|   Audit Log      |  Timeline: Latest approvals, submissions                      |
|                  |  Table: Upcoming expiries (document, date, owner, status)     |
+----------------------------------------------------------------------------------+
```

## Documents List / Detail
```
+----------------------------------------------------------------------------------+
| Left Nav | Documents                                                             |
|----------+------------------------------------------------------------------------|
| > Docs   | Header: [Create Document] [Import]  Filters: Type, Status, Owner       |
|          | --------------------------------------------------------------------   |
|          | Table columns: Title | Type | Owner | Status chip | Next Review | Tags |
|          | Row click -> right drawer or full detail                               |
|          |                                                                        |
| Detail View:                                                                      |
|  Breadcrumbs: Documents > Policy > Information Security Policy                    |
|  Header: Title, Status chip, Version dropdown, Actions (Submit, Approve, Publish) |
|  Metadata sidebar: Owner, Scope, Systems, Classification, Linked Controls         |
|  Main area tabs: [Overview] [Content] [Versions] [History] [Tasks]                |
|   - Content tab: Rich text editor with template snippets panel on right           |
|   - Versions tab: list with diff/publish buttons                                  |
+----------------------------------------------------------------------------------+
```

## Document Editor Flow
```
+---------------------------------------------------------------+
| Toolbar: Save Draft | Submit for Review | Preview | Comments   |
|---------------------------------------------------------------|
| Main Editor Canvas (rich text, sections collapsible)          |
| Right Panel:                                                 |
|  - Outline (sections drag/drop)                              |
|  - Linked Controls (chips, add)                              |
|  - Guidance tips (inline examples)                           |
+---------------------------------------------------------------+
```

## Questionnaire Builder
```
+----------------------------------------------------------------------------------+
| Left Nav | Questionnaire Builder                                                 |
|----------+------------------------------------------------------------------------|
| > Q's    | Header: [Create from Template] [Import]                                |
|          | Stage indicators: 1) Basics 2) Sections 3) Assign 4) Review & Publish  |
|          | Basics: Name, Description, Tags, Framework alignment toggles           |
|          | Sections canvas:                                                       |
|          |  - List of sections on left with reorder                               |
|          |  - Selected section detail: title, description                         |
|          |  - Questions list with card UI (type icon, prompt, controls linked)    |
|          |  - Add question drawer: choose type, add options, guidance             |
|          | Assign: table of users/groups with due dates and reminders             |
|          | Review: summary + workflow launch                                      |
+----------------------------------------------------------------------------------+
```

## Controls Catalogue
```
+----------------------------------------------------------------------------------+
| Left Nav | Controls                                                               |
|----------+-------------------------------------------------------------------------|
| > Ctrl   | Header: [Import from Library] [Add Control] [Export CSV]                |
|          | Filters: Framework (ISO 27001/NIS2), Status, Owner, Effectiveness       |
|          | Table: Code | Title | Framework refs | Owner | Status chip | Last Test  |
|          | Row detail drawer:                                                      |
|          |   Tabs [Overview][Tests][Mappings][Evidence]                            |
|          |   Overview: description, schedule, attachments                          |
|          |   Mappings: list of linked documents/questionnaires                     |
+----------------------------------------------------------------------------------+
```

## Mapping / Coverage View
```
+----------------------------------------------------------------------------------+
| Left Nav | Coverage Matrix                                                        |
|----------+------------------------------------------------------------------------|
| > Map    | Top controls: Framework selector, filters (Gap only, Status)           |
|          | Heatmap grid: Controls (rows) vs Artifacts (columns)                   |
|          |  Cell states: Covered (green), Partial (amber), Gap (red)               |
|          | Side panel shows selected control details + linked evidence            |
|          | Gap call-to-action buttons: [Create Task] [Link Document]              |
|          | Export buttons: [CSV] [PDF]                                            |
+----------------------------------------------------------------------------------+
```
