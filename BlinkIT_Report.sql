-- Selecting the database
USE Blinkit_Report;

-- Checking the first 5 records from the dataset
SELECT TOP 5 * 
FROM BlinkIT_Data;

-- Counting the total number of unique item identifiers
SELECT COUNT(Item_Identifier) AS Count_of_Rows 
FROM BlinkIT_Data;

-- Counting total items grouped by Outlet_Establishment_Year
-- Sorting in descending order to see the years with the most items first
SELECT Outlet_Establishment_Year, 
       COUNT(Item_Identifier) AS Total_Count 
FROM BlinkIT_Data
GROUP BY Outlet_Establishment_Year 
ORDER BY Total_Count DESC;

-- Counting total items grouped by Outlet_Size
-- Sorting in descending order to see the sizes with the most items first
SELECT Outlet_Size, 
       COUNT(Item_Identifier) AS Total_Count 
FROM BlinkIT_Data
GROUP BY Outlet_Size 
ORDER BY Total_Count DESC;

-- Counting total items grouped by Item_Fat_Content
-- Sorting in descending order to see the fat content categories with the most items first
SELECT Item_Fat_Content, 
       COUNT(Item_Identifier) AS Total_Count  
FROM BlinkIT_Data
GROUP BY Item_Fat_Content 
ORDER BY Total_Count DESC;

-- Updating Item_Fat_Content to standardize category names
UPDATE BlinkIT_Data
SET Item_Fat_Content = CASE 
    -- Replacing different variations of 'Low Fat' with a standardized value
    WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
    
    -- Replacing shorthand 'reg' with the standardized value 'Regular'
    WHEN Item_Fat_Content = 'reg' THEN 'Regular'
    
    -- Keeping all other values unchanged
    ELSE Item_Fat_Content
END;

-- Selecting distinct values from the Item_Fat_Content column  
-- This helps in identifying the unique categories present in the dataset  
SELECT DISTINCT  
    Item_Fat_Content  -- Retrieves only unique values from the Item_Fat_Content column  
FROM  
    BlinkIT_Data;  -- Specifies the source table from which the data is being fetched  


-- KPI: Calculating Total Sales in Millions  
SELECT  
    -- Summing up the Total_Sales column to get the overall sales  
    -- Dividing by 1,000,000 to convert the value into millions  
    -- Casting the result to DECIMAL(10,2) to ensure two decimal places for accuracy  
    CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Million  
FROM  
    -- Selecting data from the BlinkIT_Data table  
    BlinkIT_Data;  


-- KPI: Calculating Average Sales  
SELECT  
    -- Calculating the average value of the Total_Sales column  
    -- Using CAST to convert the result into an integer (removing decimal values)  
    CAST(AVG(Total_Sales) AS INT) AS Avg_Sales  
FROM  
    -- Selecting data from the BlinkIT_Data table  
    BlinkIT_Data;  


-- KPI: Counting the Total Number of Orders  
SELECT  
    -- COUNT(*) counts the total number of rows in the BlinkIT_Data table  
    -- Each row represents an order, so this gives the total number of orders  
    COUNT(*) AS No_of_Orders  
FROM  
    -- Selecting data from the BlinkIT_Data table  
    BlinkIT_Data;  


-- KPI: Calculating the Average Rating of All Orders  
SELECT  
    -- AVG(Rating) computes the average rating from the Rating column  
    -- CAST(... AS DECIMAL(10,1)) ensures the result is displayed with one decimal place  
    CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating  
FROM  
    -- Selecting data from the BlinkIT_Data table  
    BlinkIT_Data;  

-- Total Sales by Fat Content  
SELECT  
    -- Selecting the fat content category  
    Item_Fat_Content,  
    
    -- Calculating total sales for each fat content category  
    -- SUM(Total_Sales) aggregates the total sales per fat content type  
    -- CAST(... AS DECIMAL(10,2)) ensures the result is displayed with two decimal places  
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales  
FROM  
    -- Fetching data from the BlinkIT_Data table  
    BlinkIT_Data  
GROUP BY  
    -- Grouping the results by fat content to calculate sales per category  
    Item_Fat_Content;  


-- Total Sales by Item Type (sorted in descending order)  
SELECT  
    -- Selecting the item type category  
    Item_Type,  
    
    -- Calculating total sales for each item type  
    -- SUM(Total_Sales) aggregates the total sales per item type  
    -- CAST(... AS DECIMAL(10,2)) ensures the result is displayed with two decimal places  
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales  
FROM  
    -- Fetching data from the BlinkIT_Data table  
    BlinkIT_Data  
