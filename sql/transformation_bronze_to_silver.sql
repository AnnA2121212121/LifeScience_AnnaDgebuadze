-------Creating and filling silver layer


SELECT * FROM "LifeScience_Bronze".stg_covid_trials


--------checking each column 
---1
SELECT DISTINCT STATUS FROM "LifeScience_Bronze".stg_covid_trials
-----2
SELECT DISTINCT STUDY_RESULTS FROM "LifeScience_Bronze".stg_covid_trials
----3
SELECT DISTINCT CONDITIONS FROM "LifeScience_Bronze".stg_covid_trials
-----4
SELECT DISTINCT inventions FROM "LifeScience_Bronze".stg_covid_trials
------5
SELECT DISTINCT outcome_measures FROM "LifeScience_Bronze".stg_covid_trials
------6
SELECT DISTINCT sponsor_collaborators FROM "LifeScience_Bronze".stg_covid_trials
----7
SELECT DISTINCT gender FROM "LifeScience_Bronze".stg_covid_trials
------8
SELECT DISTINCT age FROM "LifeScience_Bronze".stg_covid_trials -----tr
SELECT DISTINCT phases FROM "LifeScience_Bronze".stg_covid_trials ------tr
SELECT DISTINCT funded_bys FROM "LifeScience_Bronze".stg_covid_trials ------tr
SELECT DISTINCT study_type FROM "LifeScience_Bronze".stg_covid_trials ----tra
SELECT DISTINCT study_designs FROM "LifeScience_Bronze".stg_covid_trials








------creating silver layer
----dims
CREATE SCHEMA IF NOT EXISTS life_science_silver;

CREATE TABLE life_science_silver.dim_status (
  status_id SERIAL PRIMARY KEY,
  status_name TEXT UNIQUE NOT NULL
);

CREATE TABLE life_science_silver.dim_phase (
  phase_id SERIAL PRIMARY KEY,
  phase_name TEXT UNIQUE NOT NULL
);

CREATE TABLE life_science_silver.dim_study_type (
  study_type_id SERIAL PRIMARY KEY,
  study_type_name TEXT UNIQUE NOT NULL
);

CREATE TABLE life_science_silver.dim_gender (
  gender_id SERIAL PRIMARY KEY,
  gender_name TEXT UNIQUE NOT NULL
);

-- min and max age
CREATE TABLE life_science_silver.dim_ages (
  age_id SERIAL PRIMARY KEY,
  age_range_text TEXT UNIQUE NOT NULL,
  min_age_years INTEGER NULL,
  max_age_years INTEGER NULL
);

-- grouping ages for better anaylics
CREATE TABLE life_science_silver.dim_age_groups (
  age_group_id SERIAL PRIMARY KEY,
  age_group_name TEXT UNIQUE NOT NULL
);




-----facts

CREATE TABLE life_science_silver.ft_covid_trials (
  trial_id SERIAL PRIMARY KEY,

  nct_id VARCHAR(20) UNIQUE NOT NULL,
  title TEXT,
  acronym TEXT,

  status_id INTEGER REFERENCES life_science_silver.dim_status(status_id),
  phase_id INTEGER REFERENCES life_science_silver.dim_phase(phase_id),
  study_type_id INTEGER REFERENCES life_science_silver.dim_study_type(study_type_id),
  gender_id INTEGER REFERENCES life_science_silver.dim_gender(gender_id),
  age_id INTEGER REFERENCES life_science_silver.dim_ages(age_id),

  start_date DATE,
  primary_completion_date DATE,
  completion_date DATE,

  enrollment INTEGER,

  source_url TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);





----bridge tables
CREATE TABLE life_science_silver.dim_conditions (
  condition_id SERIAL PRIMARY KEY,
  condition_name TEXT UNIQUE NOT NULL
);

CREATE TABLE life_science_silver.bridge_trial_conditions (
  trial_id INTEGER REFERENCES life_science_silver.ft_covid_trials(trial_id) ON DELETE CASCADE,
  condition_id INTEGER REFERENCES life_science_silver.dim_conditions(condition_id),
  PRIMARY KEY (trial_id, condition_id)
);

CREATE TABLE life_science_silver.dim_interventions (
  intervention_id SERIAL PRIMARY KEY,
  intervention_type TEXT,
  intervention_name TEXT,
  UNIQUE (intervention_type, intervention_name)
);

