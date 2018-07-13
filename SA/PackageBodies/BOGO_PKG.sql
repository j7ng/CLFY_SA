CREATE OR REPLACE PACKAGE BODY sa.bogo_pkg AS
 /****************************************************************************
  ****************************************************************************
  * $Revision: 1.93 $
  * $Author: oimana $
  * $Date: 2018/04/04 19:27:56 $
  * $Log: bogo_pkg.sql,v $
  * Revision 1.93  2018/04/04 19:27:56  oimana
  * CR57471 - Package Body
  *
  * Revision 1.78  2017/11/14 23:17:01  oimana
  * CR50105 - Package Body - WFM BOGO
  *
  * Revision 1.72  2017/10/09 22:10:28  oimana
  * CR51833 - Package Body
  *
  * Revision 1.41  2017/07/27 14:22:29  oimana
  * CR48916 - Package Body - Added comments to 2 new procedures with description of purpose.
  *
  * Revision 1.40  2017/07/26 22:00:29  oimana
  * CR48916 - Package Body
  *
  * Revision 1.39  2017/07/24 19:35:02  oimana
  * CR48916 - Added new parameter USER_NAME
  *
  * Revision 1.38  2017/07/21 20:21:03  oimana
  * CR48916 - SA.BOGO_PKG body with new procedures for Insert and Update including global parameter to suppress call to error table
  *
  * Revision 1.36  2017/06/27 17:04:29  oimana
  * CR47135 - Merginf with changes for another CR
  *
  * Revision 1.35  2017/06/25 15:21:29  oimana
  * CR46345 - Per Sumit and Andre, remove control for DEALER_ID
  * and allow the DEALER_ID be patr of the BOGO validation for TF BOGO
  *
  * Revision 1.25  2016/11/17 17:35:04  tbaney
  * Added logic to populate the n_inv_bin_objid variable.
  *
  * Revision 1.24  2016/10/21 17:21:21  ddudhankar
  * CR44787 - column name renamed ORIGINAL
  *
  * Revision 1.23  2016/10/20 17:47:17  ddudhankar
  * CR44787 - insert for sa.mtm_bogo_bi_info changed
  *
  * Revision 1.22  2016/10/18 21:06:53  ddudhankar
  * CR44787 - modified to get Service_plan_objid
  *
  *****************************************************************************
  *****************************************************************************/
--
--
  g_error_log_flag      VARCHAR2(1) := 'N';
  g_user_id             NUMBER;
  g_pin_reserve_status  table_part_inst.x_part_inst_status%TYPE := '400';
  g_enable_org_bogo     VARCHAR2(1) := 'N';   -- CR51833 - Enable BOGO process flag//OImana
--
--
  PROCEDURE get_bogo_pin_number (i_esn_number        IN  table_part_inst.part_serial_no%TYPE,
                                 i_brand             IN  table_bus_org.org_id%TYPE DEFAULT 'WFM',
                                 o_bogo_pin_number   OUT table_part_inst.x_red_code%TYPE,
                                 o_bogo_part_number  OUT table_part_num.part_number%TYPE,
                                 o_bogo_part_class   OUT table_part_class.name%TYPE,
                                 out_err_num         OUT NUMBER,
                                 out_err_message     OUT VARCHAR2)
  IS

  --CR50105 - Return the BOGO PIN card number for granted ESN//OImana

  l_red_card_pin       sa.table_part_inst.x_red_code%TYPE;
  l_bogo_part_number   sa.table_part_num.part_number%TYPE;
  l_bogo_part_class    sa.table_part_class.name%TYPE;

  BEGIN

    o_bogo_pin_number  := NULL;
    o_bogo_part_number := NULL;
    out_err_num        := -1;
    out_err_message    := 'ERROR - '||i_brand||' - ';

    BEGIN
      SELECT pi_card.x_red_code,
             pn_card.part_number,
             (SELECT pc_card.name
                FROM sa.table_part_class pc_card
               WHERE pc_card.objid = pn_card.part_num2part_class) part_class
        INTO l_red_card_pin,
             l_bogo_part_number,
             l_bogo_part_class
        FROM sa.table_part_inst pi_card,
             sa.table_mod_level ml_card,
             sa.table_part_num  pn_card,
             sa.table_bus_org   tbo,
             (SELECT pi_esn.objid objid,
                     pi_esn.part_serial_no esn_no
                FROM sa.table_part_inst pi_esn,
                     sa.table_mod_level ml_esn,
                     sa.table_part_num  pn_esn,
                     sa.table_bus_org   tbo
               WHERE tbo.objid = pn_esn.part_num2bus_org
                 AND pn_esn.active = 'Active'
                 AND ml_esn.part_info2part_num = pn_esn.objid
                 AND pi_esn.n_part_inst2part_mod = ml_esn.objid
                 AND pi_esn.part_status = 'Active'
                 AND pi_esn.x_domain = 'PHONES'
                 AND tbo.org_id = i_brand
                 AND pi_esn.part_serial_no = i_esn_number) pi_esn
       WHERE tbo.objid = pn_card.part_num2bus_org
         AND pi_card.part_status = 'Active'
         AND pi_card.x_part_inst_status||'' = DECODE(tbo.brm_notification_flag, 'Y', '40', '400')     --CR50105 - RESERVED PIN part number inst status
         AND pi_card.x_domain||'' = 'REDEMPTION CARDS'
         AND pi_card.n_part_inst2part_mod = ml_card.objid
         AND ml_card.part_info2part_num = pn_card.objid
         AND EXISTS (SELECT NULL
                       FROM sa.x_bogo_configuration xbc
                      WHERE xbc.bogo_part_number = pn_card.part_number
                        AND xbc.brand = tbo.org_id
                        AND xbc.bogo_status = 'ACTIVE'
                        AND ROWNUM = 1)
         AND pn_card.active = 'Active'
         AND tbo.org_id = i_brand
         AND pi_card.part_to_esn2part_inst = pi_esn.objid;
    EXCEPTION
      WHEN OTHERS THEN
        l_red_card_pin     := NULL;
        l_bogo_part_number := NULL;
        l_bogo_part_class  := NULL;
        out_err_message := out_err_message||SUBSTR(SQLERRM, 1, 200);
        RETURN;
    END;

    o_bogo_pin_number  := l_red_card_pin;
    o_bogo_part_number := l_bogo_part_number;
    o_bogo_part_class  := l_bogo_part_class;
    out_err_num        := 0;
    out_err_message    := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      out_err_num     := -2;
      out_err_message := out_err_message||SUBSTR(SQLERRM, 1, 200);
  END get_bogo_pin_number;
--
--
  PROCEDURE part_number_sp_id (i_pin_part_number  IN  table_part_num.part_number%TYPE,
                               i_brand            IN  table_bus_org.org_id%TYPE DEFAULT 'WFM',
                               out_sp_id          OUT x_service_plan.objid%TYPE,
                               out_err_num        OUT NUMBER,
                               out_err_message    OUT VARCHAR2)
  IS

  --CR50105 - Return the service plan for PIN active part number//OImana

  l_sp_id  sa.x_service_plan.objid%TYPE;

  BEGIN

    out_sp_id       := NULL;
    out_err_num     := -1;
    out_err_message := 'ERROR - '||i_brand||' - ';

    BEGIN
      SELECT sp.objid
        INTO l_sp_id
        FROM sa.x_service_plan sp,
             sa.x_service_plan_feature spf,
             sa.x_serviceplanfeature_value spfv,
             sa.x_serviceplanfeaturevalue_def a,
             sa.mtm_partclass_x_spf_value_def b,
             (SELECT pn.part_num2part_class pc_objid
                FROM sa.table_part_num pn,
                     sa.table_bus_org tbo
               WHERE tbo.objid      = pn.part_num2bus_org
                 AND pn.active      = 'Active'
                 AND pn.domain      = 'REDEMPTION CARDS'
                 AND tbo.org_id     = i_brand
                 AND pn.part_number = i_pin_part_number) esnpc
       WHERE sp.objid = spf.sp_feature2service_plan
         AND spf.objid = spfv.spf_value2spf
         AND spfv.value_ref = a.objid
         AND a.objid = b.spfeaturevalue_def_id
         AND b.part_class_id = esnpc.pc_objid;
    EXCEPTION
      WHEN OTHERS THEN
        l_sp_id := NULL;
        out_err_message := out_err_message||SUBSTR(SQLERRM, 1, 200);
        RETURN;
    END;

    out_sp_id       := l_sp_id;
    out_err_num     := 0;
    out_err_message := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      out_err_num     := -2;
      out_err_message := out_err_message||SUBSTR(SQLERRM, 1, 200);
  END part_number_sp_id;
--
--
  PROCEDURE update_bogo_status IS

  --CR48916//OImana//07242017//Tracfone
  --Optional function to set SCHEDULED BOGO records to ACTIVE when start date meets sysdate.
  --Function will set the status to EXPIRED for those active BOGO records with bogo_end_date in the past.

  l_updated_by        NUMBER(25,0);
  l_updated_date      TIMESTAMP(6);

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    BEGIN
      SELECT user_id,
             sysdate
        INTO l_updated_by,
             l_updated_date
        FROM all_users
       WHERE username = (SELECT sys_context('USERENV','SESSION_USER')
                           FROM dual
                          WHERE ROWNUM = 1);
    EXCEPTION
      WHEN OTHERS THEN
        l_updated_by   := -1;
        l_updated_date := sysdate;
    END;

    BEGIN
      UPDATE sa.x_bogo_configuration
         SET bogo_status  = 'ACTIVE',
             updated_by   = l_updated_by,
             updated_date = l_updated_date
       WHERE bogo_status  = 'SCHEDULED'
         AND bogo_start_date <= sysdate;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line ('ERROR - When updating sa.x_bogo_configuration from SCHEDULED to ACTIVE: '||SUBSTR(SQLERRM, 1, 200));
        RAISE;
    END;

    COMMIT;

    BEGIN
      UPDATE sa.x_bogo_configuration
         SET bogo_status  = 'EXPIRED',
             updated_by   = l_updated_by,
             updated_date = l_updated_date
       WHERE bogo_status  = 'ACTIVE'
         AND bogo_end_date < sysdate;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line ('ERROR - When updating sa.x_bogo_configuration from SCHEDULED to ACTIVE: '||SUBSTR(SQLERRM, 1, 200));
        RAISE;
    END;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.put_line ('ERROR - When calling ota_util_pkg.err_log: '||SUBSTR(SQLERRM, 1, 200));
  END update_bogo_status;
--
--
  PROCEDURE input_bogo_error_log (p_action        IN error_table.action%TYPE,
                                  p_error_date    IN error_table.error_date%TYPE DEFAULT SYSDATE,
                                  p_key           IN error_table.key%TYPE DEFAULT NULL,
                                  p_program_name  IN error_table.program_name%TYPE,
                                  p_error_text    IN error_table.error_text%TYPE)
  IS
  --CR48916//OImana//07242017//Tracfone
  --Function allows to send error message from BOGO process to ERROR TABLE in case the business requires it.

  BEGIN

    IF (NVL(g_error_log_flag,'N') = 'Y') THEN

      ota_util_pkg.err_log (p_action,
                            p_error_date,
                            p_key,
                            p_program_name,
                            p_error_text);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line ('ERROR - When calling ota_util_pkg.err_log: '||SUBSTR(SQLERRM, 1, 200));
  END input_bogo_error_log;
