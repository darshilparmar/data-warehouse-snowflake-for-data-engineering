
CREATE OR REPLACE stage MANAGE_DB.EXTERNAL_STAGES.JSONSTAGE
     url='s3://bucketsnowflake-jsondemo';

CREATE OR REPLACE file format MANAGE_DB.FILE_FORMATS.JSONFORMAT
    TYPE = JSON;

CREATE DATABASE OUR_FIRST_DB;

CREATE OR REPLACE table OUR_FIRST_DB.PUBLIC.JSON_RAW (
    raw_file variant);

COPY INTO OUR_FIRST_DB.PUBLIC.JSON_RAW
    FROM @MANAGE_DB.EXTERNAL_STAGES.JSONSTAGE
    file_format= MANAGE_DB.FILE_FORMATS.JSONFORMAT
    files = ('HR_data.json');    

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT $1:city City, $1:first_name::string FirstName FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;


SELECT 
    RAW_FILE:id::int as id,  
    RAW_FILE:first_name::STRING as first_name,
    RAW_FILE:last_name::STRING as last_name,
    RAW_FILE:gender::STRING as gender
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

 // Handling nested data
   
SELECT RAW_FILE:job.salary, RAW_FILE:job.title as job  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:prev_company[0]::string as prev_company
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;



SELECT 
    RAW_FILE:spoken_languages as spoken_languages
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

CREATE OR REPLACE TABLE Languages AS
select
      RAW_FILE:first_name::STRING as First_name,
      f.value:language::STRING language,
      f.value:level::STRING level
from OUR_FIRST_DB.PUBLIC.JSON_RAW, table(flatten(RAW_FILE:spoken_languages)) f

SELECT * FROM Languages;

