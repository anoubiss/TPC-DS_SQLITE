-- start query 1 in stream 0 using template query58.tpl
WITH ss_items AS (
  SELECT item.i_item_id AS item_id,
         SUM(store_sales.ss_ext_sales_price) AS ss_item_rev
  FROM store_sales
  JOIN item ON store_sales.ss_item_sk = item.i_item_sk
  JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
  WHERE date_dim.d_date IN (
    SELECT d_date
    FROM date_dim
    WHERE d_week_seq = (SELECT d_week_seq FROM date_dim WHERE d_date = '1998-02-19')
  )
  GROUP BY item.i_item_id
),
cs_items AS (
  SELECT item.i_item_id AS item_id,
         SUM(catalog_sales.cs_ext_sales_price) AS cs_item_rev
  FROM catalog_sales
  JOIN item ON catalog_sales.cs_item_sk = item.i_item_sk
  JOIN date_dim ON catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
  WHERE date_dim.d_date IN (
    SELECT d_date
    FROM date_dim
    WHERE d_week_seq = (SELECT d_week_seq FROM date_dim WHERE d_date = '1998-02-19')
  )
  GROUP BY item.i_item_id
),
ws_items AS (
  SELECT item.i_item_id AS item_id,
         SUM(web_sales.ws_ext_sales_price) AS ws_item_rev
  FROM web_sales
  JOIN item ON web_sales.ws_item_sk = item.i_item_sk
  JOIN date_dim ON web_sales.ws_sold_date_sk = date_dim.d_date_sk
  WHERE date_dim.d_date IN (
    SELECT d_date
    FROM date_dim
    WHERE d_week_seq = (SELECT d_week_seq FROM date_dim WHERE d_date = '1998-02-19')
  )
  GROUP BY item.i_item_id
)
SELECT ss_items.item_id,
       ss_items.ss_item_rev,
       (ss_items.ss_item_rev / ((ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev) / 3)) * 100 AS ss_dev,
       cs_items.cs_item_rev,
       (cs_items.cs_item_rev / ((ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev) / 3)) * 100 AS cs_dev,
       ws_items.ws_item_rev,
       (ws_items.ws_item_rev / ((ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev) / 3)) * 100 AS ws_dev,
       (ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev) / 3 AS average
FROM ss_items
JOIN cs_items ON ss_items.item_id = cs_items.item_id
JOIN ws_items ON ss_items.item_id = ws_items.item_id
WHERE ss_items.ss_item_rev BETWEEN 0.9 * cs_items.cs_item_rev AND 1.1 * cs_items.cs_item_rev
  AND ss_items.ss_item_rev BETWEEN 0.9 * ws_items.ws_item_rev AND 1.1 * ws_items.ws_item_rev
  AND cs_items.cs_item_rev BETWEEN 0.9 * ss_items.ss_item_rev AND 1.1 * ss_items.ss_item_rev
  AND cs_items.cs_item_rev BETWEEN 0.9 * ws_items.ws_item_rev AND 1.1 * ws_items.ws_item_rev
  AND ws_items.ws_item_rev BETWEEN 0.9 * ss_items.ss_item_rev AND 1.1 * ss_items.ss_item_rev
  AND ws_items.ws_item_rev BETWEEN 0.9 * cs_items.cs_item_rev AND 1.1 * cs_items.cs_item_rev
ORDER BY ss_items.item_id, ss_items.ss_item_rev
LIMIT 100;
 

-- end query 1 in stream 0 using template query58.tpl
