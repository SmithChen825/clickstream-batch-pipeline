# Where should an online clothing store investigate browsing drop-off?

Prepared 19 November 2026 · Historical browsing data: 1 April–13 August 2008

[Explore the interactive dashboard](https://smithchen825.github.io/clickstream-batch-pipeline/) · [View the metric SQL](sql/daily_entry_categories.sql)

## 🔎 Executive Summary

**Investigate the first-click experience for sessions beginning in Blouses.** Their observed continuation rate was **73.7%**, compared with **82.1%** for Trousers, the highest category: an **8.4 percentage-point gap**. The comparison identifies a useful starting point for investigation; it does not establish that the category or its page design caused visitors to stop. [1](docs/data/daily_entry_categories.csv)

Across **24,026 sessions and 165,474 clicks**, **60.8% of sessions contained no more than five clicks**. Early browsing therefore deserves attention, but a short session may reflect either efficient browsing or unmet needs. There are no purchase outcomes with which to distinguish them. [1](docs/data/daily_entry_categories.csv)

Before recommending a redesign, compare entry categories within similar dates and visitor/product segments. If the difference persists in current data, test a specific product-discovery change with purchase and usability measures alongside continuation. No intervention, experiment or commercial uplift has been measured in this project.

## 📌 Findings and business implications

### 1. Blouses has the lowest observed continuation rate

Each session is assigned to the category of its **first recorded click**, ordered by `click_order`. A continued session has at least two recorded clicks; the next click can be in **any category**. The table covers all 135 observed dates. [1](docs/data/daily_entry_categories.csv) [2](sql/daily_entry_categories.sql)

| First category | Starting sessions | Continued sessions | Continuation rate |
| --- | ---: | ---: | ---: |
| Trousers | 9,247 | 7,588 | **82.1%** |
| Sale | 3,862 | 3,100 | 80.3% |
| Skirts | 6,472 | 5,021 | 77.6% |
| Blouses | 4,445 | 3,275 | **73.7%** |

Blouses accounts for **1,170 single-click sessions**. That is a population worth examining, not a count of lost customers or recoverable sales. Differences in visitor intent, country, dates, product assortment or initial page position could explain part of the gap. The table is an unadjusted comparison; no causal effect or statistical-significance claim is made.

### 2. Most sessions involve relatively few clicks

| Recorded clicks per session | Sessions | Share of all sessions |
| --- | ---: | ---: |
| 1 | 5,042 | 21.0% |
| 2–5 | 9,574 | 39.8% |
| 6–10 | 4,846 | 20.2% |
| 11+ | 4,564 | 19.0% |

The overall average is **6.89 clicks per session**, calculated as total clicks divided by total sessions. The distribution shows why the average alone is insufficient: the 11+ group can raise it even though most sessions have five clicks or fewer. [1](docs/data/daily_entry_categories.csv)

This supports examining what visitors encounter early in a session. It does not justify maximizing clicks: more clicks could also mean difficulty finding a suitable product. Single-click sessions are a recorded browsing pattern, not a verified exit event or a standard web-analytics bounce metric.

### 3. Trousers receives the most click activity

Trousers accounts for **49,742 clicks (30.1%)**, ahead of Sale (**38,747**), Blouses (**38,577**) and Skirts (**38,408**). These are categories of the clicked products, whereas the continuation table groups sessions by their first category. The two views answer different questions. [1](docs/data/daily_entry_categories.csv)

Trousers is a useful comparison category and a high-activity area to include in discovery testing. Click volume alone cannot establish customer preference, profitability or the right inventory allocation: product exposure, repeated views and assortment size can affect the totals.

## 🎯 Recommended next steps

| Priority | Proposed action | Evidence needed and decision it would support |
| --- | --- | --- |
| 1 | Check whether the Blouses gap persists across comparable segments. | Compare continuation by date or week, country and first-click product/page characteristics. Show session counts and pooled rates; use common segment weights where coverage permits. If the gap largely disappears, investigate visitor/product mix before changing the interface. |
| 2 | Review the early browsing experience for the segments with a persistent gap. | Examine product information, navigation and related-product discovery through a current-site review or usability study. These are hypotheses to investigate, not defects established by this dataset. |
| 3 | Test one specific change if current evidence supports it. | For example, compare existing navigation with a clearer related-product option. Predefine eligibility, randomization, sample size and duration. Measure continuation as a diagnostic, with purchase conversion and usability/performance guardrails collected through new instrumentation. Ship only if the results support a better customer outcome. |

The historical data cannot supply a credible revenue forecast or a current experiment sample-size plan on its own. The Trousers rate is a comparison point, not a target Blouses is assumed able to reach.

## 🧮 Metric definitions and evidence

- **Continuation rate:** `sum(sessions - single_click) / sum(sessions)` for the selected first category and dates. Rates use pooled counts, not an average of daily percentages.
- **Category click share:** clicks on products in a category divided by all recorded clicks. A session may contribute clicks to several categories.
- **Average clicks per session:** total clicks divided by distinct sessions. The validated dataset has each session on one date, allowing the daily session counts to reconcile with the overall count.
- **Scope:** all observed sessions from 2008-04-01 through 2008-08-13, without dashboard interaction filters.

The report's counts and rates were recalculated from the committed [daily entry-category data](docs/data/daily_entry_categories.csv). Its click and session totals also reconcile with [daily traffic data](docs/data/daily_traffic.csv): **165,474 clicks, 24,026 sessions and 135 dates**. These are related exports from the same underlying dataset, not independent samples.

The [pipeline validation record](reports/pipeline_validation.md) documents the separate Databricks full-load checks: source-to-Bronze record reconciliation, Silver quality checks and Gold write/read-back checks passed. Checked missing values, rescued records and duplicate session/click-order keys were zero. Matching overall totals does not by itself establish equality of every dashboard export and new Gold row; this report does not claim that separate detailed comparison has been completed.

## ⚠️ Limitations

- **No purchase or order outcomes:** continuation cannot be interpreted as purchase conversion, revenue or retention.
- **Observational category assignment:** visitors were not randomly assigned to entry categories. The rate gap does not isolate a category or design effect.
- **Historical, limited setting:** this 2008 dataset does not establish how a present-day store or a different customer population behaves. The proposed actions require current evidence.
- **Limited identity and timing:** session IDs do not identify people across visits, and there are no within-day timestamps for session duration or time-to-next-click. First recorded click is not necessarily a complete record of a visitor's arrival journey.
- **Unmeasured exposure and context:** the available data does not establish acquisition source, product availability or all products shown to a visitor. Click counts therefore cannot be treated as exposure-adjusted preference measures.
- **Coverage and measurement:** observed dates do not prove full-day collection. Low-volume boundary dates need checking before interpreting traffic drops. Passing schema and consistency checks cannot detect every tracking omission or source measurement error.

## 📚 Sources

1. [Committed daily entry-category aggregates](docs/data/daily_entry_categories.csv): session, click and depth counts used throughout this report.
2. [First-category aggregation SQL](sql/daily_entry_categories.sql): session assignment and metric construction.
3. [Daily traffic aggregates](docs/data/daily_traffic.csv): reconciliation of overall counts and date coverage.
4. [Databricks validation record](reports/pipeline_validation.md): observed pipeline checks and execution boundaries.

Dataset attribution and license are provided in the [README](README.md#-data-source-and-attribution).
