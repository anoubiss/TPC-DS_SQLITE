-- start query 1 in stream 0 using template query66.tpl
SELECT 
    w.w_warehouse_name,
    w.w_warehouse_sq_ft,
    w.w_city,
    w.w_county,
    w.w_state,
    w.w_country,
    'DIAMOND, AIRBORNE' AS ship_carriers,
    d.d_year AS year,

    SUM(CASE WHEN d.d_moy = 1 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS jan_sales,
    SUM(CASE WHEN d.d_moy = 2 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS feb_sales,
    SUM(CASE WHEN d.d_moy = 3 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS mar_sales,
    SUM(CASE WHEN d.d_moy = 4 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS apr_sales,
    SUM(CASE WHEN d.d_moy = 5 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS may_sales,
    SUM(CASE WHEN d.d_moy = 6 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS jun_sales,
    SUM(CASE WHEN d.d_moy = 7 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS jul_sales,
    SUM(CASE WHEN d.d_moy = 8 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS aug_sales,
    SUM(CASE WHEN d.d_moy = 9 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS sep_sales,
    SUM(CASE WHEN d.d_moy = 10 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS oct_sales,
    SUM(CASE WHEN d.d_moy = 11 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS nov_sales,
    SUM(CASE WHEN d.d_moy = 12 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) AS dec_sales,

    SUM(CASE WHEN d.d_moy = 1 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS jan_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 2 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS feb_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 3 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS mar_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 4 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS apr_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 5 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS may_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 6 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS jun_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 7 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS jul_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 8 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS aug_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 9 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS sep_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 10 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS oct_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 11 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS nov_sales_per_sq_foot,
    SUM(CASE WHEN d.d_moy = 12 THEN ws.ws_sales_price * ws.ws_quantity ELSE 0 END) / w.w_warehouse_sq_ft AS dec_sales_per_sq_foot,

    -- Calcul des ventes nettes par mois
    SUM(CASE WHEN d.d_moy = 1 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS jan_net,
    SUM(CASE WHEN d.d_moy = 2 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS feb_net,
    SUM(CASE WHEN d.d_moy = 3 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS mar_net,
    SUM(CASE WHEN d.d_moy = 4 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS apr_net,
    SUM(CASE WHEN d.d_moy = 5 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS may_net,
    SUM(CASE WHEN d.d_moy = 6 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS jun_net,
    SUM(CASE WHEN d.d_moy = 7 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS jul_net,
    SUM(CASE WHEN d.d_moy = 8 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS aug_net,
    SUM(CASE WHEN d.d_moy = 9 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS sep_net,
    SUM(CASE WHEN d.d_moy = 10 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS oct_net,
    SUM(CASE WHEN d.d_moy = 11 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS nov_net,
    SUM(CASE WHEN d.d_moy = 12 THEN ws.ws_net_paid_inc_tax * ws.ws_quantity ELSE 0 END) AS dec_net

FROM 
    web_sales ws
JOIN warehouse w ON ws.ws_warehouse_sk = w.w_warehouse_sk
JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
JOIN ship_mode sm ON ws.ws_ship_mode_sk = sm.sm_ship_mode_sk

WHERE 
    d.d_year = 2002
    AND sm.sm_carrier IN ('DIAMOND', 'AIRBORNE')
    AND ws.ws_sold_time_sk BETWEEN 49530 AND 49530 + 28800

GROUP BY 
    w.w_warehouse_name,
    w.w_warehouse_sq_ft,
    w.w_city,
    w.w_county,
    w.w_state,
    w.w_country,
    d.d_year

ORDER BY 
    w.w_warehouse_name;


-- end query 1 in stream 0 using template query66.tpl
