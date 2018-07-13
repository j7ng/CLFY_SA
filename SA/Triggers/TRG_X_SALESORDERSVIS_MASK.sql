CREATE OR REPLACE TRIGGER sa.TRG_X_SALESORDERSVIS_MASK
before insert or update
on sa.X_SALES_ORDER_SERVICES
for each row
BEGIN
 :new.SSN_LAST_4 :=null;
     :new.PROV_PASS_PIN  := null;
END;
/