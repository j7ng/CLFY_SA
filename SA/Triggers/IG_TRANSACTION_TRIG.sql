CREATE OR REPLACE TRIGGER sa.ig_transaction_trig

  after update of status  on gw1.ig_transaction

  for each row
DISABLE declare

     p_env varchar2(100) := 'http://10.248.40.124:8001/XMLResponseManager.jsp';
     
     cursor c is 
     select * from gw1.test_ota_esn  where esn=:NEW.esn;
     
     cursor a is
     select * from gw1.test_ota_min@clfysit2 where min=:NEW.min;
     
     l c%rowtype;
     t a%rowtype;
    pragma AUTONOMOUS_TRANSACTION;
begin

      open c; 
      fetch c into l;

       if :NEW.status ='W' and c%found 
       then 
           open a;
           fetch a into t;
           if a%found 
           then
            update gw1.test_ota_min@clfysit2 set env=p_env where min=t.min;
           else
           insert into  gw1.test_ota_min@clfysit2 (min, env) values (:NEW.min, p_env );
           end if;
           
           close a;
       end if;
    close c;
  commit;
End;
/