-- start query 1 in stream 0 using template query45.tpl
SELECT ca_zip,
       ca_county,
       SUM(ws_sales_price) AS total_sales
FROM web_sales ws
JOIN customer c ON ws.ws_bill_customer_sk = c.c_customer_sk
JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
JOIN item i ON ws.ws_item_sk = i.i_item_sk
JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
WHERE (substr(ca.ca_zip, 1, 5) IN ('85669', '86197', '88274', '83405', '86475', '85392', '85460', '80348', '81792')
       OR i.i_item_id IN (SELECT i_item_id
                          FROM item
                          WHERE i_item_sk IN (2, 3, 5, 7, 11, 13, 17, 19, 23, 29))
      )
  AND d.d_qoy = 2 
  AND d.d_year = 2000
GROUP BY ca_zip, ca_county
ORDER BY ca_zip, ca_county
LIMIT 100;


-- end query 1 in stream 0 using template query45.tpl
