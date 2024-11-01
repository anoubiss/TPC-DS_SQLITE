-- start query 1 in stream 0 using template query80.tpl

WITH ssr AS (
    SELECT
        s.s_store_id AS store_id,
        SUM(ss.ss_ext_sales_price) AS sales,
        SUM(COALESCE(sr.sr_return_amt, 0)) AS returns,
        SUM(ss.ss_net_profit - COALESCE(sr.sr_net_loss, 0)) AS profit
    FROM
        store_sales ss
        LEFT JOIN store_returns sr ON ss.ss_item_sk = sr.sr_item_sk AND ss.ss_ticket_number = sr.sr_ticket_number
        JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
        JOIN store s ON ss.ss_store_sk = s.s_store_sk
        JOIN item i ON ss.ss_item_sk = i.i_item_sk
        JOIN promotion p ON ss.ss_promo_sk = p.p_promo_sk
    WHERE
        d.d_date BETWEEN '1998-08-04' AND DATE('1998-08-04', '+30 days')
        AND i.i_current_price > 50
        AND p.p_channel_tv = 'N'
    GROUP BY
        s.s_store_id
),
csr AS (
    SELECT
        cp.cp_catalog_page_id AS catalog_page_id,
        SUM(cs.cs_ext_sales_price) AS sales,
        SUM(COALESCE(cr.cr_return_amount, 0)) AS returns,
        SUM(cs.cs_net_profit - COALESCE(cr.cr_net_loss, 0)) AS profit
    FROM
        catalog_sales cs
        LEFT JOIN catalog_returns cr ON cs.cs_item_sk = cr.cr_item_sk AND cs.cs_order_number = cr.cr_order_number
        JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
        JOIN catalog_page cp ON cs.cs_catalog_page_sk = cp.cp_catalog_page_sk
        JOIN item i ON cs.cs_item_sk = i.i_item_sk
        JOIN promotion p ON cs.cs_promo_sk = p.p_promo_sk
    WHERE
        d.d_date BETWEEN '1998-08-04' AND DATE('1998-08-04', '+30 days')
        AND i.i_current_price > 50
        AND p.p_channel_tv = 'N'
    GROUP BY
        cp.cp_catalog_page_id
),
wsr AS (
    SELECT
        ws_site.web_site_id AS web_site_id,
        SUM(ws.ws_ext_sales_price) AS sales,
        SUM(COALESCE(wr.wr_return_amt, 0)) AS returns,
        SUM(ws.ws_net_profit - COALESCE(wr.wr_net_loss, 0)) AS profit
    FROM
        web_sales ws
        LEFT JOIN web_returns wr ON ws.ws_item_sk = wr.wr_item_sk AND ws.ws_order_number = wr.wr_order_number
        JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
        JOIN web_site ws_site ON ws.ws_web_site_sk = ws_site.web_site_sk
        JOIN item i ON ws.ws_item_sk = i.i_item_sk
        JOIN promotion p ON ws.ws_promo_sk = p.p_promo_sk
    WHERE
        d.d_date BETWEEN '1998-08-04' AND DATE('1998-08-04', '+30 days')
        AND i.i_current_price > 50
        AND p.p_channel_tv = 'N'
    GROUP BY
        ws_site.web_site_id
),
all_data AS (
    SELECT
        channel,
        id,
        sales,
        returns,
        profit
    FROM (
        SELECT
            'store channel' AS channel,
            'store' || store_id AS id,
            sales,
            returns,
            profit
        FROM ssr

        UNION ALL

        SELECT
            'catalog channel' AS channel,
            'catalog_page' || catalog_page_id AS id,
            sales,
            returns,
            profit
        FROM csr

        UNION ALL

        SELECT
            'web channel' AS channel,
            'web_site' || web_site_id AS id,
            sales,
            returns,
            profit
        FROM wsr
    )
),
channel_totals AS (
    SELECT
        channel,
        NULL AS id,
        SUM(sales) AS sales,
        SUM(returns) AS returns,
        SUM(profit) AS profit
    FROM
        all_data
    GROUP BY
        channel
),
grand_total AS (
    SELECT
        NULL AS channel,
        NULL AS id,
        SUM(sales) AS sales,
        SUM(returns) AS returns,
        SUM(profit) AS profit
    FROM
        all_data
)
SELECT
    channel,
    id,
    sales,
    returns,
    profit
FROM (
    SELECT
        channel,
        id,
        sales,
        returns,
        profit,
        1 AS order_col
    FROM
        all_data

    UNION ALL

    SELECT
        channel,
        id,
        sales,
        returns,
        profit,
        2 AS order_col
    FROM
        channel_totals

    UNION ALL

    SELECT
        channel,
        id,
        sales,
        returns,
        profit,
        3 AS order_col
    FROM
        grand_total
)
ORDER BY
    order_col,
    channel,
    id
LIMIT 100;

-- end query 1 in stream 0 using template query80.tpl
