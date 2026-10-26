# HRIS Data Quality & People Reporting

## Project Overview

This independent portfolio project demonstrates how SQL and Power BI can be used to assess HRIS data quality and prepare reliable People Reporting metrics.

The project uses synthetic HR data containing deliberately introduced data-quality issues. It is designed to simulate common validation tasks performed by HR Data Analysts, HRIS Analysts, and People Analytics teams.

**Project status:** In progress.

**Tools:** SQL, SQLite, Power BI, Power Query, and DAX.

## Business Objectives

- Assess the completeness and consistency of employee records.
- Identify duplicate employee IDs and missing mandatory fields.
- Detect invalid dates and inconsistent employment statuses.
- Validate salary values and job-level classifications.
- Produce a transparent record of data-quality exceptions.
- Prepare reliable workforce reporting metrics.

## Planned Data Quality Checks

1. Employee ID uniqueness and completeness.
2. Required-field completeness.
3. Valid hire dates and termination dates.
4. Consistency between employment status and termination date.
5. Positive and valid salary values.
6. Valid job levels and performance ratings.
7. Consistency of manager references.

## Planned People Reporting Metrics

- Total employee records.
- Distinct employee IDs.
- Active headcount.
- Terminated employee count.
- Employee records with data-quality issues.
- Data-quality exception rate.
- Records passing the defined validation rules.

Metric definitions and denominators will be documented to ensure consistent interpretation.

## Methodology

The project will follow a documented workflow:

1. Prepare and inspect the synthetic source data.
2. Profile data completeness, validity, and uniqueness.
3. Implement SQL validation rules.
4. Create an exception report for records requiring review.
5. Define which records are eligible for reporting.
6. Build a Power BI dashboard.
7. Document the results, limitations, and validation rules.

## Repository Structure

The repository will contain:

- `data/` — synthetic source dataset.
- `sql/` — data profiling, validation, and reporting queries.
- `screenshots/` — dashboard previews.
- `README.md` — project documentation and methodology.

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

### Dataset Disclaimer

This project uses synthetic HR data for portfolio learning. The findings do not describe a real organisation.
