-- start query 1 in stream 0 using template query86.tpl

WITH base_data AS (
    SELECT
        ws.ws_net_paid,
        i.i_category,
        i.i_class
    FROM
        web_sales ws
        JOIN date_dim d1 ON ws.ws_sold_date_sk = d1.d_date_sk
        JOIN item i ON ws.ws_item_sk = i.i_item_sk
    WHERE
        d1.d_month_seq BETWEEN 1212 AND 1212 + 11
),
computed_data AS (
    -- Level 0: Detailed level (i_category, i_class)
    SELECT
        SUM(ws_net_paid) AS total_sum,
        i_category,
        i_class,
        0 AS lochierarchy,
        RANK() OVER (
            PARTITION BY 0, i_category
            ORDER BY SUM(ws_net_paid) DESC
        ) AS rank_within_parent
    FROM
        base_data
    GROUP BY
        i_category,
        i_class

    UNION ALL

    -- Level 1: Subtotal level (i_category)
    SELECT
        SUM(ws_net_paid) AS total_sum,
        i_category,
        NULL AS i_class,
        1 AS lochierarchy,
        RANK() OVER (
            PARTITION BY 1
            ORDER BY SUM(ws_net_paid) DESC
        ) AS rank_within_parent
    FROM
        base_data
    GROUP BY
        i_category

    UNION ALL

    -- Level 2: Grand total
    SELECT
        SUM(ws_net_paid) AS total_sum,
        NULL AS i_category,
        NULL AS i_class,
        2 AS lochierarchy,
        1 AS rank_within_parent
    FROM
        base_data
)
SELECT
    total_sum,
    i_category,
    i_class,
    lochierarchy,
    rank_within_parent
FROM
    computed_data
ORDER BY
    lochierarchy DESC,
    CASE WHEN lochierarchy = 0 THEN i_category END,
    rank_within_parent
LIMIT 100;

-- end query 1 in stream 0 using template query86.tpl
