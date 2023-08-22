USE DEMO_DB;
USE ROLE ACCOUNTADMIN;


-- Prepare table --
create or replace table customers(
  id number,
  full_name varchar, 
  email varchar,
  phone varchar,
  spent number,
  create_date DATE DEFAULT CURRENT_DATE);

-- insert values in table --
insert into customers (id, full_name, email,phone,spent)
values
  (1,'Lewiss MacDwyer','lmacdwyer0@un.org','262-665-9168',140),
  (2,'Ty Pettingall','tpettingall1@mayoclinic.com','734-987-7120',254),
  (3,'Marlee Spadazzi','mspadazzi2@txnews.com','867-946-3659',120),
  (4,'Heywood Tearney','htearney3@patch.com','563-853-8192',1230),
  (5,'Odilia Seti','oseti4@globo.com','730-451-8637',143),
  (6,'Meggie Washtell','mwashtell5@rediff.com','568-896-6138',600);


-- set up roles
CREATE OR REPLACE ROLE ANALYST_MASKED;
CREATE OR REPLACE ROLE ANALYST_FULL;


-- grant select on table to roles
GRANT SELECT ON TABLE DEMO_DB.PUBLIC.CUSTOMERS TO ROLE ANALYST_MASKED;
GRANT SELECT ON TABLE DEMO_DB.PUBLIC.CUSTOMERS TO ROLE ANALYST_FULL;

GRANT USAGE ON SCHEMA DEMO_DB.PUBLIC TO ROLE ANALYST_MASKED;
GRANT USAGE ON SCHEMA DEMO_DB.PUBLIC TO ROLE ANALYST_FULL;

-- grant warehouse access to roles
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_MASKED;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_FULL;


-- assign roles to a user
GRANT ROLE ANALYST_MASKED TO USER NIKOLAISCHULER;
GRANT ROLE ANALYST_FULL TO USER NIKOLAISCHULER;



-- Set up masking policy

create or replace masking policy phone 
    as (val varchar) returns varchar ->
            case        
            when current_role() in ('ANALYST_FULL', 'ACCOUNTADMIN') then val
            else '##-###-##'
            end;
  

-- Apply policy on a specific column 
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN phone 
SET MASKING POLICY PHONE;

-- Validating policies

USE ROLE ANALYST_FULL;
SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;
SELECT * FROM CUSTOMERS;




USE ROLE ACCOUNTADMIN;

--- 1) Apply policy to multiple columns

-- Apply policy on a specific column 
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN full_name 
SET MASKING POLICY phone;

-- Apply policy on another specific column 
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN phone
SET MASKING POLICY phone;



--- 2) Replace or drop policy

DROP masking policy phone;

create or replace masking policy phone as (val varchar) returns varchar ->
            case
            when current_role() in ('ANALYST_FULL', 'ACCOUNTADMIN') then val
            else CONCAT(LEFT(val,2),'*******')
            end;

-- List and describe policies
DESC MASKING POLICY phone;
SHOW MASKING POLICIES;

-- Show columns with applied policies
SELECT * FROM table(information_schema.policy_references(policy_name=>'phone'));


-- Remove policy before replacing/dropping 
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN full_name 
SET MASKING POLICY phone;

ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN email
UNSET MASKING POLICY;

ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN phone
UNSET MASKING POLICY;



-- replace policy
create or replace masking policy names as (val varchar) returns varchar ->
            case
            when current_role() in ('ANALYST_FULL', 'ACCOUNTADMIN') then val
            else CONCAT(LEFT(val,2),'*******')
            end;

-- apply policy
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN full_name
SET MASKING POLICY names;


-- Validating policies
USE ROLE ANALYST_FULL;
SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;
SELECT * FROM CUSTOMERS;






### More examples - 1 - ###

USE ROLE ACCOUNTADMIN;

create or replace masking policy emails as (val varchar) returns varchar ->
case
  when current_role() in ('ANALYST_FULL') then val
  when current_role() in ('ANALYST_MASKED') then regexp_replace(val,'.+\@','*****@') -- leave email domain unmasked
  else '********'
end;


-- apply policy
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN email
SET MASKING POLICY emails;


-- Validating policies
USE ROLE ANALYST_FULL;
SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;
SELECT * FROM CUSTOMERS;

USE ROLE ACCOUNTADMIN;


### More examples - 2 - ###


create or replace masking policy sha2 as (val varchar) returns varchar ->
case
  when current_role() in ('ANALYST_FULL') then val
  else sha2(val) -- return hash of the column value
end;



-- apply policy
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN full_name
SET MASKING POLICY sha2;

ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN full_name
UNSET MASKING POLICY;


-- Validating policies
USE ROLE ANALYST_FULL;
SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;
SELECT * FROM CUSTOMERS;

USE ROLE ACCOUNTADMIN;


### More examples - 3 - ###

create or replace masking policy dates as (val date) returns date ->
case
  when current_role() in ('ANALYST_FULL') then val
  else date_from_parts(0001, 01, 01)::date -- returns 0001-01-01 00:00:00.000
end;


-- Apply policy on a specific column 
ALTER TABLE IF EXISTS CUSTOMERS MODIFY COLUMN create_date 
SET MASKING POLICY dates;


-- Validating policies

USE ROLE ANALYST_FULL;
SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;
SELECT * FROM CUSTOMERS;