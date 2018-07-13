CREATE OR REPLACE FUNCTION sa."GET_SW_CR_FLAG" (
    ip_esn IN VARCHAR2 )
  RETURN VARCHAR2
AS
  v_device_type pcpv_mv.device_type%TYPE;
  v_pi_objid table_part_inst.objid%TYPE;
  v_parent_name  VARCHAR2(30);
  sw_flag        VARCHAR2(30);
  v_parent_exist NUMBER :=0;
BEGIN
  BEGIN
    SELECT pcpv.device_type ,
      pi.objid
    INTO v_device_type,
      v_pi_objid
    FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      pcpv_mv pcpv
    WHERE 1                     = 1
    AND pi.part_serial_no       = ip_esn
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.domain               = 'PHONES'
    AND pn.part_num2part_class  = pcpv.pc_objid;
  EXCEPTION
  WHEN OTHERS THEN
    v_device_type := NULL;
  END;
  IF (v_device_type IN ('BYOP','SMARTPHONE')) OR
     (v_device_type = 'FEATURE_PHONE' AND GET_DATA_MTG_SOURCE (ip_esn) <> 'PPE') THEN--Device type IF starts
    v_parent_name := util_pkg.get_parent_name(v_pi_objid);
    BEGIN
      SELECT COUNT(1)
      INTO v_parent_exist
      FROM table_x_parameters
      WHERE x_param_name LIKE 'SL_SW_READY%'
      AND x_param_value =v_parent_name;
    EXCEPTION
    WHEN OTHERS THEN
      v_parent_exist :=0 ;
    END;
    IF v_parent_exist >0 THEN
      sw_flag        :='SW_CR';
    ELSE
      sw_flag :=NULL;
    END IF;
  ELSIF v_device_type ='FEATURE_PHONE' THEN
    sw_flag          :=NULL;
  ELSE
    sw_flag :=NULL;
  END IF;--Device type IF ends
  RETURN sw_flag;
EXCEPTION
WHEN OTHERS THEN
  sw_flag :=NULL;
  RETURN sw_flag;
END;
/