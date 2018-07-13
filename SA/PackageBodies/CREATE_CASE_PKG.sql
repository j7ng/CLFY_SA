CREATE OR REPLACE PACKAGE BODY sa."CREATE_CASE_PKG" AS
/**************************************************************************/
/*
/* Purpose: CR3970 - Opens and Closes cases for the 1100 Advanced Exchange
/*
/**************************************************************************/
--
   CURSOR site_part_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_site_part
       WHERE objid = c_objid;

   CURSOR contact_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_contact
       WHERE objid = c_objid;

   CURSOR part_inst_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_part_inst
       WHERE objid = c_objid;

   CURSOR site_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_site
       WHERE objid = c_objid;

   CURSOR user_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_user
       WHERE objid = c_objid;

   CURSOR gbst_lst_curs (c_title IN VARCHAR2)
   IS
      SELECT *
        FROM sa.table_gbst_lst
       WHERE title LIKE c_title;

   CURSOR gbst_elm_curs (c_objid IN NUMBER, c_title IN VARCHAR2)
   IS
      SELECT *
        FROM sa.table_gbst_elm
       WHERE gbst_elm2gbst_lst = c_objid AND title LIKE c_title;

   CURSOR current_user_curs
   IS
      SELECT USER
        FROM DUAL;

   CURSOR user2_curs (c_login_name IN VARCHAR2)
   IS
      SELECT *
        FROM sa.table_user
       WHERE s_login_name = UPPER (c_login_name);

   CURSOR address_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_address
       WHERE objid = c_objid;

   CURSOR employee_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_employee
       WHERE employee2user = c_objid;

   CURSOR contact_role_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_contact_role
       WHERE contact_role2site = c_objid;

   CURSOR carrier_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_x_carrier
       WHERE objid = c_objid;

   CURSOR part_num_curs (c_objid IN NUMBER)
   IS
      SELECT pn.*
        FROM sa.table_part_num pn, sa.table_mod_level ml
       WHERE pn.objid = ml.part_info2part_num AND ml.objid = c_objid;

   CURSOR site2_curs (c_objid IN NUMBER)
   IS
      SELECT s.*
        FROM sa.table_site s, sa.table_inv_bin ib
       WHERE s.site_id = ib.bin_name AND ib.objid = c_objid;

   CURSOR wipbin_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM sa.table_wipbin
       WHERE wipbin_owner2user = c_objid;

   CURSOR case_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_case
       WHERE objid = c_objid;

   CURSOR condition_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_condition
       WHERE objid = c_objid;

   CURSOR queue_curs (c_title IN VARCHAR2)
   IS
      SELECT *
        FROM table_queue
       WHERE title = c_title;

   CURSOR part_repl_curs (c_objid IN NUMBER)
   IS
      SELECT a.part_number
        FROM table_part_num a, table_x_exch_options b
       WHERE b.exch_source2part_num = c_objid
         AND b.x_exch_type = 'TECHNOLOGY'
         AND b.x_priority = 1
         AND b.exch_target2part_num = a.objid;

   CURSOR esn_curs (c_esn IN VARCHAR2)
   IS
      SELECT a.*, c.objid partobjid, c.part_number, c.x_restricted_use
        FROM table_part_inst a, table_mod_level b, table_part_num c
       WHERE part_serial_no = c_esn
         AND n_part_inst2part_mod = b.objid
         AND b.part_info2part_num = c.objid;

   CURSOR dummy_contact_curs (c_restrict IN NUMBER)
   IS
      SELECT contact_role2site
        FROM table_contact_role
       WHERE contact_role2contact =
                (SELECT objid
                   FROM table_contact
                  WHERE first_name =
                                   DECODE (c_restrict,
                                           3, '1100NET10',
                                           '1100'
                                          ));

