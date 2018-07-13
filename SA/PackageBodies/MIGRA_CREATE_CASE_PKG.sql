CREATE OR REPLACE PACKAGE BODY sa."MIGRA_CREATE_CASE_PKG" AS
/*****************************************************************
  * Package Name: Migra_Create_Case_Pkg (BODY)
  * Purpose     : To create NO_CASE Cases
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Fernando Lasa, DRITON
  * Date        : 09/14/2005
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE        WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0                  Fernando Lasa  Initial Revision
  *              1.3      09/14/05    Fernando Lasa  CR 4187 - To close some cursors that are
  *                                                            generating errors.
  *              1.4      01/24/07    VAdapa      CR5569-9 EME to remove table_num_scheme ref
  * --------------------------------------------------------------------
  *              1.0      02/14/2010  CL          CR12874
  ************************************************************************/
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
        FROM dual;

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
      SELECT S.*
        FROM sa.table_site S, sa.table_inv_bin ib
       WHERE S.site_id = ib.bin_name AND ib.objid = c_objid;

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

   CURSOR esn_curs (c_esn IN VARCHAR2)
   IS
      SELECT A.*, C.objid partobjid, C.part_number, C.x_restricted_use
        FROM table_part_inst A, table_mod_level b, table_part_num C
       WHERE part_serial_no = c_esn
         AND n_part_inst2part_mod = b.objid
         AND b.part_info2part_num = C.objid;

   CURSOR dummy_contact_curs (c_restrict IN NUMBER)
   IS
      SELECT contact_role2site
        FROM table_contact_role
       WHERE contact_role2contact =
                (SELECT objid
                   FROM table_contact
                  WHERE first_name =
                                   decode (c_restrict,
                                           3, '1100NET10',
                                           '1100'
                                          ));

