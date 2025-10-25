/* Section 3: Database Design and Implementation ~ Murach's MySQL book 3rd edition
Chap 10: How to design a Database
Houlaymatou B. | code-techhb | Fall '25
*/

-- ============================================================================
-- DATABASE RELATIONSHIPS CHEAT SHEET
-- ============================================================================
-- A comprehensive guide to understanding and implementing the three main
-- types of database relationships in MySQL
-- Date: 2025-10-14
-- ============================================================================

-- ============================================================================
-- TABLE OF CONTENTS
-- ============================================================================
-- 1. Quick Decision Guide
-- 2. One-to-One (1:1) Relationships
-- 3. One-to-Many (1:N) Relationships
-- 4. Many-to-Many (M:N) Relationships
-- 5. Referential Integrity Actions
-- 6. Best Practices
-- ============================================================================


-- ============================================================================
-- 1. QUICK DECISION GUIDE
-- ============================================================================
/*
Ask yourself: "Can A have multiple B's? Can B have multiple A's?"

┌─────────────┬─────────────┬──────────────────┬─────────────────────────┐
│   A → B     │   B → A     │  Relationship    │  Implementation         │
├─────────────┼─────────────┼──────────────────┼─────────────────────────┤
│    NO       │    NO       │  One-to-One      │  FK + UNIQUE constraint │
│    YES      │    NO       │  One-to-Many     │  FK on "many" side      │
│    NO       │    YES      │  One-to-Many     │  FK on "many" side      │
│    YES      │    YES      │  Many-to-Many    │  Junction table needed  │
└─────────────┴─────────────┴──────────────────┴─────────────────────────┘

GOLDEN RULE: 
- One-to-Many is MOST COMMON (90% of relationships)
- Many-to-Many ALWAYS needs a junction/bridge table
- Foreign key goes on the "many" or "child" side
*/


-- ============================================================================
-- 2. ONE-TO-ONE (1:1) RELATIONSHIPS
-- ============================================================================
/*
DESCRIPTION:
    One record in Table A relates to exactly ONE record in Table B
    
STRUCTURE:
    Foreign key in either table with UNIQUE constraint
    
WHEN TO USE:
    - Split tables for organization, security, or performance
    - Separate sensitive data (e.g., SSN, salary)
    - Optional data that doesn't apply to all records
    - Rarely used in practice - consider merging tables first
    
REAL-WORLD EXAMPLES:
    ✓ Person → Passport (one person has one passport)
    ✓ User → UserProfile (one user has one detailed profile)
    ✓ Employee → ParkingSpot (one employee gets one parking spot)
    ✓ State → Capitol (one State has one capitol)

VISUAL DIAGRAM:
    Users                   UserProfiles
    ┌─────────────┐        ┌──────────────┐
    │ UserID (PK) │◄───────│ ProfileID(PK)│
    │ Username    │        │ UserID (FK)  │ ← UNIQUE constraint
    │ Email       │        │ Bio          │
    └─────────────┘        │ Avatar       │
                           │ DateOfBirth  │
                           └──────────────┘

KEY THINGS TO REMEMBER:
    → RARE in practice - often better to merge into one table
    → Use UNIQUE constraint on foreign key to enforce 1:1
    → Good for sensitive data separation
    → Can put FK in either table
    → Both tables should have same number of related rows
*/

-- Example 1: User and Profile (Profile references User)
DROP TABLE IF EXISTS UserProfiles;
DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE UserProfiles (
    ProfileID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE NOT NULL,  -- UNIQUE enforces 1:1 relationship
    Bio TEXT,
    Avatar VARCHAR(255),
    PhoneNumber VARCHAR(20),
    DateOfBirth DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Sample Data
INSERT INTO Users (Username, Email) VALUES 
    ('john_doe', 'john@example.com'),
    ('jane_smith', 'jane@example.com');

INSERT INTO UserProfiles (UserID, Bio, PhoneNumber) VALUES 
    (1, 'Software developer from NYC', '555-0101'),
    (1, 'Graphic designer and coffee lover', '555-0102');

-- This will fail due to UNIQUE constraint on USERID
-- INSERT INTO UserProfiles (UserID, Bio) VALUES (1, 'Duplicate profile');


-- Example 2: Employee and Parking Spot
DROP TABLE IF EXISTS ParkingSpots;
DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50)
);

