CREATE OR REPLACE TRIGGER sa."TRG_CT_SYNC_SPR_AIU_STMT"
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: trg_ct_sync_spr_aiu_stmt.sql,v $
  --$Revision: 1.2 $
  --$Author: jpena $
  --$Date: 2015/07/09 19:18:05 $
  --$ $Log: trg_ct_sync_spr_aiu_stmt.sql,v $
  --$ Revision 1.2  2015/07/09 19:18:05  jpena
  --$ Improvement changes for fix on recon job. CR36392
  --$
  --$ Revision 1.1  2015/06/03 15:49:58  jpena
  --$ Trigger to process super carrier
  --$
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
AFTER INSERT OR UPDATE ON sa.table_x_call_trans

DISABLE DECLARE

  -- Declaration of local variables for error handling.
  o_err_code NUMBER;
  o_err_msg VARCHAR2(2000);

BEGIN -- Trigger Main Section Starts
  -- Loop through ESNs
  FOR i IN ( SELECT * FROM sa.x_ct_sync_spr_trigger) LOOP
    -- Delete temp row
    DELETE sa.x_ct_sync_spr_trigger WHERE esn = i.esn;

    --Update subscriber procedure call.
    update_pcrf_subscriber ( i_esn                 => i.esn,
                             i_action_type         => i.action_type,
                             i_reason              => i.call_trans_reason,
                             i_prgm_purc_hdr_objid => NULL,
                             i_src_program_name    => 'TRG_CT_SYNC_SPR_AIU_STMT',
                             i_sourcesystem        => i.sourcesystem,
                             o_error_code          => o_err_code,
                             o_error_msg           => o_err_msg );
  END LOOP; --Ending the if loop for completed condition check.

END;
/