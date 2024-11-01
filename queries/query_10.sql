SELECT  
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3,
  cd_dep_count,
  count(*) cnt4,
  cd_dep_employed_count,
  count(*) cnt5,
  cd_dep_college_count,
  count(*) cnt6
FROM
  customer c
JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics ON cd_demo_sk = c.c_current_cdemo_sk
LEFT JOIN store_sales ss ON c.c_customer_sk = ss.ss_customer_sk
LEFT JOIN date_dim d_store ON ss.ss_sold_date_sk = d_store.d_date_sk
LEFT JOIN web_sales ws ON c.c_customer_sk = ws.ws_bill_customer_sk
LEFT JOIN date_dim d_web ON ws.ws_sold_date_sk = d_web.d_date_sk
LEFT JOIN catalog_sales cs ON c.c_customer_sk = cs.cs_ship_customer_sk
LEFT JOIN date_dim d_catalog ON cs.cs_sold_date_sk = d_catalog.d_date_sk
WHERE
  ca_county IN ('Walker County', 'Richland County', 'Gaines County', 'Douglas County', 'Dona Ana County')
  AND d_store.d_year = 2002
  AND d_store.d_moy BETWEEN 4 AND 7
  AND (d_web.d_year = 2002 AND d_web.d_moy BETWEEN 4 AND 7
       OR d_catalog.d_year = 2002 AND d_catalog.d_moy BETWEEN 4 AND 7)
GROUP BY cd_gender, cd_marital_status, cd_education_status, cd_purchase_estimate,
         cd_credit_rating, cd_dep_count, cd_dep_employed_count, cd_dep_college_count
ORDER BY cd_gender, cd_marital_status, cd_education_status, cd_purchase_estimate,
         cd_credit_rating, cd_dep_count, cd_dep_employed_count, cd_dep_college_count
LIMIT 100;
