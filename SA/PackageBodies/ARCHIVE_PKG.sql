CREATE OR REPLACE PACKAGE BODY sa.ARCHIVE_PKG
IS
/*************************************************************************************************************************************
  * $Revision: 1.18 $
  * $Author: spagidala $
  * $Date: 2018/05/17 18:23:23 $
  * $Log: archive_pkg.sql,v $
  * Revision 1.18  2018/05/17 18:23:23  spagidala
  * CR57903 - New generic archive procedure has been added
  *
  * Revision 1.16  2018/04/16 19:41:10  sinturi
  * New Purge proc added
  *
  * Revision 1.15  2018/03/19 22:18:30  tpathare
  * New procedure archive_sui_inquiry_mismatches
  *
  * Revision 1.13  2018/03/07 14:50:24  skota
  * Merged the code
  *
  * Revision 1.12  2018/02/13 23:09:20  mshah
  * CR55240 - Enhance DP Logs data.
  *
  * Revision 1.11  2018/02/12 16:03:42  mshah
  * CR55240 - Enhance DP Logs data.
  *
  * Revision 1.7  2017/08/15 20:19:14  tpathare
  * New procedure archive_device_recovery_code
  *
  * Revision 1.4  2017/04/06 21:57:45  aganesan
  * CR47564 - archive_queue_event_log procedure signature modified
  *
  * Revision 1.3  2017/03/02 19:55:38  aganesan
  * CR47564 - archive procedure for queue log table
  *
  * Revision 1.1  2016/11/17 18:15:52  abustos
  * CR46502 - New archiving procedure for rtc_process_log. Moved already existing procedures to pkg
  *
  *************************************************************************************************************************************/

  PROCEDURE  archive_rtc_process_log  ( i_archive_from_days     IN  NUMBER DEFAULT 30   ,
                                        o_response              OUT VARCHAR2            ,
                                        i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                        i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                        i_bulk_collection_limit IN  NUMBER DEFAULT 200  )
  AS
    -- temporary record to hold required attributes
    TYPE rtc_record IS RECORD ( rowid   VARCHAR2(100) ,
                                objid   VARCHAR2(100) );

    -- based on record above
    TYPE rtcList IS TABLE OF rtc_record;

    -- table to hold array of data
    rtc rtcList;

    -- get rtc records (limit the rows to be retrieved)
    CURSOR c_rtc IS
      SELECT *
      FROM   ( SELECT rowid, rowid objid
               FROM   rtc_process_log
               WHERE  process_date < TRUNC(SYSDATE - i_archive_from_days)
             )
      WHERE  ROWNUM <= i_max_rows_limit;

    --
    n_count_rows  NUMBER := 0;
    --

  -- used to determine if an rtc record exists that needs to be archived
  FUNCTION exists_rtc RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   rtc_process_log
                    WHERE  process_date < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
   EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_rtc;

  BEGIN
    -- perform a loop while applicable rtc record exists
    WHILE ( exists_rtc )
    LOOP

      -- open cursor for rtc records
      OPEN c_rtc;

      -- start loop
      LOOP

        -- fetch cursor data into rtc collection (limit collection to i_bulk_collection_limit rows at a time)
        FETCH c_rtc BULK COLLECT INTO rtc LIMIT i_bulk_collection_limit;

        -- loop through rtc collection
        FOR i IN 1 .. rtc.COUNT LOOP

          DELETE sa.rtc_process_log
          WHERE  rowid = rtc(i).rowid;

          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
            -- Save changes
            COMMIT;
          END IF;
          --
        END LOOP; -- c_rtc
        --
        EXIT WHEN c_rtc%NOTFOUND;
        --
      END LOOP;

      CLOSE c_rtc;

      -- exit when there are no more records to archive
      EXIT WHEN NOT ( exists_rtc );

    END LOOP; -- WHILE (exists_rtc)

    -- Save changes
    COMMIT;

    -- Save changes
    COMMIT;

    -- Return successful execution
    o_response := 'SUCCESS';
    --
   EXCEPTION
     WHEN OTHERS THEN
       --
       o_response := 'ERROR IN ARCHIVE_RTC_PROCESS_LOG: ' || SQLERRM;
       RAISE;

  END archive_rtc_process_log;

  PROCEDURE  archive_spr_reprocess_log ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                         i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                         i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                         i_bulk_collection_limit IN  NUMBER DEFAULT 200  ,
                                         o_response              OUT VARCHAR2            )
  AS
    -- temporary record to hold required attributes
    TYPE spr_reprocess_record IS RECORD ( rowid   VARCHAR2(100) ,
                                          objid   NUMBER        );

    -- based on record above
    TYPE spr_reprocess_list IS TABLE OF spr_reprocess_record;

    -- table to hold array of data
    spr_rec spr_reprocess_list;

    -- get spr reprocess transactions (limit the rows to be retrieved)
    CURSOR c_reprocess_list IS
      SELECT *
      FROM   ( SELECT rowid, objid
               FROM   sa.x_spr_reprocess_log
               WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
             )
      WHERE  ROWNUM <= i_max_rows_limit;

    --
    n_count_rows  NUMBER := 0;
    --

  -- used to determine if a transaction exists that needs to be delete
  FUNCTION exists_archive_process RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   sa.x_spr_reprocess_log
                    WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
   EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_archive_process;

  BEGIN
    -- perform a loop while applicable if record exists
    WHILE ( exists_archive_process )
    LOOP

      -- open cursor for spr_log transaction records
      OPEN c_reprocess_list;

      -- start loop
      LOOP

        -- fetch cursor data into  collection (limit collection to i_bulk_collection_limit rows at a time)
        FETCH c_reprocess_list BULK COLLECT INTO spr_rec LIMIT i_bulk_collection_limit;

        -- loop through collection
        FOR i IN 1 .. spr_rec.COUNT LOOP

         DELETE  sa.x_spr_reprocess_log
          WHERE  ROWID = spr_rec(i).rowid;

          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
            -- Save changes
            COMMIT;
          END IF;
          --
        END LOOP; --
        --
        EXIT WHEN c_reprocess_list%NOTFOUND;
        --
      END LOOP;

      CLOSE c_reprocess_list;

      -- exit when there are no more records to archive
      EXIT WHEN NOT ( exists_archive_process );

    END LOOP; -- WHILE (exists)

    -- Save changes
    COMMIT;

    n_count_rows := 0;

    COMMIT;

    -- Return successful execution
    o_response := 'SUCCESS';
    --
   EXCEPTION
     WHEN OTHERS THEN
       --
       o_response := 'ERROR IN ARCHIVE_SPR_REPROCESS_LOG: ' || SQLERRM;
       RAISE;

  END archive_spr_reprocess_log;

  PROCEDURE archive_pcrf_transaction ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                       o_response              OUT VARCHAR2            ,
                                       i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                       i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                       i_bulk_collection_limit IN  NUMBER DEFAULT 200  )
  AS
    -- temporary record to hold required attributes
    TYPE pcrf_record IS RECORD ( rowid   VARCHAR2(100) ,
                                 objid   NUMBER        );

    -- based on record above
    TYPE pcrfList IS TABLE OF pcrf_record;

    -- table to hold array of data
    pcrf pcrfList;

    -- get pcrf transactions (limit the rows to be retrieved)
    CURSOR c_pcrf IS
      SELECT *
      FROM   ( SELECT rowid, objid
               FROM   x_pcrf_transaction
               WHERE  pcrf_status_code IN ('L','F','S','W','C','SS','FF')
               AND    insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
             )
      WHERE  ROWNUM <= i_max_rows_limit;

    -- get pcrf transactions with low priority (limit the rows to be retrieved)
    CURSOR c_pcrf_low_prty IS
      SELECT *
      FROM   ( SELECT rowid, objid
               FROM   x_pcrf_trans_low_prty
               WHERE  pcrf_status_code IN ('L','F','S','W','C','SS','FF')
               AND    insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
             )
      WHERE  ROWNUM <= i_max_rows_limit;

    --
    n_count_rows  NUMBER := 0;
    --

  -- used to determine if a pcrf transaction exists that needs to be archived
  FUNCTION exists_pcrf RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   x_pcrf_transaction
                    WHERE  pcrf_status_code IN ('L','F','S','W','C','SS','FF')
                    AND    insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
  EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_pcrf;

  -- used to determine if a pcrf transaction low priority exists that needs to be archived
  FUNCTION exists_pcrf_low_prty RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   x_pcrf_trans_low_prty
                    WHERE  pcrf_status_code IN ('L','F','S','W','C','SS','FF')
                    AND    insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
  EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_pcrf_low_prty;

  BEGIN
    -- perform a loop while applicable pcrf record exists
    WHILE ( exists_pcrf )
    LOOP

      -- open cursor for pcrf transaction records
      OPEN c_pcrf;

      -- start loop
      LOOP

        -- fetch cursor data into pcrf collection (limit collection to i_bulk_collection_limit rows at a time)
        FETCH c_pcrf BULK COLLECT INTO pcrf LIMIT i_bulk_collection_limit;

        -- loop through pcrf collection
        FOR i IN 1 .. pcrf.COUNT LOOP

          -- Archive history table
          INSERT
          INTO   sa.x_pcrf_transaction_detail_hist
                 ( objid,
                   pcrf_transaction_id,
                   offer_id,
                   ttl,
                   future_ttl,
                   redemption_date,
                   offer_name,
                   data_usage,
                   hi_speed_data_usage,
                   insert_timestamp,
                   update_timestamp
                 )
          SELECT objid,
                 pcrf_transaction_id,
                 offer_id,
                 ttl,
                 future_ttl,
                 redemption_date,
                 offer_name,
                 data_usage,
                hi_speed_data_usage,
                 insert_timestamp,
                 update_timestamp
          FROM   sa.x_pcrf_transaction_detail
          WHERE  pcrf_transaction_id = pcrf(i).objid;

          DELETE sa.x_pcrf_transaction_detail
          WHERE  pcrf_transaction_id = pcrf(i).objid;

          -- Archive original table
          INSERT
          INTO   x_pcrf_transaction_history
                 ( objid,
                   min,
                   esn,
                   subscriber_id,
                   group_id,
                   order_type,
                   phone_manufacturer,
                   action_type,
                   sim,
                   zipcode,
                   service_plan_id,
                   case_id,
                   pcrf_status_code,
                   status_message,
                   web_objid,
                   brand,
                   sourcesystem,
                   template,
                   rate_plan,
                   blackout_wait_date,
                   retry_count,
                   data_usage,
                   hi_speed_data_usage,
                   conversion_factor,
                   dealer_id,
                   denomination,
                   pcrf_parent_name,
                   propagate_flag,
                   service_plan_type,
                   part_inst_status,
                   phone_model,
                   content_delivery_format,
                   language,
                   wf_mac_id,
                   insert_timestamp,
                   update_timestamp,
                   mdn,
                   pcrf_cos,
                   ttl,
                   future_ttl,
                   redemption_date,
                   contact_objid
                 )
          SELECT objid,
                 min,
                 esn,
                 subscriber_id,
                 group_id,
                 order_type,
                 phone_manufacturer,
                 action_type,
                 sim,
                 zipcode,
                 service_plan_id,
                 case_id,
                 pcrf_status_code,
                 status_message,
                 web_objid,
                 brand,
                 sourcesystem,
                 template,
                 rate_plan,
                 blackout_wait_date,
                 retry_count,
                 data_usage,
                 hi_speed_data_usage,
                 conversion_factor,
                 dealer_id,
                 denomination,
                 pcrf_parent_name,
                 propagate_flag,
                 service_plan_type,
                 part_inst_status,
                 phone_model,
                 content_delivery_format,
                 language,
                 wf_mac_id,
                 insert_timestamp,
                 update_timestamp,
                 mdn,
                 pcrf_cos,
                 ttl,
                 future_ttl,
                 redemption_date,
                 contact_objid
          FROM   x_pcrf_transaction
          WHERE  ROWID = pcrf(i).rowid;

          -- Delete original table by rowid
          DELETE
          FROM   x_pcrf_transaction
          WHERE  ROWID = pcrf(i).rowid;

          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
            -- Save changes
            COMMIT;
          END IF;
          --
        END LOOP; -- c_pcrf
        --
        EXIT WHEN c_pcrf%NOTFOUND;
        --
      END LOOP;

      CLOSE c_pcrf;

      -- exit when there are no more records to archive
      EXIT WHEN NOT ( exists_pcrf );

    END LOOP; -- WHILE (exists_pcrf)

    -- Save changes
    COMMIT;
    --
    --DBMS_OUTPUT.PUT_LINE(n_count_rows || ' rows archived from pcrf transaction');
    --
    n_count_rows := 0;

    -- perform a loop while applicable pcrf record exists
    WHILE ( exists_pcrf_low_prty )
    LOOP

      -- open cursor for pcrf transaction low prty records
      OPEN c_pcrf_low_prty;

      -- start loop
      LOOP

        -- fetch cursor data into pcrf collection (limit collection to i_bulk_collection_limit rows at a time)
        FETCH c_pcrf_low_prty BULK COLLECT INTO pcrf LIMIT i_bulk_collection_limit;

        -- loop through pcrf collection
        FOR i IN 1 .. pcrf.COUNT LOOP

          -- Archive history table
          INSERT
          INTO   sa.x_pcrf_transaction_detail_hist
                 ( objid,
                   pcrf_transaction_id,
                   offer_id,
                   ttl,
                   future_ttl,
                   redemption_date,
                   offer_name,
                   data_usage,
                   hi_speed_data_usage,
                   insert_timestamp,
                   update_timestamp
                 )
          SELECT objid,
                 pcrf_trans_low_prty_id,
                 offer_id,
                 ttl,
                 future_ttl,
                 redemption_date,
                 offer_name,
                 data_usage,
                 hi_speed_data_usage,
                 insert_timestamp,
                 update_timestamp
          FROM   sa.x_pcrf_trans_detail_low_prty
          WHERE  pcrf_trans_low_prty_id = pcrf(i).objid;

          DELETE sa.x_pcrf_trans_detail_low_prty
          WHERE  pcrf_trans_low_prty_id = pcrf(i).objid;

          -- Archive original table
          INSERT
          INTO   x_pcrf_transaction_history
                 ( objid,
                   min,
                   esn,
                   subscriber_id,
                   group_id,
                   order_type,
                   phone_manufacturer,
                   action_type,
                   sim,
                   zipcode,
                   service_plan_id,
                   case_id,
                   pcrf_status_code,
                   status_message,
                   web_objid,
                   brand,
                   sourcesystem,
                   template,
                   rate_plan,
                   blackout_wait_date,
                  retry_count,
                   data_usage,
                   hi_speed_data_usage,
                   conversion_factor,
                   dealer_id,
                   denomination,
                   pcrf_parent_name,
                   propagate_flag,
                   service_plan_type,
                   part_inst_status,
                   phone_model,
                   content_delivery_format,
                   language,
                   wf_mac_id,
                   insert_timestamp,
                   update_timestamp,
                   mdn,
                   pcrf_cos,
                   ttl,
                   future_ttl,
                   redemption_date,
                   contact_objid
                 )
          SELECT objid,
                 min,
                 esn,
                 subscriber_id,
                 group_id,
                 order_type,
                 phone_manufacturer,
                 action_type,
                 sim,
                 zipcode,
                 service_plan_id,
                 case_id,
                 pcrf_status_code,
                 status_message,
                 web_objid,
                 brand,
                 sourcesystem,
                 template,
                 rate_plan,
                 blackout_wait_date,
                 retry_count,
                 data_usage,
                 hi_speed_data_usage,
                 conversion_factor,
                 dealer_id,
                 denomination,
                 pcrf_parent_name,
                 propagate_flag,
                 service_plan_type,
                 part_inst_status,
                 phone_model,
                 content_delivery_format,
                 language,
                 wf_mac_id,
                 insert_timestamp,
                 update_timestamp,
                 mdn,
                 pcrf_cos,
                 ttl,
                 future_ttl,
                 redemption_date,
                 contact_objid
          FROM   x_pcrf_trans_low_prty
          WHERE  ROWID = pcrf(i).ROWID;

          -- Delete original table by rowid
          DELETE
          FROM   x_pcrf_trans_low_prty
          WHERE  ROWID = pcrf(i).ROWID;

          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
            -- Save changes
            COMMIT;
          END IF;
          --
          --

        END LOOP; -- c_pcrf_low_prty
        -- exit loop when no more data
        EXIT WHEN c_pcrf_low_prty%NOTFOUND;
        --
      END LOOP;
      -- close low priority cursor
      CLOSE c_pcrf_low_prty;

     -- exit when there are no more records to archive
      EXIT WHEN NOT ( exists_pcrf_low_prty );

    END LOOP; -- WHILE (exists_pcrf_low_prty)
    --
    --DBMS_OUTPUT.PUT_LINE(n_count_rows || ' rows archived from pcrf transaction low priority');

    -- Save changes
    COMMIT;

    -- Return successful execution
    o_response := 'SUCCESS';
    --
  EXCEPTION
     WHEN OTHERS THEN
       --
       o_response := 'ERROR IN ARCHIVE_PCRF_TRANSACTION: ' || SQLERRM;
       RAISE;

  END archive_pcrf_transaction;

