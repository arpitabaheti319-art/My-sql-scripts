
/* 
Blinkit Analysis

To identify a comprehensive analysis of Blinkit's sales performance, Customer satisfaction and inventory distribution 
identify key insights and opportunities for optimisation using various KPIs and Visualisation in Power BI.

KPI Requirements

1. Total Sales - The overall revenue generated from all the items sold.
2. Average Sales - The average revenue per sales.
3. Number of items - The total count of different items sold.
4. Average Rating - The average Customer Rating for items sold
*/ 

--================
-- Cleaning Data
--================  

--Checking Data Consistency

SELECT COUNT(*) FROM blinkit_data;

SELECT 
	Item_fat_Content
FROM blinkit_data
GROUP BY Item_fat_Content;

UPDATE blinkit_data
SET Item_Fat_Content = 
	CASE WHEN Item_Fat_Content IN ('low fat','LF') THEN 'Low Fat'
		 WHEN Item_Fat_Content = 'reg' THEN 'Regular'
END;

--Finding Total Sales--

SELECT TOP 10 * FROM blinkit_data

SELECT
	CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Lakhs
FROM blinkit_data

-- By item identifier

SELECT
	item_identifier,
	CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Identify_L
FROM blinkit_data
GROUP BY item_identifier


--Average Sales--

SELECT
	CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average
FROM blinkit_data

-- By item identifier

SELECT
	item_identifier,
	CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Identify
FROM blinkit_data
GROUP BY item_identifier

-- Count of items sold--

SELECT
COUNT(*) AS Total_items_sold
FROM blinkit_data

-- By item identifier

SELECT
item_identifier,
COUNT(item_identifier) AS Total_items_sold
FROM blinkit_data
GROUP BY item_identifier


-- Average Ratings--

SELECT
ROUND(AVG(Rating),2) AS Overall_Avg
FROM blinkit_data;

-- By item identifier

SELECT 
item_identifier,
ROUND(AVG(Rating),2) AS Average_Rating_identifier
FROM blinkit_data
GROUP BY item_identifier;


/*
GRANULAR REQUIREMENTS

1. Total Sales by Fat Content
		Objective: Analyze the impact of fat content on Total Sales.
		Additional KPI Metrics: Assess how other KPIs (Average Sales,Number of Items,Average Rating) vary with fat content.
2. Total Sales by Item Type
		Objective: Identify the performance of different item types in terms of total sales.
		Additional KPI Metrics: Assess how other KPIs (Average Sales,Number of Items,Average Rating) vary with Item Type.
3. Fat Content by outlet for total sales
		Objective: Compare total sales accross different outlets segmented by fat content.
		Additional KPI Metrics: Assess how other KPIs (Average Sales,Number of Items,Average Rating) vary with outlet.
4. Total Sales by Outlet Establishment
		Objective: Evaluate how the age or type of outlet establishment influences outlet establishment year.
*/

-- Total sales by fat content

