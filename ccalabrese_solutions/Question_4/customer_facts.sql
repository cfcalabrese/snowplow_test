create view customer_facts as
with cust_facts as (
	select
		distinct
		customer_id,
		rental_id,
		rental_date,
		amount,
		count(*) over (partition by customer_id) as num_rentals,
		row_number() over (partition by customer_id order by rental_date) as row_num
	from
		customer c
	inner join rental using 
		(customer_id)
	inner join payment using 
		(rental_id, customer_id)
),
cust_first_rentals as (
	select 
		customer_id,
		max(case when row_num = 1 then rental_date end) as first_rental_date,
		max(case when row_num = 1 then rental_id end) as first_rental_id
	from 
		cust_facts
	group by 
		customer_id
),
cust_last_rentals as (
	select 
		customer_id,
		max(case when row_num = num_rentals then rental_date end) as last_rental_date,
		max(case when row_num = num_rentals then rental_id end) as last_rental_id
	from 
		cust_facts
	group by 
		customer_id
),
cust_val as (
	select 
		customer_id,
		count(*) as num_rentals,
		sum(amount) as total_revenue,
		sum(case when 
				rental_date between first_rental_date and first_rental_date + interval '30 day'
			then 
				amount else null end) as f30d
	from
		customer 
	inner join rental using 
		(customer_id)
	inner join payment using 
		(customer_id, rental_id)
	inner join cust_first_rentals using 
		(customer_id)
	group by
		customer_id
)
select
	customer_id,
	first_rental_date,
	first_rental_id,
	last_rental_date,
	last_rental_id,
	((last_rental_date - first_rental_date) / num_rentals) as average_rental_interval,
	total_revenue,
	(round(f30d, -1)/10) + 1 as value_tier
from 
	cust_first_rentals 
inner join cust_last_rentals using 
	(customer_id)
inner join cust_val using 
	(customer_id);
