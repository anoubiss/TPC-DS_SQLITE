-- start query 1 in stream 0 using template query39.tpl
WITH monthly_mean AS (
    SELECT 
        w.w_warehouse_name,
        w.w_warehouse_sk,
        i.i_item_sk,
        d.d_moy,
        AVG(inv.inv_quantity_on_hand) AS mean
    FROM 
        inventory inv
        JOIN item i ON inv.inv_item_sk = i.i_item_sk
        JOIN warehouse w ON inv.inv_warehouse_sk = w.w_warehouse_sk
        JOIN date_dim d ON inv.inv_date_sk = d.d_date_sk
    WHERE 
        strftime('%Y', d.d_date) = '1998'
    GROUP BY 
        w.w_warehouse_name, w.w_warehouse_sk, i.i_item_sk, d.d_moy
),
monthly_variance AS (
    SELECT 
        mm.w_warehouse_name,
        mm.w_warehouse_sk,
        mm.i_item_sk,
        mm.d_moy,
        mm.mean,
        AVG((inv.inv_quantity_on_hand - mm.mean) * (inv.inv_quantity_on_hand - mm.mean)) AS variance
    FROM 
        inventory inv
        JOIN monthly_mean mm ON inv.inv_item_sk = mm.i_item_sk
                            AND inv.inv_warehouse_sk = mm.w_warehouse_sk
                            AND strftime('%m', date(inv.inv_date_sk, 'unixepoch')) = mm.d_moy
    GROUP BY 
        mm.w_warehouse_name, mm.w_warehouse_sk, mm.i_item_sk, mm.d_moy
),
inv AS (
    SELECT 
        w_warehouse_name,
        w_warehouse_sk,
        i_item_sk,
        d_moy,
        mean,
        CASE 
            WHEN mean = 0 THEN NULL
            ELSE variance / mean
        END AS cov
    FROM 
        monthly_variance
    WHERE 
        (variance / mean) > 1  -- Remplace sqrt(variance) / mean pour détecter une forte variation
)
SELECT 
    inv1.w_warehouse_sk, inv1.i_item_sk, inv1.d_moy, inv1.mean, inv1.cov,
    inv2.w_warehouse_sk, inv2.i_item_sk, inv2.d_moy, inv2.mean, inv2.cov
FROM 
    inv inv1
    JOIN inv inv2 ON inv1.i_item_sk = inv2.i_item_sk
                 AND inv1.w_warehouse_sk = inv2.w_warehouse_sk
WHERE 
    inv1.d_moy = 4
    AND inv2.d_moy = 5
    AND inv1.cov > 1.5
ORDER BY 
    inv1.w_warehouse_sk, inv1.i_item_sk, inv1.d_moy, inv1.mean, inv1.cov,
    inv2.d_moy, inv2.mean, inv2.cov;

-- end query 1 in stream 0 using template query39.tpl
