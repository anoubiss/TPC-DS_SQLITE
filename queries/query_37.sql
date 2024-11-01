-- start query 1 in stream 0 using template query37.tpl
select 
    i_item_id,
    i_item_desc,
    i_current_price
from 
    item 
    join inventory on inv_item_sk = i_item_sk
    join date_dim on d_date_sk = inv_date_sk
    join catalog_sales on cs_item_sk = i_item_sk
where 
    i_current_price between 22 and 22 + 30
    and d_date between date('2001-06-02') and date('2001-06-02', '+60 days')
    and i_manufact_id in (678,964,918,849)
    and inv_quantity_on_hand between 100 and 500
group by 
    i_item_id,
    i_item_desc,
    i_current_price
order by 
    i_item_id
limit 100;


-- end query 1 in stream 0 using template query37.tpl
