-- ═══════════════════════════════════════════════════════════
--  Company Management System - SQL Schema
--  Generated from ER Diagram
-- ═══════════════════════════════════════════════════════════

DROP DATABASE IF EXISTS company_system;
CREATE DATABASE company_system;
USE company_system;

-- ─────────────────────────────────────────
--  JOB
-- ─────────────────────────────────────────
CREATE TABLE job (
    jobName     VARCHAR(50)     PRIMARY KEY,
    paid        DECIMAL(10,2)   NOT NULL
);

-- ─────────────────────────────────────────
--  EMPLOYEE
--  (Address is a composite attribute -> Street, City)
--  (Name is composite -> First name, Last name)
-- ─────────────────────────────────────────
CREATE TABLE employee (
    empID           INT             PRIMARY KEY AUTO_INCREMENT,
    firstName       VARCHAR(50)     NOT NULL,
    lastName        VARCHAR(50)     NOT NULL,
    phoneNumber     VARCHAR(20),
    street          VARCHAR(100),
    city            VARCHAR(50),
    hireDate        DATE,
    supervisorID    INT             NULL,               -- self-referencing (M:1 "1" side near employee loop)
    jobName         VARCHAR(50)     NOT NULL,            -- FK from "works on" (M employees : 1 job)
    FOREIGN KEY (supervisorID) REFERENCES employee(empID) ON DELETE SET NULL,
    FOREIGN KEY (jobName) REFERENCES job(jobName) ON DELETE RESTRICT
);

-- ─────────────────────────────────────────
--  CLIENT
-- ─────────────────────────────────────────
CREATE TABLE client (
    clientID    INT             PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100)    NOT NULL,
    phone       VARCHAR(20),
    addr        VARCHAR(150),
    city        VARCHAR(50),
    street      VARCHAR(100)
);

-- ─────────────────────────────────────────
--  DEBT
--  (client "has" Debt, M:1 -> one client can have many debts)
-- ─────────────────────────────────────────
CREATE TABLE debt (
    pk          INT             PRIMARY KEY AUTO_INCREMENT,
    date        DATE            NOT NULL,
    time        TIME            NOT NULL,
    amount      DECIMAL(10,2)   NOT NULL,
    status      VARCHAR(30)     NOT NULL,
    clientID    INT             NOT NULL,
    FOREIGN KEY (clientID) REFERENCES client(clientID) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  SUPPLIER
-- ─────────────────────────────────────────
CREATE TABLE supplier (
    sid             INT             PRIMARY KEY AUTO_INCREMENT,
    supplierName    VARCHAR(100)    NOT NULL,
    phone           VARCHAR(20)
);

-- ─────────────────────────────────────────
--  COMPANY
-- ─────────────────────────────────────────
CREATE TABLE company (
    companyName     VARCHAR(100)    PRIMARY KEY
);

-- ─────────────────────────────────────────
--  PRODUCT
-- ─────────────────────────────────────────
CREATE TABLE product (
    productID       INT             PRIMARY KEY AUTO_INCREMENT,
    productName     VARCHAR(100)    NOT NULL,
    sellingPrice    DECIMAL(10,2)   NOT NULL
);

-- ─────────────────────────────────────────
--  ITEM_TYPE
--  ("make" relationship: company -M-> item_type, "1" side near company)
-- ─────────────────────────────────────────
CREATE TABLE item_type (
    item            VARCHAR(50)     PRIMARY KEY,
    quitley         VARCHAR(50),                        -- (quantity/quality attribute as labeled in diagram)
    companyName     VARCHAR(100)    NOT NULL,
    FOREIGN KEY (companyName) REFERENCES company(companyName) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  PROVIDE  (Supplier M : 1 Company)
-- ─────────────────────────────────────────
CREATE TABLE provide (
    sid             INT             NOT NULL,
    companyName     VARCHAR(100)    NOT NULL,
    PRIMARY KEY (sid, companyName),
    FOREIGN KEY (sid) REFERENCES supplier(sid) ON DELETE CASCADE,
    FOREIGN KEY (companyName) REFERENCES company(companyName) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  STOCK
--  ASSUMPTION: diagram shows TWO separate diamonds between employee and stock
--  ("sending" and "organize"), both M:M-looking. Modeled here as a single
--  empID FK on stock (one employee organizes/manages a given stock record).
--  If "sending" is meant to be a distinct M:M relationship, it needs its
--  own junction table - see note in README.
-- ─────────────────────────────────────────
CREATE TABLE stock (
    serialNumber    INT             PRIMARY KEY AUTO_INCREMENT,
    stockPosition   VARCHAR(50),
    empID           INT             NOT NULL,           -- organize (employee M : stock)
    productID       INT             NOT NULL,           -- store (stock M : 1 product)
    FOREIGN KEY (empID) REFERENCES employee(empID) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  RECEIVE  (employee M : M supplier — item receiving log)
-- ─────────────────────────────────────────
CREATE TABLE receive (
    empID           INT             NOT NULL,
    sid             INT             NOT NULL,
    reviveDate      DATE            NOT NULL,
    itemSupplierPrice DECIMAL(10,2),
    PRIMARY KEY (empID, sid, reviveDate),
    FOREIGN KEY (empID) REFERENCES employee(empID) ON DELETE CASCADE,
    FOREIGN KEY (sid) REFERENCES supplier(sid) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  REQUEST  (employee M : M supplier — item requesting log)
-- ─────────────────────────────────────────
CREATE TABLE request (
    empID           INT             NOT NULL,
    sid             INT             NOT NULL,
    requestDate     DATE            NOT NULL,
    productName     VARCHAR(100),
    PRIMARY KEY (empID, sid, requestDate),
    FOREIGN KEY (empID) REFERENCES employee(empID) ON DELETE CASCADE,
    FOREIGN KEY (sid) REFERENCES supplier(sid) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  SALE
--  (client "makes" sale, M:1 -> one client can make many sales)
-- ─────────────────────────────────────────
CREATE TABLE sale (
    pk              INT             PRIMARY KEY AUTO_INCREMENT,
    date            DATE            NOT NULL,
    time            TIME            NOT NULL,
    itemSaleQuntity INT             NOT NULL,
    clientID        INT             NOT NULL,
    FOREIGN KEY (clientID) REFERENCES client(clientID) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  CONTAINS  (sale M : M product — line items of a sale)
-- ─────────────────────────────────────────
CREATE TABLE contains (
    saleID          INT             NOT NULL,
    productID       INT             NOT NULL,
    soldItemPrice   DECIMAL(10,2)   NOT NULL,
    PRIMARY KEY (saleID, productID),
    FOREIGN KEY (saleID) REFERENCES sale(pk) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE
);

-- ═══════════════════════════════════════════════════════════
--  END OF SCHEMA
-- ═══════════════════════════════════════════════════════════
