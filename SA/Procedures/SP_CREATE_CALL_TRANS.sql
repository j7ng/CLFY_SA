CREATE OR REPLACE PROCEDURE sa."SP_CREATE_CALL_TRANS" (
   ip_esn IN VARCHAR2,
   ip_action_type IN VARCHAR2,
   ip_sourcesystem IN VARCHAR2,
   ip_sub_sourcesystem IN VARCHAR2,
   ip_reason IN VARCHAR2,
   ip_result IN VARCHAR2,
   ip_ota_req_type IN VARCHAR2,
   ip_ota_type IN VARCHAR2,
   op_calltranobj OUT NUMBER,
   op_err_code OUT VARCHAR2,
   op_err_msg OUT VARCHAR2
)
   IS
   p_esn table_part_inst.part_serial_no%TYPE := TRIM(ip_esn);
   p_action_type table_x_call_trans.x_action_type%TYPE := TRIM(ip_action_type);
   p_sub_sourcesystem table_x_call_trans.x_sub_sourcesystem%TYPE := TRIM(
   ip_sub_sourcesystem);
   p_sp_objid NUMBER;
   CURSOR c_pi(
      cp_part_serial_num VARCHAR2
   )
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = cp_part_serial_num;
   c_pi_esn_rec c_pi%ROWTYPE;
   CURSOR c_sp(
      cp_objid NUMBER
   )
   IS
   SELECT *
   FROM table_site_part
   WHERE objid = cp_objid;
   c_sp_rec c_sp%ROWTYPE;
   CURSOR c_pi_min(
      cpm_min VARCHAR2
   )
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = cpm_min;
   c_pi_min_rec c_pi_min%ROWTYPE;
   CURSOR c_code(
      cc_code_num VARCHAR2
   )
   IS
   SELECT *
   FROM table_x_code_table
   WHERE x_code_number = TRIM(cc_code_num);
   c_code_rec c_code%ROWTYPE;
   CURSOR c_user
   IS
   SELECT *
   FROM table_user
   WHERE s_login_name = USER;
   c_user_rec c_user%ROWTYPE;
   CURSOR c_dealer
   IS
   SELECT s.*
   FROM table_site s, table_inv_bin ib, table_part_inst pi
   WHERE 1 = 1
   AND ib.bin_name = s.site_id
   AND pi.part_inst2inv_bin = ib.objid
   AND pi.part_serial_no = p_esn;
   c_dealer_rec c_dealer%ROWTYPE;
BEGIN

   --Verify inputs
   OPEN c_pi (p_esn);
   FETCH c_pi
   INTO c_pi_esn_rec;
   CLOSE c_pi;
   IF c_pi_esn_rec.objid
   IS
   NULL
   THEN
      op_err_code := '1';
      op_err_msg := 'Invalid input: ESN not found.';
      RETURN;
   END IF;
   OPEN c_code (p_action_type);
   FETCH c_code
   INTO c_code_rec;
   CLOSE c_code;
   IF c_code_rec.objid
   IS
   NULL
   THEN
      op_err_code := '2';
      op_err_msg := 'Invalid input: action type '||p_action_type||' not found.'
      ;
      RETURN;
   END IF;
   OPEN c_sp (c_pi_esn_rec.x_part_inst2site_part);
   FETCH c_sp
   INTO c_sp_rec;
   CLOSE c_sp;
   IF c_sp_rec.objid
   IS
   NULL
   THEN
      op_err_code := '3';
      op_err_msg := 'Invalid site part for ESN '||p_esn;
      RETURN;
   END IF;
   OPEN c_pi (c_sp_rec.x_min);
   FETCH c_pi
   INTO c_pi_min_rec;
   CLOSE c_pi;
   IF c_pi_min_rec.objid
   IS
   NULL
   THEN
      op_err_code := '4';
      op_err_msg := 'Invalid MIN '||c_sp_rec.x_min;
      RETURN;
   END IF;
   c_code_rec := NULL;
   OPEN c_code (p_sub_sourcesystem);
   FETCH c_code
   INTO c_code_rec;
   CLOSE c_code;
   IF c_code_rec.objid
   IS
   NULL
   THEN
      op_err_code := '5';
      op_err_msg := 'Invalid input: x_sub_sourcesystem '||p_sub_sourcesystem||
      ' not found.';
      RETURN;
   END IF;
   OPEN c_user;
   FETCH c_user
   INTO c_user_rec;
   CLOSE c_user;
   OPEN c_dealer;
   FETCH c_dealer
   INTO c_dealer_rec;
   CLOSE c_dealer;
   sp_seq('x_call_trans', op_calltranobj);
   INSERT
   INTO table_x_call_trans(
      objid,
      call_trans2site_part,
      x_action_type,
      x_call_trans2carrier,
      x_call_trans2dealer,
      x_call_trans2user,
      x_min,
      x_service_id,
      x_sourcesystem,
      x_transact_date,
      x_total_units,
      x_action_text,
      x_reason,
      x_result,
      x_sub_sourcesystem,
      x_iccid, -- 07/07/2004 GP
	  x_ota_req_type,
	  x_ota_type
   )VALUES(
      op_calltranobj,
      c_pi_esn_rec.x_part_inst2site_part,
      p_action_type,
      c_pi_min_rec.part_inst2carrier_mkt,
      c_dealer_rec.objid,
      c_user_rec.objid,
      c_sp_rec.x_min,
      p_esn,
      ip_sourcesystem,
      SYSDATE,
      NULL,
      c_code_rec.x_code_name,
      ip_reason,
      ip_result,
      p_sub_sourcesystem,
      c_pi_esn_rec.x_iccid,
	  ip_ota_req_type,
	  ip_ota_type
   );
   COMMIT;
   op_err_code := '0';
   op_err_msg := 'Successful';
   EXCEPTION
   WHEN OTHERS
   THEN
      op_err_code := '99';
      op_err_msg := 'Unexpected error: '||SQLERRM;
END;
/