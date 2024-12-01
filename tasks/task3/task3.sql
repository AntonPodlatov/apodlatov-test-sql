-- Для наглядности создадим таблицы

-- товары (предполодим что есть таблица с товарами)
CREATE TABLE products
(
    p_id   INT PRIMARY KEY AUTO_INCREMENT,
    p_name VARCHAR(255) NOT NULL UNIQUE
);

-- поступление
CREATE TABLE receipts
(
    r_id         INT PRIMARY KEY AUTO_INCREMENT,
    r_date       DATE NOT NULL,
    r_product_id INT  NOT NULL REFERENCES products (p_id),
    r_quantity   INT  NOT NULL
);

-- продажи
CREATE TABLE sales
(
    s_id         INT PRIMARY KEY AUTO_INCREMENT,
    s_date       DATE NOT NULL,
    s_product_id INT  NOT NULL REFERENCES products (p_id),
    s_quantity   INT  NOT NULL
);

-- текущие остатки
CREATE TABLE actual_balance
(
    ab_id         INT PRIMARY KEY AUTO_INCREMENT,
    ab_product_id INT NOT NULL REFERENCES products (p_id),
    ab_quantity   INT NOT NULL
);

INSERT INTO products(p_name)
VALUES ('продукт1'),
       ('продукт2');

INSERT INTO receipts(r_date, r_product_id, r_quantity)
VALUES ('2002-12-12', 1, 5),
       ('2002-05-01', 1, 10),
       ('2002-01-13', 1, 10),
       ('2002-09-12', 1, 10),
       ('2002-05-12', 1, 10),
       ('2002-08-12', 2, 10),
       ('2002-05-05', 2, 15),
       ('2024-07-12', 2, 11),
       ('2022-05-29', 2, 13),
       ('2012-05-23', 2, 1);

INSERT INTO sales(s_date, s_product_id, s_quantity)
VALUES ('2003-12-12', 1, 3),
       ('2003-05-01', 1, 5),
       ('2003-01-13', 1, 8),
       ('2003-09-12', 1, 7),
       ('2003-05-12', 1, 6),
       ('2003-08-12', 2, 4),
       ('2003-05-05', 2, 13),
       ('2025-07-12', 2, 10),
       ('2023-05-29', 2, 2),
       ('2013-05-23', 2, 1);

INSERT INTO actual_balance(ab_product_id, ab_quantity)
VALUES (1, 1004),
       (2, 134);

-- Запрос для вывода итоговых данных по каждому товару(без джоина с таблицей товаров)
SELECT ab.ab_product_id       AS товар_id,
       COALESCE(r.пришло, 0)  AS пришло,
       COALESCE(s.продано, 0) AS продано,
       ab.ab_quantity         AS остатки
FROM actual_balance ab
         LEFT JOIN (SELECT r_product_id, SUM(r_quantity) AS пришло FROM receipts GROUP BY r_product_id) r
                   ON ab.ab_product_id = r.r_product_id
         LEFT JOIN (SELECT s_product_id, SUM(s_quantity) AS продано FROM sales GROUP BY s_product_id) s
                   ON ab.ab_product_id = s.s_product_id;

-- Запрос для вывода данных за период, по каждому товару итог (входной параметр ДАТА_С - ДАТА_ПО:
SELECT
    ab.ab_product_id AS товар_id,
    COALESCE(r.пришло, 0) AS пришло,
    COALESCE(s.продано, 0) AS продано,
    ab.ab_quantity AS остатки
FROM
    actual_balance ab
        LEFT JOIN (SELECT r_product_id, SUM(r_quantity) AS пришло FROM receipts WHERE r_date BETWEEN :ДАТА_С AND :ДАТА_ПО GROUP BY r_product_id) r
                  ON ab.ab_product_id = r.r_product_id
        LEFT JOIN (SELECT s_product_id, SUM(s_quantity) AS продано FROM sales WHERE s_date BETWEEN :ДАТА_С AND :ДАТА_ПО GROUP BY s_product_id) s
                  ON ab.ab_product_id = s.s_product_id;

-- Запрос от таблицы с товарами с джоинами через остатки и реультаты подзапросов (входной параметр ДАТА_С - ДАТА_ПО:
-- (Доп. не было в требованиях)
SELECT p.p_name AS товар, пришло, продано, SUM(ab_quantity) as остаток
FROM products p
         LEFT JOIN actual_balance ab ON p.p_id = ab.ab_product_id
         LEFT JOIN (SELECT r_product_id, SUM(r_quantity) AS пришло FROM receipts WHERE r_date between :ДАТА_С AND :ДАТА_ПО GROUP BY r_product_id) r
                   ON p.p_id = r.r_product_id
         LEFT JOIN (SELECT s_product_id, SUM(s_quantity) AS продано FROM sales WHERE s_date BETWEEN :ДАТА_С AND :ДАТА_ПО GROUP BY s_product_id) s
                   ON p.p_id = s.s_product_id
GROUP BY p.p_name;