CREATE TABLE ParkingSpots (
    SpotID INT PRIMARY KEY AUTO_INCREMENT,
    SpotNumber VARCHAR(10) NOT NULL UNIQUE,
    EmployeeID INT UNIQUE,  -- UNIQUE enforces 1:1, NULL allowed
    Floor INT,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
        ON DELETE SET NULL  -- If employee deleted, spot becomes available
);


-- ============================================================================
-- 3. ONE-TO-MANY (1:N) RELATIONSHIPS
-- ============================================================================
/*
DESCRIPTION:
    One record in Table A relates to MANY records in Table B
    
STRUCTURE:
    Foreign key on the "many" side table
    
WHEN TO USE:
    MOST COMMON relationship - use whenever one entity owns/contains 
    multiple instances of another entity
    
REAL-WORLD EXAMPLES:
    ✓ Customer → Orders (one customer places many orders)
    ✓ Department → Employees (one department has many employees)
    ✓ Blog Post → Comments (one post has many comments)
    ✓ Author → Books (one author writes many books)
    ✓ Category → Products (one category contains many products)

VISUAL DIAGRAM:
    Customers               Orders
    ┌──────────────┐       ┌─────────────────┐
    │CustomerID(PK)│◄──────│ OrderID (PK)    │
    │ Name         │     ┌─│ CustomerID (FK) │
    │ Email        │     │ │ OrderDate       │
    └──────────────┘     │ │ TotalAmount     │
                         │ └─────────────────┘
                         │ └─────────────────┐
                         │ │ OrderID (PK)    │
                         └─│ CustomerID (FK) │
                           │ OrderDate       │
                           │ TotalAmount     │
                           └─────────────────┘
    ONE customer ────────→ MANY orders

KEY THINGS TO REMEMBER:
    → MOST COMMON relationship type (90% of cases)
    → Foreign key ALWAYS goes on the "many" side
    → The "many" side references the "one" side
    → Think: "many orders BELONG TO one customer"
    → Parent table = "one" side, Child table = "many" side
*/

-- Example 1: Customers and Orders
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,  -- FK on "many" side
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    Status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE RESTRICT  -- Prevent deleting customer with orders
        ON UPDATE CASCADE
);

-- Sample Data
INSERT INTO Customers (FirstName, LastName, Email, PhoneNumber) VALUES 
    ('Alice', 'Johnson', 'alice@example.com', '555-0201'),
    ('Bob', 'Williams', 'bob@example.com', '555-0202');

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, Status) VALUES 
    (1, '2025-01-15', 299.99, 'Delivered'),
    (1, '2025-02-20', 149.50, 'Shipped'),      -- Same customer, multiple orders
    (1, '2025-03-10', 89.99, 'Pending'),       -- Same customer, multiple orders
    (2, '2025-02-05', 599.99, 'Delivered');


-- Example 2: Departments and Employees
DROP TABLE IF EXISTS Employees2;
DROP TABLE IF EXISTS Departments;

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(100)
);