SELECT
    item_fat_content,
	CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Lakhs,
	CAST(AVG(Total_Sales) AS DECIMAL(10,2)) AS Avg_Sales,
	COUNT(item_fat_content) AS No_of_Items,
	CAST(AVG(Rating)AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
GROUP BY item_fat_content;


-- Total sales by Item Type

SELECT
	Item_Type,
	CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
	CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
	COUNT(Item_Type) AS Total_items_sold,
	CAST(AVG(Rating) AS Decimal) AS Average_Rating_type
FROM blinkit_data
GROUP BY Item_Type;

-- By outlet Location

SELECT
	Outlet_Location_Type,
	CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
	CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
	COUNT(Outlet_Location_Type) AS Total_items_sold,
	CAST(AVG(Rating) AS Decimal) AS Average_Rating_type
FROM blinkit_data
GROUP BY Outlet_Location_Type;

-- 3. Using Pivot (Fat content by outlet for total sales)

SELECT 
Outlet_location_type,
ISNULL([Low Fat],0) AS Low_Fat,
ISNULL([Regular],0) AS Regular
FROM
(
	SELECT 
	Outlet_location_type,
	Item_Fat_Content,
	CAST(SUM(Total_Sales) AS DECIMAL(10,2)) Total_Sales
	FROM blinkit_data
	GROUP BY Outlet_location_type , Item_Fat_Content
)t
PIVOT 
(
	SUM(Total_Sales)
	FOR Item_Fat_Content 
	IN ([Low Fat],[Regular])
)q
ORDER BY Outlet_location_type

-- count of items sold by fat content in different outlets

SELECT
Outlet_location_type,
ISNULL([Low fat],0) Low_Fat,
ISNULL([Regular],0) Regular
FROM
(
	SELECT
	Outlet_Location_Type,
	Item_Fat_Content,
	COUNT(item_fat_content) Count_of_Contentlabel
	FROM blinkit_data
	GROUP BY Outlet_Location_Type, Item_Fat_Content
)T
PIVOT
(
	SUM(Count_of_Contentlabel)
	FOR Item_Fat_Content
	IN ([Low Fat], [Regular])
)Q
ORDER BY Outlet_location_type

-- Avg sales by Fat content & outlet

SELECT
Outlet_Location_Type,
ISNULL([Low fat],0) Low_Fat,
ISNULL([Regular],0) Regular
FROM
(
	SELECT
	Outlet_Location_Type,
	Item_Fat_Content,
	CAST(AVG(Total_Sales) AS DECIMAL(10,2)) Average_Sales
	FROM blinkit_data
	GROUP BY Outlet_Location_Type , Item_Fat_Content
)T
PIVOT
(
	SUM(Average_Sales)
	FOR Item_Fat_Content
	IN ([Low Fat] , [Regular])
)Q

-- Avg Rating by fat content & outlet

SELECT
Outlet_Location_Type,
ISNULL([Low fat],0) Low_Fat,
ISNULL([Regular],0) Regular
FROM
(
	SELECT
	Outlet_Location_Type,
	Item_Fat_Content,
	CAST(AVG(Rating) AS DECIMAL(10,2)) Rating
	FROM blinkit_data
	GROUP BY Outlet_Location_Type , Item_Fat_Content
)T
PIVOT
(
	SUM(Rating)
	FOR Item_Fat_Content
	IN ([Low Fat] , [Regular])
)Q

--By Outlet Establishment

SELECT
	Outlet_Establishment_Year,
	CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
	CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
	COUNT(Outlet_Location_Type) AS Total_items_sold,
	CAST(AVG(Rating) AS Decimal) AS Average_Rating_type
FROM blinkit_data
GROUP BY Outlet_Establishment_Year;


 /*
Charts's Requirements

5. Percentage of Sales by outlet size
			objective: analyze the corelation between outlet size and total sales,
6. sales by outlet location
			objective: assess the geographic distribution of sales accross different location
7. all metric by outlet type
			objevctive: provide comprehensive view of all metrics(total sales, average sales, number of items, average rating)
			broken down by different outlet types
 */

SELECT TOP 10 * FROM blinkit_data

SELECT
Outlet_size,
ROUND(SUM(Total_Sales),2) Sum_of_sales,
CONCAT(ROUND((SUM(Total_Sales)/(SELECT SUM(Total_Sales)FROM blinkit_data) * 100),2),'%') AS percent_contribution
FROM blinkit_data
GROUP BY Outlet_size

-- By outlet_type

SELECT
	Outlet_Type,
	CAST(SUM(Total_Sales)/100000 AS DECIMAL(10,2)) AS Total_Sales_Type_L,
	CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Average_Type,
	COUNT(Outlet_Location_Type) AS Total_items_sold,
	CAST(AVG(Rating) AS Decimal) AS Average_Rating_type
FROM blinkit_data
GROUP BY Outlet_Type;