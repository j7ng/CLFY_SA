CREATE OR REPLACE FUNCTION sa."ADFCRM_ADD_ESN_TO_ACC" (
      ip_contact_objid VARCHAR2,
      ip_esn           VARCHAR2)
    RETURN VARCHAR2
  IS
    v_objid  NUMBER;
    v_result VARCHAR2(30):='FAILED';
    v_pi_objid number;

  BEGIN
    IF ip_contact_objid IS NOT NULL AND ip_esn IS NOT NULL THEN
      v_objid     := sa.seq('x_contact_part_inst');

      INSERT
      INTO sa.table_x_contact_part_inst
        (
          objid,
          x_contact_part_inst2contact,
          x_contact_part_inst2part_inst,
          x_esn_nick_name,
          x_is_default,
          x_transfer_flag,
          x_verified
        )
        VALUES
        (
          v_objid,
          ip_contact_objid,
          (select objid from sa.table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES'),
          NULL,1,0,'Y'
        );
        COMMIT;
      v_result:='SUCCESS';
    END IF;
    RETURN v_result;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN v_result;
  END;
/