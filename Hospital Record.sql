-- DO ALL ENCOUNTERS MAP TO A PATIENT? DO ALL PROCEDURES MAP TO ENCOUNTERS?
-- DATA QUALITY + ROW COUNTS ACROSS TABLES


SELECT
	'encounters' AS table_name, COUNT(*) AS row_count, COUNT(DISTINCT id) AS unique_id,
	COUNT(DISTINCT patient) AS unique_patients
FROM encounters
UNION ALL
SELECT
	'patients', COUNT(*), COUNT(DISTINCT id), NULL 
FROM patients
UNION ALL
SELECT
	'procedures', COUNT(*), COUNT(DISTINCT encounter), COUNT(DISTINCT patient)
FROM procedures
UNION ALL
SELECT 
	'payers', COUNT(*), COUNT(DISTINCT id), NULL
FROM payers
;


-- ENCOUNTERS WITH NO PATIENT


SELECT *
FROM encounters e
LEFT JOIN patients p
ON e.patient = p.id
WHERE p.id IS NULL
;



-- WHICH ENCOUNTER TYPE DRIVE REVENUE AND WHAT % DO PAYERS ACTUALLY COVER?
-- HOSPITAL REVENUE: CLAIM COST VS PAYER COVERAGE BY ENCOUNTER CLASS


SELECT 
	encounter_class, COUNT(*) AS total_encounters,
	ROUND(SUM(CAST(total_claim_cost AS FLOAT)), 2) AS total_billed,
	ROUND(SUM(CAST(payer_coverage AS FLOAT)), 2) AS total_covered,
	ROUND(SUM(CAST(total_claim_cost AS FLOAT)) - SUM(CAST(payer_coverage AS FLOAT)), 2) AS patient_responsibility,
	ROUND(100.0 * SUM(CAST(payer_coverage AS FLOAT)) / NULLIF(SUM(CAST(total_claim_cost AS FLOAT)), 0), 2) AS coverage_pct
FROM encounters
GROUP BY encounter_class
ORDER BY total_billed
;


-- WHAT ARE WE TREATING MOST OFTEN AND WHAT COST THE MOST?
-- TOP DIAGNOSIS BY VOLUME AND COST


SELECT
	description AS diagnosis, code, COUNT(*) AS encounter_count,
	ROUND(AVG(CAST(total_claim_cost AS FLOAT)), 2) AS avg_claim_cost,
	ROUND(SUM(CAST(total_claim_cost AS FLOAT)), 2) AS total_cost
FROM encounters
WHERE description IS NOT NULL
GROUP BY description, code
ORDER BY total_cost DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY
;



-- WHO USES THE HOSPITAL MOST BY AGE AND GENDER?
-- PATIENT DEMOGRAPHICS: AGE BAND + GENDER UTILIZATION


WITH patient_age AS (
	SELECT 
		p.id, p.gender,
		DATEDIFF(YEAR, p.birth_date, GETDATE()) -
			CASE 
				WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.birth_date, GETDATE()), p.birth_date) > GETDATE()
				THEN 1
				ELSE 0
			END AS age
	FROM patients p
)
SELECT 
	CASE
		WHEN age < 18 THEN '0-17'
		WHEN age < 35 THEN '18-34'
		WHEN age < 50 THEN '35-49'
		WHEN age < 65 THEN '50-64'
		ELSE '65+'
	END AS age_band,
	pa.gender,
	COUNT(DISTINCT E.patient) AS unique_patients,
	COUNT(*)AS total_encounters,
	ROUND(AVG(CAST(e.total_claim_cost AS FLOAT)), 2) AS avg_cost_per_encounter
FROM encounters e
JOIN patient_age pa
ON e.patient = pa.id
GROUP BY 
	CASE
		WHEN age < 18 THEN '0-17'
		WHEN age < 35 THEN '18-34'
		WHEN age < 50 THEN '35-49'
		WHEN age < 65 THEN '50-64'
		ELSE '65+'
	END,
	pa.gender
ORDER BY age_band, pa.gender
;



-- WHICH PAYERS COVER THE MOST AND WHICH LEAVE HIGHEST PATIENT RESPONSIBILITY
-- PAYER MIX + DENIAL RATE PROXY

