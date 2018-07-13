CREATE OR REPLACE procedure sa.check_trigger_prc is
cnt number :=0;
  SUBJECT_TXT1 VARCHAR2(100); --> cannot exceed 100
  MSG_FROM     VARCHAR2(200);
  SEND_TO    VARCHAR2(200);

  MESSAGE_TXT1 VARCHAR2(1000); --> cannot exceed 10,000
  OUT_RESULT   VARCHAR2(200);
  CURSOR c
  IS
    SELECT NAME FROM V$DATABASE;
  v_name varchar2(30);
begin

select count(*) into cnt from check_trigger;

if cnt >0
then
  Message_Txt1 := 'select * from check_trigger' ;
  MSG_FROM     := 'jtong@tracfone.com';
  SEND_TO     := 'jtong@tracfone.com';
  OPEN c;
  FETCH c INTO v_name;
  SUBJECT_TXT1 := 'Check Trigger in '||v_name;
  CLOSE c;
    SEND_MAIL( subject_txt1, msg_from, send_to, message_txt1, out_result );

  IF out_result IS NULL THEN
    out_result  := 'SUCCESS';
  END IF;
  DBMS_OUTPUT.PUT_LINE('RESULT = ' || OUT_RESULT);
end if;
end;
/