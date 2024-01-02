-- ------------------------ Part I – Queries for SoftUni Database ----------------------------
-- 01. Employees with Salary Above 35000
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000() 
BEGIN SELECT first_name, last_name 
FROM employees AS e
WHERE e.salary > 35000
ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

DELIMITER ;
-- 02. Employees with Salary Above Number
DELIMITER $$
CREATE PROCEDURE  usp_get_employees_salary_above(check_salary DECIMAL(19,4))
BEGIN
SELECT first_name, last_name
FROM employees AS e
WHERE e.salary >= check_salary
ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

DELIMITER ;

CALL usp_get_employees_salary_above(45000);

-- 03. Town Names Starting With
DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with(start_string VARCHAR(50))
BEGIN
SELECT name 
FROM towns AS t
WHERE t.name LIKE CONCAT(start_string, '%')
ORDER BY t.name;
END $$

DELIMITER ;

CALL usp_get_towns_starting_with('b');

-- 04. Employees from Town
DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN
SELECT e.first_name, e.last_name
FROM employees AS e
JOIN addresses AS d ON e.address_id = d.address_id
JOIN towns AS t ON d.town_id = t.town_id
WHERE t.name = town_name
ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

DELIMITER ;

CALL usp_get_employees_from_town('Sofia');

-- 05. Salary Level Function
DELIMITER $$
CREATE FUNCTION  ufn_get_salary_level(salary DECIMAL(19, 4))
RETURNS VARCHAR(7)
BEGIN
RETURN (
CASE
WHEN salary < 30000 THEN 'Low'
WHEN salary <= 50000 THEN 'Average'
ELSE 'High'
END
);
END $$

DELIMITER ;

SET GLOBAL log_bin_trust_function_creators = 1; -- allows use of create function without DETERMINISTIC etc.

SELECT ufn_get_salary_level(30000);

-- 06. Employees by Salary Level
DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(7))
BEGIN
SELECT first_name, last_name
FROM employees
WHERE (salary < 30000 AND salary_level = 'Low')
OR ((salary BETWEEN 30000 AND 50000) AND salary_level = 'Average')
OR(salary > 50000 AND salary_level = 'High')
ORDER BY first_name DESC, last_name DESC;
END $$

DELIMITER ;

CALL usp_get_employees_by_salary_level('High');


DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level2(salary_level VARCHAR(7))
BEGIN
SELECT first_name, last_name
FROM employees
WHERE (SELECT ufn_get_salary_level(salary) = salary_level)
ORDER BY first_name DESC, last_name DESC;
END $$

DELIMITER ;

CALL usp_get_employees_by_salary_level2('High');

-- 07. Define Function
CREATE FUNCTION  ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
RETURNS BIT
RETURN word REGEXP (CONCAT('^[', set_of_letters, ']+$'));

SELECT ufn_is_word_comprised('oistmiahf', 'Sofia');


-- ------------------------ PART II – Queries for Bank Database ----------------------------

-- 08. Find Full Name

DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
SELECT CONCAT_WS(' ',first_name, last_name) AS full_name
FROM account_holders
ORDER BY `full_name`, id;
END $$

DELIMITER ;

CALL usp_get_holders_full_name();

-- 9. People with Balance Higher Than (not included in final score)
DELIMITER $$
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(total_balance DECIMAL(19, 4))
BEGIN
SELECT ah.first_name, ah.last_name
FROM account_holders AS ah
JOIN accounts AS a ON ah.id  = a.account_holder_id
GROUP BY a.account_holder_id
HAVING SUM(a.balance) > total_balance
ORDER BY a.account_holder_id;
END $$

DELIMITER ;

CALL usp_get_holders_with_balance_higher_than(7000);

-- 10. Future Value Function
CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19, 4), yearly_interest_rate DOUBLE, number_of_years INT)
RETURNS DECIMAL(19, 4)
RETURN sum * POW((1 + yearly_interest_rate), number_of_years);

SELECT ufn_calculate_future_value(1000, 0.5, 5);