SELECT
	py.name AS payer_name, COUNT(*) AS encounters, 
	ROUND(SUM(CAST(e.total_claim_cost AS FLOAT)), 2) AS total_billed,
	ROUND(SUM(CAST(e.payer_coverage AS FLOAT)), 2) AS total_paid,
	ROUND(100.0 * SUM(CAST(e.payer_coverage AS FLOAT)) / 
		NULLIF(SUM(CAST(e.total_claim_cost AS FLOAT)), 0), 2) AS paid_pct,
	ROUND(AVG(CAST(e.total_claim_cost AS FLOAT) - CAST(e.payer_coverage AS FLOAT)), 2) AS avg_patient_responsibility
FROM encounters e
JOIN payers py
	ON e.payer = Py.id
GROUP BY py.name
HAVING COUNT(*) >= 50
ORDER BY total_billed DESC
;



-- DO PROCEDURE COST ROLL UP TO ENCOUNTER COST CORRECTLY?
-- PROCEDURE COST vs ENCOUNTER COST


WITH proc_sum AS (
	SELECT 
		encounter, COUNT(*) AS proc_count,
		SUM(CAST(base_cost AS FLOAT)) AS total_procedure_cost
	FROM procedures
	GROUP BY encounter
)
SELECT
	e.encounter_class, COUNT(*) AS encounters,
	ROUND(AVG(CAST(e.total_claim_cost AS FLOAT)), 2) AS avg_encounter_claim,
	ROUND(AVG(ps.total_procedure_cost), 2) AS avg_sum_procedure_cost,
	ROUND(AVG(CAST(e.total_claim_cost AS FLOAT)) - AVG(ps.total_procedure_cost), 2) AS avg_diff
FROM encounters e
JOIN proc_sum ps
	ON e.id = ps.encounter
GROUP BY e.encounter_class
ORDER BY avg_diff DESC
;



-- WHO ARE OUR SUPER UTILIZERS WE SHOULD CASE-MANAGE?
-- HIGH UTILIZERS PATIENT: TOP 1% BY ENCOUNTER AND COST


WITH patient_stats AS (
	SELECT
		p.id, p.first, p.last,
		DATEDIFF(YEAR, p.birth_date, GETDATE()) AS age,
		COUNT(*) AS encounter_count,
		SUM(CAST(e.total_claim_cost AS FLOAT)) AS total_cost
	FROM patients p
	JOIN encounters e 
		ON p.id = e.patient
	WHERE p.death_date IS NULL
	GROUP BY p.id, p.first, p.last, p.birth_date
),
ranked AS (
	SELECT *,
		NTILE(100) OVER (ORDER BY total_cost DESC) AS cost_percentile,
		NTILE(100) OVER (ORDER BY encounter_count DESC) AS visit_percentile
	FROM patient_stats
)
SELECT 
	id, first, last, age, encounter_count, ROUND(total_cost, 2) AS total_cost
FROM ranked
WHERE cost_percentile = 1 
	OR visit_percentile = 1
ORDER BY total_cost DESC
;



-- ARE WE GETTING BETTER OR WORSE MONTH OVER MONTH?
-- EXECUTIVE DASHBOARD: MONTHLY TREND OF KEY METRICS


WITH monthly AS (
	SELECT 
		DATEFROMPARTS(YEAR(start), MONTH(start), 1) AS month,
		COUNT(*) AS encounters,
		COUNT(DISTINCT patient) AS unique_patients,
		ROUND(SUM(CAST(total_claim_cost AS FLOAT)), 2) AS total_billed,
		ROUND(SUM(CAST(payer_coverage AS FLOAT)), 2) AS total_paid,
		ROUND(AVG(CAST(DATEDIFF(HOUR, start, stop) AS FLOAT) / 24.0), 2) AS avg_los_days_inpatient
	FROM encounters
	WHERE start >= DATEADD(MONTH, -12, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
	GROUP BY DATEFROMPARTS(YEAR(start), MONTH(start), 1)
)
SELECT 
	month, encounters, unique_patients, total_billed, total_paid,
	ROUND( 100.0 * total_paid / NULLIF(total_billed, 0), 2) AS collection_pct,
	avg_los_days_inpatient,
	LAG(encounters) OVER (ORDER BY month) AS encounters_prior_month
FROM monthly
ORDER BY month
;