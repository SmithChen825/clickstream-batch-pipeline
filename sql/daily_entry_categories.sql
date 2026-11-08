-- Each session belongs to the category of its first recorded click.
WITH events AS (
    SELECT session_id, event_date, main_category,
           FIRST_VALUE(main_category) OVER (
               PARTITION BY session_id ORDER BY click_order
           ) AS entry_category
    FROM workspace.default.clickstream_silver
), sessions AS (
    SELECT session_id, MIN(event_date) AS event_date, entry_category,
           COUNT(*) AS clicks,
           SUM(CASE WHEN main_category = 1 THEN 1 ELSE 0 END) AS trousers,
           SUM(CASE WHEN main_category = 2 THEN 1 ELSE 0 END) AS skirts,
           SUM(CASE WHEN main_category = 3 THEN 1 ELSE 0 END) AS blouses,
           SUM(CASE WHEN main_category = 4 THEN 1 ELSE 0 END) AS sale
    FROM events
    GROUP BY session_id, entry_category
)
SELECT event_date, entry_category, COUNT(*) AS sessions, SUM(clicks) AS clicks,
       SUM(trousers) AS trousers, SUM(skirts) AS skirts, SUM(blouses) AS blouses, SUM(sale) AS sale,
       SUM(CASE WHEN clicks = 1 THEN 1 ELSE 0 END) AS single_click,
       SUM(CASE WHEN clicks BETWEEN 2 AND 5 THEN 1 ELSE 0 END) AS two_to_five,
       SUM(CASE WHEN clicks BETWEEN 6 AND 10 THEN 1 ELSE 0 END) AS six_to_ten,
       SUM(CASE WHEN clicks >= 11 THEN 1 ELSE 0 END) AS eleven_plus
FROM sessions
GROUP BY event_date, entry_category
ORDER BY event_date, entry_category
