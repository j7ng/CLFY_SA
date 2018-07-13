CREATE OR REPLACE PACKAGE BODY sa."OTA_MRKT_INFO_PKG" IS
 /************************************************************************************************|
 | Copyright Tracfone Wireless Inc. All rights reserved
 |
 | NAME : OTA_SEND_LAST_ACK_SPEC_PKG package
 | PURPOSE :
 | FREQUENCY:
 | PLATFORMS:
 |
 | REVISIONS:
 | VERSION DATE WHO PURPOSE
 | ------- ---------- ----- ------------------------------------------------------
 | 1.0 03/11/05 Novak Lalovic Initial revision
 | 05/19/05 Novak Lalovic Commented out the entire code of send_psms_batch
 | procedure because it is not currently in use
 | 05/19/05 Novak Lalovic Added copyright and revision version info to this file
 | 05/19/05 Novak Lalovic Minor cosmetic changes in copyright header
 | 05/29/05 Novak Lalovic Modification:
 | Procedure: send_psms
 | When OTA project first started, the phones with GSM technology
 | were the only ones that were OTA enabled. That is not the case
 | anymore. The change in the procedure was made to get the
 | technology number from the table insted of hardcoding it.
 | 1.1 06/27/05 Shaowei Luo Procedure send_psms: CR4169
 | Added new OUT parameter to the procedure: p_ota_trans_objid
 | Added new logic to handle the value of p_int_dll_to_use parameter
 | 1.2 08/08/05 Novak Lalovic Modification:
 | Procedure: send_psms_inq
 | Added optional numeric parameter p_x_counter to the procedure.
 | It defaults to NULL if the value is not passed from the calling program
 / 1.3 06/07/06 Curt Lindner CR5349 - Closed the open cursors - To resolve the production issue
 ORA 100 error Open Cursors Exceeded Maximum Limit
 | 1.4 09/26/06 Vani Adapa CR5613 OTA Enhancements
 | 1.5 11/08/06 Vani Adapa CR5613
 | 1.6 08/18/10 Jimmy Angarita CR13375
 |************************************************************************************************/
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: OTA_MRKT_INFO_PKG.sql,v $
 --$Revision: 1.28 $
 --$Author: abustos $
 --$Date: 2018/02/22 16:36:56 $
 --$ $Log: OTA_MRKT_INFO_PKG.sql,v $
 --$ Revision 1.28  2018/02/22 16:36:56  abustos
 --$ CR55313 - Do not trunc the date in order to have a proper timestamp
 --$
 --$ Revision 1.27  2018/02/09 16:15:56  abustos
 --$ CR55313 - Merge with production REL947
 --$
 --$ Revision 1.24  2018/01/15 23:36:35  jcheruvathoor
 --$ CR52654  Short code for TMOBILE WFM
 --$
 --$ Revision 1.23  2017/08/01 16:01:21  smacha
 --$ Merged with the prod version.
 --$
 --$ Revision 1.21  2017/07/19 18:19:35  smacha
 --$ Added procedure to get the next BYOP SMS staging for Bulk processing.
 --$
 --$ Revision 1.20  2017/04/26 21:43:38  nsurapaneni
 --$ Added IF c.min NOT LIKE T% condition to the procedure insert_wfm_sms_stg.
 --$
 --$ Revision 1.19  2017/04/26 01:12:04  nsurapaneni
 --$ Added new procedure insert_wfm_sms_stg
 --$
 --$ Revision 1.18 2017/01/19 16:40:49 vnainar
 --$ CR47675 comments added
 --$
 --$ Revision 1.17 2017/01/19 15:51:21 vnainar
 --$ CR47675 gosmart sub brand changes
 --$
 --$ Revision 1.16 2016/11/17 17:35:22 rpednekar
 --$ CR42899
 --$
 --$ Revision 1.15 2016/11/01 22:10:06 rpednekar
 --$ CR42899 - Cursor query changed in procedure get_next_byop_sms_stg.
 --$
 --$ Revision 1.14 2016/10/31 18:49:33 rpednekar
 --$ CR42899 - New parameter added to procedure get_next_byop_sms_stg. Merged.
 --$
 --$ Revision 1.11 2016/10/19 15:01:21 ddudhankar
 --$ CR44787 - p_forecast_date OUT parameter added to get_next_byop_sms_stg proc
 --$
 --$ Revision 1.10 2016/09/19 15:43:21  ddudhankar
  --$ CR44652 - changes to sent SMS, ordered by created_time
  --$
  --$ Revision 1.9  2016/09/16 21:52:18  ddudhankar
  --$ CR44652 - transaction_type included in the update
  --$
  --$ Revision 1.8  2016/09/06 18:50:36  ddudhankar
  --$ CR44652 - NT BOGO related changes
  --$
  --$ Revision 1.7  2013/03/14 19:44:36  ymillan
  --$ CR23775
  --$
  --$ Revision 1.6  2013/03/08 22:48:25  ymillan
  --$ CR22452 simple mobile
  --$
  --$ Revision 1.5  2012/08/03 20:55:00  kacosta
  --$ CR20545 NT10_ST BYOP Welcome SMS with MIN
  --$
  --$ Revision 1.4  2012/08/01 14:32:08  kacosta
  --$ CR20545 NT10_ST BYOP Welcome SMS with MIN
  --$
  --$ Revision 1.3  2012/07/31 16:39:04  kacosta
  --$ CR20546 NT10_ST BYOP Welcome SMS with MIN
  --$
  --$ Revision 1.2  2012/07/31 14:13:28  kacosta
  --$ CR20546 NT10_ST BYOP Welcome SMS with MIN
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  --CR20545 Start kacosta 07/31/2012
  -- Private Package Variables
  --
  l_cv_package_name CONSTANT VARCHAR2(30) := 'ota_mrkt_info_pkg';
  --CR20545 Start kacosta 07/31/2012
  --
  /*******************************************************************
  | Refer to package spec for detailed description of this procedure |
  *******************************************************************/
   PROCEDURE send_psms_batch
  (
    p_part_number     IN table_part_num.part_number%TYPE DEFAULT NULL
   ,p_esn             IN table_part_inst.part_serial_no%TYPE DEFAULT NULL
   ,p_ota_mrkt_number IN table_x_ota_mrkt_info.x_mrkt_number%TYPE
   ,p_ota_mrkt_type   IN table_x_ota_mrkt_info.x_mrkt_type%TYPE
  ) IS
    /********
       Novak Lalovic: May 19 2005
       Commented out the entire code
       because the procedure is not active
    ********/

    /********************** BEGIN COMMENT SECTION ****************************

    -- query ESN(s)
    CURSOR cur_get_esn(cp_esn IN table_part_inst.PART_SERIAL_NO%TYPE
            ,cp_part_number IN table_part_num.PART_NUMBER%TYPE) IS
       SELECT tpi.part_serial_no   AS esn
             ,tpi.x_sequence
       FROM table_part_inst  tpi,
            table_mod_level  tml,
            table_part_num   tpn
       WHERE tpn.x_technology   = 'GSM'
       AND   tpn.objid    = tml.part_info2part_num
       AND   tml.objid    = tpi.n_part_inst2part_mod
       AND   tpn.part_number    = NVL(cp_part_number, tpn.part_number)
       AND   tpi.part_serial_no = NVL(cp_esn, tpi.part_serial_no)
       AND   tpi.x_domain       = 'PHONES'
       -- AND   tpi.part_to_esn2part_inst IS NOT NULL  -- defines that returned RECORD is ESN, MIN record has NULL value in this column
       AND   ROWNUM < 1001;

    -- this cursor retrieves PSMS msg for valid ESN(s) only
    -- and validates the values of input parameters p_ota_mrkt_number and p_ota_mrkt_type
    -- as well as the PSMS message size
    CURSOR cur_get_ota_msg_info IS
       SELECT x_mrkt_message
             ,objid
             ,x_end_date
             ,x_status
       FROM   table_x_ota_mrkt_info
       WHERE x_mrkt_number   = p_ota_mrkt_number
       AND   x_mrkt_type     = p_ota_mrkt_type;

    ota_msg_info_rec cur_get_ota_msg_info%ROWTYPE;
    -- c_mrkt_message_text  VARCHAR2(155);
    -- n_ota_msg_info_objid NUMBER;

    -- DLL in/out parameters:
    -- DLL o_ins parameter: hold individual data elements values
    -- in
    TECHNOLOGY CONSTANT  table_part_num.X_TECHNOLOGY%TYPE := '3'; -- 3 = GSM
    n_transaction_id        NUMBER;
    -- out
    n_error_num    NUMBER;
    c_message_out     VARCHAR2(200);

    MAX_MSG_SIZE CONSTANT   NUMBER := 155;

    -- mandatory input parameter for validate_phone_prc stored procedure:
    SOURCE_SYSTEM CONSTANT     table_x_call_trans.X_SOURCESYSTEM%TYPE := 'OTA Batch';
    -- placeholders for validate_phone_prc stored procedure:
    c_part_inst_obj2_out    VARCHAR2(2000);
    c_code_number_out    VARCHAR2(2000);
    c_code_name_out         VARCHAR2(2000);
    n_redemp_reqd_flg_out      NUMBER;
    c_warr_end_date_out     VARCHAR2(2000);
    c_phone_model_out    VARCHAR2(2000);
    c_phone_technology_out     VARCHAR2(2000);
    c_phone_description_out    VARCHAR2(2000);
    n_amigo_flg_out         NUMBER;
    c_zipcode_out        VARCHAR2(2000);
    c_pending_red_status_out   VARCHAR2(2000);
    c_click_status_out      VARCHAR2(2000);
    n_promo_units_out    NUMBER;
    n_promo_access_days_out    NUMBER;
    n_num_of_cards_out      NUMBER;
    c_pers_status_out    VARCHAR2(2000);
    c_contact_id_out     VARCHAR2(2000);
    c_contact_phone_out     VARCHAR2(2000);
    c_errnum_out         VARCHAR2(2000);
    c_errstr_out         VARCHAR2(2000);
    n_sms_flag_out       NUMBER;
    c_part_class_out     VARCHAR2(2000);
    c_parent_id_out         VARCHAR2(2000);
    c_extra_info_out     VARCHAR2(2000);
    n_int_dll_out              NUMBER;
    c_contact_email_out     VARCHAR2(2000);
    c_min_out         VARCHAR2(10);
    -- esn ota validation
    n_active_esn_out     NUMBER;
    n_esn_ota_allowed_out      NUMBER;
    n_carrier_ota_type_out     NUMBER;
    n_handset_locked_out    NUMBER;
    n_handset_redemp_menu_out  NUMBER;
    n_destination_address      NUMBER;

    e_psms_msg_null         EXCEPTION;
    e_psms_msg_too_big      EXCEPTION;
    e_psms_msg_too_old      EXCEPTION;
    e_psms_msg_not_active      EXCEPTION;
    e_dll_error       EXCEPTION;
    e_invalid_esn        EXCEPTION;

    n_int_dll_to_use     NUMBER; -- how to get the value for this variable?????
    ********************** END COMMENT SECTION ****************************/
  BEGIN
    NULL;
    /********
       Novak Lalovic: May 19 2005
       Commented out the entire code
       because the procedure is not active
    ********/

    /********************** BEGIN COMMENT SECTION ****************************

       -- step 1: read OTA marketing info table and validate the message
       OPEN cur_get_ota_msg_info;
       FETCH cur_get_ota_msg_info INTO ota_msg_info_rec;
       CLOSE cur_get_ota_msg_info;
       IF ota_msg_info_rec.X_MRKT_MESSAGE IS NULL THEN
          -- log error message and terminate program
          RAISE e_psms_msg_null;
       END IF;
       IF LENGTH(ota_msg_info_rec.X_MRKT_MESSAGE) > MAX_MSG_SIZE THEN
          -- log error message and terminate program
          RAISE e_psms_msg_too_big;
       END IF;
       -- do we need to handle case when X_END_DATE is NULL?
       IF NOT ota_msg_info_rec.x_end_date > SYSDATE THEN
          -- log error message and terminate program
          RAISE e_psms_msg_too_old;
       END IF;
       IF NOT ota_msg_info_rec.x_status = 'ACTIVE' THEN
          -- log error message and terminate program
          RAISE e_psms_msg_not_active;
       END IF;

       -- DBMS_OUTPUT.put_line('msg 1 '||DBMS_UTILITY.GET_TIME);
       -- step 2: read part inst table
       FOR cur_esn_rec IN cur_get_esn(p_esn, p_part_number) LOOP
       -- DBMS_OUTPUT.put_line('msg 2 '||DBMS_UTILITY.GET_TIME);
          BEGIN
          -- step 2: validate ESN
          validate_phone_prc(
              p_esn                  => cur_esn_rec.ESN
                ,p_source_system        => SOURCE_SYSTEM
                ,p_part_inst_objid      => c_part_inst_obj2_out
                ,p_code_number          => c_code_number_out
                ,p_code_name            => c_code_name_out
                ,p_redemp_reqd_flg      => n_redemp_reqd_flg_out
                ,p_warr_end_date        => c_warr_end_date_out
                ,p_phone_model          => c_phone_model_out
                ,p_phone_technology     => c_phone_technology_out
                ,p_phone_description    => c_phone_description_out
                ,p_amigo_flg            => n_amigo_flg_out
                ,p_zipcode              => c_zipcode_out
                ,p_pending_red_status   => c_pending_red_status_out
                ,p_click_status         => c_click_status_out
                ,p_promo_units          => n_promo_units_out
                ,p_promo_access_days    => n_promo_access_days_out
                ,p_num_of_cards         => n_num_of_cards_out
                ,p_pers_status          => c_pers_status_out
                ,p_contact_id           => c_contact_id_out
                ,p_contact_phone        => c_contact_phone_out
                ,p_errnum               => c_errnum_out
                ,p_errstr               => c_errstr_out
                ,p_sms_flag             => n_sms_flag_out
                ,p_part_class           => c_part_class_out
                ,p_parent_id            => c_parent_id_out
                ,p_extra_info           => c_extra_info_out
                ,p_int_dll              => n_int_dll_out
                ,p_contact_email        => c_contact_email_out
                ,p_min                  => c_min_out);

          n_active_esn_out     := SUBSTR(c_extra_info_out,  8, 1);
          n_esn_ota_allowed_out      := SUBSTR(c_extra_info_out,  9, 1);
          n_carrier_ota_type_out     := SUBSTR(c_extra_info_out, 10, 1);
          n_handset_locked_out    := SUBSTR(c_extra_info_out, 11, 1);
          n_handset_redemp_menu_out  := SUBSTR(c_extra_info_out, 12, 1);
          n_destination_address      := SUBSTR(c_extra_info_out, 13, 1);

          -- debug:
           --DBMS_OUTPUT.put_line('X_MRKT_MESSAGE '      || ota_msg_info_rec.X_MRKT_MESSAGE);
          --DBMS_OUTPUT.put_line('n_active_esn_out '     || n_active_esn_out);
          --DBMS_OUTPUT.put_line('n_esn_ota_allowed_out '   || n_esn_ota_allowed_out);
          --DBMS_OUTPUT.put_line('n_carrier_ota_type_out '     || n_carrier_ota_type_out);
          --DBMS_OUTPUT.put_line('n_handset_locked_out '    || n_handset_locked_out);
          --DBMS_OUTPUT.put_line('n_handset_redemp_menu_out ' || n_handset_redemp_menu_out);
          --DBMS_OUTPUT.put_line('n_destination_address '   || n_destination_address);


          IF (n_active_esn_out       = 0
          OR  n_esn_ota_allowed_out  = 0
          OR  n_carrier_ota_type_out    = 0
          OR  n_handset_locked_out   = 1
             OR  n_handset_redemp_menu_out    = 0
             OR  n_destination_address  = 0) THEN
             RAISE e_invalid_esn;
          END IF;

          -- generate objid for table_x_ota_transaction table
          n_transaction_id := ota_util_pkg.get_next_esn_counter(cur_esn_rec.ESN);

          --
          -- call DLL:
          --
          -- 1) populate IN parameters and send the message
          OTA_EXTPROC_PKG.send_marketing_psms
                   (p_esn_in      => cur_esn_rec.ESN
                     , p_sequence_in => cur_esn_rec.X_SEQUENCE
                     , p_technology_in  => TECHNOLOGY
                     , p_transid_in  => n_transaction_id
                     , p_message_in  => ota_msg_info_rec.X_MRKT_MESSAGE
                     , p_int_dll_to_use => n_int_dll_to_use
                     , p_error_number_out  => n_error_num
                     , p_message_out => c_message_out);

          -- 2) check the output:
          IF n_error_num <> 0 THEN
             RAISE e_dll_error;
          END IF;
          -- debug: DBMS_OUTPUT.put_line('c_message_out = '||c_message_out);

          --
          -- log this transaction:
          --
          -- this procedure inserts 1 record in each of the following tables:
                -- TABLE_X_CALL_TRANS
                -- TABLE_X_OTA_TRANSACTION
                -- TABLE_X_OTA_TRANS_DTL
          -- CREATE_TRANSACTION has changed. Review the parameters list and make appropriate changes here.
          --ota_trans_pkg.CREATE_TRANSACTION
                -- call_trans and common parameters, refer to ota_trans_pkg spec for the value set of each parameter
                --(p_transaction_id     => n_transaction_id
                --,p_esn          => cur_esn_rec.ESN
                --,p_min          => c_min_out
                --,p_sourcesystem       => SOURCE_SYSTEM
                --,p_action_type        => '261'
                --,p_action_text        => 'OTA Marketing'
                --,p_result       => NULL
                --,p_sub_sourcesystem      => 'OTA marketing'
                --,p_ota_req_type       => 'MT Batch'
                --,p_total_units        => NULL
                --,p_call_trans_reason     => NULL
                --,p_user            => USER
                --,p_call_trans2x_ota_code_hist  => NULL
                ---- ota trans parameters only
                --,p_status       => NULL
                --,p_ota_type        => 'MT'
                --,p_ota_trans_reason      => NULL
                --,p_ota_trans2x_ota_mrkt_info   => ota_msg_info_rec.OBJID
                --,p_ota_message_direction => 'MT'
                --,p_mode            => 'BATCH'
                ---- DLL message
                --,p_psms_text       => c_message_out
                --);

          EXCEPTION
          WHEN e_invalid_esn THEN
             -- LOG error message and CONTINUE with next esn
                ota_util_pkg.err_log (p_action   => 'Sending marketing PSMS message in batch mode'
                               ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_batch'
                               ,p_error_text  => 'ESN '||cur_esn_rec.ESN||' didn''t pass validate_phone_prc');
             WHEN e_dll_error THEN
                -- LOG error message and CONTINUE with next esn
                ota_util_pkg.err_log (p_action   => 'Sending marketing PSMS message in batch mode'
                ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_batch'
                ,p_error_text  => 'DLL returned error number '|| n_error_num ||' for ESN '||cur_esn_rec.ESN);
          END;
       END LOOP;

    EXCEPTION

       WHEN e_psms_msg_null THEN
          ota_util_pkg.err_log (p_action   => 'Sending marketing PSMS message in batch mode'
             ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_batch'
             ,p_error_text  => 'marketing message is null in TABLE_X_OTA_MRKT_INFO. X_MRKT_NUMBER='||p_ota_mrkt_number||' X_MRKT_TYPE='||p_ota_mrkt_type);
       WHEN e_psms_msg_too_big THEN
          ota_util_pkg.err_log (p_action   => 'Sending marketing PSMS message in batch mode'
             ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_batch'
             ,p_error_text  => 'The size of message in TABLE_X_OTA_MRKT_INFO exceeds 155 characters. X_MRKT_NUMBER='||p_ota_mrkt_number||' X_MRKT_TYPE='||p_ota_mrkt_type);
       WHEN e_psms_msg_too_old THEN
          ota_util_pkg.err_log (p_action   => 'Sending marketing PSMS message in batch mode'
             ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_batch'
             ,p_error_text  => 'The message in TABLE_X_OTA_MRKT_INFO is too old. X_MRKT_NUMBER='||p_ota_mrkt_number||' X_MRKT_TYPE='||p_ota_mrkt_type||' X_END_DATE='||ota_msg_info_rec.x_end_date);
       WHEN e_psms_msg_not_active THEN
          ota_util_pkg.err_log (p_action   => 'Sending marketing PSMS message in batch mode'
             ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_batch'
             ,p_error_text  => 'The message in TABLE_X_OTA_MRKT_INFO is NOT active. X_MRKT_NUMBER='||p_ota_mrkt_number||' X_MRKT_TYPE='||p_ota_mrkt_type||' X_STATUS='||ota_msg_info_rec.x_status);
       WHEN OTHERS THEN
          ota_util_pkg.err_log (p_action   => 'Sending marketing PSMS message in batch mode'
             ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_batch'
             ,p_error_text  => SQLERRM);
          -- do we need to terminate the procedure here or just log the error in error_table?
          RAISE_APPLICATION_ERROR (-20001, 'ota_mrkt_info_pkg.SEND_PSMS_BATCH procedure call failed: '||SQLERRM);

    ********************** END COMMENT SECTION ****************************/
  END send_psms_batch;

  /*******************************************************************
  | Refer to package spec for detailed description of this procedure |
  *******************************************************************/
  PROCEDURE send_psms
  (
    p_esn                       IN VARCHAR2
   ,p_min                       IN VARCHAR2
   ,p_mode                      IN VARCHAR2
   ,p_text                      IN VARCHAR2
   ,p_int_dll_to_use            IN NUMBER
   ,p_psms_message              OUT VARCHAR2
   ,p_ota_trans2x_ota_mrkt_info IN VARCHAR2 DEFAULT NULL
   ,p_ota_trans_reason          IN VARCHAR2 DEFAULT NULL
   ,p_x_ota_trans2x_call_trans  IN NUMBER DEFAULT NULL
   ,p_cbo_error_message         IN VARCHAR2 DEFAULT NULL -- error message passed from CBO
   ,p_mobile365_id              IN VARCHAR2 DEFAULT NULL
   ,
    --OTA Enhancements
    p_ota_trans_objid OUT NUMBER -- 06/27/05   CR4169
  ) IS
    n_psms_counter NUMBER;
    n_error_number NUMBER;

    /********************************************************
    | return additional phone info            |
    ********************************************************/
    /*
    All of the Line statuses below are included in the "IN" list
    because there is a chance that the phone is activated but we
    didn't receive the acknowledgment from it.
    ESN status in that case will not be changed.
    This code here is to handle such case
    */
    CURSOR get_phone_info_cur IS
      SELECT ca.x_carrier_id
            ,piesn.x_sequence
            ,DECODE(x_technology
                   ,'ANALOG'
                   ,'0'
                   ,'CDMA'
                   ,'2'
                   ,'TDMA'
                   ,'1'
                   ,'GSM'
                   ,'3') technology
            ,pn.x_dll
        FROM table_x_carrier    ca
            ,table_x_code_table ctmin
            ,table_part_inst    pimin
            ,table_x_code_table ctesn
            ,table_part_inst    piesn
            ,table_mod_level    ml
            ,table_part_num     pn
            ,table_x_code_table xct
       WHERE pn.objid = ml.part_info2part_num
         AND ml.objid = piesn.n_part_inst2part_mod
         AND piesn.x_part_inst_status = xct.x_code_number
         AND ca.objid = pimin.part_inst2carrier_mkt
         AND ctmin.x_code_number || '' IN (ota_util_pkg.msid_update -- '110'
                                          ,ota_util_pkg.line_active -- '13'
                                          ,ota_util_pkg.pending_ac_change -- '34'
                                          ,ota_util_pkg.reserved -- '57'
                                          ,ota_util_pkg.reserved_used -- '39'
                                          ,ota_util_pkg.port_cancelled --79 CR5349
                                           )
         AND ctmin.x_code_type = 'LS'
         AND pimin.x_part_inst_status = ctmin.x_code_number
         AND pimin.part_to_esn2part_inst = piesn.objid
         AND ctesn.x_code_number || '' IN (ota_util_pkg.esn_active -- '52'
                                          ,ota_util_pkg.esn_refurbished -- '150'
                                          ,ota_util_pkg.esn_new -- '50'
                                           )
         AND ctesn.x_code_type = 'PS'
         AND piesn.x_part_inst_status = ctesn.x_code_number
         AND piesn.part_serial_no = p_esn;

    get_phone_info_rec get_phone_info_cur%ROWTYPE;
    e_phoneinfo_notfound EXCEPTION;
    c_err_msg        VARCHAR2(2000);
    c_int_dll_to_use NUMBER;
  BEGIN
    OPEN get_phone_info_cur;

    FETCH get_phone_info_cur
      INTO get_phone_info_rec;

    IF get_phone_info_cur%NOTFOUND THEN
      CLOSE get_phone_info_cur; --CR5349

      RAISE e_phoneinfo_notfound;
    END IF;

    CLOSE get_phone_info_cur;

    -- step 1: get DLL number from database if needed
    IF p_int_dll_to_use = -1 THEN
      -- get DLL from database table
      c_int_dll_to_use := get_phone_info_rec.x_dll;
    ELSE
      c_int_dll_to_use := p_int_dll_to_use;
    END IF;

    -- step 2: return PSMS counter
    n_psms_counter := ota_util_pkg.get_next_esn_counter(p_esn);
    -- step 3: call DLL to create PSMS message
    ota_extproc_pkg.send_marketing_psms(p_esn_in         => p_esn
                                       ,p_sequence_in    => get_phone_info_rec.x_sequence
                                       ,p_technology_in  => get_phone_info_rec.technology
                                       ,p_transid_in     => n_psms_counter
                                       ,p_message_in     => p_text
                                       ,p_int_dll_to_use => c_int_dll_to_use
                                        --06/27/05  CR4169
                                       ,p_error_number_out => n_error_number
                                       ,p_message_out      => p_psms_message);
    -- step 4: create ota transaction
    ota_trans_pkg.create_mrkt_transaction(p_esn          => p_esn
                                         ,p_min          => p_min
                                         ,p_psms_counter => n_psms_counter
                                         ,p_carrier_id   => get_phone_info_rec.x_carrier_id
                                         ,p_mode         => p_mode
                                         ,p_psms_text    => p_psms_message
                                          -- optional parameters:
                                         ,p_ota_trans2x_ota_mrkt_info => p_ota_trans2x_ota_mrkt_info
                                         ,p_ota_trans_reason          => p_ota_trans_reason
                                         ,p_ota_trans2x_call_tran     => p_x_ota_trans2x_call_trans
                                         ,p_cbo_error_message         => p_cbo_error_message
                                         ,p_ota_trans_objid           => p_ota_trans_objid
                                         ,p_mobile365_id              => p_mobile365_id
                                          --OTA Enhancements
                                          ); -- 06/27/05  CR4169
  EXCEPTION
    WHEN e_phoneinfo_notfound THEN
      c_err_msg := 'Failed to return carrier_id and x_sequence. ESN = ' || p_esn;
      ota_util_pkg.err_log(p_action       => 'Getting carrier_id and x_sequence from table_x_carrier and table_part_inst'
                          ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms'
                          ,p_key          => p_esn
                          ,p_error_text   => c_err_msg);
      raise_application_error(-20001
                             ,c_err_msg);
    WHEN others THEN
      ota_util_pkg.err_log(p_action       => 'Sending marketing PSMS message'
                          ,p_program_name => 'OTA_MKT_INFO_PKG.send_psms'
                          ,p_error_text   => SQLERRM);
      raise_application_error(-20001
                             ,'Procedure failed with error: ' || SQLERRM);
  END send_psms;

  PROCEDURE send_psms_inq
  (
    p_esn             IN VARCHAR2 -- ESN
   ,p_min             IN VARCHAR2 -- MIN
   ,p_mode            IN VARCHAR2 -- WEB, BATCH
   ,p_psms_message    IN VARCHAR2
   ,p_reason          IN VARCHAR2
   ,p_x_counter       IN NUMBER DEFAULT NULL
   ,p_mobile365_id    IN VARCHAR2 DEFAULT NULL
   , --OTA Enhancements
    p_ota_trans_objid OUT NUMBER -- 06/27/05 CR4169
  ) IS
    n_psms_counter NUMBER;
    n_error_number NUMBER;

    /********************************************************
    | return additional phone info            |
    ********************************************************/
    CURSOR get_phone_info_cur IS
      SELECT ca.x_carrier_id
            ,piesn.x_sequence
            ,piesn.n_part_inst2part_mod -- 06/27/05 CR4169
        FROM table_x_carrier    ca
            ,table_x_code_table ctmin
            ,table_part_inst    pimin
            ,table_x_code_table ctesn
            ,table_part_inst    piesn
       WHERE ca.objid = pimin.part_inst2carrier_mkt
         AND ctmin.x_code_number || '' IN (ota_util_pkg.msid_update
                                          ,ota_util_pkg.line_active
                                          ,ota_util_pkg.pending_ac_change
                                          ,ota_util_pkg.reserved
                                          ,ota_util_pkg.reserved_used
                                          ,ota_util_pkg.port_cancelled --CR5349
                                           )
         AND ctmin.x_code_type = 'LS'
         AND pimin.x_part_inst_status = ctmin.x_code_number
         AND pimin.part_to_esn2part_inst = piesn.objid
         AND ctesn.x_code_number || '' IN (ota_util_pkg.esn_active
                                          ,ota_util_pkg.esn_refurbished
                                          ,ota_util_pkg.esn_new)
         AND ctesn.x_code_type = 'PS'
         AND piesn.x_part_inst_status = ctesn.x_code_number
         AND piesn.part_serial_no = p_esn;

    get_phone_info_rec get_phone_info_cur%ROWTYPE;
    e_phoneinfo_notfound EXCEPTION;
    c_err_msg VARCHAR2(2000);
  BEGIN
    OPEN get_phone_info_cur;

    FETCH get_phone_info_cur
      INTO get_phone_info_rec;

    IF get_phone_info_cur%NOTFOUND THEN
      CLOSE get_phone_info_cur; --CR5349

      RAISE e_phoneinfo_notfound;
    END IF;

    CLOSE get_phone_info_cur;

    -- step 1: return PSMS counter
    n_psms_counter := NVL(p_x_counter
                         ,ota_util_pkg.get_next_esn_counter(p_esn));
    -- step 2: create ota transaction
    ota_trans_pkg.create_inq_transaction(p_esn          => p_esn
                                        ,p_min          => p_min
                                        ,p_psms_counter => n_psms_counter
                                        ,p_mode         => p_mode
                                        ,p_psms_text    => p_psms_message
                                         -- optional parameters:
                                        ,p_ota_trans_reason => p_reason
                                        ,p_mobile365_id     => p_mobile365_id
                                        ,
                                         --OTA Enhancements
                                         p_ota_trans_objid => p_ota_trans_objid
                                         -- 06/27/05 CR4169
                                         );
  EXCEPTION
    WHEN e_phoneinfo_notfound THEN
      c_err_msg := 'Failed to return carrier_id and x_sequence. ESN = ' || p_esn;
      ota_util_pkg.err_log(p_action       => 'Getting carrier_id and x_sequence from table_x_carrier and table_part_inst'
                          ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms_inq'
                          ,p_key          => p_esn
                          ,p_error_text   => c_err_msg);
      raise_application_error(-20001
                             ,c_err_msg);
    WHEN others THEN
      ota_util_pkg.err_log(p_action       => 'Sending marketing PSMS message'
                          ,p_program_name => 'OTA_MKT_INFO_PKG.send_psms_inq'
                          ,p_error_text   => SQLERRM);
      raise_application_error(-20001
                             ,'Procedure failed with error: ' || SQLERRM);
  END send_psms_inq;

  PROCEDURE send_psms_pre_dll
  (
    p_esn                       IN VARCHAR2
   ,p_min                       IN VARCHAR2
   ,p_mode                      IN VARCHAR2
   ,p_text                      IN VARCHAR2
   ,p_int_dll_to_use            IN NUMBER
   ,p_psms_message              OUT VARCHAR2
   ,p_ota_trans2x_ota_mrkt_info IN VARCHAR2 DEFAULT NULL
   ,p_ota_trans_reason          IN VARCHAR2 DEFAULT NULL
   ,p_x_ota_trans2x_call_trans  IN NUMBER DEFAULT NULL
   ,p_cbo_error_message         IN VARCHAR2 DEFAULT NULL
   , -- error message passed from CBO
    p_mobile365_id              IN VARCHAR2 DEFAULT NULL
   ,
    --OTA Enhancements
    p_ota_trans_objid OUT NUMBER
   , -- 06/27/05 CR4169
    --OUT
    p_sequence_in       OUT NUMBER
   ,p_technology_in     OUT NUMBER
   ,p_transid_in        OUT NUMBER
   ,p_int_dll_to_use_in OUT NUMBER
   ,p_x_carrier_id_in   OUT NUMBER
  ) IS

    n_psms_counter NUMBER;

    /********************************************************
    | return additional phone info            |
    ********************************************************/
    /*
    All of the Line statuses below are included in the "IN" list
    because there is a chance that the phone is activated but we
    didn't receive the acknowledgment from it.
    ESN status in that case will not be changed.
    This code here is to handle such case
    */
    CURSOR get_phone_info_cur IS
      SELECT ca.x_carrier_id
            ,piesn.x_sequence
            ,DECODE(x_technology
                   ,'ANALOG'
                   ,'0'
                   ,'CDMA'
                   ,'2'
                   ,'TDMA'
                   ,'1'
                   ,'GSM'
                   ,'3') technology
            ,pn.x_dll
        FROM table_x_carrier    ca
            ,table_x_code_table ctmin
            ,table_part_inst    pimin
            ,table_x_code_table ctesn
            ,table_part_inst    piesn
            ,table_mod_level    ml
            ,table_part_num     pn
            ,table_x_code_table xct
       WHERE pn.objid = ml.part_info2part_num
         AND ml.objid = piesn.n_part_inst2part_mod
         AND piesn.x_part_inst_status = xct.x_code_number
         AND ca.objid = pimin.part_inst2carrier_mkt
         AND ctmin.x_code_number || '' IN (ota_util_pkg.msid_update -- '110'
                                          ,ota_util_pkg.line_active -- '13'
                                          ,ota_util_pkg.pending_ac_change -- '34'
                                          ,ota_util_pkg.reserved -- '57'
                                          ,ota_util_pkg.reserved_used -- '39'
                                          ,ota_util_pkg.port_cancelled --79 CR5349
                                           )
         AND ctmin.x_code_type = 'LS'
         AND pimin.x_part_inst_status = ctmin.x_code_number
         AND pimin.part_to_esn2part_inst = piesn.objid
         AND ctesn.x_code_number || '' IN (ota_util_pkg.esn_active -- '52'
                                          ,ota_util_pkg.esn_refurbished -- '150'
                                          ,ota_util_pkg.esn_new -- '50'
                                           )
         AND ctesn.x_code_type = 'PS'
         AND piesn.x_part_inst_status = ctesn.x_code_number
         AND piesn.part_serial_no = p_esn;

    get_phone_info_rec get_phone_info_cur%ROWTYPE;
    e_phoneinfo_notfound EXCEPTION;
    c_err_msg        VARCHAR2(2000);
    c_int_dll_to_use NUMBER;

    tf_var_text VARCHAR2(1000);
  BEGIN

    OPEN get_phone_info_cur;

    FETCH get_phone_info_cur
      INTO get_phone_info_rec;

    IF get_phone_info_cur%NOTFOUND THEN
      CLOSE get_phone_info_cur; --CR5349

      RAISE e_phoneinfo_notfound;
    END IF;

    CLOSE get_phone_info_cur;
    -- step 1: get DLL number from database if needed
    IF p_int_dll_to_use = -1 THEN
      -- get DLL from database table
      c_int_dll_to_use := get_phone_info_rec.x_dll;
    ELSE
      c_int_dll_to_use := p_int_dll_to_use;
    END IF;

    -- step 2: return PSMS counter
    n_psms_counter := ota_util_pkg.get_next_esn_counter(p_esn);

    p_sequence_in       := get_phone_info_rec.x_sequence;
    p_technology_in     := get_phone_info_rec.technology;
    p_transid_in        := n_psms_counter;
    p_int_dll_to_use_in := c_int_dll_to_use;
    p_x_carrier_id_in   := get_phone_info_rec.x_carrier_id;

  EXCEPTION
    WHEN e_phoneinfo_notfound THEN
      c_err_msg := 'Failed to return carrier_id and x_sequence. ESN = ' || p_esn;
      ota_util_pkg.err_log(p_action       => 'Getting carrier_id and x_sequence from table_x_carrier and table_part_inst'
                          ,p_program_name => 'OTA_MRKT_INFO_PKG.send_psms'
                          ,p_key          => p_esn
                          ,p_error_text   => c_err_msg);
      raise_application_error(-20001
                             ,c_err_msg);
    WHEN others THEN
      ota_util_pkg.err_log(p_action       => 'Sending marketing PSMS message'
                          ,p_program_name => 'OTA_MKT_INFO_PKG.send_psms'
                          ,p_error_text   => SQLERRM);
      raise_application_error(-20001
                             ,'Procedure failed with error: ' || SQLERRM);

  END send_psms_pre_dll;
  --
  --CR20545 Start kacosta 07/31/2012
  --********************************************************************************
  -- Procedure to get the next BYOP SMS staging record
  --********************************************************************************
  --
  PROCEDURE get_next_byop_sms_stg
  (
    p_esn              OUT byop_sms_stg.esn%TYPE
   ,p_min              OUT byop_sms_stg.min%TYPE
   ,p_ota_psms_address OUT table_x_parent.x_ota_psms_address%TYPE
   ,p_agg_carr_code    OUT table_x_parent.x_agg_carr_code%TYPE
   ,p_transaction_type OUT byop_sms_stg.transaction_type%TYPE
   ,p_brand            OUT table_bus_org.org_id%TYPE
   ,p_error_code       OUT PLS_INTEGER
   ,P_ERROR_MESSAGE    OUT VARCHAR2
   ,p_expire_dt        OUT date    ---CR22452 simple mobile
   ,p_x_msg_script_id  OUT byop_sms_stg.x_msg_script_id%TYPE -- CR44652
   ,p_forecast_date    OUT DATE -- CR44787
   ,p_x_msg_script_variables OUT byop_sms_stg.x_msg_script_variables%TYPE  -- CR42899
  ) IS
  --
  l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.get_next_byop_sms_stg';
  l_i_error_code       PLS_INTEGER := 0;
  l_n_agg_carr_code    table_x_parent.x_agg_carr_code%TYPE;
  l_v_error_message    VARCHAR2(32767) := 'SUCCESS';
  l_v_position         VARCHAR2(32767) := l_cv_subprogram_name || '.1';
  l_v_note             VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
  l_v_esn              byop_sms_stg.esn%TYPE;
  l_v_min              byop_sms_stg.min%TYPE;
  l_v_ota_psms_address table_x_parent.x_ota_psms_address%TYPE;
  l_v_transaction_type byop_sms_stg.transaction_type%TYPE;
  L_V_BRAND            table_bus_org.org_id%TYPE;
  l_x_msg_script_id    byop_sms_stg.x_msg_script_id%TYPE;

  -- CR44787
  l_serviceplanid  NUMBER ;
  l_serviceplanname  VARCHAR2(32767) ;
  l_serviceplanunlimited  NUMBER;
  l_autorefill  NUMBER;
  l_service_end_dt  DATE;
  l_forecast_date  DATE;
  l_creditcardreg  NUMBER;
  l_redempcardqueue  NUMBER;
  l_creditcardsch  NUMBER;
  l_statusid  VARCHAR2(32767);
  l_statusdesc  VARCHAR2(32767);
  l_email  VARCHAR2(32767);
  l_part_num  VARCHAR2(32767);
  l_err_num  NUMBER;
  l_err_string  VARCHAR2(32767);

  --
  l_x_msg_script_variables    byop_sms_stg.x_msg_script_variables%TYPE; -- CR42899
  ct customer_type := customer_type(); --CR47675 GoSmart

  --cr22452
  CURSOR EXPIRE_dt_CUR  IS
       select x_expire_dt
              from table_site_part sp
             where 1=1
               and sp.x_service_id = p_esn
               AND SP.PART_STATUS||'' = 'Active'
        AND ROWNUM < 2;

    EXPIRE_dt_rec EXPIRE_dt_CUR%ROWTYPE;

  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get next BYOP SMS staging record';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    FOR rec_byop_sms_stg IN (
        SELECT * FROM (
                       SELECT /*+ INDEX(bss byop_sms_stg_idx3) */
                              bss.esn
                             ,bss.min
                             ,txp.x_ota_psms_address ota_psms_address
                             ,txp.x_agg_carr_code    agg_carr_code
                             ,bss.transaction_type
        ,bss.x_msg_script_id
        ,bss.x_msg_script_variables   -- CR42899
                               FROM byop_sms_stg bss
                               LEFT OUTER JOIN table_x_carrier txc    -- CR42899 Changed JOIN to LEFT OUTER JOIN
                                 ON bss.carrier_id = txc.x_carrier_id
                               LEFT OUTER JOIN table_x_carrier_group xcg  -- CR42899 Changed JOIN to LEFT OUTER JOIN
                                 ON txc.carrier2carrier_group = xcg.objid
                               LEFT OUTER JOIN table_x_parent txp   -- CR42899 Changed JOIN to LEFT OUTER JOIN
                                 ON xcg.x_carrier_group2x_parent = txp.objid
                              WHERE bss.sent_date IS NULL
                  AND bss.min IS NOT NULL -- CR44787
                                ORDER BY bss.insert_date
                )
                WHERE ROWNUM <= 1)
  LOOP
      --
      l_v_esn              := rec_byop_sms_stg.esn;
      l_v_min              := rec_byop_sms_stg.min;
      l_v_ota_psms_address := rec_byop_sms_stg.ota_psms_address;
      l_n_agg_carr_code    := rec_byop_sms_stg.agg_carr_code;
      l_v_transaction_type := rec_byop_sms_stg.transaction_type;
      l_v_brand            := bau_util_pkg.get_esn_brand(p_esn => rec_byop_sms_stg.esn);
      l_x_msg_script_id    := rec_byop_sms_stg.x_msg_script_id;
      l_x_msg_script_variables     := rec_byop_sms_stg.x_msg_script_variables;    -- CR42899
          --
    END LOOP;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Check if BYOP SMS staging record was found';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (l_v_esn IS NOT NULL) THEN
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'Yes, BYOP SMS staging record was found; update the sent date for the record';
      --


      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
    --dbms_output.put_line(' l_v_esn :' || l_v_esn);
    --dbms_output.put_line(' l_v_min :' || l_v_min);
    --dbms_output.put_line(' l_v_transaction_type :' || l_v_transaction_type);
      UPDATE byop_sms_stg
         SET sent_date = SYSDATE
       WHERE esn = l_v_esn
         AND MIN = l_v_min
         AND transaction_type = l_v_transaction_type;
      --dbms_output.put_line(' No of Records Updated :' || SQL%ROWCOUNT);
    --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.5';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn             : ' || NVL(l_v_esn
                                                        ,'Value is null'));
      dbms_output.put_line('p_min             : ' || NVL(l_v_min
                                                        ,'Value is null'));
      dbms_output.put_line('p_ota_psms_address: ' || NVL(l_v_ota_psms_address
                                                        ,'Value is null'));
      dbms_output.put_line('p_agg_carr_code   : ' || NVL(TO_CHAR(l_n_agg_carr_code)
                                                        ,'Value is null'));
      dbms_output.put_line('p_transaction_type: ' || NVL(l_v_transaction_type
                                                        ,'Value is null'));
      dbms_output.put_line('p_brand           : ' || NVL(l_v_brand
                                                        ,'Value is null'));
      dbms_output.put_line('p_error_code      : ' || NVL(TO_CHAR(l_i_error_code)
                                                        ,'Value is null'));
      dbms_output.put_line('p_error_message   : ' || NVL(l_v_error_message
                                                        ,'Value is null'));
      dbms_output.put_line('p_error_message   : ' || NVL(l_x_msg_script_id
                                                        ,'Value is null'));
      --
    END IF;

  -- CR44787
  sa.service_plan.get_service_plan_prc(
     l_v_esn -- ip_esn
    ,l_serviceplanid
    ,l_serviceplanname
    ,l_serviceplanunlimited
    ,l_autorefill
    ,l_service_end_dt
    ,l_forecast_date
    ,l_creditcardreg
    ,l_redempcardqueue
    ,l_creditcardsch
    ,l_statusid
    ,l_statusdesc
    ,l_email
    ,l_part_num
    ,l_err_num
    ,l_err_string);


    --
    p_esn              := l_v_esn;
    p_min              := l_v_min;
    p_ota_psms_address := l_v_ota_psms_address;
    p_agg_carr_code    := l_n_agg_carr_code;
    p_transaction_type := l_v_transaction_type;
    p_brand            := l_v_brand;
    p_error_code       := l_i_error_code;
    p_error_message    := l_v_error_message;
    p_x_msg_script_id  := l_x_msg_script_id;
    p_forecast_date    := l_forecast_date; -- CR44787
    p_x_msg_script_variables :=  l_x_msg_script_variables;   -- CR42899

    --CR47675 Go Smart sub brand changes for Welcome message
    ct.esn             := l_v_esn;
    ct.min             := l_v_min;

    IF ct.get_sub_brand = 'GO_SMART'
    THEN
      p_brand := 'GO_SMART';
    END IF;
     --CR47675 Go Smart sub brand changes for Welcome message



    --
 --cr22452
    OPEN EXPIRE_DT_CUR;
    FETCH EXPIRE_dt_CUR
      INTO EXPIRE_DT_REC;
      P_EXPIRE_DT := EXPIRE_DT_REC.X_EXPIRE_DT;
    CLOSE EXPIRE_dt_CUR;

    COMMIT;
    --
  EXCEPTION
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_esn              := NULL;
      p_min              := NULL;
      p_ota_psms_address := NULL;
      p_agg_carr_code    := NULL;
      p_transaction_type := NULL;
      p_brand            := NULL;
      p_error_code       := SQLCODE;
      p_error_message    := SQLERRM;
    p_x_msg_script_id  := NULL;
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END get_next_byop_sms_stg;

  --CR52112 Procedure will retun records in bulk based on input parameter
  --********************************************************************************
  -- Procedure to get the next BYOP SMS staging for Bulk Processing
  --*******************************************************************************

