CREATE OR REPLACE TRIGGER sa.gethandsetinfo_trg
BEFORE insert or UPDATE or DELETE ON sa.x_gethandsetinfo REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
BEGIN
   if updating or inserting then
    :NEW.x_UPDATE_date := sysdate;
    :NEW.x_UPDATE_user := user;
  end if;
  if updating or deleting then
    insert into sa.x_gethandsetinfo_hist(objid,
                                      x_order,
                                      x_plan_type,
                                      x_due_date ,
                                      x_triple_minutes,
                                      x_safelink,
                                      x_brand,
                                      x_account_id,
                                      x_redeem_in_last_90_days,
                                      x_balance,
                                      x_balance_type,
	                              x_auto_refill,
                                      x_BILLING_DIRECTION,
                                      x_RESOLUTION_URL,
                                      x_update_date,
                                      x_update_user,
                                      x_ppe_enabled,
                                      x_device_type,
                                      x_device_os)
                               values(
                                      :old.objid,
                                      :old.x_order,
                                      :old.x_plan_type,
                                      :old.x_due_date ,
                                      :old.x_triple_minutes,
                                      :old.x_safelink,
                                      :old.x_brand,
                                      :old.x_account_id,
                                      :old.x_redeem_in_last_90_days,
                                      :old.x_balance,
                                      :old.x_balance_type,
                                      :old.x_auto_refill,
                                      :old.x_BILLING_DIRECTION,
                                      :old.x_RESOLUTION_URL,
                                      :old.x_update_date,
                                      :old.x_update_user,
                                      :old.x_ppe_enabled,
                                      :old.x_device_type,
                                      :old.x_device_os
                                      );
  end if;
END;
/