--
--
  PROCEDURE create_bogo_from_ui (i_brand                 IN  x_bogo_configuration.brand%TYPE,
                                 i_bogo_part_number      IN  x_bogo_configuration.bogo_part_number%TYPE,
                                 i_card_pin_part_class   IN  x_bogo_configuration.card_pin_part_class%TYPE,
                                 i_esn_part_class        IN  x_bogo_configuration.esn_part_class%TYPE,
                                 i_esn_part_number       IN  x_bogo_configuration.esn_part_number%TYPE,
                                 i_esn_dealer_id         IN  x_bogo_configuration.esn_dealer_id%TYPE,
                                 i_eligible_service_plan IN  VARCHAR2,
                                 i_channel               IN  x_bogo_configuration.channel%TYPE,
                                 i_action_type           IN  x_bogo_configuration.action_type%TYPE,
                                 i_tsp_id                IN  VARCHAR2 DEFAULT NULL,
                                 i_msg_script_id         IN  x_bogo_configuration.msg_script_id%TYPE,
                                 i_bogo_start_date       IN  x_bogo_configuration.bogo_start_date%TYPE,
                                 i_bogo_end_date         IN  x_bogo_configuration.bogo_end_date%TYPE,
                                 i_bogo_status           IN  x_bogo_configuration.bogo_status%TYPE,
                                 i_user_name             IN  VARCHAR2,
                                 o_bogo_flag             OUT VARCHAR2,
                                 o_response              OUT VARCHAR2)
  IS

  -- CR48916//This procedure receives BOGO attributes from front-end application to validate and insert into table//OImana
  -- CR48916//Validation includes ESN parts, channel, dealer and service plans
  -- CR48916//New data is checked against existing BOGO records to ensure no ACTIVE duplicate records get created.
  -- CR48916//Action Type ALL cannot be applied if there is an existing records with one of the 3 other values.

  CURSOR c_channel_cur (c_brand VARCHAR2) IS
    SELECT channel
      FROM sa.x_bogo_channel
     WHERE brand = c_brand
  ORDER BY channel;

  l_bogo_conf_rec         sa.X_BOGO_CONFIGURATION%ROWTYPE;
  l_channel_lname         DBMS_UTILITY.lname_array;
  l_channel_length        BINARY_INTEGER;
  l_dealer_tsp_lid        DBMS_UTILITY.lname_array;
  l_dealer_tsp_length     BINARY_INTEGER;
  l_srv_plan_lname        DBMS_UTILITY.lname_array;
  l_srv_plan_length       BINARY_INTEGER;

  TYPE sp_featv_arraytype IS TABLE OF NUMBER(25,0)
    INDEX BY PLS_INTEGER;

  l_sp_featv_array        sp_featv_arraytype;

  l_in_channel            VARCHAR2(240);
  l_in_dealer_id          VARCHAR2(240);
  l_in_tsp_id             VARCHAR2(240);
  l_in_service_plan       VARCHAR2(240);
  l_out_channel           VARCHAR2(240);
  l_out_dealer_id         VARCHAR2(240);
  l_out_tsp_id            VARCHAR2(240);
  l_out_tsp_name          VARCHAR2(240);
  l_out_service_plan      VARCHAR2(240);
  l_created_by            NUMBER(25,0);
  l_created_date          TIMESTAMP(6);
  l_bogo_exists           NUMBER;
  l_bogo_exists_sum       NUMBER;
  l_insert_count          NUMBER;
  l_check_sp_id           NUMBER;
  l_check_sp_id_cnt       NUMBER;
  l_sp_featv_count        NUMBER;
  l_tsp_objid             NUMBER;

  BEGIN

    o_bogo_flag                           := 'N';
    o_response                            := NULL;
    --
    l_bogo_conf_rec.objid                 := NULL;
    l_bogo_conf_rec.brand                 := i_brand;
    l_bogo_conf_rec.bogo_part_number      := i_bogo_part_number;
    l_bogo_conf_rec.card_pin_part_class   := i_card_pin_part_class;
    l_bogo_conf_rec.esn_part_class        := i_esn_part_class;
    l_bogo_conf_rec.esn_part_number       := i_esn_part_number;
    l_bogo_conf_rec.esn_dealer_id         := NULL;
    l_bogo_conf_rec.esn_dealer_name       := NULL;
    l_bogo_conf_rec.eligible_service_plan := NULL;
    l_bogo_conf_rec.channel               := NULL;
    l_bogo_conf_rec.action_type           := NULL;
    l_bogo_conf_rec.tsp_id                := NULL;
    l_bogo_conf_rec.msg_script_id         := NVL(i_msg_script_id,'PROMO_5243');
    l_bogo_conf_rec.bogo_start_date       := i_bogo_start_date;
    l_bogo_conf_rec.bogo_end_date         := i_bogo_end_date;
    l_bogo_conf_rec.appl_execution_id     := NULL;
    l_bogo_conf_rec.bogo_status           := NVL(i_bogo_status,'ACTIVE');
    l_bogo_conf_rec.created_by            := NULL;
    l_bogo_conf_rec.created_date          := NULL;
    l_bogo_conf_rec.updated_by            := NULL;
    l_bogo_conf_rec.updated_date          := NULL;
    l_in_channel                          := NULL;
    l_in_dealer_id                        := TRIM(i_esn_dealer_id);
    l_in_tsp_id                           := TRIM(i_tsp_id);
    l_in_service_plan                     := i_eligible_service_plan;
    l_bogo_exists                         := 0;
    l_bogo_exists_sum                     := 0;
    l_insert_count                        := 0;
    l_check_sp_id                         := 0;
    l_check_sp_id_cnt                     := 0;
    l_sp_featv_count                      := 0;
    l_tsp_objid                           := NULL;

    update_bogo_status;

    IF i_channel = 'ALL' THEN
      FOR c_channel_rec IN c_channel_cur (l_bogo_conf_rec.brand) LOOP
        l_in_channel := l_in_channel||c_channel_rec.channel||',';
      END LOOP;
    ELSE
      l_in_channel := i_channel;
    END IF;

    IF (i_bogo_part_number IS NULL) THEN
        o_response := TRIM('ERROR - Missing BOGO part number - NULL Input');
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    IF (i_esn_part_class IS NOT NULL) AND (i_esn_part_number IS NOT NULL) THEN
        o_response := TRIM('ERROR - Invalid input for ESN part class and part number.  Process can only accept one of the two values: '||i_esn_part_class||' or '||i_esn_part_number);
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    IF (l_in_channel IS NULL) OR (i_action_type IS NULL) THEN
        o_response := TRIM('ERROR - Missing input value for channel and action type - NULL Input');
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    IF (i_eligible_service_plan IS NULL) THEN
        o_response := TRIM('ERROR - Missing input value for service plan - NULL Input');
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    IF (i_esn_dealer_id IS NULL) AND (i_tsp_id IS NULL) THEN
        o_response := TRIM('ERROR - Missing input value for dealer or tsp ID - NULL Input');
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    IF (i_esn_dealer_id IS NOT NULL) AND (i_tsp_id IS NOT NULL) THEN
        o_response := TRIM('ERROR - Invalid input for dealer and tsp ID.  Process can only accept one of the two values: '||i_esn_dealer_id||' or '||i_tsp_id);
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    IF (l_bogo_conf_rec.brand = 'TRACFONE') AND (l_bogo_conf_rec.card_pin_part_class IS NULL) THEN
        o_response := TRIM('ERROR - TRACFONE brand requires valid PIN part class value - NULL Input Found');
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    BEGIN
      SELECT action_type
        INTO l_bogo_conf_rec.action_type
        FROM sa.x_bogo_action_type
       WHERE action_type = i_action_type;
    EXCEPTION
      WHEN OTHERS THEN
        o_response := TRIM('ERROR - When validating action type value: '||i_action_type||' - '||SUBSTR(SQLERRM, 1, 200));
        RAISE;
    END;

    BEGIN
      SELECT '"'||REPLACE(REPLACE(REPLACE(TRIM(BOTH ',' FROM TRIM(l_in_channel)),'"',''),' ',''),',','","')||'"' channel,
             '"'||REPLACE(REPLACE(REPLACE(TRIM(BOTH ',' FROM TRIM(l_in_dealer_id)),'"',''),' ',''),',','","')||'"' dealer_id,
             '"'||REPLACE(REPLACE(REPLACE(TRIM(BOTH ',' FROM TRIM(l_in_service_plan)),'"',''),' ',''),',','","')||'"' srv_plan_id,
             '"'||REPLACE(REPLACE(REPLACE(TRIM(BOTH ',' FROM TRIM(l_in_tsp_id)),'"',''),' ',''),',','","')||'"' tsp_id
        INTO l_out_channel,
             l_out_dealer_id,
             l_out_service_plan,
             l_out_tsp_id
        FROM dual;
    EXCEPTION
      WHEN OTHERS THEN
        o_response := TRIM('ERROR - When cleaning channel, dealer id and plan values: '||SUBSTR(SQLERRM, 1, 200));
        RAISE;
    END;

    BEGIN
      SELECT c.objid
        BULK COLLECT INTO l_sp_featv_array
        FROM sa.x_serviceplanfeaturevalue_def c,
             sa.mtm_partclass_x_spf_value_def d,
             sa.table_part_class f,
             sa.table_part_num e,
             sa.table_bus_org t
       WHERE t.objid = e.part_num2bus_org
         AND f.objid = e.part_num2part_class
         AND e.domain = e.s_domain
         AND e.s_domain = 'PHONES'
         AND e.active = 'Active'
         AND e.part_num2part_class = d.part_class_id
         AND d.spfeaturevalue_def_id = c.objid
         AND c.table_type = 'TABLE_PART_CLASS'
         AND (e.part_number = l_bogo_conf_rec.esn_part_number
          OR  f.name = l_bogo_conf_rec.esn_part_class)
         AND t.org_id = l_bogo_conf_rec.brand;
    EXCEPTION
      WHEN OTHERS THEN
        o_response := TRIM('ERROR - When validating ESN part class and/or number: '||SUBSTR(SQLERRM, 1, 200));
        RAISE;
    END;

    l_sp_featv_count := l_sp_featv_array.count;

    IF NVL(l_sp_featv_count,0) = 0 THEN
        o_response := TRIM('ERROR - Invalid input ESN part class and/or part number value: '||NVL(l_bogo_conf_rec.esn_part_class, l_bogo_conf_rec.esn_part_number));
        DBMS_OUTPUT.put_line (o_response);
        RETURN;
    END IF;

    BEGIN
      SELECT user_id,
             sysdate,
             user_id,
             sysdate
        INTO l_bogo_conf_rec.created_by,
             l_bogo_conf_rec.created_date,
             l_bogo_conf_rec.updated_by,
             l_bogo_conf_rec.updated_date
        FROM all_users
       WHERE username LIKE UPPER('%'||NVL(TRIM(i_user_name),'XXX'))
         AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          SELECT user_id,
                 sysdate,
                 user_id,
                 sysdate
            INTO l_bogo_conf_rec.created_by,
                 l_bogo_conf_rec.created_date,
                 l_bogo_conf_rec.updated_by,
                 l_bogo_conf_rec.updated_date
            FROM all_users
           WHERE username = (SELECT sys_context('USERENV','SESSION_USER')
                               FROM dual
                              WHERE ROWNUM = 1);
        EXCEPTION
          WHEN OTHERS THEN
            l_bogo_conf_rec.created_by   := -1;
            l_bogo_conf_rec.created_date := sysdate;
            l_bogo_conf_rec.updated_by   := -1;
            l_bogo_conf_rec.updated_date := sysdate;
        END;
    END;

    BEGIN
      SELECT sa.seq_x_bogo_appl_exe_id.NEXTVAL
        INTO l_bogo_conf_rec.appl_execution_id
        FROM dual;
    EXCEPTION
      WHEN OTHERS THEN
        o_response := TRIM('ERROR - When fetching new application exection ID: '||SUBSTR(SQLERRM, 1, 200));
        RAISE;
    END;

    BEGIN

      dbms_utility.comma_to_table (list   => l_out_channel,
                                   tablen => l_channel_length,
                                   tab    => l_channel_lname);

      FOR i IN 1 .. l_channel_length LOOP

        BEGIN

          l_bogo_conf_rec.channel := REPLACE(l_channel_lname(i),'"','');

          IF l_in_tsp_id IS NULL THEN
            dbms_utility.comma_to_table (list   => l_out_dealer_id,
                                         tablen => l_dealer_tsp_length,
                                         tab    => l_dealer_tsp_lid);
          ELSIF l_in_tsp_id IS NOT NULL THEN
            dbms_utility.comma_to_table (list   => l_out_tsp_id,
                                         tablen => l_dealer_tsp_length,
                                         tab    => l_dealer_tsp_lid);
          END IF;

          FOR j IN 1 .. l_dealer_tsp_length LOOP

            BEGIN

              IF l_in_tsp_id IS NULL THEN

                l_bogo_conf_rec.esn_dealer_id := REPLACE(l_dealer_tsp_lid(j),'"','');

                BEGIN
                  SELECT ts.name
                    INTO l_bogo_conf_rec.esn_dealer_name
                    FROM sa.table_inv_bin tb,
                         sa.table_site ts
                   WHERE tb.bin_name = ts.site_id
                     AND ts.type = '3'
                     AND ts.site_id = l_bogo_conf_rec.esn_dealer_id;
                EXCEPTION
                  WHEN OTHERS THEN
                    o_response := TRIM('ERROR - When validating ESN Dealer ID: '||l_bogo_conf_rec.esn_dealer_id||' - '||SUBSTR(SQLERRM, 1, 200));
                    RAISE;
                END;

              ELSIF l_in_tsp_id IS NOT NULL THEN

                l_bogo_conf_rec.tsp_id := TO_NUMBER(REPLACE(l_dealer_tsp_lid(j),'"',''));

                -- CR52740 - Need to validate input TSP_ID against table sa.x_bogo_tsp_id//OImana
                BEGIN
                  SELECT tsp_name
                    INTO l_out_tsp_name
                    FROM sa.x_bogo_tsp_id
                   WHERE (door_status = 'DEFAULT' OR door_status IS NULL)
                     AND door_type = 'Exclusive'
                     AND tsp_id = l_bogo_conf_rec.tsp_id;
                EXCEPTION
                  WHEN OTHERS THEN
                    o_response := TRIM('ERROR - When validating TSP ID: '||l_bogo_conf_rec.tsp_id||' - '||SUBSTR(SQLERRM, 1, 200));
                    RAISE;
                END;

              END IF;

              dbms_utility.comma_to_table (list   => l_out_service_plan,
                                           tablen => l_srv_plan_length,
                                           tab    => l_srv_plan_lname);

              FOR k IN 1 .. l_srv_plan_length LOOP

                BEGIN

                  l_bogo_conf_rec.eligible_service_plan := TO_NUMBER(REPLACE(l_srv_plan_lname(k),'"',''));
                  l_check_sp_id := 0;
                  l_check_sp_id_cnt := 0;

                  FOR i IN l_sp_featv_array.FIRST .. l_sp_featv_array.LAST LOOP

                    BEGIN
                      SELECT COUNT(sp.objid)
                        INTO l_check_sp_id
                        FROM sa.x_service_plan sp,
                             sa.x_service_plan_feature spf,
                             sa.x_serviceplanfeature_value spfv,
                             sa.x_serviceplanfeaturevalue_def a,
                             sa.mtm_partclass_x_spf_value_def b
                       WHERE EXISTS (SELECT NULL
                                       FROM sa.table_part_num pn
                                      WHERE pn.s_domain = 'REDEMPTION CARDS'
                                        AND pn.active = 'Active'
                                        AND pn.part_num2part_class = b.part_class_id)
                         AND a.objid = b.spfeaturevalue_def_id
                         AND a.table_type = 'TABLE_PART_CLASS'
                         AND a.objid = spfv.value_ref
                         AND spfv.spf_value2spf = spf.objid
                         AND spf.sp_feature2service_plan = sp.objid
                         AND b.spfeaturevalue_def_id = l_sp_featv_array(i)
                         AND sp.objid = l_bogo_conf_rec.eligible_service_plan;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        l_check_sp_id := 0;
                      WHEN OTHERS THEN
                        l_check_sp_id := 0;
                        o_response    := TRIM('ERROR - When validating input service plan value: '||SUBSTR(SQLERRM, 1, 200));
                        RAISE;
                    END;

                    l_check_sp_id_cnt := l_check_sp_id_cnt + l_check_sp_id;

                  END LOOP;

                  IF NVL(l_check_sp_id_cnt,0) = 0 THEN
                    o_response    := TRIM('ERROR - Input service plan NOT mapped to ESN part class/number or redemption card: '||TO_CHAR(l_bogo_conf_rec.eligible_service_plan));
                    DBMS_OUTPUT.put_line (o_response);
                    RETURN;
                  END IF;

                  --DBMS_OUTPUT.put_line ('channel         ' || i || ' is ' || l_channel_lname(i)  || ' --> ' || l_bogo_conf_rec.channel);
                  --DBMS_OUTPUT.put_line ('dealer_id       ' || j || ' is ' || l_dealer_tsp_lid(j) || ' --> ' || l_bogo_conf_rec.esn_dealer_id);
                  --DBMS_OUTPUT.put_line ('tsp_id          ' || j || ' is ' || l_dealer_tsp_lid(j) || ' --> ' || l_bogo_conf_rec.tsp_id);
                  --DBMS_OUTPUT.put_line ('service_plan_id ' || k || ' is ' || l_srv_plan_lname(k) || ' --> ' || l_bogo_conf_rec.eligible_service_plan);

                  BEGIN
                    SELECT COUNT(1)
                      INTO l_bogo_exists
                      FROM sa.x_bogo_configuration
                     WHERE brand = l_bogo_conf_rec.brand
                       AND ((bogo_part_number =  l_bogo_conf_rec.bogo_part_number)
                        OR  (bogo_part_number <> l_bogo_conf_rec.bogo_part_number))
                       AND ((card_pin_part_class = l_bogo_conf_rec.card_pin_part_class)
                        OR  (card_pin_part_class IS NULL AND l_bogo_conf_rec.card_pin_part_class IS NULL))
                       AND ((esn_part_class = l_bogo_conf_rec.esn_part_class)
                        OR  (esn_part_class IS NULL AND l_bogo_conf_rec.esn_part_class IS NULL))
                       AND ((esn_part_number = l_bogo_conf_rec.esn_part_number)
                        OR  (esn_part_number IS NULL AND l_bogo_conf_rec.esn_part_number IS NULL))
                       AND ((esn_dealer_id = l_bogo_conf_rec.esn_dealer_id)
                        OR  (l_bogo_conf_rec.esn_dealer_id IS NULL))
                       AND eligible_service_plan = l_bogo_conf_rec.eligible_service_plan
                       AND channel = l_bogo_conf_rec.channel
                       AND ((action_type = l_bogo_conf_rec.action_type)
                        OR  (action_type = 'ALL' AND l_bogo_conf_rec.action_type <> 'ALL')
                        OR  (action_type <> 'ALL' AND l_bogo_conf_rec.action_type = 'ALL'))
                       AND (tsp_id = l_bogo_conf_rec.tsp_id OR l_bogo_conf_rec.tsp_id IS NULL)
                       AND ((msg_script_id = l_bogo_conf_rec.msg_script_id)
                        OR  (msg_script_id IS NULL AND l_bogo_conf_rec.msg_script_id IS NULL))
                       AND ((l_bogo_conf_rec.bogo_start_date BETWEEN bogo_start_date AND bogo_end_date)
                        OR  (l_bogo_conf_rec.bogo_start_date < bogo_start_date AND l_bogo_conf_rec.bogo_end_date >= bogo_start_date))
                       AND bogo_status = l_bogo_conf_rec.bogo_status;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      l_bogo_exists := 0;
                    WHEN OTHERS THEN
                      l_bogo_exists := -1;
                      o_response    := TRIM('ERROR - When searching existing BOGO records: '||SUBSTR(SQLERRM, 1, 200));
                      RAISE;
                  END;

                  l_bogo_exists_sum := l_bogo_exists_sum + l_bogo_exists;

                  IF (l_bogo_exists = 0) THEN

                    BEGIN
                      SELECT sa.seq_x_bogo_configuration.NEXTVAL
                        INTO l_bogo_conf_rec.objid
                        FROM dual;
                    EXCEPTION
                      WHEN OTHERS THEN
                        l_bogo_conf_rec.objid := NULL;
                        o_response := TRIM('ERROR - When getting OBJID sequence for BOGO record: '||SUBSTR(SQLERRM, 1, 200));
                        RAISE;
                    END;

                    BEGIN

                      INSERT INTO sa.x_bogo_configuration
                           VALUES l_bogo_conf_rec;

                      l_insert_count := l_insert_count + NVL(SQL%rowcount,0);

                    EXCEPTION
                      WHEN DUP_VAL_ON_INDEX THEN
                        o_response := TRIM('ERROR - Active '||l_bogo_conf_rec.brand||' BOGO record with same attributes already found in the system.');
                        RAISE;
                      WHEN OTHERS THEN
                        o_response := TRIM('ERROR - When inserting new BOGO record: '||SUBSTR(SQLERRM, 1, 200));
                        RAISE;
                    END;

                  END IF;

                END;

              END LOOP;

            END;

          END LOOP;

        END;

      END LOOP;

    END;

    COMMIT;

    IF NVL(l_insert_count,0) <> 0 THEN
      o_bogo_flag := 'Y';
      o_response  := 'SUCCESS';
    ELSE
      o_response  := 'WARNING - No records created - Process found '||TO_CHAR(l_bogo_exists_sum)||' records in the system for same input values';
      o_response  := o_response || ' - Verify if the Action Type selected includes existing BOGO record with <ALL> action types';
    END IF;

    DBMS_OUTPUT.put_line ('Value for appl_execution_id is:  '||TO_CHAR(l_bogo_conf_rec.appl_execution_id));
    DBMS_OUTPUT.put_line ('Records Inserted in BOGO Table:  '||TO_CHAR(l_insert_count));
    DBMS_OUTPUT.put_line ('Records Already in BOGO Table:   '||TO_CHAR(l_bogo_exists_sum));
    DBMS_OUTPUT.put_line ('Response: <'||o_bogo_flag||'> - <'||o_response||'>');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      o_response := TRIM(NVL(o_response, 'ERROR - MAIN create_bogo_from_ui PROCESS FAILED: '||SUBSTR(SQLERRM, 1, 200)));
      DBMS_OUTPUT.put_line (o_response);
  END create_bogo_from_ui;
