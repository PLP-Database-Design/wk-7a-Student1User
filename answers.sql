-- Question 1: Achieving 1NF (First Normal Form)

-- Task: You are given the following table ProductDetail:
-- OrderID    CustomerName    Products
-- 101        John Doe        Laptop, Mouse
-- 102        Jane Smith      Tablet, Keyboard, Mouse
-- 103        Emily Clark     Phone

-- The Products column contains multiple values, which violates 1NF.
-- I need to write an SQL query to transform this table into 1NF, ensuring that each row represents a single product for an order.

-- Approach:
-- I will normalize the Products column by creating a new row for each product associated with an OrderID. 
-- This will ensure that each row only contains one product per order.

CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255)
);

INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT OrderID, CustomerName, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n.n), ',', -1)) AS Product
FROM ProductDetail
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= n.n - 1
ORDER BY OrderID;

-- In this query, I split the Products column into separate rows using string manipulation techniques. 
-- Each product is placed on its own row, which satisfies 1NF.


-- Question 2: Achieving 2NF (Second Normal Form)

-- Task: You are given the following table OrderDetails, which is already in 1NF but still contains partial dependencies:
-- OrderID    CustomerName    Product    Quantity
-- 101        John Doe        Laptop     2
-- 101        John Doe        Mouse      1
-- 102        Jane Smith      Tablet     3
-- 102        Jane Smith      Keyboard   1
-- 102        Jane Smith      Mouse      2
-- 103        Emily Clark     Phone      1

-- The CustomerName column depends on OrderID (a partial dependency), which violates 2NF.
-- I need to write an SQL query to transform this table into 2NF by removing partial dependencies.

-- Approach:
-- To achieve 2NF, I will split the table into two tables:
-- 1. One table for Orders, which stores the OrderID and CustomerName.
-- 2. Another table for OrderDetails, which stores the OrderID, Product, and Quantity.
-- This eliminates the partial dependency where CustomerName only depends on OrderID.

-- Step 1: Create a new table for Orders (removes partial dependency)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(255)
);

-- Step 2: Insert unique OrderID and CustomerName into the Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 3: Create a new table for OrderDetails (with no partial dependency)
CREATE TABLE OrderDetails_2NF (
    OrderID INT,
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Step 4: Insert OrderID, Product, and Quantity into the OrderDetails_2NF table
INSERT INTO OrderDetails_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- In this solution, I removed the partial dependency by separating the Order information (OrderID and CustomerName) 
-- into its own table, Orders. I then moved the product and quantity details to a new table, OrderDetails_2NF, 
-- where each OrderID is linked to its respective products and quantities. This ensures that CustomerName only depends on OrderID 
-- and not on Product, achieving 2NF.
