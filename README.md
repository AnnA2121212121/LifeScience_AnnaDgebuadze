Data Management:
Data - https://www.kaggle.com/datasets/parulpandey/covid19-clinical-trials-dataset?resource=download
Database - PostgreeSQL
Visualization Tool - Power BI
Integration -  Current: Export/Import
  Recommended: For better integration flow I would choose API connection and insert data into database though API URL.


Report:
Page 1: Clinical Trial Landscape Overview
Purpose of the Page

This page provides an overview of the global clinical trial landscape, focusing on trial volume, progression, and distribution over time. The goal is to establish context before deeper analysis and to understand how clinical research activity evolved during the COVID-19 period.
This page mostly answers following business questions:

What is the distribution of clinical trials by phase, status, and therapeutic area? How has this evolved over time?

Visuals:
1. Total Trials by Year and Phase (Stacked Column Chart)

What it shows:
Annual number of trials, broken down by clinical phase.
Stacked columns allow comparison of both total volume and phase composition simultaneously.
Highlights the sharp increase in trials during the COVID-19 period and the shift toward later-phase studies.
As a result we can say that it reveals how trial activity surged and how trial maturity evolved over time.

2. Clinical of clinical Trials by status (Donut Chart)

What it shows
Distribution of trials across recruitment and completion statuses.
A donut chart is effective for showing proportional distribution.
Helps quickly assess pipeline health: ongoing vs completed vs discontinued trials.
As a result it provides immediate visibility into trial outcomes and operational progress.

3. Distinct Clinical Trials by Therapeutic Area (Bar Chart)

What it shows
Number of unique trials by therapeutic area (custom grouped conditions).
It uses distinct trial counts to avoid double counting due to multi-condition trials.
Horizontal bars improve readability for categorical comparisons.
Demonstrates concentration of clinical research in infectious diseases, especially COVID-19-related trials.

4. Monthly Clinical Trial Trends by Phase (Line Chart)

What it shows
Month-by-month trial initiation patterns within a selected year, broken down by phase.
Line charts are ideal for detecting temporal patterns and seasonality.
There is applied slicer at the visual level only to prevent aggregation bias.
Reveals short-term dynamics and spikes in trial activity that are not visible in yearly aggregations.

5. Decomposition Tree (Advanced Visual)

What it shows
This visual allows users to explore which combinations of phase and status drive overall trial volume so we can see stepwise breakdown of distinct trials by phase → status → therapeutic area. It enables interactive root-cause analysis.
Helps identify where trials progress successfully versus where they stall or terminate.





Page 2: Trial Performance & Outcomes
Purpose of the Page

This page focuses on operational performance of clinical trials after initiation, with emphasis on patient enrollment scale, trial duration, and geographic execution.
The goal is to understand how trials differ by phase and therapeutic area in terms of resource intensity, timelines, and global distribution, rather than overall volume.

This page mostly answers the following business questions:

What are the trends in patient enrollment across different trial phases and therapeutic areas?
Which conditions attract the most participants?
What is the typical duration of completed trials by phase?
How are clinical trials distributed globally?

Visuals
1. Total Enrollment by Condition Group (Bar Chart)

What it shows
Total patient enrollment aggregated by custom therapeutic condition groups.
Each bar represents the cumulative enrollment across all trials within that condition group.
Using total enrollment highlights where the largest patient populations are concentrated, which is critical for operational planning and capacity management.
Horizontal bars improve readability for categorical comparison.
As a result we can clearly see that infectious disease trials, particularly COVID-19-related studies, dominate total enrollment, indicating high recruitment demand and large-scale study designs.

2. Average Enrollment by Phase (Column Chart with Reference Line)

What it shows
Average enrollment per trial for each clinical phase.
A reference line provides context relative to the overall enrollment level.
Average enrollment illustrates how trial scale evolves as studies progress through phases.
Column charts are effective for comparing magnitude differences across discrete phases.
Later-phase trials show substantially higher average enrollment, reflecting confirmatory study requirements, while early-phase trials remain small and exploratory.

3. Average Trial Duration (Completed Trials) by Phase (Column Chart)

What it shows
Average duration in days for completed trials, grouped by clinical phase.
Only completed trials are included to avoid bias from ongoing studies.
Focusing on completed trials provides a realistic view of expected timelines.
Averages offer a simple and interpretable summary of duration by phase.
Early-phase trials tend to take longer on average, while later phases show more controlled and predictable timelines, likely due to standardized protocols and experience.

4. Total Distinct Trials by Country (Map)

What it shows
Geographic distribution of distinct clinical trials by country.
Marker size reflects the number of trials conducted in each location.
Maps provide immediate spatial context and help identify regional concentration of clinical research activity.
Clinical trials are heavily concentrated in North America, Europe, and parts of Asia, highlighting regional research infrastructure and regulatory maturity.



