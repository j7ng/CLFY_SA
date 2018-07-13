CREATE OR REPLACE PACKAGE BODY sa.System_Test_Pkg
AS
PROCEDURE  clear_data_esn
(
   ip_esn      IN       VARCHAR2,
   op_result   OUT      VARCHAR2,
   op_msg      OUT      VARCHAR2
)
IS
   CURSOR c_part_inst (c_esn IN VARCHAR2)
   IS
      SELECT a.*, c.x_restricted_use, c.x_technology
        FROM table_part_inst a, table_mod_level b, table_part_num c
       WHERE a.part_serial_no = c_esn
         AND a.n_part_inst2part_mod = b.objid
         AND b.part_info2part_num = c.objid;
   CURSOR c_call_trans (c_esn IN VARCHAR2)
   IS
      SELECT objid
        FROM TABLE_X_CALL_TRANS
       WHERE x_service_id = c_esn;
   CURSOR c_site_part (c_esn IN VARCHAR2)
   IS
      SELECT *
        FROM table_site_part
       WHERE x_service_id = c_esn;
   v_exception_id        VARCHAR2 (5);
   v_exception_msg       VARCHAR2 (100);
   e_wipeout_exception   EXCEPTION;
BEGIN

   DBMS_OUTPUT.put_line(' Entered clear ESN Script');
   FOR r_part_inst IN c_part_inst (ip_esn)
   LOOP
         DBMS_OUTPUT.put_line ('Deleting SITE PART Record if the ESN Status is NEW');
		delete from table_site_part where table_site_part.OBJID in (select X_PART_INST2SITE_PART from table_part_inst
		where table_part_inst.PART_SERIAL_NO = r_part_inst.part_serial_no and  table_part_inst.x_domain = 'PHONES' and X_PART_INST_STATUS = '50');

		DBMS_OUTPUT.put_line ('Deleting SIM associated with IP_ESN');
          DELETE TABLE_x_sim_inv
          WHERE x_sim_serial_no IN (SELECT x_iccid FROM table_part_inst WHERE part_serial_no = r_part_inst.part_serial_no);
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING associated TABLE_X_GROUP2ESN for IP_ESN');
         DELETE TABLE_X_GROUP2ESN
          WHERE groupesn2part_inst = (SELECT objid FROM table_part_inst
          							WHERE part_serial_no = r_part_inst.part_serial_no);
         COMMIT;
         DBMS_OUTPUT.put_line ('Deleting part_inst for IP_ESN');
		 DELETE table_part_inst
          WHERE objid = r_part_inst.objid;
         COMMIT;
         DBMS_OUTPUT.put_line('UPDATING part_inst FOR ANY reserved lines TO the IP_ESN');
		 DELETE table_part_inst
          WHERE part_to_esn2part_inst = r_part_inst.objid;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING x_pi_hist FOR IP_ESN');
         DELETE TABLE_X_PI_HIST
          WHERE x_part_serial_no = r_part_inst.part_serial_no;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING x_contact_part_inst FOR IP_ESN');
         DELETE table_x_contact_part_inst
          WHERE x_contact_part_inst2part_inst = r_part_inst.objid;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING condition FOR IP_ESN CASE');
         DELETE table_condition
          WHERE objid IN (SELECT case_state2condition
                                 FROM table_case
                                WHERE x_esn = r_part_inst.part_serial_no);
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING cases FOR IP_ESN');
         DELETE table_case
          WHERE x_esn = r_part_inst.part_serial_no;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING OTA records');
         DELETE table_x_ota_features
          WHERE x_ota_features2part_inst = r_part_inst.objid;
         COMMIT;
         DELETE table_x_ota_ack
          WHERE x_ota_ack2x_ota_trans_dtl IN (
          							  SELECT objid
          							  	FROM table_x_ota_trans_dtl
          							  WHERE x_ota_trans_dtl2x_ota_trans IN (
                                      SELECT objid
                                        FROM table_x_ota_transaction
                                       WHERE x_esn =
                                                    r_part_inst.part_serial_no)
                                              );
         DELETE table_x_ota_trans_dtl
          WHERE x_ota_trans_dtl2x_ota_trans IN (
                                      SELECT objid
                                        FROM table_x_ota_transaction
                                       WHERE x_esn =
                                                    r_part_inst.part_serial_no);
         DELETE table_x_ota_transaction
          WHERE x_esn = r_part_inst.part_serial_no;
         COMMIT;
         DELETE TABLE_X_PSMS_OUTBOX
          WHERE x_esn = r_part_inst.part_serial_no;
         COMMIT;
   END LOOP;
   FOR r_call_trans IN c_call_trans (ip_esn)
   LOOP
      DBMS_OUTPUT.put_line ('DELETING red_card FOR IP_ESN redemptions');
      DELETE table_x_red_card
       WHERE red_card2call_trans = r_call_trans.objid;
       COMMIT;
      DBMS_OUTPUT.put_line ('DELETING code_hist FOR IP_ESN transactions');
      DELETE      TABLE_X_CODE_HIST
       WHERE code_hist2call_trans = r_call_trans.objid;
      COMMIT;
      DBMS_OUTPUT.put_line ('DELETING promo_hist FOR IP_ESN promotions');
      DELETE      TABLE_X_PROMO_HIST
       WHERE promo_hist2x_call_trans = r_call_trans.objid;
      COMMIT;
      DBMS_OUTPUT.put_line ('DELETING Ig_transaction RECORD FOR IP_ESN');
      DELETE gw1.ig_transaction
       WHERE action_item_id IN (SELECT task_id
                                  FROM table_task
                                 WHERE x_task2x_call_trans = r_call_trans.objid);
      COMMIT;
      DBMS_OUTPUT.put_line ('DELETING TASK RECORD FOR IP_ESN');
      DELETE table_task
       WHERE x_task2x_call_trans = r_call_trans.objid;
      COMMIT;
      DBMS_OUTPUT.put_line ('DELETING call_trans FOR IP_ESN transactions');
      DELETE TABLE_X_CALL_TRANS
       WHERE objid = r_call_trans.objid;
      COMMIT;
   END LOOP;
   FOR r_site_part IN c_site_part (ip_esn)
   LOOP
         DBMS_OUTPUT.put_line ('DELETING address RECORD FOR IP_ESN');
         DELETE table_address
          WHERE objid IN (SELECT cust_primaddr2address
                            FROM table_site
                           WHERE objid = r_site_part.site_objid);
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING contact RECORD FOR IP_ESN');
         DELETE table_contact
          WHERE objid IN (
                             SELECT contact_role2contact
                               FROM table_contact_role
                              WHERE contact_role2site = r_site_part.site_objid);
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING bus_site_role RECORD FOR IP_ESN');
         DELETE table_bus_site_role
          WHERE bus_site_role2site = r_site_part.site_objid;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING web_user RECORD FOR IP_ESN');
         DELETE table_web_user
          WHERE web_user2contact IN (
                             SELECT contact_role2contact
                               FROM table_contact_role
                              WHERE contact_role2site = r_site_part.site_objid);
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING contact_role RECORD FOR IP_ESN');
         DELETE table_contact_role
          WHERE contact_role2site = r_site_part.site_objid;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING click_plan_hist FOR IP_ESN');
         DELETE TABLE_X_CLICK_PLAN_HIST
          WHERE curr_hist2site_part = r_site_part.objid;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING pending_redemption FOR IP_ESN');
         DELETE table_x_pending_redemption
          WHERE x_pend_red2site_part = r_site_part.objid;
         COMMIT;
         DBMS_OUTPUT.put_line ('DELETING site_part FOR IP_ESN');
         DELETE table_site_part
          WHERE objid = r_site_part.objid;
         COMMIT;
   END LOOP;
   op_result := '0';
   op_msg := 'ESN:' || ip_esn || ' - SUCCESSFUL';
