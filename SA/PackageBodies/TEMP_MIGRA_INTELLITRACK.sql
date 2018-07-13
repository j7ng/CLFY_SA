CREATE OR REPLACE PACKAGE BODY sa."TEMP_MIGRA_INTELLITRACK"
IS
/*****************************************************************
   * Package Name: migra_intellitrack (BODY)
   * Purpose     : To manage the interface between Clarify and Intellitrack
   *
   * Platform    : Oracle 8.0.6 and newer versions.
   * Created by  : Fernando Lasa, DRITON
   * Date        : 09/02/2005
   *
   * Frequency   : All weekdays
   * History
   * REVISIONS    VERSION  DATE        WHO           PURPOSE
   * -------------------------------------------------------------
   *                1.0                Fernando Lasa Initial Revision
   *                1.13   09/02/05    Fernando Lasa CR 4260 - Fist release put in testing
   *                1.14   09/02/05    Fernando Lasa CR 4260 - To add the header comment
   *                1.15   09/02/05    Fernando Lasa CR 4260 - To add the functionality that
   *                                                 shoud check if the replace part number is null
   *                                                 and in that case update it.
   *                1.16   09/03/05    Fernando Lasa CR 4260 - To correct an error in Send_cases
   *                1.17   09/03/05    Fernando Lasa CR 4260 - To change from all 9 to --- for
   *                                                           SIM CARD EXCHANGE in Technology Exchange
   *                                                           cases and complete a message error.
   *                1.18   09/03/05    Fernando Lasa CR 4260 - To change the order of the procedures
   *                1.19   09/05/05    Fernando Lasa CR 4187 - To comment the line that call the procedure
   *                                                           CheckReplPartInNull in Send_Cases
   *                1.20   09/05/05    Fernando Lasa CR 4187 - To process only cases started by 9 in
   *                                                           phone_shipping process
   *                1.21   09/07/05    Fernando Lasa CR 4187 - To change DBlink to ofsprd
   *                1.22   09/09/05    Fernando Lasa CR 4187 - To fix a problem with phone_receive
   *                1.23   09/11/05    Fernando Lasa CR 4187 - To change the way the OFS records
   *                                                           are flaged as processed and to take the last
   *                                                           valid case of a ESN
   *                1.24   09/14/05    Fernando Lasa CR 4187 - To change the way NO CASE cases were saved
   *                1.25   09/27/05    Fernando Lasa CR 4187 - To manage received phones that had a non-pending case,
   *                                                           new message string 35 chars first part, 20 chars for status title in Phone_Receive
   *                                                           Change in Close_Case to fix a status bug
   *                1.26   09/29/05    Fernando Lasa CR 4187 - To fix a phone_shipping issue.
   *                                                 CR 4513 - To include procedure TransferPromotions
   *                1.27   10/11/05    VAdapa        CR4541 - Advanced Exchange
   *                1.28   10/12/05    Vadapa        Additions to CR4541
   *                1.29   10/13/05    VAdapa        Fix for CR4541
   *                1.30   10/13/05    VAdapa        Changed the database link from OFSDEV to ofsprd
   *                1.31   10/14/05    flasa         CR 4691 - To change the cursor structure of OFS in Phone_receive
   *                1.32   10/20/05    flasa         CR 4691 - To include an array in phone_receive
   *                1.33   12/29/05    flasa         CR 4878 - Bad Address Shipments
   *                1.34   12/29/05    flasa         CR 4878 - To fix a bug
   *                1.35   01/27/06    flasa         CR 4881 - To fix remove promotion in Bad Address
   *                1.35.1 02/01/06       VAdapa         Correct CR# in the comments
   *                                                       CR4878
   *                1.35.1.1 02/16/06  gcarena       CR4878 - To prevent F flagged cases of being re-updated to 'Bad Adress' status
   *                                                          over and over again, and prevent promo removal and units removal
   *                1.35.1.2 02/17/06  gcarena       CR4878 - To fix that F cases should continue to reprocess, but prevent case status
   *                                                          update, promo removal, units removal, until it succeeds and flagged as P
   *                1.35.1.3 02/22/06  gcarena       CR5029 - To modify the revision label of revision 1.35.1.2 and add this comment
   *                1.35.1.4 02/28/06  gcarena       CR5029 - To remove the package header, wrongfully included at top of package body
   *                1.35.1.5 03/07/06  flasa         CR5029 - TO check new ESN for null values, and mark as 'P' in OFS anyway
   *                1.35.1.6 06/14/06  gpintado      CR5336 - Sending FF, Carrier and Method to OFS table (tf_order_interface).
   *                1.36     09/08/06  Jasmine              - Warehouse Integration change:
   *                                                                 Add ship_to_address2;
   *                                                                 Remove the hardcode of SHIPPING_METHOD;assign values from Table_X_Part_Request to SHIPPING_METHOD;
   *                                                                 Replace parameter p_OldEsn with p_objid in Transferpromotions
   *                                                                 Insert into table_x_case_promotions
   *                         09/21/06 Jing Tong     IN parameter for tf_doc_number  while in the tf_receipt_headers,
   *                1.40 /1.41  11/01/06    gpintado       PJ244 - Re-write of Bad Address procedure.
   *                1.42  01/20/07    Vadapa       CR5569-7 - To fix not to update the duedate of the phone during transferpromotions
   *                1.43  01/25/07    gpintado     CR5980 - Change send_case to use alt_phone instead of alt_phone_num
   *           1.44  02/16/07      VAdapa    CR5848 - Tracfone and Net10 Airtime Price Change
   *           1.45  02/16/07      VAdapa    Modified to fix a defect logged for CR5848 (defect #355)
   *           1.46  02/28/07      VAdapa    Modified to fix a defect logged for CR5848 (defect #373)
   ************************************************************************//*************************************************************************
   --
   ---------------------------------------------------------------------------------------------
   --$RCSfile: TEMP_MIGRA_INTELLITRACK.sql,v $
   --$Revision: 1.2 $
   --$Author: kacosta $
   --$Date: 2012/04/03 14:48:03 $
   --$ $Log: TEMP_MIGRA_INTELLITRACK.sql,v $
   --$ Revision 1.2  2012/04/03 14:48:03  kacosta
   --$ CR16379 Triple Minutes Cards
   --$
   --$
   ---------------------------------------------------------------------------------------------
   --
   ************************************************************************//*************************************************************************
   * Procedure: IS_NUMERIC
   * Purpose  : To check if string value is numeric
   **************************************************************************/
   FUNCTION is_numeric (pnumber IN VARCHAR2)
      RETURN BOOLEAN
   IS
      v_number   NUMBER (20);
   BEGIN
      v_number := TO_NUMBER (pnumber);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   /*************************************************************************
   * Procedure: Update_log
   * Purpose  : To Update the status of the log
   **************************************************************************/
   PROCEDURE insert_log (
      esn              IN   VARCHAR2,
      receipt_number   IN   NUMBER,
      my_text          IN   VARCHAR2,
      flag_type        IN   VARCHAR2
   )
   AS
   --Proc varchar2(1);
   BEGIN
      /* IF my_text is NULL THEN
         Proc := 'P';
      ELSE
         Proc := 'F';
      END IF;    */
      INSERT INTO migr_case_log@ofsprd
                  (esn, receipt_number, process_date, error_message,
                   process_flag
                  )
           VALUES (esn, receipt_number, SYSDATE, my_text,
                   flag_type
                  );
   END;

--#############################################################################################
--#############################################################################################
   FUNCTION getsimreplacement (strgsmzipcode IN VARCHAR2)
      RETURN VARCHAR2
   AS
      strreplpartnum   VARCHAR2 (100)                        := NULL;
      strcolumn1       sa.carrierzones.sim_profile%TYPE;
      strcolumn2       sa.carrierzones.sim_profile_2%TYPE;
      strcarrierid     npanxx2carrierzones.carrier_id%TYPE   := NULL;
   BEGIN
      BEGIN
         SELECT carrier_id
           INTO strcarrierid
           FROM (SELECT tab2.carrier_id
                   FROM carrierpref cp,
                        table_x_carrier ca,
                        (SELECT DISTINCT b.state, b.county, b.carrier_id,
                                         b.gsm_tech
                                    FROM npanxx2carrierzones b,
                                         (SELECT DISTINCT a.ZONE, a.st,
                                                          a.sim_profile,
                                                          a.sim_profile_2
                                                     FROM carrierzones a
                                                    WHERE a.zip =
                                                                 strgsmzipcode) tab1
                                   WHERE b.ZONE = tab1.ZONE
                                     AND b.state = tab1.st) tab2
                  WHERE cp.new_rank =
                           (SELECT MIN (cp.new_rank)
                              FROM carrierpref cp,
                                   table_x_carrier ca,
                                   (SELECT DISTINCT b.state, b.county,
                                                    b.carrier_id, b.cdma_tech,
                                                    b.tdma_tech, b.gsm_tech
                                               FROM npanxx2carrierzones b,
                                                    (SELECT DISTINCT a.ZONE,
                                                                     a.st,
                                                                     a.sim_profile,
                                                                     a.sim_profile_2
                                                                FROM carrierzones a
                                                               WHERE a.zip =
                                                                        strgsmzipcode) tab1
                                              WHERE b.ZONE = tab1.ZONE
                                                AND b.state = tab1.st
                                                AND b.gsm_tech = 'GSM') tab2
                             WHERE cp.county = tab2.county
                               AND cp.st = tab2.state
                               AND cp.carrier_id = tab2.carrier_id
                               AND ca.x_carrier_id = tab2.carrier_id
                               AND ca.x_status = 'ACTIVE')
                    AND cp.county = tab2.county
                    AND cp.st = tab2.state
                    AND cp.carrier_id = tab2.carrier_id
                    AND tab2.carrier_id = ca.x_carrier_id
                    AND ca.x_status = 'ACTIVE'
                    AND tab2.gsm_tech = 'GSM')
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            strcarrierid := NULL;
      END;

      BEGIN
         SELECT sim_profile, sim_profile_2
           INTO strcolumn1, strcolumn2
           FROM (SELECT a.sim_profile, a.sim_profile_2
                   FROM sa.carrierzones a,
                        (SELECT DISTINCT b.bta_mkt_number, b.state, b.ZONE
                                    FROM sa.npanxx2carrierzones b
                                   WHERE b.gsm_tech = 'GSM'
                                     AND b.carrier_id = strcarrierid) b
                  WHERE (   a.sim_profile IS NOT NULL
                         OR a.sim_profile_2 IS NOT NULL
                        )
                    AND a.zip = strgsmzipcode
                    AND a.ZONE = b.ZONE
                    AND a.st = b.state)
          WHERE ROWNUM = 1;

         IF (    strcolumn1 IS NOT NULL
             AND TRIM (strcolumn1) <> ''
             AND TRIM (UPPER (strcolumn1)) <> 'NULL'
             AND strcolumn2 IS NOT NULL
             AND TRIM (strcolumn2) <> ''
             AND TRIM (UPPER (strcolumn2)) <> 'NULL'
            )
         THEN
            --that means CINGULAR
            strreplpartnum := strcolumn2;
         ELSE
            strreplpartnum := strcolumn1;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            strreplpartnum := 'No SIM Part Found';
      END;

      RETURN strreplpartnum;
   END;