PROCEDURE get_next_byop_sms_stg_blk
  (
    p_return_limit     IN  NUMBER DEFAULT 500,
    p_cursor           OUT SYS_REFCURSOR
  ) IS
  --
  l_cv_subprogram_name    CONSTANT VARCHAR2(100) := l_cv_package_name || '.get_next_byop_sms_stg_blk';
  l_v_position            VARCHAR2(32767) := l_cv_subprogram_name  ;
  l_v_note                VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
  v_error_code            PLS_INTEGER ;
  v_error_Message         VARCHAR2(50);
  v_cnt                   NUMBER := 0;
  v_upd                   NUMBER := 0;
  v_tot_rec_cnt           NUMBER := 0;
  v_sysdate               DATE := SYSDATE;
  ct                      sa.customer_type := sa.customer_type();
  l_serviceplanid         NUMBER ;
  l_serviceplanname       VARCHAR2(32767) ;
  l_serviceplanunlimited  NUMBER;
  l_autorefill            NUMBER;
  l_service_end_dt        DATE;
  l_creditcardreg         NUMBER;
  l_redempcardqueue       NUMBER;
  l_creditcardsch         NUMBER;
  l_statusid              VARCHAR2(32767);
  l_statusdesc            VARCHAR2(32767);
  l_email                 VARCHAR2(32767);
  l_part_num              VARCHAR2(32767);
  l_err_num               NUMBER;
  l_err_string            VARCHAR2(32767);
  l_fetch_limit           NUMBER := 1000;
  v_brand                 table_bus_org.org_id%TYPE := 'GO_SMART';
  v_active                sa.table_site_part.part_status%TYPE  := 'Active';
  --
  CURSOR expire_dt_cur(v_esn IN sa.table_site_part.x_service_id%TYPE)
  IS
    SELECT x_expire_dt
    FROM   table_site_part sp
    WHERE  1=1
      AND  sp.x_service_id = v_esn
      AND  sp.part_status||'' = v_active
      AND  ROWNUM < 2;
  expire_dt_rec expire_dt_cur%ROWTYPE;
  --CR52654 added new cursor to get the sms flag
  CURSOR get_sms_flag(v1_brand IN VARCHAR2)
  IS
    SELECT NVL(sms_flag_3ci,'N')  sms_flag
      FROM sa.table_bus_org
     WHERE org_id = v1_brand;
  get_sms_rec get_sms_flag%ROWTYPE; --CR52654
  --
  CURSOR byop_sms_blk
  IS
    SELECT *
    FROM ( SELECT /*+ INDEX(bss byop_sms_stg_idx3) */
                   bss.rowid
                  ,bss.esn
                  ,bss.min
                  ,txp.x_ota_psms_address ota_psms_address
                  ,txp.x_agg_carr_code    agg_carr_code
                  ,bss.transaction_type
                  ,bss.x_msg_script_id
                  ,bss.x_msg_script_variables
                  ,0 v_error_code
                  ,'SUCCESS' v_error_message
          FROM sa.byop_sms_stg bss
            LEFT OUTER JOIN table_x_carrier txc
              ON bss.carrier_id = txc.x_carrier_id
            LEFT OUTER JOIN table_x_carrier_group xcg
              ON txc.carrier2carrier_group = xcg.objid
            LEFT OUTER JOIN table_x_parent txp
              ON xcg.x_carrier_group2x_parent = txp.objid
          WHERE bss.sent_date IS NULL
            AND bss.status = 'Q' -- CR55313 only pickup Queued Records
            AND bss.min IS NOT NULL
          ORDER BY bss.insert_date)
    WHERE ROWNUM < p_return_limit;
  --
  TYPE t_byop_sms_blk IS TABLE OF byop_sms_blk%ROWTYPE;
  rec_byop_sms_blk  t_byop_sms_blk;
  p_rec_out      sa.byop_sms_send_list   := sa.byop_sms_send_list() ; -- Out record type initialized.
  l_byop_record  sa.byop_sms_send_record := sa.byop_sms_send_record(null,null,null,null,null,null,null,null,null,null,null,null,null,null); -- Out record type initialized.;
  --
