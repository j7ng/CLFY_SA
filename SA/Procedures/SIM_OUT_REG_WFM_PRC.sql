CREATE OR REPLACE PROCEDURE sa."SIM_OUT_REG_WFM_PRC" (
    i_sim             IN      VARCHAR2,
    i_login_name      IN      VARCHAR2,
	o_pseudo_esn      OUT     VARCHAR2,
    o_result_code     OUT     VARCHAR2,
    o_result_msg      OUT     VARCHAR2)
AS
--
/**********************************************************************************************/
/* */
/* Name : sim_out_reg_wfm_prc */
/* */
/* Purpose : Prepare legacy sims for activation as BYOP  */
/*           Migration exception case  */
/* VERSION DATE WHO PURPOSE */
/* ------- ---------- ----- -------------------------------------------- */
/* 1.0 Initial Revision */
/**********************************************************************************************/
--
  CURSOR sim_inv_cur
  IS
  SELECT pn.part_number
  FROM   sa.table_x_sim_inv si,
         sa.table_mod_level ml,
         sa.table_part_num pn
  WHERE  si.x_sim_serial_no     = trim(i_sim)
  AND    si.x_sim_inv_status    in ('253','180') --SIM NEW, MIGRATION
  AND    si.X_SIM_INV2PART_MOD  = ml.objid
  AND    ml.part_info2part_num  = pn.objid
  AND    pn.part_number in ('ZZZ260RMB','ZZZ260RMB2','ZZZ260RMB3','ZZZ260RMB4','ZZZ260RMB4N','ZZZ260RMB4TRIO',
		'WFM128PSIMT5N','WFM128PSIMT5TM','WFM128PSIMT5RM','WFM128PSIMT5DD','WFM128PSIMT5ND','WFM128PSIMT5TD');

  sim_inv_rec sim_inv_cur%rowtype;
  --
  CURSOR c_sim_status
  IS
  SELECT /*+ USE_INVISIBLE_INDEXES */
         x_sim_serial_no,
         x_sim_inv_status
  FROM   table_x_sim_inv sim
  WHERE  sim.x_sim_serial_no   = trim(i_sim);
  --
  sim_status_rec         c_sim_status%rowtype;
  --
  cursor c_pseudo_esn
  is
  select part_serial_no
  from table_part_inst
  where x_iccid = trim(i_sim)
  or (part_serial_no = substr(trim(i_sim),-15) and x_domain = 'PHONES');
  --
  pseudo_esn_rec         c_pseudo_esn%rowtype;
  --


  --
  v_esn                   VARCHAR2(30);
  v_hex                   VARCHAR2(30);
  v_esn_loaded            NUMBER  :=  0;
  v_luhn                  VARCHAR2(10);
  v_pi_Return             BOOLEAN;
  l_ig_status             VARCHAR2(100);
  l_vd_reqd               VARCHAR2(1);
  l_insert_call_trans     NUMBER  :=  0;
  l_calltranobj           table_x_call_trans.objid%TYPE;
  l_trans_id              gw1.ig_transaction.transaction_id%TYPE;
  l_error_txt             error_table.error_text%TYPE;
  l_action                error_table.action%TYPE;
  l_web_user_objid        table_web_user.objid%TYPE;
  l_error_code            VARCHAR2(20);
  l_error_msg             VARCHAR2(1000);

  --
BEGIN

  o_pseudo_esn:= '';

  OPEN c_sim_status;
  FETCH c_sim_status INTO sim_status_rec;
  IF c_sim_status%found AND sim_status_rec.x_sim_inv_status not in ('253','180')  THEN
    CLOSE c_sim_status;
    o_result_code:= '100';
    o_result_msg :='ERROR: SIM already in use';
    RETURN;
  ELSE
    CLOSE c_sim_status;
  END IF;
  --
  OPEN sim_inv_cur;
  FETCH sim_inv_cur INTO sim_inv_rec;
  IF sim_inv_cur%notfound THEN
    CLOSE sim_inv_cur;
    o_result_code:= '105';
    o_result_msg :='ERROR: SIM Not Found or Invalid Status';
    RETURN;
  ELSE
    CLOSE sim_inv_cur;
  END IF;
  --
  OPEN c_pseudo_esn;
  FETCH c_pseudo_esn INTO pseudo_esn_rec;
  IF c_pseudo_esn%found THEN
    CLOSE c_pseudo_esn;
	v_esn:= pseudo_esn_rec.part_serial_no;
    --o_result_code:= '110';
    --o_result_msg :='ERROR: Pseudo ESN already exists or SIM is already married';
    --RETURN;
  ELSE
    CLOSE c_pseudo_esn;
  END IF;
  --
  --
    if v_esn is null then
	v_esn := substr(i_sim,-15);
      INSERT INTO sa.table_part_inst
      (
        objid,
        part_serial_no,
        x_hex_serial_no,
        x_part_inst_status,
        x_sequence,
        x_po_num,
        x_red_code,
        x_order_number,
        x_creation_date,
        x_domain,
        n_part_inst2part_mod,
        part_inst2inv_bin,
        part_status,
        x_insert_date,
        status2x_code_table,
        last_pi_date,
        last_cycle_ct,
        next_cycle_ct,
        last_mod_time,
        last_trans_time,
        date_in_serv,
        repair_date,
        created_by2user,
        x_iccid
      )
      VALUES
      (
        sa.seq('part_inst'),
        upper(v_esn),
        null,
        '50',
        0,
        'WFM MIGRATION',
        NULL,
        NULL,
        SYSDATE,
        'PHONES',
        (SELECT objid from table_mod_level
         where part_info2part_num in (select objid from table_part_num where part_number = 'PHWFM128PSIMT5TD')),
        null,
        'Active',
        SYSDATE,
        986,
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        (SELECT objid FROM sa.table_user WHERE s_login_name = upper(i_login_name)
        ),
        trim(i_sim)
      );
    --
    v_pi_Return := sa.TOSS_UTIL_PKG.INSERT_PI_HIST_FUN( IP_PART_SERIAL_NO  => v_esn,
                                                       IP_DOMAIN          => 'PHONES',
                                                       IP_ACTION          => 'REGISTER WFM SIM' ,
                                                       IP_PROG_CALLER     => 'TAS');

    end if;

    UPDATE sa.table_x_sim_inv
    SET    x_sim_inv2part_mod =  (SELECT objid from table_mod_level
                                  where part_info2part_num in (select objid from table_part_num where part_number = 'WFM128PSIMT5TD')),
           x_sim_inv_status = '253',
           X_SIM_STATUS2X_CODE_TABLE = (select objid from table_x_code_table where x_code_number = '253')
    WHERE  x_sim_serial_no  = trim(i_sim);
    --

	update table_part_inst
	set x_iccid = trim(i_sim)
	where part_serial_no = v_esn
	and x_domain = 'PHONES';

  --
  COMMIT;
  --
  o_result_code:= '0';
  o_result_msg :='SUCCESS';
  o_pseudo_esn := v_esn;
  --
EXCEPTION
WHEN OTHERS THEN
  o_result_code:= '120';
  o_result_msg :='FAILED';

END sim_out_reg_wfm_prc;
/