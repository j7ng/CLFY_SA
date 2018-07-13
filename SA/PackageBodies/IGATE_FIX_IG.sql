CREATE OR REPLACE PACKAGE BODY sa.igate_fix_ig AS
  --
  CURSOR task_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_task WHERE objid = c_objid;
  --
  CURSOR case_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_case WHERE objid = c_objid;
  --
  CURSOR task2_curs(c_task_id IN NUMBER)
  IS
    SELECT * FROM table_task WHERE task_id = c_task_id;
  --
  CURSOR task3_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_task WHERE x_task2x_call_trans = c_objid;
  --
  CURSOR order_type_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_order_type WHERE objid = c_objid;
  --
  CURSOR trans_profile_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_trans_profile WHERE objid = c_objid;
  --
  CURSOR carrier_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_carrier WHERE objid = c_objid;
  --
  CURSOR carrier_group_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_carrier_group WHERE objid = c_objid;
  --
  CURSOR parent_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_parent WHERE objid = c_objid;
  --
  CURSOR call_trans_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_call_trans WHERE objid = c_objid;
  --
  CURSOR site_part_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_site_part WHERE objid = c_objid;
  --
  --CR20451 | CR20854: Add TELCEL Brand  added the org_flow 1 is TF 2 is NT 3 is ST and TC
  CURSOR part_num_curs(c_objid IN NUMBER)
  IS
    SELECT pn.* ,
      bo.org_id ,
      bo.org_flow
    FROM table_part_num pn ,
      table_mod_level ml ,
      table_bus_org bo
    WHERE pn.objid          = ml.part_info2part_num
    AND ml.objid            = c_objid
    AND pn.part_num2bus_org = bo.objid;
  --
  CURSOR user_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_user WHERE objid = c_objid;
  --
  CURSOR hr_curs(c_objid IN NUMBER)
  IS
    SELECT wh.*
    FROM table_work_hr wh ,
      table_wk_work_hr wwh
    WHERE wh.work_hr2wk_work_hr = wwh.objid
    AND wwh.objid               = c_objid;
  --
  CURSOR condition_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_condition WHERE objid = c_objid;
  --
  CURSOR queue_curs(c_title IN VARCHAR2)
  IS
    SELECT * FROM table_queue WHERE title = c_title;
  --
  CURSOR queue2_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_queue WHERE objid = c_objid;
  --
  CURSOR user2_curs(c_login_name IN VARCHAR2)
  IS
    SELECT * FROM table_user WHERE s_login_name = UPPER(c_login_name);
  --
  CURSOR employee_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_employee WHERE employee2user = c_objid;
  --
  CURSOR gbst_lst_curs(c_title IN VARCHAR2)
  IS
    SELECT * FROM table_gbst_lst WHERE title LIKE c_title;
  --
  CURSOR gbst_elm_curs ( c_objid IN NUMBER ,c_title IN VARCHAR2 )
  IS
    SELECT *
    FROM table_gbst_elm
    WHERE gbst_elm2gbst_lst = c_objid
    AND title LIKE c_title;
  --
  CURSOR gbst_elm_curs2(c_objid IN NUMBER)
  IS
    SELECT * FROM table_gbst_elm WHERE objid = c_objid;
  --
  CURSOR code_curs(c_code_name IN VARCHAR2)
  IS
    SELECT * FROM table_x_code_table WHERE x_code_name LIKE c_code_name;
  --
  CURSOR current_user_curs
  IS
    SELECT USER FROM dual;
  --
  /* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
  CURSOR provider_curs (c_objid IN NUMBER)
  IS
  SELECT *
  FROM TABLE_X_LD_PROVIDER
  WHERE objid = c_objid;
  --*/
  CURSOR part_inst_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_part_inst WHERE x_part_inst2site_part = c_objid;
  --
  CURSOR part_inst2_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_part_inst WHERE objid = c_objid;
  --
  CURSOR wipbin_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_wipbin WHERE wipbin_owner2user = c_objid;
  --
  /* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
  --  wipbin_rec wipbin_curs%rowtype;
  --    CURSOR contact6_curs (c_objid IN NUMBER)
  --    IS
  --       SELECT *
  --         FROM MTM_SITE_PART22_CONTACT6
  --        WHERE site_part2contact = c_objid;
  */
  --
  CURSOR contact_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_contact WHERE objid = c_objid;
  --
  CURSOR contact_role_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_contact_role WHERE contact_role2site = c_objid;
  --
  CURSOR site_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_site WHERE objid = c_objid;
  --
  CURSOR address_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_address WHERE objid = c_objid;
  --
  CURSOR site2_curs(c_objid IN NUMBER)
  IS
    SELECT S.*
    FROM table_site S ,
      table_inv_bin ib
    WHERE S.site_id = ib.bin_name
    AND ib.objid    = c_objid;
  --
  --/* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
  --    CURSOR click_plan_hist_curs (c_objid IN NUMBER)
  --    IS
  --       SELECT *
  --         FROM TABLE_X_CLICK_PLAN_HIST
  --        WHERE plan_hist2site_part = c_objid;
  --/* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
  --    CURSOR click_plan_curs (c_objid IN NUMBER)
  --    IS
  --       SELECT *
  --         FROM TABLE_X_CLICK_PLAN
  --        WHERE objid = c_objid;
  --
  /* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
  CURSOR account_hist_curs (c_objid IN NUMBER)
  IS
  SELECT *
  FROM TABLE_X_ACCOUNT_HIST
  WHERE account_hist2part_inst = c_objid;
  --
  CURSOR account_curs (c_objid IN NUMBER)
  IS
  SELECT *
  FROM TABLE_X_ACCOUNT
  WHERE objid = c_objid;
  --
  */
  --CR4981_4982 Start
  -- GSM2 START
  --    CURSOR carrier_features_curs (c_objid IN NUMBER, p_tech IN VARCHAR2)
  --    IS
  --     SELECT *
  --     FROM table_x_carrier_features
  --     WHERE x_feature2x_carrier = c_objid
  --     AND x_technology = p_tech;
  -- GSM2 END
  --cwl 6/20/11  CR15146 CR15144 CR15317
  CURSOR alt_carrier_features_curs(c_objid IN NUMBER)
  IS
    SELECT cf.*
    FROM table_x_carrier_features cf
    WHERE x_feature2x_carrier = c_objid;
  --cwl 6/20/11
  CURSOR carrier_features_curs ( c_objid IN NUMBER ,p_tech IN VARCHAR2 ,p_brand_name IN VARCHAR2 ,p_data IN NUMBER )
  IS
    SELECT cf.*
    FROM table_x_carrier_features cf ,
      table_bus_org bo
    WHERE x_feature2x_carrier = c_objid
    AND x_technology          = p_tech
    AND bo.objid              = cf.x_features2bus_org
    AND bo.org_id             = p_brand_name
    AND x_data                = nvl(p_data ,0);
  --CR4981_4982 End
  --CR4579
  CURSOR c_get_part_inst(c_serial_no IN VARCHAR2)
  IS
    SELECT * FROM table_part_inst WHERE part_serial_no = c_serial_no;
  -- CR4579 End
  /*
  -- SPRINT STARTS
  CURSOR get_parent_curs (c_objid IN NUMBER)
  IS
  SELECT p.*
  FROM TABLE_X_PARENT p, TABLE_X_CARRIER_GROUP g, TABLE_X_CARRIER c
  WHERE p.objid = g.x_carrier_group2x_parent
  AND g.objid = c.carrier2carrier_group
  AND c.objid = c_objid ;                   --p_x_call_trans2carrier;
  get_parent_rec            get_parent_curs%ROWTYPE;
  -- SPRINT ENDS
  */
  ----------------------------------------------------------------------------------------------------
PROCEDURE sp_create_action_item(
    p_contact_objid     IN NUMBER ,
    p_call_trans_objid  IN NUMBER ,
    p_order_type        IN VARCHAR2 ,
    p_bypass_order_type IN NUMBER ,
    p_case_code         IN NUMBER ,
    p_status_code OUT NUMBER ,
    p_action_item_objid OUT NUMBER )
IS
  ----------------------------------------------------------------------------------------------------
    --
    r_get_part_inst c_get_part_inst%rowtype; --CR4579
    call_trans_rec call_trans_curs%rowtype;
    site_part_rec site_part_curs%rowtype;
    part_inst_rec part_inst_curs%rowtype;
    site_rec site_curs%rowtype;
    part_num_rec part_num_curs%rowtype;
    user_rec user_curs%rowtype;
    user2_rec user2_curs%rowtype;
    gbst_lst1_rec gbst_lst_curs%rowtype;
    gbst_elm1_rec gbst_elm_curs%rowtype;
    gbst_lst2_rec gbst_lst_curs%rowtype;
    gbst_elm2_rec gbst_elm_curs%rowtype;
    gbst_lst3_rec gbst_lst_curs%rowtype;
    gbst_elm3_rec gbst_elm_curs%rowtype;
    gbst_lst4_rec gbst_lst_curs%rowtype;
    gbst_elm4_rec gbst_elm_curs%rowtype;
    wipbin_rec wipbin_curs%rowtype;
    current_user_rec current_user_curs%rowtype;
    employee_rec employee_curs%rowtype;
    contact_rec contact_curs%rowtype;
    carrier_rec carrier_curs%rowtype;
    carrier_group_rec carrier_group_curs%rowtype;
    l_order_type       VARCHAR2(100);
    boolupgrade        BOOLEAN;
    l_order_type_objid NUMBER;
    trans_profile_rec trans_profile_curs%rowtype;
    order_type_rec order_type_curs%rowtype;
    transstr          VARCHAR2(100);
    l_action_item_id  VARCHAR2(100);
    notesstr          VARCHAR2(1000);
    titlestr          VARCHAR2(1000):= NULL;
    l_condition_objid NUMBER;
    l_act_entry_objid NUMBER;
    l_task_objid      NUMBER;
    straddlinfo       VARCHAR2(1000);
    hold              NUMBER;
    hold2             VARCHAR2(200);
    cnt               NUMBER := 0;
    --
    -- OTA flag:
    --
    c_ota_type    VARCHAR2(30);
    l_tasktype_ot VARCHAR2(20); --SIMC FIX
    -- NET10_PAYGO STARTS
    l_is_st_esn NUMBER                                          := 0;
    l_cf_rate_plan sa.table_x_carrier_features.x_rate_plan%TYPE := '';
    l_ig_rate_plan sa.table_x_carrier_features.x_rate_plan%TYPE := '';
    l_cf_objid sa.table_x_carrier_features.objid%TYPE;
    l_new_template gw1.ig_transaction.TEMPLATE%TYPE := '-1';
    carr_feature_rec carrier_features_curs%rowtype;
    -- NET10_PAYGO ENDS
    CURSOR parent_curs_local(p_objid IN NUMBER)
    IS
      SELECT P.*
      FROM table_x_parent P ,
        table_x_carrier_group G ,
        table_x_carrier C
      WHERE P.objid = G.x_carrier_group2x_parent
      AND G.objid   = C.carrier2carrier_group
      AND C.objid   = p_objid; --p_x_call_trans2carrier;
    parent_rec parent_curs_local%rowtype;
    --EME to remove table_num_scheme ref
    new_act_id_format VARCHAR2(100) := NULL;
    --End EME
    --CR6103-2 Begin
    CURSOR c_dummy_data(c_esn IN VARCHAR2)
    IS
      SELECT x_esn FROM x_dummy_data WHERE x_esn = c_esn;
    rec_dummy_data c_dummy_data%rowtype;
    ----------------------------------------------------------------------------------------------------
BEGIN
--
  cnt := cnt + 1; --1
  dbms_output.put_line('cnt: call trans check initiated (return status 3 to FE if not found) : ' || cnt);
  OPEN call_trans_curs(p_call_trans_objid);
    FETCH call_trans_curs INTO call_trans_rec;
    IF call_trans_curs%notfound THEN
      p_status_code := 3;
      CLOSE call_trans_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'call_trans_curs%NOTFOUND',sysdate,'call_trans_curs('||p_call_trans_objid||')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE call_trans_curs;
  dbms_output.put_line('cnt:' || cnt || ' call_trans_rec.objid:' || call_trans_rec.objid);
  cnt := cnt + 1; --2
  dbms_output.put_line('cnt: site part check initiated (return if not found) : ' || cnt);
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
    FETCH site_part_curs INTO site_part_rec;
    IF site_part_curs%notfound THEN
      p_status_code := 3;
      CLOSE site_part_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'site_part_curs%NOTFOUND',sysdate,'site_part_curs('||call_trans_rec.call_trans2site_part||')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE site_part_curs;
  dbms_output.put_line('cnt:' || cnt || 'site part found, site_part_rec.objid:' || site_part_rec.objid);
  --Clean-up, removed the reference of these cursors contact6_curs, part_inst_curs from this part of the code Feb 01,2011, as it is already commented
  cnt := cnt + 1; --3
  dbms_output.put_line('cnt: site check initiated (return if not found) : ' || cnt);
    OPEN site_curs(site_part_rec.site_part2site);
    FETCH site_curs INTO site_rec;
    IF site_curs%notfound THEN
      p_status_code := 3;
      CLOSE site_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'site_curs%NOTFOUND',sysdate,'site_curs('||site_part_rec.site_part2site||')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE site_curs;
--
  OPEN c_get_part_inst(site_part_rec.x_service_id);
    FETCH c_get_part_inst INTO r_get_part_inst;
    IF c_get_part_inst%notfound THEN
      p_status_code := 3;
      CLOSE c_get_part_inst;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'c_get_part_inst%NOTFOUND',sysdate,'c_get_part_inst('||site_part_rec.x_service_id||')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE c_get_part_inst;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('cnt: part num check initiated (return if not found) : ' || cnt);
  OPEN part_num_curs(r_get_part_inst.n_part_inst2part_mod);
    FETCH part_num_curs INTO part_num_rec;
    IF part_num_curs%notfound THEN
      p_status_code := 3;
      CLOSE part_num_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'part_num_curs%NOTFOUND',sysdate,'part_num_curs('||r_get_part_inst.n_part_inst2part_mod||')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE part_num_curs;
  --Clean-up, removed the reference of these cursors click_plan_hist_curs, click_plan_curs from this part of the code Feb 01,2011, as it is already commented
  cnt := cnt + 1; --5
  dbms_output.put_line('cnt: user check initiated (return if not found) ' || cnt);
  OPEN user_curs(call_trans_rec.x_call_trans2user);
    FETCH user_curs INTO user_rec;
    IF user_curs%notfound THEN
      p_status_code := 3;
      CLOSE user_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'user_curs%NOTFOUND',sysdate,'user_curs('||call_trans_rec.x_call_trans2user||')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE user_curs;
  --Clean-up, removed the reference of these cursors task3_curs,account_hist_curs,  account_curs from this part of the code Feb 01,2011, as it is already commented
  cnt := cnt + 1; --6
  dbms_output.put_line('cnt: gbst lst (Activity Name) check initiated (return if not found) :  ' || cnt);
  OPEN gbst_lst_curs('Activity Name');
    FETCH gbst_lst_curs INTO gbst_lst4_rec;
    IF gbst_lst_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_lst_curs%NOTFOUND',sysdate,'gbst_lst_curs(''Activity Name'')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --7
  dbms_output.put_line('cnt: gbst elm (Create Action Item) check initiated (return if not found) : ' || cnt);
  OPEN gbst_elm_curs(gbst_lst4_rec.objid ,'Create Action Item');
    FETCH gbst_elm_curs INTO gbst_elm4_rec;
    IF gbst_elm_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_elm_curs%NOTFOUND',sysdate,'gbst_elm_curs('||gbst_lst4_rec.objid||' ,''Create Action Item'')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('cnt: gbst lst (Open Action Item) check initiated (return if not found) :' || cnt);
  OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst3_rec;
    IF gbst_lst_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_lst_curs%NOTFOUND',sysdate,'gbst_lst_curs(''Open Action Item'')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('cnt: gbst elm (Created) check initiated (return if not found) : ' || cnt);
  OPEN gbst_elm_curs(gbst_lst3_rec.objid ,'Created');
    FETCH gbst_elm_curs INTO gbst_elm3_rec;
    IF gbst_elm_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_elm_curs%NOTFOUND',sysdate,'gbst_elm_curs('||gbst_lst3_rec.objid||' ,''Create'')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('cnt: gbst lst (Task Type) check initiated (return if not found) ' || cnt);
  OPEN gbst_lst_curs('Task Type');
    FETCH gbst_lst_curs INTO gbst_lst2_rec;
    IF gbst_lst_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_lst_curs%NOTFOUND',sysdate,'gbst_lst_curs(''Task Type'')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('cnt: gbst elm (l_tasktype_ot) check initiated (return if not found) ' || cnt);
  IF p_order_type     = 'Return' THEN
    l_tasktype_ot    := 'Deactivation';
  ELSIF p_order_type IN ('SIMC' ,'EC' ,'SI') THEN
    l_tasktype_ot    := 'SIM Change';
  ELSIF p_order_type IN ('Act Payment Partial Buckets') THEN
    l_tasktype_ot    := 'Activation Payment';
  ELSIF p_order_type IN ('Partial Buckets') THEN
    l_tasktype_ot    := 'Credit';
  ELSE
    l_tasktype_ot := p_order_type;
  END IF;
  OPEN gbst_elm_curs(gbst_lst2_rec.objid ,l_tasktype_ot);
    FETCH gbst_elm_curs INTO gbst_elm2_rec;
    IF gbst_elm_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_elm_curs%NOTFOUND',sysdate,'gbst_elm_curs('||gbst_lst2_rec.objid||','||p_order_type||')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('cnt: gbst lst (Task Priority) check initiated (return if not found) ' || cnt);
  OPEN gbst_lst_curs('Task Priority');
    FETCH gbst_lst_curs INTO gbst_lst1_rec;
    IF gbst_lst_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_lst_curs%NOTFOUND',sysdate,'gbst_lst_curs(''Task Priority'')' ,p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('cnt: gbst elm (High) check initiated (return if not found)' || cnt);
  OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High');
    FETCH gbst_elm_curs INTO gbst_elm1_rec;
    IF gbst_elm_curs%notfound THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'gbst_elm_curs%NOTFOUND',sysdate,'gbst_elm_curs('||gbst_lst1_rec.objid||',''High'')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --14
  dbms_output.put_line('cnt: current user check initiated (assign appsrv user if not found) : ' || cnt);
  OPEN current_user_curs;
    FETCH current_user_curs INTO current_user_rec;
    IF current_user_curs%notfound THEN
      current_user_rec.USER := 'appsrv'; -- changed from appsvr
    END IF;
  CLOSE current_user_curs;
  dbms_output.put_line('cnt:' || cnt || ' current_user_rec.user:' || current_user_rec.USER);
  --
  cnt := cnt + 1; --15
  dbms_output.put_line('cnt: appsrv user check initiated (return if not found) : ' || cnt);
  OPEN user2_curs(current_user_rec.USER);
    FETCH user2_curs INTO user2_rec;
    IF user2_curs%notfound THEN
      p_status_code := 3;
      CLOSE user2_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'user2_curs%NOTFOUND',sysdate,'user2_curs('||current_user_rec.USER||')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE user2_curs;
  --
  cnt := cnt + 1; --16
  dbms_output.put_line('cnt: wipbin check initiated (return if not found) ' || cnt);
  OPEN wipbin_curs(user2_rec.objid);
    FETCH wipbin_curs INTO wipbin_rec;
    IF wipbin_curs%notfound THEN
      p_status_code := 3;
      CLOSE wipbin_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'wipbin_curs%NOTFOUND',sysdate,'wipbin_curs('||user2_rec.objid||')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE wipbin_curs;
  --
  cnt := cnt + 1; --17
  dbms_output.put_line('cnt: employee check initiated (return if not found) ' || cnt);
  OPEN employee_curs(user2_rec.objid);
    FETCH employee_curs INTO employee_rec;
    IF employee_curs%notfound THEN
      p_status_code := 3;
      CLOSE employee_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'employee_curs%NOTFOUND',sysdate,'employee_curs('||user2_rec.objid||')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE employee_curs;
  --
  cnt := cnt + 1; --18
  dbms_output.put_line('cnt: contact check initiated (return if not found) ' || cnt);
  OPEN contact_curs(p_contact_objid);
    FETCH contact_curs INTO contact_rec;
    IF contact_curs%notfound THEN
      p_status_code := 3;
      CLOSE contact_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'contact_curs%NOTFOUND',sysdate,'contact_curs('||p_contact_objid||')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE contact_curs;
  --
  cnt := cnt + 1; --19
  dbms_output.put_line('cnt: carrier check initiated (return if not found) ' || cnt);
    OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
    FETCH carrier_curs INTO carrier_rec;
    IF carrier_curs%notfound THEN
      p_status_code := 3;
      CLOSE carrier_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'carrier_curs%NOTFOUND',sysdate,'carrier_curs('||call_trans_rec.x_call_trans2carrier||')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE carrier_curs;
  --
  cnt := cnt + 1; --20
  dbms_output.put_line('cnt: carrier group check initiated (return if not found) ' || cnt);
  OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
    FETCH carrier_group_curs INTO carrier_group_rec;
    IF carrier_group_curs%notfound THEN
      p_status_code := 3;
      CLOSE carrier_group_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'carrier_group_curs%NOTFOUND',sysdate,'carrier_group_curs('||carrier_rec.carrier2carrier_group||')',p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
  CLOSE carrier_group_curs;
  --
  IF contact_rec.x_new_esn = call_trans_rec.x_service_id OR p_order_type = 'Suspend' THEN
    IF contact_rec.mdbk    = 'UPGRADE' THEN
      cnt := cnt + 1; --21
      dbms_output.put_line('cnt: gbst elm (High - Upgrade) check initiated (return if not found) : ' || cnt);
      OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High - Upgrade');
        FETCH gbst_elm_curs INTO gbst_elm1_rec;
        IF gbst_elm_curs%notfound THEN
          p_status_code := 3;
          CLOSE gbst_elm_curs;
          INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
          VALUES( 'gbst_elm_curs%NOTFOUND',sysdate,'gbst_elm_curs('||gbst_lst1_rec.objid||',''High - Upgrade'')',p_call_trans_objid,'igate.sp_create_action_item');
          RETURN;
        END IF;
      CLOSE gbst_elm_curs;
    END IF;
    IF p_order_type IN ('Activation' ,'ESN Change') THEN
      UPDATE table_contact
         SET x_new_esn = NULL ,
             mdbk        = NULL
       WHERE objid   = contact_rec.objid;
    END IF;
  END IF;
  --
  cnt := cnt + 1; --22
  dbms_output.put_line('cnt: get order type call initiated : ' || cnt);
  c_ota_type                  := NULL;
  --
  IF call_trans_rec.x_ota_type = ota_util_pkg.ota_activation THEN
    OPEN parent_curs_local(carrier_rec.objid);
      FETCH parent_curs_local INTO parent_rec;
      IF parent_curs_local%notfound THEN
        p_status_code := 3;
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES( 'parent_curs_local%NOTFOUND',sysdate,'parent_curs_local('||carrier_rec.objid||')' ,p_call_trans_objid,'igate.sp_create_action_item');
        CLOSE parent_curs_local;
        RETURN;
      ELSE
        IF UPPER(parent_rec.x_ota_carrier) = 'Y' THEN
          c_ota_type := ota_util_pkg.ota_queued;
        ELSE
          c_ota_type := substr('1NL' || carrier_rec.objid ,1 ,10);
        END IF;
      END IF;
    CLOSE parent_curs_local;
  END IF;
  dbms_output.put_line('c_ota_type:'||c_ota_type);
  cnt := cnt + 1; --27
  dbms_output.put_line('cnt:' || cnt || 'order_type_rec.X_ORDER_TYPE2X_TRANS_PROFILE:' || order_type_rec.x_order_type2x_trans_profile);
  --
  --ECR25704 create action item without order_type if bypass flag set
  sp_get_ordertype(site_part_rec.x_min ,p_order_type ,carrier_rec.objid ,part_num_rec.x_technology , l_order_type_objid);
  --
  IF l_order_type_objid IS NULL AND nvl(p_bypass_order_type,0) = 1 THEN
    titlestr := ' FAILED ' || UPPER(p_order_type) || ' FOR ' || UPPER(carrier_rec.x_mkt_submkt_name);
  ELSE
    p_status_code := 3;
    INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
    VALUES( 'l_order_type_objid is null',sysdate,'sp_get_ordertype('||site_part_rec.x_min||','||p_order_type||','||carrier_rec.objid||','||
             part_num_rec.x_technology||','|| l_order_type_objid||')' ,p_call_trans_objid,'igate.sp_create_action_item');
    RETURN;
  END IF;
    --
  cnt := cnt+1;
  dbms_output.put_line('cnt:' || cnt || 'l_order_type_objid:' || l_order_type_objid);
  OPEN order_type_curs(l_order_type_objid);
    FETCH order_type_curs INTO order_type_rec;
    IF order_type_curs%notfound AND nvl(p_bypass_order_type,0) = 1 THEN
      titlestr := ' FAILED ' || UPPER(p_order_type) || ' FOR ' || UPPER(carrier_rec.x_mkt_submkt_name);
    ELSIF order_type_curs%notfound THEN
      p_status_code := 3;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'order_type_curs%NOTFOUND',sysdate,'order_type_curs('||l_order_type_objid||')' ,p_call_trans_objid,'igate.sp_create_action_item');
      CLOSE order_type_curs;
      RETURN;
    END IF;
  CLOSE order_type_curs;
    --
  OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
    FETCH trans_profile_curs INTO trans_profile_rec;
    dbms_output.put_line('trans_profile_rec.objid:' || trans_profile_rec.objid);
    IF trans_profile_curs%found THEN
      IF trans_profile_rec.x_gsm_transmit_method IS NOT NULL THEN
        transstr := trans_profile_rec.x_gsm_transmit_method;
      ELSIF trans_profile_rec.x_d_transmit_method IS NOT NULL THEN
        transstr := trans_profile_rec.x_d_transmit_method;
      ELSIF trans_profile_rec.x_transmit_method IS NOT NULL THEN
        transstr := trans_profile_rec.x_transmit_method;
      ELSIF nvl(p_bypass_order_type,0) = 1 THEN
        transstr := NULL;
      ELSE
          p_status_code := 3;
          CLOSE trans_profile_curs;
          INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
          VALUES( 'all transmit methods are null',sysdate,'trans_profile_curs('||order_type_rec.x_order_type2x_trans_profile||')' ,
                   p_call_trans_objid,'igate.sp_create_action_item');
          RETURN;
      END IF;
    ELSIF trans_profile_curs%notfound AND nvl(p_bypass_order_type,0) = 1 THEN
      titlestr := ' FAILED ' || UPPER(p_order_type) || ' FOR ' || UPPER(carrier_rec.x_mkt_submkt_name);
      IF  p_order_type IN ('Return', 'Deactivation' ,'Suspend') AND nvl(p_bypass_order_type,0) =0 THEN
        p_status_code         := 2;
      ELSE
        p_status_code         := 1;
      END IF;
    ELSE
      CLOSE trans_profile_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'trans_profile_curs%NOTFOUND',sysdate,'trans_profile_curs('||order_type_rec.x_order_type2x_trans_profile||')' ,
              p_call_trans_objid,'igate.sp_create_action_item');
      RETURN;
    END IF;
    dbms_output.put_line('c_ota_type = ' || c_ota_type);
  CLOSE trans_profile_curs;
