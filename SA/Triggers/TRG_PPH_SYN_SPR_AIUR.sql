CREATE OR REPLACE TRIGGER sa."TRG_PPH_SYN_SPR_AIUR"
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: trg_pph_syn_spr_aiur.sql,v $
  --$Revision: 1.3 $
  --$Author: jpena $
  --$Date: 2015/07/09 19:18:34 $
  --$ $Log: trg_pph_syn_spr_aiur.sql,v $
  --$ Revision 1.3  2015/07/09 19:18:34  jpena
  --$ Improvement changes for fix on recon job. CR36392
  --$
  --$ Revision 1.1  2015/06/03 15:49:58  jpena
  --$ Trigger to process super carrier
  --$
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
AFTER INSERT OR UPDATE ON sa.x_program_purch_hdr REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW

DISABLE DECLARE

BEGIN -- Trigger Main Section Starts

  --DBMS_OUTPUT.PUT_LINE('entered x_pph_sync_spr_trigger');

  --Changed IF condition for CR33629
  IF ( inserting AND NVL(:new.X_ICS_RCODE,'0') IN ('1', '100')                                                                                       --Successful payments
    AND :new.X_MERCHANT_ID IS NOT NULL                                                                                                               --Exclude BML
    AND :new.X_PAYMENT_TYPE NOT IN ('REFUND', 'OTAPURCH')                                                                                            --Exclude Refunds and mobile billing
    AND :new.X_AMOUNT >= 20                                                                                                                          --Exclude HPP (as of now identifying HPP based on dollar amount)
    AND :new.X_MERCHANT_ID NOT LIKE '%wusa%'                                                                                                         --Exclude mobile billing
    ) OR ( updating AND NVL(:new.X_ICS_RCODE,'0') IN ('1','100') AND NVL(:old.X_ICS_RCODE,'0') NOT IN ('1','100') AND :new.X_MERCHANT_ID IS NOT NULL --Exclude BML
      AND :new.X_PAYMENT_TYPE NOT                 IN ('REFUND', 'OTAPURCH')                                                                          --Exclude Refunds and mobile billing
      AND :new.X_AMOUNT >= 20                                                                                                                        --Exclude HPP (as of now identifying HPP based on dollar amount)
      AND :new.X_MERCHANT_ID NOT LIKE '%wusa%'                                                                                                       --Exclude mobile billing
    )
  THEN
    --DBMS_OUTPUT.PUT_LINE('inserting into x_pph_sync_spr_trigger');
    BEGIN
      INSERT
      INTO   sa.x_pph_sync_spr_trigger
             ( pph_objid,
               sourcesystem
             )
	  VALUES
	  ( :NEW.objid,
	    :NEW.x_rqst_source
      );
     EXCEPTION
       WHEN dup_val_on_index THEN
         NULL;
    END;
    --DBMS_OUTPUT.PUT_LINE('done inserting into x_pph_sync_spr_trigger');

  END IF; -- Ending the if for completed condition check.

  --DBMS_OUTPUT.PUT_LINE('done x_pph_sync_spr_trigger');

 EXCEPTION
   WHEN OTHERS THEN
     --DBMS_OUTPUT.PUT_LINE('inserting into x_pph_sync_spr_trigger: ' || sqlerrm);
     --
     sa.ota_util_pkg.err_log ( p_action       => 'EXCEPTION BLOCK WITH PROGRAM_PURCH_HDR OBJID' ,
                               p_error_date   => SYSDATE                                        ,
                               p_key          => :NEW.objid                                     ,
                               p_program_name => 'TRG_PPH_SYN_SPR_AIUR'                         ,
                               p_error_text   => SUBSTR(SQLERRM,1,100) );
END;
/