-- start query 1 in stream 0 using template query82.tpl

SELECT
    i.i_item_id,
    i.i_item_desc,
    i.i_current_price
FROM
    item i
    JOIN inventory inv ON inv.inv_item_sk = i.i_item_sk
    JOIN date_dim d ON d.d_date_sk = inv.inv_date_sk
    JOIN store_sales ss ON ss.ss_item_sk = i.i_item_sk
WHERE
    i.i_current_price BETWEEN 30 AND 60
    AND d.d_date BETWEEN '2002-05-30' AND DATE('2002-05-30', '+60 days')
    AND i.i_manufact_id IN (437, 129, 727, 663)
    AND inv.inv_quantity_on_hand BETWEEN 100 AND 500
GROUP BY
    i.i_item_id,
    i.i_item_desc,
    i.i_current_price
ORDER BY
    i.i_item_id
LIMIT 100;

-- end query 1 in stream 0 using template query82.tpl
