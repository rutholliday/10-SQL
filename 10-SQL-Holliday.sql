USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column
--  in upper case letters. Name the column Actor Name.

SELECT UPPER(CONCAT(first_name, " ", last_name)) AS Actor_Name
FROM actor; 

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
--  What is one query would you use to obtain this information?  
SELECT actor_id, first_name, last_name FROM  actor WHERE first_name= 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE CONCAT('%GEN%');

-- 2c. Find all actors whose last names contain the letters LI. This time,
--  order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor WHERE last_name LIKE CONCAT('%LI%');

-- 2d. Using IN, display the country_id and country columns of the following 
-- countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing
--  queries on a description, so create a column in the table actor named description and 
-- use the data type BLOB

ALTER TABLE actor
ADD COLUMN description BLOB;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(1) FROM actor GROUP BY last_name;
 
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(1) FROM actor GROUP BY last_name
 HAVING COUNT(last_name) > 1;
 
 -- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
 -- Write a query to fix the record.
 SELECT  * FROM actor WHERE first_name = 'GROUCHO' AND last_name= 'WILLIAMS';
UPDATE actor SET first_name='HARPO' WHERE actor_id=172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name 
-- after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name='GROUCHO' WHERE actor_id=172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;
SHOW COLUMNS FROM address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
--  Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
address.address_id=staff.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
-- staff.staff_id, staff.first_name, staff.last_name, staff.last_update
-- payment.payment_id, payment.staff_id, payment.amount, payment.payment_date, payment.last_updatepayment_date


SELECT SUM(payment.amount) AS Amount_Rung, payment.payment_date, payment.staff_id
FROM staff INNER JOIN payment ON staff.staff_id=payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY payment.staff_id;
 

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
-- film_actor.actor_id, film_actor.film_id, 

SELECT film.title, COUNT(film_actor.actor_id) AS Number_of_Actors
FROM film_actor INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film.title; 


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id) AS Hunchback_Impossible FROM inventory WHERE film_id = 439; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
--  List the customers alphabetically by last name: ORDER BY ..  ASC
-- payment.payment_id , payment.customer_id, payment.amount
-- customer.customer_id, customer.last_name, customer.first_name 

SELECT SUM(payment.amount), customer.last_name, customer.first_name
 FROM customer
 INNER JOIN payment ON customer.customer_id = payment.customer_id 
 GROUP BY customer.customer_id
 ORDER BY customer.last_name;

-- 7a Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- film.title , film.language_id, film.film_id, 
-- language.language_id

SELECT title
	FROM film
    WHERE title = 'K%' OR 'Q%'
    IN (
          SELECT language_id
            FROM film
            WHERE language_id = 1
            );

            
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT  first_name, last_name

FROM actor

WHERE actor_id


	IN (SELECT actor_id FROM film_actor WHERE film_id


		IN (SELECT film_id from film where title='ALONE TRIP')
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- country.country, country.country_id 
SELECT cu.first_name, cu.last_name, cu.email, cntry.country
FROM customer cu
JOIN address a ON (cu.address_id = a.address_id)
JOIN  country cntry ON (cntry.country='Canada');

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
-- category.name, category.category_id
-- film_category.film_id, film_category.category_id

SELECT f.title, c.name
FROM film f
JOIN film_category fcat ON (f.film_id=fcat.film_id)
JOIN category c ON (c.name = 'Family');

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(f.film_id) AS 'Count_of_Rented_Movies'
FROM  film f
JOIN inventory i ON (f.film_id= i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY title ORDER BY Count_of_Rented_Movies DESC;

-- #7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS 'Total Made' 
FROM payment p
JOIN staff s ON (p.staff_id=s.staff_id) 
GROUP BY store_id;

-- #7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city c ON (a.city_id=c.city_id)
JOIN country cntry ON (c.country_id=cntry.country_id);

-- #7h. List the top five genres in gross revenue in descending order.
--  (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross DESC LIMIT 5 ; 

-- #8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
DROP TABLE IF  EXISTS Genre_Revenue;
CREATE VIEW Genre_Revenue AS 
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  DESC LIMIT 5;

-- #8b. How would you display the view that you created in 8a?
SELECT *FROM genre_revenue;

-- #8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW genre_revenue;




