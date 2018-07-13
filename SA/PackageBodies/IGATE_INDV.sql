CREATE OR REPLACE PACKAGE BODY sa."IGATE_INDV"
AS
/***************************************************************************
    Name         :  SA.IGATE_INDV
    Purpose      :  To return the carrier and its features based on an esn
                    or task id or case id
    Author       :  Gerald Pintado / Vanisri Adapa
    Date         :  ???
    Revisions    :
    Version     Date      Who       Purpose
    -------   --------  -------     --------------------------
    1.0         ???     GPintado    Initial revision
                        VAdapa
    1.1       06/28/04  VAdapa      CR3016 - Modify to get the features from
                                    TABLE_X_CARRIER_FEATURES instead from
                                    TABLE_X_CARRIER
    1.2       07/07/04  VAdapa      CR2739 Changes
                                    A) Return SUI,TIMEOUT,DEBUG fields
                                    for a given transmission method based
                                    on technology
                                    B) Remove Cingular Rate Plan Logic
                                    C) Remove p_curr_method input parameter
                                        and Do not return current method
                                    D) Return recordset for MIN
                                    E) Return OLD MIN
                                    F) Exclude task from SP_CHECK_BLACKOUT
   1.3      08/26/04  RGandhi     CR3153. Added procedure sp_esn_min_status
                               This will be used by Intergate to determine
                               validity of the Action item
   1.4      09/21/04   VAdapa       CR3224 - Use MIN to get the site part record
   1.5      10/01/04   VAdapa       CR3153 - Lengthen the ESN from 11 to 15
   1.6      11/04/04   Gpintado     CR3327 Added procedure sp_igate_update for
                                    single User Interface, logic is identical to
                                    the igate_in3 package except with input params
   1.7      11/23/04   Gpintado     CR3327 Removed prcoedure sp_igate_update due to
                                    table locking.
   1.8      12/01/04   Gpintado     CR3417 Added l_sim variable to ref_cursor
                                    and added port_in check. Added logic for t-mobile
                                    lines to assign state_value = 'GSM'. Added CurrESN
                                    to get_min_curs. Changed logic to old_esn_curs.
   1.9      03/14/05   Gpintado     CR3690 Changed variable size from 100 to 500
   2.0       03/02/05   RGandhi      CR3647 - T-Mobile changes. For Msid update,
                   insert a line if the min is a dummy line.
                   Update all tables with new min.
   2.1      05/26/05    VAdapa      CR3918 - Cingular MIN Change (PVCS Version 1.8)
                                    Return rate_center_no
   2.2      10/04/05    VAdapa      CR4530 - Create Batch Job to Update "T" numbers (PVCS Revision 1.9)
   2.3      10/10/05    VAdapa      Fix for CR4530 (PVCS Revision 1.10)
   2.4      10/10/05    VAdapa      Fix for CR4530 (PVCS Revision 1.11)
   2.5      10/12/05    GPintado    CR4579 - Added Technology param to sp_get_orderType (PVCS Revision 1.13)
   2.6      10/20/05    NLalovic    Cingular Next Available project changes:
                                    Removed hardcoded string "TMOBILE_" from sp_flag_new_msid procedure
                                    and replaced it with  get_min_rec.x_parent_name || '_'.
                                    For this purpose, cursor get_min_curs has been modified to query
                                    TABLE_X_PARENT and return the value of X_PARENT_NAME column.
                                    Carrier with no inventory in TracFone can be CINGULAR, not only T-MOBILE.
   2.7      01/30/06    NLalovic    Cingular Next Available project changes:
                                    Added new function "get_latest_order_type" to sp_ig_info procedure
                                    to return order type of the latest task for given ESN number, excluding
                                    the current task id.
                                    Added new field last_order_type to "SELECT FROM DUAL..." statement
                                    to return the value of get_latest_order_type function to the output record
                                    (ref cursor variable) in sp_ig_info procedure.
                                    Another package: sa.igateindvpkg was also modified to accomodate this change.
                                    This modification was about the layout of the record where we had to add a new field
                                    "last_order_type" to it so that cursor variable can accept the value for this field
                                    in sp_ig_info procedure.
   2.8      02/07/06    NLalovic    Cingular Next Available project changes:
                                    Modified logic in get_latest_order_type function.
   2.9      03/09/06    VAdapa      CR4981_4982 Changes for data phones (Get carrier features based on the data_capable)
                              PVCS Revision 1.18
   3.0      08/14/06    Gpintado    CR5395 - Added p_task_id='LUTS' to sp_flag_new_msid
   3.1/1.20 10/03/06 VAdapa      CR4589 -1 CSI - Front-End WEBCSR Changes
   3.2 1.21 07/05/07    ABarrera   CR6254  MEID changes: Getting ESN hex value, Using a function from igate package.
   3.3      12/06/07  JAmalraj     Added hint for function based index IND_ORDER_TYPE3 for cursors o_type_curs
                   and o_null_type_curs
   /**************************************************************************/---

   /***************************************************************************
     NEW PVCS STRUCTURE
    Version     Date      Who       Purpose
    -------   --------  -------     --------------------------
   1.1      08/26/08    CWL       CR7691 ADDED X_RESTRICTED_USE TO SEPARATE COMPANIES IN TABLE_X_CARRIER_FEATURES
   1.2-3    08/27/09    NGuada    BRAND_SEP Separate the Brand and Source System
   1.2      08/16/2010  PM        CR13531 STCC SUREPAY Check same as IGATE.
   1.4      06/29/2011  kacosta   CR15990 - Additional Functions Needed for the SUI (ATT and  TMO)
                                  Checked in on behalf of Curt Linder
                                  Commented out the 'MIN is a ported number' exception check
   1.5      06/30/2011  kacosta   CR15990 - Additional Functions Needed for the SUI (ATT and TMO)
                                  Added call to SERVICE_PLAN.F_GET_ESN_RATE_PLAN to retreive
                                  ESN rate plan
   1.6      06/30/2011  kacosta   CR15990 - Additional Functions Needed for the SUI (ATT and TMO)
                                  Corrected the passing of value to the call SERVICE_PLAN.F_GET_ESN_RATE_PLAN to retreive
                                  ESN rate plan
   1.4      07/21/2011  Skuthadi  CR16308 SPRINT
   /**************************************************************************/---
   CURSOR task_curs (c_id IN VARCHAR2)
   IS
      SELECT *
        FROM table_task
       WHERE task_id = c_id;

   ---
   CURSOR task_by_ctobjid_curs (ct_objid IN NUMBER)
   IS
      SELECT task_id, x_current_method
        FROM table_task
       WHERE x_task2x_call_trans = ct_objid;

   ---
   CURSOR esn_curs (c_esn IN VARCHAR2)
   IS
      SELECT *
        FROM table_part_inst
       WHERE part_serial_no = c_esn;

   ---
   CURSOR get_min_curs (c_min IN VARCHAR2)
   IS
      /*********
      | Cingular Next Available project changes:
      | Get the carrier name from the table
      | instead of harcoding it in
      | toppapp.line_insert_pkg.INSERT_LINE_REC procedure call
      |
      | SELECT b.part_serial_no AS CurrESN,
      |        a.*
      | FROM   table_part_inst a,
      |        table_part_inst b
      | WHERE  a.part_serial_no        =  c_min
      | AND    a.part_to_esn2part_inst =  b.objid(+);
      |
      |*********/
      SELECT tprnt.x_parent_name, tesn.part_serial_no curresn, tmin.*
        FROM table_part_inst tesn,
             table_part_inst tmin,
             table_x_parent tprnt,
             table_x_carrier_group tcgrp,
             table_x_carrier tcarr
       WHERE tcarr.objid = tmin.part_inst2carrier_mkt
         AND tprnt.objid = tcgrp.x_carrier_group2x_parent
         AND tcgrp.objid = tcarr.carrier2carrier_group
         AND tesn.objid(+) = tmin.part_to_esn2part_inst
         AND tesn.x_domain(+) = 'PHONES'
         AND tmin.x_domain = 'LINES'
         AND tmin.part_serial_no = c_min;

   ---
   CURSOR carrier_curs (c_objid IN NUMBER)
   IS
      SELECT a.*, b.x_carrier_name
        FROM table_x_carrier a, table_x_carrier_group b
       WHERE a.objid = c_objid AND a.carrier2carrier_group = b.objid;

   ---
   CURSOR trans_profile_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_x_trans_profile
       WHERE objid = c_objid;

   ---
   CURSOR site_part_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_site_part
       WHERE objid = c_objid;

   ---
   CURSOR order_type_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_x_order_type
       WHERE objid = c_objid;

   ---
   CURSOR call_trans_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_x_call_trans
       WHERE objid = c_objid;

   ---
   CURSOR case_curs (c_case_id IN VARCHAR2)
   IS
      SELECT x_esn
        FROM table_case
       WHERE id_number = c_case_id;

   CURSOR hr_curs (c_objid IN NUMBER)
   IS
      SELECT wh.*
        FROM table_work_hr wh, table_wk_work_hr wwh
       WHERE wh.work_hr2wk_work_hr = wwh.objid AND wwh.objid = c_objid;

   --CR3016 Changes

   -- BRAND_SEP new table_bus_org
   CURSOR carrier_features_curs (
      c_objid        IN   NUMBER,
      p_tech         IN   VARCHAR2,
      p_brand_name   IN   VARCHAR2,
      p_data         IN   NUMBER                                 --CR4981_4982
   )
   IS
      SELECT cf.*, bo.org_id
        FROM table_x_carrier_features cf, table_bus_org bo
       WHERE x_feature2x_carrier = c_objid
         AND x_technology = p_tech
         AND x_features2bus_org = bo.objid
         AND org_id = p_brand_name
         AND x_data = p_data;                                    --CR4981_4982

