-- start query 1 in stream 0 using template query38.tpl
select count(*) 
from (
    select distinct c_last_name, c_first_name, d_date
    from store_sales
    join date_dim on store_sales.ss_sold_date_sk = date_dim.d_date_sk
    join customer on store_sales.ss_customer_sk = customer.c_customer_sk
    where d_month_seq between 1212 and 1212 + 11
  intersect
    select distinct c_last_name, c_first_name, d_date
    from catalog_sales
    join date_dim on catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
    join customer on catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
    where d_month_seq between 1212 and 1212 + 11
  intersect
    select distinct c_last_name, c_first_name, d_date
    from web_sales
    join date_dim on web_sales.ws_sold_date_sk = date_dim.d_date_sk
    join customer on web_sales.ws_bill_customer_sk = customer.c_customer_sk
    where d_month_seq between 1212 and 1212 + 11
) as hot_cust
limit 100;


-- end query 1 in stream 0 using template query38.tpl