----------------------------------------------------------------------------------------------------
   PROCEDURE sp_create_case (
      p_esn          IN       VARCHAR2,
      p_queue_name   IN       VARCHAR2,
      p_type         IN       VARCHAR2,
      p_title        IN       VARCHAR2,
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
      dummy_contact_rec        dummy_contact_curs%rowtype;
      esn_rec                  esn_curs%rowtype;
      repl_esn_rec             esn_curs%rowtype;
      min_rec                  esn_curs%rowtype;
      site_part_rec            site_part_curs%rowtype;
      contact_rec              contact_curs%rowtype;
      part_inst_rec            part_inst_curs%rowtype;
      site_rec                 site_curs%rowtype;
      gbst_lst1_rec            gbst_lst_curs%rowtype;
      gbst_elm1_rec            gbst_elm_curs%rowtype;
      gbst_lst2_rec            gbst_lst_curs%rowtype;
      gbst_elm2_rec            gbst_elm_curs%rowtype;
      gbst_lst3_rec            gbst_lst_curs%rowtype;
      gbst_elm3_rec            gbst_elm_curs%rowtype;
      gbst_lst4_rec            gbst_lst_curs%rowtype;
      gbst_elm4_rec            gbst_elm_curs%rowtype;
      gbst_lst5_rec            gbst_lst_curs%rowtype;
      gbst_elm5_rec            gbst_elm_curs%rowtype;
      current_user_rec         current_user_curs%rowtype;
      user2_rec                user2_curs%rowtype;
      address_rec              address_curs%rowtype;
      employee_rec             employee_curs%rowtype;
      contact_role_rec         contact_role_curs%rowtype;
      carrier_rec              carrier_curs%rowtype;
      part_num_rec             part_num_curs%rowtype;
      site2_rec                site2_curs%rowtype;
      task_user_rec            user_curs%rowtype;
      wipbin_rec               wipbin_curs%rowtype;
      l_condition_objid        NUMBER;
      l_case_objid             NUMBER;
      l_act_entry_objid        NUMBER;
      l_case_id                VARCHAR2 (30);
      hold                     NUMBER;
      cnt                      NUMBER                       := 0;
      v_site_objid             NUMBER                       := 0;
      v_site_address           NUMBER                       := 0;
      v_sitepart_min           VARCHAR2 (20)                := '0';
      v_sitepart_objid         NUMBER                       := 0;
      v_sitepart_site          NUMBER                       := 0;
      v_contact_role2contact   NUMBER                       := 0;
      v_contact_phone          VARCHAR2 (20)                := '0';
      v_contact_objid          NUMBER                       := 0;
      v_carrierid              NUMBER                       := 0;
      v_carriername            VARCHAR2 (60)                := '0';
      v_sitepart_zip           VARCHAR2 (10)                := '0';
      v_address_objid          NUMBER                       := 0;
      v_min_rec_carriermkt     NUMBER                       := 0;
--EME to remove table_num_scheme ref
      new_case_id_format       VARCHAR2 (100)               := NULL;
--End EME to remove table_num_scheme ref
   BEGIN
--
      cnt := cnt + 1;                                                     --1
      dbms_output.put_line ('sp_create_case:' || cnt);

--
      OPEN esn_curs (p_esn);

      FETCH esn_curs
       INTO esn_rec;

      IF esn_curs%notfound
      THEN
         CLOSE esn_curs;

         RETURN;
      END IF;

      CLOSE esn_curs;

      cnt := cnt + 1;                                                      --2
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN site_part_curs (esn_rec.x_part_inst2site_part);

      FETCH site_part_curs
       INTO site_part_rec;

      IF site_part_curs%notfound
      THEN
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

      IF esn_curs%notfound
      THEN
         v_min_rec_carriermkt := 0;
      ELSE
         v_min_rec_carriermkt := min_rec.part_inst2carrier_mkt;
      END IF;

      CLOSE esn_curs;

--
      cnt := cnt + 1;                                                      --3
      dbms_output.put_line ('sp_create_case:' || cnt);
--
      cnt := cnt + 1;                                                      --4
      dbms_output.put_line (   'sp_create_case:'
                            || cnt
                            || ' site_part_rec.objid:'
                            || v_sitepart_objid
                           );

--
--
      OPEN part_inst_curs (esn_rec.objid);

      FETCH part_inst_curs
       INTO part_inst_rec;

      IF part_inst_curs%notfound
      THEN
         CLOSE part_inst_curs;

         RETURN;
      END IF;

      CLOSE part_inst_curs;

--
      cnt := cnt + 1;                                                      --5
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN dummy_contact_curs (esn_rec.x_restricted_use);

      FETCH dummy_contact_curs
       INTO dummy_contact_rec;

      IF dummy_contact_curs%found
      THEN
         v_sitepart_site := dummy_contact_rec.contact_role2site;
      END IF;

      CLOSE dummy_contact_curs;

      OPEN site_curs (v_sitepart_site);

      FETCH site_curs
       INTO site_rec;

      IF site_curs%notfound
      THEN
         v_site_address := 0;
         v_site_objid := 0;
      ELSE
         v_site_address := site_rec.cust_primaddr2address;
         v_site_objid := site_rec.objid;
      END IF;

      CLOSE site_curs;

--
      cnt := cnt + 1;                                                      --6
      dbms_output.put_line ('sp_create_case:' || cnt);
--
--
      cnt := cnt + 1;                                                      --7
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN address_curs (v_site_address);

      FETCH address_curs
       INTO address_rec;

      IF address_curs%notfound
      THEN
         v_address_objid := 0;
      ELSE
         v_address_objid := address_rec.objid;
      END IF;

      CLOSE address_curs;

--
      cnt := cnt + 1;                                                      --8
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Response Priority Code');

      FETCH gbst_lst_curs
       INTO gbst_lst1_rec;

      IF gbst_lst_curs%notfound
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                      --9
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst1_rec.objid, 'High');

      FETCH gbst_elm_curs
       INTO gbst_elm1_rec;

      IF gbst_elm_curs%notfound
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --10
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Case Type');

      FETCH gbst_lst_curs
       INTO gbst_lst2_rec;

      IF gbst_lst_curs%notfound
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --11
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst2_rec.objid, 'Problem');

      FETCH gbst_elm_curs
       INTO gbst_elm2_rec;

      IF gbst_elm_curs%notfound
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --12
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Open');

      FETCH gbst_lst_curs
       INTO gbst_lst3_rec;

      IF gbst_lst_curs%notfound
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --13
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst3_rec.objid, 'Isolated');

      FETCH gbst_elm_curs
       INTO gbst_elm3_rec;

      IF gbst_elm_curs%notfound
      THEN
         dbms_output.put_line ('No Isolated');

         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --14
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN current_user_curs;

      FETCH current_user_curs
       INTO current_user_rec;

      IF current_user_curs%notfound
      THEN
         current_user_rec.USER := 'appsrv';            -- changed from appsvr
      END IF;

      CLOSE current_user_curs;