--
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--
  PROCEDURE update_bogo_from_ui (i_appl_execution_id     IN  x_bogo_configuration.appl_execution_id%TYPE,
                                 i_bogo_status           IN  x_bogo_configuration.bogo_status%TYPE,
                                 i_bogo_end_date         IN  x_bogo_configuration.bogo_end_date%TYPE,
                                 i_user_name             IN  VARCHAR2,
                                 o_bogo_flag             OUT VARCHAR2,
                                 o_response              OUT VARCHAR2)
  IS

  -- CR48916 - This procedure receives BOGO application execution ID from front-end application to update the record.//OImana
  -- CR48916 - Update includes BOGO status and BOGO end date.  End date must be equal or greater than the start date.
  -- CR48916 - Records that are in status of DISABLED or EXPIRED cannot be updated.

  l_updated_by        NUMBER(25,0);
  l_updated_date      TIMESTAMP(6);
  l_update_count      NUMBER := 0;

  BEGIN

    o_bogo_flag := 'N';
    o_response  := NULL;

    DBMS_OUTPUT.put_line ('Values input: <'||i_appl_execution_id||'> - <'||i_bogo_status||'>');

    BEGIN
      SELECT user_id,
             sysdate
        INTO l_updated_by,
             l_updated_date
        FROM all_users
       WHERE username LIKE UPPER('%'||NVL(TRIM(i_user_name),'XXX'))
         AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          SELECT user_id,
                 sysdate
            INTO l_updated_by,
                 l_updated_date
            FROM all_users
           WHERE username = (SELECT sys_context('USERENV','SESSION_USER')
                               FROM dual
                              WHERE ROWNUM = 1);
        EXCEPTION
          WHEN OTHERS THEN
            l_updated_by   := -1;
            l_updated_date := sysdate;
        END;
    END;

    BEGIN

      UPDATE sa.x_bogo_configuration
         SET bogo_status       = NVL(i_bogo_status, bogo_status),
             bogo_end_date     = (CASE WHEN NVL(i_bogo_end_date,bogo_end_date) <= bogo_start_date
                                       THEN bogo_start_date
                                       ELSE NVL(i_bogo_end_date,bogo_end_date)
                                   END),
             appl_execution_id = (CASE WHEN NVL(i_bogo_status,'X') IN('DISABLED')
                                       THEN NULL
                                       ELSE appl_execution_id
                                   END),
             updated_by        = l_updated_by,
             updated_date      = l_updated_date
       WHERE appl_execution_id = i_appl_execution_id
         AND bogo_status NOT IN('DISABLED','EXPIRED');

      l_update_count := l_update_count + NVL(SQL%rowcount,0);

    EXCEPTION
      WHEN OTHERS THEN
        o_response := TRIM('ERROR - When updating sa.x_bogo_configuration: '||SUBSTR(SQLERRM, 1, 200));
        DBMS_OUTPUT.put_line (o_response);
        RAISE;
    END;

    COMMIT;

    IF NVL(l_update_count,0) <> 0 THEN
      o_bogo_flag := 'Y';
      o_response  := 'SUCCESS';
    ELSE
      o_response  := 'WARNING - No records found or updated by process with given appl_exe_id: '||TO_CHAR(i_appl_execution_id);
    END IF;

    DBMS_OUTPUT.put_line ('Updated number of records: '||l_update_count);
    DBMS_OUTPUT.put_line ('Response: <'||o_bogo_flag||'> - <'||o_response||'>');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      o_response := TRIM(NVL(o_response,'ERROR - MAIN update_bogo_from_ui PROCESS FAILED: '||SUBSTR(SQLERRM, 1, 200)));
      DBMS_OUTPUT.put_line (o_response);
  END update_bogo_from_ui;
