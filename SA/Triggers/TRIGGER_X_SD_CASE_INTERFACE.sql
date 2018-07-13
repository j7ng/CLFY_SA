CREATE OR REPLACE TRIGGER sa."TRIGGER_X_SD_CASE_INTERFACE"
AFTER  UPDATE ON sa.X_SD_CASE_INTERFACE
FOR EACH ROW
 DISABLE WHEN (
new.CASE_STATUS = 'C'
      ) declare
 a number;
begin
if updating then
  sa.sd_close_case(:new.id_number);
end if;
end;
/