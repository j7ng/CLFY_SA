CREATE OR REPLACE TRIGGER sa."TRG_TABLE_X_ILD_TRANSACTION"
BEFORE UPDATE
ON sa.TABLE_X_ILD_TRANSACTION REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: TRG_TABLE_X_ILD_TRANSACTION.sql,v $
--$Revision: 1.11 $
--$Author: arijal $
--$Date: 2015/01/30 15:50:04 $
--$ $Log: TRG_TABLE_X_ILD_TRANSACTION.sql,v $
--$ Revision 1.11  2015/01/30 15:50:04  arijal
--$ CR32512 ILD fix trigger
--$
--$ Revision 1.10  2014/12/17 22:13:46  arijal
--$ CR31545 SL CA HOME PHONE DDL TRIGGER ILD
--$
--$ Revision 1.8  2014/10/20 15:44:02  icanavan
--$ ADD BP_STILD_U
--$
--$ Revision 1.7  2014/10/15 18:25:06  icanavan
--$ CR30672  ADD 4 MEW ILD CODES
--$
--$ Revision 1.6  2014/09/16 16:51:54  icanavan
--$ Update trigger to include TC_ILD_20U
--$
--$ Revision 1.5  2014/02/13 20:21:05  ymillan
--$ CR26443
--$
--$ Revision 1.4  2013/07/17 16:30:50  akhan
--$ Adding CVS header
--$
--------------------------------------------------------------------------------------------
BEGIN
  if (:old.X_ILD_TRANS_TYPE in ('A', 'CRU','R')
      and :old.X_PRODUCT_ID in ('TC_ILD_50U','TC_ILD_10','TC_ILD_40U','TC_ILD_29U','TC_ILD_U','ST_ILD_U','NT_ILD_U','SM_ILD_U','TC_ILD_20U','BP_TCILD_29U','BP_TCILD_40U','BP_TCILD_50U','BP_TC60Plus','BP_STILD_U','SLNT_ILD_10', 'SLNT_ILD_P') --CR26443 -- CR29822 -- CR31545
      AND (:old.x_api_status IS NULL OR :old.x_api_status != 'OK') AND :new.x_api_status = 'OK'
      AND :old.x_ild_status != 'COMPLETED' AND :new.x_ild_status = 'COMPLETED'
      AND :old.x_min NOT LIKE 'T%') THEN
    --
    BEGIN
      --
      INSERT INTO sa.byop_sms_stg
        (esn
        ,min
        ,carrier_id
        ,transaction_type
        ,insert_date)
      (SELECT :old.x_esn
        ,:old.x_min
        ,(select X_CARRIER_ID
          from sa.TABLE_PART_INST
          inner join sa.TABLE_X_CARRIER
          on TABLE_X_CARRIER.OBJID = PART_INST2CARRIER_MKT
          where part_serial_no = :old.x_min)
        ,:old.x_product_id
        ,SYSDATE
      FROM dual
      );
                  --
      EXCEPTION
        WHEN others THEN
          --
          raise_application_error(-20000
                                 ,'Failure inserting into SA.BYOP_SMS_STG table with Oracle error: ' || SQLERRM);
          --
    END;
    --
  END IF;
  --
END;
/