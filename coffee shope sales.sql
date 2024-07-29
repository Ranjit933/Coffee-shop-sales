create database coffee_shope_sales_db
show tables;

select * from dcoffee_shope_sales;

DESCRIBE dcoffee_shope_sales

UPDATE dcoffee_shope_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%Y-%m-%d');

ALTER TABLE dcoffee_shope_sales
MODIFY COLUMN transaction_date DATE;

DESCRIBE dcoffee_shope_sales

UPDATE dcoffee_shope_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE dcoffee_shope_sales
MODIFY COLUMN transaction_time TIME;

DESCRIBE dcoffee_shope_sales

ALTER TABLE dcoffee_shope_sales
CHANGE COLUMN transaction_idd transaction_id INT;


DESCRIBE dcoffee_shope_sales

-- KPI's REQURIMENTS
-- TOTAL SALES ANALYSIS
-- calculate the total sales of each respective month

-- for sum
SELECT SUM(unit_price * transaction_qty) AS Total_sales
FROM dcoffee_shope_sales

-- for specific month

SELECT ROUND(SUM(unit_price * transaction_qty),1) AS Total_sales
FROM dcoffee_shope_sales
WHERE
MONTH(transaction_date) =5 -- May Month

-- same query

SELECT CONCAT((ROUND(SUM(unit_price * transaction_qty)))/1000 , "K") AS Total_sales
FROM dcoffee_shope_sales
WHERE
MONTH(transaction_date) =3 -- March Month

-- Determine the month-on-month increase or decrease in sales.
-- select month / CM - May=5
-- PM - April =4


SELECT 
    MONTH(transaction_date) AS month, -- Number of month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, -- Total sales column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- Month sales difference
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- Division by PM sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- percentage
FROM 
    dcoffee_shope_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- Total order Analysis:
-- Calculate the total number of orders for each respective month.

SELECT 
    COUNT(transaction_id) AS Total_orders
FROM
    dcoffee_shope_sales
WHERE
    MONTH(transaction_date) = 3 -- March Month

-- Determine the month-on-month increase or decrease in the number of orders.

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders, 
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage 
FROM 
    dcoffee_shope_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    -- calculate the diffrence in the number of order between the selected month and the previous month.
    
    SELECT SUM(transaction_qty) AS Total_Quantity_sold
    FROM dcoffee_shope_sales
    WHERE
    MONTH(transaction_date) = 5 -- may month
    
    
    -- TOTAL QUANTITY SOLD ANALYSIS:
    -- Calculate the total quantity sold for each respective month.
    
    SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold, 
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage 
FROM 
    dcoffee_shope_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- Implement tooltips to desplay details matrics(sales,order,quantity)when hovering over a specific day

SELECT
   SUM(unit_price * transaction_qty) AS Total_sales,
   SUM(transaction_qty) AS Total_Qty_sold,
   COUNT(transaction_id) AS Total_orders
FROM dcoffee_shope_sales
WHERE
   transaction_date = '2023-05-18'
   
   -- concat function and round function
SELECT
   CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 1), 'K')  AS Total_sales,
   CONCAT(ROUND(SUM(transaction_qty)/1000, 1), 'K') AS Total_Qty_sold,
   CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS Total_orders
FROM dcoffee_shope_sales
WHERE
   transaction_date = '2023-05-18'

-- Segment sales data into weekdays and weekends to analyze performance variation.
-- Weekdays - Sat and Sun
-- Weekdays - Mon to Fri
   
   Sun = 1
   Mon = 2
   .
   .
   Sat = 7
   
   SELECT 
      CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
      ELSE 'Weekdays'
      END AS day_type,
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
	FROM dcoffee_shope_sales
    WHERE MONTH(transaction_date) = 2 -- Feb month
    GROUP BY
      CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
      ELSE 'Weekdays'
      END;
      
      -- sales analysis by store locartion
	
    SELECT
      store_location,
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS Total_sales
	FROM dcoffee_shope_sales
    WHERE MONTH(transaction_date) = 6 -- Jun
    GROUP BY store_location
    ORDER BY SUM(unit_price * transaction_qty) DESC
    
    -- basic avg function
    
    SELECT AVG(unit_price * transaction_qty) as Avg_Sales
    FROM dcoffee_shope_sales
    where month(transaction_date) = 5
    
    -- daily sales analysis with avg line:
    
    SELECT
      CONCAT(ROUND(AVG(total_sales)/1000,2), 'K') AS Avg_Sales
	FROM
       (
       SELECT SUM(transaction_qty * unit_price) AS total_sales
       FROM dcoffee_shope_sales
       WHERE MONTH(transaction_date) = 5
       GROUP BY transaction_date
       ) AS Internal_query
       
       -- DAILY SALES
       
	SELECT 
          DAY(transaction_date)AS day_of_month,
          SUM(unit_price * transaction_qty) AS total_sales
	FROM dcoffee_shope_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY DAY(transaction_date)
    ORDER BY DAY(transaction_date)
    
-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
     dcoffee_shope_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
-- sales by product category

SELECT product_category,
  CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS total_sales
FROM dcoffee_shope_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC

-- TOP 10 PRODUCT BY SALES

SELECT product_type,
SUM(unit_price * transaction_qty) AS total_sales
FROM dcoffee_shope_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'Coffee'
GROUP BY product_type
ORDER by SUM(unit_price * transaction_qty) DESC 
LIMIT 10

-- sales analysis by days and hours

SELECT
   SUM(unit_price * transaction_qty) AS total_sales,
   SUM(transaction_qty) AS Total_qty_sold,
   COUNT(*)
FROM dcoffee_shope_sales
WHERE MONTH(transaction_date) = 5 -- May Month
AND DAYOFWEEK(transaction_date) = 2 -- Monday
AND HOUR(transaction_time) = 8 -- Hour NO 8

-- SALES BY DAY | HOUR
SELECT
  HOUR(transaction_time),
  SUM(unit_price * transaction_qty) AS Total_sales
FROM dcoffee_shope_sales
WHERE MONTH(transaction_date) =5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY

  SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    dcoffee_shope_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
    
    -- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT
   HOUR(transaction_time) AS Hour_of_Day,
   ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
FROM
dcoffee_shope_sales
WHERE
MONTH(transaction_date)=5 -- Filter for May(month number 5)
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);

