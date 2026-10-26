-- =========================================================
-- Project: HRIS Data Quality & People Reporting
-- File: 01_data_quality_profile.sql
-- Purpose: Profile raw HR data and identify basic issues.
-- Database: SQLite
--
-- Prerequisite:
-- Import data/employees_raw.csv into a table named employees_raw.
-- This script does not modify the source data.
-- =========================================================


-- CHECK 1: Overall data quality profile

SELECT
    COUNT(*) AS total_records,

    COUNT(
        DISTINCT NULLIF(TRIM(EmployeeID), '')
    ) AS distinct_nonblank_employee_ids,

    SUM(
        CASE
            WHEN NULLIF(TRIM(EmployeeID), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_employee_id_rows,

    SUM(
        CASE
            WHEN NULLIF(TRIM(HireDate), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_hire_date_rows,

    SUM(
        CASE
            WHEN NULLIF(TRIM(EmploymentStatus), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_employment_status_rows,

    SUM(
        CASE
            WHEN NULLIF(TRIM(Department), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_department_rows,

    SUM(
        CASE
            WHEN MonthlySalaryEUR IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_salary_rows,

    SUM(
        CASE
            WHEN NULLIF(TRIM(Country), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_country_rows,

    SUM(
        CASE
            WHEN NULLIF(TRIM(EmploymentType), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_employment_type_rows

FROM employees_raw;


-- CHECK 2: Duplicate employee IDs

SELECT
    TRIM(EmployeeID) AS EmployeeID,
    COUNT(*) AS record_count

FROM employees_raw

WHERE NULLIF(TRIM(EmployeeID), '') IS NOT NULL

GROUP BY TRIM(EmployeeID)

HAVING COUNT(*) > 1

ORDER BY record_count DESC, EmployeeID;


-- CHECK 3: Records with missing required fields

SELECT
    rowid AS source_row_number,
    EmployeeID,
    HireDate,
    EmploymentStatus,
    Department,
    MonthlySalaryEUR,
    Country,
    EmploymentType,

    CASE
        WHEN NULLIF(TRIM(EmployeeID), '') IS NULL
            THEN 'Missing EmployeeID; '
        ELSE ''
    END ||

    CASE
        WHEN NULLIF(TRIM(HireDate), '') IS NULL
            THEN 'Missing HireDate; '
        ELSE ''
    END ||

    CASE
        WHEN NULLIF(TRIM(EmploymentStatus), '') IS NULL
            THEN 'Missing EmploymentStatus; '
        ELSE ''
    END ||

    CASE
        WHEN NULLIF(TRIM(Department), '') IS NULL
            THEN 'Missing Department; '
        ELSE ''
    END ||

    CASE
        WHEN MonthlySalaryEUR IS NULL
            THEN 'Missing MonthlySalaryEUR; '
        ELSE ''
    END ||

    CASE
        WHEN NULLIF(TRIM(Country), '') IS NULL
            THEN 'Missing Country; '
        ELSE ''
    END ||

    CASE
        WHEN NULLIF(TRIM(EmploymentType), '') IS NULL
            THEN 'Missing EmploymentType; '
        ELSE ''
    END AS validation_issues

FROM employees_raw

WHERE
    NULLIF(TRIM(EmployeeID), '') IS NULL
    OR NULLIF(TRIM(HireDate), '') IS NULL
    OR NULLIF(TRIM(EmploymentStatus), '') IS NULL
    OR NULLIF(TRIM(Department), '') IS NULL
    OR MonthlySalaryEUR IS NULL
    OR NULLIF(TRIM(Country), '') IS NULL
    OR NULLIF(TRIM(EmploymentType), '') IS NULL

ORDER BY source_row_number;
