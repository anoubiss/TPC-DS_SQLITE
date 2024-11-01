-- start query 1 in stream 0 using template query70.tpl

WITH top_states AS (
    SELECT s_state
    FROM (
        SELECT
            s_state,
            RANK() OVER (ORDER BY SUM(ss_net_profit) DESC) AS ranking
        FROM
            store_sales ss
            JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
            JOIN store s ON ss.ss_store_sk = s.s_store_sk
        WHERE
            d.d_month_seq BETWEEN 1212 AND 1212 + 11
        GROUP BY
            s_state
    ) tmp1
    WHERE
        ranking <= 5
)

SELECT
    total_sum,
    s_state,
    s_county,
    lochierarchy,
    rank_within_parent
FROM (
    -- Level 0: Group by s_state and s_county
    SELECT
        SUM(ss.ss_net_profit) AS total_sum,
        s.s_state,
        s.s_county,
        0 AS lochierarchy,
        RANK() OVER (
            PARTITION BY 0, s.s_state
            ORDER BY SUM(ss.ss_net_profit) DESC
        ) AS rank_within_parent
    FROM
        store_sales ss
        JOIN date_dim d1 ON ss.ss_sold_date_sk = d1.d_date_sk
        JOIN store s ON ss.ss_store_sk = s.s_store_sk
    WHERE
        d1.d_month_seq BETWEEN 1212 AND 1212 + 11
        AND s.s_state IN (SELECT s_state FROM top_states)
    GROUP BY
        s.s_state,
        s.s_county

    UNION ALL

    -- Level 1: Group by s_state
    SELECT
        SUM(ss.ss_net_profit) AS total_sum,
        s.s_state,
        NULL AS s_county,
        1 AS lochierarchy,
        RANK() OVER (
            PARTITION BY 1
            ORDER BY SUM(ss.ss_net_profit) DESC
        ) AS rank_within_parent
    FROM
        store_sales ss
        JOIN date_dim d1 ON ss.ss_sold_date_sk = d1.d_date_sk
        JOIN store s ON ss.ss_store_sk = s.s_store_sk
    WHERE
        d1.d_month_seq BETWEEN 1212 AND 1212 + 11
        AND s.s_state IN (SELECT s_state FROM top_states)
    GROUP BY
        s.s_state

    UNION ALL

    -- Level 2: Grand total (no grouping)
    SELECT
        SUM(ss.ss_net_profit) AS total_sum,
        NULL AS s_state,
        NULL AS s_county,
        2 AS lochierarchy,
        1 AS rank_within_parent
    FROM
        store_sales ss
        JOIN date_dim d1 ON ss.ss_sold_date_sk = d1.d_date_sk
        JOIN store s ON ss.ss_store_sk = s.s_store_sk
    WHERE
        d1.d_month_seq BETWEEN 1212 AND 1212 + 11
        AND s.s_state IN (SELECT s_state FROM top_states)
) combined_results
ORDER BY
    lochierarchy DESC,
    CASE WHEN lochierarchy = 0 THEN s_state END,
    rank_within_parent
LIMIT 100;

-- end query 1 in stream 0 using template query70.tpl
