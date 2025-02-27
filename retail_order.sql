-- find top 10 highest revenue generating products

select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10 

-- find top 5 highest products in each region
with cte as (
select  region ,product_id , sum(sale_price) as sales
from df_orders
group by  region, product_id
)
select * from(
select *,
 row_number() over(partition by region order by sales desc) as rn
 from cte
)
where rn<=5



-- find monnth over month growth comparison for 2022 and 2023 eg : jan 2022 vs jan 2023
with cte as (
select 
    extract(year from order_date) as order_year, 
    extract(month from order_date) as order_month,
    sum(sale_price) as sales
    from df_orders
    group by order_year , order_month
    -- order by order_year, order_month
	)
select order_month
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte

group by order_month
order by order_month



-- for each category which month had highest sales
with cte as(

SELECT category, 
       TO_CHAR(order_date, 'YYYYMM') AS order_year_month, 
       SUM(sale_price) AS sales
FROM df_orders
GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
order by category,TO_CHAR(order_date, 'YYYYMM')

)
select * from(
select * ,
row_number() over(partition by category order by sales desc) as rn
from cte)

where rn = 1


--which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
select
    sub_category,
    extract(year from order_date) as order_year, 
    sum(sale_price) as sales
    from df_orders
    group by sub_category, order_year
    order by sub_category
	)
, cte2 as (
select sub_category
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte

group by sub_category
)

select *,
(sales_2023-sales_2022)
from cte2
order by (sales_2023-sales_2022) desc
limit 1;