--#############################################################################################
--#############################################################################################
   PROCEDURE getreplacementpartnum (
      stresn           IN       VARCHAR2,
      strzipcode       IN       VARCHAR2,
      strtype          IN       VARCHAR2,
      strnewesn        OUT      VARCHAR2,
      strreplpartnum   OUT      VARCHAR2,
      strerror         OUT      VARCHAR2
   )
   AS
      strreplacementpartnum   VARCHAR2 (100)
                                  := 'No Part Found For the Given Technology';
      strnewesntech           npanxx2carrierzones.cdma_tech%TYPE   := NULL;
      stroldesntech           table_part_num.x_technology%TYPE     := NULL;
      strzippreftech          npanxx2carrierzones.cdma_tech%TYPE   := NULL;
      blngsmzip               BOOLEAN                              := FALSE;
      --   blnDefault            Boolean := false;  -- this is for 5180/5125
      strgsmprofile           VARCHAR2 (100)                       := NULL;
      stroldpartnumobjid      table_part_num.objid%TYPE            := NULL;
      strnewpartnumtech       VARCHAR2 (100)                       := NULL;
      strtempgsm              npanxx2carrierzones.gsm_tech%TYPE;
      my_errm                 VARCHAR2 (32000);

      CURSOR c_carriers
      IS
         SELECT   tab2.cdma_tech, tab2.tdma_tech, tab2.gsm_tech, cp.new_rank
             FROM carrierpref cp,
                  table_x_carrier ca,
                  (SELECT DISTINCT b.state, b.county, b.carrier_id,
                                   b.cdma_tech, b.tdma_tech, b.gsm_tech
                              FROM npanxx2carrierzones b,
                                   (SELECT DISTINCT a.ZONE, a.st,
                                                    a.sim_profile
                                               FROM carrierzones a
                                              WHERE a.zip = strzipcode) tab1
                             WHERE b.ZONE = tab1.ZONE AND b.state = tab1.st) tab2
            WHERE cp.county = tab2.county
              AND cp.st = tab2.state
              AND cp.carrier_id = tab2.carrier_id
              AND ca.x_carrier_id = tab2.carrier_id
              AND ca.x_status = 'ACTIVE'
         ORDER BY new_rank;
   BEGIN
      --Get the ESN technology and part num objid
      IF LENGTH (stresn) > 0
      THEN
         BEGIN
            SELECT parttech, objid
              INTO stroldesntech, stroldpartnumobjid
              -- With this I am sure that I will receive only ONE record.
            FROM   (SELECT TRIM (pn.x_technology) parttech, pn.objid
                      FROM table_part_inst pi,
                           table_part_num pn,
                           table_mod_level ml
                     WHERE pi.part_serial_no = stresn
                       AND pi.x_domain = 'PHONES'
                       AND pi.n_part_inst2part_mod = ml.objid
                       AND ml.part_info2part_num = pn.objid)
             WHERE ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;                                          -- End of strESN Length

      --Get all the technologies supported by active carriers in the zipcode in order of their preference
      FOR r_carriers IN c_carriers
      LOOP
         BEGIN
            strzippreftech := r_carriers.cdma_tech;

            IF strzippreftech IS NULL OR LENGTH (strzippreftech) < 3
            THEN
               strzippreftech := r_carriers.tdma_tech;
--Get CDMA/TDMA
            END IF;

            strnewesntech := strzippreftech;
            strtempgsm := r_carriers.gsm_tech;

            IF strtempgsm IS NOT NULL AND UPPER (strtempgsm) = 'GSM'
            THEN
               blngsmzip := TRUE;
               strnewesntech := strtempgsm;
            END IF;

            IF    (    (stroldesntech = 'TDMA' OR stroldesntech = 'CDMA')
                   AND (UPPER (stroldesntech) = UPPER (strzippreftech))
                  )
               OR (stroldesntech = 'GSM' AND blngsmzip)
            THEN
               strnewpartnumtech := stroldesntech;
--Try to assign the same technology phone
            ELSE
               strnewpartnumtech := strzippreftech;
            END IF;

            --Find the replacement part
            BEGIN
               SELECT part_number
                 INTO strreplacementpartnum
                 FROM (SELECT   pn.part_number
                           FROM table_x_exch_options exch, table_part_num pn
                          WHERE exch.exch_source2part_num = stroldpartnumobjid
                            AND exch_target2part_num = pn.objid
                            AND pn.x_technology = strnewpartnumtech
                            AND exch.x_exch_type = strtype
                       ORDER BY exch.x_priority ASC)
                WHERE ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  strreplacementpartnum := NULL;
            END;

            IF strreplacementpartnum IS NULL
            THEN
               BEGIN
                  IF stroldesntech = 'GSM' AND blngsmzip
                  THEN
--If GSM replacement not found for GSM phone, get CDMA/TDMA replacement
                     blngsmzip := FALSE;

                     BEGIN
                        SELECT part_number
                          INTO strreplacementpartnum
                          FROM (SELECT   pn.part_number
                                    FROM table_x_exch_options exch,
                                         table_part_num pn
                                   WHERE exch.exch_source2part_num =
                                                            stroldpartnumobjid
                                     AND exch_target2part_num = pn.objid
                                     AND pn.x_technology = strzippreftech
                                     AND exch.x_exch_type = strtype
                                ORDER BY exch.x_priority ASC)
                         WHERE ROWNUM = 1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END IF;
               END;
            END IF;

            IF blngsmzip AND stroldesntech = 'GSM'
            THEN
--For GSM phones get the SIM profile as well
               strgsmprofile := getsimreplacement (strzipcode);

               IF LENGTH (strgsmprofile) > 0
               THEN
                  strgsmprofile :=
                            SUBSTR (strgsmprofile, LENGTH (strgsmprofile) - 1);
               END IF;

               strreplacementpartnum := strreplacementpartnum || strgsmprofile;
            END IF;

            IF strreplacementpartnum <>
                                      'No Part Found For the Given Technology'
            THEN
               EXIT;
            END IF;
         END;
      END LOOP;

      strnewesn := strnewesntech;
      strreplpartnum := strreplacementpartnum;
   EXCEPTION
      WHEN OTHERS
      THEN
         my_errm := SQLERRM;
         strnewesn := NULL;
         strreplpartnum := NULL;
         my_errm :=
            'ZipCode:' || strzipcode || ', ESN: ' || stresn || ', '
            || my_errm;
         strerror := my_errm;
   END;

   --#############################################################################################
   --#############################################################################################
