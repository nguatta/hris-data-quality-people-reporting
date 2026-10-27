# HRIS Data Quality & People Reporting

## Project Overview

This independent portfolio project demonstrates how SQL and Power BI can be used to assess HRIS data quality and prepare reliable People Reporting metrics.

The project uses synthetic HR data containing deliberately introduced data-quality issues. It is designed to simulate common validation tasks performed by HR Data Analysts, HRIS Analysts, and People Analytics teams.

**Project status: Completed — portfolio version.

**Tools:** SQL, SQLite, Power BI, Power Query, and DAX.

## Business Objectives

- Assess the completeness and consistency of employee records.
- Identify duplicate employee IDs and missing mandatory fields.
- Detect invalid dates and inconsistent employment statuses.
- Validate salary values and job-level classifications.
- Produce a transparent record of data-quality exceptions.
- Prepare reliable workforce reporting metrics.

## Initial Data Quality Checks Completed

1. Employee ID uniqueness and completeness.
2. Required-field completeness.
3. Valid hire dates and termination dates.
4. Consistency between employment status and termination date.
5. Positive and valid salary values.
6. Valid job levels and performance ratings.
7. Consistency of manager references.

## Initial SQL Audit Results

The initial SQL data-quality audit was executed
successfully using SQLite.

| Metric | Result |
|---|---:|
| Total employee records | 250 |
| Records flagged by at least one rule | 109 |
| Records with no detected exceptions | 141 |
| Data-quality exception rate | 43.6% |

The audit identified 24 exception types with
non-zero counts across the implemented checks.

Key findings include 57 unmatched manager references,
35 ambiguous manager references associated with
the duplicated EmployeeID EMP0006, and one
self-referencing manager relationship.

These results describe synthetic data and do not
represent a real organisation.

## People Reporting Metrics

The following measures are implemented in the Power BI report.

| Metric | Result | Definition |
|---|---:|---|
| Total employee records | 250 | All source records |
| Eligible records | 247 | Records with a non-missing, non-duplicated EmployeeID |
| Active headcount | 164 | Distinct eligible EmployeeIDs with Active status |
| Terminated employees | 66 | Distinct eligible EmployeeIDs with Terminated status |
| Flagged records | 109 | Records with at least one data-quality flag |
| Records with no detected exceptions | 141 | Records where has_any_issue_flag = 0 |
| Data-quality exception rate | 43.6% | Flagged records divided by total source records |

Eligibility for People Reporting excludes missing or duplicated
EmployeeIDs. Other data-quality flags are retained for investigation
and are not automatically excluded from headcount.

## Key DAX Measures

The Power BI dashboard uses the following measures.

### Total Records

```dax
Total Records =
COUNTROWS('employees_quality_export')

Flagged Records =
CALCULATE(
    [Total Records],
    KEEPFILTERS(
        'employees_quality_export'[has_any_issue_flag] = 1
    )
)
Clean Records =
CALCULATE(
    [Total Records],
    KEEPFILTERS(
        'employees_quality_export'[has_any_issue_flag] = 0
    )
)

Exception Rate =
DIVIDE([Flagged Records], [Total Records], 0)

Eligible Records =
CALCULATE(
    COUNTROWS('employees_quality_export'),
    KEEPFILTERS(
        'employees_quality_export'[employee_id_missing_flag] = 0
    ),
    KEEPFILTERS(
        'employees_quality_export'[employee_id_duplicate_flag] = 0
    )
)

Active Headcount =
CALCULATE(
    DISTINCTCOUNT('employees_quality_export'[EmployeeID]),
    KEEPFILTERS(
        'employees_quality_export'[EmploymentStatus] = "Active"
    ),
    KEEPFILTERS(
        'employees_quality_export'[employee_id_missing_flag] = 0
    ),
    KEEPFILTERS(
        'employees_quality_export'[employee_id_duplicate_flag] = 0
    )
)

Terminated Employees =
CALCULATE(
    DISTINCTCOUNT('employees_quality_export'[EmployeeID]),
    KEEPFILTERS(
        'employees_quality_export'[EmploymentStatus] = "Terminated"
    ),
    KEEPFILTERS(
        'employees_quality_export'[employee_id_missing_flag] = 0
    ),
    KEEPFILTERS(
        'employees_quality_export'[employee_id_duplicate_flag] = 0
    )
)


### 3. Documentar a hipótese sobre EMP0017

Como apresentámos `EMP0017` em Human Resources no gráfico, acrescenta esta nota à secção `Methodological Note`:

```markdown
The missing department for EMP0017 is displayed as Human Resources
for illustrative reporting purposes, based on the employee's job title.
This assignment is an assumption, not a verified source-data correction.
The original Department field remains missing, and the original
data-quality flag is preserved.




## Power BI Dashboard

### 01 — Data Quality Overview

![Data Quality Overview](screenshots/01_data_quality_overview.png)

Displays total records, flagged records, records with no detected
exceptions, exception rate, flagged records by department, and
exceptions by issue type.

### 02 — People Reporting

![People Reporting](screenshots/02_people_reporting.png)

Displays eligible records, active headcount, terminated employees,
active headcount by department, and terminated employees by department.

## Methodological Note

Data-quality flags identify records requiring review; they do not
establish that records are factually incorrect.

The dataset is synthetic and does not represent a real organisation.

## Repository Structure

```text
hris-data-quality-people-reporting/
├── data/
│   ├── employees_raw.csv
│   ├── hris_data_dictionary.md
│   └── sql/
│       ├── 01_data_quality_profile.sql
│       └── README.md
├── reports/
│   └── data_quality_findings.md
└── README.md
```
- `data/` — synthetic HR employee dataset and data dictionary.
- `data/sql/` — SQL scripts for data profiling and quality validation.
- `reports/` — documented data-quality findings and recommended actions.
- `README.md` — project overview, objectives, methodology, and documentation links.

## Data Privacy and Limitations

All data will be synthetic and created for learning and portfolio demonstration.

The project does not represent an actual company's HRIS implementation. Data-quality flags identify records requiring review; they do not automatically establish that the underlying records are factually incorrect.

Reporting results will be documented with their definitions, assumptions, and limitations.

## Project Documentation

### HRIS Data Quality Findings

The initial SQL audit results, key data-quality issues, and recommended follow-up actions are documented in the following report:

[Read the HRIS Data Quality Findings](reports/data_quality_findings.md)

### SQL Analysis

The SQL validation script used to profile employee records and identify data-quality exceptions is available here:

[View the SQL Data Quality Profile](data/sql/01_data_quality_profile.sql)


