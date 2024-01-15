CREATE DATABASE buhtig;
USE buhtig;

-- 01. Buhtig Table Design
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL
);

CREATE TABLE repositories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE repositories_contributors (
    repository_id INT,
    contributor_id INT,
    CONSTRAINT fk_repositories_contributors_reposiroties FOREIGN KEY (repository_id)
        REFERENCES repositories (id),
    CONSTRAINT fk_repositories_contributors_users FOREIGN KEY (contributor_id)
        REFERENCES users (id)
);

CREATE TABLE issues (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(225) NOT NULL,
    issue_status VARCHAR(6) NOT NULL,
    repository_id INT NOT NULL,
    assignee_id INT NOT NULL,
    CONSTRAINT fk_issues_repositories FOREIGN KEY (repository_id)
        REFERENCES repositories (id),
    CONSTRAINT fk_issues_users FOREIGN KEY (assignee_id)
        REFERENCES users (id)
);

CREATE TABLE commits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    message VARCHAR(225) NOT NULL,
    issue_id INT,
    repository_id INT NOT NULL,
    contributor_id INT NOT NULL,
    CONSTRAINT fk_commits_issues FOREIGN KEY (issue_id)
        REFERENCES issues (id),
    CONSTRAINT fk_commits_reposiroties FOREIGN KEY (repository_id)
        REFERENCES repositories (id),
    CONSTRAINT fk_commits_users FOREIGN KEY (contributor_id)
        REFERENCES users (id)
);

CREATE TABLE files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    size DECIMAL(10 , 2 ) NOT NULL,
    parent_id INT,
    commit_id INT NOT NULL,
    CONSTRAINT fk_files_files FOREIGN KEY (parent_id)
        REFERENCES files (id),
    CONSTRAINT fk_files_commits FOREIGN KEY (commit_id)
        REFERENCES commits (id)
);

-- 02. Buhtig Insert
INSERT INTO issues (title, issue_status, repository_id,assignee_id)
(
SELECT CONCAT('Critical Problem With ', name, '!') AS title,
'open' AS issue_status,
CEIL((id * 2) / 3) AS repository_id,
(SELECT contributor_id FROM commits AS c WHERE f.commit_id = c.id) AS assignee_id
FROM files AS f
WHERE f.id BETWEEN 46 AND 50
);

-- 03. Buhtig Update
UPDATE repositories_contributors AS rc
        JOIN
    (SELECT 
        r.id AS wanted_id
    FROM
        repositories AS r
    WHERE
        r.id NOT IN (SELECT 
                repository_id
            FROM
                repositories_contributors)
    ORDER BY r.id
    LIMIT 1) AS p 
SET 
    rc.repository_id = p.wanted_id
WHERE
    rc.repository_id = rc.contributor_id;
    
-- 04. Buhtig Delete
DELETE FROM repositories 
WHERE
    id NOT IN (SELECT 
        repository_id
    FROM
        issues);

-- 05. Buhtig Commit
DELIMITER $$
CREATE PROCEDURE udp_commit (username VARCHAR(30), password VARCHAR(30), message VARCHAR(225), issue_id INT)
BEGIN
 DECLARE user_commit_id INT;
if (SELECT username FROM users AS u WHERE u.username = username) IS NULL THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No such user!';
    ELSE
     START TRANSACTION;
     IF (SELECT u.password FROM users AS u WHERE u.username = username) != password THEN
     SIGNAL SQLSTATE '45000'
	 SET MESSAGE_TEXT = 'Password is incorrect!';
     ROLLBACK;
     ELSE
     IF (SELECT id FROM issues WHERE id = issue_id) IS NULL THEN
      SIGNAL SQLSTATE '45000'
	 SET MESSAGE_TEXT = 'The issue does not exist!';
     ROLLBACK;
     ELSE 
     
     SET user_commit_id = (SELECT id FROM users AS u WHERE u.username = username);
     
     INSERT INTO commits (message, issue_id, repository_id, contributor_id) 
     (
     SELECT message,
     i.id,
     i.repository_id,
     user_commit_id
     FROM issues AS i
     WHERE i.id = issue_id
     );
     
UPDATE issues 
SET 
    issue_status = 'closed'
WHERE
    id = issue_id;
COMMIT;
     END IF;
     END IF;
    END IF;
END $$

DELIMITER ;

CALL udp_commit('WhoDenoteBel', 'ajmISQi*', 'Fixed Issue: Invalid welcoming message in READ.html', 2);

-- 06. Buhtig Filter Extensions
DELIMITER $$
CREATE PROCEDURE udp_findbyextension (extension VARCHAR(30) )
BEGIN
SELECT id, name AS caption, CONCAT(size, 'KB') AS user FROM files
WHERE name LIKE CONCAT('%', extension)
ORDER BY id;
END $$

DELIMITER ;

CALL udp_findbyextension('html');