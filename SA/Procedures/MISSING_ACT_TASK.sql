CREATE OR REPLACE PROCEDURE sa."MISSING_ACT_TASK"
AS
/**************************************************************************************************
    Copyright   2004 Tracfone  Wireless Inc. All rights reserved
    Name        :   MISSING_ACT_TASK
    Purpose     :   Creates action item if ACTIVATION or REACTIVATION is not found in TABLE_TASK
    Frequency   :   DBMS JOB scheduled that runs once in 24 hours (Every night at 10:00 pm)
    Platforms   :   Oracle 8.0.6 AND newer versions
    Revisions   :
    Version     Date        Who         Purpose
    -------     ----        ---         -------
    1.0         ???         ???         Initial Revision
    1.1         01/06/04    VAdapa      Exclude Port-In Customers (CR2364)
    1.3         12/09/05    VAdapa      CR4678
    1.4         12/20/05    Jrodriguez  CR4678 Include Deactivation
    1.5         12/20/05    Jrodriguez  CR4678 Include Deactivation
   1.6         12/21/05     VAdapa      CR4678 Include correct order type
   1.7         12/22/05     VAdapa     CR4678 Include carrier rules check
   1.8         06/20/06    VAdapa      CR5324 - Warranty Exchange Cases for Verizon Wireless

   NEW_PLSQL structure
   1.1         12/04/07     Clindner    CR7005
   1.2         04/30/08     Clindner    POST 10G fixes
   1.3         11/18/08     Clindner    CR8263
   1.4         06/16/09     Vadapa    CR10856
/***************************************************************************************************/
   /* NEW CVS STRUCTURE \PLSQL_CVS\PLSQL\SA\Procedures                                             */
   /* 1.1    03/12/10            NGuada      Migrate from PVCS to CVS                              */
   /* 1.2    05/06/10            Skuthadi    CR11971 ST_GSM  curosor to use brand name             */
   /* 1.3    06/26/12            ICanavan    CR20451 | CR20854: Add TELCEL Brand  modify cursor c1 */
   /*                                        remove STRAIGHT TALK and put in ORG_FLOW              */
/***************************************************************************************************/
/***************************************************************************************************/
   p_contact_objid       NUMBER                      := 272159182;
   p_call_trans_objid    NUMBER                      := 336529084;
   --   p_order_type          VARCHAR2 (300) := 'Activation';
   p_order_type          VARCHAR2 (300);
   p_bypass_order_type   NUMBER                      := 1;
   p_case_code           NUMBER;
   p_status_code         NUMBER;
   p_action_item_objid   NUMBER;