--    PROCEDURE CheckReplPartInNull
--    AS
--       strError VARCHAR2(100);
--       newEsn table_case.x_esn%TYPE;
--       newReplPartNum table_case.x_repl_part_num%TYPE;
--       CURSOR c_Cases
--       IS
--       SELECT c.objid,
--          c.x_esn,
--          c.alt_zipcode,
--          c.x_case_type,
--          c.rowid MyRowid
--       FROM table_x_part_requesto a, table_case c
--       WHERE a.x_flag_migration = 'Y'
--       AND a.x_Migra2x_Case = c.objid
--       AND c.X_REPL_PART_NUM
--       IS
--       NULL;
--    BEGIN
--       FOR r_Cases IN c_Cases
--       LOOP
--          getReplacementPartNum(r_Cases.x_Esn, r_Cases.Alt_Zipcode, UPPER(
--          r_Cases.x_Case_Type), newEsn, newReplPartNum, strError);
--          IF newReplPartNum
--          IS
--          NOT NULL
--          THEN
--             UPDATE table_Case SET x_repl_part_num = newReplPartNum
--             WHERE ROWID = r_Cases.MyRowid;
--          END IF;
--       END LOOP;
--       NULL;
--    END;
   --#############################################################################################
   --#############################################################################################
   PROCEDURE exchangeesn (
      r_case      IN       table_case%ROWTYPE,
      esn         IN       VARCHAR2,
      tracking    IN       VARCHAR2,
      gbstobjid   IN       NUMBER,
      userid      IN       NUMBER,
      RESULT      OUT      VARCHAR2
   )
   AS
      l_alt_status    table_x_alt_esn.x_status%TYPE;
      l_alt_replace   table_x_alt_esn.x_replacement_esn%TYPE;
      l_void          VARCHAR2 (1000);
      l_cond          VARCHAR2 (100);
      l_lst_objid     table_gbst_lst.objid%TYPE;
      l_result        VARCHAR2 (1000)                          DEFAULT '';
   BEGIN
      RESULT := '';

      BEGIN
         SELECT 'x'
           INTO l_void
           FROM table_contact
          WHERE objid = r_case.case_reporter2contact;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RESULT := 'Contact not found';
      END;

      BEGIN
         SELECT e.x_status, e.x_replacement_esn
           INTO l_alt_status, l_alt_replace
           FROM table_x_alt_esn e
          WHERE e.x_alt_esn2case = r_case.objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RESULT := 'Alt ESN record not found';
      END;

      IF l_alt_status = 'CLOSED'
      THEN
         RESULT := 'Case already processed';
      END IF;

      IF l_alt_replace IS NOT NULL
      THEN
         RESULT := 'New ESN already linked to case';
      END IF;

      BEGIN
         IF r_case.x_require_return <> 1
         THEN
            l_cond := 'Closed';
         ELSE
            l_cond := 'Open';
         END IF;

         SELECT objid
           INTO l_lst_objid
           FROM table_gbst_lst
          WHERE title = l_cond;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_lst_objid := NULL;
      END;

      BEGIN
         IF r_case.x_require_return <> 2
         THEN
            l_cond := 'Shipped';
         ELSE
            l_cond := 'Received';
         END IF;

         SELECT 'x'
           INTO l_void
           FROM table_gbst_elm e
          WHERE title = l_cond AND e.gbst_elm2gbst_lst = l_lst_objid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RESULT := 'Error In The Application Status Codes';
      END;

      BEGIN
         SELECT 'x'
           INTO l_void
           FROM table_x_code_table
          WHERE x_code_name = 'EXCHANGE PARTNER';
      EXCEPTION
         WHEN OTHERS
         THEN
            RESULT := 'Default Warehouse Dealer Not Found';
      END;

      IF     LENGTH (TRIM (r_case.x_esn)) <> 11
         AND LENGTH (TRIM (r_case.x_esn)) <> 15
      THEN
         RESULT := 'Original ESN Missing from Case';
      END IF;

      update_exch_case_batch_prc (r_case.objid,
                                  esn,
                                  tracking,
                                  userid,
                                  gbstobjid,
                                  l_result
                                 );

      IF NVL (TRIM (l_result), ' ') <> ' '
      THEN
         RESULT := l_result;
      END IF;
   END exchangeesn;

--#############################################################################################
--#############################################################################################
/*************************************************************************
* Procedure: Send_Cases
* Purpose  : To send to OFS those cases that should be process by Intellitrak
**************************************************************************/
   PROCEDURE send_cases
   AS
      /*  CURSOR c_Cases
      IS
        SELECT a.rowid,a.*
        FROM x_migr_extra_info a
       WHERE a.x_flag_migration = 'Y'
         AND EXISTS (SELECT 'x'
                       FROM table_case b
                      WHERE b.objid = a.x_migra2x_case
                        AND b.x_repl_part_num IS NOT NULL)
      FOR UPDATE OF x_flag_migration;
      */
      CURSOR c_cases
      IS
         SELECT        a.ROWID, a.*
                  FROM table_x_part_request a
                 WHERE a.x_status = 'PENDING'
                   AND a.x_repl_part_num IS NOT NULL
         FOR UPDATE OF x_flag_migration;

      /**** CR5336: Added cursor to include case data *****/
      CURSOR c_case_title (c_objid IN NUMBER)
      IS
         SELECT c.*, g.title g_status, f.e_mail
           FROM table_gbst_elm g, table_case c, table_contact f
          WHERE c.casests2gbst_elm = g.objid(+)
            AND c.case_reporter2contact = f.objid(+)
            AND c.objid = c_objid;

            --AND c.X_REPL_PART_NUM IS NOT NULL;
        --*****************Begin comment out  by Jasmine on 09/08/2006***********************--
       /**** CR5336: Cursor to get Fulfillment center name ***/
      /*
       CURSOR c_getFF(c_part_num in varchar2)
        IS
            SELECT d.domain,c.x_ff_name,c.x_ff_code
            FROM table_part_class a,
                 mtm_part_class7_x_ff_center1  b,
                 table_x_ff_center c,
                 table_part_num d
           WHERE 1=1
             AND d.part_number = c_part_num
             AND a.objid = d.PART_NUM2PART_CLASS
             AND a.objid = b.part_class2ff_center
             AND b.FF_CENTER2PART_CLASS = c.objid;
       */
        --*****************End comment out  by Jasmine on 09/08/2006***********************--
      my_code              NUMBER;
      my_errm              VARCHAR2 (32000);
      /*** CR5336: FF variables ***/
      --v_ff_name varchar2(80);
      v_ff_code            VARCHAR2 (80);
      v_carrier            VARCHAR2 (80);
      v_method             VARCHAR2 (80);
      v_ship_to_address1   VARCHAR2 (240);      --Add by Jasmine on 09/08/2006
      v_ship_to_address2   VARCHAR2 (240);      --Add by Jasmine on 09/08/2006
   BEGIN
--    CheckReplPartInNull;
      FOR r_cases IN c_cases
      LOOP
         v_ff_code := r_cases.x_ff_center;
         v_carrier := r_cases.x_courier;
         v_method := r_cases.x_shipping_method;

         FOR r_case_title IN c_case_title (r_cases.request2case)
         LOOP
            IF INSTR (NVL (r_case_title.alt_address, ''), '|') = 0
            THEN
               v_ship_to_address1 := r_case_title.alt_address;
               v_ship_to_address2 := NULL;
            ELSE
               v_ship_to_address1 :=
                  SUBSTR (r_case_title.alt_address,
                          1,
                          INSTR (r_case_title.alt_address, '|') - 1
                         );
               v_ship_to_address2 :=
                  SUBSTR (r_case_title.alt_address,
                          INSTR (r_case_title.alt_address, '|', -1) + 1
                         );
            END IF;

            --*****************End added by Jasmine on 09/08/2006***********************--
            IF (   LENGTH (v_ship_to_address1) < 9
                OR v_ship_to_address1 IN
                                 ('No Address Provided', 'No Info Available')
                OR LTRIM (RTRIM (r_case_title.alt_first_name)) IS NULL
               )                                                      --CR5980
            THEN
               UPDATE table_x_part_request
                  SET x_flag_migration = 'E',
                      x_date_process = SYSDATE,
                      x_problem = 'Invalid Address: Address is too short',
                      x_status = 'PENDING'
                WHERE CURRENT OF c_cases;
            ELSIF r_cases.x_ff_center IS NULL
            THEN
               UPDATE table_x_part_request
                  SET x_flag_migration = 'E',
                      x_date_process = SYSDATE,
                      x_problem = 'Invalid FF Center: FF Center is null',
                      x_status = 'PENDING'
                WHERE CURRENT OF c_cases;
            ELSE
               BEGIN
                  INSERT INTO tf.tf_order_interface@ofsprd
                              (title, status,
                               tf_part_number,
                               po_number,
                               ship_to_name,
                               ship_to_address, ship_to_address2,
                               --Add by Jasmine on 09/08/2006
                               ship_to_city,
                               ship_to_state,
                               ship_to_zip,
                               ship_to_phone, quantity,
                               ship_to_email,
                               customer_number,
                               store_number, SOURCE,
                               creation_date,
                               delivery_date, ff_name,
                               carrier, method
                              )
                       VALUES (r_case_title.title, r_case_title.g_status,
                               r_cases.x_repl_part_num,
                               r_case_title.id_number,
                                  r_case_title.alt_first_name
                               || ' '
                               || r_case_title.alt_last_name,
                               --r_case_title.ALT_ADDRESS,--Comment out by Jasmine on 09/08/2006
                               v_ship_to_address1,
                                                  --Add by Jasmine on 09/08/2006
                                                  v_ship_to_address2,
                               --Add by Jasmine on 09/08/2006
                               r_case_title.alt_city,
                               r_case_title.alt_state,
                               r_case_title.alt_zipcode,
                               r_case_title.alt_phone,                --CR5980
                                                      1,
                               r_case_title.e_mail,
                               --'TW640',                  --Commented out by Jasmine on 09/13/2006
                               DECODE (r_case_title.case_type_lvl2,
                                       'TRACFONE', 'TW640',
                                       'NET10', 'NW640',
                                       'TW640'
                                      ),      --Added by Jasmine on 09/13/2006
                               '0616960000013', 'CLARIFY',
                               TO_CHAR (TRUNC (SYSDATE)),
                               TO_CHAR (TRUNC (SYSDATE) + 3), v_ff_code,
                               v_carrier, v_method
                              );

                  UPDATE table_x_part_request
                     SET x_flag_migration = 'S',
                         x_date_process = SYSDATE,
                         x_problem = NULL,
                         x_status = 'PROCESSED'
                   WHERE CURRENT OF c_cases;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     my_code := SQLCODE;
                     my_errm := SQLERRM;

                     UPDATE table_x_part_request
                        SET x_flag_migration = 'E',
                            x_date_process = SYSDATE,
                            x_problem = my_code || ': ' || my_errm,
                            x_status = 'ONHOLD'
                      WHERE CURRENT OF c_cases;
               END;
            END IF;

            COMMIT;
         END LOOP;
      END LOOP;
   END send_cases;

