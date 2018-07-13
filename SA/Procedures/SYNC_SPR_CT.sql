CREATE OR REPLACE PROCEDURE sa."SYNC_SPR_CT" ( i_row_number IN NUMBER DEFAULT 10000,
                                             i_divisor    IN NUMBER DEFAULT 1 ,
                                             i_remainder  IN NUMBER DEFAULT 0) IS
  -- Declaration of local variables for error handling.
  o_err_code NUMBER;
  o_err_msg VARCHAR2(2000);
  v_param_value NUMBER;
BEGIN -- Main Section Starts
  --CR39782
  BEGIN
    SELECT TO_NUMBER(x_param_value)
      INTO v_param_value
      FROM sa.table_x_parameters
     WHERE x_param_name = 'PREACTIVATION_SPR_DELAY';
  EXCEPTION
    WHEN OTHERS THEN
    v_param_value := 10;
  END; --CR39782
  --
  UPDATE sa.x_ct_sync_spr_trigger
  SET    row_number = rownum
  WHERE  1 = 1
  AND    row_number IS NULL
  AND    ROWNUM < i_row_number;
  COMMIT;
  -- Loop through ESNs
  FOR i IN ( SELECT *
             FROM   sa.x_ct_sync_spr_trigger
             WHERE  MOD(row_number, i_divisor ) = i_remainder
             AND    ROW_NUMBER IS NOT NULL
             AND    ROWNUM < i_row_number )
  LOOP
    --CR39782 Reactivations from Call trans table not creating UPs in PCRF_Transaction
    IF i.action_type in ('3','401') THEN
	   IF i.insert_timestamp >= (SYSDATE - v_param_value/1440) THEN--  10 min delay for reactivation transaction
	   CONTINUE;
	   END IF;
	END IF;
    -- Delete temp row
    DELETE sa.x_ct_sync_spr_trigger WHERE esn = i.esn;
    -- Save changes
    COMMIT;
    -- Update subscriber procedure call
    BEGIN
    update_pcrf_subscriber ( i_esn                 => i.esn,
                             i_action_type         => i.action_type,
                             i_reason              => i.call_trans_reason,
                             i_prgm_purc_hdr_objid => NULL,
                             i_src_program_name    => 'TRG_CT_SYNC_SPR_AIU_STMT',
                             i_sourcesystem        => i.sourcesystem,
                             o_error_code          => o_err_code,
                             o_error_msg           => o_err_msg );
    -- Save changes
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
      CONTINUE;
    END;
  END LOOP; --Ending the if loop for completed condition check.
  -- Save changes
  COMMIT;
END;
/