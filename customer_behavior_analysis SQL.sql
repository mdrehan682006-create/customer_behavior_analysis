
select* from customer --limit 20

--Q1. What is the total revenue genrated by male vs. female customer?
select gender,sum("purchase-amount-(usd)") as revenue
from customer
group by gender

--Q2. which customer used a dicount but still spent more then the average purchase amount?
select "customer-id","purchase-amount-(usd)"
from customer
where"discount-applied" = 'yes' and "purchase-amount-(usd)" >= (select AVG("purchase-aomunt-(usd)")
from customer)

--Q3. which are the top 5 product wtih highest review rating?
select "item-purchased",ROUND(AVG("review-rating"::numeric),2) as "Averge Product Rating"
from customer
group by "item-purchased"
order by avg("review-rating") desc
limit 5;

--Q4. compare the average purchase Amount between standard and express shipping
select "shipping-type",
Round(avg("purchase-amount-(usd)"),2)
from customer
where "shipping-type" in ('Standard','Express')
group by "shipping-type"

--Q5 do suscribe customer spent more compere average spent and total revenue
--   between suscribe customer and non-suscribe customer
select "subscription-status",
COUNT("customer-id") as total_customer,
round(avg("purchase-amount-(usd)"),2) as avg_spend,
round(sum("purchase-amount-(usd)"),2) as total_revenue
from customer
group by "subscription-status"
order by total_revenue,avg_spend desc;

--Q6. which 5 product have the higest percentage of purchase with discounts applied?
select"item-purchased",
round(100*sum(case when "discount-applied" = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by "item-purchased"
order by "discount_rate" desc
limit 5

--Q7. Segment customer into new, returning, and loyal based on their total
--numer of previous purchase, and show the count of each segment.
with customer_type as (
select "customer-id","previous-purchases",
case
    when "previous-purchases" = 1 then 'New'
	when "previous-purchases" Between 2 and 10 then 'Returning'
	else 'Loyal'
	end as customer_segment
	from customer
)

select customer_segment, count(*) as "Number of Customers"
from customer_type
group by customer_segment

--Q8. what are the top 3 most purchased within each category?
with item_counts as(
select "category","item-purchased",
count("customer-id") as total_orders,
row_number() over(partition by "category" order by count("customer-id")desc) as item_rank
from customer
group by category, "item-purchased"
)

select item_rank,"category","item-purchased",total_orders
from item_counts

--Q9. Are customer who are repeat buyer (more than 5 previous purchases) also likely to subscribe?
select "subscription-status",
count("customer-id") as repeat_buyers
from customer
where "previous-purchases" > 5
group by "subscription-status"

--Q10. what is the revenue contribution of each age group?
select age_group,
sum("purchase-amount-(usd)") as total_revenue
from customer
group by age_group
order by total_revenue desc