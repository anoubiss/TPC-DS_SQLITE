-- start query 1 in stream 0 using template query12.tpl
SELECT 
      i.i_item_id,
      i.i_item_desc,
      i.i_category,
      i.i_class,
      i.i_current_price,
      SUM(ws.ws_ext_sales_price) AS itemrevenue,
      SUM(ws.ws_ext_sales_price) * 100.0 / class_totals.total_class_revenue AS revenueratio
FROM 
      web_sales ws
JOIN 
      item i ON ws.ws_item_sk = i.i_item_sk
JOIN 
      date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
JOIN (
    -- Subquery to calculate total revenue by class
    SELECT 
          i_class AS class,
          SUM(ws_ext_sales_price) AS total_class_revenue
    FROM 
          web_sales ws
    JOIN 
          item i ON ws.ws_item_sk = i.i_item_sk
    JOIN 
          date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
    WHERE 
          i.i_category IN ('Jewelry', 'Sports', 'Books')
          AND d.d_date BETWEEN DATE('2001-01-12') AND DATE('2001-01-12', '+30 days')
    GROUP BY 
          i.i_class
) class_totals ON i.i_class = class_totals.class
WHERE 
      i.i_category IN ('Jewelry', 'Sports', 'Books')
      AND d.d_date BETWEEN DATE('2001-01-12') AND DATE('2001-01-12', '+30 days')
GROUP BY 
      i.i_item_id,
      i.i_item_desc,
      i.i_category,
      i.i_class,
      i.i_current_price,
      class_totals.total_class_revenue
ORDER BY 
      i.i_category,
      i.i_class,
      i.i_item_id,
      i.i_item_desc,
      revenueratio
LIMIT 100;
-- end query 1 in stream 0 using template query12.tpl
