CREATE OR REPLACE FUNCTION sa."TRANSFORM_DEVICE_TYPE" ( p_device_type VARCHAR2,
                                                  p_esn         VARCHAR2 )
RETURN VARCHAR2 DETERMINISTIC
IS
  v_ret_val VARCHAR2(100);
BEGIN
    v_ret_val := p_device_type;

    IF p_device_type = 'MOBILE_BROADBAND' THEN
      SELECT p_device_type ||'_NONPPE' device_type
      INTO   v_ret_val
      FROM   TABLE_PART_INST pi,
             TABLE_MOD_LEVEL ml,
             TABLE_PART_NUM pn,
             PCPV_MV pcpv
      WHERE  1 = 1 AND
             pi.part_serial_no = p_esn AND
             pi.x_domain = 'PHONES' AND
             pi.n_part_inst2part_mod = ml.objid AND
             ml.part_info2part_num = pn.objid AND
             pn.domain = 'PHONES' AND
             pn.part_num2part_class = pcpv.pc_objid AND
             pcpv.non_ppe = '1';

    END IF;

    RETURN v_ret_val;

EXCEPTION
  WHEN OTHERS THEN
             RETURN v_ret_val;
END;
/