----------------------------------------------------------------------------------------------------
   PROCEDURE sp_create_case (
      p_esn          IN       VARCHAR2,
      p_repl_esn     IN       VARCHAR2,
      p_queue_name   IN       VARCHAR2,
      p_type         IN       VARCHAR2,
      p_title        IN       VARCHAR2,
      p_repl_part    IN       VARCHAR2,
      p_firstname    IN       VARCHAR2,
      p_lastname     IN       VARCHAR2,
      p_address      IN       VARCHAR2,
      p_city         IN       VARCHAR2,
      p_state        IN       VARCHAR2,
      p_zip          IN       VARCHAR2,
      p_tracking     IN       VARCHAR2,
      p_case_objid   OUT      NUMBER,
      p_case_id      OUT      VARCHAR2
   )
   IS
      dummy_contact_rec        dummy_contact_curs%ROWTYPE;
      esn_rec                  esn_curs%ROWTYPE;
      repl_esn_rec             esn_curs%ROWTYPE;
      min_rec                  esn_curs%ROWTYPE;
      --part_repl_rec part_repl_curs%ROWTYPE;
      site_part_rec            site_part_curs%ROWTYPE;
      contact_rec              contact_curs%ROWTYPE;
      part_inst_rec            part_inst_curs%ROWTYPE;
      site_rec                 site_curs%ROWTYPE;
      user_rec                 user_curs%ROWTYPE;
      gbst_lst1_rec            gbst_lst_curs%ROWTYPE;
      gbst_elm1_rec            gbst_elm_curs%ROWTYPE;
      gbst_lst2_rec            gbst_lst_curs%ROWTYPE;
      gbst_elm2_rec            gbst_elm_curs%ROWTYPE;
      gbst_lst3_rec            gbst_lst_curs%ROWTYPE;
      gbst_elm3_rec            gbst_elm_curs%ROWTYPE;
      gbst_lst4_rec            gbst_lst_curs%ROWTYPE;
      gbst_elm4_rec            gbst_elm_curs%ROWTYPE;
      gbst_lst5_rec            gbst_lst_curs%ROWTYPE;
      gbst_elm5_rec            gbst_elm_curs%ROWTYPE;
      current_user_rec         current_user_curs%ROWTYPE;
      user2_rec                user2_curs%ROWTYPE;
      address_rec              address_curs%ROWTYPE;
      employee_rec             employee_curs%ROWTYPE;
      contact_role_rec         contact_role_curs%ROWTYPE;
      carrier_rec              carrier_curs%ROWTYPE;
      part_num_rec             part_num_curs%ROWTYPE;
      site2_rec                site2_curs%ROWTYPE;
      task_user_rec            user_curs%ROWTYPE;
      wipbin_rec               wipbin_curs%ROWTYPE;
      l_condition_objid        NUMBER;
      l_case_objid             NUMBER;
      l_act_entry_objid        NUMBER;
      l_case_id                VARCHAR2 (30);
      l_alt_esn_objid          NUMBER;
      hold                     NUMBER;
      hold1                    VARCHAR2 (20);
      hold2                    VARCHAR2 (2000);
      cnt                      NUMBER                       := 0;
      v_site_objid             NUMBER                       := 0;
      v_site_address           NUMBER                       := 0;
      v_sitepart_min           VARCHAR2 (20)                := '0';
      v_sitepart_objid         NUMBER                       := 0;
      v_sitepart_site          NUMBER                       := 0;
      v_contact_role2contact   NUMBER                       := 0;
      v_contact_phone          VARCHAR2 (20)                := '0';
      v_contact_objid          NUMBER                       := 0;
      v_contact_firstname      VARCHAR2 (20)                := '0';
      v_contact_lastname       VARCHAR2 (20)                := '0';
      v_carrierid              NUMBER                       := 0;
      v_carriername            VARCHAR2 (60)                := '0';
      v_sitepart_zip           VARCHAR2 (10)                := '0';
      v_address_objid          NUMBER                       := 0;
      v_min_rec_carriermkt     NUMBER                       := 0;
   BEGIN
--
--
      cnt := cnt + 1;                                                     --1
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
      OPEN esn_curs (p_esn);

      FETCH esn_curs
       INTO esn_rec;

      IF esn_curs%NOTFOUND
      THEN
         CLOSE esn_curs;

         RETURN;
      END IF;

      CLOSE esn_curs;

      OPEN esn_curs (p_repl_esn);

      FETCH esn_curs
       INTO repl_esn_rec;

      IF esn_curs%NOTFOUND
      THEN
         CLOSE esn_curs;

         RETURN;
      END IF;

      CLOSE esn_curs;

--
      cnt := cnt + 1;                                                      --2
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN site_part_curs (esn_rec.x_part_inst2site_part);

      FETCH site_part_curs
       INTO site_part_rec;

      IF site_part_curs%NOTFOUND
      THEN
         --CLOSE site_part_curs;
         --RETURN;
         v_sitepart_min := '0';
         v_sitepart_objid := 0;
         v_sitepart_site := 0;
         v_sitepart_zip := '0';
      ELSE
         v_sitepart_min := site_part_rec.x_min;
         v_sitepart_objid := site_part_rec.objid;
         v_sitepart_site := site_part_rec.site_part2site;
         v_sitepart_zip := site_part_rec.x_zipcode;
      END IF;

      CLOSE site_part_curs;

      OPEN esn_curs (v_sitepart_min);

      FETCH esn_curs
       INTO min_rec;

      IF esn_curs%NOTFOUND
      THEN
         --CLOSE esn_curs;
         --RETURN;
         v_min_rec_carriermkt := 0;
      ELSE
         v_min_rec_carriermkt := min_rec.part_inst2carrier_mkt;
      END IF;

      CLOSE esn_curs;

--
      cnt := cnt + 1;                                                      --3
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);
--
      cnt := cnt + 1;                                                      --4
      DBMS_OUTPUT.put_line (   'sp_create_case:'
                            || cnt
                            || ' site_part_rec.objid:'
                            || v_sitepart_objid
                           );

--
--
      OPEN part_inst_curs (esn_rec.objid);

      FETCH part_inst_curs
       INTO part_inst_rec;

      IF part_inst_curs%NOTFOUND
      THEN
         CLOSE part_inst_curs;

         RETURN;
      END IF;

      CLOSE part_inst_curs;

--
      cnt := cnt + 1;                                                      --5
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN dummy_contact_curs (esn_rec.x_restricted_use);

      FETCH dummy_contact_curs
       INTO dummy_contact_rec;

      IF dummy_contact_curs%FOUND
      THEN
         v_sitepart_site := dummy_contact_rec.contact_role2site;
      END IF;

      CLOSE dummy_contact_curs;

      OPEN site_curs (v_sitepart_site);

      FETCH site_curs
       INTO site_rec;

      IF site_curs%NOTFOUND
      THEN
         --CLOSE site_curs;
         --RETURN;
         v_site_address := 0;
         v_site_objid := 0;
      ELSE
         v_site_address := site_rec.cust_primaddr2address;
         v_site_objid := site_rec.objid;
      END IF;

      CLOSE site_curs;

