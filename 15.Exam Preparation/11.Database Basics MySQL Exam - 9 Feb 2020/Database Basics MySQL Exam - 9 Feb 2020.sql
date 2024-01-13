CREATE DATABASE fsd;
USE fsd;

-- 01. Table Design
CREATE TABLE players (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    age INT NOT NULL DEFAULT 0,
    position CHAR(1) NOT NULL,
    salary DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    hire_date DATETIME,
    skills_data_id INT NOT NULL,
    team_id INT,
    CONSTRAINT fk_players_teams FOREIGN KEY (team_id)
        REFERENCES teams (id)
);

CREATE TABLE players_coaches (
    player_id INT,
    coach_id INT,
    CONSTRAINT fk_players_coaches_players FOREIGN KEY (player_id)
        REFERENCES players (id),
    CONSTRAINT fk_players_coaches_coaches FOREIGN KEY (coach_id)
        REFERENCES coaches (id)
);

 CREATE TABLE coaches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    salary DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    coach_level INT NOT NULL DEFAULT 0
);

CREATE TABLE skills_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dribbling INT DEFAULT 0,
    pace INT DEFAULT 0,
    passing INT DEFAULT 0,
    shooting INT DEFAULT 0,
    speed INT DEFAULT 0,
    strength INT DEFAULT 0
);

CREATE TABLE teams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    established DATE NOT NULL,
    fan_base BIGINT NOT NULL DEFAULT 0,
    stadium_id INT NOT NULL,
    CONSTRAINT fk_teams_stadiums FOREIGN KEY (stadium_id)
        REFERENCES stadiums (id)
);

CREATE TABLE stadiums (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    capacity INT NOT NULL,
    town_id INT NOT NULL,
    CONSTRAINT fk_stadiums_towns FOREIGN KEY (town_id)
        REFERENCES towns (id)
);

CREATE TABLE towns (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    country_id INT NOT NULL,
    CONSTRAINT fk_towns_countries FOREIGN KEY (country_id)
        REFERENCES countries (id)
);

CREATE TABLE countries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL
);

-- 02. Insert
INSERT INTO coaches (first_name ,last_name ,salary,coach_level) 
(
SELECT 
    first_name, last_name, salary * 2, CHAR_LENGTH(first_name)
FROM
    players
WHERE
    age >= 45
);

-- 03. Update
UPDATE coaches AS c 
SET 
    c.coach_level = c.coach_level + 1
WHERE
    (SELECT 
            COUNT(*)
        FROM
            players_coaches AS pc
        WHERE
            c.id = pc.coach_id) >= 1
        AND LEFT(c.first_name, 1) = 'A';
        
-- 04. Delete
DELETE FROM players
WHERE age >= 45;

-- 05. Players
SELECT 
    first_name, age, salary
FROM
    players
ORDER BY salary DESC;

-- 06. Young offense players without contract
SELECT 
    p.id,
    CONCAT_WS(' ', p.first_name, p.last_name) AS full_name,
    p.age,
    p.position,
    p.hire_date
FROM
    players AS p
        JOIN
    skills_data AS sd ON p.skills_data_id = sd.id
WHERE
    p.position = 'A' AND p.age < 23
        AND p.hire_date IS NULL
        AND sd.strength > 50
ORDER BY p.salary , p.age;

-- 07. Detail info for all teams
SELECT 
    t.name AS team_name,
    t.established,
    t.fan_base,
    COUNT(p.id) AS players_count
FROM
    players AS p
        RIGHT JOIN
    teams AS t ON p.team_id = t.id
GROUP BY t.id
ORDER BY `players_count` DESC , t.fan_base DESC;

-- 08. The fastest player by towns
SELECT 
    MAX(sd.speed) AS max_speed, t.name AS town_name
FROM
    towns AS t
        LEFT JOIN
    stadiums AS s ON t.id = s.town_id
        LEFT JOIN
    teams AS te ON s.id = te.stadium_id
        LEFT JOIN
    players AS p ON te.id = p.team_id
        LEFT JOIN
    skills_data AS sd ON p.skills_data_id = sd.id
WHERE
    te.name != 'Devify'
GROUP BY t.id
ORDER BY `max_speed` DESC , town_name;

-- 09. Total salaries and players by country
SELECT 
    c.name,
    COUNT(p.id) AS total_count_of_players,
    SUM(p.salary) AS total_sum_of_salaries
FROM
    players AS p
        RIGHT JOIN
    teams AS t ON p.team_id = t.id
        RIGHT JOIN
    stadiums AS s ON t.stadium_id = s.id
        RIGHT JOIN
    towns AS tow ON s.town_id = tow.id
        RIGHT JOIN
    countries AS c ON tow.country_id = c.id
GROUP BY c.name
ORDER BY `total_count_of_players` DESC , c.name;

-- 10. Find all players that play on stadium
DELIMITER $$
CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN(
SELECT 
    COUNT(p.id)
FROM
    stadiums AS s
        LEFT JOIN
    teams AS t ON s.id = t.stadium_id
         LEFT JOIN
    players AS p ON t.id = p.team_id
WHERE
    s.name = stadium_name
GROUP BY s.id
);
END $$
   
DELIMITER ;
SELECT udf_stadium_players_count ('Jaxworks') as `count`;
SELECT udf_stadium_players_count ('Linklinks') as `count`;

-- 11. Find good playmaker by teams
DELIMITER $$
CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT, team_name VARCHAR(45))
BEGIN
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    p.age,
    p.salary,
    sd.dribbling,
    sd.speed,
    t.name
FROM
    players AS p
        JOIN
    teams AS t ON p.team_id = t.id
        JOIN
    skills_data AS sd ON p.skills_data_id = sd.id
WHERE
    sd.dribbling > min_dribble_points AND t.name = team_name
        AND sd.speed > (SELECT 
            AVG(speed)
        FROM
            skills_data)
ORDER BY sd.speed DESC
LIMIT 1;
END $$

DELIMITER ;
CALL udp_find_playmaker (20, 'Skyble');