CREATE TABLE life_science_silver.bridge_trial_interventions (
  trial_id INTEGER REFERENCES life_science_silver.ft_covid_trials(trial_id) ON DELETE CASCADE,
  intervention_id INTEGER REFERENCES life_science_silver.dim_interventions(intervention_id),
  PRIMARY KEY (trial_id, intervention_id)
);

CREATE TABLE life_science_silver.dim_sponsors (
  sponsor_id SERIAL PRIMARY KEY,
  sponsor_name TEXT UNIQUE NOT NULL
);

CREATE TABLE life_science_silver.bridge_trial_sponsors (
  trial_id INTEGER REFERENCES life_science_silver.ft_covid_trials(trial_id) ON DELETE CASCADE,
  sponsor_id INTEGER REFERENCES life_science_silver.dim_sponsors(sponsor_id),
  sponsor_role TEXT, -- lead or collaborator
  PRIMARY KEY (trial_id, sponsor_id)
);

CREATE TABLE life_science_silver.dim_locations (
  location_id SERIAL PRIMARY KEY,
  facility TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  UNIQUE (facility, city, state, country)
);

CREATE TABLE life_science_silver.bridge_trial_locations (
  trial_id INTEGER REFERENCES life_science_silver.ft_covid_trials(trial_id) ON DELETE CASCADE,
  location_id INTEGER REFERENCES life_science_silver.dim_locations(location_id),
  PRIMARY KEY (trial_id, location_id)
);

CREATE TABLE life_science_silver.dim_outcomes (
  outcome_id SERIAL PRIMARY KEY,
  outcome_text TEXT UNIQUE NOT NULL
);

CREATE TABLE life_science_silver.bridge_trial_outcomes (
  trial_id INTEGER REFERENCES life_science_silver.ft_covid_trials(trial_id) ON DELETE CASCADE,
  outcome_id INTEGER REFERENCES life_science_silver.dim_outcomes(outcome_id),
  PRIMARY KEY (trial_id, outcome_id)
);

-- bridge for age groups (Adult, Older Adult)
CREATE TABLE life_science_silver.bridge_trial_age_groups (
  trial_id INTEGER REFERENCES life_science_silver.ft_covid_trials(trial_id) ON DELETE CASCADE,
  age_group_id INTEGER REFERENCES life_science_silver.dim_age_groups(age_group_id),
  PRIMARY KEY (trial_id, age_group_id)
);



-------------
CREATE TABLE IF NOT EXISTS life_science_silver.dim_study_design (
  study_design_id SERIAL PRIMARY KEY,

  allocation TEXT,
  intervention_model TEXT,
  masking TEXT,
  primary_purpose TEXT,
  observational_model TEXT,
  time_perspective TEXT,

  -- optional: keep raw text for traceability
  raw_design_text TEXT,

  UNIQUE (
    allocation,
    intervention_model,
    masking,
    primary_purpose,
    observational_model,
    time_perspective
  )
);


ALTER TABLE life_science_silver.ft_covid_trials
ADD COLUMN IF NOT EXISTS study_design_id INTEGER;

ALTER TABLE life_science_silver.ft_covid_trials
ADD CONSTRAINT fk_ft_study_design
FOREIGN KEY (study_design_id)
REFERENCES life_science_silver.dim_study_design(study_design_id);




BEGIN;

-- just in case trncating tables
TRUNCATE TABLE
  life_science_silver.bridge_trial_age_groups,
  life_science_silver.bridge_trial_outcomes,
  life_science_silver.bridge_trial_locations,
  life_science_silver.bridge_trial_sponsors,
  life_science_silver.bridge_trial_interventions,
  life_science_silver.bridge_trial_conditions,
  life_science_silver.ft_covid_trials,
  life_science_silver.dim_age_groups,
  life_science_silver.dim_outcomes,
  life_science_silver.dim_locations,
  life_science_silver.dim_sponsors,
  life_science_silver.dim_interventions,
  life_science_silver.dim_conditions,
  life_science_silver.dim_ages,
  life_science_silver.dim_gender,
  life_science_silver.dim_study_type,
  life_science_silver.dim_phase,
  life_science_silver.dim_status
RESTART IDENTITY;


-- 2) DIMENSIONS (single-valued)

