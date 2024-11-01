-- start query 1 in stream 0 using template query56.tpl
WITH ss AS (
    SELECT i_item_id, SUM(ss_ext_sales_price) AS total_sales
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    JOIN customer_address ON ss_addr_sk = ca_address_sk
    JOIN item ON ss_item_sk = i_item_sk
    WHERE i_item_id IN (
        SELECT i_item_id
        FROM item
        WHERE i_color IN ('orchid', 'chiffon', 'lace')
    )
    AND d_year = 2000
    AND d_moy = 1
    AND ca_gmt_offset = -8
    GROUP BY i_item_id
),
cs AS (
    SELECT i_item_id, SUM(cs_ext_sales_price) AS total_sales
    FROM catalog_sales
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    JOIN customer_address ON cs_bill_addr_sk = ca_address_sk
    JOIN item ON cs_item_sk = i_item_sk
    WHERE i_item_id IN (
        SELECT i_item_id
        FROM item
        WHERE i_color IN ('orchid', 'chiffon', 'lace')
    )
    AND d_year = 2000
    AND d_moy = 1
    AND ca_gmt_offset = -8
    GROUP BY i_item_id
),
ws AS (
    SELECT i_item_id, SUM(ws_ext_sales_price) AS total_sales
    FROM web_sales
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    JOIN customer_address ON ws_bill_addr_sk = ca_address_sk
    JOIN item ON ws_item_sk = i_item_sk
    WHERE i_item_id IN (
        SELECT i_item_id
        FROM item
        WHERE i_color IN ('orchid', 'chiffon', 'lace')
    )
    AND d_year = 2000
    AND d_moy = 1
    AND ca_gmt_offset = -8
    GROUP BY i_item_id
)
SELECT i_item_id, SUM(total_sales) AS total_sales
FROM (
    SELECT * FROM ss
    UNION ALL
    SELECT * FROM cs
    UNION ALL
    SELECT * FROM ws
) tmp1
GROUP BY i_item_id
ORDER BY total_sales DESC, i_item_id
LIMIT 100;


-- end query 1 in stream 0 using template query56.tpl
