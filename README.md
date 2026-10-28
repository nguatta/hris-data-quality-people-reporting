# HRIS Data Quality & People Reporting

**Portfolio project | SQL · SQLite · Power Query · Power BI · DAX**  
Audit of 250 synthetic HR records and preparation of workforce reporting metrics.

**Status:** Portfolio version complete. Screenshots are provided below; no public interactive Power BI link is currently available.

## Dashboard

### 01 — Data Quality Overview

![Data Quality Overview](screenshots/01_data_quality_overview.png)

### 02 — People Reporting

![People Reporting](screenshots/02_people_reporting.png)

## SQL Audit Results

| Metric | Result |
|---|---:|
| Total records | 250 |
| Records flagged by at least one rule | 109 |
| Records with no detected exceptions | 141 |
| Data-quality exception rate | 43.6% |

The audit covers seven validation areas: employee ID completeness and uniqueness, required fields, date validity, employment-status consistency, salary validity, job and performance data, and manager references. Key findings include 57 unmatched manager references, 35 ambiguous manager references, one self-referencing manager relationship, and three employment-status/termination-date inconsistencies. One record can trigger multiple rules; issue counts are not unique-employee counts.

## People Reporting Metrics

| Metric | Result | Definition |
|---|---:|---|
| Eligible records | 247 | EmployeeID present and not flagged as duplicate |
| Active headcount | 164 | Distinct eligible IDs with Active status |
| Terminated employees | 66 | Distinct eligible IDs with Terminated status |

Missing or duplicated EmployeeIDs are excluded from these People Reporting measures. Other quality flags remain available for review and are not automatically excluded from headcount.

## Key DAX Measures

```dax
Total Records = COUNTROWS('employees_quality_export')

Flagged Records =
CALCULATE(
    [Total Records],
    KEEPFILTERS('employees_quality_export'[has_any_issue_flag] = 1)
)

Clean Records =
CALCULATE(
    [Total Records],
    KEEPFILTERS('employees_quality_export'[has_any_issue_flag] = 0)
)

Exception Rate = DIVIDE([Flagged Records], [Total Records], 0)

Eligible Records =
CALCULATE(
    COUNTROWS('employees_quality_export'),
    KEEPFILTERS('employees_quality_export'[employee_id_missing_flag] = 0),
    KEEPFILTERS('employees_quality_export'[employee_id_duplicate_flag] = 0)
)

Active Headcount =
CALCULATE(
    DISTINCTCOUNT('employees_quality_export'[EmployeeID]),
    KEEPFILTERS('employees_quality_export'[EmploymentStatus] = "Active"),
    KEEPFILTERS('employees_quality_export'[employee_id_missing_flag] = 0),
    KEEPFILTERS('employees_quality_export'[employee_id_duplicate_flag] = 0)
)

Terminated Employees =
CALCULATE(
    DISTINCTCOUNT('employees_quality_export'[EmployeeID]),
    KEEPFILTERS('employees_quality_export'[EmploymentStatus] = "Terminated"),
    KEEPFILTERS('employees_quality_export'[employee_id_missing_flag] = 0),
    KEEPFILTERS('employees_quality_export'[employee_id_duplicate_flag] = 0)
)
```

Format `Exception Rate` as a percentage. `Terminated Employees` is a count of eligible records with Terminated status, not an annual attrition rate.

## Methodology & Limitations

Data-quality flags identify records requiring review; they do not establish that records are factually incorrect. The dataset is synthetic and does not represent a real organisation.

For visualisation only, the missing department for `EMP0017` is displayed as **Human Resources**, based on the job title. This is an assumption, not a verified correction; the original `Department` value and data-quality flag remain unchanged. `Human Capital` is shown as unapproved under the project's validation rules.

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
├── screenshots/
│   ├── 01_data_quality_overview.png
│   └── 02_people_reporting.png
└── README.md
```

**Project documentation:** [SQL audit](data/sql/01_data_quality_profile.sql) · [Data-quality findings](reports/data_quality_findings.md)
