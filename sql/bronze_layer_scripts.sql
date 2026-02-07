SET search_path TO "LifeScienceScheme";

DROP TABLE IF EXISTS stg_covid_trials;

CREATE TABLE "LifeScience_Bronze".stg_covid_trials (
  rank_num INTEGER,
  nct_number VARCHAR(20),
  title TEXT,
  acronym VARCHAR(50),
  status VARCHAR(80),
  study_results TEXT,
  conditions TEXT,
  interventions TEXT,
  outcome_measures TEXT,
  sponsor_collaborators TEXT,
  gender VARCHAR(20),
  age TEXT,
  phases TEXT,
  enrollment TEXT,
  funded_bys TEXT,
  study_type VARCHAR(50),
  study_designs TEXT,
  other_ids TEXT,
  start_date TEXT,
  primary_completion_date TEXT,
  completion_date TEXT,
  first_posted TEXT,
  results_first_posted TEXT,
  last_update_posted TEXT,
  locations TEXT,
  study_documents TEXT,
  url TEXT
);
