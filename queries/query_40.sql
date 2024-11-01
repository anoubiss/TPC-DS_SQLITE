-- start query 1 in stream 0 using template query40.tpl
select 
    w_state,
    i_item_id,
    sum(case when d_date < '1998-04-08' 
        then cs_sales_price - coalesce(cr_refunded_cash, 0) 
        else 0 end) as sales_before,
    sum(case when d_date >= '1998-04-08' 
        then cs_sales_price - coalesce(cr_refunded_cash, 0) 
        else 0 end) as sales_after
from 
    catalog_sales
    left join catalog_returns on catalog_sales.cs_order_number = catalog_returns.cr_order_number
                               and catalog_sales.cs_item_sk = catalog_returns.cr_item_sk
    join item on catalog_sales.cs_item_sk = item.i_item_sk
    join warehouse on catalog_sales.cs_warehouse_sk = warehouse.w_warehouse_sk
    join date_dim on catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
where 
    i_current_price between 0.99 and 1.49
    and d_date between date('1998-04-08', '-30 days') and date('1998-04-08', '+30 days')
group by 
    w_state, i_item_id
order by 
    w_state, i_item_id
limit 100;


-- end query 1 in stream 0 using template query40.tpl