--
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--
  PROCEDURE sp_validate_and_apply_bogo (i_transaction_id  IN  ig_transaction.transaction_id%TYPE,
                                        o_response        OUT VARCHAR2)
  IS
    --
    c_bogo_config_flag    x_ig_order_type.x_bogo_config_flag%TYPE;
    c_actual_order_type   x_ig_order_type.x_actual_order_type%TYPE;
    c_msg_script_id       x_bogo_configuration.msg_script_id%TYPE;
    c_bogo_part_number    x_bogo_configuration.bogo_part_number%TYPE;
    n_bogo_objid          x_bogo_configuration.objid%TYPE;
    c_out_soft_pin        x_bogo_configuration.bogo_part_number%TYPE;
    c_all_order_type      x_bogo_configuration.action_type%TYPE;
    c_dealer_id           table_inv_bin.bin_name%TYPE;
    n_inv_bin_objid       table_inv_bin.objid%TYPE;
    c_smp_number          table_part_inst.part_serial_no%TYPE;
    c_pin_part_num        table_part_inst.part_serial_no%TYPE;
    c_free_soft_pin       table_part_inst.x_red_code%TYPE;
    c_channel             table_x_call_trans.x_sourcesystem%TYPE;
    c_ct_objid            table_x_call_trans.objid%TYPE;
    c_x_value             table_x_case_detail.x_value%TYPE;
    c_x_red_code          table_x_red_card.x_red_code%TYPE;
    c_s_title             table_condition.s_title%TYPE;
    c_brand_bogo_enabled  table_bus_org.bogo_enabled_flag%TYPE;
    c_program_name        VARCHAR2(100) := 'BOGO_PKG.sp_validate_and_apply_bogo';
    c_error_code          VARCHAR2(1000);
    n_error_num           NUMBER;
    n_benefit_count       NUMBER;
    --
    ig                    ig_transaction%ROWTYPE;
    cst                   sa.customer_type := sa.customer_type ();
    --
  BEGIN
    --
    g_error_log_flag  := 'Y';   -- CR48916 - Call err_log pkg as option//OImana
    g_enable_org_bogo := 'N';   -- CR51833 - Initally enable BOGO process flag to N//OImana
    --
    BEGIN
      SELECT *
        INTO ig
        FROM gw1.ig_transaction
       WHERE transaction_id = i_transaction_id;
    EXCEPTION
      WHEN OTHERS THEN
        o_response := 'IG TRANSACTION NOT FOUND - '||SUBSTR(SQLERRM, 1, 200);
        input_bogo_error_log (p_action => 'Select ig_transaction with i_transaction_id',
                              p_error_date => sysdate,
                              p_key => i_transaction_id,
                              p_program_name => c_program_name,
                              p_error_text => o_response);
        RETURN;
    END;
    --
    -- Get configuration flag for the ESN
    --
    BEGIN
      SELECT iot.x_bogo_config_flag,
             iot.x_actual_order_type,
             'ALL' all_order_type
        INTO c_bogo_config_flag,
             c_actual_order_type,
             c_all_order_type
        FROM sa.x_ig_order_type iot
       WHERE iot.x_programme_name = 'SP_INSERT_IG_TRANSACTION'
         AND iot.x_ig_order_type = ig.order_type
         AND iot.x_bogo_config_flag = 'Y'
         AND iot.x_actual_order_type IN(SELECT action_type
                                          FROM sa.x_bogo_action_type);
    EXCEPTION
      WHEN OTHERS THEN
        o_response         := 'X_IG_ORDER_TYPE NOT FOUND - '||SUBSTR(SQLERRM, 1, 200);
        c_bogo_config_flag := 'N';
        input_bogo_error_log (p_action => 'Select x_ig_order_type failed to RETURN',
                              p_error_date => sysdate,
                              p_key => i_transaction_id,
                              p_program_name => c_program_name,
                              p_error_text => o_response);
        RETURN;
    END;
    --
    IF c_bogo_config_flag = 'Y' THEN
      --
      BEGIN
        SELECT ct.x_sourcesystem,
               ct.objid
          INTO c_channel,
               c_ct_objid
          FROM sa.table_x_call_trans ct,
               sa.table_task tt
         WHERE ct.objid = tt.x_task2x_call_trans
           AND tt.task_id = ig.action_item_id;
      EXCEPTION
        WHEN OTHERS THEN
          o_response := 'SELECT table_x_call_trans failed Error - '||SUBSTR(SQLERRM, 1, 200);
          input_bogo_error_log (p_action => 'Select table_x_call_trans failed to RETURN',
                                p_error_date => sysdate,
                                p_key => i_transaction_id,
                                p_program_name => c_program_name,
                                p_error_text => o_response);
          RETURN;
      END;
      --
      cst := cst.retrieve (i_esn => ig.esn);
      --
      IF cst.response NOT LIKE '%SUCCESS%' THEN

        o_response := 'ERROR RETRIEVING ESN: ' ||ig.esn||' ~ '|| cst.response;

        input_bogo_error_log (p_action => 'Call for cst.retrieve failed to RETURN',
                              p_error_date => sysdate,
                              p_key => i_transaction_id,
                              p_program_name => c_program_name,
                              p_error_text => o_response);
        RETURN;

      END IF;
      --
      -- Check if the Brand is enables for BOGO enabled --CR55117//OImana
      BEGIN
        SELECT NVL(tbo.bogo_enabled_flag,'N')
          INTO c_brand_bogo_enabled
          FROM sa.table_bus_org tbo
         WHERE tbo.org_id = cst.bus_org_id;
      EXCEPTION
        WHEN OTHERS THEN
          c_brand_bogo_enabled := 'N';
      END;
      --
      -- CR55117 - Check if the Brand is enables for BOGO enabled//OImana
      IF (g_enable_org_bogo = 'N') AND (c_brand_bogo_enabled = 'N') THEN

        o_response := 'ERROR BOGO DISABLED FOR BRAND: ' ||ig.esn||' ~ '|| c_brand_bogo_enabled||' ~ '||c_brand_bogo_enabled;

        input_bogo_error_log (p_action => 'Call for BRAND setup flag set to No',
                              p_error_date => sysdate,
                              p_key => i_transaction_id,
                              p_program_name => c_program_name,
                              p_error_text => o_response);
        RETURN;

      END IF;
      --
      --Ensure CT action_type is ACTIVATION and QUEUED (1,401)
      --
      BEGIN
        SELECT ib.objid,
               ib.bin_name,
               rc.x_red_code
          INTO n_inv_bin_objid,
               c_dealer_id,
               c_x_red_code
          FROM sa.table_site_part sp,
               sa.table_x_call_trans ct,
               sa.table_x_red_card rc,
               sa.table_mod_level ml,
               sa.table_inv_bin ib,
               sa.table_part_num pn,
               sa.table_part_class pc
         WHERE pc.objid                 = pn.part_num2part_class
           AND pn.active                = 'Active'
           AND pn.objid                 = ml.part_info2part_num
           AND ib.objid                 = rc.x_red_card2inv_bin
           AND ml.objid                 = rc.x_red_card2part_mod
           AND rc.red_card2call_trans   = ct.objid
           AND ct.x_action_type         IN('1','401')
           AND ct.x_result              = 'Completed'
           AND ct.objid                 = c_ct_objid
           AND ct.call_trans2site_part  = sp.objid
           AND sp.x_service_id          = ig.esn;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            SELECT ib.objid,
                   ib.bin_name,
                   pi.x_red_code
              INTO n_inv_bin_objid,
                   c_dealer_id,
                   c_x_red_code
              FROM sa.table_inv_bin ib,
                   sa.table_part_inst pi
             WHERE ib.objid = pi.part_inst2inv_bin
               AND pi.x_part_inst_status = '40'   --RESERVED
               AND EXISTS(SELECT 'x'
                            FROM sa.table_x_call_trans ct
                           WHERE ct.x_action_type  IN('1','401')
                             AND ct.x_result       = 'Completed'
                             AND ct.objid          = c_ct_objid
                             AND ct.x_service_id   = ig.esn)
               AND pi.part_to_esn2part_inst = (SELECT pi2.objid
                                                 FROM sa.table_part_inst pi2
                                                WHERE pi2.part_serial_no = ig.esn)
               AND ROWNUM < 2;
          EXCEPTION
            WHEN OTHERS THEN
              o_response := 'DEALER NOT FOUND INNER SQL - '||SUBSTR(SQLERRM, 1, 200);
              input_bogo_error_log (p_action => 'Select for n_inv_bin_objid c_dealer_id failed to RETURN',
                                    p_error_date => sysdate,
                                    p_key => i_transaction_id,
                                    p_program_name => c_program_name,
                                    p_error_text => o_response);
              RETURN;
          END;
        WHEN OTHERS THEN
          o_response := 'DEALER RELATED ISSUE - '||SUBSTR(SQLERRM, 1, 200);
          input_bogo_error_log (p_action => 'Select for n_inv_bin_objid c_dealer_id failed to RETURN',
                                p_error_date => sysdate,
                                p_key => i_transaction_id,
                                p_program_name => c_program_name,
                                p_error_text => o_response);
          RETURN;
      END;
      --
      BEGIN
        SELECT objid,
               msg_script_id,
               bogo_part_number
          INTO n_bogo_objid,
               c_msg_script_id,
               c_bogo_part_number
          FROM sa.x_bogo_configuration
         WHERE brand                 = cst.bus_org_id
           AND (esn_part_class       = cst.part_class_name
            OR  esn_part_number      = cst.esn_part_number)
           AND esn_dealer_id         = cst.dealer_id
           AND eligible_service_plan = cst.service_plan_objid
           AND action_type           = DECODE(c_actual_order_type,
                                              action_type,
                                              c_actual_order_type,
                                              c_all_order_type)   --CR48916//OImana
           AND channel               = c_channel
           AND bogo_status           = 'ACTIVE'
           AND SYSDATE BETWEEN bogo_start_date AND bogo_end_date;
      EXCEPTION
        WHEN OTHERS THEN
          o_response := 'BOGO CONFIGURATION NOT FOUND - '||SUBSTR(SQLERRM, 1, 200);
          DBMS_OUTPUT.put_line ('o_response ==> '|| o_response);
          RETURN;
      END;
      --
      -- CR55117 - Add control to ensure only ONE BOGO is applied to ESN.
      BEGIN
        SELECT SUM(cnt)
          INTO n_benefit_count
          FROM (SELECT COUNT(1) cnt
                  FROM sa.table_part_inst pi,
                       sa.table_part_num pn,
                       sa.table_mod_level ml
                 WHERE ml.objid = pi.n_part_inst2part_mod
                   AND pi.part_to_esn2part_inst = (SELECT pi2.objid
                                                     FROM sa.table_part_inst pi2
                                                    WHERE pi2.part_serial_no = ig.esn)
                   AND pn.objid                 = ml.part_info2part_num
                   AND pn.active                = 'Active'
                   AND pn.domain                = 'REDEMPTION CARDS'
                   AND (pn.part_number          = c_bogo_part_number
                    OR INSTR(pn.part_number,'BOGO') > 0)
                UNION
                SELECT COUNT(1) cnt
                  FROM sa.table_x_call_trans ct,
                       sa.table_x_red_card rc,
                       sa.table_part_inst pi,
                       sa.table_part_num pn,
                       sa.table_mod_level ml
                 WHERE ml.objid               = rc.x_red_card2part_mod
                   AND rc.red_card2call_trans = ct.objid
                   AND ct.x_service_id        = pi.part_serial_no
                   AND pn.objid               = ml.part_info2part_num
                   AND pn.active              = 'Active'
                   AND pn.domain              = 'REDEMPTION CARDS'
                   AND (pn.part_number        = c_bogo_part_number
                    OR INSTR(pn.part_number,'BOGO') > 0)
                   AND pi.part_serial_no      = ig.esn);
      EXCEPTION
        WHEN OTHERS THEN
          n_benefit_count := -1;
          o_response      := 'BOGO N_BENEFIT_COUNT ERROR - '|| SQLCODE||' - '||SUBSTR(SQLERRM, 1, 200);
          input_bogo_error_log (p_action => 'Call for n_benefit_count failed to RETURN',
                                p_error_date => sysdate,
                                p_key => i_transaction_id,
                                p_program_name => c_program_name,
                                p_error_text => o_response);
          RETURN;
      END;
      --
      IF n_benefit_count <> 0 THEN
        o_response       := 'BOGO N_BENEFIT_COUNT <> 0';
        input_bogo_error_log (p_action => 'Check for benefit already provided N_BENEFIT_COUNT '||n_benefit_count||' RETURNING',
                              p_error_date => sysdate,
                              p_key => i_transaction_id,
                              p_program_name => c_program_name,
                              p_error_text => o_response);
        RETURN;
      ELSE
        -- Apply BOGO by getting the required PIN generated
        --
        sa.BYOP_SERVICE_PKG.generate_attach_free_pin (in_esn => ig.esn,
                                                      in_pin_part_num => c_bogo_part_number,
                                                      in_inv_bin_objid => n_inv_bin_objid,
                                                      in_reserve_status => g_pin_reserve_status,
                                                      out_soft_pin => c_out_soft_pin,
                                                      out_smp_number => c_smp_number,
                                                      out_err_num => n_error_num,
                                                      out_err_msg => c_error_code);
        --
        IF c_error_code IS NOT NULL THEN

          o_response := 'PIN NOT CREATED: ' || c_error_code;

          input_bogo_error_log (p_action => 'Error code found - free pin benefit not applied',
                                p_error_date => sysdate,
                                p_key => i_transaction_id,
                                p_program_name => c_program_name,
                                p_error_text => o_response);
          RETURN;

        ELSE

          BEGIN
            INSERT INTO sa.mtm_bogo_bi_info (objid,
                                             bogo_objid,
                                             esn,
                                             call_trans_objid,
                                             original_red_code,
                                             bogo_smp,
                                             bogo_part_num,
                                             bogo_red_card_pin,
                                             transaction_dt)
                                     VALUES (seq_mtm_bogo_bi_info.NEXTVAL,    -- objid
                                             n_bogo_objid,                    -- bogo_objid
                                             ig.esn,                          -- esn
                                             c_ct_objid,                      -- call_trans_objid
                                             c_x_red_code,                    -- original_red_code
                                             c_smp_number,                    -- bogo_smp
                                             c_bogo_part_number,              -- bogo_part_num
                                             c_out_soft_pin,                  -- bogo_red_card_pin
                                             sysdate);                        -- transaction_dt
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              o_response := 'ERROR inserting values to X_BOGO_BI_INFO - '||SUBSTR(SQLERRM, 1, 200);
              input_bogo_error_log (p_action => 'call for insert to sa.X_BOGO_BI_INFO failed',
                                    p_error_date => sysdate,
                                    p_key => i_transaction_id,
                                    p_program_name => c_program_name,
                                    p_error_text => o_response);
              RETURN;
          END;
          --
          BEGIN
            --
            INSERT INTO sa.byop_sms_stg (esn,
                                         min,
                                         carrier_id,
                                         transaction_type,
                                         x_msg_script_id,
                                         insert_date)
                                         (SELECT ig.esn,
                                                 cst.min,
                                                 (SELECT x_carrier_id
                                                    FROM sa.table_part_inst
                                                   INNER JOIN sa.table_x_carrier
                                                           ON table_x_carrier.objid = part_inst2carrier_mkt
                                                        WHERE part_serial_no = cst.min) carrier_id,
                                                 'BOGO',
                                                 c_msg_script_id,
                                                 SYSDATE
                                            FROM dual);
            --
            COMMIT;
            --
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              o_response := 'ERROR CREATING BYOP SMS STG - '||SUBSTR(SQLERRM, 1, 200);
              input_bogo_error_log (p_action => 'call for insert to sa.byop_sms_stg failed',
                                    p_error_date => sysdate,
                                    p_key => i_transaction_id,
                                    p_program_name => c_program_name,
                                    p_error_text => o_response);
              RETURN;
          END;

        END IF;

      END IF;
      --
      o_response := 'SUCCESS';
      --
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'MAIN sp_validate_and_apply_bogo call Failed - '||SUBSTR(SQLERRM, 1, 200);
      input_bogo_error_log (p_action => 'Main procedure sp_validate_and_apply_bogo execution failed',
                            p_error_date => sysdate,
                            p_key => i_transaction_id,
                            p_program_name => c_program_name,
                            p_error_text => o_response);
  END sp_validate_and_apply_bogo;
