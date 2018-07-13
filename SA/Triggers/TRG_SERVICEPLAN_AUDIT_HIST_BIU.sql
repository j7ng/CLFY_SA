CREATE OR REPLACE TRIGGER sa.TRG_SERVICEPLAN_AUDIT_HIST_BIU
AFTER INSERT OR UPDATE OR DELETE ON sa.X_SERVICE_PLAN
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
 v_action    VARCHAR2(32767);
BEGIN

  IF INSERTING THEN
    V_ACTION := 'INSERT';
  ELSIF UPDATING THEN
    V_ACTION := 'UPDATE';
  ELSE
    v_action := 'DELETE';
  END IF;

  INSERT INTO sa.X_SERVICEPLAN_AUDIT_HIST (objid,action,old_service_plan_objid,old_mkt_name,old_description,old_customer_price,old_ivr_plan_id,
                                           x_last_modified_date,new_service_plan_objid,NEW_MKT_NAME,NEW_DESCRIPTION,
                                           NEW_CUSTOMER_PRICE,NEW_IVR_PLAN_ID)
  VALUES (sa.SEQU_SERVICEPLAN_AUDIT_HIST.NEXTVAL,
          v_action,
          :OLD.objid,
          :OLD.MKT_NAME,
          :OLD.DESCRIPTION,
          :OLD.CUSTOMER_PRICE,
          :OLD.IVR_PLAN_ID,
           SYSDATE,
          :NEW.objid,
          :NEW.MKT_NAME,
          :NEW.DESCRIPTION,
          :NEW.CUSTOMER_PRICE,
          :NEW.IVR_PLAN_ID);

END;
/