--End CR3016 Changes
-------------------------------------------------------------------------------------
   PROCEDURE sp_ig_info (
      p_task_id   IN       VARCHAR2,
      p_esn       IN       VARCHAR2,
      p_case_id   IN       VARCHAR2,
      p_min       IN       VARCHAR2,
      p_message   OUT      VARCHAR2,
      rc          IN OUT   sa.igateindvpkg.igateinfocursor
   )
   IS
      --Cursor Variables
        -------
        -- * --
        -------
      task_rec                   task_curs%ROWTYPE;
      task_by_ctobjid_rec        task_by_ctobjid_curs%ROWTYPE;
      carrier_rec                carrier_curs%ROWTYPE;
      call_trans_rec             call_trans_curs%ROWTYPE;
      site_part_rec              site_part_curs%ROWTYPE;
      esn_rec                    esn_curs%ROWTYPE;
      get_min_rec                get_min_curs%ROWTYPE;
      case_rec                   case_curs%ROWTYPE;
      carr_features_rec          carrier_features_curs%ROWTYPE;
      --Local Variables
        -------
        -- * --
        -------
      l_call_waiting             NUMBER;
      l_cw_code                  VARCHAR2 (30);
      l_caller_id                NUMBER;
      l_id_code                  VARCHAR2 (30);
      l_digital_feature          VARCHAR2 (30);
      l_voicemail                NUMBER;
      l_vm_code                  VARCHAR2 (30);
      l_sms                      CHAR (1);
      l_sms_code                 VARCHAR2 (30);
 --     l_rate_plan                VARCHAR2 (30);
      l_rate_plan table_x_carrier_features.x_rate_plan%TYPE;
      l_call_trans_objid         NUMBER;
      l_old_esn                  VARCHAR2 (20);
      l_transmit_method          VARCHAR2 (100);
      l_rate_plan_obj            VARCHAR2 (30);
      l_esn                      VARCHAR2 (20);
      l_curr_method              VARCHAR2 (30);
      l_task_id                  VARCHAR2 (25);
      l_iccid                    VARCHAR2 (20);
      l_min                      VARCHAR2 (20);
      l_zipcode                  VARCHAR2 (20);
      l_pin                      VARCHAR2 (20);
      l_msid                     VARCHAR2 (20);
      l_min_status               VARCHAR2 (20);
      l_old_min                  VARCHAR2 (20);
      l_rate_center_no           VARCHAR2 (20);
      l_latest_order_type        VARCHAR2 (30);

      -------
      -- * --
      -------

      -- BRAND_SEP new table_bus_org
      CURSOR part_num_curs (c_objid IN NUMBER)
      IS
         SELECT pn.*, bo.org_id
           FROM table_part_num pn, table_mod_level ml, table_bus_org bo
          WHERE pn.objid = ml.part_info2part_num
            AND ml.objid = c_objid
            AND pn.part_num2bus_org = bo.objid;

      part_num_rec               part_num_curs%ROWTYPE;

      -------
      -- * --
      -------
      CURSOR old_esn_curs (c_min IN VARCHAR2)
      IS
         SELECT   x_service_id AS x_old_esn
             FROM table_site_part
            WHERE x_min = c_min AND part_status || '' = 'Inactive'
         ORDER BY service_end_dt DESC;

      old_esn_rec                old_esn_curs%ROWTYPE;

      -- Double rate plan
      -------
      -- * --
      -------
      CURSOR cingular_parent_curs (c_carrier_objid NUMBER)
      IS
         SELECT cg.*
           FROM TABLE_X_CARRIER c, TABLE_X_CARRIER_GROUP cg,
                TABLE_X_PARENT p
          WHERE 1 = 1
            AND c.objid = c_carrier_objid
            AND c.carrier2carrier_group = cg.objid
            AND UPPER (cg.x_status) = 'ACTIVE'
            AND cg.x_carrier_group2x_parent = p.objid
            AND p.x_parent_name = 'CINGULAR'
            AND UPPER (p.x_status) = 'ACTIVE';

      cingular_parent_curs_rec   cingular_parent_curs%ROWTYPE;

      -------
      -- * --
      -------
      CURSOR last_call_curs (c_esn VARCHAR2, current_call_tran_objid NUMBER)
      IS
         SELECT   *
             FROM table_x_call_trans
            WHERE 1 = 1
              AND EXISTS (
                     SELECT 1
                       FROM table_x_carrier c,
                            table_x_carrier_group cg,
                            table_x_parent p
                      WHERE 1 = 1
                        AND c.objid = x_call_trans2carrier
                        AND c.carrier2carrier_group = cg.objid
                        AND UPPER (cg.x_status) = 'ACTIVE'
                        AND cg.x_carrier_group2x_parent = p.objid
                        AND p.x_parent_name = 'CINGULAR'
                        AND UPPER (p.x_status) = 'ACTIVE')
              AND x_action_type IN ('1', '3')
              AND x_result = 'Completed'
              AND x_service_id = LTRIM (RTRIM (c_esn))
              AND objid <> current_call_tran_objid
         ORDER BY x_transact_date ASC;

      last_call_curs_rec         last_call_curs%ROWTYPE;

      -------
      -- * --
      -------
      CURSOR latest_call_curs (c_esn VARCHAR2)
      IS
         SELECT   MAX (objid) AS objid
             FROM table_x_call_trans
            WHERE 1 = 1
              AND x_action_type IN ('1', '3', '2', '10', '5', '9')
              AND x_result = 'Completed'
              AND x_service_id = LTRIM (RTRIM (c_esn))
         ORDER BY x_transact_date ASC;

      latest_call_rec            latest_call_curs%ROWTYPE;

      -------
      -- * --
      -------
      CURSOR c_esn_from_min
      IS
         SELECT phone.part_serial_no esn_no,
                phone.n_part_inst2part_mod esn_ml, phone.x_iccid esn_iccid,
                phone.x_part_inst2site_part esn_sp, line.*
           FROM table_part_inst phone, table_part_inst line
          WHERE line.part_to_esn2part_inst = phone.objid
            AND line.part_serial_no = p_min;

      r_esn_from_min             c_esn_from_min%ROWTYPE;

      -------
      -- * --
      -------
      CURSOR old_min_curs (ip_service_id IN VARCHAR2)
      IS
         SELECT   x_min
             FROM table_site_part
            WHERE x_service_id = ip_service_id
              AND part_status || '' = 'Inactive'
         ORDER BY service_end_dt DESC;

      old_min_rec                old_min_curs%ROWTYPE;

      -------
      -- * --
      -------
      CURSOR c_nap_rc (p_zipcode IN VARCHAR2)
      IS
         SELECT *
           FROM x_cingular_mrkt_info
          WHERE zip = p_zipcode AND ROWNUM < 2;

      c_nap_rc_rec               c_nap_rc%ROWTYPE;

      FUNCTION get_latest_order_type
         RETURN table_x_order_type.x_order_type%TYPE
      IS
         n_max_objid    table_x_call_trans.objid%TYPE;
         return_value   table_x_order_type.x_order_type%TYPE;

         -- Get max objid from the call trans table
         CURSOR call_trans_max_cur
         IS
            SELECT   MAX (objid) AS objid
                FROM table_x_call_trans
               WHERE 1 = 1
                 AND x_action_type IN ('1', '3', '2', '10', '5', '9')
                 AND x_result = 'Completed'
                 AND x_service_id = p_esn
            ORDER BY x_transact_date ASC;

         -- Get order type
         CURSOR order_type_cur
         IS
            SELECT c.x_order_type
              FROM table_task a, table_x_call_trans b, table_x_order_type c
             WHERE a.x_task2x_call_trans = b.objid
               AND b.x_service_id = p_esn
               AND b.objid = n_max_objid
               AND a.x_task2x_order_type = c.objid;
      BEGIN
         OPEN call_trans_max_cur;

         FETCH call_trans_max_cur
          INTO n_max_objid;

         IF call_trans_max_cur%FOUND
         THEN
            OPEN order_type_cur;

            FETCH order_type_cur
             INTO return_value;

            CLOSE order_type_cur;
         END IF;

         CLOSE call_trans_max_cur;

         RETURN return_value;
      END get_latest_order_type;
   BEGIN
      p_message := 'Successful';
      l_call_waiting := NULL;
      l_cw_code := NULL;
      l_caller_id := NULL;
      l_id_code := NULL;
      l_digital_feature := NULL;
      l_voicemail := NULL;
      l_vm_code := NULL;
      l_sms := NULL;
      l_sms_code := NULL;
      l_rate_center_no := NULL;
      l_latest_order_type := NULL;

      IF p_case_id IS NOT NULL
      THEN
         -------
         -- * --
         -------
         OPEN case_curs (p_case_id);

         FETCH case_curs
          INTO case_rec;

         IF case_curs%NOTFOUND
         THEN
            p_message := 'Case record not found';

            CLOSE case_curs;

            RETURN;
         END IF;

         l_esn := case_rec.x_esn;

         CLOSE case_curs;
      ELSIF p_task_id IS NOT NULL
      THEN
           -------
         -- * --
         -------
         OPEN task_curs (p_task_id);

         FETCH task_curs
          INTO task_rec;

         IF task_curs%NOTFOUND
         THEN
            p_message := 'Action Item not found';

            CLOSE task_curs;

            RETURN;
         END IF;

         l_task_id := p_task_id;
         l_curr_method := task_rec.x_current_method;
         l_call_trans_objid := task_rec.x_task2x_call_trans;

         CLOSE task_curs;
      END IF;

      IF p_esn IS NOT NULL
      THEN
         l_esn := p_esn;
      END IF;

      IF l_esn IS NOT NULL
      THEN
         -------
         -- * --
         -------
         OPEN latest_call_curs (l_esn);

         FETCH latest_call_curs
          INTO latest_call_rec;

         IF latest_call_curs%NOTFOUND
         THEN
            p_message := 'No Previous Transaction found';

            CLOSE latest_call_curs;

            RETURN;
         END IF;

         l_call_trans_objid := latest_call_rec.objid;

         CLOSE latest_call_curs;

         -------
         -- * --
         -------
         OPEN call_trans_curs (l_call_trans_objid);

         FETCH call_trans_curs
          INTO call_trans_rec;

         IF call_trans_curs%NOTFOUND
         THEN
            p_message := 'No Previous Transaction found';

            CLOSE call_trans_curs;

            RETURN;
         END IF;

         l_esn := call_trans_rec.x_service_id;

         CLOSE call_trans_curs;

         -------
         -- * --
         -------
         OPEN esn_curs (l_esn);

         FETCH esn_curs
          INTO esn_rec;

         IF esn_curs%NOTFOUND
         THEN
            p_message := 'ESN record not found';

            CLOSE esn_curs;

            RETURN;
         END IF;

         CLOSE esn_curs;

         l_iccid := esn_rec.x_iccid;

         -------
         -- * --
         -------
         OPEN site_part_curs (esn_rec.x_part_inst2site_part);

         FETCH site_part_curs
          INTO site_part_rec;

         IF site_part_curs%NOTFOUND
         THEN
            p_message := 'Service Transaction not found';

            CLOSE site_part_curs;

            RETURN;
         END IF;

         l_min := site_part_rec.x_min;
         l_zipcode := site_part_rec.x_zipcode;
         l_pin := site_part_rec.x_pin;

         CLOSE site_part_curs;

         -------
         -- * --
         -------
         OPEN get_min_curs (l_min);

         FETCH get_min_curs
          INTO get_min_rec;

         IF get_min_curs%NOTFOUND
         THEN
            p_message := 'MIN record not found';

            CLOSE get_min_curs;

            RETURN;
         END IF;

         CLOSE get_min_curs;

         IF (    get_min_rec.x_part_inst_status = '13'
             AND get_min_rec.curresn <> l_esn
            )
         THEN
            p_message :=
                  'Associated MIN '
               || l_min
               || ' is active with a different ESN '
               || get_min_rec.curresn;
            RETURN;
         END IF;

