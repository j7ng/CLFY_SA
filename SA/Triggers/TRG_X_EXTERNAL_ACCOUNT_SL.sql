CREATE OR REPLACE TRIGGER sa.TRg_X_EXTERNAL_ACCOUNT_SL
before insert on sa.X_SL_SUBS
for each row
BEGIN
  IF :new.X_EXTERNAL_ACCOUNT IS NOT NULL THEN
    :new.X_EXTERNAL_ACCOUNT :=substr( :new.X_EXTERNAL_ACCOUNT,1,4)||to_char(sysdate, 'YYYYMMDD')||round(dbms_random.value(100000000, 999999999)) ;
  END IF;
 EXCEPTION WHEN OTHERS THEN
  raise_application_error(-200120,SUBSTR('Error in updating X_EXTERNAL_ACCOUNT on SA.X_SL_SUBS '||SQLERRM,1,255));
END;
/