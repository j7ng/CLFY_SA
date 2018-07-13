CREATE OR REPLACE TRIGGER sa."TRG_TP_INST"
BEFORE UPDATE
ON sa.TABLE_PART_INST REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
BEGIN
  if :new.X_PART_INST_STATUS = '44'   THEN
   BEGIN
     INSERT INTO sa.PART_INST_AUDIT
           (PART_SERIAL_NO,
             OLD_PART_INST_STATUS,
             NEW_PART_INST_STATUS,
             OS_USER,
             DB_USER,
             UPDATE_DATE)
       values
            (:old.PART_SERIAL_NO,
             :old.X_PART_INST_STATUS,
             :new.X_PART_INST_STATUS,
             sys_context('USERENV', 'OS_USER'),
             UPPER(user),
             sysdate);
        EXCEPTION
        WHEN others THEN
          raise_application_error(-20000
                                 ,'Failure inserting into SA.PART_INST_AUDIT table with Oracle error: ' || SQLERRM);
     END;
   END IF;

END;
/