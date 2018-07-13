CREATE OR REPLACE FORCE VIEW sa.btestdata (job_data_id,x_request_type,x_request,ordinal) AS
SELECT '201102041830167930','bcreatetestaccounts', '<request><requestType>bcreatetestaccounts</requestType><requestId/><esn>'||part_serial_no||'</esn>
<data1>125 Minutes Value Plan</data1><data2>TRACFONE</data2></request>',0
FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL, TABLE_PART_NUM
WHERE x_part_inst_status = '52'
AND x_domain = 'PHONES'
AND n_part_inst2part_mod = TABLE_MOD_LEVEL.objid
AND part_info2part_num = TABLE_PART_NUM.objid
AND TABLE_PART_NUM.part_number = 'TF1100P' /* Enter Part Number */
AND NOT EXISTS ( /* Exclude Esns with myaccounts */
  select web.objid from TABLE_X_CONTACT_PART_INST conpi,TABLE_WEB_USER web
  where conpi.x_contact_part_inst2part_inst = pi.objid 
  and web.web_user2contact = conpi.x_contact_part_inst2contact
)
AND NOT EXISTS (
  select (1) from TABLE_X_OTA_TRANSACTION 
  where x_esn = part_serial_no
)
AND ROWNUM <5
------------------- NET 10 Easy minutes--------------------------
union
SELECT '201102041830167930','bcreatetestaccounts', '<request><requestType>bcreatetestaccounts</requestType><requestId/><esn>'||part_serial_no||'</esn>
<data1>150 Minutes Value Plan</data1><data2>NET10</data2></request>',0
FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL, TABLE_PART_NUM
WHERE x_part_inst_status = '52'
AND x_domain = 'PHONES'
AND n_part_inst2part_mod = TABLE_MOD_LEVEL.objid
AND part_info2part_num = TABLE_PART_NUM.objid
AND TABLE_PART_NUM.part_number ='NTLG200CB' /* Enter Part Number */
AND NOT EXISTS ( /* Exclude Esns with myaccounts */
  select web.objid from TABLE_X_CONTACT_PART_INST conpi,TABLE_WEB_USER web
  where conpi.x_contact_part_inst2part_inst = pi.objid 
  and web.web_user2contact = conpi.x_contact_part_inst2contact
)
AND NOT EXISTS (
  select (1) from TABLE_X_OTA_TRANSACTION 
  where x_esn = part_serial_no
)
AND ROWNUM <5
------------------- NET 10 Mega Card Recurring -------------------------
union
SELECT '201102041830167930','bcreatetestaccounts', '<request><requestType>bcreatetestaccounts</requestType><requestId/><esn>'||part_serial_no||'</esn>
<data1>Net10 Mega Card</data1><data2>NET10</data2></request>',0
FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL, TABLE_PART_NUM
WHERE x_part_inst_status = '52'
AND x_domain = 'PHONES'
AND n_part_inst2part_mod = TABLE_MOD_LEVEL.objid
AND part_info2part_num = TABLE_PART_NUM.objid
AND TABLE_PART_NUM.part_number ='NTLG300GB' /* Enter Part Number */
AND NOT EXISTS ( /* Exclude Esns with myaccounts */
  select web.objid from TABLE_X_CONTACT_PART_INST conpi,TABLE_WEB_USER web
  where conpi.x_contact_part_inst2part_inst = pi.objid 
  and web.web_user2contact = conpi.x_contact_part_inst2contact
)
AND NOT EXISTS (
  select (1) from TABLE_X_OTA_TRANSACTION 
  where x_esn = part_serial_no
)
AND ROWNUM <5
------------------- NET 10 Mega Card Bundle --------------------------
union
SELECT '201102041830167930','bcreatetestaccounts', '<request><requestType>bcreatetestaccounts</requestType><requestId/><esn>'||part_serial_no||'</esn>
<data1>Net10 Mega Card Bundle</data1><data2>NET10</data2></request>',0
FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL, TABLE_PART_NUM
WHERE x_part_inst_status = '52'
AND x_domain = 'PHONES'
AND n_part_inst2part_mod = TABLE_MOD_LEVEL.objid
AND part_info2part_num = TABLE_PART_NUM.objid
AND TABLE_PART_NUM.part_number ='NTLG300GB' /* Enter Part Number */
AND NOT EXISTS ( /* Exclude Esns with myaccounts */
  select web.objid from TABLE_X_CONTACT_PART_INST conpi,TABLE_WEB_USER web
  where conpi.x_contact_part_inst2part_inst = pi.objid 
  and web.web_user2contact = conpi.x_contact_part_inst2contact
)
AND NOT EXISTS (
  select (1) from TABLE_X_OTA_TRANSACTION 
  where x_esn = part_serial_no
)
AND ROWNUM <5
------------------- Straight Talk Bundle --------------------------
union
SELECT '201102041830167930','bcreatetestaccounts', '<request><requestType>bcreatetestaccounts</requestType><requestId/><esn>'||part_serial_no||'</esn>
<data1>Straight Talk B</data1><data2>STRAIGHT_TALK</data2></request>',0
FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL, TABLE_PART_NUM
WHERE x_part_inst_status = '52'
AND x_domain = 'PHONES'
AND n_part_inst2part_mod = TABLE_MOD_LEVEL.objid
AND part_info2part_num = TABLE_PART_NUM.objid
AND TABLE_PART_NUM.part_number ='STLG620GB' /* Enter Part Number */
AND NOT EXISTS ( /* Exclude Esns with myaccounts */
  select web.objid from TABLE_X_CONTACT_PART_INST conpi,TABLE_WEB_USER web
  where conpi.x_contact_part_inst2part_inst = pi.objid 
  and web.web_user2contact = conpi.x_contact_part_inst2contact
)
AND NOT EXISTS (
  select (1) from TABLE_X_OTA_TRANSACTION 
  where x_esn = part_serial_no
)
AND ROWNUM <5
------------------- Straight Talk Recurring --------------------------
union
SELECT '201102041830167930','bcreatetestaccounts', '<request><requestType>bcreatetestaccounts</requestType><requestId/><esn>'||part_serial_no||'</esn>
<data1>Straight Talk</data1><data2>STRAIGHT_TALK</data2></request>',0
FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL, TABLE_PART_NUM
WHERE x_part_inst_status = '52'
AND x_domain = 'PHONES'
AND n_part_inst2part_mod = TABLE_MOD_LEVEL.objid
AND part_info2part_num = TABLE_PART_NUM.objid
AND TABLE_PART_NUM.part_number ='STLG620GB' /* Enter Part Number */
AND NOT EXISTS ( /* Exclude Esns with myaccounts */
  select web.objid from TABLE_X_CONTACT_PART_INST conpi,TABLE_WEB_USER web
  where conpi.x_contact_part_inst2part_inst = pi.objid 
  and web.web_user2contact = conpi.x_contact_part_inst2contact
)
AND NOT EXISTS (
  select (1) from TABLE_X_OTA_TRANSACTION 
  where x_esn = part_serial_no
)
AND ROWNUM <5
------------------- Safe Link--------------------------
union
SELECT '201102041830167930','bcreatetestaccounts', '<request><requestType>bcreatetestaccounts</requestType><requestId/><esn>'||part_serial_no||'</esn>
<data1>Lifeline - UT - 1</data1><data2>TRACFONE</data2></request>',0
FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL, TABLE_PART_NUM
WHERE x_part_inst_status = '52'
AND x_domain = 'PHONES'
AND n_part_inst2part_mod = TABLE_MOD_LEVEL.objid
AND part_info2part_num = TABLE_PART_NUM.objid
AND TABLE_PART_NUM.part_number ='TFLG300GP4' /* Enter Part Number */
AND NOT EXISTS ( /* Exclude Esns with myaccounts */
  select web.objid from TABLE_X_CONTACT_PART_INST conpi,TABLE_WEB_USER web
  where conpi.x_contact_part_inst2part_inst = pi.objid 
  and web.web_user2contact = conpi.x_contact_part_inst2contact
)
AND NOT EXISTS (
  select (1) from TABLE_X_OTA_TRANSACTION 
  where x_esn = part_serial_no
)
AND ROWNUM <5 ;