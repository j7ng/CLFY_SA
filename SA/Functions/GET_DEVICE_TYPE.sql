CREATE OR REPLACE FUNCTION sa."GET_DEVICE_TYPE" (
    p_esn IN VARCHAR2 )
  RETURN VARCHAR2
IS
  l_device_type VARCHAR2 (100);
BEGIN
  SELECT pcpv.device_type
  INTO l_device_type
  FROM table_part_inst pi,
    table_mod_level ml,
    table_part_num pn,
    pcpv_mv pcpv
  WHERE 1                     = 1
  AND pi.part_serial_no       = p_esn
  AND pi.x_domain             = 'PHONES'
  AND pi.n_part_inst2part_mod = ml.objid
  AND ml.part_info2part_num   = pn.objid
  AND pn.domain               = 'PHONES'
  AND pn.part_num2part_class  = pcpv.pc_objid;
  RETURN l_device_type;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END;
/