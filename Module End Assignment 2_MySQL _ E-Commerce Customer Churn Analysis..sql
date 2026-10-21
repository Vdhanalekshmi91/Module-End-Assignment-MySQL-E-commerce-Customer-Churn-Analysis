USE ecomm;

-- DATA CLEANING

-- IMPUTATION BY MEAN

SELECT ROUND(AVG(WarehouseToHome)) FROM customer_churn;
SET SQL_SAFE_UPDATES = 0;
UPDATE customer_churn SET WarehouseToHome = 16 WHERE WarehouseToHome IS NULL;
SELECT ROUND(AVG(HourSpendOnApp)) FROM customer_churn;
UPDATE customer_churn SET HourSpendOnApp = 3 WHERE HourSpendOnApp IS NULL;
SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) FROM customer_churn;
UPDATE customer_churn SET OrderAmountHikeFromlastYear = 16 WHERE OrderAmountHikeFromlastYear IS NULL;
SELECT ROUND(AVG(DaySinceLastOrder)) FROM customer_churn;
UPDATE customer_churn SET DaySinceLastOrder = 5 WHERE DaySinceLastOrder IS NULL;

-- IMPUTATION BY MODE
 
SELECT Tenure, COUNT(*) AS frequency FROM customer_churn WHERE Tenure IS NOT NULL GROUP BY Tenure ORDER BY frequency DESC LIMIT 1;
UPDATE customer_churn SET Tenure = 1 WHERE Tenure IS NULL;
SELECT CouponUsed, COUNT(*) AS frequency FROM customer_churn WHERE CouponUsed IS NOT NULL GROUP BY CouponUsed ORDER BY frequency DESC LIMIT 1;
UPDATE customer_churn SET CouponUsed = 1 WHERE CouponUsed IS NULL;
SELECT OrderCount, COUNT(*) AS frequency FROM customer_churn WHERE OrderCount IS NOT NULL GROUP BY OrderCount ORDER BY frequency DESC LIMIT 1;
UPDATE customer_churn SET OrderCount = 2 WHERE OrderCount IS NULL;
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM customer_churn;

-- OUTLIER REMOVAL

SELECT CustomerID, WarehouseToHome FROM customer_churn WHERE WarehouseToHome > 100;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM customer_churn WHERE WarehouseToHome > 100;
SET SQL_SAFE_UPDATES = 1;

-- CLEARING INCONSISTENCIES

SET SQL_SAFE_UPDATES = 0;
UPDATE customer_churn SET PreferredLoginDevice = 'Mobile Phone' WHERE PreferredLoginDevice = 'Phone';
UPDATE customer_churn SET PreferedOrderCat = 'Mobile Phone' WHERE PreferedOrderCat = 'Mobile';
UPDATE customer_churn SET PreferredPaymentMode = 'Cash on Delivery' WHERE PreferredPaymentMode = 'COD';
UPDATE customer_churn SET PreferredPaymentMode = 'Credit Card' WHERE PreferredPaymentMode = 'CC';

SELECT * FROM customer_churn;

-- DATA TRANSFORMATION

-- Column Renaming:

ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

-- Creating New Columns:

ALTER TABLE customer_churn ADD COLUMN ComplaintReceived VARCHAR(10);
UPDATE customer_churn SET ComplaintReceived = CASE 
WHEN Complain = 1 THEN 'Yes' ELSE 'No' END;
ALTER TABLE customer_churn ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn SET ChurnStatus = CASE 
WHEN Churn = 1 THEN 'Churned' ELSE 'Active' END;

SELECT * FROM customer_churn;

-- Column Dropping:
ALTER TABLE customer_churn DROP COLUMN Churn, DROP COLUMN Complain;

SELECT * FROM customer_churn;

-- DATA EXPLORATION AND ANALYSIS

