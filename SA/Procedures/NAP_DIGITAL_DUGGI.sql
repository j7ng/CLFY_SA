CREATE OR REPLACE PROCEDURE sa.nap_digital_duggi(
   /********************************************************************************/
   /* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved                */
   /*                                                                              */
   /* Name         :   nap_digital                                                 */
   /* Purpose      :   Reserves a line                                             */
   /* Parameters   :                                                               */
   /* Platforms    :   Oracle 8.0.6 AND newer versions                             */
   /* Author       :                                                               */
   /* Date         :   07/11/2001                                                  */
   /* Revisions    :                                                               */
   /*                                                                              */
   /* Version  Date        Who             Purpose                                 */
   /* -------  --------    -------         --------------------------------------  */
   /* 4.22    08/08/05     VA              Checked in with the correct version label CR4375 (PVCS Revision 1.43)
   /* 4.21    08/08/05     VA              CR4347 - Insert a record into NAP_C_CHOICE for "No NET-10 Coverage" (PVCS Revision 1.42)
   /* 4.20    08/02/05     VA              CR4371 - Emergency Fix (Modifed based on Curt's recommendations to improve the performance)
   /*                                               (PVCS Revision 1.41)
   /* 4.19    06/27/05     VA              CR4212 - Bug Fix (PVCS Revision 1.40)
   /* 4.18    06/24/05     VA              EME Fix for CR3918 (PVCS Revision 1.39)
   /*                                      (No MIN change if the latest deact reason is "NON TOPP LINE"
   /* 4.17    06/14/05     VA              CR4017 - SIM Errors and ACT/REACT FLOW WEBCSR (1.38)
   /* 4.16    06/09/05     VA              CR3918 - Fix added to get the previous sim only for non-T MIN numbers (1.37)
   /*                                      Since CR3918 was rolled back, used the same CR# in the header
   /* 4.15    06/03/05     VA              CR4117 - Check for markets only if old and new sim are same (1.36)
   /* 4.14    05/31/05     VA              Check for different markets only if it is Cingular (1.35)
   /* 4.13    05/26/05     VA              Correct PVCS Revision # 1.34
   /* 4.12    05/26/05     VA              Fix to check for "150" status - is_a_react_fun
   /*                                      (PVCS Version 1.33)
   /* 4.11    05/11/05     VA              Merged CR3918 with CR3824 (PVCS Revision 1.32)
   /* 4.10    05/10/05     VA              Fix for CR3918
   /*                                      Same zip return "no min" (PVCS Version 1.31)
   /* 4.9     05/09/05     VA              Fix for CR3918
   /*                                       - No same zone/st check for Cingular
   /*                                       - Return "NO CINGULAR COVERAGE" message
   /*                                       - Check for market only for same sims
   /* 4.8     05/04/05     VA              Fix for a bug for CR3918 found during
   /*                                      testing (PVCS Version 1.29)
   /* 4.7     05/03/05     VA              CR3918 - New Project_ Cingular change
   /*                                      MSISDN (PVCS Version 1.28)
   /* 4.6     05/10/05     VA              CR3824 - WEBCSR upgrade flow
   /* 4.5     05/02/05     VA              CR3885 -  Project SIM 4 for all Cingular
   /*                                      GSM activations (PVCS Revision 1.27)
   /* 4.4     04/18/05     VA              CR3910 - NEW LINES for GSM customers
   /*                                      whenever possible (PVCS Revision 1.26)  */
   /* 4.3     03/14/05     VA              CR3647 - T-Mobile Min Change            */
   /* 4.2     12/09/04     VA              CR3327(1)-Portability Automation changes*/
   /* 4.1     12/14/04     VA              CR3190 - NET10 Changes                  */
   /* 4.0     02/01/05     VA              CR3614 - EME Nap Changes                */
   /* 3.9     01/07/05     VA              CR3527 - EME Nap Verify Fix             */
   /* 3.8     12/07/04     VA              CR3459 - Fix for GSM reacts that give   */
   /*                                      "No Lines Available" message in non-GSM */
   /*                                      zipcodes                                */
   /* 3.7     11/30/04     VA              CR3437(MT57585) Modify Nap Verify to not*/
   /*                                      reserve lines                           */
   /* 3.6     11/03/04     VA              CR3338 Changes : GSM Activation /       */
   /*                                      Reactivation Logic                      */
   /* 3.5     11/03/04     VA              CR3310 - Check for inactive site part   */
   /*                                       record (react_65_90_fun)               */
   /* 3.4     10/15/04     VA              CR2620 - Carrier Automation Phase III   */
   /* 3.3	   08/08/04	    CL		        CR3153: Return new message for no      */
   /*					                    inventory carrier			           */
   /* 3.2     07/09/04     VA              CR2739: CASE Modifications              */
   /*                                      Use x_gsm_grace_period field instead of */
   /*                                      x_line_expire_days                      */
   /* 3.1     05/26/04     VA              CR2672: Fix to return the reserved line */
   /*                                      for a new activation                    */
   /* 3.0     05/20/04     GP              CR2824: Changed p_msg when no carrier   */
   /*                                      found.                                  */
   /* 2.9     04/13/04     CWL             To put the carriers (preferred/default) */
   /*                                      in the right order - Separate in 2 loops*/
   /* 2.8     04/07/04     VAdapa          change to check for pref technology     */
   /*                                      (as per Dan Driscoll)                   */
   /* 2.7     11/14/03     VAdapa          change for # portability (technology)   */
   /* 2.6     11/09/03     CWL             change for # portability                */
   /* 2.5     08/22/03     ML              Added branching logic fro GSM. It was   */
   /*                                      to the developer to 'clone' the exiting */
   /*                                      nap logic for GSM.                      */
   /* 2.4     03/25/03     SL              Optimize quries that use bad index      */
   /*                                                                              */
   /* 2.3     12/30/02     D. Driscoll     Motorola Digital (1900 MHz) addition    */
   /* 2.2     10/03/02     VAdapa          AMIGO Changes                           */
   /* 2.1     08/14/02     ???             ???                                     */
   /* 2.0     06/18/02     VAdapa          Remove D Choice logic, but keep         */
   /*                                      reporting                               */
   /* 1.1........                                                                  */
   /* 1.0     07/11/01                     Initial revision                        */
   /*                                                                              */
   /*                                                                              */
   /*                                                                              */
   /*                                                                              */
   /********************************************************************************/
   p_zip IN VARCHAR2,
   p_esn IN VARCHAR2,
   p_commit IN VARCHAR2
   DEFAULT 'YES',
   p_language IN VARCHAR2
   DEFAULT 'English',
   --CR3338 Start
   p_sim IN VARCHAR2,
   p_source IN VARCHAR2,
   p_upg_flag IN VARCHAR2
   DEFAULT 'N', --CR3824
   p_repl_part OUT VARCHAR2,
   p_repl_tech OUT VARCHAR2,
   p_sim_profile OUT VARCHAR2,
   --CR3338 End
   p_part_serial_no OUT VARCHAR2,
   p_msg OUT VARCHAR2
)
IS
---------------------------------------------------------------
   TYPE carrier_tab
   IS
   TABLE OF table_x_carrier.objid%TYPE INDEX BY BINARY_INTEGER;
   carrier_array carrier_tab;
   carrier_array2 carrier_tab;
   carrier_array3 carrier_tab;
   carrier_cnt INTEGER := 0;
   carrier_cnt2 INTEGER := 0;
   carrier_cnt3 INTEGER := 0;
   global_dealer_id VARCHAR2 (100);
   global_part_serial_no VARCHAR2 (100);
   global_technology VARCHAR2 (100);
   global_zip VARCHAR2 (100) := p_zip;
   global_esn VARCHAR2 (100) := p_esn;
   global_try_sid VARCHAR2 (30) := 'N';
   global_resource_busy VARCHAR2 (30) := 'Y';
   global_resource_busy_cnt NUMBER := 1;
   global_carr_found_flag NUMBER := 0;
   global_no_inventory NUMBER := 0; --Variable for CR3153
   --Variables flagged when one of the D Choices is found - Vadapa 06/18/02
   d_choice_found BOOLEAN := FALSE;
   d2_choice_found BOOLEAN := FALSE;
   --
   --Variables for Amigo - VAdapa 10/03/02
   global_restricted_use NUMBER := 0;
   l_amigo_yn NUMBER := 0;
   --Variables for Motorola Digital 12/30/02
   global_carrier_frequency NUMBER := 800;
   global_phone_frequency NUMBER := 800;
   global_phone_frequency2 NUMBER := 1900;
   global_part_good_flag NUMBER;
   global_new_handset BOOLEAN := FALSE;
   global_react_new_line BOOLEAN := FALSE;
   --CR3338 Start
   l_react_sim NUMBER := 0;
   global_sim_profile VARCHAR2(20);
   l_react_valid_check NUMBER := 0;
   l_commit VARCHAR2(10) := UPPER(p_commit);
   l_sim_valid_check NUMBER := 0;
   l_gsm_same_zone BOOLEAN := FALSE;
   --CR3338 End
   l_same_zone BOOLEAN := FALSE; --CR3614
   global_portin_line VARCHAR2 (100); --CR3327-1
   l_msisdn_flag CHAR(1) ; --CR3918
   l_new_msg_flag CHAR(1) := 'N'; --CR3918
   ---------------------------------------------------------------
   -- new code cwl
   ---------------------------------------------------------------
   CURSOR check_analog_order(
      c_carrier_objid IN VARCHAR2,
      c_rank IN VARCHAR2
   )
   IS
   SELECT 1 hold
   FROM carrierpref e, table_x_carrier c, carrierzones a
   WHERE e.county = a.county
   AND e.st = a.st
   AND e.carrier_id = c.x_carrier_id
   AND c.objid = c_carrier_objid
   AND e.new_rank = c_rank
   AND a.zip = global_zip;
   analog_order_rec check_analog_order%ROWTYPE;
   ---------------------------------------------------------------
   CURSOR check_digital_order(
      c_carrier_objid IN VARCHAR2,
      c_rank IN VARCHAR2
   )
   IS
   SELECT 1 hold
   FROM carrierpref e, table_x_carrier c, npanxx2carrierzones b, carrierzones a
   WHERE a.county = e.county
   AND e.st = b.state
   AND e.carrier_id = b.carrier_id
   AND e.carrier_id = c.x_carrier_id
   AND c.objid = c_carrier_objid
   AND e.new_rank = c_rank
   AND b.frequency1 IN ('1900', '800')
   AND ( b.tdma_tech = global_technology
   OR b.cdma_tech = global_technology
   OR b.gsm_tech = global_technology)
   AND a.zone = b.zone
   AND b.state = a.st
   AND a.zip = global_zip;
   digital_order_rec check_digital_order%ROWTYPE;
   new_carrier_cnt2 NUMBER := 0;
   ---------------------------------------------------------------
   -- end new code cwl
   ---------------------------------------------------------------
   --CR3338 Start
   CURSOR c_line_port(
      ip_min IN VARCHAR2
   )
   IS
   SELECT x_port_in
   FROM table_part_inst
   WHERE part_serial_no = ip_min;
   c_line_port_rec c_line_port%ROWTYPE;
   ---------------------------------------------------------------
   CURSOR gsm_get_same_zone_cur(
      ip_line IN VARCHAR2
   )
   IS
   SELECT DISTINCT a.zip,
      a.rate_cente,
      a.zone,
      a.county,
      a.st,
      b.npa,
      b.nxx
   FROM carrierzones a, npanxx2carrierzones b
   WHERE b.nxx = SUBSTR (ip_line, 4, 3)
   AND b.npa = SUBSTR (ip_line, 1, 3)
   AND a.st = b.state
   AND a.zone = b.zone
   AND a.zip = p_zip;
   gsm_get_same_zone_rec gsm_get_same_zone_cur%ROWTYPE;
   -----------------------------------------
   CURSOR c_sim_carr_info(
      c_ip_profile IN VARCHAR2
   )
   IS
   SELECT DISTINCT c.objid carr_objid,
      c.x_carrier_id,
      f.x_acct_num,
      e.x_no_inventory,
      c.CARRIER2RULES
   FROM sa.carrierzones a, sa.npanxx2carrierzones b, sa.table_x_carrier c, sa.table_x_carrier_group
   d, table_x_parent e, table_x_account f
   WHERE (a.sim_profile
   IS
   NOT NULL
   OR a.sim_profile_2
   IS
   NOT NULL) --CR3885
   AND b.GSM_TECH = 'GSM'
   --   AND a.bta_mkt_number = b.bta_mkt_number
   AND a.st = b.state
   AND a.zone = b.zone
   AND a.zip = global_zip
   AND (a.sim_profile = c_ip_profile
   OR a.sim_profile_2 = c_ip_profile) --CR3885
   AND b.carrier_id = c.x_carrier_id
   AND c.carrier2carrier_group = d.objid
   AND d.x_carrier_group2x_parent = e.objid
   AND f.account2x_carrier = c.objid
   AND f.x_status = 'Active';
   c_sim_carr_info_rec c_sim_carr_info%ROWTYPE;
   -------------------------------------------------
   PROCEDURE get_repl_sim(
      p_out_msg OUT VARCHAR2,
      p_repl_sim OUT VARCHAR2
   )
   IS
      CURSOR c_pref_gsm_carr(
         ip_phone_freq1 IN NUMBER,
         ip_phone_freq2 IN NUMBER
      )
      IS
      SELECT tab2.carrier_id pref_carr_id
      FROM carrierpref cp, table_x_carrier CA, (
         SELECT DISTINCT b.state,
            b.county,
            b.carrier_id,
            b.gsm_tech
         FROM npanxx2carrierzones b, (
            SELECT DISTINCT a.zone,
               a.st,
               a.sim_profile,
               a.sim_profile_2--CR3885
            FROM carrierzones a
            WHERE a.zip = global_zip)tab1
         WHERE b.zone = tab1.zone
         AND b.state = tab1.st)tab2
      WHERE cp.new_rank = (
      SELECT MIN(cp.new_rank)
      FROM carrierpref cp, table_x_carrier CA, (
         SELECT DISTINCT b.state,
            b.county,
            b.carrier_id,
            b.cdma_tech,
            b.tdma_tech,
            b.gsm_tech
         FROM npanxx2carrierzones b, (
            SELECT DISTINCT a.zone,
               a.st,
               a.sim_profile,
               a.sim_profile_2--CR3885
            FROM carrierzones a
            WHERE a.zip = global_zip)tab1
         WHERE b.zone = tab1.zone
         AND b.state = tab1.st
         AND b.gsm_tech = 'GSM'
         AND (b.frequency1 IN ( ip_phone_freq1, ip_phone_freq2 )
         OR b.frequency2 IN ( ip_phone_freq1, ip_phone_freq2)))tab2
      WHERE cp.county = tab2.county
      AND cp.st = tab2.state
      AND cp.carrier_id = tab2.carrier_id
      AND CA.x_Carrier_Id = tab2.carrier_id
      AND CA.x_status = 'ACTIVE' )
      AND cp.county = tab2.county
      AND cp.st = tab2.state
      AND cp.carrier_id = tab2.carrier_id
      AND tab2.carrier_id = ca.x_carrier_id
      AND ca.x_status = 'ACTIVE'
      AND tab2.gsm_tech = 'GSM' ;
      c_pref_gsm_carr_rec c_pref_gsm_carr%ROWTYPE;
      -------------------------------------------
      CURSOR c_sim_repl(
         c_ip_carr IN VARCHAR2
      )
      IS
      SELECT a.sim_profile,
         a.sim_profile_2--CR3885
      FROM sa.carrierzones a, (
         SELECT DISTINCT --b.bta_mkt_number,
            b.state,
            b.zone
         FROM sa.npanxx2carrierzones b
         WHERE 1 = 1
         AND b.GSM_TECH = 'GSM'
         AND b.carrier_id = c_ip_carr)b
      WHERE 1 = 1
      AND (a.sim_profile
      IS
      NOT NULL
      OR a.sim_profile_2
      IS
      NOT NULL )--CR3885
      AND a.zip = global_zip
      AND a.zone = b.zone
      --      AND a.bta_mkt_number = b.bta_mkt_number
      AND a.st = b.state;
      c_sim_repl_rec c_sim_repl%ROWTYPE;
      phone_freq1 NUMBER := global_phone_frequency;
      phone_freq2 NUMBER := global_phone_frequency2;

   ------------------------------------------
   BEGIN
      IF global_phone_frequency = 0
      THEN
         phone_freq1 := global_phone_frequency2;
      END IF;
      IF global_phone_frequency2 = 0
      THEN
         phone_freq2 := global_phone_frequency;
      END IF;
      OPEN c_pref_gsm_carr(phone_freq1, phone_freq2);
      FETCH c_pref_gsm_carr
      INTO c_pref_gsm_carr_rec;
      --      IF c_pref_gsm_carr%found
      IF c_pref_gsm_carr_rec.pref_carr_id
      IS
      NOT NULL
      THEN
         OPEN c_sim_repl(c_pref_gsm_carr_rec.pref_carr_id);
         FETCH c_sim_repl
         INTO c_sim_repl_rec;
         IF c_sim_repl%found
         THEN
            p_out_msg := 'SIM Exchange';
            --CR3885 Starts
            IF (c_sim_repl_rec.sim_profile
            IS
            NOT NULL
            AND c_sim_repl_rec.sim_profile_2
            IS
            NOT NULL)
            THEN
               p_repl_sim := c_sim_repl_rec.sim_profile_2;
            ELSE
