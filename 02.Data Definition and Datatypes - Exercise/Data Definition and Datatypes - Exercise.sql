
CREATE DATABASE minions;

-- 1
USE  minions;
CREATE TABLE minions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(25),
    age INT
);

CREATE TABLE towns (
    town_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(25)
);

-- 2

ALTER TABLE minions
ADD COLUMN town_id INT;

ALTER TABLE minions
ADD CONSTRAINT fk_towns_minions 
FOREIGN KEY minion(town_id)
REFERENCES towns(id);

-- 3
INSERT INTO `towns` (`id`, `name`)
VALUES (1, 'Sofia'), 
(2, 'Plovdiv'), 
(3, 'Varna');

INSERT INTO `minions` (`id`, `name`, `age`, `town_id`)
VALUES (1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2);

-- 4
TRUNCATE TABLE minions;
-- 5
DROP TABLE minions;
DROP TABLE towns;

-- 6
CREATE TABLE `people` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `picture` BLOB,
    `height` DOUBLE(5 , 2 ),
    `weight` DOUBLE(5 , 2 ),
    `gender` CHAR(1) NOT NULL,
    `birthdate` DATE NOT NULL,
    `biography` TEXT
);

INSERT INTO `people` (`name`, `gender` , `birthdate`)
VALUES ('Peter', 'm', DATE(NOW())),
('John', 'm', DATE(NOW())),
('Maria', 'f', DATE(NOW())),
('Alex', 'm', DATE(NOW())),
('Tricia', 'f', DATE(NOW()));

-- 7
CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(30) NOT NULL,
    `password` VARCHAR(26) NOT NULL,
    `profile_picture` BLOB,
    `last_login_time` DATETIME,
    `is_deleted` BOOLEAN
);

INSERT INTO `users` (`username`, `password`)
VALUES ('Some', 'pass'),
('Some', 'pass'),
('Some', 'pass'),
('Some', 'pass'),
('Some', 'pass');

INSERT INTO `users` (`username`, `password`, `last_login_time`, `is_deleted`)
VALUES ('Gogo', 'spojpe',  '2017-05-15', TRUE),
('Bobo','epgojro', '2017-08-05', FALSE),
('Ani',  'rpker', '2017-04-25', TRUE),
('Sasho',  'rgpjrpe', '2017-05-06', TRUE),
('Gery', 'pkptkh','2017-01-11', FALSE);

-- 8
ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users2
PRIMARY KEY users(`id`, `username`);

-- 9
ALTER TABLE `users`
CHANGE COLUMN `last_login_time`
`last_login_time` DATETIME DEFAULT NOW();

-- 10
ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY users(`id`),
CHANGE COLUMN `username`
`username` VARCHAR(30) UNIQUE;

-- 11
CREATE DATABASE movies;
USE movies;

CREATE TABLE `directors` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    director_name VARCHAR(30) NOT NULL,
    notes TEXT
);

INSERT INTO `directors` (id, director_name)
VALUES (1, 'Peter'),
(2, 'Peter'),
(3, 'Peter'),
(4, 'Peter'),
(5, 'Peter');

CREATE TABLE `genres` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(30) NOT NULL,
    notes TEXT
);

INSERT INTO `genres` (id, genre_name) 
VALUES (1, 'Action'),
(2, 'Action'),
(3, 'Action'),
(4, 'Action'),
(5, 'Action');

CREATE TABLE `categories` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(30) NOT NULL,
    notes TEXT
);

INSERT INTO `categories` (id, category_name) 
VALUES (1, 'none'),
(2, 'none'),
(3, 'none'),
(4, 'none'),
(5, 'none');

CREATE TABLE `movies` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(30) NOT NULL,
    director_id INT,
    FOREIGN KEY (director_id)
        REFERENCES directors (id),
    copyright_year YEAR,
    length DOUBLE(6 , 2 ),
    genre_id INT,
    FOREIGN KEY (genre_id)
        REFERENCES genres (id),
    category_id INT,
    FOREIGN KEY (category_id)
        REFERENCES categories (id),
    rating DOUBLE(4 , 2 ),
    notes TEXT
);