-- dim_status
INSERT INTO life_science_silver.dim_status (status_name)
SELECT DISTINCT
  regexp_replace(trim(status), '\s+', ' ', 'g') AS status_name
FROM "LifeScience_Bronze".stg_covid_trials
WHERE trim(coalesce(status, '')) <> ''
ON CONFLICT (status_name) DO NOTHING;

-- dim_phase
INSERT INTO life_science_silver.dim_phase (phase_name)
SELECT DISTINCT
  regexp_replace(trim(phases), '\s+', ' ', 'g') AS phase_name
FROM "LifeScience_Bronze".stg_covid_trials
WHERE trim(coalesce(phases, '')) <> ''
ON CONFLICT (phase_name) DO NOTHING;

-- dim_study_type
INSERT INTO life_science_silver.dim_study_type (study_type_name)
SELECT DISTINCT
  regexp_replace(trim(study_type), '\s+', ' ', 'g') AS study_type_name
FROM "LifeScience_Bronze".stg_covid_trials
WHERE trim(coalesce(study_type, '')) <> ''
ON CONFLICT (study_type_name) DO NOTHING;

-- dim_gender
INSERT INTO life_science_silver.dim_gender (gender_name)
SELECT DISTINCT
  regexp_replace(trim(gender), '\s+', ' ', 'g') AS gender_name
FROM "LifeScience_Bronze".stg_covid_trials
WHERE trim(coalesce(gender, '')) <> ''
ON CONFLICT (gender_name) DO NOTHING;

-- dim_ages (age range part before parentheses)
-- with min_age_years and max_age_years best-effort
WITH a AS (
  SELECT DISTINCT
    regexp_replace(trim(split_part(age, '(', 1)), '\s+', ' ', 'g') AS age_range_text
  FROM "LifeScience_Bronze".stg_covid_trials
  WHERE trim(coalesce(age, '')) <> ''
),
parsed AS (
  SELECT
    age_range_text,
    CASE
      WHEN age_range_text ~ '([0-9]+)\s*Years?' THEN (regexp_match(age_range_text, '([0-9]+)\s*Years?'))[1]::int
      ELSE NULL
    END AS min_age_years,
    CASE
      WHEN age_range_text ILIKE '%to%Years%' THEN (regexp_match(age_range_text, 'to\s*([0-9]+)\s*Years?'))[1]::int
      ELSE NULL
    END AS max_age_years
  FROM a
  WHERE age_range_text <> ''
)
INSERT INTO life_science_silver.dim_ages (age_range_text, min_age_years, max_age_years)
SELECT DISTINCT
  age_range_text,
  min_age_years,
  max_age_years
FROM parsed
ON CONFLICT (age_range_text) DO NOTHING;

-- dim_age_groups (values inside parentheses, split by comma)
WITH g AS (
  SELECT DISTINCT
    trim(x.val) AS age_group_name
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL (
    SELECT regexp_replace(b.age, '.*\((.*)\).*', '\1') AS inside_parens
  ) p
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(NULLIF(p.inside_parens, b.age), ''), ',') AS x(val)
  WHERE b.age LIKE '%(%'
    AND b.age LIKE '%)%'
    AND trim(x.val) <> ''
)
INSERT INTO life_science_silver.dim_age_groups (age_group_name)
SELECT DISTINCT
  regexp_replace(trim(age_group_name), '\s+', ' ', 'g')
FROM g
ON CONFLICT (age_group_name) DO NOTHING;

-- 3) DIMENSIONS (multi-valued)
-- dim_conditions
WITH c AS (
  SELECT DISTINCT trim(x.val) AS condition_name
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.conditions, ''), '\|') AS x(val)
  WHERE trim(x.val) <> ''
)
INSERT INTO life_science_silver.dim_conditions (condition_name)
SELECT DISTINCT regexp_replace(trim(condition_name), '\s+', ' ', 'g')
FROM c
ON CONFLICT (condition_name) DO NOTHING;

