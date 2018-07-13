CREATE OR REPLACE PROCEDURE sa."INBOUND_PHONE_INV_PRC"
AS
 ---------------------------------------------------------------------------------------------
 --$RCSfile: INBOUND_PHONE_INV_PRC.sql,v $
 --$Revision: 1.57 $
 --$Author: rpednekar $
 --$Date: 2017/02/14 21:24:54 $
 --$Log: INBOUND_PHONE_INV_PRC.sql,v $
 --Revision 1.57  2017/02/14 21:24:54  rpednekar
 --CR48072
 --
 --Revision 1.56  2017/02/08 20:44:40  rpednekar
 --CR48072
 --
 --Revision 1.55  2017/01/09 15:00:22  rpednekar
 --CR46897 AND 47353
 --
 --Revision 1.54  2016/09/07 21:20:55  rpednekar
 --CR44147 - Added condition for POSA while breaking association of cards in queue in clarify.
 --
 --Revision 1.53  2016/09/01 14:58:13  rpednekar
 --CR44147- Changes done to dequeque cards for new phones.
 --
   --Revision 1.52  2016/05/05 21:46:42  skota
   --Modified
   --
   --Revision 1.51  2016/05/04 19:15:27  skota
   --modified
   --
   --Revision 1.50  2016/05/04 15:41:14  skota
   --Modified for CR41652
   --
   --Revision 1.49  2016/01/07 19:00:45  rpednekar
   --40013 - Used new part class parameter SERIAL_NUM_CONVERSION for hex to dec conversion.
   --
   --Revision 1.48  2015/12/29 21:48:38  rpednekar
   --CR40013 - Changed acme cursor query.
   --
   --Revision 1.47  2015/08/18 17:23:59  pvenkata
   -- Merge CR34728 and the CR35619
   --
   --Revision 1.45  2015/08/03 20:18:28  vyegnamurthy
   --CR34728
   --
   --Revision 1.42  2015/06/22 13:38:21  vyegnamurthy
   --CR34956
   --
   --Revision 1.41  2015/03/24 17:36:46  pvenkata
   --CR32693-411 : X_BUY_AIR_TIME  for the GSM, Home_Center.
   --
   --Revision 1.40  2015/03/23 17:12:29  pvenkata
   --CR32693
   --
   --Revision 1.39  2015/01/12 21:54:24  clinder
   --CR31489
   --
   --Revision 1.38  2014/11/05 13:57:27  clinder
   --CR31489
   --
   --Revision 1.37  2014/10/27 19:04:29  oarbab
   --CR31173 closed cur if if exception is raised.
   --
   --Revision 1.36  2014/10/10 13:24:20  oarbab
   --added a note where change was added for CR31173
   --
   --Revision 1.35  2014/10/09 20:26:22  oarbab
   --*** empty log message ***
   --
   --Revision 1.34  2014/10/02 14:37:57  oarbab
   --CR30945 new function benefit_given
   --
   --Revision 1.32  2014/07/25 15:50:04  jarza
   --As per CR29653 modified procedure not to update x_iccid in table_part_inst based on part inst status
   --
   --Revision 1.31  2014/06/05 16:12:20  mvadlapally
   --CR28538 - Car Connection Post Rollout
   --
   --Revision 1.30  2014/05/21 20:58:30  akhan
   --Added intitializaion of the variable in the loop
   --
   --Revision 1.29  2014/05/09 19:05:07  cpannala
   --CR25490 dependent schema changes are not there in env
   --
   --Revision 1.28  2014/05/01 15:24:44  cpannala
   --CR25490 B2B changes merged on Osaman Changes for sit1
   --
   --Revision 1.27  2014/04/29 14:33:26  oarbab
   --merged with CR27015
   --
   --Revision 1.24  2014/03/14 15:32:04  ymillan
   --CR27015
   --
   --Revision 1.21  2013/11/15 22:47:34  icanavan
   --MODIFY ACME CURSOR ON TOP OF PRODUCTION
   --
   --Revision 1.19  2013/01/04 16:28:20  akhan
   --Added updating of the hex_serial_no on reextraction
   --
   --Revision 1.18  2012/11/12 16:23:16  icanavan
   --added SA
   --
   --Revision 1.17  2012/11/01 19:58:22  icanavan
   --ACMI ACME project  change x_posa_phone update to the orignal serial no from OFS
   --
   --Revision 1.15  2012/08/30 19:07:23  icanavan
   --TELCEL use 2 new fields in TABLE_BUS_ORG for conversion rate and flow
   --
   --Revision 1.14  2012/07/26 16:26:53  icanavan
   --TELCEL
   --
   --Revision 1.12  2010/11/29 20:11:46  akhan
   --modified to use dummy variables while transitioning from using retailer to ff_center to manuf
   --
   --Revision 1.11  2010/11/11 23:21:15  akhan
   --removed unneeded exception
   --
   --Revision 1.10  2010/11/11 22:39:32  akhan
   --Changes for retailer check
   --
   --Revision 1.9  2010/11/11 20:49:41  akhan
   --Changes for factory_short_code
   --
   --Revision 1.8  2010/11/01 20:24:54  akhan
   --Include changes to look for FACTORY_SHORT_CODE pc parameter and update x_psms_destination_addr accordingly
   --
   --Revision 1.7  2010/10/05 21:17:31  nguada
   --CR13085
   --
   --Revision 1.3  2010/07/23 15:14:48  akhan
   --new inbound for handset release
   --
   -- CR20451 | CR20854: Add TELCEL Brand
   ---------------------------------------------------------------------------------------------
   --Local Variables
   l_part_inst_objid               table_part_inst.objid%TYPE;
   l_part_inst_status              table_part_inst.x_part_inst_status%TYPE;
   l_part_mod                      table_part_inst.part_mod%TYPE;
   l_action                        VARCHAR2 (100) := ' ';
   l_inv_status                    VARCHAR2 (20);
   l_serial_num                    VARCHAR2 (50);
   l_send_location_code            VARCHAR2 (50);
   l_inner_excep_flag              BOOLEAN := FALSE;
   l_revision                      VARCHAR2 (30);
   l_part_inst2part_mod            NUMBER;
   l_creation_date                 DATE;
   l_current_site_id               table_site.site_id%TYPE;
   l_previous_site_id              table_site.site_id%TYPE;
   l_inv_bin_objid                 table_inv_bin.objid%TYPE;
   l_procedure_name                VARCHAR2 (80) := '.INBOUND_PHONE_INV_PRC';
   l_recs_processed                NUMBER := 0;
   l_start_date                    DATE := SYSDATE;
   l_commit_counter                NUMBER := 0;
   l_part_inst_seq                 NUMBER;
   l_pi_status_code_objid          NUMBER;
   l_upd_pi_status                 VARCHAR2 (20);
   l_upd_pi_status_code_objid      NUMBER;
   l_promo_objid                   NUMBER;
   l_restricted_use                NUMBER := 0;
   l_pn_tobe_update                VARCHAR2 (30);
   l_is_st_gsm                     NUMBER := 0;
   --   l_hex2dec_flag BOOLEAN := FALSE;
   is_acme_part                    VARCHAR2 (5) := 'NO';
   v_part_mod                      table_part_inst.part_mod%TYPE;
   l_allow_part_num_change         VARCHAR2 (30) := 'true';          --CR27995
   --EXCEPTIONS Variables
   no_site_id_exp                  EXCEPTION;
   no_part_num_exp                 EXCEPTION;                        -- CR4659
   distributed_trans_time_out      EXCEPTION;
   record_locked                   EXCEPTION;
   no_ml_excep                     EXCEPTION;
   pre_actv_resv_pin_exp           EXCEPTION;                       -- CR28538
   ------------- LOCAL VARIABLES TO AVOID UNNECESSARY TRIPS ---------
   l_previous_part_number          VARCHAR2 (100);
   l_current_part_number           VARCHAR2 (100);
   l_previous_part_num_transpose   VARCHAR2 (100);
   l_current_part_num_transpose    VARCHAR2 (100);
   --
   l_current_retailer              VARCHAR2 (100);
   l_previous_retailer             VARCHAR2 (100);
   --
   l_current_ff_center             VARCHAR2 (100);
   l_previous_ff_center            VARCHAR2 (100);
   --
   l_current_manf                  VARCHAR2 (100);
   l_previous_manf                 VARCHAR2 (100);
   l_data_phone                    NUMBER := 0;
   l_conv_rate                     NUMBER := 0;
   l_domain_objid                  NUMBER;
   l_mod_level_objid               NUMBER;
   l_sp_rowid                      VARCHAR2 (100);
   l_user_objid                    NUMBER;
   l_max_posa_date                 DATE;
   v_data_conf_objid               NUMBER;
   l_soft_pin                      table_x_cc_red_inv.x_red_card_number%TYPE
                                      := NULL;                      -- CR28538
   l_smp_number                    table_x_cc_red_inv.x_smp%TYPE := NULL; -- CR28538
   l_err_num                       NUMBER;                          -- CR28538
   l_err_msg                       VARCHAR2 (300);                  -- CR28538
   l_iccid_change                  VARCHAR2 (10) := 'true';          --CR29653
   --

   --CR48072

   l_esn_old_part_number	table_part_num.part_number%TYPE;

   --CR48072

   PRAGMA EXCEPTION_INIT (distributed_trans_time_out, -2049);
   PRAGMA EXCEPTION_INIT (record_locked, -54);
   --
   -------------------------------------------------------------------------------
   CURSOR inv_cur
   IS
        SELECT a.ROWID, a.*
          FROM tf_toss_interface_phone_inv a
      ORDER BY tf_ret_location_code,
               tf_ff_location_code,
               tf_manuf_location_code;
   -------------------------------------------------------------------------------
   CURSOR item_cur (part_no_in IN VARCHAR2)
   IS
      SELECT *
        FROM tf_of_item_v_phone_inv
       WHERE part_number = part_no_in;
   item_rec                        item_cur%ROWTYPE;
   r_transpose                     item_cur%ROWTYPE;
   r_chkitempromo                  item_cur%ROWTYPE;
   CURSOR multibrand_cur (
      part_no_in IN VARCHAR2)
   IS
      SELECT x_param_value
        FROM table_x_part_class_values v,
             table_x_part_class_params n,
             table_part_num pn
       WHERE     value2class_param = n.objid
             AND n.x_param_name = 'PRODUCT_SELECTION'
             AND v.value2part_class = pn.part_num2part_class
             AND pn.part_number = part_no_in;
   multibrand_rec                  multibrand_cur%ROWTYPE;
   -- ACMI ACME project
   CURSOR ACMI_cur (
      part_no_in IN VARCHAR2)
   IS
    /* Commented and modified by Rahul for CR40013
      SELECT x_param_value
        FROM table_x_part_class_values v,
             table_x_part_class_params n,
             table_part_num pn
       WHERE     value2class_param = n.objid
             AND v.value2part_class = pn.part_num2part_class
             AND n.x_param_name = 'OPERATING_SYSTEM'
             AND UPPER (v.x_param_value) = 'IOS'
             AND pn.x_technology = 'CDMA'                -- CR26535 ACME 5S 5C
             AND pn.part_number = part_no_in; -- sample 'STAPI4CP' --TOSS_PART_NUM
    */

    -- Start modified by Rahul for CR40013
    SELECT pn.part_number
    FROM     table_part_num pn
    WHERE 1 = 1
    AND pn.part_number = part_no_in
    AND EXISTS (SELECT 1
                FROM table_x_part_class_values v,
                table_x_part_class_params n
                WHERE     value2class_param = n.objid
                AND v.value2part_class = pn.part_num2part_class
                AND n.x_param_name = 'SERIAL_NUM_CONVERSION'
                AND NVL(UPPER (v.x_param_value),'N') = 'Y'
                )
    ;
    -- End modified by Rahul for CR40013
   ACMI_rec                        ACMI_cur%ROWTYPE;
   CURSOR c_part_num (p_part_num IN VARCHAR2)                       -- CR28538
   IS
      SELECT pn.x_card_plan
        FROM table_part_num pn
       WHERE part_number = p_part_num;
   part_num_rec                    c_part_num%ROWTYPE;

   --CR34728 TO CHECK THE PIN SERIAL INSERTED IN TABLE_PART_INST
   CURSOR PIN_PART_SNO_CUR (c_card_partnum IN VARCHAR2, c_phone_part_no IN VARCHAR2)IS
   SELECT PN.PART_NUMBER CARD_PART_NUM,
       PI2.PART_SERIAL_NO PIN_SERIAL_NUM,
       BO.ORG_ID,
       BO.ORG_FLOW
