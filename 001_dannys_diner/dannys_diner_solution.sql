USE dannys_diner;

-- Question 1 - What is the total amount each customer spent at the restaurant?

SELECT 
    s.customer_id, SUM(m.price) AS total_spent
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Question 2 - How many days has each customer visited the restaurant?

SELECT 
    customer_id, COUNT(DISTINCT CAST(order_date AS DATE)) AS visit_day_count
FROM
    sales
GROUP BY customer_id;
