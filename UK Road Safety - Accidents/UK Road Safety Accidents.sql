USE ukaccidents;
SELECT * FROM casualties;
SELECT * FROM accidents;
SELECT * FROM vehicles;

-- Retrieve all accident details where the accident severity is "Fatal" (severity = 1).
SELECT 
    *
FROM
    accidents
WHERE
    Accident_Severity = 1;

-- Count the number of accidents recorded in the dataset.
SELECT 
    COUNT(*) AS Total_Accidents
FROM
    accidents;
    
#Total 20,000 accidents recorded in the dataset.

-- List all the unique weather conditions recorded in the 
-- accidents dataset count how often each weather condition appears.

SELECT 
    Weather_Conditions, COUNT(*) AS Occurence_event
FROM
    accidents
GROUP BY Weather_Conditions
ORDER BY Occurence_event DESC;

-- Find the total number of casualties recorded, grouped by accident severity.
SELECT 
    Accident_Severity,
    COUNT(Casualty_Reference) AS Total_Casualties
FROM
    accidents
        JOIN
    casualties ON accidents.Accident_Index = casualties.Accident_Index
GROUP BY Accident_Severity;

-- Retrieve the accident index, vehicle reference, and vehicle type for all 
-- recorded vehicles also count the occurrences of each vehicle type in accidents.

SELECT 
    Vehicle_Type, COUNT(*) AS Vehicle_Count
FROM
    Vehicles
GROUP BY Vehicle_Type
ORDER BY Vehicle_Count DESC;

-- Display the number of accidents that occurred in rural versus urban areas.
SELECT Urban_or_Rural_Area, COUNT(*) AS Total_accidents FROM accidents GROUP BY Urban_or_Rural_Area;

# 1 represents Urban 2 represents Rural

-- Find the top 5 most common vehicle types involved in accidents.
SELECT 
    Vehicle_Type, COUNT(*) AS Vehicle_count
FROM
    vehicles
GROUP BY Vehicle_Type
ORDER BY Vehicle_count DESC
LIMIT 5;

-- Determine the number of accidents that occurred under different light conditions.
SELECT 
    Light_Conditions, COUNT(*) AS Total_Accidents
FROM
    accidents
GROUP BY Light_Conditions
ORDER BY Total_Accidents DESC;

# 1-Daylight, 4-Darkness-Lights Lit, 5-Darkness-Lights Unlit, 6-Darkness-No Lighting, 7-Darkness-Lighting Unknown

-- Identify the age group that had the highest number of casualties.
SELECT 
    Age_Band_of_Casualty,
    COUNT(Age_Band_of_Casualty) AS Num_of_accidents_in_this_age_group
FROM
    casualties
GROUP BY Age_Band_of_Casualty
ORDER BY Num_of_accidents_in_this_age_group DESC;

# Age Band of 6 representing 26-35 years of age group has the highest number of casualties.

-- List the top 3 accident locations with the most casualties.
SELECT 
    `Local_Authority_(District)`,
    COUNT(casualties.Casualty_Reference) AS Total_Casualties
FROM
    Accidents
        JOIN
    casualties ON accidents.Accident_Index = casualties.Accident_Index
GROUP BY `Local_Authority_(District)`
ORDER BY Total_Casualties DESC
LIMIT 3;

# 1st is Birmingham followed by Liverpool, Westminster

-- Find the percentage of accidents that occurred in rainy conditions.
SELECT 
    ROUND(COUNT(*) * 100 / (SELECT 
                    COUNT(*)
                FROM
                    accidents),
            2) AS Percentage_of_accidents_in_rainy_conditions
FROM
    accidents
WHERE
    Weather_Conditions IN (2 , 5);
    
#10.61 percent of total accidents happend in rainy weather condition
    
-- Retrieve details of all accidents where pedestrians were involved.
SELECT 
    *
FROM
    accidents
