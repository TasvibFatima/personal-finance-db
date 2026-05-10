-- ================================================
-- Personal Finance & Budget Management System
-- Database Schema
-- Author: Tasvib Fatima
-- University of Lahore — Database Systems Project
-- ================================================

-- ------------------------------------------------
-- TABLE: USER
-- ------------------------------------------------
CREATE TABLE USER (
    user_id     INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    role        VARCHAR(20) DEFAULT 'user',
    created_at  DATE NOT NULL
);

-- ------------------------------------------------
-- TABLE: ADMIN
-- ------------------------------------------------
CREATE TABLE ADMIN (
    admin_id    INT PRIMARY KEY AUTO_INCREMENT,
    user_id     INT NOT NULL,
    permissions VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE
);

-- ------------------------------------------------
-- TABLE: ACCOUNT
-- ------------------------------------------------
CREATE TABLE ACCOUNT (
    account_id    INT PRIMARY KEY AUTO_INCREMENT,
    user_id       INT NOT NULL,
    account_name  VARCHAR(50) NOT NULL,
    account_type  VARCHAR(50) NOT NULL,  -- e.g. Bank, JazzCash, Cash
    balance       DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE
);

-- ------------------------------------------------
-- TABLE: CATEGORY
-- ------------------------------------------------
CREATE TABLE CATEGORY (
    category_id   INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    category_type VARCHAR(20) NOT NULL   -- 'income' or 'expense'
);

-- ------------------------------------------------
-- TABLE: TRANSACTION
-- ------------------------------------------------
CREATE TABLE TRANSACTION (
    transaction_id   INT PRIMARY KEY AUTO_INCREMENT,
    user_id          INT NOT NULL,
    category_id      INT NOT NULL,
    account_id       INT NOT NULL,
    amount           DECIMAL(10,2) NOT NULL,
    transaction_date DATE NOT NULL,
    description      VARCHAR(100),
    FOREIGN KEY (user_id)     REFERENCES USER(user_id)         ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id) ON DELETE RESTRICT,
    FOREIGN KEY (account_id)  REFERENCES ACCOUNT(account_id)   ON DELETE RESTRICT
);

-- ------------------------------------------------
-- TABLE: BUDGET
-- ------------------------------------------------
CREATE TABLE BUDGET (
    budget_id      INT PRIMARY KEY AUTO_INCREMENT,
    user_id        INT NOT NULL,
    category_id    INT NOT NULL,
    budget_amount  DECIMAL(10,2) NOT NULL,
    month          VARCHAR(20) NOT NULL,   -- e.g. 'January 2026'
    FOREIGN KEY (user_id)     REFERENCES USER(user_id)         ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id) ON DELETE RESTRICT
);

-- ------------------------------------------------
-- TABLE: INCOME
-- ------------------------------------------------
CREATE TABLE INCOME (
    income_id   INT PRIMARY KEY AUTO_INCREMENT,
    user_id     INT NOT NULL,
    account_id  INT NOT NULL,
    amount      DECIMAL(10,2) NOT NULL,
    source      VARCHAR(50),
    date        DATE NOT NULL,
    FOREIGN KEY (user_id)    REFERENCES USER(user_id)       ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES ACCOUNT(account_id) ON DELETE RESTRICT
);

-- ------------------------------------------------
-- TABLE: EXPENSE
-- ------------------------------------------------
CREATE TABLE EXPENSE (
    expense_id  INT PRIMARY KEY AUTO_INCREMENT,
    user_id     INT NOT NULL,
    category_id INT NOT NULL,
    account_id  INT NOT NULL,
    amount      DECIMAL(10,2) NOT NULL,
    date        DATE NOT NULL,
    FOREIGN KEY (user_id)     REFERENCES USER(user_id)         ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id) ON DELETE RESTRICT,
    FOREIGN KEY (account_id)  REFERENCES ACCOUNT(account_id)   ON DELETE RESTRICT
);

-- ------------------------------------------------
-- TABLE: REPORT
-- ------------------------------------------------
CREATE TABLE REPORT (
    report_id      INT PRIMARY KEY AUTO_INCREMENT,
    user_id        INT NOT NULL,
    report_type    VARCHAR(50),   -- e.g. 'Monthly', 'Annual'
    generated_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE
);

-- ------------------------------------------------
-- TABLE: NOTIFICATION
-- ------------------------------------------------
CREATE TABLE NOTIFICATION (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id         INT NOT NULL,
    message         VARCHAR(255),
    status          VARCHAR(20) DEFAULT 'unread',
    created_at      DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE
);

-- ------------------------------------------------
-- SAMPLE DATA
-- ------------------------------------------------

INSERT INTO USER (name, email, password, role, created_at) VALUES
('Tasvib Fatima', 'tasvib@example.com', 'hashed_password_1', 'user', '2026-01-01'),
('Admin User',    'admin@example.com',  'hashed_password_2', 'admin','2026-01-01');

INSERT INTO CATEGORY (category_name, category_type) VALUES
('Salary',     'income'),
('Freelance',  'income'),
('Food',       'expense'),
('Transport',  'expense'),
('Shopping',   'expense'),
('Utilities',  'expense');

INSERT INTO ACCOUNT (user_id, account_name, account_type, balance) VALUES
(1, 'HBL Account', 'Bank',     50000.00),
(1, 'JazzCash',    'JazzCash', 12000.00),
(1, 'Cash Wallet', 'Cash',      5000.00);

INSERT INTO INCOME (user_id, account_id, amount, source, date) VALUES
(1, 1, 45000.00, 'Monthly Salary',   '2026-01-01'),
(1, 2, 15000.00, 'Freelance Project','2026-01-15');

INSERT INTO EXPENSE (user_id, category_id, account_id, amount, date) VALUES
(1, 3, 3, 3000.00, '2026-01-05'),
(1, 4, 2, 1500.00, '2026-01-10'),
(1, 5, 1, 5000.00, '2026-01-20');

INSERT INTO BUDGET (user_id, category_id, budget_amount, month) VALUES
(1, 3, 4000.00,  'January 2026'),
(1, 4, 2000.00,  'January 2026'),
(1, 5, 6000.00,  'January 2026');

-- ------------------------------------------------
-- USEFUL QUERIES
-- ------------------------------------------------

-- Total income for a user in January 2026
SELECT SUM(amount) AS total_income
FROM INCOME
WHERE user_id = 1 AND date BETWEEN '2026-01-01' AND '2026-01-31';

-- Total expenses for a user in January 2026
SELECT SUM(amount) AS total_expenses
FROM EXPENSE
WHERE user_id = 1 AND date BETWEEN '2026-01-01' AND '2026-01-31';

-- Expenses by category
SELECT c.category_name, SUM(e.amount) AS total_spent
FROM EXPENSE e
JOIN CATEGORY c ON e.category_id = c.category_id
WHERE e.user_id = 1
GROUP BY c.category_name;

-- Budget vs actual spending
SELECT c.category_name, b.budget_amount, SUM(e.amount) AS actual_spent
FROM BUDGET b
JOIN CATEGORY c ON b.category_id = c.category_id
LEFT JOIN EXPENSE e ON e.category_id = b.category_id AND e.user_id = b.user_id
WHERE b.user_id = 1 AND b.month = 'January 2026'
GROUP BY c.category_name, b.budget_amount;

-- Account balances for a user
SELECT account_name, account_type, balance
FROM ACCOUNT
WHERE user_id = 1;
