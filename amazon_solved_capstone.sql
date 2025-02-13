use amozon_capstone;

-- FEATURE ENGINEERING.

-- TO COUNT TOTAL COLUMNS IN THE AMAZON TABLE.
SELECT COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'amozon_capstone'
  AND TABLE_NAME = 'amazon';
 
 # Checking for Null Values - No Null values found
SELECT * FROM amazon WHERE `Product line` IS NULL OR `Unit price` IS NULL OR Quantity IS NULL OR `Total` IS NULL 
OR Payment IS NULL OR cogs IS NULL OR `gross margin percentage` IS NULL OR `gross income` IS NULL OR `Rating` IS NULL;


-- DISABLING SAFE UPDATES MODE TO ADD COLUMNS IN THE AMAZON TABLE.
set sql_safe_updates = 0;

-- 1.ADDING TIMEOFDAY COLUMN TO THE AMAZON TABLE.
alter table amazon
add column timeofday varchar(50);

-- UPDATE THE 'AMAZON' TABLE TO CATEGORIZE THE 'TIMEOFDAY' BASED ON THE 'TIME' COLUMN.
update amazon
set timeofday =
case 
    when time >= "00:00:00" and time < "12:00:00" then "Morning"
    when time >= "12:00:00" and time <= "16:00:00" then "Afternoon"
    else "Evening"
    end ;
    
    
-- 2.ADDING DAYNAME COLUMN TO THE AMAZON TABLE.
alter table amazon
add column dayname varchar(10);

-- UPDATING THE DAYNAME COLUMN BASED ON THE DATE COLUMN.
update amazon
set dayname = date_Format(Date,"%a") ;


-- 3.ADDING MONTHNAME COLUMN TO THE AMAZON TABLE. 
alter table amazon
add column monthname varchar(10);

-- UPDATING MONTHNAME COLUMN TO THE AMAZON TABLE
update amazon
set monthname = date_format(date,'%b');

-- ENABLING SAFE UPDATES MODE TO PREVENT UNSAFE DATA CHANGES
SET SQL_SAFE_UPDATES = 1;

-- TO VIEW THE CLEANED DATA
select * from amazon;


-- BUSINEES QUESTIONS.

-- 1. WHAT IS THE COUNT OF DISTINCT CITIES IN THE DATASET?
SELECT  count(DISTINCT city) AS city_count 
FROM amazon;

-- 2. FOR EACH BRANCH, WHAT IS THE CORRESPONDING CITY?
SELECT DISTINCT Branch,City FROM amazon;

-- 3. WHAT IS THE COUNT OF DISTINCT PRODUCT LINES IN THE DATASET?
SELECT COUNT(DISTINCT `product line`) AS total_product_lines 
FROM amazon;

-- 4. WHICH PAYMENT METHOD OCCURS MOST FREQUENTLY?
SELECT payment, COUNT(payment) AS total_payments 
FROM amazon
GROUP BY payment
ORDER BY total_payments DESC
LIMIT 1;

-- 5. WHICH PRODUCT LINE HAS THE HIGHEST SALES?
SELECT `product line`, CAST(SUM(`Unit Price` * Quantity) AS SIGNED) AS Highest_Sales 
FROM amazon
GROUP BY `product line`
ORDER BY Highest_Sales DESC;

-- 6. HOW MUCH REVENUE IS GENERATED EACH MONTH?
SELECT monthname, 
       CAST(SUM(total) AS SIGNED) AS Total_Sales 
FROM amazon
GROUP BY monthname;

-- 7. IN WHICH MONTH DID THE COST OF GOODS SOLD REACH ITS PEAK?
SELECT monthname, 
       ROUND(SUM(cogs), 2) AS total_cogs 
FROM amazon
GROUP BY monthname
ORDER BY total_cogs DESC
LIMIT 1;

