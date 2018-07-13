CREATE OR REPLACE FORCE VIEW sa.view_st_red_menu (job_data_id,x_request_type,x_request,ordinal) AS
SELECT
'201102011200000000',
'BPers611',
'<request><requestType>BPers611</requestType><lid>-1</lid><esn>'||pi.part_serial_no||'</esn><reason></reason><data1>0</data1><data2>1</data2><data3></data3><apexuser>SYSTEM</apexuser></request>',
0
FROM table_part_inst pi,
       table_mod_level ml,
       table_part_num pn,
       table_bus_org  bo,
       table_x_ota_features otaf
WHERE 1=1
   AND pi.x_domain||'' = 'PHONES'
  AND otaf.x_ota_features2part_inst = pi.objid
   AND pi.x_part_inst_status ||'' = '52'
   AND pi.n_part_inst2part_mod = ml.objid+0
   AND ml.part_info2part_num = pn.objid+0
   AND pn.PART_NUM2BUS_ORG = bo.objid
   AND bo.org_id = 'STRAIGHT_TALK'
   AND pn.x_technology = 'CDMA'
    AND otaf.x_redemption_menu <> 'Y'
    AND pi.warr_end_date > sysdate + 28
   AND pn.x_dll < 49
   AND ROWNUM < 5001;