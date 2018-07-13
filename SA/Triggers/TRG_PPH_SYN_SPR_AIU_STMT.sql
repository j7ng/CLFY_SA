CREATE OR REPLACE TRIGGER sa."TRG_PPH_SYN_SPR_AIU_STMT"
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: trg_pph_syn_spr_aiu_stmt.sql,v $
  --$Revision: 1.4 $
  --$Author: skota $
  --$Date: 2015/12/14 22:48:52 $
  --$ $Log: trg_pph_syn_spr_aiu_stmt.sql,v $
  --$ Revision 1.4  2015/12/14 22:48:52  skota
  --$ for CR39982
  --$
  --$ Revision 1.3  2015/08/27 20:04:55  aganesan
  --$ CR37640 - Super carrier changes.
  --$
  --$ Revision 1.2  2015/07/09 19:18:59  jpena
  --$ Improvement changes for fix on recon job. CR36392
  --$
  --$ Revision 1.1  2015/06/03 15:49:58  jpena
  --$ Trigger to process super carrier
  --$
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
AFTER INSERT OR UPDATE ON sa.x_program_purch_hdr
DISABLE DECLARE

  -- Declaration of local variables for error handling.
  o_err_code NUMBER;
  o_err_msg  VARCHAR2(2000);
  l_esn      VARCHAR2(30);
  l_exist_exclusion NUMBER := NULL;
  l_exist_ct_syn_spr NUMBER := NULL;
  v_param_value NUMBER;

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
  END; --CR39982

  FOR i IN ( SELECT * FROM sa.x_pph_sync_spr_trigger ) LOOP

	--CR39982 Delaying the transaction 10 mins
    IF i.insert_timestamp >= (SYSDATE - v_param_value/1440) THEN--  10 min delay for redemption transaction
	  CONTINUE;
	  END IF;
    --
    FOR j IN ( SELECT x_esn, sa.util_pkg.get_bus_org_id ( i_esn => x_esn) brand
               FROM   sa.x_program_purch_dtl
               WHERE  pgm_purch_dtl2prog_hdr = i.pph_objid
             ) LOOP


      -- Delete temp row
      DELETE sa.x_pph_sync_spr_trigger WHERE pph_objid = i.pph_objid;

      -- Validate brand in the parameter table
      BEGIN
        SELECT 1
        INTO   l_exist_exclusion
        FROM   table_x_parameters
        WHERE  x_param_name = 'BRAND_INCLUDED_FROM_SPR:FALSE'
        AND    x_param_value = j.brand;
      EXCEPTION
        WHEN too_many_rows THEN
          -- Continue for safelink jobs
          CONTINUE;
        WHEN others THEN
         NULL;
      END;

      IF l_exist_exclusion IS NOT NULL THEN
        -- return for safelink jobs
        CONTINUE;
      END IF;

      IF j.x_esn IS NOT NULL THEN
       BEGIN
          SELECT 1
          INTO   l_exist_ct_syn_spr
          FROM   sa.x_ct_sync_spr_trigger
          WHERE  esn = j.x_esn;
	   EXCEPTION
          WHEN too_many_rows THEN
            CONTINUE;
          WHEN others THEN
            NULL;
	   END;

	   IF l_exist_ct_syn_spr IS NOT NULL THEN
       CONTINUE;
       END IF;
        -- Update subscriber procedure call.
        BEGIN
        update_pcrf_subscriber ( i_esn                 => j.x_esn,
                                 i_action_type         => '6',
                                 i_reason              => NULL,
                                 i_prgm_purc_hdr_objid => i.pph_objid,
                                 i_src_program_name    => 'TRG_PPH_SYN_SPR_AIU_STMT',
                                 i_sourcesystem        => i.sourcesystem,
                                 o_error_code          => o_err_code,
                                 o_error_msg           => o_err_msg );
		EXCEPTION
         WHEN OTHERS THEN
           CONTINUE;
        END;
        --
      END IF;

      --
    END LOOP; -- j
  END LOOP; -- Ending the loop.

END;
/