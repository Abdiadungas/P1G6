 Check if the movie is in stock: for a givne film title

SELECT inventory.inventory_id
FROM inventory, film
WHERE film.title = [insert movie_title]
  AND inventory.store_id = [insert store_id]		 -- AND film.title = 'Annie Identity'			
  AND inventory.film_id = film.film_id	 			 -- AND inventory.store_id = 1	  
  AND NOT EXISTS (SELECT * FROM rental
                  WHERE inventory.inventory_id = rental.inventory_id
                  AND rental.return_date IS NULL);
	
-- Check if the customer has an outstanding balance:	 
			 
SELECT * FROM customer
WHERE customer_id = [insert customer_id] AND						    	--WHERE customer_id = 600 AND
      (SELECT SUM(amount) FROM payment
       WHERE customer.customer_id = payment.customer_id) <
      (SELECT SUM(film.rental_rate) FROM rental
       JOIN inventory ON rental.inventory_id = inventory.inventory_id
       JOIN film ON inventory.film_id = film.film_id
       WHERE rental.customer_id = customer.customer_id AND					 --WHERE rental.customer_id = 600 AND
             rental.return_date IS NULL);
			 		 
------------------------------------------------------------------------------------------------------------
--option 2 without using the join keyword
SELECT customer.customer_id, customer.first_name, customer.last_name, film.title,
       payment.payment_id, rental.rental_id, payment.amount, film.rental_rate,
       payment.payment_date, rental.rental_date, rental.return_date, rental.last_update
        
FROM customer, payment, rental, inventory, film
WHERE customer.customer_id = [insert customer_id]					--WHERE customer.customer_id = 602
  AND payment.customer_id = customer.customer_id
  AND rental.customer_id = customer.customer_id
  AND rental.return_date IS NULL
  AND rental.inventory_id = inventory.inventory_id
  AND inventory.film_id = film.film_id
  AND (SELECT SUM(payment.amount) FROM payment
       WHERE customer.customer_id = payment.customer_id) <
      (SELECT SUM(film.rental_rate) FROM rental, inventory, film
       WHERE rental.customer_id = customer.customer_id
         AND rental.return_date IS NULL
         AND rental.inventory_id = inventory.inventory_id
         AND inventory.film_id = film.film_id);
----------------------------------------------------------------------------------------------------
-- Check if the customer has an overdue rental:

SELECT * FROM rental
WHERE customer_id = [insert customer_id] AND             --WHERE customer_id = 600 AND
      return_date IS NULL AND
      rental_date + INTERVAL '7 days' < CURRENT_TIMESTAMP;

-- Insert a row into the rental table:

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (CURRENT_TIMESTAMP, 83, 600, 1);

-- Insert a row into the payment table:

INSERT INTO Payment(customer_id, staff_id, rental_id, amount, payment_date)
VALUES (600, 1, currval('rental_rental_id_seq'), 1, CURRENT_TIMESTAMP)

--  Queries for Processing Return of a Rented Movie:
--  Update the rental table with the return date when a movie is returned:

UPDATE rental
SET return_date = CURRENT_TIMESTAMP
WHERE rental_id = [insert rental_id];


-- PART 2,

-- A.1)
-- Which movie genres are the most popular? 
-- And how much revenue have they each generated for the business?

SELECT
    category.name AS genre,
    COUNT(rental.rental_id) AS rental_count,
    SUM(payment.amount) AS total_revenue
FROM 
    film_category,
    category,
    film,
    inventory,
    rental,
    payment
WHERE 
    film.film_id = film_category.film_id AND
    category.category_id = film_category.category_id AND
    inventory.film_id = film.film_id AND
    rental.inventory_id = inventory.inventory_id AND
    payment.rental_id = rental.rental_id
GROUP BY 
   genre
ORDER BY 
    rental_count DESC;


-- A.2)
-- Which movie genres are the least popular? 
-- And how much revenue have they each generated for the business?

SELECT
    category.name AS genre,
    COUNT(rental.rental_id) AS rental_count,
    SUM(payment.amount) AS total_revenue
FROM 
    film_category,
    category,
    film,
    inventory,
    rental,
    payment
WHERE 
    film.film_id = film_category.film_id AND
    category.category_id = film_category.category_id AND
    inventory.film_id = film.film_id AND
    rental.inventory_id = inventory.inventory_id AND
    payment.rental_id = rental.rental_id
GROUP BY 
   genre
ORDER BY 
    rental_count ASC;
	
-- B)
-- What are the top 10 most popular movies? And how many times have they each been rented out thus far?

SELECT 
    film.title,
    COUNT(*) AS rental_count
