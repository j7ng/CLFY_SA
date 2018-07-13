CREATE OR REPLACE TRIGGER sa."TRG_AUDIT_X_CUSTOMER_LEASE"
BEFORE UPDATE OR DELETE ON sa.x_customer_lease
REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
DECLARE
 V_ACTION VARCHAR2(30);
BEGIN


  IF UPDATING AND ( :old.x_esn != :new.x_esn or
                    :old.lease_status != :new.lease_status or
                    nvl(:old.client_id, 'XXXXX') !=  nvl(:new.client_id, 'XXXXX')  OR
					nvl(:old.application_req_num, 'XXXXX') !=  nvl(:new.application_req_num, 'XXXXX')
                   )   OR DELETING
  THEN

   IF UPDATING
   THEN V_ACTION := 'UPDATE';
   ELSE
   V_ACTION := 'DELETE';
   END IF;

    INSERT
	INTO    x_customer_lease_history
          (objid ,
           esn_lease_obj_id ,
           change_dt ,
		   dml_action,
           x_esn ,
           lease_status ,
           client_id ,
            insert_dt ,
           update_dt
           )
    VALUES
    ( sa.SEQ_X_CUSTOMER_LEASE_HISTORY.NEXTVAL ,
      :OLD.objid ,
       systimestamp ,
	   V_ACTION,
      :OLD.x_esn ,
      :OLD.lease_status ,
      :OLD.client_id ,
      :OLD.insert_dt ,
      :OLD.update_dt
    );
  END IF;
END;
/