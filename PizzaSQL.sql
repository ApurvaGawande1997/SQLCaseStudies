select * from order_details
select * from orders
select * from pizza_types
select * from pizzas

--Basic:
--Retrieve the total number of orders placed.
select count(distinct order_id) as total_no_of_orders
from order_details

select count(distinct order_id) as total_no_of_orders
from orders

--Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity*p.price),2) as total_revenue
from order_details od inner join pizzas p 
on od.pizza_id=p.pizza_id

--Identify the highest-priced pizza.
select max(price) as highest_priced_yummy_pizza
from pizzas

select top 1 p.pizza_id,round(p.price,2) as highest_pizza_price from
order_details od inner join pizzas p
on od.pizza_id=p.pizza_id
group by p.price,p.pizza_id
order by p.price desc

--Identify the most common pizza size ordered.
select top 1 p.size,count(p.size) as most_common_pizza from
order_details od inner join pizzas p
on od.pizza_id=p.pizza_id
group by (p.size)

--Identify the most common pizza size ordered by with orders count.
select top 1 p.size,count(distinct(od.order_id)) as no_of_orders,SUM(od.quantity) as most_common_pizza from
order_details od inner join pizzas p
on od.pizza_id=p.pizza_id
group by (p.size)
order by count(distinct(od.order_id)) desc

--List the top 5 most ordered pizza types along with their quantities.
select top 5 pt.name,sum(od.quantity) as pizza_quantity
from order_details od
inner join pizzas p on od.pizza_id=p.pizza_id
inner join pizza_types pt on p.pizza_type_id=pt.pizza_type_id 
group by pt.name
order by sum(od.quantity) desc

select * from order_details
select * from pizza_types
select * from pizzas

--Intermediate:
--Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).
select pt.category,sum(od.quantity) as pizza_quantity_by_category
from order_details od
inner join pizzas p on od.pizza_id=p.pizza_id
inner join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category
order by pizza_quantity_by_category desc

--Determine the distribution of orders by hour of the day (at which time the orders are maximum (for inventory management and resource allocation).
select * from orders
select DATEPART(HOUR,time) as 'Hour of the day',count(distinct order_id) as 'No of orders'
from orders
group by DATEPART(Hour,time)
order by count(distinct order_id) DESC

--Find the category-wise distribution of pizzas (to understand customer behaviour).
select category,count(distinct pizza_type_id) as No_of_pizzas
from pizza_types
group by category
order by No_of_pizzas

--Group the orders by date and calculate the average number of pizzas ordered per day.
with cte as
(select o.date,sum(od.quantity) as No_Pizzas_order_that_day
from order_details od
inner join orders o on od.order_id=o.order_id
group by o.date
)

select avg(No_Pizzas_order_that_day) as avg_pizzas_ordered from cte


--Determine the top 3 most ordered pizza types based on revenue (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)
select * from orders
select * from order_details
select top 3 pt.name, round(sum(od.quantity*p.price),2) as Revenue_pizza
from order_details od
inner join pizzas p on p.pizza_id=od.pizza_id
inner join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by Revenue_pizza


--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)

--Analyze the cumulative revenue generated over time.

--Determine the top 3 most ordered pizza types based on revenue for each pizza category (In each category which pizza is the most selling)