--
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--
  PROCEDURE sp_bogo (i_esn                IN table_part_inst.part_serial_no%TYPE ,
                     i_channel            IN table_x_call_trans.x_sourcesystem%TYPE,
                     i_action             IN x_ig_order_type.x_actual_order_type%TYPE,
                     i_red_card_pin       IN table_x_red_card.x_red_code%TYPE,
                     i_service_plan_objid IN x_service_plan.objid%TYPE,
                     i_call_trans_objid   IN table_x_call_trans.objid%TYPE,
                     i_apply_bogo         IN VARCHAR2,
                     i_tsp_id             IN x_bogo_configuration.tsp_id%TYPE,
                     o_bogo               OUT VARCHAR2,
                     o_free_pin_number    OUT VARCHAR2,
                     o_response           OUT VARCHAR2)
  IS

    -- CR48916 - Updated process to improve performance and add new requirements//OImana
    -- CR51833 - Added variable c_pin_reserve_status to set the PART_INS records reserve status code.
    -- CR51833 - g_pin_reserve_status is set by default to 400 - RESERVED QUEUED

    c_brand                   VARCHAR2(1000);
    c_bogo_config_flag        x_ig_order_type.x_bogo_config_flag%TYPE;
    c_part_serial_no          table_part_inst.part_serial_no%TYPE;
    c_part_class_name         table_part_class.name%TYPE;
    c_part_number             table_part_num.part_number%TYPE;
    c_dealer_id               table_inv_bin.bin_name%TYPE;
    c_smp_number              table_part_inst.part_serial_no%TYPE;
    c_out_soft_pin            table_x_cc_red_inv.x_red_card_number%TYPE;
    c_pin_reserve_status      table_part_inst.x_part_inst_status%TYPE;
    c_inv_bin_objid           table_inv_bin.objid%TYPE;
    c_brand_bogo_enabled      table_bus_org.bogo_enabled_flag%TYPE;
    c_brm_notification_flag   table_bus_org.brm_notification_flag%TYPE;
    c_bogo_objid              x_bogo_configuration.objid%TYPE;
    c_msg_script_id           x_bogo_configuration.msg_script_id%TYPE;
    c_bogo_part_number        x_bogo_configuration.bogo_part_number%TYPE;
    c_card_pin_part_class     x_bogo_configuration.card_pin_part_class%TYPE;
    c_action_type             x_bogo_configuration.action_type%TYPE;
    c_all_action_type         x_bogo_configuration.action_type%TYPE;
    c_bogo_status             x_bogo_configuration.bogo_status%TYPE;
    c_service_plan_objid      x_service_plan.objid%TYPE;
    c_tsp_name                x_bogo_tsp_id.tsp_name%TYPE;
    c_key                     error_table.key%TYPE;
    c_procedure               VARCHAR2(100);
    c_error_code              VARCHAR2(1000);
    c_brand_count             NUMBER := 0;
    c_benefit_count           NUMBER := 0;
    c_error_num               NUMBER;
    c_db_name                 VARCHAR2(240);

    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    -- Main procedure starts
    --
  BEGIN
    --
    BEGIN
      SELECT name
        INTO c_db_name
        FROM v$database;
    EXCEPTION
      WHEN OTHERS THEN
        c_db_name := NULL;
    END;
    --
    -- CR48916 - Write to error table when it is not production Db for debugging and testing.
    IF (c_db_name NOT IN('CLFYTOPP','CLFYRTRP')) AND (c_db_name IS NOT NULL) THEN
      g_error_log_flag := 'Y';
    END IF;
    --
    -- CR46345/CR47135 - Added new option P to return PIN generated by process
    IF i_apply_bogo = 'Y' THEN
      c_procedure := 'SP_APPLY_BOGO';
    ELSIF i_apply_bogo = 'P' THEN
      c_procedure := 'SP_REDEEM_FREE_PIN_NO';
    ELSE
      c_procedure := 'SP_BOGO_ELIGIBILITY';
    END IF;
    --
    o_bogo := 'N';
    o_response := NULL;
    o_free_pin_number := NULL;
    c_card_pin_part_class := NULL;
    c_bogo_status := 'ACTIVE';
    --
    -- data provided as input
    --
    c_key := 'i_esn=<'               ||i_esn               ||'> '||
             'i_channel=<'           ||i_channel           ||'> '||
             'i_action=<'            ||i_action            ||'> '||
             'i_red_card_pin=<'      ||i_red_card_pin      ||'> '||
             'i_service_plan_objid=<'||i_service_plan_objid||'> '||
             'i_call_trans_objid=<'  ||i_call_trans_objid  ||'> '||
             'i_tsp_id=<'            ||i_tsp_id            ||'> '||
             'c_procedure=<'         ||c_procedure         ||'> ';
    --
    DBMS_OUTPUT.put_line ('c_key: '||c_key);
    -- Get the brand for input esn
    c_brand := sa.BAU_UTIL_PKG.get_esn_brand (i_esn);
    --
    -- Check if the Brand is configured for BOGO
    BEGIN
      SELECT COUNT(1)
        INTO c_brand_count
        FROM sa.x_bogo_configuration
       WHERE brand = c_brand
         AND bogo_status = 'ACTIVE';
    EXCEPTION
      WHEN OTHERS THEN
        o_response         := 'ERROR While checking COUNT of BRAND - '||SUBSTR(SQLERRM, 1, 200);
        input_bogo_error_log (p_action => 'Validating COUNT of BRAND - '||i_esn||' ~ '||c_brand,
                              p_error_date => sysdate,
                              p_key => c_key,
                              p_program_name => 'BOGO_PKG.'||c_procedure,
                              p_error_text => o_response);
      RETURN;
    END;
    --
    IF c_brand_count = 0 THEN
      o_response         := 'Error: BOGO is not applicable for Brand provided - '||c_brand;
      input_bogo_error_log (p_action => 'Validating COUNT of BRAND - '||i_esn||' ~ '||c_brand||' ~ '||c_brand_count,
                            p_error_date => sysdate,
                            p_key => c_key,
                            p_program_name => 'BOGO_PKG.'||c_procedure,
                            p_error_text => o_response);
      RETURN;
    END IF;
    --
    -- CR51833/CR50105 - Check if the Brand is enables for BOGO and BRM enabled//OImana
    BEGIN
      SELECT NVL(tbo.bogo_enabled_flag,'N'),
             NVL(tbo.brm_notification_flag,'N')
        INTO c_brand_bogo_enabled,
             c_brm_notification_flag
        FROM sa.table_bus_org tbo
       WHERE tbo.org_id = c_brand;
    EXCEPTION
      WHEN OTHERS THEN
        o_response         := 'ERROR While checking BOGO enabled flag and BRM Notification of BRAND - '||SUBSTR(SQLERRM, 1, 200);
        input_bogo_error_log (p_action => 'Validating BOGO flag for BRAND - '||i_esn||' ~ '||c_brand,
                              p_error_date => sysdate,
                              p_key => c_key,
                              p_program_name => 'BOGO_PKG.'||c_procedure,
                              p_error_text => o_response);
        RETURN;
    END;
    --
    IF c_brm_notification_flag = 'Y' THEN
      -- CR51833 - Set the value to '40' (RESERVED) only for WFM bogo or promo code//OImana.
      -- CR50105 - Check if ESN/Brand is BRM enabled and assign the x_part_inst_status to '40' (RESERVED) if yes//OImana
      c_pin_reserve_status := '40';
    ELSE
      c_pin_reserve_status := g_pin_reserve_status;
    END IF;
    --
    IF (NVL(g_enable_org_bogo,'N') = 'N') AND (c_brand_bogo_enabled = 'N') THEN
      o_response         := 'Error: BOGO process is not enabled for the Brand provided - <'||c_brand||'><'||g_enable_org_bogo||'>';
      input_bogo_error_log (p_action => 'Validating BOGO availability for BRAND - '||i_esn||' ~ '||c_brand||' ~ '||c_brand_bogo_enabled,
                            p_error_date => sysdate,
                            p_key => c_key,
                            p_program_name => 'BOGO_PKG.'||c_procedure,
                            p_error_text => o_response);
      RETURN;
    END IF;
    --
    BEGIN
      SELECT action_type,
             'ALL' all_action_type
        INTO c_action_type,
             c_all_action_type
        FROM sa.x_bogo_action_type
       WHERE action_type = i_action;
    EXCEPTION
      WHEN OTHERS THEN
        o_response         := 'ERROR Validating Action Type - ' || SQLCODE||' - '||SUBSTR(SQLERRM, 1, 200);
        input_bogo_error_log (p_action => 'Validation for Action Type FAILED for '||i_action,
                              p_error_date => sysdate,
                              p_key => c_key,
                              p_program_name => 'BOGO_PKG.'||c_procedure,
                              p_error_text => o_response);
        RETURN;
    END;
    --
    BEGIN
      SELECT pi.part_serial_no  part_serial_no,
             pc.name            part_class_name,
             pn.part_number     part_number,
             inv.bin_name       dealer_id,
             inv.objid          inv_bin_objid
        INTO c_part_serial_no,
             c_part_class_name,
             c_part_number,
             c_dealer_id,
             c_inv_bin_objid
        FROM sa.table_part_inst pi,
             sa.table_mod_level ml,
             sa.table_part_num pn,
             sa.table_part_class pc,
             sa.table_inv_bin inv,
             sa.table_bus_org tbo
       WHERE tbo.objid         = pn.part_num2bus_org
         AND pc.objid          = pn.part_num2part_class
         AND pn.active         = 'Active'
         AND pn.objid          = ml.part_info2part_num
         AND inv.objid         = pi.part_inst2inv_bin
         AND ml.objid          = pi.n_part_inst2part_mod
         AND tbo.org_id        = c_brand
         AND pi.part_serial_no = i_esn;
    EXCEPTION
      WHEN OTHERS THEN
        o_response         := 'ERROR Retrieving c_part_class_name, c_part_number, c_dealer_id - ' || SQLCODE||' - '||SUBSTR(SQLERRM, 1, 200);
        input_bogo_error_log (p_action => 'Validation for part_class_name, part_number, dealer_id FAILED for '||i_esn||' ~ '||c_brand,
                              p_error_date => sysdate,
                              p_key => c_key,
                              p_program_name => 'BOGO_PKG.'||c_procedure,
                              p_error_text => o_response);
        RETURN;
    END;
    --
    IF i_service_plan_objid IS NULL THEN

      BEGIN
        --
        c_service_plan_objid := sa.get_service_plan_id (i_esn, i_red_card_pin);
        --
      EXCEPTION
        WHEN OTHERS THEN
          o_response         := 'ERROR when retrieving c_service_plan_objid - '||SUBSTR(SQLERRM, 1, 200);
          input_bogo_error_log (p_action => 'Call for sa.get_service_plan_id FAILED for '||i_esn||' ~ '||i_red_card_pin,
                                p_error_date => sysdate,
                                p_key => c_key,
                                p_program_name => 'BOGO_PKG.'||c_procedure,
                                p_error_text => o_response);
          RETURN;
      END;

      IF c_service_plan_objid IS NULL THEN

          o_response         := 'ERROR - No service plan found for ESN and card PIN provided';

          input_bogo_error_log (p_action => 'Call for sa.get_service_plan_id FAILED for '||i_esn||' ~ '||i_red_card_pin,
                                p_error_date => sysdate,
                                p_key => c_key,
                                p_program_name => 'BOGO_PKG.'||c_procedure,
                                p_error_text => o_response);

          RETURN;

      END IF;

    ELSE

      c_service_plan_objid := i_service_plan_objid;

    END IF;
    --
    -- CR47135/CR52740 - Added validation for TSP parameter and SM brand//OImana
    -- CR52740 - Decommissioned table sa.x_bogo_tsp_list created for CR47135 as TSP will be store in BOGO table//OImana
    --
    IF (c_dealer_id IS NULL) AND (i_tsp_id IS NULL) THEN

        o_response := 'ERROR - Missing value for dealer ID and tsp ID';

        input_bogo_error_log (p_action => 'Check for DEALER_ID and TSP_ID input value.',
                              p_error_date => sysdate,
                              p_key => c_key,
                              p_program_name => 'BOGO_PKG.'||c_procedure,
                              p_error_text => o_response);

        RETURN;

    ELSIF (i_tsp_id IS NOT NULL) THEN

        BEGIN
          SELECT tsp_name
            INTO c_tsp_name
            FROM sa.x_bogo_tsp_id
           WHERE (door_status = 'DEFAULT' OR door_status IS NULL)
             AND door_type = 'Exclusive'
             AND tsp_id = i_tsp_id;
        EXCEPTION
          WHEN OTHERS THEN
            o_response := 'ERROR in Search for TSP_ID - '||SUBSTR(SQLERRM, 1, 200);
            input_bogo_error_log (p_action => 'TSP_ID search for ~ '||i_tsp_id,
                                  p_error_date => sysdate,
                                  p_key => c_key,
                                  p_program_name => 'BOGO_PKG.'||c_procedure,
                                  p_error_text => o_response);
            RETURN;
        END;

    END IF;
    --
    -- CR46345 - Validate if TF red card PIN exists//OImana
    IF NVL(c_brand, 'X') = 'TRACFONE' THEN
      --
      BEGIN
        SELECT pc.name pin_part_class_name
          INTO c_card_pin_part_class
          FROM sa.table_part_inst pi,
               sa.table_mod_level ml,
               sa.table_part_num pn,
               sa.table_part_class pc
         WHERE ml.objid      = pi.n_part_inst2part_mod
           AND pn.objid      = ml.part_info2part_num
           AND pn.active     = 'Active'
           AND pn.domain     = pi.x_domain
           AND pc.objid      = pn.part_num2part_class
           AND pi.x_domain   = 'REDEMPTION CARDS'
           AND pi.x_red_code = i_red_card_pin;
      EXCEPTION
        WHEN OTHERS THEN
          -- CR46345 - Checking if benefit has been used/OImana
          BEGIN
            SELECT pc.name pin_part_class_name
              INTO c_card_pin_part_class
              FROM sa.table_x_red_card pi,
                   sa.table_mod_level ml,
                   sa.table_part_num pn,
                   sa.table_part_class pc
             WHERE ml.objid      = pi.x_red_card2part_mod
               AND pn.objid      = ml.part_info2part_num
               AND pc.objid      = pn.part_num2part_class
               AND pn.active     = 'Active'
               AND pn.domain     = 'REDEMPTION CARDS'
               AND pi.x_red_code = i_red_card_pin;
          EXCEPTION
            WHEN OTHERS THEN
              o_response := 'ERROR in Search for Red Card Pin Part Class - '||SUBSTR(SQLERRM, 1, 200);
              input_bogo_error_log (p_action => 'Red Card Pin Part Class Search for PIN ~ '||c_brand||' ~ '||i_red_card_pin,
                                    p_error_date => sysdate,
                                    p_key => c_key,
                                    p_program_name => 'BOGO_PKG.'||c_procedure,
                                    p_error_text => o_response);
              RETURN;
          END;
      END;
      --
    END IF;
    --
    -- CR46345//CR47135//CR48916 - Update validations for TF BOGO and TSP//07-24-2017//TracfoneInc//OImana
    -- CR48916 - Need to check first with ESN part number and if not found check with ESN part class//OImana
    -- CR47135 - If No Data Found Exception reached then do not report in error table//OImana
    BEGIN
      SELECT objid,
             msg_script_id,
             bogo_part_number
        INTO c_bogo_objid,
             c_msg_script_id,
             c_bogo_part_number
        FROM sa.x_bogo_configuration
       WHERE brand                  = c_brand
         AND esn_part_class         IS NULL
         AND esn_part_number        = c_part_number
         AND (esn_dealer_id         = NVL2(i_tsp_id, esn_dealer_id, c_dealer_id) OR esn_dealer_id IS NULL)
         AND (tsp_id                = NVL2(i_tsp_id, i_tsp_id, tsp_id) OR tsp_id IS NULL)
         AND eligible_service_plan  = DECODE(c_brand, 'TRACFONE', eligible_service_plan, c_service_plan_objid)
         AND (card_pin_part_class   = DECODE(c_brand, 'TRACFONE', c_card_pin_part_class, card_pin_part_class)
          OR  card_pin_part_class   IS NULL)
         AND action_type            = (CASE WHEN c_action_type = action_type
                                            THEN c_action_type
                                            ELSE c_all_action_type
                                        END)
         AND channel                = i_channel
         AND sysdate BETWEEN bogo_start_date AND bogo_end_date
         AND bogo_status = c_bogo_status;
    EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          SELECT objid,
                 msg_script_id,
                 bogo_part_number
            INTO c_bogo_objid,
                 c_msg_script_id,
                 c_bogo_part_number
            FROM sa.x_bogo_configuration
           WHERE brand                  = c_brand
             AND esn_part_class         = c_part_class_name
             AND esn_part_number        IS NULL
             AND (esn_dealer_id         = NVL2(i_tsp_id, esn_dealer_id, c_dealer_id) OR esn_dealer_id IS NULL)
             AND (tsp_id                = NVL2(i_tsp_id, i_tsp_id, tsp_id) OR tsp_id IS NULL)
             AND eligible_service_plan  = DECODE(c_brand, 'TRACFONE', eligible_service_plan, c_service_plan_objid)
             AND (card_pin_part_class   = DECODE(c_brand, 'TRACFONE', c_card_pin_part_class, card_pin_part_class)
              OR  card_pin_part_class   IS NULL)
             AND action_type            = (CASE WHEN c_action_type = action_type
                                                THEN c_action_type
                                                ELSE c_all_action_type
                                            END)
             AND channel                = i_channel
             AND sysdate BETWEEN bogo_start_date AND bogo_end_date
             AND bogo_status = c_bogo_status;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            o_response := 'Input data not matched with any active BOGO CONFIGURATION - No Data Found.';
            DBMS_OUTPUT.put_line (o_response);
            RETURN;
          WHEN OTHERS THEN
            o_response := 'BOGO CONFIGURATION Record Error - '||SUBSTR(SQLERRM, 1, 200);
            input_bogo_error_log (p_action => 'Validation for x_bogo_configuration for values ~ ' ||c_brand||' ~ '||c_part_class_name||' ~ '||
                                              c_part_number||' ~ '||i_tsp_id||' ~ '||c_dealer_id||' ~ '||c_service_plan_objid|| ' ~ '||
                                              c_card_pin_part_class||' ~ '||i_action||' ~ '||i_channel||' ~ '||c_bogo_status||' ~ '||sysdate,
                                  p_error_date => sysdate,
                                  p_key => c_key,
                                  p_program_name => 'BOGO_PKG.'||c_procedure,
                                  p_error_text => o_response);
            RETURN;
        END;
    END;
    --
    -- CR50105 - Ensure only ONE BOGO is applied to given active ESN at a time//OImana
    BEGIN
      SELECT SUM (cnt)
        INTO c_benefit_count
        FROM (SELECT COUNT(1) cnt
                FROM sa.table_part_inst pi,
                     sa.table_part_num pn,
                     sa.table_mod_level ml
               WHERE ml.objid = pi.n_part_inst2part_mod
                 AND pi.part_to_esn2part_inst = (SELECT pi2.objid
                                                   FROM sa.table_part_inst pi2
                                                  WHERE pi2.part_serial_no = i_esn)
                 AND pn.objid                 = ml.part_info2part_num
                 AND pn.active                = 'Active'
                 AND pn.domain                = 'REDEMPTION CARDS'
                 AND (pn.part_number          = c_bogo_part_number
                  OR INSTR(pn.part_number,'BOGO') > 0)
              UNION
              SELECT COUNT(1) cnt
                FROM sa.table_x_call_trans ct,
                     sa.table_x_red_card rc,
                     sa.table_part_inst pi,
                     sa.table_part_num pn,
                     sa.table_mod_level ml
               WHERE ml.objid               = rc.x_red_card2part_mod
                 AND rc.red_card2call_trans = ct.objid
                 AND ct.x_service_id        = pi.part_serial_no
                 AND pn.objid               = ml.part_info2part_num
                 AND pn.active              = 'Active'
                 AND pn.domain              = 'REDEMPTION CARDS'
                 AND (pn.part_number        = c_bogo_part_number
                  OR INSTR(pn.part_number,'BOGO') > 0)
                 AND pi.part_serial_no      = i_esn);
    EXCEPTION
      WHEN OTHERS THEN
        c_benefit_count := -1;
        o_response      := 'ERROR While Getting c_benefit_count: - '||SUBSTR(SQLERRM, 1, 200);
        input_bogo_error_log (p_action => 'Validating c_benefit_count for values ~ '||i_esn||' ~ '||c_bogo_part_number,
                              p_error_date => sysdate,
                              p_key => c_key,
                              p_program_name => 'BOGO_PKG.'||c_procedure,
                              p_error_text => o_response);
        RETURN;
    END;
    --
    IF c_benefit_count <> 0 THEN
      --
      o_response       := 'ERROR: BOGO Benefit already provided ('||c_benefit_count||') to ESN and Phone Number';
      input_bogo_error_log (p_action => 'BOGO Benefit check provided - c_benefit_count = ' ||
                                        c_benefit_count||' for ~ '||i_esn||' ~ '||c_bogo_part_number,
                            p_error_date => sysdate,
                            p_key => c_key,
                            p_program_name => 'BOGO_PKG.'||c_procedure,
                            p_error_text => o_response);
      RETURN;
      --
    END IF;
    --
    IF c_procedure = 'SP_BOGO_ELIGIBILITY' THEN
      o_response := 'SUCCESS';
      o_bogo     := 'Y';
      RETURN;
    ELSIF c_procedure IN('SP_APPLY_BOGO','SP_REDEEM_FREE_PIN_NO') THEN
      --
      c_out_soft_pin := NULL;
      --
      -- Apply BOGO by getting the required PIN generated
      -- Free Pin option for FT
      -- Check for the error code c_error_code to halt process and rollback
      --
      sa.BYOP_SERVICE_PKG.generate_attach_free_pin (in_esn             => i_esn,
                                                    in_pin_part_num    => c_bogo_part_number,
                                                    in_inv_bin_objid   => c_inv_bin_objid,
                                                    in_reserve_status  => c_pin_reserve_status,
                                                    out_soft_pin       => c_out_soft_pin,
                                                    out_smp_number     => c_smp_number,
                                                    out_err_num        => c_error_num,
                                                    out_err_msg        => c_error_code);
      --
      IF c_error_code IS NOT NULL THEN
        --
        o_response := 'ERROR: New Free PIN Number Not Created: '||c_error_code||' ~ '||c_out_soft_pin||' ~ '||c_smp_number;
        input_bogo_error_log (p_action => 'Execution of generate_attach_free_pin for '||i_esn||' ~ '||
                                          c_bogo_part_number||' ~ '||c_inv_bin_objid||' ~ '||c_pin_reserve_status,
                              p_error_date => sysdate,
                              p_key => c_key,
                              p_program_name => 'BOGO_PKG.'||c_procedure,
                              p_error_text => o_response);
        RETURN;
        --
      ELSE
        -- CR47135 - Added TSP_ID column to insert for SM BOGO//OImana
        BEGIN
          INSERT INTO sa.mtm_bogo_bi_info (objid,
                                           bogo_objid,
                                           esn,
                                           call_trans_objid,
                                           original_red_code,
                                           bogo_smp,
                                           bogo_part_num,
                                           bogo_red_card_pin,
                                           transaction_dt,
                                           tsp_id)
                                   VALUES (sa.seq_mtm_bogo_bi_info.NEXTVAL, -- objid
                                           c_bogo_objid,                    -- bogo_objid
                                           i_esn,                           -- esn
                                           i_call_trans_objid,              -- call_trans_objid
                                           i_red_card_pin,                  -- original_red_code
                                           c_smp_number,                    -- bogo_smp
                                           c_bogo_part_number,              -- bogo_part_num
                                           c_out_soft_pin,                  -- bogo_red_card_pin
                                           sysdate,                         -- transaction_dt
                                           i_tsp_id);                       -- tsp_id
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            o_response := 'ERROR While Inserting Values to MTM_BOGO_BI_INFO Table - '||SUBSTR(SQLERRM, 1, 200);
            input_bogo_error_log (p_action => 'Inserting Record to SA.MTM_BOGO_BI_INFO with new PIN: '||c_out_soft_pin||' ~ '||
                                              c_smp_number||' ~ '||i_esn||' ~ '||i_red_card_pin||' ~ '||c_bogo_part_number,
                                  p_error_date => sysdate,
                                  p_key => c_key,
                                  p_program_name => 'BOGO_PKG.'||c_procedure,
                                  p_error_text => o_response);
            RETURN;
        END;
        --
        BEGIN
          INSERT INTO sa.byop_sms_stg (esn,
                                       min,
                                       carrier_id,
                                       transaction_type,
                                       x_msg_script_id,
                                       insert_date)
                                      (SELECT i_esn,
                                              NULL min,
                                              NULL carrier_id,
                                              'BOGO' transaction_type,
                                              c_msg_script_id,
                                              SYSDATE
                                         FROM dual);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            o_response := 'ERROR While Inserting Values to SA.BYOP_SMS_STG Table - '||SUBSTR(SQLERRM, 1, 200);
            input_bogo_error_log (p_action => 'Inserting Record to SA.BYOP_SMS_STG with new PIN: '||c_msg_script_id||' ~ '||i_esn,
                                  p_error_date => sysdate,
                                  p_key => c_key,
                                  p_program_name => 'BOGO_PKG.'||c_procedure,
                                  p_error_text => o_response);
            RETURN;
        END;
        --
        o_free_pin_number := c_out_soft_pin;
        --
      END IF;
      --
    ELSE
      --
      o_response := 'ERROR - Failed Execution - BOGO_PKG.'||c_procedure;
      input_bogo_error_log (p_action => 'Invalid Procedure Called for BOGO Process - No Action Executed.',
                            p_error_date => sysdate,
                            p_key => c_key,
                            p_program_name => 'BOGO_PKG.'||c_procedure,
                            p_error_text => o_response);
      RETURN;
      --
    END IF;
    --
    COMMIT;
    --
    o_response := 'SUCCESS';
    o_bogo     := 'Y';
    --
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      o_response := 'ERROR in MAIN SP_BOGO Procedure - '||SUBSTR(SQLERRM, 1, 200);
      input_bogo_error_log (p_action => 'ERROR in MAIN call to SP_BOGO ***',
                            p_error_date => sysdate,
                            p_key => c_key,
                            p_program_name => 'BOGO_PKG.'||c_procedure,
                            p_error_text => o_response);
  END sp_bogo;
