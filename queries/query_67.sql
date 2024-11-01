SELECT
    i_category,
    i_class,
    i_brand,
    i_product_name,
    d_year,
    d_qoy,
    d_moy,
    s_store_id,
    sumsales,
    rk
FROM (
    SELECT
        i.i_category,
        i.i_class,
        i.i_brand,
        i.i_product_name,
        dd.d_year,
        dd.d_qoy,
        dd.d_moy,
        s.s_store_id,
        SUM(COALESCE(ss.ss_sales_price * ss.ss_quantity, 0)) AS sumsales,
        RANK() OVER (PARTITION BY i.i_category ORDER BY SUM(COALESCE(ss.ss_sales_price * ss.ss_quantity, 0)) DESC) AS rk
    FROM
        store_sales ss
        JOIN date_dim dd ON ss.ss_sold_date_sk = dd.d_date_sk
        JOIN store s ON ss.ss_store_sk = s.s_store_sk
        JOIN item i ON ss.ss_item_sk = i.i_item_sk
    WHERE
        dd.d_month_seq BETWEEN 1212 AND 1212 + 11
    GROUP BY
        i.i_category,
        i.i_class,
        i.i_brand,
        i.i_product_name,
        dd.d_year,
        dd.d_qoy,
        dd.d_moy,
        s.s_store_id
)
WHERE
    rk <= 100
ORDER BY
    i_category,
    i_class,
    i_brand,
    i_product_name,
    d_year,
    d_qoy,
    d_moy,
    s_store_id,
    sumsales,
    rk
LIMIT 100;
