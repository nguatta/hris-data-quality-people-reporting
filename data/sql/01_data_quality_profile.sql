-- =====================================================================
-- Project: HRIS Data Quality & People Reporting
-- File: 01_data_quality_profile.sql
-- Database: SQLite
-- Purpose: Profile employee records and flag data-quality exceptions.
--
-- BEFORE RUNNING:
-- 1. Import data/employees_raw.csv into SQLite.
-- 2. Name the imported table exactly: employees_raw
-- 3. Keep the raw table unchanged; this script only reads from it.
--
-- Reproducibility: date validation uses the fixed as-of date 2026-10-26.
-- Salary bands are illustrative synthetic rules, not market benchmarks.
-- =====================================================================

DROP VIEW IF EXISTS temp.v_employees_quality;

CREATE TEMP VIEW v_employees_quality AS
WITH raw_data AS (
    SELECT
        e.rowid AS source_row_number,
        e.*,
        NULLIF(TRIM(CAST(e.EmployeeID AS TEXT)), '') AS employee_id_clean,
        NULLIF(TRIM(CAST(e.HireDate AS TEXT)), '') AS hire_date_raw,
        NULLIF(TRIM(CAST(e.TerminationDate AS TEXT)), '') AS termination_date_raw,
        NULLIF(TRIM(CAST(e.EmploymentStatus AS TEXT)), '') AS employment_status_clean,
        NULLIF(TRIM(CAST(e.Department AS TEXT)), '') AS department_clean,
        NULLIF(TRIM(CAST(e.JobTitle AS TEXT)), '') AS job_title_clean,
        NULLIF(TRIM(CAST(e.Country AS TEXT)), '') AS country_clean,
        NULLIF(TRIM(CAST(e.EmploymentType AS TEXT)), '') AS employment_type_clean,
        NULLIF(TRIM(CAST(e.ManagerID AS TEXT)), '') AS manager_id_clean,
        NULLIF(TRIM(CAST(e.MonthlySalaryEUR AS TEXT)), '') AS salary_raw_clean,
        CAST(NULLIF(TRIM(CAST(e.MonthlySalaryEUR AS TEXT)), '') AS REAL) AS salary_numeric,
        CASE
            WHEN NULLIF(TRIM(CAST(e.HireDate AS TEXT)), '') IS NOT NULL
             AND LENGTH(TRIM(CAST(e.HireDate AS TEXT))) = 10
             AND date(TRIM(CAST(e.HireDate AS TEXT)), '+0 days') = TRIM(CAST(e.HireDate AS TEXT))
            THEN date(TRIM(CAST(e.HireDate AS TEXT)))
            ELSE NULL
        END AS hire_date_clean,
        CASE
            WHEN NULLIF(TRIM(CAST(e.TerminationDate AS TEXT)), '') IS NOT NULL
             AND LENGTH(TRIM(CAST(e.TerminationDate AS TEXT))) = 10
             AND date(TRIM(CAST(e.TerminationDate AS TEXT)), '+0 days') = TRIM(CAST(e.TerminationDate AS TEXT))
            THEN date(TRIM(CAST(e.TerminationDate AS TEXT)))
            ELSE NULL
        END AS termination_date_clean,
        CASE TRIM(CAST(e.JobTitle AS TEXT))
            WHEN 'HR Assistant' THEN 1
            WHEN 'Data Support Analyst' THEN 1
            WHEN 'Junior Analyst' THEN 1
            WHEN 'HR Analyst' THEN 2
            WHEN 'HRIS Specialist' THEN 2
            WHEN 'People Reporting Analyst' THEN 2
            WHEN 'Senior HR Analyst' THEN 3
            WHEN 'Senior People Analyst' THEN 3
            WHEN 'Senior HRIS Analyst' THEN 3
            WHEN 'People Analytics Lead' THEN 4
            WHEN 'HR Manager' THEN 4
            WHEN 'HRIS Manager' THEN 4
            WHEN 'People Analytics Principal' THEN 5
            WHEN 'HR Systems Director' THEN 5
            WHEN 'HR Director' THEN 5
            ELSE NULL
        END AS expected_job_level
    FROM employees_raw AS e
), flags AS (
    SELECT
        r.*,

        CASE WHEN r.employee_id_clean IS NULL THEN 1 ELSE 0 END AS employee_id_missing_flag,
        CASE
            WHEN r.employee_id_clean IS NOT NULL
             AND (SELECT COUNT(*)
                  FROM employees_raw AS d
                  WHERE NULLIF(TRIM(CAST(d.EmployeeID AS TEXT)), '') = r.employee_id_clean) > 1
            THEN 1 ELSE 0
        END AS employee_id_duplicate_flag,

        CASE WHEN r.hire_date_raw IS NULL THEN 1 ELSE 0 END AS hire_date_missing_flag,
        CASE WHEN r.hire_date_raw IS NOT NULL AND r.hire_date_clean IS NULL THEN 1 ELSE 0 END AS hire_date_invalid_flag,
        CASE WHEN r.hire_date_clean > date('2026-10-26') THEN 1 ELSE 0 END AS hire_date_future_flag,

        CASE WHEN r.termination_date_raw IS NOT NULL AND r.termination_date_clean IS NULL THEN 1 ELSE 0 END AS termination_date_invalid_flag,
        CASE
            WHEN r.termination_date_clean IS NOT NULL
             AND r.hire_date_clean IS NOT NULL
             AND r.termination_date_clean < r.hire_date_clean
            THEN 1 ELSE 0
        END AS termination_before_hire_flag,
        CASE WHEN r.termination_date_clean > date('2026-10-26') THEN 1 ELSE 0 END AS termination_date_future_flag,

        CASE WHEN r.employment_status_clean IS NULL THEN 1 ELSE 0 END AS employment_status_missing_flag,
        CASE
            WHEN r.employment_status_clean IS NOT NULL
             AND r.employment_status_clean NOT IN ('Active', 'Terminated', 'On Leave')
