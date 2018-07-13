CREATE OR REPLACE TRIGGER sa.BLK_NONSQA_RIM_TRAN2CARR
BEFORE INSERT OR UPDATE
ON gw1.TABLE_X_RIM_TRANSACTION REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
declare
cursor c1 is
select ESN, ESN_TYPE
      from sa.TEST_IGATE_ESN
     where ESN = :new.x_esn
     and ESN_TYPE = 'C';
      
  c1_rec c1%rowtype;
begin
  open c1;
    fetch c1 into c1_rec;

    if c1%found
then
    :new.X_RIM_STATUS:='COMPLETED';
end if;
     close c1;
end;
/