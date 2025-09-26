/* Section 2: More SQl Skills as you need them ~ Murach's MySQL book 3rd edition
Chap 7: How to code subqueries
Houlaymatou B. | code-techhb | Fall '25
*/

SELECT category_name
FROM categories
WHERE category_id IN (
    SELECT category_id
    FROM products
)
ORDER BY category_name; 


SELECT product_name, list_price
FROM products
WHERE list_price > (
    SELECT AVG(list_price)
    FROM products
)
ORDER BY list_price DESC;


SELECT category_name
FROM categories c
WHERE NOT EXISTS (
    SELECT *
    FROM products p
    WHERE p.category_id = c.category_id
);


SELECT email_address, MAX(order_total) AS largest_order
FROM (
    SELECT c.email_address, oi.order_id, 
           SUM(oi.item_price * oi.quantity) AS order_total
    FROM customers c
      JOIN orders o ON c.customer_id = o.customer_id
      JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.email_address, oi.order_id
) AS order_totals
GROUP BY email_address
ORDER BY largest_order DESC;


SELECT product_name, discount_percent
FROM products p1
WHERE discount_percent NOT IN (
    SELECT discount_percent
    FROM products p2
    WHERE p2.product_id != p1.product_id
)
ORDER BY product_name;


SELECT c.email_address, o.order_id, o.order_date
FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date = (
    SELECT MIN(o2.order_date)
    FROM orders o2
    WHERE o2.customer_id = c.customer_id
)
ORDER BY o.order_date, o.order_id;