PROCEDURE archive_queue_event_log(i_archive_from_days     IN  NUMBER DEFAULT 60  ,
                                  i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                  i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                  i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                  o_response              OUT VARCHAR2
                                  )
AS

  -- temporary record to hold required attributes
  TYPE queue_event_record IS RECORD (rowid   VARCHAR2(100) ,
                                     objid   VARCHAR2(100)
				    );

  -- based on record above
  TYPE eventList IS TABLE OF queue_event_record;

  -- table to hold array of data
  xeg eventList;

  -- get xeg records (limit the rows to be retrieved)
  CURSOR c_xeg
  IS
  SELECT *
  FROM   (SELECT rowid, rowid objid
          FROM   x_queue_event_log
          WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
         )
  WHERE  ROWNUM <= i_max_rows_limit;
  --
  n_count_rows  NUMBER := 0;
  -- used to determine if an xeg record exists that needs to be archived
  FUNCTION exists_xeg RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   sa.x_queue_event_log
                    WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
   EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_xeg;

BEGIN
  -- perform a loop while applicable xeg record exists
  WHILE ( exists_xeg )
  LOOP
    -- open cursor for xeg records
    OPEN c_xeg;
    -- start loop
    LOOP
      -- fetch cursor data into xeg collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_xeg BULK COLLECT INTO xeg LIMIT i_bulk_collection_limit;
      -- loop through xeg collection
      FOR i IN 1 .. xeg.COUNT LOOP
        DELETE sa.x_queue_event_log
        WHERE  rowid = xeg(i).rowid;
        -- increase row count
        n_count_rows := n_count_rows + 1;
        IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
          -- Save changes
          COMMIT;
        END IF;
        --
      END LOOP; -- c_xeg
      --
      EXIT WHEN c_xeg%NOTFOUND;
      --
    END LOOP;

    CLOSE c_xeg;

    -- exit when there are no more records to archive
    EXIT WHEN NOT ( exists_xeg );
  END LOOP; -- WHILE (exists_xeg)

  -- Save changes
  COMMIT;

  -- Return successful execution
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN ARCHIVE_QUEUE_EVENT_LOG: ' || SQLERRM;
     RAISE;
