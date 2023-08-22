CREATE OR REPLACE DATABASE DATA_S;

CREATE OR REPLACE STAGE aws_stage
    url='s3://bucketsnowflakes3';

// List files in stage
LIST @aws_stage;

// Create table
CREATE OR REPLACE TABLE ORDERS (
ORDER_ID	VARCHAR(30)
,AMOUNT	NUMBER(38,0)
,PROFIT	NUMBER(38,0)
,QUANTITY	NUMBER(38,0)
,CATEGORY	VARCHAR(30)
,SUBCATEGORY	VARCHAR(30)); 


// Load data using copy command
COPY INTO ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*OrderDetails.*';
    
SELECT * FROM ORDERS;


// Create a share object
CREATE OR REPLACE SHARE ORDERS_SHARE;

---- Setup Grants ----

// Grant usage on database
GRANT USAGE ON DATABASE DATA_S TO SHARE ORDERS_SHARE; 

// Grant usage on schema
GRANT USAGE ON SCHEMA DATA_S.PUBLIC TO SHARE ORDERS_SHARE; 

// Grant SELECT on table

GRANT SELECT ON TABLE DATA_S.PUBLIC.ORDERS TO SHARE ORDERS_SHARE; 

// Validate Grants
SHOW GRANTS TO SHARE ORDERS_SHARE;

---- Add Consumer Account ----
ALTER SHARE ORDERS_SHARE ADD ACCOUNT=<consumer-account-id>;



-- reader acc


-- Create Reader Account --

CREATE MANAGED ACCOUNT tech_joy_account
ADMIN_NAME = tech_joy_admin,
ADMIN_PASSWORD = 'P@ssw0rd123$',
TYPE = READER;

// Make sure to have selected the role of accountadmin

// Show accounts
SHOW MANAGED ACCOUNTS;


-- Share the data -- 

ALTER SHARE ORDERS_SHARE 
ADD ACCOUNT = OM47533;


ALTER SHARE ORDERS_SHARE 
ADD ACCOUNT =  <reader-account-id>
SHARE_RESTRICTIONS=false;



-- Create database from share --

// Show all shares (consumer & producers)
SHOW SHARES;

// See details on share
DESC SHARE QNA46172.ORDERS_SHARE;

// Create a database in consumer account using the share
CREATE DATABASE DATA_SHARE_DB FROM SHARE <account_name_producer>.ORDERS_SHARE;

// Validate table access
SELECT * FROM  DATA_SHARE_DB.PUBLIC.ORDERS


// Setup virtual warehouse
CREATE WAREHOUSE READ_WH WITH
WAREHOUSE_SIZE='X-SMALL'
AUTO_SUSPEND = 180
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE;