--
  cnt := cnt + 1; --26
  dbms_output.put_line('cnt: insert into TABLE_CONDITION initiated :' || cnt);
  cnt := cnt + 1; --27
  dbms_output.put_line('cnt: Build the Task Entry initiated :' || cnt);
  OPEN c_dummy_data(site_part_rec.x_service_id);
    FETCH c_dummy_data INTO rec_dummy_data;
    IF c_dummy_data%notfound THEN
      IF titlestr IS NULL THEN
        titlestr    := UPPER(carrier_rec.x_mkt_submkt_name) || ' ' || UPPER(p_order_type);
      END IF;
      notesstr := ':  ********** New Action Item *********** :' || CHR(10) || CHR(13) || ' ActionTitle:  ' || titlestr || CHR(10) || CHR(13) ||
                'Originator: ' || USER || CHR(10) || CHR(13) || ' Create Time: ' || sysdate;
      SELECT seq('condition') INTO l_condition_objid FROM dual;
      INSERT INTO table_condition
      (
        objid ,
        condition ,
        wipbin_time ,
        title ,
        s_title ,
        sequence_num
      )
      VALUES
      (
        l_condition_objid ,
        268435456 ,
        sysdate ,
        'Not Started' ,
        'NOT STARTED' ,
        0
      );
    --
      SELECT seq('task') INTO p_action_item_objid FROM dual;
      dbms_output.put_line('p_action_item_objid:' || p_action_item_objid);
      SELECT sa.sequ_action_item_id.NEXTVAL INTO l_action_item_id FROM dual;
      dbms_output.put_line('l_action_item_id:' || l_action_item_id);
  --
      INSERT INTO table_task
        (
          objid ,
          task_id ,
          s_task_id ,
          title ,
          s_title ,
          notes ,
          start_date ,
          x_original_method ,
          x_current_method ,
          x_queued_flag ,
          task_priority2gbst_elm ,
          task_sts2gbst_elm ,
          type_task2gbst_elm ,
          task2contact ,
          task_wip2wipbin ,
          x_task2x_call_trans ,
          task_state2condition ,
          task_originator2user ,
          task_owner2user ,
          x_task2x_order_type ,
          active ,
          x_ota_type
        )
        VALUES
        (
          p_action_item_objid ,
          l_action_item_id ,
          l_action_item_id ,
          titlestr || decode(p_case_code ,100 ,':CASE' ,NULL) ,
          UPPER(titlestr || decode(p_case_code ,100 ,':CASE' ,NULL)) ,
          notesstr ,
          sysdate ,
          transstr ,
          transstr ,
          '1' , -- hard code 1 as per alan reancianto 8/27/02
          -- in the cb code we had queued flag as 0 and 1
          -- since queued flag has been set to 1 the action item
          -- will no be sent to Intergate-Sent queue
          -- all items will be sent Intergate queue only
          gbst_elm1_rec.objid ,
          gbst_elm3_rec.objid ,
          gbst_elm2_rec.objid ,
          contact_rec.objid ,
          wipbin_rec.objid ,
          call_trans_rec.objid ,
          l_condition_objid ,
          user2_rec.objid ,
          user2_rec.objid ,
          order_type_rec.objid ,
          1 , --always 1
          c_ota_type
        );
        --
      IF titlestr LIKE 'FAILED%'  THEN
        sp_dispatch_task(l_task_objid ,'Line Management Re-work' ,hold);
      END IF;
    END IF;
  CLOSE c_dummy_data;
END sp_create_action_item;
  ----------------------------------------------------------------------------------------------------
  FUNCTION f_create_case(
      p_call_trans_objid IN NUMBER ,
      p_task_objid       IN NUMBER ,
      p_queue_name       IN VARCHAR2 ,
      p_type             IN VARCHAR2 ,
      p_title            IN VARCHAR2 )
    RETURN NUMBER
  IS
    l_case_objid NUMBER;
  BEGIN
    sp_create_case(p_call_trans_objid ,p_task_objid ,p_queue_name ,p_type ,p_title ,l_case_objid);
    RETURN l_case_objid;
  END;
  ----------------------------------------------------------------------------------------------------
PROCEDURE sp_create_case(
    p_call_trans_objid IN NUMBER ,
    p_task_objid       IN NUMBER ,
    p_queue_name       IN VARCHAR2 ,
    p_type             IN VARCHAR2 ,
    p_title            IN VARCHAR2 ,
    p_case_objid OUT NUMBER )
IS
  call_trans_rec call_trans_curs%rowtype;
  site_part_rec site_part_curs%rowtype;
  contact_rec contact_curs%rowtype;
  part_inst_rec part_inst_curs%rowtype;
  site_rec site_curs%rowtype;
  user_rec user_curs%rowtype;
  gbst_lst1_rec gbst_lst_curs%rowtype;
  gbst_elm1_rec gbst_elm_curs%rowtype;
  gbst_lst2_rec gbst_lst_curs%rowtype;
  gbst_elm2_rec gbst_elm_curs%rowtype;
  gbst_lst3_rec gbst_lst_curs%rowtype;
  gbst_elm3_rec gbst_elm_curs%rowtype;
  gbst_lst4_rec gbst_lst_curs%rowtype;
  gbst_elm4_rec gbst_elm_curs%rowtype;
  gbst_lst5_rec gbst_lst_curs%rowtype;
  gbst_elm5_rec gbst_elm_curs%rowtype;
  current_user_rec current_user_curs%rowtype;
  user2_rec user2_curs%rowtype;
  address_rec address_curs%rowtype;
  employee_rec employee_curs%rowtype;
  contact_role_rec contact_role_curs%rowtype;
  carrier_rec carrier_curs%rowtype;
  part_num_rec part_num_curs%rowtype;
  site2_rec site2_curs%rowtype;
  task_rec task_curs%rowtype;
  condition_rec condition_curs%rowtype;
  task_user_rec user_curs%rowtype;
  wipbin_rec wipbin_curs%rowtype;
  l_condition_objid NUMBER;
  l_case_objid      NUMBER;
  l_act_entry_objid NUMBER;
  l_case_id         VARCHAR2(30);
  hold              NUMBER;
  cnt               NUMBER := 0;
  --EME to remove table_num_scheme ref
  new_case_id_format VARCHAR2(100) := NULL;
  --EME to remove table_num_scheme ref
BEGIN
  --
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  OPEN call_trans_curs(p_call_trans_objid);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%notfound THEN
    CLOSE call_trans_curs;
    RETURN;
  END IF;
  CLOSE call_trans_curs;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%notfound THEN
    CLOSE site_part_curs;
    RETURN;
  END IF;
  CLOSE site_part_curs;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  --    open contact6_curs(site_part_rec.objid);
  --      fetch contact6_curs into contact6_rec;
  --      if contact6_curs%notfound then
  --        return;
  --      end if;
  --    close contact6_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_create_case:' || cnt || ' site_part_rec.objid:' || site_part_rec.objid);
  --
  --
  OPEN part_inst_curs(site_part_rec.objid);
  FETCH part_inst_curs INTO part_inst_rec;
  IF part_inst_curs%notfound THEN
    CLOSE part_inst_curs;
    RETURN;
  END IF;
  CLOSE part_inst_curs;
  --
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN site_curs(site_part_rec.site_part2site);
  FETCH site_curs INTO site_rec;
  IF site_curs%notfound THEN
    CLOSE site_curs;
    RETURN;
  END IF;
  CLOSE site_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN user_curs(call_trans_rec.x_call_trans2user);
  FETCH user_curs INTO user_rec;
  IF user_curs%notfound THEN
    CLOSE user_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user_curs;
  --
  cnt := cnt + 1; --7
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN address_curs(site_rec.cust_primaddr2address);
  FETCH address_curs INTO address_rec;
  IF address_curs%notfound THEN
    CLOSE address_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE address_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Response Priority Code');
  FETCH gbst_lst_curs INTO gbst_lst1_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High');
  FETCH gbst_elm_curs INTO gbst_elm1_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Case Type');
  FETCH gbst_lst_curs INTO gbst_lst2_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst2_rec.objid ,'Problem');
  FETCH gbst_elm_curs INTO gbst_elm2_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Not Started');
  FETCH gbst_lst_curs INTO gbst_lst3_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst3_rec.objid ,'Not Started');
  FETCH gbst_elm_curs INTO gbst_elm3_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --14
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%notfound THEN
    current_user_rec.USER := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  cnt := cnt + 1; --15
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN user2_curs(current_user_rec.USER);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%notfound THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  cnt := cnt + 1; --16
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN wipbin_curs(user2_rec.objid);
  FETCH wipbin_curs INTO wipbin_rec;
  IF wipbin_curs%notfound THEN
    CLOSE wipbin_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE wipbin_curs;
  --
  cnt := cnt + 1; --17
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst4_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --18
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst4_rec.objid ,'Create');
  FETCH gbst_elm_curs INTO gbst_elm4_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --19
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Problem Severity Level');
  FETCH gbst_lst_curs INTO gbst_lst5_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --20
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst5_rec.objid ,'High');
  FETCH gbst_elm_curs INTO gbst_elm5_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --21
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%notfound THEN
    CLOSE employee_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  cnt := cnt + 1; --22
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN contact_role_curs(site_rec.objid);
  FETCH contact_role_curs INTO contact_role_rec;
  IF contact_role_curs%notfound THEN
    CLOSE contact_role_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE contact_role_curs;
  --
  cnt := cnt + 1; --23
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN contact_curs(contact_role_rec.contact_role2contact);
  FETCH contact_curs INTO contact_rec;
  IF contact_curs%notfound THEN
    CLOSE contact_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE contact_curs;
  --
  cnt := cnt + 1; --24
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%notfound THEN
    CLOSE carrier_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE carrier_curs;
  --
  cnt := cnt + 1; --25
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN part_num_curs(site_part_rec.site_part2part_info);
  FETCH part_num_curs INTO part_num_rec;
  IF part_num_curs%notfound THEN
    CLOSE part_num_curs; --CR4579
    RETURN;
  END IF;
  CLOSE part_num_curs;
  --
  cnt := cnt + 1; --26
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN site2_curs(part_inst_rec.part_inst2inv_bin);
  FETCH site2_curs INTO site2_rec;
  IF site2_curs%notfound THEN
    CLOSE site2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE site2_curs;
  --
  cnt := cnt + 1; --27
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%notfound THEN
    CLOSE task_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  cnt := cnt + 1; --28
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%notfound THEN
    CLOSE condition_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  cnt := cnt + 1; --29
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN user_curs(task_rec.task_owner2user);
  FETCH user_curs INTO task_user_rec;
  IF user_curs%notfound THEN
    CLOSE user_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user_curs;
  --
  cnt := cnt + 1; --30
  dbms_output.put_line('sp_create_case:' || cnt || 'condition_Rec.title:' || condition_rec.title);
  --
  --
  /* If condition_Rec.title= 'Closed Action Item' AND
  p_Title <> 'Inactive Features' Then */
  --01/17/03
  IF condition_rec.title = 'Closed Action Item' AND p_title NOT IN ('Inactive Features' ,'Non Tracfone #') THEN
    RETURN;
  END IF;
  --
  cnt := cnt + 1;
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  --04/10/03 select seq_condition.nextval +(power(2,28)) into l_condition_objid from dual;
  SELECT seq('condition')
  INTO l_condition_objid
  FROM dual;
  --
  INSERT
  INTO table_condition
    (
      objid ,
      condition ,
      title ,
      wipbin_time ,
      sequence_num
    )
    VALUES
    (
      l_condition_objid ,
      2 ,
      'Open' ,
      sysdate ,
      0
    );
  --
  -- 04/10/03 select seq_case.nextval +(power(2,28)) into l_case_objid from dual;
  SELECT seq('case')
  INTO l_case_objid
  FROM dual;
  --
  p_case_objid := l_case_objid;
  --EME to remove table_num_scheme ref
  --
  --       SELECT     next_value
  --             INTO l_case_id
  --             FROM table_num_scheme
  --            WHERE NAME = 'Case ID'
  --       FOR UPDATE;
  --
  -- -- after you get it update the sequence
  --       UPDATE table_num_scheme
  --          SET next_value = next_value + 1
  --        WHERE NAME = 'Case ID';
  --
  --       COMMIT;
  --cwl CR12874
  SELECT sa.sequ_case_id.NEXTVAL
  INTO l_case_id
  FROM dual;
  --      sa.Next_Id ('Case ID', l_case_id, new_case_id_format);
  --cwl CR12874
  --EME to remove table_num_scheme ref
  --
  INSERT
  INTO table_case
    (
      objid ,
      x_case_type ,
      title ,
      s_title ,
      phone_num ,
      ownership_stmp ,
      modify_stmp ,
      id_number ,
      creation_time ,
      case_history ,
      x_carrier_id ,
      x_esn ,
      x_min ,
      x_carrier_name ,
      x_text_car_id ,
      x_phone_model ,
      x_retailer_name ,
      case2address ,
      case_reporter2site ,
      case_reporter2contact ,
      calltype2gbst_elm ,
      case_owner2user ,
      case_originator2user ,
      case_wip2wipbin ,
      casests2gbst_elm ,
      respprty2gbst_elm ,
      respsvrty2gbst_elm ,
      case_state2condition ,
      internal_case ,
      yank_flag
    )
    VALUES
    (
      l_case_objid ,
      p_type ,
      p_title ,
      UPPER(p_title) ,
      contact_rec.phone ,
      sysdate ,
      sysdate ,
      l_case_id ,
      --App.GenerateID("Case ID"),
      sysdate ,
      '*** CASE' ,
      carrier_rec.x_carrier_id ,
      site_part_rec.x_service_id ,
      site_part_rec.x_min ,
      carrier_rec.x_mkt_submkt_name ,
      to_char(carrier_rec.x_carrier_id) ,
      substr(part_num_rec.DESCRIPTION ,1 ,30) ,
      site2_rec.NAME ,
      address_rec.objid ,
      site_rec.objid ,
      contact_rec.objid ,
      gbst_elm2_rec.objid ,
      task_user_rec.objid ,
      task_user_rec.objid ,
      wipbin_rec.objid ,
      gbst_elm3_rec.objid ,
      gbst_elm1_rec.objid ,
      gbst_elm5_rec.objid ,
      l_condition_objid ,
      0 ,
      0
    );
  -- 04/10/03 select seq_act_entry.nextval +(power(2,28)) into l_act_entry_objid from dual;
  SELECT seq('act_entry')
  INTO l_act_entry_objid
  FROM dual;
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      act_entry2case ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      l_act_entry_objid ,
      600 ,
      sysdate ,
      ' Contact = '
      || contact_rec.first_name
      || ' '
      || contact_rec.last_name
      || ', Priority = '
      || gbst_elm1_rec.title
      || ', Status = '
      || gbst_elm3_rec.title
      || '.' ,
      l_case_objid ,
      user2_rec.objid ,
      gbst_elm4_rec.objid
    );
  --
/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  INSERT INTO table_time_bomb
     (objid ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      time_period ,
      flags ,
      cmit_creator2employee)
    VALUES
     (seq('time_bomb') ,
      SYSDATE - (365 * 10) ,
      SYSDATE ,
      l_case_objid ,
      0 ,
      l_act_entry_objid ,
      589826 ,
      employee_rec.objid);
*/
  --
  IF p_task_objid > 0 THEN
    sp_dispatch_case(l_case_objid ,p_queue_name ,hold);
  END IF;
  --
  p_case_objid := l_case_objid;
  COMMIT;
END sp_create_case;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_close_action_item
  (
    p_task_objid IN NUMBER ,
    p_status     IN NUMBER ,
    p_dummy_out OUT NUMBER
  )
IS
  gbst_elm_title VARCHAR2(100);
  gbst_elm_rec gbst_elm_curs%rowtype;
  gbst_elm2_rec gbst_elm_curs%rowtype;
  gbst_lst_rec gbst_lst_curs%rowtype;
  gbst_lst2_rec gbst_lst_curs%rowtype;
  user2_rec user2_curs%rowtype;
  current_user_rec current_user_curs%rowtype;
  task_rec task_curs%rowtype;
  condition_rec condition_curs%rowtype;
  employee_rec employee_curs%rowtype;
  queue2_rec queue2_curs%rowtype;
  act_entry_objid NUMBER;
  cnt             NUMBER := 0;
  -- OTA flag:
  c_ota_type table_task.x_ota_type%TYPE;
  -- Fail OTA transaction when IGATE transaction fails with status 3 (Failed - NTN)
PROCEDURE fail_ota_trans
  (
    p_x_task2x_call_trans IN NUMBER
  )
IS
  -- ------------------------------------ --
  -- "NTN" stands for Non Tracfone Number --
  -- ------------------------------------ --
  CURSOR x_code_hist_cur
  IS
    SELECT x_sequence
    FROM table_x_code_hist
    WHERE code_hist2call_trans = p_x_task2x_call_trans
    ORDER BY objid ASC;
  x_code_hist_rec x_code_hist_cur%rowtype;
  CURSOR x_call_trans_cur
  IS
    SELECT x_service_id ,
      x_min ,
      ROWID
    FROM table_x_call_trans
    WHERE objid = p_x_task2x_call_trans;
  x_call_trans_rec x_call_trans_cur%rowtype;
BEGIN
  -- 1) fail ota trans
  UPDATE table_x_ota_transaction
  SET x_status                   = 'Failed - NTN'
  WHERE x_ota_trans2x_call_trans = p_x_task2x_call_trans
  AND x_action_type              = '1'; -- activation
  -- 2) fail code hist
  OPEN x_code_hist_cur;
  FETCH x_code_hist_cur INTO x_code_hist_rec;
  IF x_code_hist_cur%found THEN
    UPDATE table_x_code_hist
    SET x_code_accepted        = 'Failed NTN'
    WHERE code_hist2call_trans = p_x_task2x_call_trans;
  END IF;
  CLOSE x_code_hist_cur;
  -- 3) fail call trans
  OPEN x_call_trans_cur;
  FETCH x_call_trans_cur INTO x_call_trans_rec;
  IF x_call_trans_cur%found THEN
    UPDATE table_x_call_trans
    SET x_result = 'Failed' ,
      x_reason   = 'Failed - NTN'
    WHERE ROWID  = x_call_trans_rec.ROWID;
  END IF;
  CLOSE x_call_trans_cur;
  -- 4) put the old sequence to ESN
  UPDATE table_part_inst
  SET x_sequence       = x_code_hist_rec.x_sequence
  WHERE part_serial_no = x_call_trans_rec.x_service_id
  AND x_domain         = 'PHONES';
  -- 5) update MIN as NTN so it will not be picked up again for any ESN
  UPDATE table_part_inst
  SET x_part_inst_status = '60' -- NTN
    ,
    last_trans_time     = sysdate ,
    status2x_code_table =
    (SELECT objid FROM table_x_code_table WHERE x_code_number = '60'
    )
  WHERE part_serial_no = x_call_trans_rec.x_min
  AND x_domain         = 'LINES';
  -- COMMIT is executed at the end of main procedure - sp_close_action_item
END fail_ota_trans;
--
BEGIN
  p_dummy_out := 1;
  SELECT decode(p_status ,0 ,'Succeeded' ,1 ,'Failed - Closed' ,2 ,'Failed - Retail ESN' ,3 ,'Failed - NTN')
  INTO gbst_elm_title
  FROM dual;
  -- set OTA flag:
  IF gbst_elm_title = 'Succeeded' THEN
    c_ota_type     := ota_util_pkg.ota_success;
  ELSE
    c_ota_type := ota_util_pkg.ota_failed;
  END IF;
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%notfound THEN
    current_user_rec.USER := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%notfound THEN
    p_dummy_out := 2; --no task found
    CLOSE task_curs;
    RETURN;
  END IF;
  CLOSE task_curs;
  -- handle Failed - NTN transactions for OTA:
  IF p_status = 3 AND task_rec.x_ota_type IS NOT NULL THEN
    fail_ota_trans(task_rec.x_task2x_call_trans);
  END IF;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || ' task_rec.task_state2condition:' || task_rec.task_state2condition);
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%notfound THEN
    p_dummy_out := 3; -- no condition found
    CLOSE condition_curs;
    RETURN;
  ELSE
    IF condition_rec.title = 'Closed Action Item' THEN
      CLOSE condition_curs;
      RETURN;
    END IF;
  END IF;
  CLOSE condition_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN user2_curs(current_user_rec.USER);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%notfound THEN
    CLOSE user2_curs;
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || ' task_rec.task_currq2queue:' || task_rec.task_currq2queue);
  --
  --    open queue2_curs(task_rec.task_currq2queue);
  --      fetch queue2_curs into queue2_rec;
  --      if queue2_curs%notfound then
  --        return;
  --      end if;
  --    close queue2_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN gbst_lst_curs('Closed Action Item');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%notfound THEN
    p_dummy_out := 4; --no gbst_lst found
    CLOSE gbst_lst_curs;
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --7
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || 'gbst_lst_rec.objid,gbst_elm_title:' || gbst_lst_rec.objid || ':' || gbst_elm_title);
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,gbst_elm_title);
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%notfound THEN
    p_dummy_out := 5; --no gbst_elm found
    CLOSE gbst_elm_curs;
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('gbst_elm_rec.objid:' || gbst_elm_rec.objid);
  dbms_output.put_line('gbst_elm_rec.title:' || gbst_elm_rec.title);
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst2_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs;
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || ' gbst_lst_rec.objid:' || gbst_lst_rec.objid);
  --
  OPEN gbst_elm_curs(gbst_lst2_rec.objid ,'Close Action Item');
  FETCH gbst_elm_curs INTO gbst_elm2_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs;
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%notfound THEN
    p_dummy_out := 6; --no employee record found
    CLOSE employee_curs;
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  UPDATE table_condition
  SET condition  = 8192 ,
    wipbin_time  = sysdate ,
    title        = 'Closed Action Item' ,
    s_title      = 'CLOSED ACTION ITEM' ,
    sequence_num = 0
  WHERE objid    = condition_rec.objid;
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  dbms_output.put_line('gbst_elm_rec.objid:' || gbst_elm_rec.objid);
  dbms_output.put_line('gbst_elm_rec.title:' || gbst_elm_rec.title);
  UPDATE table_task
  SET comp_date       = sysdate ,
    active            = 1 ,
    task_sts2gbst_elm = gbst_elm_rec.objid ,
    task_wip2wipbin   = NULL ,
    task_currq2queue  = NULL ,
    -- set OTA type
    x_ota_type = c_ota_type
  WHERE objid  = task_rec.objid;
  -- OTA x_status update
  -- UPDATE table_x_ota_transaction SET x_status to value 'OTA SEND'
  -- Java program will be looking for this value in this table every 30 seconds
  -- to send activation PSMS message to the phone over the air
  IF c_ota_type = ota_util_pkg.ota_success THEN
    -- We want to make sure to update our OTA transaction
    -- only if it is not completed yet
    -- If IGATE process was too late and didn't finish on time
    -- but in the mean time customer called and our transaction was completed by the
    -- WEBSCR or IVR we don't want to update that traqnsaction here
    UPDATE table_x_ota_transaction
    SET x_status                   = ota_util_pkg.ota_send
    WHERE x_ota_trans2x_call_trans = task_rec.x_task2x_call_trans
    AND UPPER(x_status)           <> 'COMPLETED';
  END IF;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  -- 04/10/03 select seq_act_entry.nextval +(power(2,28))
  SELECT seq('act_entry')
  INTO act_entry_objid
  FROM dual;
  --
  cnt := cnt + 1; --14
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      removed ,
      focus_type ,
      focus_lowid ,
      act_entry2task ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      act_entry_objid ,
      332871994 ,
      sysdate ,
      'Closed at '
      || sysdate ,
      0 ,
      5080 ,
      task_rec.objid ,
      task_rec.objid ,
      user2_rec.objid ,
      gbst_elm_rec.objid
    );
  --