END archive_queue_event_log;

--CR48846 Procedure added to cleanup table x_device_recovery_code
PROCEDURE archive_device_recovery_code(i_archive_from_days     IN  NUMBER DEFAULT 60  ,
                                       i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                       i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                       i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                       o_response              OUT VARCHAR2
                                       )
AS

  -- temporary record to hold required attributes
  TYPE device_recovery_record IS RECORD (rowid   VARCHAR2(100) ,
                                         objid   VARCHAR2(100)
                                        );

  -- based on record above
  TYPE codeList IS TABLE OF device_recovery_record;

  -- table to hold array of data
  xeg codeList;

  -- get xeg records (limit the rows to be retrieved)
  CURSOR c_xeg
  IS
  SELECT *
  FROM   (SELECT rowid, objid
          FROM   x_device_recovery_code
          WHERE  creation_time < TRUNC(SYSDATE - i_archive_from_days)
         )
  WHERE  ROWNUM <= i_max_rows_limit;
  --
  n_count_rows  NUMBER := 0;
  -- used to determine if an xeg record exists that needs to be archived
  FUNCTION exists_xeg RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   x_device_recovery_code
                    WHERE  creation_time < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
   EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_xeg;

BEGIN
  -- perform a loop while applicable xeg record exists
  WHILE ( exists_xeg )
  LOOP
    -- open cursor for xeg records
    OPEN c_xeg;
    -- start loop
    LOOP
      -- fetch cursor data into xeg collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_xeg BULK COLLECT INTO xeg LIMIT i_bulk_collection_limit;
      -- loop through xeg collection
      FOR i IN 1 .. xeg.COUNT LOOP
        DELETE x_device_recovery_code
        WHERE  rowid = xeg(i).rowid;
        -- increase row count
        n_count_rows := n_count_rows + 1;
        IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
          -- Save changes
          COMMIT;
        END IF;
        --
      END LOOP; -- c_xeg
      --
      EXIT WHEN c_xeg%NOTFOUND;
      --
    END LOOP;

    CLOSE c_xeg;

    -- exit when there are no more records to archive
    EXIT WHEN NOT ( exists_xeg );
  END LOOP; -- WHILE (exists_xeg)

  -- Save changes
  COMMIT;

  -- Return successful execution
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN ARCHIVE_DEVICE_RECOVERY_CODE: ' || SQLERRM;
     RAISE;
