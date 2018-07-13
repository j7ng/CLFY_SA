CREATE OR REPLACE TRIGGER sa.TRIG_XSU_VMBC_RESPONSE_VIEW
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_XSU_VMBC_RESPONSE_VIEW.sql,v $
--$Revision: 1.1 $
--$Author: rpednekar $
--$Date: 2015/11/11 18:36:41 $
--$ $Log: TRIG_XSU_VMBC_RESPONSE_VIEW.sql,v $
--$ Revision 1.1  2015/11/11 18:36:41  rpednekar
--$ CR39089
--$
--$ Revision 1.3  2015/11/10 20:48:44  rpednekar
--$ CR39089 - Modified condition in view.
--$
--$ Revision 1.2  2015/11/03 23:38:21  rpednekar
--$ CR38122 - VMBC specific changes only
--$
--$ Revision 1.2  2011/12/21 22:03:29  mmunoz
--$ Safelink Vmbc Sync   CR 17925 SafeLink II (Invoicing & Synch). Allow updating batchdate
--$
--------------------------------------------------------------------------------------------
   INSTEAD OF INSERT OR UPDATE OR DELETE
   ON sa.XSU_VMBC_RESPONSE_VIEW   REFERENCING NEW AS NEW OLD AS OLD
BEGIN
   BEGIN
       IF INSERTING THEN
          INSERT INTO sa.XSU_VMBC_RESPONSE
                  (responseto, requestid, lid,
                   enrollrequest, errorcode, errormsg,
                   activatedate, phoneesn, phonenumber,
                   trackingnumber, ticketnumber, batchdate
				   ,data_source		--CR38122
                  )
          VALUES (:NEW."responseTo", :NEW."requestId", :NEW."lid",
                   :NEW."enrollRequest", :NEW."errorCode", :NEW."errorMsg",
                   :NEW."activateDate", :NEW."phoneEsn", :NEW."phoneNumber",
                   :NEW."trackingNumber", :NEW."ticketNumber", :NEW.batchdate
				   ,'VMBC'			--CR38122
                   );
       END IF;
   EXCEPTION WHEN OTHERS THEN
       raise_application_error (-20175,SUBSTR('Error when inserting into XSU_VMBC_RESPONSE TABLE from XSU_VMBC_RESPONSE_VIEW - '||SQLERRM,1,255));
   END;

   IF UPDATING THEN
     if :OLD.batchdate is null AND :NEW.batchdate IS NOT NULL then
	    /** Safelink Vmbc Sync ?  CR 17925 SafeLink II (Invoicing & Synch)  **/
		    UPDATE sa.XSU_VMBC_RESPONSE
		    SET    batchdate =  :NEW.batchdate
		    WHERE  batchdate IS NULL;
	   else
	      null;
	   end if;
     --raise_application_error (-20110,SUBSTR(' UPDATE OF XSU_VMBC_RESPONSE_VIEW IS NOT ALLOWED '||SQLERRM,1,255));
   ELSIF DELETING THEN
     raise_application_error (-20120,SUBSTR(' DELETE FROM XSU_VMBC_RESPONSE_VIEW IS NOT ALLOWED '||SQLERRM,1,255));
   END IF;

END;
/