/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  INSERT INTO table_time_bomb
     (objid ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      time_period ,
      flags ,
      left_repeat ,
      cmit_creator2employee)
    VALUES
     (seq('time_bomb') ,
      TO_DATE('01/01/1753' ,'dd/mm/yyyy') ,
      SYSDATE ,
      task_rec.objid ,
      5080 ,
      act_entry_objid ,
      333053954 ,
      0 ,
      employee_rec.objid);
*/
  --
  COMMIT;
END sp_close_action_item;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_dispatch_task
  (
    p_task_objid IN NUMBER ,
    p_queue_name IN VARCHAR2 ,
    p_dummy_out OUT NUMBER
  )
IS
  user_rec user_curs%rowtype;
  l_queue_name      VARCHAR2(100) := p_queue_name;
  l_queue_objid     NUMBER;
  l_act_entry_objid NUMBER;
  current_user_rec current_user_curs%rowtype;
  task_rec task_curs%rowtype;
  condition_rec condition_curs%rowtype;
  queue_rec queue_curs%rowtype;
  queue_rec2 queue_curs%rowtype;
  code_rec code_curs%rowtype;
  user2_rec user2_curs%rowtype;
  employee_rec employee_curs%rowtype;
  gbst_lst_rec gbst_lst_curs%rowtype;
  gbst_elm_rec gbst_elm_curs%rowtype;
  --new
  gbst_elm2_rec gbst_elm_curs2%rowtype;
  gbst_elm2_rec2 gbst_elm_curs2%rowtype;
  queue2_rec2 queue2_curs%rowtype;
  queue2_rec3 queue2_curs%rowtype;
  part_num_rec part_num_curs%rowtype;
  call_trans_rec call_trans_curs%rowtype;
  parent_rec parent_curs%rowtype;
  carrier_group_rec carrier_group_curs%rowtype;
  carrier_rec carrier_curs%rowtype;
  site_part_rec site_part_curs%rowtype;
  strtechnology VARCHAR2(100);
  boolholddeac  BOOLEAN;
  ------------------------------------------------
  CURSOR part_inst3_curs(c_min IN VARCHAR2)
  IS
    SELECT * FROM table_part_inst WHERE part_serial_no = c_min;
  part_inst3_rec part_inst3_curs%rowtype;
  ------------------------------------------------
  CURSOR esn_call_trans_curs(c_esn IN VARCHAR2)
  IS
    SELECT *
    FROM table_x_call_trans
    WHERE x_service_id = c_esn
      --03/17/03 Clarify Upgrade refurbished phone
      --or x_service_id = c_esn||'R')
    AND x_action_type = '99'
    ORDER BY x_transact_date DESC;
  esn_call_trans_rec esn_call_trans_curs%rowtype;
  esn_task_rec task_curs%rowtype;
  esn_curr_queue_rec queue2_curs%rowtype;
  esn_prev_queue_rec queue2_curs%rowtype;
  part_inst_rec part_inst_curs%rowtype;
  part_inst2_rec part_inst2_curs%rowtype;
  hold       NUMBER;
  cnt        NUMBER := 0;
  temp_queue BOOLEAN;
BEGIN
  p_dummy_out := 1;
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%notfound THEN
    current_user_rec.USER := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  IF l_queue_name = 'Please Specify' THEN
    l_queue_name := 'Line Activation NoOrdTyp';
  END IF;
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN queue_curs(l_queue_name);
  FETCH queue_curs INTO queue_rec;
  IF queue_curs%found THEN
    l_queue_objid := queue_rec.objid;
    CLOSE queue_curs;
  ELSE
    CLOSE queue_curs;
    OPEN code_curs('DEFAULT QUEUE');
    FETCH code_curs INTO code_rec;
    IF code_curs%notfound THEN
      CLOSE code_curs;
      RETURN;
    ELSE
      OPEN queue_curs(code_rec.x_text);
      FETCH queue_curs INTO queue_rec2;
      IF queue_curs%notfound THEN
        CLOSE queue_curs;
        CLOSE code_curs;
        RETURN;
      ELSE
        l_queue_objid := queue_rec2.objid;
      END IF;
      CLOSE queue_curs;
    END IF;
    CLOSE code_curs;
  END IF;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%notfound THEN
    CLOSE task_curs;
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%notfound THEN
    CLOSE condition_curs;
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  IF condition_rec.title = 'Closed Action Item' THEN
    RETURN;
  END IF;
  --
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN call_trans_curs(task_rec.x_task2x_call_trans);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%notfound THEN
    CLOSE call_trans_curs;
    RETURN;
  END IF;
  CLOSE call_trans_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' call_trans_rec.x_service_id:' || call_trans_rec.x_service_id);
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' call_trans_rec.x_min:' || call_trans_rec.x_min);
  --
  OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%notfound THEN
    CLOSE carrier_curs;
    RETURN;
  END IF;
  CLOSE carrier_curs;
  --
  cnt := cnt + 1; --7
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
  FETCH carrier_group_curs INTO carrier_group_rec;
  IF carrier_group_curs%notfound THEN
    CLOSE carrier_group_curs;
    RETURN;
  END IF;
  CLOSE carrier_group_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN parent_curs(carrier_group_rec.x_carrier_group2x_parent);
  FETCH parent_curs INTO parent_rec;
  IF parent_curs%notfound THEN
    CLOSE parent_curs;
    RETURN;
  END IF;
  CLOSE parent_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN queue2_curs(parent_rec.x_parent2temp_queue);
  FETCH queue2_curs INTO queue2_rec2;
  IF queue2_curs%notfound THEN
    temp_queue := FALSE;
  ELSE
    temp_queue := TRUE;
  END IF;
  CLOSE queue2_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%notfound THEN
    CLOSE site_part_curs;
    RETURN;
  END IF;
  CLOSE site_part_curs;
  --
  dbms_output.put_line('sp_dispatch_task a:' || cnt || ' site_part_rec.objid:' || site_part_rec.objid);
  --
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  OPEN part_inst_curs(site_part_rec.objid);
  FETCH part_inst_curs INTO part_inst_rec;
  --      if part_inst_curs%notfound then
  --        close part_inst_curs;
  --        return;
  --      end if;
  CLOSE part_inst_curs;
  --
  dbms_output.put_line('sp_dispatch_task b:' || cnt);
  --
  OPEN part_inst2_curs(part_inst_rec.part_to_esn2part_inst);
  FETCH part_inst2_curs INTO part_inst2_rec;
  --      if part_inst2_curs%notfound then
  --        close part_inst2_curs;
  --        return;
  --      end if;
  CLOSE part_inst2_curs;
  -- new code cwl oct 2 2002
  OPEN part_inst3_curs(site_part_rec.x_min);
  FETCH part_inst3_curs INTO part_inst2_rec;
  CLOSE part_inst3_curs;
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  --
  dbms_output.put_line('sp_dispatch_task c:' || cnt);
  --
  --CR4579
  IF part_num_curs%isopen THEN
    CLOSE part_num_curs;
  END IF;
  OPEN part_num_curs(site_part_rec.site_part2part_info);
  FETCH part_num_curs INTO part_num_rec;
  IF part_num_curs%notfound THEN
    CLOSE part_num_curs;
    RETURN;
  END IF;
  CLOSE part_num_curs;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' task_rec.task_currq2queue:' || task_rec.task_currq2queue);
  --
  OPEN queue2_curs(task_rec.task_currq2queue);
  FETCH queue2_curs INTO queue2_rec3;
  --      if queue2_curs%notfound then
  --        close queue2_curs;
  --        return;
  --      end if;
  CLOSE queue2_curs;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' task_rec.task_currq2queue:' || task_rec.task_currq2queue);
  --
  OPEN gbst_elm_curs2(task_rec.task_currq2queue);
  FETCH gbst_elm_curs2 INTO gbst_elm2_rec;
  --      if gbst_elm_curs2%notfound then
  --        close gbst_elm_curs2;
  --        return;
  --      end if;
  CLOSE gbst_elm_curs2;
  --
  --
  OPEN gbst_elm_curs2(task_rec.type_task2gbst_elm);
  FETCH gbst_elm_curs2 INTO gbst_elm2_rec2;
  IF gbst_elm_curs2%notfound THEN
    CLOSE gbst_elm_curs2;
    RETURN;
  END IF;
  CLOSE gbst_elm_curs2;
  --
  cnt := cnt + 1; --14
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  --
  --------Detrmine Technology
  --    strTechnology = Part_Num_rec.x_technology;
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  --    if Parent_rec.x_hold_digital_deac=1 and Part_Num_rec.x_technology <> 'ANALOG' then
  --dbms_output.put_line('sp_dispatch_task:'||'digital bool true and x_tech != ANALOG');
  --      boolHoldDeac := True;
  --    end if;
  --    if Parent_rec.x_hold_analog_deac=1 and Part_Num_rec.x_technology = 'ANALOG' then
  --dbms_output.put_line('sp_dispatch_task:'||'analog bool true and x_tech != ANALOG');
  --      boolHoldDeac := True;
  --    end if;
  --
  --if boolholddeac = true then
  --  dbms_output.put_line('boolholddeac:true');
  --else
  --  dbms_output.put_line('boolholddeac:false');
  --end if;
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  dbms_output.put_line('Call_Trans_rec.x_action_type:' || call_trans_rec.x_action_type);
  dbms_output.put_line('Queue2_rec2.title :' || queue2_rec2.title);
  dbms_output.put_line('Queue2_rec3.title :' || queue2_rec3.title);
  dbms_output.put_line('gbst_elm2_rec2.title :' || gbst_elm2_rec2.title);
  IF
    -- new cursors for 9/27
    --       boolHoldDeac and
    temp_queue AND part_inst2_rec.x_part_inst_status IN ('37' ,'39') AND call_trans_rec.x_action_type = '99' AND nvl(queue2_rec2.title ,'1') <> nvl(queue2_rec3.title ,'2') AND gbst_elm2_rec2.title IN ('Suspend' ,'Deactivation') THEN
    dbms_output.put_line('update_task');
    UPDATE table_task
    SET task_prevq2queue = l_queue_objid
    WHERE objid          = task_rec.objid;
    --
    l_queue_objid := queue2_rec2.objid;
    --
  ELSIF temp_queue AND call_trans_rec.x_action_type IN ('1' ,'3') THEN
    dbms_output.put_line('don t update_task 1');
    OPEN esn_call_trans_curs(call_trans_rec.x_service_id);
    FETCH esn_call_trans_curs INTO esn_call_trans_rec;
    IF esn_call_trans_curs%found THEN
      -------------------------------------------------------------------
      CLOSE esn_call_trans_curs;
      dbms_output.put_line('don t update_task 2');
      OPEN task3_curs(esn_call_trans_rec.objid);
      FETCH task3_curs INTO esn_task_rec;
      IF task3_curs%notfound THEN
        CLOSE task3_curs;
      ELSE
        CLOSE task3_curs;
        dbms_output.put_line('don t update_task 3');
        OPEN queue2_curs(esn_task_rec.task_currq2queue);
        FETCH queue2_curs INTO esn_curr_queue_rec;
        CLOSE queue2_curs;
        dbms_output.put_line('don t update_task 4');
        OPEN queue2_curs(esn_task_rec.task_prevq2queue);
        FETCH queue2_curs INTO esn_prev_queue_rec;
        CLOSE queue2_curs;
        dbms_output.put_line('don t update_task 5');
        dbms_output.put_line('don t update_task: Queue2_rec2.title:' || queue2_rec2.title);
        dbms_output.put_line('don t update_task: esn_curr_queue_rec.title:' || esn_curr_queue_rec.title);
        IF queue2_rec2.title = esn_curr_queue_rec.title THEN
          dbms_output.put_line('don t update_task: call_trans_rec.x_min:' || TRANSLATE(call_trans_rec.x_min ,' ' ,'*'));
          dbms_output.put_line('don t update_task: esn_call_trans_rec.x_min:' || TRANSLATE(esn_call_trans_rec.x_min ,' ' ,'*'));
          IF LTRIM(RTRIM(call_trans_rec.x_min)) = LTRIM(RTRIM(esn_call_trans_rec.x_min)) THEN
            dbms_output.put_line('don t update_task:sp_Close_Action_Item');
            sp_close_action_item(esn_task_rec.objid ,0 ,hold);
            sp_close_action_item(p_task_objid ,0 ,hold);
            COMMIT;
            RETURN;
          END IF;
        ELSE
          dbms_output.put_line('don t update_task:sp_Dispatch_Task');
          sp_dispatch_task(esn_task_rec.objid ,esn_prev_queue_rec.title ,hold);
        END IF;
      END IF;
    ELSE
      CLOSE esn_call_trans_curs;
    END IF;
  END IF;
  ----------------NEG END
  --
  cnt := cnt + 1; --15
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  --
  OPEN user2_curs(current_user_rec.USER);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%notfound THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  cnt := cnt + 1; --16
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%notfound THEN
    CLOSE employee_curs; --CR4579
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  cnt := cnt + 1; --17
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --CR4579
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --18
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Dispatch');
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --CR4579
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --19
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  UPDATE table_condition
  SET condition = 536870920 ,
    title       = 'Open Action Item-Dispatch' ,
    s_title     = 'OPEN ACTION ITEM-DISPATCH'
  WHERE objid   = condition_rec.objid;
  --
  IF condition_rec.queue_time IS NULL THEN
    UPDATE table_condition
    SET queue_time = sysdate
    WHERE objid    = condition_rec.objid;
  END IF;
  --
  UPDATE table_task
  SET task_currq2queue = l_queue_objid
  WHERE objid          = task_rec.objid;
  --
  -- 04/10/03 select SEQ_ACT_ENTRY.nextval +(power(2,28)) into l_act_entry_objid from dual;
  SELECT seq('act_entry')
  INTO l_act_entry_objid
  FROM dual;
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      proxy ,
      removed ,
      focus_lowid ,
      act_entry2task ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      l_act_entry_objid ,
      900 ,
      sysdate ,
      'Dispatched to Queue '
      || l_queue_name
      || '.' ,
      current_user_rec.USER ,
      0 ,
      task_rec.objid ,
      task_rec.objid ,
      user2_rec.objid ,
      gbst_elm_rec.objid
    );
  --
/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  INSERT INTO table_time_bomb
     (objid ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      time_period ,
      flags ,
      left_repeat ,
      cmit_creator2employee)
    VALUES
     (seq('time_bomb') ,
      TO_DATE('01/01/1753' ,'dd/mm/yyyy') ,
      SYSDATE ,
      task_rec.objid ,
      5080 ,
      l_act_entry_objid ,
      655362 ,
      0 ,
      employee_rec.objid);
*/
  --
  COMMIT;
END sp_dispatch_task;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_determine_trans_method
  (
    p_action_item_objid IN NUMBER ,
    p_order_type        IN VARCHAR2 ,
    p_trans_method      IN VARCHAR2 ,
    p_destination_queue OUT NUMBER ,
    p_application_system IN VARCHAR2 DEFAULT 'IG' -- GSM Enhancement
  )
IS
  r_get_part_inst c_get_part_inst%rowtype; --CR4579
  l_order_type_objid NUMBER;
  gbst_lst_rec gbst_lst_curs%rowtype;
  gbst_elm_rec gbst_elm_curs%rowtype;
  task2_rec task2_curs%rowtype;
  call_trans_rec call_trans_curs%rowtype;
  carrier_rec carrier_curs%rowtype;
  site_part_rec site_part_curs%rowtype;
  part_num_rec part_num_curs%rowtype;
  user_rec user_curs%rowtype;
  part_inst_rec part_inst_curs%rowtype;
  gbst_elm_rec2 gbst_elm_curs2%rowtype;
  order_type_rec order_type_curs%rowtype;
  trans_profile_rec trans_profile_curs%rowtype;
  voicemailstr   VARCHAR2(1);
  calleridstr    VARCHAR2(1);
  callwaitingstr VARCHAR2(1);
  boolupgrade    BOOLEAN;
  queuestr       VARCHAR2(100);
  technologystr  VARCHAR2(1);
  methodstr      VARCHAR2(100);
  str_ordertype  VARCHAR2(100);
  hold           NUMBER;
  cnt            NUMBER := 0;
  --------------------------------------------------------------
  CURSOR test_verizon1_curs(c_task_objid IN NUMBER)
  IS
    SELECT C.title
    FROM table_condition C ,
      table_task T
    WHERE C.objid = task_state2condition
    AND C.title LIKE 'Closed Action Item%'
    AND T.objid = c_task_objid;
  test_verizon1_rec test_verizon1_curs%rowtype;
  --------------------------------------------------------------
  CURSOR test_verizon2_curs(c_task_objid IN NUMBER)
  IS
    SELECT q.title
    FROM table_queue q ,
      table_task T
    WHERE q.objid = task_currq2queue
    AND q.title LIKE 'Verizon Deac Queue%'
    AND T.objid = c_task_objid;
  test_verizon2_rec test_verizon2_curs%rowtype;
  --------------------------------------------------------------
  CURSOR check_for_previous_task_curs
  IS
    SELECT 1 col1
    FROM gw1.ig_transaction ig ,
      table_task T
    WHERE ig.action_item_id = T.task_id
    AND T.objid             = p_action_item_objid;
  check_for_previous_task_rec check_for_previous_task_curs%rowtype;