END archive_device_recovery_code;

  --CR52654 Procedure added to purge table table_customer_comm_stg
PROCEDURE archive_customer_comm_stg(i_archive_from_days     IN  NUMBER DEFAULT 7  ,
                                       i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                       i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                       i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                       o_response              OUT VARCHAR2
                                       )
AS

  -- temporary record to hold required attributes
  TYPE customer_comm_record IS RECORD (rowid   VARCHAR2(100) ,
                                         objid   VARCHAR2(100)
                                        );

  -- based on record above
  TYPE codeList IS TABLE OF customer_comm_record;

  -- table to hold array of data
  xeg codeList;

  -- get xeg records (limit the rows to be retrieved)
  CURSOR c_xeg
  IS
  SELECT *
  FROM   (SELECT rowid, objid
          FROM   table_customer_comm_stg
          WHERE  TRUNC(insert_timestamp) < TRUNC(SYSDATE - i_archive_from_days)
         )
  WHERE  ROWNUM <= i_max_rows_limit;
  --
  n_count_rows  NUMBER := 0;
  -- used to determine if an xeg record exists that needs to be archived
  FUNCTION exists_xeg RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   table_customer_comm_stg
                    WHERE  TRUNC(insert_timestamp) < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
   EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_xeg;

BEGIN
  -- perform a loop while applicable xeg record exists
  WHILE ( exists_xeg )
  LOOP
    -- open cursor for xeg records
    OPEN c_xeg;
    -- start loop
    LOOP
      -- fetch cursor data into xeg collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_xeg BULK COLLECT INTO xeg LIMIT i_bulk_collection_limit;
      -- loop through xeg collection
      FOR i IN 1 .. xeg.COUNT LOOP
        DELETE table_customer_comm_stg
        WHERE  rowid = xeg(i).rowid;
        -- increase row count
        n_count_rows := n_count_rows + 1;
        IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
          -- Save changes
          COMMIT;
        END IF;
        --
      END LOOP; -- c_xeg
      --
      EXIT WHEN c_xeg%NOTFOUND;
      --
    END LOOP;

    CLOSE c_xeg;

    -- exit when there are no more records to archive
    EXIT WHEN NOT ( exists_xeg );
  END LOOP; -- WHILE (exists_xeg)

  -- Save changes
  COMMIT;

  -- Return successful execution
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN ARCHIVE_CUSTOMER_COMM_STG: ' || SQLERRM;
     RAISE;
