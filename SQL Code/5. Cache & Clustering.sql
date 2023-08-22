// Publicly accessible staging area    
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.aws_stage
    url='s3://bucketsnowflakes3';

// List files in stage
LIST @MANAGE_DB.external_stages.aws_stage;


CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

    
//Load data using copy command

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*OrderDetails.*';
    

// Create table
CREATE OR REPLACE TABLE ORDERS_CACHING (
ORDER_ID	VARCHAR(30)
,AMOUNT	NUMBER(38,0)
,PROFIT	NUMBER(38,0)
,QUANTITY	NUMBER(38,0)
,CATEGORY	VARCHAR(30)
,SUBCATEGORY	VARCHAR(30)
,DATE DATE)  ;  


INSERT INTO ORDERS_CACHING 
SELECT
t1.ORDER_ID
,t1.AMOUNT	
,t1.PROFIT	
,t1.QUANTITY	
,t1.CATEGORY	
,t1.SUBCATEGORY	
,DATE(UNIFORM(1500000000,1700000000,(RANDOM())))
FROM ORDERS t1
CROSS JOIN (SELECT * FROM ORDERS) t2
CROSS JOIN (SELECT TOP 100 * FROM ORDERS) t3


// Query Performance before Cluster Key
SELECT * FROM ORDERS_CACHING  WHERE DATE = '2020-06-10'


// Adding Cluster Key & Compare the result
ALTER TABLE ORDERS_CACHING CLUSTER BY ( DATE ) 

SELECT * FROM ORDERS_CACHING  WHERE DATE = '2020-01-09'


// Not ideal clustering & adding a different Cluster Key using function
SELECT * FROM ORDERS_CACHING  WHERE MONTH(DATE)=11

ALTER TABLE ORDERS_CACHING CLUSTER BY ( MONTH(DATE) )
