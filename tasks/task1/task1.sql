USE example_db;

-- создадим таблицу t для наглядности
CREATE TABLE t
(
    t_id            INT PRIMARY KEY AUTO_INCREMENT,
    t_date          DATE                        NOT NULL,
    t_product_id    INT                         NOT NULL,
    t_movement_type ENUM ('продажа', 'возврат') NOT NULL,
    t_quantity      INT                         NOT NULL
);

-- Именно для такого запроса лучше будет композитный индекс:
CREATE INDEX idx_qnt_date ON t (t_quantity, t_date);

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

EXPLAIN SELECT t_product_id                                              AS товар,
       ABS(SUM(IF(YEAR(t_date) IN (2013, 2014), t_quantity, 0))) AS продано_2013_2014,
       ABS(SUM(IF(YEAR(t_date) = 2013, t_quantity, 0)))          AS продано_2013,
       abs(SUM(IF(YEAR(t_date) = 2014, t_quantity, 0)))          AS продано_2014
FROM t
WHERE t_quantity < 0
  AND t_date BETWEEN '2013-01-01' AND '2014-12-31'
GROUP BY t_product_id;