use superstore;

-- PS1 Total Sales, Total Profit, Average Discount, Total Quantity
SELECT 
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  AVG(Discount) AS Average_Discount,
  SUM(Quantity) AS Total_Quantity
FROM superstore_cleaned_2;

select count(*) from superstore_cleaned_2;

--  PS2: Top 10 customers by total sales
SELECT 
  `Customer Name`,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  COUNT(`Order ID`) AS Total_Orders
FROM superstore_cleaned_2
GROUP BY `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;

-- PS3: Find top 10 highest selling products by total sales and quantity sold
SELECT 
  `Product Name`,
  SUM(Sales) AS Total_Sales,
  SUM(Quantity) AS Total_Quantity,
  SUM(Profit) AS Total_Profit
FROM superstore_cleaned_2
GROUP BY `Product Name`
ORDER BY Total_Sales DESC
LIMIT 10;

--  PS4: Top 10 Customers by Total Sales
SELECT 
  `Customer ID`,
  `Customer Name`,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  COUNT(`Order ID`) AS Total_Orders
FROM superstore_cleaned_2
GROUP BY `Customer ID`, `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;

--  PS5: Products with the Highest Average Discounts
SELECT 
  `Product ID`,
  `Product Name`,
  `Category`,
  `Sub-Category`,
  AVG(Discount) AS Average_Discount,
  COUNT(*) AS Order_Count
FROM superstore_cleaned_2
GROUP BY `Product ID`, `Product Name`, `Category`, `Sub-Category`
ORDER BY Average_Discount DESC
LIMIT 10;

--  PS6: Top Customers by Total Sales
SELECT 
  `Customer ID`,
  `Customer Name`,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  COUNT(`Order ID`) AS Orders_Placed
FROM superstore_cleaned_2
GROUP BY `Customer ID`, `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;

--  PS7: Most Profitable Product Sub-Categories
SELECT 
  `Sub-Category`,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  COUNT(`Order ID`) AS Orders_Count
FROM superstore_cleaned_2
GROUP BY `Sub-Category`
ORDER BY Total_Profit DESC;

--  PS8: Top Customers by Total Sales
SELECT 
  `Customer ID`,
  `Customer Name`,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  COUNT(`Order ID`) AS Orders_Count
FROM superstore_cleaned_2
GROUP BY `Customer ID`, `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;

--  PS9: Top Products by Total Sales
SELECT 
  `Product ID`,
  `Product Name`,
  SUM(Sales) AS Total_Sales,
  SUM(Profit) AS Total_Profit,
  COUNT(`Order ID`) AS Orders_Count
FROM superstore_cleaned_2
GROUP BY `Product ID`, `Product Name`
ORDER BY Total_Sales DESC
LIMIT 10;

-- PS10: Repeat Purchase Behavior
SELECT 
  `Customer ID`,
  `Customer Name`,
  COUNT(DISTINCT `Order ID`) AS Total_Orders,
  SUM(Sales) AS Total_Spent,
  SUM(Profit) AS Total_Profit
FROM superstore_cleaned_2
GROUP BY `Customer ID`, `Customer Name`
HAVING Total_Orders > 1
ORDER BY Total_Orders DESC, Total_Spent DESC
LIMIT 20;

-- Advanced SQL Problem Statements we are going to implement on our dataset 
-- PSA.1 RANK() – Top 5 products by total sales within each category
SELECT *
FROM (
    SELECT
        Category,
        `Product ID`,
        `Product Name`,
        SUM(Sales) AS Total_Sales,
        RANK() OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) AS Sales_Rank
    FROM
        superstore_cleaned_2
    GROUP BY
        Category, `Product ID`, `Product Name`
) AS ranked_products
WHERE
    Sales_Rank <= 5;

-- PSA 2 NTILE() – Divide customers into quartiles by total sales
SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS Total_Sales,
    NTILE(4) OVER (ORDER BY SUM(Sales) DESC) AS Sales_Quartile