--CR3885 Ends
               p_repl_sim := c_sim_repl_rec.sim_profile;
            END IF;
--CR3885
         ELSE
            CLOSE c_sim_repl;
            p_out_msg := 'Failure - Sim replacement';
            p_repl_sim := NULL;
            RETURN;
         END IF;--End sim_repl check
         CLOSE c_sim_repl;
      ELSE
         CLOSE c_pref_gsm_carr;
         p_out_msg := 'No preferred carrier for SIM';
         p_repl_sim := NULL;
         RETURN;
      END IF;
      CLOSE c_pref_gsm_carr;
   END get_repl_sim;
   ---------------------------------------------------------------
   PROCEDURE get_repl_part(
      p_out_msg OUT VARCHAR2,
      p_repl_part OUT VARCHAR2,
      p_repl_tech OUT VARCHAR2,
      p_repl_sim OUT VARCHAR2
   )
   IS
      CURSOR c_repl_tech
      IS
      SELECT tab2.cdma_tech ctech,
         tab2.tdma_tech ttech,
         tab2.gsm_tech gtech,
         cp.new_rank
      FROM carrierpref cp, table_x_carrier CA, (
         SELECT DISTINCT b.state,
            b.county,
            b.carrier_id,
            b.cdma_tech,
            b.tdma_tech,
            b.gsm_tech
         FROM npanxx2carrierzones b, (
            SELECT DISTINCT a.zone,
               a.st,
               a.sim_profile
            FROM carrierzones a
            WHERE a.zip = global_zip)tab1
         WHERE b.zone = tab1.zone
         AND b.state = tab1.st)tab2
      WHERE cp.county = tab2.county
      AND cp.st = tab2.state
      AND cp.carrier_id = tab2.carrier_id
      AND CA.x_carrier_Id = tab2.carrier_id
      AND CA.x_Status = 'ACTIVE'
      ORDER BY new_rank;
      --------------------
      CURSOR c_old_ESN_info
      IS
      SELECT pn.objid,
         pn.x_technology
      FROM table_part_inst pi, table_mod_level ml, table_part_num pn
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = global_esn;
      c_old_ESN_info_rec c_old_ESN_info%ROWTYPE;
      --------------------
      CURSOR c_repl_part(
         c_ip_tech IN VARCHAR2,
         c_ip_esn_objid IN NUMBER
      )
      IS
      SELECT pn.part_number,
         pn.x_technology
      FROM table_x_exch_options exch, table_part_num pn
      WHERE exch.exch_source2part_num = c_ip_esn_objid
      AND exch_target2part_num = pn.objid
      AND pn.x_technology = c_ip_tech
      AND exch.x_exch_type = 'TECHNOLOGY'
      ORDER BY exch.x_priority ASC;
      c_repl_part_rec c_repl_part%ROWTYPE;
      ---------------------
      l_pref_tech VARCHAR2(20);
      l_repl_partnum_tech VARCHAR2(20);
      l_bln_gsm BOOLEAN;
      l_gsm_pref_tech VARCHAR2(20);
   BEGIN
      OPEN c_old_esn_info;
      FETCH c_old_esn_info
      INTO c_old_esn_info_rec;
      IF c_old_esn_info%notfound
      THEN
         p_out_msg := 'Esn Not Found';
         CLOSE c_old_esn_info;
         RETURN;
      END IF;
      CLOSE c_old_esn_info;
      FOR c_repl_tech_rec IN c_repl_tech
      LOOP
         IF c_old_esn_info_rec.x_technology = 'GSM'
         THEN
            l_gsm_pref_tech := c_repl_tech_rec.gtech;
            IF l_gsm_pref_tech
            IS
            NOT NULL
            AND l_gsm_pref_tech = 'GSM'
            THEN
               l_bln_gsm := TRUE;
            END IF;
         END IF;
         IF c_repl_tech_rec.ctech
         IS
         NOT NULL
         THEN
            l_pref_tech := c_repl_tech_rec.ctech;
         ELSE
            l_pref_tech := c_repl_tech_rec.ttech;
         END IF;
         IF (((c_old_esn_info_rec.x_technology IN ('TDMA', 'CDMA'))
         AND (c_old_esn_info_rec.x_technology = l_pref_tech))
         OR (c_old_esn_info_rec.x_technology = 'GSM'
         AND l_bln_gsm))
         THEN
            l_repl_partnum_tech := c_old_esn_info_rec.x_technology;
         ELSE
            l_repl_partnum_tech := l_pref_tech;
         END IF;
         OPEN c_repl_part(l_repl_partnum_tech, c_old_esn_info_rec.objid);
         FETCH c_repl_part
         INTO c_repl_part_rec;
         IF c_repl_part%notfound
         THEN
            IF (c_old_esn_info_rec.x_technology = 'GSM'
            AND l_bln_gsm)
            THEN
               CLOSE c_repl_part;
               l_bln_gsm := FALSE;
               OPEN c_repl_part(l_pref_tech, c_old_esn_info_rec.objid);
               FETCH c_repl_part
               INTO c_repl_part_rec;
               IF c_repl_part%found --GSM repl part not found, get CDMA/TDMA repl part
               THEN
                  p_repl_part := c_repl_part_rec.part_number;
                  p_repl_tech := c_repl_part_rec.x_technology;
                  p_out_msg := 'Replacement Part Found';
                  CLOSE c_repl_part;
                  RETURN;
               END IF;--End of c_repl_part%found check
               CLOSE c_repl_part;
            END IF;
--End of GSM phone check
         --If GSM phone
         ELSE
            p_repl_part := c_repl_part_rec.part_number;
            p_repl_tech := c_repl_part_rec.x_technology;
            p_out_msg := 'Replacement Part Found';
            IF (c_old_esn_info_rec.x_technology = 'GSM'
            AND l_bln_gsm)
            THEN
               get_repl_sim(p_out_msg, p_repl_sim);
            ELSE
               p_repl_sim := NULL;
            END IF;
--End of GSM phone check (for sim replacement)
         END IF; --End of c_repl_part%notfound check
         CLOSE c_repl_part;
         IF p_repl_part
         IS
         NOT NULL
         THEN
            EXIT;
         END IF;
      END LOOP;
      IF p_repl_part
      IS
      NOT NULL
      AND p_repl_sim
      IS
      NOT NULL
      THEN
         p_out_msg := 'Replacement Part Found';
      END IF;
   END get_repl_part;
   ---------------------------------------------------------------
   FUNCTION is_valid_iccid
   RETURN NUMBER
   IS
      CURSOR c_sim_status
      IS
      SELECT pn.part_number,
         sim.x_sim_mnc
      FROM table_x_sim_inv sim, table_mod_level ml, table_part_num pn
      WHERE sim.x_sim_inv_status IN ('251', '253')
      AND sim.X_SIM_STATUS2X_CODE_table = DECODE(x_sim_inv_status, '251',
      268438604, '253', 268438606)
      AND sim.x_sim_inv2part_mod = ml.objid
      AND ml.part_info2part_num = pn.objid
      AND sim.x_sim_serial_no = p_sim;
      c_sim_status_rec c_sim_status%ROWTYPE;
      -------------------------
      CURSOR c_sim_info
      IS
      SELECT DISTINCT b.mnc,
         a.sim_profile,
         a.sim_profile_2,  --CR3885
         a.zone,
         a.st
      FROM sa.carrierzones a, sa.npanxx2carrierzones b
      WHERE (a.sim_profile
      IS
      NOT NULL
      OR a.sim_profile_2
      IS
      NOT NULL )--CR3885
      AND b.GSM_TECH = 'GSM'
      AND a.st = b.state
      AND a.zone = b.zone
      AND a.zip = global_zip;
      c_sim_info_rec c_sim_info%ROWTYPE;
      -------------------------
      CURSOR c_is_sim_married
      IS
      SELECT 'X'
      FROM table_part_inst
      WHERE x_iccid = p_sim;
      c_is_sim_married_rec c_is_sim_married%ROWTYPE;
      -------------------------
      l_sim_mnc_cnt NUMBER := 0;
   BEGIN
      OPEN c_sim_status;
      FETCH c_sim_status
      INTO c_sim_status_rec;
      IF c_sim_status%notfound
      THEN
         CLOSE c_sim_status;
         OPEN c_is_sim_married;
         FETCH c_is_sim_married
         INTO c_is_sim_married_rec;
         IF c_is_sim_married%found
         THEN
            CLOSE c_is_sim_married;
            RETURN 1;
         END IF;
         CLOSE c_is_sim_married;
         RETURN 2;
      END IF;
      CLOSE c_sim_status;
      FOR c_sim_info_rec IN c_sim_info
      LOOP

         --CR3885 Starts
         /* IF (c_sim_info_rec.mnc = c_sim_status_rec.x_sim_mnc
         AND c_sim_info_rec.sim_profile = c_sim_status_rec.part_number )
         THEN
            l_sim_mnc_cnt := l_sim_mnc_cnt + 1;
            global_sim_profile := c_sim_info_rec.sim_profile;
         END IF;*/
         IF (c_sim_info_rec.sim_profile = c_sim_status_rec.part_number
         OR c_sim_info_rec.sim_profile_2 = c_sim_status_rec.part_number )
         THEN
            l_sim_mnc_cnt := l_sim_mnc_cnt + 1;
            --global_sim_profile := c_sim_info_rec.sim_profile;
            global_sim_profile := c_sim_status_rec.part_number;
         END IF;

      --CR3885 Ends
      END LOOP;
      IF l_sim_mnc_cnt = 0
      THEN
         RETURN 3;
      END IF;
      RETURN 0;
   END is_valid_iccid;
   ---------------------------------------------------------------
   PROCEDURE update_line(
      p_part_serial_no IN VARCHAR2
   )
   IS
      CURSOR c1
      IS
      SELECT phones.objid
      FROM table_part_inst phones
      WHERE phones.x_domain = 'PHONES'
      AND phones.part_serial_no = p_esn;
      c1_rec c1%ROWTYPE;
      hold_part_inst_status VARCHAR (200);
---------------------------------------------------------------
   BEGIN
      OPEN c1;
      FETCH c1
      INTO c1_rec;
      CLOSE c1;
      --      IF UPPER (p_commit) = 'YES'
      IF UPPER (l_commit) = 'YES'
      THEN
         SELECT x_part_inst_status
         INTO hold_part_inst_status
         FROM table_part_inst
         WHERE part_serial_no = p_part_serial_no
         AND x_part_inst_status IN ('11', '12')
         AND x_domain = 'LINES' FOR UPDATE NOWAIT;
         UPDATE table_part_inst SET x_part_inst_status = DECODE (
         x_part_inst_status, '11', '37', '12', '39'), part_to_esn2part_inst =
         c1_rec.objid, status2x_code_table = DECODE (x_part_inst_status, '11',
         969, '12', 1040), last_cycle_ct = SYSDATE
         WHERE part_serial_no = p_part_serial_no
         AND x_part_inst_status IN ('11', '12')
         AND x_domain = 'LINES';
         DBMS_OUTPUT.put_line ('p_commit:= yes');
      ELSE
         DBMS_OUTPUT.put_line ('p_commit:= no');
      END IF;
      global_resource_busy := 'N';
      EXCEPTION
      WHEN OTHERS
      THEN
         global_resource_busy := 'Y';
   END update_line;
   ---------------------------------------------------------------
   PROCEDURE update_c_choice(
      c_zip IN VARCHAR2,
      c_esn IN VARCHAR2,
      c_phone IN VARCHAR2,
      c_choice IN VARCHAR2
   )
   IS
   BEGIN
--      IF UPPER (p_commit) = 'YES'
      IF UPPER (l_commit) = 'YES'
      THEN

         --    INSERT INTO nap_c_choice
         --  VALUES(c_zip, c_esn, c_phone, c_choice, SYSDATE);
         INSERT
         INTO nap_c_choice(
            zip,
            esn,
            given_line,
            choice,
            action_date
         )--,
         --X_ICCID)
         VALUES(
            c_zip,
            c_esn,
            c_phone,
            c_choice,
            SYSDATE
         );
--, NULL); -- FOR NOW ML
      END IF;
   END;
   ---------------------------------------------------------------
   FUNCTION valid_zip
   RETURN BOOLEAN
   IS
      CURSOR check_zip
      IS
      SELECT 1
      FROM carrierzones cz --JRD nap_zip2mrkt nz2m
      WHERE cz.zip = global_zip;
      zip_rec check_zip%ROWTYPE;
---------------------------------------------------------------
   BEGIN
      OPEN check_zip;
      FETCH check_zip
      INTO zip_rec;
      IF check_zip%FOUND
      THEN
         CLOSE check_zip;
         RETURN TRUE;
      END IF;
      CLOSE check_zip;
      RETURN FALSE;
   END;
   ---------------------------------------------------------------
   FUNCTION get_line
   RETURN BOOLEAN
   IS
      CURSOR get_cell_num(
         c_esn IN VARCHAR2
      )
      IS
      SELECT lines.objid,
         lines.part_serial_no,
         lines.x_part_inst_status line_status,
         lines.x_port_in--CR3327-1
      FROM table_part_inst lines, table_part_inst phones
      WHERE lines.x_domain = 'LINES'
      AND lines.part_to_esn2part_inst = phones.objid
      --AND lines.x_part_inst_status IN ('37',  '39',  '73') --CR2620
      AND lines.x_part_inst_status IN ('37', '39', '73', '110') --CR2620
      AND phones.x_domain = 'PHONES'
      AND phones.part_serial_no = c_esn;
      get_cell_num_rec get_cell_num%ROWTYPE;
      --CR2620 Start
      CURSOR get_no_msid_line(
         c_min IN VARCHAR2
      )
      IS
      SELECT 1
      FROM table_x_parent cp, table_x_carrier_group cg, table_x_carrier ca,
      table_part_inst pimin
      WHERE pimin.part_inst2carrier_mkt = ca.objid
      AND ca.carrier2carrier_group = cg.objid
      AND cg.x_carrier_group2x_parent = cp.objid
      AND cp.x_no_msid = 1
      AND pimin.part_serial_no = c_min;
      get_no_msid_line_rec get_no_msid_line%ROWTYPE;
--CR2620 End
   ---------------------------------------------------------------
   BEGIN

      --CR3327-1 Starts
      global_portin_line := NULL;
      FOR get_cell_num_rec IN get_cell_num (p_esn)
      LOOP
         IF get_cell_num_rec.x_port_in <> 0
         THEN
            global_portin_line := get_cell_num_rec.part_serial_no;
            EXIT;
         END IF;
      END LOOP;
      --CR3327-1 Ends
      OPEN get_cell_num (p_esn);
      FETCH get_cell_num
      INTO get_cell_num_rec;
      IF get_cell_num%FOUND
      THEN
