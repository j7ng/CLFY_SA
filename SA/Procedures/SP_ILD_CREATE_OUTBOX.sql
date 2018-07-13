CREATE OR REPLACE PROCEDURE sa."SP_ILD_CREATE_OUTBOX" ( ip_esn              IN   VARCHAR2,
                                                   op_err_code         OUT  VARCHAR2,
                                                   op_err_msg          OUT  VARCHAR2 )
IS
 l_esn table_part_inst.part_serial_no%TYPE := trim(ip_esn);
 CURSOR C_ESN IS
   SELECT pi.part_serial_no esn, pi.objid esn_objid,
          pn.*
   FROM table_part_num pn, table_mod_level ml,
        table_part_inst pi
   WHERE 1=1
   AND ml.part_info2part_num=pn.objid
   AND pi.n_part_inst2part_mod=ml.objid
   AND pi.part_serial_no=l_esn;
 c_esn_rec c_esn%ROWTYPE;
 l_cnt NUMBER :=0;
BEGIN

  OPEN c_esn;
  FETCH c_esn INTO c_esn_rec;
  CLOSE c_esn;
  IF c_esn_rec.esn IS NULL THEN
    op_err_code := '1';
    op_err_msg := 'ESN: '||ip_esn||' is not valid.';
    RETURN;
  END IF;

  UPDATE table_x_psms_outbox u
  SET x_status='Canceled',
      x_last_update = sysdate
  WHERE u.x_esn = l_esn
  AND x_status='Pending';

  INSERT INTO table_x_psms_outbox (objid,x_seq,x_esn,x_command,
                                   x_status,x_creation_date, x_ild_type )
            SELECT sa.seq('x_psms_outbox'),
                   x_seq,
                   l_esn,
                   x_command,
                   'Pending',
                   sysdate,
                   x_ild_type
            FROM table_x_psms_template
            WHERE x_ild_type=c_esn_rec.x_ild_type;

  IF sql%rowcount = 0 THEN
    op_err_code := '2';
    op_err_msg := 'ESN: '||ip_esn||' does not have psms template. ';
    RETURN;
  END IF;

  UPDATE table_x_ota_features u
  SET x_ild_prog_status = 'InQueue'
  WHERE u.x_ota_features2part_inst=c_esn_rec.esn_objid;

  IF sql%rowcount = 0 then
      ROLLBACK;
      op_err_code := '3';
      op_err_msg := 'ESN: '||ip_esn||' does not have ota feature. ';
      RETURN;
  END IF;

  COMMIT;

  op_err_code := '0';
  op_err_msg := 'Successful';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    op_err_code := '99';
    op_err_msg := 'Unexpected error: '||sqlerrm;
END;
/