--CR 15990
--         IF get_min_rec.x_port_in = 1
--         THEN
--            p_message := 'MIN is a ported number';
--            RETURN;
--         END IF;
--CR 15990

         l_msid := get_min_rec.x_msid;
         l_min_status := get_min_rec.x_part_inst_status;

         -------
         -- * --
         -------
         OPEN carrier_curs (get_min_rec.part_inst2carrier_mkt);

         FETCH carrier_curs
          INTO carrier_rec;

         IF carrier_curs%NOTFOUND
         THEN
            p_message := 'Carrier record not found';

            CLOSE carrier_curs;

            RETURN;
         END IF;

         CLOSE carrier_curs;

         -------
         -- * --
         -------
         OPEN part_num_curs (site_part_rec.site_part2part_info);

         FETCH part_num_curs
          INTO part_num_rec;

         IF part_num_curs%NOTFOUND
         THEN
            p_message := 'ESN Part Number not found';

            CLOSE part_num_curs;

            RETURN;
         END IF;

         CLOSE part_num_curs;
      END IF;                                                      --ESN Check

      IF p_min IS NOT NULL
      THEN
         -------
         -- * --
         -------
         l_min := p_min;

         OPEN c_esn_from_min;

         FETCH c_esn_from_min
          INTO r_esn_from_min;

         IF c_esn_from_min%NOTFOUND
         THEN
            p_message := 'ESN from MIN not found';

            CLOSE c_esn_from_min;

            RETURN;
         END IF;

         CLOSE c_esn_from_min;

         -- Added port_in check
