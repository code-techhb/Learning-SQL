/*
 * Library Database - Sample Queries and Operations
 * 
 * Contains example SQL operations for common library management tasks:
 * 
 * BORROWING OPERATIONS:
 * - Borrowing, returning, and renewing books
 * - Automatic copy count updates
 * - Fine calculation for overdue items
 * 
 * REPORTING QUERIES:
 * - Overdue and borrowed books tracking
 * - Member borrowing history
 * - Fine collection reports
 * - Inventory management by category
 * - Popular books and authors analytics
 * - Monthly borrowing statistics
 */

-- ----------------------------------------------------------------------------
-- Borrowing Ops
-- ----------------------------------------------------------------------------
-- 1- Borrowing a book
INSERT INTO borrowing (book_id, member_id, staff_id, borrow_date, due_date, status)
VALUES (1, 1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Borrowed');
-- Decrease available copies
UPDATE books
SET copies_available = copies_available - 1
WHERE book_id = 1;

-- 2- Return a Book
UPDATE borrowing
SET return_date = CURDATE(),
    status = 'Returned'
WHERE borrowing_id = 1;
-- increase available copies
UPDATE books
SET copies_available = copies_available + 1
WHERE book_id = 1; 


-- 3- renew a Book
UPDATE borrowing
SET due_date = DATE_ADD(due_date, INTERVAL 14 DAY)
WHERE borrowing_id = 1
  AND status = 'Borrowed';


-- 4- calculate fine at $1.50 per day overdue
INSERT INTO fines (borrowing_id, fine_amount, fine_date, payment_status)
SELECT borrowing_id, DATEDIFF(CURDATE(), due_date) * 1.50 AS fine_amount, CURDATE(), 'Unpaid'
FROM borrowing
WHERE status = 'Overdue'
  AND return_date IS NULL
  AND borrowing_id NOT IN (SELECT borrowing_id FROM fines);


-- ----------------------------------------------------------------------------
-- Selection Ops
-- ----------------------------------------------------------------------------
-- 1- Overdue Books
SELECT b.title, concat(first_name, " ", m.last_name) as member_name, bor.due_date
FROM borrowing bor JOIN books b ON b.book_id = bor.book_id JOIN members m ON m.member_id = bor.member_id
WHERE bor.status = 'Overdue';


-- 2- Borrowed Books 
SELECT b.title, CONCAT(m.first_name, ' ', m.last_name) AS borrower_name, m.email AS borrower_email, bor.borrow_date, bor.due_date, 
CONCAT(s.first_name, ' ', s.last_name) AS processed_by_staff, s.position AS staff_position
FROM borrowing bor JOIN books b ON bor.book_id = b.book_id JOIN members m ON bor.member_id = m.member_id JOIN staff s ON bor.staff_id = s.staff_id
WHERE bor.status = 'Borrowed' ORDER BY bor.due_date;


-- 3- Member borrowing History
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, m.email, b.title, bor.borrow_date, bor.due_date, bor.return_date, bor.status,
   CASE 
        WHEN bor.return_date IS NOT NULL THEN DATEDIFF(DATE(bor.return_date), DATE(bor.borrow_date))
        ELSE DATEDIFF(CURDATE(), DATE(bor.borrow_date))
    END AS days_borrowed
FROM members m JOIN borrowing bor ON m.member_id = bor.member_id JOIN books b ON bor.book_id = b.book_id
ORDER BY m.last_name, m.first_name, bor.borrow_date DESC;


-- 4- Get history for a specific member
SELECT b.title, bor.borrow_date, bor.due_date, bor.return_date, bor.status
FROM borrowing bor
JOIN books b ON bor.book_id = b.book_id
WHERE bor.member_id = 6
ORDER BY bor.borrow_date DESC;


-- 5- Fines
SELECT f.fine_id, CONCAT(m.first_name, ' ', m.last_name) as member_name, f.fine_amount, f.payment_status
FROM fines f JOIN borrowing bor ON bor.borrowing_id = f.borrowing_id
JOIN members m ON m.member_id = bor.member_id;


-- 6 Fine Collection Report 
SELECT payment_status, COUNT(*) AS fine_count, SUM(fine_amount) AS total_amount, ROUND(AVG(fine_amount), 2) AS average_fine
FROM fines 
GROUP BY payment_status
ORDER BY payment_status;


-- 7- Inventory By Category
SELECT  c.category_name, b.title, b.isbn, b.publication_year, b.copies_available
FROM books b JOIN category c ON b.category_id = c.category_id
ORDER BY c.category_name, b.title; 


-- 8- Inventory by Category with available copies count
SELECT c.category_name, COUNT(*) AS total_books, SUM(b.copies_total) AS total_copies, SUM(b.copies_available) AS available_copies
FROM books b JOIN category c ON b.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_books DESC;


-- 9- Full list of all books
SELECT b.book_id, b.title, b.isbn, c.category_name, p.publisher_name, b.publication_year, b.copies_total, b.copies_available, b.shelf_location
FROM books b LEFT JOIN category c ON b.category_id = c.category_id LEFT JOIN publishers p ON b.publisher_id = p.publisher_id ORDER BY b.title;


-- 10- list of books by author name 
SELECT CONCAT(a.first_name, ' ', a.last_name) AS author_name, a.country, b.title, b.isbn, b.publication_year
FROM author a JOIN book_authors ba ON a.author_id = ba.author_id JOIN books b ON ba.book_id = b.book_id
ORDER BY author_name, b.title;


-- 11- list all members
SELECT member_id, CONCAT(first_name, ' ', last_name) AS member_name, email, phone, membership_date, membership_status
FROM members
ORDER BY last_name, first_name; 


-- 12- list all staff
SELECT  staff_id, CONCAT(first_name, ' ', last_name) AS staff_name, position, email, hire_date, status
FROM staff
ORDER BY last_name, first_name; 


-- 13-  Most Popular Books (Top 15)
SELECT b.book_id, b.title, b.isbn, c.category_name, COUNT(bor.borrowing_id) AS times_borrowed, b.copies_total, b.copies_available
FROM books b LEFT JOIN borrowing bor ON b.book_id = bor.book_id LEFT JOIN category c ON b.category_id = c.category_id
GROUP BY b.book_id, b.title, b.isbn, c.category_name, b.copies_total, b.copies_available
ORDER BY times_borrowed DESC
LIMIT 15;


-- 14- Most Popular Authors
SELECT a.author_id, CONCAT(a.first_name, ' ', a.last_name) AS author_name, a.country, COUNT(DISTINCT ba.book_id) AS books_in_library, COUNT(bor.borrowing_id) AS total_borrows
FROM author a JOIN book_authors ba ON a.author_id = ba.author_id LEFT JOIN borrowing bor ON ba.book_id = bor.book_id
GROUP BY a.author_id, a.first_name, a.last_name, a.country
ORDER BY total_borrows DESC
LIMIT 15;


-- 15- Monthly Borrowing Statistics 
SELECT YEAR(borrow_date) AS year, MONTH(borrow_date) AS month, MONTHNAME(borrow_date) AS month_name, COUNT(*) AS total_borrowings, COUNT(DISTINCT member_id) AS unique_borrowers
FROM borrowing
GROUP BY YEAR(borrow_date), MONTH(borrow_date), MONTHNAME(borrow_date)
ORDER BY year DESC, month DESC;