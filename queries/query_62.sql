-- start query 1 in stream 0 using template query62.tpl
SELECT 
    substr(w.w_warehouse_name, 1, 20) AS warehouse_name,
    sm.sm_type AS ship_mode,
    ws.web_name AS web_site,
    SUM(CASE 
            WHEN (ws.ws_ship_date_sk - ws.ws_sold_date_sk <= 30) 
            THEN 1 ELSE 0 
        END) AS "30 days", 
    SUM(CASE 
            WHEN (ws.ws_ship_date_sk - ws.ws_sold_date_sk > 30) 
                 AND (ws.ws_ship_date_sk - ws.ws_sold_date_sk <= 60) 
            THEN 1 ELSE 0 
        END) AS "31-60 days", 
    SUM(CASE 
            WHEN (ws.ws_ship_date_sk - ws.ws_sold_date_sk > 60) 
                 AND (ws.ws_ship_date_sk - ws.ws_sold_date_sk <= 90) 
            THEN 1 ELSE 0 
        END) AS "61-90 days", 
    SUM(CASE 
            WHEN (ws.ws_ship_date_sk - ws.ws_sold_date_sk > 90) 
                 AND (ws.ws_ship_date_sk - ws.ws_sold_date_sk <= 120) 
            THEN 1 ELSE 0 
        END) AS "91-120 days", 
    SUM(CASE 
            WHEN (ws.ws_ship_date_sk - ws.ws_sold_date_sk > 120) 
            THEN 1 ELSE 0 
        END) AS ">120 days"
FROM web_sales ws
JOIN warehouse w ON ws.ws_warehouse_sk = w.w_warehouse_sk
JOIN ship_mode sm ON ws.ws_ship_mode_sk = sm.sm_ship_mode_sk
JOIN web_site ws ON ws.ws_web_site_sk = ws.web_site_sk
JOIN date_dim dd ON ws.ws_ship_date_sk = dd.d_date_sk
WHERE dd.d_month_seq BETWEEN 1212 AND 1212 + 11
GROUP BY substr(w.w_warehouse_name, 1, 20), sm.sm_type, ws.web_name
ORDER BY substr(w.w_warehouse_name, 1, 20), sm.sm_type, ws.web_name
LIMIT 100;


-- end query 1 in stream 0 using template query62.tpl