END archive_customer_comm_stg;


---CR54420 -  Enhance DP Logs data
PROCEDURE archive_x_payment_log (
                                 i_archive_from_days     IN  NUMBER DEFAULT 30  ,
                                 i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                 i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                 i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                 o_response              OUT VARCHAR2
                                )
AS

  -- temporary record to hold required attributes
  TYPE x_payment_log IS RECORD (
                                rowid   VARCHAR2(100) ,
                                MERCHANT_REF_NUMBER   VARCHAR2(100)
                               );

  -- based on record above
  TYPE codeList IS TABLE OF x_payment_log;

  -- table to hold array of data
  xeg codeList;

  -- get xeg records (limit the rows to be retrieved)
  CURSOR c_xeg
  IS
  SELECT *
  FROM   (
          SELECT rowid, MERCHANT_REF_NUMBER
          FROM   sa.X_PAYMENT_LOG
          WHERE  INSERT_DATE < TRUNC(SYSDATE - NVL((SELECT TO_NUMBER(X_PARAM_VALUE)
                                                    FROM   sa.TABLE_X_PARAMETERS PARA
                                                    WHERE  PARA.X_PARAM_NAME = 'DP_LOG_XML_PARSE_DAYS'), i_archive_from_days))
         )
  WHERE  ROWNUM <= i_max_rows_limit;
  --
  n_count_rows  NUMBER := 0;
  -- used to determine if an xeg record exists that needs to be archived
  FUNCTION exists_xeg RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   sa.X_PAYMENT_LOG
                    WHERE  INSERT_DATE <   TRUNC(SYSDATE - NVL((SELECT TO_NUMBER(X_PARAM_VALUE)
                                                 FROM   sa.TABLE_X_PARAMETERS PARA
                                                 WHERE  PARA.X_PARAM_NAME = 'DP_LOG_XML_PARSE_DAYS'), i_archive_from_days))
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
   EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_xeg;

