# NHS A&E Performance Analysis Using SQL

## Project Overview
This project explores NHS A&E performance data using SQL to analyse attendance trends, waiting-time pressures, and regional operational performance across NHS England trusts.

The analysis focuses on identifying:
- High-pressure hospitals
- Regional differences in emergency care demand
- Trends in 4-hour waiting times
- Operational strain across NHS regions

---

## Tools Used
- MySQL Workbench
- SQL
- Excel
- Power BI (dashboard created separately)

---

## Dataset
The dataset contains NHS A&E attendance and emergency admissions data for 2024–2025.

### Key fields include:
- Period
- Organisation name
- Total attendances
- Total over 4 hours
- Emergency admissions
- Parent NHS region

---

## SQL Skills Demonstrated

### Data Cleaning
- Removed summary rows
- Used `LOWER()` and `TRIM()` functions for standardisation

### Aggregations
- `SUM()`
- `COUNT()`
- `GROUP BY`
- `ORDER BY`

### Advanced SQL Techniques
- JOIN operations
- Subqueries
- HAVING clauses
- CASE statements
- Derived tables
- Window Functions

---

## Example Business Questions Answered
- Which NHS trusts experienced the highest 4-hour waiting pressures?
- Which regions had the highest operational strain?
- Which trusts performed worse than the national average?
- How did attendance trends change over time?

---

## Key Insights
- Midlands and London recorded the highest operational pressures.
- Several NHS trusts significantly exceeded the national average for 4-hour waits.
- Winter months showed elevated attendance and waiting-time pressures.

---

## Repository Contents

```text
nhs_ae_cleaned.csv # Cleaned dataset
nhs_analysis_queries.sql # Full SQL analysis queries
README.md # Project documentation
