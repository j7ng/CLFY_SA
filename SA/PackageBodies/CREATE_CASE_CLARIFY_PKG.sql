CREATE OR REPLACE PACKAGE BODY sa."CREATE_CASE_CLARIFY_PKG" AS
/*****************************************************************
  * Package Name: CREATE_CASE_CLARIFY_PKG
  * Purpose     : To create, dispatch and close a case
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Natalio guada
  * Date        : 11/03/2005
  *
  * History
  * REVISIONS    VERSION  DATE          WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0      11/03/2005    NGuada     Initial Revision (CR4513)
  *              1.1      11/03/2005    VAdapa      Added header information
  *              1.2 and 1.3
  *              1.4       11/10/05     VAdapa      Added extra input parameter (stock type)
  *              1.5        05/17/06     VAdapa      CR4981_4982 changes - closed the cursors
  *              1.6    05/27/06     Nguada      Added extra input parameter (reason)
  *              1.7    05/27/06     Nguada      Added extra input parameter (problem_source)
  *              1.8    08/08/06     VAdapa      CR5391A - Added 3 new parameters to SP_CREATE_CASE procedure
  *                                       and a new procedure has been added sp_create_case_phone_log
  *                                    (copy of sp_create_case) for overloading purposes
  *              1.9      0817/06     VAdapa      Label Change from CR5391A to CR5523
  *              1.10 /1.11 /1.12/1.13   09/11/06   VA    CR5581/CR5582 -Bundle for Wal-mart / SAM's
  *              1.14     01/24/07   VA    CR5569-9 EME to remove table_num_scheme ref
  *  -------------------------------------------------------------------------------------------- */
  /*             1.0     02/15/2010  CL CR12874  New Initial Version
  ************************************************************************/

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

   CURSOR part_repl_curs (c_objid IN NUMBER)
   IS
      SELECT A.part_number
        FROM table_part_num A, table_x_exch_options b
       WHERE b.exch_source2part_num = c_objid
         AND b.x_exch_type = 'TECHNOLOGY'
         AND b.x_priority = 1
         AND b.exch_target2part_num = A.objid;

   CURSOR esn_curs (c_esn IN VARCHAR2)
   IS
      SELECT A.*, C.objid partobjid, C.part_number, C.x_restricted_use,
             C.x_technology                                    --CR5581/CR5582
        FROM table_part_inst A, table_mod_level b, table_part_num C
       WHERE part_serial_no = c_esn
         AND n_part_inst2part_mod = b.objid
         AND b.part_info2part_num = C.objid;