BEGIN
  --
  OPEN byop_sms_blk;
  LOOP
    FETCH byop_sms_blk BULK COLLECT INTO rec_byop_sms_blk limit l_fetch_limit;
        --dbms_output.put_line('Here 1 '||rec_byop_sms_blk.count);
    IF rec_byop_sms_blk.count > 0 THEN
      FOR i IN 1..rec_byop_sms_blk.LAST
      LOOP
        BEGIN -- to handle exception if any in loop

          l_v_position               := l_cv_subprogram_name || '.1';
          l_v_note                   := 'Inside  For Loop ' || l_cv_subprogram_name;
          p_rec_out.extend();
          p_rec_out(p_rec_out.LAST)  := l_byop_record;
          ct.esn                     := rec_byop_sms_blk(i).esn;
          ct.min                     := rec_byop_sms_blk(i).min;
          p_rec_out(i).p_brand       := sa.bau_util_pkg.get_esn_brand(p_esn => rec_byop_sms_blk(i).esn);

          -- Deriving Sub Brand for GO SMART
          IF ct.get_sub_brand = v_brand THEN
            p_rec_out(i).p_brand := v_brand;
          END IF;

          l_v_position := l_cv_subprogram_name || '.2';
          l_v_note     := 'After Brand Derivation ' || l_cv_subprogram_name;
          dbms_output.put_line('Record fetch : esn:'    || rec_byop_sms_blk(i).esn||
                               ',transaction_type:'     || rec_byop_sms_blk(i).transaction_type||
                               ',p_rec_out(i).p_brand :'|| p_rec_out(i).p_brand||',l_v_note:||l_v_note');

          -- Deriving Expire Date
          OPEN expire_dt_cur(rec_byop_sms_blk(i).esn);
          FETCH expire_dt_cur INTO expire_dt_rec;
          p_rec_out(i).p_expire_dt := expire_dt_rec.x_expire_dt;
          CLOSE expire_dt_cur;
          -- Deriving SMS Flag CR52654
          OPEN get_sms_flag(p_rec_out(i).p_brand);
          FETCH get_sms_flag INTO get_sms_rec;
          IF get_sms_flag%FOUND THEN
            p_rec_out(i).p_sms_flag := get_sms_rec.sms_flag;
          ELSE
            p_rec_out(i).p_sms_flag := 'N';
          END IF;
          CLOSE get_sms_flag;

          l_v_position := l_cv_subprogram_name || '.3';
          l_v_note     := 'After Expire Date Derivation ' || l_cv_subprogram_name;
          -- Deriving Forecast Date
          --dbms_output.put_line('Here 2 ');
          sa.service_plan.get_service_plan_prc( rec_byop_sms_blk(i).esn
                                               ,l_serviceplanid
                                               ,l_serviceplanname
                                               ,l_serviceplanunlimited
                                               ,l_autorefill
                                               ,l_service_end_dt
                                               ,p_rec_out(i).p_forecast_date
                                               ,l_creditcardreg
                                               ,l_redempcardqueue
                                               ,l_creditcardsch
                                               ,l_statusid
                                               ,l_statusdesc
                                               ,l_email
                                               ,l_part_num
                                               ,l_err_num
                                               ,l_err_string);
          --
          l_v_position                          := l_cv_subprogram_name || '.3';
          l_v_note                              := 'After Forecast Date Derivation ' || l_cv_subprogram_name;
          --
          --CR55313 Set new attribute p_rowid, CBO will use this to update on their end
          p_rec_out(i).p_rowid                  := rowidtochar(rec_byop_sms_blk(i).rowid);
          p_rec_out(i).p_esn                    := rec_byop_sms_blk(i).esn;
          p_rec_out(i).p_min                    := rec_byop_sms_blk(i).min;
          p_rec_out(i).p_ota_psms_address       := rec_byop_sms_blk(i).ota_psms_address;
          p_rec_out(i).p_agg_carr_code          := rec_byop_sms_blk(i).agg_carr_code;
          p_rec_out(i).p_transaction_type       := rec_byop_sms_blk(i).transaction_type;
          p_rec_out(i).p_error_code             := rec_byop_sms_blk(i).v_error_code;
          p_rec_out(i).p_error_message          := rec_byop_sms_blk(i).v_error_Message;
          p_rec_out(i).p_x_msg_script_id        := rec_byop_sms_blk(i).x_msg_script_id;
          p_rec_out(i).p_x_msg_script_variables := rec_byop_sms_blk(i).x_msg_script_variables;

          dbms_output.put_line('p_rec_out(i).p_esn : '||p_rec_out(i).p_esn );
          --
          --CR55313 Use rowid to update staging table and set to 'S'
          UPDATE byop_sms_stg
             SET sent_date = v_sysdate,
                 status    = 'S'
          WHERE  1     = 1
            AND  rowid = rec_byop_sms_blk(i).rowid;
            -- AND esn              = rec_byop_sms_blk(i).esn
            -- AND min              = rec_byop_sms_blk(i).min
            -- AND transaction_type = rec_byop_sms_blk(i).transaction_type;

          v_upd := v_upd + SQL%ROWCOUNT;
          v_cnt := v_cnt +1;
          l_v_position := l_cv_subprogram_name || '.4';
          l_v_note     := 'After Successfull Update ' || l_cv_subprogram_name;

          dbms_output.put_line('After Successfull Update :'||'esn:'||rec_byop_sms_blk(i).esn);

        EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          l_v_note     := 'In Exception ' || l_cv_subprogram_name;
          p_rec_out(i).p_error_message := SQLERRM;
          ota_util_pkg.err_log(p_action       => l_v_note
                              ,p_error_date   => v_sysdate
                              ,p_key          => rec_byop_sms_blk(i).esn
                              ,p_program_name => l_v_position
                              ,p_error_text   => p_rec_out(i).p_error_message);
        END;
      END LOOP; --FOR i IN 1..rec_byop_sms_blk.LAST
    END IF;
    COMMIT;
    EXIT WHEN byop_sms_blk%notfound;
  END LOOP; --OPEN byop_sms_blk
  CLOSE byop_sms_blk;
  OPEN p_cursor FOR SELECT * FROM TABLE ( CAST ( p_rec_out AS sa.byop_sms_send_list) );
  dbms_output.put_line('Exiting from Procedure total count '||v_cnt ||' update Count '||v_upd);
 --