CREATE TABLE Employees2 (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,  -- FK on "many" side
    Salary DECIMAL(10, 2),
    HireDate DATE,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Sample Data
INSERT INTO Departments (DepartmentName, Location) VALUES 
    ('Engineering', 'Building A'),
    ('Marketing', 'Building B'),
    ('Sales', 'Building C');

INSERT INTO Employees2 (FirstName, LastName, DepartmentID, Salary, HireDate) VALUES 
    ('John', 'Smith', 1, 85000, '2023-01-15'),
    ('Sarah', 'Connor', 1, 90000, '2023-03-20'),    -- Same dept, multiple employees
    ('Mike', 'Davis', 1, 78000, '2024-01-10'),      -- Same dept, multiple employees
    ('Emily', 'Brown', 2, 72000, '2023-06-01'),
    ('David', 'Wilson', 3, 68000, '2024-02-15');


-- Example 3: Blog Posts and Comments
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Posts;

CREATE TABLE Posts (
    PostID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(200) NOT NULL,
    Content TEXT NOT NULL,
    AuthorName VARCHAR(100),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Comments (
    CommentID INT PRIMARY KEY AUTO_INCREMENT,
    PostID INT NOT NULL,  -- FK on "many" side
    CommenterName VARCHAR(100) NOT NULL,
    CommentText TEXT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID)
        ON DELETE CASCADE  -- Delete comments when post is deleted
);


-- ============================================================================
-- 4. MANY-TO-MANY (M:N) RELATIONSHIPS
-- ============================================================================
/*
DESCRIPTION:
    Many records in Table A relate to many records in Table B
    
STRUCTURE:
    REQUIRES a junction/bridge/associative table with two foreign keys
    
WHEN TO USE:
    When BOTH sides can have multiple relationships with the other
    
REAL-WORLD EXAMPLES:
    ✓ Students ↔ Classes (students take many classes, classes have many students)
    ✓ Products ↔ Orders (products in many orders, orders have many products)
    ✓ Authors ↔ Books (books can have multiple authors - co-authoring)
    ✓ Actors ↔ Movies (actors in many movies, movies have many actors)
    ✓ Tags ↔ Articles (articles have many tags, tags on many articles)

VISUAL DIAGRAM:
    Students            StudentsToClasses          Classes
    ┌──────────┐       ┌──────────────────┐       ┌─────────────┐
    │StudentID │◄──────│StudentID (FK)(PK)│       │ ClassID (PK)│
    │Name      │       │ClassID (FK) (PK) │──────►│ ClassName   │
    │Email     │       │EnrollmentDate    │       │ Schedule    │
    └──────────┘       │Grade             │       │ Credits     │
                       └──────────────────┘       └─────────────┘
                       Junction/Bridge Table
    
    MANY students ←→ Junction Table ←→ MANY classes

KEY THINGS TO REMEMBER:
    → ALWAYS requires a junction/bridge/associative table
    → Junction table has 2+ foreign keys (one for each entity)
    → Primary key is usually composite (both FKs together)
    → Can add extra attributes (enrollment date, quantity, price, etc.)
    → Breaks M:N into two 1:N relationships
    → Most flexible relationship type
*/

-- Example 1: Students and Classes (Classic M:N)
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Classes;
DROP TABLE IF EXISTS Students;

CREATE TABLE Students (
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    EnrollmentYear INT
);

CREATE TABLE Classes (
    ClassID INT PRIMARY KEY AUTO_INCREMENT,
    ClassName VARCHAR(100) NOT NULL,
    ClassCode VARCHAR(20) NOT NULL UNIQUE,
    Credits INT NOT NULL,
    Schedule VARCHAR(50)
);

-- Junction/Bridge Table
CREATE TABLE Enrollments (
    StudentID INT NOT NULL,
    ClassID INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    Grade CHAR(2),
    Semester VARCHAR(20),
    PRIMARY KEY (StudentID, ClassID),  -- Composite PK prevents duplicates
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ClassID) REFERENCES Classes(ClassID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Sample Data
INSERT INTO Students (FirstName, LastName, Email, EnrollmentYear) VALUES 
    ('Emma', 'Thompson', 'emma@university.edu', 2025),
    ('Liam', 'Garcia', 'liam@university.edu', 2025),
    ('Fatou', 'Diallo', 'olivia@university.edu', 2024);

INSERT INTO Classes (ClassName, ClassCode, Credits, Schedule) VALUES 
    ('Database Systems', 'CS301', 3, 'MWF 10:00-11:00'),
    ('Web Development', 'CS205', 3, 'TTh 14:00-15:30'),
    ('Data Structures', 'CS202', 4, 'MWF 09:00-10:00'),
    ('Computer Networks', 'CS401', 3, 'TTh 10:00-11:30');

-- Enrollments: Students taking multiple classes
INSERT INTO Enrollments (StudentID, ClassID, EnrollmentDate, Semester) VALUES 
    (1, 1, '2025-01-15', 'Spring 2025'),  -- Emma in Database Systems
    (1, 2, '2025-01-15', 'Spring 2025'),  -- Emma in Web Development
    (1, 3, '2025-01-15', 'Spring 2025'),  -- Emma in Data Structures (3 classes!)
    (2, 1, '2025-01-16', 'Spring 2025'),  -- Liam in Database Systems
    (2, 4, '2025-01-16', 'Spring 2025'),  -- Liam in Computer Networks
    (3, 2, '2025-01-17', 'Spring 2025'),  -- Fatou in Web Development
    (3, 3, '2025-01-17', 'Spring 2025');  -- Fatou in Data Structures

-- Query: Which students are in Database Systems (CS301)?
SELECT s.FirstName, s.LastName, c.ClassName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Classes c ON e.ClassID = c.ClassID
WHERE c.ClassCode = 'CS301';

-- Query: What classes is Emma taking?
SELECT s.FirstName, s.LastName, c.ClassName, c.Credits
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Classes c ON e.ClassID = c.ClassID
WHERE s.FirstName = 'Emma';


-- Example 2: Products and Orders (M:N with additional data)
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Orders2;

CREATE TABLE Orders2 (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    OrderDate DATE NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    TotalAmount DECIMAL(10, 2)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT DEFAULT 0
);

-- Junction Table with additional columns
CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10, 2) NOT NULL,  -- Price at time of order
    Subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (Quantity * UnitPrice) STORED,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders2(OrderID)
        ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
        ON DELETE RESTRICT  -- Don't delete products that are in orders
);