--#############################################################################################
--#############################################################################################
/*************************************************************************
* Procedure: Bad_Address
* Purpose  : To process those cases that were not posible to be committed
*            because a bad address.
**************************************************************************/
   PROCEDURE bad_address (ip_case_number IN VARCHAR2, ip_order_number IN NUMBER)
   AS
      l_status_id       table_gbst_elm.objid%TYPE;
      p_error_number    NUMBER;
      p_error_message   VARCHAR2 (1000);
      l_sa              table_user.objid%TYPE;
      my_code           NUMBER;
      my_errm           VARCHAR2 (32000);
         /*
            TYPE c_Bad IS RECORD (
            tf_receipt_type   tf_receipt_headers.tf_receipt_type@ofsprd%TYPE,
            tf_receipt_number tf_receipt_headers.tf_receipt_number@ofsprd%TYPE,
            tf_part_number    tf_receipt_headers.tf_part_number@ofsprd%TYPE,
            t_case_number     tf_receipt_headers.attribute6@ofsprd%TYPE);

            r_Bad c_Bad;

            TYPE Bad_tab_type IS TABLE OF c_Bad index by binary_integer;

            Bad_tab Bad_tab_type;

            cursor c1 is
               select * from TF.TF_MWH_BAD_ADDRESS@ofsprd;

            cursor c2(c_tf_doc_number in varchar2) is
               select
                  rh.tf_receipt_type,
                  rh.tf_receipt_number,
                  rh.tf_part_number,
                  rh.attribute6 t_case_number
               from
                  tf.tf_receipt_lines@ofsprd rl,
                  tf.tf_receipt_headers@ofsprd rh
               where 1=1
                  AND rl.tf_part_number = rh.tf_part_number
                  AND rl.tf_receipt_number = rh.tf_receipt_number
                  AND rl.tf_receipt_type = rh.tf_receipt_type
                  and rl.TF_RECEIVED_LOC = rh.TF_RECEIVED_LOC
                  --
                  AND rh.ATTRIBUTE7 = 'BAD_ADD'
                  and rh.TF_RECEIPT_TYPE = 'R2'
                  and rh.TF_RECEIVED_LOC = 'MM_IO'
                  AND rh.tf_doc_number = c_tf_doc_number;

            cursor c3(c_tf_serial_num in varchar2, c_tf_receipt_number in number) is
               SELECT 'x' col1
               FROM tf.migr_case_log@ofsprd
               WHERE process_flag = 'P'
                  AND esn = c_tf_serial_num
                  AND receipt_number = c_tf_receipt_number;

            c3_rec c3%rowtype;

      -- CR 4691 End
            cnt number := 0;
            l_esn  table_case.x_esn%Type;
            l_objid  table_case.objid%type;
         */
      l_error           BOOLEAN;
   BEGIN
      SELECT objid
        INTO l_status_id
        FROM table_gbst_elm
       WHERE title = 'Modify';

      SELECT objid
        INTO l_sa
        FROM table_user t
       WHERE login_name = 'sa';

      /*
          FOR c1_rec IN c1 LOOP
             FOR c2_rec IN c2(c1_rec.tf_doc_number) LOOP
                open c3(c2_rec.t_case_number,c2_rec.tf_receipt_number);
                FETCH c3 INTO c3_rec;
                IF c3%notfound THEN
                   cnt := cnt + 1;
                   Bad_tab(cnt).tf_receipt_type   := c2_rec.tf_receipt_type;
                   Bad_tab(cnt).tf_receipt_number := c2_rec.tf_receipt_number;
                   Bad_tab(cnt).tf_part_number    := c2_rec.tf_part_number;
                   Bad_tab(cnt).t_case_number     := c2_rec.t_case_number;
                END IF;
                close c3;
             END loop;
          END loop;
      */

      /*
            IF cnt > 0 THEN
               FOR j IN Bad_tab.FIRST..Bad_tab.LAST loop
                  COMMIT;
                  r_Bad.tf_receipt_type   := Bad_tab(j).tf_receipt_type;
                  r_Bad.tf_receipt_number := Bad_tab(j).tf_receipt_number;
                  r_Bad.tf_part_number    := Bad_tab(j).tf_part_number;
                  r_Bad.t_case_number     := Bad_tab(j).t_case_number;

                  p_error_message := '';
                  l_error := false;
      */          /*IF p_error_message IS NULL THEN*/   --CR4878
      IF ip_order_number > 0
      THEN
         BEGIN
            p_error_number := 0;
            p_error_message := NULL;
            l_error := FALSE;
            -- Even if ESN couldn't be retrieved, update case status and remove units
            --UPDATE_REOPEN_WHCASE_PRC(r_Bad.t_case_number, l_sa, l_status_id, p_error_message);
            update_reopen_whcase_prc (ip_case_number,
                                      l_sa,
                                      l_status_id,
                                      p_error_message
                                     );

            IF p_error_number <> 0
            THEN
               p_error_number := 4;
               l_error := TRUE;
            END IF;

            -- Flag the case number as 'P' (processed)
            IF p_error_number = 0
            THEN
               --Insert_log(r_Bad.t_case_number, r_Bad.tf_receipt_number, null, 'P');
               insert_log (ip_case_number, ip_order_number, NULL, 'P');
            ELSIF p_error_number IN (1, 2, 3)
            THEN
               --Insert_log(r_Bad.t_case_number, r_Bad.tf_receipt_number, p_error_message, 'P');
               insert_log (ip_case_number,
                           ip_order_number,
                           p_error_message,
                           'P'
                          );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               my_code := SQLCODE;
               my_errm := SQLERRM;
               l_error := TRUE;
               p_error_message := my_code || ': ' || my_errm;
         END;

         IF l_error
         THEN
            ROLLBACK;

            INSERT INTO x_migr_extra_info
                        (x_flag_migration, x_date_process,
                         x_problem
                        )
                 VALUES ('E_BA', SYSDATE,
                            'Case number '
                         || ip_case_number
                         || '. '
                         || p_error_message
                        );

            --Insert_log(r_Bad.t_case_number, r_Bad.tf_receipt_number, p_error_message, 'F');
            insert_log (ip_case_number, ip_order_number, p_error_message, 'F');
         END IF;

         COMMIT;
         --END LOOP;
      --END IF;
      END IF;
   END bad_address;

--#############################################################################################
--#############################################################################################
/*************************************************************************
* Procedure: Phone_Shipping
* Purpose  : To process those cases that were shipped
**************************************************************************/
   PROCEDURE phone_shipping
   AS
      l_status_id       table_gbst_elm.objid%TYPE;
      p_error_message   VARCHAR2 (100);
      l_sa              table_user.objid%TYPE;
      r_table_case      table_case%ROWTYPE;
      l_condition       table_condition.condition%TYPE;
      l_case_history    VARCHAR2 (32700);

      CURSOR c_shipping
      IS
         SELECT DISTINCT ah.tp_location_code, ah.shipment_num,
                         ah.customer_po_number p_case_number,
                         ah.waybill_number p_tracking_number,
                         ad.item_code_1 p_part_number,
                         asn.product_code_1 p_esn
                    FROM tf_asni_header@ofsprd ah,
                         tf_asni_detail@ofsprd ad,
                         tf_asni_serial_number@ofsprd asn
                   WHERE ah.tp_location_code = ad.tp_location_code
                     AND ad.tp_location_code = asn.tp_location_code
                     AND ah.shipment_num = ad.shipment_num
                     AND ad.shipment_num = asn.shipment_num
                     AND SUBSTR (LTRIM (ah.order_number), 1, 1) = '9'
                     --AND ah.tp_location_code = 'MM_IO'
                     AND ah.attribute9 IS NULL;
   BEGIN
      --CR4541 Starts
      /*    SELECT objid
      INTO l_status_id
      FROM table_gbst_elm
      WHERE title = 'Modify';*/
      BEGIN
         SELECT objid
           INTO l_status_id
           FROM table_gbst_elm g
          WHERE g.gbst_elm2gbst_lst = (SELECT objid
                                         FROM table_gbst_lst
                                        WHERE title = 'Activity Name')
            AND g.title = 'Ship';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_status_id := NULL;
      END;

      --CR4541 Ends
      SELECT objid
        INTO l_sa
        FROM table_user t
       WHERE login_name = 'sa';

      FOR r_shipping IN c_shipping
      LOOP
         COMMIT;

         IF r_shipping.p_case_number IS NOT NULL
         THEN
            BEGIN
               SELECT *
                 INTO r_table_case
                 FROM table_case c
                WHERE c.id_number = r_shipping.p_case_number;

               SELECT condition
                 INTO l_condition
                 FROM table_condition
                WHERE objid = r_table_case.case_state2condition;

               IF l_condition <> 4
               THEN
                  IF    TRIM (r_table_case.x_case_type) =
                                                        'Technology Exchange'
                     OR TRIM (r_table_case.x_case_type) = 'Exchange'
                  THEN
                     IF     r_table_case.s_title = 'SIM CARD EXCHANGE'
                        AND r_shipping.p_esn = '999999999999999'
                     THEN
                        r_shipping.p_esn := '---';
                     END IF;

                     exchangeesn (r_table_case,
                                  r_shipping.p_esn,
                                  r_shipping.p_tracking_number,
                                  l_status_id,
                                  l_sa,
                                  p_error_message
                                 );

                     IF p_error_message IS NULL
                     THEN
                        UPDATE tf.tf_asni_header@ofsprd
                           SET attribute9 = 'OK',
                               attribute_date_3 = SYSDATE
                         WHERE tp_location_code = r_shipping.tp_location_code
                           AND shipment_num = r_shipping.shipment_num;
                     ELSE
                        INSERT INTO x_migr_extra_info
                                    (x_flag_migration, x_date_process,
                                     x_problem
                                    )
                             VALUES ('E_PS', SYSDATE,
                                     p_error_message
                                    );

                        UPDATE tf.tf_asni_header@ofsprd
                           SET attribute9 = p_error_message,
                               attribute_date_3 = SYSDATE
                         WHERE tp_location_code = r_shipping.tp_location_code
                           AND shipment_num = r_shipping.shipment_num;
                     END IF;
                  ELSIF    TRIM (r_table_case.x_case_type) = 'Warehouse'
                        OR TRIM (r_table_case.x_case_type) = 'Warranty'
                  THEN
                     l_case_history := r_table_case.case_history;
                     l_case_history :=
                           l_case_history
                        || CHR (13)
                        || ' Shipped on '
                        || TO_CHAR (SYSDATE);
                     l_case_history :=
                           l_case_history
                        || CHR (13)
                        || ' ESN Shipped : '
                        || r_shipping.p_esn;
                     l_case_history :=
                           l_case_history
                        || CHR (13)
                        || ' Tracking Number : '
                        || r_shipping.p_tracking_number;

                     UPDATE table_case
                        SET case_history = l_case_history,
                            x_po_number = r_shipping.p_tracking_number,
                            x_stock_type = r_shipping.p_esn
                      WHERE objid = r_table_case.objid;

                     p_error_message := NULL;
                     update_exch_case_batch_prc (r_table_case.objid,
                                                 r_shipping.p_esn,
                                                 r_shipping.p_tracking_number,
                                                 l_sa,
                                                 l_status_id,
                                                 p_error_message
                                                );

                     IF p_error_message IS NULL
                     THEN
                        UPDATE tf.tf_asni_header@ofsprd
                           SET attribute9 = 'OK',
                               attribute_date_3 = SYSDATE
                         WHERE tp_location_code = r_shipping.tp_location_code
                           AND shipment_num = r_shipping.shipment_num;
                     ELSE
                        INSERT INTO x_migr_extra_info
                                    (x_flag_migration, x_date_process,
                                     x_problem
                                    )
                             VALUES ('E_PS', SYSDATE,
                                     p_error_message
                                    );

                        UPDATE tf.tf_asni_header@ofsprd
                           SET attribute9 = p_error_message,
                               attribute_date_3 = SYSDATE
                         WHERE tp_location_code = r_shipping.tp_location_code
                           AND shipment_num = r_shipping.shipment_num;
                     END IF;
                  ELSE
                     INSERT INTO x_migr_extra_info
                                 (x_flag_migration, x_date_process,
                                  x_problem
                                 )
                          VALUES ('E_PS', SYSDATE,
                                  'The Case has a not valid Type'
                                 );

                     UPDATE tf.tf_asni_header@ofsprd
                        SET attribute9 = 'The Case has a not valid Type',
                            attribute_date_3 = SYSDATE
                      WHERE tp_location_code = r_shipping.tp_location_code
                        AND shipment_num = r_shipping.shipment_num;
                  END IF;
               ELSE
                  -- The case was already closed
                  UPDATE tf.tf_asni_header@ofsprd
                     SET attribute9 = 'OK',
                         attribute_date_3 = SYSDATE
                   WHERE tp_location_code = r_shipping.tp_location_code
                     AND shipment_num = r_shipping.shipment_num;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  INSERT INTO x_migr_extra_info
                              (x_flag_migration, x_date_process, x_problem
                              )
                       VALUES ('E_PS', SYSDATE, 'The Case was not found.'
                              );

                  UPDATE tf.tf_asni_header@ofsprd
                     SET attribute9 = 'The Case was not found.',
                         attribute_date_3 = SYSDATE
                   WHERE tp_location_code = r_shipping.tp_location_code
                     AND shipment_num = r_shipping.shipment_num;
               WHEN OTHERS
               THEN
                  DECLARE
                     error_msg   VARCHAR2 (1000) := SQLERRM;
                  BEGIN
                     INSERT INTO x_migr_extra_info
                                 (x_flag_migration, x_date_process, x_problem
                                 )
                          VALUES ('E_PS', SYSDATE, error_msg
                                 );

                     UPDATE tf.tf_asni_header@ofsprd
                        SET attribute9 = error_msg,
                            attribute_date_3 = SYSDATE
                      WHERE tp_location_code = r_shipping.tp_location_code
                        AND shipment_num = r_shipping.shipment_num;
                  END;
            END;

            COMMIT;
         END IF;
      END LOOP;
   END phone_shipping;

