CREATE DATABASE NYC_test_score;
USE NYC_test_score;

CREATE TABLE sat_results (
    dbn VARCHAR(10) PRIMARY KEY,
    school_name VARCHAR(255),
    num_of_sat_test_takers INT,
    sat_critical_reading_avg_score INT,
    sat_math_avg_score INT,
    sat_writing_avg_score INT
);

-- What are the top 10 schools with the highest graduation rates?
SELECT 
    school_name, total_grads___n
FROM
    graduation_rates
ORDER BY total_grads___n DESC
LIMIT 10;

-- How do graduation rates vary across different school districts?

SELECT 
    borough, SUM(total_grads___n) AS Total_grads
FROM
    high_school_directory
        JOIN
    graduation_rates ON high_school_directory.school_name = graduation_rates.school_name
GROUP BY borough
ORDER BY Total_grads DESC;

-- Is there a correlation between class size and graduation rates?
SELECT 
    class_size.school_name,
    ROUND(AVG(average_class_size),1),
    ROUND (AVG(total_grads___n),1) AS Avg_Num_grads
FROM
    class_size
        JOIN
    graduation_rates ON class_size.school_name = graduation_rates.school_name
GROUP BY school_name
ORDER BY Avg_Num_grads DESC;

-- Which schools have the largest average class sizes?
SELECT 
    school_name,
    ROUND(AVG(size_of_largest_class), 0) AS Largest_Avg_Class_size
FROM
    class_size
GROUP BY school_name
ORDER BY Largest_Avg_Class_size DESC
LIMIT 10;

-- Do schools with smaller average class sizes have better SAT scores
SELECT 
    class_size.school_name,
    ROUND(AVG(average_class_size), 0) AS Average_class_size,
    SUM(sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score) AS total_sat_score
FROM
    class_size
        JOIN
    sat_results ON class_size.school_name = sat_results.school_name
GROUP BY school_name
ORDER BY Average_class_size ASC;

-- What is the average class size per borough?
SELECT 
    high_school_directory.borough,
    ROUND(AVG(average_class_size), 0) AS Average_class_size
FROM
    class_size
        JOIN
    high_school_directory ON class_size.school_name = high_school_directory.school_name
GROUP BY high_school_directory.borough
ORDER BY Average_class_size;

 -- How has student enrollment changed over the years?
SELECT 
    schoolyear, 
    SUM(total_enrollment) AS total_students
FROM 
    school_demographics
GROUP BY 
    schoolyear
ORDER BY 
    schoolyear ASC;
    
-- What is the racial distribution of students across different schools?
SELECT 
    sat_results.school_name, 
    asian_per AS Asian_Percentage, 
    black_per AS Black_Percentage, 
    hispanic_per AS Hispanic_Percentage, 
    white_per AS White_Percentage
FROM sat_results JOIN school_demographics ON sat_results.dbn = school_demographics .dbn ;
    

-- Which schools have the highest and lowest SAT scores?
SELECT 
    school_name, 
    (sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score) / 3 AS total_average
FROM 
    sat_results
WHERE 
    (sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score) / 3 = 
    (SELECT MAX((sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score) / 3)
     FROM sat_results);
     
SELECT 
    school_name, 
    (sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score) / 3 AS total_average
FROM 
    sat_results
WHERE 
    (sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score) / 3 = 
    (SELECT MIN((sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score) / 3)
     FROM sat_results);
     
-- How do SAT scores impact graduation rates across different schools?
SELECT 
    g.school_name,
    ROUND(AVG(s.sat_critical_reading_avg_score + s.sat_math_avg_score + s.sat_writing_avg_score),
            0) AS total_avg_sat_score,
    g.total_grads___n AS total_graduates,
    ROUND((g.total_grads___n * 100.0) / g.cohort,
            2) AS graduation_rate
FROM
    graduation_rates g
        JOIN
    sat_results s ON g.school_name = s.school_name
WHERE
    g.cohort > 0
GROUP BY g.school_name , g.total_grads___n , g.cohort
ORDER BY total_avg_sat_score DESC;

-- How do SAT scores differ based on class size?
SELECT 
    ROUND(AVG(class_size.average_class_size), 0) AS Average_class_size, 
    ROUND(AVG(sat_critical_reading_avg_score + sat_math_avg_score + sat_writing_avg_score), 0) AS total_average_scores
FROM class_size
JOIN sat_results ON class_size.school_name = sat_results.school_name 
GROUP BY class_size.average_class_size
ORDER BY Average_class_size;

-- Which borough has the highest number of high schools?
SELECT 
    borough, COUNT(*) AS Total_High_Schools
FROM
    high_school_directory
GROUP BY borough
ORDER BY Total_High_Schools DESC
LIMIT 1;

-- What are the top-ranked schools based on SAT and graduation data?
SELECT 
    graduation_rates.school_name,
    ROUND(AVG(sat_critical_reading_avg_score) + AVG(sat_math_avg_score) + AVG(sat_writing_avg_score),
            0) AS total_average_scores,
    SUM(total_grads___n) AS Total_graduates
FROM
    graduation_rates
        JOIN
    sat_results ON graduation_rates.school_name = sat_results.school_name
GROUP BY graduation_rates.school_name
ORDER BY total_average_scores DESC , Total_graduates DESC
LIMIT 5;

--  Which high schools offer specialized programs like STEM or arts?
SELECT 
    school_name, 
    overview_paragraph
FROM 
    high_school_directory
WHERE 
    LOWER(overview_paragraph) LIKE '%stem%' 
    OR LOWER(overview_paragraph) LIKE '%science%' 
    OR LOWER(overview_paragraph) LIKE '%technology%' 
    OR LOWER(overview_paragraph) LIKE '%engineering%' 
    OR LOWER(overview_paragraph) LIKE '%math%' 
    OR LOWER(overview_paragraph) LIKE '%arts%' 
    OR LOWER(overview_paragraph) LIKE '%music%' 
    OR LOWER(overview_paragraph) LIKE '%theater%' 
    OR LOWER(overview_paragraph) LIKE '%visual arts%'
ORDER BY school_name;