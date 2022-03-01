create view rental_titles as
with films_by_rental_id as (
	select
		rental_id,
		title as film_title
	from 
		rental r
	inner join inventory i using
		(inventory_id)
	inner join film f using 
		(film_id)
)
select 
	rental_id,
	film_title 
from 
	films_by_rental_id;
	