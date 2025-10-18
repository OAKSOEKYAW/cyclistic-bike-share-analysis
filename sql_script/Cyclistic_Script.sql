USE cyclistic;

CREATE TABLE cyclistic_trips_2019_q1 (
    trip_id BIGINT,
    start_time VARCHAR(50),
    end_time VARCHAR(50),
    bikeid INT,
    tripduration INT,
    from_station_id INT,
    from_station_name VARCHAR(255),
    to_station_id INT,
    to_station_name VARCHAR(255),
    usertype VARCHAR(50),
    gender VARCHAR(50),
    birthyear INT
);

CREATE TABLE cyclistic_trips_2019_q2 (
    trip_id BIGINT,
    start_time VARCHAR(50),
    end_time VARCHAR(50),
    bikeid INT,
    tripduration INT,
    from_station_id INT,
    from_station_name VARCHAR(255),
    to_station_id INT,
    to_station_name VARCHAR(255),
    usertype VARCHAR(50),
    gender VARCHAR(50),
    birthyear INT
);

CREATE TABLE cyclistic_trips_2019_q3 (
    trip_id BIGINT,
    start_time VARCHAR(50),
    end_time VARCHAR(50),
    bikeid INT,
    tripduration INT,
    from_station_id INT,
    from_station_name VARCHAR(255),
    to_station_id INT,
    to_station_name VARCHAR(255),
    usertype VARCHAR(50),
    gender VARCHAR(50),
    birthyear INT
);

CREATE TABLE cyclistic_trips_2019_q4 (
    trip_id BIGINT,
    start_time VARCHAR(50),
    end_time VARCHAR(50),
    bikeid INT,
    tripduration INT,
    from_station_id INT,
    from_station_name VARCHAR(255),
    to_station_id INT,
    to_station_name VARCHAR(255),
    usertype VARCHAR(50),
    gender VARCHAR(50),
    birthyear INT
);

CREATE TABLE cyclistic_trips_2020_q1 (
    trip_id VARCHAR(255),
    start_time VARCHAR(50),
    end_time VARCHAR(50),
	from_station_name VARCHAR(255),
    from_station_id INT,
	to_station_name VARCHAR(255),
    to_station_id INT,
    usertype VARCHAR(50)
);







SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'pid_file';

-- Enables MySQL to load data from local files on the client machine using the LOAD DATA LOCAL INFILE command.
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'D:/Case_Studies_(DataAnalyst)/Bike/Dataset/Datasets_to_work_with/Divvy_Trips_2019_Q1.csv'
INTO TABLE cyclistic_trips_2019_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'D:\Case_Studies_(DataAnalyst)\Bike\Dataset\Datasets_to_work_with\Divvy_Trips_2019_Q1.csv'
INTO TABLE cyclistic_trips_2019_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



LOAD DATA LOCAL INFILE 'D:/Case_Studies_(DataAnalyst)/Bike/Dataset/Datasets_to_work_with/Divvy_Trips_2020_Q1.csv'
INTO TABLE cyclistic_trips_2020_q1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
	trip_id,
    @rideable_type,
	start_time,
    end_time,
    from_station_name,
    from_station_id,
	to_station_name,
    to_station_id,
	@start_lat,
	@start_lng,
	@end_lat,
	@end_lng,
	usertype
);











-- Preparing for Data Cleaning, Copying data from the original table to the new one
DROP TABLE IF EXISTS cyclistic_trips_2019_q1_staging;
CREATE TABLE cyclistic_trips_2019_q1_staging LIKE cyclistic.cyclistic_trips_2019_q1;

DROP TABLE IF EXISTS cyclistic_trips_2019_q2_staging;
CREATE TABLE cyclistic_trips_2019_q2_staging LIKE cyclistic.cyclistic_trips_2019_q2;

DROP TABLE IF EXISTS cyclistic_trips_2019_q3_staging;
CREATE TABLE cyclistic_trips_2019_q3_staging LIKE cyclistic.cyclistic_trips_2019_q3;

