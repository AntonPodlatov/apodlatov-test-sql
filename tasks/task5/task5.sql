DROP TABLE IF EXISTS receipts;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS actual_balance;
DROP TABLE IF EXISTS products_options_values;

DROP TABLE IF EXISTS products;
CREATE TABLE products
(
    p_id             INT PRIMARY KEY AUTO_INCREMENT,
    p_name           VARCHAR(255) NOT NULL,
    p_article_number VARCHAR(100) NOT NULL,
    p_code           VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS products_groups;
CREATE TABLE products_groups
(
    g_id   INT PRIMARY KEY AUTO_INCREMENT,
    g_name VARCHAR(255) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS options;
CREATE TABLE options
(
    o_id        INT PRIMARY KEY AUTO_INCREMENT,
    option_name VARCHAR(255) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS options_values;
CREATE TABLE options_values
(
    ov_id        INT PRIMARY KEY AUTO_INCREMENT,
    option_value VARCHAR(255) NOT NULL
);

CREATE TABLE products_options_values
(
    pov_id    INT PRIMARY KEY AUTO_INCREMENT,
    p_id      INT NOT NULL REFERENCES products (p_id),
    option_id INT NOT NULL REFERENCES options (o_id),
    value_id  INT NOT NULL REFERENCES options_values (ov_id)
);

-- чтобы джоины работали лучше, можно добавить индекс
CREATE INDEX idx_option_value ON products_options_values (option_id, value_id, p_id);

INSERT INTO products (p_name, p_article_number, p_code)
VALUES ('Футболка', 'FT-001', 'CODE123'),
       ('Джинсы', 'JN-002', 'CODE456'),
       ('Кроссовки', 'KS-003', 'CODE789');

INSERT INTO options (option_name)
VALUES ('Цвет'),
       ('Размер');

INSERT INTO options_values (option_value)
VALUES ('Красный'),
       ('Белый'),
       ('Черный'),
       ('S'),
       ('L'),
       ('XL');

INSERT INTO products_options_values (p_id, option_id, value_id)
VALUES (1, 1, 1),
       (1, 1, 2),
       (1, 2, 4),
       (1, 2, 5),
       (2, 1, 1),
       (2, 1, 3),
       (2, 2, 4),
       (2, 2, 6),
       (3, 1, 2),
       (3, 1, 3),
       (3, 2, 5),
       (3, 2, 6);

-- запрос выводящий - Наименование товара, Артикул товара, Код товара, Цвет, Размер
SELECT p.p_name                                                                   AS 'Наименование товара',
       p.p_article_number                                                         AS 'Артикул товара',
       p.p_code                                                                   AS 'Код товара',
       COALESCE(CASE WHEN o.option_name = 'Цвет' THEN ov.option_value END, '-')   AS 'Цвет',
       COALESCE(CASE WHEN o.option_name = 'Размер' THEN ov.option_value END, '-') AS 'Размер'
FROM products p
         LEFT JOIN products_options_values pov ON p.p_id = pov.p_id
         LEFT JOIN options o ON pov.option_id = o.o_id
         LEFT JOIN options_values ov ON pov.value_id = ov.ov_id;

-- допишу еще пару запросов

-- запрос выводящий сгруппированные свойства товара
/*
SELECT p.p_name, GROUP_CONCAT(DISTINCT ov.option_value ORDER BY ov.option_value) AS _values
FROM products p
         LEFT JOIN products_options_values pov ON p.p_id = pov.p_id
         LEFT JOIN options o ON pov.option_id = o.o_id
         LEFT JOIN options_values ov ON pov.value_id = ov.ov_id
GROUP BY p.p_id;
 */

-- запрос выводящий сгруппированные размеры и цвета товара
/*
SELECT p.p_name,
       GROUP_CONCAT(CASE WHEN o.option_name = 'Размер' THEN ov.option_value END) AS sizes,
       GROUP_CONCAT(CASE WHEN o.option_name = 'Цвет' THEN ov.option_value END) AS colors
FROM products p
         LEFT JOIN products_options_values pov ON p.p_id = pov.p_id
         LEFT JOIN options o ON pov.option_id = o.o_id
         LEFT JOIN options_values ov ON pov.value_id = ov.ov_id
GROUP BY p.p_id;
 */