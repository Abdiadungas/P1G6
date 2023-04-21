/* 
 DML: The dvdrental db already has a pre-populated data in it, 
 but let's assume that the business is still running in which case we need
  to not only analyze existing data but also maintain the database mainly 
  by INSERTing data for new rentals and UPDATEing the db for existing 
  rentals--i.e implementing DML (Data Manipulation Language). To this 
  effect,
*/

/*A Write ALL the queries we need to rent out a given movie.
 (Hint: these are the business logics that go into this task: 
 first confirm that the given movie is in stock, and then INSERT a 
 row into the rental and the payment tables. You may also need to check
  whether the customer has an outstanding balance or an overdue rental 
  before allowing him/her to rent a new DVD).*/

--  Check if the movie is in stock:
​
SELECT inventory_id FROM inventory
WHERE film_id = 17 AND
      store_id = 1 AND
      NOT EXISTS (SELECT * FROM rental
                  WHERE inventory.inventory_id = rental.inventory_id
                  AND rental.return_date IS NULL);
​
-- Check if the customer has an outstanding balance:
​
SELECT * FROM customer
WHERE customer_id = 600 AND
      (SELECT SUM(amount) FROM payment
       WHERE customer.customer_id = payment.customer_id) <
      (SELECT SUM(rental_rate) FROM rental
       JOIN inventory ON rental.inventory_id = inventory.inventory_id
       JOIN film ON inventory.film_id = film.film_id
       WHERE rental.customer_id = 600 AND
             rental.return_date IS NULL);
/*
 B write ALL the queries we need to process return of a rented movie. 
 (Hint: update the rental table and add the return date by first
  identifying the rental_id 
 to update based on the inventory_id of the movie being returned.)
*/ 

