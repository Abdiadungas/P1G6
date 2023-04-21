/*
DQL: Now that we have an up-to-date database, 
let's write some queries and analyze the data to understand 
how our DVD rental business is performing so far.
*/

-- A.1)
-- Which movie genres are the most popular? 
-- And how much revenue have they each generated for the business?
​
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
​
​
-- A.2)
-- Which movie genres are the least popular? 
-- And how much revenue have they each generated for the business?
​
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
​
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
​
​
-- C)
​
-- Which genres have the highest and the lowest average rental rate?
-- (modify the ORDER BY to ASC for "from lowest to highest" rental rate result)
​
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
​
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
​
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
​
-- F)
-- best customers who are loyal and also return movie on time
​
SELECT customer.first_name, customer.last_name, COUNT(rental.rental_id) AS rental_count
FROM customer, rental
WHERE customer.customer_id = rental.customer_id
      AND rental.return_date IS NOT NULL
      AND rental.return_date <= rental.date_returned
GROUP BY customer.first_name, customer.last_name
ORDER BY rental_count DESC
LIMIT 10;
​
​
-- What are the 10 best rated movies? Is customer rating somehow correlated with revenue? 
-- Which actors have acted in most number of the most popular or highest rated movies?
SELECT film.title, 
​
​
​
​
​
-- I)
-- How much revenue has each store generated so far?
SELECT store.store_id, SUM(payment.amount) AS revenue
FROM store, staff, payment, rental
WHERE store.store_id = staff.store_id
      AND staff.staff_id = rental.staff_id
      AND rental.rental_id = payment.rental_id
GROUP BY store.store_id;
​
-- J)
--  Top 5 genres by average revenue. 
​
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
-- to check the view,
SELECT * FROM top_5_genre_revenue;