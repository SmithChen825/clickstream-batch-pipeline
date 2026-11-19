# Databricks pipeline validation

Validated on **19 November 2026**, using the actual Databricks Job outputs. Times below use **Australia/Sydney (UTC+11 on this date)**.

The pipeline processes the UCI Clickstream Data for Online Shopping dataset. The daily files represent historical event dates, not the dates when the Job ran. [Notebook 04](../data/notebooks/04_incremental_clickstream_trial.ipynb) contains the code used for these checks.

## Full-load result

Job run **896655823848715** was manually triggered at 15:06, finished at 15:07 and reported **Succeeded**. Task duration was **1 minute 2 seconds**.

| Check | Observed result |
| --- | ---: |
| Daily CSV files / distinct filename dates | 135 / 135 |
| Event-date coverage | 2008-04-01 to 2008-08-13 |
| Source / Bronze / Silver click records | 165,474 / 165,474 / 165,474 |
| Distinct sessions | 24,026 |
| Silver event dates | 135 |
| Gold session rows | 24,026 |
| Gold daily rows | 135 |
| Gold date/entry-category rows | 540 |
| Rescued records | 0 |
| Duplicate `(session_id, click_order)` pairs | 0 |
| Sessions spanning multiple event dates | 0 |
| Violations of checked missing-value and value-range rules | 0 |

Before this load, Bronze held 8,491 records from three files. The remaining 132 files added **156,983 records**, bringing the total to **165,474**. File discovery listed 135 unique dates from April 1 through August 13, with no missing dates in that range.

## Observed runs

| Stage | Job run ID | Trigger | Result |
| --- | --- | --- | --- |
| Two-day Job after correcting the stale first-day assertion | `1070565028334373` | Manual, 14:41 | Succeeded; 6,637 clicks, 957 sessions, 2 dates |
| Scheduled execution | `654898533516865` | **By scheduler**, 14:50 | Succeeded; verified that the configured schedule launched the task |
| Add April 3 | `1051755567047711` | Manual, 14:59 | Succeeded; 8,491 clicks, 1,233 sessions, 3 dates |
| Rerun the same three files | `824309390510506` | Manual, 15:01 | Succeeded; still 8,491 clicks and 1,233 sessions |
| Load remaining 132 files | `896655823848715` | Manual, 15:06 | Succeeded; full-load totals shown above |

The first two manual Job attempts failed because a Bronze assertion still expected the first day's 3,181 rows after the second day had arrived. The assertion was corrected, then the fixed two-day assumptions were replaced with source-derived validation before loading day three. Those failed attempts are not counted as successful pipeline runs.

The rerun check demonstrates that the existing checkpoint prevented duplicate ingestion for the unchanged three-file input. A separate no-new-file rerun after the 135-file load has not been recorded here. Likewise, the full load was manually triggered; the scheduler was verified separately in the earlier two-day run. There were not 135 separate scheduled executions.

## What the notebook checks

- **Inputs:** valid daily filenames, nonempty files, explicit CSV schema and matching headers, no header-only files, and record dates matching filename dates.
- **Source to Bronze:** total and per-file row counts, session totals, and both directions of `exceptAll` over the 14 business fields. This preserves duplicate multiplicities when checking missing or unexpected records.
- **Silver quality:** required fields, blank product codes, positive IDs/click order/price, documented category-code ranges, unique session/click-order keys and one date per session.
- **Silver persistence:** daily counts and summary totals agree with the source CSVs; saved records match the calculated Silver records in both directions.
- **Gold:** daily clicks and sessions reconcile with Silver; each session has one first category; continuation rates are between zero and one; all three saved tables match their calculated results in both directions.

The UI's shortened daily preview is not the validation scope: the daily reconciliation checks every date. These checks establish consistency with the uploaded source, not that every historical source record is free of measurement error.

## Deployed configuration

| Setting | Value |
| --- | --- |
| Job | `clickstream_two_day_trial` |
| Task | `process_clickstream` |
| Notebook | `04_incremental_clickstream_trial` |
| Compute | Serverless, Databricks Free Edition |
| Maximum concurrent runs | 1 |
| Schedule at validation time | Daily at 14:50:55, `Australia/Sydney` |
| Quartz cron | `55 50 14 * * ?` |
| Incoming directory | `/Volumes/workspace/default/clickstream_data/two_day_trial/incoming` |
| Checkpoint | `/Volumes/workspace/default/clickstream_data/two_day_trial/checkpoints/bronze` |

The original pilot names are retained so the existing checkpoint and tables remain connected. Bronze appends new files; Silver and Gold use full rebuilds from accumulated data. Source reconciliation also reads the retained CSVs on each run. This is a small-dataset implementation, not incremental computation at every layer.

Files must remain unchanged and available for reconciliation. Uploads were manual and performed between runs. The daily schedule automates processing, while the historical source delivery and GitHub Pages data refresh remain separate manual steps.

Run IDs are included for traceability inside the owner's Databricks workspace. They are not public dashboard links. This record summarizes observed run outputs; the repository notebook intentionally clears older interactive outputs rather than presenting them as the full-load run.