-- dim_interventions (split | then parse "Type: Name")
WITH i AS (
  SELECT DISTINCT
    trim(x.val) AS raw_val
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.interventions, ''), '\|') AS x(val)
  WHERE trim(x.val) <> ''
),
parsed AS (
  SELECT
    CASE
      WHEN position(':' in raw_val) > 0 THEN regexp_replace(trim(split_part(raw_val, ':', 1)), '\s+', ' ', 'g')
      ELSE NULL
    END AS intervention_type,
    CASE
      WHEN position(':' in raw_val) > 0 THEN regexp_replace(trim(split_part(raw_val, ':', 2)), '\s+', ' ', 'g')
      ELSE regexp_replace(trim(raw_val), '\s+', ' ', 'g')
    END AS intervention_name
  FROM i
)
INSERT INTO life_science_silver.dim_interventions (intervention_type, intervention_name)
SELECT DISTINCT intervention_type, intervention_name
FROM parsed
WHERE trim(coalesce(intervention_name, '')) <> ''
ON CONFLICT (intervention_type, intervention_name) DO NOTHING;

-- dim_sponsors
WITH s AS (
  SELECT DISTINCT trim(x.val) AS sponsor_name
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.sponsor_collaborators, ''), '\|') AS x(val)
  WHERE trim(x.val) <> ''
)
INSERT INTO life_science_silver.dim_sponsors (sponsor_name)
SELECT DISTINCT regexp_replace(trim(sponsor_name), '\s+', ' ', 'g')
FROM s
ON CONFLICT (sponsor_name) DO NOTHING;

-- dim_outcomes
WITH o AS (
  SELECT DISTINCT trim(x.val) AS outcome_text
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.outcome_measures, ''), '\|') AS x(val)
  WHERE trim(x.val) <> ''
)
INSERT INTO life_science_silver.dim_outcomes (outcome_text)
SELECT DISTINCT regexp_replace(trim(outcome_text), '\s+', ' ', 'g')
FROM o
ON CONFLICT (outcome_text) DO NOTHING;

-- dim_locations ( facility, city, state, country)
WITH loc AS (
  SELECT DISTINCT
    trim(x.val) AS raw_location,
    regexp_split_to_array(trim(x.val), '\s*,\s*') AS parts
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.locations, ''), '\|') AS x(val)
  WHERE trim(x.val) <> ''
),
parsed AS (
  SELECT
    CASE
      WHEN array_length(parts, 1) >= 4 THEN array_to_string(parts[1:array_length(parts, 1)-3], ', ')
      WHEN array_length(parts, 1) = 3 THEN parts[1]
      ELSE raw_location
    END AS facility,
    CASE WHEN array_length(parts, 1) >= 3 THEN parts[array_length(parts, 1)-2] ELSE NULL END AS city,
    CASE WHEN array_length(parts, 1) >= 2 THEN parts[array_length(parts, 1)-1] ELSE NULL END AS state,
    CASE WHEN array_length(parts, 1) >= 1 THEN parts[array_length(parts, 1)] ELSE NULL END AS country
  FROM loc
)
INSERT INTO life_science_silver.dim_locations (facility, city, state, country)
SELECT DISTINCT
  NULLIF(regexp_replace(trim(facility), '\s+', ' ', 'g'), ''),
  NULLIF(regexp_replace(trim(city), '\s+', ' ', 'g'), ''),
  NULLIF(regexp_replace(trim(state), '\s+', ' ', 'g'), ''),
  NULLIF(regexp_replace(trim(country), '\s+', ' ', 'g'), '')
FROM parsed
ON CONFLICT (facility, city, state, country) DO NOTHING;

-- 4) FACT TABLE

INSERT INTO life_science_silver.ft_covid_trials (
  nct_id, title, acronym,
  status_id, phase_id, study_type_id, gender_id, age_id,
  start_date, primary_completion_date, completion_date,
  enrollment, source_url
)
SELECT
  regexp_replace(trim(b.nct_number), '\s+', ' ', 'g') AS nct_id,
  NULLIF(regexp_replace(trim(b.title), '\s+', ' ', 'g'), '') AS title,
  NULLIF(regexp_replace(trim(b.acronym), '\s+', ' ', 'g'), '') AS acronym,

  ds.status_id,
  dp.phase_id,
  dst.study_type_id,
  dg.gender_id,
  da.age_id,

  CASE WHEN b.start_date ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN to_date(b.start_date, 'Month DD, YYYY') END,
  CASE WHEN b.primary_completion_date ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN to_date(b.primary_completion_date, 'Month DD, YYYY') END,
  CASE WHEN b.completion_date ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN to_date(b.completion_date, 'Month DD, YYYY') END,

  NULLIF(regexp_replace(coalesce(b.enrollment, ''), '[^0-9]', '', 'g'), '')::int,
  NULLIF(regexp_replace(trim(b.url), '\s+', ' ', 'g'), '')