--
      cnt := cnt + 1;                                                      --6
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);
--
--
      cnt := cnt + 1;                                                      --7
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN address_curs (v_site_address);

      FETCH address_curs
       INTO address_rec;

      IF address_curs%NOTFOUND
      THEN
          --CLOSE address_curs;
         --RETURN;
         v_address_objid := 0;
      ELSE
         v_address_objid := address_rec.objid;
      END IF;

      CLOSE address_curs;

--
      cnt := cnt + 1;                                                      --8
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Response Priority Code');

      FETCH gbst_lst_curs
       INTO gbst_lst1_rec;

      IF gbst_lst_curs%NOTFOUND
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                      --9
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst1_rec.objid, 'High');

      FETCH gbst_elm_curs
       INTO gbst_elm1_rec;

      IF gbst_elm_curs%NOTFOUND
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --10
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Case Type');

      FETCH gbst_lst_curs
       INTO gbst_lst2_rec;

      IF gbst_lst_curs%NOTFOUND
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --11
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst2_rec.objid, 'Problem');

      FETCH gbst_elm_curs
       INTO gbst_elm2_rec;

      IF gbst_elm_curs%NOTFOUND
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --12
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Open');

      FETCH gbst_lst_curs
       INTO gbst_lst3_rec;

      IF gbst_lst_curs%NOTFOUND
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --13
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst3_rec.objid, 'Isolated');

      FETCH gbst_elm_curs
       INTO gbst_elm3_rec;

      IF gbst_elm_curs%NOTFOUND
      THEN
         DBMS_OUTPUT.put_line ('No Isolated');

         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --14
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN current_user_curs;

      FETCH current_user_curs
       INTO current_user_rec;

      IF current_user_curs%NOTFOUND
      THEN
         current_user_rec.USER := 'appsrv';            -- changed from appsvr
      END IF;

      CLOSE current_user_curs;

--
      cnt := cnt + 1;                                                     --15
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN user2_curs (current_user_rec.USER);

      FETCH user2_curs
       INTO user2_rec;

      IF user2_curs%NOTFOUND
      THEN
         CLOSE user2_curs;

         RETURN;
      END IF;

      CLOSE user2_curs;

--
      cnt := cnt + 1;                                                     --16
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN wipbin_curs (user2_rec.objid);

      FETCH wipbin_curs
       INTO wipbin_rec;

      IF wipbin_curs%NOTFOUND
      THEN
         CLOSE wipbin_curs;

         RETURN;
      END IF;

      CLOSE wipbin_curs;

--
      cnt := cnt + 1;                                                     --17
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Activity Name');

      FETCH gbst_lst_curs
       INTO gbst_lst4_rec;

      IF gbst_lst_curs%NOTFOUND
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --18
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst4_rec.objid, 'Create');

      FETCH gbst_elm_curs
       INTO gbst_elm4_rec;

      IF gbst_elm_curs%NOTFOUND
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --19
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Problem Severity Level');

      FETCH gbst_lst_curs
       INTO gbst_lst5_rec;

      IF gbst_lst_curs%NOTFOUND
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --20
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst5_rec.objid, 'High');

      FETCH gbst_elm_curs
       INTO gbst_elm5_rec;

      IF gbst_elm_curs%NOTFOUND
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --21
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN employee_curs (user2_rec.objid);

      FETCH employee_curs
       INTO employee_rec;

      IF employee_curs%NOTFOUND
      THEN
         CLOSE employee_curs;

         RETURN;
      END IF;

      CLOSE employee_curs;

--
      cnt := cnt + 1;                                                     --22
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN contact_role_curs (v_site_objid);

      FETCH contact_role_curs
       INTO contact_role_rec;

      IF contact_role_curs%NOTFOUND
      THEN
          --CLOSE contact_role_curs;
         --RETURN;
         v_contact_role2contact := 0;
      ELSE
         v_contact_role2contact := contact_role_rec.contact_role2contact;
      END IF;

      CLOSE contact_role_curs;

--
      cnt := cnt + 1;                                                     --23
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN contact_curs (v_contact_role2contact);

      FETCH contact_curs
       INTO contact_rec;

      IF contact_curs%NOTFOUND
      THEN
          --CLOSE contact_curs;
         --RETURN;
         v_contact_phone := '0';
         v_contact_objid := 0;
         v_contact_firstname := '0';
         v_contact_lastname := '0';
      ELSE
         v_contact_phone := contact_rec.phone;
         v_contact_objid := contact_rec.objid;
         v_contact_firstname := contact_rec.first_name;
         v_contact_lastname := contact_rec.last_name;
      END IF;

      CLOSE contact_curs;

--
      cnt := cnt + 1;                                                     --24
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN carrier_curs (v_min_rec_carriermkt);

      FETCH carrier_curs
       INTO carrier_rec;

      IF carrier_curs%NOTFOUND
      THEN
          --CLOSE carrier_curs;
         --RETURN;
         v_carrierid := 0;
         v_carriername := '0';
      ELSE
         v_carrierid := carrier_rec.x_carrier_id;
         v_carriername := carrier_rec.x_mkt_submkt_name;
      END IF;

      CLOSE carrier_curs;

