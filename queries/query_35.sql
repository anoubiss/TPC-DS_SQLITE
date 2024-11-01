-- start query 1 in stream 0 using template query35.tpl
select  
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  count(*) cnt1,
  avg(cd_dep_count),
  max(cd_dep_count),
  sum(cd_dep_count),
  cd_dep_employed_count,
  count(*) cnt2,
  avg(cd_dep_employed_count),
  max(cd_dep_employed_count),
  sum(cd_dep_employed_count),
  cd_dep_college_count,
  count(*) cnt3,
  avg(cd_dep_college_count),
  max(cd_dep_college_count),
  sum(cd_dep_college_count)
from
  customer c, customer_address ca, customer_demographics cd
where
  c.c_current_addr_sk = ca.ca_address_sk and
  cd.cd_demo_sk = c.c_current_cdemo_sk and 
  exists (select *
          from store_sales ss, date_dim d
          where c.c_customer_sk = ss.ss_customer_sk and
                ss.ss_sold_date_sk = d.d_date_sk and
                d.d_year = 1999 and
                d.d_qoy < 4) and
   (exists (select * 
            from web_sales ws, date_dim d
            where c.c_customer_sk = ws.ws_bill_customer_sk and
                  ws.ws_sold_date_sk = d.d_date_sk and
                  d.d_year = 1999 and
                  d.d_qoy < 4) or 
    exists (select * 
            from catalog_sales cs, date_dim d
            where c.c_customer_sk = cs.cs_ship_customer_sk and
                  cs.cs_sold_date_sk = d.d_date_sk and
                  d.d_year = 1999 and
                  d.d_qoy < 4))
group by ca_state,
         cd_gender,
         cd_marital_status,
         cd_dep_count,
         cd_dep_employed_count,
         cd_dep_college_count
order by ca_state,
         cd_gender,
         cd_marital_status,
         cd_dep_count,
         cd_dep_employed_count,
         cd_dep_college_count
limit 100;


-- end query 1 in stream 0 using template query35.tpl
