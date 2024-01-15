CREATE DATABASE instagraph_db;
USE instagraph_db;

-- 01. Table Design
CREATE TABLE pictures (
    id INT PRIMARY KEY AUTO_INCREMENT,
    path VARCHAR(255) NOT NULL,
    size DECIMAL(10 , 2 ) NOT NULL
);

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(30) NOT NULL,
    profile_picture_id INT,
    CONSTRAINT fk_users_pictures FOREIGN KEY (profile_picture_id)
        REFERENCES pictures (id)
);

CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    caption VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    picture_id INT NOT NULL,
    CONSTRAINT fk_posts_users FOREIGN KEY (user_id)
        REFERENCES users (id),
    CONSTRAINT fk_posts_pictures FOREIGN KEY (picture_id)
        REFERENCES pictures (id)
);

CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    content VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    CONSTRAINT fk_comments_users FOREIGN KEY (user_id)
        REFERENCES users (id),
    CONSTRAINT fk_comments_posts FOREIGN KEY (post_id)
        REFERENCES posts (id)
);

CREATE TABLE users_followers (
    user_id INT,
    follower_id INT,
    CONSTRAINT fk_users_followers_users FOREIGN KEY (user_id)
        REFERENCES users (id),
    CONSTRAINT fk_users_followers_followers FOREIGN KEY (follower_id)
        REFERENCES users (id)
);

-- 02. Data Insertion
INSERT INTO comments (content, user_id,post_id)
(
SELECT 
    CONCAT('Omg!', u.username, '!This is so cool!'),
    CEIL((p.id * 3) / 2),
    p.id
FROM
    posts AS p
        JOIN
    users AS u ON p.user_id = u.id
WHERE 
	p.id BETWEEN 1 AND 10
);

-- 03. Data Update
UPDATE users AS u
        JOIN
    (SELECT 
        COUNT(*) AS count
    FROM
        users_followers AS uf
    WHERE
        uf.user_id = (SELECT 
                id
            FROM
                users
            WHERE
                profile_picture_id IS NULL)) AS p 
SET 
    u.profile_picture_id = (IF(p.count = 0,
        u.profile_picture_id = u.id,
        p.count))
WHERE
    u.profile_picture_id IS NULL;
    
-- 04. Data Deletion
DELETE u FROM users AS u
        LEFT JOIN
    users_followers AS uf ON u.id = uf.user_id 
WHERE
    uf.user_id IS NULL
    AND uf.follower_id IS NULL;
    
-- 05. Users
SELECT 
    id, username
FROM
    users
ORDER BY id;

-- 06. Cheaters
SELECT 
    u.id, u.username
FROM
    users AS u
        JOIN
    users_followers AS uf ON u.id = uf.user_id
WHERE
    u.id = uf.follower_id
ORDER BY u.id;

-- 07. High Quality Pictures
SELECT 
    *
FROM
    pictures
WHERE
    size > 50000
        AND (path LIKE ('%jpeg') OR path LIKE ('%'))
ORDER BY size DESC;

-- 08. Comments and Users
SELECT 
    c.id, CONCAT(u.username, ' : ', c.content) AS full_comment
FROM
    comments AS c
        JOIN
    users AS u ON c.user_id = u.id
ORDER BY c.id DESC;

-- 09. Profile Pictures
SELECT 
    u.id, u.username, p.size
FROM
    users AS u
        JOIN
    pictures AS p ON u.profile_picture_id = p.id
WHERE
    p.id IN (SELECT 
            profile_picture_id
        FROM
            users
        GROUP BY profile_picture_id
        HAVING COUNT(profile_picture_id) > 1)
ORDER BY u.id;

-- 10. Spam Posts
SELECT 
    p.id, p.caption, COUNT(c.id) AS comments
FROM
    posts AS p
        JOIN
    comments AS c ON p.id = c.post_id
GROUP BY p.id
ORDER BY `comments` DESC , p.id;

-- 11. Most Popular User
SELECT 
    u.id,
    u.username,
    (SELECT 
            COUNT(*)
        FROM
            posts AS p
        WHERE
            p.user_id = u.id) AS posts,
    COUNT(uf.follower_id) AS followers
FROM
    users AS u
        JOIN
    users_followers AS uf ON u.id = uf.user_id
GROUP BY u.id
ORDER BY `followers` DESC
LIMIT 1;

-- 12. Commenting Myself
SELECT 
    u.id, u.username, COUNT(p.id) AS my_comments
FROM
    users AS u
        JOIN
    comments AS c ON u.id = c.user_id
        JOIN
    posts AS p ON c.post_id = p.id
WHERE
    u.id = p.user_id
GROUP BY u.id
ORDER BY `my_comments` DESC , u.id;

-- 13. User Top Posts
SELECT u.id, u.username, p.caption FROM users AS u
JOIN posts AS p ON u.id = p.user_id
GROUP BY u.id, p.id
ORDER BY u.id; -- not finished

-- 14. Posts and Commentators
SELECT 
    p.id, p.caption, COUNT(u.id) AS users
FROM
    posts AS p
        JOIN
    users AS u ON p.user_id = u.id
        JOIN
    comments AS c ON p.id = c.post_id
GROUP BY p.id
ORDER BY `users` DESC, p.id;

-- 15. Post
DELIMITER $$
CREATE PROCEDURE udp_post (username VARCHAR(30), password VARCHAR(30), caption VARCHAR(255), path VARCHAR(255))
BEGIN
START TRANSACTION;
IF(password != (SELECT u.password FROM users AS u WHERE u.username = username))
THEN SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Password is incorrect!';
      ROLLBACK;
ELSE IF (path NOT IN (SELECT p.path FROM pictures AS p)) THEN 
SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The picture does not exist!';
ROLLBACK;
ELSE
INSERT INTO posts
(caption, user_id, picture_id)
	(SELECT caption,
	(SELECT id FROM users AS u WHERE u.username = username),
	(SELECT id FROM pictures AS p WHERE p.path = path)
	FROM users
    WHERE 
    id = (SELECT id FROM users AS u WHERE u.username = username AND u.password = password));
COMMIT;
END IF;
END IF;
END $$

DELIMITER ;
CALL udp_post('UnderSinduxrein', '4l8nYGTKMW', '#new #procedure', 'src/folders/resources/images/story/reformatted/img/hRI3TW31rC.img');

-- 16. Filter
DELIMITER $$
CREATE PROCEDURE udp_filter (hashtag VARCHAR(50))
BEGIN
SELECT 
    p.id, p.caption, u.username
FROM
    posts AS p
        JOIN
    users AS u ON p.user_id = u.id
WHERE
    caption LIKE CONCAT('%#', hashtag, '%')
ORDER BY p.id;
END $$

DELIMITER ;

CALL udp_filter('cool');