WHERE
    Pedestrian_Crossing_Human_Control IN (1 , 2);

-- Identify the most common driver age group involved in accidents and correlate it with accident severity.
SELECT 
    Age_Band_of_Driver,
    Accident_Severity,
    COUNT(*) AS Accident_count
FROM
    accidents
        JOIN
    vehicles ON accidents.Accident_Index = vehicles.Accident_Index
GROUP BY Age_Band_of_Driver , Accident_Severity
ORDER BY Accident_count DESC
LIMIT 1; 
 
#The age group 6 representing drivers of age 26-35 are the most common and involved in the most accident_count having
#Accident_Severity = 3 represents "Slight" accidents, meaning minor injuries or damage, but no serious harm or fatalities.

-- Determine which day of the week had the highest number of accidents.
SELECT 
    Day_of_Week, COUNT(*) AS Total_Accidents
FROM
    accidents
GROUP BY Day_of_Week
ORDER BY Total_Accidents DESC
LIMIT 1;

# Day 6 - Friday has the highest number of accidents.

-- Calculate the percentage of severe (fatal + serious) accidents per road condition:
SELECT 
    Road_Surface_Conditions,
    ROUND(SUM(CASE
                WHEN Accident_Severity IN (1 , 2) THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS Severe_accident_percentage
FROM
    accidents
GROUP BY Road_Surface_Conditions
ORDER BY Severe_accident_percentage DESC;

#Road condition 4 which is frost or ice has the highest number of severe accident percentage

-- Compare accident severity between urban and rural areas using SQL window functions.

SELECT 
    Urban_or_Rural_Area, 
    Accident_Severity, 
    COUNT(*) AS Total_Accidents, 
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Urban_or_Rural_Area), 2) AS Percentage_Within_Area 
FROM Accidents
GROUP BY 
    Urban_or_Rural_Area, 
    Accident_Severity
ORDER BY  
    Urban_or_Rural_Area, 
    Accident_Severity;
    
#Urban areas with Slight accident severeity has the highest percentage of accidents.

-- Identify accident hotspots using a clustering approach in SQL
SELECT 
    Longitude, 
    Latitude, 
    COUNT(*) AS Accident_Count
FROM Accidents
GROUP BY Longitude, Latitude
HAVING COUNT(*) > (
    SELECT AVG(Accident_Count) 
    FROM ( 
        SELECT Longitude, Latitude, COUNT(*) AS Accident_Count 
        FROM Accidents 
        GROUP BY Longitude, Latitude
    ) AS SubQuery
)
ORDER BY Accident_Count DESC;

-- Determine the influence of weather conditions on accident severity
SELECT 
    Weather_Conditions, 
    Accident_Severity, 
    COUNT(*) AS Total_Accidents,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Weather_Conditions), 2) AS Percentage_Within_Condition
FROM Accidents
GROUP BY Weather_Conditions, Accident_Severity
ORDER BY Weather_Conditions, Accident_Severity;

-- Find the most accident-prone vehicle type and its impact on casualties
SELECT 
    Vehicle_Type, 
    COUNT(DISTINCT vehicles.Accident_Index) AS Total_Accidents, 
    COUNT(Casualty_Reference) AS Total_Casualties,
    ROUND(AVG(Casualty_Severity), 2) AS Avg_Casualty_Severity
FROM vehicles 
JOIN casualties  ON vehicles.Accident_Index = casualties.Accident_Index
GROUP BY Vehicle_Type
ORDER BY Total_Casualties DESC
LIMIT 5;

#Vehicle Type 9 representing car is the most accident-prone vehicle type and average casualty severity is 2.93.

--  Analyze accident trends over time using a moving average
SELECT 
    Date, 
    COUNT(*) AS Daily_Accidents, 
    ROUND(AVG(COUNT(*)) OVER (ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS Seven_Day_Avg
FROM Accidents
GROUP BY Date
ORDER BY Date;
