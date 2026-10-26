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
            THEN 1 ELSE 0
        END AS employment_status_invalid_flag,
        CASE
            WHEN r.employment_status_clean = 'Terminated' AND r.termination_date_raw IS NULL THEN 1
            WHEN r.employment_status_clean IN ('Active', 'On Leave') AND r.termination_date_raw IS NOT NULL THEN 1
            ELSE 0
        END AS status_termination_mismatch_flag,

        CASE WHEN r.department_clean IS NULL THEN 1 ELSE 0 END AS department_missing_flag,
        CASE
            WHEN r.department_clean IS NOT NULL
             AND r.department_clean NOT IN ('Engineering', 'Finance', 'Human Resources', 'Sales', 'Operations', 'IT', 'Customer Success', 'Product')
            THEN 1 ELSE 0
        END AS department_invalid_flag,

        CASE
            WHEN r.JobLevel IS NULL OR TRIM(CAST(r.JobLevel AS TEXT)) = '' OR CAST(r.JobLevel AS INTEGER) NOT BETWEEN 1 AND 5
            THEN 1 ELSE 0
        END AS job_level_invalid_flag,
        CASE
            WHEN r.expected_job_level IS NOT NULL
             AND CAST(r.JobLevel AS INTEGER) BETWEEN 1 AND 5
             AND CAST(r.JobLevel AS INTEGER) <> r.expected_job_level
            THEN 1 ELSE 0
        END AS job_title_level_review_flag,

        CASE WHEN r.salary_raw_clean IS NULL THEN 1 ELSE 0 END AS salary_missing_flag,
        CASE WHEN r.salary_raw_clean IS NOT NULL AND r.salary_numeric <= 0 THEN 1 ELSE 0 END AS salary_nonpositive_flag,
        CASE
            WHEN r.salary_numeric > 0 AND CAST(r.JobLevel AS INTEGER) = 1 AND (r.salary_numeric < 1800 OR r.salary_numeric > 3000) THEN 1
            WHEN r.salary_numeric > 0 AND CAST(r.JobLevel AS INTEGER) = 2 AND (r.salary_numeric < 2600 OR r.salary_numeric > 4200) THEN 1
            WHEN r.salary_numeric > 0 AND CAST(r.JobLevel AS INTEGER) = 3 AND (r.salary_numeric < 3600 OR r.salary_numeric > 5600) THEN 1
            WHEN r.salary_numeric > 0 AND CAST(r.JobLevel AS INTEGER) = 4 AND (r.salary_numeric < 4800 OR r.salary_numeric > 7200) THEN 1
            WHEN r.salary_numeric > 0 AND CAST(r.JobLevel AS INTEGER) = 5 AND (r.salary_numeric < 6200 OR r.salary_numeric > 9500) THEN 1
            ELSE 0
        END AS salary_outside_reference_band_flag,

        CASE
            WHEN r.PerformanceRating IS NULL OR TRIM(CAST(r.PerformanceRating AS TEXT)) = '' OR CAST(r.PerformanceRating AS INTEGER) NOT BETWEEN 1 AND 5
            THEN 1 ELSE 0
        END AS performance_rating_invalid_flag,

        CASE WHEN r.country_clean IS NULL THEN 1 ELSE 0 END AS country_missing_flag,
        CASE
            WHEN r.country_clean IS NOT NULL
             AND r.country_clean NOT IN ('Portugal', 'France', 'Spain', 'Ireland', 'Germany', 'Brazil', 'Canada', 'Netherlands')
            THEN 1 ELSE 0
        END AS country_invalid_flag,

        CASE WHEN r.employment_type_clean IS NULL THEN 1 ELSE 0 END AS employment_type_missing_flag,
        CASE
            WHEN r.employment_type_clean IS NOT NULL
             AND r.employment_type_clean NOT IN ('Full-time', 'Part-time', 'Contract')
            THEN 1 ELSE 0
        END AS employment_type_invalid_flag,

        CASE
            WHEN r.manager_id_clean IS NOT NULL
             AND NOT EXISTS (
                SELECT 1 FROM employees_raw AS m
                WHERE NULLIF(TRIM(CAST(m.EmployeeID AS TEXT)), '') = r.manager_id_clean
             )
            THEN 1 ELSE 0
        END AS manager_reference_unknown_flag,
        CASE
            WHEN r.manager_id_clean IS NOT NULL
             AND r.employee_id_clean IS NOT NULL
             AND r.manager_id_clean = r.employee_id_clean
            THEN 1 ELSE 0
        END AS manager_self_reference_flag,
        CASE
            WHEN r.manager_id_clean IS NOT NULL
             AND (SELECT COUNT(*)
                  FROM employees_raw AS m
                  WHERE NULLIF(TRIM(CAST(m.EmployeeID AS TEXT)), '') = r.manager_id_clean) > 1
            THEN 1 ELSE 0
        END AS manager_reference_ambiguous_flag
    FROM raw_data AS r
), counted AS (
    SELECT
        f.*,
        (
            employee_id_missing_flag + employee_id_duplicate_flag +
            hire_date_missing_flag + hire_date_invalid_flag + hire_date_future_flag +
            termination_date_invalid_flag + termination_before_hire_flag + termination_date_future_flag +
            employment_status_missing_flag + employment_status_invalid_flag + status_termination_mismatch_flag +
            department_missing_flag + department_invalid_flag + job_level_invalid_flag + job_title_level_review_flag +
            salary_missing_flag + salary_nonpositive_flag + salary_outside_reference_band_flag +
            performance_rating_invalid_flag + country_missing_flag + country_invalid_flag +
            employment_type_missing_flag + employment_type_invalid_flag + manager_reference_unknown_flag +
            manager_self_reference_flag + manager_reference_ambiguous_flag
        ) AS issue_flag_count
    FROM flags AS f
)
SELECT
    counted.*,
    CASE WHEN issue_flag_count > 0 THEN 1 ELSE 0 END AS has_any_issue_flag
