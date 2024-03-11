-- Usa el esquema de sakila antes de ejecutar cualquier otra query
USE `sakila`;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.
-- Ya que la Primary Key es la ID y no el titulo de la película, para asegurar que no haya duplicados a la hora de mostrar los resultados de la query, se aplica DISTINCT a la columna en cuestión
SELECT DISTINCT(`title`)
FROM `film`;

-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".
-- En esta ocasión (y ya que no se especifica que sean títulos únicos), no se añade el DISTINCT y se incorpora un condicional para revisar que los títulos mostrados tengan un rating "PG-13"
SELECT `title`
FROM `film`
WHERE `rating` = "PG-13";

-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.
-- Añade una columna más, descripción, y un condicional para asegurar que esa descripción incluya la palabra "amazing" en cualquier posición dentro del texto
SELECT `title`, 
		`description`
FROM `film`
WHERE `description` LIKE "%amazing%";

-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.
-- Usa el condicional de la cláusula WHERE para filtrar y mostrar únicamente aquellos títulos cuya duración supera los 120 min
SELECT `title`
FROM `film`
WHERE `length` > 120;

-- 5. Recupera los nombres de todos los actores.
-- Se entiende por 'nombres' sólo eso, no el nombre completo (que incluiría el apellido)
SELECT `first_name`
FROM `actor`;

-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.
-- Al decir "que tengan" se entiende que el apellido pueda contener Gibson, pero no necesariamente ser únicamente Gibson, por tanto se usaría de nuevo la cláusula WHERE con un LIKE "%gibson%" para indicar que este término pueda estar en cualquier parte del texto
SELECT `first_name`, 
		`last_name`
FROM `actor`
WHERE `last_name` LIKE "%Gibson%";

-- Si únicamente quisiéramos resultados que coincidieran con Gibson, sería:
SELECT `first_name`, 
		`last_name`
FROM `actor`
WHERE `last_name` = "Gibson";

-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.
-- La cláusula WHERE se utiliza junto a la BETWEEN para especificar y filtrar por un rango inclusivo de valores para el actor_id
SELECT `first_name` , 
		`actor_id`
FROM `actor`
WHERE `actor_id` BETWEEN 10 AND 20;

-- 8. Encuentra el título de las películas en la tabla `film` que no sean ni "R" ni "PG-13" en cuanto a su clasificación.
-- La cláusula NOT IN se utiliza para excluir las clasificaciones especificadas
SELECT `title`
FROM `film`
WHERE `rating` NOT IN ("PG-13" , "R");

-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla `film` y muestra la clasificación junto con el recuento.
-- Cuenta el número de películas empleando la función de agregación COUNT y agrupa los resultados (GROUP BY) por su clasificación
SELECT `rating` , 
		COUNT(`film_id`) AS `films`
FROM `film`
GROUP BY `rating`;

-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.
-- Une las tablas rental y customer para relacionar los alquileres con la información personal de cada cliente. Utiliza INNER JOIN para devolver coincidencias por customer_id
SELECT COUNT(`rental`.`rental_id`) AS `rented_movies`, 
		`rental`.`customer_id` , 
		`customer`.`first_name` , 
		`customer`.`last_name`
FROM `rental`
INNER JOIN `customer`
	ON `rental`.`customer_id` = `customer`.`customer_id`
GROUP BY `customer_id`;

-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
-- Emplea una CTE (Expresión de Tabla Común) para unir las tablas film_category y category y así obtener el nombre de la categoria. Se cuenta la cantidad de alquileres por categoria empleando la tabla rental, inventory y la CTE creada.
-- El uso de la CTE se ha priorizado al uso de una subconsulta por un tema de legibilidad y posible reutilización
WITH `pelis_categoria` AS (
							SELECT `film_category`.`film_id` AS `id` , 
									`category`.`name` AS `cat_name`
							FROM `film_category`
							INNER JOIN `category`
										ON `film_category`.`category_id` = `category`.`category_id`)
SELECT COUNT(`rental`.`rental_id`) AS `rentals`,  
		`pelis_categoria`.`cat_name` AS `category_name`
FROM `rental`
INNER JOIN `inventory`
			ON `rental`.`inventory_id` = `inventory`.`inventory_id`
INNER JOIN `pelis_categoria`
			ON `inventory`.`film_id` = `pelis_categoria`.`id`
GROUP BY `pelis_categoria`.`cat_name`;

