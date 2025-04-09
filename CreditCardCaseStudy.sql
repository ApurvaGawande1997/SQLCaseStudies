select * from Credit_Card_Transactions

select * from orders

--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends
--select city from (select city,rank() over (partition by city order by Amount) as rnk from Credit_Card_Transactions) A ;

select city,Amt,rnk from (select Amt,city,rank() over (order by Amt desc) as rnk from (select city, sum(Amount) as Amt
from Credit_Card_Transactions group by city ) A) B where rnk<=5

with cte as (
select City,SUM(Amount) as Amt
from Credit_Card_Transactions
group by City
),total_spent as ( select City,(Amt*1.0) as Total_Amt,rank() over(order by Amt desc) as rnk from cte )
select City,Total_Amt from total_spent where rnk<=5;


with cte1 as (
select city,sum(amount) as total_spend
from Credit_Card_Transactions
group by city)
,total_spent as ( select sum(cast(amount as bigint)) as total_amount from Credit_Card_Transactions )
select top 5 cte1.*, round(total_spend*1.0/total_amount * 100,2) as percentage_contribution from 
cte1 inner join total_spent on 1=1
order by total_spend desc


--, total_spent as (
--select rank() over(order by Amt) as rnk from cte
--);
--select * from total_spent where rnk<=5;


--2)write a query to print highest spend month and amount spent in that month for each card type

select * from Credit_Card_Transactions;

with cte as (
select card_type as Card_Type,SUM(Amount) as total_spend_by_Card,datepart(month,Date) as month,datepart(year,Date) as year 
from Credit_Card_Transactions
group by datepart(month,Date),datepart(year,Date),card_type)
select * from ( select *,rank() over(partition by Card_Type order by total_spend_by_Card desc) as rnk 
from cte ) A where rnk=1

with cte as (
select card_type,datepart(year,Date) yt
,datepart(month,Date) mt,sum(amount) as total_spend
from Credit_Card_Transactions
group by card_type,datepart(year,Date),datepart(month,Date)
--order by card_type,total_spend desc
)
select * from (select *, rank() over(partition by card_type order by total_spend desc) as rn
from cte) a where rn=1


--3)write a query to print the transaction details(all columns from the table) for each card type when it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with cte as (select *,SUM(Amount) over(partition by card_type order by Date,Transaction_id) as total_spend
from Credit_Card_Transactions
)
select * from (select *, rank() over(partition by card_type order by total_spend) as rn  
from cte where total_spend >= 1000000) a where rn=1

select * from Credit_Card_Transactions

--4) write a query to find city which had lowest percentage spend for gold card type
--instead this solution is for city with lowest percentage contribution for gold card type
with total_gold_amount as (select SUM(AMOUNT) as total_gold_spend
from Credit_Card_Transactions
where Card_Type='Gold'), gold_by_city as (
select city as city,SUM(AMOUNT) as gold_by_city
from Credit_Card_Transactions
where Card_Type='Gold'
group by city )
select top 1 city,round((gold_by_city*(1.0)/total_gold_spend)*100,2) as percentage_spend
from total_gold_amount inner join gold_by_city on 1=1

--this is solution for 4)write a query to find city which had lowest percentage spend for gold card type !!!!not understood
with cte as (
select top 1 city,card_type,sum(amount) as amount
,sum(case when card_type='Gold' then amount end) as gold_amount
from Credit_Card_Transactions
group by city,card_type)
select 
city,sum(gold_amount)*1.0/sum(amount) as gold_ratio
from cte
group by city
having count(gold_amount) > 0 and sum(gold_amount)>0
order by gold_ratio;

--5)write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

select * from Credit_Card_Transactions
select distinct exp_type from Credit_Card_Transactions;

select City,MAX(Exp_Type) as highest_expense_type,MIN(Exp_Type) as lowest_expense_type
from Credit_Card_Transactions
group by City,Exp_Type

--solution of above question
with City_Exp_cte as (select city,exp_type,sum(amount) as total_amount from Credit_Card_Transactions
group by city,exp_type)
select
city , max(case when rn_asc=1 then exp_type end) as lowest_exp_type
, min(case when rn_desc=1 then exp_type end) as highest_exp_type
from (
select *,rank() over(partition by city order by total_amount desc) rn_desc
,rank() over(partition by city order by total_amount asc) rn_asc
from City_Exp_cte ) A
group by City

--6)write a query to find percentage contribution of spends by females for each expense type
select exp_type,
(sum(case when gender='F' then amount else 0 end)*1.0/sum(amount))*100 as percentage_female_contribution
from Credit_Card_Transactions
group by exp_type
order by percentage_female_contribution desc;

--other approach
--analyze error
select exp_type,total_spend_by_female*(1.0) from (select exp_type,SUM(Amount) as total_spend_by_female
from Credit_Card_Transactions
where gender='F'
group by gender,exp_type) A
group by exp_type

--other approach continued--again doubt
With cte_female as ( select exp_type,SUM(Amount) as total_spend_by_female
from Credit_Card_Transactions
where gender='F'
group by gender,exp_type)
select female.exp_type,(female.total_spend_by_female*(1.0)/SUM(AMOUNT)) as total_amount
from Credit_Card_Transactions C inner join cte_female female on C.exp_type=female.exp_type
group by C.exp_type,female.exp_type

--7)which card and expense type combination saw highest month over month growth in Jan-2014
with cte as (
select card_type,exp_type,datepart(year,transaction_date) yt
,datepart(month,transaction_date) mt,sum(amount) as total_spend
from credit_card_transcations
group by card_type,exp_type,datepart(year,transaction_date),datepart(month,transaction_date)
)

--8)during weekends which city has highest total spend to total no of transcations ratio
select top 1 city , sum(amount)*1.0/count(1) as ratio
from Credit_Card_Transactions
where datepart(weekday,Date) in (1,7)
group by city
order by ratio desc;


--9)which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as (
select *
,row_number() over(partition by city order by Date,transaction_id) as rn
from Credit_Card_Transactions)
select top 1 city,datediff(day,min(Date),max(Date)) as datediff1
from cte
where rn=1 or rn=500
group by city
having count(1)=2
order by datediff1 