EXCEPTION
WHEN OTHERS THEN
  --
  DBMS_OUTPUT.PUT_LINE('Exception'||SQLERRM);
  ROLLBACK;
  --
END get_next_byop_sms_stg_blk;
  --CR52112
  --
  --********************************************************************************
  -- Procedure to purge BYOP SMS staging records
  --********************************************************************************
  --
  PROCEDURE purge_byop_sms_stg
  (
    p_days_back     IN INTEGER DEFAULT 7
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.purge_byop_sms_stg';
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_days_back: ' || NVL(TO_CHAR(p_days_back)
                                                 ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Purge BYOP SMS staging records';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    DELETE byop_sms_stg bss
     WHERE bss.insert_date < TRUNC(SYSDATE) - NVL(p_days_back
                                                 ,7);
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code      : ' || NVL(TO_CHAR(l_i_error_code)
                                                        ,'Value is null'));
      dbms_output.put_line('p_error_message   : ' || NVL(l_v_error_message
                                                        ,'Value is null'));
      --
    END IF;
    --
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
    COMMIT;
    --
  EXCEPTION
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.13';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => TO_CHAR(p_days_back)
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END purge_byop_sms_stg;
  --CR20545 End Kacosta 07/31/2012

END ota_mrkt_info_pkg;
/