FROM  TABLE_PART_NUM PN
JOIN  TABLE_MOD_LEVEL ML  ON PN.OBJID = ML.PART_INFO2PART_NUM
JOIN  TABLE_BUS_ORG BO    ON BO.OBJID = PN.PART_NUM2BUS_ORG
JOIN  TABLE_PART_INST PI2 ON PI2.n_part_inst2part_mod = ML.OBJID
JOIN  TABLE_PART_INST PI  ON PI2.PART_TO_ESN2PART_INST = PI.OBJID
WHERE PN.PART_NUMBER = c_card_partnum--'STAPPCC0010D'
AND PI.PART_SERIAL_NO = c_phone_part_no;   --'862300000009051'
PIN_PART_SNO_REC  PIN_PART_SNO_CUR%rowtype;  --END CR34728



   FUNCTION benefit_given (part_num IN VARCHAR2, esn_objid IN NUMBER) -- CR30945
      RETURN BOOLEAN
   IS
      benefit_count   NUMBER := 0;
   BEGIN
      SELECT SUM (cnt)
        INTO benefit_count
        FROM (SELECT COUNT (*) cnt
                FROM table_part_inst pi,
                     table_part_num pn,
                     table_mod_level ml
               WHERE     ml.objid = pi.n_part_inst2part_mod
                     AND part_to_esn2part_inst = esn_objid
                     AND pn.objid = ml.part_info2part_num
                     AND pn.part_number = part_num
              UNION
              SELECT COUNT (*)
                FROM table_x_call_trans ct,
                     table_x_red_card rc,
                     table_part_inst pi,
                     table_part_num pn,
                     table_mod_level ml
               WHERE     ml.objid = rc.x_red_card2part_mod
                     AND rc.red_card2call_trans = ct.objid
                     AND ct.x_service_id = pi.part_serial_no
                     AND pn.objid = ml.part_info2part_num
                     AND pi.objid = esn_objid --CR31173
                     AND pn.part_number = part_num);
      IF benefit_count = 0
      THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END;
   --CR41652 Start
   --to check the old part numbers have any pins (card plan) attched
   FUNCTION is_card_plan_exists(
    ip_esn             IN VARCHAR2,
    ip_new_part_number IN VARCHAR2)
    RETURN BOOLEAN
  -------------------------------------------------------------------------------
   IS
    l_old_part_number VARCHAR2(30) := NULL;
    l_old_card_plan   VARCHAR2(30) := NULL;
   BEGIN
    -- checking the old part number has any card plan
    BEGIN
        SELECT pn.part_number,
               pn.x_card_plan
        INTO   l_old_part_number,
               l_old_card_plan
        FROM   sa.table_part_num pn,
               sa.table_mod_level ml,
               sa.table_bus_org bo,
               table_part_inst pi
        WHERE  pn.objid                = ml.part_info2part_num
        AND    bo.objid                = pn.part_num2bus_org
        AND    pi.n_part_inst2part_mod = ml.objid
        AND    pi.part_serial_no       = ip_esn;
    EXCEPTION
      WHEN OTHERS THEN
        l_old_part_number := NULL;
        l_old_card_plan   := NULL;
    END;

    IF l_old_part_number <> ip_new_part_number THEN
       IF l_old_card_plan IS NOT NULL THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;
    ELSE
       RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END is_card_plan_exists;
  --CR41652 end
   -------------------------------------------------------------------------------
   --------------- PRIVATE PROCEDURES
   -------------------------------------------------------------------------------
   PROCEDURE clean_up_prc
   -------------------------------------------------------------------------------
   IS
   BEGIN
      IF item_cur%ISOPEN
      THEN
         CLOSE item_cur;
      END IF;
      IF PIN_PART_SNO_CUR%ISOPEN  --CR34728
      THEN
         CLOSE PIN_PART_SNO_CUR;
      END IF;
   END clean_up_prc;
   --------------------------------------------------------------------------------------
   PROCEDURE insert_or_update_ota_features (
      p_part_inst_objid   IN table_part_inst.objid%TYPE,
      p_part_num          IN table_part_num.part_number%TYPE,
      p_is_st_gsm         IN NUMBER)
   IS
      --------------------------------------------------------------------------------------
      ota_seq             table_x_ota_features.objid%TYPE;
      -- BRAND SEPARATION   -- BRAND_SEP
      buy_airtime_menu    VARCHAR2 (2);
      buy_airtime_promo   VARCHAR2 (2);
      l_411_number        VARCHAR2 (30);
      l_multicall_flag    VARCHAR2 (30);
      l_psms_address      table_x_ota_features.x_psms_destination_addr%TYPE;
      ---CR26885


      CURSOR Brand_Tech_cur
      IS
         SELECT pn.part_number
           FROM table_bus_org b, table_part_num pn
          WHERE     pn.part_number = p_part_num
                AND b.ORG_ID = 'TELCEL'
                AND pn.x_technology = 'GSM'
                AND pn.part_num2bus_org = b.objid;
