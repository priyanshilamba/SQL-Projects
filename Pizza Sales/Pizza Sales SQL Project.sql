Create Database PizzaSales;
Use PizzaSales;

SELECT * from pizzas;
SELECT * from pizza_types;
SELECT * FROM orders;
SELECT * FROM orders_details;


Create Table Orders(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
primary key(order_id) );

Create Table Orders_details(
order_detail_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
primary key(order_detail_id) );


-- Retrieve total number of orders placed

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    Orders;

-- Calculate the total revenue generated from Pizza Sale

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Revenue_generated
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- Identify the highest priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered
SELECT 
    pizzas.size,
    COUNT(orders_details.order_detail_id) AS No_of_Orders
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY No_of_Orders DESC
LIMIT 1;

-- List 5 most ordered pizza types along with their quantities

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS Total_orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_orders DESC
LIMIT 5;

-- Join  the necessary tables to find total quantity of each pizza category ordered

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS Total_Orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category; 

-- Determine distribution of orders by hours in a day
SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY Hours;

-- Join necessary tables to find category wise distribution of pizzas
SELECT category, Count(name) As Variants FROM pizza_types GROUP BY category;

-- Group the orders by date and calculate the avg number of pizzas ordered per day
SELECT 
    ROUND(AVG(Quantity))
FROM
    (SELECT 
        orders.order_date AS Order_Date,
            SUM(orders_details.quantity) AS Quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY Order_Date) AS Avg_Order;
    
    -- Determine the top 3 most ordered pizza types based on revenue.
    
   SELECT 
    pizza_types.category,
    SUM(orders_details.quantity * pizzas.price) AS Revenue_generated
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue_generated DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    (ROUND(SUM(orders_details.quantity * pizzas.price)) / (SELECT 
            ROUND(SUM(orders_details.quantity * pizzas.price),
                        2) AS Revenue_generated
        FROM
            orders_details
                JOIN
            pizzas ON pizzas.pizza_id = orders_details.pizza_id)) * 100 AS Percent_Revenue_contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category;

-- Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER(order by order_date) as cum_revenue FROM 
(SELECT orders.order_date, ROUND(SUM(orders_details.quantity * pizzas.price)) as revenue FROM orders_details JOIN pizzas ON 
orders_details.pizza_id = pizzas.pizza_id JOIN orders ON orders.order_id = orders_details.order_id 
GROUP BY orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, Revenue_generated, rn FROM
(SELECT category, name, Revenue_generated , 
rank() OVER(partition by category ORDER BY Revenue_generated DESC) as rn 
FROM 
(SELECT
    pizza_types.category, pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS Revenue_generated
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category, pizza_types.name) as a) as b
WHERE rn <= 3;