-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla `film` y muestra la clasificación junto con el promedio de duración.
-- Usa la función de agregación AVG() para calcular el promedio de la columna length (duración) agrupado por la columna rating (clasificación)
SELECT `rating` , AVG(`length`) AS `avg_length`
FROM `film`
GROUP BY `rating`;

-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".
-- Usa una subconsulta para encontrar los IDs de los actores que aparecen en la película "Indian Love" y luego selecciona los nombres y apellidos de los actores correspondientes
-- En esta ocasión se ha empleado una subconsulta por tratarse de una consulta específica y no demasiado grande
SELECT `first_name` , 
		`last_name`
FROM `actor`
WHERE `actor_id` IN (
					SELECT `film_actor`.`actor_id`
					FROM `film_actor`
					INNER JOIN `film`
								ON `film_actor`.`film_id` = `film`.`film_id`
					WHERE `film`.`title` = "Indian Love");
                    
-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.
SELECT `title`
FROM `film`
WHERE `description` LIKE "%dog%" 
		OR `description` LIKE "%cat%";
	
-- 15. Hay algún actor o actriz que no apareca en ninguna película en la tabla `film_actor`.
-- Se usa LEFT JOIN para unir ambas tablas, ya que este mantiene todas las filas de la tabla izquierda (actor) aún cuando no encuentra coincidencias con la tabla derecha (film_actor)
SELECT `actor`.`actor_id` 
FROM `actor`
LEFT JOIN `film_actor`
			ON `actor`.`actor_id` = `film_actor`.`actor_id`
WHERE `film_actor`.`film_id` IS NULL;

-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.
SELECT `title` 
FROM `film`
WHERE `release_year` BETWEEN 2005 AND 2010;

-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".
-- Reutiliza la CTE del ejercicio 11, con algunas modificaciones, para traer de vuelta sólo aquellas IDs cuya categoría sea "Family" y une las tablas con inner join para que solo conserve aquellas que coincidan
WITH `pelis_categoria` AS (
							SELECT `film_category`.`film_id` AS `id`
							FROM `film_category`
							INNER JOIN `category`
										ON `film_category`.`category_id` = `category`.`category_id`
							WHERE `category`.`name` = "Family")
SELECT `title`
FROM `film`
INNER JOIN `pelis_categoria`
			ON `film`.`film_id` = `pelis_categoria`.`id`;
            
-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
-- Emplea HAVING después del GROUP BY para filtrar los resultados de la subconsulta basándose en que el recuento de veces que aparece el id del actor sea mayor que 10
SELECT `first_name` , 
		`last_name`
FROM `actor`
WHERE `actor_id` IN (
					SELECT `film_actor`.`actor_id` 
					FROM `film_actor`
					GROUP BY `actor_id`
					HAVING COUNT(`film_actor`.`actor_id`) > 10);

-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla `film`.
-- Al entender que la duración está en minutos, se emplea la equivalencia de 2h como tal (120 min) en la cláusula WHERE
SELECT `title`
FROM `film`
WHERE `rating` = "R" 
		AND `length` > 120;
        
-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.
-- Reutiliza la CTE del ejercicio 11, con algunas modificaciones para que muestre los nombres de las categorías. Une ambas tablas con INNER JOIN y filtra las categorías basadas en el promedio de duración indicado, empleando HAVING
WITH `pelis_categoria` AS (
							SELECT `film_category`.`film_id` AS `id` , 
									`category`.`name` AS `cat_name`
							FROM `film_category`
							INNER JOIN `category`
										ON `film_category`.`category_id` = `category`.`category_id`)
SELECT `pelis_categoria`.`cat_name` AS `category`, 
		AVG(`film`.`length`) AS `avg_length`
FROM `film`
INNER JOIN `pelis_categoria`
			ON `film`.`film_id` = `pelis_categoria`.`id`
GROUP BY `pelis_categoria`.`cat_name`
HAVING AVG(`film`.`length`) > 120;

-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.
-- Cuenta el numero de veces que aparece el id del actor como "apariciones" y filtra el resultado con la cláusula HAVING a almenos 5 películas ( >= 5 )
SELECT `actor`.`first_name` , 
		`actor`.`last_name`,
        COUNT(`film_actor`.`actor_id`) AS `appearances`
FROM `actor`
INNER JOIN `film_actor`
			ON `actor`.`actor_id` = `film_actor`.`actor_id`
GROUP BY `film_actor`.`actor_id`
HAVING COUNT(`film_actor`.`actor_id`) >= 5;

