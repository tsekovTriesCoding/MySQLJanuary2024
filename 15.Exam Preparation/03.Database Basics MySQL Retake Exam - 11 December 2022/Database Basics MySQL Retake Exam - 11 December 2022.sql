-- 01. Table Design
CREATE TABLE countries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL UNIQUE,
    description TEXT,
    currency VARCHAR(5) NOT NULL
);

CREATE TABLE airplanes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    model VARCHAR(50) NOT NULL UNIQUE,
    passengers_capacity INT NOT NULL,
    tank_capacity DECIMAL(19 , 2 ) NOT NULL,
    cost DECIMAL(19 , 2 ) NOT NULL
);

CREATE TABLE passengers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    country_id INT NOT NULL,
    CONSTRAINT fk_passengers_countries FOREIGN KEY (country_id)
        REFERENCES countries (id)
);

CREATE TABLE flights (
    id INT PRIMARY KEY AUTO_INCREMENT,
    flight_code VARCHAR(30) NOT NULL UNIQUE,
    departure_country INT NOT NULL,
    destination_country INT NOT NULL,
    airplane_id INT NOT NULL,
    has_delay TINYINT(1),
    departure DATETIME,
    CONSTRAINT fk_flights_from_countries FOREIGN KEY (departure_country)
        REFERENCES countries (id),
    CONSTRAINT fk_flights_to_countries FOREIGN KEY (destination_country)
        REFERENCES countries (id),
    CONSTRAINT fk_flights_airplanes FOREIGN KEY (airplane_id)
        REFERENCES airplanes (id)
);

CREATE TABLE flights_passengers (
    flight_id INT,
    passenger_id INT,
    CONSTRAINT fk_flights_passengers_flights FOREIGN KEY (flight_id)
        REFERENCES flights (id),
    CONSTRAINT fk_flights_passengers_passengers FOREIGN KEY (passenger_id)
        REFERENCES passengers (id)
);

-- 02. Insert
INSERT INTO airplanes (model, passengers_capacity, tank_capacity, cost)
(
SELECT CONCAT(REVERSE(first_name), '797') ,
	CHAR_LENGTH(last_name) * 17,
	id * 790,
	CHAR_LENGTH(first_name) * 50.6
	FROM passengers
    WHERE id <= 5
);

-- 03. Update
UPDATE flights AS f
        JOIN
    countries AS c ON f.departure_country = c.id 
SET 
    f.airplane_id = f.airplane_id + 1
WHERE
    c.name = 'Armenia';
    
SELECT 
    *
FROM
    flights AS f
        JOIN
    countries AS c ON f.departure_country = c.id
WHERE
    c.name = 'Armenia';

-- 04. Delete
DELETE p FROM passengers AS p
        LEFT JOIN
    flights_passengers AS fp ON p.id = fp.passenger_id 
WHERE
    fp.flight_id IS NULL;

DELETE f FROM flights AS f
        LEFT JOIN
    flights_passengers AS fp ON f.id = fp.flight_id 
WHERE
    fp.flight_id IS NULL;
    
-- 05. Airplanes
SELECT 
    *
FROM
    airplanes
ORDER BY cost DESC , id DESC;
    
-- 06. Flights from 2022
SELECT 
    flight_code, departure_country, airplane_id, departure
FROM
    flights
WHERE
    YEAR(departure) = 2022
ORDER BY airplane_id , flight_code
LIMIT 20;

-- 07. Private flights
SELECT 
    CONCAT(UPPER(LEFT(p.last_name, 2)),
            p.country_id) AS flight_code,
    CONCAT_WS(' ', p.first_name, last_name) AS full_anme,
    p.country_id
FROM
    passengers AS p
        LEFT JOIN
    flights_passengers AS fp ON p.id = fp.passenger_id
WHERE
    fp.flight_id IS NULL
ORDER BY p.country_id;

-- 08. Leading destinations
SELECT 
    c.name,
    c.currency,
    COUNT(f.destination_country) AS booked_tickets
FROM
    flights AS f
        JOIN
    flights_passengers AS fp ON f.id = fp.flight_id
        JOIN
    passengers AS p ON fp.passenger_id = p.id
        JOIN
    countries AS c ON f.destination_country = c.id
GROUP BY f.destination_country
HAVING `booked_tickets` >= 20
ORDER BY booked_tickets DESC;

-- 09. Parts of the day
SELECT 
    flight_code,
    departure,
    CASE
        WHEN TIME(departure) BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(departure) BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        WHEN TIME(departure) BETWEEN '17:00:00' AND '20:59:59' THEN 'Evening'
        ELSE 'Night'
    END AS day_part
FROM
    flights
ORDER BY flight_code DESC;

-- 10. Number of flights
DELIMITER $$
CREATE FUNCTION udf_count_flights_from_country(country VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (
	SELECT COUNT(f.departure_country)
		FROM flights AS f
        JOIN countries AS c on f.departure_country = c.id
		WHERE c.name = country
		GROUP BY f.departure_country
);
END$$

DELIMITER ;

SELECT udf_count_flights_from_country('Brazil') AS 'flights_count';
SELECT udf_count_flights_from_country('Philippines') AS 'flights_count';

-- 11. Delay flight
DELIMITER $$
CREATE PROCEDURE udp_delay_flight(code VARCHAR(50))
BEGIN
	UPDATE flights
		SET has_delay = 1, departure = departure + INTERVAL 30 MINUTE
		WHERE flight_code = code;
END $$

DELIMITER ;

CALL udp_delay_flight('ZP-782');
SELECT *
FROM flights
WHERE flight_code = 'ZP-782';
