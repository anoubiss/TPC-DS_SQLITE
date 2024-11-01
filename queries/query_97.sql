-- start query 1 in stream 0 using template query97.tpl

WITH ssci AS (
    SELECT
        ss.ss_customer_sk AS customer_sk,
        ss.ss_item_sk AS item_sk
    FROM
        store_sales ss
        JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    WHERE
        d.d_month_seq BETWEEN 1212 AND 1223
    GROUP BY
        ss.ss_customer_sk,
        ss.ss_item_sk
),
csci AS (
    SELECT
        cs.cs_bill_customer_sk AS customer_sk,
        cs.cs_item_sk AS item_sk
    FROM
        catalog_sales cs
        JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
    WHERE
        d.d_month_seq BETWEEN 1212 AND 1223
    GROUP BY
        cs.cs_bill_customer_sk,
        cs.cs_item_sk
),
all_combinations AS (
    SELECT customer_sk, item_sk FROM ssci
    UNION
    SELECT customer_sk, item_sk FROM csci
)
SELECT
    SUM(CASE WHEN s.customer_sk IS NOT NULL AND c.customer_sk IS NULL THEN 1 ELSE 0 END) AS store_only,
    SUM(CASE WHEN s.customer_sk IS NULL AND c.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS catalog_only,
    SUM(CASE WHEN s.customer_sk IS NOT NULL AND c.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS store_and_catalog
FROM
    all_combinations ac
    LEFT JOIN ssci s ON ac.customer_sk = s.customer_sk AND ac.item_sk = s.item_sk
    LEFT JOIN csci c ON ac.customer_sk = c.customer_sk AND ac.item_sk = c.item_sk
LIMIT 100;

-- end query 1 in stream 0 using template query97.tpl
