
create or replace storage integration s3_init
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::2034864637456:role/snowflake-s3-connection'
  STORAGE_ALLOWED_LOCATIONS = ('s3://dw-snowflake-course-darshil')
   COMMENT = 'Creating connection to S3' 


DESC integration s3_init;

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_S3_INT (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));
    
// Create file format object
CREATE OR REPLACE file format MANAGE_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;

    
 // Create stage object with integration object & file format object
CREATE OR REPLACE stage MANAGE_DB.external_stages.csv_folder
    URL = 's3://dw-snowflake-course-darshil/OrderDetails.csv'
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = MANAGE_DB.file_formats.csv_fileformat

//Load data using copy command

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_S3_INT
    FROM @MANAGE_DB.external_stages.csv_folder;

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_S3_INT;