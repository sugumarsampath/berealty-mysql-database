-- ============================================================
-- Berealty Real Estate Property Management Database
-- Schema definition (MySQL / MariaDB)
-- ============================================================
DROP DATABASE IF EXISTS berealty;
CREATE DATABASE berealty CHARACTER SET utf8mb4;
USE berealty;

-- ------------------------------------------------------------
-- AGENTS: the agency's employees who list properties and
-- close transactions
-- ------------------------------------------------------------
CREATE TABLE agents (
    agent_id        INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(25)  NOT NULL,
    hire_date       DATE         NOT NULL,
    commission_rate DECIMAL(4,3) NOT NULL DEFAULT 0.030
                    CHECK (commission_rate BETWEEN 0 AND 0.20)
);

-- ------------------------------------------------------------
-- CLIENTS: buyers, sellers, tenants and landlords
-- ------------------------------------------------------------
CREATE TABLE clients (
    client_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(25),
    client_type     ENUM('buyer','seller','tenant','landlord') NOT NULL,
    registered_date DATE NOT NULL
);

-- ------------------------------------------------------------
-- PROPERTIES: the portfolio; each property is managed by one agent
-- ------------------------------------------------------------
CREATE TABLE properties (
    property_id   INT AUTO_INCREMENT PRIMARY KEY,
    agent_id      INT NOT NULL,
    title         VARCHAR(120) NOT NULL,
    property_type ENUM('apartment','house','office','retail') NOT NULL,
    district      VARCHAR(50)  NOT NULL,
    address       VARCHAR(150) NOT NULL,
    size_sqm      DECIMAL(7,1) NOT NULL CHECK (size_sqm > 0),
    rooms         TINYINT UNSIGNED,
    listing_type  ENUM('sale','rent') NOT NULL,
    price         DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    status        ENUM('available','under_offer','sold','rented')
                  NOT NULL DEFAULT 'available',
    listed_date   DATE NOT NULL,
    CONSTRAINT fk_prop_agent FOREIGN KEY (agent_id)
        REFERENCES agents(agent_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- VIEWINGS: appointments between clients and properties
-- ------------------------------------------------------------
CREATE TABLE viewings (
    viewing_id   INT AUTO_INCREMENT PRIMARY KEY,
    property_id  INT NOT NULL,
    client_id    INT NOT NULL,
    agent_id     INT NOT NULL,
    viewing_date DATETIME NOT NULL,
    feedback     VARCHAR(255),
    CONSTRAINT fk_view_prop   FOREIGN KEY (property_id)
        REFERENCES properties(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_view_client FOREIGN KEY (client_id)
        REFERENCES clients(client_id)      ON DELETE CASCADE,
    CONSTRAINT fk_view_agent  FOREIGN KEY (agent_id)
        REFERENCES agents(agent_id)        ON DELETE RESTRICT,
    CONSTRAINT uq_viewing UNIQUE (property_id, client_id, viewing_date)
);

-- ------------------------------------------------------------
-- TRANSACTIONS: completed sales and rentals
-- ------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
    property_id      INT NOT NULL,
    client_id        INT NOT NULL,
    agent_id         INT NOT NULL,
    transaction_type ENUM('sale','rental') NOT NULL,
    transaction_date DATE NOT NULL,
    amount           DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    commission       DECIMAL(10,2),
    CONSTRAINT fk_tx_prop   FOREIGN KEY (property_id)
        REFERENCES properties(property_id) ON DELETE RESTRICT,
    CONSTRAINT fk_tx_client FOREIGN KEY (client_id)
        REFERENCES clients(client_id)      ON DELETE RESTRICT,
    CONSTRAINT fk_tx_agent  FOREIGN KEY (agent_id)
        REFERENCES agents(agent_id)        ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- AUDIT LOG: written automatically by trigger when a
-- property changes status
-- ------------------------------------------------------------
CREATE TABLE property_status_log (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    old_status  VARCHAR(20),
    new_status  VARCHAR(20),
    changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TRIGGERS
-- ============================================================
DELIMITER $$

-- Trigger 1: before a transaction is stored, compute the agent's
-- commission automatically from their personal commission rate
CREATE TRIGGER trg_tx_commission
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.commission IS NULL THEN
        SET NEW.commission = ROUND(
            NEW.amount * (SELECT commission_rate
                          FROM agents WHERE agent_id = NEW.agent_id), 2);
    END IF;
END$$

-- Trigger 2: when a transaction completes, update the property
-- status to sold / rented automatically
CREATE TRIGGER trg_tx_status
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    UPDATE properties
    SET status = IF(NEW.transaction_type = 'sale', 'sold', 'rented')
    WHERE property_id = NEW.property_id;
END$$

-- Trigger 3: audit trail of every property status change
CREATE TRIGGER trg_status_audit
AFTER UPDATE ON properties
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO property_status_log(property_id, old_status, new_status)
        VALUES (NEW.property_id, OLD.status, NEW.status);
    END IF;
END$$

DELIMITER ;
