-- start query 1 in stream 0 using template query27.tpl
SELECT  
    i_item_id,
    s_state,
    AVG(ss_quantity) AS agg1,
    AVG(ss_list_price) AS agg2,
    AVG(ss_coupon_amt) AS agg3,
    AVG(ss_sales_price) AS agg4
FROM 
    store_sales
JOIN 
    customer_demographics ON ss_cdemo_sk = cd_demo_sk
JOIN 
    date_dim ON ss_sold_date_sk = d_date_sk
JOIN 
    store ON ss_store_sk = s_store_sk
JOIN 
    item ON ss_item_sk = i_item_sk
WHERE 
    cd_gender = 'F'
    AND cd_marital_status = 'W'
    AND cd_education_status = 'Primary'
    AND d_year = 1998
    AND s_state = 'TN'
GROUP BY 
    i_item_id, s_state
ORDER BY 
    i_item_id, s_state
LIMIT 100;
-- end query 1 in stream 0 using template query27.tpl
