/* Section 2: More SQl Skills as you need them ~ Murach's MySQL book 3rd edition
Chap 6: How to code summary queries
Houlaymatou B. | code-techhb | Fall '25
*/

-- Aggregate Functions
 
SELECT vendor_id, SUM(invoice_total) AS invoice_total_sum
FROM invoices
GROUP BY vendor_id;

SELECT v.vendor_name, SUM(i.payment_total) AS total_payments
FROM Vendors v
JOIN Invoices i ON v.vendor_id = i.vendor_id
GROUP BY v.vendor_name
ORDER BY total_payments DESC;

SELECT v.vendor_name, COUNT(i.invoice_id) AS invoice_count, SUM(i.invoice_total) AS total_invoice_amount
FROM Vendors v
JOIN Invoices i ON v.vendor_id = i.vendor_id
GROUP BY v.vendor_name
ORDER BY invoice_count DESC;

SELECT gla.account_description, COUNT(ili.account_number) AS line_item_count,
    SUM(line_item_amount) AS line_item_amount_sum
FROM General_Ledger_Accounts gla
JOIN Invoice_Line_Items ili ON gla.account_number = ili.account_number
GROUP BY gla.account_description
HAVING line_item_count > 1
ORDER BY line_item_amount_sum DESC;

SELECT gla.account_description, COUNT(ili.account_number) AS line_item_count,
    SUM(ili.line_item_amount) AS line_item_amount_sum
FROM General_Ledger_Accounts gla
JOIN Invoice_Line_Items ili ON gla.account_number = ili.account_number
JOIN Invoices i ON ili.invoice_id = i.invoice_id
WHERE i.invoice_date BETWEEN '2018-04-01' AND '2018-06-30'
GROUP BY gla.account_description
HAVING line_item_count > 1
ORDER BY line_item_amount_sum DESC;

SELECT ili.account_number, SUM(ili.line_item_amount) AS total_amount
FROM Invoice_Line_Items ili
GROUP BY ili.account_number WITH ROLLUP;

SELECT IF(GROUPING(i.terms_id) = 1, 'Grand totals', i.terms_id) AS terms_id,
    IF(GROUPING(i.vendor_id)=1, 'Terms id totals', i.vendor_id) AS vendor_id,
    MAX(i.payment_date) AS max_payment_date,
    SUM(i.invoice_total - i.payment_total - i.credit_total) AS balance_due_sum
FROM Invoices i
GROUP BY i.terms_id, i.vendor_id WITH ROLLUP;

SELECT vendor_id, (invoice_total - payment_total - credit_total) AS balance_due,
    SUM(invoice_total - payment_total - credit_total) 
        OVER () AS total_due,
    SUM(invoice_total - payment_total - credit_total) OVER(PARTITION BY vendor_id
           ORDER BY invoice_total - payment_total - credit_total) AS vendor_due
FROM Invoices
WHERE (invoice_total - payment_total - credit_total) > 0
ORDER BY balance_due;


SELECT vendor_id,
    (invoice_total - payment_total - credit_total) AS balance_due,
    SUM(invoice_total - payment_total - credit_total) OVER() AS total_due,
    SUM(invoice_total - payment_total - credit_total) OVER vendor_window AS vendor_due,
	ROUND(AVG(invoice_total - payment_total - credit_total) OVER vendor_window, 2) AS vendor_avg
FROM Invoices
WHERE (invoice_total - payment_total - credit_total) > 0
WINDOW vendor_window AS (PARTITION BY vendor_id)
ORDER BY balance_due;

SELECT MONTH(invoice_date) AS month,
    SUM(invoice_total) AS monthly_invoice_total,
    ROUND(AVG(SUM(invoice_total)) 
        OVER (ORDER BY MONTH(invoice_date) 
              RANGE BETWEEN 3 PRECEDING AND CURRENT ROW), 2) AS moving_average_4_months
FROM Invoices
GROUP BY MONTH(invoice_date)
ORDER BY MONTH(invoice_date);