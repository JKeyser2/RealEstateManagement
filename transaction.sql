-- 5. Change the partner assigned to an owner and transfer all current (non-expired) leases to the new partner

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SHOW VARIABLES LIKE 'transaction_isolation';


-- Shows the partner id (4) assigned to an owner
SELECT lease_id, owner_id, partner_id, rental_id FROM lease WHERE owner_id = 19

-- Creates the transaction. Changes partner id from 4 to 5
START TRANSACTION;

UPDATE lease
SET partner_id = 5
WHERE owner_id = 19;

COMMIT;


-- Shows the partner id (5) assigned to an owner now
SELECT lease_id, owner_id, partner_id, rental_id FROM lease WHERE owner_id = 19