--CR2620 Start
         IF get_cell_num_rec.line_status = '110'
         THEN
            OPEN get_no_msid_line(get_cell_num_rec.part_serial_no);
            FETCH get_no_msid_line
            INTO get_no_msid_line_rec;
            IF get_no_msid_line%FOUND
            THEN
               global_part_serial_no := get_cell_num_rec.part_serial_no;
               CLOSE get_no_msid_line;
               RETURN TRUE;
            END IF;
            CLOSE get_no_msid_line;
            RETURN FALSE;
         ELSE
            global_part_serial_no := get_cell_num_rec.part_serial_no;
         END IF;
         --CR2620 End
         CLOSE get_cell_num;
         RETURN TRUE;
      END IF;
      CLOSE get_cell_num;
      RETURN FALSE;
   END get_line;
   /*****************************************************************************/
   /* Name: get_carriers                                                        */
   /* Description:                                                              */
   /*****************************************************************************/
   PROCEDURE get_carriers
   IS
      CURSOR get_dealer
      IS
      SELECT s.site_id,
         pn.x_technology,
         NVL (pi.part_good_qty, 0) part_good_flag,  --JR 11/27/01
         pn.x_restricted_use-- Amigo
      FROM table_part_num pn, table_mod_level ml, table_site s, table_inv_role
      ir, table_inv_bin ib, table_part_inst pi
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND s.objid = ir.inv_role2site
      AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
      AND ib.objid = pi.part_inst2inv_bin
      AND pi.x_domain = 'PHONES'
      AND pi.part_serial_no = global_esn;
      dealer_rec get_dealer%ROWTYPE;
      ---------------------------------------------------------------
      CURSOR get_cd(
         c_dealer_id IN VARCHAR2
      )
      IS
      SELECT x_carrier_id
      FROM table_x_carrierdealer
      WHERE x_dealer_id = c_dealer_id;
      cd_rec get_cd%ROWTYPE;
      ---------------------------------------------------------------
      CURSOR get_carrier(
         c_dealer IN VARCHAR2,
         c_amigo_yn IN VARCHAR2
      )
      IS --Amigo
      SELECT ca.objid,
         ca.x_carrier_id,
         ca.x_react_analog,
         ca.x_react_technology ca_react_technology,
         ca.x_act_analog,
         ca.x_act_technology ca_act_technology,
         pt.x_technology pref_technology,
         f.x_frequency
      FROM table_x_frequency f, mtm_x_frequency2_x_pref_tech1 f2pt,
      table_x_pref_tech pt, table_x_carrier ca, table_x_carrierdealer c, (
         SELECT DISTINCT b.carrier_id
         FROM npanxx2carrierzones b, carrierzones a
         WHERE a.zip = global_zip
         AND b.zone = a.zone
         AND b.state = a.st)tab1
      WHERE f.objid = f2pt.x_frequency2x_pref_tech
      AND f.x_frequency <= NVL (global_phone_frequency, 800) -- Mot Digital
      AND f2pt.x_pref_tech2x_frequency = pt.objid
      AND pt.x_pref_tech2x_carrier = ca.objid
      AND ca.x_status = 'ACTIVE'
      AND ca.x_special_mkt = c_amigo_yn --Amigo
      AND ca.x_carrier_id = tab1.carrier_id
      AND c.x_dealer_id = c_dealer
      AND c.x_carrier_id = tab1.carrier_id
      ORDER BY f.x_frequency DESC;
      test_carrier get_carrier%ROWTYPE;
      --------------------------------------------------------------
      -- check to see if this is a react
      CURSOR react_curs
      IS
      SELECT 'X' col1
      FROM table_part_inst
      WHERE part_serial_no = p_esn
      AND x_domain = 'PHONES'
      AND x_part_inst_status || '' = '50';
      react_rec react_curs%ROWTYPE;
      ---------------------------------------------------------------
      -- determine the frequency of the phone being activated
      CURSOR phone_frequency_curs
      IS
      SELECT MAX (f.x_frequency) phone_frequency
      FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num
      pn, table_mod_level ml, table_part_inst pi
      WHERE pf.x_frequency2part_num = f.objid
      AND pn.objid = pf.part_num2x_frequency
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = global_esn
      AND pi.x_domain = 'PHONES';
      ---------------------------------------------------------------
      CURSOR get_carrier2(
         c_dealer IN VARCHAR2,
         c_amigo_yn IN VARCHAR2
      )
      IS --Amigo
      SELECT ca.objid,
         ca.x_carrier_id,
         ca.x_react_analog,
         ca.x_react_technology ca_react_technology,
         ca.x_act_analog,
         ca.x_act_technology ca_act_technology,
         pt.x_technology pref_technology,
         f.x_frequency
      FROM table_x_frequency f, mtm_x_frequency2_x_pref_tech1 f2pt,
      table_x_pref_tech pt, table_x_carrier ca, table_x_carrierdealer c, (
         SELECT DISTINCT b.carrier_id
         FROM npanxx2carrierzones b, carrierzones a
         WHERE a.zip = global_zip
         AND b.zone = a.zone
         AND b.state = a.st)tab1
      WHERE f.objid = f2pt.x_frequency2x_pref_tech
      AND f.x_frequency <= NVL (global_phone_frequency, 800) -- Mot Digital
      AND f2pt.x_pref_tech2x_frequency = pt.objid
      AND pt.x_pref_tech2x_carrier = ca.objid
      AND ca.x_status = 'ACTIVE'
      AND ca.x_carrier_id = tab1.carrier_id --c.x_carrier_id
      AND c.x_dealer_id = 'DEFAULT'
      AND c.x_carrier_id = tab1.carrier_id
      ORDER BY f.x_frequency DESC;
      test_carrier2 get_carrier2%ROWTYPE;
      ---------------------------------------------------------------
      CURSOR pref(
         c_carrier_objid1 IN NUMBER,
         c_carrier_objid2 IN NUMBER
      )
      IS
      SELECT 'X'
      FROM table_x_carrierpreference c, table_x_carrier ca1, table_x_carrier
      ca2
      WHERE c.x_ca_id_pref = TO_CHAR (ca1.x_carrier_id)
      AND c.x_ca_id_2 = TO_CHAR (ca2.x_carrier_id)
      AND ca1.objid = c_carrier_objid1
      AND ca2.objid = c_carrier_objid2;
      pref_rec pref%ROWTYPE;
      ---------------------------------------------------------------
      CURSOR get_carrier_group(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT TO_NUMBER (p.x_parent_id) x_carrier_group_id
      FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier c
      WHERE p.objid = cg.x_carrier_group2x_parent
      AND UPPER (p.x_status) = 'ACTIVE'
      AND cg.objid = c.carrier2carrier_group
      AND cg.x_status = 'ACTIVE'
      AND c.objid = c_carrier_objid;
      carrier_group_rec get_carrier_group%ROWTYPE;
      --------------------------------------------------------------
      -- check to see if this is a cingular fcc market where analog react is allowed
      CURSOR react_cingular
      IS
      SELECT cm.market_id
      FROM x_cingular_fcc_mkt cm, carrierzones zm -- nap_zip2mrkt zm
      WHERE zm.marketid = cm.market_id
      AND zm.zip = p_zip;
      react_cingular_rec react_cingular%ROWTYPE;
   BEGIN
      OPEN get_dealer;
      FETCH get_dealer
      INTO dealer_rec;
      global_dealer_id := dealer_rec.site_id;
      global_technology := dealer_rec.x_technology;
      global_restricted_use := dealer_rec.x_restricted_use; --Amigo
      CLOSE get_dealer;
      DBMS_OUTPUT.put_line ('dealer_id :' || dealer_rec.site_id);
      ---------------------------------------------------------------
      --Amigo
      IF global_restricted_use = 0
      THEN
         l_amigo_yn := 0;
      ELSIF global_restricted_use = 1
      THEN
         l_amigo_yn := 1;
      END IF;
      --End Amigo
      -- Check Phone Frequency - Motorola Digital
      OPEN phone_frequency_curs;
      FETCH phone_frequency_curs
      INTO global_phone_frequency;
      CLOSE phone_frequency_curs;
      OPEN react_curs;
      FETCH react_curs
      INTO react_rec;
      FOR carrier_rec2 IN get_carrier2 (dealer_rec.site_id, l_amigo_yn)
      LOOP
--
         DBMS_OUTPUT.put_line ( 'dealer_rec.x_technology        :' ||
         dealer_rec.x_technology );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_ACT_ANALOG      :' ||
         carrier_rec2.x_act_analog );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_REACT_ANALOG    :' ||
         carrier_rec2.x_react_analog );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_ACT_TECHNOLOGY  :' ||
         carrier_rec2.pref_technology
         --            carrier_rec2.x_act_technology
         );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_REACT_TECHNOLOGY:' ||
         carrier_rec2.pref_technology
         --            carrier_rec2.x_react_technology
         );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.x_carrier_id      :' || TO_CHAR (
         carrier_rec2.x_carrier_id) );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.x_frequency       :' ||
         carrier_rec2.x_frequency );
         DBMS_OUTPUT.put_line ( 'global_phone_frequency         :' ||
         global_phone_frequency );
         --
         IF ( react_curs%FOUND
         AND dealer_rec.x_technology = carrier_rec2.pref_technology --carrier_rec2.x_act_technology
         AND carrier_rec2.ca_act_technology = 'Yes') --11/14/03 Vadapa
         OR ( react_curs%FOUND
         AND dealer_rec.x_technology = 'ANALOG'
         AND carrier_rec2.x_act_analog = 1)
         OR ( react_curs%NOTFOUND
         AND dealer_rec.x_technology = 'ANALOG'
         AND carrier_rec2.x_react_analog = 1)
         OR ( react_curs%NOTFOUND
         AND dealer_rec.x_technology = carrier_rec2.pref_technology --carrier_rec2.x_react_technology
         AND carrier_rec2.ca_react_technology = 'Yes') --11/14/03 Vadapa
         THEN
            carrier_cnt2 := carrier_cnt2 + 1;
            carrier_array2 (carrier_cnt2) := carrier_rec2.objid;
            DBMS_OUTPUT.put_line ( 'carrier_rec2.x_carrier_id :' || TO_CHAR (
            carrier_rec2.x_carrier_id) );
         END IF;
         IF carrier_rec2.x_frequency = 1900
         THEN
            global_carrier_frequency := 1900;
         END IF;
      END LOOP;
      --04/07/04 Changes
      FOR carrier_rec2 IN get_carrier2 (dealer_rec.site_id, l_amigo_yn)
      LOOP
--04/07/04 Changes
         IF ( react_curs%FOUND
         AND dealer_rec.x_technology != 'ANALOG'
         AND dealer_rec.x_technology = carrier_rec2.pref_technology --04/07/04 Changes
         AND ( carrier_rec2.ca_act_technology
         IS
         NULL
         OR carrier_rec2.ca_act_technology = 'No') --11/14/03 Vadapa
         AND ( carrier_rec2.ca_react_technology
         IS
         NULL
         OR carrier_rec2.ca_react_technology = 'No') --11/14/03 Vadapa
         AND carrier_rec2.x_act_analog = 1)
         OR ( react_curs%NOTFOUND
         AND dealer_rec.x_technology != 'ANALOG'
         AND dealer_rec.x_technology = carrier_rec2.pref_technology --04/07/04 Changes
         AND ( carrier_rec2.ca_react_technology
         IS
         NULL
         OR carrier_rec2.ca_react_technology = 'No') --11/14/03 Vadapa
         AND ( carrier_rec2.ca_act_technology
         IS
         NULL
         OR carrier_rec2.ca_act_technology = 'No') --11/14/03 Vadapa
         AND carrier_rec2.x_react_analog = 1)
         THEN
            carrier_cnt2 := carrier_cnt2 + 1;
            carrier_array2 (carrier_cnt2) := carrier_rec2.objid;
            DBMS_OUTPUT.put_line ( 'carrier_rec2.x_carrier_id :' || TO_CHAR (
            carrier_rec2.x_carrier_id) );
         END IF;
         --End 04/07/04 Changes
         IF carrier_rec2.x_frequency = 1900
         THEN
            global_carrier_frequency := 1900;
         END IF;
      END LOOP;
      --End 04/07/04 Changes
      CLOSE react_curs;
      ---------------------------------------------------------------
      OPEN react_curs;
      FETCH react_curs
      INTO react_rec;
      FOR carrier_rec IN get_carrier (dealer_rec.site_id, l_amigo_yn)
      LOOP
--
         DBMS_OUTPUT.put_line ( 'dealer_rec.x_technology        :' ||
         dealer_rec.x_technology );
         DBMS_OUTPUT.put_line ( 'carrier_rec.X_ACT_ANALOG       :' ||
         carrier_rec.x_act_analog );
         DBMS_OUTPUT.put_line ( 'carrier_rec.X_REACT_ANALOG     :' ||
         carrier_rec.x_react_analog );
         DBMS_OUTPUT.put_line ( 'carrier_rec.X_ACT_TECHNOLOGY   :' ||
         carrier_rec.pref_technology
         --carrier_rec.x_act_technology
         );
         DBMS_OUTPUT.put_line ( 'carrier_rec.X_REACT_TECHNOLOGY :' ||
         carrier_rec.pref_technology
         --carrier_rec.x_react_technology
         );
         DBMS_OUTPUT.put_line ( 'carrier_rec.x_carrier_id       :' || TO_CHAR (
         carrier_rec.x_carrier_id) );
         DBMS_OUTPUT.put_line ( 'carrier_rec.x_frequency        :' ||
         carrier_rec.x_frequency );
         DBMS_OUTPUT.put_line ( 'global_phone_frequency         :' ||
         global_phone_frequency );
         --
         IF ( react_curs%FOUND
         AND dealer_rec.x_technology = carrier_rec.pref_technology --carrier_rec.x_act_technology
         AND carrier_rec.ca_act_technology = 'Yes') -- 11/14/03 Vadapa
         OR ( react_curs%FOUND
         AND dealer_rec.x_technology = 'ANALOG'
         AND carrier_rec.x_act_analog = 1)
         OR ( react_curs%NOTFOUND
         AND dealer_rec.x_technology = 'ANALOG'
         AND carrier_rec.x_react_analog = 1)
         OR ( react_curs%NOTFOUND
         AND dealer_rec.x_technology = carrier_rec.pref_technology --carrier_rec.x_react_technology
         AND carrier_rec.ca_react_technology = 'Yes') -- 11/14/03
         THEN
            carrier_cnt := carrier_cnt + 1;
            carrier_array (carrier_cnt) := carrier_rec.objid;
            DBMS_OUTPUT.put_line ( 'carrier_rec.x_carrier_id :' || TO_CHAR (
            carrier_rec.x_carrier_id) );
         END IF;
      END LOOP;
      --04/07/04 Changes
      FOR carrier_rec IN get_carrier (dealer_rec.site_id, l_amigo_yn)
      LOOP
--04/07/04 Changes
         IF ( react_curs%FOUND
         AND dealer_rec.x_technology != 'ANALOG'
         AND dealer_rec.x_technology = carrier_rec.pref_technology ----04/07/04 Changes
         AND carrier_rec.x_act_analog = 1
         AND ( carrier_rec.ca_act_technology
         IS
         NULL
         OR carrier_rec.ca_act_technology = 'No') --11/14/03 Vadapa
         AND ( carrier_rec.ca_react_technology
         IS
         NULL
         OR carrier_rec.ca_react_technology = 'No')) --11/14/03 Vadapa
         OR ( react_curs%NOTFOUND
         AND dealer_rec.x_technology != 'ANALOG'
         AND dealer_rec.x_technology = carrier_rec.pref_technology ----04/07/04 Changes
         AND carrier_rec.x_react_analog = 1
         AND ( carrier_rec.ca_react_technology
         IS
         NULL
         OR carrier_rec.ca_react_technology = 'No') --11/14/03 Vadapa
         AND ( carrier_rec.ca_act_technology
         IS
         NULL
         OR carrier_rec.ca_act_technology = 'No')) --11/14/03 Vadapa
         THEN
            carrier_cnt := carrier_cnt + 1;
            carrier_array (carrier_cnt) := carrier_rec.objid;
            DBMS_OUTPUT.put_line ( 'carrier_rec.x_carrier_id :' || TO_CHAR (
            carrier_rec.x_carrier_id) );
         END IF;
--End 04/07/04 Changes
      END LOOP;
      --End 04/07/04 Changes
      IF (carrier_cnt2 = 0)
      AND (carrier_cnt = 0)
      THEN
--Amigo
         IF l_amigo_yn = 0
         THEN
            p_msg := 'No carrier found for technology.';
         ELSIF l_amigo_yn = 1
         THEN
            p_msg := 'NO AMIGO';
         END IF;
         --End Amigo
         global_carr_found_flag := 0;
      ELSE
--
         --VAdapa on 011002 Modified the message as per the change request # CR 0130 and added a check flag
         IF p_language = 'English'
         THEN
--CR3527 Start
            --             p_msg :=
            --             'lines temporarily not available for the zip code you provided. Please call us back within 24-48 hours. sorry for the inconvenience.'
            --             ;
            p_msg :=
            'AGENT:  There are no lines available for this zip code.  Please advise the customer to call back in 24-48 hours.'
            ;
--CR3527 End
         ELSE
            p_msg :=
            'Las lmneas no estan disponibles temporalmente para el area que usted desea. Por favor llamenos en 24 a 48 horas. '
            || 'Pedimos una disculpa por las molestias ocasionadas';
         END IF;
         global_carr_found_flag := 1;