Page 3: Trial Completion & Risk Analysis
Purpose of the Page
This page focuses on trial success, risk signals, and operational uncertainty across clinical phases.
The goal is to identify which trials are more likely to complete, where risks of delay or failure increase, and how duration and enrollment interact with trial outcomes.

This page mostly answers the following business questions:

Which factors are associated with higher trial completion rates?
Are there patterns in trials that get terminated or withdrawn?
How does trial duration relate to enrollment size and completion risk?

Visuals
1. Completion Rate by Phase (Column Chart)

What it shows
Completion rate calculated as the proportion of completed trials within each clinical phase.

Why this visual
A simple column chart allows direct comparison of success likelihood across phases.
Completion rate is a key operational KPI for assessing trial maturity and risk.

As a result
Mid- and late-phase trials show higher completion rates, while early-phase trials exhibit significantly lower completion probability, reflecting higher uncertainty and exploratory nature.

2. Enrollment vs Duration (Relationship Insight) (Scatter Plot)

What it shows
Each point represents a clinical trial, plotting enrollment size against trial duration.
Color encoding by phase highlights structural differences across trial stages.

Why this visual
Scatter plots are ideal for detecting correlations, clusters, and outliers.
This visual supports exploratory analysis of whether longer trials tend to enroll more patients and where atypical trials occur.

As a result
Most trials cluster at lower enrollment and shorter duration, while a small number of trials act as outliers with very high enrollment or extended duration, indicating operational complexity or exceptional study designs.

3. Trial Duration Distribution by Phase (Completed Trials) (Box Plot)

What it shows
Distribution of trial duration for completed trials by phase, including median, interquartile range, and outliers.

Why this visual
Box plots effectively reveal variability, skewness, and extreme cases that averages alone would hide.
Restricting to completed trials avoids distortion from ongoing studies.

As a result
Early phases show greater variability and longer tails, while later phases exhibit more controlled and predictable durations, suggesting improved process standardization.

4. Status Breakdown by Phase (Stacked Column Chart)

What it shows
Distinct trial counts by phase, segmented by trial status such as completed, recruiting, terminated, or withdrawn.

Why this visual
Stacked columns allow simultaneous assessment of total volume and outcome composition.
This visual highlights where trials tend to succeed versus where they stall or fail.

As a result
Later phases are dominated by completed and recruiting trials, whereas early phases show a higher relative share of terminated and withdrawn studies, indicating elevated operational risk.






Bonus Questions (Answer in README) Please provide brief answers to these questions: 
1. Stakeholder Communication: How would you adapt your dashboard and presentation for a non-technical executive versus a clinical operations manager?
For non-technical users I would
High-level KPIs such as total trials, completion rates, average duration, and enrollment scale.
Clear trends and comparisons using simple visuals (bar charts, maps, summary cards).
Minimal interactivity to avoid cognitive overload.
Business-focused insights and implications rather than methodological details.
The presentation would focus on what happened, why it matters, and what decisions should be made.
For clinical operation, the dashboard would:
Expose detailed breakdowns by phase, status, geography, and therapeutic area.
Highlight risk signals such as long-running trials, low completion rates, and high termination rates.
Enable drill-down and filtering to investigate specific trial subsets.
Support operational planning, monitoring, and corrective actions.

2. Data Quality at Scale: What automated data quality checks would you implement if this pipeline ran daily with new incoming data? 

If this pipeline ran daily with new incoming data,  I would implement following automated data quality checks:
Ensure expected columns, data types, and constraints are preserved across loads.
Monitor missing values for critical fields such as start date, phase, status, and country.
Set alerts
Put constraints and validations and track all the abnormal incoming data
Detect sudden spikes or drops in trial counts, enrollment, or completion rates that may indicate data ingestion issues.

3. Self-Service Analytics: How would you design this solution to enable stakeholders to explore the data themselves without your direct involvement? 
To make report intuitive for stakeholders I would:
Give to the table intuitive naming
Create Business-friendly calculated measures
Clean and Intuitive design of the report
Business-friendly calculated measures

4. Compliance Considerations: If this were a GxP-regulated environment, what additional documentation or validation would be required for your analysis?
In my opinion, in GxP-regulated environment for my analysis there would be following documentations required:
Full documentation of data sources, transformations, and business rules.
Validation Documentation (Formal validation of ETL processes, Evidence that outputs are accurate)
Change Management like version control, impact assessment, and approval workflows for any change.
Access Controls and audit documentation
Log files
Technical Documentation and SOP (Standard Operating Procedures)


5. Advanced Analytics: What predictive or machine learning models could add value to this clinical trial analytics use case?
For clinical trial analytics following machine learning models would be useful:
Predictive modeling: Predicting trial results based on phases, enrollment, duration, sponsor characteristics; Predicting future risks and opportunities in clinical field
Risk scoring: Assign operational risk scores to ongoing trials to prioritize monitoring and intervention.
Clustering and segmentation: Group trials by behaviours to understand patterns that are causing particular results. This process will improve decision making.
