CREATE OR REPLACE FORCE VIEW sa.view_st_411 (job_data_id,x_request_type,x_request,ordinal) AS
SELECT '201109011200000000'
      ,'BPers611'
      ,'<request><requestType>BPers611</requestType><lid>-1</lid><esn>' || tpi.part_serial_no || '</esn><reason></reason><data1>0</data1><data2>15</data2><data3></data3><apexuser>SYSTEM</apexuser></request>'
      ,0
  FROM table_part_class tpc
  JOIN table_part_num tpn
    ON tpc.objid = tpn.part_num2part_class
  JOIN table_mod_level tml
    ON tpn.objid = tml.part_info2part_num
  JOIN table_part_inst tpi
    ON tml.objid = tpi.n_part_inst2part_mod
  JOIN table_x_ota_features xof
    ON tpi.objid = xof.x_ota_features2part_inst
  JOIN table_part_inst tpi_min
    ON tpi.objid = tpi_min.part_to_esn2part_inst
 WHERE tpc.name IN ('NTLGS100C'
                   ,'NTSAS451C'
                   ,'NTLGS220C'
                   ,'NTLGS290C'
                   ,'STSAR355C')
   AND tpi.x_part_inst_status = '52'
   AND NVL(xof.x_411_number
          ,'N') = 'N'
   AND NOT EXISTS (SELECT 1
          FROM table_x_ota_transaction xot
         WHERE xot.x_esn = tpi.part_serial_no
           AND UPPER(xot.x_status) <> 'OTA PENDING')
   AND tpi_min.part_serial_no NOT LIKE 'T%'
   AND ROWNUM <= 5000;