BEGIN
  -- perform a loop while applicable xeg record exists
  WHILE ( exists_xeg )
  LOOP
    -- open cursor for xeg records
    OPEN c_xeg;
    -- start loop
    LOOP
      -- fetch cursor data into xeg collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_xeg BULK COLLECT INTO xeg LIMIT i_bulk_collection_limit;
      -- loop through xeg collection
      FOR i IN 1 .. xeg.COUNT LOOP
        DELETE sa.X_PAYMENT_LOG
        WHERE  rowid = xeg(i).rowid;
        -- increase row count
        n_count_rows := n_count_rows + 1;
        IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
          -- Save changes
          COMMIT;
        END IF;
        --
      END LOOP; -- c_xeg
      --
      EXIT WHEN c_xeg%NOTFOUND;
      --
    END LOOP;

    CLOSE c_xeg;

    -- exit when there are no more records to archive
    EXIT WHEN NOT ( exists_xeg );
  END LOOP; -- WHILE (exists_xeg)

  -- Save changes
  COMMIT;

  -- Return successful execution
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN archive_x_payment_log: ' || SQLERRM;
     RAISE;
END archive_x_payment_log;
-------------------------------------------------

PROCEDURE archive_pageplus_event_stg ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                        o_response              OUT VARCHAR2            ,
                                        i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                        i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                        i_bulk_collection_limit IN  NUMBER DEFAULT 200  )
 AS
  -- temporary record to hold required attributes
  TYPE stg_record IS RECORD ( rowid   VARCHAR2(100) ,
                              objid   NUMBER        );

  -- based on record above
  TYPE stgList IS TABLE OF stg_record;

  -- table to hold array of data
  stg stgList;

  -- get spr pageplus stg transactions (limit the rows to be retrieved)
  CURSOR c_stg IS
    SELECT *
    FROM   ( SELECT rowid, objid
             FROM   sa.x_pageplus_spr_staging
             WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
           )
    WHERE  ROWNUM <= i_max_rows_limit;

  --
  n_count_rows  NUMBER := 0;
  --

  -- used to determine if a pagplus stg  exists that needs to be archived
  FUNCTION exists_stg RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   x_pageplus_spr_staging
                    WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
  EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_stg;


  BEGIN
    -- perform a loop while applicable stg record exists
    WHILE ( exists_stg )
    LOOP

      -- open cursor for spr pageplus stg records
      OPEN c_stg;

      -- start loop
      LOOP

        FETCH c_stg BULK COLLECT INTO stg LIMIT i_bulk_collection_limit;

        -- loop through collection
        FOR i IN 1 .. stg.COUNT LOOP

          -- Archive original table
          INSERT
          INTO   x_pageplus_spr_staging_hist
                 (  objid                   ,
                    pcrf_min                ,
                    pcrf_mdn                ,
                    pcrf_esn                ,
                    pcrf_spr_id             ,
                    pcrf_group_id           ,
                    pcrf_parent_name        ,
                    pcrf_cos                ,
                    pcrf_base_ttl           ,
                    future_ttl              ,
                    brand                   ,
                    phone_manufacturer      ,
                    phone_model             ,
                    content_delivery_format ,
                    denomination            ,
                    conversion_factor       ,
                    dealer_id               ,
                    rate_plan               ,
                    propagate_flag          ,
                    pcrf_transaction_id     ,
                    service_plan_type       ,
                    service_plan_id         ,
                    queued_days             ,
                    LANGUAGE                ,
                    part_inst_status        ,
                    bus_org_objid           ,
                    contact_objid           ,
                    web_user_objid          ,
                    wf_mac_id               ,
                    spr_status_code         ,
                    curr_throttle_policy_id ,
                    curr_throttle_eff_date  ,
                    zipcode                 ,
                    insert_timestamp        ,
                    update_timestamp        ,
                    meter_source_voice      ,
                    meter_source_sms        ,
                    meter_source_data       ,
                    meter_source_ild        ,
                    pcrf_subscriber_id      ,
                    subscriber_status_code  ,
                    imsi                    ,
                    action                  ,
                    spr_status              ,
                    pcrf_status             ,
                    event_timestamp         ,
                    renewal_processed       ,
                    addon_flag              )
          SELECT    objid                   ,
                    pcrf_min                ,
                    pcrf_mdn                ,
                    pcrf_esn                ,
                    pcrf_spr_id             ,
                    pcrf_group_id           ,
                    pcrf_parent_name        ,
                    pcrf_cos                ,
                    pcrf_base_ttl           ,
                    future_ttl              ,
                    brand                   ,
                    phone_manufacturer      ,
                    phone_model             ,
                    content_delivery_format ,
                    denomination            ,
                    conversion_factor       ,
                    dealer_id               ,
                    rate_plan               ,
                    propagate_flag          ,
                    pcrf_transaction_id     ,
                    service_plan_type       ,
                    service_plan_id         ,
                    queued_days             ,
                    LANGUAGE                ,
                    part_inst_status        ,
                    bus_org_objid           ,
                    contact_objid           ,
                    web_user_objid          ,
                    wf_mac_id               ,
                    spr_status_code         ,
                    curr_throttle_policy_id ,
                    curr_throttle_eff_date  ,
                    zipcode                 ,
                    insert_timestamp        ,
                    update_timestamp        ,
                    meter_source_voice      ,
                    meter_source_sms        ,
                    meter_source_data       ,
                    meter_source_ild        ,
                    pcrf_subscriber_id      ,
                    subscriber_status_code  ,
                    imsi                    ,
                    action                  ,
                    spr_status              ,
                    pcrf_status             ,
                    event_timestamp         ,
                    renewal_processed       ,
                    addon_flag
          FROM      sa.x_pageplus_spr_staging
          WHERE     ROWID = stg(I).ROWID;

          -- Delete original table by rowid
          DELETE
          FROM   X_PAGEPLUS_SPR_STAGING
          WHERE  ROWID = stg(i).rowid;

          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
            -- Save changes
            COMMIT;
          END IF;
          --
      END LOOP; --
        --
      EXIT WHEN c_stg%NOTFOUND;
        --
    END LOOP;

     CLOSE c_stg;
      -- exit when there are no more records to archive
      EXIT WHEN NOT ( exists_stg );

    END LOOP;

    -- Save changes
    COMMIT;
    --
    -- Return successful execution
    o_response := 'SUCCESS';
    --
  EXCEPTION
     WHEN OTHERS THEN
       --
       o_response := 'ERROR IN ARCHIVE_SPR_PAGEPLUS_STG_EVENT: ' || SQLERRM;
       RAISE;