---------------------------------------------------------------------------------------------------
   PROCEDURE sp_create_case_phone_log (
      p_esn                 IN       VARCHAR2,
      p_contact_objid       IN       NUMBER,
      p_queue_name          IN       VARCHAR2,                   -- Queue Name
      p_type                IN       VARCHAR2,
      p_title               IN       VARCHAR2,
      p_history             IN       VARCHAR2,
      p_status              IN       VARCHAR2,
      -- Starting Status of the Case: Pending, BadAddress
      p_repl_part           IN       VARCHAR2,
      p_replacement_units   IN       NUMBER,
      p_case2task           IN       NUMBER,
      p_case_type_lvl2      IN       VARCHAR2,    -- Company (Tracfone, Net10)
      p_issue               IN       VARCHAR2,
      p_inbound             IN       VARCHAR2,
      p_outbound            IN       VARCHAR2,
      p_signal              IN       VARCHAR2,
      p_scan                IN       VARCHAR2,
      p_promo_code          IN       VARCHAR2,
      p_master_sid          IN       VARCHAR2,
      p_prl_soc             IN       VARCHAR2,
      p_time_tank           IN       VARCHAR2,
      p_tt_units            IN       NUMBER,
      p_fraud_id            IN       VARCHAR2,
      p_wrong_esn           IN       VARCHAR2,
      p_ttest_seq           IN       NUMBER,
      p_sys_seq             IN       NUMBER,
      p_channel             IN       VARCHAR2,
      -- Equivalent To Source System (IVR,WEBCSR,ETC)
      p_phone_due_date      IN       DATE,
      p_sys_phone_date      IN       DATE,
      p_super_login         IN       VARCHAR2,
      p_cust_units_claim    IN       NUMBER,
      p_fraud_units         IN       NUMBER,
      p_vm_password         IN       VARCHAR2,
      p_courier             IN       VARCHAR2,
      p_stock_type          IN       VARCHAR2,                           --1.4
      p_reason              IN       VARCHAR2,                           --1.6
      p_problem_source      IN       VARCHAR2,                           --1.7
      p_resultdesc          IN       VARCHAR2,                        --CR5523
      p_sim                 IN       VARCHAR2,                        --CR5523
      p_notes               IN       VARCHAR2,                        --CR5523
      p_case_id             OUT      VARCHAR2
   )
   IS
      esn_rec                esn_curs%rowtype;
      repl_esn_rec           esn_curs%rowtype;
      min_rec                esn_curs%rowtype;
      --part_repl_rec part_repl_curs%ROWTYPE;
      site_part_rec          site_part_curs%rowtype;
      contact_rec            contact_curs%rowtype;
      part_inst_rec          part_inst_curs%rowtype;
      site_rec               site_curs%rowtype;
      user_rec               user_curs%rowtype;
      gbst_lst1_rec          gbst_lst_curs%rowtype;
      gbst_elm1_rec          gbst_elm_curs%rowtype;
      gbst_lst2_rec          gbst_lst_curs%rowtype;
      gbst_elm2_rec          gbst_elm_curs%rowtype;
      gbst_lst3_rec          gbst_lst_curs%rowtype;
      gbst_elm3_rec          gbst_elm_curs%rowtype;
      gbst_lst4_rec          gbst_lst_curs%rowtype;
      gbst_elm4_rec          gbst_elm_curs%rowtype;
      gbst_lst5_rec          gbst_lst_curs%rowtype;
      gbst_elm5_rec          gbst_elm_curs%rowtype;
      gbst_lst6_rec          gbst_lst_curs%rowtype;                  --CR5523
      gbst_elm6_rec          gbst_elm_curs%rowtype;                  --CR5523
      current_user_rec       current_user_curs%rowtype;
      user2_rec              user2_curs%rowtype;
      address_rec            address_curs%rowtype;
      employee_rec           employee_curs%rowtype;
      contact_role_rec       contact_role_curs%rowtype;
      carrier_rec            carrier_curs%rowtype;
      part_num_rec           part_num_curs%rowtype;
      site2_rec              site2_curs%rowtype;
      wipbin_rec             wipbin_curs%rowtype;
      l_condition_objid      NUMBER;
      l_case_objid           NUMBER;
      l_act_entry_objid      NUMBER;
      l_case_id              VARCHAR2 (30);
      l_extra_objid          NUMBER;
      hold                   NUMBER;
      hold1                  VARCHAR2 (20);
      hold2                  VARCHAR2 (2000);
      cnt                    NUMBER                      := 0;
      v_site_objid           NUMBER                      := 0;
      v_site_address         NUMBER                      := 0;
      v_sitepart_min         VARCHAR2 (20)               := '0';
      v_sitepart_objid       NUMBER                      := 0;
      v_sitepart_site        NUMBER                      := 0;
      v_carrierid            NUMBER                      := 0;
      v_carriername          VARCHAR2 (60)               := '0';
      v_sitepart_zip         VARCHAR2 (10)               := '0';
      v_address_objid        NUMBER                      := 0;
      v_min_rec_carriermkt   NUMBER                      := 0;
      v_return_required      NUMBER                      := 0;
      l_alt_esn_objid        NUMBER                      := 0;
      v_status               VARCHAR2 (20);
--CR5581/CR5582
      v_ret_repl_units       NUMBER                      := 0;
      v_replacement_units    NUMBER                      := 0;
      v_history              VARCHAR2 (2000);
