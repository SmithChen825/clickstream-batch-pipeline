# Clickstream batch pipeline

A learning project for exploring online shopping clickstream data with pandas, local PySpark, and Databricks. The local notebooks inspect the source, generate daily CSV batches, and read one batch with Spark. A separate Databricks notebook cleans the full source in Spark, saves Delta tables, and summarizes browsing behavior.

## Current progress

Completed:

- Inspect dates, missing values, duplicate event keys, click sequences, category codes, prices, and product codes with pandas.
- Build session and daily summaries as reference results.
- Generate 135 daily CSV batches and compare every file with its source records after reading it back.
- Start Spark locally and read the first batch with a defined 14-column schema.
- In Databricks, validate the full source with an explicit schema, create `event_date`, and save cleaned click, session, and daily Delta tables.
- Summarize session length, category browsing, daily activity, and repeat product views.

The Databricks workflow is separate from the local daily-batch workflow. The local notebooks do not yet implement a complete incremental pipeline; rejected-record handling, Parquet batches, duplicate-batch handling, failure recovery, automated tests, and performance measurements remain future work.

## Data

Download [Clickstream Data for Online Shopping from UCI](https://archive.ics.uci.edu/dataset/553/clickstream+data+for+online+shopping). The dataset is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

| Property | Observed value |
| --- | --- |
| Click records | 165,474 |
| Source columns | 14 |
| Dates | 2008-04-01 to 2008-08-13 |
| Dates with records | 135 |
| Session IDs | 24,026 |
| Product codes | 217 |

One row records a product-browsing click. The pair `(session ID, order)` is unique in the inspected data. Each session appears on one date, and its recorded click sequence starts at 1 with no internal gaps.

Daily file arrival is simulated by splitting the static source by event date. The dataset does not provide actual arrival times, purchase outcomes, or click times within the day. It cannot support purchase conversion rates or visit durations. Session IDs do not identify users across visits. Structural checks cannot establish that the source logs captured every click.

Dataset citation: *Clickstream Data for Online Shopping* (2019), UCI Machine Learning Repository. [DOI: 10.24432/C5QK7X](https://doi.org/10.24432/C5QK7X).

The accompanying data description also requests citation of: Łapczyński M., Białowąs S. (2013), "Discovering Patterns of Users' Behaviour in an E-shop - Comparison of Consumer Buying Behaviours in Poland and Other European Countries," *Studia Ekonomiczne*, no. 151, pp. 144-153.

## Project files

```text
clickstream/
  README.md
  environment.yml
  .gitignore
  data/
    raw/                              # Downloaded source files, excluded from Git
    batches/                          # Generated CSV files, excluded from Git
    notebooks/
      01_inspect_clickstream.ipynb
      02_spark_single_batch.ipynb
      03_databricks_clickstream_pipeline.ipynb
```

## Run locally

The notebooks have been run on Windows using Conda, Python 3.11.17, Java 17.0.18, and PySpark 4.0.1. The Spark notebook configures Java using the Windows Conda environment's `Library` directory. Other platforms need a different Java path.

### 1. Create the environment

Open Anaconda Prompt in the project root:

```bat
conda env create -f environment.yml
conda activate clickstream
python -m ipykernel install --user --name clickstream --display-name "Python (clickstream)"
```

If the `clickstream` environment already exists, activate it and check its installed versions before deciding whether to update it. The environment file pins the direct Python dependencies used here; it is not a lockfile for every transitive dependency. Recreation from this file has not yet been tested in a new environment.

### 2. Download the source

Extract the UCI download and place `e-shop clothing 2008.csv` in `data/raw/`. Keep the accompanying data description there as well. The CSV uses semicolons as delimiters.

### 3. Run the notebooks in order

Open the project folder in VS Code with the Python and Jupyter extensions installed. Select `Python (clickstream)` as the kernel for each notebook.

1. Open `data/notebooks/01_inspect_clickstream.ipynb`. Restart the kernel and run all cells. This builds pandas reference summaries and writes daily files under `data/batches/`.
2. Open `data/notebooks/02_spark_single_batch.ipynb`. Restart the kernel and run all cells. This configures Java, starts Spark with `local[2]`, and reads `clickstream_2008-04-01.csv`.

Relative paths assume that the working directory is `data/notebooks/`. Check `Path.cwd()` if a file cannot be found. The notebooks use separate kernel state; notebook 02 reads the batch file created by notebook 01.

Running notebook 01 again replaces the same-named generated batch files. It leaves the original CSV unchanged. Notebook 02 may initially report that Java is unavailable; its later setup cells configure Java for the current kernel.

### Run in Databricks

Notebook 03 is a separate cloud workflow. In Databricks, create or use the `workspace.default.clickstream_data` volume, upload `e-shop clothing 2008.csv` to its root, and open the notebook with Serverless compute. Its input path is `/Volumes/workspace/default/clickstream_data/e-shop clothing 2008.csv`. The notebook writes three Delta tables in `workspace.default`: `clickstream_silver`, `clickstream_sessions`, and `clickstream_daily`. It uses overwrite mode, so rerunning the table-writing cells replaces those tables. The Databricks notebook has been run in the project owner's Free Edition workspace; other workspaces may need different catalog, schema, volume, or file paths.

## Expected results

| Check | Expected result |
| --- | --- |
| Source data shape | 165,474 rows and 14 columns |
| Session summary | 24,026 rows; 165,474 total clicks |
| Daily summary | 135 rows; 165,474 total clicks |
| Batch verification | 135 files match their corresponding source records |
| Spark startup check | `spark.range(10).count()` returns 10 |
| First batch read | 3,181 rows and 14 columns |
| Databricks cleaned table | 165,474 rows and 15 columns |
| Databricks session summary | 24,026 rows |
| Databricks daily summary | 135 rows; 165,474 clicks; 24,026 sessions |

The notebooks contain saved outputs. Batch comparisons use `pandas.testing.assert_frame_equal`; several exploratory checks print counts for review. Spark uses `FAILFAST` for parsing and checks the CSV header against the schema. These are initial checks; business validation and automated failure tests are planned.

## Next work

Extend the local Spark workflow to process multiple daily batches, write Parquet, and compare its summaries with the pandas reference results. Then test repeat submissions, failure recovery, and performance. The Databricks notebook currently provides a separate full-file Delta workflow.
