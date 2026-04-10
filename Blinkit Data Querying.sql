/* 
Blinkit Analysis

Objective: Comprehensive analysis of Blinkit's sales performance, customer satisfaction, and inventory distribution.
Approach: Use KPIs and Power BI visualizations to identify insights and optimization opportunities.

KPI Requirements:
1. Total Sales - Overall revenue generated.
2. Average Sales - Average revenue per sale.
3. Number of Items - Count of items sold.
4. Average Rating - Average customer rating.
*/ 

--================
-- Data Cleaning & Consistency
--================  

-- Check total records
SELECT COUNT(*) FROM blinkit_data;

-- Inspect fat content categories
SELECT Item_fat_Content
FROM blinkit_data
GROUP BY Item_fat_Content;

-- Standardize fat content labels
UPDATE blinkit_data
SET Item_Fat_Content = 
    CASE 
        WHEN Item_Fat_Content IN ('low fat','LF') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
    END;

--================
-- Core KPIs
--================  

-- Preview dataset
SELECT TOP 10 * FROM blinkit_data;

-- Total Sales (in Lakhs)
SELECT CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Lakhs
FROM blinkit_data;

-- Total Sales by Item Identifier
SELECT item_identifier,
       CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Identify_L
FROM blinkit_data
GROUP BY item_identifier;

-- Average Sales
SELECT CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average
FROM blinkit_data;

-- Average Sales by Item Identifier
SELECT item_identifier,
       CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Identify
FROM blinkit_data
GROUP BY item_identifier;

-- Total Items Sold
SELECT COUNT(*) AS Total_items_sold
FROM blinkit_data;

-- Items Sold by Item Identifier
SELECT item_identifier,
       COUNT(item_identifier) AS Total_items_sold
FROM blinkit_data
GROUP BY item_identifier;

-- Overall Average Rating
SELECT ROUND(AVG(Rating),2) AS Overall_Avg
FROM blinkit_data;

-- Average Rating by Item Identifier
SELECT item_identifier,
       ROUND(AVG(Rating),2) AS Average_Rating_identifier
FROM blinkit_data
GROUP BY item_identifier;

/*
Granular Analysis Requirements:
1. Sales by Fat Content
2. Sales by Item Type
3. Fat Content vs Outlet (pivot analysis)
4. Sales by Outlet Establishment Year
*/

-- Sales & KPIs by Fat Content
SELECT item_fat_content,
       CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Lakhs,
       CAST(AVG(Total_Sales) AS DECIMAL(10,2)) AS Avg_Sales,
       COUNT(item_fat_content) AS No_of_Items,
       CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
GROUP BY item_fat_content;

-- Sales & KPIs by Item Type
SELECT Item_Type,
       CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
       CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
       COUNT(Item_Type) AS Total_items_sold,
       CAST(AVG(Rating) AS DECIMAL) AS Average_Rating_type
FROM blinkit_data
GROUP BY Item_Type;

-- Sales & KPIs by Outlet Location
SELECT Outlet_Location_Type,
       CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
       CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
       COUNT(Outlet_Location_Type) AS Total_items_sold,
       CAST(AVG(Rating) AS DECIMAL) AS Average_Rating_type
FROM blinkit_data
GROUP BY Outlet_Location_Type;

-- Pivot: Fat Content vs Outlet (Total Sales)
SELECT Outlet_location_type,
       ISNULL([Low Fat],0) AS Low_Fat,
       ISNULL([Regular],0) AS Regular
FROM (
    SELECT Outlet_location_type,
           Item_Fat_Content,
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) Total_Sales
    FROM blinkit_data
    GROUP BY Outlet_location_type, Item_Fat_Content
) t
PIVOT (
    SUM(Total_Sales)
    FOR Item_Fat_Content IN ([Low Fat],[Regular])
) q
ORDER BY Outlet_location_type;

-- Pivot: Count of Items Sold by Fat Content & Outlet
SELECT Outlet_location_type,
       ISNULL([Low Fat],0) AS Low_Fat,
       ISNULL([Regular],0) AS Regular
FROM (
    SELECT Outlet_Location_Type,
           Item_Fat_Content,
           COUNT(item_fat_content) Count_of_Contentlabel
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) t
PIVOT (
    SUM(Count_of_Contentlabel)
    FOR Item_Fat_Content IN ([Low Fat],[Regular])
) q
ORDER BY Outlet_location_type;

-- Pivot: Average Sales by Fat Content & Outlet
SELECT Outlet_Location_Type,
       ISNULL([Low Fat],0) AS Low_Fat,
       ISNULL([Regular],0) AS Regular
FROM (
    SELECT Outlet_Location_Type,
           Item_Fat_Content,
           CAST(AVG(Total_Sales) AS DECIMAL(10,2)) Average_Sales
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) t
PIVOT (
    SUM(Average_Sales)
    FOR Item_Fat_Content IN ([Low Fat],[Regular])
) q;

-- Pivot: Average Rating by Fat Content & Outlet
SELECT Outlet_Location_Type,
       ISNULL([Low Fat],0) AS Low_Fat,
       ISNULL([Regular],0) AS Regular
FROM (
    SELECT Outlet_Location_Type,
           Item_Fat_Content,
           CAST(AVG(Rating) AS DECIMAL(10,2)) Rating
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) t
PIVOT (
    SUM(Rating)
    FOR Item_Fat_Content IN ([Low Fat],[Regular])
) q;

-- Sales & KPIs by Outlet Establishment Year
SELECT Outlet_Establishment_Year,
       CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
       CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
       COUNT(Outlet_Location_Type) AS Total_items_sold,
       CAST(AVG(Rating) AS DECIMAL) AS Average_Rating_type
FROM blinkit_data
GROUP BY Outlet_Establishment_Year;

/*
Visualization Requirements:
5. % Contribution of Sales by Outlet Size
6. Sales by Outlet Location
7. All KPIs by Outlet Type
*/

-- % Contribution of Sales by Outlet Size
SELECT Outlet_size,
       ROUND(SUM(Total_Sales),2) AS Sum_of_sales,
       CONCAT(ROUND((SUM(Total_Sales)/(SELECT SUM(Total_Sales) FROM blinkit_data) * 100),2),'%') AS percent_contribution
FROM blinkit_data
GROUP BY Outlet_size;

-- KPIs by Outlet Type
SELECT Outlet_Type,
       CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
       CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
       COUNT(Outlet_Location_Type) AS Total_items_sold,
       CAST(AVG(Rating) AS DECIMAL) AS Average_Rating_type
FROM blinkit_data
GROUP BY Outlet_Type;