--CR5581/CR5582
--EME to remove table_num_scheme ref
      new_case_id_format     VARCHAR2 (100)              := NULL;
--End EME to remove table_num_scheme ref
   BEGIN
--
--
      cnt := cnt + 1;                                                     --1
      dbms_output.put_line ('sp_create_case:' || cnt);

--
      IF p_title = 'Defective Phone' OR p_title = 'Digital Exchange'
      THEN
         v_return_required := 1;
      END IF;

      --IF NVL(P_STATUS,'') = '' THEN
      --   v_status := 'Pending';
      --END IF;
      OPEN esn_curs (p_esn);

      FETCH esn_curs
       INTO esn_rec;

      IF esn_curs%notfound
      THEN
         CLOSE esn_curs;

         RETURN;
      END IF;

      CLOSE esn_curs;

--
      cnt := cnt + 1;                                                      --2
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN site_part_curs (esn_rec.x_part_inst2site_part);

      FETCH site_part_curs
       INTO site_part_rec;

      IF site_part_curs%notfound
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

      IF esn_curs%notfound
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
      OPEN site_curs (v_sitepart_site);

      FETCH site_curs
       INTO site_rec;

      IF site_curs%notfound
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
          --CLOSE address_curs;
         --RETURN;
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
      OPEN gbst_elm_curs (gbst_lst3_rec.objid, p_status);

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

      cnt := cnt + 1;
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--CR5523
      OPEN gbst_lst_curs ('Open');

      FETCH gbst_lst_curs
       INTO gbst_lst6_rec;

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
      OPEN gbst_elm_curs (gbst_lst6_rec.objid, 'Pending');

      FETCH gbst_elm_curs
       INTO gbst_elm6_rec;

      IF gbst_elm_curs%notfound
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--CR5523
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
      cnt := cnt + 1;                                                     --23
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      OPEN contact_curs (p_contact_objid);

      FETCH contact_curs
       INTO contact_rec;

      IF contact_curs%notfound
      THEN
         CLOSE contact_curs;

         RETURN;
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
      cnt := cnt + 1;                                                     --30
--
--
      cnt := cnt + 1;
      dbms_output.put_line ('sp_create_case:' || cnt);

--
--
      SELECT sa.seq ('condition')
        INTO l_condition_objid
        FROM dual;

--
      INSERT INTO sa.table_condition
                  (objid, condition, title, wipbin_time, sequence_num
                  )
           VALUES (l_condition_objid, 2, 'Open', sysdate, 0
                  );

--
      SELECT sa.seq ('case')
        INTO l_case_objid
        FROM dual;

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
--CR5581/CR5582
      IF p_title = 'Digital Exchange'
      THEN
         IF (    esn_rec.x_part_inst_status = '50'
             AND esn_rec.x_restricted_use <> 3
            )
         THEN
            convert_bo_to_sql_pkg.enroll_for_tech_exch (p_esn,
                                                        v_ret_repl_units
                                                       );
         END IF;

         IF nvl (v_ret_repl_units, 0) <> 0
         THEN
            v_replacement_units :=
                               nvl (p_replacement_units, 0)
                               + v_ret_repl_units;
            v_history :=
                  p_history
               || CHR (10)
               || 'BUNDLE Minutes (60) added as the original phone was qualified';
         END IF;
      END IF;

