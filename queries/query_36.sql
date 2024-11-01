-- start query 1 in stream 0 using template query36.tpl
select  
    sum(ss_net_profit) / sum(ss_ext_sales_price) as gross_margin,
    i_category,
    i_class,
    (case when i_category is null then 1 else 0 end + case when i_class is null then 1 else 0 end) as lochierarchy,
    row_number() over (
        partition by 
            (case when i_category is null then 1 else 0 end + case when i_class is null then 1 else 0 end),
            i_category
        order by sum(ss_net_profit) / sum(ss_ext_sales_price) asc
    ) as rank_within_parent
from
    store_sales ss
    join date_dim d1 on d1.d_date_sk = ss.ss_sold_date_sk
    join item i on i.i_item_sk = ss.ss_item_sk
    join store s on s.s_store_sk = ss.ss_store_sk
where
    d1.d_year = 2000
    and s.s_state in ('TN','TN','TN','TN','TN','TN','TN','TN')
group by 
    i_category,
    i_class
order by 
    lochierarchy desc,
    i_category,
    rank_within_parent
limit 100;


-- end query 1 in stream 0 using template query36.tpl
