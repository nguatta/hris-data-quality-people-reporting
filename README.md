HRIS Data Quality & People Reporting
Portfolio project using SQL, SQLite, Power Query, Power BI and DAX to audit synthetic HR data and prepare workforce reporting metrics.
Status: Completed — portfolio version  
Dataset: 250 synthetic employee records
Dashboard
01 — Data Quality Overview
![Data Quality Overview](screenshots/01_data_quality_overview.png)
02 — People Reporting
![People Reporting](screenshots/02_people_reporting.png)
SQL Audit Results
Metric	Result
Total records	250
Records flagged by at least one rule	109
Records with no detected exceptions	141
Exception rate	43.6%
The audit covers seven validation areas: employee ID completeness and uniqueness, required fields, date validity, employment status consistency, salary validity, job and performance data, and manager references.
Key findings include 57 unmatched manager references, 35 ambiguous manager references, one self-referencing manager relationship, and three status/termination-date inconsistencies. A record can trigger more than one rule, so issue counts are not counts of unique employees.
People Reporting Metrics
Metric	Result	Definition
Eligible records	247	EmployeeID is present and not flagged as duplicate
Active headcount	164	Distinct eligible IDs with Active status
Terminated employees	66	Distinct eligible IDs with Terminated status
The reporting measures exclude records with missing or duplicated EmployeeIDs. Other quality flags remain available for review and are not automatically excluded from headcount.
Key DAX Measures
```dax
Total Records = COUNTROWS('employees_quality_export')

Flagged Records =
CALCULATE([Total Records], KEEPFILTERS('employees_quality_export'[has_any_issue_flag] = 1))

Clean Records =
CALCULATE([Total Records], KEEPFILTERS('employees_quality_export'[has_any_issue_flag] = 0))

Exception Rate = DIVIDE([Flagged Records], [Total Records], 0)
```
The report also includes `Eligible Records`, `Active Headcount`, and `Terminated Employees` measures based on non-missing, non-duplicated employee IDs.
Methodology & Limitations
Source data is synthetic; it does not represent a real organisation.
Data-quality flags identify records requiring review; they do not prove the records are factually incorrect.
`EMP0017` is displayed under Human Resources for illustrative reporting only, based on job title. This is an assumption, not a verified correction; the original Department value and quality flag remain unchanged.
The dashboard screenshots are included in this repository. No public interactive Power BI link is included.
Repository
`data/` — synthetic employee dataset and data dictionary
`data/sql/` — SQL audit script and documentation
`reports/` — data-quality findings
`screenshots/` — Power BI dashboard images