BEGIN
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN task_curs(p_action_item_objid);
  FETCH task_curs INTO task2_rec;
  IF task_curs%notfound THEN
    CLOSE task_curs;
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN call_trans_curs(task2_rec.x_task2x_call_trans);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%notfound THEN
    CLOSE call_trans_curs;
    RETURN;
  END IF;
  CLOSE call_trans_curs;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%notfound THEN
    CLOSE site_part_curs;
    RETURN;
  END IF;
  CLOSE site_part_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%notfound THEN
    CLOSE carrier_curs;
    RETURN;
  ELSE
    IF carrier_rec.x_voicemail = 1 THEN
      voicemailstr            := 'Y';
    ELSE
      voicemailstr := 'N';
    END IF;
    IF carrier_rec.x_caller_id = 1 THEN
      calleridstr             := 'Y';
    ELSE
      calleridstr := 'N';
    END IF;
    IF carrier_rec.x_call_waiting = 1 THEN
      callwaitingstr             := 'Y';
    ELSE
      callwaitingstr := 'N';
    END IF;
  END IF;
  CLOSE carrier_curs;
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt || ' site_part_rec.SITE_PART2PART_INFO:' || site_part_rec.site_part2part_info);
  --
  --CR4579
  OPEN c_get_part_inst(site_part_rec.x_service_id);
  FETCH c_get_part_inst INTO r_get_part_inst;
  CLOSE c_get_part_inst;
  IF part_num_curs%isopen THEN
    CLOSE part_num_curs;
  END IF;
  --CR4579 END
  -- CR4579
  OPEN part_num_curs(r_get_part_inst.n_part_inst2part_mod);
  FETCH part_num_curs INTO part_num_rec;
  IF part_num_curs%notfound THEN
    CLOSE part_num_curs;
    sp_dispatch_task(task2_rec.objid ,'Line Management Re-work' ,hold);
    RETURN;
  ELSE
    technologystr := substr(part_num_rec.x_technology ,1 ,1);
  END IF;
  CLOSE part_num_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  sp_get_ordertype(site_part_rec.x_min ,p_order_type ,carrier_rec.objid ,part_num_rec.x_technology ,
  --CR4579 : Added technology to use w/carrierRules
  l_order_type_objid);
  --
  dbms_output.put_line('l_order_type_objid:' || l_order_type_objid);
  cnt := cnt + 1; --7
  dbms_output.put_line('f_check_blackout:' || cnt);
  --
  IF f_check_blackout(task2_rec.objid ,l_order_type_objid) = 1 THEN
    --
    p_destination_queue := 5;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%notfound THEN
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'In Blackout');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%notfound THEN
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    sp_dispatch_task(task2_rec.objid ,'BlackOut' ,hold);
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    --
    RETURN;
    --
  END IF;
  --
  --cnt := cnt + 1;--7
  --dbms_output.put_line('sp_Determine_Trans_Method:'||cnt||' carrier_rec.CARRIER2provider:'||carrier_rec.CARRIER2provider);
  --
  --    open provider_curs(carrier_rec.CARRIER2provider);
  --      fetch provider_curs into provider_rec;
  --      if provider_curs%notfound then
  --        close provider_curs;
  --        return;
  --      end if;
  --    close provider_curs;
  --
  --       cnt := cnt + 1;   --7
  --       DBMS_OUTPUT.put_line (
  --          'sp_Determine_Trans_Method:' ||
  --          cnt ||
  --          ' site_part_rec.SITE_PART2PART_INFO:' ||
  --          site_part_rec.site_part2part_info
  --       );
  -- --
  --       OPEN part_num_curs (site_part_rec.site_part2part_info);
  --       FETCH part_num_curs INTO part_num_rec;
  --
  --
  --       IF part_num_curs%NOTFOUND
  --       THEN
  --          sp_dispatch_task (task2_rec.objid, 'Line Management Re-work', hold);
  --          CLOSE part_num_curs;
  --          RETURN;
  --       ELSE
  --          technologystr := SUBSTR (part_num_rec.x_technology, 1, 1);
  --       END IF;
  --
  --       CLOSE part_num_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN user_curs(call_trans_rec.x_call_trans2user);
  FETCH user_curs INTO user_rec;
  IF user_curs%notfound THEN
    CLOSE user_curs;
    RETURN;
  END IF;
  CLOSE user_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN part_inst_curs(site_part_rec.objid);
  FETCH part_inst_curs INTO part_inst_rec;
  --not being used by this proceduere oct 2 2002 cwl
  --      if part_inst_curs%notfound then
  --        close part_inst_curs;
  --        return;
  --      end if;
  CLOSE part_inst_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN gbst_elm_curs2(task2_rec.task_priority2gbst_elm);
  FETCH gbst_elm_curs2 INTO gbst_elm_rec2;
  IF gbst_elm_curs2%notfound THEN
    CLOSE gbst_elm_curs2;
    RETURN;
  ELSE
    IF gbst_elm_rec2.title = 'High - Upgrade' THEN
      boolupgrade         := TRUE;
    ELSE
      boolupgrade := FALSE;
    END IF;
  END IF;
  CLOSE gbst_elm_curs2;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  dbms_output.put_line('l_order_type_objid:' || l_order_type_objid);
  --
  OPEN order_type_curs(l_order_type_objid);
  FETCH order_type_curs INTO order_type_rec;
  IF order_type_curs%notfound THEN
    CLOSE order_type_curs;
    RETURN;
  ELSE
    -- CR15035 Order Type Function Start
    /*
    IF order_type_rec.x_order_type = 'Internal Port In'
    THEN
    --  --TMO Automated Port Request         -- CR12155 ST_BUNDLE_III for VERIZON_PP
    -- if carrier_rec.x_carrier_id IN(190260,192260,193260,104152) OR carrier_rec.x_carrier_id = 122794 then
    --    str_ordertype := 'PIR';        --CR13035 - NTUL  added T-MOBILE UNLIMITED , wsrd - 104152
    -- else  (Cingular/ATT)
    --    str_ordertype := 'IPI';
    -- end if;
    IF carrier_rec.x_mkt_submkt_name LIKE 'CING%' OR carrier_rec.x_mkt_submkt_name LIKE 'AT&%' THEN
    str_ordertype := 'IPI';  -- if cingular,ATT -- WSRD
    ELSE
    str_ordertype := 'PIR';  -- all other carriers
    END IF;
    ELSIF order_type_rec.x_order_type = 'Internal Port Status'
    THEN
    str_ordertype := 'IPS';
    ELSIF order_type_rec.x_order_type = 'Int Port Approval'
    THEN
    str_ordertype := 'IPA';
    --MIN Change - CR3647 - Starts
    ELSIF order_type_rec.x_order_type = 'MIN Change'
    THEN
    str_ordertype := 'MINC';
    --CDMA NAVAIL
    ELSIF order_type_rec.x_order_type = 'PRL Inquiry'
    THEN
    str_ordertype := 'IPRL';
    --CDMA NAVAIL
    --ST_BUNDLE_II
    ELSIF order_type_rec.x_order_type = 'External PIR'
    THEN
    str_ordertype := 'EPIR';
    --ST_BUNDLE_II
    ELSE
    str_ordertype := SUBSTR (order_type_rec.x_order_type, 1, 1);
    end if;
    */
    str_ordertype := sf_get_ig_order_type('SP_DETERMINE_TRANS_METHOD' ,task2_rec.objid ,order_type_rec.x_order_type);
    -- CR15035 Order Type Function End
  END IF;
  CLOSE order_type_curs;
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt || ' order_type_rec.X_ORDER_TYPE2X_TRANS_PROFILE:' || order_type_rec.x_order_type2x_trans_profile);
  --
  OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
  FETCH trans_profile_curs INTO trans_profile_rec;
  IF trans_profile_curs%notfound THEN
    IF p_order_type IN ('Deactivation' ,'Suspend') THEN
      queuestr      := 'Line Management Re-work';
    ELSE
      queuestr := 'Line Activation NoOrdTyp';
    END IF;
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    p_destination_queue := 4;
    --
    CLOSE trans_profile_curs;
    RETURN;
  ELSE
    IF trans_profile_rec.x_exception = 1 THEN
      sp_dispatch_task(task2_rec.objid ,trans_profile_rec.x_exception_queue ,hold);
      CLOSE trans_profile_curs;
      RETURN;
    END IF;
    IF p_trans_method IS NULL THEN
      IF technologystr = 'G' --CR3380
        THEN
        methodstr         := trans_profile_rec.x_gsm_transmit_method;
      ELSIF technologystr <> 'A' THEN
        methodstr         := trans_profile_rec.x_d_transmit_method;
      ELSE
        methodstr := trans_profile_rec.x_transmit_method;
      END IF;
    ELSE
      methodstr := p_trans_method;
    END IF;
  END IF;
  CLOSE trans_profile_curs;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  IF str_ordertype                  IN ('A' ,'E') THEN
    IF part_num_rec.x_technology     = 'ANALOG' AND boolupgrade = FALSE THEN
      queuestr                      := trans_profile_rec.x_default_queue;
    ELSIF part_num_rec.x_technology  = 'GSM' --CR3380
      AND boolupgrade                = FALSE THEN
      queuestr                      := trans_profile_rec.x_gsm_act;
    ELSIF part_num_rec.x_technology <> 'ANALOG' AND boolupgrade = FALSE THEN
      queuestr                      := trans_profile_rec.x_digital_act;
    END IF;
  ELSIF str_ordertype               IN ('S' ,'D' ,'R') THEN
    IF part_num_rec.x_technology     = 'ANALOG' AND boolupgrade = FALSE THEN
      queuestr                      := trans_profile_rec.x_analog_deact;
    ELSIF part_num_rec.x_technology  = 'GSM' --CR3380
      AND boolupgrade                = FALSE THEN
      queuestr                      := trans_profile_rec.x_gsm_deact;
    ELSIF part_num_rec.x_technology <> 'ANALOG' AND boolupgrade = FALSE THEN
      queuestr                      := trans_profile_rec.x_digital_deact;
    END IF;
  END IF;
  IF boolupgrade THEN
    queuestr := trans_profile_rec.x_upgrade;
  END IF;
  --CR3327-1 - Set the queue name for Int Port Approval
  IF str_ordertype = 'IPA' THEN
    queuestr      := 'Internal Port Approval';
  END IF;
  IF queuestr IS NULL OR queuestr = 'Please Specify' THEN
    queuestr  := 'Line Management Re-work';
  END IF;
  --    If TransMethod is not null Then
  --        MethodStr := TransMethod;
  --    End If;
  --
  IF methodstr                      IN ('AOL' ,'EMAIL' ,'FAX') THEN
    IF boolupgrade AND str_ordertype = 'S' AND methodstr <> 'AOL' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      RETURN;
    END IF;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%notfound THEN
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent AOL');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%notfound THEN
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    ------------------------------------------------------------------
    sp_dispatch_task(task2_rec.objid ,'Intergate' ,hold);
    --
    --check to make sure new que is not Verizon Deac Queue and line not past due oct 4
    --
    OPEN test_verizon1_curs(task2_rec.objid);
    FETCH test_verizon1_curs INTO test_verizon1_rec;
    IF test_verizon1_curs%found THEN
      CLOSE test_verizon1_curs;
      COMMIT;
      RETURN;
    END IF;
    CLOSE test_verizon1_curs;
    --
    OPEN test_verizon2_curs(task2_rec.objid);
    FETCH test_verizon2_curs INTO test_verizon2_rec;
    IF test_verizon2_curs%found THEN
      CLOSE test_verizon2_curs;
      COMMIT;
      RETURN;
    END IF;
    CLOSE test_verizon2_curs;
    --
    --end check of verizon
    --
    --dbms_output.put_line('Before Insert 1');
    --dbms_output.put_line('Task OBJID:'||to_char(task2_rec.objid));
    OPEN check_for_previous_task_curs;
    FETCH check_for_previous_task_curs INTO check_for_previous_task_rec;
    IF check_for_previous_task_curs%notfound THEN
      dbms_output.put_line('Before Insert 2');
      sp_insert_ig_transaction(p_task_objid => task2_rec.objid ,p_order_type_objid => l_order_type_objid ,p_status => hold ,p_application_system => p_application_system
      -- GSM Enhancement
      );
      dbms_output.put_line('After Insert status:' || hold);
    END IF;
    ------------------------------------------------------------------
    IF methodstr           = 'AOL' THEN
      p_destination_queue := 8;
    ELSIF methodstr        = 'FAX' THEN
      p_destination_queue := 9;
    ELSIF methodstr        = 'EMAIL' THEN
      p_destination_queue := 10;
    END IF;
    --
  ELSIF methodstr                   IN ('ICI') THEN
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      RETURN;
    END IF;
    --
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    IF trans_profile_rec.x_ici_system = 'ICI CALL IN' THEN
      p_destination_queue            := 11;
    ELSE
      p_destination_queue := 6;
    END IF;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%notfound THEN
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent ICI');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%notfound THEN
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    --
  ELSIF methodstr                   IN ('ECI') THEN
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      RETURN;
    END IF;
    --sp_Open_Action_Item(Task2_Rec.task_id);
    p_destination_queue := 7;
    --
  ELSIF methodstr                   IN ('MANUAL - EMAIL') THEN
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      RETURN;
    END IF;
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    p_destination_queue := 7;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%notfound THEN
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent Manual');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%notfound THEN
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    --
  ELSIF methodstr IN ('MANUAL - FAX') THEN
    --
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      RETURN;
    END IF;
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    p_destination_queue := 7;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%notfound THEN
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent Manual');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%notfound THEN
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    --
  ELSE
    --
    queuestr := 'Line Activation NoOrdTyp';
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    p_destination_queue := 7;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%notfound THEN
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent Manual');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%notfound THEN
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
  END IF;
  dbms_output.put_line('sp_determine_trans_method: before commit');
  COMMIT;
END sp_determine_trans_method;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_insert_ig_transaction(
    p_task_objid       IN NUMBER ,
    p_order_type_objid IN NUMBER ,
    p_status OUT NUMBER ,
    p_application_system IN VARCHAR2 DEFAULT 'IG' -- GSM Enhancement
  )
IS
  CURSOR task_curs(c_task_objid IN NUMBER) IS
    SELECT * FROM table_task WHERE objid = c_task_objid;
  task_rec task_curs%rowtype;
--
  CURSOR chk_need_dep_igtx_curs(c_esn VARCHAR2) IS
    SELECT /*+ use_invisible_indexes */
           *
      FROM gw1.ig_transaction
     WHERE esn         = c_esn
       AND order_type               IN ('A' ,'E' ,'IPI' ,'PIR' ,'EPIR') --CR17415 PM 08/02/2011 'Port In' added for PPIR order type. -- CR17793 to remove PPIR
       AND status NOT               IN ('S' ,'F')
       AND creation_date > = sysdate - 1 / 24;
  chk_need_dep_igtx_rec chk_need_dep_igtx_curs%rowtype;
  CURSOR bucket_curs(c_esn IN VARCHAR2,
                     c_bucket_type IN VARCHAR2) IS
    SELECT cd.x_name ,
           cd.x_value ,
           C.creation_time,
           1 x_sort
      FROM table_case C,
           table_x_case_detail cd
     WHERE 1=1
       AND C.x_esn        = c_esn
       AND cd.detail2case = C.objid
       AND cd.x_name      = c_bucket_type
    UNION
    SELECT c_bucket_type x_name,
           '0' x_value,
           sysdate creation_time,
           2 x_sort
      FROM dual
     ORDER BY x_sort ASC,creation_time DESC;
  bucket_rec bucket_curs%rowtype;
  CURSOR ig_bucket_curs(c_bucket_type IN VARCHAR2,
                        c_rate_plan   IN VARCHAR2)IS
    SELECT *
      FROM gw1.ig_buckets bkt
     WHERE 1=1
       AND bkt.bucket_type  = c_bucket_type
       AND bkt.rate_plan    = c_rate_plan;
  ig_bucket_rec ig_bucket_curs%rowtype;
  CURSOR contact_curs(c_contact_objid IN NUMBER) IS
    SELECT tc.*
    FROM table_contact tc
    WHERE tc.objid = c_contact_objid;
  contact_rec contact_curs%rowtype;
  CURSOR address_curs(c_contact_objid IN NUMBER) IS
    SELECT A.*
      FROM table_contact_role cr,
           table_site S,
           table_address A
     WHERE cr.contact_role2contact = c_contact_objid
       AND S.objid  = cr.contact_role2site
       AND A.objid = cust_primaddr2address;
  address_rec address_curs%rowtype;
  CURSOR c1 IS
  SELECT ig.*
   FROM gw1.ig_transaction ig,
        table_task T
  WHERE 1=1
    AND ig.action_item_id = T.task_id
    AND T.objid = p_task_objid;
  c1_rec c1%rowtype;
  CURSOR ld_curs(c_call_trans_objid IN NUMBER) IS
    SELECT rsid,x_value
      FROM x_switchbased_transaction st
     WHERE st.x_sb_trans2x_call_trans = c_call_trans_objid;
  ld_rec ld_curs%rowtype;
--
  CURSOR order_type_curs(c_objid IN NUMBER) IS
    SELECT ot.*
           --sf_get_ig_order_type('SP_INSERT_IG_TRANSACTION' ,task_rec.objid ,order_type_rec.x_order_type) new_order_type
     FROM table_x_order_type ot
    WHERE ot.objid = c_objid;
  order_type_rec order_type_curs%rowtype;
--
  CURSOR trans_profile_curs(c_objid IN NUMBER,
                            c_tech IN VARCHAR2) IS
    SELECT objid,
           decode(c_tech,'GSM',x_gsm_trans_template,'CDMA',x_d_trans_template,x_transmit_template) TEMPLATE,
           decode(c_tech,'GSM',x_gsm_transmit_method,'CDMA',x_d_transmit_method,x_transmit_method) transmit_method,
           decode(c_tech,'GSM',x_gsm_fax_number,'CDMA',x_d_fax_number,x_fax_number) fax_number,
           decode(c_tech,'GSM',x_gsm_fax_num2,'CDMA',x_d_fax_num2,x_fax_num2) fax_num2,
           decode(c_tech,'GSM',x_gsm_online_number,'CDMA',x_d_online_number,x_online_number) online_number,
           decode(c_tech,'GSM',x_gsm_online_num2,'CDMA',x_d_online_num2,x_online_num2) online_num2,
           decode(c_tech,'GSM',x_gsm_email,'CDMA',x_d_email,x_email) email,
           decode(c_tech,'GSM',x_gsm_network_login,'CDMA',x_d_network_login,x_network_login) network_login,
           decode(c_tech,'GSM',x_gsm_network_password,'CDMA',x_d_network_password,x_network_password) network_password,
           decode(c_tech,'GSM',x_system_login,'CDMA',x_d_system_login,x_system_login) system_login,
           decode(c_tech,'GSM',x_system_password,'CDMA',x_d_system_password,x_system_password) system_password,
           decode(c_tech,'GSM',x_gsm_batch_delay_max,'CDMA',x_d_batch_delay_max,x_batch_delay_max) batch_delay_max,
           decode(c_tech,'GSM',x_gsm_batch_quantity,'CDMA',x_d_batch_quantity,x_batch_quantity) batch_quantity
      FROM table_x_trans_profile
     WHERE objid = c_objid;
  trans_profile_rec trans_profile_curs%rowtype;
--
  CURSOR carrier_curs(c_objid IN NUMBER) IS
    SELECT C.*,
           nvl((SELECT 1
                  FROM sa.x_next_avail_carrier nac
                 WHERE nac.x_carrier_id = C.x_carrier_id
                   AND ROWNUM < 2),0) x_next_avail_carrier
      FROM table_x_carrier C WHERE objid = c_objid;
  carrier_rec carrier_curs%rowtype;
--
  CURSOR carrier_group_curs(c_objid IN NUMBER) IS
    SELECT * FROM table_x_carrier_group WHERE objid = c_objid;
  carrier_group_rec carrier_group_curs%rowtype;
--
  CURSOR parent_curs(c_objid IN NUMBER) IS
    SELECT * FROM table_x_parent WHERE objid = c_objid;
  parent_rec parent_curs%rowtype;
--
  CURSOR c_nap_rc(p_zipcode IN VARCHAR2) IS
    SELECT * FROM sa.x_cingular_mrkt_info WHERE zip = p_zipcode AND ROWNUM < 2;
  c_nap_rc_rec c_nap_rc%rowtype;
--
  CURSOR call_trans_curs(c_objid IN NUMBER) IS
    SELECT ct.* ,
           (SELECT pi.x_msid
              FROM table_part_inst pi
             WHERE pi.part_serial_no = ct.x_min) msid,
           decode(ct.x_ota_type,ota_util_pkg.ota_activation,'Y',NULL) ota_activation
      FROM table_x_call_trans ct
     WHERE ct.objid = c_objid;
  call_trans_rec call_trans_curs%rowtype;
--
  CURSOR site_part_curs(c_objid IN NUMBER) IS
    SELECT CAST(sp.x_min AS VARCHAR2(30)) x_min,
           sp.x_service_id,
           sp.x_expire_dt,
           CAST(sp.x_pin AS VARCHAR2(30)) x_pin,
           sp.x_zipcode,
           sp.site_part2part_info,
           (SELECT pi.n_part_inst2part_mod
              FROM table_part_inst pi
             WHERE part_serial_no = sp.x_service_id) n_part_inst2part_mod,
           (CASE WHEN sp.x_iccid IS NULL THEN
                   (SELECT pi.x_iccid
                      FROM table_part_inst pi
                     WHERE pi.x_part_inst2site_part = sp.objid)
                 ELSE
                   sp.x_iccid
                 END) iccid
      FROM table_site_part sp
     WHERE objid = c_objid;
  site_part_rec site_part_curs%rowtype;
--
  CURSOR alt_min_curs(c_esn        IN VARCHAR2,
                      c_order_type IN VARCHAR2) IS
    SELECT C.s_title,
           (SELECT cd.x_value l_account
              FROM table_x_case_detail cd
             WHERE cd.x_name || ''                     IN ('CURRENT_MIN')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) MIN ,
           (SELECT cd.x_value l_account
              FROM table_x_case_detail cd
             WHERE cd.x_name || ''                     IN ('ACCOUNT')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) ACCOUNT ,
           (SELECT cd.x_value l_first_name
              FROM table_x_case_detail cd
             WHERE cd.x_name|| ''                     IN ('NAME')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) first_name ,
           (SELECT cd.x_value l_last_name
              FROM table_x_case_detail cd
             WHERE cd.x_name|| ''                     IN ('LAST_NAME')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) last_name ,
           (SELECT cd.x_value l_add1
              FROM table_x_case_detail cd
             WHERE cd.x_name|| ''                     IN ('ADDRESS_1')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) add1 ,
           (SELECT cd.x_value l_add2
              FROM table_x_case_detail cd
             WHERE cd.x_name|| ''                     IN ('ADDRESS_2')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) add2 ,
           (SELECT cd.x_value l_zip
              FROM table_x_case_detail cd
             WHERE cd.x_name|| ''                     IN ('ZIP_CODE')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) zip ,
           (SELECT cd.x_value l_account
              FROM table_x_case_detail cd
             WHERE cd.x_name|| ''                     IN ('PIN')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2) pin,
           (SELECT cd.x_value l_curr_addr_house_number
              FROM table_x_case_detail cd
             WHERE cd.x_name || '' IN ('CURR_ADDR_HOUSE_NUMBER')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2 ) curr_addr_house_number,
           (SELECT cd.x_value l_curr_addr_direction
              FROM table_x_case_detail cd
             WHERE cd.x_name || '' IN ('CURR_ADDR_DIRECTION')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2 ) curr_addr_direction,
           (SELECT cd.x_value l_curr_addr_street_name
              FROM table_x_case_detail cd
             WHERE cd.x_name || '' IN ('CURR_ADDR_STREET_NAME')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2 ) curr_addr_street_name,
           (SELECT cd.x_value l_curr_addr_street_type
              FROM table_x_case_detail cd
             WHERE cd.x_name || '' IN ('CURR_ADDR_STREET_TYPE')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2 ) curr_addr_street_type,
           (SELECT cd.x_value l_curr_addr_unit
              FROM table_x_case_detail cd
             WHERE cd.x_name || '' IN ('CURR_ADDR_UNIT')
               AND cd.detail2case = C.objid + 0
               AND ROWNUM <2 ) curr_addr_unit
      FROM table_case C
     WHERE 1=1
       AND C.x_case_type || ''     = 'Port In'
       AND C.x_esn = c_esn
    ORDER BY C.creation_time DESC;
  alt_min_rec alt_min_curs%rowtype;
--
  CURSOR part_num_curs(c_objid IN NUMBER) IS
    SELECT pn.* ,
           decode(org_id,'STRAIGHT_TALK',1,0) straight_talk_flag,
           bo.org_id ,
           bo.objid bus_org_objid,
           bo.org_flow,
           nvl((SELECT to_number(V.x_param_value)
              FROM table_x_part_class_values V,
                   table_x_part_class_params N
             WHERE 1=1
               AND V.value2part_class     = pn.part_num2part_class
               AND V.value2class_param    = N.objid
               AND N.x_param_name         = 'DATA_SPEED'
               AND ROWNUM <2),nvl(x_data_capable,0)) data_speed
    FROM table_part_num pn ,
      table_mod_level ml ,
      table_bus_org bo
    WHERE pn.objid          = ml.part_info2part_num
    AND ml.objid            = c_objid
    AND pn.part_num2bus_org = bo.objid;
  part_num_rec part_num_curs%rowtype;
--
  CURSOR carrier_features_curs1 ( c_objid IN NUMBER ,p_tech IN VARCHAR2 ,p_bus_org_objid IN NUMBER ,p_data_speed IN NUMBER,c_order_type IN VARCHAR2 ) IS
    SELECT cf.*,1 col1
    FROM table_x_carrier_features cf
    WHERE x_feature2x_carrier = c_objid
    AND cf.x_technology       = p_tech
    AND cf.x_features2bus_org = p_bus_org_objid
    AND cf.x_data             = p_data_speed
    UNION
    SELECT cf.*,2 col1
    FROM table_x_carrier_features cf
    WHERE x_feature2x_carrier = c_objid
      AND c_order_type IN ('D','S')
    ORDER BY col1;
  carr_feature_rec1 carrier_features_curs1%rowtype;
--
  CURSOR carrier_features_curs ( c_objid IN NUMBER) IS
    SELECT cf.*,
           decode(cf.x_voicemail ,1 ,'Y' ,'N')    voice_mail,
           cf.x_vm_code                           voice_mail_package,
           decode(cf.x_caller_id ,1 ,'Y' ,'N')    caller_id,
           cf.x_id_code                           caller_id_package,
           decode(cf.x_call_waiting ,1 ,'Y' ,'N') call_waiting,
           cf.x_cw_code                           call_waiting_package,
           decode(cf.x_sms ,1 ,'Y' ,'N')          sms,
           cf.x_sms_code                          sms_package,
           decode(cf.x_dig_feature ,1 ,'Y' ,'N')  digital_feature,
           cf.x_digital_feature                   digital_feature_code,
           decode(cf.x_mpn ,1 ,'Y' ,'N')          mpn,
           cf.x_mpn_code                          mpn_code,
           cf.x_pool_name                         pool_name
      FROM table_x_carrier_features cf
     WHERE cf.objid = c_objid;
  carr_feature_rec carrier_features_curs%rowtype;
--
  CURSOR old_esn_curs(c_esn    IN VARCHAR2,
                      c_org_id IN VARCHAR2) IS
    SELECT cd.x_value esn,
           C.creation_time c_date
      FROM table_x_case_detail cd ,
           table_case C
     WHERE cd.detail2case = C.objid + 0
       AND C.x_esn          = c_esn
       AND cd.x_name || '' = 'REFERENCE_ESN'
       AND 'STRAIGHT_TALK' = c_org_id
    UNION
    SELECT x_old_esn esn,
           x_detach_dt c_date
      FROM x_min_esn_change
     WHERE x_new_esn = c_esn
       AND 'STRAIGHT_TALK' != c_org_id
    ORDER BY c_date DESC;
  old_esn_rec old_esn_curs%rowtype;
--
  CURSOR old_min_curs(ip_service_id IN VARCHAR2)
  IS
    SELECT x_min
    FROM table_site_part
    WHERE x_service_id = ip_service_id
    AND part_status    = 'Inactive'
    AND x_min NOT LIKE 'T%'
    ORDER BY service_end_dt DESC;
  old_min_rec old_min_curs%rowtype;
  CURSOR new_transaction_id_curs IS
    SELECT gw1.trans_id_seq.NEXTVAL + (POWER(2 ,28)) transaction_id
      FROM dual;
  new_transaction_id_rec new_transaction_id_curs%rowtype;
  order_type VARCHAR2(200);
  l_carr_feat_objid  NUMBER;
BEGIN
    NULL;
--
    OPEN task_curs(p_task_objid);
    FETCH task_curs INTO task_rec;
    IF task_curs%notfound THEN
      p_status := 1;
      CLOSE task_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'task_curs%NOTFOUND',sysdate,'task_curs('||p_task_objid||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE task_curs;