--#############################################################################################
--#############################################################################################
/*************************************************************************
* Procedure: Phone_Receive
* Purpose  : To process those cases where the phones were receive in the
*            Warehouse. New requirements for non pending cases
**************************************************************************/
   PROCEDURE phone_receive
   AS
      l_sa               table_user.objid%TYPE;
      r_table_case       table_case%ROWTYPE;
      l_title            table_gbst_elm.title%TYPE;
      l_v                NUMBER (2);                  --number of valid cases
      l_np               NUMBER (2);         --GC number of non-pending cases
      l_np_status        table_gbst_elm.title%TYPE;
                                     --GC description of the non-pending case
      --    l_nv                number(2);  --number of not valid cases
      --    dummy               varchar2(1);
      l_elm_objid        table_gbst_elm.objid%TYPE;
      l_error            VARCHAR2 (200);
      l_case_objid       table_case.objid%TYPE;
      l_case_id          table_case.id_number%TYPE;
      l_case_id_new      table_case.id_number%TYPE;
      l_case_history     VARCHAR2 (32700);
      my_code            NUMBER;
      my_errm            VARCHAR2 (32000);

-- CR 4691 Starts
      TYPE c_receive IS RECORD (
         tf_receipt_type     tf_receipt_headers.tf_receipt_type@ofsprd%TYPE,
         tf_receipt_number   tf_receipt_headers.tf_receipt_number@ofsprd%TYPE,
         tf_part_number      tf_receipt_headers.tf_part_number@ofsprd%TYPE,
         t_esn               tf_receipt_lines.tf_serial_num@ofsprd%TYPE,
         tf_reason_code      tf_receipt_lines.tf_reason_code@ofsprd%TYPE
      );

      r_receive          c_receive;

      TYPE receive_tab_type IS TABLE OF c_receive
         INDEX BY BINARY_INTEGER;

      receive_tab        receive_tab_type;

/*      CURSOR c_Receive
      IS
      SELECT DISTINCT rh.tf_receipt_type,
         rh.tf_receipt_number,
         rh.tf_part_number,
         rl.tf_serial_num t_esn,
         rl.tf_reason_code
      FROM ont.oe_order_lines_all@ofsprd l, ont.oe_order_headers_all@ofsprd h,
      tf.tf_receipt_headers@ofsprd rh, tf.tf_receipt_lines@ofsprd rl, tf.tf_of_item_v@ofsprd itm
      WHERE h.header_id = l.header_id
      AND TO_CHAR(h.order_number) = rh.tf_doc_number
      AND rh.tf_receipt_type = rl.tf_receipt_type
      AND rh.tf_receipt_number = rl.tf_receipt_number
      AND rh.tf_part_number = rl.tf_part_number
      AND itm.item_id = l.inventory_item_id
      AND itm.part_number = rh.tf_part_number
      AND rh.ATTRIBUTE7 = 'PHONE_REC'
      AND l.RETURN_REASON_CODE = 'PHONE_REC'
      AND NOT EXISTS (
      SELECT 'x'
      FROM migr_case_log@ofsprd
      WHERE process_flag = 'P'
      AND esn = rl.tf_serial_num
      AND receipt_number = rh.tf_receipt_number);*/
-- CR 4691 Ends
      CURSOR c_case (pc_esn IN VARCHAR2, cond IN VARCHAR2)
      IS
         SELECT objid, title, x_case_type, gbst_elm_status, id_number
           FROM (SELECT   c.objid, c.title, c.x_case_type,
                          s.title gbst_elm_status, c.id_number
                     FROM table_case c, table_gbst_elm s
                    WHERE c.casests2gbst_elm = s.objid
                      AND c.x_esn = pc_esn
                      AND (c.s_title,
                           UPPER (c.x_case_type),
                           c.casests2gbst_elm
                          ) IN (
                             SELECT m.title, m.TYPE, gg.objid
                               FROM x_migr_conf m, table_gbst_elm gg
                              WHERE m.status = gg.s_title
                                AND m.active = 'Y'
                                AND (   (    gg.s_title <> 'PENDING'
                                         AND 1 = DECODE (cond, '<>', 1, 0)
                                        )
                                     OR (    gg.s_title = 'PENDING'
                                         AND 1 = DECODE (cond, '=', 1, 0)
                                        )
                                    ))
                 ORDER BY c.objid DESC)
          WHERE ROWNUM = 1;

-- CR 4691 Starts
      CURSOR c1
      IS
         SELECT *
           FROM tf_mwh_phone_receive1@ofsprd;

      /*
         select tab1.tf_doc_number
            from
               (SELECT + LEADING(rh)
                        distinct rh.tf_doc_number
                  from
                        tf.tf_receipt_lines@ofsprd rl,
                        tf.tf_receipt_headers@ofsprd rh
                  where 1=1
                     AND rl.tf_part_number = rh.tf_part_number
                     AND rl.tf_receipt_number = rh.tf_receipt_number
                     AND rl.tf_receipt_type = rh.tf_receipt_type
                     and rl.TF_RECEIVED_LOC = rh.TF_RECEIVED_LOC
               --
                     AND rh.ATTRIBUTE7 = 'PHONE_REC'
                     and rh.TF_RECEIPT_TYPE = 'R2'
                     and rh.TF_RECEIVED_LOC = 'MM_IO') tab1
         where 1=1
            and exists (select + leading( h) use_nl(l) index(h OE_ORDER_HEADERS_U2)  1
                           from ont.oe_order_lines_all@ofsprd  l,
                                ont.oe_order_headers_all@ofsprd  h
                        where 1=1
                           AND l.RETURN_REASON_CODE||'' = 'PHONE_REC'
                           and l.header_id = h.header_id
                           AND h.order_number = tab1.tf_doc_number);*/
      CURSOR c2 (c_tf_doc_number IN VARCHAR2)
      IS
         SELECT rh.tf_receipt_type, rh.tf_receipt_number, rh.tf_part_number,
                rl.tf_serial_num t_esn, rl.tf_reason_code
           FROM tf.tf_receipt_lines@ofsprd rl,
                tf.tf_receipt_headers@ofsprd rh
          WHERE 1 = 1
            AND rl.tf_part_number = rh.tf_part_number
            AND rl.tf_receipt_number = rh.tf_receipt_number
            AND rl.tf_receipt_type = rh.tf_receipt_type
            AND rl.tf_received_loc = rh.tf_received_loc
            --
            AND rh.attribute7 = 'PHONE_REC'
            AND rh.tf_receipt_type = 'R2'
            AND rh.tf_received_loc = 'MM_IO'
            AND rh.tf_doc_number = c_tf_doc_number;

      CURSOR c3 (c_tf_serial_num IN VARCHAR2, c_tf_receipt_number IN NUMBER)
      IS
         SELECT 'x' col1
           FROM tf.migr_case_log@ofsprd
          WHERE process_flag = 'P'
            AND esn = c_tf_serial_num
            AND receipt_number = c_tf_receipt_number;

      c3_rec             c3%ROWTYPE;

