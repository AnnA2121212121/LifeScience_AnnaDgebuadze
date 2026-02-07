-----------inserting into golden layer

BEGIN;

-- TRUNCATE TABLE "life_science_golden".studies RESTART IDENTITY CASCADE;

INSERT INTO "life_science_golden".studies (
  nct_id, title, acronym, status, phase, study_type,
  start_date, primary_completion_date, completion_date,
  enrollment, enrollment_type,
  minimum_age, maximum_age, gender
)
SELECT
  ft.nct_id,
  ft.title,
  ft.acronym,
  ds.status_name,
  dp.phase_name,
  dst.study_type_name,
  ft.start_date,
  ft.primary_completion_date,
  ft.completion_date,
  ft.enrollment,
  NULL,

  -- minimum_age: numeric only (as text)
  CASE
    WHEN da.min_age_years IS NOT NULL THEN da.min_age_years::text
    ELSE NULL
  END AS minimum_age,

  -- maximum_age: numeric only (as text)
  CASE
    WHEN da.max_age_years IS NOT NULL THEN da.max_age_years::text
    ELSE NULL
  END AS maximum_age,

  dg.gender_name
FROM life_science_silver.ft_covid_trials ft
LEFT JOIN life_science_silver.dim_status ds ON ds.status_id = ft.status_id
LEFT JOIN life_science_silver.dim_phase dp ON dp.phase_id = ft.phase_id
LEFT JOIN life_science_silver.dim_study_type dst ON dst.study_type_id = ft.study_type_id
LEFT JOIN life_science_silver.dim_gender dg ON dg.gender_id = ft.gender_id
LEFT JOIN life_science_silver.dim_ages da ON da.age_id = ft.age_id
ON CONFLICT (nct_id) DO UPDATE SET
  title = EXCLUDED.title,
  acronym = EXCLUDED.acronym,
  status = EXCLUDED.status,
  phase = EXCLUDED.phase,
  study_type = EXCLUDED.study_type,
  start_date = EXCLUDED.start_date,
  primary_completion_date = EXCLUDED.primary_completion_date,
  completion_date = EXCLUDED.completion_date,
  enrollment = EXCLUDED.enrollment,
  enrollment_type = EXCLUDED.enrollment_type,
  gender = EXCLUDED.gender,
  minimum_age = EXCLUDED.minimum_age,
  maximum_age = EXCLUDED.maximum_age,
  updated_at = CURRENT_TIMESTAMP;

COMMIT;





ROLLBACK;


ALTER TABLE "life_science_golden".studies
ALTER COLUMN enrollment_type TYPE VARCHAR(100);



ALTER TABLE "life_science_golden".studies
ALTER COLUMN gender TYPE VARCHAR(50);

ALTER TABLE "life_science_golden".studies
ALTER COLUMN enrollment_type TYPE VARCHAR(50);

ALTER TABLE "life_science_golden".studies
ALTER COLUMN minimum_age TYPE VARCHAR(50);

ALTER TABLE "life_science_golden".studies
ALTER COLUMN maximum_age TYPE VARCHAR(50);


Truncate table "life_science_golden".studies cascade


ALTER TABLE "life_science_golden".locations
ALTER COLUMN facility TYPE VARCHAR(400);




--------------
BEGIN;

DELETE FROM "life_science_golden".conditions c
USING "life_science_golden".studies s
WHERE c.study_id = s.study_id
  AND s.nct_id IN (SELECT nct_id FROM life_science_silver.ft_covid_trials);

INSERT INTO "life_science_golden".conditions (study_id, condition_name, mesh_term)
SELECT
  s.study_id,
  dc.condition_name,
  NULL
FROM life_science_silver.bridge_trial_conditions btc
JOIN life_science_silver.ft_covid_trials ft ON ft.trial_id = btc.trial_id
JOIN "life_science_golden".studies s ON s.nct_id = ft.nct_id
JOIN life_science_silver.dim_conditions dc ON dc.condition_id = btc.condition_id;

COMMIT;











-------------

BEGIN;