FROM "LifeScience_Bronze".stg_covid_trials b
LEFT JOIN life_science_silver.dim_status ds
  ON ds.status_name = regexp_replace(trim(b.status), '\s+', ' ', 'g')
LEFT JOIN life_science_silver.dim_phase dp
  ON dp.phase_name = regexp_replace(trim(b.phases), '\s+', ' ', 'g')
LEFT JOIN life_science_silver.dim_study_type dst
  ON dst.study_type_name = regexp_replace(trim(b.study_type), '\s+', ' ', 'g')
LEFT JOIN life_science_silver.dim_gender dg
  ON dg.gender_name = regexp_replace(trim(b.gender), '\s+', ' ', 'g')
LEFT JOIN life_science_silver.dim_ages da
  ON da.age_range_text = regexp_replace(trim(split_part(b.age, '(', 1)), '\s+', ' ', 'g')
WHERE trim(coalesce(b.nct_number, '')) <> ''
ON CONFLICT (nct_id) DO UPDATE SET
  title = EXCLUDED.title,
  acronym = EXCLUDED.acronym,
  status_id = EXCLUDED.status_id,
  phase_id = EXCLUDED.phase_id,
  study_type_id = EXCLUDED.study_type_id,
  gender_id = EXCLUDED.gender_id,
  age_id = EXCLUDED.age_id,
  start_date = EXCLUDED.start_date,
  primary_completion_date = EXCLUDED.primary_completion_date,
  completion_date = EXCLUDED.completion_date,
  enrollment = EXCLUDED.enrollment,
  source_url = EXCLUDED.source_url,
  updated_at = CURRENT_TIMESTAMP;

-- 5) BRIDGES

-- bridge_trial_conditions
INSERT INTO life_science_silver.bridge_trial_conditions (trial_id, condition_id)
SELECT DISTINCT
  ft.trial_id,
  dc.condition_id
FROM "LifeScience_Bronze".stg_covid_trials b
JOIN life_science_silver.ft_covid_trials ft
  ON ft.nct_id = regexp_replace(trim(b.nct_number), '\s+', ' ', 'g')
CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.conditions, ''), '\|') AS x(val)
JOIN life_science_silver.dim_conditions dc
  ON dc.condition_name = regexp_replace(trim(x.val), '\s+', ' ', 'g')
WHERE trim(x.val) <> ''
ON CONFLICT DO NOTHING;

-- bridge_trial_interventions
WITH raw_i AS (
  SELECT
    b.nct_number,
    trim(x.val) AS raw_val
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.interventions, ''), '\|') AS x(val)
  WHERE trim(x.val) <> ''
),
parsed AS (
  SELECT
    regexp_replace(trim(nct_number), '\s+', ' ', 'g') AS nct_id,
    CASE
      WHEN position(':' in raw_val) > 0 THEN regexp_replace(trim(split_part(raw_val, ':', 1)), '\s+', ' ', 'g')
      ELSE NULL
    END AS intervention_type,
    CASE
      WHEN position(':' in raw_val) > 0 THEN regexp_replace(trim(split_part(raw_val, ':', 2)), '\s+', ' ', 'g')
      ELSE regexp_replace(trim(raw_val), '\s+', ' ', 'g')
    END AS intervention_name
  FROM raw_i
)
INSERT INTO life_science_silver.bridge_trial_interventions (trial_id, intervention_id)
SELECT DISTINCT
  ft.trial_id,
  di.intervention_id
FROM parsed p
JOIN life_science_silver.ft_covid_trials ft ON ft.nct_id = p.nct_id
JOIN life_science_silver.dim_interventions di
  ON di.intervention_type IS NOT DISTINCT FROM p.intervention_type
 AND di.intervention_name = p.intervention_name
ON CONFLICT DO NOTHING;