-- 8. WHICH PRODUCT LINE GENERATED THE HIGHEST REVENUE?
SELECT `product line`, 
       CAST(SUM(total) AS SIGNED) AS Highest_revenue 
FROM amazon
GROUP BY `product line`
ORDER BY Highest_revenue DESC 
LIMIT 1;

-- 9. IN WHICH CITY WAS THE HIGHEST REVENUE RECORDED?
SELECT city, 
       CAST(SUM(total) AS SIGNED) AS highest_revenue 
FROM amazon
GROUP BY city
ORDER BY highest_revenue DESC
LIMIT 1;

-- 10. WHICH PRODUCT LINE INCURRED THE HIGHEST VALUE ADDED TAX?
SELECT `product line`,
		ROUND(SUM(`Tax 5%`),2) as Highest_tax_paid
FROM amazon
GROUP BY `product line`
ORDER BY Highest_tax_paid desc;

-- 11. FOR EACH PRODUCT LINE,ADD A COLUMN INDICATING "GOOD" IF ITS SALES ARE ABOVE AVERAGE, 
-- OTHERWISE "BAD."
SELECT distinct `Product_Line`,
       CASE 
           WHEN prod_Avg_Sale > All_Avg_Sale THEN "GOOD"
           ELSE "BAD"
       END AS "GOOD/BAD_Rating"
FROM (
    SELECT `Product line` AS Product_Line, 
           AVG(Total) OVER (PARTITION BY `Product line`) AS prod_Avg_Sale,
           AVG(Total) OVER () AS All_Avg_Sale 
    FROM amazon
) AS Sale;

-- 12. IDENTIFY THE BRANCH THAT EXCEEDED THE AVERAGE NUMBER OF PRODUCTS SOLD.
SELECT Branch, SUM(Quantity) AS Total_Products_Sold
FROM amazon
GROUP BY Branch
HAVING SUM(Quantity) > (
    SELECT AVG(Branch_Total) 
    FROM (
        SELECT SUM(Quantity) AS Branch_Total
        FROM amazon
        GROUP BY Branch
    ) AS Branch_Sales
);


-- 13. WHICH PRODUCT LINE IS MOST FREQUENTLY ASSOCIATED WITH EACH GENDER?
SELECT 
    `product line`,
    most_frequently_associated,
    gender
FROM (
    SELECT 
        `product line`,
        gender,
        COUNT(`product line`) AS most_frequently_associated,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(`product line`) DESC) AS ranking
    FROM amazon
    GROUP BY `product line`, gender
) AS ranked
WHERE ranking = 1;

-- 14. CALCULATE THE AVERAGE RATING FOR EACH PRODUCT LINE.
SELECT 
    `product line`, 
    ROUND(AVG(rating), 2) AS average_rating
FROM 
    amazon
GROUP BY 
    `product line`
ORDER BY average_rating DESC;

-- 15. COUNT THE SALES OCCURRENCES FOR EACH TIME OF DAY ON EVERY WEEKDAY.
SELECT 
      timeofday,
      dayname,
      COUNT(total) AS sales_occurrences
FROM amazon
WHERE dayname NOT IN("Sun", "Sat")  -- EXCLUDE SUNDAY AND SATURDAY
GROUP BY timeofday, dayname
ORDER BY sales_occurrences desc;

-- 16. IDENTIFY THE CUSTOMER TYPE CONTRIBUTING THE HIGHEST REVENUE.
SELECT `customer type`,
        ROUND(SUM(total),2) AS Highest_revenue
FROM amazon
GROUP BY `customer type`
ORDER BY Highest_revenue DESC;

-- 17. DETERMINE THE CITY WITH THE HIGHEST VAT PERCENTAGE.
SELECT city, 
       ROUND((SUM(`Tax 5%`) / SUM(`Unit price` * Quantity) * 100),2) AS VAT_Percentage
FROM amazon
GROUP BY city
ORDER BY VAT_Percentage DESC;

