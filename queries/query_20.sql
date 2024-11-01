-- start query 1 in stream 0 using template query20.tpl
SELECT 
      i.i_item_id,
      i.i_item_desc,
      i.i_category,
      i.i_class,
      i.i_current_price,
      SUM(cs.cs_ext_sales_price) AS itemrevenue,
      SUM(cs.cs_ext_sales_price) * 100.0 / SUM(SUM(cs.cs_ext_sales_price)) OVER (PARTITION BY i.i_class) AS revenueratio
FROM 
      catalog_sales cs
JOIN 
      item i ON cs.cs_item_sk = i.i_item_sk
JOIN 
      date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
WHERE 
      i.i_category IN ('Jewelry', 'Sports', 'Books')
      AND d.d_date BETWEEN DATE('2001-01-12') AND DATE('2001-01-12', '+30 days')
GROUP BY 
      i.i_item_id,
      i.i_item_desc,
      i.i_category,
      i.i_class,
      i.i_current_price
ORDER BY 
      i.i_category,
      i.i_class,
      i.i_item_id,
      i.i_item_desc,
      revenueratio
LIMIT 100;
-- end query 1 in stream 0 using template query20.tpl