-- CR 4691 End
      --CR4541 Starts
      CURSOR c_esn_shipped (c_case_objid IN NUMBER)
      IS
         SELECT *
           FROM table_act_entry
          WHERE act_entry2case = c_case_objid AND act_code = 1500;

      --ESN Shipped

      --1.29 revision start
      CURSOR get_site_part_count_c (p_esn VARCHAR2)
      IS
         SELECT COUNT (*) cnt
           FROM table_site_part
          WHERE x_service_id = p_esn AND LOWER (part_status) <> 'obsolete';

      l_intcount         INTEGER;

      CURSOR get_code_table_c (p_code_no VARCHAR2)
      IS
         SELECT *
           FROM table_x_code_table
          WHERE x_code_number = p_code_no;

      rec_code_table_c   get_code_table_c%ROWTYPE;
      --1.29 revision end
      r_esn_shipped      c_esn_shipped%ROWTYPE;
      is_esn_shipped     NUMBER;
      v_status           VARCHAR2 (20);
      v_message          VARCHAR2 (1000);
      cnt                NUMBER                      := 0;
--CR4541 Ends
   BEGIN
      SELECT objid
        INTO l_sa
        FROM table_user t
       WHERE login_name = 'sa';

      BEGIN
         SELECT objid
           INTO l_elm_objid
           FROM table_gbst_elm g
          WHERE g.gbst_elm2gbst_lst = (SELECT objid
                                         FROM table_gbst_lst
                                        WHERE title = 'Open')
            AND g.title = 'Received';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_elm_objid := NULL;
      END;

      FOR c1_rec IN c1
      LOOP
         FOR c2_rec IN c2 (c1_rec.tf_doc_number)
         LOOP
            OPEN c3 (c2_rec.t_esn, c2_rec.tf_receipt_number);

            FETCH c3
             INTO c3_rec;

            IF c3%NOTFOUND
            THEN
               cnt := cnt + 1;
               receive_tab (cnt).tf_receipt_type := c2_rec.tf_receipt_type;
               receive_tab (cnt).tf_receipt_number :=
                                                     c2_rec.tf_receipt_number;
               receive_tab (cnt).tf_part_number := c2_rec.tf_part_number;
               receive_tab (cnt).t_esn := c2_rec.t_esn;
               receive_tab (cnt).tf_reason_code := c2_rec.tf_reason_code;
            END IF;

            CLOSE c3;
         END LOOP;
      END LOOP;

      IF cnt > 0
      THEN
         FOR j IN receive_tab.FIRST .. receive_tab.LAST
         LOOP
            COMMIT;
            r_receive.tf_receipt_type := receive_tab (j).tf_receipt_type;
            r_receive.tf_receipt_number := receive_tab (j).tf_receipt_number;
            r_receive.tf_part_number := receive_tab (j).tf_part_number;
            r_receive.t_esn := receive_tab (j).t_esn;
            r_receive.tf_reason_code := receive_tab (j).tf_reason_code;
            l_error := NULL;
            l_case_id := NULL;

            IF r_receive.t_esn IS NULL
            THEN
               l_error := 'The receipt ESN cannot be null.';

               INSERT INTO x_migr_extra_info
                           (x_flag_migration, x_date_process, x_problem
                           )
                    VALUES ('E_PR', SYSDATE, l_error
                           );

               insert_log (r_receive.t_esn,
                           r_receive.tf_receipt_number,
                           l_error,
                           'F'
                          );
            ELSE
               --       IF r_Receive.t_esn IS NOT NULL THEN
               l_v := 0;
               l_np := 0;                                                --GC

               FOR r_case IN c_case (r_receive.t_esn, '=')
               LOOP
                  --Check for PENDING cases
                  BEGIN
                     l_case_id := r_case.id_number;
                     l_v := l_v + 1;
                  END;
               END LOOP;

               IF l_v = 0
               THEN
                  BEGIN
                     -- There are no valid PENDING cases, let's check 4 cases <> Pending
                     FOR r_case IN c_case (r_receive.t_esn, '<>')
                     LOOP
                        BEGIN
                           l_case_id := r_case.id_number;
                           l_np_status := r_case.gbst_elm_status;
                           --GC to include the status in the log message in OFS
                           l_np := l_np + 1;
                        END;
                     END LOOP;

                     IF l_np = 0
                     THEN
                        --If there are no non-pending cases...
                                             --There are no valid PENDING or NON-PENDING cases, therefore, we create a NO_CASE case
                        BEGIN
                           migra_create_case_pkg.sp_create_case
                                                            (r_receive.t_esn,
                                                             'NO CASE',
                                                             'Warehouse',
                                                             'No Case',
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             l_case_objid,
                                                             l_case_id_new
                                                            );
                           l_error :=
                                 'The receipt ESN '
                              || r_receive.t_esn
                              || ' has not valid cases. The NO_CASE case '
                              || l_case_id_new
                              || ' was created';

                           INSERT INTO x_migr_extra_info
                                       (x_flag_migration, x_date_process,
                                        x_problem
                                       )
                                VALUES ('E_PR', SYSDATE,
                                        l_error
                                       );

                           insert_log (r_receive.t_esn,
                                       r_receive.tf_receipt_number,
                                       l_error,
                                       'P'
                                      );
                        END;
                     --end of NO_CASE case creation
                     END IF;
                  END;
               END IF;
            END IF;

            IF l_case_id IS NOT NULL AND l_v > 0 AND l_np = 0
            THEN
               --GC: if there's a valid and pending case
               BEGIN
                  BEGIN
                     SELECT *
                       INTO r_table_case
                       FROM table_case c
                      WHERE c.id_number = l_case_id;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_error :=
                                'This should not happen. Case: ' || l_case_id;
                  END;

                  IF l_error IS NOT NULL
                  THEN
                     INSERT INTO x_migr_extra_info
                                 (x_flag_migration, x_date_process, x_problem
                                 )
                          VALUES ('E_PR', SYSDATE, l_error
                                 );

                     insert_log (r_receive.t_esn,
                                 r_receive.tf_receipt_number,
                                 l_error,
                                 'F'
                                );
                  ELSE
                     BEGIN
                        SELECT title
                          INTO l_title
                          FROM table_gbst_elm
                         WHERE objid = r_table_case.casests2gbst_elm;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_title := NULL;
                     END;

                     IF l_title = 'Closed' AND l_title IS NOT NULL
                     THEN
                        l_error :=
                              'The case '
                           || l_case_id
                           || ' is Closed, You can not update the notes.';

                        INSERT INTO x_migr_extra_info
                                    (x_flag_migration, x_date_process,
                                     x_problem
                                    )
                             VALUES ('E_PR', SYSDATE,
                                     l_error
                                    );

                        insert_log (r_receive.t_esn,
                                    r_receive.tf_receipt_number,
                                    l_error,
                                    'F'
                                   );
                     ELSE
                        BEGIN
                           SAVEPOINT my_insert;

                           INSERT INTO table_act_entry
                                       (objid, act_code, entry_time,
                                        addnl_info, act_entry2user,
                                        act_entry2case, entry_name2gbst_elm
                                       )
                                VALUES (sa.seq ('act_entry'), 2000, SYSDATE,
                                        'ESN Received', l_sa,
                                        r_table_case.objid, l_elm_objid
                                       );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              my_code := SQLCODE;
                              my_errm := SQLERRM;
                              l_error :=
                                    'The insertion in table_act_entry for case '
                                 || r_table_case.id_number
                                 || ' had the following error: '
                                 || my_code
                                 || ': '
                                 || my_errm;
                        END;

                        IF l_error IS NULL
                        THEN
                           BEGIN
                              l_case_history := r_table_case.case_history;

                              UPDATE table_case c
                                 SET case_history =
                                           TRIM (l_case_history)
                                        || CHR (10)
                                        || CHR (13)
                                        || '*** Logged by Integration *** '
                                        || CHR (10)
                                        || 'ESN Received on '
                                        || SYSDATE,
                                     site_time = SYSDATE,
                                     casests2gbst_elm =
                                        DECODE (l_elm_objid,
                                                NULL, casests2gbst_elm,
                                                l_elm_objid
                                               )
                               WHERE objid = r_table_case.objid;

                              --CR4541 Starts
                              OPEN c_esn_shipped (r_table_case.objid);

                              FETCH c_esn_shipped
                               INTO r_esn_shipped;

                              IF c_esn_shipped%NOTFOUND
                              THEN
                                 is_esn_shipped := 0;
                              ELSE
                                 is_esn_shipped := 1;
                              END IF;

                              CLOSE c_esn_shipped;

                              IF is_esn_shipped = 1
                              THEN
                                 igate.sp_close_case (l_case_id,
                                                      'sa',
                                                      'CLARIFY',
                                                      'Cust Exchanged Phone',
                                                      v_status,
                                                      v_message
                                                     );

                                 IF v_status <> 'S'
                                 THEN
                                    l_error :=
                                          ' The case number '
                                       || l_case_id
                                       || ' was not closed.';
                                    insert_log (r_receive.t_esn,
                                                r_receive.tf_receipt_number,
                                                l_error,
                                                'F'
                                               );
                                 END IF;

                                 --1.29 revision start
                                 OPEN get_site_part_count_c (r_receive.t_esn);

                                 FETCH get_site_part_count_c
                                  INTO l_intcount;

                                 CLOSE get_site_part_count_c;

                                 IF l_intcount > 0
                                 THEN
                                    OPEN get_code_table_c ('51');

                                    FETCH get_code_table_c
                                     INTO rec_code_table_c;

                                    CLOSE get_code_table_c;

                                    UPDATE table_part_inst
                                       SET x_part_inst_status = '51',
                                           status2x_code_table =
                                                        rec_code_table_c.objid
                                     WHERE part_serial_no = r_receive.t_esn;
                                 ELSE
                                    OPEN get_code_table_c ('50');

                                    FETCH get_code_table_c
                                     INTO rec_code_table_c;

                                    CLOSE get_code_table_c;

                                    UPDATE table_part_inst
                                       SET x_part_inst_status = '50',
                                           status2x_code_table =
                                                        rec_code_table_c.objid
                                     WHERE part_serial_no = r_receive.t_esn;
                                 END IF;
                              --1.29 revision end
                              END IF;
                           --CR4541 Ends
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 ROLLBACK TO SAVEPOINT my_insert;
                                 my_code := SQLCODE;
                                 my_errm := SQLERRM;
                                 l_error :=
                                       'The actualization of table_case for case '
                                    || r_table_case.id_number
                                    || ' had the following error: '
                                    || my_code
                                    || ': '
                                    || my_errm;
                           END;
                        END IF;

                        IF l_error IS NULL
                        THEN
                           insert_log (r_receive.t_esn,
                                       r_receive.tf_receipt_number,
                                       NULL,
                                       'P'
                                      );
                        ELSE
                           INSERT INTO x_migr_extra_info
                                       (x_flag_migration, x_date_process,
                                        x_problem
                                       )
                                VALUES ('E_PR', SYSDATE,
                                        l_error
                                       );

                           insert_log (r_receive.t_esn,
                                       r_receive.tf_receipt_number,
                                       l_error,
                                       'F'
                                      );
                        END IF;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     my_code := SQLCODE;
                     my_errm := SQLERRM;
                     l_error :=
                           'Unexpected error in Case: '
                        || l_case_id
                        || ': '
                        || my_code
                        || ': '
                        || my_errm;

                     INSERT INTO x_migr_extra_info
                                 (x_flag_migration, x_date_process, x_problem
                                 )
                          VALUES ('E_PR', SYSDATE, l_error
                                 );

                     insert_log (r_receive.t_esn,
                                 r_receive.tf_receipt_number,
                                 l_error,
                                 'F'
                                );
               END;
            ELSIF l_case_id IS NOT NULL AND l_v = 0 AND l_np > 0
            THEN
               --There's a non-pending case, update OFS but don't touch Clarify
               BEGIN
                  IF LENGTH (l_np_status) > 20
                  THEN
                     l_np_status := SUBSTR (l_np_status, 1, 20);
                  --in case the title is bigger than 20 chars
                  ELSE
                     l_np_status := RPAD (l_np_status, 20, ' ');
                  --if it's smaller, I fill with spaces, up to 20
                  END IF;

                  --build message string 35 chars 4 first part
                  l_error :=
                        'The status is '
                     || l_np_status
                     || '. The case number '
                     || l_case_id
                     || ' was not updated.';
                  --l_error := 'The status of this ESN is not pending. Case: ' || l_case_id; --obsolete message
                  insert_log (r_receive.t_esn,
                              r_receive.tf_receipt_number,
                              l_error,
                              'P'
                             );                   --in this case the flag is P
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     my_code := SQLCODE;
                     my_errm := SQLERRM;
                     l_error :=
                           'Unexpected error in Case: '
                        || l_case_id
                        || ': '
                        || my_code
                        || ': '
                        || my_errm;
                     insert_log (r_receive.t_esn,
                                 r_receive.tf_receipt_number,
                                 l_error,
                                 'F'
                                );
               END;
            --End of new section
            END IF;

            COMMIT;
         END LOOP;
      END IF;
   END phone_receive;

   /*************************************************************************
   * Procedure: TransferPromotions
   * Purpose  : To transfer all promotions from a given ESN to another
   *            This procedure hasn't a commit sentences therefore a commit
   *            sentence should be included after the execution of it.
   *            Only active promotions will be moved.
   **************************************************************************/
   PROCEDURE transferpromotions (
      --p_OldEsn        IN VARCHAR2, --commented out by Jasmine on 09/08/2006
      p_objid           IN       NUMBER,     -- Added by Jasmine on 09/08/2006
      p_newesn          IN       VARCHAR2,
      p_error_number    OUT      NUMBER,
      p_error_message   OUT      VARCHAR2
   )
   IS
      v_oldesn_id           table_part_inst.objid%TYPE;
      v_newesn_id           table_part_inst.objid%TYPE;
      v_objid               table_x_group2esn.objid%TYPE;
      v_oldesn              table_part_inst.part_serial_no%TYPE;
      --Add by Jasmine
      r_esnpromotions       table_x_group2esn%ROWTYPE;
      my_code               NUMBER;
      my_errm               VARCHAR2 (32000);
      error_esn_not_found   EXCEPTION;
      error_transfering     EXCEPTION;
      error_historical      EXCEPTION;
      error_updating        EXCEPTION;
      PRAGMA EXCEPTION_INIT (error_esn_not_found, -20000);
      PRAGMA EXCEPTION_INIT (error_transfering, -20001);
      PRAGMA EXCEPTION_INIT (error_historical, -20002);
      PRAGMA EXCEPTION_INIT (error_updating, -20003);

      --************Begin modified  by Jasmine on 09/08/2006***************
      /*CURSOR c_EsnPromotions(cp_objid IN NUMBER ) IS
             SELECT *
               FROM table_x_group2esn
              WHERE groupesn2part_inst = cp_objid
               AND (  x_end_date IS NULL
                   OR x_end_date > SYSDATE)
             FOR UPDATE OF x_end_date;*/
      CURSOR c_esnpromotions (cp_objid IN NUMBER)
      IS
         SELECT objid, x_annual_plan x_annual_plan,
                case_promo2case groupesn2part_inst,
                case_promo2promo_grp groupesn2x_promo_group,
                x_end_date x_end_date, x_start_date x_start_date,
                case_promo2promotion groupesn2x_promotion
           FROM table_x_case_promotions
          WHERE case_promo2case = cp_objid
            AND NVL (x_end_date, SYSDATE) >= SYSDATE;

       --************End modified  by Jasmine on 09/08/2006***************
      --CR5848 Start
      CURSOR c_case (cp_objid IN NUMBER)
      IS
         SELECT s_title, x_model                                      --CR5848
           FROM table_case
          WHERE objid = cp_objid;

      r_case                c_case%ROWTYPE;

      CURSOR c_promogrp (pg_objid IN NUMBER)
      IS
         SELECT group_name
           FROM table_x_promotion_group
          WHERE objid = pg_objid
            AND SYSDATE BETWEEN x_start_date AND x_end_date;

      CURSOR c_get_tech (ip_model IN VARCHAR2)
      IS
         SELECT x_technology
           FROM table_part_num
          WHERE part_number = ip_model;

      r_get_tech            c_get_tech%ROWTYPE;
      r_promogrp            c_promogrp%ROWTYPE;
      l_no_dmpp_transfer    CHAR (1)                              := 'F';
      l_upg_case            CHAR (1)                              := 'F';
      l_grp_name            VARCHAR2 (20);
      l_tech                VARCHAR2 (200);
