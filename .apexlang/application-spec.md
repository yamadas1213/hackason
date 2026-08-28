# Customer Insights — Application Specification

## Summary

- Application purpose: Analyze imported customer, sales, and churn data.
- Target users: Authenticated `CUSTOMER_INSIGHTS` workspace users.
- Authoritative sources: Live dictionary metadata from `CUSTOMER_INSIGHTS`.
- Target app path: `/home/opc/hackason/customer-insights-apex`
- Destination workspace: `CUSTOMER_INSIGHTS`
- Runtime mode: Live DB validation and import.

## Requirement Coverage Matrix

| ID | Requirement | Planned scope | Status |
| --- | --- | --- | --- |
| FR-001 | Show business KPIs and sales by genre | Page 1 Dashboard | covered |
| FR-006 | Compare genre views by gender, region, male audience, payment method, income level, and strong-wind days | Page 1 Dashboard | covered |
| FR-002 | Search and download customer data | Page 2 Customers | covered |
| FR-003 | Analyze sales transactions | Future Page 3 Sales Analysis | backlog |
| FR-004 | Analyze churn details | Future Page 4 Churn Analysis | backlog |
| FR-005 | Review customer feedback | Future Page 5 Customer Feedback | backlog |

## Source Evidence Matrix

| Object | Required columns | Evidence |
| --- | --- | --- |
| CUSTOMER | CUST_ID, FIRST_NAME, LAST_NAME, EMAIL, CITY, STATE_PROVINCE, COUNTRY, AGE, GENDER, CREDIT_BALANCE, INCOME, INCOME_LEVEL, SEGMENT_ID | live DB dictionary |
| CUSTSALES | DAY_ID, GENRE_ID, CUST_ID, PAYMENT_METHOD, ACTUAL_PRICE | live DB dictionary and verified row count of 25,037,621; all CUST_ID values match CUSTOMER; DAY_ID is NULL for all rows after CSV import |
| GENRE | GENRE_ID, NAME | live DB dictionary |
| MOVIESTREAM_CHURN | IS_CHURNER | live DB dictionary; values verified as 0 and 1 |
| WEATHER | REPORTED_DATE, WIND_AVG | live DB dictionary; 731 daily rows |
| Source CSV snapshot | DAY_ID, GENRE_ID | local imported-source CSVs; used only for the strong-wind-day snapshot because CUSTSALES.DAY_ID is NULL |

## Frozen Application Plan

| Page | Name | Native pattern | Menu | Primary source |
| --- | --- | --- | --- | --- |
| 1 | Dashboard | Metric Cards and seven native charts | Dashboard | CUSTOMER, CUSTSALES, GENRE, MOVIESTREAM_CHURN, WEATHER, imported-source CSV snapshot |
| 2 | Customers | Interactive Report | Customers | CUSTOMER |

## Frozen Region Plan

| Page | Order | Region | Component | Source |
| --- | --- | --- | --- | --- |
| 1 | 1 | Key Metrics | Metric Card | Customer count, transaction count, total actual sales, churn rate |
| 1 | 2 | Sales by Genre | Pie Chart | CUSTSALES joined to GENRE |
| 1 | 3 | Genre Views by Gender | Bar Chart | Transaction count grouped by CUSTOMER.GENDER and GENRE.NAME |
| 1 | 4 | Top Genres by Region | Bar Chart | Top three genres per CUSTOMER.STATE_PROVINCE by transaction count |
| 1 | 5 | Top 10 Genres Viewed by Men | Bar Chart | Top ten genres where CUSTOMER.GENDER is Male |
| 1 | 6 | Payment Method Share | Pie Chart | Transaction count grouped by CUSTSALES.PAYMENT_METHOD |
| 1 | 7 | Genre Share by Income Level | Bar Chart | Top ten overall genres shown as percentage within CUSTOMER.INCOME_LEVEL |
| 1 | 8 | Top Genres on Strong-Wind Days | Bar Chart | Top ten genres on dates where WEATHER.WIND_AVG is at least 15 |
| 2 | 1 | Customers | Interactive Report | CUSTOMER |

## Application Composition Plan

- Page 1 is the root page and contains one four-card KPI row, the existing full-width Sales by Genre row, and three equal-width two-chart rows below it.
- The three two-chart rows use explicit six-column spans while preserving `startNewRow: false` on the second chart in each row, matching the local dashboard layout validator.
- Page 2 is a child of Page 1 and contains one full-width interactive report.
- Navigation menu and breadcrumb entries are declared for both pages.
- All business pages require an authenticated APEX workspace account.
- Reports are read-only; create, update, and delete actions are outside this iteration.

## Generation Readiness

- Canonical patterns: dashboard page, metric card, pie chart, interactive report.
- Compiler truth: Oracle APEXlang 26.1 compiler shipped with Oracle SQL Developer 26.2.1.
- Local validation: Required before live validation.
- Live validation: Required before import.
- Import target: `CUSTOMER_INSIGHTS` workspace through saved SQLcl connection `hackason-adb-customer-insights`.

## Test Plan

| Scenario | Expected Result | Validation Method |
| --- | --- | --- |
| Dashboard metrics | Customer 148,129; transactions 25,037,621; total sales 6,401,541,370.50; churn 474 of 1,433 | Compare page output with SQL aggregates |
| Sales by genre | One slice per GENRE value represented in CUSTSALES | Compare chart SQL with direct query |
| Genre views by gender | 72 rows across Male, Female, and Non-binary series | Compare chart SQL with direct grouped query |
| Top genres by region | Up to three genre series for each populated state/province | Compare chart SQL with ranked grouped query |
| Male genre ranking | Ten genres, led by ドラマ with 2,342,936 views | Compare chart SQL with direct grouped query |
| Payment method share | Five methods totaling 25,037,621 transactions | Compare chart SQL with direct grouped query |
| Genre share by income level | Top ten genres, normalized within each of six income levels | Compare chart SQL with grouped and analytic query |
| Strong-wind genres | Top ten genre counts for the 87 dates with WIND_AVG >= 15 | Compare embedded snapshot with source CSV and WEATHER aggregation |
| Customer report | CUSTOMER columns are searchable, filterable, sortable, and downloadable | Open Page 2 and exercise Actions menu |
| Navigation | Dashboard and Customers entries open Pages 1 and 2 | Runtime UI verification |

## Assumptions

- English chart titles are acceptable; genre, region, and income values remain in the imported Japanese data.
- A strong-wind day is defined as `WIND_AVG >= 15`, approximately the top 10% of the 731 weather rows.
- The strong-wind chart is a fixed snapshot computed from the same imported-source CSV files because the loaded `CUSTSALES.DAY_ID` column contains only NULL values. No base table is reloaded or destructively modified.
- No row-level authorization beyond authenticated workspace access is required for this preview.

## Missing Inputs / Blockers

- None for generation or live validation.
