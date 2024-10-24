-- THE BEGINING OF SCRIPT --

#######################################################################
-- DESIGN DATABASE
#######################################################################

SHOW DATABASES;

-- Create Database
CREATE DATABASE IF NOT EXISTS kc_earthquake_db;
USE kc_earthquake_db;

-- Create Table
DROP TABLE IF EXISTS earthquake_tb;
CREATE TABLE IF NOT EXISTS earthquake_tb (
    earthquake_id INTEGER NOT NULL,
    occurred_on DATETIME,
    latitude DECIMAL(5,3),
    longitude FLOAT8,
    depth DOUBLE,
    magnitude DOUBLE,
    calculation_method VARCHAR(10),
    network_id VARCHAR(50),
    place VARCHAR(100),
    cause VARCHAR(50),
    CONSTRAINT earthquake_pkey PRIMARY KEY (earthquake_id)
);


#######################################################################
-- LOAD DATASETS
#######################################################################

-- START TRANSACTION;  -- Uncomment this line to start transaction.
 
-- Set the local_infile to 'ON' for faster loading
SET GLOBAL local_infile = 'ON';

-- Use the SHOW command to see that it is effected
SHOW GLOBAL VARIABLES LIKE 'local_infile';

SHOW VARIABLES LIKE "secure_file_priv";

-- To load heavy data in MySQL, begin by loading the first 12,000 records
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/input_files/dbin_earthquake_1.csv' 
INTO TABLE earthquake_tb
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(earthquake_id,occurred_on,latitude,longitude,depth,magnitude,
calculation_method,network_id,place,cause);

-- Displaying the total number of records in a table to see the 12,000 records
SELECT COUNT(*)
FROM earthquake_tb;


-- Load the last 11,119 records -- LIFOLI
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/input_files/dbin_earthquake_2.csv' 
INTO TABLE earthquake_tb
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(earthquake_id,occurred_on,latitude,longitude,depth,magnitude,
calculation_method,network_id,place,cause);

SHOW TABLES;

########################################################################
-- DATA CLEANING
########################################################################



########################################################################
-- EXPLORATORY DATA ANALYSIS
########################################################################

-- Displaying the Table Structure that was imported
describe earthquake_tb;

select * from earthquake_tb;

select count(*) from earthquake_tb;

-- SOME USEFUL INSIGHTS FROM THE EARTHQUAKE TABLE

-- 01: The highest cause of earthquake
select distinct cause, count(cause) as 'occurrence'
from earthquake_tb
group by cause
order by occurrence desc;
/*
This suggests that natural phenomena were the leading causes of earthquake.
However, it is not immediately clear if these are completely random occurrences or 
if natural factors (like temperature, topography, etc.) influenced the frequency and magnitude of the earthquakes.
*/


-- 02: Top 10 regions mostly affected by earthquakes
select place, count(cause) as 'occurrence'
from earthquake_tb
group by place
order by occurrence Desc
limit 10;

-- 03a: Top 10 regions mostly affected by nuclear explosions
select place, count(cause) as 'occurrence'
from earthquake_tb
where cause like '%nuclear%'
group by place
order by occurrence Desc
limit 10;
/*
The analysis show that 'eastern Kazakhstan' region was mostly ravaged by nuclear explosions (92 explosions).
This region borders Abai Region to the west, Russia's Altai Krai and Altai Republic to the north and
China's Xinjiang Uyghur Autonomous Region to the south and east. This region must have sufferred so much impact
owing to possible weapon testing exercise by Russia and China.
*/

-- 03b: Period time when the highest nuclear explosions occurred
select year(occurred_on) as 'blast_year', count(cause) as 'occurrence'
from earthquake_tb
where place like '%eastern Kazakhstan%'
group by blast_year
order by occurrence desc;
/*
The highest frequency of nuclear explosions in Eastern Kazakhstan was reported in 1984 and 1987. 
As literature suggests there were no reported war in Russia and China around this time, 
other reports suggests that these countries were heavily involved in nuclear weapon testing around this time.
Therefore, recording the highest frequency of nuclear tests in 1984 and 1987 suggests that these countries 
possibly had their major breakthrough in research and development of nuclear weapons around this time.   
*/

-- 04: The earthquake pattern/trend over the years: Finding out how many earthquakes occurred each year
select year(occurred_on) as 'Year_occurred', cause, count(earthquake_id) as 'occurrence'
from earthquake_tb
group by Year_occurred, cause
order by Year_occurred desc;

-- 05: Most likely time of the day an earthquake would occur (before 12noon, between 12:00-18:00, or between 18:00-24:00)


-- 06: what season of the year an earthquake is most likely to occur (Spring, Summer, Autumn, or Winter)
-- Spring = 03 - 05
-- summer = 06 - 08
-- Fall = 09 - 11
-- winter = 12 - 02

select quarter(occurred_on) as 'season', count(earthquake_id) as 'occurrence'
from earthquake_tb
group by season
order by season asc;

SELECT cause, 
       CASE 
           WHEN MONTH(occurred_on) IN (12, 1, 2) THEN 'Winter'
           WHEN MONTH(occurred_on) IN (3, 4, 5) THEN 'Spring'
           WHEN MONTH(occurred_on) IN (6, 7, 8) THEN 'Summer'
           WHEN MONTH(occurred_on) IN (9, 10, 11) THEN 'Autumn'
       END AS season,
       COUNT(*) AS total_earthquakes
FROM earthquake_tb
WHERE cause like '%earthquake%'
GROUP BY season, cause
ORDER BY 
       CASE 
           WHEN season = 'Winter' THEN 1
           WHEN season = 'Spring' THEN 2
           WHEN season = 'Summer' THEN 3
           WHEN season = 'Autumn' THEN 4
       END;

-- 07: Top 3 earthquakes by avg magnitude, average depth. Describing the date and time of occurrence, place, longitude and lattitude could
-- provide an insight as to possible factors that influence such degree of earthquake, including proximity to the equator

select year(occurred_on) as 'blast_year', max(magnitude) as 'max_mag', max(depth) as 'max_depth', count(cause) as 'occurrence'
from earthquake_tb
where cause like '%earthquake%'
group by blast_year
order by max_depth desc;


-- 08: Places with earthquake by explosion
select place, cause
from earthquake_tb
where cause like 'explosion%';

-- 09: Place with the highest magnitude of earthquake
SELECT place, cause, latitude, longitude, magnitude, occurred_on
FROM earthquake_tb
WHERE magnitude =
(SELECT MAX(magnitude)
FROM earthquake_tb);


-- 10: Relationship between magnitude and depth
SELECT magnitude, ROUND(AVG(depth), 2)
FROM earthquake_tb
GROUP BY magnitude
ORDER BY magnitude DESC;

-- Total period of years studied
select count(distinct year(occurred_on)) from earthquake_tb;

select distinct year(occurred_on) as 'blast_year' 
from earthquake_tb
order by blast_year asc;

    -- THE END OF SCRIPT--