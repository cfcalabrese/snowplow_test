create view customer_movies_seen as
with movies_seen as (
	select
		distinct customer_id, film_id, title
	from 
		rental
	inner join 
		inventory using (inventory_id)
	inner join 
		film using (film_id)
	inner join 
		customer using (customer_id)
)
select 
	customer_id,
	film_id,
	title 
from 
	movies_seen 
order by 
	customer_id, title;