--
      END IF;
      ---------------------------------------------------------------
      FOR i IN 1 .. carrier_cnt2
      LOOP
         DBMS_OUTPUT.put_line ( 'pre carrier_array2(' || TO_CHAR (i) || '):' ||
         TO_CHAR (carrier_array2 (i)) );
      END LOOP;
      ---------------------------------------------------------------
      OPEN react_cingular;
      FETCH react_cingular
      INTO react_cingular_rec;
      DBMS_OUTPUT.put_line ( 'found cingular fcc: ' || react_cingular_rec.market_id
      );
      IF react_curs%NOTFOUND
      AND dealer_rec.x_technology = 'ANALOG'
      THEN
         IF dealer_rec.part_good_flag = 6
         AND carrier_cnt2 > 0
         THEN
            carrier_cnt3 := 0;
            FOR i IN 1 .. carrier_cnt2
            LOOP
               OPEN get_carrier_group (carrier_array2 (i));
               FETCH get_carrier_group
               INTO carrier_group_rec;
               IF carrier_group_rec.x_carrier_group_id != 7
               OR react_cingular%FOUND
               THEN
                  carrier_cnt3 := carrier_cnt3 + 1;
                  carrier_array3 (carrier_cnt3) := carrier_array2 (i);
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:'
               || TO_CHAR (carrier_group_rec.x_carrier_group_id) );
               CLOSE get_carrier_group;
            END LOOP;
         ELSIF dealer_rec.part_good_flag = 7
         AND carrier_cnt2 > 0
         THEN
            carrier_cnt3 := 0;
            FOR i IN 1 .. carrier_cnt2
            LOOP
               OPEN get_carrier_group (carrier_array2 (i));
               FETCH get_carrier_group
               INTO carrier_group_rec;
               IF carrier_group_rec.x_carrier_group_id != 6
               OR react_cingular%FOUND
               THEN
                  carrier_cnt3 := carrier_cnt3 + 1;
                  carrier_array3 (carrier_cnt3) := carrier_array2 (i);
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:'
               || TO_CHAR (carrier_group_rec.x_carrier_group_id) );
               CLOSE get_carrier_group;
            END LOOP;
         ELSIF carrier_cnt2 > 0
         AND dealer_rec.part_good_flag NOT IN (7, 6)
         THEN
            carrier_cnt3 := 0;
            FOR i IN 1 .. carrier_cnt2
            LOOP
               OPEN get_carrier_group (carrier_array2 (i));
               FETCH get_carrier_group
               INTO carrier_group_rec;
               DBMS_OUTPUT.put_line ( TO_CHAR (carrier_array2 (i)) || ':' ||
               TO_CHAR (carrier_group_rec.x_carrier_group_id) );
               IF carrier_group_rec.x_carrier_group_id NOT IN (6, 7)
               OR react_cingular%FOUND
               THEN
                  carrier_cnt3 := carrier_cnt3 + 1;
                  carrier_array3 (carrier_cnt3) := carrier_array2 (i);
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:'
               || TO_CHAR (carrier_group_rec.x_carrier_group_id) );
               CLOSE get_carrier_group;
            END LOOP;
         END IF;
         IF carrier_cnt2 > 0
         THEN
            carrier_cnt2 := carrier_cnt3;
            FOR i IN 1 .. carrier_cnt3
            LOOP
               carrier_array2 (i) := carrier_array3 (i);
            END LOOP;
         END IF;
      END IF;
      ---------------------------------------------------------------
      FOR i IN 1 .. carrier_cnt
      LOOP
         DBMS_OUTPUT.put_line ( 'pre carrier_array(' || TO_CHAR (i) || '):' ||
         TO_CHAR (carrier_array (i)) );
      END LOOP;
      ---------------------------------------------------------------
      IF react_curs%NOTFOUND
      AND dealer_rec.x_technology = 'ANALOG'
      THEN
         IF dealer_rec.part_good_flag = 6
         AND carrier_cnt > 0
         THEN
            carrier_cnt3 := 0;
            FOR i IN 1 .. carrier_cnt
            LOOP
               OPEN get_carrier_group (carrier_array (i));
               FETCH get_carrier_group
               INTO carrier_group_rec;
               IF carrier_group_rec.x_carrier_group_id != 7
               OR react_cingular%FOUND
               THEN
                  carrier_cnt3 := carrier_cnt3 + 1;
                  carrier_array3 (carrier_cnt3) := carrier_array (i);
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:'
               || TO_CHAR (carrier_group_rec.x_carrier_group_id) );
               CLOSE get_carrier_group;
            END LOOP;
         ELSIF dealer_rec.part_good_flag = 7
         AND carrier_cnt > 0
         THEN
            carrier_cnt3 := 0;
            FOR i IN 1 .. carrier_cnt
            LOOP
               OPEN get_carrier_group (carrier_array (i));
               FETCH get_carrier_group
               INTO carrier_group_rec;
               IF carrier_group_rec.x_carrier_group_id != 6
               OR react_cingular%FOUND
               THEN
                  carrier_cnt3 := carrier_cnt3 + 1;
                  carrier_array3 (carrier_cnt3) := carrier_array (i);
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:'
               || TO_CHAR (carrier_group_rec.x_carrier_group_id) );
               CLOSE get_carrier_group;
            END LOOP;
         ELSIF carrier_cnt2 > 0
         AND dealer_rec.part_good_flag NOT IN (7, 6)
         THEN
            carrier_cnt3 := 0;
            FOR i IN 1 .. carrier_cnt
            LOOP
               OPEN get_carrier_group (carrier_array (i));
               FETCH get_carrier_group
               INTO carrier_group_rec;
               IF carrier_group_rec.x_carrier_group_id NOT IN (6, 7)
               OR react_cingular%FOUND
               THEN
                  carrier_cnt3 := carrier_cnt3 + 1;
                  carrier_array3 (carrier_cnt3) := carrier_array (i);
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:'
               || TO_CHAR (carrier_group_rec.x_carrier_group_id) );
               CLOSE get_carrier_group;
            END LOOP;
         END IF;
         IF carrier_cnt > 0
         THEN
            carrier_cnt := carrier_cnt3;
            FOR i IN 1 .. carrier_cnt3
            LOOP
               carrier_array (i) := carrier_array3 (i);
            END LOOP;
         END IF;
      END IF;
      CLOSE react_cingular;
      CLOSE react_curs;
      ---------------------------------------------------------------
      IF (carrier_cnt2 = 0)
      AND (carrier_cnt = 0)
      AND global_carr_found_flag = 1
      THEN
         p_msg := 'NO REACT';
      END IF;
      ---------------------------------------------------------------
      --**************** New Prefererce Logic
      IF carrier_cnt2 > 1
      THEN
         new_carrier_cnt2 := 0;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            FOR j IN 1 .. carrier_cnt2
            LOOP
               DBMS_OUTPUT.put_line ( 'carrier_array2(' || j || '):' ||
               carrier_array2 (j) );
               DBMS_OUTPUT.put_line ('i:' || TO_CHAR (i));
               IF global_technology = 'ANALOG'
               THEN
                  OPEN check_analog_order (carrier_array2 (j), TO_CHAR (i));
                  FETCH check_analog_order
                  INTO analog_order_rec;
                  IF check_analog_order%FOUND
                  THEN
                     DBMS_OUTPUT.put_line ('analog:found');
                     new_carrier_cnt2 := new_carrier_cnt2 + 1;
                     carrier_array2 (carrier_cnt2 + 1) := carrier_array2 (
                     new_carrier_cnt2);
                     carrier_array2 (new_carrier_cnt2) := carrier_array2 (j);
                     carrier_array2 (j) := carrier_array2 (carrier_cnt2 + 1);
                  END IF;
                  CLOSE check_analog_order;
               ELSE
                  OPEN check_digital_order (carrier_array2 (j), TO_CHAR (i));
                  FETCH check_digital_order
                  INTO digital_order_rec;
                  IF check_digital_order%FOUND
                  THEN
                     DBMS_OUTPUT.put_line ('digital:found');
                     new_carrier_cnt2 := new_carrier_cnt2 + 1;
                     carrier_array2 (carrier_cnt2 + 1) := carrier_array2 (
                     new_carrier_cnt2);
                     carrier_array2 (new_carrier_cnt2) := carrier_array2 (j);
                     carrier_array2 (j) := carrier_array2 (carrier_cnt2 + 1);
                  END IF;
                  CLOSE check_digital_order;
               END IF;
            END LOOP;
         END LOOP;
      END IF;
      global_carrier_frequency := 800; -- Reset global_carrier_frequency to default
      ---------------------------------------------------------------
      FOR i IN 1 .. carrier_cnt
      LOOP
         DBMS_OUTPUT.put_line ( 'post carrier_array(' || TO_CHAR (i) || '):' ||
         TO_CHAR (carrier_array (i)) );
      END LOOP;
      ---------------------------------------------------------------
      FOR i IN 1 .. carrier_cnt2
      LOOP
         DBMS_OUTPUT.put_line ( 'post carrier_array2(' || TO_CHAR (i) || '):'
         || TO_CHAR (carrier_array2 (i)) );
      END LOOP;
      ---------------------------------------------------------------
      DBMS_OUTPUT.put_line ('carrier_cnt:' || TO_CHAR (carrier_cnt));
      DBMS_OUTPUT.put_line ('x_technology:' || dealer_rec.x_technology);
      DBMS_OUTPUT.put_line ( 'dealer_rec.part_good_qty:' || TO_CHAR (dealer_rec.part_good_flag
      ) );
      ---------------------------------------------------------------
      DBMS_OUTPUT.put_line ('carrier_cnt2:' || TO_CHAR (carrier_cnt2));
      DBMS_OUTPUT.put_line ('x_technology:' || dealer_rec.x_technology);
      DBMS_OUTPUT.put_line ( 'dealer_rec.part_good_qty:' || TO_CHAR (dealer_rec.part_good_flag
      ) );
   END get_carriers; /*  END OF GET_CARRIERS PROCEDURE */
   /*****************************************************************************/
   ---------------------------------------------------------------
   FUNCTION prefered_county(
      p_choice IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
---------------------------------------------------------------
      CURSOR c1(
         c_carrier_objid IN NUMBER
      )
      IS
      --CR4371 Starts
      SELECT l.part_serial_no,
         l.x_part_inst_status,
         l.last_trans_time,
         l.x_insert_date
      FROM table_part_inst l, (
         SELECT DISTINCT lt.npa,
            lt.nxx
         FROM npanxx2carrierzones lt, carrierzones z
         WHERE lt.zone = z.zone
         AND lt.state = z.st
         AND z.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain = 'LINES' --03/25/03
      AND l.x_npa = tab1.npa
      AND l.x_nxx = tab1.nxx
      AND l.x_part_inst_status = '12'
      AND l.part_inst2carrier_mkt = c_carrier_objid UNION ALL
      SELECT l.part_serial_no,
         l.x_part_inst_status,
         l.last_trans_time,
         l.x_insert_date
      FROM table_part_inst l, (
         SELECT DISTINCT lt.npa,
            lt.nxx
         FROM npanxx2carrierzones lt, carrierzones z
         WHERE lt.zone = z.zone
         AND lt.state = z.st
         AND z.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain = 'LINES' --03/25/03
      AND l.x_npa = tab1.npa
      AND l.x_nxx = tab1.nxx
      AND l.x_part_inst_status = '11'
      AND l.part_inst2carrier_mkt = c_carrier_objid;
      /*
      SELECT l.part_serial_no,
         l.x_part_inst_status,
         l.last_trans_time,
         l.x_insert_date
      FROM table_part_inst l, (
         SELECT DISTINCT lt.npa,
            lt.nxx
         FROM npanxx2carrierzones lt, carrierzones z
         WHERE lt.zone = z.zone
         AND lt.state = z.st
         AND z.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain || '' = 'LINES' --03/25/03
      AND l.x_npa = tab1.npa
      AND l.x_nxx = tab1.nxx
      AND l.part_inst2carrier_mkt = c_carrier_objid;
      */
      --CR4371 Ends
      c1_rec c1%ROWTYPE;
---------------------------------------------------------------
   BEGIN
      IF p_choice = 'B1'
      THEN
         FOR i IN 1 .. carrier_cnt
         LOOP
            OPEN c1 (carrier_array (i));
            FETCH c1
            INTO c1_rec;
            IF c1%FOUND
            THEN
               global_part_serial_no := c1_rec.part_serial_no;
               CLOSE c1;
               update_c_choice (p_zip, p_esn, global_part_serial_no, 'B');
               IF p_language = 'English'
               THEN
                  p_msg :=
                  'B1 Choice: Preferred local, non-roaming, and non-long distance from Tracfone MIN.'
                  ;
               ELSE
                  p_msg :=
                  'Seleccion B1: Preferible para Local, sin Roaming, y sin larga distancia de TracFone MIN'
                  ;
               END IF;
               DBMS_OUTPUT.put_line ( p_zip || ':' || p_esn ||
               ':found line prefered B1:' || global_part_serial_no );
               update_line (global_part_serial_no);
               RETURN TRUE;
            END IF;
            CLOSE c1;
         END LOOP;
      ELSE
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN c1 (carrier_array2 (i));
            FETCH c1
            INTO c1_rec;
            IF c1%FOUND
            THEN
               global_part_serial_no := c1_rec.part_serial_no;
               CLOSE c1;
               update_c_choice (p_zip, p_esn, global_part_serial_no, 'B2');
               DBMS_OUTPUT.put_line ( p_zip || ':' || p_esn ||
               ':found line prefered B2:' || global_part_serial_no );
               IF p_language = 'English'
               THEN
                  p_msg :=
                  'B2 Choice: Local, non-roaming, and non-long distance from Tracfone MIN.'
                  ;
               ELSE
                  p_msg :=
                  'Seleccion B2: Local, sin Roaming, y sin larga distancia de TracFone MIN'
                  ;
               END IF;
               update_line (global_part_serial_no);
               RETURN TRUE;
            END IF;
            CLOSE c1;
         END LOOP;
      END IF;
      RETURN FALSE;
   END;
   ---------------------------------------------------------------
   FUNCTION prefered_sid
   RETURN BOOLEAN
   IS
      CURSOR c0(
         c_carrier_objid IN NUMBER
      )
      IS
      --CR4371 Starts
      SELECT l.part_serial_no
      FROM table_part_inst l, (
         SELECT DISTINCT z.nxx,
            z.npa
         FROM npanxx2carrierzones z, --npanxx2zones z,
         carrierzones a --pe_zip2areacode a
         WHERE a.county = z.county
         AND a.marketid = z.marketid
         AND a.st = z.state
         AND a.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain = 'LINES' --03/25/03
      AND l.part_inst2carrier_mkt = c_carrier_objid
      AND l.x_part_inst_status = '12'
      AND l.x_nxx = tab1.nxx
      AND l.x_npa = tab1.npa UNION ALL
      SELECT l.part_serial_no
      FROM table_part_inst l, (
         SELECT DISTINCT z.nxx,
            z.npa
         FROM npanxx2carrierzones z, --npanxx2zones z,
         carrierzones a --pe_zip2areacode a
         WHERE a.county = z.county
         AND a.marketid = z.marketid
         AND a.st = z.state
         AND a.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain = 'LINES' --03/25/03
      AND l.part_inst2carrier_mkt = c_carrier_objid
      AND l.x_part_inst_status = '11'
      AND l.x_nxx = tab1.nxx
      AND l.x_npa = tab1.npa ;
      /*
      SELECT l.part_serial_no
      FROM table_part_inst l, (
         SELECT DISTINCT z.nxx,
            z.npa
         FROM npanxx2carrierzones z, --npanxx2zones z,
         carrierzones a --pe_zip2areacode a
         WHERE a.county = z.county
         AND a.marketid = z.marketid
         AND a.st = z.state
         AND a.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain || '' = 'LINES' --03/25/03
      AND l.part_inst2carrier_mkt = c_carrier_objid
      AND l.x_nxx = tab1.nxx
      AND l.x_npa = tab1.npa;
      */
      --CR4371 Ends
      c0_rec c0%ROWTYPE;
      ---------------------------------------------------------------
      ---------------------------------------------------------------
      CURSOR c2(
         c_carrier_objid IN NUMBER
      )
      IS
      --CR4371 Starts
      SELECT part_serial_no
      FROM (
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '12', 1, '11', 2),
            DECODE ( l.x_part_inst_status, '12', l.last_trans_time, '11', l.x_insert_date
            )
         FROM table_part_inst l
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain || '' = 'LINES' --03/25/03
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status||'' = '12'
         AND ROWNUM < 101 UNION ALL
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '12', 1, '11', 2),
            DECODE ( l.x_part_inst_status, '12', l.last_trans_time, '11', l.x_insert_date
            )
         FROM table_part_inst l
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain || '' = 'LINES' --03/25/03
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status||'' = '11'
         AND ROWNUM < 101
         ORDER BY 2, 3);
      /*
      SELECT l.part_serial_no
      FROM table_part_inst l
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain || '' = 'LINES' --03/25/03
      AND l.part_inst2carrier_mkt = c_carrier_objid
      ORDER BY DECODE (l.x_part_inst_status, '12', 1, '11', 2), DECODE ( l.x_part_inst_status
      , '12', l.last_trans_time, '11', l.x_insert_date );
      */
      --CR4371 Ends
      c2_rec c2%ROWTYPE;
---------------------------------------------------------------
   BEGIN
-- No C or D choices should be made for 1900 MHz or greater phones, 2/10/03 D. Driscoll
      IF global_phone_frequency < 1900
      THEN
--Vadapa 06/18/02 Initialize the D choice flags with FALSE
         d_choice_found := FALSE;
         d2_choice_found := FALSE;
         --
         FOR i IN 1 .. carrier_cnt
         LOOP
            OPEN c0 (carrier_array (i));
            FETCH c0
            INTO c0_rec;
            IF c0%FOUND
            THEN
               global_part_serial_no := c0_rec.part_serial_no;
               CLOSE c0;
               update_c_choice (p_zip, p_esn, global_part_serial_no, 'PC1');
               IF p_language = 'English'
               THEN
                  p_msg :=
                  'C Choice: Alternate MIN issued outside of customer zipcode. We were unable to assign the best number in this area.'
                  ||
                  'The MIN is non-roaming, but may be long-distance. Ask customer to call back in 24-48 hrs'
                  ;
               ELSE
                  p_msg :=
                  'Seleccion C: MIN Alternativo para fuera del area del cliente. No nos fue posible asignar el mejor '
                  ||
                  ' nzmero en esta area. El MIN es no-Roaming pero puede ser de larga distancia. Pmdale al cliente llamar en 24 a 48 horas.'
                  ;
               END IF;
               DBMS_OUTPUT.put_line ( p_zip || ':' || p_esn ||
               ':found line prefered PC1:' || global_part_serial_no );
               update_line (global_part_serial_no);
               RETURN TRUE;
            END IF;
            CLOSE c0;
         END LOOP;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN c0 (carrier_array2 (i));
            FETCH c0
            INTO c0_rec;
            IF c0%FOUND
            THEN
               global_part_serial_no := c0_rec.part_serial_no;
               CLOSE c0;
               update_c_choice (p_zip, p_esn, global_part_serial_no, 'PC2');
               IF p_language = 'English'
               THEN
                  p_msg :=
                  'C Choice: Alternate MIN issued outside of customer zipcode. We were unable to assign the best number in this area.'
                  ||
                  'The MIN is non-roaming, but may be long-distance. Ask customer to call back in 24-48 hrs'
                  ;
               ELSE
                  p_msg :=
                  'Seleccion C: MIN Alternativo para fuera del area del cliente. No nos fue posible asignar el mejor '
                  ||
                  ' nzmero en esta area. El MIN es no-Roaming pero puede ser de larga distancia. Pmdale al cliente llamar en 24 a 48 horas.'
                  ;
               END IF;
               DBMS_OUTPUT.put_line ( p_zip || ':' || p_esn ||
               ':found line prefered PC2:' || global_part_serial_no );
               update_line (global_part_serial_no);
               RETURN TRUE;
            END IF;
            CLOSE c0;
         END LOOP;
         FOR i IN 1 .. carrier_cnt
         LOOP
            OPEN c2 (carrier_array (i));
            FETCH c2
            INTO c2_rec;
            IF c2%FOUND
            THEN
               global_part_serial_no := c2_rec.part_serial_no;
               CLOSE c2;
               --
               --Vadapa 06/18/02 Add logic to not to reserve line for 'D' choice, but update the report table
               d_choice_found := TRUE;
               IF p_language = 'English'
               THEN
--CR3527 Start
                  --                   p_msg :=
                  --                   'D Choice: lines temporarily not available for the zip code you provided. Please call us back within 24-48 hours. sorry for the inconvenience.'
                  --                   ;
                  p_msg :=
                  'AGENT:  There are no lines available for this zip code.  Please advise the customer to call back in 24-48 hours.'
                  ;
--CR3527 End
               ELSE
                  p_msg :=
                  'Seleccion D: Las lmneas no estan disponibles temporalmente para el area que usted desea. Por favor llamenos en 24 a 48 horas. '
                  || 'Pedimos una disculpa por las molestias ocasionadas';
               END IF;
               DBMS_OUTPUT.put_line ( p_zip || ' : ' || p_esn ||
               ' :found line prefered D1 but not reserved: ' ||
               global_part_serial_no );
               RETURN FALSE;
--Vadapa 06/18/02 changes end
            END IF;
            CLOSE c2;
         END LOOP;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN c2 (carrier_array2 (i));
            FETCH c2
            INTO c2_rec;
            IF c2%FOUND
            THEN
               global_part_serial_no := c2_rec.part_serial_no;
               CLOSE c2;
               --Vadapa 06/18/02 Add logic to not to reserve line for 'D' choice, but update the report table
               d2_choice_found := TRUE;
               IF p_language = 'English'
               THEN
--CR3527 Start
                  --                   p_msg :=
                  --                   'D Choice: lines temporarily not available for the zip code you provided. Please call us back within 24-48 hours. sorry for the inconvenience.'
                  --                   ;
                  p_msg :=
                  'AGENT:  There are no lines available for this zip code.  Please advise the customer to call back in 24-48 hours.'
                  ;
--CR3527 End
               ELSE
                  p_msg :=
                  'Seleccion D: Las lmneas no estan disponibles temporalmente para el area que usted desea. Por favor llamenos en 24 a 48 horas. '
                  || 'Pedimos una disculpa por las molestias ocasionadas';
               END IF;
               DBMS_OUTPUT.put_line ( p_zip || ' : ' || p_esn ||
               ' :found line prefered D2 but not reserved: ' ||
               global_part_serial_no );
               RETURN FALSE;
--VAdapa 06/18/02 changes end
            END IF;
            CLOSE c2;
         END LOOP;
      END IF;
      RETURN FALSE;
   END;
   /**** START Gsm new procedures ***/
   /*****************************************************************************/
   /* Name: get_gsm_dealer_prc                                                  */
   /* Description:                                                              */
   /*****************************************************************************/
   PROCEDURE get_gsm_dealer_prc
   IS
/* Cursor to get the dealer associated with the esn */
      CURSOR get_dealer_cur
      IS
      SELECT s.site_id,
         pn.x_technology,
         NVL (pi.part_good_qty, 0) part_good_flag,
         pn.x_restricted_use
      FROM table_part_num pn, table_mod_level ml, table_site s, table_inv_role
      ir, table_inv_bin ib, table_part_inst pi
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND s.objid = ir.inv_role2site
      AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
      AND ib.objid = pi.part_inst2inv_bin
      AND pi.x_domain = 'PHONES'
      AND pi.part_serial_no = global_esn;
      get_dealer_rec get_dealer_cur%ROWTYPE;
/** main of get_gsm_dealer**/
   BEGIN
      OPEN get_dealer_cur;
      FETCH get_dealer_cur
      INTO get_dealer_rec;
      global_dealer_id := get_dealer_rec.site_id;
      global_technology := get_dealer_rec.x_technology;
      global_restricted_use := get_dealer_rec.x_restricted_use; --Amigo
      global_part_good_flag := get_dealer_rec.part_good_flag; --new
      CLOSE get_dealer_cur;
      DBMS_OUTPUT.put_line ('dealer_id :' || get_dealer_rec.site_id);
   END; /* of get_gsm_dealer_prc */
   /*****************************************************************************/
   /* Name: get_phone_frequency_prc                                             */
   /* Description:                                                              */
   /*****************************************************************************/
   PROCEDURE get_phone_frequency_prc
   IS
      CURSOR phone_frequency_cur
      IS
      SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency,
         MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2
      FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num
      pn, table_mod_level ml, table_part_inst pi
      WHERE pf.x_frequency2part_num = f.objid
      AND pn.objid = pf.part_num2x_frequency
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = global_esn
      AND pi.x_domain = 'PHONES';
/** main of get_phone_frequency_prc **/
   BEGIN

      /** get phone frequency info and set to global variable **/
      global_phone_frequency := 0;
      global_phone_frequency2 := 0;
      OPEN phone_frequency_cur;
      FETCH phone_frequency_cur
      INTO global_phone_frequency, global_phone_frequency2;
      CLOSE phone_frequency_cur;
   END; /* of get_phone_frequency_prc */
   /*****************************************************************************/
   /* Name: is_a_react_fun                                                      */
   /* Description:                                                              */
   /*****************************************************************************/
   FUNCTION is_a_react_fun
   RETURN BOOLEAN
   IS
      CURSOR is_new_cur
      IS
      SELECT 'X' col1
      FROM table_part_inst
      WHERE part_serial_no = p_esn
      AND x_domain = 'PHONES'
      --      AND x_part_inst_status || '' = '50';
      AND x_part_inst_status || '' IN ('50', '150');
      is_new_rec is_new_cur%ROWTYPE;
      l_return_value BOOLEAN := FALSE;
   BEGIN
/* of is_a_react_fun */
      OPEN is_new_cur;
      FETCH is_new_cur
      INTO is_new_rec; --CR2672 Fix
      IF is_new_cur%FOUND
      THEN
         l_return_value := FALSE;
/* is a new phone **/
      ELSE
         l_return_value := TRUE;
/* is a react **/
      END IF;
      CLOSE is_new_cur;
      RETURN l_return_value;
   END; /* of is_a_react_fun */
   /*****************************************************************************/
   /* Name: get_default_carrier_prc                                             */
   /* Description:                                                              */
   /*****************************************************************************/
   PROCEDURE get_default_carrier_prc(
      technology_ip IN VARCHAR2
   )--(amigo_flag_pi IN NUMBER)
   IS
      CURSOR get_carrier2
      IS --Amigo
      SELECT ca.objid,
         ca.x_carrier_id,
         ca.x_react_analog,
         ca.x_react_technology ca_react_technology,
         ca.x_act_analog,
         ca.x_act_technology ca_act_technology,
         pt.x_technology pref_technology,
         f.x_frequency,
         pt.x_technology
      FROM table_x_frequency f, mtm_x_frequency2_x_pref_tech1 f2pt,
      table_x_pref_tech pt, table_x_carrier ca, table_x_carrierdealer c, (
         SELECT DISTINCT b.carrier_id
         FROM npanxx2carrierzones b, carrierzones a
         WHERE b.frequency1 IN ('1900', '800')
         AND ( b.tdma_tech = technology_ip
         OR b.cdma_tech = technology_ip
         OR b.gsm_tech = technology_ip)
         AND b.zone = a.zone
         AND b.state = a.st
         AND a.zip = global_zip)tab1
      WHERE f.objid = f2pt.x_frequency2x_pref_tech
      AND f.x_frequency IN (global_phone_frequency, global_phone_frequency2) -- Mot Digital
      AND f2pt.x_pref_tech2x_frequency = pt.objid
      AND pt.x_pref_tech2x_carrier = ca.objid
      AND pt.x_technology = technology_ip
      AND ca.x_carrier_id = c.x_carrier_id
      AND ca.x_status = 'ACTIVE'
      AND c.x_dealer_id = 'DEFAULT'
      AND c.x_carrier_id = tab1.carrier_id
      ORDER BY f.x_frequency DESC;
   BEGIN
      FOR carrier_rec2 IN get_carrier2
      LOOP
--
         --      DBMS_OUTPUT.put_line ('dealer_rec.x_technology        :' || dealer_rec.x_technology);
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_ACT_ANALOG      :' ||
         carrier_rec2.x_act_analog );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_REACT_ANALOG    :' ||
         carrier_rec2.x_react_analog );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_ACT_TECHNOLOGY  :' ||
         carrier_rec2.pref_technology
         --carrier_rec2.x_act_technology
         );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.X_REACT_TECHNOLOGY:' ||
         carrier_rec2.pref_technology
         --carrier_rec2.x_react_technology
         );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.x_carrier_id      :' || TO_CHAR (
         carrier_rec2.x_carrier_id) );
         DBMS_OUTPUT.put_line ( 'carrier_rec2.x_frequency       :' ||
         carrier_rec2.x_frequency );
         DBMS_OUTPUT.put_line ( 'global_phone_frequency         :' ||
         global_phone_frequency );
         carrier_cnt2 := carrier_cnt2 + 1;
         carrier_array2 (carrier_cnt2) := carrier_rec2.objid;
         DBMS_OUTPUT.put_line ( 'carrier_rec2.x_carrier_id :' || TO_CHAR (
         carrier_rec2.x_carrier_id) );
         IF carrier_rec2.x_frequency = 1900
         THEN
            global_carrier_frequency := 1900;
         END IF;
      END LOOP;
      /** Debugging **/
      FOR i IN 1 .. carrier_cnt2
      LOOP
         DBMS_OUTPUT.put_line ( 'pre carrier_array2(' || TO_CHAR (i) || '):' ||
         TO_CHAR (carrier_array2 (i)) );
      END LOOP;
   END;
   /*****************************************************************************/
   /* Name: get_carrier_group_prc                                               */
   /* Description:                                                              */
   /*****************************************************************************/
   PROCEDURE get_carrier_group_prc
   IS
      CURSOR get_carrier_group(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT TO_NUMBER (p.x_parent_id) x_carrier_group_id
      FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier c
      WHERE p.objid = cg.x_carrier_group2x_parent
      AND UPPER (p.x_status) = 'ACTIVE'
      AND cg.objid = c.carrier2carrier_group
      AND cg.x_status = 'ACTIVE'
      AND c.objid = c_carrier_objid;
      carrier_group_rec get_carrier_group%ROWTYPE;
   BEGIN
/* Main */
      IF global_part_good_flag = 6
      THEN
-- AND carrier_cnt2 > 0 THEN
         carrier_cnt3 := 0;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN get_carrier_group (carrier_array2 (i));
            FETCH get_carrier_group
            INTO carrier_group_rec;
            IF carrier_group_rec.x_carrier_group_id != 7
            THEN
-- OR react_cingular%FOUND THEN
               carrier_cnt3 := carrier_cnt3 + 1;
               carrier_array3 (carrier_cnt3) := carrier_array2 (i);
            END IF;
            DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
            global_part_good_flag );
            DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:' ||
            TO_CHAR (carrier_group_rec.x_carrier_group_id) );
            CLOSE get_carrier_group;
         END LOOP;
      ELSIF global_part_good_flag = 7
      THEN
