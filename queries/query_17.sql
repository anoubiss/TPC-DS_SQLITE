-- start query 1 in stream 0 using template query17.tpl
SELECT  
   i_item_id,
   i_item_desc,
   s_state,
   COUNT(ss_quantity) AS store_sales_quantitycount,
   AVG(ss_quantity) AS store_sales_quantityave,
   -- Calculating the standard deviation manually due to SQLite limitations
   (SUM(ss_quantity * ss_quantity) - SUM(ss_quantity) * AVG(ss_quantity)) / COUNT(ss_quantity) AS store_sales_quantitystdev,
   ((SUM(ss_quantity * ss_quantity) - SUM(ss_quantity) * AVG(ss_quantity)) / COUNT(ss_quantity)) / AVG(ss_quantity) AS store_sales_quantitycov,
   COUNT(sr_return_quantity) AS store_returns_quantitycount,
   AVG(sr_return_quantity) AS store_returns_quantityave,
   (SUM(sr_return_quantity * sr_return_quantity) - SUM(sr_return_quantity) * AVG(sr_return_quantity)) / COUNT(sr_return_quantity) AS store_returns_quantitystdev,
   ((SUM(sr_return_quantity * sr_return_quantity) - SUM(sr_return_quantity) * AVG(sr_return_quantity)) / COUNT(sr_return_quantity)) / AVG(sr_return_quantity) AS store_returns_quantitycov,
   COUNT(cs_quantity) AS catalog_sales_quantitycount,
   AVG(cs_quantity) AS catalog_sales_quantityave,
   (SUM(cs_quantity * cs_quantity) - SUM(cs_quantity) * AVG(cs_quantity)) / COUNT(cs_quantity) AS catalog_sales_quantitystdev,
   ((SUM(cs_quantity * cs_quantity) - SUM(cs_quantity) * AVG(cs_quantity)) / COUNT(cs_quantity)) / AVG(cs_quantity) AS catalog_sales_quantitycov
FROM 
   store_sales
JOIN 
   store_returns ON ss_customer_sk = sr_customer_sk AND ss_item_sk = sr_item_sk AND ss_ticket_number = sr_ticket_number
JOIN 
   catalog_sales ON sr_customer_sk = cs_bill_customer_sk AND sr_item_sk = cs_item_sk
JOIN 
   date_dim d1 ON d1.d_date_sk = ss_sold_date_sk
JOIN 
   date_dim d2 ON d2.d_date_sk = sr_returned_date_sk
JOIN 
   date_dim d3 ON d3.d_date_sk = cs_sold_date_sk
JOIN 
   store ON s_store_sk = ss_store_sk
JOIN 
   item ON i_item_sk = ss_item_sk
WHERE 
   d1.d_quarter_name = '1998Q1'
   AND d2.d_quarter_name IN ('1998Q1', '1998Q2', '1998Q3')
   AND d3.d_quarter_name IN ('1998Q1', '1998Q2', '1998Q3')
GROUP BY 
   i_item_id,
   i_item_desc,
   s_state
ORDER BY 
   i_item_id,
   i_item_desc,
   s_state
LIMIT 100;
-- end query 1 in stream 0 using template query17.tpl