--
    OPEN contact_curs(task_rec.task2contact);
      FETCH contact_curs INTO contact_rec;
      IF contact_curs%found THEN
        dbms_output.put_line('contact_rec.objid:'||contact_rec.objid);
        dbms_output.put_line('contact_rec.first_name:'||contact_rec.first_name);
        dbms_output.put_line('contact_rec.last_name:'||contact_rec.last_name);
        dbms_output.put_line('contact_rec.x_ss_number:'||contact_rec.x_ss_number);
        dbms_output.put_line('contact_rec.ADDRESS_1:'||contact_rec.address_1);
        dbms_output.put_line('contact_rec.ADDRESS_2:'||contact_rec.address_2);
        dbms_output.put_line('contact_rec.CITY:'||contact_rec.city);
        dbms_output.put_line('contact_rec.STATE:'||contact_rec.STATE);
        dbms_output.put_line('contact_rec.ZIPCODE:'||contact_rec.zipcode);
        OPEN address_curs(contact_rec.objid);
          FETCH address_curs INTO address_rec;
          IF address_curs%found THEN
            dbms_output.put_line('address_rec.objid:'||address_rec.objid);
            dbms_output.put_line('address_rec.address:'||address_rec.address);
            dbms_output.put_line('address_rec.address_2:'||address_rec.address_2);
            dbms_output.put_line('address_rec.city:'||address_rec.city);
            dbms_output.put_line('address_rec.state:'||address_rec.STATE);
            dbms_output.put_line('address_rec.ZIPCODE:'||address_rec.zipcode);
          ELSE
            CLOSE contact_curs;
            CLOSE address_curs;
            INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
            VALUES( 'address_curs%NOTFOUND',sysdate,'address_curs('||contact_rec.objid||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
            RETURN;
          END IF;
        CLOSE address_curs;
      ELSE
        CLOSE contact_curs;
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES( 'contact_curs%NOTFOUND',sysdate,'contact_curs('||task_rec.task2contact||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
        RETURN;
      END IF;
    CLOSE contact_curs;
--
    dbms_output.put_line('task_rec.x_task2x_order_type:'||task_rec.x_task2x_order_type);
--
    OPEN order_type_curs(p_order_type_objid);
      FETCH order_type_curs INTO order_type_rec;
      IF order_type_curs%notfound THEN
        p_status := 2;
        CLOSE order_type_curs;
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES( 'order_type_curs%NOTFOUND',sysdate,'order_type_curs('||p_order_type_objid||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
        RETURN;
      END IF;
    CLOSE order_type_curs;
    dbms_output.put_line('order_type_rec.x_order_type:'||order_type_rec.x_order_type);
    dbms_output.put_line('order_type_rec.objid:'||order_type_rec.objid);
    dbms_output.put_line('task_rec.objid:'||task_rec.objid);
--
    order_type := sf_get_ig_order_type('SP_INSERT_IG_TRANSACTION' ,task_rec.objid ,order_type_rec.x_order_type);
    IF order_type IS NULL THEN
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES( 'order_type is null',sysdate,'sf_get_ig_order_type('||'SP_INSERT_IG_TRANSACTION,'||task_rec.objid||','||
                 order_type_rec.x_order_type||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    dbms_output.put_line('order_type:'||order_type);
--
    OPEN carrier_curs(order_type_rec.x_order_type2x_carrier);
    FETCH carrier_curs INTO carrier_rec;
    IF carrier_curs%notfound THEN
      p_status := 3;
      CLOSE carrier_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'carrier_curs%NOTFOUND',sysdate,'carrier_curs('||order_type_rec.x_order_type2x_carrier||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE carrier_curs;
--
    OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
    FETCH carrier_group_curs INTO carrier_group_rec;
    IF carrier_group_curs%notfound THEN
      p_status := 4;
      CLOSE carrier_group_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'carrier_group_curs%NOTFOUND',sysdate,'carrier_group_curs('||carrier_rec.carrier2carrier_group||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE carrier_group_curs;
--
    OPEN parent_curs(carrier_group_rec.x_carrier_group2x_parent);
    FETCH parent_curs INTO parent_rec;
    IF parent_curs%notfound THEN
      p_status := 5;
      CLOSE parent_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'parent_curs%NOTFOUND',sysdate,'parent_curs('||carrier_group_rec.x_carrier_group2x_parent||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE parent_curs;
--
    OPEN call_trans_curs(task_rec.x_task2x_call_trans);
    FETCH call_trans_curs INTO call_trans_rec;
    IF call_trans_curs%notfound THEN
      p_status := 6;
      CLOSE call_trans_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'call_trans_curs%NOTFOUND',sysdate,'call_trans_curs('||task_rec.x_task2x_call_trans||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE call_trans_curs;
    dbms_output.put_line('call_trans_rec.x_action_type:'||call_trans_rec.x_action_type);
    dbms_output.put_line('call_trans_rec.ota_activation:'||call_trans_rec.ota_activation);
--
    OPEN site_part_curs(call_trans_rec.call_trans2site_part);
    FETCH site_part_curs INTO site_part_rec;
    IF site_part_curs%notfound THEN
      p_status := 7;
      CLOSE site_part_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'site_part_curs%NOTFOUND',sysdate,'site_part_curs('||call_trans_rec.call_trans2site_part||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE site_part_curs;
    dbms_output.put_line('site_part_rec.x_min:'||site_part_rec.x_min);
    dbms_output.put_line('site_part_rec.x_service_id:'||site_part_rec.x_service_id);
    dbms_output.put_line('site_part_rec.x_pin:'||site_part_rec.x_pin);
--
    OPEN old_esn_curs(site_part_rec.x_service_id,part_num_rec.org_id);
      FETCH old_esn_curs INTO old_esn_rec;
      IF old_esn_curs%notfound THEN
        dbms_output.put_line('old_esn_curs%NOTFOUND');
      ELSE
        dbms_output.put_line('old_esn_rec.esn:'||old_esn_rec.esn);
      END IF;
    CLOSE old_esn_curs;
--
    IF call_trans_rec.x_action_type IN ('1' ,'2' ,'3') THEN
      OPEN old_min_curs(call_trans_rec.x_service_id);
        FETCH old_min_curs INTO old_min_rec;
        IF old_min_curs%notfound THEN
          dbms_output.put_line('old_min_curs%NOTFOUND');
        ELSE
          dbms_output.put_line('old_min_rec.x_min:'|| old_min_rec.x_min);
        END IF;
      CLOSE old_min_curs;
    END IF;
--
    IF order_type IN ('PIC' ,'EPIC','EPIR', 'PIR') THEN
      OPEN alt_min_curs(site_part_rec.x_service_id, order_type);
        FETCH alt_min_curs INTO alt_min_rec;
        IF alt_min_curs%notfound OR alt_min_rec.MIN IS NULL THEN
          dbms_output.put_line('alt_min_curs%NOTFOUND');
         -- p_status := 8;
          --CLOSE alt_min_curs;
          INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
          VALUES( 'alt_min_curs%NOTFOUND',sysdate,'alt_min_curs('||site_part_rec.x_service_id||','|| order_type||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
         -- RETURN;
        END IF;
      CLOSE alt_min_curs;
      dbms_output.put_line('site_part_rec.x_min changed to:'|| alt_min_rec.MIN||' because of ordertype:'|| order_type_rec.x_order_type);
      dbms_output.put_line('order_type:'||order_type);
      dbms_output.put_line('alt_min_rec.s_title:'||alt_min_rec.s_title);
      dbms_output.put_line('alt_min_rec.first_name:'||alt_min_rec.first_name);
      dbms_output.put_line('alt_min_rec.last_name:'||alt_min_rec.last_name);
      dbms_output.put_line('alt_min_rec.account:'||alt_min_rec.ACCOUNT);
      dbms_output.put_line('alt_min_rec.add1:'||alt_min_rec.add1);
      dbms_output.put_line('alt_min_rec.add2:'||alt_min_rec.add2);
      dbms_output.put_line('alt_min_rec.pin:'||alt_min_rec.pin);
      dbms_output.put_line('alt_min_rec.zip:'||alt_min_rec.zip);
      site_part_rec.x_min := alt_min_rec.MIN;
      IF order_type = 'EPIR' THEN
        dbms_output.put_line('change site_part_rec.x_pin:'||site_part_rec.x_pin);
        site_part_rec.x_pin := alt_min_rec.pin;
      END IF;
    END IF;
--
    dbms_output.put_line('site_part_rec.site_part2part_info:'||site_part_rec.site_part2part_info);
    dbms_output.put_line('site_part_rec.n_part_inst2part_mod:'||site_part_rec.n_part_inst2part_mod);
    OPEN part_num_curs(site_part_rec.n_part_inst2part_mod);
    FETCH part_num_curs INTO part_num_rec;
    IF part_num_curs%notfound THEN
      p_status := 9;
      CLOSE part_num_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'part_num_curs%NOTFOUND',sysdate,'part_num_curs('||site_part_rec.n_part_inst2part_mod||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE part_num_curs;
    dbms_output.put_line('site_part_rec.x_zipcode:'|| site_part_rec.x_zipcode );
--
    OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile,part_num_rec.x_technology);
    FETCH trans_profile_curs INTO trans_profile_rec;
    IF trans_profile_curs%notfound THEN
      p_status := 10;
      CLOSE trans_profile_curs;
      INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
      VALUES( 'trans_profile_curs%NOTFOUND',sysdate,'trans_profile_curs('||order_type_rec.x_order_type2x_trans_profile||','||
               part_num_rec.x_technology||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    CLOSE trans_profile_curs;
--
    IF part_num_rec.x_technology = 'GSM' AND
       parent_rec.x_parent_id    IN ('6' ,'71' ,'76') AND
       nvl(parent_rec.x_next_available,0) = 1 AND
       carrier_rec.x_next_avail_carrier = 1 THEN
      dbms_output.put_line('cingular order_type');
      OPEN c_nap_rc(site_part_rec.x_zipcode );
        FETCH c_nap_rc INTO c_nap_rc_rec;
        IF c_nap_rc%notfound THEN
          dbms_output.put_line('c_nap_rc%notfound');
          --p_status := 11;
          --close c_nap_rc;
          INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
          VALUES( 'c_nap_rc%NOTFOUND',sysdate,'c_nap_rc('||site_part_rec.x_zipcode||')' ,p_task_objid,'igate.sp_insert_ig_transaction');
          --return;
        END IF;
      CLOSE c_nap_rc;
      order_type_rec.x_ld_account_num       := c_nap_rc_rec.account_num;
      order_type_rec.x_market_code          := c_nap_rc_rec.market_code;
      order_type_rec.x_dealer_code          := c_nap_rc_rec.dealer_code;
      trans_profile_rec.TEMPLATE            := c_nap_rc_rec.TEMPLATE;
    END IF;
--
    dbms_output.put_line('carrier_rec.objid:' || carrier_rec.objid);
    dbms_output.put_line('part_num_rec.part_number:' || part_num_rec.part_number);
    dbms_output.put_line('part_num_rec.x_technology:' || part_num_rec.x_technology);
    dbms_output.put_line('part_num_rec.org_id:' || part_num_rec.org_id);
    dbms_output.put_line('part_num_rec.bus_org_objid:' || part_num_rec.bus_org_objid);
    dbms_output.put_line('part_num_rec.data_speed:' || part_num_rec.data_speed);
    dbms_output.put_line('part_num_rec.x_data_capable:' || part_num_rec.x_data_capable);
--
    OPEN carrier_features_curs1(carrier_rec.objid ,part_num_rec.x_technology ,part_num_rec.bus_org_objid ,part_num_rec.data_speed, order_type);
      FETCH carrier_features_curs1 INTO carr_feature_rec1;
      IF carrier_features_curs1%notfound THEN
    -- ECR25704 do not fail if carrier_features_curs1%notfound
        carr_feature_rec1.objid := NULL;
      END IF;
    dbms_output.put_line('carr_features_rec1.col1:'||carr_feature_rec1.col1);
    CLOSE carrier_features_curs1;
    dbms_output.put_line('pre sf_get_carr_feat:'|| carr_feature_rec1.objid);
--
    l_carr_feat_objid := sf_get_carr_feat(order_type , --P_ORDER_TYPE
    part_num_rec.straight_talk_flag,                   --l_st_esn_count ,                                   --P_ST_ESN_FLAG
    call_trans_rec.call_trans2site_part ,              --P_SITE_PART_OBJID
    call_trans_rec.x_service_id ,                      --P_ESN
    call_trans_rec.x_call_trans2carrier ,              --P_CARRIER_OBJID
    carr_feature_rec1.objid ,                          --P_CARR_FEATURE_OBJID
    part_num_rec.data_speed ,                          --P_DATA_CAPABLE
    trans_profile_rec.TEMPLATE ,                       --P_TEMPLATE
    NULL                                               --P_SERVICE_PLAN_ID
    );
    dbms_output.put_line('post sf_get_carr_feat:'|| l_carr_feat_objid);
--
    OPEN carrier_features_curs (nvl(l_carr_feat_objid,carr_feature_rec1.objid));
      FETCH carrier_features_curs INTO carr_feature_rec;
      IF carrier_features_curs%notfound THEN
        CLOSE carrier_features_curs;
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES ('carrier_features_curs1%NOTFOUND',sysdate,'carrier_features_curs1('|| carrier_rec.objid          ||','||
                                                                                      part_num_rec.x_technology  ||','||
                                                                                      part_num_rec.bus_org_objid ||','||
                                                                                      part_num_rec.data_speed    ||','||
                                                                                      order_type                 ||')',
                p_task_objid,'igate.sp_insert_ig_transaction');
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES ('sf_get_carr_feat returned null',sysdate,'sf_get_carr_feat('||order_type||','||
                                                                            part_num_rec.straight_talk_flag     ||','||
                                                                            call_trans_rec.call_trans2site_part ||','||
                                                                            call_trans_rec.x_service_id         ||','||
                                                                            call_trans_rec.x_call_trans2carrier ||','||
                                                                            carr_feature_rec1.objid             ||','||
                                                                            part_num_rec.data_speed             ||','||
                                                                            trans_profile_rec.TEMPLATE          ||','||
                                                                            'NULL )',
                 p_task_objid,'igate.sp_insert_ig_transaction');
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES( 'carrier_features_curs%NOTFOUND',sysdate,'carrier_features_curs(nvl('||l_carr_feat_objid||','||carr_feature_rec1.objid||'))' ,
                 p_task_objid,'igate.sp_insert_ig_transaction');
        RETURN;
      END IF;
    CLOSE carrier_features_curs;
--
    OPEN ld_curs(call_trans_rec.objid);
      FETCH ld_curs INTO ld_rec;
      IF ld_curs%notfound THEN
        ld_rec.rsid := carrier_rec.x_ld_pic_code;
      END IF;
    CLOSE ld_curs;
    dbms_output.put_line('ld_rec.rsid:'||ld_rec.rsid);
    dbms_output.put_line('ld_rec.x_value:'||ld_rec.x_value);
    dbms_output.put_line('carrier_rec.x_ld_pic_code:'||carrier_rec.x_ld_pic_code);
    OPEN new_transaction_id_curs;
      FETCH new_transaction_id_curs INTO new_transaction_id_rec;
      IF new_transaction_id_curs%notfound THEN
        CLOSE new_transaction_id_curs;
        INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
        VALUES( 'new_transaction_id_curs%NOTFOUND',sysdate,'new_transaction_id_curs' ,p_task_objid,'igate.sp_insert_ig_transaction');
        RETURN;
      END IF;
    CLOSE new_transaction_id_curs;
    OPEN chk_need_dep_igtx_curs(call_trans_rec.x_service_id);
      FETCH chk_need_dep_igtx_curs INTO chk_need_dep_igtx_rec;
      IF     chk_need_dep_igtx_curs%found
         AND chk_need_dep_igtx_rec.rate_plan != carr_feature_rec.x_rate_plan THEN
        INSERT INTO gw1.ig_dependent_transaction(
              objid ,
              dep_transaction_id , -- same objid sequence which is used for IG_TX as eventually this record will be moved to IG_TX
              dep_action_item_task_id ,
              dep_trans_prof_key ,
              dep_carrier_id ,
              dep_state_field ,
              dep_order_type ,
              dep_old_min ,
              dep_min ,
              dep_msid ,
              dep_zip_code ,
              dep_iccid ,
              dep_esn ,
              dep_esn_hex ,
              dep_old_esn ,
              dep_old_esn_hex ,
              dep_account_num ,
              dep_market_code ,
              dep_dealer_code ,
              dep_template ,
              dep_transmission_method ,
              dep_fax_num ,
              dep_fax_num2 ,
              dep_online_num ,
              dep_online_num2 ,
              dep_email ,
              dep_network_login ,
              dep_network_password ,
              dep_system_login ,
              dep_system_password ,
              dep_fax_batch_size ,
              dep_fax_batch_q_time ,
              dep_voice_mail ,
              dep_voice_mail_package ,
              dep_caller_id ,
              dep_caller_id_package ,
              dep_call_waiting ,
              dep_call_waiting_package ,
              dep_sms ,
              dep_sms_package ,
              dep_digital_feature ,
              dep_digital_feature_code ,
              x_mpn,
              x_mpn_code,
              x_pool_name,
              dep_rate_plan ,
              dep_end_user ,
              dep_pin ,
              dep_phone_manf ,
              dep_technology_flag ,
              dep_expidite ,
              dep_ld_provider ,
              dep_tux_iti_server ,
              dep_q_transaction ,
              dep_com_port ,
              dep_status ,         -- for now we have only 'S'
              dep_status_message ,
              dep_ota_type ,
              dep_rate_center_no ,
              dep_application_system ,
              dep_balance ,
              -- extra values
              dep_creation_date ,
              dep_update_date ,
              dep_blackout_wait ,
              ig_depend2ig_trans , -- transaction _id of IG_TX
              parent_action_item_id)
        VALUES( gw1.sequ_ig_tx_dependent.NEXTVAL,
               new_transaction_id_rec.transaction_id,
               task_rec.task_id ,
               trans_profile_rec.objid ,
               carrier_rec.x_carrier_id ,
               carrier_rec.x_state ,
               'R',
               old_min_rec.x_min,
               site_part_rec.x_min,
               site_part_rec.x_min,
               site_part_rec.x_zipcode ,
               site_part_rec.iccid,
               site_part_rec.x_service_id,
               sa.igate.f_get_hex_esn(site_part_rec.x_service_id),
               old_esn_rec.esn,
               sa.igate.f_get_hex_esn( old_esn_rec.esn),
               order_type_rec.x_ld_account_num,
               order_type_rec.x_market_code,
               order_type_rec.x_dealer_code,
               trans_profile_rec.TEMPLATE,
               trans_profile_rec.transmit_method,
               trans_profile_rec.fax_number,
               trans_profile_rec.fax_num2,
               trans_profile_rec.online_number,
               trans_profile_rec.online_num2,
               trans_profile_rec.email,
               trans_profile_rec.network_login,
               trans_profile_rec.network_password,
               trans_profile_rec.system_login,
               trans_profile_rec.system_password,
               trans_profile_rec.batch_delay_max,
               trans_profile_rec.batch_quantity,
               carr_feature_rec.voice_mail ,
               carr_feature_rec.voice_mail_package ,
               carr_feature_rec.caller_id ,
               carr_feature_rec.caller_id_package ,
               carr_feature_rec.call_waiting ,
               carr_feature_rec.call_waiting_package ,
               carr_feature_rec.sms ,
               carr_feature_rec.sms_package ,
               carr_feature_rec.digital_feature ,
               carr_feature_rec.digital_feature_code ,
               carr_feature_rec.mpn ,
               carr_feature_rec.mpn_code ,
               carr_feature_rec.pool_name,
               carr_feature_rec.x_rate_plan,
               call_trans_rec.x_call_trans2user,
               site_part_rec.x_pin,
               part_num_rec.x_manufacturer,
               substr(part_num_rec.x_technology ,1 ,1) ,
               task_rec.x_expedite,
               ld_rec.rsid,
               NULL,
               'Y' ,
               'Queued' ,
               'Q',
               NULL ,
               call_trans_rec.ota_activation,
               c_nap_rc_rec.rc_number,
               p_application_system,
               ld_rec.x_value,
               -- extra values
               sysdate,
               sysdate,
               sysdate,
               chk_need_dep_igtx_rec.transaction_id ,
               chk_need_dep_igtx_rec.action_item_id);
      END IF;
    CLOSE chk_need_dep_igtx_curs;
    INSERT INTO gw1.ig_transaction
        ( transaction_id,
          action_item_id ,
          trans_prof_key ,
          carrier_id ,
          state_field ,
          order_type ,
          old_min ,
          MIN ,
          msid ,
          zip_code ,
          iccid ,
          esn ,
          esn_hex ,
          old_esn ,
          old_esn_hex ,
          account_num ,
          market_code ,
          dealer_code ,
          TEMPLATE ,
          transmission_method ,
          fax_num ,
          fax_num2 ,
          online_num ,
          online_num2 ,
          email ,
          network_login ,
          network_password ,
          system_login ,
          system_password ,
          fax_batch_size ,
          fax_batch_q_time ,
          voice_mail ,
          voice_mail_package ,
          caller_id ,
          caller_id_package ,
          call_waiting ,
          call_waiting_package ,
          sms ,
          sms_package ,
          digital_feature ,
          digital_feature_code ,
          x_mpn,
          x_mpn_code,
          x_pool_name,
          rate_plan ,
          end_user ,
          pin,
          phone_manf ,
          technology_flag ,
          expidite ,
          ld_provider,
          tux_iti_server ,
          q_transaction,
          com_port ,
          status ,
          status_message ,
          ota_type ,
          rate_center_no ,     -- 04/29/05
          application_system , -- GSM Enhancement
          balance)
   VALUES(
       new_transaction_id_rec.transaction_id,
       task_rec.task_id ,
       trans_profile_rec.objid ,
       carrier_rec.x_carrier_id ,
       carrier_rec.x_state ,
       order_type,
       old_min_rec.x_min,
       site_part_rec.x_min,
       site_part_rec.x_min,
       site_part_rec.x_zipcode ,
       site_part_rec.iccid,
       site_part_rec.x_service_id,
       sa.igate.f_get_hex_esn(site_part_rec.x_service_id),
       old_esn_rec.esn,
       sa.igate.f_get_hex_esn( old_esn_rec.esn),
       order_type_rec.x_ld_account_num,
       order_type_rec.x_market_code,
       order_type_rec.x_dealer_code,
       trans_profile_rec.TEMPLATE,
       trans_profile_rec.transmit_method,
       trans_profile_rec.fax_number,
       trans_profile_rec.fax_num2,
       trans_profile_rec.online_number,
       trans_profile_rec.online_num2,
       trans_profile_rec.email,
       trans_profile_rec.network_login,
       trans_profile_rec.network_password,
       trans_profile_rec.system_login,
       trans_profile_rec.system_password,
       trans_profile_rec.batch_delay_max,
       trans_profile_rec.batch_quantity,
       carr_feature_rec.voice_mail ,
       carr_feature_rec.voice_mail_package ,
       carr_feature_rec.caller_id ,
       carr_feature_rec.caller_id_package ,
       carr_feature_rec.call_waiting ,
       carr_feature_rec.call_waiting_package ,
       carr_feature_rec.sms ,
       carr_feature_rec.sms_package ,
       carr_feature_rec.digital_feature ,
       carr_feature_rec.digital_feature_code ,
       carr_feature_rec.mpn ,
       carr_feature_rec.mpn_code ,
       carr_feature_rec.pool_name,
       carr_feature_rec.x_rate_plan,
       call_trans_rec.x_call_trans2user,
       site_part_rec.x_pin,
       part_num_rec.x_manufacturer,
       substr(part_num_rec.x_technology ,1 ,1) ,
       task_rec.x_expedite,
       ld_rec.rsid,
       NULL,
       'Y' ,
       'Queued' ,
       'Q',
       NULL ,
       call_trans_rec.ota_activation,
       c_nap_rc_rec.rc_number,
       p_application_system,
       ld_rec.x_value
       );
  dbms_output.put_line('order_type:'||order_type);
  IF order_type = 'EPIR' THEN
    INSERT INTO gw1.ig_transaction_addl_info(osp_account,
                       curr_addr_house_number,
                       curr_addr_direction,
                       curr_addr_street_name,
                       curr_addr_street_type,
                       curr_addr_unit,
                       transaction_id,
                       first_name,
                       middle_initial,
                       last_name,
                       SUFFIX,
                       prefix,
                       ssn_last_4,
                       address_1,
                       address_2,
                       city,
                       STATE,
                       zip_code,
                       country)
                VALUES(
                       alt_min_rec.ACCOUNT,
                       alt_min_rec.curr_addr_house_number,
                       alt_min_rec.curr_addr_direction,
                       alt_min_rec.curr_addr_street_name,
                       alt_min_rec.curr_addr_street_type,
                       alt_min_rec.curr_addr_unit,
                       new_transaction_id_rec.transaction_id,
                       alt_min_rec.first_name,
                       NULL,
                       alt_min_rec.last_name,
                       NULL,
                       NULL,
                       contact_rec.x_ss_number,
                       alt_min_rec.add1,
                       alt_min_rec.add2,
                       contact_rec.city,
                       contact_rec.STATE,
                       alt_min_rec.zip,
                       contact_rec.country);
  END IF;
  IF order_type IN ('PAP' ,'PCR' ,'ACR') THEN
    FOR bucket_type_rec IN (SELECT 'SERVICE_DAYS' bucket_type FROM dual UNION
                            SELECT 'VOICE_UNITS'  bucket_type FROM dual UNION
                            SELECT 'DATA_UNITS'   bucket_type FROM dual UNION
                            SELECT 'SMS_UNITS'    bucket_type FROM dual) LOOP
      dbms_output.put_line(bucket_type_rec.bucket_type);
      OPEN ig_bucket_curs(bucket_type_rec.bucket_type,carr_feature_rec.x_rate_plan);
        FETCH ig_bucket_curs INTO ig_bucket_rec;
      CLOSE ig_bucket_curs;
      OPEN bucket_curs(site_part_rec.x_service_id,bucket_type_rec.bucket_type);
        FETCH bucket_curs INTO bucket_rec;
        INSERT INTO gw1.ig_transaction_buckets (transaction_id ,
                                                bucket_id ,
                                                recharge_date ,
                                                bucket_balance ,
                                                bucket_value ,
                                                expiration_date)
                                        VALUES (new_transaction_id_rec.transaction_id,
                                                          CASE WHEN bucket_type_rec.bucket_type = 'SERVICE_DAYS' THEN
                                                                   NULL
                                                                 ELSE
                                                       ig_bucket_rec.bucket_id
                                                               END,
                                                NULL ,
                                                           CASE WHEN bucket_type_rec.bucket_type = 'DATA_UNITS' AND UPPER(ig_bucket_rec.measure_unit) = 'KB' THEN
                                                                   to_number(bucket_rec.x_value) * 1024 * 1024
                                                                 WHEN bucket_type_rec.bucket_type = 'VOICE_UNITS' THEN
                                                       to_number(bucket_rec.x_value) * 60
                                                     ELSE
                                                       to_number(bucket_rec.x_value)
                                                                 END,
                                                           CASE WHEN bucket_type_rec.bucket_type = 'DATA_UNITS' AND UPPER(ig_bucket_rec.measure_unit) = 'KB' THEN
                                                       to_number(bucket_rec.x_value) * 1024 * 1024
                                                               WHEN bucket_type_rec.bucket_type = 'VOICE_UNITS' THEN
                                                       to_number(bucket_rec.x_value) * 60
                                                                 ELSE
                                                       to_number(bucket_rec.x_value)
                                                                 END,
                                                site_part_rec.x_expire_dt);
      CLOSE bucket_curs;
    END LOOP;
  END IF;
EXCEPTION WHEN OTHERS THEN
  DECLARE
    hold1 VARCHAR2(300) := SQLCODE||':'||sqlerrm;
  BEGIN
    INSERT INTO error_table( error_text, error_date, action, KEY, program_name)
       VALUES( 'system error',sysdate,hold1,
                 p_task_objid,'igate.sp_insert_ig_transaction');
  END;
END ;
  ----------------------------------------------------------------------------------------------------
  -- CR6254 Start MEID retrieving
  ---------------------------------------------------------------------------------------------------
FUNCTION f_get_hex_esn(
    p_esn VARCHAR2)
  RETURN VARCHAR2
IS
  new_hex_meid VARCHAR2(30) := NULL;
  meid NUMBER :=0 ;
  CURSOR part_inst_curs
  IS
    SELECT pn.x_meid_phone,
      pi.x_hex_serial_no
    FROM table_part_num pn,
      table_mod_level ml,
      table_part_inst pi
    WHERE 1               = 1
    AND pn.objid          = ml.part_info2part_num
    AND ml.objid          = pi.n_part_inst2part_mod
    AND pi.part_serial_no = p_esn ;
BEGIN
  FOR part_inst_rec IN part_inst_curs
  LOOP
    new_hex_meid := part_inst_rec.x_hex_serial_no;
    meid         := part_inst_rec.x_meid_phone;
  END LOOP;
  -- The next code is used to calculate the hex meid value
  -- in case we dont get it from table_part_inst
  -- The function MEIDDECTOHEX works for Meid decimal numbers
  -- to convert them to a validate Meid hex number.
  -- The get_hex function is used for non Meid numbers to
  -- calculate the plain hex value.
  IF new_hex_meid   IS NULL THEN
      -- if it's an MEID number
    IF meid        = 1 THEN
      new_hex_meid := meiddectohex(p_esn);
    ELSE
      new_hex_meid := get_hex(p_esn);
    END IF;
  END IF;
  RETURN new_hex_meid;
END;
-- Exit function f_get_hex_meid
-- CR6254 End
----------------------------------------------------------------------------------------------------
PROCEDURE sp_get_hex(
    p_esn IN VARCHAR2 ,
    p_hex_esn OUT VARCHAR2 )
IS
BEGIN
  p_hex_esn := get_hex(p_esn);
END;
----------------------------------------------------------------------------------------------------
FUNCTION get_hex(
    p_esn IN VARCHAR2)
  RETURN VARCHAR2
IS
  esn_number NUMBER;
  var1       VARCHAR2(100) := NULL;
  var2       VARCHAR2(100) := NULL;
  hex_esn    VARCHAR2(30)  := NULL;
FUNCTION hex(
    p_str IN VARCHAR2)
  RETURN VARCHAR2
IS
  in_string  NUMBER        := p_str;
  bin_string VARCHAR2(100) := NULL;
  hex_string VARCHAR2(100) := NULL;
BEGIN
  FOR I IN 0 .. 35
  LOOP
    IF in_string                                   - POWER(2 ,(35 - I)) >= 0 THEN
      in_string                       := in_string - POWER(2 ,(35 - I));
      bin_string                      := bin_string || '1';
    ELSE
      bin_string := bin_string || '0';
    END IF;
  END LOOP;
  FOR I IN 0 .. 8
  LOOP
    dbms_output.put_line(substr(bin_string ,(I * 4) + 1 ,4));
    IF substr(bin_string ,(I                   * 4) + 1 ,4) = '0000' THEN
      hex_string                                           := hex_string || '0';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '0001' THEN
      hex_string                                           := hex_string || '1';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '0010' THEN
      hex_string                                           := hex_string || '2';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '0011' THEN
      hex_string                                           := hex_string || '3';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '0100' THEN
      hex_string                                           := hex_string || '4';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '0101' THEN
      hex_string                                           := hex_string || '5';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '0110' THEN
      hex_string                                           := hex_string || '6';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '0111' THEN
      hex_string                                           := hex_string || '7';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1000' THEN
      hex_string                                           := hex_string || '8';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1001' THEN
      hex_string                                           := hex_string || '9';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1010' THEN
      hex_string                                           := hex_string || 'A';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1011' THEN
      hex_string                                           := hex_string || 'B';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1100' THEN
      hex_string                                           := hex_string || 'C';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1101' THEN
      hex_string                                           := hex_string || 'D';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1110' THEN
      hex_string                                           := hex_string || 'E';
    ELSIF substr(bin_string ,(I * 4) + 1 ,4)                = '1111' THEN
      hex_string                                           := hex_string || 'F';
    END IF;
  END LOOP;
  hex_string := LTRIM(hex_string ,'0');
  RETURN hex_string;
END;
BEGIN
  dbms_output.put_line('esn:' || p_esn);
  --    esn_number := to_number(substr(p_esn,1,11));
  var1 := hex(substr(p_esn ,1 ,3));
  dbms_output.put_line('var1:' || var1);
  var2 := hex(substr(p_esn ,4 ,8));
  dbms_output.put_line('var2:' || var2);
  hex_esn := var1 || var2;
  dbms_output.put_line('hex_esn:' || hex_esn);
  RETURN hex_esn;
END;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_check_blackout(
    p_task_objid       IN NUMBER ,
    p_order_type_objid IN NUMBER ,
    p_black_out_code OUT NUMBER )
IS
BEGIN
  p_black_out_code := f_check_blackout(p_task_objid ,p_order_type_objid);
END;
----------------------------------------------------------------------------------------------------
FUNCTION f_check_blackout(
    p_task_objid       IN NUMBER ,
    p_order_type_objid IN NUMBER )
  RETURN NUMBER
IS
  l_seconds_from_sunday NUMBER := (sysdate - TRUNC(sysdate - to_number(to_char(sysdate ,'d')) + 1)) * 24 * 60 * 60;
  l_work_wk_objid       NUMBER;
  task_rec task_curs%rowtype;
  call_trans_rec call_trans_curs%rowtype;
  carrier_rec carrier_curs%rowtype;
  site_part_rec site_part_curs%rowtype;
  order_type_rec order_type_curs%rowtype;
  trans_profile_rec trans_profile_curs%rowtype;
BEGIN
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%notfound THEN
    CLOSE task_curs;
    RETURN 2;
  END IF;
  CLOSE task_curs;
  --
  OPEN order_type_curs(p_order_type_objid);
  FETCH order_type_curs INTO order_type_rec;
  IF order_type_curs%notfound THEN
    CLOSE order_type_curs;
    RETURN 5;
  END IF;
  CLOSE order_type_curs;
  --
  OPEN call_trans_curs(task_rec.x_task2x_call_trans);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%notfound THEN
    CLOSE call_trans_curs;
    RETURN 3;
  END IF;
  CLOSE call_trans_curs;
  --
  OPEN carrier_curs(order_type_rec.x_order_type2x_carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%notfound THEN
    CLOSE carrier_curs;
    RETURN 4;
  END IF;
  CLOSE carrier_curs;
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%notfound THEN
    CLOSE site_part_curs;
    RETURN 9;
  END IF;
  CLOSE site_part_curs;
  IF LTRIM(site_part_rec.state_value) IS NULL THEN
    site_part_rec.state_value         := 'ANALOG';
  END IF;
  --
  OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
  FETCH trans_profile_curs INTO trans_profile_rec;
  IF trans_profile_curs%notfound THEN
    CLOSE trans_profile_curs;
    RETURN 6;
  END IF;
  CLOSE trans_profile_curs;
  --
  IF site_part_rec.state_value = 'ANALOG' THEN
    l_work_wk_objid           := trans_profile_rec.x_trans_profile2wk_work_hr;
  ELSE
    l_work_wk_objid := trans_profile_rec.d_trans_profile2wk_work_hr;
  END IF;
  FOR hr_rec IN hr_curs(l_work_wk_objid)
  LOOP
    IF l_seconds_from_sunday BETWEEN hr_rec.start_time AND hr_rec.end_time THEN
      RETURN 1;
    END IF;
  END LOOP;
  RETURN 0;
  --
END f_check_blackout;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_get_ordertype(
    p_min           IN VARCHAR2 ,
    p_order_type    IN VARCHAR2 ,
    p_carrier_objid IN NUMBER ,
    p_technology    IN VARCHAR2 ,
    p_order_type_objid OUT NUMBER )
IS
  l_order_type VARCHAR2(100) := p_order_type;
  CURSOR o_type_curs ( c_npa IN VARCHAR2 ,c_nxx IN VARCHAR2 ,c_order_type IN VARCHAR2 ,c_carrier_objid IN NUMBER )
  IS
    SELECT
      /*+ index ( ot IND_ORDER_TYPE3 ) */
      ot.*
    FROM table_x_order_type ot ,
      table_x_carrier C
    WHERE ot.x_order_type2x_carrier = C.objid
    AND nvl(ot.x_npa ,-1)           = c_npa
    AND nvl(ot.x_nxx ,-1)           = c_nxx
    AND ot.x_order_type             = c_order_type
    AND C.objid                     = c_carrier_objid;
  o_type_rec o_type_curs%rowtype;
  CURSOR o_type_curs2 ( c_npa IN VARCHAR2 ,c_nxx IN VARCHAR2 ,c_order_type IN VARCHAR2 ,c_carrier_objid IN NUMBER )
  IS
    SELECT
      /*+ index ( ot IND_ORDER_TYPE3 ) */
      ot.*
    FROM table_x_order_type ot ,
      table_x_carrier C
    WHERE ot.x_order_type2x_carrier = C.objid
    AND nvl(ot.x_npa ,-1)           = -1
    AND nvl(ot.x_nxx ,-1)           = -1
    AND ot.x_order_type             = c_order_type
    AND C.objid                     = c_carrier_objid;
  o_type_rec2 o_type_curs2%rowtype;
  CURSOR rules_curs ( c_carrier_objid IN NUMBER ,c_tech IN VARCHAR2 )
  IS
    SELECT cr.*
    FROM table_x_carrier_rules cr ,
      table_x_carrier C
      --CR4579 Commented Out: WHERE cr.objid = c.carrier2rules
    WHERE cr.objid = decode(c_tech ,'GSM' ,C.carrier2rules_gsm ,'TDMA' ,C.carrier2rules_tdma ,'CDMA' ,C.carrier2rules_cdma ,C.carrier2rules)
    AND C.objid    = c_carrier_objid;
  rules_rec rules_curs%rowtype;
  cnt NUMBER := 0;
BEGIN
  --
  cnt := cnt + 1;
  dbms_output.put_line('sp_get_ordertype:' || cnt);
  --
  IF p_order_type = 'Return' THEN
    l_order_type := 'Deactivation';
  ELSE
    l_order_type := p_order_type;
  END IF;
  --
  cnt := cnt + 1;
  dbms_output.put_line('sp_get_ordertype:' || cnt);
  --
  OPEN o_type_curs(substr(p_min ,1 ,3) ,substr(p_min ,4 ,3) ,l_order_type ,p_carrier_objid);
  FETCH o_type_curs INTO o_type_rec;
  IF o_type_curs%found THEN
    p_order_type_objid := o_type_rec.objid;
    CLOSE o_type_curs;
    RETURN;
  END IF;
  CLOSE o_type_curs;
  --
  cnt := cnt + 1;
  dbms_output.put_line('sp_get_ordertype:' || cnt);
  dbms_output.put_line('sp_get_ordertype:' || cnt || ' l_order_type:' || l_order_type);
  dbms_output.put_line('sp_get_ordertype:' || cnt || ' p_carrier_objid:' || p_carrier_objid);
  --
  OPEN o_type_curs2(NULL ,NULL ,l_order_type ,p_carrier_objid);
  FETCH o_type_curs2 INTO o_type_rec2;
  IF o_type_curs2%notfound THEN
    p_order_type_objid := 0;
    --
    cnt := cnt + 1;
    dbms_output.put_line('1sp_get_ordertype:' || cnt);
    --
  ELSE
    OPEN rules_curs(p_carrier_objid ,p_technology);
    FETCH rules_curs INTO rules_rec;
    IF rules_curs%found THEN
      dbms_output.put_line('2sp_get_ordertype rules found:' || cnt);
      IF rules_rec.x_npa_nxx_flag > 0 THEN
        p_order_type_objid       := o_type_rec2.objid;
      ELSE
        p_order_type_objid := 0;
      END IF;
    ELSE
      dbms_output.put_line('1sp_get_ordertype rules not found:' || cnt);
      p_order_type_objid := 0;
    END IF;
    CLOSE rules_curs;
    --
    cnt := cnt + 1;
    dbms_output.put_line('2sp_get_ordertype:' || cnt);
    --
  END IF;
  CLOSE o_type_curs2;
END sp_get_ordertype;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_dispatch_queue(
    p_task_objid IN NUMBER ,
    p_queue_name IN VARCHAR2 ,
    p_dummy_out OUT NUMBER )
IS
  l_queue_name VARCHAR2(100) := p_queue_name;
  current_user_rec current_user_curs%rowtype;
  task_rec task_curs%rowtype;
  condition_rec condition_curs%rowtype;
  queue_rec queue_curs%rowtype;
  user2_rec user2_curs%rowtype;
  employee_rec employee_curs%rowtype;
  gbst_lst_rec gbst_lst_curs%rowtype;
  gbst_elm_rec gbst_elm_curs%rowtype;
  code_rec code_curs%rowtype;
BEGIN
  p_dummy_out    := 1;
  IF l_queue_name = 'Please Specify' THEN
    l_queue_name := 'Line Activation NoOrdTyp';
  END IF;
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  CLOSE current_user_curs;
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%notfound THEN
    CLOSE task_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%notfound THEN
    CLOSE condition_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  OPEN queue_curs(l_queue_name);
  FETCH queue_curs INTO queue_rec;
  IF queue_curs%notfound THEN
    CLOSE queue_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE queue_curs;
  --
  OPEN user2_curs(current_user_rec.USER);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%notfound THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%notfound THEN
    CLOSE employee_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Dispatch');
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  OPEN code_curs('DEFAULT QUEUE');
  FETCH code_curs INTO code_rec;
  IF code_curs%notfound THEN
    CLOSE code_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE code_curs;
  --
END sp_dispatch_queue;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_dispatch_case(
    p_case_objid IN NUMBER ,
    p_queue_name IN VARCHAR2 ,
    p_dummy_out OUT NUMBER )
IS
  current_user_rec current_user_curs%rowtype;
  case_rec case_curs%rowtype;
  condition_rec condition_curs%rowtype;
  user2_rec user2_curs%rowtype;
  employee_rec employee_curs%rowtype;
  gbst_lst_rec gbst_lst_curs%rowtype;
  gbst_elm_rec gbst_elm_curs%rowtype;
  queue_rec queue_curs%rowtype;
  l_act_entry_objid NUMBER;
  hold              NUMBER;
BEGIN
  p_dummy_out := 1;
  ----------------------------------------------------------------------------------------------------
  OPEN queue_curs(p_queue_name);
  FETCH queue_curs INTO queue_rec;
  IF queue_curs%notfound THEN
    CLOSE queue_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE queue_curs;
  --
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%notfound THEN
    current_user_rec.USER := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  OPEN case_curs(p_case_objid);
  FETCH case_curs INTO case_rec;
  IF case_curs%notfound THEN
    CLOSE case_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE case_curs;
  --
  OPEN condition_curs(case_rec.case_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%notfound THEN
    CLOSE condition_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  OPEN user2_curs(current_user_rec.USER);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%notfound THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%notfound THEN
    CLOSE employee_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%notfound THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Dispatch');
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%notfound THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  --Updates the Condition Record
  UPDATE table_condition
  SET condition = 10 ,
    queue_time  = sysdate ,
    title       = 'Open-Dispatch' ,
    s_title     = 'OPEN-DISPATCH'
  WHERE objid   = condition_rec.objid;
  UPDATE table_case
  SET case_currq2queue = queue_rec.objid
  WHERE objid          = p_case_objid;
  --Build the Activity Entry
  -- 04/10/03 select seq_act_entry.nextval +(power(2,28)) into l_act_entry_objid from dual;
  SELECT seq('act_entry')
  INTO l_act_entry_objid
  FROM dual;
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      proxy ,
      removed ,
      act_entry2case ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      l_act_entry_objid ,
      900 ,
      sysdate ,
      ' Dispatched to Queue '
      || p_queue_name ,
      current_user_rec.USER ,
      0 ,
      p_case_objid ,
      user2_rec.objid ,
      gbst_elm_rec.objid
    );
  --Build The time_bomb entry
  --
/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  INSERT INTO table_time_bomb
     (objid ,
      title ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      suppl_info ,
      time_period ,
      flags ,
      left_repeat ,
      report_title ,
      property_set ,
      users ,
      cmit_creator2employee)
    VALUES
     (seq('time_bomb') ,
      NULL ,
      TO_DATE('01/01/1753' ,'dd/mm/yyyy') ,
      SYSDATE ,
      p_case_objid ,
      0 ,
      NULL ,
      l_act_entry_objid ,
      655362 ,
      0 ,
      NULL ,
      NULL ,
      NULL ,
      employee_rec.objid);
*/
  --
END;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_close_case
  (
    p_case_id         VARCHAR2 ,
    p_user_login_name VARCHAR2 ,
    p_source          VARCHAR2 ,
    p_resolution_code VARCHAR2 ,
    p_status OUT VARCHAR2 ,
    p_msg OUT VARCHAR2
  )
IS
  v_current_date DATE := sysdate;
  v_case_id table_case.id_number%TYPE;
  v_user_objid NUMBER;
  CURSOR c_case
  IS
    SELECT C.* --, q.title queue_title
    FROM       --table_queue q,
      table_case C
      --    WHERE q.objid = case_currq2queue
      --    AND
    WHERE id_number = v_case_id;
  rec_case c_case%rowtype;
  CURSOR c_condition(c_condition_objid NUMBER)
  IS
    SELECT * FROM table_condition WHERE objid = c_condition_objid;
  rec_condition c_condition%rowtype;
  CURSOR c_subcase
  IS
    SELECT *
    FROM table_case2sub_cls
    WHERE (case_id = v_case_id)
    ORDER BY close_date DESC;
  CURSOR c_gbst_elm ( c_gbst_lst_title VARCHAR2 ,c_gbst_elm_title VARCHAR2 )
  IS
    SELECT ge.title elm_title ,
      ge.objid elm_objid ,
      ge.RANK ,
      gl.title lst_title ,
      gl.objid lst_objid
    FROM table_gbst_elm ge ,
      table_gbst_lst gl
    WHERE 1      = 1
    AND ge.title = c_gbst_elm_title
    AND gl.objid = ge.gbst_elm2gbst_lst
    AND gl.title = c_gbst_lst_title;
  CURSOR c_task ( c_esn VARCHAR2 ,c_min VARCHAR2 )
  IS
    SELECT T.*
    FROM table_condition C ,
      table_task T ,
      table_x_call_trans ct
    WHERE C.s_title
      || ''                   <> 'CLOSED ACTION ITEM'
    AND T.task_state2condition = C.objid
    AND ct.objid               = T.x_task2x_call_trans
    AND ct.x_action_type
      || ''            IN ('1' ,'2' ,'3' ,'5')
    AND ct.x_min        = c_min
    AND ct.x_service_id = c_esn;
  --CR4902
  CURSOR get_param_curs
  IS
    SELECT x_param_value
    FROM table_x_parameters
    WHERE x_param_name = 'CLOSE_CASE_SUCCESS';
  get_param_rec get_param_curs%rowtype;
  v_succ_notes VARCHAR2(2000);
  --CR4902
  v_seq_close_case      NUMBER;
  v_seq_act_entry       NUMBER;
  v_seq_time_bomb       NUMBER;
  v_resolution_gbst     VARCHAR2(80) := 'Resolution Code';
  v_resolution_default  VARCHAR2(80) := 'Carri Problem Solved';
  v_resolution_code     VARCHAR2(80);
  v_addl_info           VARCHAR2(255);
  v_actl_phone_time     NUMBER := 0;
  v_sub_actl_phone_time NUMBER := 0;
  v_sub_calc_phone_time NUMBER := 0;
  v_calc_phone_time     NUMBER := 0;
  v_tot_actl_phone_time NUMBER := 0;
  v_case_history        VARCHAR2(32000);
  rec_case_sts_closed c_gbst_elm%rowtype;
  rec_act_caseclose c_gbst_elm%rowtype;
  rec_act_accept c_gbst_elm%rowtype;
  rec_resolution_code c_gbst_elm%rowtype;
  hold NUMBER;
BEGIN
  v_case_id         := RTRIM(LTRIM(p_case_id));
  v_resolution_code := p_resolution_code;
  v_resolution_code := RTRIM(LTRIM(nvl(v_resolution_code ,' ')));
  --CR4902
  OPEN get_param_curs;
  FETCH get_param_curs INTO get_param_rec;
  IF get_param_curs%found THEN
    v_succ_notes := get_param_rec.x_param_value;
  ELSE
    v_succ_notes := NULL;
  END IF;
  CLOSE get_param_curs;
  --CR4902
  OPEN c_case;
  FETCH c_case INTO rec_case;
  IF c_case%notfound THEN
    p_status := 'F';
    p_msg    := 'CASE ' || nvl(p_case_id ,'<NULL>') || ' not found';
    CLOSE c_case;
    RETURN;
  END IF;
  CLOSE c_case;
  dbms_output.put_line('CASE ' || v_case_id || ' found.');
  BEGIN
    SELECT objid
    INTO v_user_objid
    FROM table_user
    WHERE s_login_name = UPPER(p_user_login_name);
  EXCEPTION
  WHEN OTHERS THEN
    p_status := 'F';
    p_msg    := 'User login name ' || p_user_login_name || ' not found.';
    RETURN;
  END;
  dbms_output.put_line('User login name ' || p_user_login_name || ' found.');
  dbms_output.put_line('length of resolution code: ' || LENGTH(v_resolution_code));
  --IF length(v_resolution_code) < 1 or v_resolution_code is null THEN
  IF nvl(LENGTH(v_resolution_code) ,0) < 1 THEN
    v_resolution_code                 := v_resolution_default;
  END IF;
  -- CR4831 -- by pass Resolution Code check if  p_resolution_code = 'Expired'
  IF p_resolution_code = 'Expired' THEN
    OPEN c_gbst_elm('Closed' ,'Expired');
    FETCH c_gbst_elm INTO rec_resolution_code;
  ELSE
    OPEN c_gbst_elm(v_resolution_gbst ,v_resolution_code);
    FETCH c_gbst_elm INTO rec_resolution_code;
  END IF;
  -- CR4831
  IF c_gbst_elm%notfound THEN
    p_status := 'F';
    p_msg    := 'Resolution code ' || v_resolution_code || ' is not valid';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  dbms_output.put_line('Resolution code: ' || v_resolution_code);
  OPEN c_condition(nvl(rec_case.case_state2condition ,0));
  FETCH c_condition INTO rec_condition;
  IF c_condition%notfound THEN
    p_status := 'F';
    p_msg    := 'CONDITION FOR CASE ' || v_case_id || ' not found.';
    CLOSE c_condition;
    RETURN;
  END IF;
  CLOSE c_condition;
  dbms_output.put_line('CONDITION objid FOR ' || v_case_id || ' is ' || rec_condition.objid);
  IF rec_condition.s_title LIKE 'CLOSED%' THEN
    p_status := 'F';
    p_msg    := 'Case ' || p_case_id || ' is already closed.';
    RETURN;
  END IF;
  -- CR4831 - Set as expired / Closed in case the 'p_resolution_code' = 'Expired'
  IF p_resolution_code = 'Expired' THEN
    OPEN c_gbst_elm('Closed' ,'Expired');
    FETCH c_gbst_elm INTO rec_case_sts_closed;
  ELSE
    OPEN c_gbst_elm('Closed' ,'Closed');
    FETCH c_gbst_elm INTO rec_case_sts_closed;
  END IF;
  -- CR4831
  IF c_gbst_elm%notfound THEN
    p_status := 'F';
    p_msg    := 'Status for closed case not found';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  dbms_output.put_line('Status for closed case found');
  OPEN c_gbst_elm('Activity Name' ,'Case Close');
  FETCH c_gbst_elm INTO rec_act_caseclose;
  IF c_gbst_elm%notfound THEN
    p_status := 'F';
    p_msg    := 'Activity code for closed case not found';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  OPEN c_gbst_elm('Activity Name' ,'Accept');
  FETCH c_gbst_elm INTO rec_act_accept;
  IF c_gbst_elm%notfound THEN
    p_status := 'F';
    p_msg    := 'Activity code for accepting case not found';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  dbms_output.put_line('Activity code for closed case not found');
  dbms_output.put_line('Start to close case:');
  IF rec_case.hangup_time IS NOT NULL THEN
    v_actl_phone_time     := (rec_case.hangup_time - rec_case.creation_time) * 24 * 60 * 60;
    IF v_actl_phone_time  IS NULL OR v_actl_phone_time < 0 THEN
      v_actl_phone_time   := 0;
    END IF;
  ELSE
    v_actl_phone_time := 0;
  END IF;
  FOR c_subcase_rec IN c_subcase
  LOOP
    v_sub_actl_phone_time := v_sub_actl_phone_time + nvl(c_subcase_rec.actl_phone_time ,0);
    v_sub_calc_phone_time := v_sub_calc_phone_time + nvl(c_subcase_rec.calc_phone_time ,0);
  END LOOP;
  v_actl_phone_time     := round(v_actl_phone_time + v_sub_actl_phone_time);
  v_calc_phone_time     := round(v_actl_phone_time + v_sub_calc_phone_time);
  v_tot_actl_phone_time := round(v_actl_phone_time);
  dbms_output.put_line('actl_phone_time: ' || v_actl_phone_time);
  dbms_output.put_line('calc_phone_time: ' || v_calc_phone_time);
  dbms_output.put_line('v_tot_actl_phone_time: ' || v_tot_actl_phone_time);
  -- find related TASK
  FOR c_task_rec IN c_task(rec_case.x_esn ,rec_case.x_min)
  LOOP
    dbms_output.put_line('Related ACTION ITEM FOUND, TASK_ID: ' || c_task_rec.task_id);
    dbms_output.put_line('c_task_rec.objid:' || c_task_rec.objid);
    sp_close_action_item(c_task_rec.objid ,0 ,hold);
  END LOOP;
  BEGIN
    UPDATE table_condition
    SET condition = 4 ,
      title       = 'Closed' ,
      s_title     = 'CLOSED'
    WHERE objid   = rec_condition.objid;
    --
    --    FOR upd_condition_rec IN ( SELECT rowid from table_condition
    --                               WHERE objid = rec_condition.objid for update nowait)
    --    LOOP
    --      UPDATE TABLE_CONDITION
    --      SET condition = 4, title='Closed', s_title='CLOSED'
    --      WHERE rowid = upd_condition_rec.rowid;
    --      AND   (  ( (mod(condition,16) >= 8) or (mod(condition,64) >= 32)
    --                   or (mod(condition,1024) >= 512)) );
    --      IF SQL%ROWCOUNT <=0 THEN
    --        p_status := 'F';
    --        p_msg := 'The record may have been changed, please refresh and try again.';
    --        RETURN;
    --      END IF;
    --    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := substr('Unable to update condition for case id ' || v_case_id || sqlerrm ,1 ,255);
    RETURN;
  END;
  dbms_output.put_line('Condition for Case id ' || v_case_id || ' updated.');
  v_case_history := rec_case.case_history;
  v_case_history := v_case_history || CHR(10) || '*** CASE CLOSE ' ||
  --CR3221 Start
  --         TO_CHAR (v_current_date, 'DD/MM/YY HH:MI:SS AM ') ||
  to_char(v_current_date ,'MM/DD/YYYY HH:MI:SS AM ') ||
  --CR3221 End
  p_user_login_name || ' FROM source "' || p_source || '"' || CHR(10) || v_succ_notes; --CR4902
  BEGIN
    UPDATE table_case
    SET case_currq2queue = NULL ,
      case_wip2wipbin    = NULL ,
      case_owner2user    = v_user_objid ,
      casests2gbst_elm   = rec_case_sts_closed.elm_objid ,
      case_history       = v_case_history
    WHERE objid          = rec_case.objid;
    --    FOR upd_rec_case IN (select rowid from table_case
    --                        where objid = rec_case.objid for update nowait)
    --    LOOP
    --     UPDATE table_case set case_currq2queue = NULL
    --                          ,case_wip2wipbin = NULL
    --                          ,case_owner2user = v_user_objid
    --                          ,casests2gbst_elm = rec_case_sts_closed.elm_objid
    --                          ,case_history = v_case_history
    --     WHERE rowid = upd_rec_case.rowid;
    --    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := substr('Unable to update case record for case id ' || v_case_id || ': ' || sqlerrm ,1 ,255);
    RETURN;
  END;

  dbms_output.put_line('Case record updated.');
  -- 04/10/03 SELECT SEQ_act_entry.nextval + power(2,28) INTO v_seq_act_entry from dual;
  SELECT seq('act_entry')
  INTO v_seq_act_entry
  FROM dual;

  v_addl_info := 'Status = Closed, Resolution Code =' || v_resolution_code || ' State = Open.';
  dbms_output.put_line('table_act_entry record: ' || CHR(10));
  dbms_output.put_line('OBJID : ' || v_seq_act_entry);
  dbms_output.put_line('ACT_CODE : ' || rec_act_caseclose.RANK);
  dbms_output.put_line('ENTRY_TIME : ' || v_current_date);
  dbms_output.put_line('ADDNL_INFO : ' || v_addl_info);
  dbms_output.put_line('ENTRY_NAME2GBST_ELM : ' || rec_act_caseclose.elm_objid);
  dbms_output.put_line('ACT_ENTRY2CASE : ' || rec_case.objid);
  dbms_output.put_line('ACT_ENTRY2USER : ' || v_user_objid);

  BEGIN
    INSERT
    INTO table_act_entry
      (
        objid ,
        act_code ,
        entry_time ,
        addnl_info ,
        proxy ,
        removed ,
        focus_type ,
        focus_lowid ,
        entry_name2gbst_elm ,
        act_entry2case ,
        act_entry2user
      )
      VALUES
      (
        v_seq_act_entry ,
        rec_act_caseclose.RANK ,
        v_current_date ,
        v_addl_info ,
        '' ,
        0 ,
        0 ,
        0 ,
        rec_act_caseclose.elm_objid ,
        rec_case.objid ,
        v_user_objid
      );
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := substr('Unable to create new activity record: ' || sqlerrm ,1 ,255);
    RETURN;
  END;
  -- 04/10/03 SELECT SEQ_close_case.nextval + power(2,28) INTO v_seq_close_case FROM dual;
  SELECT seq('close_case')
  INTO v_seq_close_case
  FROM dual;
  dbms_output.put_line('table_close_case record: ' || v_seq_close_case || CHR(10));
  dbms_output.put_line('OBJID : ' || v_seq_close_case);
  dbms_output.put_line('close_date : ' || v_current_date);
  dbms_output.put_line('actl_phone_time : ' || v_actl_phone_time);
  dbms_output.put_line('calc_phone_time : ' || v_calc_phone_time);
  dbms_output.put_line('tot_actl_phone_time : ' || v_tot_actl_phone_time);
  dbms_output.put_line('cls_old_stat2gbst_elm : ' || rec_case.casests2gbst_elm);
  dbms_output.put_line('cls_new_stat2gbst_elm : ' || rec_case_sts_closed.elm_objid);
  dbms_output.put_line('close_rsolut2gbst_elm : ' || rec_resolution_code.elm_objid);
  dbms_output.put_line('last_close2case : ' || rec_case.objid);
  dbms_output.put_line('closer2employee : ' || v_user_objid);
  dbms_output.put_line('close_case2act_entry : ' || v_seq_act_entry);
  BEGIN
    INSERT
    INTO table_close_case
      (
        objid ,
        close_date ,
        actl_phone_time ,
        calc_phone_time ,
        actl_rsrch_time ,
        calc_rsrch_time ,
        used_unit ,
        summary ,
        tot_actl_phone_time ,
        tot_actl_rsrch_time ,
        actl_bill_exp ,
        actl_nonbill ,
        calc_bill_exp ,
        calc_nonbill ,
        tot_actl_bill ,
        tot_actl_nonb ,
        bill_time ,
        nonbill_time ,
        previous_closed ,
        cls_old_stat2gbst_elm ,
        cls_new_stat2gbst_elm ,
        close_rsolut2gbst_elm ,
        last_close2case ,
        closer2employee ,
        close_case2act_entry
      )
      VALUES
      (
        v_seq_close_case ,
        v_current_date ,
        v_actl_phone_time ,
        v_calc_phone_time ,
        0 ,
        0 ,
        0.000000 ,
        '' ,
        v_tot_actl_phone_time ,
        0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0 ,
        0 ,
        TO_DATE('01/01/1753 00:00:00' ,'MM/DD/YYYY HH24:MI:SS') ,
        rec_case.casests2gbst_elm ,
        rec_case_sts_closed.elm_objid ,
        rec_resolution_code.elm_objid ,
        rec_case.objid ,
        v_user_objid ,
        v_seq_act_entry
      );
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := substr('Unable to create new close case record: ' || sqlerrm ,1 ,255);
    RETURN;
  END;
  --rollback;
  COMMIT;
  p_status := 'S';
  p_msg    := 'Completed sucessfully';
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_status := 'F';
  p_msg    := substr('Unexpected error detected when trying to close case ' || v_case_id || ': ' || sqlerrm ,1 ,255);
END sp_close_case;
----------------------------------------------------------------------------------------------------
PROCEDURE reopen_case_proc
  (
    p_case_objid      IN NUMBER ,
    p_queue_name      IN VARCHAR2 ,
    p_notes           IN VARCHAR2 ,
    p_user_login_name IN VARCHAR2 ,
    p_error_message OUT VARCHAR2
  )
IS
  -- To get Case and Condition of the Case
  CURSOR c_case
  IS
    SELECT cs.ROWID case_rowid ,
      cs.objid case_objid ,
      cs.case_history case_history ,
      cnd.s_title condition_s_title ,
      cnd.objid condition_objid
    FROM table_case cs ,
      table_condition cnd
    WHERE cnd.objid = cs.case_state2condition
    AND cs.objid    = p_case_objid;
  rec_case c_case%rowtype;
  -- To get objid from table_gbst_elm
  CURSOR c_act_entry
  IS
    SELECT objid
    FROM table_gbst_elm
    WHERE s_title         = 'REOPEN'
    AND gbst_elm2gbst_lst = 268435579;
  rec_act_entry c_act_entry%rowtype;
  -- To get the current User
  CURSOR c_user
  IS
    SELECT objid FROM table_user WHERE s_login_name = UPPER(p_user_login_name);
  c_user_objid table_user.objid%TYPE;
  -- local variables
  long_case_history table_case.case_history%TYPE;
  n_dummy_out NUMBER;
BEGIN
  -- input proc params:
  -- p_queue_name := 'LINE MANAGEMENT';
  p_error_message := '';
  -- get Gbst_elm record.
  OPEN c_act_entry;
  FETCH c_act_entry INTO rec_act_entry;
  IF c_act_entry%notfound THEN
    p_error_message := 'ACT ENTRY TYPE for REOPEN not found';
    CLOSE c_act_entry;
    -------
    -- * --
    -------
    RETURN;
  END IF;
  CLOSE c_act_entry;
  -- get Case details.
  OPEN c_case;
  FETCH c_case INTO rec_case;
  IF c_case%notfound THEN
    p_error_message := 'Case not found';
    CLOSE c_case;
    -------
    -- * --
    -------
    RETURN;
  ELSE
    -- Check if the case is still open
    IF rec_case.condition_s_title <> 'CLOSED' THEN
      p_error_message             := 'Case is Still Open';
      CLOSE c_case; --Fix OPEN_CURSORS
      -------
      -- * --
      -------
      RETURN;
    END IF;
    CLOSE c_case; --Fix OPEN_CURSORS
    -- Get the user info
    OPEN c_user;
    FETCH c_user INTO c_user_objid;
    IF c_user%notfound THEN
      p_error_message := 'Unable to reopen case. User login name ' || p_user_login_name || ' not found in table_user.';
      CLOSE c_user;
      -------
      -- * --
      -------
      RETURN;
    END IF;
    CLOSE c_user;
    -- Update table case
    long_case_history := rec_case.case_history;
    long_case_history := long_case_history || CHR(10) || CHR(13) || '*** Notes ' || sysdate || ' ' || p_notes;
    UPDATE table_case
    SET case_history   = long_case_history ,
      casests2gbst_elm =
      (SELECT objid
      FROM table_gbst_elm
      WHERE s_title         = 'PENDING'
      AND gbst_elm2gbst_lst = 268435562
      ) ,
      case_wip2wipbin =
      (SELECT objid
      FROM table_wipbin
      WHERE s_title         = 'DEFAULT'
      AND wipbin_owner2user =
        (SELECT objid FROM table_user WHERE s_login_name = 'SA'
        )
      )
    WHERE ROWID = rec_case.case_rowid;
    -- Update table condition
    UPDATE table_condition
    SET s_title = 'OPEN' ,
      title     = 'Open' ,
      condition = 2
    WHERE objid = rec_case.condition_objid;
    -- Insert act_entry to leave log of the 'no Line Available'
    INSERT
    INTO table_act_entry
      (
        objid ,
        act_code ,
        entry_time ,
        addnl_info ,
        act_entry2case ,
        act_entry2user ,
        entry_name2gbst_elm
      )
      VALUES
      (
        seq('act_entry') ,
        2400 ,
        sysdate ,
        'with Condition of Open and Status of Pending.' ,
        rec_case.case_objid ,
        c_user_objid ,
        rec_act_entry.objid
      );
    -- Dispatch the case (this procedure will, among other things, update queue name on table_case...)
    sp_dispatch_case(rec_case.case_objid ,p_queue_name ,n_dummy_out);
    COMMIT;
  END IF; -- ...IF c_case%NOTFOUND
END reopen_case_proc;
PROCEDURE call_sp_determine_trans_method
  (
    p_action_item_objid  IN NUMBER ,
    p_order_type         IN VARCHAR2 ,
    p_trans_method       IN VARCHAR2 ,
    p_application_system IN VARCHAR2 DEFAULT 'IG' ,
    p_destination_queue OUT NUMBER
  )
IS
BEGIN
  /*
  |  Wrapper procedure to call sp_determine_trans_method from the Clarify software.
  |  OUT parameter in the procedure declaration has to be the last parametar or
  |  the procedure can't be called from Clarify.
  */
  sp_determine_trans_method(p_action_item_objid => p_action_item_objid ,p_order_type => p_order_type ,p_trans_method => p_trans_method ,p_application_system => p_application_system ,p_destination_queue => p_destination_queue);
END call_sp_determine_trans_method;
-- CR15565 Starts PMistry 02/17/2011 Instead of Rate Plan the same function will return Carrier Feature Objid.
-- NET10_PAYGO STARTS
FUNCTION sf_get_carr_feat
  (
    p_order_type         IN VARCHAR2 ,
    p_st_esn_flag        IN VARCHAR2 ,
    p_site_part_objid    IN NUMBER ,
    p_esn                IN VARCHAR2 ,
    p_carrier_objid      IN NUMBER ,
    p_carr_feature_objid IN NUMBER ,
    p_data_capable       IN VARCHAR2 ,
    p_template           IN VARCHAR2 ,
    p_service_plan_id    IN NUMBER DEFAULT NULL -- SPRINT
  )
  RETURN NUMBER
IS
  l_r_rateplan ig_transaction.rate_plan%TYPE;
  l_rate_plan ig_transaction.rate_plan%TYPE;
  l_cf_objid sa.table_x_carrier_features.objid%TYPE;                    -- CR15565 PMistry 02/17/2011
  l_service_plan_id sa.x_service_plan_site_part.x_service_plan_id%TYPE; -- SPRINT
  l_have_service_plans sa.table_x_parameters.x_param_value%TYPE;        -- CR20451 | CR20854: Add TELCEL Brand
  -- NET10MC Ends
  CURSOR parent_curs_local(p_x_call_trans2carrier IN NUMBER)
  IS
    SELECT P.*
    FROM table_x_parent P ,
      table_x_carrier_group G ,
      table_x_carrier C
    WHERE P.objid = G.x_carrier_group2x_parent
    AND G.objid   = C.carrier2carrier_group
    AND C.objid   = p_x_call_trans2carrier;
  parent_rec parent_curs_local%rowtype;
  l_is_mc NUMBER;
  -- CR13919 Start.
  CURSOR cu_get_reserve_pin
  IS
    SELECT pi_pin.x_red_code ,
      pi_pin.objid pin_objid
    FROM table_part_inst pi_pin ,
      table_part_inst pi_esn ,
      table_part_num pn_esn ,
      table_mod_level ml_esn
    WHERE 1                          = 1
    AND pi_pin.x_part_inst_status    = '40'
    AND pi_pin.part_to_esn2part_inst = pi_esn.objid
    AND pi_esn.part_serial_no        = p_esn
    AND ml_esn.part_info2part_num    = pn_esn.objid
    AND pi_esn.n_part_inst2part_mod  = ml_esn.objid
    ORDER BY pi_pin.last_trans_time;
  rec_get_reserve_pin cu_get_reserve_pin%rowtype;
  -- CR13919 End.
  -- TFNT750A Start
  CURSOR cu_esn_dtl
  IS
    SELECT get_param_by_name_fun(pc.NAME ,'DATA_SPEED') part_class_param ,
      pn.x_technology ,
      pn.x_data_capable x_data -- CR16193 04/18/2011
      --CR18794 Start kacosta 11/7/2011
      ,
      pn.part_num2bus_org bus_org_objid
      --CR18794 End kacosta 11/7/2011
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_part_class pc
    WHERE 1               = 1
    AND pi.part_serial_no = p_esn
    AND ml.objid          = pi.n_part_inst2part_mod
    AND pn.objid          = ml.part_info2part_num
    AND pc.objid          = pn.part_num2part_class;
  rec_esn_dtl cu_esn_dtl%rowtype;
  l_data NUMBER;
  -- TFNT750A End
BEGIN
  -- NET10MC STARTS
  -- to determine rateplan for NET10 Mega Card / 750 to and from Pay Go
  -- order type will be 'Rate Plan Change' - 'R'
  SELECT COUNT(1)
  INTO l_is_mc
  FROM x_service_plan_site_part spsp ,
    x_service_plan sp
  WHERE sp.objid              = spsp.x_service_plan_id
--  AND SP.MKT_NAME            IN ('Net10 Mega Card' ,'Net10 Mega Card 750 Minutes' ,'Net10 Mega Card BYOP' ,'Net10 Unlimited ILD') --CR19552/CR19853
  AND sp.mkt_name LIKE ('Net10%') AND ivr_plan_id NOT IN '999' -- CR22487 NET10 HP include all mega card, 750 , Unlimited and Unlimited ILD
  AND spsp.table_site_part_id = p_site_part_objid;
  -- CR13919 Start.
  OPEN cu_get_reserve_pin;
  FETCH cu_get_reserve_pin INTO rec_get_reserve_pin;
  CLOSE cu_get_reserve_pin;
  -- CR13919 End.
  OPEN parent_curs_local(p_carrier_objid);
  FETCH parent_curs_local INTO parent_rec;
  CLOSE parent_curs_local;
  -- TFNT750A Start
  OPEN cu_esn_dtl;
  FETCH cu_esn_dtl INTO rec_esn_dtl;
  CLOSE cu_esn_dtl;
  IF rec_esn_dtl.part_class_param <> 'NOT FOUND' THEN
    l_data                        := to_number(rec_esn_dtl.part_class_param); -- CR16193 04/18/2011
  END IF;
  -- TFNT750A End
  -- SPRINT STARTS
  ---  Here the x_service_plan_id is KNOWN (P_SERVICE_PLAN_ID)
  ---  but X_SERVICE_PLAN_SITE_PART will NOT be created by java process yet due to some dependency
  ---  hence the below logic is modified indepedent of X_SERVICE_PLAN_SITE_PART
  ---  And also we need to improvise this function to be independent of order type (if possible)
  --
  l_service_plan_id := p_service_plan_id;
  --
  IF p_service_plan_id IS NULL THEN
    --
    BEGIN
      -- The combination of site part objid + service plan id in this x_service_plan_site_part table will be unique
      SELECT spsp.x_service_plan_id
      INTO l_service_plan_id
      FROM x_service_plan_site_part spsp ,
        table_site_part tsp ,
        x_service_plan sp
      WHERE spsp.table_site_part_id = tsp.objid
      AND sp.objid                  = spsp.x_service_plan_id
      AND tsp.objid                 = p_site_part_objid
      AND ROWNUM                    < 2;
      --
    EXCEPTION
    WHEN OTHERS THEN
      --
      NULL;
      --
    END;
    --
  END IF;
  IF ((p_order_type IN ('E' ,'R' ,'EPIR' ,'PIR' ,'IPI') OR -- CR17793 to remove PPIR
    (p_order_type    = 'A' AND p_template <> 'SUREPAY')) AND l_is_mc = 1) THEN
    BEGIN
      SELECT cf_objid
      INTO l_cf_objid
      FROM
        (SELECT 1 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND (l_data                 = xcf.x_data)       -- CR19552
        AND xcf.x_feature2x_carrier = p_carrier_objid
        AND mtm.PRIORITY           IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          )
        AND ROWNUM < 2
        UNION
        SELECT 2 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND xcf.x_data              = p_data_capable
        AND xcf.x_feature2x_carrier = p_carrier_objid
        AND mtm.PRIORITY           IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          )
        AND ROWNUM < 2
        UNION
        SELECT 3 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                      = 1
        AND xcf.objid                = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id    = l_service_plan_id -- SPRINT
        AND (l_data                  = xcf.x_data)       -- CR19552
        AND xcf.x_feature2x_carrier IN
          (SELECT C.objid
          FROM table_x_carrier_group cg ,
            table_x_parent P ,
            table_x_carrier C
          WHERE cg.x_carrier_group2x_parent = P.objid
          AND C.carrier2carrier_group       = cg.objid
          AND x_parent_id                   = parent_rec.x_parent_id
          )
        AND mtm.PRIORITY IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          )
        AND ROWNUM < 2
        UNION
        SELECT 4 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                      = 1
        AND xcf.objid                = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id    = l_service_plan_id -- SPRINT
        AND xcf.x_data               = p_data_capable
        AND xcf.x_feature2x_carrier IN
          (SELECT C.objid
          FROM table_x_carrier_group cg ,
            table_x_parent P ,
            table_x_carrier C
          WHERE cg.x_carrier_group2x_parent = P.objid
          AND C.carrier2carrier_group       = cg.objid
          AND x_parent_id                   = parent_rec.x_parent_id
          )
        AND mtm.PRIORITY IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          )
        AND ROWNUM < 2
        UNION
        SELECT 5 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                      = 1
        AND xcf.objid                = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id    = l_service_plan_id -- SPRINT
        AND (l_data                  = xcf.x_data)       -- CR19552
        AND xcf.x_feature2x_carrier IN
          (SELECT C.objid
          FROM table_x_carrier_group cg ,
            table_x_parent P ,
            table_x_carrier C
          WHERE cg.x_carrier_group2x_parent = P.objid
          AND C.carrier2carrier_group       = cg.objid
          AND x_parent_id                   = parent_rec.x_parent_id
          )
        AND mtm.PRIORITY = 1
        AND ROWNUM       < 2
        UNION
        SELECT 6 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                      = 1
        AND xcf.objid                = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id    = l_service_plan_id -- SPRINT
        AND xcf.x_data               = p_data_capable
        AND xcf.x_feature2x_carrier IN
          (SELECT C.objid
          FROM table_x_carrier_group cg ,
            table_x_parent P ,
            table_x_carrier C
          WHERE cg.x_carrier_group2x_parent = P.objid
          AND C.carrier2carrier_group       = cg.objid
          AND x_parent_id                   = parent_rec.x_parent_id
          )
        AND mtm.PRIORITY = 1
        AND ROWNUM       < 2
        UNION
        SELECT 7 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM table_x_carrier_features xcf ,
          mtm_sp_carrierfeatures mtm
        WHERE (l_data                 = xcf.x_data) -- CR19552
        AND xcf.x_feature2x_carrier   = p_carrier_objid
        AND mtm.x_carrier_features_id = xcf.objid
        AND ROWNUM                    < 2
        UNION
        SELECT 8 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM table_x_carrier_features xcf ,
          mtm_sp_carrierfeatures mtm
        WHERE xcf.x_data              = p_data_capable
        AND xcf.x_feature2x_carrier   = p_carrier_objid
        AND mtm.x_carrier_features_id = xcf.objid
        AND ROWNUM                    < 2
        UNION
        SELECT 9 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM table_x_carrier_features xcf ,
          mtm_sp_carrierfeatures mtm
        WHERE (l_data                = xcf.x_data) -- CR19552
        AND xcf.x_feature2x_carrier IN
          (SELECT C.objid
          FROM table_x_carrier_group cg ,
            table_x_parent P ,
            table_x_carrier C
          WHERE cg.x_carrier_group2x_parent = P.objid
          AND C.carrier2carrier_group       = cg.objid
          AND x_parent_id                   = parent_rec.x_parent_id
          )
        AND mtm.x_carrier_features_id = xcf.objid
        AND ROWNUM                    < 2
        UNION
        SELECT 10 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM table_x_carrier_features xcf ,
          mtm_sp_carrierfeatures mtm
        WHERE xcf.x_data             = p_data_capable
        AND xcf.x_feature2x_carrier IN
          (SELECT C.objid
          FROM table_x_carrier_group cg ,
            table_x_parent P ,
            table_x_carrier C
          WHERE cg.x_carrier_group2x_parent = P.objid
          AND C.carrier2carrier_group       = cg.objid
          AND x_parent_id                   = parent_rec.x_parent_id
          )
        AND mtm.x_carrier_features_id = xcf.objid
        AND ROWNUM                    < 2
        ORDER BY 1
        )
      WHERE ROWNUM < 2;
    EXCEPTION
    WHEN no_data_found THEN
      l_cf_objid := NULL;
    WHEN OTHERS THEN
      l_cf_objid := NULL;
    END;
  END IF;
  -- NET10MC ENDS
  --                      carr_feature_rec.x_rate_plan,
  --ST_BUNDLE_II Starts 10/14/09
  --6/11/09 rate plan change for switch base STUL
  -- PIR -- CR12155 ST_BUNDLE_III -- l_st_esn_count =1 means it is ST ESN
  -- CR13531 Add new order type introduced for ST Cust. Care.
  IF (p_order_type IN ('E' ,'PIR' ,'CR' ,'CRU' ,'EU' ,'PCR' ,'ACR' ,'EPIR' ,'IPI' ,'SIMC' ,'MINC' ,'EC' ,'S' ,'D') OR -- CR17793 to remove PPIR
    (p_order_type   = 'A' AND p_template <> 'SUREPAY')) AND p_st_esn_flag = 1 THEN
    -- ST_GSM added 'CR','A' , --WSRD , CR15035 added 'S','D'
    BEGIN
      -- Query chnage with reference to CR13348
      -- TFNT750A Start
      SELECT cf_objid
      INTO l_cf_objid
      FROM
        (SELECT 1 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND xcf.x_feature2x_carrier = p_carrier_objid   -- ST_GSM
        AND (l_data                 = xcf.x_data)
        AND mtm.PRIORITY           IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          ) --= 1  -- THIS MUST be 1
        AND ROWNUM < 2
        UNION
        SELECT 2 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND xcf.x_feature2x_carrier = p_carrier_objid   -- ST_GSM
        AND xcf.x_data              = rec_esn_dtl.x_data
        AND mtm.PRIORITY           IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          ) --= 1  -- THIS MUST be 1
        AND ROWNUM < 2
        UNION
        SELECT 3 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND xcf.x_feature2x_carrier = p_carrier_objid   -- ST_GSM
        AND (l_data                 = xcf.x_data)
        AND mtm.PRIORITY            = 1
        AND ROWNUM                  < 2
        UNION
        SELECT 4 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND xcf.x_feature2x_carrier = p_carrier_objid   -- ST_GSM
        AND xcf.x_data              = rec_esn_dtl.x_data
        AND mtm.PRIORITY            = 1
        AND ROWNUM                  < 2
        ORDER BY 1
        )
      WHERE ROWNUM < 2;
      -- TFNT750A End
    EXCEPTION
    WHEN OTHERS THEN
      l_cf_objid := NULL;
    END;
    RETURN l_cf_objid;
    -- CR15035 added 'S','D' below
  ELSIF p_order_type IN ('AP' ,'PAP' ,'CR' ,'CRU' ,'EU' ,'DB' ,'S' ,'D') OR (p_order_type = 'A' AND p_template = 'SUREPAY') THEN
    --6/11/09 rate plan change for switch base STUL
    -- Query chnage with reference to CR13348
    BEGIN
      -- TFNT750A Start
      SELECT cf_objid
      INTO l_cf_objid
      FROM
        (SELECT 1 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND xcf.x_feature2x_carrier = p_carrier_objid   -- ST_GSM
        AND (l_data                 = xcf.x_data
        AND p_st_esn_flag           = 1)
        AND mtm.PRIORITY           IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          ) --= 1  -- THIS MUST be 1
        AND ROWNUM < 2
        UNION
        SELECT 2 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                   = 1
        AND xcf.objid             = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id = l_service_plan_id -- SPRINT
        AND (xcf.x_data           = rec_esn_dtl.x_data
        AND p_st_esn_flag         = 1)
        AND mtm.PRIORITY         IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = l_service_plan_id
            ) ,1) PRIORITY
          FROM dual
          ) --= 1  -- THIS MUST be 1
        AND ROWNUM < 2
        UNION
        SELECT 3 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                     = 1
        AND xcf.objid               = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id   = l_service_plan_id -- SPRINT
        AND xcf.x_feature2x_carrier = p_carrier_objid   -- ST_GSM
        AND (l_data                 = xcf.x_data
        AND p_st_esn_flag           = 1)
        AND mtm.PRIORITY            = 1
        AND ROWNUM                  < 2
        UNION
        SELECT 4 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid -- ST_BUNDLE_II for EPIR
        FROM mtm_sp_carrierfeatures mtm ,
          table_x_carrier_features xcf
        WHERE 1                   = 1
        AND xcf.objid             = mtm.x_carrier_features_id + 0
        AND mtm.x_service_plan_id = l_service_plan_id -- SPRINT
        AND mtm.PRIORITY          = 1
        AND (xcf.x_data           = rec_esn_dtl.x_data
        AND p_st_esn_flag         = 1)
        AND ROWNUM                < 2
        ORDER BY 1
        )
      WHERE ROWNUM < 2;
      -- TFNT750A End
    EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE ('ERRNO - '||SQLERRM);
      l_cf_objid := NULL;
    END;
    RETURN l_cf_objid;
  ELSIF (p_order_type IN ('E' ,'R' ,'EPIR' ,'PIR' ,'IPI') OR -- CR17793 to remove PPIR
    p_order_type       = 'A' AND p_template <> 'SUREPAY') AND l_is_mc = 1 THEN
    RETURN l_cf_objid; -- NET10MC
    -- CR13919 Start.
  ELSIF (p_order_type             IN ('EPIR' ,'PIR' ,'IPI') AND -- CR17793 to remove PPIR
    rec_get_reserve_pin.pin_objid IS NOT NULL) THEN
    BEGIN
      SELECT cf_objid
      INTO l_cf_objid
      FROM
        (SELECT 1 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM table_part_inst pi_pin ,
          table_mod_level ml_pin ,
          table_part_num pn_pin ,
          table_bus_org bo_pin ,
          table_part_class pc_pin ,
          mtm_partclass_x_spf_value_def mtmspfv_pin ,
          x_serviceplanfeature_value spfv_pin ,
          x_service_plan_feature spf_pin ,
          x_service_plan sp_pin ,
          mtm_sp_carrierfeatures mtm_cf ,
          table_x_carrier_features xcf
        WHERE 1                               = 1
        AND ml_pin.objid                      = pi_pin.n_part_inst2part_mod
        AND pn_pin.objid                      = ml_pin.part_info2part_num
        AND bo_pin.objid                      = pn_pin.part_num2bus_org
        AND pc_pin.objid                      = pn_pin.part_num2part_class
        AND mtmspfv_pin.part_class_id         = pc_pin.objid
        AND mtmspfv_pin.spfeaturevalue_def_id = spfv_pin.value_ref
        AND spfv_pin.spf_value2spf            = spf_pin.objid
        AND spf_pin.sp_feature2service_plan   = sp_pin.objid
        AND pi_pin.objid                      = rec_get_reserve_pin.pin_objid
        AND mtm_cf.x_service_plan_id          = sp_pin.objid
        AND xcf.objid                         = mtm_cf.x_carrier_features_id
        AND mtm_cf.PRIORITY                  IN
          (SELECT nvl(
            (SELECT x_priority
            FROM x_multi_rate_plan_esns
            WHERE x_esn           = p_esn
            AND x_service_plan_id = sp_pin.objid
            ) ,1) PRIORITY
          FROM dual
          )
        AND xcf.x_data              = p_data_capable
        AND xcf.x_feature2x_carrier = p_carrier_objid
        UNION
        SELECT 2 sort_order ,
          xcf.x_rate_plan ,
          xcf.objid cf_objid
        FROM table_part_inst pi_pin ,
          table_mod_level ml_pin ,
          table_part_num pn_pin ,
          table_bus_org bo_pin ,
          table_part_class pc_pin ,
          mtm_partclass_x_spf_value_def mtmspfv_pin ,
          x_serviceplanfeature_value spfv_pin ,
          x_service_plan_feature spf_pin ,
          x_service_plan sp_pin ,
          mtm_sp_carrierfeatures mtm_cf ,
          table_x_carrier_features xcf
        WHERE 1                               = 1
        AND ml_pin.objid                      = pi_pin.n_part_inst2part_mod
        AND pn_pin.objid                      = ml_pin.part_info2part_num
        AND bo_pin.objid                      = pn_pin.part_num2bus_org
        AND pc_pin.objid                      = pn_pin.part_num2part_class
        AND mtmspfv_pin.part_class_id         = pc_pin.objid
        AND mtmspfv_pin.spfeaturevalue_def_id = spfv_pin.value_ref
        AND spfv_pin.spf_value2spf            = spf_pin.objid
        AND spf_pin.sp_feature2service_plan   = sp_pin.objid
        AND pi_pin.objid                      = rec_get_reserve_pin.pin_objid
        AND mtm_cf.x_service_plan_id          = sp_pin.objid
        AND xcf.objid                         = mtm_cf.x_carrier_features_id
        AND mtm_cf.PRIORITY                   = 1
        AND xcf.x_data                        = p_data_capable
        AND xcf.x_feature2x_carrier           = p_carrier_objid
        )
      WHERE ROWNUM < 2;
    EXCEPTION
    WHEN OTHERS THEN
      l_cf_objid := NULL;
    END;
    RETURN l_cf_objid;
    -- CR13919 End.
  ELSE
    --CR14427 and CR18794 Start KACOSTA 11/07/2011
    --BEGIN
    --   SELECT objid cf_objid
    --   INTO   l_cf_objid
    --   FROM   TABLE_X_CARRIER_FEATURES
    --   where  objid = P_CARR_FEATURE_OBJID;
    --
    --   EXCEPTION
    --     WHEN OTHERS THEN
    --       l_cf_objid  := null;
    --END;
    -- CR20451 | CR20854: Add TELCEL Brand
    -- IF (sa.bau_util_pkg.get_esn_brand(p_esn => p_esn) IN('NET10','STRAIGHT_TALK')) THEN
    SELECT x_param_value
    INTO l_have_service_plans
    FROM table_x_parameters
    WHERE x_param_name                                                                    = 'HAVE_SERVICE_PLANS';
    IF nvl(instr(l_have_service_plans ,sa.bau_util_pkg.get_esn_brand(p_esn => p_esn)) ,0) > 0 THEN
      --
      dbms_output.put_line('5. ESN, ORG_ID see table_x_parameters.HAVE_SERVICE_PLANS, service plan, ESN carrier, data, technology');
      --dbms_output.put_line('5. ESN either NET10 or STRAIGHT_TALK, service plan, ESN carrier, data, technology');
      --
      BEGIN
        --
        SELECT cf_objid
        INTO l_cf_objid
        FROM
          ( --based on exception table, service plan, ESN carrier, data speed, technology
          SELECT DISTINCT 1 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          JOIN x_multi_rate_plan_esns rpe
          ON msc.x_service_plan_id    = rpe.x_service_plan_id
          AND msc.PRIORITY            = rpe.x_priority
          WHERE 1                     = 1
          AND psp.table_site_part_id  = p_site_part_objid
          AND xcf.x_feature2x_carrier = p_carrier_objid
          AND xcf.x_data              = l_data
          AND xcf.x_technology        = rec_esn_dtl.x_technology
          AND rpe.x_esn               = p_esn
          UNION
          --based on exception table, service plan, ESN carrier parent, data speed, technology
          SELECT DISTINCT 2 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          JOIN x_multi_rate_plan_esns rpe
          ON msc.x_service_plan_id   = rpe.x_service_plan_id
          AND msc.PRIORITY           = rpe.x_priority
          WHERE 1                    = 1
          AND psp.table_site_part_id = p_site_part_objid
          AND EXISTS
            (SELECT 1
            FROM table_x_carrier txc
            JOIN table_x_carrier_group xcg
            ON txc.carrier2carrier_group = xcg.objid
            JOIN table_x_carrier_group xcg_child
            ON xcg.x_carrier_group2x_parent = xcg_child.x_carrier_group2x_parent
            JOIN table_x_carrier txc_child
            ON xcg_child.objid  = txc_child.carrier2carrier_group
            WHERE txc.objid     = p_carrier_objid
            AND txc_child.objid = xcf.x_feature2x_carrier
            )
          AND xcf.x_data       = l_data
          AND xcf.x_technology = rec_esn_dtl.x_technology
          AND rpe.x_esn        = p_esn
          UNION
          --based on priority 1, service plan, ESN carrier, data speed, technology
          SELECT DISTINCT 3 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          WHERE 1                      = 1
          AND psp.table_site_part_id   = p_site_part_objid
          AND msc.PRIORITY             = 1
          AND xcf.x_feature2x_carrier  = p_carrier_objid
          AND xcf.x_data               = l_data
          AND xcf.x_technology         = rec_esn_dtl.x_technology
          UNION
          --based on priority 1, service plan, ESN carrier parent, data speed, technology
          SELECT DISTINCT 4 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          WHERE 1                      = 1
          AND psp.table_site_part_id   = p_site_part_objid
          AND msc.PRIORITY             = 1
          AND EXISTS
            (SELECT 1
            FROM table_x_carrier txc
            JOIN table_x_carrier_group xcg
            ON txc.carrier2carrier_group = xcg.objid
            JOIN table_x_carrier_group xcg_child
            ON xcg.x_carrier_group2x_parent = xcg_child.x_carrier_group2x_parent
            JOIN table_x_carrier txc_child
            ON xcg_child.objid  = txc_child.carrier2carrier_group
            WHERE txc.objid     = p_carrier_objid
            AND txc_child.objid = xcf.x_feature2x_carrier
            )
          AND xcf.x_data       = l_data
          AND xcf.x_technology = rec_esn_dtl.x_technology
          UNION
          --based on exception table, service plan, ESN carrier, data capable parameter, technology
          SELECT DISTINCT 5 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          JOIN x_multi_rate_plan_esns rpe
          ON msc.x_service_plan_id    = rpe.x_service_plan_id
          AND msc.PRIORITY            = rpe.x_priority
          WHERE 1                     = 1
          AND psp.table_site_part_id  = p_site_part_objid
          AND xcf.x_feature2x_carrier = p_carrier_objid
          AND xcf.x_data              = to_number(p_data_capable)
          AND xcf.x_technology        = rec_esn_dtl.x_technology
          AND rpe.x_esn               = p_esn
          UNION
          --based on exception table, service plan, ESN carrier parent, data capable parameter, technology
          SELECT DISTINCT 6 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          JOIN x_multi_rate_plan_esns rpe
          ON msc.x_service_plan_id   = rpe.x_service_plan_id
          AND msc.PRIORITY           = rpe.x_priority
          WHERE 1                    = 1
          AND psp.table_site_part_id = p_site_part_objid
          AND EXISTS
            (SELECT 1
            FROM table_x_carrier txc
            JOIN table_x_carrier_group xcg
            ON txc.carrier2carrier_group = xcg.objid
            JOIN table_x_carrier_group xcg_child
            ON xcg.x_carrier_group2x_parent = xcg_child.x_carrier_group2x_parent
            JOIN table_x_carrier txc_child
            ON xcg_child.objid  = txc_child.carrier2carrier_group
            WHERE txc.objid     = p_carrier_objid
            AND txc_child.objid = xcf.x_feature2x_carrier
            )
          AND xcf.x_data       = to_number(p_data_capable)
          AND xcf.x_technology = rec_esn_dtl.x_technology
          AND rpe.x_esn        = p_esn
          UNION
          --based on priority 1, service plan, ESN carrier, data capable parameter, technology
          SELECT DISTINCT 7 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          WHERE 1                      = 1
          AND psp.table_site_part_id   = p_site_part_objid
          AND msc.PRIORITY             = 1
          AND xcf.x_feature2x_carrier  = p_carrier_objid
          AND xcf.x_data               = to_number(p_data_capable)
          AND xcf.x_technology         = rec_esn_dtl.x_technology
          UNION
          --based on priority 1, service plan, ESN carrier parent, data capable parameter, technology
          SELECT DISTINCT 8 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          WHERE 1                      = 1
          AND psp.table_site_part_id   = p_site_part_objid
          AND msc.PRIORITY             = 1
          AND EXISTS
            (SELECT 1
            FROM table_x_carrier txc
            JOIN table_x_carrier_group xcg
            ON txc.carrier2carrier_group = xcg.objid
            JOIN table_x_carrier_group xcg_child
            ON xcg.x_carrier_group2x_parent = xcg_child.x_carrier_group2x_parent
            JOIN table_x_carrier txc_child
            ON xcg_child.objid  = txc_child.carrier2carrier_group
            WHERE txc.objid     = p_carrier_objid
            AND txc_child.objid = xcf.x_feature2x_carrier
            )
          AND xcf.x_data       = to_number(p_data_capable)
          AND xcf.x_technology = rec_esn_dtl.x_technology
          UNION
          --based on exception table, service plan, ESN carrier, ESN data capable, technology
          SELECT DISTINCT 9 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          JOIN x_multi_rate_plan_esns rpe
          ON msc.x_service_plan_id    = rpe.x_service_plan_id
          AND msc.PRIORITY            = rpe.x_priority
          WHERE 1                     = 1
          AND psp.table_site_part_id  = p_site_part_objid
          AND xcf.x_feature2x_carrier = p_carrier_objid
          AND xcf.x_data              = rec_esn_dtl.x_data
          AND xcf.x_technology        = rec_esn_dtl.x_technology
          AND rpe.x_esn               = p_esn
          UNION
          --based on exception table, service plan, ESN carrier parent, ESN data capable, technology
          SELECT DISTINCT 10 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          JOIN x_multi_rate_plan_esns rpe
          ON msc.x_service_plan_id   = rpe.x_service_plan_id
          AND msc.PRIORITY           = rpe.x_priority
          WHERE 1                    = 1
          AND psp.table_site_part_id = p_site_part_objid
          AND EXISTS
            (SELECT 1
            FROM table_x_carrier txc
            JOIN table_x_carrier_group xcg
            ON txc.carrier2carrier_group = xcg.objid
            JOIN table_x_carrier_group xcg_child
            ON xcg.x_carrier_group2x_parent = xcg_child.x_carrier_group2x_parent
            JOIN table_x_carrier txc_child
            ON xcg_child.objid  = txc_child.carrier2carrier_group
            WHERE txc.objid     = p_carrier_objid
            AND txc_child.objid = xcf.x_feature2x_carrier
            )
          AND xcf.x_data       = rec_esn_dtl.x_data
          AND xcf.x_technology = rec_esn_dtl.x_technology
          AND rpe.x_esn        = p_esn
          UNION
          --based on priority 1, service plan, ESN carrier, ESN data capable, technology
          SELECT DISTINCT 11 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          WHERE 1                      = 1
          AND psp.table_site_part_id   = p_site_part_objid
          AND msc.PRIORITY             = 1
          AND xcf.x_feature2x_carrier  = p_carrier_objid
          AND xcf.x_data               = rec_esn_dtl.x_data
          AND xcf.x_technology         = rec_esn_dtl.x_technology
          UNION
          --based on priority 1, service plan, ESN carrier parent, ESN data capable, technology
          SELECT DISTINCT 12 sort_order ,
            xcf.objid cf_objid
          FROM x_service_plan_site_part psp
          JOIN mtm_sp_carrierfeatures msc
          ON psp.x_service_plan_id = msc.x_service_plan_id
          JOIN table_x_carrier_features xcf
          ON msc.x_carrier_features_id = xcf.objid
          WHERE 1                      = 1
          AND psp.table_site_part_id   = p_site_part_objid
          AND msc.PRIORITY             = 1
          AND EXISTS
            (SELECT 1
            FROM table_x_carrier txc
            JOIN table_x_carrier_group xcg
            ON txc.carrier2carrier_group = xcg.objid
            JOIN table_x_carrier_group xcg_child
            ON xcg.x_carrier_group2x_parent = xcg_child.x_carrier_group2x_parent
            JOIN table_x_carrier txc_child
            ON xcg_child.objid  = txc_child.carrier2carrier_group
            WHERE txc.objid     = p_carrier_objid
            AND txc_child.objid = xcf.x_feature2x_carrier
            )
          AND xcf.x_data       = rec_esn_dtl.x_data
          AND xcf.x_technology = rec_esn_dtl.x_technology
          ORDER BY 1
          )
        WHERE ROWNUM < 2;
        --
      EXCEPTION
      WHEN OTHERS THEN
        --
        l_cf_objid := NULL;
        --
      END;
      --
    END IF;
    --
    IF (l_cf_objid IS NULL AND p_carr_feature_objid IS NOT NULL) THEN
      --
      BEGIN
        --
        dbms_output.put_line('6. Carrier features');
        --
        SELECT xcf.objid cf_objid
        INTO l_cf_objid
        FROM table_x_carrier_features xcf
        WHERE 1       = 1
        AND xcf.objid = p_carr_feature_objid;
        --
      EXCEPTION
      WHEN OTHERS THEN
        --
        l_cf_objid := NULL;
        --
      END;
      --
    END IF;
    --
    IF (l_cf_objid IS NULL) THEN
      --
      BEGIN
        --
        dbms_output.put_line('7. Retrieve rate plan based on ESN carrier, data, technology, brand');
        --
        SELECT cf_objid
        INTO l_cf_objid
        FROM
          ( --based on ESN carrier, data speed, technology, brand
          SELECT DISTINCT 1 sort_order ,
            xcf.objid cf_objid
          FROM table_x_carrier_features xcf
          WHERE 1                     = 1
          AND xcf.x_feature2x_carrier = p_carrier_objid
          AND xcf.x_technology        = rec_esn_dtl.x_technology
          AND xcf.x_data              = l_data
          AND xcf.x_features2bus_org  = rec_esn_dtl.bus_org_objid
          UNION
          --based on ESN carrier, data capable parameter, technology, brand
          SELECT DISTINCT 2 sort_order ,
            xcf.objid cf_objid
          FROM table_x_carrier_features xcf
          WHERE 1                     = 1
          AND xcf.x_feature2x_carrier = p_carrier_objid
          AND xcf.x_technology        = rec_esn_dtl.x_technology
          AND xcf.x_data              = to_number(p_data_capable)
          AND xcf.x_features2bus_org  = rec_esn_dtl.bus_org_objid
          UNION
          --based on ESN carrier, ESN data capable, technology, brand
          SELECT DISTINCT 3 sort_order ,
            xcf.objid cf_objid
          FROM table_x_carrier_features xcf
          WHERE 1                     = 1
          AND xcf.x_feature2x_carrier = p_carrier_objid
          AND xcf.x_technology        = rec_esn_dtl.x_technology
          AND xcf.x_data              = rec_esn_dtl.x_data
          AND xcf.x_features2bus_org  = rec_esn_dtl.bus_org_objid
          ORDER BY 1
          )
        WHERE ROWNUM < 2;
        --
      EXCEPTION
      WHEN OTHERS THEN
        --
        l_cf_objid := NULL;
        --
      END;
      --
    END IF;
    --
    --CR14427 and CR18794 End KACOSTA 11/07/2011
    RETURN l_cf_objid;
  END IF;
END sf_get_carr_feat; -----CR13085
-- NET10_PAYGO ENDS

END igate_fix_ig;
/