END archive_pageplus_event_stg;

--CR55008 Procedure added to cleanup table ig_sui_inquiry_mismatches
PROCEDURE archive_sui_inquiry_mismatches( i_archive_from_days     IN  NUMBER DEFAULT 30  ,
                                          i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                          i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                          i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                          o_response              OUT VARCHAR2
                                          )
AS

  -- temporary record to hold required attributes
  TYPE sui_ui_mismatch_record IS RECORD ( rowid          VARCHAR2(100) ,
                                          transaction_id NUMBER         );

  -- based on record above
  TYPE codeList IS TABLE OF sui_ui_mismatch_record;

  -- table to hold array of data
  xeg codeList;

  -- get xeg records (limit the rows to be retrieved)
  CURSOR c_xeg
  IS
  SELECT *
  FROM   (SELECT rowid, transaction_id
          FROM   ig_sui_inquiry_mismatch
          WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
         )
  WHERE  ROWNUM <= i_max_rows_limit;
  --
  n_count_rows  NUMBER := 0;
  -- used to determine if an xeg record exists that needs to be archived
  FUNCTION exists_xeg RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   ig_sui_inquiry_mismatch
                    WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
   EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_xeg;

BEGIN
  -- perform a loop while applicable xeg record exists
  WHILE ( exists_xeg )
  LOOP
    -- open cursor for xeg records
    OPEN c_xeg;
    -- start loop
    LOOP
      -- fetch cursor data into xeg collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_xeg BULK COLLECT INTO xeg LIMIT i_bulk_collection_limit;
      -- loop through xeg collection
      FOR i IN 1 .. xeg.COUNT LOOP

        DELETE ig_sui_inquiry_mismatch_dtl
        WHERE  transaction_id = xeg(i).transaction_id;

        DELETE ig_sui_inquiry_mismatch
        WHERE  rowid = xeg(i).rowid;

        -- increase row count
        n_count_rows := n_count_rows + 1;

        IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
          -- Save changes
          COMMIT;
        END IF;
        --
      END LOOP; -- c_xeg
      --
      EXIT WHEN c_xeg%NOTFOUND;
      --
    END LOOP;

    CLOSE c_xeg;

    -- exit when there are no more records to archive
    EXIT WHEN NOT ( exists_xeg );
  END LOOP; -- WHILE (exists_xeg)

  -- Save changes
  COMMIT;

  -- Return successful execution
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN ARCHIVE_SUI_INQUIRY_MISMATCHES: ' || SQLERRM;
     RAISE;
END archive_sui_inquiry_mismatches;