-- 18. IDENTIFY THE CUSTOMER TYPE WITH THE HIGHEST VAT PAYMENTS.
SELECT `Customer type`,
        ROUND(SUM(`Tax 5%`),2) AS TOTAL_VAT_payments
FROM amazon
GROUP BY `Customer type`
ORDER BY TOTAL_VAT_payments DESC;

-- 19. WHAT IS THE COUNT OF DISTINCT CUSTOMER TYPES IN THE DATASET.
SELECT COUNT(DISTINCT `Customer type`) AS total_customer_type  
FROM amazon;

-- 20. WHAT IS THE COUNT OF DISTINCT PAYMENT METHODS IN THE DATASET.
SELECT COUNT(DISTINCT Payment) AS total_payment_methods
FROM amazon;

-- 21. WHICH CUSTOMER TYPE OCCURS MOST FREQUENTLY.
SELECT `Customer type`,
        COUNT(`Customer type`) AS Most_frequently
FROM amazon
GROUP BY `Customer type`
ORDER BY Most_frequently DESC;

-- 22. IDENTIFY THE CUSTOMER TYPE WITH THE HIGHEST PURCHASE FREQUENCY.
SELECT `customer type`,
       COUNT(*) AS total_purchase_frequency
FROM amazon
GROUP BY `customer type`
ORDER BY total_purchase_frequency DESC;

-- 23. DETERMINE THE PREDOMINANT GENDER AMONG CUSTOMERS. 
SELECT `customer type`,
       gender,
       total_gender_count
FROM (
    SELECT `customer type`,
           gender,
           COUNT(gender) AS total_gender_count,
           ROW_NUMBER() OVER (PARTITION BY `customer type` ORDER BY COUNT(gender) DESC) AS serial_number
    FROM amazon
    GROUP BY `customer type`, gender
) AS referencing;

-- 24. EXAMINE THE DISTRIBUTION OF GENDERS WITHIN EACH BRANCH. 
SELECT branch,
       gender,
       COUNT(gender) AS gender_count
FROM amazon
GROUP BY branch, gender
ORDER BY branch, gender_count desc;

-- 25. IDENTIFY THE TIME OF DAY WHEN CUSTOMERS PROVIDE THE MOST RATINGS. 
SELECT timeofday,
       COUNT(rating) AS total_ratings
FROM amazon
GROUP BY timeofday
ORDER BY total_ratings DESC;

-- 26. DETERMINE THE TIME OF DAY WITH THE HIGHEST CUSTOMER RATINGS FOR EACH BRANCH.
WITH highest_cust_rating AS (
    SELECT timeofday,
           branch,
           COUNT(rating) AS total_ratings,
           DENSE_RANK() OVER (PARTITION BY branch ORDER BY COUNT(rating) DESC) AS ranking
    FROM amazon
    GROUP BY timeofday, branch
)
SELECT timeofday,
       branch,
       total_ratings
FROM highest_cust_rating
WHERE ranking = 1;

-- 27. IDENTIFY THE DAY OF THE WEEK WITH THE HIGHEST AVERAGE RATINGS.
SELECT dayname,
       ROUND(AVG(rating), 2) AS average_rating,
       DENSE_RANK() OVER (ORDER BY ROUND(AVG(rating), 2) DESC) AS highest_average_ranking
FROM amazon
GROUP BY dayname;

-- 28. DETERMINE THE DAY OF THE WEEK WITH THE HIGHEST AVERAGE RATINGS FOR EACH BRANCH. 
SELECT * 
FROM (
    SELECT dayname,
           branch,
           ROUND(AVG(rating), 2) AS highest_average_rating,
           DENSE_RANK() OVER (PARTITION BY branch ORDER BY ROUND(AVG(rating), 2) DESC) AS ranking
    FROM amazon
    GROUP BY dayname, branch
) AS day_of_the_week
WHERE ranking = 1;


