--
      cnt := cnt + 1;                                                     --15
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN user2_curs (current_user_rec.USER);

      FETCH user2_curs
       INTO user2_rec;

      IF user2_curs%notfound
      THEN
         CLOSE user2_curs;

         RETURN;
      END IF;

      CLOSE user2_curs;

--
      cnt := cnt + 1;                                                     --16
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN wipbin_curs (user2_rec.objid);

      FETCH wipbin_curs
       INTO wipbin_rec;

      IF wipbin_curs%notfound
      THEN
         CLOSE wipbin_curs;

         RETURN;
      END IF;

      CLOSE wipbin_curs;

--
      cnt := cnt + 1;                                                     --17
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Activity Name');

      FETCH gbst_lst_curs
       INTO gbst_lst4_rec;

      IF gbst_lst_curs%notfound
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --18
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst4_rec.objid, 'Create');

      FETCH gbst_elm_curs
       INTO gbst_elm4_rec;

      IF gbst_elm_curs%notfound
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --19
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_lst_curs ('Problem Severity Level');

      FETCH gbst_lst_curs
       INTO gbst_lst5_rec;

      IF gbst_lst_curs%notfound
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                     --20
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN gbst_elm_curs (gbst_lst5_rec.objid, 'High');

      FETCH gbst_elm_curs
       INTO gbst_elm5_rec;

      IF gbst_elm_curs%notfound
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --21
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN employee_curs (user2_rec.objid);

      FETCH employee_curs
       INTO employee_rec;

      IF employee_curs%notfound
      THEN
         CLOSE employee_curs;

         RETURN;
      END IF;

      CLOSE employee_curs;

--
      cnt := cnt + 1;                                                     --22
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN contact_role_curs (v_site_objid);

      FETCH contact_role_curs
       INTO contact_role_rec;

      IF contact_role_curs%notfound
      THEN
         v_contact_role2contact := 0;
      ELSE
         v_contact_role2contact := contact_role_rec.contact_role2contact;
      END IF;

      CLOSE contact_role_curs;

--
      cnt := cnt + 1;                                                     --23
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN contact_curs (v_contact_role2contact);

      FETCH contact_curs
       INTO contact_rec;

      IF contact_curs%notfound
      THEN
         v_contact_phone := '0';
         v_contact_objid := 0;
      ELSE
         v_contact_phone := contact_rec.phone;
         v_contact_objid := contact_rec.objid;
      END IF;

      CLOSE contact_curs;

--
      cnt := cnt + 1;                                                     --24
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN carrier_curs (v_min_rec_carriermkt);

      FETCH carrier_curs
       INTO carrier_rec;

      IF carrier_curs%notfound
      THEN
         v_carrierid := 0;
         v_carriername := '0';
      ELSE
         v_carrierid := carrier_rec.x_carrier_id;
         v_carriername := carrier_rec.x_mkt_submkt_name;
      END IF;

      CLOSE carrier_curs;

--
      cnt := cnt + 1;                                                     --25
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN part_num_curs (esn_rec.n_part_inst2part_mod);

      FETCH part_num_curs
       INTO part_num_rec;

      IF part_num_curs%notfound
      THEN
         CLOSE part_num_curs;

         RETURN;
      END IF;

      CLOSE part_num_curs;