--      DBMS_OUTPUT.put_line ('v_ret_repl_units ' || v_ret_repl_units);
--       DBMS_OUTPUT.put_line ('v_replacement_units ' || v_replacement_units);
--       DBMS_OUTPUT.put_line ('v_history ' || v_history);

      --CR5581/CR5582
      INSERT INTO sa.table_case
                  (objid, x_case_type, title, s_title,
                   alt_phone_num, phone_num, ownership_stmp, modify_stmp,
                   id_number, creation_time, case_history, x_carrier_id,
                   x_esn, x_min, x_carrier_name,
                   x_text_car_id,
                   x_phone_model,
                   x_model, x_retailer_name, case2address,
                   case_reporter2site, case_reporter2contact,
                   calltype2gbst_elm, case_owner2user, case_originator2user,
                   case_wip2wipbin, casests2gbst_elm,
                   respprty2gbst_elm, respsvrty2gbst_elm,
                   case_state2condition, internal_case, yank_flag,
                   case_type_lvl2, x_stock_type, x_require_return,
                   x_activation_zip, x_repl_part_num, x_replacement_units,
                   alt_first_name, alt_last_name, alt_address, alt_city,
                   alt_state, alt_zipcode, x_po_number, x_case2task,
                   case_type_lvl1, x_return_desc, x_iccid             --CR5523
                  )
           VALUES (l_case_objid, p_type, p_title, UPPER (p_title),
                   contact_rec.phone, contact_rec.phone, sysdate, sysdate,
                   l_case_id, sysdate, v_history, --p_history, --CR5581/CR5582
                                                 v_carrierid,
                   esn_rec.part_serial_no, v_sitepart_min, v_carriername,
                   to_char (v_carrierid),
                   substr (part_num_rec.DESCRIPTION, 1, 30),
                   part_num_rec.part_number, site2_rec.NAME, v_address_objid,
                   v_site_objid, p_contact_objid,
                   gbst_elm2_rec.objid, user2_rec.objid, user2_rec.objid,
                   wipbin_rec.objid, gbst_elm3_rec.objid,
                   gbst_elm1_rec.objid, gbst_elm5_rec.objid,
                   l_condition_objid, 0, 0,
                   p_case_type_lvl2,
--              NULL,
                                    p_stock_type,                        --1.4
                                                 v_return_required,
                   v_sitepart_zip, p_repl_part, nvl (v_replacement_units, 0),

                   --CR5581/CR5582

                   --NVL (p_replacement_units, 0), --CR5581/CR5582
                   '', '', '', '',
                   '', '', '', p_case2task,
                   p_problem_source, p_resultdesc, p_sim              --CR5523
                  );

      IF p_title = 'Defective Phone' OR p_title = 'Digital Exchange'
      THEN
         SELECT sa.seq ('x_alt_esn')
           INTO l_alt_esn_objid
           FROM dual;

         INSERT INTO table_x_alt_esn
                     (objid, x_date, x_type,
                      x_orig_esn, x_replacement_esn, x_user,
                      x_status, x_alt_esn2case, x_alt_esn2contact,
                      x_orig_esn2part_inst, x_replacement_esn2part_inst,
                      x_new_sim
                     )
              VALUES (l_alt_esn_objid, sysdate, 'EXCHANGE',
                      esn_rec.part_serial_no, '', user2_rec.login_name,
                      'PENDING', l_case_objid, p_contact_objid,
                      esn_rec.objid, NULL,
                      NULL
                     );
      END IF;

      IF LENGTH (p_issue) > 0
      THEN
         SELECT sa.seq ('x_case_extra_info')
           INTO l_extra_objid
           FROM dual;

         INSERT INTO table_x_case_extra_info
                     (objid, x_issue, x_inbound, x_outbound,
                      x_signal, x_scan, x_promo_code, x_master_sid,
                      x_prl_soc, x_time_tank, x_tt_units, x_fraud_id,
                      x_wrong_esn, x_ttest_seq, x_sys_seq, x_channel,
                      x_phone_due_date, x_sys_phone_date, x_super_login,
                      x_extra_info2x_case, x_cust_units_claim, x_fraud_units,
                      x_vm_password, x_courier, x_reason
                     )
              VALUES (l_extra_objid, p_issue, p_inbound, p_outbound,
                      p_signal, p_scan, p_promo_code, p_master_sid,
                      p_prl_soc, p_time_tank, p_tt_units, p_fraud_id,
                      p_wrong_esn, p_ttest_seq, p_sys_seq, p_channel,
                      p_phone_due_date, p_sys_phone_date, p_super_login,
                      l_case_objid, p_cust_units_claim, p_fraud_units,
                      p_vm_password, p_courier, p_reason
                     );
      END IF;

      SELECT sa.seq ('act_entry')
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
                   || contact_rec.first_name
                   || ' '
                   || contact_rec.last_name
                   || ', Priority = '
                   || gbst_elm1_rec.title
                   || ', Status = '
                   || gbst_elm3_rec.title
                   || '.',
                   l_case_objid, user2_rec.objid, gbst_elm4_rec.objid
                  );

