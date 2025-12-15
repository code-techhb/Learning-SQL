/*
 * Library Database - User Roles and Permissions Setup
 * 
 * Defines four user roles with appropriate access levels:
 * - library_admin: Full database access
 * - librarian: CRUD operations on books, members, borrowing, and fines
 * - library_staff: Limited access for processing borrowings
 * - library_member: Read-only access to book catalog
 */

CREATE USER IF NOT EXISTS 'librarian'@'localhost' IDENTIFIED BY '<CHANGE_THIS_PASSWORD>';
CREATE USER IF NOT EXISTS 'library_staff'@'localhost' IDENTIFIED BY '<CHANGE_THIS_PASSWORD>';
CREATE USER IF NOT EXISTS 'library_member'@'localhost' IDENTIFIED BY '<CHANGE_THIS_PASSWORD>';
CREATE USER IF NOT EXISTS 'library_admin'@'localhost' IDENTIFIED BY '<CHANGE_THIS_PASSWORD>';



GRANT ALL PRIVILEGES ON librarydb.* TO 'library_admin'@'localhost';

-- Librarian: Full CRUD on operational tables
GRANT SELECT, INSERT, UPDATE, DELETE ON librarydb.books TO 'librarian'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON librarydb.members TO 'librarian'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON librarydb.borrowing TO 'librarian'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON librarydb.fines TO 'librarian'@'localhost';
GRANT SELECT ON librarydb.category TO 'librarian'@'localhost';
GRANT SELECT ON librarydb.publishers TO 'librarian'@'localhost';
GRANT SELECT ON librarydb.author TO 'librarian'@'localhost';
GRANT SELECT ON librarydb.staff TO 'librarian'@'localhost';

-- Staff: Limited access (can view and process borrowings)
GRANT SELECT ON librarydb.books TO 'library_staff'@'localhost';
GRANT SELECT ON librarydb.members TO 'library_staff'@'localhost';
GRANT SELECT, INSERT, UPDATE ON librarydb.borrowing TO 'library_staff'@'localhost';
GRANT SELECT ON librarydb.category TO 'library_staff'@'localhost';

-- Member: Read-only access to book catalog
GRANT SELECT ON librarydb.books TO 'library_member'@'localhost';
GRANT SELECT ON librarydb.category TO 'library_member'@'localhost';
GRANT SELECT ON librarydb.author TO 'library_member'@'localhost';
GRANT SELECT ON librarydb.publishers TO 'library_member'@'localhost';

FLUSH PRIVILEGES;


REVOKE DELETE ON librarydb.members FROM 'librarian'@'localhost';
FLUSH PRIVILEGES;

-- Check: Show granted privileges 
SHOW GRANTS FOR 'librarian'@'localhost';
SHOW GRANTS FOR 'library_staff'@'localhost';
SHOW GRANTS FOR 'library_member'@'localhost';
SHOW GRANTS FOR 'library_admin'@'localhost';