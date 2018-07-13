CREATE OR REPLACE PROCEDURE sa."RESET_PCRF_TRANSACTION" ( i_divisor   IN NUMBER DEFAULT 1 ,
                                                        i_remainder IN NUMBER DEFAULT 0 ,
                                                        i_row_limit IN NUMBER DEFAULT 1000 ) IS

  ptt   pcrf_transaction_type; -- Used to capture temporary attributes

  pcrf  pcrf_transaction_type; -- Used to instantiate constructor
  p     pcrf_transaction_type; -- Used to call method to perform update action

  pftl  pcrf_failed_trans_log_type; -- Used to instantiate constructor
  pf    pcrf_failed_trans_log_type; -- Used to call method to perform update action

  lptt  pcrf_trans_low_prty_type; -- Used to capture temporary attributes
  lpcrf pcrf_trans_low_prty_type; -- Used to instantiate constructor
  lp    pcrf_trans_low_prty_type; -- Used to call method to perform update action

  --
  CURSOR get_pcrf IS
    SELECT *
    FROM   ( SELECT ROWID, p.*
             FROM   x_pcrf_transaction p
             WHERE  pcrf_status_code IN ('E','W')
             AND    MOD( p.objid, i_divisor ) = i_remainder
             ORDER BY p.objid
           )
    WHERE  ROWNUM <= i_row_limit;

