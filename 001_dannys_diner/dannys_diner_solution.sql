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



-- Question 3 - What was the first item from the menu purchased by each customer?
SELECT
    s.customer_id,
    s.order_date AS first_purchase_date,
    m.product_name
FROM(
    SELECT 
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM
        sales
    GROUP BY customer_id
) AS first_day
INNER JOIN sales s 
    ON first_day.customer_id = s.customer_id
    AND first_day.first_purchase_date = s.order_date
INNER JOIN menu m ON s.product_id = m.product_id;

-- Question 4 - What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
    m.product_name,
    COUNT(s.product_id) AS amount_of_purchase
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name;

-- Question 5 - Which item was the most popular for each customer?

WITH purchase_stats AS (
    SELECT
        customer_id,
        product_id,
        COUNT(product_id) AS purchase_frequency
    FROM sales s
    GROUP BY customer_id, product_id
),
max_freq AS (
    SELECT
        customer_id,
        MAX(purchase_frequency) AS max_freq
    FROM purchase_stats
    GROUP BY customer_id
)

SELECT
    ps.customer_id,
    m.product_name,
    ps.purchase_frequency
FROM
    purchase_stats ps
INNER JOIN max_freq mf 
   ON ps.customer_id = mf.customer_id
  AND ps.purchase_frequency = mf.max_freq
INNER JOIN menu m
   ON ps.product_id = m.product_id;
   
-- Question 6 - Which item was purchased first by the customer after they became a member?

WITH ranked_purchases AS (

    SELECT 
        s.customer_id,
        s.product_id,
        s.order_date,
        m.join_date,
         -- Rank purchases made after membership by earliest order_date
        RANK() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date ASC
        ) AS purchase_rank -- 
    
    FROM sales s
    INNER JOIN
        members m
    ON s.customer_id = m.customer_id
    
    -- Only include purchases made on or after membership start
    WHERE s.order_date >= m.join_date
)

-- Join to menu to retrieve product name for the first purchase
-- Filter to get only the first-ranked item(s) after membership

SELECT
    rp.customer_id,
    m.product_name
FROM 
    ranked_purchases rp
INNER JOIN 
    menu m
ON rp.product_id = m.product_id
WHERE rp.purchase_rank = 1;
