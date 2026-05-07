SET SQL_SAFE_UPDATES = false;
DROP DATABASE test;
CREATE DATABASE test;

USE test;

CREATE TABLE Users(
	user_id INT primary key auto_increment,
    username VARCHAR(50) unique not null,
    password VARCHAR(255) not null,
    email VARCHAR(100) not null,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE Posts(
	post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT not null,
    content TEXT not null,
    created_at datetime DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Comments(
	comment_id INT PRIMARY KEY AUTO_INCREMENT,
	post_id INT,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Friends(
	user_id INT,
    friend_id INT,
    status VARCHAR(20) CHECK (status IN ('pending','accepted')),
	PRIMARY KEY(user_id,friend_id),
    FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(friend_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    Check(user_id != friend_id)
);

CREATE TABLE Likes(
	user_id INT,
    post_id INT,
    FOREIGN KEY(post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    PRIMARY KEY(user_id,post_id)
);


-- Users
INSERT INTO Users (username, password, email) VALUES
('alice', 'alice123', 'alice@gmail.com'),
('bob', 'bob123', 'bob@gmail.com'),
('charlie', 'charlie123', 'charlie@gmail.com'),
('david', 'david123', 'david@gmail.com'),
('emma', 'emma123', 'emma@gmail.com');

-- Posts
INSERT INTO Posts (user_id, content) VALUES
(1, 'Hello everyone, this is my first post!'),
(2, 'Today is a beautiful day 🌤️'),
(3, 'Learning MySQL is really fun!'),
(1, 'Just finished my homework.'),
(4, 'Anyone wants to play games tonight?');

-- Comments
INSERT INTO Comments (post_id, user_id, content) VALUES
(1, 2, 'Welcome to the platform!'),
(1, 3, 'Nice to meet you!'),
(2, 1, 'Yeah, weather is great today.'),
(3, 5, 'SQL procedures are difficult 😭'),
(5, 2, 'I am in!');

-- Friends
INSERT INTO Friends (user_id, friend_id, status) VALUES
(1, 2, 'accepted'),
(1, 3, 'pending'),
(2, 3, 'accepted'),
(3, 4, 'accepted'),
(4, 5, 'pending');

-- Likes
INSERT INTO Likes (user_id, post_id) VALUES
(1, 2),
(2, 1),
(3, 1),
(4, 3),
(5, 2),
(2, 5);


CREATE VIEW vw_UserInfo AS
SELECT user_id,username,email,created_at
FROM Users;

SELECT * FROM vw_UserInfo;

-- YC 2
CREATE VIEW vw_PostStatistics AS
SELECT pos.post_id, pos.content, `use`.username, SUM(lik.post_id), SUM(com.post_id)
FROM Posts pos
JOIN Comments com ON com.post_id = pos.post_id
JOIN Likes lik ON lik.post_id = pos.post_id
JOIN Users `use` ON `use`.user_id = pos.user_id
GROUP BY pos.post_id;

select * from vw_PostStatistics;

-- YC 3

DELIMITER //
CREATE PROCEDURE sp_AddUser(IN username_in VARCHAR(50),IN password_in VARCHAR(255),IN email_in VARCHAR(100),OUT addUser_out varchar(255))
BEGIN
	DECLARE email_process VARCHAR(100);
    
    SELECT email
    INTO email_process
    FROM Users
    WHERE email = email_in
    LIMIT 1; -- chắc chắn chỉ có 1 email
    
    IF email_process IS NULL THEN
		INSERT INTO Users(username,password,email)
        VALUES(username_in,password_in,email_in);
        SET addUser_out = "Thêm thành công";
	ELSE
		SET addUser_out = "Email đã được sử dụng";
    END IF;
    
END //
DELIMITER ;

CALL sp_AddUser('tom','tom123','tom@gmail.com',@result);

SELECT @result;
SELECT * FROM Users;

DELIMITER //
CREATE PROCEDURE newPost(IN user_id_in INT, IN content_in TEXT, OUT post_id_out INT)
BEGIN
    INSERT INTO Posts(user_id,content)
    VALUES(user_id_in,content_in);
	
	SET post_id_out = last_insert_id();
END //
DELIMITER ;

CALL newPost(5,"yoooooooo",@result_new_post);
SELECT @result_new_post;

-- YC 5
DELIMITER //

CREATE PROCEDURE friend_list_show(IN user_id_friend_in INT, IN limit_in INT, IN offset_in INT)
BEGIN
    SELECT 
        us.username,
        us.email
    FROM Friends fri
    JOIN Users us ON us.user_id = fri.friend_id
    WHERE fri.user_id = user_id_friend_in and fri.status = "accepted"
    LIMIT limit_in OFFSET offset_in;
END //

DELIMITER ;

CALL friend_list_show(3,3,0);

-- YC 5.1
CREATE INDEX idx_post_created_at ON Posts(post_id);

-- YC 5.2
DELETE FROM Users LIMIT 1;
SELECT * FROM Users;
