// Creating schema to keep things organized
CREATE OR REPLACE SCHEMA MANAGE_DB.file_formats;

// Create File Format Object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.file_formats.my_file_format;

// See properties of file format object
DESC file format MANAGE_DB.file_formats.csv_file_format;

// Altering file format object
ALTER file format MANAGE_DB.file_formats.my_file_format
    SET SKIP_HEADER = 1;

// Defining properties on creation of file format object   
CREATE OR REPLACE file format MANAGE_DB.file_formats.my_file_format
    TYPE=JSON,
    TIME_FORMAT=AUTO;   

// Altering the type of a file format is not possible
ALTER file format MANAGE_DB.file_formats.my_file_format
SET TYPE = CSV;


CREATE OR REPLACE FILE FORMAT MANAGE_DB.file_formats.csv_file_format
TYPE = CSV,
FIELD_DELIMITER = ","
SKIP_HEADER = 1;

TRUNCATE  MANAGE_DB.PUBLIC.ORDERS;

COPY INTO MANAGE_DB.PUBLIC.ORDERS
    FROM  @MANAGE_DB.external_stages.aws_stage
    file_format = (FORMAT_NAME= MANAGE_DB.file_formats.csv_file_format )
    files = ('OrderDetails.csv');

SELECT * FROM  MANAGE_DB.PUBLIC.ORDERS;