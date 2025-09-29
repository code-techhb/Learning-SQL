/* Section 2: More SQl Skills as you need them ~ Murach's MySQL book 3rd edition
Chap 8: How to work with data types
Houlaymatou B. | code-techhb | Fall '25
*/

SELECT list_price,
       FORMAT(list_price, 1) AS formatted_price,
       CONVERT(list_price, SIGNED) AS converted_price,
       CAST(list_price AS SIGNED) AS cast_price
FROM products;


SELECT date_added,
       CAST(date_added AS DATE) AS dateOnly,
	CAST(DATE_FORMAT(date_added, '%Y-%m') AS CHAR) AS yearMonth,
       CAST(date_added AS TIME) AS timeOnly
FROM products;