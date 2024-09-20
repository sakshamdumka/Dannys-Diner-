/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id,
	   SUM(m.price)
FROM menu m
JOIN sales s
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY 1



-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
	   COUNT(DISTINCT order_date)
FROM sales
GROUP BY customer_id



-- 3. What was the first item from the menu purchased by each customer?
SELECT customer_id,
	   product_id
FROM
(
SELECT *,
	   RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as r
FROM sales
) as aa
WHERE r = 1
GROUP BY customer_id, product_id



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT s.product_id,
	   m.product_name,
	   COUNT(*)
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.product_id,
	     m.product_name
ORDER BY COUNT(*) DESC
LIMIT 1




-- 5. Which item was the most popular for each customer?
WITH cte1 AS
(
SELECT s.customer_id,
	   s.product_id,
  	   m.product_name,
	   COUNT(*) no_times_order,
       RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC)  as rnk     
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id,
	     s.product_id,
  	     m.product_name
)

SELECT customer_id,
	   product_id,
	   product_name,
       no_times_order
FROM cte1
WHERE rnk = 1



-- 6. Which item was purchased first by the customer after they became a member?
WITH cte1 AS
(
SELECT m.customer_id,
	   join_date,
       order_date,
       s.product_id,
 	   product_name,
       ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY order_date) r
FROM members m
JOIN sales s
ON m.customer_id = s.customer_id
JOIN menu dm
ON dm.product_id = s.product_id
WHERE join_date < order_date
)
SELECT customer_id,
	   product_id,
       product_name
FROM cte1
WHERE r = 1



-- 7. Which item was purchased just before the customer became a member?
WITH cte1 AS
(
SELECT m.customer_id,
	   join_date,
       order_date,
       s.product_id,
 	   product_name,
       ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY order_date DESC) r
FROM members m
JOIN sales s
ON m.customer_id = s.customer_id
JOIN menu dm
ON dm.product_id = s.product_id
WHERE join_date > order_date
)

SELECT customer_id,
	   product_id,
       product_name
FROM cte1
WHERE r = 1



-- 8. What is the total items and amount spent for each member before they became a member?
WITH cte1 AS
(
SELECT m.customer_id,
	   join_date,
       order_date,
       s.product_id,
 	   product_name,
       price,
       ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY order_date DESC) r
FROM members m
JOIN sales s
ON m.customer_id = s.customer_id
JOIN menu dm
ON dm.product_id = s.product_id
WHERE join_date > order_date
)

SELECT customer_id,
	   COUNT(product_id) total_item,
       SUM(price) amount_spent
FROM cte1
GROUP BY customer_id
ORDER BY 1


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH cte1 AS
(
SELECT customer_id,
	   CASE WHEN product_name = 'sushi' THEN total*20
			ELSE total*10
       END as points
FROM
(
SELECT customer_id,
	   product_name,
       SUM(price) as total
FROM sales s
JOIN menu m
ON m.product_id = s.product_id
GROUP BY customer_id,
	     product_name
ORDER BY 1) as aa
)

SELECT customer_id,
	   SUM(points) as total_points
FROM cte1
GROUP BY 1



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH cte1 AS
(
SELECT m.customer_id,
	   join_date,
       order_date,
       s.product_id,
 	   product_name,
       price,
       ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY order_date) r
FROM members m
JOIN sales s
ON m.customer_id = s.customer_id
JOIN menu dm
ON dm.product_id = s.product_id
WHERE join_date <= order_date
AND EXTRACT(MONTH FROM order_date) = 1
)

SELECT customer_id,
       SUM(price) * 20 as total_points
FROM cte1
GROUP BY customer_id