--
  PROCEDURE sp_bogo_eligibility (i_esn                IN table_part_inst.part_serial_no%TYPE ,
                                 i_channel            IN table_x_call_trans.x_sourcesystem%TYPE,
                                 i_action             IN x_ig_order_type.x_actual_order_type%TYPE,
                                 i_red_card_pin       IN table_x_red_card.x_red_code%TYPE DEFAULT NULL,
                                 i_service_plan_objid IN x_service_plan.objid%TYPE DEFAULT NULL,
                                 o_bogo_eligible      OUT VARCHAR2,
                                 o_response           OUT VARCHAR2)
  IS
  --
  c_free_pin_number  VARCHAR2(100) := NULL;
  --
  BEGIN
    --
    update_bogo_status;
    --
    g_enable_org_bogo := 'N';
    --
    sp_bogo (i_esn                => i_esn,
             i_channel            => i_channel,
             i_action             => i_action,
             i_red_card_pin       => i_red_card_pin,
             i_service_plan_objid => i_service_plan_objid,
             i_call_trans_objid   => NULL,
             i_apply_bogo         => 'N',
             i_tsp_id             => NULL,
             o_bogo               => o_bogo_eligible,
             o_free_pin_number    => c_free_pin_number,
             o_response           => o_response);
    --
    IF NVL(o_response,'X') <> 'SUCCESS' THEN
      DBMS_OUTPUT.put_line ('SP_BOGO_ELIGIBILITY');
      DBMS_OUTPUT.put_line ('O_BOGO:            '||o_bogo_eligible);
      DBMS_OUTPUT.put_line ('O_RESPONSE:        '||o_response);
      DBMS_OUTPUT.put_line ('O_FREE_PIN_NUMBER: '||c_free_pin_number);
    END IF;
    --
  END sp_bogo_eligibility;
