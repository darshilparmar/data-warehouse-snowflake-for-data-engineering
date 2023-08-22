// Setting up table

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string)
    


CREATE OR REPLACE FILE FORMAT MANAGE_DB.file_formats.csv_file
    type = csv
    field_delimiter = ','
    skip_header = 1
    
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = MANAGE_DB.file_formats.csv_file;
    

LIST @MANAGE_DB.external_stages.time_travel_stage


COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv')


SELECT * FROM OUR_FIRST_DB.public.test

// Use-case: Update data (by mistake)

UPDATE OUR_FIRST_DB.public.test
SET FIRST_NAME = 'Joyen' 


// // // Using time travel: Method 1 - 2 minutes back
SELECT * FROM OUR_FIRST_DB.public.test at (OFFSET => -60*1.5)


// // // Using time travel: Method 2 - before timestamp
SELECT * FROM OUR_FIRST_DB.public.test before (timestamp => '2021-04-15 17:47:50.581'::timestamp)


-- Setting up table
CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);

COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');


SELECT * FROM OUR_FIRST_DB.public.test;


2021-04-17 08:16:24.259

-- Setting up UTC time for convenience


ALTER SESSION SET TIMEZONE ='UTC'
SELECT DATEADD(DAY, 1, CURRENT_TIMESTAMP)



UPDATE OUR_FIRST_DB.public.test
SET Job = 'Data Scientist'


SELECT * FROM OUR_FIRST_DB.public.test;

SELECT * FROM OUR_FIRST_DB.public.test before (timestamp => '2021-04-16 07:30:47.145'::timestamp)




// // // Using time travel: Method 3 - before Query ID

// Preparing table
CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Phone string,
  Job string)

COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv')


SELECT * FROM OUR_FIRST_DB.public.test


// Altering table (by mistake)
UPDATE OUR_FIRST_DB.public.test
SET EMAIL = null

SELECT * FROM OUR_FIRST_DB.public.test

SELECT * FROM OUR_FIRST_DB.public.test before (statement => '019b9ee5-0500-8473-0043-4d8300073062')


