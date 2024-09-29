
-- Here we are creating a database of various surveys conducted accross various health care contres in the USA to determine how well the patients are treated or rendered sevice to
-- First step is to create a database and the corresponding tables
CREATE DATABASE healthcare;
USE healthcare;
-- The below code is written as a part of test ride and overite any previous actions made on the tables
-- SELECT * FROM measures;
-- DROP TABLE measures;
-- CREATE TABLE measures (
-- measure_id VARCHAR(20) PRIMARY KEY,
-- measure_name VARCHAR(255),
-- measure_type VARCHAR(255)
-- );
SELECT * FROM national_results;
DROP TABLE IF EXISTS national_results;
CREATE TABLE national_results (
	release_period VARCHAR(20),
    measure_id VARCHAR(20),
    bottom_percent INT,
    middle_percent INT,
    top_percent INT
);
-- This step involves a bit of character re-structure in the table and coverting date columns from str to m/d/y format 

-- Updating the existing values in the release_period column
UPDATE national_results
SET release_period = REPLACE(release_period, '-', '/');

-- Convert release_period as DATE(not required)
-- ALTER TABLE national_results
-- MODIFY COLUMN release_period DATE;

-- Add a a new column new_release_date
ALTER TABLE national_results
ADD COLUMN new_release_date DATE;
-- Update the new column with the converted dates
UPDATE national_results
SET new_release_date = STR_TO_DATE(CONCAT(release_period, '/01'), '%m/%Y/%d');
SELECT * FROM national_results;
DESC national_results;


-- reports -- 
SELECT * FROM reports;
DESC reports;
-- DROP TABLE IF EXISTS reports;
CREATE TABLE reports (
	release_period VARCHAR(20),
    start_date DATE,
    end_date DATE
);
UPDATE reports
SET release_period = REPLACE(release_period, '_', '/');
-- Add column new_release_date 
ALTER TABLE reports
ADD COLUMN new_release_date DATE;
-- Update new column with converted_dates
UPDATE reports 
SET new_release_date = STR_TO_DATE(CONCAT(release_period, '/01'), '%m/%Y/%d');
-- reports --


-- responses--
SELECT * FROM responses;
UPDATE responses
SET release_period = REPLACE(release_period, '_', '/');
-- Add column new_release_date
ALTER TABLE responses
ADD COLUMN new_release_date DATE;
-- Update new column with converted_dates
UPDATE responses
SET new_release_date = STR_TO_DATE(CONCAT(release_period, '/01'), '%m/%Y/%d');
-- responses--

-- state_results -- 
SELECT * FROM state_results;
UPDATE state_results
SET release_period = REPLACE(release_period, '_', '/');
-- Add column new_release_date
ALTER TABLE state_results
ADD COLUMN new_release_date DATE;
-- Update new column with onverted_dates
UPDATE state_results
SET new_release_date = STR_TO_DATE(CONCAT(release_period, '/01'), '%m/%Y/%d');
-- state_results -- 

SELECT * FROM states;

-- Q1 What was the lowest measure ratings at national level
SELECT 
-- new_release_date,
(measures.measure_name),
bottom_percent,
middle_percent,
top_percent
FROM national_results
LEFT JOIN measures ON measures.measure_id = national_results.measure_id
GROUP BY 1
ORDER BY 2;
-- A: 'Communication with Doctors' received the lowest ratings at 4 follwowed by Care Transition & Willingness to Recommend the hospital at 5

-- Q2 In the survey which question had the highest reposnse rate?
SELECT
(measures.measure_id) AS id,
(measures.measure_name) AS name, 
question,
COUNT(CASE WHEN bottom_box_answer = 'Usually' THEN 1 ELSE NULL END) AS low_response,
COUNT(CASE WHEN middle_box_answer = 'Agree' OR 'Probably Yes' THEN 1 ELSE NULL END) AS moderate_repsonse,
COUNT(CASE WHEN top_box_answer = 'Always' OR 'Strongly Agree' OR 'Yes' THEN 1 ELSE NULL END) AS top_response
FROM 
questions
INNER JOIN measures 
ON measures.measure_id = questions.measure_id
GROUP BY name
ORDER BY top_response DESC;
-- A: As per survey data results the respondents were pretty happy with how doctors and nurses treated with courtesy and respect through communication however it was certain that most
-- were not willing to recommend the hospital to their family and friends

-- Q3 Find out which most US region and state partipated in the survey?
/*'300 or more'
'Between 100 and 299'
'Fewer than 100'
'Not Available'
'FEWER THAN 50'
*/
UPDATE responses
SET completed_surveys = REPLACE(completed_surveys, '300 or more', 300);
SET completed_surveys = REPLACE(completed_surveys, 'Between 100 and 299', 270);
SET completed_surveys = REPLACE(completed_surveys, 'Fewer than 100', 98);
SET completed_surveys = REPLACE(completed_surveys, 'Not Available', 0);
SET completed_surveys = REPLACE(completed_surveys, 'FEWER THAN 50', 45);

SELECT 
	DISTINCT(state_name) AS states,
	-- (responses.facility_id) AS hosp_id,
	SUM(responses.completed_surveys) AS total_survey,
	(responses.response_rate_percent) AS res_rt,
    ROUND(SUM(responses.completed_surveys)/COUNT(state_name), 2) AS survey_share_pct,
	region
FROM states
	INNER JOIN responses 
ON states.state = responses.state
-- WHERE responses.completed_surveys = 270
		GROUP BY 1
		ORDER by 4 DESC;
        
-- Q4 Compare national results of surveys with state results
CREATE TABLE national_top_rating
SELECT 
new_release_date,
measure_id,
-- AVG(bottom_percent),
-- AVG(middle_percent),
AVG(top_percent)
OVER(PARTITION BY measure_id) AS avg_national_top_rating
FROM national_results
ORDER BY 3 DESC;

SELECT * FROM national_top_rating;

SELECT
(states.state),
(states.state_name),
(states.region),
(state_results.new_release_date),
(state_results.measure_id),
(state_results.top_box_percent) AS st_top_box_pct,
(national_top_rating.avg_national_top_rating)
-- middle_box_percent,
-- bottom_box_percent
FROM state_results
LEFT JOIN states ON states.state = state_results.state
LEFT JOIN national_top_rating ON national_top_rating.measure_id = state_results.measure_id
GROUP BY 1
ORDER BY 6 DESC;

-- Q5 
