-- bridge_trial_sponsors
WITH sp AS (
  SELECT
    regexp_replace(trim(b.nct_number), '\s+', ' ', 'g') AS nct_id,
    regexp_replace(trim(x.val), '\s+', ' ', 'g') AS sponsor_name,
    row_number() OVER (
      PARTITION BY regexp_replace(trim(b.nct_number), '\s+', ' ', 'g')
      ORDER BY (SELECT 1)
    ) AS rn
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.sponsor_collaborators, ''), '\|') AS x(val)
  WHERE trim(coalesce(b.nct_number, '')) <> ''
    AND trim(x.val) <> ''
)
INSERT INTO life_science_silver.bridge_trial_sponsors (trial_id, sponsor_id, sponsor_role)
SELECT DISTINCT
  ft.trial_id,
  ds.sponsor_id,
  CASE WHEN sp.rn = 1 THEN 'lead' ELSE 'collaborator' END
FROM sp
JOIN life_science_silver.ft_covid_trials ft ON ft.nct_id = sp.nct_id
JOIN life_science_silver.dim_sponsors ds ON ds.sponsor_name = sp.sponsor_name
ON CONFLICT DO NOTHING;

-- bridge_trial_locations

DROP TABLE IF EXISTS life_science_silver.tmp_parsed_locations;

CREATE TABLE life_science_silver.tmp_parsed_locations AS
WITH exploded AS (
  SELECT
    regexp_replace(trim(b.nct_number), '\s+', ' ', 'g') AS nct_id,
    trim(x.val) AS loc_text
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.locations, ''), '\|') AS x(val)
  WHERE trim(coalesce(b.nct_number, '')) <> ''
    AND trim(x.val) <> ''
),
parts AS (
  SELECT
    nct_id,
    loc_text,
    regexp_split_to_array(loc_text, '\s*,\s*') AS p,
    array_length(regexp_split_to_array(loc_text, '\s*,\s*'), 1) AS n
  FROM exploded
),
parsed AS (
  SELECT
    nct_id,

    -- country = last part
    NULLIF(regexp_replace(trim(p[n]), '\s+', ' ', 'g'), '') AS country,

    -- state
    CASE
      -- US with 4+ parts: ... facility, city, state, United States
      WHEN p[n] = 'United States' AND n >= 4
        THEN NULLIF(regexp_replace(trim(p[n-1]), '\s+', ' ', 'g'), '')
      -- US with 3 parts: ... facility, city, United States (no state)
      WHEN p[n] = 'United States' AND n = 3
        THEN NULL
      -- Non-US with 4+ parts: ... facility, city, region/state, country
      WHEN p[n] <> 'United States' AND n >= 4
        THEN NULLIF(regexp_replace(trim(p[n-1]), '\s+', ' ', 'g'), '')
      -- Non-US with 3 parts: ... facility, city, country (no state)
      ELSE NULL
    END AS state,

    -- city
    CASE
      -- US with 4+ parts: ... facility, city, state, United States
      WHEN p[n] = 'United States' AND n >= 4
        THEN NULLIF(regexp_replace(trim(p[n-2]), '\s+', ' ', 'g'), '')
      -- US with 3 parts: ... facility, city, United States
      WHEN p[n] = 'United States' AND n = 3
        THEN NULLIF(regexp_replace(trim(p[2]), '\s+', ' ', 'g'), '')
      -- Non-US with 3+ parts: ... facility, city, country  OR facility, city, region, country
      WHEN p[n] <> 'United States' AND n >= 3
        THEN NULLIF(regexp_replace(trim(p[n-1]), '\s+', ' ', 'g'), '')
      ELSE NULL
    END AS city,

    -- facility
    CASE
      -- US with 4+ parts: everything before city/state/country
      WHEN p[n] = 'United States' AND n >= 4
        THEN NULLIF(regexp_replace(trim(array_to_string(p[1:n-3], ', ')), '\s+', ' ', 'g'), '')
      -- US with 3 parts: facility is first part
      WHEN p[n] = 'United States' AND n = 3
        THEN NULLIF(regexp_replace(trim(p[1]), '\s+', ' ', 'g'), '')
      -- Non-US with 4+ parts: everything before city/state/country (facility may include commas)
      WHEN p[n] <> 'United States' AND n >= 4
        THEN NULLIF(regexp_replace(trim(array_to_string(p[1:n-2], ', ')), '\s+', ' ', 'g'), '')
      -- Non-US with 3 parts: facility is first part
      WHEN p[n] <> 'United States' AND n = 3
        THEN NULLIF(regexp_replace(trim(p[1]), '\s+', ' ', 'g'), '')
      -- 2 parts: facility, country
      WHEN n = 2
        THEN NULLIF(regexp_replace(trim(p[1]), '\s+', ' ', 'g'), '')
      -- fallback
      ELSE NULLIF(regexp_replace(trim(loc_text), '\s+', ' ', 'g'), '')
    END AS facility
  FROM parts
),
cleaned AS (
  SELECT
    nct_id,
    facility,
    CASE
      WHEN city IS NOT NULL AND facility IS NOT NULL AND city = facility THEN NULL
      WHEN city IS NOT NULL AND country IS NOT NULL AND city = country THEN NULL
      ELSE city
    END AS city,
    CASE
      WHEN state IS NOT NULL AND country IS NOT NULL AND state = country THEN NULL
      ELSE state
    END AS state,
    country
  FROM parsed
)
SELECT DISTINCT
  nct_id, facility, city, state, country
