# HRIS Data Quality & People Reporting — Data Dictionary

## Dataset
- File: `employees_raw.csv`
- Records: 250 synthetic employee rows.
- As-of date for date checks: `2026-10-26`.
- Purpose: demonstrate HRIS data-quality checks; this is not real employee data.
- The raw file intentionally contains known quality issues. Do not treat it as analysis-ready until validation is performed.

## Fields
| Field | Meaning | Expected rules / values |
|---|---|---|
| `EmployeeID` | Employee identifier | Required and unique per employee record. |
| `HireDate` | Employment start date | Required; valid ISO date `YYYY-MM-DD`; not after 2026-10-26. |
| `TerminationDate` | Employment end date | Optional for active/on-leave employees; valid date when present; not before hire date or after 2026-10-26. |
| `EmploymentStatus` | Current employment status | `Active`, `Terminated`, or `On Leave`. |
| `Department` | Department | Required; `Engineering`, `Finance`, `Human Resources`, `Sales`, `Operations`, `IT`, `Customer Success`, or `Product`. |
| `JobLevel` | Role level | Integer 1–5. |
| `JobTitle` | Role title | Should be broadly consistent with `JobLevel`; title/level matching is a review flag, not an automatic truth claim. |
| `MonthlySalaryEUR` | Gross monthly salary in euros | Required, positive numeric amount; review against level-specific ranges. |
| `PerformanceRating` | Performance rating | Integer 1–5. |
| `ManagerID` | EmployeeID of the manager | Optional for top-level managers; when present should refer to an existing EmployeeID and must not equal the employee's own ID. |
| `Country` | Country of employment | Required; `Portugal`, `France`, `Spain`, `Ireland`, `Germany`, `Brazil`, `Canada`, or `Netherlands`. |
| `EmploymentType` | Type of employment | `Full-time`, `Part-time`, or `Contract`. |

## Salary reference ranges used for validation practice
| JobLevel | Label | Minimum EUR/month | Maximum EUR/month |
|---:|---|---:|---:|
| 1 | Entry | 1800 | 3000 |
| 2 | Intermediate | 2600 | 4200 |
| 3 | Senior | 3600 | 5600 |
| 4 | Lead / Manager | 4800 | 7200 |
| 5 | Director / Principal | 6200 | 9500 |

These ranges are illustrative synthetic reference bands, not market benchmarks or recommendations. Overlaps are intentional. A salary outside a range is an exception for review, not proof of incorrect pay.

## Deliberately introduced issues
The dataset includes examples of missing and duplicated employee IDs, missing/invalid/future dates, status/termination-date inconsistencies, missing or unapproved departments and countries, zero/negative/missing/out-of-band salaries, invalid job levels, invalid performance ratings, unknown/self-referencing managers, missing employment status/type, and a job-title/job-level mismatch.

## Reporting principles
- Keep raw and validated data separate.
- Preserve source values and create validation flags rather than silently overwriting records.
- Define denominators before calculating data-quality rates.
- `EmployeeID` duplicates mean raw row count and distinct employee count can differ.
- The as-of date is fixed for reproducibility; update it explicitly if the project date changes.
