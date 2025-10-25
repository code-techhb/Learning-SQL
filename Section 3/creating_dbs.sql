/* Section 3: Database design and implementation ~ Murach's MySQL book 3rd edition
Chap 11: How to create databases, tables and indexes
Houlaymatou B. | code-techhb | Fall '25
*/

--  1 - working with indexes
CREATE INDEX last_name_idx 
ON customers(last_name);
SHOW INDEXES FROM customers;



-- 2 - Creat a DB from an ERR
-- --------------- 
DROP DATABASE IF EXISTS my_web_db;

CREATE DATABASE my_web_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Select the database
USE my_web_db;

-- Create tables
CREATE TABLE users (
    user_id         INT            PRIMARY KEY   AUTO_INCREMENT,
    email_address   VARCHAR(100)   NOT NULL      UNIQUE,
    first_name      VARCHAR(45)    NOT NULL,
    last_name       VARCHAR(45)    NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE products (
    product_id      INT            PRIMARY KEY   AUTO_INCREMENT,
    product_name    VARCHAR(45)    NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE downloads (
    download_id     INT            PRIMARY KEY   AUTO_INCREMENT,
    user_id         INT            NOT NULL,
    download_date   DATETIME       NOT NULL,
    filename        VARCHAR(50)    NOT NULL,
    product_id      INT            NOT NULL,
    CONSTRAINT downloads_fk_users
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT downloads_fk_products
        FOREIGN KEY (product_id)
        REFERENCES products (product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create indexes for better query performance
CREATE INDEX idx_product_name ON products (product_name);
CREATE INDEX idx_downloads_user_id ON downloads (user_id); 
CREATE INDEX idx_downloads_product_id ON downloads (product_id);
CREATE INDEX idx_download_date ON downloads (download_date);
-- Composite index for common query patterns (user downloads by date)
CREATE INDEX idx_user_download_date ON downloads (user_id, download_date); 




-- 3- Inserting Data to the web-db tables
INSERT INTO users (email_address, first_name, last_name)
VALUES 
    ('johnsmith@gmail.com', 'John', 'Smith'),
    ('janedoe@yahoo.com', 'Jane', 'Doe');
    
INSERT INTO products (product_name)
VALUES 
    ('Local Music Vol 1'),
    ('Local Music Vol 2');

INSERT INTO downloads (user_id, download_date, filename, product_id)
VALUES 
    (1, NOW(), 'pedals_are_falling.mp3', 2),  
    (2, NOW(), 'turn_signal.mp3', 1),      
    (2, NOW(), 'one_horse_town.mp3', 2);       
    
SELECT u.email_address,
       u.first_name,
       u.last_name,
       d.download_date,
       d.filename,
       p.product_name
FROM downloads d
    INNER JOIN users u 
        ON d.user_id = u.user_id
    INNER JOIN products p 
        ON d.product_id = p.product_id
ORDER BY 
    u.email_address DESC,
    p.product_name ASC;
    
    

-- 4- Altering tables - add cols
ALTER TABLE products
    ADD COLUMN product_price DECIMAL(5, 2) DEFAULT 9.99,
    ADD COLUMN date_added DATETIME DEFAULT NOW();
    

-- 5 Altering tables -- modifying cols
ALTER TABLE users
    MODIFY COLUMN first_name VARCHAR(20) NOT NULL;

-- failing statements   
UPDATE users
SET first_name = NULL
WHERE user_id = 1;

UPDATE users
SET first_name = 'Christopher Alexander'
WHERE user_id = 1;