-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.
SELECT `film`.`title`
FROM `film`
INNER JOIN `inventory`
			ON `film`.`film_id` = `inventory`.`film_id`
INNER JOIN `rental` 
			ON `rental`.`inventory_id` = `inventory`.`inventory_id`
WHERE `rental`.`rental_id` IN (  
								-- Uso de la subconsulta propuesta
								SELECT `rental`.`rental_id`
								FROM `rental`
								WHERE DATEDIFF(`rental`.`return_date`, `rental`.`rental_date`) > 5)
GROUP BY `film`.`title`;

-- Método alternativo de resolución más conciso (pero sin subconsulta específica con rental_ids):
SELECT `film`.`title`
FROM `film`
WHERE `film`.`film_id` IN (
							SELECT `inventory`.`film_id` 
							FROM `inventory`
							INNER JOIN `rental` 
										ON `rental`.`inventory_id` = `inventory`.`inventory_id`
							WHERE DATEDIFF(`rental`.`return_date`, `rental`.`rental_date`) > 5
                            GROUP BY `inventory`.`film_id`);

-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.
-- Reutiliza la CTE del ejercicio 11 para tener acceso a una tabla temporal con los nombres de las categorías
WITH `pelis_categoria` AS (
							SELECT `film_category`.`film_id` AS `id` , 
									`category`.`name` AS `cat_name`
							FROM `film_category`
							INNER JOIN `category`
										ON `film_category`.`category_id` = `category`.`category_id`)
-- Consulta principal para encontrar los actores que no han actuado en películas de la categoría "Horror"
SELECT `actor`.`first_name` , 
		`actor`.`last_name`
FROM `actor`
INNER JOIN `film_actor`
			ON `actor`.`actor_id` = `film_actor`.`actor_id`
WHERE `film_actor`.`actor_id` NOT IN (
										-- Subconsulta que devuelve el listado de actores que han participado en una película cuya categoría es "Horror"
										SELECT `film_actor`.`actor_id`
                                        FROM `film_actor`
                                        INNER JOIN `pelis_categoria`
													ON `pelis_categoria`.`id` = `film_actor`.`film_id`
										WHERE `pelis_categoria`.`cat_name` = "Horror")
GROUP BY `actor`.`actor_id`; 

-- 24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla `film`.
-- Reutiliza la CTE del ejercicio 11 para tener acceso a una tabla temporal con los nombres de las categorías
WITH `pelis_categoria` AS (
							SELECT `film_category`.`film_id` AS `id` , 
									`category`.`name` AS `cat_name`
							FROM `film_category`
							INNER JOIN `category`
										ON `film_category`.`category_id` = `category`.`category_id`)
-- Consulta principal: Encuentra los títulos de aquellas películas cuya categoria sea Comedia y tengan una duración superior a 180 min empleando la cláusula WHERE con dos condiciones
SELECT `title`
FROM `film`
INNER JOIN `pelis_categoria`
			ON `pelis_categoria`.`id` = `film`.`film_id`
WHERE `pelis_categoria`.`cat_name` = "Comedy" 
		AND `length` > 180;
        
-- 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.
WITH `id_and_films` AS (
						SELECT `tabla1`.`actor_id` AS `Id_actor1`, 
								`tabla2`.`actor_id` AS `Id_actor2` , 
								COUNT(*) AS `films`
						FROM `film_actor` AS `tabla1`
						INNER JOIN `film_actor` AS `tabla2`
									ON `tabla1`.`actor_id` < `tabla2`.`actor_id` -- Especifica que el resultado de la tabla2 sea mayor en lugar de dejarlo como distinto para evitar duplicados (de esta manera, si la combinación de Ids 1 - 10 ya ha aparecido, luego no habrá 10 - 1) 
						WHERE `tabla1`.`film_id` = `tabla2`.`film_id`
						GROUP BY `tabla1`.`actor_id` , `tabla2`.`actor_id`
						HAVING COUNT(*) >= 1)
SELECT `a1`.`first_name` AS `actor1_name`,
		`a1`.`last_name` AS `actor1_lastname`,
        `a2`.`first_name` AS `actor2_name`,
        `a2`.`last_name` AS `actor2_lastname`,
        `ids`.`films` AS `films`
FROM `id_and_films` AS `ids`
INNER JOIN `actor` AS `a1`
			ON `a1`.`actor_id` = `ids`.`Id_actor1`
INNER JOIN `actor` AS `a2`
			ON `a2`.`actor_id` = `ids`.`Id_actor2`;