/* --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
      INSERT INTO sa.table_time_bomb
                  (objid, escalate_time, end_time,
                   focus_lowid, focus_type, time_period, flags,
                   cmit_creator2employee
                  )
           VALUES (sa.seq ('time_bomb'), sysdate - (365 * 10), sysdate,
                   l_case_objid, 0, l_act_entry_objid, 589826,
                   employee_rec.objid
                  );
*/

--
--CR5523
      IF p_notes IS NOT NULL
      THEN
         INSERT INTO table_phone_log
                     (objid, creation_time, stop_time, notes, site_time,
                      internal, commitment, due_date, action_type, dev,
                      case_phone2case, subc_phone2subcase,
                      phone_custmr2contact, phone_owner2user,
                      phone_empl2employee, old_phone_stat2gbst_elm,
                      new_phone_stat2gbst_elm, opp_phone2opportunity,
                      task_phone2task, contr_phone2contract
                     )
              VALUES (sa.seq ('phone_log'), sysdate, sysdate, p_notes, NULL,
                      NULL, 'Call back Required', NULL, 'Auto Log', NULL,
                      l_case_objid, NULL,
                      p_contact_objid, user2_rec.objid,
                      employee_rec.objid, gbst_elm6_rec.objid,
                      gbst_elm6_rec.objid, NULL,
                      NULL, NULL
                     );
      END IF;

--CR5523
      sp_dispatch_case (l_case_objid, p_queue_name, hold);
--
      p_case_id := l_case_id;
      COMMIT;
   END sp_create_case_phone_log;

----------------------------------------------------------------------------------------------------
--CR5523
   PROCEDURE sp_create_case (
      p_esn                 IN       VARCHAR2,
      p_contact_objid       IN       NUMBER,
      p_queue_name          IN       VARCHAR2,                   -- Queue Name
      p_type                IN       VARCHAR2,
      p_title               IN       VARCHAR2,
      p_history             IN       VARCHAR2,
      p_status              IN       VARCHAR2,
      -- Starting Status of the Case: Pending, BadAddress
      p_repl_part           IN       VARCHAR2,
      p_replacement_units   IN       NUMBER,
      p_case2task           IN       NUMBER,
      p_case_type_lvl2      IN       VARCHAR2,    -- Company (Tracfone, Net10)
      p_issue               IN       VARCHAR2,
      p_inbound             IN       VARCHAR2,
      p_outbound            IN       VARCHAR2,
      p_signal              IN       VARCHAR2,
      p_scan                IN       VARCHAR2,
      p_promo_code          IN       VARCHAR2,
      p_master_sid          IN       VARCHAR2,
      p_prl_soc             IN       VARCHAR2,
      p_time_tank           IN       VARCHAR2,
      p_tt_units            IN       NUMBER,
      p_fraud_id            IN       VARCHAR2,
      p_wrong_esn           IN       VARCHAR2,
      p_ttest_seq           IN       NUMBER,
      p_sys_seq             IN       NUMBER,
      p_channel             IN       VARCHAR2,
      -- Equivalent To Source System (IVR,WEBCSR,ETC)
      p_phone_due_date      IN       DATE,
      p_sys_phone_date      IN       DATE,
      p_super_login         IN       VARCHAR2,
      p_cust_units_claim    IN       NUMBER,
      p_fraud_units         IN       NUMBER,
      p_vm_password         IN       VARCHAR2,
      p_courier             IN       VARCHAR2,
      p_stock_type          IN       VARCHAR2,                           --1.4
      p_reason              IN       VARCHAR2,                           --1.6
      p_problem_source      IN       VARCHAR2,                           --1.7
      p_case_id             OUT      VARCHAR2
   )
   IS
      l_case_id   VARCHAR2 (20);
   BEGIN
      sp_create_case_phone_log (p_esn,
                                p_contact_objid,
                                p_queue_name,
                                p_type,
                                p_title,
                                p_history,
                                p_status,
                                p_repl_part,
                                p_replacement_units,
                                p_case2task,
                                p_case_type_lvl2,
                                p_issue,
                                p_inbound,
                                p_outbound,
                                p_signal,
                                p_scan,
                                p_promo_code,
                                p_master_sid,
                                p_prl_soc,
                                p_time_tank,
                                p_tt_units,
                                p_fraud_id,
                                p_wrong_esn,
                                p_ttest_seq,
                                p_sys_seq,
                                p_channel,
                                p_phone_due_date,
                                p_sys_phone_date,
                                p_super_login,
                                p_cust_units_claim,
                                p_fraud_units,
                                p_vm_password,
                                p_courier,
                                p_stock_type,
                                p_reason,
                                NULL,
                                NULL,
                                NULL,
                                p_problem_source,
                                l_case_id
                               );
      p_case_id := l_case_id;
      COMMIT;
   END sp_create_case;