--
      cnt := cnt + 1;                                                     --25
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN part_num_curs (esn_rec.n_part_inst2part_mod);

      FETCH part_num_curs
       INTO part_num_rec;

      IF part_num_curs%NOTFOUND
      THEN
         CLOSE part_num_curs;

         RETURN;
      END IF;

      CLOSE part_num_curs;

--
      cnt := cnt + 1;                                                     --26
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN site2_curs (part_inst_rec.part_inst2inv_bin);

      FETCH site2_curs
       INTO site2_rec;

      IF site2_curs%NOTFOUND
      THEN
         CLOSE site2_curs;

         RETURN;
      END IF;

      CLOSE site2_curs;

--
      cnt := cnt + 1;                                                     --27
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);
--
--
      cnt := cnt + 1;                                                     --28
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);
--
--
      cnt := cnt + 1;                                                     --29
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      OPEN user_curs (268435556);                               -- objid of SA

      FETCH user_curs
       INTO task_user_rec;

      IF user_curs%NOTFOUND
      THEN
         CLOSE user_curs;

         RETURN;
      END IF;

      CLOSE user_curs;

--
      cnt := cnt + 1;                                                     --30
--
--
      cnt := cnt + 1;
      DBMS_OUTPUT.put_line ('sp_create_case:' || cnt);

--
--
      SELECT seq ('condition')
        INTO l_condition_objid
        FROM DUAL;

--
      INSERT INTO sa.table_condition
                  (objid, condition, title, wipbin_time, sequence_num
                  )
           VALUES (l_condition_objid, 2, 'Open', SYSDATE, 0
                  );

--
      SELECT seq ('case')
        INTO l_case_objid
        FROM DUAL;

--
      p_case_objid := l_case_objid;

--
--cwl CR12874
      SELECT sa.sequ_individual_id.NEXTVAL                        --next_value
        INTO l_case_id
        FROM DUAL;

--        FROM SA.table_num_scheme
--       WHERE name = 'Case ID'
--         FOR UPDATE;
-- after you get it update the sequence
--      UPDATE table_num_scheme
--         SET next_value = next_value + 1
--       WHERE name = 'Case ID';
--cwl CR12874
      COMMIT;

--
      INSERT INTO sa.table_case
                  (objid, x_case_type, title, s_title,
                   alt_phone_num, phone_num, ownership_stmp, modify_stmp,
                   id_number, creation_time,
                   case_history, x_carrier_id,
                   x_esn, x_min, x_carrier_name,
                   x_text_car_id,
                   x_phone_model,
                   x_model, x_retailer_name, case2address,
                   case_reporter2site, case_reporter2contact,
                   calltype2gbst_elm, case_owner2user,
                   case_originator2user, case_wip2wipbin,
                   casests2gbst_elm, respprty2gbst_elm,
                   respsvrty2gbst_elm, case_state2condition, internal_case,
                   yank_flag, case_type_lvl2, x_stock_type, x_require_return,
                   x_activation_zip, x_repl_part_num, x_replacement_units,
                   alt_first_name, alt_last_name, alt_address, alt_city,
                   alt_state, alt_zipcode, x_po_number
                  )
           VALUES (l_case_objid, p_type, p_title, UPPER (p_title),
                   v_contact_phone, v_contact_phone, SYSDATE, SYSDATE,
                   l_case_id, SYSDATE,
                   '*** CASE: 1100 BP initiated Exchange', v_carrierid,
                   esn_rec.part_serial_no, v_sitepart_min, v_carriername,
                   TO_CHAR (v_carrierid),
                   SUBSTR (part_num_rec.description, 1, 30),
                   part_num_rec.part_number, site2_rec.NAME, v_address_objid,
                   v_site_objid, v_contact_objid,
                   gbst_elm2_rec.objid, task_user_rec.objid,
                   task_user_rec.objid, wipbin_rec.objid,
                   gbst_elm3_rec.objid, gbst_elm1_rec.objid,
                   gbst_elm5_rec.objid, l_condition_objid, 0,
                   0, 'Tracfone', repl_esn_rec.part_serial_no, 1,
                   v_sitepart_zip, repl_esn_rec.part_number, 0,
                   p_firstname, p_lastname, p_address, p_city,
                   p_state, p_zip, p_tracking
                  );

      SELECT seq ('x_alt_esn')
        INTO l_alt_esn_objid
        FROM DUAL;

      INSERT INTO table_x_alt_esn
                  (objid, x_date, x_type,
                   x_orig_esn, x_replacement_esn, x_user,
                   x_status, x_alt_esn2case, x_alt_esn2contact,
                   x_orig_esn2part_inst, x_replacement_esn2part_inst,
                   x_new_sim
                  )
           VALUES (l_alt_esn_objid, SYSDATE, 'EXCHANGE',
                   esn_rec.part_serial_no, repl_esn_rec.part_serial_no, 'sa',
                   'CLOSED', l_case_objid, v_contact_objid,
                   esn_rec.objid, repl_esn_rec.objid,
                   NULL
                  );

      SELECT seq ('act_entry')
        INTO l_act_entry_objid
        FROM DUAL;

