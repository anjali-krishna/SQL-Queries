-- Using the Sakila DB

USE sakila;

SELECT * FROM actor;

-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.

SELECT CONCAT (first_name,'  ',last_name) as 'Actor Name'
FROM actor;

-- 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN

SELECT *
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- Order the rows by last name and first name, in that order

SELECT *
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name , first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China

SELECT country_id,country
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. Add a middle_name column to the table actor. 
-- Position it between first_name and last_name.

-- To get the data type of the colums
DESCRIBE actor;

ALTER TABLE actor
ADD middle_name varchar(45) NOT NULL AFTER first_name;

-- Verify the addition of column middle_name
SELECT * FROM actor;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.

ALTER TABLE actor
MODIFY column middle_name BLOB;

-- To verify the data type of the colum middle_name
DESCRIBE actor;

-- 3c. Now delete the middle_name column.

ALTER TABLE actor 
DROP `middle_name`;
 
-- Verify if the column middle_name is deleted
SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*) AS actor_count
FROM actor
GROUP BY last_name
ORDER BY actor_count DESC;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS actor_count
FROM actor
GROUP BY last_name
HAVING actor_count >= 2
ORDER BY actor_count ASC;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.

UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
	AND last_name = 'WILLIAMS';
 
 -- To verify the above fix, the below query should not return null any values
SELECT *
FROM actor
WHERE first_name = 'GROUCHO'
	AND last_name = 'WILLIAMS';

-- And the below query should return the desired fix (first_name as Harpo)

SELECT *
FROM actor
WHERE first_name = 'HARPO'
	AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, 
-- as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, 
-- HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = 
	CASE 
		WHEN first_name = "HARPO"
			THEN "GROUCHO"
		ELSE "MUCHO GROUCHO"
	END
WHERE actor_id = 172;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, 
-- as well as the address, of each staff member. 
-- Use the tables staff and address

SELECT s.first_name, s.last_name, a.address 
FROM staff AS s
JOIN address AS a
ON (s.address_id = a.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment

SELECT s.first_name, s.last_name, p.staff_id, sum(p.amount) AS 'Total Amount in $'
FROM staff AS s
INNER JOIN payment AS p
ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE "2005-08%"
GROUP BY p.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

SELECT f.title, 
COUNT(fa.actor_id) AS 'Number of Actors'
FROM film AS f
INNER JOIN film_actor AS fa
ON (f.film_id = fa.film_id)
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT f.title, (
	SELECT COUNT(*) FROM inventory AS i
	WHERE f.film_id = i.film_id
) AS 'Number of Copies'
FROM film AS f
WHERE f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer.
-- List the customers alphabetically by last name

SELECT customer.customer_id, customer.first_name, customer.last_name, sum(payment.amount) as 'Total Paid'
FROM customer 
INNER JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY customer_id 
ORDER BY customer.last_name; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
AND language_id IN (
	SELECT language_id
	FROM language
	WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT film_id 
		FROM film
		WHERE title = "Alone Trip")
		);
        
-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT  cust.first_name, cust.last_name, cust.email, country.country
FROM address AS a
JOIN city
ON (city.city_id =  a.city_id)
JOIN customer AS cust
ON (cust.address_id = a.address_id)
JOIN country
ON (country.country_id = city.country_id)
WHERE country.country = 'Canada';

-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.

SELECT film_id, title 
FROM film 
WHERE film_id IN(
	SELECT film_id 
    FROM film_category 
    WHERE category_id IN(
		SELECT category_id 
        FROM category 
        WHERE name = 'Family'
        )
	) ;
    
-- 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(f.title) AS 'Number_Rented'
FROM film AS f
JOIN inventory AS i 
ON(i.film_id = f.film_id)
JOIN rental AS r
ON (i.inventory_id = r.inventory_id)
GROUP BY f.title
ORDER BY COUNT(f.title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT staff.store_id, sum(payment.amount) AS 'Total Amount in  $' 
FROM staff 
LEFT JOIN payment 
ON payment.staff_id = staff.staff_id
GROUP BY staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, c.city, co.country
FROM store s
JOIN address a 
ON s.address_id = a.address_id
JOIN city c 
ON a.city_id = c.city_id
JOIN country co 
ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 

SELECT category.name, sum(payment.amount) AS 'Gross Revenue'
FROM film_category
JOIN category 
ON film_category.category_id = category.category_id
JOIN film 
ON  film_category.film_id = film.film_id
JOIN inventory 
ON film.film_id = inventory.film_id
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
JOIN payment 
ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC
limit 5;

-- 8a. In your new role as an executive, 
-- you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW `Top Genres` AS
SELECT category.name, sum(payment.amount) AS 'Gross Revenue'
FROM film_category
JOIN category 
ON film_category.category_id = category.category_id
JOIN film 
ON  film_category.film_id = film.film_id
JOIN inventory 
ON film.film_id = inventory.film_id
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
JOIN payment 
ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC
limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM  `Top Genres`;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `Top Genres`;