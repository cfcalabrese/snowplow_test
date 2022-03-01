create view customer_fav_actors as
with customer_actors_watched as (
	select 
		customer_id, 
		unnest(string_to_array(fl.actors, ', ')) as actor from customer_movies_seen cms 
	inner join film_list fl on 
		cms.film_id = fl.fid
),
actors_agg as (
	select
		customer_id,
		actor,
		count(actor) as times_watched,
		row_number() over (partition by customer_id order by count(actor) desc) as rn
	from 
		customer_actors_watched
	group by
		customer_id, actor 
	order by 
		customer_id, times_watched desc
)
select 
	customer_id,
	max(case when rn = 1 then actor end) as first_fav,
	max(case when rn = 2 then actor end) as second_fav,
	max(case when rn = 3 then actor end) as third_fav
from actors_agg
group by customer_id;