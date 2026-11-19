# Online Shopping Clickstream Analysis

[**View the interactive dashboard →**](https://smithchen825.github.io/clickstream-batch-pipeline/)

[**Business report**](BUSINESS_REPORT.md) · [**Pipeline validation record**](reports/pipeline_validation.md) · [**Pipeline notebook**](data/notebooks/04_incremental_clickstream_trial.ipynb)

An analysis of how shoppers browse an online clothing store, built with Python, PySpark, Databricks and Delta Lake.

**165,474 clicks · 24,026 sessions · 135 days** | UCI Clickstream Data for Online Shopping, April to August 2008

[![Live dashboard showing continuation rates by first category, click and session totals, daily traffic, category activity and session depth](assets/dashboard-preview.jpg)](https://smithchen825.github.io/clickstream-batch-pipeline/)

*April 1 to August 13, 2008. Click the image to filter the dashboard by date, category or session length.*

## 🔎 Overview

Where do shoppers keep browsing after their first click? This project compares browsing activity across product categories and looks at how many products shoppers view, daily traffic and repeat product views.

I checked the source data with pandas, built a scheduled data pipeline in Databricks, and published an interactive dashboard. The pipeline processed all 135 daily files. Its totals match the source: 165,474 clicks across 24,026 sessions.

## 💼 Business questions

- How many clicks do visitors make in a session, and how widely do they browse across products?
- Which product categories receive the most browsing activity?
- How does daily traffic vary, and do click volume and session volume move together?
- How often does the same product appear more than once within a session?

The dataset contains browsing events but no orders or purchases, so this analysis cannot measure sales or purchase conversion.

## 🧰 Solution

### ⚙️ Data pipeline

1. Use pandas to check the source data and split it into 135 daily CSVs. Read each file back to check that it matches the source, then upload the files to a Unity Catalog volume.
2. Load new files into Bronze, the raw Delta table. Auto Loader uses `availableNow` to process available files, and a saved checkpoint tracks progress. Each run compares file counts, row counts and records with the retained CSVs.
3. Rebuild Silver, the cleaned table, from all Bronze records. Spark standardizes product codes, creates the event date and checks missing values, category codes and duplicate click keys.
4. Build Gold summary tables for sessions, dates and first categories by date. Check their totals against Silver and compare the saved records with the calculated results.
5. Run the notebook daily through a Databricks Job on serverless compute. Tests passed for a scheduled run, adding a third day, rerunning without new files and loading all 135 files.
6. Export dashboard summaries and commit them to GitHub. GitHub Pages displays these files as interactive charts. Updating the public dashboard is a separate step from the Databricks Job.

The scheduled pipeline writes these Delta tables in `workspace.default`:

| Table | What it contains |
| --- | --- |
| `clickstream_bronze_trial` | original clicks, source file and ingestion details; new files are appended |
| `clickstream_silver_trial` | validated click-level records; rebuilt each run |
| `clickstream_sessions_trial` | one row per session |
| `clickstream_daily_trial` | one row per date |
| `clickstream_entry_daily_trial` | one row per date and first category |

The `_trial` tables and `two_day_trial` input path now contain the full dataset. Their names come from the initial test. Notebook 03 uses separate analysis tables.

All 135 files passed the full-load checks: 165,474 clicks, 24,026 sessions, zero rescued rows and no duplicate click keys. [View the pipeline notebook](data/notebooks/04_incremental_clickstream_trial.ipynb) · [View the validation record](reports/pipeline_validation.md).

The historical CSVs are uploaded manually. The Job processes files after they arrive; it does not upload them or collect live events. Bronze loads new files incrementally. Silver and Gold are rebuilt from the accumulated data on each run.

## 📌 Key findings

- Shoppers clicked again in **82.1%** of sessions starting in Trousers, the highest rate, and **73.7%** of sessions starting in Blouses, the lowest. The gap was **8.4 percentage points**. A second click in any category counts.
- The dataset contains **165,474 clicks** across **24,026 sessions** and **135 dates**, from **2008-04-01 to 2008-08-13**.
- Sessions have a median of **4 clicks** and an average of about **6.89 clicks**. The longest observed session has **195 clicks**.
- **Trousers** received the most clicks (**49,742**). The average listed price per click was highest for Skirts ($51.19) and lowest for Sale ($36.23).
- Daily clicks and daily sessions have a strong positive correlation (**r = 0.949**) across the observed dates.
- In **6,046 sessions**, a shopper viewed the same product code more than once. The data does not explain why they returned to it.

## 📊 Dashboard

The [business report](BUSINESS_REPORT.md) explains the findings, why Blouses is worth investigating and what to check before recommending changes.

Open the [live dashboard](https://smithchen825.github.io/clickstream-batch-pipeline/) and choose a date range to compare second-click rates. Select a starting category to see what those shoppers browsed and how many clicks they made. [View the SQL behind the rates](sql/daily_entry_categories.sql).

## 🧪 Data quality and limitations

The checks found no missing values in the tested fields, no duplicate `(session_id, click_order)` pairs and no invalid category codes. Click and session totals match across the source data, daily summaries and Databricks tables.

There are no purchase records or timestamps within each day, so the data cannot show revenue, purchase conversion or visit duration. Session IDs cannot identify the same person across visits. Treat high average clicks per session cautiously on days with few sessions.

## 🗂️ Project files

Read notebook 01 for the pandas checks and daily batch exports, then notebook 02 for the local Spark batch-reading exercise. Run both from `data/notebooks/` in the local environment.

Notebook 03 reads the full source CSV from the `workspace.default.clickstream_data` volume in Databricks and builds the analysis tables. Run its cells in order. Notebook 04 runs the scheduled pipeline using separate `_trial` tables. The SQL in `sql/daily_entry_categories.sql` reads Notebook 03's `workspace.default.clickstream_silver` table.

| File | Purpose |
| --- | --- |
| `BUSINESS_REPORT.md` | core findings, business recommendations, metric definitions and limitations |
| `data/notebooks/01_inspect_clickstream.ipynb` | pandas data inspection, reference summaries and daily batch checks |
| `data/notebooks/02_spark_single_batch.ipynb` | local PySpark setup and single-batch read |
| `data/notebooks/03_databricks_clickstream_pipeline.ipynb` | Databricks Spark processing, Delta tables and browsing analysis |
| `data/notebooks/04_incremental_clickstream_trial.ipynb` | scheduled Auto Loader pipeline with Bronze, Silver and Gold tables and checks against the current source files |
| `reports/pipeline_validation.md` | observed scheduled-run, incremental-load, rerun and 135-day validation results |
| `sql/daily_entry_categories.sql` | daily summaries by first category, including the counts used for continuation rates |
| `docs/index.html` | published dashboard and browser-side filtering |
| `docs/data/` | aggregate CSVs used by the dashboard |
| `docs/continuation-sql.html` | SQL explanation available from the dashboard |
| `environment.yml` | local Python environment |
| `.gitignore` | excludes raw data and generated batches |

Raw source files and generated daily batches are excluded from Git. The aggregate CSVs in docs/data/ are committed so the public dashboard can load them.

## 📚 Data source and attribution

*Clickstream Data for Online Shopping* (2019). UCI Machine Learning Repository. [Dataset page](https://archive.ics.uci.edu/dataset/553/clickstream+data+for+online+shopping) · [DOI: 10.24432/C5QK7X](https://doi.org/10.24432/C5QK7X). Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

The data description also requests this citation: Łapczyński, M. and Białowąs, S. (2013). “Discovering Patterns of Users' Behaviour in an E-shop - Comparison of Consumer Buying Behaviours in Poland and Other European Countries.” *Studia Ekonomiczne*, no. 151, pp. 144-153.
