CREATE OR REPLACE Procedure sa.Create_User_db (
P_Uname In Varchar2,
OP_MESSAGE out varchar2)
AS
  Uname VARCHAR2(50) := upper(P_Uname);
  v_statement  varchar2(1000);

 cursor c (p_name varchar2) is
 select 1 from dba_users where username=upper(p_name);
 l c%rowtype;

begin
  open c(Uname);
  fetch c into l;
  if c%notfound then
       v_statement := 'CREATE user '||Uname||'  identified by "Abc123**" default tablespace users ACCOUNT UNLOCK PROFILE default';
--     dbms_output.put_line (v_statement);
   EXECUTE IMMEDIATE v_statement ;
   op_message:='DB User Created -- '||Uname ||'|| Password Abc123**';
   else
     v_statement := 'alter USER  '||Uname||' IDENTIFIED BY "Abc123**" account unlock profile default';
   EXECUTE IMMEDIATE v_statement ;
   op_message:='DB User Altered -- '||Uname ||'|| Password Abc123**';
   end if;


  v_statement := 'grant CONNECT,RESOURCE,CLARIFY_USER,ROLE_SA_SELECT, ROLE_SA_UPDATE,ROLE_TF_SELECT,ROLE_SQA_TESTER, CREATE SESSION , UNLIMITED TABLESPACE to '||uname;
   EXECUTE IMMEDIATE v_statement ;
  /**
   v_statement := 'grant  select, update, insert  on GW1.IG_TRANSACTION to '||Uname;
     EXECUTE IMMEDIATE v_statement ;

    v_statement := 'grant  select, update, insert  on gw1.test_ota_esn to '||Uname;
     EXECUTE IMMEDIATE v_statement ;

    v_statement := 'grant  select, update, insert  on gw1.test_ota_min to '||Uname;
   EXECUTE IMMEDIATE v_statement ;
**/


 close c;

End;
/