-- ============================================================
-- Berealty — SQL query portfolio
-- ============================================================
USE berealty;

-- Q1. Property information retrieval: available apartments for
--     sale under €800,000, cheapest first
SELECT property_id, title, district, size_sqm, rooms, price
FROM properties
WHERE property_type = 'apartment' AND listing_type = 'sale'
  AND status = 'available' AND price < 800000
ORDER BY price;

-- Q2. Portfolio management: average asking price per district (sales)
SELECT district,
       COUNT(*)                AS listings,
       ROUND(AVG(price),0)     AS avg_price,
       ROUND(AVG(price/size_sqm),0) AS avg_eur_per_sqm
FROM properties
WHERE listing_type = 'sale'
GROUP BY district
ORDER BY avg_price DESC;

-- Q3. INNER JOIN: every completed transaction with its property,
--     client and responsible agent
SELECT t.transaction_id, t.transaction_date, t.transaction_type,
       p.title, p.district,
       CONCAT(c.first_name,' ',c.last_name) AS client,
       CONCAT(a.first_name,' ',a.last_name) AS agent,
       t.amount, t.commission
FROM transactions t
INNER JOIN properties p ON p.property_id = t.property_id
INNER JOIN clients    c ON c.client_id   = t.client_id
INNER JOIN agents     a ON a.agent_id    = t.agent_id
ORDER BY t.transaction_date;

-- Q4. Transactions handled by agents: performance league table
SELECT CONCAT(a.first_name,' ',a.last_name) AS agent,
       COUNT(t.transaction_id)   AS deals,
       COALESCE(SUM(t.amount),0)     AS total_volume,
       COALESCE(SUM(t.commission),0) AS total_commission
FROM agents a
LEFT JOIN transactions t ON t.agent_id = a.agent_id
GROUP BY a.agent_id
ORDER BY total_commission DESC;

-- Q5. Transactions for a client: full history for one client
SELECT t.transaction_date, t.transaction_type, p.title, p.district, t.amount
FROM transactions t
JOIN properties p ON p.property_id = t.property_id
WHERE t.client_id = (SELECT client_id FROM clients
                     WHERE email = 'omar.haddad@mail.de')
ORDER BY t.transaction_date;

-- Q6. LEFT JOIN: properties that have NEVER had a viewing
--     (marketing follow-up list)
SELECT p.property_id, p.title, p.district, p.status
FROM properties p
LEFT JOIN viewings v ON v.property_id = p.property_id
WHERE v.viewing_id IS NULL;

-- Q7. RIGHT JOIN: all clients, with their viewings if any
--     (clients with no viewing appear with NULLs)
SELECT CONCAT(c.first_name,' ',c.last_name) AS client,
       c.client_type, v.viewing_date, v.feedback
FROM viewings v
RIGHT JOIN clients c ON c.client_id = v.client_id
ORDER BY c.client_id, v.viewing_date;

-- Q8. CROSS JOIN: coverage matrix of every agent against every
--     district in the portfolio (territory planning)
SELECT CONCAT(a.first_name,' ',a.last_name) AS agent, d.district
FROM agents a
CROSS JOIN (SELECT DISTINCT district FROM properties) d
ORDER BY agent, district;

-- Q9. Subquery: sale listings priced above the average of
--     their OWN district (overpricing check)
SELECT p.title, p.district, p.price
FROM properties p
WHERE p.listing_type = 'sale'
  AND p.price > (SELECT AVG(p2.price)
                 FROM properties p2
                 WHERE p2.district = p.district
                   AND p2.listing_type = 'sale');

-- Q10. JOIN + subquery: the top-earning agent, with details
SELECT CONCAT(a.first_name,' ',a.last_name) AS agent,
       SUM(t.commission) AS commission_earned
FROM agents a
JOIN transactions t ON t.agent_id = a.agent_id
GROUP BY a.agent_id
HAVING SUM(t.commission) = (
    SELECT MAX(total) FROM (
        SELECT SUM(commission) AS total
        FROM transactions GROUP BY agent_id) x);

-- Q11. MONTHLY report: revenue and deal count per month
SELECT DATE_FORMAT(transaction_date,'%Y-%m') AS month,
       COUNT(*)          AS deals,
       SUM(amount)       AS volume,
       SUM(commission)   AS agency_revenue
FROM transactions
GROUP BY month
ORDER BY month;

-- Q12. QUARTERLY report: split by sales vs rentals
SELECT CONCAT(YEAR(transaction_date),'-Q',QUARTER(transaction_date)) AS quarter,
       transaction_type,
       COUNT(*)        AS deals,
       SUM(amount)     AS volume,
       SUM(commission) AS agency_revenue
FROM transactions
GROUP BY quarter, transaction_type
ORDER BY quarter, transaction_type;

-- Q13. YEARLY report: headline totals per year
SELECT YEAR(transaction_date) AS year,
       COUNT(*)               AS deals,
       SUM(amount)            AS volume,
       SUM(commission)        AS agency_revenue,
       ROUND(AVG(amount),0)   AS avg_deal_size
FROM transactions
GROUP BY year
ORDER BY year;

-- Q14. Complex: for each district, the most expensive completed
--      sale and the client who bought it (JOIN + correlated subquery)
SELECT p.district, p.title, t.amount,
       CONCAT(c.first_name,' ',c.last_name) AS buyer
FROM transactions t
JOIN properties p ON p.property_id = t.property_id
JOIN clients    c ON c.client_id   = t.client_id
WHERE t.transaction_type = 'sale'
  AND t.amount = (SELECT MAX(t2.amount)
                  FROM transactions t2
                  JOIN properties p2 ON p2.property_id = t2.property_id
                  WHERE p2.district = p.district
                    AND t2.transaction_type = 'sale');

-- ============================================================
-- TRIGGER DEMONSTRATION (live)
-- ============================================================
-- Step 1 — BEFORE: property 15 is still available, no commission exists
SELECT property_id, title, status FROM properties WHERE property_id = 15;

-- Step 2 — a sale is recorded WITHOUT specifying the commission
INSERT INTO transactions
    (property_id, client_id, agent_id, transaction_type, transaction_date, amount)
VALUES (15, 12, 6, 'sale', '2026-01-22', 748000.00);

-- Step 3 — AFTER: trg_tx_commission has computed the commission,
-- trg_tx_status has flipped the status, trg_status_audit logged it
SELECT t.transaction_id, t.amount, t.commission, p.status
FROM transactions t JOIN properties p ON p.property_id = t.property_id
WHERE t.property_id = 15;

SELECT * FROM property_status_log ORDER BY log_id DESC LIMIT 3;