--
      cnt := cnt + 1;                                                     --26
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN site2_curs (part_inst_rec.part_inst2inv_bin);

      FETCH site2_curs
       INTO site2_rec;

      IF site2_curs%notfound
      THEN
         CLOSE site2_curs;

         RETURN;
      END IF;

      CLOSE site2_curs;

--
      cnt := cnt + 1;                                                     --27
      dbms_output.put_line ('sp_create_case:' || cnt);
--
--
      cnt := cnt + 1;                                                     --28
      dbms_output.put_line ('sp_create_case:' || cnt);
--
--
      cnt := cnt + 1;                                                     --29
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN user_curs (268435556);                               -- objid of SA

      FETCH user_curs
       INTO task_user_rec;

      IF user_curs%notfound
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
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      SELECT seq ('condition')
        INTO l_condition_objid
        FROM dual;

--
      INSERT INTO sa.table_condition
                  (objid, condition, title, wipbin_time, sequence_num
                  )
           VALUES (l_condition_objid, 2, 'Open', sysdate, 0
                  );

--
      SELECT seq ('case')
        INTO l_case_objid
        FROM dual;

--
      p_case_objid := l_case_objid;
--
   --EME to remove table_num_scheme ref
--
--
--       SELECT     next_value
--             INTO l_case_id
--             FROM sa.table_num_scheme
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
--      sa.next_id ('Case ID', l_case_id, new_case_id_format);
--cwl CR12874

      --End EME to remove table_num_scheme ref
--
      INSERT INTO sa.table_case
                  (objid, x_case_type, title, s_title,
                   alt_phone_num, phone_num, ownership_stmp, modify_stmp,
                   id_number, creation_time,
                   case_history,
                   x_carrier_id, x_esn, x_min,
                   x_carrier_name, x_text_car_id,
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
                   v_contact_phone, v_contact_phone, sysdate, sysdate,
                   l_case_id, sysdate,
                   '*** CASE: ESN without a valid Case. NO CASE case is created.',
                   v_carrierid, esn_rec.part_serial_no, v_sitepart_min,
                   v_carriername, to_char (v_carrierid),
                   substr (part_num_rec.DESCRIPTION, 1, 30),
                   part_num_rec.part_number, site2_rec.NAME, v_address_objid,
                   v_site_objid, v_contact_objid,
                   gbst_elm2_rec.objid, task_user_rec.objid,
                   task_user_rec.objid, wipbin_rec.objid,
                   gbst_elm3_rec.objid, gbst_elm1_rec.objid,
                   gbst_elm5_rec.objid, l_condition_objid, 0,
                   0, 'Tracfone', NULL,         --repl_esn_rec.part_serial_no,
                                       1,
                   v_sitepart_zip, NULL,           --repl_esn_rec.part_number,
                                        0,
                   p_firstname, p_lastname, p_address, p_city,
                   p_state, p_zip, p_tracking
                  );

      SELECT seq ('act_entry')
        INTO l_act_entry_objid
        FROM dual;

--
      INSERT INTO sa.table_act_entry
                  (objid, act_code, entry_time,
                   addnl_info,
                   act_entry2case, act_entry2user, entry_name2gbst_elm
                  )
           VALUES (l_act_entry_objid, 600, sysdate,
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
                   cmit_creator2employee)
           VALUES (seq ('time_bomb'), sysdate - (365 * 10), sysdate,
                   l_case_objid, 0, l_act_entry_objid, 589826,
                   employee_rec.objid);
*/
--
         /*** Changes ReplacementPartNumber Dealer info ******/
      UPDATE table_part_inst
         SET part_inst2inv_bin = esn_rec.part_inst2inv_bin
       WHERE objid = repl_esn_rec.objid;

      sp_dispatch_case (l_case_objid, p_queue_name, hold);
--
      p_case_objid := l_case_objid;
      p_case_id := l_case_id;
--      COMMIT;
   END sp_create_case;