------------------------------------------------------------------------
-- rework this query to finish in under 12 hours cwl 4/30/08 POST 10G
------------------------------------------------------------------------
   CURSOR c1 (c_half_days IN NUMBER)
   IS
      SELECT TO_CHAR (ct.x_transact_date, 'dd-mon-yyyy hh:mi pm') tdate,
             ct.*
        FROM (SELECT          /*+ ORDERED_PREDICATES  */
                     DISTINCT ct.*
                         FROM table_x_call_trans ct
                        WHERE 1 = 1
                          AND ct.x_transact_date >=
                                            TRUNC (SYSDATE)
                                          - ((c_half_days) / 2)
                          AND ct.x_transact_date <
                                        TRUNC (SYSDATE)
                                      - ((c_half_days - 1) / 2)
                          AND ct.x_result = 'Completed'
                          AND ct.x_action_text IN
                                 ('ACTIVATION', 'REACTIVATION',
                                  'DEACTIVATION')
                          AND NOT EXISTS (
                                        SELECT 1
                                          FROM table_task t
                                         WHERE t.x_task2x_call_trans =
                                                                      ct.objid)
                          AND 0 =
                                 (CASE
                                     WHEN ct.x_action_text IN
                                               ('ACTIVATION', 'REACTIVATION')
                                        THEN 0
                                     WHEN ct.x_action_text = 'DEACTIVATION'
                                        THEN (SELECT COUNT (*)
                                                FROM table_x_block_deact bd
                                               WHERE 1 = 1
                                                 AND bd.x_code_name =
                                                                   ct.x_reason
                                                 AND (   bd.x_block_active = 1
                                                      OR (    bd.x_block_active =
                                                                             0
                                                          AND bd.x_removed_date >
                                                                 ct.x_transact_date
                                                         )
                                                     )
/*********************************************************************************************************
   11/18/08
   change for ricky ramon
   when x_block_active removed and set to 0 only pick call_trans greater than x_removed_date
*********************************************************************************************************/
                                                 AND bd.x_parent_id =
                                                        (SELECT p1.x_parent_id
                                                           FROM table_x_parent p1,
                                                                table_x_carrier_group cg1,
                                                                table_x_carrier c1
                                                          WHERE 1 = 1
                                                            AND p1.objid =
                                                                   cg1.x_carrier_group2x_parent
                                                            AND cg1.objid =
                                                                   c1.carrier2carrier_group
                                                            AND c1.objid =
                                                                   ct.x_call_trans2carrier)
                                                 AND ROWNUM < 2)
                                     ELSE 1
                                  END
                                 )) ct
       WHERE 1 = 1
         AND NOT EXISTS (SELECT 1
                           FROM table_part_inst
                          WHERE part_serial_no = ct.x_min AND x_port_in = 1)
         AND EXISTS (
                SELECT 1                                     --New JR 12/19/05
                  FROM table_site_part
                 WHERE x_min = ct.x_min
                   AND x_service_id = ct.x_service_id
                   AND objid = ct.call_trans2site_part)
/* 6/4/09 exclude NON_PPE */
        and not exists( select 1
                          from table_x_part_class_values v,
                               table_x_part_class_params n,
                               table_part_num pn,
                               table_mod_level ml,
                               table_part_inst pi,
                               table_bus_org bo
                         where 1=1
                           and pn.part_num2bus_org = bo.objid
                           -- and bo.org_id = 'STRAIGHT_TALK' -- ST_GSM CR11971
                           and bo.org_flow = '3' -- CR20451 | CR20854: Add TELCEL Brand
                           and v.value2part_class     = pn.part_num2part_class
                           and v.value2class_param    = n.objid
                           and n.x_param_name         = 'NON_PPE'
                           and pn.objid               = ml.part_info2part_num
                           and ml.objid               = pi.n_part_inst2part_mod
                           and pi.part_serial_no      = ct.x_service_id);
/* 6/4/09 exclude NON_PPE */
   CURSOR c2 (c_spobjid IN VARCHAR2)                         --New JR 12/19/05
   IS
      SELECT sp.*, cr.contact_role2contact contact_objid
        FROM table_contact_role cr, table_site_part sp
       WHERE cr.contact_role2site = sp.site_part2site AND sp.objid = c_spobjid;

------------------------------------------------------------------------
   CURSOR c_carr_rules_cdma (c_ip_carr_objid IN NUMBER)
   IS
      SELECT x_line_return_days
        FROM table_x_carrier_rules cr, table_x_carrier ca
       WHERE ca.carrier2rules_cdma = cr.objid AND ca.objid = c_ip_carr_objid;

   r_carr_rules_cdma     c_carr_rules_cdma%ROWTYPE;

   CURSOR c_carr_rules_gsm (c_ip_carr_objid IN NUMBER)
   IS
      SELECT x_line_return_days
        FROM table_x_carrier_rules cr, table_x_carrier ca
       WHERE ca.carrier2rules_gsm = cr.objid AND ca.objid = c_ip_carr_objid;

   r_carr_rules_gsm      c_carr_rules_gsm%ROWTYPE;

   CURSOR c_carr_rules_tdma (c_ip_carr_objid IN NUMBER)
   IS
      SELECT x_line_return_days
        FROM table_x_carrier_rules cr, table_x_carrier ca
       WHERE ca.carrier2rules_tdma = cr.objid AND ca.objid = c_ip_carr_objid;

   r_carr_rules_tdma     c_carr_rules_tdma%ROWTYPE;

   CURSOR c_tech (c_ip_esn IN VARCHAR2)
   IS
      SELECT x_technology
        FROM table_part_num pn, table_mod_level ml, table_part_inst pi
       WHERE pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pi.part_serial_no = c_ip_esn;

   r_tech                c_tech%ROWTYPE;
   l_line_retn_days      NUMBER                      := 0;
