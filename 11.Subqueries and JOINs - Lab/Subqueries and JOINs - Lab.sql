-- 1. Managers
SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    departments.department_id,
    departments.name
FROM
    employees
        RIGHT JOIN
    departments ON departments.manager_id = employees.employee_id
ORDER BY employee_id
LIMIT 5;

-- 2. Towns and Addresses
SELECT 
    t.town_id, t.name AS 'town_name', a.address_text
FROM
    towns AS t
        JOIN
    addresses AS a ON a.town_id = t.town_id
WHERE
    name IN ('San Francisco' , 'Sofia', 'Carnation')
ORDER BY town_id , address_id;

-- 3. Employees Without Managers
SELECT 
    employee_id, first_name, last_name, department_id, salary
FROM
    employees
WHERE
    manager_id IS NULL;
    
-- 4. High Salary
SELECT 
    COUNT(salary)
FROM
    employees
WHERE
    salary > (SELECT 
            AVG(salary)
        FROM
            employees);
