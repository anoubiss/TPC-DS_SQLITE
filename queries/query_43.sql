-- start query 1 in stream 0 using template query43.tpl
select s_store_name,
       s_store_id,
       sum(case when d_day_name = 'Sunday' then ss_sales_price else 0 end) as sun_sales,
       sum(case when d_day_name = 'Monday' then ss_sales_price else 0 end) as mon_sales,
       sum(case when d_day_name = 'Tuesday' then ss_sales_price else 0 end) as tue_sales,
       sum(case when d_day_name = 'Wednesday' then ss_sales_price else 0 end) as wed_sales,
       sum(case when d_day_name = 'Thursday' then ss_sales_price else 0 end) as thu_sales,
       sum(case when d_day_name = 'Friday' then ss_sales_price else 0 end) as fri_sales,
       sum(case when d_day_name = 'Saturday' then ss_sales_price else 0 end) as sat_sales
from date_dim dt
join store_sales ss on dt.d_date_sk = ss.ss_sold_date_sk
join store s on s.s_store_sk = ss.ss_store_sk
where s.s_gmt_offset = -5
  and dt.d_year = 1998 
group by s_store_name, s_store_id
order by s_store_name, s_store_id, sun_sales, mon_sales, tue_sales, wed_sales, thu_sales, fri_sales, sat_sales
limit 100;


-- end query 1 in stream 0 using template query43.tpl
