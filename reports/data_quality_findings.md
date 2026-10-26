# HRIS Data Quality Findings

## Project Status

Initial SQL data-quality checks completed successfully using SQLite.

**Dataset:** Synthetic HR employee records  
**Records analysed:** 250  
**Analysis date:** 26 October 2026  
**Tools:** SQLite, SQL, DB Browser for SQLite

## Overall Results

| Metric | Result |
|---|---:|
| Total employee records | 250 |
| Records flagged by at least one implemented rule | 109 |
| Records with no implemented rule triggered | 141 |
| Records flagged by at least one rule (%) | 43.6% |

These results reflect the validation rules implemented in this portfolio project. Records without a flag are not guaranteed to be completely error-free.

## Confirmed Findings

### 1. Missing Required Fields

Seven records were returned by the initial checks for missing values in seven required fields:

- EmployeeID
- HireDate
- EmploymentStatus
- Department
- MonthlySalaryEUR
- Country
- EmploymentType

### 2. Duplicate Employee IDs

The identifier `EMP0006` appears in two employee records with different hire dates, employment statuses, departments, job levels, and job titles.

This duplicate creates ambiguity for manager references that use `EMP0006`.

### 3. Manager Reference Issues

| Finding | Records affected |
|---|---:|
| Manager references not found in the employee dataset | 57 |
| Ambiguous manager references | 35 |
| Self-referencing manager relationship | 1 |

The 57 records with unmatched manager references were associated with:

| ManagerID | Records affected |
|---|---:|
| EMP0007 | 29 |
| EMP0003 | 27 |
| EMP99999 | 1 |

All 35 ambiguous manager references pointed to `EMP0006`, which appears twice in the employee dataset.

The self-reference was identified in source row 27, where `EmployeeID` and `ManagerID` are both `EMP0027`.

### 4. Other Identified Issues

The validation summary also flagged examples of:

- Inconsistencies between employment status and termination date.
- Invalid job levels.
- Non-positive salary values.
- Salaries outside illustrative reference bands.
- Invalid employment status values.
- Invalid or inconsistent employment dates.

## Recommended Follow-up Actions

1. Review missing and duplicate employee identifiers before using the data for reporting.
2. Investigate unmatched manager references and distinguish genuine errors from references to employees outside the supplied dataset.
3. Resolve ambiguous manager relationships using an authoritative source rather than guessing.
4. Review invalid dates, employment statuses, and salary values.
5. Document validation rules and retest the data after any approved corrections.

## Methodology and Limitations

The raw dataset was preserved during the checks. SQL queries identify records requiring review; they do not automatically correct the source data.

Salary reference bands are illustrative synthetic rules, not market benchmarks.

The dataset is synthetic and intended for portfolio learning. The findings do not describe an actual organisation and should not be interpreted as evidence of discrimination or real-world HR performance.