-- Sample Data
INSERT INTO Products (ProductName, Description, Price, StockQuantity) VALUES 
    ('Laptop', '15-inch, 16GB RAM', 999.99, 50),
    ('Mouse', 'Wireless optical mouse', 29.99, 200),
    ('Keyboard', 'Mechanical keyboard', 89.99, 150),
    ('Monitor', '27-inch 4K display', 449.99, 75);

INSERT INTO Orders2 (OrderDate, CustomerName, TotalAmount) VALUES 
    ('2025-03-01', 'Alice Johnson', 1119.97),
    ('2025-03-02', 'Bob Smith', 569.97);

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES 
    (1, 1, 1, 999.99),  -- Order 1: 1 Laptop
    (1, 2, 2, 29.99),   -- Order 1: 2 Mice
    (1, 3, 1, 89.99),   -- Order 1: 1 Keyboard (multiple products in one order!)
    (2, 1, 1, 999.99),  -- Order 2: 1 Laptop (same product in multiple orders!)
    (2, 4, 1, 449.99);  -- Order 2: 1 Monitor


-- Example 3: Authors and Books (Co-authoring scenario)
DROP TABLE IF EXISTS BookAuthors;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;

CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Biography TEXT
);

CREATE TABLE Books (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(200) NOT NULL,
    ISBN VARCHAR(13) UNIQUE,
    PublicationYear INT,
    Genre VARCHAR(50)
);

-- Junction Table
CREATE TABLE BookAuthors (
    BookID INT NOT NULL,
    AuthorID INT NOT NULL,
    AuthorOrder INT,  -- For listing authors in correct order
    ContributionType ENUM('Primary', 'Co-author', 'Editor') DEFAULT 'Primary',
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
        ON DELETE CASCADE,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
        ON DELETE CASCADE
);

-- Sample Data
INSERT INTO Authors (FirstName, LastName, Biography) VALUES 
    ('Stephen', 'King', 'Master of horror fiction'),
    ('Peter', 'Straub', 'American novelist and poet'),
    ('J.K.', 'Rowling', 'British author');

INSERT INTO Books (Title, ISBN, PublicationYear, Genre) VALUES 
    ('The Talisman', '9780345444882', 1984, 'Fantasy'),
    ('Black House', '9780375507960', 2001, 'Horror'),
    ('Harry Potter and the Sorcerer\'s Stone', '9780439708180', 1997, 'Fantasy');

INSERT INTO BookAuthors (BookID, AuthorID, AuthorOrder, ContributionType) VALUES 
    (1, 1, 1, 'Co-author'),    -- The Talisman by King & Straub
    (1, 2, 2, 'Co-author'),    -- Co-authored book!
    (2, 1, 1, 'Co-author'),    -- Black House by King & Straub
    (2, 2, 2, 'Co-author'),    -- Another co-authored book!
    (3, 3, 1, 'Primary');      -- Harry Potter by Rowling (single author)


