-- start query 1 in stream 0 using template query46.tpl
SELECT c.c_last_name,
       c.c_first_name,
       ca_bought.ca_city AS bought_city,
       dn.bought_city,
       dn.ss_ticket_number,
       dn.amt,
       dn.profit
FROM (
    SELECT ss_ticket_number,
           ss_customer_sk,
           ca.ca_city AS bought_city,
           SUM(ss_coupon_amt) AS amt,
           SUM(ss_net_profit) AS profit
    FROM store_sales ss
    JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    JOIN store s ON ss.ss_store_sk = s.s_store_sk  
    JOIN household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN customer_address ca ON ss.ss_addr_sk = ca.ca_address_sk
    WHERE (hd.hd_dep_count = 5 OR hd.hd_vehicle_count = 3)
      AND d.d_dow IN (6, 0)
      AND d.d_year IN (1999, 2000, 2001) 
      AND s.s_city IN ('Midway', 'Fairview')
    GROUP BY ss_ticket_number, ss_customer_sk, ss_addr_sk, ca.ca_city
) AS dn
JOIN customer c ON dn.ss_customer_sk = c.c_customer_sk
JOIN customer_address ca_bought ON c.c_current_addr_sk = ca_bought.ca_address_sk
WHERE ca_bought.ca_city <> dn.bought_city
ORDER BY c.c_last_name,
         c.c_first_name,
         ca_bought.ca_city,
         dn.bought_city,
         dn.ss_ticket_number
LIMIT 100;


-- end query 1 in stream 0 using template query46.tpl
