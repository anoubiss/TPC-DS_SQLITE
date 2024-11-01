-- start query 1 in stream 0 using template query18.tpl
SELECT  
    i_item_id,
    ca_country,
    ca_state, 
    ca_county,
    AVG(cs_quantity * 1.0) AS agg1,
    AVG(cs_list_price * 1.0) AS agg2,
    AVG(cs_coupon_amt * 1.0) AS agg3,
    AVG(cs_sales_price * 1.0) AS agg4,
    AVG(cs_net_profit * 1.0) AS agg5,
    AVG(c_birth_year * 1.0) AS agg6,
    AVG(cd1.cd_dep_count * 1.0) AS agg7
FROM 
    catalog_sales
JOIN 
    customer_demographics cd1 ON cs_bill_cdemo_sk = cd1.cd_demo_sk
JOIN 
    customer ON cs_bill_customer_sk = c_customer_sk
JOIN 
    customer_demographics cd2 ON c_current_cdemo_sk = cd2.cd_demo_sk
JOIN 
    customer_address ON c_current_addr_sk = ca_address_sk
JOIN 
    date_dim ON cs_sold_date_sk = d_date_sk
JOIN 
    item ON cs_item_sk = i_item_sk
WHERE 
    cd1.cd_gender = 'M' 
    AND cd1.cd_education_status = 'College'
    AND c_birth_month IN (9, 5, 12, 4, 1, 10)
    AND d_year = 2001
    AND ca_state IN ('ND','WI','AL','NC','OK','MS','TN')
GROUP BY 
    i_item_id, ca_country, ca_state, ca_county
ORDER BY 
    ca_country,
    ca_state, 
    ca_county,
    i_item_id
LIMIT 100;
-- end query 1 in stream 0 using template query18.tpl
