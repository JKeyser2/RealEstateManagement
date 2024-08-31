-- 1. List the names of all (unique) clients.
SELECT DISTINCT CONCAT(first_name, ' ', last_name) AS client_name FROM property_client;



-- 2. Find the unique names of owners and total square footage of all the properties they own.
SELECT
CONCAT(property_owner.first_name, ' ', property_owner.last_name) AS owner_name,
    SUM(rental_property.area_square_footage) AS total_square_footage
FROM
    property_owner
JOIN
    owned_by ON property_owner.owner_id = owned_by.owner_id
JOIN
    rental_property ON owned_by.rental_id = rental_property.rental_id
GROUP BY
    property_owner.owner_id, owner_name;



-- 3. Find the properties shown by each associate in a given month.
SELECT
    CONCAT(associate.first_name, ' ', associate.last_name) AS associate_name,
    CONCAT(rental_property.street, ', ', rental_property.city, ', ', rental_property.state) AS property_address
FROM
    viewing_for_property
JOIN
    associate ON viewing_for_property.associate_id = associate.associate_id
JOIN
    rental_property ON viewing_for_property.rental_id = rental_property.rental_id
# 3 is the 3rd month -> March
WHERE
    MONTH(viewing_for_property.the_date) = 3
ORDER BY
    associate.associate_id, viewing_for_property.rental_id;



-- 4. Find the most popular properties (in terms of number of viewings) in a given period (range of dates). 
-- I did for the month of March
SELECT
    CONCAT(rental_property.street, ', ', rental_property.city, ', ', rental_property.state) AS property_address,
    COUNT(*) AS num_viewings
FROM
    viewing_for_property
JOIN
    rental_property ON viewing_for_property.rental_id = rental_property.rental_id
WHERE
    viewing_for_property.the_date BETWEEN '2024-03-01' AND '2024-03-31' -- Month of March
GROUP BY
    viewing_for_property.rental_id,
    rental_property.street,
    rental_property.city,
    rental_property.state
ORDER BY
    num_viewings DESC;
    


-- 5. Find the total rent due to each property owner in a given month year.
SELECT
    CONCAT(property_owner.first_name, ' ', property_owner.last_name) AS owner_name,
    SUM(lease.monthly_rent) AS total_rent_due
FROM
    lease
JOIN
    property_owner ON lease.owner_id = property_owner.owner_id
WHERE
    # Lease started before May 2024 and lease ends after May 2024
    DATE(lease.start_date) <= '2024-5-1' AND DATE(lease.end_date) >= '2024-5-31'
GROUP BY
    property_owner.owner_id,
    owner_name
ORDER BY
    total_rent_due DESC;
    
    
    
-- 6. Find the unique names of clients that were ever shown at least three or more unique residential properties owned by a given owner. 
-- For "residental properties owned by a given over", I chose "Rich Guy"
SELECT DISTINCT property_client.first_name, property_client.last_name
FROM viewing_for_property
JOIN rental_property ON viewing_for_property.rental_id = rental_property.rental_id
AND rental_property.property_type = 'Residential' -- Added condition here
JOIN owned_by ON rental_property.rental_id = owned_by.rental_id
JOIN property_owner ON owned_by.owner_id = property_owner.owner_id
JOIN property_client ON viewing_for_property.client_id = property_client.client_id
-- "Given owner" is currently "Rich Guy"
WHERE property_owner.first_name = 'Rich'
AND property_owner.last_name = 'Guy'
GROUP BY property_client.first_name, property_client.last_name
HAVING COUNT(DISTINCT rental_property.rental_id) >= 3;



-- 7. Find the unique names of owners that have a residential property in every city where Pat Doe owns a commercial property.
-- 1. Gets every time a city is in the list of cities owned by Pat Doe
-- 2. Gets count of distinct cities
-- 3. Compares count of distinct cities to count of distinct cities owned by Pat Doe
-- 4. If numbers match, person fufills the criteria
SELECT po.first_name, po.last_name
FROM property_owner po
JOIN owned_by o ON po.owner_id = o.owner_id
JOIN rental_property r ON o.rental_id = r.rental_id
WHERE r.property_type = 'Residential'
-- Gets Every time a city is in the list of cities owned by Pat Doe
AND r.city IN (
    SELECT DISTINCT r2.city
    FROM rental_property r2
    JOIN owned_by o2 ON r2.rental_id = o2.rental_id
    JOIN property_owner po2 ON o2.owner_id = po2.owner_id
    WHERE r2.property_type = 'Commercial'
    AND po2.first_name = 'Pat'
    AND po2.last_name = 'Doe'
)
GROUP BY po.first_name, po.last_name
-- Removes repeat cities, gets total
HAVING COUNT(DISTINCT r.city) = (
    SELECT COUNT(DISTINCT r2.city)
    FROM rental_property r2
    JOIN owned_by o2 ON r2.rental_id = o2.rental_id
    JOIN property_owner po2 ON o2.owner_id = po2.owner_id
    WHERE r2.property_type = 'Commercial'
    AND po2.first_name = 'Pat'
    AND po2.last_name = 'Doe'
);



-- 8. Find the top-3 partners with respect to number of properties leased in the current year.
SELECT partner.first_name, partner.last_name, COUNT(lease.rental_id) AS num_properties_leased
FROM partner
JOIN lease ON partner.partner_id = lease.partner_id
WHERE YEAR(lease.start_date) = 2024
GROUP BY partner.partner_id, partner.first_name, partner.last_name
ORDER BY num_properties_leased DESC
LIMIT 3;



-- 9.  Write a SQL function to compute the total management fees due to Pluto in the last 3 months. 
-- The next line of code creates the function
DELIMITER //

CREATE FUNCTION CalculateTotalManagementFeesDueToPluto()
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE total_fees DECIMAL(10,2);
    SELECT SUM(monthly_management_fee) INTO total_fees
    FROM rental_property;
    SET total_fees = total_fees * 3;
    RETURN total_fees;
END;
//

DELIMITER ;


-- Next line of code runs the function
SELECT CalculateTotalManagementFeesDueToPluto() AS total_management_fees_due_to_pluto;




-- 10. Create a SQL trigger to automatically set to FALSE the ADV flag of a property when it is leased.
-- The next line of code creates the trigger
DELIMITER //

CREATE TRIGGER SetADVFlagOnLease
AFTER INSERT ON lease
FOR EACH ROW
BEGIN
    UPDATE rental_property
    SET adv = FALSE
    WHERE rental_id = NEW.rental_id;
END;
//

DELIMITER ;

-- The next line of code shows the adv boolean before the trigger
SELECT adv
FROM rental_property
WHERE rental_id = 777777;


-- The next line of code creates the new lease
INSERT INTO lease (lease_id, client_id, owner_id, partner_id, rental_id, the_date, monthly_rent, deposit, lease_duration, start_date, end_date)
VALUES (123456, 000009, 000051, 000005, 777777, "4/1/2024", 100, 100, "3 months", "2024-4-1", "2024-7-1");


-- The next line of code shows the adv boolean after the new lease was created
SELECT adv
FROM rental_property
WHERE rental_id = 777777;