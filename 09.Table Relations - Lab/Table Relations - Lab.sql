-- 1. Mountains and Peaks
 CREATE TABLE mountains (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL
);
 
 CREATE TABLE peaks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    mountain_id INT,
    CONSTRAINT fk_peaks_mountains FOREIGN KEY (mountain_id)
        REFERENCES mountains (id)
);

-- 2. Trip Organization
SELECT 
    driver_id,
    vehicle_type,
    CONCAT(first_name, ' ', last_name) AS driver_name
FROM
    vehicles AS v
        JOIN
    campers AS c ON v.driver_id = c.id;
    
-- 3. SoftUni Hiking
SELECT 
    starting_point,
    end_point,
    leader_id,
    CONCAT(first_name, ' ', last_name) AS leader_name
FROM
    routes AS r
        JOIN
    campers AS c ON r.leader_id = c.id;
    
-- 4. Delete Mountains
    CREATE TABLE mountains (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL
);
 
 CREATE TABLE peaks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    mountain_id INT,
    CONSTRAINT fk_peaks_mountains FOREIGN KEY (mountain_id)
        REFERENCES mountains (id)
        ON DELETE CASCADE
);

-- Project Management DB*
CREATE DATABASE project_management;

CREATE TABLE clients (
id INT PRIMARY KEY AUTO_INCREMENT,
client_name VARCHAR(100) NOT NULL
);

CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    project_lead_id INT,
    CONSTRAINT fk_projects_client_id_clients_id FOREIGN KEY (client_id)
        REFERENCES clients (id)
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30),
last_name VARCHAR(30),
project_id INT,
CONSTRAINT fk_projects_project_id_projects_id
FOREIGN KEY (project_id)
REFERENCES projects(id)
);

ALTER TABLE projects
ADD CONSTRAINT fk_projects_project_lead_id_employees_id
FOREIGN KEY (project_lead_id)
REFERENCES employees(id);
