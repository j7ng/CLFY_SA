CREATE OR REPLACE TRIGGER sa."BLK_NONSQA_ILD_TRAN2CARR"
BEFORE INSERT OR UPDATE
ON sa.table_x_ild_transaction REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
declare
cursor c1 is
select ESN, ESN_TYPE
      from sa.TEST_IGATE_ESN
     where ESN = :NEW.x_esn
       and esn_type='C';

c1_rec c1%rowtype;

begin
  open c1;
    fetch c1 into c1_rec;

    if c1%found
then
    :NEW.X_ILD_STATUS:='COMPLETED';
end if;
     close c1;
end;
/