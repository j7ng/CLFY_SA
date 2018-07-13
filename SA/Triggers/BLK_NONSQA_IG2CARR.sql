CREATE OR REPLACE TRIGGER sa.BLK_NONSQA_IG2CARR
BEFORE INSERT 
ON GW1.IG_TRANSACTION REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
declare
cursor c1 is
select ESN, ESN_TYPE
      from sa.TEST_IGATE_ESN
     where ESN = :new.esn;
  c1_rec c1%rowtype;
begin
  open c1;
    fetch c1 into c1_rec;
if c1_rec.ESN_TYPE = 'C' or c1%notfound
then
   :NEW.STATUS:='L';
end if;
close c1;
end;
/