FROM cleaned;

CREATE INDEX idx_tmp_parsed_locations_nct
ON life_science_silver.tmp_parsed_locations (nct_id);

ANALYZE life_science_silver.tmp_parsed_locations;



---------

TRUNCATE life_science_silver.bridge_trial_locations;
TRUNCATE TABLE life_science_silver.dim_locations
RESTART IDENTITY
CASCADE;



-----------

INSERT INTO life_science_silver.dim_locations (facility, city, state, country)
SELECT DISTINCT facility, city, state, country
FROM life_science_silver.tmp_parsed_locations
WHERE country IS NOT NULL
ON CONFLICT (facility, city, state, country) DO NOTHING;



---------------

INSERT INTO life_science_silver.bridge_trial_locations (trial_id, location_id)
SELECT
  ft.trial_id,
  dl.location_id
FROM life_science_silver.tmp_parsed_locations p
JOIN life_science_silver.ft_covid_trials ft
  ON ft.nct_id = p.nct_id
JOIN life_science_silver.dim_locations dl
  ON dl.facility IS NOT DISTINCT FROM p.facility
 AND dl.city IS NOT DISTINCT FROM p.city
 AND dl.state IS NOT DISTINCT FROM p.state
 AND dl.country IS NOT DISTINCT FROM p.country
ON CONFLICT DO NOTHING;












-- bridge_trial_outcomes
INSERT INTO life_science_silver.bridge_trial_outcomes (trial_id, outcome_id)
SELECT DISTINCT
  ft.trial_id,
  do1.outcome_id
FROM "LifeScience_Bronze".stg_covid_trials b
JOIN life_science_silver.ft_covid_trials ft
  ON ft.nct_id = regexp_replace(trim(b.nct_number), '\s+', ' ', 'g')
CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.outcome_measures, ''), '\|') AS x(val)
JOIN life_science_silver.dim_outcomes do1
  ON do1.outcome_text = regexp_replace(trim(x.val), '\s+', ' ', 'g')
WHERE trim(x.val) <> ''
ON CONFLICT DO NOTHING;

-- bridge_trial_age_groups
WITH ag AS (
  SELECT
    regexp_replace(trim(b.nct_number), '\s+', ' ', 'g') AS nct_id,
    trim(x.val) AS age_group_name
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL (
    SELECT regexp_replace(b.age, '.*\((.*)\).*', '\1') AS inside_parens
  ) p
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(NULLIF(p.inside_parens, b.age), ''), ',') AS x(val)
  WHERE b.age LIKE '%(%'
    AND b.age LIKE '%)%'
    AND trim(coalesce(b.nct_number, '')) <> ''
    AND trim(x.val) <> ''
)
INSERT INTO life_science_silver.bridge_trial_age_groups (trial_id, age_group_id)
SELECT DISTINCT
  ft.trial_id,
  dag.age_group_id
FROM ag
JOIN life_science_silver.ft_covid_trials ft ON ft.nct_id = ag.nct_id
JOIN life_science_silver.dim_age_groups dag
  ON dag.age_group_name = regexp_replace(trim(ag.age_group_name), '\s+', ' ', 'g')
ON CONFLICT DO NOTHING;

COMMIT;







