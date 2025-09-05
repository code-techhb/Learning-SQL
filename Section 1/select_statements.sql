/* Section 1: Intro to SQL ~ Murach's MySQL book 3rd edition
Chap 2: How to Retrieve Data from a Single Table
Houlaymatou B. | code-techhb | Fall '25
*/

-- Writing Select statements
SELECT vendor_name, vendor_contact_last_name , vendor_contact_first_name 
From vendors
ORDER BY 2 ASC;

SELECT CONCAT(vendor_contact_last_name, ', ', vendor_contact_first_name) AS full_name 
FROM vendors
WHERE vendor_contact_last_name REGEXP "^[A-CE]"
ORDER BY vendor_contact_last_name, vendor_contact_first_name;

SELECT invoice_due_date AS "Due Date", 
       invoice_total AS "Invoice Total", 
       invoice_total / 10 AS "10%",
       invoice_total * 1.1 AS "Plus 10%"
FROM Invoices
WHERE invoice_total>=500 AND invoice_total<=1000
ORDER BY invoice_due_date DESC;

SELECT  invoice_number,
		invoice_total, 
		payment_total + credit_total AS payment_credit_total, 
		invoice_total - payment_total - credit_total AS balance_due
FROM invoices
WHERE (invoice_total - payment_total - credit_total)>50
ORDER BY balance_due DESC
LIMIT 5;

-- Working Null and test expression
SELECT  invoice_number,
		invoice_date, 
		invoice_total - payment_total - credit_total AS balance_due,
        payment_date
FROM invoices
WHERE payment_date is NULL;

SELECT date_format(CURRENT_DATE, "%m-%d-%y") AS "current_date";

SELECT 55000 AS starting_principal,
	   55000 * 4.5 AS bonus,
       55000 + (55000 * 4.5) as principal_plus_bonus;