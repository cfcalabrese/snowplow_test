-- Avg. customer value per store by month for rentals in 2005.
-- Exclude top & bottom 10% of customers by value.
with cust_rentals as 
(
	select
		customer_id,
		store_id,
		sum(amount) as customer_value,
		percent_rank() over (partition by store_id order by sum(amount)) as perc_rank 
	from 
		rental
	inner join
		payment using (rental_id, customer_id)
	inner join 
		inventory using (inventory_id)
	where 
		date_part('year', rental_date) = 2005
	group by 
		customer_id, store_id
)
select
	store_id,
	round(avg(customer_value), 2) as avg_customer_value
from 
	cust_rentals 
where
	perc_rank between 0.1 and 0.9
group by 
	store_id
order by 
	store_id;