-- ============================================================================
-- 5. REFERENTIAL INTEGRITY ACTIONS
-- ============================================================================
/*
When defining foreign keys, you can specify what happens on UPDATE/DELETE:

┌──────────────┬─────────────────────────────────────────────────────────┐
│   Action     │  Description                                            │
├──────────────┼─────────────────────────────────────────────────────────┤
│  CASCADE     │  Automatically update/delete related rows               │
│  RESTRICT    │  Prevent operation if related rows exist (default)      │
│  SET NULL    │  Set foreign key to NULL (column must allow NULL)       │
│  NO ACTION   │  Same as RESTRICT (checked at end of statement)         │
│  SET DEFAULT │  Set to default value (not supported in MySQL/InnoDB)   │
└──────────────┴─────────────────────────────────────────────────────────┘

WHEN TO USE EACH:
    CASCADE     → When child records have no meaning without parent
                  Example: Delete order → delete order items
    
    RESTRICT    → When parent shouldn't be deleted if children exist
                  Example: Prevent deleting customer with active orders
    
    SET NULL    → When you want to keep orphaned records
                  Example: Delete department → employees.DepartmentID = NULL
*/

-- Example: Different referential actions
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders3;
DROP TABLE IF EXISTS Customers2;

CREATE TABLE Customers2 (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100)
);

CREATE TABLE Orders3 (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers2(CustomerID)
        ON DELETE RESTRICT      -- Can't delete customer with orders
        ON UPDATE CASCADE       -- Update cascades to orders
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductName VARCHAR(100),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders3(OrderID)
        ON DELETE CASCADE       -- Delete details when order deleted
        ON UPDATE CASCADE
);


-- ============================================================================
-- 6. BEST PRACTICES & TIPS
-- ============================================================================
/*
NAMING CONVENTIONS:
    ✓ Use singular nouns for table names (User, not Users)
    ✓ Primary keys: TableNameID (e.g., CustomerID, OrderID)
    ✓ Foreign keys: Same name as referenced PK
    ✓ Junction tables: Table1Table2 or Table1_Table2 (e.g., StudentsClasses)

INDEXING:
    ✓ Primary keys are automatically indexed
    ✓ Foreign keys should be indexed for performance
    ✓ Composite keys in junction tables are automatically indexed

DESIGN PRINCIPLES:
    ✓ Start with One-to-Many (1:N) - it's the most common
    ✓ Only use Many-to-Many (M:N) when BOTH sides need multiple relationships
    ✓ Avoid One-to-One (1:1) unless there's a compelling reason
    ✓ Keep junction tables simple - add only necessary columns
    ✓ Use CASCADE carefully - it can delete a lot of data!

COMMON MISTAKES TO AVOID:
    ✗ Putting foreign key on wrong side in 1:N relationships
    ✗ Forgetting UNIQUE constraint in 1:1 relationships
    ✗ Not using junction table for M:N relationships
    ✗ Circular references without proper handling
    ✗ Not indexing foreign key columns

TESTING YOUR DESIGN:
    1. Can you insert all necessary data?
    2. Can you query efficiently (check EXPLAIN)?
    3. Do constraints prevent invalid data?
    4. What happens when you delete/update?
    5. Are there orphaned records?
*/


-- ============================================================================
-- EXAM TIPS & QUICK REFERENCE
-- ============================================================================
/*
FOR MULTIPLE CHOICE QUESTIONS:

Q: "How to implement relationship between Students and Classes?"
A: Look for junction/bridge table with TWO foreign keys → Many-to-Many

Q: "Where does foreign key go in One-to-Many?"
A: ALWAYS on the "many" side (Orders table, not Customers table)

Q: "How to enforce One-to-One relationship?"
A: Add UNIQUE constraint to the foreign key column

Q: "What constraint enforces referential integrity?"
A: FOREIGN KEY constraint (not unique, not null, not primary key)

Q: "Options for ON DELETE action?"
A: CASCADE, RESTRICT, SET NULL are all valid

MEMORIZATION TRICKS:
    → "MANY orders belong to ONE customer" → FK in Orders table
    → "Students ENROLL IN Classes" → need Enrollments junction table
    → "One person, one passport" → UNIQUE foreign key
    → "CASCADE = waterfall" → changes flow down to child records
    → "RESTRICT = roadblock" → stops the operation

VISUAL MEMORY:
    1:N  =  Tree structure (one trunk, many branches)
    M:N  =  Network/mesh (everything connects to everything)
    1:1  =  Mirror image (one-to-one correspondence)
*/


-- ============================================================================
-- END OF CHEAT SHEET
-- ============================================================================
-- Good luck with your exam and database design projects!
-- Remember: When in doubt, it's probably One-to-Many 😄 
-- ============================================================================