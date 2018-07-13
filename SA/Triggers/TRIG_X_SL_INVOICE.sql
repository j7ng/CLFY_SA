CREATE OR REPLACE TRIGGER sa.TRIG_X_SL_INVOICE BEFORE
  DELETE OR UPDATE ON sa.X_SL_INVOICE REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_X_SL_INVOICE.sql,v $
--$Revision: 1.2 $
--$Author: mmunoz $
--$Date: 2012/02/22 21:29:35 $
--$ $Log: TRIG_X_SL_INVOICE.sql,v $
--$ Revision 1.2  2012/02/22 21:29:35  mmunoz
--$ Added logic with x_invoice_reason
--$
--$ Revision 1.1  2012/02/22 19:46:12  mmunoz
--$ Insert a new row in x_sl_hist with event_code 618 when update contact data. Not allow delete
--$
--------------------------------------------------------------------------------------------
BEGIN
  IF UPDATING THEN
	IF nvl(:new.X_BILL_STATE,' ')    <> nvl(:old.X_BILL_STATE,' ')    OR
       nvl(:new.X_BILL_CITY,' ')     <> nvl(:old.X_BILL_CITY,' ')     OR
       nvl(:new.X_BILL_ZIP5,' ')     <> nvl(:old.X_BILL_ZIP5,' ')     OR
       nvl(:new.X_BILL_ADDRESS1,' ') <> nvl(:old.X_BILL_ADDRESS1,' ') OR
       nvl(:new.X_BILL_ADDRESS2,' ') <> nvl(:old.X_BILL_ADDRESS2,' ') OR
	   nvl(:new.X_INVOICE_REASON,' ')<> nvl(:old.X_INVOICE_REASON,' ')
	   --any change in contact data
	THEN
    BEGIN
     INSERT INTO sa.X_SL_HIST
            ( objid,
              lid,
              x_esn,
              x_event_dt,
              x_insert_dt,
              x_event_value,
              x_event_code,
              x_event_data,
              x_min,
              username,
              x_sourcesystem,
              x_code_number,
              x_SRC_table,
              x_SRC_objid
            )
            VALUES
            (
              sa.SEQ_X_SL_HIST.nextval,
              :new.x_lifeline_id,
              :new.x_current_part_serial_no,
              :new.x_batch_date,
              SYSDATE,
              NULL,
              618,
              substr(:new.X_INVOICE_REASON,1,100)||'|'
              ||:new.X_BILL_STATE          ||'|'
              ||:new.X_BILL_CITY           ||'|'
              ||:new.X_BILL_ZIP5           ||'|'
              ||substr(:new.X_BILL_ADDRESS1,1,50)||'|'
              ||substr(:new.X_BILL_ADDRESS2,1,50),
              :new.x_current_x_min,
              'SYSTEM',
              'SAFELINK',
              0,
              'x_sl_invoice',
              :new.objid
            );
     EXCEPTION WHEN OTHERS THEN
        raise_application_error ( -20099,SUBSTR('Audit error in TRIG_X_SL_INVOICE when inserting into SL_HIST -  '||SQLERRM,1,255) ) ;
     END;
	 END IF;
  ElSIF DELETING THEN
     raise_application_error (-20140,SUBSTR('DELETE FROM X_SL_INVOICE TABLE IS NOT ALLOWED '||SQLERRM,1,255));
  END IF;
END;
/