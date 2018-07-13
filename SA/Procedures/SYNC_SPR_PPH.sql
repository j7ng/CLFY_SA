CREATE OR REPLACE PROCEDURE sa."SYNC_SPR_PPH" ( i_row_number IN NUMBER DEFAULT 10000,
                                               i_divisor    IN NUMBER DEFAULT 1 ,
                                               i_remainder  IN NUMBER DEFAULT 0 ) IS
  -- Declaration of local variables for error handling.
  o_err_code         NUMBER;
  o_err_msg          VARCHAR2(2000);
  l_esn              VARCHAR2(30);
  l_exist_exclusion  NUMBER := NULL;
  l_exist_ct_syn_spr NUMBER := 0;
  v_param_value      NUMBER;
BEGIN -- Trigger Main Section Starts
  -- Loop through PPHs
  BEGIN
    SELECT TO_NUMBER(x_param_value)
    INTO v_param_value
    FROM sa.table_x_parameters
    WHERE x_param_name = 'PREACTIVATION_SPR_DELAY';
   EXCEPTION
     WHEN OTHERS THEN
       v_param_value := 10;
  END; -- CR39982
  FOR i IN ( SELECT *
             FROM   sa.x_pph_sync_spr_trigger
             WHERE  MOD(pph_objid, i_divisor ) = i_remainder
             AND    ROWNUM < i_row_number )
  LOOP
    -- CR39982 Delaying the transaction 10 mins
    IF i.insert_timestamp >= (SYSDATE - v_param_value/1440) THEN -- 10 min delay for redemption transaction
      CONTINUE;
    END IF;
    --
    FOR j IN ( SELECT x_esn
               FROM   x_program_purch_dtl
               WHERE  pgm_purch_dtl2prog_hdr = i.pph_objid
             ) LOOP
      -- Delete temp row
      DELETE sa.x_pph_sync_spr_trigger WHERE pph_objid = i.pph_objid;
      -- Save changes
      COMMIT;
      IF j.x_esn IS NOT NULL THEN
        BEGIN
   	      SELECT COUNT(1)
   	      INTO   l_exist_ct_syn_spr
   	      FROM   sa.x_ct_sync_spr_trigger
   	      WHERE  esn = j.x_esn;
         EXCEPTION
   	       WHEN others THEN
   	         l_exist_ct_syn_spr := 0;
        END;
        IF l_exist_ct_syn_spr > 0 THEN
          CONTINUE;
        END IF;
        BEGIN
          -- Update subscriber procedure call.
          update_pcrf_subscriber ( i_esn                 => j.x_esn,
                                   i_action_type         => '6',
                                   i_reason              => NULL,
                                   i_prgm_purc_hdr_objid => i.pph_objid,
                                   i_src_program_name    => 'TRG_PPH_SYN_SPR_AIU_STMT',
                                   i_sourcesystem        => i.sourcesystem,
                                   o_error_code          => o_err_code,
                                   o_error_msg           => o_err_msg );
          COMMIT;
         EXCEPTION
           WHEN OTHERS THEN
             CONTINUE;
        END;
      --
      END IF;
      --
    END LOOP; -- j
  END LOOP; -- Ending the loop.
  -- Save changes
  COMMIT;
END;
/