--CR 15990
--         IF r_esn_from_min.x_port_in = 1
--         THEN
--            p_message := 'MIN is a ported number';
--            RETURN;
--         END IF;
--CR 15990

         l_esn := r_esn_from_min.esn_no;
         l_msid := r_esn_from_min.x_msid;
         l_min_status := r_esn_from_min.x_part_inst_status;
         l_iccid := r_esn_from_min.esn_iccid;

         -------
         -- * --
         -------
         OPEN carrier_curs (r_esn_from_min.part_inst2carrier_mkt);

         FETCH carrier_curs
          INTO carrier_rec;

         IF carrier_curs%NOTFOUND
         THEN
            p_message := 'Carrier record from MIN not found';

            CLOSE carrier_curs;

            RETURN;
         END IF;

         CLOSE carrier_curs;

         -------
         -- * --
         -------
         OPEN part_num_curs (r_esn_from_min.esn_ml);

         FETCH part_num_curs
          INTO part_num_rec;

         IF part_num_curs%NOTFOUND
         THEN
            p_message := 'ESN Part Number from MIN not found';

            CLOSE part_num_curs;

            RETURN;
         END IF;

         CLOSE part_num_curs;

         -------
         -- * --
         -------
         OPEN site_part_curs (r_esn_from_min.esn_sp);

         FETCH site_part_curs
          INTO site_part_rec;

         IF site_part_curs%NOTFOUND
         THEN
            p_message := 'Service Transaction from MIN not found';

            CLOSE site_part_curs;

            RETURN;
         END IF;

         l_zipcode := site_part_rec.x_zipcode;
         l_pin := site_part_rec.x_pin;

         CLOSE site_part_curs;
      END IF;                                                      --MIN Check

      -------
      -- * --
      -------
      OPEN old_esn_curs (l_esn);

      FETCH old_esn_curs
       INTO old_esn_rec;

      IF old_esn_curs%NOTFOUND
      THEN
         old_esn_rec.x_old_esn := NULL;
      END IF;

      CLOSE old_esn_curs;

      -------
      -- * --
      -------
      OPEN old_min_curs (call_trans_rec.x_service_id);

      FETCH old_min_curs
       INTO old_min_rec;

      IF old_min_curs%FOUND
      THEN
         l_old_min := old_min_rec.x_min;
      ELSE
         l_old_min := NULL;
      END IF;

      CLOSE old_min_curs;

      -------
      -- * --
      -------
     --CR4981_4982 Start
--      OPEN carrier_features_curs (carrier_rec.objid, part_num_rec.x_technology);
--cwl cr7691
      OPEN carrier_features_curs (carrier_rec.objid,
                                  part_num_rec.x_technology,
                                  part_num_rec.org_id,
                                  NVL (part_num_rec.x_data_capable, 0)
                                 --CR4589-1
                                 );

      --CR4981_4982 End
      FETCH carrier_features_curs
       INTO carr_features_rec;

      IF carrier_features_curs%NOTFOUND
      THEN
         l_call_waiting := NULL;
         l_cw_code := NULL;
         l_caller_id := NULL;
         l_id_code := NULL;
         l_digital_feature := NULL;
         l_voicemail := NULL;
         l_vm_code := NULL;
         l_sms := NULL;
         l_sms_code := NULL;
         l_rate_plan := NULL;
      ELSE
         l_call_waiting := carr_features_rec.x_call_waiting;
         l_cw_code := carr_features_rec.x_cw_code;
         l_caller_id := carr_features_rec.x_caller_id;
         l_id_code := carr_features_rec.x_id_code;
         l_digital_feature := carr_features_rec.x_digital_feature;
         l_voicemail := carr_features_rec.x_voicemail;
         l_vm_code := carr_features_rec.x_vm_code;
         l_sms := carr_features_rec.x_sms;
         l_sms_code := carr_features_rec.x_sms_code;
         -- CR15990 Start KACOSTA 06/29/2011
         --l_rate_plan := carr_features_rec.x_rate_plan;
         l_rate_plan := service_plan.f_get_esn_rate_plan(p_esn => l_esn);
         -- CR15990 End KACOSTA 06/29/2011

      END IF;

      CLOSE carrier_features_curs;

      -------
      -- * --
      -------
      OPEN c_nap_rc (l_zipcode);

      FETCH c_nap_rc
       INTO c_nap_rc_rec;

      IF c_nap_rc%FOUND
      THEN
         l_rate_center_no := c_nap_rc_rec.rc_number;
      ELSE
         l_rate_center_no := NULL;
      END IF;

      CLOSE c_nap_rc;

      -------
      -- * --
      -------
      l_latest_order_type := get_latest_order_type;

---------------------
-- * OUTPUT DATA * --
---------------------
      OPEN rc FOR
         SELECT DECODE (l_call_waiting, 1, 'Y', 'N') "call waiting",
                l_cw_code "call waiting package",
                DECODE (l_caller_id, 1, 'Y', 'N') "caller id",
                l_id_code "caller id package",
                carrier_rec.objid "carrier objid",
                carrier_rec.x_carrier_id "carrier id",
                carrier_rec.x_mkt_submkt_name "carrier market name",
                carrier_rec.x_carrier_name "carrier name",
                l_digital_feature "digital feature code", l_esn "esn",

-- CR6254 Starts Meid changes,  getting the hex value using the f_get_hex_esn function
--          sa.igate.get_hex (l_esn) "hex esn",
                sa.igate.f_get_hex_esn (l_esn) "hex esn",

-- CR6254 Ends
                carrier_rec.x_ld_pic_code "ld provider", l_min "min",
                l_msid "msid", SUBSTR (old_esn_rec.x_old_esn, 1,
                                       11) "old esn",

-- CR6254 Starts Meid changes,  getting the hex value using the f_get_hex_esn function
--          sa.igate.get_hex (old_esn_rec.x_old_esn) "hex old esn",
                sa.igate.f_get_hex_esn (old_esn_rec.x_old_esn) "hex old esn",

