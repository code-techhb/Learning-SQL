/* Section 1: Intro to SQL ~ Murach's MySQL book 3rd edition
Chap 4: How to Retrieve Data from two or more tables
Houlaymatou B. | code-techhb | Fall '25
*/

-- INNER JOIN
SELECT * 
FROM vendors 
INNER JOIN invoices ON  vendors.vendor_id = invoices.vendor_id;


SELECT vendor_name, invoice_number, invoice_date,
	   invoice_total - payment_total - credit_total AS balance_due
FROM vendors v JOIN invoices i 
	 ON v.vendor_id = i.vendor_id
WHERE invoice_total - payment_total - credit_total <> 0
ORDER BY vendor_name;


SELECT vendor_name, default_account_number AS default_account, account_description AS description
FROM vendors v JOIN general_ledger_accounts gla
	 ON v.default_account_number = gla.account_number
ORDER BY description, vendor_name;


SELECT vendor_name, invoice_date, invoice_number, invoice_sequence AS li_sequence,
       line_item_amount AS li_amount
FROM vendors v JOIN invoices i
		ON v.vendor_id = i.vendor_id
	JOIN invoice_line_items ili
		ON i.invoice_id = ili.invoice_id
ORDER BY v.vendor_name, invoice_date, invoice_number, invoice_sequence;


-- SELF & OUTER JOIN
SELECT t1.vendor_id, 
       t1.vendor_name,
       CONCAT(t1.vendor_contact_first_name, ' ', t1.vendor_contact_last_name) AS contact_name
FROM vendors t1 JOIN vendors t2
    ON t1.vendor_id <> t2.vendor_id AND
       t1.vendor_contact_last_name = t2.vendor_contact_last_name  
ORDER BY t1.vendor_contact_last_name;


SELECT gla.account_number, account_description, invoice_id
FROM general_ledger_accounts gla 
LEFT JOIN invoice_line_items as ili
	ON gla.account_number = ili.account_number
WHERE invoice_id IS NULL
ORDER BY gla.account_number;


-- UNION
SELECT vendor_name, vendor_state
	FROM vendors
	WHERE vendor_state = "CA" 
UNION 
  SELECT vendor_name, 'Outside CA'
  FROM vendors
  WHERE vendor_state <> 'CA'
ORDER BY vendor_name;

