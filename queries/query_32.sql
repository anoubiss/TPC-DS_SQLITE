-- start query 1 in stream 0 using template query32.tpl
SELECT SUM(cs_ext_discount_amt) AS "excess discount amount" 
FROM 
   catalog_sales 
JOIN 
   item ON cs_item_sk = i_item_sk 
JOIN 
   date_dim ON d_date_sk = cs_sold_date_sk 
WHERE 
   i_manufact_id = 269
   AND d_date BETWEEN '1998-03-18' AND date('1998-03-18', '+90 days')
   AND cs_ext_discount_amt > (
       SELECT 1.3 * AVG(cs_ext_discount_amt) 
       FROM 
           catalog_sales 
       JOIN 
           date_dim ON cs_sold_date_sk = d_date_sk 
       WHERE 
           cs_item_sk = i_item_sk 
           AND d_date BETWEEN '1998-03-18' AND date('1998-03-18', '+90 days')
   )
LIMIT 100;
-- end query 1 in stream 0 using template query32.tpl
