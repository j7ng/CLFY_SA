CREATE OR REPLACE PROCEDURE sa."ASSIG_MIN"
(
PARAM1 IN VARCHAR2
, PARAM2 OUT VARCHAR2
) AS
----------- SIT Assignment MIN ***********************
l_num integer;
v_ESN VARCHAR2(30):= Param1;
BEGIN
----------- SIT Assignment MIN ***********************
--Random MIN
l_num := dbms_random.value(2000000,9999999);
Param2:=('786'||l_num);
if length(v_ESN) = 15 then
--GSM
UPDATE ig_transaction SET status = 'W', msid = Param2, new_msid_flag = 'Y'
WHERE action_item_id =(SELECT Max (action_item_id) FROM ig_transaction WHERE esn = v_esn);
else
--CDMA
UPDATE ig_transaction SET status = 'W', MIN = Param2, msid = Param2, new_msid_flag = 'Y'
WHERE action_item_id =(SELECT Max (action_item_id) FROM ig_transaction WHERE esn = v_esn);
end if;
update sa.table_x_ota_transaction set x_status = 'Completed' where X_ESN = v_ESN;
commit;
END ASSIG_MIN;
/