-- Start of Main Section
BEGIN
  -- Loop through all
  FOR i IN get_pcrf LOOP

    -- Reset PCRF transaction type
    ptt := pcrf_transaction_type();

    -- Get current status of the pcrf row
    BEGIN
      SELECT pcrf_status_code
      INTO   ptt.pcrf_status_code
      FROM   x_pcrf_transaction
      WHERE  objid = i.objid;
     EXCEPTION
       WHEN others THEN
         -- Process should never come in this block
         CONTINUE; -- Continue to next iteration
    END;

    -- Making sure the STATUS was not set to SUCCESSFUL by another process
    IF ptt.pcrf_status_code = 'S' THEN
      --
      CONTINUE; -- Continue to next iteration
    END IF;

    -- Find a newer pcrf transaction row
    BEGIN
      SELECT p.objid
      INTO   ptt.pcrf_transaction_id
      FROM   x_pcrf_transaction p
      WHERE  1 = 1
      AND    objid  = i.objid
      AND    order_type NOT IN ('BI')
      AND    EXISTS ( SELECT 1
                      FROM   x_pcrf_transaction
                      WHERE  1 = 1
                      AND    subscriber_id = p.subscriber_id
                      AND    order_type NOT IN ('BI')
                      AND    pcrf_status_code NOT IN ('S','C')
                      AND    insert_timestamp > p.insert_timestamp
                    );
     EXCEPTION
       WHEN no_data_found THEN
         -- Do nothing and continue logic
         NULL;
       WHEN others THEN
         -- Process should never come in this block
         NULL;
    END;

    -- Close when there is a newer PCRF transaction row
    IF ptt.pcrf_transaction_id IS NOT NULL THEN

      -- Instantiate values for the update member function
      pcrf := pcrf_transaction_type ( i_pcrf_transaction_id => i.objid   ,
                                      i_pcrf_status_code    => 'C',
                                      i_status_message      => 'NEWER PCRF TRANSACTION FOUND' );

      -- Call update pcrf transaction member function
      p := pcrf.upd;

      --DBMS_OUTPUT.PUT_LINE('pcrf.upd(status) => ' || p.status);

      -- Save changes
      COMMIT;

      -- Continue to next iteration
      CONTINUE;

    END IF;

    --
    ptt.pcrf_transaction_id := NULL;


    -- Fail the PCRF row when there is an error (E)
    IF i.pcrf_status_code = 'E' THEN

      -- Instantiate values for the insert of pcrf failed transaction log member function
      pftl := pcrf_failed_trans_log_type ( i_pcrf_transaction_id => i.objid);

      -- Call insert pcrf failed transaction log member function
      pf := pftl.ins;

      --DBMS_OUTPUT.PUT_LINE('pftl.ins(response) => ' || pf.response);

      -- Save changes
      COMMIT;

      -- Increment failed count retries
      ptt.retry_count := NVL(i.retry_count,0) + 1;

      -- Instantiate values for the update member function
      pcrf := pcrf_transaction_type ( i_pcrf_transaction_id => i.objid   ,
                                      i_pcrf_status_code    => 'F',
                                      i_retry_count         => ptt.retry_count );

      -- Call update pcrf transaction member function
      p := pcrf.upd;

      --DBMS_OUTPUT.PUT_LINE('pcrf.upd(status) => ' || p.status);

      -- Save changes
      COMMIT;

      -- Continue to next iteration
      CONTINUE;
    END IF;

    -- Set the PCRF transaction to successful
    IF i.pcrf_status_code = 'W' THEN

      -- Instantiate values for the update member function
      pcrf := pcrf_transaction_type ( i_pcrf_transaction_id => i.objid,
                                      i_pcrf_status_code    => 'S' );

      -- Call update pcrf transaction member function
      p := pcrf.upd;

      --DBMS_OUTPUT.PUT_LINE('pcrf.upd(status) => ' || p.status);

      -- Save changes
      COMMIT;

      -- Continue to next iteration
      CONTINUE;

    END IF;

    -- Reset type attribute
    ptt.pcrf_status_code := NULL;

    -- Check the final pcrf_status_code of the PCRF transaction
    BEGIN
      SELECT pcrf_status_code
      INTO   ptt.pcrf_status_code
      FROM   x_pcrf_transaction
      WHERE  ROWID = i.ROWID;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;

    -- If final status is successful
    IF ptt.pcrf_status_code = 'S' THEN

      -- Do nothing for now
      NULL;

    END IF;

  END LOOP; -- get_pcrf

  -- Save
  COMMIT;

  ------------------------------------------------------
  -- Loop through all low priority records
  ------------------------------------------------------
  FOR i IN ( SELECT *
             FROM   ( SELECT ROWID, p.*
                      FROM   x_pcrf_trans_low_prty p
                      WHERE  pcrf_status_code IN ('E','W')
                      AND    MOD( p.objid, i_divisor ) = i_remainder
                      ORDER BY p.objid
                    )
             WHERE  ROWNUM <= i_row_limit
           )
  LOOP

    -- Reset PCRF transaction type
    lptt := pcrf_trans_low_prty_type();

    -- Get current status of the pcrf row
    BEGIN
      SELECT pcrf_status_code
      INTO   lptt.pcrf_status_code
      FROM   x_pcrf_trans_low_prty
      WHERE  objid = i.objid;
     EXCEPTION
       WHEN others THEN
         -- Process should never come in this block
         CONTINUE; -- Continue to next iteration
    END;

    -- Making sure the STATUS was not set to SUCCESSFUL by another process
    IF lptt.pcrf_status_code = 'S' THEN
      --
      CONTINUE; -- Continue to next iteration
    END IF;

    -- Find a newer pcrf transaction row
    BEGIN
      SELECT p.objid
      INTO   lptt.pcrf_transaction_id
      FROM   x_pcrf_trans_low_prty p
      WHERE  1 = 1
      AND    objid  = i.objid
      AND    order_type NOT IN ('BI')
      AND    EXISTS ( SELECT 1
                      FROM   x_pcrf_trans_low_prty
                      WHERE  1 = 1
                      AND    subscriber_id = p.subscriber_id
                      AND    order_type NOT IN ('BI')
                      AND    pcrf_status_code NOT IN ('S','C')
                      AND    insert_timestamp > p.insert_timestamp
                    );
     EXCEPTION
       WHEN no_data_found THEN
         -- Do nothing and continue logic
         NULL;
       WHEN others THEN
         -- Process should never come in this block
         NULL;
    END;

    -- Close when there is a newer PCRF transaction row
    IF lptt.pcrf_transaction_id IS NOT NULL THEN

      -- Instantiate values for the update member function
      lpcrf := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => i.objid   ,
                                       i_pcrf_status_code    => 'C',
                                       i_status_message      => 'NEWER PCRF TRANSACTION FOUND' );

      -- Call update pcrf transaction member function
      lp := lpcrf.upd;

      --DBMS_OUTPUT.PUT_LINE('pcrf.upd(status) => ' || p.status);

      -- Save changes
      COMMIT;

      -- Continue to next iteration
      CONTINUE;

    END IF;

    --
    lptt.pcrf_transaction_id := NULL;


    -- Fail the PCRF row when there is an error (E)
    IF i.pcrf_status_code = 'E' THEN

      -- Instantiate values for the insert of pcrf failed transaction log member function
      pftl := pcrf_failed_trans_log_type ( i_pcrf_transaction_id => i.objid);

      -- Call insert pcrf failed transaction log member function
      pf := pftl.ins;

      --DBMS_OUTPUT.PUT_LINE('pftl.ins(response) => ' || pf.response);

      -- Save changes
      COMMIT;

      -- Increment failed count retries
      lptt.retry_count := NVL(i.retry_count,0) + 1;

      -- Instantiate values for the update member function
      lpcrf := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => i.objid   ,
                                       i_pcrf_status_code    => 'F',
                                       i_retry_count         => lptt.retry_count );

      -- Call update pcrf transaction member function
      lp := lpcrf.upd;

      --DBMS_OUTPUT.PUT_LINE('pcrf.upd(status) => ' || p.status);

      -- Save changes
      COMMIT;

      -- Continue to next iteration
      CONTINUE;
    END IF;

    -- Set the PCRF transaction to successful
    IF i.pcrf_status_code = 'W' THEN

      -- Instantiate values for the update member function
      lpcrf := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => i.objid,
                                       i_pcrf_status_code    => 'S' );

      -- Call update pcrf transaction member function
      lp := lpcrf.upd;

      --DBMS_OUTPUT.PUT_LINE('pcrf.upd(status) => ' || p.status);

      -- Save changes
      COMMIT;

      -- Continue to next iteration
      CONTINUE;

    END IF;

    -- Reset type attribute
    lptt.pcrf_status_code := NULL;

    -- Check the final pcrf_status_code of the PCRF transaction
    BEGIN
      SELECT pcrf_status_code
      INTO   lptt.pcrf_status_code
      FROM   x_pcrf_trans_low_prty
      WHERE  ROWID = i.ROWID;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;

    -- If final status is successful
    IF lptt.pcrf_status_code = 'S' THEN

      -- Do nothing for now
      NULL;

    END IF;

  END LOOP; -- get_pcrf

  -- Save
  COMMIT;

END;
/