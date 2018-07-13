CREATE OR REPLACE PROCEDURE sa.hnfcnt1
IS

v_objid  VARCHAR2(30):= '';
v_Name1 VARCHAR2(30):= 'Active';
v_num1  NUMBER := 0 ;
BEGIN

--DBMS_OUTPUT.PUT_LINE ('IN LOOP  '|| v_objid||'    '||to_char(i)) ;

SELECT COUNT(*)
       INTO v_Num1
  FROM table_site_part
  WHERE INSTANCE_NAME IN ('Wireless','wir', 'wire','wirele','WiRELESS','wireLESS')
    AND part_status = v_Name1;


DBMS_OUTPUT.PUT_LINE ('total count  '||to_char(v_Num1));

END ;
/