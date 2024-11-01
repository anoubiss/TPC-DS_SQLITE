WITH ssr AS (
  SELECT s_store_id,
         SUM(sales_price) AS sales,
         SUM(profit) AS profit,
         SUM(return_amt) AS returns,
         SUM(net_loss) AS profit_loss
  FROM (
    SELECT ss_store_sk AS store_sk,
           ss_sold_date_sk AS date_sk,
           ss_ext_sales_price AS sales_price,
           ss_net_profit AS profit,
           CAST(0 AS REAL) AS return_amt,
           CAST(0 AS REAL) AS net_loss
    FROM store_sales
    UNION ALL
    SELECT sr_store_sk AS store_sk,
           sr_returned_date_sk AS date_sk,
           CAST(0 AS REAL) AS sales_price,
           CAST(0 AS REAL) AS profit,
           sr_return_amt AS return_amt,
           sr_net_loss AS net_loss
    FROM store_returns
  ) AS salesreturns
  JOIN date_dim ON date_sk = d_date_sk
  JOIN store ON store_sk = s_store_sk
  WHERE d_date BETWEEN date('1998-08-04') AND date('1998-08-04', '+14 days')
  GROUP BY s_store_id
),
csr AS (
  SELECT cp_catalog_page_id,
         SUM(sales_price) AS sales,
         SUM(profit) AS profit,
         SUM(return_amt) AS returns,
         SUM(net_loss) AS profit_loss
  FROM (
    SELECT cs_catalog_page_sk AS page_sk,
           cs_sold_date_sk AS date_sk,
           cs_ext_sales_price AS sales_price,
           cs_net_profit AS profit,
           CAST(0 AS REAL) AS return_amt,
           CAST(0 AS REAL) AS net_loss
    FROM catalog_sales
    UNION ALL
    SELECT cr_catalog_page_sk AS page_sk,
           cr_returned_date_sk AS date_sk,
           CAST(0 AS REAL) AS sales_price,
           CAST(0 AS REAL) AS profit,
           cr_return_amount AS return_amt,
           cr_net_loss AS net_loss
    FROM catalog_returns
  ) AS salesreturns
  JOIN date_dim ON date_sk = d_date_sk
  JOIN catalog_page ON page_sk = cp_catalog_page_sk
  WHERE d_date BETWEEN date('1998-08-04') AND date('1998-08-04', '+14 days')
  GROUP BY cp_catalog_page_id
),
wsr AS (
  SELECT web_site_id,
         SUM(sales_price) AS sales,
         SUM(profit) AS profit,
         SUM(return_amt) AS returns,
         SUM(net_loss) AS profit_loss
  FROM (
    SELECT ws_web_site_sk AS wsr_web_site_sk,
           ws_sold_date_sk AS date_sk,
           ws_ext_sales_price AS sales_price,
           ws_net_profit AS profit,
           CAST(0 AS REAL) AS return_amt,
           CAST(0 AS REAL) AS net_loss
    FROM web_sales
    UNION ALL
    SELECT ws_web_site_sk AS wsr_web_site_sk,
           wr_returned_date_sk AS date_sk,
           CAST(0 AS REAL) AS sales_price,
           CAST(0 AS REAL) AS profit,
           wr_return_amt AS return_amt,
           wr_net_loss AS net_loss
    FROM web_returns
    LEFT OUTER JOIN web_sales ON (wr_item_sk = ws_item_sk AND wr_order_number = ws_order_number)
  ) AS salesreturns
  JOIN date_dim ON date_sk = d_date_sk
  JOIN web_site ON wsr_web_site_sk = web_site_sk
  WHERE d_date BETWEEN date('1998-08-04') AND date('1998-08-04', '+14 days')
  GROUP BY web_site_id
)

-- Requête principale
SELECT channel, id, SUM(sales) AS sales, SUM(returns) AS returns, SUM(profit - profit_loss) AS profit
FROM (
    -- Détails par store
    SELECT 'store channel' AS channel,
           'store' || s_store_id AS id,
           sales,
           returns,
           profit,
           profit_loss
    FROM ssr

    UNION ALL

    -- Détails par page du catalogue
    SELECT 'catalog channel' AS channel,
           'catalog_page' || cp_catalog_page_id AS id,
           sales,
           returns,
           profit,
           profit_loss
    FROM csr

    UNION ALL

    -- Détails par site web
    SELECT 'web channel' AS channel,
           'web_site' || web_site_id AS id,
           sales,
           returns,
           profit,
           profit_loss
    FROM wsr

    UNION ALL

    -- Total par channel uniquement
    SELECT 'store channel' AS channel, 'Total' AS id,
           SUM(sales), SUM(returns), SUM(profit), SUM(profit_loss)
    FROM ssr
    UNION ALL
    SELECT 'catalog channel' AS channel, 'Total' AS id,
           SUM(sales), SUM(returns), SUM(profit), SUM(profit_loss)
    FROM csr
    UNION ALL
    SELECT 'web channel' AS channel, 'Total' AS id,
           SUM(sales), SUM(returns), SUM(profit), SUM(profit_loss)
    FROM wsr

    UNION ALL

    -- Total global
    SELECT 'All channels' AS channel, 'Grand Total' AS id,
           SUM(sales), SUM(returns), SUM(profit), SUM(profit_loss)
    FROM (
        SELECT sales, returns, profit, profit_loss FROM ssr
        UNION ALL
        SELECT sales, returns, profit, profit_loss FROM csr
        UNION ALL
        SELECT sales, returns, profit, profit_loss FROM wsr
    ) AS all_sales
) AS x
GROUP BY channel, id
ORDER BY channel, id
LIMIT 100;