FROM
    superstore_cleaned_2
GROUP BY
    `Customer ID`, `Customer Name`
ORDER BY
    Total_Sales DESC;
    
    -- PSA 3 LAG() & LEAD() – Sales with previous & next orders for each customer
SELECT
    `Customer ID`,
    `Order ID`,
    `Order Date`,
    Sales,
    LAG(Sales) OVER (PARTITION BY `Customer ID` ORDER BY `Order Date`) AS Prev_Sales,
    LEAD(Sales) OVER (PARTITION BY `Customer ID` ORDER BY `Order Date`) AS Next_Sales
FROM
    superstore_cleaned_2; 

-- PSA 4 Compare category average discount with overall average
    WITH category_discount AS (
    SELECT
        `Category`,
        AVG(`Discount`) AS avg_discount
    FROM
        superstore_cleaned_2
    GROUP BY
        `Category`
),
overall_discount AS (
    SELECT
        AVG(`Discount`) AS overall_avg_discount
    FROM
        superstore_cleaned_2
)
SELECT
    cd.`Category`,
    cd.avg_discount,
    ovr.overall_avg_discount
FROM
    category_discount cd, overall_discount ovr;


-- PSA 5 Running total of profit over time
SELECT
    `Order Date`,
    SUM(`Profit`) AS Daily_Profit,
    SUM(SUM(`Profit`)) OVER (
        ORDER BY STR_TO_DATE(`Order Date`, '%m/%d/%Y')
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total_Profit
FROM
    superstore_cleaned_2
GROUP BY
    `Order Date`
ORDER BY
    STR_TO_DATE(`Order Date`, '%m/%d/%Y');

-- PSA 6 Dense rank states by total sales
SELECT
    `State`,
    SUM(`Sales`) AS Total_Sales,
    DENSE_RANK() OVER (ORDER BY SUM(`Sales`) DESC) AS State_Rank
FROM
    superstore_cleaned_2
GROUP BY
    `State`
ORDER BY
    State_Rank;

-- PSA 7 Moving average of profit over 7 days
SELECT
    `Order Date`,
    SUM(`Profit`) AS Daily_Profit,
    AVG(SUM(`Profit`)) OVER (
        ORDER BY STR_TO_DATE(`Order Date`, '%m/%d/%Y')
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_Profit_7_Days
FROM
    superstore_cleaned_2
GROUP BY
    `Order Date`
ORDER BY
    STR_TO_DATE(`Order Date`, '%m/%d/%Y');

-- PSA 8 Percent rank customers by total sales
SELECT
    `Customer ID`,
    SUM(`Sales`) AS Total_Sales,
    PERCENT_RANK() OVER (ORDER BY SUM(`Sales`)) AS Sales_Percent_Rank
FROM
    superstore_cleaned_2
GROUP BY
    `Customer ID`
ORDER BY
    Total_Sales DESC;


-- PSA 9 Detect possible duplicate orders for the same customer and date
SELECT *
FROM (
    SELECT
        `Customer ID`,
        `Order Date`,
        `Order ID`,
        ROW_NUMBER() OVER (
            PARTITION BY `Customer ID`, `Order Date` ORDER BY `Order ID`
        ) AS row_num
    FROM
        superstore_cleaned_2
) AS sub
WHERE
    row_num > 1;


-- PSA 10 Rank products within each sub-category by their average profit margin
SELECT
    `Sub-Category`,
    `Product ID`,
    `Product Name`,
    AVG(`Profit Margin`) AS Avg_Profit_Margin,
    RANK() OVER (
        PARTITION BY `Sub-Category` ORDER BY AVG(`Profit Margin`) DESC
    ) AS Profit_Rank
FROM
    superstore_cleaned_2
GROUP BY
    `Sub-Category`, `Product ID`, `Product Name`
ORDER BY
    `Sub-Category`, Profit_Rank;



