CREATE OR REPLACE FUNCTION sa."GET_SWITCHBASED_CREDIT_FLAG" ( ip_device_type     IN VARCHAR2 ,
                                                            ip_part_inst_objid IN NUMBER)
  RETURN VARCHAR2
AS
  v_device_type  pcpv_mv.device_type%TYPE;
  v_pi_objid     table_part_inst.objid%TYPE;
  v_parent_name  VARCHAR2(30);
  sw_flag        VARCHAR2(30);
  v_parent_exist NUMBER :=0;
  v_esn          table_part_inst.part_serial_no%TYPE := NULL;
BEGIN
  --
  -- CR42459 Check if Feature phone is PPE - GET_DATA_MTG_SOURCE
  --
  BEGIN
    --CR58413 - Modify query as we are passing ESN objid, in SL_MONTH_INSERT_ONE job, and not MIN as input param
    SELECT pi_esn.part_serial_no
      INTO v_esn
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.x_domain             = 'PHONES'
      AND  pi_esn.objid                = ip_part_inst_objid;

  EXCEPTION
  WHEN no_data_found THEN
    --CR58413 - If the ESN is not retrieved try and fetch by MIN
    BEGIN
      SELECT pi_esn.part_serial_no
        INTO v_esn
      FROM   table_part_inst pi_esn,
             table_part_inst pi_min
      WHERE  pi_esn.x_domain              = 'PHONES'
        AND  pi_min.part_to_esn2part_inst = pi_esn.objid
        AND  pi_min.x_domain              = 'LINES'
        AND  pi_min.objid                 = ip_part_inst_objid;
    EXCEPTION
    WHEN OTHERS THEN
      v_esn := NULL;
    END;
    --CR58413 End
  WHEN OTHERS THEN
    v_esn := NULL;
  END;

  IF (ip_device_type IN ('BYOP','SMARTPHONE')) OR
     (ip_device_type = 'FEATURE_PHONE' AND GET_DATA_MTG_SOURCE (v_esn) <> 'PPE')
  THEN--Device type IF starts
    v_parent_name := util_pkg.get_parent_name(ip_part_inst_objid);
    BEGIN
      SELECT COUNT(1)
        INTO v_parent_exist
      FROM   table_x_parameters
      WHERE  x_param_name LIKE 'SL_SW_READY%'
        AND  x_param_value = v_parent_name;
    EXCEPTION
    WHEN OTHERS THEN
      v_parent_exist := 0 ;
    END;
    --
    IF v_parent_exist > 0 THEN
      sw_flag := 'SW_CR';
    ELSE
      sw_flag := NULL;
    END IF;
  --ELSIF ip_device_type = 'FEATURE_PHONE' THEN sw_flag          :=NULL;
  ELSE
    sw_flag :=NULL;
  END IF;--Device type IF ends

  RETURN sw_flag;

EXCEPTION
WHEN OTHERS THEN
  sw_flag := NULL;
  RETURN sw_flag;
END;
/