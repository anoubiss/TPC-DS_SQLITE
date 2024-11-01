-- start query 1 in stream 0 using template query44.tpl
WITH ranked_items AS (
    SELECT 
        ss_item_sk AS item_sk,
        AVG(ss_net_profit) AS rank_col
    FROM store_sales
    WHERE ss_store_sk = 2
    GROUP BY ss_item_sk
    HAVING AVG(ss_net_profit) > 0.9 * (
        SELECT AVG(ss_net_profit)
        FROM store_sales
        WHERE ss_store_sk = 2 AND ss_hdemo_sk IS NULL
    )
),
ascended AS (
    SELECT item_sk, 
           RANK() OVER (ORDER BY rank_col ASC) AS rnk
    FROM ranked_items
),
descended AS (
    SELECT item_sk, 
           RANK() OVER (ORDER BY rank_col DESC) AS rnk
    FROM ranked_items
)
SELECT a.rnk, 
       i1.i_product_name AS best_performing, 
       i2.i_product_name AS worst_performing
FROM ascended a
JOIN descended d ON a.rnk = d.rnk
JOIN item i1 ON i1.i_item_sk = a.item_sk
JOIN item i2 ON i2.i_item_sk = d.item_sk
ORDER BY a.rnk
LIMIT 100;


-- end query 1 in stream 0 using template query44.tpl
