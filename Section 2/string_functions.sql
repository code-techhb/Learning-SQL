/* Section 2: More SQl Skills as you need them ~ Murach's MySQL book 3rd edition
Chap 9: How to use functions
Houlaymatou B. | code-techhb | Fall '25
*/

--  Working with ROUND and TRUNCATE functions
SELECT invoice_total,
    ROUND(invoice_total, 1) AS rounded_1_decimal,
    ROUND(invoice_total, 0) AS rounded_no_decimal,
    TRUNCATE(invoice_total, 0) AS truncated_no_decimal
FROM invoices;


-- Working with DATE_FORMAT function 
SELECT start_date,
    DATE_FORMAT(start_date, '%b/%d/%y') AS format1,
    DATE_FORMAT(start_date, '%c/%e/%y') AS format2, 
    DATE_FORMAT(start_date, '%l:%i %p') AS twelve_hour,
    DATE_FORMAT(start_date, '%c/%e/%y %l:%i %p') AS format3 
FROM date_sample;


--   Working with String Functions 
SELECT vendor_name,
    UPPER(vendor_name) AS vendor_name_upper,
    vendor_phone,
    RIGHT(vendor_phone, 4) AS last_four_digits
FROM vendors;

SELECT 
    vendor_name,
    UPPER(vendor_name) AS vendor_name_upper,
    vendor_phone,
    RIGHT(vendor_phone, 4) AS last_four_digits,
    CONCAT(
        SUBSTRING(vendor_phone, 2, 3), '.',
        SUBSTRING(vendor_phone, 7, 3), '.',
        SUBSTRING(vendor_phone, 11, 4)
    ) AS phone_with_dots,
    CASE 
        WHEN LENGTH(vendor_name) - LENGTH(REPLACE(vendor_name, ' ', '')) >= 1
        THEN SUBSTRING_INDEX(SUBSTRING_INDEX(vendor_name, ' ', 2), ' ', -1)
        ELSE ''
    END AS second_word
FROM vendors;


-- Working with Date Functions 
SELECT invoice_number,
    invoice_date,
    DATE_ADD(invoice_date, INTERVAL 30 DAY) AS date_plus_30,
    payment_date,
    DATEDIFF(payment_date, invoice_date) AS days_to_pay,
    MONTH(invoice_date) AS invoice_month,
    YEAR(invoice_date) AS invoice_year
FROM invoices
WHERE MONTH(invoice_date) = 5;


--  Regular Expressions
SELECT emp_name,
    REGEXP_SUBSTR(emp_name, '^[^ ]+') AS first_name,
    REGEXP_REPLACE(emp_name, '^[^ ]+ ', '') AS last_name
FROM string_sample;


-- RANK() Function 
SELECT invoice_number, invoice_total - payment_total - credit_total AS balance_due,
    RANK() OVER (ORDER BY invoice_total - payment_total - credit_total DESC) AS balance_rank
FROM invoices
WHERE invoice_total - payment_total - credit_total > 0;