CREATE DATABASE colonial_journey_management_system_db;
USE colonial_journey_management_system_db;

-- 00. Table Design
CREATE TABLE planets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE spaceports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    planet_id INT,
    CONSTRAINT fk_spaceports_planets FOREIGN KEY (planet_id)
        REFERENCES planets (id)
);

CREATE TABLE spaceships (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(30) NOT NULL,
    light_speed_rate INT DEFAULT 0
);

CREATE TABLE colonists (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    ucn CHAR(10) NOT NULL UNIQUE,
    birth_date DATE NOT NULL
);

CREATE TABLE journeys (
    id INT PRIMARY KEY AUTO_INCREMENT,
    journey_start DATETIME NOT NULL,
    journey_end DATETIME NOT NULL,
    purpose ENUM('Medical', 'Technical', 'Educational', 'Military'),
    destination_spaceport_id INT,
    spaceship_id INT,
    CONSTRAINT fk_journeys_spaceports FOREIGN KEY (destination_spaceport_id)
        REFERENCES spaceports (id),
    CONSTRAINT fk_journeys_spaceships FOREIGN KEY (spaceship_id)
        REFERENCES spaceships (id)
);

CREATE TABLE travel_cards (
    id INT PRIMARY KEY AUTO_INCREMENT,
    card_number CHAR(10) NOT NULL UNIQUE,
    job_during_journey ENUM('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'),
    colonist_id INT,
    journey_id INT,
    CONSTRAINT fk_travel_cards_colonists FOREIGN KEY (colonist_id)
        REFERENCES colonists (id),
    CONSTRAINT fk_travel_cards_journeys FOREIGN KEY (journey_id)
        REFERENCES journeys (id)
);

-- 01. Insert
INSERT INTO travel_cards (card_number, job_during_journey,colonist_id, journey_id)
(
SELECT 
    (CASE
        WHEN
            birth_date > '1980-01-01'
        THEN
            CONCAT(YEAR(birth_date),
                    DAY(birth_date),
                    LEFT(ucn, 4))
        ELSE CONCAT(YEAR(birth_date),
                MONTH(birth_date),
                RIGHT(ucn, 4))
    END),
    (CASE
        WHEN id % 2 = 0 THEN 'Pilot'
        WHEN id % 3 = 0 THEN 'Cook'
        ELSE 'Engineer'
    END),
    id,
    LEFT(ucn, 1)
FROM
    colonists
WHERE
	id BETWEEN 96 AND 100
);

-- 02. Update
UPDATE journeys 
SET 
    purpose = (CASE
        WHEN id % 2 = 0 THEN 'Medical'
        WHEN id % 3 = 0 THEN 'Technical'
        WHEN id % 5 = 0 THEN 'Educational'
        WHEN id % 7 = 0 THEN 'Military'
        ELSE purpose
    END);
        
-- 03. Delete
DELETE FROM colonists 
WHERE
    id NOT IN (SELECT 
        colonist_id
    FROM
        travel_cards);
        
-- 04. Extract all travel cards
SELECT 
    card_number, job_during_journey
FROM
    travel_cards
ORDER BY card_number;

-- 05. Extract all colonists
SELECT 
    id, CONCAT(first_name, ' ', last_name) AS full_name, ucn
FROM
    colonists
ORDER BY first_name , last_name , id;

-- 06. Extract all military journeys
SELECT 
    id, journey_start, journey_end
FROM
    journeys
WHERE
    purpose = 'Military'
ORDER BY journey_start;

-- 07. Extract all pilots
SELECT 
    c.id, CONCAT(first_name, ' ', last_name) AS full_name
FROM
    colonists AS c
        JOIN
    travel_cards AS tc ON c.id = tc.colonist_id
WHERE
    tc.job_during_journey = 'Pilot'
ORDER BY c.id;

-- 08. Count all colonists
SELECT 
    COUNT(*) AS count
FROM
    colonists AS c
        JOIN
    travel_cards AS tc ON c.id = tc.colonist_id
        JOIN
    journeys AS j ON tc.journey_id = j.id
WHERE
    j.purpose = 'Technical';
    