--CR32693

        CURSOR Cur_part_class(p_num in varchar2)
     IS
   select pc.name, pn.part_number,part_num2x_promotion,part_num2part_class
   from table_part_num pn, table_part_class pc
   where part_num2part_class = pc.objid
   and   pn.part_number= p_num;
   --CR32693
   CURSOR C_PARAM_TECH(p_class in varchar2)
    IS
   select part_class,param_name,param_value from pc_params_view
   where part_class = p_class
   and param_name in ('TECHNOLOGY');

    --CR32693
  CURSOR C_PARAM_MODEL(p_class in varchar2)
    IS
  select part_class,param_name,param_value from pc_params_view
  where part_class = p_class
  and param_name in ('MODEL_TYPE');

cur_part_class_ref Cur_part_class%ROWTYPE;
C_PARAM_TECH_REF   C_PARAM_TECH%ROWTYPE;
C_PARAM_MODEL_REF  C_PARAM_MODEL%ROWTYPE;
 brand_tech_rec      brand_tech_cur%ROWTYPE;
 l_x_ild_plus        sa.table_x_ota_features.x_ild_plus%TYPE; --CR26885/CR27015





   BEGIN
      l_411_number := 'N';
      l_multicall_flag := 'N';
      l_x_ild_plus := NULL;                                  --CR26885/CR27015
      BEGIN
         SELECT param_value
           INTO l_psms_address
           FROM pc_params_view a, table_part_num pn
          WHERE     a.part_class = (SELECT name
                                      FROM table_part_class
                                     WHERE objid = pn.part_num2part_class)
                AND a.param_name = 'FACTORY_SHORT_CODE'
                AND pn.part_number = p_part_num;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_psms_address := '31778';
      END;
      ---CR26885  Mex international CR27015
      OPEN Brand_Tech_cur;
      FETCH Brand_Tech_cur INTO Brand_Tech_rec;
      IF Brand_Tech_cur%FOUND
      THEN
         l_x_ild_plus := 'Y';
      END IF;
      CLOSE Brand_Tech_cur;
      ---CR26885
      SELECT objid
        INTO ota_seq
        FROM table_x_ota_features
       WHERE x_ota_features2part_inst = p_part_inst_objid;
      UPDATE table_x_ota_features
         SET current_config2x_data_config = v_data_conf_objid,
             x_multicall_flag = l_multicall_flag,
             x_411_number = l_411_number,
             x_psms_destination_addr = l_psms_address,
             x_ild_plus = l_x_ild_plus                       --CR26885/CR27015
       WHERE objid = ota_seq;



   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- BRand Separation
         IF item_rec.dll >= 32
         THEN
            buy_airtime_menu := 'Y';
            buy_airtime_promo := 'Y';
        --CR34956
         ELSIF p_part_num like 'TF%LL%'
         THEN
            buy_airtime_menu := 'Y';
         ELSE
            buy_airtime_menu := 'N';
            buy_airtime_promo := 'N';
         END IF;
         IF p_is_st_gsm = 1
         THEN
            buy_airtime_menu := 'N';
            buy_airtime_promo := 'N';
         END IF;


    --CR32693
        OPEN Cur_part_class(p_part_num) ;
         FETCH Cur_part_class INTO cur_part_class_ref;
         CLOSE Cur_part_class;

         OPEN C_PARAM_TECH(cur_part_class_ref.name);
         FETCH C_PARAM_TECH INTO C_PARAM_TECH_REF;
         CLOSE C_PARAM_TECH;

         OPEN C_PARAM_MODEL(cur_part_class_ref.name);
         FETCH C_PARAM_MODEL INTO C_PARAM_MODEL_REF;
         CLOSE C_PARAM_MODEL;

  IF (C_PARAM_TECH_REF.param_name='TECHNOLOGY' and C_PARAM_TECH_REF.param_value ='GSM')
    THEN
       IF (C_PARAM_MODEL_REF.param_name='MODEL_TYPE' and C_PARAM_MODEL_REF.param_value ='HOME_CENTER')
         THEN
               buy_airtime_menu := 'Y';
              -- dbms_output.put_line(buy_airtime_menu);
       END IF;
   END IF;

         INSERT INTO table_x_ota_features (objid,
                                           dev,
                                           x_redemption_menu,
                                           x_handset_lock,
                                           x_low_units,
                                           x_ota_features2part_num,
                                           x_ota_features2part_inst,
                                           x_psms_destination_addr,
                                           x_ild_account,
                                           x_ild_carr_status,
                                           x_ild_prog_status,
                                           x_ild_counter,
                                           x_current_conv_rate,
                                           x_close_count,
                                           current_config2x_data_config,
                                           x_data_config_prog_counter,
                                           x_buy_airtime_menu,
                                           x_spp_promo_code,
                                           x_multicall_flag,
                                           x_411_number,
                                           x_ild_plus)       --CR26885/CR27015
              VALUES (sa.seq ('x_ota_features'),
                      NULL,
                      'Y',
                      'Y',
                      'N',
                      NULL,
                      p_part_inst_objid,
                      l_psms_address,
                      NULL,
                      'Inactive',
                      'Completed',
                      NULL,
                      l_conv_rate,
                      0,
                      v_data_conf_objid,
                      0,
                      buy_airtime_menu,
                      buy_airtime_promo,
                      l_multicall_flag,
                      l_411_number,
                      l_x_ild_plus                          --CR26885/ CR27015
                                  );
   END;
   -------------------------------------------------------------------------------
   FUNCTION get_site_idninv_bin (p_fin_cust_id     IN     VARCHAR2,
                                 p_ship_loc_id     IN     NUMBER,    --CR25490
                                 p_site_id            OUT VARCHAR2, -- CR25490
                                 p_inv_bin_objid      OUT NUMBER)
      RETURN BOOLEAN
   IS
   -------------------------------------------------------------------------------
   --return boolean is
   BEGIN
      SELECT site_id, ib.objid
        INTO p_site_id, p_inv_bin_objid
        FROM table_site s, table_inv_bin ib
       WHERE     TYPE = 3
             AND bin_name = s.site_id
             AND NVL (s.x_ship_loc_id, -1) = NVL (p_ship_loc_id, -1) -- CR22623
             AND x_fin_cust_id = p_fin_cust_id;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END get_site_idninv_bin;
   -------------------------------------------------------------------------------
   PROCEDURE validate_fin_num (v_financial_control_num   IN VARCHAR2,
                               v_serial_num              IN VARCHAR2)
   IS
      -------------------------------------------------------------------------------
      l_sim_status   table_x_sim_inv.x_sim_inv_status%TYPE;
      PROCEDURE record_inv_exception (v_status IN VARCHAR2)
      IS
      BEGIN
         INSERT INTO x_inv_data_exception (OBJID,
                                           X_ESN,
                                           X_OLD_SIM_SERIAL_NO,
                                           X_NEW_SIM_SERIAL_NO,
                                           X_NOTIFY_PROCESS,
                                           X_SOURCE_SYSTEM,
                                           X_STATUS,
                                           X_PROCESS_DATE)
              VALUES (sequ_x_inv_data_exp.NEXTVAL,
                      v_serial_num,
                      NULL,
                      v_financial_control_num,
                      l_procedure_name,
                      'BATCH',
                      v_status,
                      SYSDATE);
      END;
   BEGIN
      IF LENGTH (NVL (v_financial_control_num, 0)) NOT BETWEEN 17 AND 21
      THEN
         record_inv_exception ('Invalid Length');
      ELSE
         BEGIN
            SELECT x_sim_inv_status
              INTO l_sim_status
              FROM table_x_sim_inv
             WHERE x_sim_serial_no = v_financial_control_num;
            IF l_sim_status <> '253'
            THEN
               record_inv_exception ('Invalid status');
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               record_inv_exception ('Sim Not Found');
         END;
      END IF;
   END;
   -------------------------------------------------------------------------------
   PROCEDURE upd_ti_phone_inv (p_extract_flag      IN VARCHAR2,
                               p_pn_tobe_updated   IN VARCHAR2,
                               p_rowid             IN VARCHAR2)
   IS
   -------------------------------------------------------------------------------
   BEGIN
      UPDATE tf_toss_interface_phone_inv
         SET toss_extract_flag = p_extract_flag,
             toss_extract_date = SYSDATE,
             last_update_date = SYSDATE,
             last_updated_by = l_procedure_name,
             toss_part_num = p_pn_tobe_updated
       WHERE ROWID = p_rowid;
   END;
   -------------------------------------------------------------------------------
   -- CR20451 | CR20854: Add TELCEL Brand field in table_bus_org for default conversion
   FUNCTION get_conv_rate (ip_part_number    IN     VARCHAR2,
                           ip_domain_objid   IN     NUMBER,
                           op_conv_rate         OUT NUMBER)
      RETURN BOOLEAN
   IS
   -------------------------------------------------------------------------------
   BEGIN
      SELECT DECODE (x_data_capable,
                     1, DECODE (NVL (x_conversion, 0), 0, hc, x_conversion),
                     hc)
        INTO op_conv_rate
        FROM (SELECT part_number,
                     x_conversion,
                     x_data_capable,
                     bus.org_conversion HC
                -- decode(bus.org_id,'NET10',10,'TRACFONE',3,'STRAIGHT_TALK',1) HC
                FROM table_part_num pn, table_bus_org bus
               WHERE     pn.part_num2bus_org = bus.objid
                     AND pn.part_number = ip_part_number
                     AND pn.part_num2domain = ip_domain_objid);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;