DROP TABLE IF EXISTS cyclistic_trips_2019_q4_staging;
CREATE TABLE cyclistic_trips_2019_q4_staging LIKE cyclistic.cyclistic_trips_2019_q4;

DROP TABLE IF EXISTS cyclistic_trips_2020_q1_staging;
CREATE TABLE cyclistic_trips_2020_q1_staging LIKE cyclistic.cyclistic_trips_2020_q1;












-- Insering all the Data from the original table for Data Cleaning
INSERT cyclistic_trips_2019_q1_staging
SELECT * FROM cyclistic_trips_2019_q1;

INSERT cyclistic_trips_2019_q2_staging
SELECT * FROM cyclistic_trips_2019_q2;

SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL max_allowed_packet = 1073741824; -- 1GB

SHOW VARIABLES LIKE 'max_allowed_packet';

INSERT cyclistic_trips_2019_q3_staging
SELECT * FROM cyclistic_trips_2019_q3;

INSERT cyclistic_trips_2019_q4_staging
SELECT * FROM cyclistic_trips_2019_q4;

INSERT cyclistic_trips_2020_q1_staging
SELECT * FROM cyclistic_trips_2020_q1;









/* 
---------------------------------------------
Cyclistic Bike-Share Data Cleaning Summary
---------------------------------------------
This section documents the data cleaning and standardization process 
performed on the quarterly Cyclistic datasets (2019 Q1–2020 Q1) to 
prepare them for analysis.

Objective:
Ensure data consistency, integrity, and reliability across all tables 
so that meaningful comparisons can be made between annual members 
and casual riders.

Key Steps and Decisions:
1. Standardized table structures — aligned column names, order, and datatypes 
   across all quarters to ensure compatibility for merging and analysis.

2. Removed unnecessary or inconsistent fields — columns such as bikeid, 
   gender, and birthyear were excluded as they were not essential to 
   the business objective.

3. Checked for missing or blank values — records with null or empty values 
   in critical fields (start_time, end_time, from_station_name, to_station_name) 
   were deleted to maintain data completeness.

4. Identified and removed outliers — trips with unrealistic durations 
   (less than 60 seconds or longer than 24 hours) were considered system or 
   user errors and removed.

5. Recalculated tripduration where missing — derived as the difference between 
   end_time and start_time (in seconds) for consistency across datasets.

6. Converted trip_id to text datatype — to accommodate both numeric and 
   alphanumeric values in later datasets (e.g., 2020 Q1), ensuring future 
   compatibility and avoiding type conflicts.
 
 7. Unexpected Data Cleaning
*/


-- START OF DATA CLEANING PROCESS
-- Finding duplicate rows
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY trip_id, start_time, end_time, bikeid, tripduration, from_station_id, from_station_name, to_station_id, to_station_name,
usertype, gender, birthyear) AS row_num
FROM cyclistic_trips_2020_q1_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY trip_id, from_station_name, from_station_id, to_station_name, to_station_id, usertype) AS row_num
FROM cyclistic_trips_2020_q1_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- End
SELECT * FROM cyclistic_trips_2020_q1_staging;









-- Creating new table and importing data to that table (unique values) because there was a server connection error when importing the data
-- from csv files, so there are too much duplicates.
CREATE TABLE cyclistic_trips_2019_q3_cleaned AS
SELECT DISTINCT
    trip_id, start_time, end_time, bikeid, tripduration,
    from_station_id, from_station_name, to_station_id, to_station_name,
    usertype, gender, birthyear
FROM cyclistic_trips_2019_q3_staging;

DROP TABLE cyclistic_trips_2019_q3_staging;
RENAME TABLE cyclistic_trips_2019_q3_cleaned TO cyclistic_trips_2019_q3_staging;
-- End

SELECT COUNT(*) FROM  cyclistic_trips_2019_q3;










-- Standardizing Data 
ALTER TABLE cyclistic_trips_2019_q1_staging
DROP COLUMN bikeid,
DROP COLUMN gender,
DROP COLUMN birthyear;