WITH exploded AS (
  SELECT
    regexp_replace(trim(nct_number), '\s+', ' ', 'g') AS nct_id,
    regexp_replace(trim(study_designs), '\s+', ' ', 'g') AS raw_design_text,
    trim(x.val) AS kv
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.study_designs, ''), '\|') AS x(val)
  WHERE trim(coalesce(b.nct_number, '')) <> ''
    AND trim(coalesce(b.study_designs, '')) <> ''
    AND trim(x.val) <> ''
),
kv AS (
  SELECT
    nct_id,
    raw_design_text,
    regexp_replace(trim(split_part(kv, ':', 1)), '\s+', ' ', 'g') AS k,
    regexp_replace(trim(split_part(kv, ':', 2)), '\s+', ' ', 'g') AS v
  FROM exploded
  WHERE position(':' in kv) > 0
),
pivoted AS (
  SELECT
    nct_id,
    max(CASE WHEN lower(k) = 'allocation' THEN v END) AS allocation,
    max(CASE WHEN lower(k) IN ('intervention model','intervention model description') THEN v END) AS intervention_model,
    max(CASE WHEN lower(k) = 'masking' THEN v END) AS masking,
    max(CASE WHEN lower(k) = 'primary purpose' THEN v END) AS primary_purpose,
    max(CASE WHEN lower(k) = 'observational model' THEN v END) AS observational_model,
    max(CASE WHEN lower(k) = 'time perspective' THEN v END) AS time_perspective,
    max(raw_design_text) AS raw_design_text
  FROM kv
  GROUP BY nct_id
)
INSERT INTO life_science_silver.dim_study_design (
  allocation, intervention_model, masking, primary_purpose,
  observational_model, time_perspective, raw_design_text
)
SELECT DISTINCT
  NULLIF(allocation, ''),
  NULLIF(intervention_model, ''),
  NULLIF(masking, ''),
  NULLIF(primary_purpose, ''),
  NULLIF(observational_model, ''),
  NULLIF(time_perspective, ''),
  NULLIF(raw_design_text, '')
FROM pivoted
ON CONFLICT (
  allocation,
  intervention_model,
  masking,
  primary_purpose,
  observational_model,
  time_perspective
) DO NOTHING;




WITH exploded AS (
  SELECT
    regexp_replace(trim(nct_number), '\s+', ' ', 'g') AS nct_id,
    regexp_replace(trim(study_designs), '\s+', ' ', 'g') AS raw_design_text,
    trim(x.val) AS kv
  FROM "LifeScience_Bronze".stg_covid_trials b
  CROSS JOIN LATERAL regexp_split_to_table(COALESCE(b.study_designs, ''), '\|') AS x(val)
  WHERE trim(coalesce(b.nct_number, '')) <> ''
    AND trim(coalesce(b.study_designs, '')) <> ''
    AND trim(x.val) <> ''
),
kv AS (
  SELECT
    nct_id,
    raw_design_text,
    regexp_replace(trim(split_part(kv, ':', 1)), '\s+', ' ', 'g') AS k,
    regexp_replace(trim(split_part(kv, ':', 2)), '\s+', ' ', 'g') AS v
  FROM exploded
  WHERE position(':' in kv) > 0
),
pivoted AS (
  SELECT
    nct_id,
    NULLIF(max(CASE WHEN lower(k) = 'allocation' THEN v END), '') AS allocation,
    NULLIF(max(CASE WHEN lower(k) IN ('intervention model','intervention model description') THEN v END), '') AS intervention_model,
    NULLIF(max(CASE WHEN lower(k) = 'masking' THEN v END), '') AS masking,
    NULLIF(max(CASE WHEN lower(k) = 'primary purpose' THEN v END), '') AS primary_purpose,
    NULLIF(max(CASE WHEN lower(k) = 'observational model' THEN v END), '') AS observational_model,
    NULLIF(max(CASE WHEN lower(k) = 'time perspective' THEN v END), '') AS time_perspective
  FROM kv
  GROUP BY nct_id
)
UPDATE life_science_silver.ft_covid_trials ft
SET study_design_id = dsd.study_design_id
FROM pivoted p
JOIN life_science_silver.dim_study_design dsd
  ON dsd.allocation IS NOT DISTINCT FROM p.allocation
 AND dsd.intervention_model IS NOT DISTINCT FROM p.intervention_model
 AND dsd.masking IS NOT DISTINCT FROM p.masking
 AND dsd.primary_purpose IS NOT DISTINCT FROM p.primary_purpose
 AND dsd.observational_model IS NOT DISTINCT FROM p.observational_model
 AND dsd.time_perspective IS NOT DISTINCT FROM p.time_perspective
WHERE ft.nct_id = p.nct_id;


