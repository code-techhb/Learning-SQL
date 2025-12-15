/* Section 3: Database design and implementation ~ Murach's MySQL book 3rd edition
Chap 12: How to work with views
Houlaymatou B. | code-techhb | Fall '25
*/

-- creating Views 
CREATE OR REPLACE VIEW customer_addresses AS
SELECT 
    c.customer_id,
    c.email_address,
    c.last_name,
    c.first_name,
    
    ba.line1 AS bill_line1,
    ba.line2 AS bill_line2,
    ba.city AS bill_city,
    ba.state AS bill_state,
    ba.zip_code AS bill_zip,
    
    sa.line1 AS ship_line1,
    sa.line2 AS ship_line2,
    sa.city AS ship_city,
    sa.state AS ship_state,
    sa.zip_code AS ship_zip

FROM Customers c
    LEFT JOIN Addresses ba ON c.billing_address_id = ba.address_id
    LEFT JOIN Addresses sa ON c.shipping_address_id = sa.address_id;
    
SELECT * FROM customer_addresses;

-- selecting from views  
SELECT 
    customer_id,
    last_name,
    first_name,
    bill_line1
FROM customer_addresses
ORDER BY last_name, first_name;



-- updating base table from views
UPDATE Addresses
SET line1 = '1990 Westwood Blvd.'
WHERE address_id = (
    SELECT shipping_address_id
    FROM Customers
    WHERE customer_id = 8
);
SELECT * FROM customer_addresses;


CREATE OR REPLACE VIEW order_item_products AS
SELECT
    o.order_id,
    o.order_date,
    o.tax_amount,
    o.ship_date,

    p.product_name,
    
    oi.item_price,
    oi.discount_amount,
    
    (oi.item_price - oi.discount_amount) AS final_price,
    oi.quantity,
    ((oi.item_price - oi.discount_amount) * oi.quantity) AS item_total
    
FROM Orders o
    INNER JOIN Order_Items oi ON o.order_id = oi.order_id
    INNER JOIN Products p ON oi.product_id = p.product_id;
Select * from order_item_products;

-- summary from views 
CREATE OR REPLACE VIEW product_summary AS
SELECT
    p.product_name,
    COUNT(oip.order_id) AS order_count,
    SUM(oip.item_total) AS order_total
FROM Products p
    LEFT JOIN order_item_products oip ON p.product_name = oip.product_name
GROUP BY p.product_name;
Select * from product_summary;

SELECT 
    product_name,
    order_count,
    order_total
FROM product_summary
ORDER BY order_total DESC
LIMIT 5; 