SELECT ChurnStatus, COUNT(*) AS TotalCustomers FROM customer_churn GROUP BY ChurnStatus;
SELECT AVG(Tenure) AS AverageTenure, SUM(CashbackAmount) AS TotalCashback FROM customer_churn WHERE ChurnStatus = 'Churned';
SELECT (SUM(CASE WHEN ComplaintReceived = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS PercentageComplained
FROM customer_churn WHERE ChurnStatus = 'Churned';
SELECT CityTier, COUNT(*) AS ChurnedCount FROM customer_churn WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier ORDER BY ChurnedCount DESC LIMIT 1;
SELECT PreferredPaymentMode, COUNT(*) AS PaymentMethodCount FROM customer_churn WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode ORDER BY PaymentMethodCount DESC LIMIT 1;
SELECT SUM(OrderAmountHikeFromlastYear) AS TotalHikeAmount FROM customer_churn WHERE MaritalStatus = 'Single' 
AND PreferredLoginDevice = 'Mobile Phone';
SELECT AVG(NumberOfDeviceRegistered) AS AverageDevicesRegistered FROM customer_churn WHERE PreferredPaymentMode = 'UPI';
SELECT CityTier, COUNT(*) AS Total_No_of_Customers FROM customer_churn GROUP BY CityTier ORDER BY Total_No_of_Customers DESC LIMIT 1;
SELECT Gender, SUM(CouponUsed) AS TotalCouponsUsed FROM customer_churn GROUP BY Gender ORDER BY TotalCouponsUsed DESC LIMIT 1;
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount, MAX(HoursSpentOnApp) AS MaxHoursOnApp
FROM customer_churn GROUP BY PreferredOrderCat;
SELECT MAX(SatisfactionScore) AS HighestScore FROM customer_churn;
SELECT SUM(OrderCount) AS TotalOrdersPlaced FROM customer_churn WHERE PreferredPaymentMode = 'Credit Card'
AND SatisfactionScore = 5;
SELECT AVG(SatisfactionScore) AS AverageSatisfactionOfComplainers FROM customer_churn
WHERE ComplaintReceived = 'Yes';
SELECT DISTINCT PreferredOrderCat FROM customer_churn WHERE CouponUsed > 5;
SELECT PreferredOrderCat, AVG(CashbackAmount) AS AverageCashbackAmount FROM customer_churn GROUP BY PreferredOrderCat 
ORDER BY AverageCashbackAmount DESC LIMIT 3;
SELECT DISTINCT PreferredPaymentMode FROM customer_churn WHERE Tenure = 10 AND OrderCount > 500; 
SELECT CASE 
WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
WHEN WarehouseToHome <= 10 THEN 'Close Distance'
WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
ELSE 'Far Distance'
END AS DistanceCategory, ChurnStatus, COUNT(*) AS CustomerCount FROM customer_churn 
GROUP BY DistanceCategory, ChurnStatus ORDER BY DistanceCategory;
SELECT CustomerID, MaritalStatus, CityTier, OrderCount, PreferredOrderCat, PreferredPaymentMode, OrderAmountHikeFromlastYear, CouponUsed ,
DaySinceLastOrder, CashbackAmount FROM customer_churn WHERE MaritalStatus = 'Married' AND CityTier = 1
AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);

SET SQL_SAFE_UPDATES = 1;

USE ecomm;

CREATE TABLE customer_returns (
    ReturnID         INT PRIMARY KEY,
    CustomerID       INT,
    ReturnDate       DATE,
    RefundAmount     INT
);

INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

SELECT * FROM customer_returns;

SELECT 
    cust_retrn.ReturnID, cust_retrn.CustomerID, cust_retrn.ReturnDate, cust_retrn.RefundAmount,
    churn_data.Gender, churn_data.MaritalStatus, churn_data.CityTier, churn_data.ChurnStatus, churn_data.ComplaintReceived
FROM customer_returns AS cust_retrn INNER JOIN customer_churn AS churn_data 
ON cust_retrn.CustomerID = churn_data.CustomerID
WHERE churn_data.ChurnStatus = 'Churned' AND churn_data.ComplaintReceived = 'Yes';





  
  
  
  
  



































