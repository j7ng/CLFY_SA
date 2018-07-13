CREATE OR REPLACE PROCEDURE sa."ARCHIVE_PCRF_TRANSACTION" ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                                          o_response              OUT VARCHAR2            ,
                                                          i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                                          i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                                          i_bulk_collection_limit IN  NUMBER DEFAULT 200  ) AS
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
/