FROM 
    film,
    inventory,
    rental
WHERE 
    inventory.film_id = film.film_id AND
    rental.inventory_id = inventory.inventory_id
GROUP BY 
    film.film_id
ORDER BY 
    rental_count DESC
LIMIT 10;


-- C)
-- Which genres have the highest and the lowest average rental rate?
-- (modify the ORDER BY to ASC for "from lowest to highest" rental rate result)

SELECT 
    category.name,
    AVG(film.rental_rate) AS avg_rental_rate
FROM 
    category,
    film_category,
    film,
    inventory,
    rental
WHERE 
    category.category_id = film_category.category_id AND
    film.film_id = film_category.film_id AND
    inventory.film_id = film.film_id AND
    rental.inventory_id = inventory.inventory_id
GROUP BY 
    category.name
ORDER BY 
    avg_rental_rate DESC;
	
-- D)	
-- How many rented movies were returned late? Is this somehow correlated with the genre of a movie?

SELECT 
    category.name,
    COUNT(*) AS late_return_count
FROM 
    category,
    film_category,
    film,
    inventory,
    rental
WHERE 
    category.category_id = film_category.category_id AND
    film.film_id = film_category.film_id AND
    inventory.film_id = film.film_id AND
    rental.inventory_id = inventory.inventory_id AND
    rental.return_date > rental.rental_date + INTERVAL '7 days'
GROUP BY 
    category.name
ORDER BY 
    late_return_count DESC;
	
-- E)
-- What are the top 5 cities that rent the most movies? How about in terms of total sales volume?

SELECT city.city, SUM(payment.amount) AS total_sales
FROM customer, rental, inventory, film, film_category, category, address, city, payment
WHERE customer.customer_id = rental.customer_id
AND rental.inventory_id = inventory.inventory_id
AND inventory.film_id = film.film_id
AND film.film_id = film_category.film_id
AND film_category.category_id = category.category_id
AND customer.address_id = address.address_id
AND address.city_id = city.city_id
AND payment.rental_id = rental.rental_id
GROUP BY city.city
ORDER BY total_sales DESC
LIMIT 5;

-- F)
-- best customers who are loyal and also return movie on time

SELECT customer.first_name, customer.last_name, COUNT(rental.rental_id) AS rental_count
FROM customer, rental
WHERE customer.customer_id = rental.customer_id
      AND rental.return_date IS NOT NULL
      AND rental.return_date <= rental.date_returned
GROUP BY customer.first_name, customer.last_name
ORDER BY rental_count DESC
LIMIT 10;

/* 
G) 
What are the 10 best rated movies? Is customer rating somehow correlated with revenue? Which 
actors have acted in most number of the most popular or highest rated movies?
*/

-- G.1) best rated movies

SELECT film.title, AVG(film.rating) AS avg_rating
FROM film
GROUP BY film.title
ORDER BY AVG(film.rating) DESC
LIMIT 10;

-- G.2) Correlation between customer rating and revenue
SELECT AVG(film.rental_rate) AS avg_rental_rate, AVG(film.rating) AS avg_rating
FROM film;

-- G.3) Actors who have acted in the most popular or highest rated movies
SELECT actor.first_name, actor.last_name, COUNT() AS movie_count
FROM actor
INNER JOIN film_actor ON actor.actor_id = film_actor.actor_id
INNER JOIN (
SELECT inventory.film_id, COUNT() AS rental_count
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
GROUP BY inventory.film_id
ORDER BY COUNT() DESC
LIMIT 10
) top_films ON film_actor.film_id = top_films.film_id
GROUP BY actor.first_name, actor.last_name
ORDER BY COUNT() DESC;

--  H)
-- Identify all movies categorized as family films to target all family genres for promotion

SELECT film.title, film.release_year, category.name AS category
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- I)
-- How much revenue has each store generated so far?

SELECT store.store_id, SUM(payment.amount) AS revenue
FROM store, staff, payment, rental
WHERE store.store_id = staff.store_id
      AND staff.staff_id = rental.staff_id
      AND rental.rental_id = payment.rental_id
GROUP BY store.store_id;

-- J)
--  Top 5 genres by average revenue. 

CREATE VIEW top_5_genre_revenue AS
SELECT category.name, AVG(payment.amount) AS avg_revenue
FROM category, film_category, film, inventory, rental, payment
WHERE category.category_id = film_category.category_id
      AND film_category.film_id = film.film_id
      AND film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY avg_revenue DESC
LIMIT 5;

-- to check the view created in the above query

SELECT * FROM top_5_genre_revenue;