-- CR6254 Ends
                l_pin "pin", l_rate_plan "rate plan",
                carrier_rec.x_state "state",
                SUBSTR (part_num_rec.x_technology, 1, 1) "technology flag",
                part_num_rec.x_technology "esn technology",
                DECODE (l_voicemail, 1, 'Y', 'N') "voicemail",
                l_vm_code "voicemail package", l_zipcode "zipcode",
                DECODE (l_min_status,
                        '13', 'ACTIVE',
                        '34', 'ACTIVE',
                        '110', 'ACTIVE',
                        'INACTIVE'
                       ) "line status",
                DECODE (l_sms, 1, 'Y', 0, 'N') "sms",
                l_sms_code "sms package",
                                         -- CR3417: Commented Out: esn_rec.x_iccid "gsm info",
                                         l_iccid "gsm info",
                part_num_rec.x_manufacturer "phone manf", l_old_min "old min",
                l_rate_center_no "rate_center_no",                    --CR3918
                l_latest_order_type "last_order_type"
           FROM DUAL;
   END sp_ig_info;

-------------------------------------------------------------------------------------
   PROCEDURE sp_ordertype_info (
      p_min             IN       VARCHAR2,
      p_order_type      IN       VARCHAR2,
      p_carrier_objid   IN       NUMBER,
      --      p_curr_method     IN       VARCHAR2, CR2739C
      p_technology      IN       VARCHAR2,
      p_message         OUT      VARCHAR2,
      rc                IN OUT   sa.igateindvpkg.igateordercursor
   )
   IS
      l_order_type_objid    NUMBER;
      order_type_rec        order_type_curs%ROWTYPE;
      trans_profile_rec     trans_profile_curs%ROWTYPE;
      l_order_type_1        VARCHAR2 (20);
      l_account_num         VARCHAR2 (30);
      l_market_code         VARCHAR2 (30);
      l_dealer_code         VARCHAR2 (30);
      l_network_login       VARCHAR2 (30);
      l_network_password    VARCHAR2 (30);
      l_transmit_method     VARCHAR2 (30);
      l_transmit_template   VARCHAR2 (80);
      --CR2739A Changes
      l_sui                 NUMBER;
      l_timeout             NUMBER;
      l_debug               NUMBER;

-----------------------
--  CR13531 STCC Start
-----------------------
-- CR16308 SPRINT STARTS -- tempalte calculation will be table driven
/*
         cursor surepay_curs is
           select 1 cnt
             from --table_x_part_class_values v,
                  --table_x_part_class_params n,
                  table_part_num  pn,
                  TABLE_MOD_LEVEL ML,
                  TABLE_PART_INST TESN,
                  TABLE_PART_INST Tmin,
                  table_bus_org   bo
            where 1=1
              and pn.part_num2bus_org    = bo.objid
              and bo.org_id              = 'STRAIGHT_TALK'        -- CR11971 ST_GSM to use Bus org
              --and v.value2part_class     = pn.part_num2part_class
              --and v.value2class_param    = n.objid
              --and n.x_param_name         = 'NON_PPE'
              --and v.X_PARAM_VALUE        = '1'
              and pn.x_technology        = 'CDMA'
              and PN.OBJID               = ML.PART_INFO2PART_NUM
              and ML.OBJID               = tesn.N_PART_INST2PART_MOD
              and TESN.OBJID(+)          = TMIN.PART_TO_ESN2PART_INST
              and TESN.X_DOMAIN          = 'PHONES'
              and TMIN.X_DOMAIN          = 'LINES'
              AND tmin.part_serial_no    = p_min;
         surepay_rec surepay_curs%rowtype;

-----------------------
--  CR13531 STCC End
-----------------------
-- CR16308 SPRINT ENDS
*/
--End CR2739A Changes
   BEGIN
      p_message := 'Successful';
      -- CR4579: Added technology
      sa.igate.sp_get_ordertype (p_min,
                                 p_order_type,
                                 p_carrier_objid,
                                 p_technology,
                                 l_order_type_objid
                                );

      OPEN order_type_curs (l_order_type_objid);

      FETCH order_type_curs
       INTO order_type_rec;

      IF order_type_curs%NOTFOUND
      THEN
         p_message := 'Order Type not found';

         CLOSE order_type_curs;

         RETURN;
      END IF;

      l_order_type_1 := SUBSTR (order_type_rec.x_order_type, 1, 1);
      l_account_num := order_type_rec.x_ld_account_num;
      l_market_code := order_type_rec.x_market_code;
      l_dealer_code := order_type_rec.x_dealer_code;

      CLOSE order_type_curs;

      --
      OPEN trans_profile_curs (order_type_rec.x_order_type2x_trans_profile);

      FETCH trans_profile_curs
       INTO trans_profile_rec;

      IF trans_profile_curs%NOTFOUND
      THEN
         p_message := 'Trans Profile not found';

         CLOSE trans_profile_curs;

         RETURN;
      END IF;

      l_network_login := trans_profile_rec.x_network_login;
      L_NETWORK_PASSWORD := TRANS_PROFILE_REC.X_NETWORK_PASSWORD;
      L_TRANSMIT_TEMPLATE := TRANS_PROFILE_REC.X_TRANSMIT_TEMPLATE;

-- CR16308 SPRINT STARTS -- tempalte calculation will be table driven
-- L_TRANSMIT_TEMPLATE will be SPRINT and SUREPAY based on carrier from above no need for below cursor
/*
-----------------------
--  CR13531 STCC Start
-----------------------
      open surepay_curs;
        fetch surepay_curs into surepay_rec;
        if surepay_curs%found then
          L_TRANSMIT_TEMPLATE := 'SUREPAY';
            end if;
      close SUREPAY_CURS;
-----------------------
--  CR13531 STCC Start
-----------------------
*/
-- CR16308 SPRINT ENDS -- tempalte calculation will be table driven

      l_transmit_method := trans_profile_rec.x_transmit_method;

      --CR2739A Changes
      IF p_technology = 'ANALOG'
      THEN
         l_sui := trans_profile_rec.x_sui_analog;
         l_timeout := trans_profile_rec.x_timeout_analog;
         l_debug := trans_profile_rec.x_debug_analog;
      ELSIF p_technology IN ('TDMA', 'CDMA')
      THEN
         l_sui := trans_profile_rec.x_sui_digital;
         l_timeout := trans_profile_rec.x_timeout_digital;
         l_debug := trans_profile_rec.x_debug_digital;
      ELSIF p_technology = 'GSM'
      THEN
         l_sui := trans_profile_rec.x_sui_gsm;
         l_timeout := trans_profile_rec.x_timeout_gsm;
         l_debug := trans_profile_rec.x_debug_gsm;
      END IF;

      --End CR2739A Changes
      CLOSE trans_profile_curs;

      --CR2739C changes
      --       IF p_curr_method IS NOT NULL
      --       THEN
      --          IF     p_curr_method != trans_profile_rec.x_d_transmit_method
      --             AND p_technology IN ('CDMA',  'TDMA')
      --          THEN
      --             l_transmit_method := p_curr_method;
      --          ELSIF     p_curr_method != trans_profile_rec.x_transmit_method
      --                AND p_technology NOT IN ('CDMA',  'TDMA')
      --          THEN
      --             l_transmit_method := p_curr_method;
      --          ELSIF p_technology IN ('CDMA',  'TDMA')
      --          THEN
      --             l_transmit_method := trans_profile_rec.x_d_transmit_method;
      --          ELSE
      --             l_transmit_method := trans_profile_rec.x_transmit_method;
      --          END IF;
      --       ELSE
      --          IF p_technology IN ('CDMA',  'TDMA')
      --          THEN
      --             l_transmit_method := trans_profile_rec.x_d_transmit_method;
      --          ELSE
      --             l_transmit_method := trans_profile_rec.x_transmit_method;
      --          END IF;
      --       END IF;
      --End CR2739C changes
      OPEN rc FOR
         SELECT l_order_type_1 "order type", l_account_num "account number",
                l_market_code "market code", l_dealer_code "dealer code",
                l_network_login "network login",
                l_network_password "network password",
                l_transmit_method "transmission method",
                l_transmit_template "template", l_sui "sui",
                l_timeout "timeout", l_debug "debug"
           FROM DUAL;
   END sp_ordertype_info;