-- 09.Extract the fastest spaceship
SELECT 
    s.name, sp.name
FROM
    spaceships AS s
        JOIN
    journeys AS j ON s.id = j.spaceship_id
        JOIN
    spaceports AS sp ON j.destination_spaceport_id = sp.id
ORDER BY s.light_speed_rate DESC
LIMIT 1;

-- 10. Extract - pilots younger than 30 years
SELECT 
    s.name, s.manufacturer
FROM
    spaceships AS s
        JOIN
    journeys AS j ON s.id = j.spaceship_id
        JOIN
    travel_cards AS tc ON j.id = tc.journey_id
        JOIN
    colonists AS c ON tc.colonist_id = c.id
WHERE
    tc.job_during_journey = 'Pilot'
        AND YEAR(c.birth_date) > YEAR('2019-01-01' - INTERVAL 30 YEAR)
ORDER BY s.name;

-- 11. Extract all educational mission
SELECT 
    p.name, s.name
FROM
    planets AS p
        JOIN
    spaceports AS s ON p.id = s.planet_id
        JOIN
    journeys AS j ON s.id = j.destination_spaceport_id
WHERE
    j.purpose = 'Educational'
ORDER BY s.name DESC;

-- 12. Extract all planets and their journey count
SELECT 
    p.name AS planet_name, COUNT(j.id) AS journeys_count
FROM
    planets AS p
        JOIN
    spaceports AS s ON p.id = s.planet_id
        JOIN
    journeys AS j ON s.id = j.destination_spaceport_id
GROUP BY p.id
ORDER BY `journeys_count` DESC , p.name;

-- 13. Extract the shortest journey
SELECT 
    j.id,
    p.name AS planet_name,
    s.name AS spaceport_name,
    j.purpose AS journey_purpose
FROM
    journeys AS j
        JOIN
    spaceports AS s ON j.destination_spaceport_id = s.id
        JOIN
    planets AS p ON s.planet_id = p.id
ORDER BY j.journey_end - j.journey_start
LIMIT 1;

-- 14. Extract the less popular job
SELECT 
    tc.job_during_journey
FROM
    travel_cards tc
WHERE
    tc.journey_id = (SELECT 
            j.id
        FROM
            journeys AS j
        ORDER BY DATEDIFF(j.journey_end, j.journey_start) DESC
        LIMIT 1)
GROUP BY tc.job_during_journey
ORDER BY COUNT(tc.job_during_journey)
LIMIT 1;

-- 15. Get colonists count
DELIMITER $$
CREATE FUNCTION udf_count_colonists_by_destination_planet (planet_name VARCHAR (30))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN
(
SELECT 
    COUNT(tc.colonist_id)
FROM
    planets AS p
        JOIN
    spaceports AS s ON s.planet_id = p.id
        JOIN
    journeys AS j ON s.id = j.destination_spaceport_id
        JOIN
    travel_cards AS tc ON j.id = tc.journey_id
WHERE
    p.name = planet_name
);
END $$

DELIMITER ;

SELECT 
    p.name,
    UDF_COUNT_COLONISTS_BY_DESTINATION_PLANET('Otroyphus') AS count
FROM
    planets AS p
WHERE
    p.name = 'Otroyphus';
    
-- 16. Modify spaceship
DELIMITER $$
CREATE PROCEDURE udp_modify_spaceship_light_speed_rate(spaceship_name VARCHAR(50), light_speed_rate_increse INT(11))
BEGIN
START TRANSACTION;
UPDATE spaceships 
SET 
    light_speed_rate = light_speed_rate + light_speed_rate_increse
WHERE
    name = spaceship_name;

IF (SELECT id FROM spaceships WHERE name = spaceship_name) IS NULL
	THEN SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
	ROLLBACK;
ELSE COMMIT;
END IF;
END $$

DELIMITER ;
CALL udp_modify_spaceship_light_speed_rate ('Na Pesho koraba', 1914);
SELECT name, light_speed_rate FROM spaceships WHERE name = 'Na Pesho koraba';

CALL udp_modify_spaceship_light_speed_rate ('USS Templar', 5);
SELECT name, light_speed_rate FROM spaceships WHERE name = 'USS Templar';
