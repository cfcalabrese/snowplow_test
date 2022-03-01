drop table if exists public.customer_lifecycle;

create table public.customer_lifecycle (
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
	constraint customer_id_pkey primary key (customer_id)
);

insert into public.customer_lifecycle
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
select 
	customer_id,
	date_trunc('day', first_rental_date) as first_rental_date,
	rt.film_title as first_film_rented,
	date_trunc('day', last_rental_date) as last_rental_date,
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
	rt2.rental_id = cf.last_rental_id;