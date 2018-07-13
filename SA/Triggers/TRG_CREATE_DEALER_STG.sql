CREATE OR REPLACE TRIGGER sa.TRG_CREATE_DEALER_STG
BEFORE INSERT ON sa.CREATE_DEALER_STG FOR EACH ROW
DECLARE
   v_username varchar2(50);
BEGIN
   -- Find username of person performing INSERT into table
   SELECT sys_context('USERENV', 'OS_USER') INTO v_username
   FROM dual;
   -- Update created_by field to the username of the person performing the INSERT
   :new.INSERT_USER := v_username;
END;
/