-- Safe Update Mode, which prevents accidental updates or deletes that don’t specify a WHERE condition (to stop you from accidentally updating all rows).
SET SQL_SAFE_UPDATES=0;
SET SQL_SAFE_UPDATES=1;

UPDATE cyclistic_trips_2020_q1_staging
SET from_station_name = TRIM(from_station_name),
	to_station_name = TRIM(to_station_name),
	usertype = TRIM(usertype);
    
SELECT DISTINCT from_station_name FROM cyclistic_trips_2019_q1_staging ORDER BY from_station_name;





-- checing if there are null values or 0 in numerical fields
SELECT * FROM cyclistic_trips_2020_q1_staging
WHERE from_station_id IS NULL OR from_station_id = 0;

SELECT * FROM cyclistic_trips_2020_q1_staging
WHERE to_station_id IS NULL OR to_station_id = 0;

SELECT to_station_id, to_station_name 
FROM cyclistic_trips_2020_q1_staging
WHERE to_station_id = 0 OR to_station_name IN ('', 'NULL');

DELETE FROM cyclistic_trips_2020_q1_staging
WHERE to_station_id = '0' AND (to_station_name IS NULL OR to_station_name = '');







-- checking if there are tripduration that are <= 0 or tripduration > 86,400 (24 hours) and remove it if found.
SELECT 
    MIN(tripduration) AS min_duration,
    MAX(tripduration) AS max_duration,
    AVG(tripduration) AS avg_duration
FROM cyclistic_trips_2019_q1_staging;

-- just double checking for null values
SELECT 
    COUNT(*) AS total_rows,
    SUM(start_time IS NULL) AS missing_start_time,
    SUM(end_time IS NULL) AS missing_end_time,
    SUM(usertype IS NULL) AS missing_usertype
FROM cyclistic_trips_2020_q1_staging;

SELECT tripduration FROM cyclistic_trips_2019_q1_staging WHERE tripduration REGEXP '[^0-9]';



-- Checking the datatypes of the columns
SHOW COLUMNS FROM cyclistic_trips_2019_q1_staging;
SHOW COLUMNS FROM cyclistic_trips_2019_q2_staging;
SHOW COLUMNS FROM cyclistic_trips_2019_q3_staging;
SHOW COLUMNS FROM cyclistic_trips_2019_q4_staging;
SHOW COLUMNS FROM cyclistic_trips_2020_q1_staging;



-- Changing the date to ISO 8601 format (YYYY-MM-DD HH:MM:SS)
UPDATE cyclistic_trips_2019_q1_staging
SET start_time = STR_TO_DATE(start_time, '%c/%e/%Y %H:%i:%s'),
	end_time = STR_TO_DATE(end_time, '%c/%e/%Y %H:%i:%s');	
    
UPDATE cyclistic_trips_2019_q1_staging
SET start_time = STR_TO_DATE(start_time, '%Y-%c-%e %H:%i:%s'),
	end_time = STR_TO_DATE(end_time, '%Y-%c-%e %H:%i:%s');	
    
-- Changing the datatype back to 'DATETIME', at first it was varchar to make the data import process smooth
ALTER TABLE cyclistic_trips_2020_q1_staging
MODIFY COLUMN start_time DATETIME,
MODIFY COLUMN end_time DATETIME;




-- Separating DATE and TIME into separate columns
ALTER TABLE cyclistic_trips_2020_q1_staging
ADD COLUMN start_date_only DATE,
ADD COLUMN start_time_only TIME,
ADD COLUMN end_date_only DATE,
ADD COLUMN end_time_only TIME;


UPDATE cyclistic_trips_2020_q1_staging
SET
	start_date_only = DATE(start_time),
    start_time_only = TIME(start_time),
    end_date_only = DATE(end_time),
    end_time_only = TIME(end_time);


-- Forgot to specify where to put the newly created columns
ALTER TABLE cyclistic_trips_2020_q1_staging
MODIFY COLUMN start_date_only DATE AFTER start_time,
MODIFY COLUMN start_time_only TIME AFTER start_date_only,
MODIFY COLUMN end_date_only DATE AFTER end_time,
MODIFY COLUMN end_time_only TIME AFTER end_date_only;






