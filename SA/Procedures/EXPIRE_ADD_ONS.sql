CREATE OR REPLACE PROCEDURE sa.expire_add_ons IS

  counter         NUMBER := 0;
  add_on_counter  NUMBER := 0;
  expired_counter NUMBER := 0;
BEGIN
  -- loop through temporary table
  FOR addons IN ( SELECT *
                  FROM   sa.temp_expire_add_on 
                  WHERE  status IS NULL
                  AND    processed_timestamp IS NULL
                  AND    add_ons_count > 0 )
  LOOP
    -- loop through add on cards to be expired
    FOR i IN ( SELECT ROWID,
                      status
               FROM   ( SELECT *               
                        FROM   sa.x_account_group_benefit 
                        WHERE  account_group_id = addons.account_group_id
                        ORDER BY start_date, 
                                 objid
                      )
               WHERE  ROWNUM <= addons.add_ons_count )
    LOOP
      IF i.status = 'EXPIRED' THEN
        UPDATE sa.temp_expire_add_on 
        SET    status = 'PROCESSED',
               processed_timestamp = SYSDATE
        WHERE  account_group_id = addons.account_group_id
        AND    status IS NULL
        AND    processed_timestamp IS NULL;
        expired_counter := expired_counter + SQL%ROWCOUNT;
        -- Skip the current iteration since it's already expired
        CONTINUE;
      END IF;
      --
      UPDATE sa.x_account_group_benefit 
      SET    status = 'EXPIRED',
             end_date = SYSDATE,
             reason = 'EXPIRED FROM Manual Script',
             update_timestamp = SYSDATE
      WHERE  rowid = i.rowid;
      add_on_counter := add_on_counter + SQL%ROWCOUNT;
      COMMIT;
    END LOOP; -- i
    --
    UPDATE sa.temp_expire_add_on 
    SET    status = 'PROCESSED',
           processed_timestamp = SYSDATE
    WHERE  account_group_id = addons.account_group_id
    AND    status IS NULL
    AND    processed_timestamp IS NULL;
    -- Save changes
    COMMIT;
    counter := counter + 1;
  END LOOP; -- addons
  --
  DBMS_OUTPUT.PUT_LINE(counter || ' groups were updated and ' || add_on_counter || ' add-ons were expired');
  DBMS_OUTPUT.PUT_LINE(expired_counter || ' groups were skipped being already expired');
  --
END;
/