--CR5848 End
   BEGIN
      p_error_number := 0;
      p_error_message := NULL;

      -- Get objid of old ESN
      BEGIN
         --************Begin modified  by Jasmine on 09/08/2006***************
         /*
         SELECT   objid
           INTO   v_OldEsn_id
           FROM   table_part_inst
          WHERE   part_serial_no = TRIM(p_OldEsn);
         */
         SELECT x_esn
           INTO v_oldesn
           FROM table_case
          WHERE objid = p_objid;

         SELECT objid
           INTO v_oldesn_id
           FROM table_part_inst
          WHERE part_serial_no = TRIM (v_oldesn);
      --************End modified  by Jasmine on 09/08/2006***************
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20000,
                                        'The old ESN given ('
                                     || v_oldesn
                                     || ') is not valid.'
                                    );
      END;

      -- Get objid of new ESN
      BEGIN
         SELECT objid
           INTO v_newesn_id
           FROM table_part_inst
          WHERE part_serial_no = TRIM (p_newesn);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20000,
                                        'The new ESN given ('
                                     || p_newesn
                                     || ') is not valid.'
                                    );
      END;

--CR5848 Start
      OPEN c_case (p_objid);

      FETCH c_case
       INTO r_case;

      IF c_case%FOUND AND r_case.s_title LIKE '%UPGRADE%'
      THEN
         l_upg_case := 'T';

         OPEN c_get_tech (r_case.x_model);

         FETCH c_get_tech
          INTO r_get_tech;

         IF c_get_tech%FOUND
         THEN
            l_tech := r_get_tech.x_technology;
         ELSE
            l_tech := NULL;
         END IF;

         CLOSE c_get_tech;
      ELSE
         l_upg_case := 'F';
      END IF;

      CLOSE c_case;