-- Changing the name of the usertype from 'Subscriber' to 'Member' and 'Customer' to 'Casual'
UPDATE cyclistic_trips_2019_q1_staging
SET usertype = CASE 
    WHEN usertype = 'Subscriber' THEN 'Member'
    WHEN usertype = 'Customer' THEN 'Casual'
    ELSE usertype
END;



-- checking if there are whitespaces in theh usertype column
SELECT CONCAT('[', usertype, ']') AS usertype_checked, COUNT(*)
FROM cyclistic_trips_2020_q1_staging
GROUP BY usertype_checked;


-- In 2020 Q1 table, the data fields are already 'member' and 'casual' so UPDATE command will not work.
-- I just want the first character capitalize and all the other character lower to Standarize all the data value across table.
-- It's like writing the 'PROPER' function or 'TITLE' Case manually in SQL
UPDATE cyclistic_trips_2020_q1_staging
SET usertype = CONCAT(UPPER(LEFT(TRIM(usertype),1)), LOWER(SUBSTRING(TRIM(usertype),2)));





-- This block of code is complicated and will look a bit random
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Calculating new tripduration since the original one seems off
ALTER TABLE cyclistic_trips_2019_q1_staging
ADD COLUMN tripduration2 INT;


UPDATE cyclistic_trips_2019_q1_staging
SET tripduration2 = TIMESTAMPDIFF(SECOND, start_time, end_time);


-- Compare tripduration vs tripduration2 to check if the original data matches your recalculation.
SELECT trip_id, tripduration, tripduration2
FROM cyclistic_trips_2019_q1_staging
WHERE tripduration <> tripduration2;

ALTER TABLE cyclistic_trips_2019_q1_staging
DROP COLUMN tripduration;
-- ----------------------------------------------
-- Changing the name of the column
ALTER TABLE cyclistic_trips_2019_q1_staging
CHANGE COLUMN tripduration2 tripduration INT;
-- ----------------------------------------------


ALTER TABLE cyclistic_trips_2020_q1_staging
ADD COLUMN tripduration INT;


UPDATE cyclistic_trips_2020_q1_staging
SET tripduration = TIMESTAMPDIFF(SECOND, start_time, end_time);



-- Checking for bike ride that are over 24 hours or less than 1 minute and deleting those data because it doens't make sense
SELECT start_time, end_time, tripduration
FROM cyclistic_trips_2020_q1_staging
WHERE tripduration < 60 OR tripduration > 86400;

SELECT COUNT(*)
FROM cyclistic_trips_2020_q1_staging
WHERE tripduration < 60 OR tripduration > 86400;

DELETE FROM cyclistic_trips_2020_q1_staging
WHERE tripduration < 60 OR tripduration > 86400;

SELECT COUNT(*) AS total_rows FROM cyclistic_trips_2019_q4_staging;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Making sure 2020 Q1 table columns align with the rest of the tables
ALTER TABLE cyclistic_trips_2020_q1_staging
MODIFY COLUMN from_station_id INT AFTER end_time_only,
MODIFY COLUMN from_station_name VARCHAR(255) AFTER from_station_id,
MODIFY COLUMN to_station_id INT AFTER from_station_name,
MODIFY COLUMN to_station_name VARCHAR(255) AFTER  to_station_id;