----------------------------------------------------------------------------------------------------
   PROCEDURE sp_dispatch_case (
      p_case_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   )
   IS
      current_user_rec    current_user_curs%rowtype;
      case_rec            case_curs%rowtype;
      condition_rec       condition_curs%rowtype;
      user2_rec           user2_curs%rowtype;
      employee_rec        employee_curs%rowtype;
      gbst_lst_rec        gbst_lst_curs%rowtype;
      gbst_elm_rec        gbst_elm_curs%rowtype;
      queue_rec           queue_curs%rowtype;
      l_act_entry_objid   NUMBER;
   BEGIN
      p_dummy_out := 1;

      OPEN queue_curs (p_queue_name);

      FETCH queue_curs
       INTO queue_rec;

      IF queue_curs%notfound
      THEN
         CLOSE queue_curs;

         RETURN;
      END IF;

      CLOSE queue_curs;

--
      OPEN current_user_curs;

      FETCH current_user_curs
       INTO current_user_rec;

      IF current_user_curs%notfound
      THEN
         current_user_rec.USER := 'appsrv';            -- changed from appsvr
      END IF;

      CLOSE current_user_curs;

--
      OPEN case_curs (p_case_objid);

      FETCH case_curs
       INTO case_rec;

      IF case_curs%notfound
      THEN
         CLOSE case_curs;

         RETURN;
      END IF;

      CLOSE case_curs;

--
      OPEN condition_curs (case_rec.case_state2condition);

      FETCH condition_curs
       INTO condition_rec;

      IF condition_curs%notfound
      THEN
         CLOSE condition_curs;

         RETURN;
      END IF;

      CLOSE condition_curs;

--
      OPEN user2_curs (current_user_rec.USER);

      FETCH user2_curs
       INTO user2_rec;

      IF user2_curs%notfound
      THEN
         CLOSE user2_curs;

         RETURN;
      END IF;

      CLOSE user2_curs;

--
      OPEN employee_curs (user2_rec.objid);

      FETCH employee_curs
       INTO employee_rec;

      IF employee_curs%notfound
      THEN
         CLOSE employee_curs;

         RETURN;
      END IF;

      CLOSE employee_curs;

--
      OPEN gbst_lst_curs ('Activity Name');

      FETCH gbst_lst_curs
       INTO gbst_lst_rec;

      IF gbst_lst_curs%notfound
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      OPEN gbst_elm_curs (gbst_lst_rec.objid, 'Dispatch');

      FETCH gbst_elm_curs
       INTO gbst_elm_rec;

      IF gbst_elm_curs%notfound
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
--Updates the Condition Record
      UPDATE table_condition
         SET condition = 10,
             queue_time = sysdate,
             title = 'Open-Dispatch',
             s_title = 'OPEN-DISPATCH'
       WHERE objid = condition_rec.objid;

      UPDATE table_case
         SET case_currq2queue = queue_rec.objid
       WHERE objid = p_case_objid;

--Build the Activity Entry
      SELECT seq ('act_entry')
        INTO l_act_entry_objid
        FROM dual;

--
      INSERT INTO table_act_entry
                  (objid, act_code, entry_time,
                   addnl_info,
                   proxy, removed, act_entry2case, act_entry2user,
                   entry_name2gbst_elm
                  )
           VALUES (l_act_entry_objid, 900, sysdate,
                   ' Dispatched to Queue ' || p_queue_name,
                   current_user_rec.USER, 0, p_case_objid, user2_rec.objid,
                   gbst_elm_rec.objid
                  );
--
/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
    --Build The time_bomb entry
      INSERT INTO table_time_bomb
                  (objid, title,
                   escalate_time, end_time,
                   focus_lowid, focus_type, suppl_info, time_period, flags,
                   left_repeat, report_title, property_set, USERS,
                   cmit_creator2employee)
           VALUES (seq ('time_bomb'), NULL,
                   TO_DATE ('01/01/1753', 'dd/mm/yyyy'), sysdate,
                   p_case_objid, 0, NULL, l_act_entry_objid, 655362,
                   0, NULL, NULL, NULL,
                   employee_rec.objid);
*/
--
   END sp_dispatch_case;
--
END migra_create_case_pkg;
/