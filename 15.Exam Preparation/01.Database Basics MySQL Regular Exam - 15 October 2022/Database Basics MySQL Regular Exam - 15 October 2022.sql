-- 01. Table Design

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL UNIQUE,
    type VARCHAR(30) NOT NULL,
    price DECIMAL(10 , 2 ) NOT NULL
);

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birthdate DATE NOT NULL,
    card VARCHAR(50),
    review TEXT
);

CREATE TABLE tables (
    id INT PRIMARY KEY AUTO_INCREMENT,
    floor INT NOT NULL,
    reserved TINYINT(1),
    capacity INT NOT NULL
);

CREATE TABLE waiters (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(50),
    salary DECIMAL(10 , 2 )
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_id INT NOT NULL,
    waiter_id INT NOT NULL,
    order_time TIME NOT NULL,
    payed_status TINYINT(1),
    CONSTRAINT fk_orders_tables FOREIGN KEY (table_id)
        REFERENCES tables (id),
    CONSTRAINT fk_orders_waiters FOREIGN KEY (waiter_id)
        REFERENCES waiters (id)
);

CREATE TABLE orders_clients (
    order_id INT,
    client_id INT,
    CONSTRAINT fk_orders_clients_orders FOREIGN KEY (order_id)
        REFERENCES orders (id),
    CONSTRAINT fk_orders_clients_clients FOREIGN KEY (client_id)
        REFERENCES clients (id)
);

CREATE TABLE orders_products (
    order_id INT,
    product_id INT,
    CONSTRAINT orders_products_orders FOREIGN KEY (order_id)
        REFERENCES orders (id),
    CONSTRAINT orders_products_products FOREIGN KEY (product_id)
        REFERENCES products (id)
);

-- 02. Insert
INSERT INTO products(name, type, price)
(
	SELECT
		CONCAT(last_name,' ', 'specialty'),
		'Cocktail',
		CEILING(0.01 * salary)
        FROM waiters
        WHERE id > 6
);

-- 03. Update
UPDATE orders 
SET 
    table_id = table_id - 1
WHERE
    id BETWEEN 12 AND 23;
    
-- 04. Delete
SELECT 
    w.id,
    (SELECT 
            COUNT(*)
        FROM
            orders
        WHERE
            waiter_id = w.id) AS count
FROM
    waiters AS w
HAVING count = 0;

DELETE FROM waiters AS w
WHERE (SELECT COUNT(*) FROM orders WHERE waiter_id = w.id) = 0;

-- 05. Clients
SELECT 
    *
FROM
    clients
ORDER BY birthdate DESC , id DESC;

-- 06. Birthdate
SELECT 
    first_name, last_name, birthdate, review
FROM
    clients
WHERE
    CARD IS NULL
        AND YEAR(birthdate) BETWEEN 1978 AND 1993
ORDER BY last_name DESC , id
LIMIT 5;

-- 07. Accounts
SELECT 
    CONCAT(last_name,
            first_name,
            CHAR_LENGTH(first_name),
            'Restaurant') AS username,
    REVERSE(SUBSTRING(email, 2, 12)) AS 'password'
FROM
    waiters
WHERE
    salary IS NOT NULL
ORDER BY `password` DESC;

-- 08. Top from menu
SELECT 
    p.id, p.name, COUNT(id) AS count
FROM
    products AS p
        JOIN
    orders_products AS op ON p.id = op.product_id
GROUP BY p.id
HAVING `count` >= 5
ORDER BY `count` DESC , p.name;

-- 09. Availability
SELECT 
    t.id,
    t.capacity,
    COUNT(t.id) AS count_clients,
    (
    CASE
        WHEN `capacity` > COUNT(t.id) THEN 'Free seats'
        WHEN `capacity` = COUNT(t.id) THEN 'Full'
        ELSE 'Extra seats'
    END
    ) AS availability
FROM
    tables AS t
        JOIN
    orders AS o ON t.id = o.table_id
        JOIN
    orders_clients AS oc ON o.id = oc.order_id
WHERE
    t.floor = 1
GROUP BY t.id
ORDER BY t.id DESC;

-- 10. Extract bill
SELECT 
    c.first_name, c.last_name, SUM(p.price) AS bill
FROM
    clients AS c
        JOIN
    orders_clients AS oc ON c.id = oc.client_id
        JOIN
    orders_products AS op ON oc.order_id = op.order_id
        JOIN
    products AS p ON op.product_id = p.id
GROUP BY c.id
HAVING c.first_name = 'Silvio' AND c.last_name= 'Blyth';

DELIMITER $$
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
	DECLARE index_of_space INT;
	SET index_of_space = LOCATE (' ', full_name);

	RETURN (SELECT SUM(p.price) AS bill
	FROM clients AS c
		JOIN orders_clients AS oc ON c.id = oc.client_id
		JOIN orders_products AS op ON oc.order_id = op.order_id
		JOIN products AS p ON op.product_id = p.id
		WHERE c.first_name = SUBSTRING(full_name, 1, index_of_space - 1)
		AND c.last_name = SUBSTRING(full_name, index_of_space + 1)
		GROUP BY c.id
);
END $$

DELIMITER ;
SELECT c.first_name,c.last_name, udf_client_bill('Silvio Blyth') as 'bill'
FROM
clients c
WHERE c.first_name = 'Silvio' AND c.last_name= 'Blyth';

-- 11. Happy hour
DELIMITER $$
CREATE PROCEDURE udp_happy_hour(type VARCHAR(50))
BEGIN
	UPDATE products AS p
	SET p.price = p.price * 0.8
		WHERE p.price >= 10
		AND p.type = type;
END$$

DELIMITER ;

CALL udp_happy_hour ('Cognac');
SELECT 
    *
FROM
    products
WHERE
    type = 'Cognac';