-------------------------------------------------------------------------------
-------- MAIN/Main/main procedure starts here
-------------------------------------------------------------------------------
BEGIN
   l_previous_part_number := 'DUMMY_PART';
   l_current_part_number := 'DUMMY_PART';
   l_previous_part_num_transpose := 'DUMMY_PART_TRANS';
   l_current_part_num_transpose := 'DUMMY_PART_TRANS';
   --l_previous_transceiver_num := 'DUMMY_PART_TRANC_NUM';
   --l_current_transceiver_num := 'DUMMY_PART_TRANC_NUM';
   l_current_retailer := 'DUMMY_RET';
   l_previous_retailer := 'DUMMY_RET';
   l_current_ff_center := 'DUMMY_FF';
   l_previous_ff_center := 'DUMMY_FF';
   l_current_manf := 'DUMMY_MANF';
   l_previous_manf := 'DUMMY_MANF';
   l_previous_site_id := NULL;                                        --CR8548
   --c_loop := 0; --CR8548
   l_pn_tobe_update := NULL;                                          --CR8548
   ---- GET USER ONLY ONCE
   BEGIN
      SELECT objid
        INTO l_user_objid
        FROM table_user
       WHERE login_name = 'ORAFIN';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_user_objid := NULL;
   END;
   FOR inv_rec IN inv_cur
   LOOP
      l_inner_excep_flag := FALSE;                                    --CR3886
      l_restricted_use := 0;                                          --CR3190
      l_upd_pi_status := NULL;
      l_upd_pi_status_code_objid := NULL;
      l_recs_processed := l_recs_processed + 1;
      l_commit_counter := l_commit_counter + 1;
      --l_hex2dec_flag := FALSE ; -- ACMI ACME project
      is_acme_part := 'NO';
      OPEN multibrand_cur (inv_rec.tf_part_num_transpose);
      FETCH multibrand_cur INTO multibrand_rec;
      IF multibrand_cur%NOTFOUND
      THEN
         OPEN item_cur (inv_rec.tf_part_num_transpose);
         FETCH item_cur INTO r_chkitempromo;
         CLOSE item_cur;
         IF NVL (r_chkitempromo.promo_code, 'NONE') = 'NONE'
         THEN
            IF r_chkitempromo.upc IS NOT NULL                        -- CR5575
            THEN
               inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
            END IF;
         ELSE
            inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
         END IF;
      ELSE
         inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
      END IF;
      CLOSE multibrand_cur;
      --End of CR5461 - TF PartNumber transpose
      l_current_part_number := inv_rec.tf_part_num_parent;
      l_current_part_num_transpose := inv_rec.tf_part_num_transpose;
      l_current_retailer := inv_rec.tf_ret_location_code;
      l_current_ff_center := inv_rec.tf_ff_location_code;
      l_current_manf := inv_rec.tf_manuf_location_code;
      -- ACMI ACME project start
      OPEN ACMI_cur (inv_rec.tf_part_num_transpose);
      FETCH ACMI_cur INTO ACMI_rec;
      IF ACMI_cur%FOUND
      THEN
         is_acme_part := 'YES';
      ELSE
         is_acme_part := 'NO';
      END IF;
      CLOSE ACMI_cur;
      -- ACMI ACME project end
      BEGIN
         -------- MAIN INNER BLOCK --------
         l_action := ' ';
         l_creation_date := NULL;
         -- ACMI ACME project start
         IF is_acme_part = 'YES'
         THEN
            l_serial_num := sa.Hex2dec (inv_rec.tf_serial_num);
         ELSE
            l_serial_num := inv_rec.tf_serial_num;
         END IF;
         -- ACMI ACME project end
         BEGIN
            SELECT part_num2x_data_config
              INTO v_data_conf_objid
              FROM table_part_num pn
             WHERE part_number = inv_rec.tf_part_num_parent;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
         l_send_location_code := NULL;
         IF inv_rec.tf_ret_location_code IS NOT NULL
         THEN
            l_creation_date := inv_rec.retailer_ship_date;
            l_current_ff_center := 'USING_RET';
            l_current_manf := 'USING_RET';
            IF (l_current_retailer != l_previous_retailer)
            THEN
               l_send_location_code := inv_rec.tf_ret_location_code;
            ELSE
               l_current_site_id := l_previous_site_id;
            END IF;
         ELSIF inv_rec.tf_ff_location_code IS NOT NULL
         THEN
            l_creation_date := inv_rec.ff_receive_date;
            l_current_retailer := 'USING_FF';
            l_current_manf := 'USING_FF';
            IF (l_current_ff_center != l_previous_ff_center)
            THEN
               l_send_location_code := inv_rec.tf_ff_location_code;
            ELSE
               l_current_site_id := l_previous_site_id;
            END IF;
         ELSIF inv_rec.tf_manuf_location_code IS NOT NULL
         THEN
            l_creation_date := inv_rec.creation_date;
            l_current_retailer := 'USING_MANF';
            l_current_ff_center := 'USING_MANF';
            IF (l_current_manf != l_previous_manf)
            THEN
               l_send_location_code := inv_rec.tf_manuf_location_code;
            ELSE
               l_current_site_id := l_previous_site_id;
            END IF;
         END IF;
         IF (l_send_location_code IS NOT NULL)
         THEN
            IF get_site_idNinv_bin (l_send_location_code,
                                    inv_rec.ship_to_id,             -- CR25490
                                    l_current_site_id,
                                    l_inv_bin_objid)
            THEN
               l_previous_site_id := l_current_site_id;
            ELSE
               RAISE no_site_id_exp;
            END IF;
         END IF;
         l_action := 'Checking for existent of SITE in TOSS';
         IF l_current_site_id IS NOT NULL
         THEN
            IF inv_rec.tf_financials_control_num IS NOT NULL
            THEN
               -- ACMI ACME project keep this as the OFS serial number because it is an
               -- error log at the time of inbound.  If it was after the inbound then
               -- it could be the converted number
               validate_fin_num (inv_rec.tf_financials_control_num,
                                 inv_rec.tf_serial_num);
            END IF;
            ------ CHECK IF THE PART NUMBER IS EQUAL -------
            IF l_previous_part_number || l_previous_part_num_transpose !=
                  l_current_part_number || l_current_part_num_transpose
            THEN
               OPEN item_cur (inv_rec.tf_part_num_parent);
               FETCH item_cur INTO item_rec;
               CLOSE item_cur;
               -- for phones check at tf_part_num_transpose
               OPEN item_cur (inv_rec.tf_part_num_transpose);
               FETCH item_cur INTO r_transpose;
               CLOSE item_cur;
               --CR4981_4982 Start
               IF NVL (item_rec.data_phone, 'N') = 'N'
               THEN
                  l_data_phone := 0;
               ELSE
                  l_data_phone := 1;
               END IF;
               l_revision := inv_rec.tf_part_num_transpose;
               IF r_transpose.posa_type = 'POSA'
               THEN
                  l_inv_status := '59';
               ELSIF r_transpose.posa_type = 'NPOSA'
               THEN
                  l_inv_status := '50';
               ELSE
                  l_inv_status := NULL;
               END IF;
               IF l_inv_status IS NOT NULL
               THEN
                  SELECT objid
                    INTO l_pi_status_code_objid
                    FROM table_x_code_table
                   WHERE x_code_number = l_inv_status;
               END IF;
               l_action := ' ';
               BEGIN
                  SELECT objid
                    INTO l_promo_objid
                    FROM table_x_promotion
                   WHERE x_promo_code = item_rec.promo_code;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_promo_objid := NULL;
               END;
               -- Get the domain object id
               BEGIN
                  SELECT objid
                    INTO l_domain_objid
                    FROM table_prt_domain
                   WHERE NAME = item_rec.clfy_domain;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
               l_action :=
                     'Checking for existence of PART-'
                  || inv_rec.tf_part_num_parent
                  || ' in TOSS';
               IF NOT get_conv_rate (inv_rec.tf_part_num_parent,
                                     l_domain_objid,
                                     l_conv_rate)
               THEN
                  RAISE no_part_num_exp;
               END IF;
               BEGIN
                  SELECT a.objid,
                         a.mod_level,
                         DECODE (l_data_phone, 1, part_num2x_data_config)
                    INTO l_part_inst2part_mod,
                         l_pn_tobe_update,
                         v_data_conf_objid
                    FROM table_mod_level a, table_part_num b
                   WHERE     a.mod_level = l_revision
                         AND a.part_info2part_num = b.objid
                         AND a.active = 'Active'                     --Digital
                         AND b.part_number = inv_rec.tf_part_num_transpose
                         AND b.domain = item_rec.clfy_domain;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     l_pn_tobe_update := NULL;
                     RAISE no_ml_excep;
               END;
            END IF;                               -- of same part number check
            BEGIN
               SELECT objid, x_part_inst_status, part_mod
                 INTO l_part_inst_objid, l_part_inst_status, l_part_mod
                 FROM table_part_inst
                WHERE     part_serial_no = l_serial_num -- ACMI ACME project  inv_rec.tf_serial_num
                      AND x_domain = item_rec.clfy_domain;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  l_part_inst_objid := -1;
            END;
            IF (inv_rec.tf_part_num_transpose = l_pn_tobe_update)
            THEN
               --ST GSM  CHANGE
               -- CR20451 | CR20854: Add TELCEL Brand ? change SELECT from ORG_ID to ORG_FLOW
               SELECT COUNT (*)
                 INTO l_is_st_gsm
                 FROM (SELECT pcv.value2part_class pcid, pcv.x_param_value
                         FROM TABLE_X_PART_CLASS_VALUES PCV,
                              TABLE_X_PART_CLASS_PARAMS PCP
                        WHERE     PCP.OBJID = PCV.VALUE2CLASS_PARAM
                              AND PCP.X_PARAM_NAME = 'NON_PPE') a,
                      table_part_class pc,
                      table_part_num pn,
                      table_bus_org bo
                WHERE     pn.part_num2part_class = pc.objid
                      AND a.pcid(+) = pc.objid
                      AND bo.objid = pn.part_num2bus_org
                      AND pn.x_technology = 'GSM'
                      AND a.x_param_value = '0'
                      --and bo.org_id = 'STRAIGHT_TALK'
                      AND bo.org_flow = '3'
                      AND pn.part_number = inv_rec.tf_part_num_transpose;
               --ST GSM  CHANGE
               IF l_part_inst_objid = -1               -- Phone does not exist
               THEN
                  l_action := 'Insert into table_part_inst';
                  l_part_inst_seq := seq ('part_inst');
                  IF item_rec.clfy_domain = 'PHONES'
                  THEN
                     IF LENGTH (RTRIM (inv_rec.toss_changed_retailer_name)) >
                           10
                     THEN
                        v_part_mod :=
                           SUBSTR (
                              RTRIM (inv_rec.toss_changed_retailer_name),
                              -10,
                              10);
                     ELSE
                        v_part_mod := inv_rec.toss_changed_retailer_name;
                     END IF;
                  ELSE
                     v_part_mod := NULL;
                  END IF;
                  --CR5565 END;
                  INSERT INTO table_part_inst (objid,
                                               part_serial_no,
                                               x_part_inst_status,
                                               x_sequence,
                                               x_red_code,
                                               x_order_number,
                                               x_creation_date,
                                               created_by2user,
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
                                               part_mod,
                                               repair_date,
                                               x_clear_tank,
                                               x_hex_serial_no,
                                               x_iccid,
                                               x_wf_mac_id,
                                               cpo_manufacturer)
                       VALUES (l_part_inst_seq,
                               -- ACMI ACME project inv_rec.tf_serial_num,
                               l_serial_num,
                               l_inv_status,
                               0,
                               inv_rec.tf_card_pin_num,
                               inv_rec.tf_order_num,
                               l_creation_date,
                               l_user_objid,
                               item_rec.clfy_domain,
                               l_part_inst2part_mod,
                               l_inv_bin_objid,
                               'Active',
                               inv_rec.creation_date,
                               l_pi_status_code_objid,
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               v_part_mod,
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               0,
                               inv_rec.toss_changed_retailer_id,
                               inv_rec.tf_financials_control_num,
                               inv_rec.tf_wf_mac_id ,
                               inv_rec.cpo_manufacturer );
                  insert_or_update_ota_features (l_part_inst_seq,
                                                 l_current_part_number,
                                                 l_is_st_gsm);
                  -- Attaching pre-active benefits for car connection devices CR28538
                  OPEN c_part_num (inv_rec.tf_part_num_parent);
                  FETCH c_part_num INTO part_num_rec;
                  IF     c_part_num%FOUND
                     AND NVL (part_num_rec.x_card_plan, 'X') <> 'X'
                  THEN
                     benefits_pkg.sp_preactive_reserve_pin (
                        in_esn             => inv_rec.tf_serial_num,
                        in_pin_part_num    => part_num_rec.x_card_plan,
                        in_inv_bin_objid   => l_inv_bin_objid,
                        out_soft_pin       => l_soft_pin,
                        out_smp_number     => l_smp_number,
                        out_err_num        => l_err_num,
                        out_err_msg        => l_err_msg);
                     IF NVL (l_err_num, 0) <> 0
                     THEN
                        CLOSE c_part_num; --CR31173
                        RAISE pre_actv_resv_pin_exp;
                     END IF;
                  END IF;
                  CLOSE c_part_num;
                  l_action := 'Update tf_toss_interface_table 1';
                  upd_ti_phone_inv ('YES', l_pn_tobe_update, inv_rec.ROWID);
               ELSE
                  l_action := 'Update table_part_inst 1';
	/*	Commented for CR44147
          --CR41652 BEGIN --
          --removing the link for cards reserve if current part number does not have card plan
          IF is_card_plan_exists (ip_esn => l_serial_num,
                              ip_new_part_number => inv_rec.tf_part_num_parent) THEN

            UPDATE table_part_inst
              SET  x_part_inst_status = '44',
                   part_to_esn2part_inst = NULL
            WHERE  part_to_esn2part_inst = l_part_inst_objid;
          END IF;
          --CR41652 END
	  Commented for CR44147	*/


	--  CR48072
	BEGIN

	  SELECT pn.part_number
	  INTO l_esn_old_part_number
	  FROM sa.table_part_num pn,
	    sa.table_mod_level ml,
	    table_part_inst pi
	  WHERE pn.objid              = ml.part_info2part_num
	  AND pi.n_part_inst2part_mod = ml.objid
	  AND pi.x_domain             = 'PHONES'
	  AND pi.part_serial_no       = l_serial_num ;

	EXCEPTION
	WHEN OTHERS THEN

	  l_esn_old_part_number := NULL;

	END;

	IF l_esn_old_part_number <> inv_rec.tf_part_num_parent THEN

	  IF l_part_inst_status   = '50' OR l_part_inst_status = '59' -- NON POSA, POSA OR NEW, INACTIVE
	    THEN

		UPDATE table_part_inst pi
		SET x_part_inst_status  = '44' ,
		part_to_esn2part_inst = NULL ,
		STATUS2X_CODE_TABLE   = (SELECT OBJID
					FROM sa.table_x_code_table
					WHERE X_CODE_TYPE = 'CS'
					AND X_CODE_NUMBER = '44'
					AND ROWNUM        = 1
					)
		WHERE pi.part_to_esn2part_inst = l_part_inst_objid
		AND pi.x_domain                = 'REDEMPTION CARDS'
		AND EXISTS   (SELECT 1
				FROM sa.table_part_num pn,
				sa.table_mod_level ml
				WHERE pn.objid      = ml.part_info2part_num
				AND ml.objid        = pi.n_part_inst2part_mod
				AND pn.part_number IN
							(SELECT
							DISTINCT x_card_plan
							FROM table_part_num
							WHERE x_card_plan IS NOT NULL
							)
				);

	  END IF;

	END IF;

	-- CR48072
                  ----- BEGIN CR30945 ----------------
                  OPEN c_part_num (inv_rec.tf_part_num_parent); --CR31173
                  FETCH c_part_num INTO part_num_rec;
                  IF c_part_num%FOUND
                     AND NVL (part_num_rec.x_card_plan, 'X') <> 'X'
                  THEN
                     IF NOT benefit_given (part_num_rec.x_card_plan,
                                           l_part_inst_objid)
                     THEN
                        benefits_pkg.sp_preactive_reserve_pin (
                           in_esn             => inv_rec.tf_serial_num,
                           in_pin_part_num    => part_num_rec.x_card_plan,
                           in_inv_bin_objid   => l_inv_bin_objid,
                           out_soft_pin       => l_soft_pin,
                           out_smp_number     => l_smp_number,
                           out_err_num        => l_err_num,
                           out_err_msg        => l_err_msg);
                        IF NVL (l_err_num, 0) <> 0
                        THEN
                           CLOSE c_part_num; --CR31173
                           RAISE pre_actv_resv_pin_exp;
                        END IF;
                     END IF;                               --benefit not given
                  END IF;
                  CLOSE c_part_num;
                  ---------- END CR30945---------------
                  --------------------------------------------------------
                  --  NOW CHECK IF there has been a posa transaction    --
                  --  against this serial_num (assumption here is:      --
                  --  if there was a swipe or unswipe or multiple combi --
                  --  nations of this events.. the phone was,is and will--
                  --  be a posa phone and it should remain a posa card  --
                  --------------------------------------------------------
                  l_upd_pi_status := l_inv_status;
                  l_upd_pi_status_code_objid := l_pi_status_code_objid;
                  l_allow_part_num_change := 'true';
                  l_iccid_change := 'true';
                  IF l_part_inst_status IN ('150', '50', '59')
                  THEN
                     BEGIN
                        SELECT NVL (MAX (toss_posa_date),
                                    TO_DATE ('01-jan-1753'))
                          INTO l_max_posa_date
                          FROM sa.x_posa_phone
                         WHERE tf_serial_num = inv_rec.tf_serial_num; -- ACMI ACME project
                        -- keeping this the OFS part serial number
                        IF (l_creation_date <= l_max_posa_date)
                        THEN
                           l_upd_pi_status := NULL;
                           l_upd_pi_status_code_objid := NULL;
                        END IF;
                     END;
                  ELSIF l_part_inst_status NOT IN ('69')
                  THEN
                     IF inv_rec.tf_part_num_transpose LIKE 'GP%'
                     THEN                                            --CR27995
                        l_allow_part_num_change := 'false';
                     ELSE
                        l_allow_part_num_change := 'true';
                     END IF;
                     l_upd_pi_status := NULL;
                     l_upd_pi_status_code_objid := NULL;
                     l_iccid_change := 'false';
                  END IF;
                  IF item_rec.clfy_domain = 'PHONES'
                  THEN
                     IF LENGTH (RTRIM (inv_rec.toss_changed_retailer_name)) >
                           10
                     THEN
                        v_part_mod :=
                           SUBSTR (
                              RTRIM (inv_rec.toss_changed_retailer_name),
                              -10,
                              10);
                     ELSE
                        v_part_mod := inv_rec.toss_changed_retailer_name;
                     END IF;
                  ELSE
                     v_part_mod := l_part_mod;
                  END IF;
                  --CR5565 END;


                  UPDATE table_part_inst
                     SET x_part_inst_status =
                            NVL (l_upd_pi_status, x_part_inst_status),
                         status2x_code_table =
                            NVL (l_upd_pi_status_code_objid,
                                 status2x_code_table),
                         x_creation_date = l_creation_date,
                         x_order_number = inv_rec.tf_order_num,
                         created_by2user = l_user_objid,
                         x_domain = item_rec.clfy_domain,
                         last_pi_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                         last_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                         next_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                         last_mod_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                         last_trans_time =
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                         date_in_serv = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                         repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                         n_part_inst2part_mod =
                            DECODE (l_allow_part_num_change,
                                    'true', l_part_inst2part_mod,
                                    n_part_inst2part_mod),           --CR27995
                         part_mod = v_part_mod,
                         part_inst2inv_bin = l_inv_bin_objid,
                         x_hex_serial_no =
                            DECODE (is_acme_part,
                                    'YES', inv_rec.tf_serial_num,
                                    x_hex_serial_no),
                         x_iccid =
                            DECODE (
                               l_iccid_change,
                               'true', NVL (
                                          inv_rec.tf_financials_control_num,
                                          x_iccid),
                               x_iccid)
                   WHERE     part_serial_no = l_serial_num -- ACMI ACME project
                         AND x_domain = item_rec.clfy_domain;
                --CR34728 To update the retailer information for the card in table_part_inst
                OPEN PIN_PART_SNO_CUR (part_num_rec.x_card_plan,l_serial_num);
                FETCH PIN_PART_SNO_CUR INTO PIN_PART_SNO_REC;
                  IF PIN_PART_SNO_CUR%FOUND THEN
                  UPDATE table_part_inst
                     SET part_inst2inv_bin = l_inv_bin_objid
                   WHERE part_serial_no    = PIN_PART_SNO_REC.PIN_SERIAL_NUM
                     AND x_domain          = 'REDEMPTION CARDS';
                END IF;
                CLOSE PIN_PART_SNO_CUR;         --end CR34728

                  insert_or_update_ota_features (l_part_inst_objid,
                                                 l_current_part_number,
                                                 l_is_st_gsm);
                  l_action := 'Update tf_toss_interface_table 2';
                  upd_ti_phone_inv ('YES', l_pn_tobe_update, inv_rec.ROWID);
               END IF;                                  --end of part id check
               -- Now update the table_site_part.site_part2part_info
               BEGIN
                  SELECT ROWID
                    INTO l_sp_rowid
                    FROM table_site_part sp
                   WHERE     x_service_id = l_serial_num -- ACMI ACME project inv_rec.tf_serial_num
                         AND part_status = 'Active';
                  BEGIN
                     SELECT a.objid
                       INTO l_mod_level_objid
                       FROM table_mod_level a, table_part_num b
                      WHERE     a.part_info2part_num = b.objid
                            AND a.active = 'Active'
                            AND b.part_number = inv_rec.tf_part_num_transpose;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
                  UPDATE table_site_part sp
                     SET site_part2part_info = l_mod_level_objid
                   WHERE sp.ROWID = l_sp_rowid;
               EXCEPTION
                  -- No active site record exists;
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            ELSE
               l_action := 'Update tf_toss_interface_table 3';
               upd_ti_phone_inv ('PN_NOT_SAME',
                                 l_pn_tobe_update,
                                 inv_rec.ROWID);
            END IF;
         ELSE
            RAISE no_site_id_exp;
         END IF;                                       -- end of site_id check
      EXCEPTION
         WHEN no_ml_excep
         THEN
            toss_util_pkg.insert_error_tab_proc (
               'Inner Block : ' || l_action,
               l_current_part_number,
               l_procedure_name,
               'MOD_LEVEL NOT EXISTS');
            l_inner_excep_flag := TRUE;
         WHEN no_part_num_exp
         THEN
            toss_util_pkg.insert_error_tab_proc (
               'Inner Block : ' || l_action,
               l_serial_num, -- ACMI ACMI project this is the converted number,
               l_procedure_name,
               'PART_NUM NOT EXISTS ');
            l_inner_excep_flag := TRUE;
         WHEN no_site_id_exp
         THEN
            toss_util_pkg.insert_error_tab_proc (
               'NO SITE ID',
               l_serial_num, -- ACMI ACMI project this is the converted number,
               l_procedure_name,
               'Inner Block Error no_site_id_exp');
            l_inner_excep_flag := TRUE;
         WHEN distributed_trans_time_out
         THEN
            toss_util_pkg.insert_error_tab_proc (
               'Caught distributed_trans_time_out',
               l_serial_num, -- ACMI ACMI project this is the converted number,
               l_procedure_name,
               'Inner Block Error distributed_trans_time_out');
            l_inner_excep_flag := TRUE;
         WHEN record_locked
         THEN
            toss_util_pkg.insert_error_tab_proc (
               'Caught distributed_trans_time_out',
               l_serial_num, -- ACMI ACMI project this is the converted number,
               l_procedure_name,
               'Inner Block Error record_locked ');
            l_inner_excep_flag := TRUE;
         WHEN pre_actv_resv_pin_exp                                 -- CR28538
         THEN
            toss_util_pkg.insert_error_tab_proc (
                  'BENIFITS_PKG.SP_PREACTIVE_RESERVE_PIN '
               || ' : '
               || inv_rec.tf_serial_num
               || ' : '
               || part_num_rec.x_card_plan
               || ' : '
               || l_inv_bin_objid,
               l_serial_num,
               l_procedure_name,
               l_err_msg);
            l_inner_excep_flag := TRUE;
         WHEN OTHERS
         THEN
            toss_util_pkg.insert_error_tab_proc (
               'Inner Block Error -When others',
               l_serial_num, -- ACMI ACMI project this is the converted number,
               l_procedure_name);
            l_inner_excep_flag := TRUE;
      END;
      clean_up_prc;
      IF l_inner_excep_flag
      THEN
         l_previous_part_number := 'DUMMY_PART';
         l_previous_part_num_transpose := 'DUMMY_PART_TRANS';
         l_inv_bin_objid := -1;
         l_previous_retailer := 'DUMMY_RET';
         l_previous_ff_center := 'DUMMY_FF';
         l_previous_manf := 'DUMMY_MANF';
      ELSE
         ------------------ Set current to previous ------------------
         l_previous_part_number := l_current_part_number;
         l_previous_part_num_transpose := l_current_part_num_transpose;
         l_previous_retailer := l_current_retailer;
         l_previous_ff_center := l_current_ff_center;
         l_previous_manf := l_current_manf;
      END IF;
      IF MOD (l_commit_counter, 1000) = 0
      THEN
         COMMIT;
      END IF;
   END LOOP;                                                       --Main loop
   COMMIT;
   IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name)
   THEN
      COMMIT;
   END IF;
   clean_up_prc;
END;
/