GROUP BY  
    -- Grouping the results by item type to calculate sales per category  
    Item_Type  
ORDER BY  
    -- Sorting the results in descending order to show item types with the highest sales first  
    Total_Sales DESC;  


-- Fat Content by Outlet for Total Sales (Pivot Table)  
SELECT  
    -- Selecting the outlet location type  
    Outlet_Location_Type,  
    
    -- Using ISNULL() to replace NULL values with 0 for better readability  
    ISNULL([Low Fat], 0) AS Low_Fat,  
    ISNULL([Regular], 0) AS Regular  
FROM (  
    -- Subquery to calculate total sales based on outlet location type and fat content  
    SELECT  
        -- Selecting outlet location type  
        Outlet_Location_Type,  
        
        -- Selecting item fat content category  
        Item_Fat_Content,  
        
        -- Aggregating total sales per location type and fat content  
        -- SUM(Total_Sales) computes the total sales  
        -- CAST(... AS DECIMAL(10,2)) ensures the result has two decimal places  
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales  
    FROM  
        -- Fetching data from the BlinkIT_Data table  
        BlinkIT_Data  
    GROUP BY  
        -- Grouping by outlet location type and fat content category  
        Outlet_Location_Type, Item_Fat_Content  
) AS SourceTable  
PIVOT (  
    -- Pivoting data to create separate columns for 'Low Fat' and 'Regular' categories  
    SUM(Total_Sales)  
    FOR Item_Fat_Content IN ([Low Fat], [Regular])  
) AS PivotTable  
ORDER BY  
    -- Sorting results alphabetically by outlet location type  
    Outlet_Location_Type;  


-- Total Sales by Outlet Establishment Year
-- Selecting the year when each outlet was established
SELECT Outlet_Establishment_Year, 

       -- Calculating the total sales for each establishment year
       -- SUM(Total_Sales) aggregates the total sales for each year
       -- CAST ensures the result is formatted as a decimal with two decimal places
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales

-- Fetching data from the BlinkIT_Data table
FROM BlinkIT_Data 

-- Grouping sales data by the establishment year of the outlets
GROUP BY Outlet_Establishment_Year 

-- Sorting results in ascending order to display sales trends over time
ORDER BY Outlet_Establishment_Year;


-- Percentage of Sales by Outlet Size

-- Selecting the outlet size category
SELECT Outlet_Size, 

       -- Calculating the total sales for each outlet size
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,

       -- Calculating the percentage contribution of each outlet size to total sales
       -- SUM(Total_Sales) * 100.0 gives the sales as a percentage
       -- SUM(SUM(Total_Sales)) OVER() computes the total sales across all outlet sizes
       -- CAST ensures the percentage is formatted as a decimal with two decimal places
       CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage

-- Fetching data from the BlinkIT_Data table
FROM BlinkIT_Data 

-- Grouping sales data by outlet size
GROUP BY Outlet_Size 

-- Sorting in descending order to display the highest-selling outlet sizes first
ORDER BY Total_Sales DESC; 


-- Sales by Outlet Location Type

-- Selecting the location type of each outlet
SELECT Outlet_Location_Type, 

       -- Calculating the total sales for each outlet location type
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales

-- Fetching data from the BlinkIT_Data table
FROM BlinkIT_Data 

-- Grouping sales data by outlet location type
GROUP BY Outlet_Location_Type 

-- Sorting in descending order to highlight the location type with the highest sales
ORDER BY Total_Sales DESC; 


-- All Metrics by Outlet Type

-- Selecting the outlet type for analysis
SELECT Outlet_Type, 

       -- Calculating the total sales for each outlet type
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,

       -- Computing the average sales per item in each outlet type
       CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,

       -- Counting the total number of items sold for each outlet type
       COUNT(*) AS No_Of_Items,

       -- Calculating the average rating for each outlet type
       CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,

       -- Computing the average visibility of items for each outlet type
       CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility

-- Fetching data from the BlinkIT_Data table
FROM BlinkIT_Data 

-- Grouping sales data by outlet type
GROUP BY Outlet_Type 

-- Sorting in descending order to show the highest total sales first
ORDER BY Total_Sales DESC;

