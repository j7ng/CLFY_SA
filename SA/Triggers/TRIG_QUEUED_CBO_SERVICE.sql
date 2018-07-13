CREATE OR REPLACE TRIGGER sa.TRIG_queued_cbo_service
  BEFORE INSERT OR UPDATE ON sa.table_queued_cbo_service
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
DECLARE
begin
  if :new.status in('F', 'C') then
    :new.processed_date := sysdate;
  end if;
END;
/