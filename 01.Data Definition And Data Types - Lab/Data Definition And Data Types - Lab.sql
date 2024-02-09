-- 01. Create Tables
CREATE TABLE `employees` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL);
  
  CREATE TABLE `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(45) NOT NULL);
  

  CREATE TABLE `products` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(45) NOT NULL,
  `category_id` INT NOT NULL);
  
  -- 02. Insert Data in Tables
  INSERT INTO `employees` (`first_name`, `last_name`) VALUES ('John', 'John'),
("Peter", "Peter"),
("Mаria", "Maria");

-- 03. Alter Tables
ALTER TABLE `employees`
ADD COLUMN `middle_name` VARCHAR(50);

-- 04. Adding Constraints
ALTER TABLE `products` 
ADD CONSTRAINT `fk`
  FOREIGN KEY (`category_id`)
  REFERENCES `categories` (`id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
  
-- 05. Modifying Columns
ALTER TABLE `employees` 
CHANGE COLUMN `middle_name` `middle_name` VARCHAR(100) NULL DEFAULT NULL;