--
  PROCEDURE sp_apply_bogo (i_esn                IN table_part_inst.part_serial_no%TYPE ,
                           i_channel            IN table_x_call_trans.x_sourcesystem%TYPE,
                           i_action             IN x_ig_order_type.x_actual_order_type%TYPE,
                           i_red_card_pin       IN table_x_red_card.x_red_code%TYPE DEFAULT NULL,
                           i_service_plan_objid IN x_service_plan.objid%TYPE DEFAULT NULL,
                           i_call_trans_objid   IN table_x_call_trans.objid%TYPE DEFAULT NULL,
                           o_bogo_applied       OUT VARCHAR2,
                           o_response           OUT VARCHAR2)
  IS
  --
  c_free_pin_number  VARCHAR2(100) := NULL;
  --
  BEGIN
    --
    update_bogo_status;
    --
    g_enable_org_bogo := 'N';
    --
    sp_bogo (i_esn                => i_esn,
             i_channel            => i_channel,
             i_action             => i_action,
             i_red_card_pin       => i_red_card_pin,
             i_service_plan_objid => i_service_plan_objid,
             i_call_trans_objid   => i_call_trans_objid,
             i_apply_bogo         => 'Y',
             i_tsp_id             => NULL,
             o_bogo               => o_bogo_applied,
             o_free_pin_number    => c_free_pin_number,
             o_response           => o_response);
    --
    IF NVL(o_response,'X') <> 'SUCCESS' THEN
      DBMS_OUTPUT.put_line ('SP_APPLY_BOGO');
      DBMS_OUTPUT.put_line ('O_BOGO:            '||o_bogo_applied);
      DBMS_OUTPUT.put_line ('O_RESPONSE:        '||o_response);
      DBMS_OUTPUT.put_line ('O_FREE_PIN_NUMBER: '||c_free_pin_number);
    END IF;
    --
  END sp_apply_bogo;
--
  PROCEDURE sp_redeem_free_pin_no (i_esn                IN table_part_inst.part_serial_no%TYPE,
                                   i_channel            IN table_x_call_trans.x_sourcesystem%TYPE,
                                   i_action             IN x_ig_order_type.x_actual_order_type%TYPE,
                                   i_red_card_pin       IN table_x_red_card.x_red_code%TYPE DEFAULT NULL,
                                   i_service_plan_objid IN x_service_plan.objid%TYPE DEFAULT NULL,
                                   i_call_trans_objid   IN table_x_call_trans.objid%TYPE DEFAULT NULL,
                                   i_tsp_id             IN x_bogo_configuration.tsp_id%TYPE DEFAULT NULL,
                                   o_bogo_applied       OUT VARCHAR2,
                                   o_free_pin_number    OUT VARCHAR2,
                                   o_response           OUT VARCHAR2)
  IS
  --
  BEGIN
    --
    update_bogo_status;
    --
    g_enable_org_bogo := 'N';
    --
    sp_bogo (i_esn                => i_esn,
             i_channel            => i_channel,
             i_action             => i_action,
             i_red_card_pin       => i_red_card_pin,
             i_service_plan_objid => i_service_plan_objid,
             i_call_trans_objid   => i_call_trans_objid,
             i_apply_bogo         => 'P',
             i_tsp_id             => TRIM(i_tsp_id),
             o_bogo               => o_bogo_applied,
             o_free_pin_number    => o_free_pin_number,
             o_response           => o_response);
    --
    IF NVL(o_response,'X') <> 'SUCCESS' THEN
      DBMS_OUTPUT.put_line ('SP_REDEEM_FREE_PIN_NO');
      DBMS_OUTPUT.put_line ('O_BOGO:            '||o_bogo_applied);
      DBMS_OUTPUT.put_line ('O_RESPONSE:        '||o_response);
      DBMS_OUTPUT.put_line ('O_FREE_PIN_NUMBER: '||o_free_pin_number);
    END IF;
    --
  END sp_redeem_free_pin_no;