FROM counted;


-- CHECK 1: Overall profile. The issue rate denominator is all raw rows.
SELECT
    COUNT(*) AS total_raw_records,
    COUNT(DISTINCT employee_id_clean) AS distinct_nonblank_employee_ids,
    SUM(employee_id_missing_flag) AS rows_missing_employee_id,
    COUNT(DISTINCT CASE WHEN employee_id_duplicate_flag = 1 THEN employee_id_clean END) AS duplicated_id_groups,
    SUM(employee_id_duplicate_flag) AS rows_with_duplicated_employee_id,
    SUM(hire_date_missing_flag) AS rows_missing_hire_date,
    SUM(hire_date_invalid_flag) AS rows_with_invalid_hire_date,
    SUM(hire_date_future_flag) AS rows_with_future_hire_date,
    SUM(salary_missing_flag) AS rows_missing_salary,
    SUM(salary_nonpositive_flag) AS rows_with_nonpositive_salary,
    SUM(job_level_invalid_flag) AS rows_with_invalid_job_level,
    SUM(employment_status_invalid_flag) AS rows_with_invalid_employment_status,
    SUM(has_any_issue_flag) AS rows_with_at_least_one_flag,
    ROUND(100.0 * SUM(has_any_issue_flag) / NULLIF(COUNT(*), 0), 2) AS pct_rows_with_at_least_one_flag,
    SUM(issue_flag_count) AS total_flag_occurrences
FROM v_employees_quality;


-- CHECK 2: Duplicate employee IDs (shows every row in each duplicate group).
SELECT source_row_number, EmployeeID, EmploymentStatus, Department, JobTitle
FROM v_employees_quality
WHERE employee_id_duplicate_flag = 1
ORDER BY EmployeeID, source_row_number;


-- CHECK 3: Records with missing required fields.
SELECT
    source_row_number, EmployeeID, HireDate, EmploymentStatus, Department,
    MonthlySalaryEUR, Country, EmploymentType,
    employee_id_missing_flag, hire_date_missing_flag, employment_status_missing_flag,
    department_missing_flag, salary_missing_flag, country_missing_flag, employment_type_missing_flag
FROM v_employees_quality
WHERE employee_id_missing_flag = 1
   OR hire_date_missing_flag = 1
   OR employment_status_missing_flag = 1
   OR department_missing_flag = 1
   OR salary_missing_flag = 1
   OR country_missing_flag = 1
   OR employment_type_missing_flag = 1
ORDER BY source_row_number;


-- CHECK 4: Invalid/future hire dates and invalid termination dates.
SELECT
    source_row_number, EmployeeID, HireDate, TerminationDate,
    hire_date_missing_flag, hire_date_invalid_flag, hire_date_future_flag,
    termination_date_invalid_flag, termination_before_hire_flag, termination_date_future_flag
FROM v_employees_quality
WHERE hire_date_missing_flag = 1
   OR hire_date_invalid_flag = 1
   OR hire_date_future_flag = 1
   OR termination_date_invalid_flag = 1
   OR termination_before_hire_flag = 1
   OR termination_date_future_flag = 1
ORDER BY source_row_number;


-- CHECK 5: Employment-status/date consistency and invalid categories.
SELECT
    source_row_number, EmployeeID, EmploymentStatus, TerminationDate,
    employment_status_missing_flag, employment_status_invalid_flag,
    status_termination_mismatch_flag, department_missing_flag, department_invalid_flag,
    country_missing_flag, country_invalid_flag,
    employment_type_missing_flag, employment_type_invalid_flag
FROM v_employees_quality
WHERE employment_status_missing_flag = 1
   OR employment_status_invalid_flag = 1
   OR status_termination_mismatch_flag = 1
   OR department_missing_flag = 1
   OR department_invalid_flag = 1
   OR country_missing_flag = 1
   OR country_invalid_flag = 1
   OR employment_type_missing_flag = 1
   OR employment_type_invalid_flag = 1
ORDER BY source_row_number;


