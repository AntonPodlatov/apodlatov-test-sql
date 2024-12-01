USE example_db;

DROP TABLE IF EXISTS t;

CREATE TABLE t
(
    t_id            INT PRIMARY KEY AUTO_INCREMENT,
    t_date          DATE                        NOT NULL,
    t_product_id    INT                         NOT NULL,
    t_movement_type ENUM ('продажа', 'возврат') NOT NULL,
    t_quantity      INT                         NOT NULL
);

-- CREATE INDEX idx_date ON t(t_date);
-- CREATE INDEX idx_product_id ON t(t_product_id);

-- Здесь нужны индексы или составной индекс. я решил сделать составной
CREATE INDEX idx_product_date ON t(t_product_id, t_date);

INSERT INTO t (t_date, t_product_id, t_movement_type, t_quantity)
VALUES (NOW(), 1, 'продажа', -15),
       (NOW(), 1, 'продажа', -15),
       ('2012-12-12', 1, 'продажа', -1),
       ('2013-12-12', 1, 'продажа', -10),
       ('2013-12-12', 1, 'продажа', -1),
       ('2014-12-12', 2, 'продажа', -1123),
       ('2014-12-12', 1, 'продажа', -1),
       ('2014-12-12', 2, 'продажа', -1),
       (NOW(), 2, 'возврат', 10),
       ('2000-01-02', 1, 'возврат', 1);

-- Без оконных функций
SELECT t_product_id                                   AS товар,
       SUM(t_quantity)                                AS остаток_текущий,
       SUM(IF(t_date <= '2021-01-01', t_quantity, 0)) AS остаток_2021_01_01
FROM t
WHERE t_quantity > 0
  AND t_date <= CURRENT_DATE
GROUP BY t_product_id;

-- С оконными функциями
SELECT DISTINCT t_product_id                                                                    AS товар,
                SUM(t_quantity) OVER (PARTITION BY t_product_id)                                AS остаток_текущий,
                SUM(IF(t_date <= '2021-01-01', t_quantity, 0)) OVER (PARTITION BY t_product_id) AS остаток_2021_01_01
FROM t
WHERE t_quantity > 0
  AND t_date <= CURRENT_DATE;