--
  PROCEDURE wfm_promo_code_pin (i_min                 IN  table_site_part.x_min%TYPE,
                                i_promo_code          IN  x_wfm_min_promo_code.promo_code%TYPE,
                                i_channel             IN  table_x_call_trans.x_sourcesystem%TYPE,
                                i_brand               IN  table_bus_org.org_id%TYPE DEFAULT 'WFM',
                                o_promo_applied       OUT VARCHAR2,
                                o_promo_response      OUT VARCHAR2,
                                o_promo_pin_number    OUT VARCHAR2)
  IS
  -- CR51833 - WFM BOGO Activation Promo Code to retrieve PIN//OImana
  -- CR51833 - Error codes provided by PSI Team to map to library used for verbiage presented to customers.
  --
  l_esn                 table_part_inst.part_serial_no%TYPE;
  l_service_plan_objid  x_service_plan.objid%TYPE;
  l_domain              table_part_num.domain%TYPE;
  l_action              x_ig_order_type.x_actual_order_type%TYPE;
  l_trans_type          table_x_call_trans.x_action_type%TYPE;
  l_call_trans_objid    table_x_call_trans.objid%TYPE;
  l_transact_date       table_x_call_trans.x_transact_date%TYPE;
  l_site_part_objid     table_site_part.objid%TYPE;
  l_brand               table_bus_org.org_id%TYPE;
  l_promo_code          x_wfm_min_promo_code.promo_code%TYPE;
  l_promo_min           x_wfm_min_promo_code.promo_min%TYPE;
  l_promo_status        x_wfm_min_promo_code.promo_status%TYPE;
  l_applied_promo_code  x_wfm_min_promo_code.promo_code%TYPE;
  l_max_days            NUMBER;
  l_min_days            NUMBER;
  l_days_diff           NUMBER;
  l_upd_flag            VARCHAR2(30);
  l_upd_response        VARCHAR2(2400);
  --
  BEGIN
    --
    g_enable_org_bogo   := 'N';         -- CR51833 - Enable BOGO process global flag with N//OImana
    --
    o_promo_applied     := 'RDSG_5399';
    o_promo_response    := 'ERROR WF001 - Process failed to initialize the promo code assignment to phone number';
    o_promo_pin_number  := NULL;

    l_domain            := 'PHONES';
    l_action            := 'Activation';
    l_trans_type        := NULL;         -- CR51833//CR55631//CR56696 - table_x_call_trans type should be activation and reactivation only//OImana.
    --
    IF (i_min IS NULL) OR (i_promo_code IS NULL) OR (i_channel IS NULL) THEN

        o_promo_applied  := 'RDSG_5399';
        o_promo_response := 'ERROR WF002 - Input values for min, promo code or channel are missing: <'||i_min||'> or <'||i_promo_code||'> or <'||i_channel||'>';

        RETURN;

    END IF;
    --
    -- CR55631 - Promo codes in table must be kept in upper case.
    BEGIN
      SELECT promo_code,
             TRIM(promo_min),
             promo_status,
             NVL(i_brand,'WFM') brand       --Default value 'WFM'
        INTO l_promo_code,
             l_promo_min,
             l_promo_status,
             l_brand
        FROM sa.x_wfm_min_promo_code
       WHERE promo_code = UPPER(i_promo_code);
    EXCEPTION
      WHEN OTHERS THEN
        l_promo_code     := NULL;
        l_promo_status   := NULL;
        o_promo_applied  := 'ERROR_1985875';
        o_promo_response := 'ERROR WF003 - Invalid promo code provided: <'||i_promo_code||'> - '||SUBSTR(SQLERRM, 1, 200);
        RETURN;
    END;
    --
    IF (l_promo_status = 'NEW') AND (l_promo_min IS NULL) THEN

      BEGIN
        SELECT promo_code
          INTO l_applied_promo_code
          FROM sa.x_wfm_min_promo_code
         WHERE promo_min = i_min
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_applied_promo_code := NULL;
        WHEN OTHERS THEN
          o_promo_applied  := 'RDSG_5399';
          o_promo_response := 'ERROR WF004 - Cannot validate if phone number has previously received a promo code: <'||i_min||'> - '||SUBSTR(SQLERRM, 1, 200);
          RAISE;
      END;

      IF (l_applied_promo_code IS NOT NULL) THEN

        o_promo_applied  := 'ERROR_1985885';
        o_promo_response := 'ERROR WF005 - Phone number <'||i_min||'> has already been granted another promo code: '||l_applied_promo_code;

        RETURN;

      ELSE

        upd_wfm_promo_code (i_promo_code       => l_promo_code,
                            i_min              => i_min,
                            i_pin              => NULL,
                            i_promo_status     => 'PROCESSING',
                            o_update_applied   => l_upd_flag,
                            o_update_response  => l_upd_response);

        IF (NVL(l_upd_flag,'N') <> 'Y') THEN
          o_promo_applied  := l_upd_flag;
          o_promo_response := 'ERROR WF006 - '||l_upd_response;
          RETURN;
        END IF;

      END IF;

    ELSIF (l_promo_status IN('DISABLED','EXPIRED','INVALIDATED')) THEN

      IF l_promo_status = 'INVALIDATED' THEN
        o_promo_applied  := 'ERROR_1985176';
        o_promo_response := 'ERROR WF007 - Promo code has been invalidated by WFM/TF agents: '||l_promo_code;
      ELSE
        o_promo_applied  := 'ERROR_1985875';
        o_promo_response := 'ERROR WF008 - Promo code is disabled/expired and it cannot be applied: '||l_promo_code;
      END IF;

      RETURN;

    ELSE

      o_promo_applied  := 'ERROR_1985874';
      o_promo_response := 'ERROR WF009 - Promo code has already been applied ('||l_promo_status||') to phone number <'||l_promo_min||'>';

      IF (l_promo_status NOT IN('APPLIED','GENERATED','PROCESSING')) THEN

        upd_wfm_promo_code (i_promo_code       => l_promo_code,
                            i_promo_status     => l_promo_status,
                            o_update_applied   => l_upd_flag,
                            o_update_response  => l_upd_response);

        IF (NVL(l_upd_flag,'N') <> 'Y') THEN
          o_promo_applied  := l_upd_flag;
          o_promo_response := 'ERROR WF010 - '||l_upd_response;
          RETURN;
        END IF;

      END IF;

      RETURN;

    END IF;
    --
    BEGIN

      SELECT ABS(TO_NUMBER(NVL(TRIM(x_param_value),1))) max_days
        INTO l_max_days
        FROM sa.table_x_parameters
       WHERE x_param_name = 'WFM_PROMO_MIN_INST_DAYS'
         AND ROWNUM = 1;

      SELECT ABS(TO_NUMBER(NVL(TRIM(x_param_value),1))) min_days
        INTO l_min_days
        FROM sa.table_x_parameters
       WHERE x_param_name = 'WFM_PROMO_MIN_DEACT_REACT_DAYS'
         AND ROWNUM = 1;

    EXCEPTION
      WHEN OTHERS THEN
        o_promo_applied  := 'RDSG_5399';
        o_promo_response := 'ERROR WF011 - Invalid or missing number of eligible days for phone number activation service - '||SUBSTR(SQLERRM, 1, 200);
        upd_wfm_promo_code (i_promo_code       => l_promo_code,
                            i_promo_status     => 'ERROR',
                            o_update_applied   => l_upd_flag,
                            o_update_response  => l_upd_response);
        RAISE;
    END;
    --
    DBMS_OUTPUT.put_line ('WFM MIN Validation with: <'||i_min||'>-<'||l_brand||'>-<'||l_domain||'>-<'||l_max_days||'>');
    --
    BEGIN
      SELECT sp.objid service_plan_id,
             pi.part_serial_no,
             st.objid
        INTO l_service_plan_objid,
             l_esn,
             l_site_part_objid
        FROM sa.table_site_part st,
             sa.x_service_plan_site_part mtm,
             sa.table_part_inst pi,
             sa.table_mod_level ml,
             sa.table_part_num pn,
             sa.table_bus_org bo,
             sa.x_service_plan sp
       WHERE sp.objid = mtm.x_service_plan_id
         AND bo.org_id = l_brand
         AND bo.objid = pn.part_num2bus_org
         AND pn.active = 'Active'
         AND pn.s_domain = pi.x_domain
         AND pn.objid = ml.part_info2part_num
         AND ml.objid = pi.n_part_inst2part_mod
         AND pi.x_domain = l_domain
         AND pi.x_part_inst2site_part = st.objid
         AND mtm.table_site_part_id = st.objid
         AND TRUNC(NVL(st.x_actual_expire_dt,NVL(st.x_expire_dt,sysdate))) >= TRUNC(sysdate)
         AND st.install_date >= TRUNC((sysdate+1)-l_max_days)
         AND st.part_status = 'Active'
         AND st.objid = (SELECT MAX(objid)
                           FROM sa.table_site_part st2
                          WHERE st2.x_min = st.x_min
                            AND st2.part_status = st.part_status)
         AND NOT EXISTS (SELECT NULL
                           FROM sa.table_site_part st3
                          WHERE st3.x_min = st.x_min
                            AND st3.x_deact_reason = 'UPGRADE'
                            AND st3.part_status <> st.part_status)
         AND st.x_min = i_min;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_promo_applied  := 'ERROR_1985873';
        o_promo_response := 'ERROR WF012 - The phone number provided is not active or valid for this service: <'||i_min||'>';
        upd_wfm_promo_code (i_promo_code       => l_promo_code,
                            i_promo_status     => 'ERROR',
                            o_update_applied   => l_upd_flag,
                            o_update_response  => l_upd_response);
        RAISE;
      WHEN OTHERS THEN
        o_promo_applied  := 'RDSG_5399';
        o_promo_response := 'ERROR WF013 - Invalid MIN/Brand/Domain data submitted for ESN search - '||SUBSTR(SQLERRM, 1, 200);
        upd_wfm_promo_code (i_promo_code       => l_promo_code,
                            i_promo_status     => 'ERROR',
                            o_update_applied   => l_upd_flag,
                            o_update_response  => l_upd_response);
        RAISE;
    END;
    --
    IF (l_service_plan_objid IS NULL) OR (l_esn IS NULL) OR (l_site_part_objid IS NULL) THEN
      o_promo_applied  := 'ERROR_1985873';
      o_promo_response := 'ERROR WF014 - No valid activation transaction record found for phone number: <'||i_min||'>';
      upd_wfm_promo_code (i_promo_code       => l_promo_code,
                          i_promo_status     => 'ERROR',
                          o_update_applied   => l_upd_flag,
                          o_update_response  => l_upd_response);
      RETURN;
    END IF;
    --
    BEGIN
      SELECT ct.objid,
             ct.x_action_type,
             ct.x_transact_date
        INTO l_call_trans_objid,
             l_trans_type,
             l_transact_date
        FROM sa.table_x_call_trans ct
       WHERE ct.objid = (SELECT MIN(ctx.objid)
                           FROM sa.table_x_call_trans ctx
                          WHERE ctx.x_service_id = l_esn
                            AND ctx.x_min = i_min
                            AND ctx.call_trans2site_part = l_site_part_objid
                            AND ctx.x_sub_sourcesystem = l_brand);
    EXCEPTION
      WHEN OTHERS THEN
        o_promo_applied  := 'ERROR_1985873';
        o_promo_response := 'ERROR WF015 - The CT transaction for MIN is not found for ESN and site part: <'||i_min||'><'||l_esn||'><'||l_site_part_objid||'>';
        upd_wfm_promo_code (i_promo_code       => l_promo_code,
                            i_promo_status     => 'ERROR',
                            o_update_applied   => l_upd_flag,
                            o_update_response  => l_upd_response);
        RAISE;
    END;
    --
    -- CR55631//CR56696 - Allow for WFM re-activations to be accounted for promo code grant with more than 60 days from WFM de-activation.
    IF (l_trans_type = '3') THEN

      BEGIN
        SELECT ct.x_action_type,
               (TRUNC(l_transact_date) - TRUNC(ct.x_transact_date)) days_diff
          INTO l_trans_type,
               l_days_diff
          FROM sa.table_x_call_trans ct
         WHERE ct.objid = (SELECT MAX(ctx.objid)
                             FROM sa.table_x_call_trans ctx
                            WHERE ctx.x_sub_sourcesystem = l_brand
                              AND ctx.call_trans2site_part <> l_site_part_objid
                              AND ctx.x_min = i_min
                              AND ctx.x_service_id = l_esn);
      EXCEPTION
        WHEN OTHERS THEN
          o_promo_applied  := 'ERROR_1985873';
          o_promo_response := 'ERROR WF016 - The DEACTIVATION CT transaction for MIN is not found for ESN and site part: <'||i_min||'><'||l_esn||'><'||l_site_part_objid||'>';
          upd_wfm_promo_code (i_promo_code       => l_promo_code,
                              i_promo_status     => 'ERROR',
                              o_update_applied   => l_upd_flag,
                              o_update_response  => l_upd_response);
          RAISE;
      END;

      IF (NVL(l_trans_type,'X') <> '2') OR (l_days_diff <= l_min_days) THEN
        o_promo_applied  := 'ERROR_1985873';
        o_promo_response := 'ERROR WF017 - No valid deactivation-reactivation condition met for phone number: <'||i_min||'><'||l_trans_type||'><'||l_days_diff||'>';
        upd_wfm_promo_code (i_promo_code       => l_promo_code,
                            i_promo_status     => 'ERROR',
                            o_update_applied   => l_upd_flag,
                            o_update_response  => l_upd_response);
        RETURN;
      END IF;

    END IF;
    --
    IF (l_brand = 'WFM') THEN
      g_enable_org_bogo := 'Y';   -- CR51833 - Enable BOGO process for WINBACK promo code//OImana.
    END IF;
    --
    sp_bogo (i_esn                => l_esn,
             i_channel            => i_channel,
             i_action             => l_action,
             i_red_card_pin       => NULL,
             i_service_plan_objid => l_service_plan_objid,
             i_call_trans_objid   => l_call_trans_objid,
             i_apply_bogo         => 'P',
             i_tsp_id             => NULL,
             o_bogo               => o_promo_applied,
             o_free_pin_number    => o_promo_pin_number,
             o_response           => o_promo_response);
    --
    IF (NVL(o_promo_response,'X') = 'SUCCESS') AND (o_promo_pin_number IS NOT NULL) THEN

      l_promo_status   := 'GENERATED';  -- CR51833 - PIN has been generated successfully

    ELSE

      -- CR51833 - MIN may have been granted a BOGO from other source.
      -- CR56696 - ESN part number/class is not defined for BOGO activity.

      IF o_promo_response LIKE '%BOGO Benefit already provided%' THEN
        o_promo_applied  := 'ERROR_1985885';
        o_promo_response := 'Input MIN has already been granted a promotional program (BOGO)';
      ELSIF o_promo_response LIKE '%Input data not matched with any active BOGO%' THEN
        o_promo_applied  := 'ERROR_1985074';
        o_promo_response := 'This promotional program is not applicable for the input ESN: '||l_esn;
      ELSE
        o_promo_applied  := 'RDSG_5399';
      END IF;

      o_promo_response := 'ERROR WF018 - '||o_promo_response;
      l_promo_status   := 'ERROR';

    END IF;
    --
    upd_wfm_promo_code (i_promo_code       => l_promo_code,
                        i_pin              => o_promo_pin_number,
                        i_promo_status     => l_promo_status,
                        o_update_applied   => l_upd_flag,
                        o_update_response  => l_upd_response);
    --
    IF (NVL(l_upd_flag,'N') <> 'Y') THEN
      o_promo_applied  := l_upd_flag;
      o_promo_response := 'ERROR WF019 - '||l_upd_response;
    END IF;
    --
    DBMS_OUTPUT.put_line ('O_PROMO_BOGO       => '||o_promo_applied);
    DBMS_OUTPUT.put_line ('O_PROMO_RESPONSE   => '||o_promo_response);
    DBMS_OUTPUT.put_line ('O_PROMO_PIN_NUMBER => '||o_promo_pin_number);
    --
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      o_promo_applied  := NVL(o_promo_applied,'RDSG_5399');
      o_promo_response := NVL(o_promo_response,'ERROR WF020 - Main wfm_promo_code_pin procedure process failed: '||SUBSTR(SQLERRM, 1, 200));
      DBMS_OUTPUT.put_line (o_promo_response);
  END wfm_promo_code_pin;
--
  PROCEDURE upd_wfm_promo_code (i_promo_code       IN  x_wfm_min_promo_code.promo_code%TYPE,
                                i_min              IN  x_wfm_min_promo_code.promo_min%TYPE DEFAULT NULL,
                                i_pin              IN  x_wfm_min_promo_code.promo_pin%TYPE DEFAULT NULL,
                                i_promo_status     IN  x_wfm_min_promo_code.promo_status%TYPE,
                                o_update_applied   OUT VARCHAR2,
                                o_update_response  OUT VARCHAR2)
  IS
  -- CR51833 - WFM BOGO Activation Promo Code to retrieve PIN//OImana
  -- CR55631 - Add EXPIRED status to ignore disabled/outdated codes.
  -- CR56696 - Add new condition for INVALIDATED promo codes to send response for TAS with code ERROR_1985914.
  --
  l_promo_status   x_wfm_min_promo_code.promo_status%TYPE;
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
  BEGIN
    --
    o_update_applied  := 'N';
    o_update_response := NULL;
    --
    BEGIN
      SELECT user_id
        INTO g_user_id
        FROM all_users
       WHERE username = (SELECT sys_context('USERENV','SESSION_USER')
                           FROM dual
                          WHERE ROWNUM = 1);
    EXCEPTION
      WHEN OTHERS THEN
        g_user_id := NULL;
    END;
    --
    SELECT promo_status
      INTO l_promo_status
      FROM sa.x_wfm_min_promo_code
     WHERE promo_code = UPPER(i_promo_code);
    --
    IF i_promo_status IS NULL THEN

      RAISE value_error;

    ELSIF (i_promo_status = 'ERROR') AND (l_promo_status IN('APPLIED','GENERATED')) THEN

      o_update_applied  := 'Y';
      o_update_response := 'ERROR - Final process cannot change the status of '||l_promo_status||' to status of ERROR for: '||i_promo_code;
      DBMS_OUTPUT.put_line (o_update_response);

    ELSIF (l_promo_status IN('DISABLED','EXPIRED','INVALIDATED')) THEN

      o_update_applied  := 'ERROR_1985176';
      o_update_response := 'ERROR - Update cannot be processed - Status of '||l_promo_status||' found for code: '||i_promo_code;
      DBMS_OUTPUT.put_line (o_update_response);

    ELSE

      UPDATE sa.x_wfm_min_promo_code
         SET promo_status       = DECODE(i_promo_status,'ERROR','NEW',i_promo_status),
             promo_applied_date = DECODE(i_promo_status,'ERROR',NULL,'APPLIED',sysdate,promo_applied_date),
             promo_min          = DECODE(i_promo_status,'ERROR',NULL,NVL(i_min,promo_min)),
             promo_pin          = DECODE(i_promo_status,'ERROR',NULL,NVL(i_pin,promo_pin)),
             updated_by         = NVL(g_user_id,updated_by),
             updated_date       = systimestamp
       WHERE promo_code         = UPPER(i_promo_code);

      COMMIT;

      IF i_promo_status = 'INVALIDATED' THEN
        o_update_applied  := 'ERROR_1985914';
        o_update_response := 'Promo code marked invalid';
      ELSE
        o_update_applied  := 'Y';
        o_update_response := 'SUCCESS';
      END IF;

    END IF;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_update_applied  := 'ERROR_1985875';
      o_update_response := 'No promo code record found with value: <'||i_promo_code||'>';
      DBMS_OUTPUT.put_line (o_update_response);
    WHEN OTHERS THEN
      ROLLBACK;
      o_update_applied  := 'RDSG_5399';
      o_update_response := 'Error when STATUS updated to: <'||i_promo_status||'> in x_wfm_min_promo_code table for: '||i_promo_code||' - '||SUBSTR(SQLERRM, 1, 200);
      DBMS_OUTPUT.put_line (o_update_response);
  END upd_wfm_promo_code;
--
END bogo_pkg;
/