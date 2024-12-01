SELECT t_product_id                                                     AS товар,
       SUM(t_quantity)                                                  AS остаток_текущий,
       SUM(CASE WHEN t_date <= '2021-01-01' THEN t_quantity ELSE 0 END) AS остаток_2021_01_01
FROM t
WHERE t_quantity > 0
  AND t_date <= CURRENT_DATE
GROUP BY t_product_id;


SELECT DISTINCT t_product_id                                                             AS товар,
                SUM(t_quantity) OVER ()                                                  AS остаток_текущий,
        SUM(CASE WHEN t_date <= '2021-01-01' THEN t_quantity ELSE 0 END) OVER () AS остаток_2021_01_01
FROM t
WHERE t_quantity > 0
  AND t_date <= CURRENT_DATE;