-- Final Checking all the columns if there are any NULL values or not
SELECT 
    SUM(CASE WHEN trip_id IS NULL THEN 1 ELSE 0 END) AS trip_id_nulls,
    SUM(CASE WHEN start_time IS NULL THEN 1 ELSE 0 END) AS start_time_nulls,
    SUM(CASE WHEN end_time IS NULL THEN 1 ELSE 0 END) AS end_time_nulls,
    SUM(CASE WHEN start_date_only IS NULL THEN 1 ELSE 0 END) AS start_date_only_nulls,
    SUM(CASE WHEN end_date_only IS NULL THEN 1 ELSE 0 END) AS end_date_only_nulls,
    SUM(CASE WHEN start_time_only IS NULL THEN 1 ELSE 0 END) AS start_time_only_nulls,
    SUM(CASE WHEN end_time_only IS NULL THEN 1 ELSE 0 END) AS end_time_only_nulls,
    SUM(CASE WHEN from_station_id IS NULL THEN 1 ELSE 0 END) AS from_station_id_nulls,
    SUM(CASE WHEN from_station_name IS NULL OR from_station_name = '' THEN 1 ELSE 0 END) AS from_station_name_nulls,
    SUM(CASE WHEN to_station_id IS NULL THEN 1 ELSE 0 END) AS to_station_id_nulls,
    SUM(CASE WHEN to_station_name IS NULL OR to_station_name = '' THEN 1 ELSE 0 END) AS to_station_name_nulls,
    SUM(CASE WHEN usertype IS NULL OR usertype = '' THEN 1 ELSE 0 END) AS usertype_nulls,
    SUM(CASE WHEN tripduration IS NULL THEN 1 ELSE 0 END) AS tripduration_nulls
FROM cyclistic_trips_2019_q1_staging;


-- Changing datatype of the trip_id column to VARCHAR to match 2020 Q1 table,
-- so that we can combine all 5 tables and start the EDA
ALTER TABLE cyclistic_trips_2019_q4_staging
MODIFY COLUMN trip_id VARCHAR(255);


-- Unexpected Data Cleaning
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- I am getting two separate values for usertype
-- Although I used TRIM for usertype column it only removed Standard spaces (' ') at the beginning and end of the string.
UPDATE cyclistic_trips_analysis
SET usertype = TRIM(
    REPLACE(
        REPLACE(
            REPLACE(usertype, '\r', ''),
        '\n', ''),
    '\t', '')
);

SELECT DISTINCT usertype from cyclistic_trips_analysis;



-- I noticed a really big anomaly from one station where the average duratio is so high from Member
SELECT
    from_station_name,
    usertype,
    ROUND(AVG(tripduration) / 60, 2) AS avg_duration_mins,
    COUNT(*) AS total_trips
FROM cyclistic_trips_analysis
GROUP BY from_station_name, usertype
ORDER BY avg_duration_mins DESC;


SELECT 
  from_station_name,
  usertype,
  COUNT(*) AS cnt,
  ROUND(AVG(tripduration)/60,2) AS avg_mins,
  MAX(tripduration)/60 AS max_mins,
  MIN(tripduration)/60 AS min_mins
FROM cyclistic_trips_analysis
WHERE from_station_name = 'Racine Ave & 61st St'
  AND usertype = 'Member'
GROUP BY from_station_name, usertype;


SELECT trip_id, DAYNAME(start_time), DAYNAME(end_time), from_station_name, to_station_name, tripduration
FROM cyclistic_trips_analysis
WHERE from_station_name = 'Racine Ave & 61st St'
  AND usertype = 'Member'
ORDER BY tripduration DESC
LIMIT 10;





SELECT COUNT(*) FROM cyclistic_trips_analysis
WHERE tripduration > 36000 AND usertype = 'Member';

SELECT 
  usertype,
  CASE
    WHEN tripduration/3600 <= 1 THEN '≤1 hr'
    WHEN tripduration/3600 <= 2 THEN '1–2 hrs'
    WHEN tripduration/3600 <= 4 THEN '2–4 hrs'
    WHEN tripduration/3600 <= 6 THEN '4–6 hrs'
    WHEN tripduration/3600 <= 10 THEN '6–10 hrs'
    ELSE '>10 hrs'
  END AS duration_range,
  COUNT(*) AS trip_count
FROM cyclistic_trips_analysis
GROUP BY usertype, duration_range
ORDER BY usertype, duration_range;







-- 10/16/2025
-- Just realized needed to consider about tripduration
-- Trips lasting 5 minutes or less where the start and end station were identical were removed. 
-- These records likely represent aborted or test rides and do not reflect meaningful user behavior
SELECT COUNT(*) AS total
FROM cyclistic_trips_analysis
WHERE tripduration <= 300 AND from_station_name = to_station_name;



