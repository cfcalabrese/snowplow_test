-- 10 most popular movies from rentals in h1 2005, by category
with film_cat as 
(
    select
        film_id,
        name as cat,
        title
    from
        category
    inner join
        film_category using (category_id)
    inner join 
    	film using (film_id)
),
rentals as 
(
	select
		film_id,
		count(rental_date) as times_rented
	from
		inventory
	inner join 
		rental using (inventory_id)
	where
		date_part('quarter', rental_date) in (1, 2)
		and date_part('year', rental_date) = 2005
	group by
		film_id
),
popularity_rankings as 
(
	select 
	    title as film_title,
	    cat as category_name,
	    times_rented,
	    row_number() over (partition by cat order by times_rented desc) as ranking 
	    -- If rank() is used here instead of row_number() we see that there are multiple
	    -- films in each category with equal ranking, bringing our total number of films in 
	    -- the per category rankings over 10.
	from 
	    film_cat 
	inner join
	    rentals using (film_id)
)
select 
	film_title,
	category_name,
	ranking2 
from 
	popularity_rankings 
where 
	ranking < 11
order by 
	category_name, ranking;