----------------------------------------------------------------------------------------------------
--CR5523
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
      hold                NUMBER;
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
      -- 04/10/03 select seq_act_entry.nextval +(power(2,28)) into l_act_entry_objid from dual;
      SELECT sa.seq ('act_entry')
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

/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
    --Build The time_bomb entry
      INSERT INTO table_time_bomb
                  (objid, title,
                   escalate_time, end_time,
                   focus_lowid, focus_type, suppl_info, time_period, flags,
                   left_repeat, report_title, property_set, USERS,
                   cmit_creator2employee
                  )
           VALUES (sa.seq ('time_bomb'), NULL,
                   TO_DATE ('01/01/1753', 'dd/mm/yyyy'), sysdate,
                   p_case_objid, 0, NULL, l_act_entry_objid, 655362,
                   0, NULL, NULL, NULL,
                   employee_rec.objid
                  );
*/

   END;

----------------------------------------------------------------------------------------------------
   PROCEDURE sp_close_case (
      p_case_id                 VARCHAR2,
      p_user_login_name         VARCHAR2,
      p_source                  VARCHAR2,
      p_resolution_code         VARCHAR2,
      p_status            OUT   VARCHAR2,
      p_msg               OUT   VARCHAR2
   )
   IS
      v_current_date          DATE                        := sysdate;
      v_case_id               table_case.id_number%TYPE;
      v_user_objid            NUMBER;

      CURSOR c_case
      IS
         SELECT C.*
           FROM table_case C
          WHERE id_number = v_case_id;

      rec_case                c_case%rowtype;

      CURSOR c_condition (c_condition_objid NUMBER)
      IS
         SELECT *
           FROM table_condition
          WHERE objid = c_condition_objid;

      rec_condition           c_condition%rowtype;

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
         SELECT T.*
           FROM table_condition C, table_task T, table_x_call_trans ct
          WHERE C.s_title || '' <> 'CLOSED ACTION ITEM'
            AND T.task_state2condition = C.objid
            AND ct.objid = T.x_task2x_call_trans
            AND ct.x_action_type || '' IN ('1', '2', '3', '5')
            AND ct.x_min = c_min
            AND ct.x_service_id = c_esn;

      v_seq_close_case        NUMBER;
      v_seq_act_entry         NUMBER;
      v_seq_time_bomb         NUMBER;
      v_resolution_gbst       VARCHAR2 (80)               := 'Resolution Code';
      v_resolution_default    VARCHAR2 (80)          := 'Carri Problem Solved';
      v_resolution_code       VARCHAR2 (80);
      v_addl_info             VARCHAR2 (255);
      v_actl_phone_time       NUMBER                      := 0;
      v_sub_actl_phone_time   NUMBER                      := 0;
      v_sub_calc_phone_time   NUMBER                      := 0;
      v_calc_phone_time       NUMBER                      := 0;
      v_tot_actl_phone_time   NUMBER                      := 0;
      v_case_history          VARCHAR2 (32000);
      rec_case_sts_closed     c_gbst_elm%rowtype;
      rec_act_caseclose       c_gbst_elm%rowtype;
      rec_act_accept          c_gbst_elm%rowtype;
      rec_resolution_code     c_gbst_elm%rowtype;
      hold                    NUMBER;
   BEGIN
      v_case_id := RTRIM (LTRIM (p_case_id));
      v_resolution_code := p_resolution_code;
      v_resolution_code := RTRIM (LTRIM (nvl (v_resolution_code, ' ')));

      OPEN c_case;

      FETCH c_case
       INTO rec_case;

      IF c_case%notfound
      THEN
         p_status := 'F';
         p_msg := 'CASE ' || nvl (p_case_id, '<NULL>') || ' not found';

         CLOSE c_case;

         RETURN;
      END IF;

      CLOSE c_case;

      dbms_output.put_line ('CASE ' || v_case_id || ' found.');

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

      dbms_output.put_line ('User login name ' || p_user_login_name
                            || ' found.'
                           );
      dbms_output.put_line (   'length of resolution code: '
                            || LENGTH (v_resolution_code)
                           );

      --IF length(v_resolution_code) < 1 or v_resolution_code is null THEN
      IF nvl (LENGTH (v_resolution_code), 0) < 1
      THEN
         v_resolution_code := v_resolution_default;
      END IF;

      OPEN c_gbst_elm (v_resolution_gbst, v_resolution_code);

      FETCH c_gbst_elm
       INTO rec_resolution_code;

      IF c_gbst_elm%notfound
      THEN
         p_status := 'F';
         p_msg := 'Resolution code ' || v_resolution_code || ' is not valid';

         CLOSE c_gbst_elm;

         RETURN;
      END IF;

      CLOSE c_gbst_elm;

      dbms_output.put_line ('Resolution code: ' || v_resolution_code);

      OPEN c_condition (nvl (rec_case.case_state2condition, 0));

      FETCH c_condition
       INTO rec_condition;

      IF c_condition%notfound
      THEN
         p_status := 'F';
         p_msg := 'CONDITION FOR CASE ' || v_case_id || ' not found.';

         CLOSE c_condition;

         RETURN;
      END IF;

      CLOSE c_condition;

      dbms_output.put_line (   'CONDITION objid FOR '
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

      IF c_gbst_elm%notfound
      THEN
         p_status := 'F';
         p_msg := 'Status for closed case not found';

         CLOSE c_gbst_elm;

         RETURN;
      END IF;

      CLOSE c_gbst_elm;

      dbms_output.put_line ('Status for closed case found');

      OPEN c_gbst_elm ('Activity Name', 'Case Close');

      FETCH c_gbst_elm
       INTO rec_act_caseclose;

      IF c_gbst_elm%notfound
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

      IF c_gbst_elm%notfound
      THEN
         p_status := 'F';
         p_msg := 'Activity code for accepting case not found';

         CLOSE c_gbst_elm;

         RETURN;
      END IF;

      CLOSE c_gbst_elm;

      dbms_output.put_line ('Activity code for closed case not found');
      dbms_output.put_line ('Start to close case:');

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
               v_sub_actl_phone_time + nvl (c_subcase_rec.actl_phone_time, 0);
         v_sub_calc_phone_time :=
               v_sub_calc_phone_time + nvl (c_subcase_rec.calc_phone_time, 0);
      END LOOP;

      v_actl_phone_time := round (v_actl_phone_time + v_sub_actl_phone_time);
      v_calc_phone_time := round (v_actl_phone_time + v_sub_calc_phone_time);
      v_tot_actl_phone_time := round (v_actl_phone_time);
      dbms_output.put_line ('actl_phone_time: ' || v_actl_phone_time);
      dbms_output.put_line ('calc_phone_time: ' || v_calc_phone_time);
      dbms_output.put_line ('v_tot_actl_phone_time: ' || v_tot_actl_phone_time);

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
               substr (   'Unable to update condition for case id '
                       || v_case_id
                       || sqlerrm,
                       1,
                       255
                      );
            RETURN;
      END;

      dbms_output.put_line ('Condition for Case id ' || v_case_id
                            || ' updated.'
                           );
      v_case_history := rec_case.case_history;
      v_case_history :=
            v_case_history
         || CHR (10)
         || '*** CASE CLOSE '
         ||
--         TO_CHAR (v_current_date, 'DD/MM/YY HH:MI:SS AM ') ||
            to_char (v_current_date, 'MM/DD/YYYY HH:MI:SS AM ')
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
               substr (   'Unable to update case record for case id '
                       || v_case_id
                       || ': '
                       || sqlerrm,
                       1,
                       255
                      );
            RETURN;
      END;

      dbms_output.put_line ('Case record updated.');

      -- 04/10/03 SELECT SEQ_act_entry.nextval + power(2,28) INTO v_seq_act_entry from dual;
      SELECT sa.seq ('act_entry')
        INTO v_seq_act_entry
        FROM dual;

      --SELECT SEQ_time_bomb.nextval INTO v_seq_time_bomb;
      v_addl_info :=
            'Status = Closed, Resolution Code ='
         || v_resolution_code
         || ' State = Open.';
      dbms_output.put_line ('table_act_entry record: ' || CHR (10));
      dbms_output.put_line ('OBJID : ' || v_seq_act_entry);
      dbms_output.put_line ('ACT_CODE : ' || rec_act_caseclose.RANK);
      dbms_output.put_line ('ENTRY_TIME : ' || v_current_date);
      dbms_output.put_line ('ADDNL_INFO : ' || v_addl_info);
      dbms_output.put_line (   'ENTRY_NAME2GBST_ELM : '
                            || rec_act_caseclose.elm_objid
                           );
      dbms_output.put_line ('ACT_ENTRY2CASE : ' || rec_case.objid);
      dbms_output.put_line ('ACT_ENTRY2USER : ' || v_user_objid);

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
               substr ('Unable to create new activity record: ' || sqlerrm,
                       1,
                       255
                      );
            RETURN;
      END;

      -- 04/10/03 SELECT SEQ_close_case.nextval + power(2,28) INTO v_seq_close_case FROM dual;
      SELECT sa.seq ('close_case')
        INTO v_seq_close_case
        FROM dual;

      dbms_output.put_line (   'table_close_case record: '
                            || v_seq_close_case
                            || CHR (10)
                           );
      dbms_output.put_line ('OBJID : ' || v_seq_close_case);
      dbms_output.put_line ('close_date : ' || v_current_date);
      dbms_output.put_line ('actl_phone_time : ' || v_actl_phone_time);
      dbms_output.put_line ('calc_phone_time : ' || v_calc_phone_time);
      dbms_output.put_line ('tot_actl_phone_time : ' || v_tot_actl_phone_time);
      dbms_output.put_line (   'cls_old_stat2gbst_elm : '
                            || rec_case.casests2gbst_elm
                           );
      dbms_output.put_line (   'cls_new_stat2gbst_elm : '
                            || rec_case_sts_closed.elm_objid
                           );
      dbms_output.put_line (   'close_rsolut2gbst_elm : '
                            || rec_resolution_code.elm_objid
                           );
      dbms_output.put_line ('last_close2case : ' || rec_case.objid);
      dbms_output.put_line ('closer2employee : ' || v_user_objid);
      dbms_output.put_line ('close_case2act_entry : ' || v_seq_act_entry);

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
               substr ('Unable to create new close case record: ' || sqlerrm,
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
            substr
                  (   'Unexpected error detected when trying to close case '
                   || v_case_id
                   || ': '
                   || sqlerrm,
                   1,
                   255
                  );
   END;
END create_case_clarify_pkg;
/