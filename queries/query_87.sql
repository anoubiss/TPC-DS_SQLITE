SELECT COUNT(*) 
FROM (
    -- Customers who made store sales
    SELECT DISTINCT c.c_last_name, c.c_first_name, d.d_date
    FROM store_sales ss
    JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    JOIN customer c ON ss.ss_customer_sk = c.c_customer_sk
    WHERE d.d_month_seq BETWEEN 1212 AND 1223

    EXCEPT

    -- Customers who made catalog sales
    SELECT DISTINCT c.c_last_name, c.c_first_name, d.d_date
    FROM catalog_sales cs
    JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
    JOIN customer c ON cs.cs_bill_customer_sk = c.c_customer_sk
    WHERE d.d_month_seq BETWEEN 1212 AND 1223

    EXCEPT

    -- Customers who made web sales
    SELECT DISTINCT c.c_last_name, c.c_first_name, d.d_date
    FROM web_sales ws
    JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
    JOIN customer c ON ws.ws_bill_customer_sk = c.c_customer_sk
    WHERE d.d_month_seq BETWEEN 1212 AND 1223
) AS cool_cust;
