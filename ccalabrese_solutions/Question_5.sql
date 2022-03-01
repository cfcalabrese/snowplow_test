-- If max(rental.rental_date) group by customer_id > max(customer_lifecycle_incremental.last_rental_date) group by customer_id
-- update row

create table public.customer_lifecycle_incremental (
	customer_id int4 not null,
	first_rental_date timestamp not null,
	first_film_rented varchar(255) not null,
	last_rental_date timestamp not null,
	last_film_rented varchar(255) not null,
	average_rental_interval interval not null,
	total_revenue numeric not null,
	f30d_revenue numeric not null,
	value_tier_f30d numeric not null,
	first_fav_actor text not null,
	second_fav_actor text null,
	third_fav_actor text null,
	constraint customer_id_inc_pkey primary key (customer_id)
);

insert into customer_lifecycle_incremental 
(
	customer_id,
	first_rental_date,
	first_film_rented,
	last_rental_date,
	last_film_rented,
	average_rental_interval,
	total_revenue,
	f30d_revenue,
	value_tier_f30d,
	first_fav_actor,
	second_fav_actor,
	third_fav_actor 
)
with cust_lifecycle_latest_rentals as (
	select 
		customer_id,
		last_rental_date as last_rental_date
	from 
		customer_lifecycle
),
rentals_latest_rentals as (
	select 
		customer_id,
		max(rental_date) as last_rental_date
	from 
		rental
	group by 
		customer_id
),
ids_to_update as(
	select 
		customer_id
	from
		cust_lifecycle_latest_rentals 
	inner join rentals_latest_rentals using
		(customer_id)
	where 
		rentals_latest_rentals.last_rental_date > cust_lifecycle_latest_rentals.last_rental_date
)
select 
	customer_id,
	first_rental_date as first_rental_date,
	rt.film_title as first_film_rented,
	last_rental_date as last_rental_date,
	rt2.film_title as last_film_rented,
	cf.average_rental_interval,
	cf.total_revenue,
	cf.f30d_revenue,
	cf.value_tier_f30d,
	cfa.first_fav as first_fav_actor,
	cfa.second_fav as second_fav_actor,
	cfa.third_fav as third_fav_actor
from 
	customer_facts cf
inner join customer_fav_actors cfa using
	(customer_id)
inner join rental_titles rt on 
	rt.rental_id = cf.first_rental_id
inner join rental_titles rt2 on 
	rt2.rental_id = cf.last_rental_id
inner join ids_to_update using 
	(customer_id)
on conflict on constraint customer_id_inc_pkey do update
set 
	last_rental_date = excluded.last_rental_date,
	last_film_rented = excluded.last_film_rented,
	average_rental_interval = excluded.average_rental_interval,
	total_revenue = excluded.total_revenue,
	first_fav_actor = excluded.first_fav_actor,
	second_fav_actor = excluded.second_fav_actor,
	third_fav_actor = excluded.third_fav_actor
where
	customer_lifecycle_incremental.customer_id = excluded.customer_id;