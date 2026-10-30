# Online Shopping Clickstream Analysis

A portfolio project exploring how visitors browsed an online clothing store, using **Python, PySpark, Databricks and Delta Lake**.

**Dataset:** UCI Clickstream Data for Online Shopping · **Period:** April–August 2008 · **165,474 click events**

## 🔎 Overview

The project turns click-level records into session and daily summaries, then examines browsing depth, product-category activity and repeat product views. The analysis uses a local pandas workflow for initial data checks and Databricks Spark for full-file processing and Delta tables.

## 💼 Business Questions

- How many clicks do visitors make in a session, and how widely do they browse across products?
- Which product categories receive the most browsing activity?
- How does daily traffic vary, and do click volume and session volume move together?
- How often does the same product appear more than once within a session?

The dataset records browsing events. It does not include purchases, orders or conversion outcomes, so the project does not estimate sales or purchase conversion.

## 🧰 Solution

The work has two complementary parts:

1. **Local exploration:** pandas checks the source structure and data quality, builds reference summaries, and splits the static dataset into 135 daily CSV files. Every batch was read back and compared with its source records.
2. **Databricks processing:** Spark reads the uploaded source with an explicit schema, standardizes field names, adds an event date, checks key quality, and saves the cleaned data and analytical summaries as Delta tables.

The Databricks tables are:

- `workspace.default.clickstream_silver` — cleaned click-level records
- `workspace.default.clickstream_sessions` — one row per session
- `workspace.default.clickstream_daily` — one row per date

The daily files simulate date-based batches from a static historical dataset. They do not represent real-time ingestion.

## 📌 Key Findings

- The dataset contains **165,474 clicks** across **24,026 sessions** and **135 dates**, from **2008-04-01 to 2008-08-13**.
- Sessions have a median of **4 clicks** and an average of about **6.89 clicks**. The longest observed session has **195 clicks**.
- **Trousers** received the most clicks (**49,742**). **Skirts** had the highest average listed price (**$51.19**); Sale had the lowest (**$36.23**).
- Daily clicks and daily sessions have a strong positive correlation (**r = 0.949**) across the observed dates.
- **6,046 sessions** included at least one repeat product view. This means a product code appeared more than once in a session; it does not explain why the visitor returned to it.

## 📊 Dashboard

An interactive dashboard is a planned next step. The current analysis and saved results are available in the notebooks and Databricks Delta tables.

## 🧪 Data Quality and Limitations

The inspected data has no missing values in the checked fields, no duplicate `(session_id, click_order)` pairs, and no invalid values in the documented category codes. Click totals and session totals reconcile across the source data, daily summaries and Databricks tables.

The data has no purchase outcomes or within-day timestamps. It cannot support conversion rates, revenue, visit duration or user-level repeat-visit analysis. Session IDs identify sessions, not people across visits. High daily clicks per session on dates with few sessions should be interpreted cautiously.

## 🗂️ Project Files

| File | Purpose |
| --- | --- |
| `data/notebooks/01_inspect_clickstream.ipynb` | pandas data inspection, reference summaries and daily batch checks |
| `data/notebooks/02_spark_single_batch.ipynb` | local PySpark setup and single-batch read |
| `data/notebooks/03_databricks_clickstream_pipeline.ipynb` | Databricks Spark processing, Delta tables and browsing analysis |
| `environment.yml` | local Python environment |
| `.gitignore` | excludes raw data and generated batches |

Raw source files and generated CSV batches are excluded from Git.

## 📚 Data Source and Attribution

*Clickstream Data for Online Shopping* (2019). UCI Machine Learning Repository. [Dataset page](https://archive.ics.uci.edu/dataset/553/clickstream+data+for+online+shopping) · [DOI: 10.24432/C5QK7X](https://doi.org/10.24432/C5QK7X). Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

The accompanying data description also requests citation of: Łapczyński, M. and Białowąs, S. (2013). “Discovering Patterns of Users' Behaviour in an E-shop - Comparison of Consumer Buying Behaviours in Poland and Other European Countries.” *Studia Ekonomiczne*, no. 151, pp. 144–153.