INSERT INTO `movies` (title, director_id, genre_id, category_id) 
VALUES ("Terminator", 1, 4, 1),
("Terminator", 1, 2, 3),
("Terminator", 2, 5, 1),
("Terminator", 3, 4, 2),
("Terminator", 1, 2, 5);

-- 12------
CREATE TABLE `categories` (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    category VARCHAR(50) NOT NULL,
    daily_rate DECIMAL(5 , 2 ),
    weekly_rate DECIMAL(5 , 2 ),
    monthly_rate DECIMAL(5 , 2 ),
    weekend_rate DECIMAL(5 , 2 )
);

insert into categories(category)
values('A'),
('B'),
('C');

CREATE TABLE `cars` (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    plate_number INT NOT NULL,
    make VARCHAR(10) NOT NULL,
    model VARCHAR(10),
    car_year DATE,
    category_id INT,
    FOREIGN KEY (category_id)
        REFERENCES caegories (id),
    doors INT,
    picture BLOB,
    car_condition VARCHAR(20),
    available BIT
);

insert into `cars`(plate_number,make) 
values(74646734, "Opel"),
(2352341, "BMW"),
(90632, "VW");

CREATE TABLE `employees` (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    title VARCHAR(50),
    notes TEXT
);
insert into `employees`(first_name) values
('John'),
('Peter'),
('Smith');

CREATE TABLE `customers` (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    driver_licence_number VARCHAR(20) NOT NULL,
    full_name VARCHAR(50) NOT NULL,
    address VARCHAR(50),
    city VARCHAR(50),
    zip_code VARCHAR(50),
    notes TEXT
);

insert into `customers`(driver_licence_number,full_name) values
(12345, 'Peter Peter'),
	(57536, 'John Johnson'),
	(46885, 'Nobody Mister');

CREATE TABLE `rental_orders` (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    employee_id INT,
    FOREIGN KEY (employee_id)
        REFERENCES emplyoees (id),
    customer_id INT,FOREIGN KEY (customer_id)
        REFERENCES customers (id),
    car_id INT,
    car_condition VARCHAR(50),
    tank_level DECIMAL(20 , 2 ),
    kilometrage_start INT,
    kilometrage_end INT,
    total_kilometrage INT,
    start_date DATE,
    end_date DATE,
    total_days INT,
    rate_applied VARCHAR(50),
    tax_rate INT,
    order_status VARCHAR(30),
    notes TEXT
);

INSERT INTO rental_orders (employee_id, customer_id, car_id, kilometrage_start) VALUES
    (1, 2, 3, 12567),
	(3, 3, 2, 2000.67),
	(2, 1, 2, 120985.89);
    
    -- 13
    CREATE DATABASE `soft_uni`;
    USE `soft_uni`;
  
    create table `towns` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(30)
    );
    
    CREATE TABLE `addresses` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `address_text` TEXT,
    `town_id` INT,
    FOREIGN KEY (town_id)
        REFERENCES towns (id)
);

 create table `departments` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(30)
    );
  
CREATE TABLE `employees` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    middle_name VARCHAR(30),
    last_name VARCHAR(30),
    job_title VARCHAR(30),
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES departments (id),
    hire_date DATE,
    salary DOUBLE(10 , 2 ),
    address_id INT,
    FOREIGN KEY (address_id)
        REFERENCES addresses (id)
);

INSERT INTO `towns` (`name`) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas');

INSERT INTO `departments` (`name`) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance');

INSERT INTO `employees` (`first_name`, `middle_name`, `last_name`, `job_title`, `department_id`, `hire_date`, `salary`)
VALUES ('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28' , 599.88);

-- 14
SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;

-- 15
SELECT * FROM `towns`
ORDER BY `name`;

SELECT * FROM `departments`
ORDER BY `name`;

SELECT * FROM `employees`
ORDER BY `salary` DESC;

-- 16
SELECT `name` FROM `towns`
ORDER BY `name`;
SELECT `name` FROM `departments`
ORDER BY `name`;
SELECT 
    `first_name`, `last_name`, `job_title`, `salary`
FROM
    `employees`
    ORDER BY `salary` DESC;

-- 17
UPDATE `employees`
SET `salary` = `salary` * 1.1; -- To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.You cannot update without WHERE in Sefe mode. 
SELECT `salary` FROM `employees`; 





    