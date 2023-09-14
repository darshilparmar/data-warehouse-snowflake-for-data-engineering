show streams;
select * from customer_table_changes;

insert into customer values(223136,'Jessica','Arnold','tanner39@smith.com','595 Benjamin Forge Suite 124','Michaelstad','Connecticut'
                            ,'Cape Verde',current_timestamp());
update customer set FIRST_NAME='Jessica', update_timestamp = current_timestamp()::timestamp_ntz where customer_id=72;
delete from customer where customer_id =73 ;

select * from customer_history where customer_id in (72,73,223136);
select * from customer_table_changes;
select * from  customer where customer_id in (72,73,223136);


--View Creation--
create or replace view v_customer_change_data as
-- This subquery figures out what to do when data is inserted into the customer table
-- An insert to the customer table results in an INSERT to the customer_HISTORY table
select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,
 start_time, end_time, is_current, 'I' as dml_type
from (
select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,
             update_timestamp as start_time,
             lag(update_timestamp) over (partition by customer_id order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then TRUE else FALSE end as is_current
      from (select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,UPDATE_TIMESTAMP
            from SCD_DEMO.SCD2.customer_table_changes
            where metadata$action = 'INSERT'
            and metadata$isupdate = 'FALSE')
  )
union
-- This subquery figures out what to do when data is updated in the customer table
-- An update to the customer table results in an update AND an insert to the customer_HISTORY table
-- The subquery below generates two records, each with a different dml_type
select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY, start_time, end_time, is_current, dml_type
from (select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,
             update_timestamp as start_time,
             lag(update_timestamp) over (partition by customer_id order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then TRUE else FALSE end as is_current, 
             dml_type
      from (-- Identify data to insert into customer_history table
            select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY, update_timestamp, 'I' as dml_type
            from customer_table_changes
            where metadata$action = 'INSERT'
            and metadata$isupdate = 'TRUE'
            union
            -- Identify data in customer_HISTORY table that needs to be updated
            select CUSTOMER_ID, null, null, null, null, null,null,null, start_time, 'U' as dml_type
            from customer_history
            where customer_id in (select distinct customer_id 
                                  from customer_table_changes
                                  where metadata$action = 'DELETE'
                                  and metadata$isupdate = 'TRUE')
     and is_current = TRUE))
union
-- This subquery figures out what to do when data is deleted from the customer table
-- A deletion from the customer table results in an update to the customer_HISTORY table
select ctc.CUSTOMER_ID, null, null, null, null, null,null,null, ch.start_time, current_timestamp()::timestamp_ntz, null, 'D'
from customer_history ch
inner join customer_table_changes ctc
   on ch.customer_id = ctc.customer_id
where ctc.metadata$action = 'DELETE'
and   ctc.metadata$isupdate = 'FALSE'
and   ch.is_current = TRUE;

select * from v_customer_change_data;

create or replace task tsk_scd_hist warehouse= COMPUTE_WH schedule='1 minute'
ERROR_ON_NONDETERMINISTIC_MERGE=FALSE
as
merge into customer_history ch -- Target table to merge changes from NATION into
using v_customer_change_data ccd -- v_customer_change_data is a view that holds the logic that determines what to insert/update into the customer_history table.
   on ch.CUSTOMER_ID = ccd.CUSTOMER_ID -- CUSTOMER_ID and start_time determine whether there is a unique record in the customer_history table
   and ch.start_time = ccd.start_time
when matched and ccd.dml_type = 'U' then update -- Indicates the record has been updated and is no longer current and the end_time needs to be stamped
    set ch.end_time = ccd.end_time,
        ch.is_current = FALSE
when matched and ccd.dml_type = 'D' then update -- Deletes are essentially logical deletes. The record is stamped and no newer version is inserted
   set ch.end_time = ccd.end_time,
       ch.is_current = FALSE
when not matched and ccd.dml_type = 'I' then insert -- Inserting a new CUSTOMER_ID and updating an existing one both result in an insert
          (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY, start_time, end_time, is_current)
    values (ccd.CUSTOMER_ID, ccd.FIRST_NAME, ccd.LAST_NAME, ccd.EMAIL, ccd.STREET, ccd.CITY,ccd.STATE,ccd.COUNTRY, ccd.start_time, ccd.end_time, ccd.is_current);
    
show tasks;
alter task tsk_scd_hist suspend;--resume --suspend



insert into customer values(223136,'Jessica','Arnold','tanner39@smith.com','595 Benjamin Forge Suite 124','Michaelstad','Connecticut'
                            ,'Cape Verde',current_timestamp());
update customer set FIRST_NAME='Jessica' where customer_id=7523;
delete from customer where customer_id =136 and FIRST_NAME = 'Kim';
select count(*),customer_id from customer group by customer_id having count(*)=1;
select * from customer_history where customer_id =223136;
select * from customer_history where IS_CURRENT=TRUE;

--alter warehouse suspend;
select timestampdiff(second, current_timestamp, scheduled_time) as next_run, scheduled_time, current_timestamp, name, state 
from table(information_schema.task_history()) where state = 'SCHEDULED' order by completed_time desc;

select * from customer_history where IS_CURRENT=FALSE;
show tasks;