--AND carrier_cnt2 > 0 THEN
         carrier_cnt3 := 0;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN get_carrier_group (carrier_array2 (i));
            FETCH get_carrier_group
            INTO carrier_group_rec;
            IF carrier_group_rec.x_carrier_group_id != 6
            THEN
--OR react_cingular%FOUND THEN
               carrier_cnt3 := carrier_cnt3 + 1;
               carrier_array3 (carrier_cnt3) := carrier_array2 (i);
            END IF;
            DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
            global_part_good_flag );
            DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:' ||
            TO_CHAR (carrier_group_rec.x_carrier_group_id) );
            CLOSE get_carrier_group;
         END LOOP;
      ELSIF global_part_good_flag NOT IN (7, 6)
      THEN

         --carrier_cnt2 > 0 AND dealer_rec.part_good_flag NOT IN (7,6) THEN
         carrier_cnt3 := 0;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN get_carrier_group (carrier_array2 (i));
            FETCH get_carrier_group
            INTO carrier_group_rec;
            DBMS_OUTPUT.put_line ( TO_CHAR (carrier_array2 (i)) || ':' ||
            TO_CHAR (carrier_group_rec.x_carrier_group_id) );
            IF carrier_group_rec.x_carrier_group_id NOT IN (6, 7)
            THEN