--
      INSERT INTO sa.table_act_entry
                  (objid, act_code, entry_time,
                   addnl_info,
                   act_entry2case, act_entry2user, entry_name2gbst_elm
                  )
           VALUES (l_act_entry_objid, 600, SYSDATE,
                      ' Contact = '
                   || p_firstname
                   || ' '
                   || p_lastname
                   || ', Priority = '
                   || gbst_elm1_rec.title
                   || ', Status = '
                   || gbst_elm3_rec.title
                   || '.',
                   l_case_objid, user2_rec.objid, gbst_elm4_rec.objid
                  );

/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
      INSERT INTO sa.table_time_bomb
                  (objid, escalate_time, end_time,
                   focus_lowid, focus_type, time_period, flags,
                   cmit_creator2employee
                  )
           VALUES (seq ('time_bomb'), SYSDATE - (365 * 10), SYSDATE,
                   l_case_objid, 0, l_act_entry_objid, 589826,
                   employee_rec.objid
                  );
*/

--
         /*** Changes ReplacementPartNumber Dealer info ******/
      UPDATE table_part_inst
         SET part_inst2inv_bin = esn_rec.part_inst2inv_bin
       WHERE objid = repl_esn_rec.objid;

      sp_dispatch_case (l_case_objid, p_queue_name, hold);
      /**** Automatic Closing of Case *****/
      sp_close_case (l_case_id, 'SA', 'WEBCSR', NULL, hold1, hold2);
--
      p_case_objid := l_case_objid;
      p_case_id := l_case_id;
      COMMIT;
   END sp_create_case;

----------------------------------------------------------------------------------------------------
   PROCEDURE sp_dispatch_case (
      p_case_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   )
   IS
      current_user_rec    current_user_curs%ROWTYPE;
      case_rec            case_curs%ROWTYPE;
      condition_rec       condition_curs%ROWTYPE;
      user2_rec           user2_curs%ROWTYPE;
      employee_rec        employee_curs%ROWTYPE;
      gbst_lst_rec        gbst_lst_curs%ROWTYPE;
      gbst_elm_rec        gbst_elm_curs%ROWTYPE;
      queue_rec           queue_curs%ROWTYPE;
      l_act_entry_objid   NUMBER;
      hold                NUMBER;
   BEGIN
      p_dummy_out := 1;

      OPEN queue_curs (p_queue_name);

      FETCH queue_curs
       INTO queue_rec;

      IF queue_curs%NOTFOUND
      THEN
         RETURN;
      END IF;

      CLOSE queue_curs;

--
      OPEN current_user_curs;

      FETCH current_user_curs
       INTO current_user_rec;

      IF current_user_curs%NOTFOUND
      THEN
         current_user_rec.USER := 'appsrv';            -- changed from appsvr
      END IF;

      CLOSE current_user_curs;

--
      OPEN case_curs (p_case_objid);

      FETCH case_curs
       INTO case_rec;

      IF case_curs%NOTFOUND
      THEN
         RETURN;
      END IF;

      CLOSE case_curs;

--
      OPEN condition_curs (case_rec.case_state2condition);

      FETCH condition_curs
       INTO condition_rec;

      IF condition_curs%NOTFOUND
      THEN
         RETURN;
      END IF;

      CLOSE condition_curs;

--
      OPEN user2_curs (current_user_rec.USER);

      FETCH user2_curs
       INTO user2_rec;

      IF user2_curs%NOTFOUND
      THEN
         CLOSE user2_curs;

         RETURN;
      END IF;

      CLOSE user2_curs;

--
      OPEN employee_curs (user2_rec.objid);

      FETCH employee_curs
       INTO employee_rec;

      IF employee_curs%NOTFOUND
      THEN
         CLOSE employee_curs;

         RETURN;
      END IF;

      CLOSE employee_curs;

--
      OPEN gbst_lst_curs ('Activity Name');

      FETCH gbst_lst_curs
       INTO gbst_lst_rec;

      IF gbst_lst_curs%NOTFOUND
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      OPEN gbst_elm_curs (gbst_lst_rec.objid, 'Dispatch');

      FETCH gbst_elm_curs
       INTO gbst_elm_rec;

      IF gbst_elm_curs%NOTFOUND
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
--Updates the Condition Record
      UPDATE table_condition
         SET condition = 10,
             queue_time = SYSDATE,
             title = 'Open-Dispatch',
             s_title = 'OPEN-DISPATCH'
       WHERE objid = condition_rec.objid;

      UPDATE table_case
         SET case_currq2queue = queue_rec.objid
       WHERE objid = p_case_objid;

--Build the Activity Entry
      -- 04/10/03 select seq_act_entry.nextval +(power(2,28)) into l_act_entry_objid from dual;
      SELECT seq ('act_entry')
        INTO l_act_entry_objid
        FROM DUAL;

--
      INSERT INTO table_act_entry
                  (objid, act_code, entry_time,
                   addnl_info,
                   proxy, removed, act_entry2case, act_entry2user,
                   entry_name2gbst_elm
                  )
           VALUES (l_act_entry_objid, 900, SYSDATE,
                   ' Dispatched to Queue ' || p_queue_name,
                   current_user_rec.USER, 0, p_case_objid, user2_rec.objid,
                   gbst_elm_rec.objid
                  );

/*    --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
      --Build The time_bomb entry
      INSERT INTO table_time_bomb
                  (objid, title,
                   escalate_time, end_time,
                   focus_lowid, focus_type, suppl_info, time_period, flags,
                   left_repeat, report_title, property_set, users,
                   cmit_creator2employee
                  )
           VALUES (seq ('time_bomb'), NULL,
                   TO_DATE ('01/01/1753', 'dd/mm/yyyy'), SYSDATE,
                   p_case_objid, 0, NULL, l_act_entry_objid, 655362,
                   0, NULL, NULL, NULL,
                   employee_rec.objid
                  );
*/

   END;

