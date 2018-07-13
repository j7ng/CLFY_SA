CREATE OR REPLACE TRIGGER sa."TRG_CT_SYNC_SPR_AIUR"
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: trg_ct_sync_spr_aiur.sql,v $
  --$Revision: 1.7 $
  --$Author: skota $
  --$Date: 2015/12/11 17:02:53 $
  --$ $Log: trg_ct_sync_spr_aiur.sql,v $
  --$ Revision 1.7  2015/12/11 17:02:53  skota
  --$ modified the if block
  --$
  --$ Revision 1.6  2015/12/11 16:29:03  skota
  --$ modified for NVL changes
  --$
  --$ Revision 1.5  2015/12/07 17:12:18  skota
  --$ modifed for the action type
  --$
  --$ Revision 1.4  2015/08/27 20:04:55  aganesan
  --$ CR37640 - Super carrier changes.
  --$
  --$ Revision 1.3  2015/07/09 19:17:28  jpena
  --$ Improvement changes for fix on recon job. CR36392
  --$
  --$ Revision 1.1  2015/06/03 15:49:58  jpena
  --$ Trigger to process super carrier
  --$
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
AFTER INSERT OR UPDATE ON sa.table_x_call_trans REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW

DISABLE DECLARE

  --Declaration of local variables for error handling.
  o_err_code NUMBER;
  o_err_msg  VARCHAR2(2000);
  l_exist_exclusion    NUMBER := NULL;
BEGIN -- Trigger Main Section Starts

  -- Added by Juda Pena for update subscriber procedure call.
  IF UPPER(:NEW.x_result) = 'COMPLETED' AND
     :NEW.x_min NOT LIKE 'T%' AND
     :NEW.x_min IS NOT NULL AND
     :NEW.x_service_id IS NOT NULL
  THEN
    -- validate brand in the parameter table
    BEGIN
      SELECT 1
      INTO   l_exist_exclusion
      FROM   sa.table_x_parameters
      WHERE  x_param_name = 'BRAND_INCLUDED_FROM_SPR:FALSE'
      AND    x_param_value = sa.util_pkg.get_bus_org_id ( i_esn => :NEW.x_service_id);
     EXCEPTION
       WHEN too_many_rows THEN
        -- return for safelink jobs
        RETURN;
       WHEN others THEN
         NULL;
    END;

    IF l_exist_exclusion IS NOT NULL THEN
      -- exit the program for safelink job
      RETURN;
    END IF;

    IF NVL(:NEW.x_action_type, :OLD.x_action_type) IN ('2','3','6','401','111') THEN --CR39782

      BEGIN
        INSERT
        INTO   sa.x_ct_sync_spr_trigger
               ( esn,
                 action_type,
                 call_trans_reason,
                 sourcesystem,
                 sub_sourcesystem
               )
        VALUES
        ( :NEW.x_service_id,
          :NEW.x_action_type,
          :NEW.x_reason,
        :NEW.x_sourcesystem,
          :NEW.x_sub_sourcesystem
        );

       EXCEPTION
         WHEN dup_val_on_index THEN
           NULL;
       WHEN OTHERS THEN
           NULL;
      END;
    END IF;
  END IF; --Ending the if loop for completed condition check.

 EXCEPTION
   WHEN OTHERS THEN
     --
     --
     sa.ota_util_pkg.err_log ( p_action       => 'EXCEPTION BLOCK WITH ESN',
                               p_error_date   => SYSDATE                   ,
                               p_key          => :NEW.x_service_id         ,
                               p_program_name => 'TRG_CT_SYNC_SPR_AIUR'    ,
                               p_error_text   => SUBSTR(SQLERRM,1,100)     );
END;
/