EXCEPTION
   WHEN e_wipeout_exception
   THEN
      ROLLBACK;
      op_result := v_exception_id;
      op_msg := v_exception_msg;
   WHEN OTHERS
   THEN
      ROLLBACK;
      v_exception_msg := SUBSTR (SQLERRM, 1, 100);
      op_result := '-100';
      op_msg := 'ESN:' || ip_esn || ' - ' || v_exception_msg;
END clear_data_esn;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
PROCEDURE clear_data_esn_list(
   ip_esn_list      IN       VARCHAR2,
   op_result   OUT      VARCHAR2,
   op_msg      OUT      VARCHAR2
)
IS
        l_esns VARCHAR2(5000);
        out_message VARCHAR2(5000);
	out_result VARCHAR2(5000);
	temp_message VARCHAR2(5000);
        temp_result VARCHAR2(5000);
	TYPE esn_tab_type IS TABLE OF VARCHAR2 (30)
	         INDEX BY BINARY_INTEGER;
        esn_tab_original   esn_tab_type;
	esn_tab            esn_tab_type;
	clear_esn_tab      esn_tab_type;
        l_found NUMBER;
        l NUMBER;
        i NUMBER;
BEGIN
	DBMS_OUTPUT.put_line('entering 1');
	l_esns := ip_esn_list;
	esn_tab := clear_esn_tab;
	esn_tab_original := clear_esn_tab;
        i := 1;
	WHILE LENGTH (l_esns) > 0
        LOOP
		     DBMS_OUTPUT.put_line('entering 1' || l_esns);
	         IF INSTR (l_esns, ',') = 0
	         THEN
	            esn_tab_original (i) := LTRIM (RTRIM (l_esns));
	            EXIT;
	         ELSE
	            esn_tab_original (i) :=
	                 LTRIM (RTRIM (SUBSTR (l_esns, 1, INSTR (l_esns, ',') - 1)));
	            l_esns :=
	                    LTRIM (RTRIM (SUBSTR (l_esns, INSTR (l_esns, ',') + 1)));
	            i := i + 1;
	         END IF;
        END LOOP;

        --Initialise l;
        l := 0;
        --REMOVE DUPLICATES IN AN ARRAY 5033
	FOR i IN esn_tab_original.FIRST .. esn_tab_original.LAST
	LOOP
	         DBMS_OUTPUT.put_line('present in esn_tab_original' || esn_tab_original (i));
                 l_found := 0;
	         FOR j IN i + 1 .. esn_tab_original.LAST
	         LOOP
	            IF esn_tab_original (j) = esn_tab_original (i)
	            THEN
	               l_found := 1;
	               EXIT;
	            END IF;
	         END LOOP;
	         --Revision 1.13.1.4
	         IF (   LENGTH (LTRIM (RTRIM (esn_tab_original (i)))) IS NULL
	             OR LENGTH (LTRIM (RTRIM (esn_tab_original (i)))) = 0
	            )
	         THEN
	            l_found := 1;
	         END IF;
	         --Revision 1.13.1.4
	         IF l_found = 0
	         THEN
                    DBMS_OUTPUT.put_line('adding into esn_tab' || esn_tab_original (i));
	            esn_tab (l) := esn_tab_original (i);
	            l := l + 1;
	         END IF;
        END LOOP;

	    DBMS_OUTPUT.put_line('entering 3');
        IF esn_tab.LAST >= 0
	      THEN
	         FOR i IN esn_tab.FIRST .. esn_tab.LAST
	         LOOP
	            temp_message := '';
				temp_result := '';
				DBMS_OUTPUT.put_line('clear_data_esn');
				clear_data_esn(esn_tab (i), temp_result,temp_message);
				out_message := out_message || ' ' || temp_message;
				out_result := out_result || ' ' || temp_result;
			 END LOOP;
      	END IF;
	    op_result := 0;
        op_msg := out_message;
END clear_data_esn_list;
END System_Test_Pkg;
/