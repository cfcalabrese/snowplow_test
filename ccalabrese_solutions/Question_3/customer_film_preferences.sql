create view customer_film_preferences as
with cust_rentals as (
	select
		customer_id,
		category_id,
		name as category,
		count(name) as films_seen_in_category
	from 
		rental
	inner join 
		inventory using (inventory_id)
	inner join 
		film using (film_id)
	inner join 
		film_category using (film_id)
	inner join
		category using (category_id)
	inner join 
		customer using (customer_id)
	group by 
		customer_id, category_id, name
),
cust_genre_preferences as (
	select
		customer_id,
		category_id,
		category,
		round(films_seen_in_category /
			sum(films_seen_in_category) over (partition by customer_id), 2)
			as preference
	from 
		cust_rentals
	order by 
		customer_id, preference desc
)
select
	*
from (
	select
		customer_id,
		category_id,
		category,
		row_number() over 
			(partition by customer_id order by preference desc) as pref_rank
	from 
		cust_genre_preferences 
) subq
where 
	pref_rank < 11
order by
	customer_id, pref_rank;