CREATE OR REPLACE PACKAGE BODY sa.FOTA_SERVICE_PKG
IS
/*************************************************************************************************************************************
  * $Revision: 1.20 $
  * $Author: oimana $
  * $Date: 2017/07/10 16:02:12 $
  * $Log: FOTA_SERVICE_PKB.SQL,v $
  * Revision 1.20  2017/07/10 16:02:12  oimana
  * CR48183 - FOTA Campaign Model - Change in Package criteria to use new table ADFCRM_FOTA_PC_PARAMS
  *
  * Revision 1.19  2017/02/20 20:47:12  abustos
  * CR45817 - Update new column name
  *
  * Revision 1.18  2017/02/13 22:13:52  abustos
  * CR45817 - New ig fota column + enhancements to procedure and debugging
  *
  * Revision 1.17  2017/01/16 21:55:27  abustos
  * CR45817 - Use new ig_trans column to store FOTA name
  *
  * Revision 1.16  2016/10/21 23:15:23  rpednekar
  * CR43254
  *
  * Revision 1.15  2016/10/20 22:19:23  rpednekar
  * 43254
  *
  * Revision 1.14  2016/10/18 19:43:56  rpednekar
  * CR43254 - Initial version
  *
  *************************************************************************************************************************************/

PROCEDURE PROCESS_FOTA_CAMP_TRANS (ip_transaction_id   IN  VARCHAR2
                                  ,ip_call_trans_objid IN  NUMBER
                                  ,op_err_code         OUT VARCHAR2
                                  ,op_err_msg          OUT VARCHAR2
                                  )
IS

  CURSOR cur_fota_camp(i_esn VARCHAR2)
  IS
  SELECT fcm.fota_camp_objid,
         fcm.objid fota_member_objid
    FROM adfcrm_fota_camp_members fcm
   WHERE fcm.esn = i_esn
     AND UPPER(fcm.status) IN('PENDING','FAILED')
  ORDER BY fcm.insert_date;

  --rec_fota_camp   cur_fota_camp%ROWTYPE;

  CURSOR cur_fota_trans (I_FOTA_CAMP_OBJID NUMBER,
                         I_CT_ACTION_TYPE VARCHAR2,
                         I_IG_ORDER_TYPE VARCHAR2,
                         I_ESN VARCHAR2) IS
  SELECT *
  FROM adfcrm_fota_campaign fc
  WHERE 1  = 1
    AND fc.objid  = i_fota_camp_objid
    AND ((fc.activation   =  '1' AND i_ig_order_type IN('A','AP','E') AND i_ct_action_type = '1')
     OR  (fc.reactivation =  '1' AND i_ig_order_type IN ('A','AP')    AND i_ct_action_type = '3')
     OR  (fc.redemption   =  '1' AND i_ct_action_type = '6')
     OR  (fc.reactivation =  '1' AND i_ig_order_type = 'E'            AND i_ct_action_type = '3'
          AND NOT EXISTS(SELECT 1
                           FROM table_x_case_detail cd,
                                table_case cs
                          WHERE cd.x_name = 'NEW_ESN'
                            AND cd.x_value = i_esn
                            AND cd.detail2case = cs.objid
                            AND cs.s_title LIKE '%PHONE%UPGRADE%'
                            AND cs.objid = (SELECT MAX(objid)
                                              FROM table_case
                                             WHERE x_esn = cs.x_esn
                                               AND s_title LIKE '%PHONE%UPGRADE%')
                         UNION
                         SELECT 1
                           FROM table_case cs
                          WHERE cs.x_esn = i_esn
                            AND cs.s_title LIKE '%PHONE%UPGRADE%'
                            AND cs.objid = (SELECT MAX(objid)
                                              FROM table_case
                                             WHERE x_esn = cs.x_esn
                                               AND s_title LIKE '%PHONE%UPGRADE%')
                        )
         )
        );

  rec_fota_trans    cur_fota_trans%ROWTYPE;
  ig_original       ig_transaction%ROWTYPE;
  ct_original       table_x_call_trans%ROWTYPE;
  pi_esn_rec        table_part_inst%ROWTYPE;
  lv_fota_action_type       table_x_call_trans.x_action_text%type;
  lv_fota_calltrans_obj     table_x_call_trans.objid%type;
  lv_fota_action_item_objid table_task.objid%type;
  lv_fota_destination_queue VARCHAR2(5);
  lv_fota_action_text       table_x_code_table.x_code_name%type;
  lv_fota_member_objid      adfcrm_fota_camp_members.objid%type;
  lv_fota_active            TABLE_X_PARAMETERS.X_PARAM_VALUE%TYPE;

  PRAGMA AUTONOMOUS_TRANSACTION;

  PROCEDURE UPDATE_FOTA_CAMP_MEMBER (IP_FOTA_CAMP_MEMBER_OBJID NUMBER
                                    ,IP_CALL_TRANS_OBJID NUMBER
                                    ,IP_STATUS  VARCHAR2
                                    ,IP_ERR_MSG VARCHAR2)
  IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    UPDATE sa.adfcrm_fota_camp_members
       SET status = ip_status,
           cal_trans_objid = ip_call_trans_objid,
           modify_date = sysdate,
           error_message = ip_err_msg
     WHERE objid = ip_fota_camp_member_objid;

    COMMIT;

  END UPDATE_FOTA_CAMP_MEMBER;

