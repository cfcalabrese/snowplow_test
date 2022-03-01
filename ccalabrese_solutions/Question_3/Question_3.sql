-- Recommend 10 films to customers based on past viewing patterns
-- and viewing patterns of other customers 
--views:
--customer_film_preferences
--customer_movies_seen
--popularity_rankings_by_category
drop table if exists public.film_recommendations;

create table public.film_recommendations (
	customer_id int4 not null,
	film_title varchar(255) not null,
	category varchar(25) not null,
	recommendation_ranking int8 not null,
	CONSTRAINT customer_recc_pkey PRIMARY KEY (customer_id, recommendation_ranking)
);

insert into public.film_recommendations(customer_id, film_title, category, recommendation_ranking)
with recs as (
	select 
		prefs.customer_id, 
		category_id, 
		category, 
		pref_rank, 
		film_title, 
		ranking, 
		row_number() over (
			partition by 
				prefs.customer_id, category_id 
			order by 
				pref_rank, ranking) as recommended
	from 
		popularity_rankings_by_category pop_rank
	inner join customer_film_preferences prefs using 
		(category_id)
	left outer join customer_movies_seen seen on 
		seen.customer_id = prefs.customer_id and 
		seen.film_id = pop_rank.film_id
	where 
		seen.film_id is null
)
select 
	customer_id, 
	film_title, 
	category, 
	pref_rank as recommendation_ranking 
from 
	recs 
where 
	recommended = 1 
order by customer_id, pref_rank;