-- Trips lasting 5 minutes or less is still possible to make a trip to another station
SELECT COUNT(*) AS total
FROM cyclistic_trips_analysis
WHERE tripduration <= 300 AND from_station_name != to_station_name;

DELETE FROM cyclistic_trips_analysis
WHERE tripduration <= 300
  AND from_station_name = to_station_name;




-- Additionally found 919 rows where trip durations are under 60 seconds but start station and end station are different.
-- There is no chance a rider could travel to another station in 1 minute
-- So concluded it's likely due to system error or log error
SELECT tripduration, from_station_name, to_station_name, start_time, end_time
FROM cyclistic_trips_analysis
WHERE tripduration <= 60;

SELECT COUNT(*) AS total
FROM cyclistic_trips_analysis
WHERE tripduration <= 60 AND usertype = 'Casual';


-- Since this analysis is for business insights and not for Data auditing or system monitoring, it will be deleted
DELETE FROM cyclistic_trips_analysis
WHERE tripduration <= 60;

-- Still there is no way to travel between station to station around 4 minute range but 5 minute might still be possible
-- So trip duration under 4 minutes will also be deleted and not realistic to include in this analysis
SELECT 
    COUNT(*) AS total_short_trips,
    SUM(CASE WHEN from_station_name = to_station_name THEN 1 ELSE 0 END) AS same_station_count,
    ROUND(SUM(CASE WHEN from_station_name = to_station_name THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS same_station_percent
FROM cyclistic_trips_analysis
WHERE tripduration <= 240;

DELETE FROM cyclistic_trips_analysis
WHERE tripduration <= 240;




-- There are trips that are over 6 hours in duration and need to mark it as outlier
-- Even though there are people who would actually rent a bike for six hour for leisure purposes
-- it's not a normal behavior of the general population
-- Because we are studying human behavior pattern, those above 6 hours need to be marked as outlier or anomaly
ALTER TABLE cyclistic_trips_analysis 
ADD COLUMN outlier_flag BOOLEAN DEFAULT 0;

UPDATE cyclistic_trips_analysis
SET outlier_flag = 1
WHERE tripduration > 21600;  -- 6 hours = 21600 seconds




-- Adding this column so that it will be easier to work with visualizations in POWERBI
ALTER TABLE cyclistic_trips_analysis 
ADD COLUMN quarter_order INT;

UPDATE cyclistic_trips_analysis
SET quarter_order = CASE source_quarter
WHEN '2019_Q1' THEN 1
WHEN '2019_Q2' THEN 2
WHEN '2019_Q3' THEN 3
WHEN '2019_Q4' THEN 4
WHEN '2020_Q1' THEN 5
ELSE NULL
END;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- END OF DATA CLEANING PROCESS




-- EDA START

-- 1. Understand the Data Structure
-- 2. Summarize Key Columns (explore general patterns)
-- 3. Compare Behavior (based on business objective)
-- 4. Look for Trends & Opportunities

-- Combining all the tables for EDA Process
CREATE TABLE cyclistic_trips_analysis AS
SELECT *, '2019_Q1' AS source_quarter FROM cyclistic_trips_2019_q1_staging
UNION ALL
SELECT *, '2019_Q2' FROM cyclistic_trips_2019_q2_staging
UNION ALL
SELECT *, '2019_Q3' FROM cyclistic_trips_2019_q3_staging
UNION ALL
SELECT *, '2019_Q4' FROM cyclistic_trips_2019_q4_staging
UNION ALL
SELECT *, '2020_Q1' FROM cyclistic_trips_2020_q1_staging;


-- Checking if all the rows were combined properly
SELECT 'total' AS label, COUNT(*) FROM cyclistic_trips_analysis;
SELECT 'sum_of_parts' AS label,
 (SELECT COUNT(*) FROM cyclistic_trips_2019_q1_staging)
 + (SELECT COUNT(*) FROM cyclistic_trips_2019_q2_staging)
 + (SELECT COUNT(*) FROM cyclistic_trips_2019_q3_staging)
 + (SELECT COUNT(*) FROM cyclistic_trips_2019_q4_staging)
 + (SELECT COUNT(*) FROM cyclistic_trips_2020_q1_staging) AS sum_total;
 



-- Understand the Data Structure
SELECT COUNT(*) FROM cyclistic_trips_analysis;

DESCRIBE cyclistic_trips_analysis;

SELECT * FROM cyclistic_trips_analysis
WHERE tripduration <= 180;


-- !IMPORTANT NOTE
-- Trips exceeding 6 hours were identified as potential outliers. 
-- After testing analyses with and without these records, there was no significant difference in key findings or insights. 
-- Therefore, all data points were retained for the final analysis to preserve completeness and transparency.

SELECT 
  MIN(tripduration) AS shortest,
  MAX(tripduration) AS longest,
  ROUND(AVG(tripduration)/60, 2) AS avg_duration_mins
FROM cyclistic_trips_analysis;



SELECT usertype, COUNT(*) AS total_trips
FROM cyclistic_trips_analysis
GROUP BY usertype;

SELECT 
  usertype,
  ROUND(AVG(tripduration)/60, 2) AS avg_duration_mins
FROM cyclistic_trips_analysis
GROUP BY usertype;

SELECT 
  usertype, SUM(tripduration)
FROM cyclistic_trips_analysis
GROUP BY usertype;


SELECT 
  usertype,
  DAYNAME(start_time) AS day_of_week,
  COUNT(*) AS total_trips
FROM cyclistic_trips_analysis
GROUP BY usertype, day_of_week
ORDER BY usertype, total_trips DESC;

SELECT 
  usertype,
  HOUR(start_time) AS hour_of_day,
  COUNT(*) AS total_trips
FROM cyclistic_trips_analysis
GROUP BY usertype, hour_of_day
ORDER BY usertype, hour_of_day;


SELECT 
  usertype,
  from_station_name,
  COUNT(*) AS total_starts
FROM cyclistic_trips_analysis
GROUP BY usertype, from_station_name
ORDER BY total_starts DESC
LIMIT 20;



SELECT 
    source_quarter,
    usertype,
    COUNT(*) AS total_trips
FROM cyclistic_trips_analysis
GROUP BY source_quarter, usertype
ORDER BY source_quarter, usertype;


SELECT usertype, SUM(tripduration)
FROM cyclistic_trips_analysis
GROUP BY usertype;


-- Top 10 popular stations by usertype for Q3 2019
SELECT 
    usertype,
    from_station_name,
    COUNT(*) AS total_trips
FROM cyclistic_trips_analysis
WHERE source_quarter = '2019_Q3'
GROUP BY usertype, from_station_name
ORDER BY usertype, total_trips DESC;


SELECT 
  usertype,
  from_station_name,
  COUNT(*) AS total_trips,
  ROUND(AVG(tripduration)/60, 2) AS avg_duration_mins
FROM cyclistic_trips_analysis
WHERE source_quarter = '2019_Q3'
GROUP BY usertype, from_station_name
ORDER BY total_trips DESC
LIMIT 20;


SELECT * FROM cyclistic_trips_analysis;


SELECT * FROM cyclistic_trips_2019_q1_staging;
SELECT * FROM cyclistic_trips_2019_q2_staging;
SELECT * FROM cyclistic_trips_2019_q3_staging;
SELECT * FROM cyclistic_trips_2019_q4_staging;
SELECT * FROM cyclistic_trips_2020_q1_staging;

SELECT * FROM cyclistic_trips_2019_q1;
SELECT * FROM cyclistic_trips_2019_q2;
SELECT * FROM cyclistic_trips_2019_q3;
SELECT * FROM cyclistic_trips_2019_q4;
SELECT * FROM cyclistic_trips_2020_q1;
SELECT * FROM cyclistic_trips_analysis;
SELECT COUNT(*) FROM cyclistic_trips_analysis;

USE cyclistic;
SELECT VERSION();