----------------------------------------------------------------------------------------------------
   PROCEDURE sp_close_case (
      p_case_id           IN    VARCHAR2,
      p_user_login_name   IN    VARCHAR2,
      p_source            IN    VARCHAR2,
      p_resolution_code   IN    VARCHAR2,
      p_status            OUT   VARCHAR2,
      p_msg               OUT   VARCHAR2
   )
   IS
      v_current_date          DATE := SYSDATE;
      v_case_id               table_case.id_number%TYPE;
      v_user_objid            NUMBER;

      CURSOR c_case
      IS
         SELECT c.*
           FROM table_case c
          WHERE id_number = v_case_id;

      rec_case                c_case%ROWTYPE;

      CURSOR c_condition (c_condition_objid NUMBER)
      IS
         SELECT *
           FROM table_condition
          WHERE objid = c_condition_objid;

      rec_condition           c_condition%ROWTYPE;

      CURSOR c_subcase
      IS
         SELECT   *
             FROM table_case2sub_cls
            WHERE (case_id = v_case_id)
         ORDER BY close_date DESC;

      CURSOR c_gbst_elm (c_gbst_lst_title VARCHAR2, c_gbst_elm_title VARCHAR2)
      IS
         SELECT ge.title elm_title, ge.objid elm_objid, ge.RANK,
                gl.title lst_title, gl.objid lst_objid
           FROM table_gbst_elm ge, table_gbst_lst gl
          WHERE 1 = 1
            AND ge.title = c_gbst_elm_title
            AND gl.objid = ge.gbst_elm2gbst_lst
            AND gl.title = c_gbst_lst_title;

      CURSOR c_task (c_esn VARCHAR2, c_min VARCHAR2)
      IS
         SELECT t.*
           FROM table_condition c, table_task t, table_x_call_trans ct
          WHERE c.s_title || '' <> 'CLOSED ACTION ITEM'
            AND t.task_state2condition = c.objid
            AND ct.objid = t.x_task2x_call_trans
            AND ct.x_action_type || '' IN ('1', '2', '3', '5')
            AND ct.x_min = c_min
            AND ct.x_service_id = c_esn;

      v_seq_close_case        NUMBER;
      v_seq_act_entry         NUMBER;
      v_resolution_gbst       VARCHAR2 (80)          := 'Resolution Code';
      v_resolution_default    VARCHAR2 (80)          := 'Carri Problem Solved';
      v_resolution_code       VARCHAR2 (80);
      v_addl_info             VARCHAR2 (255);
      v_actl_phone_time       NUMBER                      := 0;
      v_sub_actl_phone_time   NUMBER                      := 0;
      v_sub_calc_phone_time   NUMBER                      := 0;
      v_calc_phone_time       NUMBER                      := 0;
      v_tot_actl_phone_time   NUMBER                      := 0;
      v_case_history          VARCHAR2 (32000);
      rec_case_sts_closed     c_gbst_elm%ROWTYPE;
      rec_act_caseclose       c_gbst_elm%ROWTYPE;
      rec_act_accept          c_gbst_elm%ROWTYPE;
      rec_resolution_code     c_gbst_elm%ROWTYPE;
      hold                    NUMBER;

   BEGIN

      v_case_id := RTRIM (LTRIM (p_case_id));
      v_resolution_code := p_resolution_code;
      v_resolution_code := RTRIM (LTRIM (NVL (v_resolution_code, ' ')));

      OPEN c_case;

      FETCH c_case
       INTO rec_case;

      IF c_case%NOTFOUND
      THEN
         p_status := 'F';
         p_msg := 'CASE ' || NVL (p_case_id, '<NULL>') || ' not found';

         CLOSE c_case;

         RETURN;
      END IF;

      CLOSE c_case;

      DBMS_OUTPUT.put_line ('CASE ' || v_case_id || ' found.');

      BEGIN
         SELECT objid
           INTO v_user_objid
           FROM table_user
          WHERE s_login_name = UPPER (p_user_login_name);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_status := 'F';
            p_msg := 'User login name ' || p_user_login_name || ' not found.';
            RETURN;
      END;

      DBMS_OUTPUT.put_line ('User login name ' || p_user_login_name
                            || ' found.'
                           );
      DBMS_OUTPUT.put_line (   'length of resolution code: '
                            || LENGTH (v_resolution_code)
                           );

      --IF length(v_resolution_code) < 1 or v_resolution_code is null THEN
      IF NVL (LENGTH (v_resolution_code), 0) < 1
      THEN
         v_resolution_code := v_resolution_default;
      END IF;

      OPEN c_gbst_elm (v_resolution_gbst, v_resolution_code);

      FETCH c_gbst_elm
       INTO rec_resolution_code;

      IF c_gbst_elm%NOTFOUND
      THEN
         p_status := 'F';
         p_msg := 'Resolution code ' || v_resolution_code || ' is not valid';

         CLOSE c_gbst_elm;

         RETURN;
      END IF;

      CLOSE c_gbst_elm;

      DBMS_OUTPUT.put_line ('Resolution code: ' || v_resolution_code);

      OPEN c_condition (NVL (rec_case.case_state2condition, 0));

      FETCH c_condition
       INTO rec_condition;

      IF c_condition%NOTFOUND
      THEN
         p_status := 'F';
         p_msg := 'CONDITION FOR CASE ' || v_case_id || ' not found.';

         CLOSE c_condition;

         RETURN;
      END IF;

      CLOSE c_condition;

      DBMS_OUTPUT.put_line (   'CONDITION objid FOR '
                            || v_case_id
                            || ' is '
                            || rec_condition.objid
                           );

      IF rec_condition.s_title LIKE 'CLOSED%'
      THEN
         p_status := 'F';
         p_msg := 'Case ' || p_case_id || ' is already closed.';
         RETURN;
      END IF;

      OPEN c_gbst_elm ('Closed', 'Closed');

      FETCH c_gbst_elm
       INTO rec_case_sts_closed;

      IF c_gbst_elm%NOTFOUND
      THEN
         p_status := 'F';
         p_msg := 'Status for closed case not found';

         CLOSE c_gbst_elm;

         RETURN;
      END IF;

      CLOSE c_gbst_elm;

      DBMS_OUTPUT.put_line ('Status for closed case found');

      OPEN c_gbst_elm ('Activity Name', 'Case Close');

      FETCH c_gbst_elm
       INTO rec_act_caseclose;

      IF c_gbst_elm%NOTFOUND
      THEN
         p_status := 'F';
         p_msg := 'Activity code for closed case not found';

         CLOSE c_gbst_elm;

         RETURN;
      END IF;

      CLOSE c_gbst_elm;

      OPEN c_gbst_elm ('Activity Name', 'Accept');

      FETCH c_gbst_elm
       INTO rec_act_accept;

      IF c_gbst_elm%NOTFOUND
      THEN
         p_status := 'F';
         p_msg := 'Activity code for accepting case not found';

         CLOSE c_gbst_elm;

         RETURN;
      END IF;

      CLOSE c_gbst_elm;

      DBMS_OUTPUT.put_line ('Activity code for closed case not found');
      DBMS_OUTPUT.put_line ('Start to close case:');

      IF rec_case.hangup_time IS NOT NULL
      THEN
         v_actl_phone_time :=
               (rec_case.hangup_time - rec_case.creation_time
               ) * 24 * 60 * 60;

         IF v_actl_phone_time IS NULL OR v_actl_phone_time < 0
         THEN
            v_actl_phone_time := 0;
         END IF;
      ELSE
         v_actl_phone_time := 0;
      END IF;

      FOR c_subcase_rec IN c_subcase
      LOOP
         v_sub_actl_phone_time :=
               v_sub_actl_phone_time + NVL (c_subcase_rec.actl_phone_time, 0);
         v_sub_calc_phone_time :=
               v_sub_calc_phone_time + NVL (c_subcase_rec.calc_phone_time, 0);
      END LOOP;

      v_actl_phone_time := ROUND (v_actl_phone_time + v_sub_actl_phone_time);
      v_calc_phone_time := ROUND (v_actl_phone_time + v_sub_calc_phone_time);
      v_tot_actl_phone_time := ROUND (v_actl_phone_time);
      DBMS_OUTPUT.put_line ('actl_phone_time: ' || v_actl_phone_time);
      DBMS_OUTPUT.put_line ('calc_phone_time: ' || v_calc_phone_time);
      DBMS_OUTPUT.put_line ('v_tot_actl_phone_time: ' || v_tot_actl_phone_time);

       -- find related TASK
      -- FOR c_task_rec IN c_task (rec_case.x_esn, rec_case.x_min)
      -- LOOP
      --    DBMS_OUTPUT.put_line (
      --       'Related ACTION ITEM FOUND, TASK_ID: ' || c_task_rec.task_id
      --    );
      --    DBMS_OUTPUT.put_line ('c_task_rec.objid:' || c_task_rec.objid);
      --    sp_close_action_item (c_task_rec.objid, 0, hold);
      -- END LOOP;
      BEGIN
         UPDATE table_condition
            SET condition = 4,
                title = 'Closed',
                s_title = 'CLOSED'
          WHERE objid = rec_condition.objid;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_status := 'F';
            p_msg :=
               SUBSTR (   'Unable to update condition for case id '
                       || v_case_id
                       || SQLERRM,
                       1,
                       255
                      );
            RETURN;
      END;

      DBMS_OUTPUT.put_line ('Condition for Case id ' || v_case_id
                            || ' updated.'
                           );
      v_case_history := rec_case.case_history;
      v_case_history :=
            v_case_history
         || CHR (10)
         || '*** CASE CLOSE '
         ||
