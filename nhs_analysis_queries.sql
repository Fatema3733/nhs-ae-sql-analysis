-- ============================================================
-- NHS A&E Performance Analysis Using SQL
-- Dataset: NHS England A&E Attendances and Emergency Admissions
-- Tools: MySQL Workbench, Excel, Power BI
-- ============================================================

-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS nhs_project;

USE nhs_project;


-- ============================================================
-- 2. DATA VALIDATION
-- ============================================================

-- Preview dataset
SELECT *
FROM nhs_cleaned
LIMIT 10;


-- Check total number of records
SELECT COUNT(*) AS total_records
FROM nhs_cleaned;


-- Check table structure
DESCRIBE nhs_cleaned;


-- ============================================================
-- 3. MONTHLY TREND ANALYSIS
-- ============================================================

-- Monthly attendance trends
SELECT
Period,
SUM(`Total Attendances`) AS total_attendances
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY Period
ORDER BY total_attendances DESC;


-- Monthly 4-hour wait trends
SELECT
Period,
SUM(`Total Over 4hrs`) AS total_over_4hrs
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY Period
ORDER BY total_over_4hrs DESC;


-- Monthly emergency admission trends
SELECT
Period,
SUM(`Total Emergency Admissions`) AS total_emergency_admissions
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY Period
ORDER BY total_emergency_admissions DESC;


-- ============================================================
-- 4. TRUST-LEVEL PERFORMANCE ANALYSIS
-- ============================================================

-- Top 10 NHS trusts by total attendances
SELECT
`Org name`,
SUM(`Total Attendances`) AS total_attendances
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
ORDER BY total_attendances DESC
LIMIT 10;


-- Top 10 NHS trusts by 4-hour waits
SELECT
`Org name`,
SUM(`Total Over 4hrs`) AS total_over_4hrs
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
ORDER BY total_over_4hrs DESC
LIMIT 10;


-- 4-hour wait rate by trust
SELECT
`Org name`,
SUM(`Total Attendances`) AS total_attendances,
SUM(`Total Over 4hrs`) AS total_over_4hrs,
ROUND(
(SUM(`Total Over 4hrs`) / SUM(`Total Attendances`)) * 100,
2
) AS four_hour_wait_rate
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
HAVING SUM(`Total Attendances`) > 0
ORDER BY four_hour_wait_rate DESC
LIMIT 10;


-- Emergency admission rate by trust
SELECT
`Org name`,
SUM(`Total Attendances`) AS total_attendances,
SUM(`Total Emergency Admissions`) AS total_emergency_admissions,
ROUND(
(SUM(`Total Emergency Admissions`) / SUM(`Total Attendances`)) * 100,
2
) AS emergency_admission_rate
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
HAVING SUM(`Total Attendances`) > 0
ORDER BY emergency_admission_rate DESC
LIMIT 10;


-- ============================================================
-- 5. OPERATIONAL PRESSURE CLASSIFICATION
-- ============================================================

-- Classify NHS trusts by operational pressure level using CASE
SELECT
`Org name`,
SUM(`Total Attendances`) AS total_attendances,
SUM(`Total Over 4hrs`) AS total_over_4hrs,
CASE
WHEN SUM(`Total Over 4hrs`) >= 100000 THEN 'Critical Pressure'
WHEN SUM(`Total Over 4hrs`) >= 50000 THEN 'High Pressure'
WHEN SUM(`Total Over 4hrs`) >= 10000 THEN 'Moderate Pressure'
ELSE 'Low Pressure'
END AS pressure_level
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
ORDER BY total_over_4hrs DESC
LIMIT 10;


-- Identify providers with both high attendances and high delays
SELECT
`Org name`,
SUM(`Total Attendances`) AS total_attendances,
SUM(`Total Over 4hrs`) AS total_over_4hrs
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
HAVING
SUM(`Total Attendances`) > 300000
AND SUM(`Total Over 4hrs`) > 100000
ORDER BY total_over_4hrs DESC;


-- ============================================================
-- 6. REGIONAL REFERENCE TABLE FOR JOIN ANALYSIS
-- ============================================================

-- Create a reference table to group NHS parent organisations into regions
CREATE TABLE IF NOT EXISTS region_reference (
parent_org TEXT,
region_group TEXT
);

TRUNCATE TABLE region_reference;

-- Insert NHS England regional mappings
INSERT INTO region_reference (parent_org, region_group)
VALUES
('NHS ENGLAND EAST OF ENGLAND', 'East of England'),
('NHS ENGLAND LONDON', 'London'),
('NHS ENGLAND MIDLANDS', 'Midlands'),
('NHS ENGLAND NORTH EAST AND YORKSHIRE', 'North East and Yorkshire'),
('NHS ENGLAND NORTH WEST', 'North West'),
('NHS ENGLAND SOUTH EAST', 'South East'),
('NHS ENGLAND SOUTH WEST', 'South West');

-- Check reference table
SELECT *
FROM region_reference;


-- Regional performance analysis using JOIN
SELECT
r.region_group,
SUM(n.`Total Attendances`) AS total_attendances,
SUM(n.`Total Over 4hrs`) AS total_over_4hrs
FROM nhs_cleaned n
JOIN region_reference r
ON LOWER(TRIM(n.`Parent Org`)) = LOWER(TRIM(r.parent_org))
WHERE LOWER(TRIM(n.Period)) <> 'total'
GROUP BY r.region_group
ORDER BY total_over_4hrs DESC;


-- ============================================================
-- 7. SUBQUERY BENCHMARK ANALYSIS
-- ============================================================

-- Identify trusts with 4-hour waits above the average trust-level total
SELECT
`Org name`,
SUM(`Total Over 4hrs`) AS total_over_4hrs
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
HAVING SUM(`Total Over 4hrs`) > (
SELECT AVG(trust_waits)
FROM (
SELECT
SUM(`Total Over 4hrs`) AS trust_waits
FROM nhs_cleaned
WHERE LOWER(TRIM(Period)) <> 'total'
GROUP BY `Org name`
) AS trust_summary
)
ORDER BY total_over_4hrs DESC
LIMIT 10;