-- 11. Calculating Interest
DELIMITER $$
CREATE PROCEDURE  usp_calculate_future_value_for_account(account_id INT, interest_rate DECIMAL(19, 4))
BEGIN
SELECT a.id,
ah.first_name,
ah.last_name,
a.balance AS current_balance,
ufn_calculate_future_value(a.balance , interest_rate, 5) AS balance_in_5_years
FROM accounts AS a
JOIN account_holders AS ah ON  a.account_holder_id = ah.id
WHERE a.id = account_id ;
END $$

DELIMITER ;
CALL usp_calculate_future_value_for_account(1, 0.1);

-- 12. Deposit Money
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT , money_amount DECIMAL(19, 4))
BEGIN
START TRANSACTION;
IF (money_amount <= 0)
THEN ROLLBACK;
ELSE
UPDATE accounts AS a
SET a.balance = a.balance + money_amount
WHERE a.id = account_id;
END IF;
END $$

DELIMITER ;

CALL usp_deposit_money(1, 10);
CALL usp_deposit_money(1, 0);
CALL usp_deposit_money(1, -5);

-- 13. Withdraw Money
DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
IF (money_amount > 0)
THEN START TRANSACTION;
UPDATE accounts AS a 
SET 
    a.balance = a.balance - money_amount
WHERE
    a.id = account_id;
    IF (SELECT balance FROM accounts WHERE id = account_id) < 0
    THEN ROLLBACK;
	ELSE COMMIT;
    END IF;
END IF;
END $$

DELIMITER ;

CALL usp_withdraw_money(1, 113);
 SELECT * FROM accounts;
 
-- 14. Money Transfer
DELIMITER $$
CREATE PROCEDURE  usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19, 4))
BEGIN
	IF amount > 0
	   AND (SELECT id FROM accounts WHERE id = from_account_id) IS NOT NULL
       AND (SELECT id FROM accounts WHERE id = to_account_id) IS NOT NULL
       AND (SELECT balance FROM accounts WHERE id = from_account_id) >= amount
       AND (from_account_id <> to_account_id)
	THEN START TRANSACTION;
UPDATE accounts AS a 
SET 
    a.balance = a.balance - amount
WHERE
    a.id = from_account_id;
UPDATE accounts AS a 
SET 
    a.balance = a.balance + amount
WHERE
    a.id = to_account_id;
     END IF;
END $$

DELIMITER ;

CALL usp_transfer_money(1, 2, 20);
SELECT * FROM accounts;

-- 15. Log Accounts Trigger (not included in final score)
CREATE TABLE logs(
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT NOT NULL,
old_sum DECIMAL(19, 4) NOT NULL,
new_sum DECIMAL(19, 4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_changed_account_balance
AFTER UPDATE
ON accounts
FOR EACH ROW
BEGIN
	IF OLD.balance <> NEW.balance
    THEN
        INSERT INTO logs(account_id, old_sum, new_sum)
		VALUE (OLD.id, OLD.balance, NEW.balance);
	END IF;
END $$

DELIMITER ;
CALL usp_deposit_money(1, 10);
SELECT * FROM accounts;
SELECT * FROM logs;

-- 16. Emails Trigger (not included in final score)
CREATE TABLE notification_emails(
id INT PRIMARY KEY AUTO_INCREMENT,
recipient INT NOT NULL,
subject VARCHAR(50) NOT NULL,
body TEXT NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_create_notification_email
  AFTER INSERT
  ON logs
  FOR EACH ROW
BEGIN
  INSERT INTO notification_emails(recipient, subject, body)
  VALUE(NEW.account_id,
  CONCAT('Balance change for account: ', NEW.account_id),
  CONCAT_WS(' ', 'On', DATE_FORMAT(NOW(), '%M %e %Y at %r'), 'your balance was changed from', NEW.old_sum, 'to', NEW.new_sum));
END $$

DELIMITER ;
CALL usp_deposit_money(1, 10);
SELECT * FROM logs;
SELECT 
    *
FROM
    notification_emails;