-- CHECK 6: Salary, job-level, performance-rating and title/level checks.
-- Salary-band exceptions require review; they do not prove incorrect pay.
SELECT
    source_row_number, EmployeeID, JobTitle, JobLevel, MonthlySalaryEUR,
    salary_missing_flag, salary_nonpositive_flag, salary_outside_reference_band_flag,
    job_level_invalid_flag, PerformanceRating, performance_rating_invalid_flag,
    expected_job_level, job_title_level_review_flag
FROM v_employees_quality
WHERE salary_missing_flag = 1
   OR salary_nonpositive_flag = 1
   OR salary_outside_reference_band_flag = 1
   OR job_level_invalid_flag = 1
   OR performance_rating_invalid_flag = 1
   OR job_title_level_review_flag = 1
ORDER BY source_row_number;


-- CHECK 7: Manager-reference checks. Blank ManagerID is allowed for top-level managers.
SELECT
    source_row_number, EmployeeID, ManagerID,
    manager_reference_unknown_flag, manager_self_reference_flag,
    manager_reference_ambiguous_flag
FROM v_employees_quality
WHERE manager_reference_unknown_flag = 1
   OR manager_self_reference_flag = 1
   OR manager_reference_ambiguous_flag = 1
ORDER BY source_row_number;


-- CHECK 8: Complete exception register with one row per flagged source record.
-- A row may have more than one issue. Raw values are preserved.
SELECT
    source_row_number,
    EmployeeID,
    EmploymentStatus,
    Department,
    JobTitle,
    JobLevel,
    MonthlySalaryEUR,
    HireDate,
    TerminationDate,
    ManagerID,
    issue_flag_count,
    TRIM(
        (CASE WHEN employee_id_missing_flag = 1 THEN 'Missing EmployeeID; ' ELSE '' END) ||
        (CASE WHEN employee_id_duplicate_flag = 1 THEN 'Duplicate EmployeeID; ' ELSE '' END) ||
        (CASE WHEN hire_date_missing_flag = 1 THEN 'Missing HireDate; ' ELSE '' END) ||
        (CASE WHEN hire_date_invalid_flag = 1 THEN 'Invalid HireDate; ' ELSE '' END) ||
        (CASE WHEN hire_date_future_flag = 1 THEN 'Future HireDate; ' ELSE '' END) ||
        (CASE WHEN termination_date_invalid_flag = 1 THEN 'Invalid TerminationDate; ' ELSE '' END) ||
        (CASE WHEN termination_before_hire_flag = 1 THEN 'Termination before HireDate; ' ELSE '' END) ||
        (CASE WHEN termination_date_future_flag = 1 THEN 'Future TerminationDate; ' ELSE '' END) ||
        (CASE WHEN employment_status_missing_flag = 1 THEN 'Missing EmploymentStatus; ' ELSE '' END) ||
        (CASE WHEN employment_status_invalid_flag = 1 THEN 'Invalid EmploymentStatus; ' ELSE '' END) ||
        (CASE WHEN status_termination_mismatch_flag = 1 THEN 'Status/TerminationDate mismatch; ' ELSE '' END) ||
        (CASE WHEN department_missing_flag = 1 THEN 'Missing Department; ' ELSE '' END) ||
        (CASE WHEN department_invalid_flag = 1 THEN 'Unapproved Department; ' ELSE '' END) ||
        (CASE WHEN job_level_invalid_flag = 1 THEN 'Invalid JobLevel; ' ELSE '' END) ||
        (CASE WHEN job_title_level_review_flag = 1 THEN 'Review JobTitle/JobLevel match; ' ELSE '' END) ||
        (CASE WHEN salary_missing_flag = 1 THEN 'Missing salary; ' ELSE '' END) ||
        (CASE WHEN salary_nonpositive_flag = 1 THEN 'Nonpositive salary; ' ELSE '' END) ||
        (CASE WHEN salary_outside_reference_band_flag = 1 THEN 'Salary outside illustrative reference band; ' ELSE '' END) ||
        (CASE WHEN performance_rating_invalid_flag = 1 THEN 'Invalid PerformanceRating; ' ELSE '' END) ||
        (CASE WHEN country_missing_flag = 1 THEN 'Missing Country; ' ELSE '' END) ||
        (CASE WHEN country_invalid_flag = 1 THEN 'Unapproved Country; ' ELSE '' END) ||
        (CASE WHEN employment_type_missing_flag = 1 THEN 'Missing EmploymentType; ' ELSE '' END) ||
        (CASE WHEN employment_type_invalid_flag = 1 THEN 'Invalid EmploymentType; ' ELSE '' END) ||
        (CASE WHEN manager_reference_unknown_flag = 1 THEN 'Unknown ManagerID; ' ELSE '' END) ||
        (CASE WHEN manager_self_reference_flag = 1 THEN 'Employee references self as manager; ' ELSE '' END) ||
        (CASE WHEN manager_reference_ambiguous_flag = 1 THEN 'ManagerID points to duplicate employee IDs; ' ELSE '' END)
    ) AS validation_issues
FROM v_employees_quality
WHERE has_any_issue_flag = 1
ORDER BY source_row_number;

-- End of script.
