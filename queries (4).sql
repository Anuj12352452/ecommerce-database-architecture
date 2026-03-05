

-- 1. Create Lookup Tables (Parents)
CREATE TABLE City (
  CityID INT AUTO_INCREMENT PRIMARY KEY,
  CityName VARCHAR(100),
  ZipCode VARCHAR(20)
);

CREATE TABLE Category (
  CategoryID INT AUTO_INCREMENT PRIMARY KEY,
  CategoryName VARCHAR(100),
  Description TEXT
);

CREATE TABLE Supplier (
  SupplierID INT AUTO_INCREMENT PRIMARY KEY,
  CompanyName VARCHAR(100),
  ContactEmail VARCHAR(100)
);

CREATE TABLE Employee (
  EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
  FirstName VARCHAR(50),
  LastName VARCHAR(50),
  JobTitle VARCHAR(50)
);

-- 2. Create Core Tables
CREATE TABLE Customer (
  CustomerID INT AUTO_INCREMENT PRIMARY KEY,
  FirstName VARCHAR(50),
  LastName VARCHAR(50),
  Email VARCHAR(100),
  Phone VARCHAR(20),
  AddressLine1 VARCHAR(255)
);

CREATE TABLE Product (
  ProductID INT AUTO_INCREMENT PRIMARY KEY,
  ProductName VARCHAR(100),
  Price DECIMAL(10, 2),
  StockQuantity INT,
  CategoryID INT,
  SupplierID INT,
  FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
  FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

CREATE TABLE Orders (
  OrderID INT AUTO_INCREMENT PRIMARY KEY,
  OrderDate DATE,
  CustomerID INT,
  CityID INT,
  EmployeeID INT,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (CityID) REFERENCES City(CityID),
  FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE OrderDetails (
  TransactionID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT,
  ProductID INT,
  Quantity INT,
  UnitPrice DECIMAL(10, 2),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE Payment (
  PaymentID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT,
  PaymentDate DATE,
  Method VARCHAR(50),
  Amount DECIMAL(10, 2),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE Delivery (
  DeliveryID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT,
  DeliveryDate DATE,
  VehicleType VARCHAR(50),
  Status VARCHAR(50),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


INSERT INTO City (CityName, ZipCode) VALUES 
('London', 'SW1A'), ('Manchester', 'M1'), ('Birmingham', 'B2');

INSERT INTO Category (CategoryName) VALUES 
('Fresh Produce'), ('Beverages'), ('Bakery');

INSERT INTO Supplier (CompanyName) VALUES 
('GreenFarm Ltd'), ('FreshBakes Co');

INSERT INTO Employee (FirstName, JobTitle) VALUES 
('James', 'Driver'), ('Lara', 'Manager');

INSERT INTO Customer (FirstName, LastName, Email, Phone) VALUES 
('John', 'Doe', 'john@email.com', '07700123456'),
('Sarah', 'Smith', 'sarah@email.com', '07700987654'),
('Mike', 'Jones', 'mike@email.com', '07700555555');

INSERT INTO Product (ProductName, Price, StockQuantity, CategoryID, SupplierID) VALUES 
('Organic Bananas', 1.50, 100, 1, 1),
('Sourdough Bread', 3.20, 50, 3, 2),
('Orange Juice', 2.50, 200, 2, 1),
('Avocados', 4.00, 80, 1, 1),
('Mineral Water', 1.00, 150, 2, 1);

INSERT INTO Orders (OrderDate, CustomerID, CityID, EmployeeID) VALUES 
('2025-01-10', 1, 1, 1), 
('2025-01-12', 2, 2, 2),
('2025-01-14', 3, 1, 1);

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES 
(1, 1, 2, 1.50), 
(1, 2, 1, 3.20), 
(2, 3, 4, 2.50),
(3, 4, 2, 4.00);

INSERT INTO Payment (OrderID, PaymentDate, Amount) VALUES 
(1, '2025-01-10', 6.20),
(2, '2025-01-12', 10.00),
(3, '2025-01-14', 8.00);

INSERT INTO Delivery (OrderID, Status) VALUES 
(1, 'Delivered'), (2, 'In Transit'), (3, 'Pending');

-- Verify it worked by showing all customers
SELECT * FROM Customer;

-- Section 6.1: Total Sales by Category (2025)
SELECT 
    c.CategoryName, 
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM Category c
JOIN Product p ON c.CategoryID = p.CategoryID
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY c.CategoryName;

-- Section 6.2: Top 10 Popular Products
SELECT 
    p.ProductName, 
    c.CategoryName, 
    SUM(od.Quantity) AS TotalItemsSold,
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName, c.CategoryName
ORDER BY TotalItemsSold DESC
LIMIT 10;

-- Section 6.3: Customer Order History
SELECT 
    cu.FirstName, 
    cu.LastName, 
    cu.Email, 
    COUNT(o.OrderID) AS TotalOrdersPlaced
FROM Customer cu
JOIN Orders o ON cu.CustomerID = o.CustomerID
GROUP BY cu.CustomerID, cu.FirstName, cu.LastName, cu.Email;

-- Section 6.4: Current Inventory Levels
SELECT 
    p.ProductName, 
    c.CategoryName, 
    p.StockQuantity
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
ORDER BY p.StockQuantity ASC; 
-- Ordered ASC to show low stock first (good for "alerts")-- Section 6.4: Current Inventory Levels
SELECT 
    p.ProductName, 
    c.CategoryName, 
    p.StockQuantity
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
ORDER BY p.StockQuantity ASC; 
-- Ordered ASC to show low stock first (good for "alerts")

-- Section 6.5: Revenue by City
SELECT 
    ci.CityName, 
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
FROM City ci
JOIN Orders o ON ci.CityID = o.CityID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY ci.CityName
ORDER BY TotalRevenue DESC;

-- Section 7.1: Daily Revenue Summary Report
SELECT 
    o.OrderDate AS 'Date',
    COUNT(DISTINCT o.OrderID) AS 'Total Orders',
    SUM(od.Quantity) AS 'Items Sold',
    CONCAT('£', FORMAT(SUM(od.Quantity * od.UnitPrice), 2)) AS 'Total Revenue'
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderDate
ORDER BY o.OrderDate DESC;



-- Query to get data for "Revenue by City" Bar Chart
SELECT 
    ci.CityName, 
    SUM(od.Quantity * od.UnitPrice) AS Revenue
FROM City ci
JOIN Orders o ON ci.CityID = o.CityID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY ci.CityName;

-- Advanced Feature: View for Marketing Team
CREATE VIEW CustomerContactList AS
SELECT FirstName, LastName, Email
FROM Customer;

-- Testing the View
SELECT * FROM CustomerContactList;