DELETE FROM "life_science_golden".interventions i
USING "life_science_golden".studies s
WHERE i.study_id = s.study_id
  AND s.nct_id IN (SELECT nct_id FROM life_science_silver.ft_covid_trials);

INSERT INTO "life_science_golden".interventions (study_id, intervention_type, name, description)
SELECT
  s.study_id,
  di.intervention_type,
  di.intervention_name,
  NULL
FROM life_science_silver.bridge_trial_interventions bti
JOIN life_science_silver.ft_covid_trials ft ON ft.trial_id = bti.trial_id
JOIN "life_science_golden".studies s ON s.nct_id = ft.nct_id
JOIN life_science_silver.dim_interventions di ON di.intervention_id = bti.intervention_id;

COMMIT;





----------
BEGIN;

DELETE FROM "life_science_golden".outcomes o
USING "life_science_golden".studies s
WHERE o.study_id = s.study_id
  AND s.nct_id IN (SELECT nct_id FROM life_science_silver.ft_covid_trials);

INSERT INTO "life_science_golden".outcomes (study_id, outcome_type, measure, time_frame, description)
SELECT
  s.study_id,
  NULL,
  do1.outcome_text,
  NULL,
  NULL
FROM life_science_silver.bridge_trial_outcomes bto
JOIN life_science_silver.ft_covid_trials ft ON ft.trial_id = bto.trial_id
JOIN "life_science_golden".studies s ON s.nct_id = ft.nct_id
JOIN life_science_silver.dim_outcomes do1 ON do1.outcome_id = bto.outcome_id;

COMMIT;

-----------
BEGIN;

DELETE FROM "life_science_golden".sponsors sp
USING "life_science_golden".studies s
WHERE sp.study_id = s.study_id
  AND s.nct_id IN (SELECT nct_id FROM life_science_silver.ft_covid_trials);

INSERT INTO "life_science_golden".sponsors (study_id, agency, agency_class, lead_or_collaborator)
SELECT
  s.study_id,
  ds.sponsor_name,
  NULL,
  bts.sponsor_role
FROM life_science_silver.bridge_trial_sponsors bts
JOIN life_science_silver.ft_covid_trials ft ON ft.trial_id = bts.trial_id
JOIN "life_science_golden".studies s ON s.nct_id = ft.nct_id
JOIN life_science_silver.dim_sponsors ds ON ds.sponsor_id = bts.sponsor_id;

COMMIT;


-----------
BEGIN;

DELETE FROM "life_science_golden".locations l
USING "life_science_golden".studies s
WHERE l.study_id = s.study_id
  AND s.nct_id IN (SELECT nct_id FROM life_science_silver.ft_covid_trials);

INSERT INTO "life_science_golden".locations (study_id, facility, city, state, country, continent)
SELECT
  s.study_id,
  dl.facility,
  dl.city,
  dl.state,
  dl.country,
  NULL
FROM life_science_silver.bridge_trial_locations btl
JOIN life_science_silver.ft_covid_trials ft ON ft.trial_id = btl.trial_id
JOIN "life_science_golden".studies s ON s.nct_id = ft.nct_id
JOIN life_science_silver.dim_locations dl ON dl.location_id = btl.location_id;

COMMIT;








BEGIN;

-- Clean reload for the trials coming from Silver
DELETE FROM "life_science_golden".study_design sd
USING "life_science_golden".studies s
WHERE sd.study_id = s.study_id
  AND s.nct_id IN (SELECT nct_id FROM life_science_silver.ft_covid_trials);

-- Insert study design rows
INSERT INTO "life_science_golden".study_design (
  study_id,
  allocation,
  intervention_model,
  masking,
  primary_purpose,
  observational_model,
  time_perspective
)
SELECT
  s.study_id,
  dsd.allocation,
  dsd.intervention_model,
  dsd.masking,
  dsd.primary_purpose,
  dsd.observational_model,
  dsd.time_perspective
FROM life_science_silver.ft_covid_trials ft
JOIN "life_science_golden".studies s
  ON s.nct_id = ft.nct_id
JOIN life_science_silver.dim_study_design dsd
  ON dsd.study_design_id = ft.study_design_id
WHERE ft.study_design_id IS NOT NULL;

COMMIT;















