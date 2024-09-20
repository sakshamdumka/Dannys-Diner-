# Dannys-Diner-
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.
<br>

## Project Overview
Danny's Diner aims to create a deeper connection with customers by analyzing their behaviors and preferences. This project is designed to help Danny analyze customer data, enhance customer relationships, and optimize the diner’s loyalty program. It leverages SQL databases to provide insights into customer spending patterns, visiting habits, and menu preferences.

## Dataset
The project utilizes three key datasets:

**1. Sales:** Records of customer purchases, including customer IDs, order dates, and product IDs.
<br>
**2. Sales:** Menu: Details of menu items, including product IDs, names, and prices.
<br>
**3. Members:** Information about customers enrolled in the loyalty program, including their join dates.

## Data Analysis and findings
The project includes various SQL queries designed to extract valuable insights from the datasets:


**1. What is the total amount each customer spent at the restaurant?**
```sql
SELECT s.customer_id,
	   SUM(m.price)
FROM menu m
JOIN sales s
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY 1
```


**2. How many days has each customer visited the restaurant?**
```sql
SELECT customer_id,
	   COUNT(DISTINCT order_date)
FROM sales
GROUP BY customer_id
```


**3. What was the first item from the menu purchased by each customer?**
```sql
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
```


**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```sql
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
```


**5. Which item was the most popular for each customer?**
```sql
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
```


**6. Which item was purchased first by the customer after they became a member?**
```sql
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
```


**7. Which item was purchased just before the customer became a member?**
```sql
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
```


**8. What is the total items and amount spent for each member before they became a member?**
```sql
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
```


**9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
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
```


**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```sql
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
```
## Usage
**1. Setup:** Ensure you have a PostgreSQL database setup. Import the provided datasets into your database using the Create_Insert_queries.sql.
<br>
**2. Run SQL Queries:** Use the SQL queries provided in the sql_queries.sql file to analyze the data.
<br>
**3. Inspect Results:** Review the results of the queries to gain insights into customer behaviors and preferences.

## Conclusion
By leveraging the insights gained from the data, Danny can deliver a more personalized experience. These queries will provide Danny with valuable insights into customer behavior, spending, and preferences, helping him evaluate the effectiveness of his loyalty program and consider potential expansions.