--CR57166,Archive table x_imei_mismatch
PROCEDURE archive_imei_mismatch ( i_archive_from_days     IN  NUMBER DEFAULT 60    ,
                                  o_response              OUT VARCHAR2            ,
                                  i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                  i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                  i_bulk_collection_limit IN  NUMBER DEFAULT 200
                                  )

 AS
  -- temporary record to hold required attributes
  TYPE stg_record IS RECORD ( rowid   VARCHAR2(100) ,
                              objid   NUMBER        );

  -- based on record above
  TYPE stgList IS TABLE OF stg_record;

  -- table to hold array of data
  stg stgList;

  -- get spr imei_mismatch transactions (limit the rows to be retrieved)
  CURSOR c_stg IS
    SELECT *
    FROM   ( SELECT rowid, objid
             FROM   sa.x_imei_mismatch
             WHERE  created_date < TRUNC(SYSDATE - i_archive_from_days)
           )
    WHERE  ROWNUM <= i_max_rows_limit;

  --
  n_count_rows  NUMBER := 0;
  --

  -- used to determine if a imei_mismatch record exists that needs to be archived
  FUNCTION exists_stg RETURN BOOLEAN IS
    n_count NUMBER := 0;
  BEGIN

    SELECT COUNT(1)
    INTO   n_count
    FROM   dual
    WHERE  EXISTS ( SELECT 1
                    FROM   x_imei_mismatch
                    WHERE  created_date < TRUNC(SYSDATE - i_archive_from_days)
                  );
    --
    RETURN ( CASE
               WHEN n_count > 0 THEN TRUE
               ELSE FALSE
             END );
    --
  EXCEPTION
     WHEN others THEN
       RETURN FALSE;
  END exists_stg;

  BEGIN
    -- perform a loop while applicable stg record exists
    WHILE ( exists_stg )
    LOOP

      -- open cursor for imei_mismatch records
      OPEN c_stg;

      -- start loop
      LOOP

        FETCH c_stg BULK COLLECT INTO stg LIMIT i_bulk_collection_limit;

        -- loop through collection
        FOR i IN 1 .. stg.COUNT LOOP

          -- Archive original table
          INSERT
            INTO  x_imei_mismatch_hist
               (  objid               ,
                  min                 ,
                  iccid               ,
                  old_esn             ,
                  old_esn_status      ,
                  new_esn             ,
                  new_esn_status      ,
                  old_esn_brand       ,
                  new_esn_brand       ,
                  old_esn_device_type ,
                  new_esn_device_type ,
                  old_esn_manufacturer,
                  new_esn_manufacturer,
                  old_esn_technology  ,
                  new_esn_technology  ,
                  old_esn_rate_plan   ,
                  old_esn_service_plan,
                  old_esn_cos         ,
                  old_esn_carrier     ,
                  new_esn_carrier     ,
                  zipcode             ,
                  status_result       ,
                  status_desc         ,
                  carrier_response    ,
                  created_date        ,
                  updated_date         )
          SELECT  objid               ,
                  min                 ,
                  iccid               ,
                  old_esn             ,
                  old_esn_status      ,
                  new_esn             ,
                  new_esn_status      ,
                  old_esn_brand       ,
                  new_esn_brand       ,
                  old_esn_device_type ,
                  new_esn_device_type ,
                  old_esn_manufacturer,
                  new_esn_manufacturer,
                  old_esn_technology  ,
                  new_esn_technology  ,
                  old_esn_rate_plan   ,
                  old_esn_service_plan,
                  old_esn_cos         ,
                  old_esn_carrier     ,
                  new_esn_carrier     ,
                  zipcode             ,
                  status_result       ,
                  status_desc         ,
                  carrier_response    ,
                  created_date        ,
                  updated_date
             FROM sa.x_imei_mismatch
            WHERE ROWID = stg(I).ROWID;

          -- Delete original table by rowid
          DELETE
          FROM   x_imei_mismatch
          WHERE  ROWID = stg(i).rowid;

          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
            -- Save changes
            COMMIT;
          END IF;
          --

      END LOOP; --
        --
      EXIT WHEN c_stg%NOTFOUND;
        --
    END LOOP;

     CLOSE c_stg;
      -- exit when there are no more records to archive
      EXIT WHEN NOT ( exists_stg );

    END LOOP;

    -- Save changes
    COMMIT;
    --
    -- Return successful execution
    o_response := 'SUCCESS';
    --

  EXCEPTION
     WHEN OTHERS THEN
       --
       o_response := 'ERROR IN archive_imei_mismatch: ' || SQLERRM;
       RAISE;

END archive_imei_mismatch;


-- This procedure will delete the archied data dinamically with passing table details.
PROCEDURE archive_purge_process ( i_table_name        IN    VARCHAR2,
                                  i_base_column_name  IN    VARCHAR2,
                                  i_archive_from_days IN    NUMBER,
                                  i_max_rows_limit    IN    NUMBER,
                                  o_response          OUT   VARCHAR2)
 AS
  TYPE event_record IS RECORD ( rowid VARCHAR2(100) ,
                                objid VARCHAR2(100) );
  TYPE eventList IS TABLE OF event_record;
  eventBulkData eventList;
  n_number_of_records NUMBER := 0;
  v_sql               VARCHAR2(4000);
BEGIN
  -- Table validation required
  LOOP
    v_sql := ' SELECT COUNT(1)
               FROM dual
               WHERE EXISTS ( SELECT 1
                              FROM   '||i_table_name||'
	  		                  WHERE  '||i_base_column_name||' < TRUNC(SYSDATE - :a ) )';

    EXECUTE IMMEDIATE v_sql INTO n_number_of_records USING i_archive_from_days;

    EXIT WHEN n_number_of_records = 0;

    v_sql := ' SELECT *
               FROM ( SELECT rowid, rowid objid
                      FROM   '||i_table_name||'
                      WHERE  '||i_base_column_name||' < TRUNC(SYSDATE - :x ) )
               WHERE ROWNUM <= :y';

      EXECUTE IMMEDIATE v_sql BULK COLLECT INTO eventBulkData USING i_archive_from_days, i_max_rows_limit;

      FORALL k IN eventBulkData.FIRST..eventBulkData.LAST
         EXECUTE IMMEDIATE 'DELETE FROM '||i_table_name||'  WHERE rowid = :j' USING eventBulkData(k).rowid;
      COMMIT;
  END LOOP;
  COMMIT;
  o_response := 'SUCCESS';
END archive_purge_process;

END ARCHIVE_PKG;
/