------------------------------------------------------------------------
BEGIN
   FOR i IN 1 .. 20                                              --  POST 10G
   LOOP
      DBMS_OUTPUT.put_line ('i loop:' || i);

      FOR c1_rec IN c1 (i)
      LOOP
         DBMS_OUTPUT.put_line (c1_rec.objid);

         OPEN c_tech (c1_rec.x_service_id);

         FETCH c_tech
          INTO r_tech;

         CLOSE c_tech;

         IF r_tech.x_technology = 'TDMA'
         THEN
            OPEN c_carr_rules_tdma (c1_rec.x_call_trans2carrier);

            FETCH c_carr_rules_tdma
             INTO r_carr_rules_tdma;

            l_line_retn_days := r_carr_rules_tdma.x_line_return_days;

            CLOSE c_carr_rules_tdma;
         ELSIF r_tech.x_technology = 'CDMA'
         THEN
            OPEN c_carr_rules_cdma (c1_rec.x_call_trans2carrier);

            FETCH c_carr_rules_cdma
             INTO r_carr_rules_cdma;

            l_line_retn_days := r_carr_rules_cdma.x_line_return_days;

            CLOSE c_carr_rules_cdma;
         ELSIF r_tech.x_technology = 'GSM'
         THEN
            OPEN c_carr_rules_gsm (c1_rec.x_call_trans2carrier);

            FETCH c_carr_rules_gsm
             INTO r_carr_rules_gsm;

            l_line_retn_days := r_carr_rules_gsm.x_line_return_days;

            CLOSE c_carr_rules_gsm;
         END IF;

         IF c1_rec.x_action_text = 'DEACTIVATION'
         THEN
            IF l_line_retn_days = 1
            THEN
               p_order_type := 'Deactivation';
            ELSE
               p_order_type := 'Suspend';
            END IF;
         ELSIF c1_rec.x_action_text IN ('ACTIVATION', 'REACTIVATION')
         THEN
            p_order_type := 'Activation';
         END IF;

         --FOR c2_rec IN c2 (c1_rec.x_service_id)
         FOR c2_rec IN c2 (c1_rec.call_trans2site_part)      --New JR 12/19/05
         LOOP
            igate.sp_create_action_item
                                     (c2_rec.contact_objid, --P_CONTACT_OBJID,
                                      c1_rec.objid,      --P_CALL_TRANS_OBJID,
                                      p_order_type,
                                      p_bypass_order_type,
                                      p_case_code,
                                      p_status_code,
                                      p_action_item_objid
                                     );
            DBMS_OUTPUT.put_line ('P_CONTACT_OBJID:' || p_contact_objid);
            DBMS_OUTPUT.put_line ('P_CALL_TRANS_OBJID:' || p_call_trans_objid);
            DBMS_OUTPUT.put_line ('P_ORDER_TYPE:' || p_order_type);
            DBMS_OUTPUT.put_line ('P_BYPASS_ORDER_TYPE:'
                                  || p_bypass_order_type
                                 );
            DBMS_OUTPUT.put_line ('P_CASE_CODE:' || p_case_code);
            DBMS_OUTPUT.put_line ('P_STATUS_CODE:' || p_status_code);
            DBMS_OUTPUT.put_line ('P_ACTION_ITEM_OBJID:'
                                  || p_action_item_objid
                                 );
         END LOOP;
      END LOOP;
   END LOOP;                                                      --  POST 10G
END missing_act_task;
/