--CR5848 End
       -- Create new esn promotions
      FOR r_esnpromotions IN c_esnpromotions (p_objid)
      LOOP
         --CR5848 Start
         l_no_dmpp_transfer := 'F';
         l_grp_name := NULL;

         OPEN c_promogrp (r_esnpromotions.groupesn2x_promo_group);

         FETCH c_promogrp
          INTO r_promogrp;

         IF c_promogrp%FOUND
         THEN
            l_grp_name := r_promogrp.group_name;
         ELSE
            l_grp_name := NULL;
         END IF;

         CLOSE c_promogrp;

         IF     NVL (l_upg_case, 'F') = 'T'
            AND NVL (l_grp_name, 'ZZZ') LIKE 'DBL%GRP'
            AND NVL (l_tech, 'ZZZ') <> 'TDMA'
         THEN
            l_no_dmpp_transfer := 'T';
         ELSE
            l_no_dmpp_transfer := 'F';
         END IF;

         IF l_no_dmpp_transfer = 'F'
         THEN
            --CR5848 End
            BEGIN
               BEGIN
                  v_objid := seq ('x_group2esn');

                  -- Create new esn promotions records
                  INSERT INTO table_x_group2esn
                              (objid, x_annual_plan,
                               groupesn2part_inst,
                               groupesn2x_promo_group,
                               x_end_date,
                               x_start_date,
                               groupesn2x_promotion
                              )
                       VALUES (v_objid, r_esnpromotions.x_annual_plan,
                               v_newesn_id,       -- Assigned 2 the new esn...
                               r_esnpromotions.groupesn2x_promo_group,
                               r_esnpromotions.x_end_date,
                               r_esnpromotions.x_start_date,
                               r_esnpromotions.groupesn2x_promotion
                              );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     raise_application_error
                                    (-20001,
                                        'Error tranfering promotions to ESN '
                                     || p_newesn
                                    );
               END;

               -- Create historical records in table_x_group_hist
               BEGIN
                  v_objid := seq ('x_group_hist');

                  INSERT INTO table_x_group_hist
                              (objid, x_annual_plan,
                               grouphist2part_inst,
                               grouphist2x_promo_group,
                               x_end_date,
                               x_start_date, x_action_date,
                               x_action_type, x_old_esn
                              )
                       VALUES (v_objid, r_esnpromotions.x_annual_plan,
                               v_newesn_id,
                               r_esnpromotions.groupesn2x_promo_group,
                               r_esnpromotions.x_end_date,
                               r_esnpromotions.x_start_date, SYSDATE,
                               'Handset transfer', v_oldesn
                              );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     raise_application_error
                              (-20002,
                                  'Error creating historical records of ESN '
                               || p_newesn
                              );
               END;
            --*****************Begin commented out  by Jasmine on 09/08/2006***********************--
             /*BEGIN

               -- Update x_end_date field of old esn records

              UPDATE table_x_group2esn SET x_end_date = SYSDATE
               WHERE CURRENT OF c_EsnPromotions;

               EXCEPTION
               WHEN OTHERS
               THEN
                  Raise_application_error( - 20003,
                  'Error updating x_end_date of ESN ' || v_OldEsn );
            END;*/
            --*****************End commented out  by Jasmine on 09/08/2006***********************--
            END;
         END IF;                                                  --CR5848 End
      END LOOP;

      --*****************Begin added  by Jasmine on 09/08/2006***********************--
      BEGIN
         -- Update x_end_date field of old esn records
         UPDATE table_x_group2esn
            SET x_end_date = SYSDATE
          WHERE NVL (x_end_date, SYSDATE) >= SYSDATE
            AND groupesn2part_inst = v_oldesn_id;
--CR5569-7
--            -- Update the Due Date of the new phone
--            UPDATE table_part_inst
--               SET warr_end_date = (SELECT  site_time
--                                      FROM  table_case
--                                     WHERE  objid = p_objid
--                                    )
--             WHERE part_serial_no = p_NewEsn;
--CR5569-7
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (-20003,
                                        'Error updating Due Date of ESN '
                                     || p_newesn
                                    );
      END;
   --*****************End added  by Jasmine on 09/08/2006***********************--
     --
     -- CR16379 Start kacosta 03/09/2012
     DECLARE
       --
       l_i_error_code    INTEGER := 0;
       l_v_error_message VARCHAR2(32767) := 'SUCCESS';
       --
     BEGIN
       --
       promotion_pkg.expire_double_if_esn_is_triple(p_esn           => p_newesn
                                                   ,p_error_code    => l_i_error_code
                                                   ,p_error_message => l_v_error_message);
       --
       IF (l_i_error_code <> 0) THEN
         --
         dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with error: ' || l_v_error_message);
         --
       END IF;
       --
     EXCEPTION
       WHEN others THEN
         --
         dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with Oracle error: ' || SQLCODE);
         --
     END;
     -- CR16379 End kacosta 03/09/2012
     --
   EXCEPTION
      WHEN OTHERS
      THEN
         my_code := SQLCODE;
         my_errm := SQLERRM;
         p_error_number := my_code;
         p_error_message := my_errm;
   END transferpromotions;

   /*************************************************************************
   * Procedure: RemovePromotions
   * Purpose  : To remove all promotions of given ESN
   *            This procedure hasn't a commit sentences therefore a commit
   *            sentence should be included after the execution of it.
   *            Only active promotions will be removed.
   **************************************************************************/
   PROCEDURE removepromotions (
      p_esn             IN       VARCHAR2,
      p_error_number    OUT      NUMBER,
      p_error_message   OUT      VARCHAR2
   )
   IS
      v_esn_id              table_part_inst.objid%TYPE;
      v_objid               table_x_group2esn.objid%TYPE;
      r_esnpromotions       table_x_group2esn%ROWTYPE;
      my_code               NUMBER;
      my_errm               VARCHAR2 (32000);
      error_esn_not_found   EXCEPTION;
      error_transfering     EXCEPTION;
      error_historical      EXCEPTION;
      error_updating        EXCEPTION;
      PRAGMA EXCEPTION_INIT (error_esn_not_found, -20000);
      PRAGMA EXCEPTION_INIT (error_transfering, -20001);
      PRAGMA EXCEPTION_INIT (error_historical, -20002);
      PRAGMA EXCEPTION_INIT (error_updating, -20003);

      CURSOR c_esnpromotions (p_objid IN NUMBER)
      IS
         SELECT        *
                  FROM table_x_group2esn
                 WHERE groupesn2part_inst = p_objid
                   AND (x_end_date IS NULL OR x_end_date > SYSDATE)
         FOR UPDATE OF x_end_date;

      CURSOR c_esnpartinst (p_esn VARCHAR2)
      IS
         SELECT objid
           FROM table_part_inst
          WHERE part_serial_no = TRIM (p_esn)
            AND x_part_inst_status || '' <> '52';

      recesnpartinst        c_esnpartinst%ROWTYPE;
   BEGIN
      p_error_number := 0;
      p_error_message := NULL;

      -- Get objid of ESN
      OPEN c_esnpartinst (p_esn);

      FETCH c_esnpartinst
       INTO recesnpartinst;

      IF c_esnpartinst%NOTFOUND
      THEN
         CLOSE c_esnpartinst;

         raise_application_error (-20000,
                                     'The ESN given ('
                                  || p_esn
                                  || ') is not valid.'
                                 );
      END IF;

      CLOSE c_esnpartinst;

      v_esn_id := recesnpartinst.objid;

      -- Remove promotions
      FOR r_esnpromotions IN c_esnpromotions (v_esn_id)
      LOOP
         DBMS_OUTPUT.put_line ('inside loop 1');

         -- Create historical records in table_x_group_hist
         BEGIN
            v_objid := seq ('x_group_hist');

            INSERT INTO table_x_group_hist
                        (objid, x_annual_plan, grouphist2part_inst,
                         grouphist2x_promo_group,
                         x_end_date,
                         x_start_date, x_action_date, x_action_type,
                         x_old_esn
                        )
                 VALUES (v_objid, r_esnpromotions.x_annual_plan, v_esn_id,
                         r_esnpromotions.groupesn2x_promo_group,
                         r_esnpromotions.x_end_date,
                         r_esnpromotions.x_start_date, SYSDATE, 'Remove',
                         NULL
                        );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                              (-20002,
                                  'Error creating historical records of ESN '
                               || p_esn
                              );
         END;

         BEGIN
            DBMS_OUTPUT.put_line ('inside loop 2');

            -- Update x_end_date field of old esn records
            UPDATE table_x_group2esn
               SET x_end_date = SYSDATE
             WHERE CURRENT OF c_esnpromotions; --objid= r_EsnPromotions.objid;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                                      (-20003,
                                          'Error updating x_end_date of ESN '
                                       || p_esn
                                      );
         END;

         DBMS_OUTPUT.put_line ('update done');
      END LOOP;

      DBMS_OUTPUT.put_line ('outside loop 1');

-- Remove pending units
      DELETE      table_x_pending_redemption
            WHERE objid IN (
                     SELECT pend.objid
                       FROM table_site_part sp,
                            table_x_pending_redemption pend,
                            table_x_promotion pr
                      WHERE sp.x_service_id = p_esn
                        AND pend.x_pend_red2site_part = sp.objid
                        AND pr.objid = pend.pend_red2x_promotion
                     UNION
                     SELECT pend.objid
                       FROM table_part_inst pi,
                            table_x_pending_redemption pend,
                            table_x_promotion pr
                      WHERE pi.part_serial_no = p_esn
                        AND pend.pend_redemption2esn = pi.objid
                        AND pr.objid = pend.pend_red2x_promotion
                        AND pend.x_pend_type = 'REPL');

      UPDATE table_x_group2esn
         SET x_end_date = SYSDATE
       WHERE (x_end_date IS NULL OR x_end_date > SYSDATE)
         AND objid IN (
                SELECT g.objid
                  FROM table_x_group2esn g, table_part_inst pi
                 WHERE pi.part_serial_no = p_esn
                   AND g.groupesn2part_inst = pi.objid);

      --*****************Begin add  by Jasmine on 09/08/2006***********************--
      BEGIN
         -- null out: WARR_END_DATE from Part Inst
         UPDATE table_part_inst
            SET warr_end_date = NULL
          WHERE part_serial_no = p_esn;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
                               (-20003,
                                   'Error updating warranty end data of ESN '
                                || p_esn
                               );
      END;
   --*****************End add  by Jasmine on 09/08/2006***********************--
   EXCEPTION
      WHEN OTHERS
      THEN
         my_code := SQLCODE;
         my_errm := SQLERRM;
         p_error_number := my_code;
         p_error_message := my_errm;
   END removepromotions;
END temp_migra_intellitrack;
/