--         TO_CHAR (v_current_date, 'DD/MM/YY HH:MI:SS AM ') ||
            TO_CHAR (v_current_date, 'MM/DD/YYYY HH:MI:SS AM ')
         || p_user_login_name
         || ' FROM source "'
         || p_source
         || '"';

      BEGIN
         UPDATE table_case
            SET case_currq2queue = NULL,
                case_wip2wipbin = NULL,
                case_owner2user = v_user_objid,
                casests2gbst_elm = rec_case_sts_closed.elm_objid,
                case_history = v_case_history
          WHERE objid = rec_case.objid;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_status := 'F';
            p_msg :=
               SUBSTR (   'Unable to update case record for case id '
                       || v_case_id
                       || ': '
                       || SQLERRM,
                       1,
                       255
                      );
            RETURN;
      END;

      DBMS_OUTPUT.put_line ('Case record updated.');

      -- 04/10/03 SELECT SEQ_act_entry.nextval + power(2,28) INTO v_seq_act_entry from dual;
      SELECT seq ('act_entry')
        INTO v_seq_act_entry
        FROM DUAL;

      v_addl_info := 'Status = Closed, Resolution Code ='
         || v_resolution_code
         || ' State = Open.';

      DBMS_OUTPUT.put_line ('table_act_entry record: ' || CHR (10));
      DBMS_OUTPUT.put_line ('OBJID : ' || v_seq_act_entry);
      DBMS_OUTPUT.put_line ('ACT_CODE : ' || rec_act_caseclose.RANK);
      DBMS_OUTPUT.put_line ('ENTRY_TIME : ' || v_current_date);
      DBMS_OUTPUT.put_line ('ADDNL_INFO : ' || v_addl_info);
      DBMS_OUTPUT.put_line (   'ENTRY_NAME2GBST_ELM : '
                            || rec_act_caseclose.elm_objid
                           );
      DBMS_OUTPUT.put_line ('ACT_ENTRY2CASE : ' || rec_case.objid);
      DBMS_OUTPUT.put_line ('ACT_ENTRY2USER : ' || v_user_objid);

      BEGIN
         INSERT INTO table_act_entry
                     (objid, act_code,
                      entry_time, addnl_info, proxy, removed, focus_type,
                      focus_lowid, entry_name2gbst_elm, act_entry2case,
                      act_entry2user
                     )
              VALUES (v_seq_act_entry, rec_act_caseclose.RANK,
                      v_current_date, v_addl_info, '', 0, 0,
                      0, rec_act_caseclose.elm_objid, rec_case.objid,
                      v_user_objid
                     );
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_status := 'F';
            p_msg :=
               SUBSTR ('Unable to create new activity record: ' || SQLERRM,
                       1,
                       255
                      );
            RETURN;
      END;

      -- 04/10/03 SELECT SEQ_close_case.nextval + power(2,28) INTO v_seq_close_case FROM dual;
      SELECT seq ('close_case')
        INTO v_seq_close_case
        FROM DUAL;

      DBMS_OUTPUT.put_line (   'table_close_case record: '
                            || v_seq_close_case
                            || CHR (10)
                           );
      DBMS_OUTPUT.put_line ('OBJID : ' || v_seq_close_case);
      DBMS_OUTPUT.put_line ('close_date : ' || v_current_date);
      DBMS_OUTPUT.put_line ('actl_phone_time : ' || v_actl_phone_time);
      DBMS_OUTPUT.put_line ('calc_phone_time : ' || v_calc_phone_time);
      DBMS_OUTPUT.put_line ('tot_actl_phone_time : ' || v_tot_actl_phone_time);
      DBMS_OUTPUT.put_line (   'cls_old_stat2gbst_elm : '
                            || rec_case.casests2gbst_elm
                           );
      DBMS_OUTPUT.put_line (   'cls_new_stat2gbst_elm : '
                            || rec_case_sts_closed.elm_objid
                           );
      DBMS_OUTPUT.put_line (   'close_rsolut2gbst_elm : '
                            || rec_resolution_code.elm_objid
                           );
      DBMS_OUTPUT.put_line ('last_close2case : ' || rec_case.objid);
      DBMS_OUTPUT.put_line ('closer2employee : ' || v_user_objid);
      DBMS_OUTPUT.put_line ('close_case2act_entry : ' || v_seq_act_entry);

      BEGIN
         INSERT INTO table_close_case
                     (objid, close_date, actl_phone_time,
                      calc_phone_time, actl_rsrch_time, calc_rsrch_time,
                      used_unit, summary, tot_actl_phone_time,
                      tot_actl_rsrch_time, actl_bill_exp, actl_nonbill,
                      calc_bill_exp, calc_nonbill, tot_actl_bill,
                      tot_actl_nonb, bill_time, nonbill_time,
                      previous_closed,
                      cls_old_stat2gbst_elm,
                      cls_new_stat2gbst_elm,
                      close_rsolut2gbst_elm, last_close2case,
                      closer2employee, close_case2act_entry
                     )
              VALUES (v_seq_close_case, v_current_date, v_actl_phone_time,
                      v_calc_phone_time, 0, 0,
                      0.000000, '', v_tot_actl_phone_time,
                      0, 0.0, 0.0,
                      0.0, 0.0, 0.0,
                      0.0, 0, 0,
                      TO_DATE ('01/01/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                      rec_case.casests2gbst_elm,
                      rec_case_sts_closed.elm_objid,
                      rec_resolution_code.elm_objid, rec_case.objid,
                      v_user_objid, v_seq_act_entry
                     );
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_status := 'F';
            p_msg :=
               SUBSTR ('Unable to create new close case record: ' || SQLERRM,
                       1,
                       255
                      );
            RETURN;
      END;

      --rollback;
      COMMIT;
      p_status := 'S';
      p_msg := 'Completed sucessfully';
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_status := 'F';
         p_msg :=
            SUBSTR
                  (   'Unexpected error detected when trying to close case '
                   || v_case_id
                   || ': '
                   || SQLERRM,
                   1,
                   255
                  );
   END;
END create_case_pkg;
/