-- OR react_cingular%FOUND THEN
               carrier_cnt3 := carrier_cnt3 + 1;
               carrier_array3 (carrier_cnt3) := carrier_array2 (i);
            END IF;
            DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
            global_part_good_flag );
            DBMS_OUTPUT.put_line ( '**carrier_group_rec.x_carrier_group_id:' ||
            TO_CHAR (carrier_group_rec.x_carrier_group_id) );
            CLOSE get_carrier_group;
         END LOOP;
      END IF;
      --IF carrier_cnt2 > 0 THEN
      carrier_cnt2 := carrier_cnt3;
      FOR i IN 1 .. carrier_cnt3
      LOOP
         carrier_array2 (i) := carrier_array3 (i);
      END LOOP;
      -- END IF;
      /* at this point I need to check if carrier count 2 has changed.. */
      IF (carrier_cnt2 = 0)
      AND global_carr_found_flag = 1
      THEN
         p_msg := 'NO REACT';
      END IF;
   END; /* of get_carrier_group_prc */
   /*****************************************************************************/
   /* Name: get_pref_prc                                                        */
   /* Description:                                                              */
   /*****************************************************************************/
   PROCEDURE get_pref_prc
   IS
      CURSOR pref(
         c_carrier_objid1 IN NUMBER,
         c_carrier_objid2 IN NUMBER
      )
      IS
      SELECT 'X'
      FROM table_x_carrierpreference c, table_x_carrier ca1, table_x_carrier
      ca2
      WHERE c.x_ca_id_pref = TO_CHAR (ca1.x_carrier_id)
      AND c.x_ca_id_2 = TO_CHAR (ca2.x_carrier_id)
      AND ca1.objid = c_carrier_objid1
      AND ca2.objid = c_carrier_objid2;
      pref_rec pref%ROWTYPE;
   BEGIN
      IF carrier_cnt2 > 1
      THEN
         new_carrier_cnt2 := 0;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            FOR j IN 1 .. carrier_cnt2
            LOOP
               DBMS_OUTPUT.put_line ( 'carrier_array2(' || j || '):' ||
               carrier_array2 (j) );
               DBMS_OUTPUT.put_line ('i:' || TO_CHAR (i));
               OPEN check_digital_order (carrier_array2 (j), TO_CHAR (i));
               FETCH check_digital_order
               INTO digital_order_rec;
               IF check_digital_order%FOUND
               THEN
                  DBMS_OUTPUT.put_line ('digital:found');
                  new_carrier_cnt2 := new_carrier_cnt2 + 1;
                  carrier_array2 (carrier_cnt2 + 1) := carrier_array2 (
                  new_carrier_cnt2);
                  carrier_array2 (new_carrier_cnt2) := carrier_array2 (j);
                  carrier_array2 (j) := carrier_array2 (carrier_cnt2 + 1);
               END IF;
               CLOSE check_digital_order;
            END LOOP;
         END LOOP;
      END IF;
      -- global_carrier_frequency := 800;  -- Reset global_carrier_frequency to default
      FOR i IN 1 .. carrier_cnt2
      LOOP
         DBMS_OUTPUT.put_line ( 'post carrier_array2(' || TO_CHAR (i) || '):'
         || TO_CHAR (carrier_array2 (i)) );
      END LOOP;
      DBMS_OUTPUT.put_line ('carrier_cnt2:' || TO_CHAR (carrier_cnt2));
      DBMS_OUTPUT.put_line ('x_technology:' || global_technology);
      DBMS_OUTPUT.put_line ( 'dealer_rec.part_good_qty:' || TO_CHAR (
      global_part_good_flag) );
   END; /* get_pref_prc */
   /*****************************************************************************/
   /* Name: prefered_county_fun                                                 */
   /* Description:                                                              */
   /*****************************************************************************/
   FUNCTION prefered_county_fun
   RETURN BOOLEAN
   IS
      CURSOR c1(
         c_carrier_objid IN NUMBER
      )
      IS
      --CR4371 Starts
      SELECT part_serial_no
      FROM (
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE ( l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l, (
            SELECT DISTINCT lt.npa,
               lt.nxx
            FROM npanxx2carrierzones lt, carrierzones z --pe_zip2rate_usa z
            WHERE lt.zone = z.zone
            AND lt.state = z.st
            AND lt.gsm_tech = global_technology
            AND z.zip = global_zip)tab1
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain = 'LINES' --03/25/03
         AND l.x_npa = tab1.npa
         AND l.x_nxx = tab1.nxx
         AND l.x_part_inst_status = '12'
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND ROWNUM < 101 UNION ALL
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE ( l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l, (
            SELECT DISTINCT lt.npa,
               lt.nxx
            FROM npanxx2carrierzones lt, carrierzones z --pe_zip2rate_usa z
            WHERE lt.zone = z.zone
            AND lt.state = z.st
            AND lt.gsm_tech = global_technology
            AND z.zip = global_zip)tab1
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain = 'LINES' --03/25/03
         AND l.x_npa = tab1.npa
         AND l.x_nxx = tab1.nxx
         AND l.x_part_inst_status = '11'
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND ROWNUM < 101
         ORDER BY 2, 3);
      --CR3190 Starts
      /*
      SELECT l.part_serial_no
      FROM table_part_inst l, (
         SELECT DISTINCT lt.npa,
            lt.nxx
         FROM npanxx2carrierzones lt, carrierzones z --pe_zip2rate_usa z
         WHERE lt.zone = z.zone
         AND lt.state = z.st
         AND lt.gsm_tech = global_technology
         AND z.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain || '' = 'LINES' --03/25/03
      AND l.x_npa = tab1.npa
      AND l.x_nxx = tab1.nxx
      AND l.part_inst2carrier_mkt = c_carrier_objid
      --CR3190 Starts
      ORDER BY DECODE (l.x_part_inst_status, '11', 1, '12', 2), DECODE ( l.x_part_inst_status
      , '11', l.x_insert_date, '12', l.last_trans_time);
      */
      --       ORDER BY DECODE (l.x_part_inst_status, '12', 1, '11', 2), DECODE ( l.x_part_inst_status
      --       , '12', l.last_trans_time, '11', l.x_insert_date );
      --CR3910 Ends
      --CR4371 Ends
      c1_rec c1%ROWTYPE;
   BEGIN
      FOR i IN 1 .. carrier_cnt2
      LOOP
         OPEN c1 (carrier_array2 (i));
         FETCH c1
         INTO c1_rec;
         IF c1%FOUND
         THEN
            global_part_serial_no := c1_rec.part_serial_no;
            CLOSE c1;
            update_c_choice (p_zip, p_esn, global_part_serial_no, 'GSM');
            DBMS_OUTPUT.put_line ( p_zip || ':' || p_esn ||
            ':found line prefered B2:' || global_part_serial_no );
            IF p_language = 'English'
            THEN
               IF global_restricted_use = 0
               THEN
--CR3190
                  p_msg :=
                  'GSM Choice: Local, non-roaming, and non-long distance from Tracfone MIN.'
                  ;
               ELSIF global_restricted_use = 3
               THEN
--CR3190
                  p_msg :=
                  'GSM Choice: Local, non-roaming, and non-long distance from NET10 MIN.'
                  ;
               END IF;
--End CR3190
            ELSE
               IF global_restricted_use = 0
               THEN
--CR3190
                  p_msg :=
                  'Seleccion GSM: Local, sin Roaming, y sin larga distancia de TracFone MIN'
                  ;
               ELSIF global_restricted_use = 3
               THEN
--CR3190
                  p_msg :=
                  'Seleccion GSM: Local, sin Roaming, y sin larga distancia de NET10 MIN'
                  ;
               END IF;
--End CR3190
            END IF;
            update_line (global_part_serial_no);
            RETURN TRUE;
/* return */
         END IF;
         CLOSE c1;
      END LOOP;
      RETURN FALSE;
/* return */
   END; /* of prefered_county_fun */
   /*****************************************************************************/
   /* Name: prefered_sid_fun                                                    */
   /* Description:                                                              */
   /*****************************************************************************/
   FUNCTION prefered_sid_fun
   RETURN BOOLEAN
   IS
      CURSOR c0(
         c_carrier_objid IN NUMBER
      )
      IS
      --CR4371 Starts
      SELECT part_serial_no
      FROM (
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE ( l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l, (
            SELECT DISTINCT z.npa,
               z.nxx
            FROM npanxx2carrierzones z, --npanxx2zones z,
            carrierzones a --pe_zip2areacode a
            WHERE z.county = a.county
            AND z.marketid = a.marketid
            AND z.state = a.st
            AND z.gsm_tech = global_technology
            AND a.zip = global_zip)tab1
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain = 'LINES' --03/25/03
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status = '12'
         AND l.x_nxx = tab1.nxx
         AND l.x_npa = tab1.npa
         AND ROWNUM < 101 UNION ALL
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE ( l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l, (
            SELECT DISTINCT z.npa,
               z.nxx
            FROM npanxx2carrierzones z, --npanxx2zones z,
            carrierzones a --pe_zip2areacode a
            WHERE z.county = a.county
            AND z.marketid = a.marketid
            AND z.state = a.st
            AND z.gsm_tech = global_technology
            AND a.zip = global_zip)tab1
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain = 'LINES' --03/25/03
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status = '11'
         AND l.x_nxx = tab1.nxx
         AND l.x_npa = tab1.npa
         AND ROWNUM < 101
         ORDER BY 2, 3);
      /*
      SELECT l.part_serial_no
      FROM table_part_inst l, (
         SELECT DISTINCT z.npa,
            z.nxx
         FROM npanxx2carrierzones z, --npanxx2zones z,
         carrierzones a --pe_zip2areacode a
         WHERE z.county = a.county
         AND z.marketid = a.marketid
         AND z.state = a.st
         AND z.gsm_tech = global_technology
         AND a.zip = global_zip)tab1
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain || '' = 'LINES' --03/25/03
      AND l.part_inst2carrier_mkt = c_carrier_objid
      AND l.x_nxx = tab1.nxx
      AND l.x_npa = tab1.npa
      --CR3910 Starts
      ORDER BY DECODE (l.x_part_inst_status, '11', 1, '12', 2), DECODE ( l.x_part_inst_status
      , '11', l.x_insert_date, '12', l.last_trans_time );
      --        ORDER BY DECODE (l.x_part_inst_status, '12', 1, '11', 2), DECODE ( l.x_part_inst_status
      --        , '12', l.last_trans_time, '11', l.x_insert_date );
      */
      --CR3910 ends
      --CR4371 Ends
      c0_rec c0%ROWTYPE;
      ---------------------------------------------------------------
      ---------------------------------------------------------------
      CURSOR c2(
         c_carrier_objid IN NUMBER
      )
      IS
      --CR4371 Starts
      SELECT part_serial_no
      FROM (
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE ( l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain || '' = 'LINES' --03/25/03
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status||'' = '12'
         AND ROWNUM < 101 UNION ALL
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE ( l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l
         WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE)
         AND l.x_domain || '' = 'LINES' --03/25/03
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status||'' = '11'
         AND ROWNUM < 101
         ORDER BY 2, 3);
      /*
      SELECT l.part_serial_no
      FROM table_part_inst l
      WHERE DECODE ( l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE)
      , '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE)
      AND l.x_domain || '' = 'LINES' --03/25/03
      AND l.part_inst2carrier_mkt = c_carrier_objid
      --CR3910 Starts
      ORDER BY DECODE (l.x_part_inst_status, '11', 1, '12', 2), DECODE ( l.x_part_inst_status
      , '11', l.x_insert_date, '12', l.last_trans_time );
      --       ORDER BY DECODE (l.x_part_inst_status, '12', 1, '11', 2), DECODE ( l.x_part_inst_status
      --       , '12', l.last_trans_time, '11', l.x_insert_date );
      --CR3910 Ends
      */
      --CR4371 Ends
      c2_rec c2%ROWTYPE;
---------------------------------------------------------------
   BEGIN
-- No C or D choices should be made for 1900 MHz or greater phones, 2/10/03 D. Driscoll
      IF global_phone_frequency < 800
      THEN
--Vadapa 06/18/02 Initialize the D choice flags with FALSE
         d_choice_found := FALSE;
         d2_choice_found := FALSE;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN c0 (carrier_array2 (i));
            FETCH c0
            INTO c0_rec;
            IF c0%FOUND
            THEN
               global_part_serial_no := c0_rec.part_serial_no;
               CLOSE c0;
               update_c_choice (p_zip, p_esn, global_part_serial_no, 'GSM');
               IF p_language = 'English'
               THEN
                  p_msg :=
                  'GSM Choice: Alternate MIN issued outside of customer zipcode. We were unable to assign the best number in this area.'
                  ||
                  'The MIN is non-roaming, but may be long-distance. Ask customer to call back in 24-48 hrs'
                  ;
               ELSE
                  p_msg :=
                  'Seleccion GSM: MIN Alternativo para fuera del area del cliente. No nos fue posible asignar el mejor '
                  ||
                  ' nzmero en esta area. El MIN es no-Roaming pero puede ser de larga distancia. Pmdale al cliente llamar en 24 a 48 horas.'
                  ;
               END IF;
               DBMS_OUTPUT.put_line ( p_zip || ':' || p_esn ||
               ':found line prefered GSM:' || global_part_serial_no );
               update_line (global_part_serial_no);
               RETURN TRUE;
            END IF;
            CLOSE c0;
         END LOOP;
         FOR i IN 1 .. carrier_cnt2
         LOOP
            OPEN c2 (carrier_array2 (i));
            FETCH c2
            INTO c2_rec;
            IF c2%FOUND
            THEN
               global_part_serial_no := c2_rec.part_serial_no;
               CLOSE c2;
               --Vadapa 06/18/02 Add logic to not to reserve line for 'D' choice, but update the report table
               d2_choice_found := TRUE;
               IF p_language = 'English'
               THEN
--CR3527 Start
                  --                   p_msg :=
                  --                   'GSM Choice: lines temporarily not available for the zip code you provided. Please call us back within 24-48 hours. sorry for the inconvenience.'
                  --                   ;
                  p_msg :=
                  'AGENT:  There are no lines available for this zip code.  Please advise the customer to call back in 24-48 hours.'
                  ;
--CR3527 End
               ELSE
                  p_msg :=
                  'Seleccion GSM: Las lmneas no estan disponibles temporalmente para el area que usted desea. Por favor llamenos en 24 a 48 horas. '
                  || 'Pedimos una disculpa por las molestias ocasionadas';
               END IF;
               DBMS_OUTPUT.put_line ( p_zip || ' : ' || p_esn ||
               ' :found line prefered GSM but not reserved: ' ||
               global_part_serial_no );
               RETURN FALSE;
--VAdapa 06/18/02 changes end
            END IF;
            CLOSE c2;
         END LOOP;
      END IF;
      RETURN FALSE;
   END; /* of prefered sid fun */
   /****************************************************************************/
   /* Name: react_65_90_fun                                                     */
   /* Description:                                                              */
   /*****************************************************************************/
   FUNCTION react_65_90_fun(
      technology_ip IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      CURSOR get_carrier_rules_cur
      IS
      SELECT lines_pi.part_serial_no
      FROM table_x_carrier_rules car, table_x_carrier ca, table_x_pref_tech pt, ----11/14/03 Vadapa
      table_part_inst lines_pi, table_site_part sp, table_part_inst esn_pi
      WHERE esn_pi.part_serial_no = p_esn
      --CR3310 Start
      --            AND esn_pi.x_part_inst2site_part = sp.objid
      AND sp.objid = (
      SELECT MAX(objid)
      FROM table_site_part sp1
      WHERE part_status ||'' = 'Inactive'
      AND sp1.x_Service_id = esn_pi.part_serial_no)
      --CR3310 End
      AND sp.x_min = lines_pi.part_serial_no
      AND lines_pi.part_inst2carrier_mkt = ca.objid
      AND ca.carrier2rules = car.objid
      --11/14/03 Vadapa
      AND pt.x_pref_tech2x_carrier = ca.objid
      AND pt.x_technology = technology_ip
      AND ca.x_react_technology = 'Yes'
      --            AND ca.x_react_technology = technology_ip
      --11/14/03 Vadapa
      AND TRUNC (SYSDATE) >= TRUNC (sp.service_end_dt)
      AND TRUNC (SYSDATE) <
      --                   TRUNC (sp.service_end_dt + car.x_line_expire_days + 1); --CR2739
      TRUNC (sp.service_end_dt + car.x_gsm_grace_period + 1);
      get_carrier_rules_rec get_carrier_rules_cur%ROWTYPE;
      CURSOR get_same_zone_cur(
         ip_line IN VARCHAR2
      )
      IS
      SELECT DISTINCT a.zip,
         a.rate_cente,
         a.zone,
         a.county,
         a.st,
         b.npa,
         b.nxx
      FROM carrierzones a, npanxx2carrierzones b
      WHERE b.nxx = SUBSTR (ip_line, 4, 3)
      AND b.npa = SUBSTR (ip_line, 1, 3)
      AND a.st = b.state
      AND a.zone = b.zone
      AND a.zip = p_zip;
      get_same_zone_rec get_same_zone_cur%ROWTYPE;
      --CR3327-1 Starts
      CURSOR c_old_sim_info
      IS
      SELECT x_zipcode,
         x_iccid,
         service_end_dt last_deact_date
      FROM table_site_part sp
      WHERE objid = (
      SELECT MAX(objid)
      FROM table_site_part sp1
      WHERE sp1.x_service_id = global_esn
      AND part_status ||'' = 'Inactive');
      c_old_sim_info_rec c_old_sim_info%ROWTYPE;
      l_different_sim BOOLEAN := FALSE;
      l_prev_resv_line VARCHAR2(20);
      --CR3327-1 Ends
      l_return_value BOOLEAN := FALSE;
   BEGIN
--CR3327 -1 Starts
      DBMS_OUTPUT.put_line ('tech: ' || technology_ip);
      DBMS_OUTPUT.put_line ('esn: ' || p_esn);
      OPEN get_carrier_rules_cur;
      FETCH get_carrier_rules_cur
      INTO get_carrier_rules_rec;
      IF get_carrier_rules_rec.part_serial_no
      IS
      NOT NULL
      THEN
         l_prev_resv_line := get_carrier_rules_rec.part_serial_no;
      END IF;
      CLOSE get_carrier_rules_cur;
      OPEN c_old_sim_info;
      FETCH c_old_sim_info
      INTO c_old_sim_info_rec;
      IF c_old_sim_info%found
      THEN
         IF c_old_sim_info_rec.x_iccid <> p_sim
         THEN
            l_different_sim := TRUE;
         ELSE
            l_different_sim := FALSE;
         END IF;
      ELSE
         l_different_sim := FALSE;
      END IF;
      IF global_portin_line
      IS
      NULL
      THEN
         IF NOT l_different_sim --old sim and new sim are same, then run the same zone check for previous line
         THEN
            OPEN get_same_zone_cur (l_prev_resv_line);
            FETCH get_same_zone_cur
            INTO get_same_zone_rec;
            IF get_same_zone_rec.zone
            IS
            NOT NULL
            THEN
               l_return_value := TRUE;
            ELSE
               l_return_value := FALSE;
            END IF;
            CLOSE get_same_zone_cur;
         ELSE
--old sim and new sim are different, then run the same zone check for reserved line
            --CR3824 Starts
            IF p_upg_flag = 'Y'
            THEN
               l_return_value := TRUE;
            ELSE

               --CR3824 Ends
               OPEN get_same_zone_cur (global_part_serial_no);
               FETCH get_same_zone_cur
               INTO get_same_zone_rec;
               IF get_same_zone_rec.zone
               IS
               NOT NULL
               THEN
                  l_return_value := TRUE;
               ELSE
                  l_return_value := FALSE;
               END IF;
               CLOSE get_same_zone_cur;
            END IF;
--CR3824
         END IF;
      ELSE
         IF l_different_sim
         THEN
            l_return_value := TRUE;
         ELSE
            l_return_value := FALSE;
         END IF;
      END IF;
      RETURN l_return_value;
/*       DBMS_OUTPUT.put_line ('tech: ' || technology_ip);
      DBMS_OUTPUT.put_line ('esn: ' || p_esn);
      OPEN get_carrier_rules_cur;
      FETCH get_carrier_rules_cur
      INTO get_carrier_rules_rec;
      DBMS_OUTPUT.put_line ('line: ' || get_carrier_rules_rec.part_serial_no);
      IF get_carrier_rules_rec.part_serial_no
      IS
      NOT NULL
      THEN

         --  IF get_carrier_rules_cur%FOUND THEN
         --      FETCH get_carrier_rules_cur INTO get_carrier_rules_rec;
         OPEN get_same_zone_cur (get_carrier_rules_rec.part_serial_no);
         FETCH get_same_zone_cur
         INTO get_same_zone_rec;
         DBMS_OUTPUT.put_line ( 'npa ' || ':' || SUBSTR (get_carrier_rules_rec.part_serial_no
         , 1, 3) || ':' );
         DBMS_OUTPUT.put_line ( 'nxx ' || ':' || SUBSTR (get_carrier_rules_rec.part_serial_no
         , 4, 3) || ':' );
         DBMS_OUTPUT.put_line ('zone ' || get_same_zone_rec.zone);
         DBMS_OUTPUT.put_line ('zip ' || p_zip);
         IF get_same_zone_rec.zone
         IS
         NOT NULL
         THEN

            --   IF get_same_zone_cur%FOUND THEN
            DBMS_OUTPUT.put_line ('zone' || get_same_zone_rec.zone);
            l_return_value := TRUE;
         ELSE
            l_return_value := FALSE;
         END IF;
         CLOSE get_same_zone_cur;
      ELSE
         l_return_value := FALSE;
      END IF;
      CLOSE get_carrier_rules_cur;
      RETURN l_return_value;
   */
   --CR3327 -1 Ends
   END; /* end of react_65_90_fun */
   /***** END Gsm new procedures   ***/
   FUNCTION get_gsm_line_fun
   RETURN BOOLEAN
   IS
      CURSOR get_cell_num(
         c_esn IN VARCHAR2
      )
      IS
      SELECT lines.objid,
         lines.part_serial_no,
         lines.x_part_inst_status line_status,
         lines.x_port_in--CR3327-1
      FROM table_part_inst lines, table_part_inst phones
      WHERE lines.x_domain = 'LINES'
      AND lines.part_to_esn2part_inst = phones.objid
      --AND lines.x_part_inst_status IN ('37',  '39',  '73') --CR2620
      AND lines.x_part_inst_status IN ('37', '39', '73', '110') --CR2620
      AND phones.x_domain = 'PHONES'
      AND phones.part_serial_no = c_esn
      ORDER BY lines.last_trans_time DESC;
      get_cell_num_rec get_cell_num%ROWTYPE;
      --CR2620 Start
      CURSOR get_no_msid_line(
         c_min IN VARCHAR2
      )
      IS
      SELECT 1
      FROM table_x_parent cp, table_x_carrier_group cg, table_x_carrier ca,
      table_part_inst pimin
      WHERE pimin.part_inst2carrier_mkt = ca.objid
      AND ca.carrier2carrier_group = cg.objid
      AND cg.x_carrier_group2x_parent = cp.objid
      AND cp.x_no_msid = 1
      AND pimin.part_serial_no = c_min;
      get_no_msid_line_rec get_no_msid_line%ROWTYPE;
--CR2620 End
   ---------------------------------------------------------------
   BEGIN

      --CR3327-1 Starts
      global_portin_line := NULL;
      FOR get_cell_num_rec IN get_cell_num (p_esn)
      LOOP
         IF get_cell_num_rec.x_port_in <> 0
         THEN
            global_portin_line := get_cell_num_rec.part_serial_no;
            EXIT;
         END IF;
      END LOOP;
      --CR3327-1 Ends
      OPEN get_cell_num (p_esn);
      FETCH get_cell_num
      INTO get_cell_num_rec;
      IF get_cell_num%FOUND
      THEN
--CR2620 Start
         IF get_cell_num_rec.line_status = '110'
         THEN
            OPEN get_no_msid_line(get_cell_num_rec.part_serial_no);
            FETCH get_no_msid_line
            INTO get_no_msid_line_rec;
            IF get_no_msid_line%FOUND
            THEN
               global_part_serial_no := get_cell_num_rec.part_serial_no;
               CLOSE get_no_msid_line;
               RETURN TRUE;
            END IF;
            CLOSE get_no_msid_line;
            RETURN FALSE;
         ELSE
            global_part_serial_no := get_cell_num_rec.part_serial_no;
         END IF;
         --CR2620 End
         CLOSE get_cell_num;
         RETURN TRUE;
      END IF;
      CLOSE get_cell_num;
      RETURN FALSE;
   END get_gsm_line_fun;
   --CR3153 - Changes for T-Mobile
   /*************************************************************************/
   /************Check for no inventory carrier **************************/
   /*************************************************************************/
   FUNCTION check_no_inventory_carrier
   RETURN BOOLEAN
   IS
      CURSOR get_carrier_group(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT 1
      FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier c
      WHERE p.objid = cg.x_carrier_group2x_parent
      AND p.X_NO_INVENTORY = 1
      AND UPPER (p.x_status) = 'ACTIVE'
      AND cg.objid = c.carrier2carrier_group
      AND cg.x_status = 'ACTIVE'
      AND c.objid = c_carrier_objid;
      carrier_group_rec get_carrier_group%ROWTYPE;
   BEGIN

      --CR3338 Starts
      FOR c_sim_carr_info_rec IN c_sim_carr_info(global_sim_profile)
      LOOP
         OPEN get_carrier_group(c_sim_carr_info_rec.carr_objid);
         FETCH get_carrier_group
         INTO carrier_group_rec;
         IF get_carrier_group%found
         THEN
            CLOSE get_carrier_group;
            RETURN TRUE;
         ELSE
            CLOSE get_carrier_group;
            RETURN FALSE;
         END IF;
      END LOOP;
      --CR3338 Ends
      /* Main */
      FOR i IN 1 .. carrier_cnt2
      LOOP
         OPEN get_carrier_group(carrier_array2(i));
         FETCH get_carrier_group
         INTO carrier_group_rec;
         IF get_carrier_group%found
         THEN
            CLOSE get_carrier_group;
            RETURN TRUE;
         END IF;
         CLOSE get_carrier_group;
      END LOOP;
      FOR i IN 1 .. carrier_cnt
      LOOP
         OPEN get_carrier_group(carrier_array(i));
         FETCH get_carrier_group
         INTO carrier_group_rec;
         IF get_carrier_group%found
         THEN
            CLOSE get_carrier_group;
            RETURN TRUE;
         END IF;
         CLOSE get_carrier_group;
      END LOOP;
      RETURN FALSE;
   END;
   --CR3153 - End Changes for T-Mobile
   FUNCTION is_iccid_valid_for_react
   RETURN NUMBER
   IS
      CURSOR c_old_sim_info
      IS
      SELECT x_zipcode,
         x_iccid,
         service_end_dt last_deact_date,
         x_deact_reason--EME Fix for CR3918
      FROM table_site_part sp
      WHERE objid = (
      SELECT MAX(objid)
      FROM table_site_part sp1
      WHERE sp1.x_service_id = global_esn
      AND part_status ||'' = 'Inactive'
      AND SUBSTR(x_min, 1, 1) <> 'T'); --1.37
      c_old_sim_info_rec c_old_sim_info%ROWTYPE;
      ------------------------------------------------
      CURSOR c_old_sim_zone(
         c_ip_zip IN VARCHAR2
      )
      IS
      SELECT DISTINCT a.zone,
         a.st
      FROM sa.carrierzones a, sa.npanxx2carrierzones b
      WHERE (a.sim_profile
      IS
      NOT NULL
      OR a.sim_profile_2
      IS
      NOT NULL ) --CR3885
      AND b.GSM_TECH = 'GSM'
      --      AND a.bta_mkt_number = b.bta_mkt_number
      AND a.st = b.state
      AND a.zone = b.zone
      AND a.zip = c_ip_zip;
      c_old_sim_zone_rec c_old_sim_zone%ROWTYPE;
      -----------------------------------------------
      CURSOR c_new_sim_zone
      IS
      SELECT DISTINCT a.zone,
         a.st
      FROM sa.carrierzones a, sa.npanxx2carrierzones b
      WHERE (a.sim_profile
      IS
      NOT NULL
      OR a.sim_profile_2
      IS
      NOT NULL ) --CR3885
      AND b.GSM_TECH = 'GSM'
      --      AND a.bta_mkt_number = b.bta_mkt_number
      AND a.st = b.state
      AND a.zone = b.zone
      AND a.zip = global_zip;
      c_old_sim_zone_rec c_old_sim_zone%ROWTYPE;
      ------------------------------------
      CURSOR c_gsm_grace_time(
         c_ip_rule_objid IN NUMBER
      )
      IS
      SELECT x_gsm_grace_period
      FROM table_x_carrier_rules
      WHERE objid = c_ip_rule_objid;
      c_gsm_grace_time_rec c_gsm_grace_time%ROWTYPE;
      -------------------------
      --CR3918 Starts
      CURSOR c_zip_mrkt(
         ip_zip IN VARCHAR2
      )
      IS
      SELECT DISTINCT mkt
      FROM x_cingular_mrkt_info
      WHERE zip = ip_zip;
      c_zip_mrkt_rec c_zip_mrkt%ROWTYPE;
      l_old_mkt VARCHAR2(20);
      l_new_mkt VARCHAR2(20);
      --CR3918 ends;
      l_sim_zone_cnt NUMBER := 0;
      l_sim_expd_cnt NUMBER := 0;
      l_same_sim VARCHAR2(1) := 'F';
--CR3918
   BEGIN
      OPEN c_old_sim_info;
      FETCH c_old_sim_info
      INTO c_old_sim_info_rec;
      IF c_old_sim_info%found
      THEN
         IF c_old_sim_info_rec.x_iccid = p_sim
         THEN
            l_same_sim := 'T'; --CR3918
            --Commented for CR3918 same zone and state check is ot required for cingular anymore
            --             IF NOT check_no_inventory_carrier
            --             THEN
            -- --CR3647
            --                FOR c_new_sim_zone_rec IN c_new_sim_zone
            --                LOOP
            --                   FOR c_old_sim_zone_rec IN c_old_sim_zone (c_old_sim_info_rec.x_zipcode
            --                   )
            --                   LOOP
            --                      IF c_new_sim_zone_rec.zone = c_old_sim_zone_rec.zone
            --                      AND c_new_sim_zone_rec.st = c_old_sim_zone_rec.st
            --                      THEN
            --                         l_sim_zone_cnt := l_sim_zone_cnt + 1;
            --                      END IF;
            --                   END LOOP;
            --                END LOOP;
            --                IF l_sim_zone_cnt = 0
            --                THEN
            --                   RETURN 1;
            -- --'Invalid ICCID'
            --                /*         ELSE
            --                      RETURN 2;*/
            --                --No Old Sim Info
            --                END IF;
            --             END IF; --CR3647
            FOR c_sim_carr_info_rec IN c_sim_carr_info(global_sim_profile)
            LOOP
               OPEN c_gsm_grace_time(c_sim_carr_info_rec.CARRIER2RULES);
               FETCH c_gsm_grace_time
               INTO c_gsm_grace_time_rec;
               IF c_gsm_grace_time%found
               THEN
                  IF (SYSDATE - c_old_sim_info_rec.last_deact_date) >
                  c_gsm_grace_time_rec.x_gsm_grace_period
                  THEN
                     l_sim_expd_cnt := l_sim_expd_cnt + 1;
                  END IF;
               END IF;
               CLOSE c_gsm_grace_time;
            END LOOP;
            IF l_sim_expd_cnt > 0
            THEN
               RETURN 2;
--'ICCID expired'
            END IF;
         END IF;
         --only if old and new sim matches
         --CR3918 starts
         --Old Zip's market info
         --Check for different markets only if it is Cingular (1.35) and same sim (1.36)
         --IF NOT check_no_inventory_carrier
         IF ( NOT check_no_inventory_carrier)
         AND (l_same_sim = 'T')
         THEN
            OPEN c_zip_mrkt(c_old_sim_info_rec.x_zipcode);
            FETCH c_zip_mrkt
            INTO c_zip_mrkt_rec;
            IF c_zip_mrkt%found
            THEN
               l_old_mkt := c_zip_mrkt_rec.mkt;
            ELSE
               l_old_mkt := NULL;
            END IF;
            CLOSE c_zip_mrkt;
            --New Zip's market info
            OPEN c_zip_mrkt(p_zip);
            FETCH c_zip_mrkt
            INTO c_zip_mrkt_rec;
            IF c_zip_mrkt%found
            THEN
               l_new_mkt := c_zip_mrkt_rec.mkt;
            ELSE
               l_new_mkt := NULL;
            END IF;
            CLOSE c_zip_mrkt;
            IF l_same_sim = 'T'
            AND (c_old_sim_info_rec.x_zipcode <> p_zip)
            THEN
               IF NVL(l_old_mkt, 'zzz') <> NVL(l_new_mkt, 'yyy')
               THEN
                  RETURN 4;
               END IF;
            END IF;
            --CR4212 Starts
            IF c_old_sim_info_rec.x_deact_reason IN ('NON TOPP LINE')
            THEN
               IF c_old_sim_info_rec.x_zipcode = p_zip
               THEN
                  RETURN 0;
               ELSE
                  IF NVL(l_old_mkt, 'zzz') = NVL(l_new_mkt, 'yyy')
                  THEN
                     l_msisdn_flag := 'T';
                  ELSE
                     RETURN 4;
                  END IF;
               END IF;
            ELSE
               IF (NVL(l_old_mkt, 'zzz') = NVL(l_new_mkt, 'yyy'))
               OR (c_old_sim_info_rec.x_zipcode = p_zip)
               THEN
                  l_msisdn_flag := 'T';
               END IF;
            END IF;

         --EME Fix for CR3918 (deact_reason check) Starts
         --             IF (NVL(l_old_mkt, 'zzz') = NVL(l_new_mkt, 'yyy'))
         --             OR (c_old_sim_info_rec.x_zipcode = p_zip)
         --             THEN
         --                l_msisdn_flag := 'T';
         -- --Different Markets
         --             END IF;
         --             IF (c_old_sim_info_rec.x_zipcode = p_zip)
         --             AND (c_old_sim_info_rec.x_deact_reason NOT IN ('NON TOPP LINE')) ----deact reason check
         --             THEN
         --                IF (NVL(l_old_mkt, 'zzz') = NVL(l_new_mkt, 'yyy'))
         --                THEN
         --                   DBMS_OUTPUT.PUT_LINE('c_old_sim_info_rec.x_deact_reason '||
         --                   c_old_sim_info_rec.x_deact_reason);
         --                   l_msisdn_flag := 'T';
         --                END IF;
         -- --Different Markets
         --             END IF;
         --EME Fix for CR3918 (deact_reason check) Ends
         --CR4212 Ends
         END IF;
-- End of Check for different markets only if it is Cingular (1.35)
      --CR3918 Ends
      END IF;--check for inactive record
      CLOSE c_old_sim_info;
      RETURN 0;
--Success
   END is_iccid_valid_for_react;
--CR3338 End
/*************************************************************************/
/***** START OF MAIN NAP_DIGITAL******************************************/
/*************************************************************************/
BEGIN
   IF p_language = 'English'
   THEN
--CR3527 Start
      --       p_msg :=
      --       'No lines found for this zipcode. PLEASE WARM TRANSFER THIS CALL TO EXT 1118'
      --       ;
      p_msg :=
      'AGENT:  There are no lines available for this zip code.  Please advise the customer to call back in 24-48 hours.'
      ;
   ELSE

      --       p_msg :=
      --       'No se encontraron lmneas para esta area. Por favor transfiera amablemente esta llamada a la extensisn 1118'
      --       ;
      p_msg :=
      'No hay lineas disponibles en el codigo de area que ingreso. Por favor informe al cliente que llame en un periodo de 24 a 48 horas'
      ;
--CR3527 End
   END IF;
   /**** Branch for GSM technology ****/
   IF LENGTH (p_esn) = 11
   THEN
      IF NOT valid_zip
      THEN
         IF p_language = 'English'
         THEN
            p_msg := 'Invalid zipcode.';
         ELSE
            p_msg := 'area no valida.';
         END IF;
         RETURN;
      END IF;
      get_carriers;
      IF (carrier_cnt2 = 0)
      AND (carrier_cnt = 0)
      THEN
         IF p_msg != 'NO REACT'
         THEN

            --Amigo
            IF l_amigo_yn = 0
            THEN
               p_msg := 'No carrier found for technology.';
            ELSIF l_amigo_yn = 1
            THEN
               p_msg := 'NO AMIGO';
            END IF;
            DBMS_OUTPUT.put_line (
            'No carrier found for technology.(carrier_cnt2 = 0) and (carrier_cnt = 0)'
            );
         ELSE
            DBMS_OUTPUT.put_line ('NO REACT');
         END IF;
         --CR3338 Start
         IF p_source = 'WEBCSR'
         THEN
            get_repl_part( p_msg, p_repl_part, p_repl_tech, p_sim_profile ) ;
         END IF;
         --CR3338 End
         RETURN;
      END IF;
      WHILE global_resource_busy_cnt < 4
      AND global_resource_busy = 'Y'
      LOOP
         IF (get_line = TRUE)
         THEN

            --CR3614 Start
            OPEN c_line_port (global_part_serial_no);
            FETCH c_line_port
            INTO c_line_port_rec;
            CLOSE c_line_port;
            IF NVL(c_line_port_rec.x_port_in, 0) <> 0
            THEN
               l_same_zone := TRUE;
               --CR3327-1 Starts
               IF global_portin_line
               IS
               NOT NULL
               THEN
                  global_part_serial_no := global_portin_line;
               END IF;
               --CR3327-1 Ends
               update_c_choice (p_zip, p_esn, global_part_serial_no, 'F');
               IF p_language = 'English'
               THEN
                  p_msg :=
                  'F Choice: MIN already attached to ESN.  Please verify.';
               ELSE
                  p_msg :=
                  'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique'
                  ;
               END IF;
               p_part_serial_no := global_part_serial_no;
               global_resource_busy := 'N';
            ELSE
               OPEN gsm_get_same_zone_cur(global_part_serial_no);
               FETCH gsm_get_same_zone_cur
               INTO gsm_get_same_zone_rec;
               CLOSE gsm_get_same_zone_cur;
               IF gsm_get_same_zone_rec.zone
               IS
               NOT NULL
               OR p_upg_flag = 'Y' --CR3824
               THEN
                  l_same_zone := TRUE;
                  update_c_choice (p_zip, p_esn, global_part_serial_no, 'F');
                  IF p_language = 'English'
                  THEN
                     p_msg :=
                     'F Choice: MIN already attached to ESN.  Please verify.';
                  ELSE
                     p_msg :=
                     'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique'
                     ;
                  END IF;
                  p_part_serial_no := global_part_serial_no;
                  global_resource_busy := 'N';
               ELSE
                  l_same_zone := FALSE;
               END IF;
            END IF;
         END IF;
         --         ELSIF (prefered_county ('B1') = TRUE)
         IF l_same_zone = FALSE
         THEN
            IF (prefered_county ('B1') = TRUE)
            THEN
--CR3614 End
               p_part_serial_no := global_part_serial_no;
            ELSIF (prefered_county ('B2') = TRUE)
            THEN
               p_part_serial_no := global_part_serial_no;
            ELSIF (prefered_sid = TRUE)
            THEN
               p_part_serial_no := global_part_serial_no;
            ELSE
--Vadapa 06/18/02 Add logic to not to reserve line for 'D' choice, but update the report table
               IF d_choice_found
               THEN
                  update_c_choice (p_zip, p_esn, NULL, 'D');
               ELSIF d2_choice_found
               THEN
                  update_c_choice (p_zip, p_esn, NULL, 'D2');
               ELSE
--Vadapa 06/18/02 changes end
                  update_c_choice (p_zip, p_esn, NULL, 'N');
               END IF;
               global_resource_busy := 'N';
            END IF;
         END IF; --CR3614
         global_resource_busy_cnt := global_resource_busy_cnt + 1;
      END LOOP;
      IF global_resource_busy = 'Y'
      THEN
         IF p_language = 'English'
         THEN
            p_msg := 'Resource was busy try again.';
         ELSE
            p_msg := 'El recurso esta ocupado. Por favor llame mas tarde.';
         END IF;
         p_part_serial_no := NULL;
      ELSE
         IF UPPER (p_commit) = 'YES'
         THEN
            DBMS_OUTPUT.put_line ('p_commit:= yes');
            COMMIT;
         ELSE
            DBMS_OUTPUT.put_line ('p_commit:= no');
         END IF;
      END IF;
   ELSE

      --CR4017 Starts
      IF NOT valid_zip
      THEN
         IF p_language = 'English'
         THEN
            p_msg := 'Invalid zipcode.';
         ELSE
            p_msg := 'area no valida.';
         END IF;
         RETURN;
      END IF;
      --CR4017 Ends
      l_sim_valid_check := is_valid_iccid; --CR3338
      /** GSM TECHNOLOGY BRANCH **/
      /** get dealer **/
      get_gsm_dealer_prc;
      /** get phone frequency **/
      get_phone_frequency_prc;
      /** determine if the phone is being reactivated or not **/
      IF is_a_react_fun
      THEN

         --CR3459 Starts
         get_default_carrier_prc (global_technology);
         get_pref_prc;
         IF carrier_cnt2 > 0
         THEN
--CR3459 Ends
            --CR3338 Start
            DECLARE
               l_out_msg VARCHAR2(2000);
               l_repl_sim VARCHAR2(100);
            BEGIN
               IF l_sim_valid_check = 0
               THEN
                  l_react_sim := is_iccid_valid_for_react;
                  IF l_react_sim > 0
                  THEN
--1=Reactivate SIM Info Not Available, 2=Invalid ICCID, 3=ICCID expired 4=Different Markets
                     get_repl_sim(l_out_msg, l_repl_sim);
                     IF l_react_sim = 1
                     THEN
                        p_msg := l_out_msg||'-ICCID is not valid';
                     ELSIF l_react_sim = 2
                     THEN
                        p_msg := l_out_msg||'-ICCID Expired';
--CR3918 Starts
                     ELSIF l_react_sim = 4
                     THEN
                        p_msg := l_out_msg||'-Different Markets';
--CR3918 Ends
                     END IF;
                     p_sim_profile := l_repl_sim;
                     RETURN;
                  END IF;
               ELSE
                  get_repl_sim(l_out_msg, l_repl_sim);
                  IF l_sim_valid_check = 1
                  THEN
                     p_msg := l_out_msg||
                     '-ICCID is already attached to an IMEI';
                  ELSIF l_sim_valid_check = 2
                  THEN
                     p_msg := l_out_msg||'-ICCID status is invalid';
                  ELSIF l_sim_valid_check = 3
                  THEN
                     p_msg := l_out_msg||'-ICCID is not valid';
                  END IF;
                  p_sim_profile := l_repl_sim;
                  RETURN;
               END IF;
            END;
         END IF; --CR3459
         --CR3338 End
         /* verify if the phone is attached to a line --should be  */
         IF get_gsm_line_fun
         THEN

            /* Can I use the same line per carrier rules */
            IF react_65_90_fun (global_technology)
            THEN

               /** is a new phone  **/
               /** get default carrier **/
               get_default_carrier_prc (global_technology);
               /** get the carrier group **/
               --   get_carrier_group_prc;
               /** get pref carrier **/
               get_pref_prc;
               --CR3338 Start (Variable to not to assign a line for T-Mobile phones)
               IF check_no_inventory_carrier
               OR l_msisdn_flag = 'T' --CR3918
               THEN
                  l_commit := 'NO';
               ELSE

                  --CR3437 Start
                  --l_commit := 'YES';
                  l_commit := UPPER(p_commit);

               --CR3437 End
               END IF;
               --CR3338 End
               /* done */
               --CR3327-1 Starts
               IF global_portin_line
               IS
               NOT NULL
               THEN
                  global_part_serial_no := global_portin_line;
               END IF;
               --CR3327-1 Ends
               update_c_choice (p_zip, p_esn, global_part_serial_no, 'F');
               IF p_language = 'English'
               THEN
                  p_msg :=
                  'F Choice: MIN already attached to ESN.  Please verify.';
               ELSE
                  p_msg :=
                  'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique'
                  ;
               END IF;
               p_part_serial_no := global_part_serial_no;
               global_resource_busy := 'N';
            ELSE
               global_new_handset := TRUE;
               global_react_new_line := TRUE;
            END IF;
/* of react_65_90_fun */
         ELSE
            global_new_handset := TRUE;
         END IF;
/* get_line */
      ELSE
         global_new_handset := TRUE;
      END IF /* is_a_react_fun */
;
      --dbms_output.put_line(global_new_handset);
      /** check if handset is new */
      IF global_new_handset
      THEN

         /** is a new phone  **/
         /** get default carrier **/
         get_default_carrier_prc (global_technology);
         /** get the carrier group **/
         --   get_carrier_group_prc;
         /** get pref carrier **/
         get_pref_prc;
         --CR3338 Start (Variable to not to assign a line for T-Mobile phones)
         IF check_no_inventory_carrier
         OR l_msisdn_flag = 'T' --CR3918
         THEN
            l_commit := 'NO';
         ELSE

            --CR3437 Start
            --l_commit := 'YES';
            l_commit := UPPER(p_commit);

         --CR3437 End
         END IF;
         --CR3338 End
         /** check the results **/
         IF (carrier_cnt2 = 0)
         THEN
            IF p_msg != 'NO REACT'
            THEN

               --Amigo
               IF global_restricted_use = 0
               THEN
                  p_msg := 'No carrier found for technology.';
                  l_new_msg_flag := 'Y';
--CR3918
               ELSIF global_restricted_use = 1
               THEN
                  p_msg := 'NO AMIGO';

               --CR3190 Start
               ELSIF global_restricted_use = 3
               THEN
                  p_msg := 'NO NET10 COVERAGE';
                  update_c_choice (p_zip, p_esn, NULL, 'NO NET10');
--CR4347
               --CR3190 End
               END IF;
               DBMS_OUTPUT.put_line (
               'No carrier found for technology.(carrier_cnt2 = 0)' );
            ELSE
               DBMS_OUTPUT.put_line ('NO REACT');
            END IF;
            --CR3338 Start
            IF p_source = 'WEBCSR'
            THEN
               get_repl_part( p_msg, p_repl_part, p_repl_tech, p_sim_profile )
               ;
               --CR3918 Starts
               IF p_msg
               IS
               NULL
               AND l_new_msg_flag = 'Y'
               THEN
                  p_msg := 'NO CINGULAR COVERAGE';
               END IF;

            --CR3918 Ends
            --CR3190 Start
            ELSIF p_source = 'NETCSR'
            AND global_restricted_use = 3
            THEN
               DECLARE
                  l_out_msg VARCHAR2(2000);
                  l_repl_sim VARCHAR2(100);
                  l_ret_value NUMBER;
               BEGIN
                  get_repl_sim(l_out_msg, l_repl_sim);
                  IF l_ret_value = 1
                  THEN
                     p_msg := l_out_msg||
                     '-ICCID is already attached to an IMEI';
                  ELSIF l_ret_value = 2
                  THEN
                     p_msg := l_out_msg||'-ICCID status is invalid';
                  ELSIF l_ret_value = 3
                  THEN
                     p_msg := l_out_msg||'-ICCID is not valid';
                  END IF;
                  p_sim_profile := l_repl_sim;
               END;
               RETURN;
--CR3190 End
            END IF;
            RETURN;

         --CR3338 End
         /* exit */
         --CR3338 Start
         ELSE
            DECLARE
               l_ret_value NUMBER;
               l_carr_objid NUMBER;
               l_same_carr_cnt NUMBER := 0;
               l_out_msg VARCHAR2(2000);
               l_repl_sim VARCHAR2(100);
            BEGIN
               l_ret_value := l_sim_valid_check;
               IF l_ret_value = 0
               THEN

                  --compare sim carrier and get_carriers....ok....if doesnt match, we need sim replacement
                  FOR i IN 1..carrier_cnt2
                  LOOP
                     OPEN c_sim_carr_info(global_sim_profile );
                     FETCH c_sim_carr_info
                     INTO c_sim_carr_info_rec;
                     CLOSE c_sim_carr_info;
                     IF carrier_array2(i) = c_sim_carr_info_rec.carr_objid
                     THEN
                        l_same_carr_cnt := l_same_carr_cnt + 1;
                     END IF;
                  END LOOP;
                  IF l_same_carr_cnt <= 0
                  THEN
                     get_repl_sim(l_out_msg, l_repl_sim);
                     p_msg := l_out_msg||'-ICCID Preferred Carrier Not Found';
                     p_sim_profile := l_repl_sim;
                     RETURN;
                  END IF;
               ELSE
--1=ICCID is already attached to an IMEI, 2=Invalid ICCID status, 3=Invalid ICCID
                  get_repl_sim(l_out_msg, l_repl_sim);
                  IF l_ret_value = 1
                  THEN
                     p_msg := l_out_msg||
                     '-ICCID is already attached to an IMEI';
                  ELSIF l_ret_value = 2
                  THEN
                     p_msg := l_out_msg||'-ICCID status is invalid';
                  ELSIF l_ret_value = 3
                  THEN
                     p_msg := l_out_msg||'-ICCID is not valid';
                  END IF;
                  p_sim_profile := l_repl_sim;
                  RETURN;
               END IF;
            END;
--CR3338 End
         END IF; /*of carrier count 2 check */
         -----------------------------------------------------------------------
         WHILE global_resource_busy_cnt < 4
         AND global_resource_busy = 'Y'
         LOOP
            IF (get_gsm_line_fun = TRUE)
            AND (global_react_new_line = FALSE)
            THEN

               --CR3338 Start
               OPEN c_line_port (global_part_serial_no);
               FETCH c_line_port
               INTO c_line_port_rec;
               CLOSE c_line_port;
               IF NVL(c_line_port_rec.x_port_in, 0) <> 0
               THEN
                  l_gsm_same_zone := TRUE;
                  update_c_choice (p_zip, p_esn, global_part_serial_no, 'F');
                  IF p_language = 'English'
                  THEN
                     p_msg :=
                     'F Choice: MIN already attached to ESN.  Please verify.';
                  ELSE
                     p_msg :=
                     'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique'
                     ;
                  END IF;
                  p_part_serial_no := global_part_serial_no;
                  global_resource_busy := 'N';
               ELSE
                  OPEN gsm_get_same_zone_cur(global_part_serial_no);
                  FETCH gsm_get_same_zone_cur
                  INTO gsm_get_same_zone_rec;
                  CLOSE gsm_get_same_zone_cur;
                  IF gsm_get_same_zone_rec.zone
                  IS
                  NOT NULL
                  OR p_upg_flag = 'Y' --CR3824
                  THEN
                     l_gsm_same_zone := TRUE;
                     update_c_choice (p_zip, p_esn, global_part_serial_no, 'F')
                     ;
                     IF p_language = 'English'
                     THEN
                        p_msg :=
                        'F Choice: MIN already attached to ESN.  Please verify.'
                        ;
                     ELSE
                        p_msg :=
                        'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique'
                        ;
                     END IF;
                     p_part_serial_no := global_part_serial_no;
                     global_resource_busy := 'N';
                  ELSE
                     l_gsm_same_zone := FALSE;
                  END IF;
               END IF;
            END IF;
            IF l_gsm_same_zone = FALSE
            THEN
--            ELSIF (prefered_county_fun = TRUE)
               IF (prefered_county_fun = TRUE)
               THEN
                  p_part_serial_no := global_part_serial_no;
               ELSIF (prefered_sid_fun = TRUE)
               THEN
                  p_part_serial_no := global_part_serial_no;
               ELSE
--Vadapa 06/18/02 Add logic to not to reserve line for 'D' choice, but update the report table
                  IF d_choice_found
                  THEN
                     update_c_choice (p_zip, p_esn, NULL, 'D');
                  ELSIF d2_choice_found
                  THEN
                     update_c_choice (p_zip, p_esn, NULL, 'D2');
                  ELSE
--Vadapa 06/18/02 changes end
                     update_c_choice (p_zip, p_esn, NULL, 'N');
                  END IF;
                  global_resource_busy := 'N';
               END IF;
            END IF;
            global_resource_busy_cnt := global_resource_busy_cnt + 1;
         END LOOP;
------------------------------------------------------------------
      END IF; /* new phone*/
      IF global_resource_busy = 'Y'
      THEN
         IF p_language = 'English'
         THEN
            p_msg := 'Resource was busy try again.';
         ELSE
            p_msg := 'El recurso esta ocupado. Por favor llame mas tarde.';
         END IF;
         p_part_serial_no := NULL;
      ELSE
--         IF UPPER (p_commit) = 'YES'
         IF UPPER (l_commit) = 'YES'
         THEN
            DBMS_OUTPUT.put_line ('p_commit:= yes');
            COMMIT;
         ELSE
            DBMS_OUTPUT.put_line ('p_commit:= no');
         END IF;
      END IF;
   END IF; /* of gsm check */
   /*************************************************************************/
   /*****   END OF MAIN NAP_DIGITAL******************************************/
   /*************************************************************************/
   DBMS_OUTPUT.put_line('l_commit '||l_commit);
   DBMS_OUTPUT.put_line('p_part_serial_no '||p_part_serial_no);
   DBMS_OUTPUT.put_line('global_resource_busy '||global_resource_busy);
   --      IF ( UPPER (p_commit) != 'YES' AND   --CR3338
   IF ( UPPER (l_commit) != 'YES'
   AND --CR3338
   --   p_part_serial_no IS NULL AND
   global_resource_busy != 'Y'
   AND (carrier_cnt > 0
   OR carrier_cnt2 > 0))
   THEN

      --CR3153 - Changes for T-Mobile
      IF check_no_inventory_carrier
      OR l_msisdn_flag = 'T' --CR3918
      THEN
         p_msg := 'No inventory carrier.';
         p_part_serial_no := NULL;
      END IF;

   --CR3153 - End Changes for T-Mobile
   END IF;
END;
/