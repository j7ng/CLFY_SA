CREATE OR REPLACE TRIGGER sa.BLK_NONSQA_pcrf_trans
BEFORE INSERT
ON sa.x_pcrf_transaction REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
declare
cursor c1 is
select ESN, ESN_TYPE
      from sa.TEST_IGATE_ESN
     where ESN = :new.esn;
  c1_rec c1%rowtype;
begin
  -- CR47564 changes starts..
  -- Do not fire trigger if global variable is turned off
  IF NOT sa.globals_pkg.g_run_my_trigger THEN
    RETURN;
  END IF;
  -- CR47564 changes ends.
  open c1;
    fetch c1 into c1_rec;
if c1_rec.ESN_TYPE = 'C' or c1%notfound
then
   :NEW.PCRF_STATUS_CODE:='L';
end if;
close c1;
end;
/