-------------------------------------------------------------------------------------
   FUNCTION sp_check_blackout (
      --      p_task_id IN VARCHAR2,
      p_min             IN   VARCHAR2,
      p_order_type      IN   VARCHAR2,
      p_carrier_objid   IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_seconds_from_sunday   NUMBER
         :=   (  SYSDATE
               - TRUNC (SYSDATE - TO_NUMBER (TO_CHAR (SYSDATE, 'd')) + 1)
              )
            * 24
            * 60
            * 60;
      l_work_wk_objid         NUMBER;
      l_order_type_objid      NUMBER;
      task_rec                task_curs%ROWTYPE;
      call_trans_rec          call_trans_curs%ROWTYPE;
      carrier_rec             carrier_curs%ROWTYPE;
      site_part_rec           site_part_curs%ROWTYPE;
      order_type_rec          order_type_curs%ROWTYPE;
      trans_profile_rec       trans_profile_curs%ROWTYPE;

      --CR2739F Changes
      CURSOR c_max_sp
      IS
         SELECT MAX (objid) sp_objid
           FROM TABLE_SITE_PART
          WHERE x_min = p_min AND part_status || '' IN ('Active', 'Inactive', 'CarrierPending');  -- CR13531 STCC PM

      r_max_sp                c_max_sp%ROWTYPE;
--End CR2739F Changes
   BEGIN
--CR2739F Changes
      --       OPEN task_curs (p_task_id);
      --       FETCH task_curs
      --       INTO task_rec;
      --       IF task_curs%notfound
      --       THEN
      --          CLOSE task_curs;
      --          RETURN 2;
      --       END IF;
      --       CLOSE task_curs;
      --End CR2739F Changes

      --
      --CR2739F Changes
      OPEN c_max_sp;

      FETCH c_max_sp
       INTO r_max_sp;

      IF c_max_sp%NOTFOUND
      THEN
         CLOSE c_max_sp;

         RETURN 10;
      END IF;

      CLOSE c_max_sp;

      --      OPEN site_part_curs (call_trans_rec.call_trans2site_part);
      --End CR2739F Changes
      OPEN site_part_curs (r_max_sp.sp_objid);

      FETCH site_part_curs
       INTO site_part_rec;

      IF site_part_curs%NOTFOUND
      THEN
         --CR3417 Added this for T-Mobile since
         --these lines have no site_part record
         IF SUBSTR (p_min, 1, 1) = 'T'
         THEN
            site_part_rec.state_value := 'GSM';
         ELSE
            CLOSE site_part_curs;

            RETURN 9;
         END IF;
      END IF;

      CLOSE site_part_curs;

      IF LTRIM (site_part_rec.state_value) IS NULL
      THEN
         site_part_rec.state_value := 'ANALOG';
      END IF;

      sa.igate.sp_get_ordertype (p_min,
                                 p_order_type,
                                 p_carrier_objid,
                                 site_part_rec.state_value,
                                 l_order_type_objid
                                );

      OPEN order_type_curs (l_order_type_objid);

      FETCH order_type_curs
       INTO order_type_rec;

      IF order_type_curs%NOTFOUND
      THEN
         CLOSE order_type_curs;

         RETURN 5;
      END IF;

      CLOSE order_type_curs;

      --CR2739F Changes
      --       OPEN call_trans_curs (task_rec.x_task2x_call_trans);
      --       FETCH call_trans_curs
      --       INTO call_trans_rec;
      --       IF call_trans_curs%notfound
      --       THEN
      --          CLOSE call_trans_curs;
      --          RETURN 3;
      --       END IF;
      --       CLOSE call_trans_curs;
      --End CR2739F Changes
      OPEN carrier_curs (order_type_rec.x_order_type2x_carrier);

      FETCH carrier_curs
       INTO carrier_rec;

      IF carrier_curs%NOTFOUND
      THEN
         CLOSE carrier_curs;

         RETURN 4;
      END IF;

      CLOSE carrier_curs;

      --
      OPEN trans_profile_curs (order_type_rec.x_order_type2x_trans_profile);

      FETCH trans_profile_curs
       INTO trans_profile_rec;

      IF trans_profile_curs%NOTFOUND
      THEN
         CLOSE trans_profile_curs;

         RETURN 6;
      END IF;

      CLOSE trans_profile_curs;

      --
      IF site_part_rec.state_value = 'ANALOG'
      THEN
         l_work_wk_objid := trans_profile_rec.x_trans_profile2wk_work_hr;
      ELSE
         l_work_wk_objid := trans_profile_rec.d_trans_profile2wk_work_hr;
      END IF;

      FOR hr_rec IN hr_curs (l_work_wk_objid)
      LOOP
         IF l_seconds_from_sunday BETWEEN hr_rec.start_time AND hr_rec.end_time
         THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
--
   END sp_check_blackout;

-------------------------------------------------------------------------------------
   FUNCTION sp_ret_order_type (p_min IN VARCHAR2, p_carrier_objid IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR o_type_curs (
         c_npa             IN   VARCHAR2,
         c_nxx             IN   VARCHAR2,
         c_carrier_objid   IN   NUMBER
      )
      IS
         SELECT          /*+ index ( ot IND_ORDER_TYPE3 ) */
                DISTINCT x_order_type otype
                    FROM table_x_order_type ot, table_x_carrier c
                   WHERE ot.x_order_type2x_carrier = c.objid
                     AND NVL (ot.x_npa, -1) = c_npa
                     AND NVL (ot.x_nxx, -1) = c_nxx
                     AND c.objid = c_carrier_objid;

      CURSOR o_null_type_curs (c_carrier_objid IN NUMBER)
      IS
         SELECT          /*+ index ( ot IND_ORDER_TYPE3 ) */
                DISTINCT x_order_type otype
                    FROM table_x_order_type ot, table_x_carrier c
                   WHERE ot.x_order_type2x_carrier = c.objid
                     AND NVL (ot.x_npa, -1) = -1
                     AND NVL (ot.x_nxx, -1) = -1
                     AND c.objid = c_carrier_objid;

      l_order_type       VARCHAR2 (500);
      -- CR3690 change variable size 100 to 500
      l_cnt              NUMBER         := 0;
      l_first_loop_cnt   NUMBER         := 0;
   BEGIN
      l_cnt := 0;
      l_first_loop_cnt := 0;

      FOR o_type_rec IN o_type_curs (SUBSTR (p_min, 1, 3),
                                     SUBSTR (p_min, 4, 3),
                                     p_carrier_objid
                                    )
      LOOP
         IF l_cnt = 0
         THEN
            l_order_type := o_type_rec.otype;
         ELSE
            l_order_type := l_order_type || ',' || o_type_rec.otype;
         END IF;

         l_cnt := l_cnt + 1;
         l_first_loop_cnt := l_first_loop_cnt + 1;
      END LOOP;

      l_cnt := 0;

      IF l_first_loop_cnt = 0
      THEN
         FOR o_null_type_rec IN o_null_type_curs (p_carrier_objid)
         LOOP
            IF l_cnt = 0
            THEN
               l_order_type := o_null_type_rec.otype;
            ELSE
               l_order_type := l_order_type || ',' || o_null_type_rec.otype;
            END IF;

            l_cnt := l_cnt + 1;
         END LOOP;
      END IF;

      RETURN l_order_type;
   END sp_ret_order_type;

-------------------------------------------------------------------------------------
   PROCEDURE sp_flag_new_msid (
      p_min       IN       VARCHAR2,
      p_task_id   IN       VARCHAR2,
      p_msid      IN       VARCHAR2,
      p_message   OUT      VARCHAR2
   )
   IS
      CURSOR c_sp_objid (v_min VARCHAR2)
      IS
         SELECT sp.objid sp_objid, sp.x_service_id sp_esn            --CR4530
           FROM table_site_part sp,
                table_part_inst piesn,
                table_part_inst pimin
          WHERE sp.objid = piesn.x_part_inst2site_part
            AND piesn.objid = pimin.part_to_esn2part_inst
            AND pimin.part_serial_no = v_min;

      r_sp_objid           c_sp_objid%ROWTYPE;
      l_call_trans_objid   NUMBER;
      l_site_part_objid    NUMBER;
      get_min_rec          get_min_curs%ROWTYPE;
      get_msid_rec         get_min_curs%ROWTYPE;
      task_rec             task_curs%ROWTYPE;
      call_trans_rec       call_trans_curs%ROWTYPE;
      l_program_name       VARCHAR2 (100)     := 'IGATE_INDV.SP_FLAG_NEW_MSID';
      blnresult            BOOLEAN;
      l_ins_pihist_flag    BOOLEAN;
      v_min                VARCHAR2 (30);
      --CR4530 Starts
      l_continue           VARCHAR2 (20)             := 'T';
      l_site_part_esn      VARCHAR2 (30);
--CR4530 Ends
   BEGIN
      v_min := p_min;
      p_message := 'Successful';
      l_continue := 'T';                                             --CR4530

      OPEN get_min_curs (p_min);

      FETCH get_min_curs
       INTO get_min_rec;

      IF get_min_curs%NOTFOUND
      THEN
         p_message := 'New MSID: MIN record not found';

         CLOSE get_min_curs;

         RETURN;
      END IF;

      CLOSE get_min_curs;

      --CR3647 - For T-Mobile, if min is a dummy number and then insert a line with msid value
      IF SUBSTR (p_min, 1, 1) = 'T' OR p_task_id = 'LUTS'             --CR5395
      THEN
         --Check if the MSID line exists, if so flag that for MSID update
         OPEN get_min_curs (p_msid);

         FETCH get_min_curs
          INTO get_msid_rec;

         IF get_min_curs%NOTFOUND
         THEN
            -- Insert a new line
            blnresult :=
               toppapp.line_insert_pkg.insert_line_rec
                                          (p_msid,
                                           p_msid,
                                           SUBSTR (p_msid, 1, 3),
                                           SUBSTR (p_msid, 4, 3),
                                           SUBSTR (p_msid, 7),
                                              get_min_rec.x_parent_name
                                           || '_'
                                           || SYSDATE,
                                           get_min_rec.warr_end_date,
                                           get_min_rec.x_cool_end_date,
                                           get_min_rec.x_part_inst_status,
                                           get_min_rec.n_part_inst2part_mod,
                                           get_min_rec.part_inst2x_pers,
                                           get_min_rec.part_inst2carrier_mkt,
                                           get_min_rec.status2x_code_table,
                                           get_min_rec.created_by2user
                                          );

            UPDATE table_part_inst
               SET part_to_esn2part_inst = get_min_rec.part_to_esn2part_inst
             WHERE part_serial_no = p_msid;

            -- Insert records into pi_hist
            l_ins_pihist_flag :=
               toss_util_pkg.insert_pi_hist_fun (p_msid,
                                                 'LINES',
                                                 'LINE_BATCH',
                                                 l_program_name
                                                );
            l_ins_pihist_flag :=
               toss_util_pkg.insert_pi_hist_fun (p_msid,
                                                 'LINES',
                                                 'ACTIVATE',
                                                 l_program_name
                                                );
            l_continue := 'T';
--CR4530
         ELSE
            UPDATE table_part_inst
               SET part_to_esn2part_inst = get_min_rec.part_to_esn2part_inst
             WHERE part_serial_no = p_msid
                   AND x_part_inst_status || '' <> '13';              --CR4530

            --CR4530 Starts
            IF SQL%ROWCOUNT > 0
            THEN
               l_continue := 'T';
--CR4530
            ELSE
               l_continue := 'F';
            END IF;
--CR4530 Ends
         END IF;

         CLOSE get_min_curs;

         OPEN get_min_curs (p_msid);

         FETCH get_min_curs
          INTO get_min_rec;

         CLOSE get_min_curs;

         IF l_continue = 'T'
         THEN
--CR4530
            DELETE FROM table_part_inst
                  WHERE part_serial_no = p_min;

            DELETE FROM table_x_pi_hist
                  WHERE x_part_serial_no = p_min;

            --Update Site_part and Call Trans with Line
            UPDATE table_site_part
               SET x_min = p_msid
             WHERE x_min = p_min;

            v_min := p_msid;
         END IF;                                                      --CR4530

         COMMIT;
      END IF;

      --CR3647 - Ends
      --CR3224 Start
      --       OPEN task_curs (p_task_id);
      --       FETCH task_curs
      --       INTO task_rec;
      --       IF task_curs%notfound
      --       THEN
      --          p_message := 'New MSID: Action Item not found';
      --          CLOSE task_curs;
      --          RETURN;
      --       END IF;
      --       l_call_trans_objid := task_rec.x_task2x_call_trans;
      --       CLOSE task_curs;
      --       OPEN call_trans_curs (l_call_trans_objid);
      --       FETCH call_trans_curs
      --       INTO call_trans_rec;
      --       IF call_trans_curs%notfound
      --       THEN
      --          p_message := 'New MSID: Call Transaction not found';
      --          CLOSE call_trans_curs;
      --          RETURN;
      --       END IF;
      --       l_site_part_objid := call_trans_rec.call_trans2site_part;
      --       CLOSE call_trans_curs;
      IF l_continue = 'T'
      THEN
--CR4530
         OPEN c_sp_objid (v_min);

         FETCH c_sp_objid
          INTO r_sp_objid;

         IF c_sp_objid%NOTFOUND
         THEN
            p_message :=
                     'New MSID: Site Part Record not found for the given MIN';

            CLOSE c_sp_objid;

            RETURN;
         END IF;

         l_site_part_objid := r_sp_objid.sp_objid;
         l_site_part_esn := r_sp_objid.sp_esn;                        --CR4530

         CLOSE c_sp_objid;

         --CR3224 End
         --CR3647 - Starts
         UPDATE table_x_call_trans
            SET x_min = p_msid
          WHERE call_trans2site_part = l_site_part_objid;

         --CR3647 - Ends
         UPDATE table_part_inst
            SET x_part_inst_status = '110',
                status2x_code_table = 268438300,
                x_msid = p_msid
          WHERE part_serial_no = get_min_rec.part_serial_no;

         --CR4530 Starts
         UPDATE table_part_inst
            SET part_inst2x_pers = get_min_rec.part_inst2x_pers
          WHERE part_serial_no = l_site_part_esn;

         --CR4530 Ends
         IF SQL%ROWCOUNT = 1
         THEN
            UPDATE table_site_part
               SET x_msid = p_msid
             WHERE objid = l_site_part_objid;

            IF SQL%ROWCOUNT = 1
            THEN
               INSERT INTO table_x_pi_hist
                           (objid,
                            status_hist2x_code_table, x_change_date,
                            x_change_reason, x_cool_end_date,
                            x_creation_date,
                            x_deactivation_flag,
                            x_domain, x_ext,
                            x_insert_date, x_npa,
                            x_nxx,
                            x_old_ext,
                            x_old_npa,
                            x_old_nxx,
                            x_part_bin, x_part_inst_status,
                            x_part_mod,
                            x_part_serial_no,
                            x_part_status,
                            x_pi_hist2carrier_mkt,
                            x_pi_hist2inv_bin,
                            x_pi_hist2part_inst,
                            x_pi_hist2part_mod,
                            x_pi_hist2user,
                            x_pi_hist2x_new_pers,
                            x_pi_hist2x_pers,
                            x_po_num,
                            x_reactivation_flag,
                            x_red_code, x_sequence,
                            x_warr_end_date, dev,
                            fulfill_hist2demand_dtl,
                            part_to_esn_hist2part_inst,
                            x_bad_res_qty,
                            x_date_in_serv,
                            x_good_res_qty,
                            x_last_cycle_ct,
                            x_last_mod_time,
                            x_last_pi_date,
                            x_last_trans_time,
                            x_next_cycle_ct,
                            x_order_number,
                            x_part_bad_qty,
                            x_part_good_qty,
                            x_pi_tag_no, x_pick_request,
                            x_repair_date,
                            x_transaction_id, x_msid
                           )
                    VALUES (seq ('x_pi_hist'),
                            get_min_rec.status2x_code_table, SYSDATE,
                            'MSID UPDATE', get_min_rec.x_cool_end_date,
                            get_min_rec.x_creation_date,
                            get_min_rec.x_deactivation_flag,
                            get_min_rec.x_domain, get_min_rec.x_ext,
                            get_min_rec.x_insert_date, get_min_rec.x_npa,
                            get_min_rec.x_nxx,
                            SUBSTR (get_min_rec.part_serial_no, 7, 4),
                            SUBSTR (get_min_rec.part_serial_no, 1, 3),
                            SUBSTR (get_min_rec.part_serial_no, 4, 3),
                            get_min_rec.part_bin, '110',
                            get_min_rec.part_mod,
                            get_min_rec.part_serial_no,
                            get_min_rec.part_status,
                            get_min_rec.part_inst2carrier_mkt,
                            get_min_rec.part_inst2inv_bin,
                            get_min_rec.objid,
                            get_min_rec.n_part_inst2part_mod,
                            get_min_rec.created_by2user,
                            get_min_rec.part_inst2x_new_pers,
                            get_min_rec.part_inst2x_pers,
                            get_min_rec.x_po_num,
                            get_min_rec.x_reactivation_flag,
                            get_min_rec.x_red_code, get_min_rec.x_sequence,
                            get_min_rec.warr_end_date, get_min_rec.dev,
                            get_min_rec.fulfill2demand_dtl,
                            get_min_rec.part_to_esn2part_inst,
                            get_min_rec.bad_res_qty,
                            get_min_rec.date_in_serv,
                            get_min_rec.good_res_qty,
                            get_min_rec.last_cycle_ct,
                            get_min_rec.last_mod_time,
                            get_min_rec.last_pi_date,
                            get_min_rec.last_trans_time,
                            get_min_rec.next_cycle_ct,
                            get_min_rec.x_order_number,
                            get_min_rec.part_bad_qty,
                            get_min_rec.part_good_qty,
                            get_min_rec.pi_tag_no, get_min_rec.pick_request,
                            get_min_rec.repair_date,
                            get_min_rec.transaction_id, p_msid
                           );

               p_message := 'Sucessful';
               COMMIT;
            END IF;
         END IF;
      END IF;                                                         --CR4530
   EXCEPTION
      WHEN OTHERS
      THEN
         p_message := 'Oracle Error: ' || SQLERRM;
   END sp_flag_new_msid;

-------------------------------------------------------------------------------------
--CR3153 - Changes for T-Mobile
   PROCEDURE sp_esn_min_status (
      p_esn          IN       VARCHAR2,
      p_esn_status   OUT      VARCHAR2,
      p_min_status   OUT      VARCHAR2,
      p_min          OUT      VARCHAR2,
      p_message      OUT      VARCHAR2
   )
   IS
      CURSOR esn_curs
      IS
         SELECT *
           FROM table_part_inst
          WHERE part_serial_no = p_esn;

      esn_rec     esn_curs%ROWTYPE;

      CURSOR phone_curs (c_objid VARCHAR2)
      IS
         SELECT *
           FROM table_site_part
          WHERE objid = c_objid;

      phone_rec   phone_curs%ROWTYPE;

      CURSOR min_curs (c_esn_objid NUMBER, c_min VARCHAR2)
      IS
         SELECT *
           FROM table_part_inst
          WHERE part_to_esn2part_inst = c_esn_objid
            AND part_serial_no = c_min
            AND x_domain = 'LINES';

      min_rec     min_curs%ROWTYPE;

      CURSOR code_curs (c_code_number VARCHAR2)
      IS
         SELECT x_code_name
           FROM table_x_code_table
          WHERE x_code_number = c_code_number;

      code_rec    code_curs%ROWTYPE;
   BEGIN
      p_message := 'S';

      OPEN esn_curs;

      FETCH esn_curs
       INTO esn_rec;

      IF esn_curs%NOTFOUND
      THEN
         p_message := 'F';
         RETURN;
      END IF;

      CLOSE esn_curs;

      OPEN code_curs (esn_rec.x_part_inst_status);

      FETCH code_curs
       INTO code_rec;

      IF code_curs%NOTFOUND
      THEN
         p_message := 'F';
         RETURN;
      END IF;

      CLOSE code_curs;

      p_esn_status := code_rec.x_code_name;

      OPEN phone_curs (esn_rec.x_part_inst2site_part);

      FETCH phone_curs
       INTO phone_rec;

      IF phone_curs%NOTFOUND
      THEN
         p_message := 'F';
         RETURN;
      END IF;

      CLOSE phone_curs;

      OPEN min_curs (esn_rec.objid, phone_rec.x_min);

      FETCH min_curs
       INTO min_rec;

      IF min_curs%NOTFOUND
      THEN
         p_message := 'F';
         RETURN;
      END IF;

      CLOSE min_curs;

      p_min := min_rec.part_serial_no;

      OPEN code_curs (min_rec.x_part_inst_status);

      FETCH code_curs
       INTO code_rec;

      IF code_curs%NOTFOUND
      THEN
         p_message := 'F';
         RETURN;
      END IF;

      p_min_status := code_rec.x_code_name;

      CLOSE code_curs;
   END sp_esn_min_status;
--CR3153 - End Changes for T-Mobile
END igate_indv;
/