BEGIN

  BEGIN
    SELECT x_param_value
      INTO lv_fota_active
      FROM table_x_parameters
     WHERE x_param_name = 'FLAG_TO_EXECUTE_FOTA_TRANSACTIONS'
       AND ROWNUM = 1;
  EXCEPTION
    WHEN OTHERS THEN
      lv_fota_active := 'FALSE';
  END;

  IF lv_fota_active <> 'TRUE' THEN
    dbms_output.put_line('TABLE_X_PARAMETER FLAG_TO_EXECUTE_FOTA_TRANSACTIONS IS DISABLED OR NOT FOUND');
    RETURN;
  END IF;

  IF ip_call_trans_objid IS NOT NULL AND  ip_transaction_id IS NULL THEN --- In case of PPE redemption there wont be ig.

    BEGIN
      SELECT ct.*
        INTO ct_original
        FROM table_x_call_trans ct
       WHERE 1 = 1
         AND ct.objid = ip_call_trans_objid;
    EXCEPTION
      WHEN OTHERS THEN
        op_err_code :=  '99';
        op_err_msg := 'Original call trans not found - '||SQLERRM;
        ota_util_pkg.err_log(p_action => 'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS select table_x_call_trans failed RETURNING'
                            ,p_error_date => NULL
                            ,p_key => NVL(ip_transaction_id,ip_call_trans_objid)
                            ,p_program_name => 'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS'
                            ,p_error_text => op_err_msg);
        ROLLBACK;
        RETURN;
    END;

  ELSE

  BEGIN

    SELECT   *
    INTO ig_original
    FROM ig_transaction
    WHERE 1              = 1
    AND transaction_id = ip_transaction_id;

  EXCEPTION
  WHEN OTHERS THEN

    op_err_code :=  '99';
    op_err_msg := 'IG TRANSACTION NOT FOUND, ERROR- '||SQLERRM;
    ota_util_pkg.err_log ( p_action =>
    'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS' ,
    p_error_date => NULL,p_key => ip_transaction_id ,p_program_name =>
    'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS' ,p_error_text => op_err_msg );


    ROLLBACK;
    RETURN;
  --
  END;


  BEGIN
    SELECT   ct.*
    INTO ct_original
    FROM table_x_call_trans ct,
    table_task tt
    WHERE 1                      = 1
    AND tt.x_task2x_call_trans = ct.objid
    AND tt.task_id             = ig_original.action_item_id;

  EXCEPTION
  WHEN OTHERS THEN

  op_err_code :=  '99';
  op_err_msg := 'Original call trans not found - '||SQLERRM;
  ota_util_pkg.err_log( p_action =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS select table_x_call_trans failed RETURNING'
  ,p_error_date => NULL,p_key => NVL(ip_transaction_id,ip_call_trans_objid) ,p_program_name =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS' ,p_error_text => op_err_msg );


  ROLLBACK;
  RETURN;
  END;

  END IF;

  dbms_output.put_line('Rahul 1 '||ct_original.x_service_id);

  FOR rec_fota_camp IN cur_fota_camp(ct_original.x_service_id)
  LOOP



    OPEN cur_fota_trans ( rec_fota_camp.fota_camp_objid , ct_original.X_ACTION_TYPE,ig_original.ORDER_TYPE,ct_original.x_service_id );
    FETCH cur_fota_trans INTO rec_fota_trans;


    IF cur_fota_trans%NOTFOUND
    THEN

      CLOSE cur_fota_trans;

      ROLLBACK;
      CONTINUE;
    ELSE
      CLOSE cur_fota_trans;

    END IF;

  lv_fota_member_objid  :=  rec_fota_camp.FOTA_MEMBER_OBJID;


  BEGIN
    SELECT   pi_esn.*
    INTO pi_esn_rec
    FROM table_part_inst pi_esn
    WHERE 1                      = 1
    AND pi_esn.part_serial_no = ct_original.x_service_id
    AND pi_esn.x_domain = 'PHONES'
    ;

  EXCEPTION
  WHEN OTHERS THEN

  op_err_code :=  '99';
  op_err_msg := 'ESN not found original call trans - '||ct_original.objid||' '||SQLERRM;
  ota_util_pkg.err_log( p_action =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS'
  ,p_error_date => NULL,p_key => ct_original.x_service_id ,p_program_name =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS' ,p_error_text => op_err_msg );

  UPDATE_FOTA_CAMP_MEMBER(rec_fota_camp.FOTA_MEMBER_OBJID
          ,NULL
          ,'FAILED'
          ,op_err_msg
        );
  ROLLBACK;
  CONTINUE;
  END;


  dbms_output.put_line('Rahul 4');
  BEGIN

  select x_code_number,x_code_name
  INTO lv_fota_action_type,lv_fota_action_text
  from table_x_code_table
  where X_CODE_NAME = 'FOTA'
  and x_code_type = 'AT'
  ;

  EXCEPTION WHEN OTHERS
  THEN
    lv_fota_action_text :=  'FOTA';
  END;

  sa.sp_seq('x_call_trans' ,lv_fota_calltrans_obj);


  INSERT
    INTO table_x_call_trans
      (
        objid ,
        call_trans2site_part ,
        x_action_type ,
        x_call_trans2carrier ,
        x_call_trans2dealer ,
        x_call_trans2user ,
        x_min ,
        x_service_id ,
        x_sourcesystem ,
        x_transact_date ,
        x_total_units ,
        x_action_text ,
        x_reason ,
        x_result ,
        x_sub_sourcesystem ,
        x_iccid ,
        x_ota_req_type ,
        x_ota_type
      )
      VALUES
      (
        lv_fota_calltrans_obj ,
        ct_original.call_trans2site_part ,
        lv_fota_action_type ,
        ct_original.x_call_trans2carrier ,
        ct_original.x_call_trans2dealer ,
        ct_original.x_call_trans2user ,
        ct_original.x_min ,
        ct_original.x_service_id ,
        ct_original.x_sourcesystem ,
        SYSDATE ,
        '', --  ct_original.x_total_units ,
        lv_fota_action_text ,
        ct_original.x_reason ,
       ct_original.x_result,
        ct_original.x_sub_sourcesystem
        ,ct_original.x_iccid ,
        ct_original.x_ota_req_type
        ,ct_original.x_ota_type
      );



  dbms_output.put_line('Rahul 5');

  sa.IGATE.sp_create_action_item(
              pi_esn_rec.x_part_inst2contact,   --  p_contact_objid
              lv_fota_calltrans_obj,            --  p_call_trans_objid
              'FOTA',                           --  p_order_type
              '',                               --  p_bypass_order_type
              '0',                              --  p_case_code
              op_err_code,                      --  p_status_code OUT NUMBER
              lv_fota_action_item_objid         --  p_action_item_objid OUT NUMBER
              );

  dbms_output.put_line('Rahul 6 sp_create_action_item error '||op_err_code);

  IF op_err_code  <> '0'
  THEN

  op_err_msg := 'SA.IGATE.SP_CREATE_ACTION_ITEM FAILED - '||op_err_code||' Original call trans '||ct_original.objid||' fota call trans '||lv_fota_calltrans_obj||' - '||SQLERRM;
  ota_util_pkg.err_log( p_action =>
  'SA.IGATE.SP_CREATE_ACTION_ITEM FAILED - RETURNING'
  ,p_error_date => NULL,p_key => ct_original.x_service_id ,p_program_name =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS' ,p_error_text => op_err_msg );
  UPDATE_FOTA_CAMP_MEMBER(rec_fota_camp.FOTA_MEMBER_OBJID
          ,lv_fota_calltrans_obj
          ,'FAILED'
          ,op_err_msg
        );
  ROLLBACK;
  CONTINUE;
  END IF;


  CREATE_IG_FOR_FOTA(
  p_action_item_objid =>  lv_fota_action_item_objid
  ,ip_fota_camp_name  =>  rec_fota_trans.CAMPAIGN_NAME
  ,op_error_code    =>  op_err_code
  ,op_error_msg   =>  op_err_msg
  );

  IF op_err_code  <> '0'
  THEN

  op_err_msg := 'SA.FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA FAILED - '||op_err_code||' Original call trans '||ct_original.objid||' fota call trans '||lv_fota_calltrans_obj||' - '||SQLERRM;
  ota_util_pkg.err_log( p_action =>
  'SA.IGATE.SP_CREATE_ACTION_ITEM FAILED - RETURNING'
  ,p_error_date => NULL,p_key => ct_original.x_service_id ,p_program_name =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS' ,p_error_text => op_err_msg );
  UPDATE_FOTA_CAMP_MEMBER(rec_fota_camp.FOTA_MEMBER_OBJID
          ,lv_fota_calltrans_obj
          ,'FAILED'
          ,op_err_msg
        );
  ROLLBACK;
  CONTINUE;
  END IF;




  UPDATE_FOTA_CAMP_MEMBER(rec_fota_camp.FOTA_MEMBER_OBJID
          ,lv_fota_calltrans_obj
          ,'COMPLETED'
          ,NULL
        );

  COMMIT;

  END LOOP;





EXCEPTION WHEN OTHERS
THEN

  op_err_code :=  '99';
  op_err_msg := 'Main Exception - '||op_err_msg||' - '||SQLERRM;
  ota_util_pkg.err_log( p_action =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS Main Exception RETURNING'
  ,p_error_date => NULL,p_key => ip_transaction_id ,p_program_name =>
  'FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS' ,p_error_text => op_err_msg );
  UPDATE_FOTA_CAMP_MEMBER(  lv_fota_member_objid
          ,lv_fota_calltrans_obj
          ,'FAILED'
          ,op_err_msg
        );

  ROLLBACK;
  RETURN;

END PROCESS_FOTA_CAMP_TRANS;


/*
PROCEDURE get_make_model(pi_esn    IN VARCHAR2,
                         po_make  OUT VARCHAR2,
                         po_model OUT VARCHAR2,
                         po_tech  OUT VARCHAR2,
                         po_found OUT BOOLEAN) AS

BEGIN

  po_found := TRUE;

  SELECT pn.x_manufacturer,
         pc.x_model_number,
         pn.x_technology
    INTO po_make,
         po_model,
         po_tech
    FROM sa.table_part_inst pi,
         sa.table_mod_level ml,
         sa.table_part_num pn,
         sa.table_part_class pc
   WHERE 1 = 1
     AND pc.objid = pn.part_num2part_class
     AND pn.objid = ml.part_info2part_num
     AND ml.objid = pi.n_part_inst2part_mod
     AND pi.part_serial_no = pi_esn;

    IF po_make = 'LG INC' THEN
      po_make := 'LG';
    ELSIF po_make = 'HUAWEI' THEN
      po_make := 'Huawei';
    ELSIF po_make = 'ALCATEL' THEN
        po_make := 'Alcatel';
    ELSIF po_make = 'SAMSUNG INC' THEN
        po_make := 'SAMSUNG';
    END IF;

    IF po_tech = 'GSM' THEN
      IF po_make = 'LG' THEN
        po_model := 'L16C';
      ELSIF po_make = 'SAMSUNG' THEN
        po_model := 'SMS777C';
      ELSIF   po_make = 'Huawei' THEN
        po_model := 'H891L';
      ELSIF po_make = 'Alcatel' THEN
        po_model := 'A462C';
      ELSIF po_make = 'ZTE'  THEN
       po_model := 'Z668C';
      END IF;
    ELSIF po_tech = 'CDMA' THEN

      IF po_make = 'LG' THEN

        IF    po_model LIKE '%L16C%' THEN
          po_model := 'L16C';
        ELSIF po_model LIKE '%L22C%' THEN
          po_model := 'L22C';
        ELSIF po_model LIKE '%L34C%' THEN
          po_model := 'L34C';
        ELSIF po_model LIKE '%L41C%' THEN
          po_model := 'L41C';
        ELSE
          po_found := FALSE;
        END IF;

      ELSIF po_make = 'SAMSUNG' THEN

        IF    po_model LIKE '%SMS777C%' THEN
          po_model := 'SMS777C';
        ELSIF po_model LIKE '%SMS906L%'  THEN
          po_model := 'SMS906L';
        ELSIF po_model LIKE '%SMS920L%'  THEN
          po_model := 'SMS920L';
        ELSIF po_model LIKE '%SMS978L%'  THEN
          po_model := 'SMS978L';
        ELSE
          po_found := FALSE;
        END IF;

      ELSIF po_make = 'Huawei' THEN

        IF    po_model LIKE '%H891L%' THEN
          po_model := 'H891L';
        ELSIF po_model LIKE '%H892L%'  THEN
          po_model := 'H892L';
        ELSE
          po_found := FALSE;
        END IF;

      ELSIF po_make = 'Alcatel' THEN

        IF    po_model LIKE '%A462C%'  THEN
          po_model := 'A462C';
        ELSIF po_model LIKE '%A520L%'  THEN
          po_model := 'A520L';
        ELSIF po_model LIKE '%A571VL%' THEN
          po_model := 'A571VL';
        ELSIF po_model LIKE '%A622VL%' THEN
          po_model := 'A622VL';
        ELSIF po_model LIKE '%A846L%'  THEN
          po_model := 'A846L';
        ELSE
          po_found := FALSE;
        END IF;

      ELSIF po_make = 'ZTE' THEN

        IF    po_model LIKE '%Z668C%' THEN
          po_model := 'Z668C';
        ELSIF po_model LIKE '%Z752C%' THEN
          po_model := 'Z752C';
        ELSIF po_model LIKE '%Z793C%' THEN
          po_model := 'Z793C';
        ELSIF po_model LIKE '%Z797C%' THEN
          po_model := 'Z797C';
        ELSIF po_model LIKE '%Z819L%' THEN
          po_model := 'Z819L';
        ELSIF po_model LIKE '%Z932L%' THEN
          po_model := 'Z932L';
        ELSIF po_model LIKE '%Z936L%' THEN
          po_model := 'Z936L';
        ELSE
          po_found := FALSE;
        END IF;

      ELSE
        po_found := FALSE;
      END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    po_found := FALSE;
END get_make_model;
*/

PROCEDURE CREATE_IG_FOR_FOTA (p_action_item_objid IN NUMBER
                             ,ip_fota_camp_name   IN VARCHAR2
                             ,op_error_code       OUT VARCHAR2
                             ,op_error_msg        OUT VARCHAR2)
IS

lv_found  BOOLEAN;
lv_tech   table_part_num.x_technology%TYPE;
lv_make   ig_transaction.x_make%type;
lv_model  ig_transaction.x_model%type;

CURSOR task_curs (c_task_objid IN NUMBER)
IS
SELECT *
  FROM table_task
 WHERE objid = c_task_objid;

task_rec task_curs%ROWTYPE;

CURSOR order_type_curs (c_objid IN NUMBER)
IS
SELECT *
  FROM table_x_order_type
 WHERE objid = c_objid;

order_type_rec order_type_curs%ROWTYPE;

CURSOR carrier_curs (c_objid IN NUMBER)
IS
SELECT c.*,
       NVL((SELECT 1
              FROM sa.x_next_avail_carrier nac
             WHERE nac.x_carrier_id = c.x_carrier_id
               AND rownum < 2),0) x_next_avail_carrier
  FROM table_x_carrier c
 WHERE objid = c_objid;

carrier_rec carrier_curs%ROWTYPE;

CURSOR call_trans_curs (c_objid IN NUMBER)
IS
SELECT ct.* ,
       (SELECT pi.x_msid
          FROM table_part_inst pi
         WHERE pi.part_serial_no = ct.x_min) msid,
           DECODE(ct.x_ota_type,ota_util_pkg.ota_activation,'Y',NULL) ota_activation
  FROM table_x_call_trans ct
 WHERE ct.objid = c_objid;

call_trans_rec call_trans_curs%ROWTYPE;

CURSOR site_part_curs (c_objid IN NUMBER)
IS
SELECT CAST(sp.x_min AS VARCHAR2(30)) x_min,
       sp.x_service_id,
       sp.x_expire_dt,
       CAST(sp.x_pin AS VARCHAR2(30)) x_pin,
       sp.x_zipcode,
       sp.site_part2part_info,
       (SELECT pi.part_inst2carrier_mkt
          FROM table_part_inst pi
         WHERE pi.part_serial_no = sp.x_min
           AND pi.x_domain   = 'LINES') part_inst2carrier_mkt,
       (SELECT pi.n_part_inst2part_mod
          FROM table_part_inst pi
         WHERE pi.part_serial_no = sp.x_service_id
           AND pi.x_domain   = 'PHONES') n_part_inst2part_mod,
       (CASE
          WHEN sp.x_iccid IS NULL
          THEN (SELECT pi.x_iccid
                  FROM table_part_inst pi
                 WHERE pi.part_serial_no = sp.x_service_id
                   AND pi.x_domain = 'PHONES')
          ELSE sp.x_iccid
        END) iccid
  FROM table_site_part sp
 WHERE objid = c_objid;

site_part_rec site_part_curs%ROWTYPE;

CURSOR trans_profile_curs (c_objid IN NUMBER,
                           c_tech  IN VARCHAR2)
IS
SELECT objid,
       DECODE(c_tech,'GSM',x_gsm_trans_template,'CDMA',x_d_trans_template,x_transmit_template) template,
       DECODE(c_tech,'GSM',x_gsm_transmit_method,'CDMA',x_d_transmit_method,x_transmit_method) transmit_method,
       DECODE(c_tech,'GSM',x_gsm_fax_number,'CDMA',x_d_fax_number,x_fax_number) fax_number,
       DECODE(c_tech,'GSM',x_gsm_fax_num2,'CDMA',x_d_fax_num2,x_fax_num2) fax_num2,
       DECODE(c_tech,'GSM',x_gsm_online_number,'CDMA',x_d_online_number,x_online_number) online_number,
       DECODE(c_tech,'GSM',x_gsm_online_num2,'CDMA',x_d_online_num2,x_online_num2) online_num2,
       DECODE(c_tech,'GSM',x_gsm_email,'CDMA',x_d_email,x_email) email,
       DECODE(c_tech,'GSM',x_gsm_network_login,'CDMA',x_d_network_login,x_network_login) network_login,
       DECODE(c_tech,'GSM',x_gsm_network_password,'CDMA',x_d_network_password,x_network_password) network_password,
       DECODE(c_tech,'GSM',x_system_login,'CDMA',x_d_system_login,x_system_login) system_login,
       DECODE(c_tech,'GSM',x_system_password,'CDMA',x_d_system_password,x_system_password) system_password,
       DECODE(c_tech,'GSM',x_gsm_batch_delay_max,'CDMA',x_d_batch_delay_max,x_batch_delay_max) batch_delay_max,
       DECODE(c_tech,'GSM',x_gsm_batch_quantity,'CDMA',x_d_batch_quantity,x_batch_quantity) batch_quantity
  FROM table_x_trans_profile
 WHERE objid = c_objid;

trans_profile_rec trans_profile_curs%ROWTYPE;

CURSOR part_num_curs(c_objid IN NUMBER)
IS
SELECT pn.*,
       DECODE(org_flow,'3',1,0) straight_talk_flag,
       bo.org_id ,
       bo.objid bus_org_objid,
       bo.org_flow,
       NVL((SELECT to_number(v.x_param_value)
              FROM table_x_part_class_values v,
                   table_x_part_class_params n
             WHERE 1 = 1
               AND v.value2part_class  = pn.part_num2part_class
               AND v.value2class_param = n.objid
               AND n.x_param_name = 'DATA_SPEED'
               AND rownum  <2),
           NVL(x_data_capable,0)) data_speed,
       (SELECT to_number(v.x_param_value)
          FROM table_x_part_class_values v,
               table_x_part_class_params n
         WHERE 1 = 1
           AND v.value2part_class = pn.part_num2part_class
           AND v.value2class_param = n.objid
           AND n.x_param_name = 'NON_PPE'
           AND rownum  <2) PPE_FLAG           --CR38927 SL UPGRADE
  FROM table_part_num pn ,
       table_mod_level ml ,
       table_bus_org bo
 WHERE pn.objid = ml.part_info2part_num
   AND ml.objid = c_objid
   AND pn.part_num2bus_org = bo.objid;

part_num_rec part_num_curs%ROWTYPE;

BEGIN

  op_error_code :=  '0';

  OPEN task_curs (p_action_item_objid);
    FETCH task_curs INTO task_rec;

    IF task_curs%NOTFOUND THEN

      op_error_code := 1;

      INSERT INTO error_table (ERROR_TEXT,
                               ERROR_DATE,
                               ACTION,
                               KEY,
                               PROGRAM_NAME)
                       VALUES ('task_curs%NOTFOUND',
                               sysdate,
                               'task_curs(' ||p_action_item_objid ||')',
                               p_action_item_objid,
                               'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');

      CLOSE task_curs;

      RETURN;

    END IF;

  CLOSE task_curs;

  OPEN call_trans_curs (task_rec.x_task2x_call_trans);
    FETCH call_trans_curs INTO call_trans_rec;

      IF call_trans_curs%NOTFOUND THEN

        op_error_code := 6;

        INSERT INTO error_table (ERROR_TEXT,
                                 ERROR_DATE,
                                 ACTION,
                                 KEY,
                                 PROGRAM_NAME)
                         VALUES ('call_trans_curs%NOTFOUND',
                                 sysdate,
                                 'call_trans_curs(' ||task_rec.x_task2x_call_trans ||')',
                                 p_action_item_objid,
                                 'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');

        CLOSE call_trans_curs;

        RETURN;

      END IF;

  CLOSE call_trans_curs;

  dbms_output.put_line('call_trans_rec.X_CALL_TRANS2CARRIER:'||call_trans_rec.X_CALL_TRANS2CARRIER);
  dbms_output.put_line('call_trans_rec.x_action_type:'||call_trans_rec.x_action_type);
  dbms_output.put_line('call_trans_rec.ota_activation:'||call_trans_rec.ota_activation);
  dbms_output.put_line('call_trans_rec.call_trans2site_part:'||call_trans_rec.call_trans2site_part);

  OPEN site_part_curs (call_trans_rec.call_trans2site_part);
    FETCH site_part_curs INTO site_part_rec;

      IF site_part_curs%NOTFOUND THEN

        op_error_code := 7;

        INSERT INTO error_table (ERROR_TEXT,
                                 ERROR_DATE,
                                 ACTION,
                                 KEY,
                                 PROGRAM_NAME)
                         VALUES ('site_part_curs%NOTFOUND',
                                 sysdate,
                                 'site_part_curs(' ||call_trans_rec.call_trans2site_part ||')',
                                 p_action_item_objid,
                                 'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');

        CLOSE site_part_curs;

        RETURN;

      END IF;

  CLOSE site_part_curs;

  OPEN order_type_curs(task_rec.x_task2x_order_type);
    FETCH order_type_curs INTO order_type_rec;

      IF order_type_curs%NOTFOUND THEN

        op_error_code := 2;

        INSERT INTO error_table (ERROR_TEXT,
                                 ERROR_DATE,
                                 ACTION,
                                 KEY,
                                 PROGRAM_NAME)
                         VALUES ('order_type_curs%NOTFOUND',
                                 sysdate,
                                 'order_type_curs(' ||task_rec.x_task2x_order_type ||')',
                                 p_action_item_objid,
                                 'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');

        CLOSE order_type_curs;

        RETURN;

      END IF;
  CLOSE order_type_curs;

  OPEN carrier_curs (order_type_rec.x_order_type2x_carrier);
    FETCH carrier_curs INTO carrier_rec;

      IF carrier_curs%NOTFOUND THEN

        op_error_code := 3;

        INSERT INTO error_table (ERROR_TEXT,
                                 ERROR_DATE,
                                 ACTION,
                                 KEY,
                                 PROGRAM_NAME)
                         VALUES ('carrier_curs%NOTFOUND',
                                 sysdate,
                                 'carrier_curs(' ||order_type_rec.x_order_type2x_carrier ||')',
                                 p_action_item_objid,
                                 'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');

        CLOSE carrier_curs;

        RETURN;

      END IF;

  CLOSE carrier_curs;

  dbms_output.put_line('carrier_rec.x_mkt_submkt_name:'||carrier_rec.x_mkt_submkt_name);

  OPEN part_num_curs (NVL(site_part_rec.n_part_inst2part_mod,site_part_rec.site_part2part_info));
    FETCH part_num_curs INTO part_num_rec;

      IF part_num_curs%NOTFOUND THEN

        op_error_code := 9;

        INSERT INTO error_table (ERROR_TEXT,
                                 ERROR_DATE,
                                 ACTION,
                                 KEY,
                                 PROGRAM_NAME)
                         VALUES ('part_num_curs%NOTFOUND',
                                 sysdate,
                                 'part_num_curs(' ||site_part_rec.n_part_inst2part_mod ||')',
                                 p_action_item_objid,
                                 'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');

        CLOSE part_num_curs;

        RETURN;

      END IF;

  CLOSE part_num_curs;

  OPEN trans_profile_curs (order_type_rec.x_order_type2x_trans_profile, part_num_rec.x_technology);
    FETCH trans_profile_curs INTO trans_profile_rec;

      IF trans_profile_curs%NOTFOUND THEN

        op_error_code := 10;

        INSERT INTO error_table (ERROR_TEXT,
                                 ERROR_DATE,
                                 ACTION,
                                 KEY,
                                 PROGRAM_NAME)
                         VALUES ('trans_profile_curs%NOTFOUND',
                                 sysdate,
                                 'trans_profile_curs(' ||order_type_rec.x_order_type2x_trans_profile ||','|| part_num_rec.x_technology ||')',
                                 p_action_item_objid,
                                 'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');

        CLOSE trans_profile_curs;

        RETURN;

      END IF;

  CLOSE trans_profile_curs;

  BEGIN
    SELECT NVL(fp.x_fota_pc_make, pn.x_manufacturer) make,
           NVL(fp.x_fota_pc_model, pc.x_model_number) model,
           pn.x_technology
      INTO lv_make,
           lv_model,
           lv_tech
      FROM sa.table_part_inst pi,
           sa.table_mod_level ml,
           sa.table_part_num pn,
           sa.table_part_class pc,
           sa.adfcrm_fota_pc_params fp      --CR48183//Change in criteria to use new table ADFCRM_FOTA_PC_PARAMS//OImana
     WHERE pc.objid = pn.part_num2part_class
       AND pn.objid = ml.part_info2part_num
       AND ml.objid = pi.n_part_inst2part_mod
       AND pi.x_domain = 'PHONES'
       AND fp.part_class_objid(+) = pc.objid
       AND pi.part_serial_no = site_part_rec.x_service_id;
  EXCEPTION
     WHEN OTHERS THEN
       INSERT INTO error_table (ERROR_TEXT,
                                ERROR_DATE,
                                ACTION,
                                KEY,
                                PROGRAM_NAME)
                        VALUES ('Phone Make and Model Not Found',
                                sysdate,
                                'Exception - Phone Make and Model not found for ESN - '||site_part_rec.x_service_id,
                                p_action_item_objid,
                                'FOTA_SERVICE_PKG.CREATE_IG_FOR_FOTA');
  END;

  INSERT INTO ig_transaction (transaction_id,
                              action_item_id,
                              carrier_id,
                              order_type,
                              application_system,
                              status,
                              iccid,
                              esn,
                              esn_hex,
                              min,
                              msid,
                              template,
                              zip_code,
                              x_campaign_name,   --CR45817 use new column in ig_transaction for FOTA name
                              x_make,
                              x_model,
                              technology_flag)
                      VALUES (gw1.trans_id_seq.nextval + (POWER(2 ,28)),
                              task_rec.task_id ,
                              carrier_rec.x_carrier_id ,
                              'FOTA',
                              'IG_354',
                              'Q',
                              site_part_rec.iccid,
                              site_part_rec.x_service_id,
                              sa.igate.f_get_hex_esn (site_part_rec.x_service_id),
                              site_part_rec.x_min,
                              site_part_rec.x_min,
                              trans_profile_rec.template,
                              site_part_rec.x_zipcode ,
                              ip_fota_camp_name,
                              lv_make,      --CR48183//Change in criteria to use new table ADFCRM_FOTA_PC_PARAMS//OImana
                              lv_model,     --CR48183//Change in criteria to use new table ADFCRM_FOTA_PC_PARAMS//OImana
                              SUBSTR(part_num_rec.x_technology ,1 ,1));

END;
--
END FOTA_SERVICE_PKG;
/