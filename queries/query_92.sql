-- start query 1 in stream 0 using template query92.tpl

SELECT  
   SUM(ws.ws_ext_discount_amt) AS "Excess Discount Amount"
FROM 
    web_sales ws
    JOIN item i ON ws.ws_item_sk = i.i_item_sk
    JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
WHERE
    i.i_manufact_id = 269
    AND d.d_date BETWEEN '1998-03-18' AND DATE('1998-03-18', '+90 days')
    AND ws.ws_ext_discount_amt  
     > ( 
         SELECT 
            1.3 * AVG(ws2.ws_ext_discount_amt) 
         FROM 
            web_sales ws2
            JOIN date_dim d2 ON ws2.ws_sold_date_sk = d2.d_date_sk
         WHERE 
            ws2.ws_item_sk = i.i_item_sk 
            AND d2.d_date BETWEEN '1998-03-18' AND DATE('1998-03-18', '+90 days')
     ) 
ORDER BY
    "Excess Discount Amount"
LIMIT 100;

-- end query 1 in stream 0 using template query92.tpl
