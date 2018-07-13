CREATE OR REPLACE PACKAGE BODY sa.rtr_multi_trans_pkg
AS
  /*******************************************************************************************************
  --$RCSfile: RTR_MULTI_TRANS_PKB.sql,v $
  --$ $Log: RTR_MULTI_TRANS_PKB.sql,v $
  --$ Revision 1.77  2018/04/23 19:15:56  sgangineni
  --$ CR49520 - Modified CANCEL_ORDER proc to add new error code 154
  --$
  --$ Revision 1.76  2018/04/23 16:10:09  sgangineni
  --$ CR49520 - New overloaded proc get_order_status
  --$
  --$ Revision 1.75  2018/04/20 19:07:39  tbaney
  --$ Added logic to correct ESN and MIN that were over written.
  --$
  --$ Revision 1.74  2018/04/19 16:22:35  tbaney
  --$ Incident_1784412 C95008 Changed to use util_pkg. Simple Mobile Dealers are receiving a a??device is already activea?? error message upon activation in RTR/API.
  --$
  --$ Revision 1.73  2018/03/09 17:40:28  sraman
  --$ Added log to consider COMPLETED_CRM and COMPLETED_BRM as COMPLETED
  --$
  --$ Revision 1.72  2018/03/08 19:58:08  sraman
  --$ bug fix
  --$
  --$ Revision 1.71  2018/03/07 17:15:12  sraman
  --$ Added validation for rtr_trans_type input
  --$
  --$ Revision 1.70  2018/03/05 22:32:17  sraman
  --$ Bug Fix
  --$
  --$ Revision 1.69  2018/03/02 21:53:33  sraman
  --$ Bug fix
  --$
  --$ Revision 1.68  2018/03/01 22:47:41  sraman
  --$ Changed Status Initiated to Inprogress
  --$
  --$ Revision 1.67  2018/03/01 21:38:06  sraman
  --$ added new procedure get_order_status
  --$
  --$ Revision 1.66  2018/02/14 19:11:21  sraman
  --$ CR56346  - SMMLD RTR Cancel Order-Add to Reserve
  --$
  --$ Revision 1.62  2018/01/15 20:48:36  sraman
  --$ CR52120 - Renamed cancel_order2 to cancel_order_unused
  --$
  --$ Revision 1.61  2018/01/12 19:01:04  sraman
  --$ CR52120 - Fixed Cancel Re-activation after 10 minute issue
  --$
  --$ Revision 1.60  2018/01/12 15:55:34  sgangineni
  --$ CR52120 - Added grants
  --$
  --$ Revision 1.59  2018/01/11 17:35:54  sraman
  --$ CR52120 - Modified as per review comments
  --$
  --$ Revision 1.58  2018/01/08 22:54:26  sgangineni
  --$ CR48260 - New validation in CANCEL_ORDER proc for error 153
  --$
  --$ Revision 1.57  2018/01/08 16:19:18  sgangineni
  --$ CR48260 - Fixed minor issue in CANCEL_ORDER proc
  --$
  --$ Revision 1.56  2018/01/06 17:40:23  sgangineni
  --$ CR48260 - Modified the web user comparison logic as per the new scenario identified
  --$  by SOA
  --$
  --$ Revision 1.55  2018/01/06 00:39:29  sgangineni
  --$ CR48260 - Fixed minor issue in error code 152
  --$
  --$ Revision 1.54  2018/01/05 23:46:35  sgangineni
  --$ CR48260 - Changes in update_order and cancel_order
  --$
  --$ Revision 1.53  2018/01/05 22:34:15  sraman
  --$ CR48260 - Added logging in all returns
  --$
  --$ Revision 1.52  2018/01/05 17:59:18  sraman
  --$ CR48260 - Added RTTR transaction logging.
  --$
  --$ Revision 1.51  2018/01/05 14:24:12  sraman
  --$ fixed truncate issue
  --$
  --$ Revision 1.50  2018/01/04 22:02:25  sraman
  --$ CR48260 - Bug Fix - Part number mapping issue
  --$
  --$ Revision 1.49  2018/01/04 21:06:16  sraman
  --$ CR48260 - To fix redeem ban scenario
  --$
  --$ Revision 1.48  2018/01/04 19:53:32  sgangineni
  --$ CR48260 - Fixed issue in cancel_order procedure
  --$
  --$ Revision 1.47  2018/01/03 23:15:30  sraman
  --$ CR48260 - Fixed Siteid null issue in submit order
  --$
  --$ Revision 1.46  2018/01/03 22:34:40  sraman
  --$ CR48260 - Fixed update_order header status issue
  --$
  --$ Revision 1.45  2018/01/03 20:02:54  sgangineni
  --$ CR48260 - issue fix in VALIDATE_ORDER
  --$
  --$ Revision 1.44  2018/01/03 19:58:50  sgangineni
  --$ CR48260 - issue fix in UPDATE_ORDER
  --$
  --$ Revision 1.43  2018/01/03 19:49:36  sgangineni
  --$ CR48260 - Fixed issue with SIM nap check for REDEMPTION and removed compare logic
  --$  from the UPDATE_ORDER procedure
  --$
  --$ Revision 1.42  2018/01/03 17:11:09  sraman
  --$ CR48260 - Removed Part num comparison in update order
  --$
  --$ Revision 1.41  2018/01/02 23:14:39  sgangineni
  --$ CR48260 - minor bug fix
  --$
  --$ Revision 1.40  2018/01/02 21:19:40  sgangineni
  --$ CR48260 - Fixed SIM related validation issues.
  --$
  --$ Revision 1.39  2018/01/02 20:16:22  sraman
  --$ CR48260 - Bug fix defect #35049 - for SIM Card- 10014, 10025 and 10029 are not being handled
  --$
  --$ Revision 1.38  2018/01/02 17:28:29  sgangineni
  --$ CR48260 - Reverted the ADD_TO_RESERVE code temporarly
  --$
  --$ Revision 1.37  2017/12/29 23:19:12  sgangineni
  --$ CR48260 - Fixed data comparision issues
  --$
  --$ Revision 1.35  2017/12/23 01:40:00  akhan
  --$ fixed code
  --$
  --$ Revision 1.34  2017/12/22 15:19:45  sgangineni
  --$ CR48260 - Fixed minor issues in update_order
  --$
  --$ Revision 1.33  2017/12/21 22:14:36  sraman
  --$ added check to see PIN fetch is success
  --$
  --$ Revision 1.32  2017/12/21 15:56:50  sgangineni
  --$ CR48260 - Fixed issues in VALIDATE_ORDER
  --$
  --$ Revision 1.31  2017/12/20 23:44:17  sgangineni
  --$ CR48260 - Additional validations in VALIDATE_ORDER as requested by Raj
  --$
  --$ Revision 1.25  2017/12/10 16:29:58  sgangineni
  --$ CR48260 - added c_discount_code_tbl.delete; statement
  --$
  --$ Revision 1.24  2017/12/06 23:41:10  sgangineni
  --$ CR48260 - Modified to have conditional commit
  --$
  --$ Revision 1.23  2017/12/06 23:33:55  sgangineni
  --$ CR48260 - Modified to control the commit happening in the sub ordinate procedures
  --$
  --$ Revision 1.22  2017/12/05 17:22:54  sgangineni
  --$ CR48260 - changes the port request type from 'ADDRESERVE' to 'ADD_TO_RESERVE'
  --$
  --$ Revision 1.21  2017/12/02 21:14:22  sgangineni
  --$ CR48260 - additional validations in validate_order and modified submit_order
  --$
  --$ Revision 1.20  2017/11/30 17:36:36  sgangineni
  --$ CR48260 - Added ESN  validation in validate_order prc
  --$
  --$ Revision 1.19  2017/11/28 23:03:45  sgangineni
  --$ CR48260 - Changed the PORT request type to ADDRESERVE
  --$
  --$ Revision 1.18  2017/11/28 23:00:00  sgangineni
  --$ CR48260 - added new attributes call_trans_objid and pin_servide_days in cancel_order
  --$  procedure
  --$
  --$ Revision 1.17  2017/11/28 22:50:26  sgangineni
  --$ CR48260 - Modified as per code review comments
  --$
  --$ Revision 1.16  2017/11/06 19:18:42  sgangineni
  --$ CR48260 - Modified cancel_order procedure to add additional logic
  --$
  --$ Revision 1.15  2017/11/01 20:12:15  sgangineni
  --$ CR48260 - Modified as per code review comments
  --$
  --$ Revision 1.13  2017/10/12 20:23:52  schatterjee
  --$ Modify the DB link for SITZ deployment only
  --$
  --$ Revision 1.12  2017/10/12 16:31:06  sgangineni
  --$ CR48260 - Added logic in cancel_order procedure
  --$
  --$ Revision 1.11  2017/10/09 21:49:11  nsurapaneni
  --$ Added attributes web user objid , esn status , account type , queue cards and pin part class
  --$
  --$ Revision 1.10  2017/10/04 19:20:48  sraman
  --$ made changes to validate order
  --$
  --$ Revision 1.8  2017/09/28 17:42:27  sraman
  --$ updated error codes and error messages
  --$
  --$ Revision 1.7  2017/09/28 16:46:31  nsurapaneni
  --$ Error codes and Erorr messages Fix
  --$
  --$ Revision 1.5  2017/09/25 20:19:00  sraman
  --$ Added new procedures
  --$
  --$ Revision 1.4  2017/09/20 14:54:07  vnainar
  --$ CR48260  removed  get_app_part_num and get_billing_part_num
  --$
  --$ Revision 1.3  2017/09/19 19:18:17  sraman
  --$ Modified Validate Order Proc
  --$
  --$ Revision 1.1  2017/09/19 18:01:51  sgangineni
  --$ CR48260 (SM MLD) - RTR_MULTI_TRANS_PKG body initial version
  --$
  --$
  * Description: This package includes the below procedures and functions
  *                 GET_BILLING_PART_NUM
  *                 VALIDATE_ORDER
  *                 SUBMIT_ORDER
  *                 UPDATE_ORDER
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
-- Procedure to insert records into x_quote_service_log table
PROCEDURE merge_rtr_trans_log (    io_rtr_trans_log_objid   IN OUT NUMBER                               ,
                                   i_Step                        IN    VARCHAR2             DEFAULT NULL,
                                   i_rtr_vendor_name             IN    VARCHAR2             DEFAULT NULL,
                                   i_rtr_remote_trans_id         IN    VARCHAR2             DEFAULT NULL,
                                   i_rtr_merch_store_name        IN    VARCHAR2             DEFAULT NULL,
                                   i_rtr_request                 IN sa.rtr_trans_header_tab DEFAULT NULL,
                                   i_rtr_response                IN sa.rtr_trans_header_tab DEFAULT NULL,
                                   i_error_number                IN    NUMBER               DEFAULT NULL,
                                   i_error_message               IN    VARCHAR2             DEFAULT NULL,
                                   o_response                   OUT   VARCHAR2
				   )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF io_rtr_trans_log_objid IS NULL THEN
    SELECT sa.seq_rtr_trans_log.NEXTVAL
    INTO   io_rtr_trans_log_objid
    FROM   DUAL;
  END IF;

    -- Inserting or updating x_rtr_trans_log table
    MERGE
    INTO   sa.x_rtr_trans_log rtl
    USING  dual
    ON     ( rtl.objid = io_rtr_trans_log_objid)
    WHEN MATCHED THEN
         UPDATE
         SET Step                        = NVL(i_Step                           ,Step                          ),
             rtr_vendor_name             = NVL(i_rtr_vendor_name                ,rtr_vendor_name               ),
             rtr_remote_trans_id         = NVL(i_rtr_remote_trans_id            ,rtr_remote_trans_id           ),
             rtr_merch_store_name        = NVL(i_rtr_merch_store_name           ,rtr_merch_store_name          ),
             rtr_request                 = NVL(i_rtr_request                    ,rtr_request                   ),
             rtr_response                = NVL(i_rtr_response                   ,rtr_response                  ),
             error_number                = NVL(i_error_number                   ,error_number                  ),
             error_message               = NVL(i_error_message                  ,error_message                 ),
             update_timestamp            = SYSDATE
    WHEN NOT MATCHED THEN
         INSERT (objid                   ,
                 Step                    ,
                 rtr_vendor_name         ,
                 rtr_remote_trans_id     ,
                 rtr_merch_store_name    ,
                 rtr_request             ,
                 rtr_response            ,
                 error_number            ,
                 error_message           ,
                 insert_timestamp        ,
                 update_timestamp
                 )
         VALUES(io_rtr_trans_log_objid    ,
                i_Step                    ,
                i_rtr_vendor_name         ,
                i_rtr_remote_trans_id     ,
                i_rtr_merch_store_name    ,
                i_rtr_request             ,
                i_rtr_response            ,
                i_error_number            ,
                i_error_message           ,
                SYSDATE                   ,
                SYSDATE
              );
  COMMIT;
  o_response := 'SUCCESS';
 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     o_response := 'ERROR INSERTING INTO RTR_TRANS LOG: '||SQLERRM;
     RETURN;
END merge_rtr_trans_log;


PROCEDURE validate_order ( io_rtr_header_type    IN OUT rtr_trans_header_type,
                           o_error_code          OUT    VARCHAR2 ,
                           o_error_message       OUT    VARCHAR2 )
AS
  CURSOR dealer_curs ( p_rtr_merchant_id IN VARCHAR2 )
  IS
    SELECT s.site_id,
           ib.objid ib_objid
    FROM   sa.table_inv_bin ib,
           sa.table_site S,
           sa.x_partner_id pi
    WHERE  1=1
    AND    ib.bin_name     = s.site_id
    AND    s.site_id       = pi.x_site_id
    AND    pi.x_status     = 'Active'
    AND    pi.x_partner_id = p_rtr_merchant_id;

  dealer_rec dealer_curs%rowtype;

  CURSOR check_trans_curs ( p_rtr_merchant_id IN VARCHAR2, p_rtr_remote_trans_id IN VARCHAR2 )
  IS
    SELECT *
    FROM   sa.x_rtr_trans_header
    WHERE  1=1
    AND    rtr_vendor_name     = p_rtr_merchant_id
    AND    rtr_remote_trans_id = p_rtr_remote_trans_id;

  check_trans_rec check_trans_curs%rowtype;

  CURSOR esn_details_from_esn ( p_esn IN VARCHAR2 )
  IS
    SELECT pi_esn.part_serial_no esn,
           pi_esn.objid pi_esn_objid,
           pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
           ib.bin_name site_id,
           pi_esn.x_part_inst_status,
           pi_esn.x_iccid,
           2 col1
    FROM   table_part_inst pi_esn,
           table_inv_bin ib
    WHERE  1=1
    AND    pi_esn.part_serial_no = p_esn
    AND    ib.objid = pi_esn.part_inst2inv_bin;

  CURSOR esn_details_from_min ( p_min IN VARCHAR2 )
  IS
    SELECT pi_esn.part_serial_no esn,
           pi_esn.objid pi_esn_objid,
           pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
           ib.bin_name site_id,
           pi_esn.x_part_inst_status,
           pi_esn.x_iccid,
           2 col1
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn,
           table_inv_bin ib
    WHERE  1=1
    AND    pi_min.part_serial_no = p_min
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst
    AND    ib.objid = pi_esn.part_inst2inv_bin
    UNION
    SELECT pi_esn.part_serial_no esn,
           pi_esn.objid pi_esn_objid,
           pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
           ib.bin_name site_id,
           pi_esn.x_part_inst_status,
           pi_esn.x_iccid,
           1 col1
    FROM   table_site_part sp,
           table_part_inst pi_esn,
           table_inv_bin ib
    WHERE  sp.x_min = p_min
    AND    sp.part_status IN ('CarrierPending', 'Active')
    AND    pi_esn.part_serial_no = sp.x_service_id
    AND    pi_esn.x_domain = 'PHONES'
    AND    ib.objid = pi_esn.part_inst2inv_bin
    UNION
    SELECT /*+  ORDERED  INDEX(pi_min, IND_PART_INST_PSERIAL_U11) INDEX(pi_esn, IND_PART_INST_PSERIAL_U11) */
           pi_esn.part_serial_no esn,
           pi_esn.objid pi_esn_objid,
           pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
           ib.bin_name site_id,
           pi_esn.x_part_inst_status,
           pi_esn.x_iccid,
           3 col1
    FROM   table_site_part sp,
           table_part_inst pi_min,
           table_part_inst pi_esn,
           table_inv_bin ib
    WHERE  1=1
    AND    sp.x_min = p_min
    AND    sp.part_status||'' = 'Inactive'
    AND    pi_min.part_serial_no = sp.x_min
    AND    pi_min.x_part_inst_status||'' IN ('37','39')
    AND    pi_esn.part_serial_no = sp.x_service_id
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst
    AND    pi_esn.x_part_inst_status||'' IN ('54')
    AND    ib.objid = pi_esn.part_inst2inv_bin
    ORDER BY col1 ASC;

  esn_rec esn_details_from_min%rowtype;

  CURSOR c_pi ( i_sim IN VARCHAR2 )
  IS
    SELECT pi.part_serial_no esn
    FROM   table_part_inst pi
    WHERE  pi.x_iccid = i_sim
    AND    ROWNUM = 1;

  c_pi_rec c_pi%ROWTYPE;
  CURSOR pin_part_num_curs(c_pin_part_num IN VARCHAR2) IS
    SELECT m.objid mod_level_objid,
           bo.org_id,
           pn.x_upc,
           pn.part_number
      FROM table_part_num pn,
           table_mod_level m,
           table_bus_org bo
     WHERE 1=1
       AND pn.part_number = c_pin_part_num
       AND m.part_info2part_num = pn.objid
       AND bo.objid = pn.part_num2bus_org;

  pin_part_num_rec pin_part_num_curs%rowtype;

  cst                     sa.customer_type := sa.customer_type();
  l_rtr_header_type       sa.rtr_trans_header_type := io_rtr_header_type;
  l_part_num_list         sa.part_num_mapping_tab;
  l_part_number           VARCHAR2(200);
  l_part_status           VARCHAR2(200);
  l_plan_name             VARCHAR2(200);
  l_future_date           DATE;
  l_description           VARCHAR2(200);
  l_customer_price        VARCHAR2(200);
  c_addon_flag            VARCHAR2(1);
  l_rtr_trans_exists      VARCHAR2(1) := 'N';
  l_valid_account_cnt     NUMBER := 0;
  c_esn_min_status        VARCHAR2(10);
  c_is_exists             VARCHAR2(1);
  queued_cards customer_queued_card_tab := customer_queued_card_tab( );
  n_seq_rtr_trans_log     NUMBER :=  NULL;
  l_response              VARCHAR2(4000) := NULL;
  n_web_user_objid        NUMBER;
BEGIN
  --Invoke this procedure to log rtr transactions
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log    ,
                           i_Step                  => 'VALIDATE_ORDER'       ,
                           i_rtr_vendor_name       => io_rtr_header_type.rtr_vendor_name       ,
                           i_rtr_remote_trans_id   => io_rtr_header_type.rtr_remote_trans_id            ,
                           i_rtr_merch_store_name  => io_rtr_header_type.rtr_merch_store_name              ,
                           i_rtr_request           => sa.rtr_trans_header_tab(io_rtr_header_type)         ,
                           o_response              => l_response
                           );
  dbms_output.put_line ('l_response:'||l_response);

  IF io_rtr_header_type IS NULL
  THEN
    o_error_code     := '100'; --INPUT IS NULL
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  IF io_rtr_header_type.trans_detail IS NULL
  THEN
    o_error_code     := '101'; --RTR TRANS DETAIL INPUT IS NULL
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  ELSIF io_rtr_header_type.trans_detail.count = 0
  THEN
    o_error_code     := '108'; --INPUT RTR TRANS DETAIL DOES NOT HAVE DATA
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  IF io_rtr_header_type.brand IS NULL
  THEN
    o_error_code     := '133'; --INPUT BRAND CANNOT BE NULL
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  OPEN check_trans_curs (io_rtr_header_type.rtr_vendor_name, io_rtr_header_type.rtr_remote_trans_id );
  FETCH check_trans_curs INTO check_trans_rec;
  IF check_trans_curs%found
  THEN
    IF check_trans_rec.status IN ('COMPLETED', 'FAILED', 'INITIATED') THEN
      CLOSE check_trans_curs;
      o_error_code := '11'; --DUPLICATE TRANSACTION
      o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||io_rtr_header_type.rtr_remote_trans_id;
      merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                               i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                               i_error_number          => o_error_code                                      ,
                               i_error_message         => o_error_message                                   ,
                               o_response              => l_response
                               );
      RETURN;
    END IF;
  END IF;
  CLOSE check_trans_curs;

  OPEN dealer_curs (io_rtr_header_type.rtr_vendor_name);
  FETCH dealer_curs INTO dealer_rec;
  IF dealer_curs%notfound
  THEN
    CLOSE dealer_curs;
    o_error_code := '1';
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||io_rtr_header_type.rtr_vendor_name;
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;
  CLOSE dealer_curs;

  --Validation of Line level starts here
  FOR  i in 1..io_rtr_header_type.trans_detail.COUNT
  LOOP

    --initialize inside the loop
    cst                := sa.customer_type();
    l_part_number      := NULL;
    l_part_status      := NULL;
    l_plan_name        := NULL;
    l_future_date      := NULL;
    l_description      := NULL;
    l_customer_price   := NULL;
    c_addon_flag       := 'N';
    l_rtr_trans_exists := 'N';

    IF NVL(UPPER(io_rtr_header_type.trans_detail(i).order_line_action_type),'X') NOT IN('ACTIVATION','REACTIVATION','ADD_TO_RESERVE','RENEW','REDEMPTION')
    THEN
      io_rtr_header_type.trans_detail(i).error_code    := '140'; --'INVALID TRNSACTION TYPE',
      io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
      CONTINUE;
    END IF;

    IF io_rtr_header_type.trans_detail(i).esn IS NULL  AND
       io_rtr_header_type.trans_detail(i).min IS NULL
    THEN
      io_rtr_header_type.trans_detail(i).error_code    := '102'; --BOTH ESN AND MIN CAN NOT BE NULL
      io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
      CONTINUE;
    END IF;

    --Get ESN and MIN
    IF io_rtr_header_type.trans_detail(i).esn IS NULL
    THEN
      --Check if the given MIN is valid
      BEGIN
        SELECT x_part_inst_status
        INTO   c_esn_min_status
        FROM   table_part_inst
        WHERE  part_serial_no = io_rtr_header_type.trans_detail(i).min
        AND    x_domain= 'LINES';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          io_rtr_header_type.trans_detail(i).error_code    := '127'; --'GIVEN MIN IS NOT VALID'
          io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
          CONTINUE;
      END;

      IF NVL(c_esn_min_status, '00') = '13' AND UPPER(io_rtr_header_type.trans_detail(i).order_line_action_type) IN('ACTIVATION','REACTIVATION')
      THEN
        io_rtr_header_type.trans_detail(i).error_code    := '128'; --'GIVEN MIN IS ALREADY ACTIVE'
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
     --For reactivation min should be in RESERVED or RESERVED USED status
     IF NVL(c_esn_min_status, '00') NOT IN ('37','39') AND UPPER(io_rtr_header_type.trans_detail(i).order_line_action_type) IN('REACTIVATION')
      THEN
        io_rtr_header_type.trans_detail(i).error_code    := '141'; --'LINE IS NOT AVAILABLE FOR REACTIVATION'
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
      -- Incident_1784412 C95008 Changed to use util_pkg. Simple Mobile Dealers are receiving a i??device is already activei?? error message upon activation in RTR/API.
      cst.esn := sa.util_pkg.get_esn_by_min ( i_min => io_rtr_header_type.trans_detail(i).min ) ;
      IF cst.esn IS NULL AND
         io_rtr_header_type.trans_detail(i).sim IS NOT NULL
      THEN
        OPEN c_pi (io_rtr_header_type.trans_detail(i).sim);
        FETCH c_pi INTO  c_pi_rec;
        CLOSE c_pi;
        cst.esn := c_pi_rec.esn;
      END IF;
      io_rtr_header_type.trans_detail(i).esn := cst.esn;
      IF cst.esn IS NULL THEN
        io_rtr_header_type.trans_detail(i).error_code    := '139'; --'GIVEN MIN OR SIM DOES NOT HAVE A DEVICE ASSOCIATED WITH IT'
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
    ELSE--io_rtr_header_type.trans_detail(i).esn IS NULL
      cst.esn := io_rtr_header_type.trans_detail(i).esn;
    END IF;

    IF io_rtr_header_type.trans_detail(i).min IS NULL
    THEN
      --Check if the given ESN is valid
      BEGIN
        SELECT pi.x_part_inst_status,pn.x_technology
        INTO   c_esn_min_status, cst.technology
        FROM   table_part_inst pi,
               table_mod_level ml,
               table_part_num pn
        WHERE  pi.part_serial_no = io_rtr_header_type.trans_detail(i).esn
         AND   pi.x_domain= 'PHONES'
         AND   ml.objid =pi.n_part_inst2part_mod
         AND   pn.objid =ml.part_info2part_num;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          io_rtr_header_type.trans_detail(i).error_code    := '125'; --'GIVEN ESN IS NOT VALID'
          io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
          CONTINUE;
      END;

      -- Incident_1784412 C95008 Changed to use util_pkg. Simple Mobile Dealers are receiving a i??device is already activei?? error message upon activation in RTR/API.
      cst.min :=   sa.util_pkg.get_min_by_esn ( i_esn => io_rtr_header_type.trans_detail(i).esn );
      io_rtr_header_type.trans_detail(i).min := cst.min;
    ELSE
      cst.min := io_rtr_header_type.trans_detail(i).min;
    END IF;
    cst.bus_org_id := UPPER(sa.customer_info.get_bus_org_id (i_esn => cst.esn) );
    IF UPPER(io_rtr_header_type.brand) <> cst.bus_org_id
    THEN
      io_rtr_header_type.trans_detail(i).error_code    := '132'; --'ESN/MIN DOES NOT BELONG TO GIVEN BRAND '
      io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH')||io_rtr_header_type.brand;
      CONTINUE;
    END IF;

    IF    io_rtr_header_type.trans_detail(i).red_code IS NOT NULL
       OR io_rtr_header_type.trans_detail(i).serial_num IS NOT NULL
    THEN
      --Check if given PIN is valid
      BEGIN
        SELECT 'Y'
        INTO   c_is_exists
        FROM   table_x_cc_red_inv
        WHERE  (X_RED_CARD_NUMBER = io_rtr_header_type.trans_detail(i).red_code OR x_smp = io_rtr_header_type.trans_detail(i).serial_num)
        AND    x_domain = 'REDEMPTION CARDS';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          io_rtr_header_type.trans_detail(i).error_code    := '130'; --'GIVEN PIN IS NOT VALID'
          io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
          CONTINUE;
      END;
    END IF;
--
    -- IF SOA does not send the part num, fetch the APP part number based on part_class
    IF io_rtr_header_type.trans_detail(i).part_num_parent IS NULL and io_rtr_header_type.trans_detail(i).pin_part_class IS NOT NULL
    THEN
       l_part_num_list := sa.part_num_mapping_tab
                           (
                              sa.part_num_mapping_type
                                   (
                                           NULL,                                              --APP_PART_NUMBER
                                           NULL,                                              --APP_AR_PART_NUMBER
                                           io_rtr_header_type.trans_detail(i).pin_part_class, --PART_CLASS_NAME
                                           NULL,                                              --SERVICE_PLAN_OBJID
                                           NULL,                                              --SERVICE_PLAN_NAME
                                           NULL,                                              --SERVICE_PLAN_GROUP
                                           NULL                                               --SERVICE_PLAN_TYPE
                                     )
                             );

       sa.service_plan.get_billing_part_num(
                                            io_part_num_list => l_part_num_list,
                                            o_error_code     => io_rtr_header_type.trans_detail(i).error_code,
                                            o_error_message  => io_rtr_header_type.trans_detail(i).error_message
                                            );
      --Assign the part number
       io_rtr_header_type.trans_detail(i).part_num_parent := l_part_num_list(1).app_part_number;
	   l_rtr_header_type.trans_detail(i).part_num_parent  := l_part_num_list(1).app_part_number;
    END IF;
--
    --Check if the given PIN part number is valid
    OPEN pin_part_num_curs(io_rtr_header_type.trans_detail(i).part_num_parent);
      FETCH pin_part_num_curs INTO pin_part_num_rec;
      IF pin_part_num_curs%NOTFOUND
      THEN
        CLOSE pin_part_num_curs;
        io_rtr_header_type.trans_detail(i).error_code    := '144'; --'SERVICE PLAN PART NUMBER IS NOT VALID'
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
    CLOSE pin_part_num_curs;
    dbms_output.put_line('cst.esn                                            = '||cst.esn);
    dbms_output.put_line('cst.min                                            = '||cst.min);
    dbms_output.put_line('io_rtr_header_type.trans_detail(i).part_num_parent ='|| io_rtr_header_type.trans_detail(i).part_num_parent);
    --
    cst := cst.get_service_plan_attributes;
    -- Reset the ESN and MIN
    cst.esn := io_rtr_header_type.trans_detail(i).esn;
    cst.min := io_rtr_header_type.trans_detail(i).min;


    -- For Tracfone and NET10 PAY_GO, always ADD_NOW, otherwise ADD_RESERVE
    IF (cst.bus_org_id = 'TRACFONE' OR  (cst.bus_org_id = 'NET10' AND  cst.service_plan_group = 'PAY_GO' ))
    THEN
      io_rtr_header_type.trans_detail(i).card_action := 'ADD_NOW';
    ELSE
      io_rtr_header_type.trans_detail(i).card_action := 'ADD_RESERVE';
    END IF;

    dbms_output.put_line('cst.bus_org_id                                   = '||cst.bus_org_id);
    dbms_output.put_line('io_rtr_header_type.trans_detail(i).card_action   = '||io_rtr_header_type.trans_detail(i).card_action);
    dbms_output.put_line('service_plan_group                               = '||cst.service_plan_group );

    IF io_rtr_header_type.rtr_vendor_name != 'IN_COMM' AND cst.bus_org_id = 'STRAIGHT_TALK'
    THEN
      io_rtr_header_type.trans_detail(i).error_code    := '20';
      io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
      CONTINUE;
    END IF;

    IF cst.min IS NOT NULL
    THEN
      OPEN esn_details_from_min (cst.min);
      FETCH esn_details_from_min INTO esn_rec;
      IF esn_details_from_min%notfound
      THEN
        CLOSE esn_details_from_min;
        --
        io_rtr_header_type.trans_detail(i).error_code    := '2';
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' , io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
      CLOSE esn_details_from_min;
    ELSE
      OPEN esn_details_from_esn (cst.esn);
      FETCH esn_details_from_esn INTO esn_rec;
      IF esn_details_from_esn%notfound THEN
        CLOSE esn_details_from_esn;
        io_rtr_header_type.trans_detail(i).error_code    := '42';
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
      CLOSE esn_details_from_esn;
    END IF;

    io_rtr_header_type.trans_detail(i).sim := NVL(io_rtr_header_type.trans_detail(i).sim,esn_rec.x_iccid);
    IF io_rtr_header_type.trans_detail(i).sim  IS NULL THEN
       io_rtr_header_type.trans_detail(i).error_code    := '142'; --'SIM IS REQUIRED'
       io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
       CONTINUE;
    END IF;

    IF io_rtr_header_type.trans_detail(i).sim IS NOT NULL
    THEN
      --Check if the given SIM is valid
      BEGIN
        SELECT 'Y'
        INTO   c_is_exists
        FROM   table_x_sim_inv
        WHERE  X_SIM_SERIAL_NO = io_rtr_header_type.trans_detail(i).sim;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          io_rtr_header_type.trans_detail(i).error_code    := '129'; --'GIVEN SIM IS NOT VALID'
          io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
          CONTINUE;
      END;
    END IF;

    IF esn_rec.x_part_inst_status = '54'
    THEN
      BEGIN
        SELECT  'Y'
        INTO    l_rtr_trans_exists
        FROM    x_rtr_trans_header hdr,
                x_rtr_trans_detail dtl
        WHERE   NVL(dtl.esn,'x')    = cst.esn
        AND     hdr.trans_date > systimestamp  - 3 /1440
        AND     hdr.objid = dtl.rtr_trans_header_objid
        AND     ROWNUM=1;
      EXCEPTION
      WHEN OTHERS
      THEN
        l_rtr_trans_exists := 'N';
      END;
      --
      IF l_rtr_trans_exists = 'Y' THEN
        io_rtr_header_type.trans_detail(i).error_code    := '34';
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' , io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;

    END IF;

    --Additional Validations that SOA requested for SM Multi-line
    -- For 'ACTIVATION','ADD_TO_RESERVE','RENEW', ESN status should not be Active (52)
    IF UPPER(io_rtr_header_type.trans_detail(i).order_line_action_type) IN ('ACTIVATION','ADD_TO_RESERVE','RENEW', 'REACTIVATION')
    THEN
      IF esn_rec.x_part_inst_status = '52'
      THEN
        io_rtr_header_type.trans_detail(i).error_code    := '104'; --PHONE ALREADY ACTIVE
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
      IF sa.customer_info.get_sim_status ( i_sim_serial => io_rtr_header_type.trans_detail(i).sim ) = 'SIM ACTIVE'
      THEN
        io_rtr_header_type.trans_detail(i).error_code    := '143'; --SIM ALREADY ACTIVE
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;

    -- For 'ADD_TO_RESERVE', SIM status should be SIM NEW
      IF UPPER(io_rtr_header_type.trans_detail(i).order_line_action_type) IN ('ADD_TO_RESERVE','ACTIVATION') AND
         io_rtr_header_type.trans_detail(i).sim IS NOT NULL AND
         sa.customer_info.get_sim_status ( i_sim_serial => io_rtr_header_type.trans_detail(i).sim ) != 'SIM NEW'
      THEN
        io_rtr_header_type.trans_detail(i).error_code    := '105';
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' , io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      ELSIF UPPER(io_rtr_header_type.trans_detail(i).order_line_action_type) IN ('REACTIVATION') AND
         io_rtr_header_type.trans_detail(i).sim IS NOT NULL AND
         sa.customer_info.get_sim_status ( i_sim_serial => io_rtr_header_type.trans_detail(i).sim ) NOT IN ('SIM NEW' ,'SIM RESERVED')
      THEN
        io_rtr_header_type.trans_detail(i).error_code    := '105';
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' , io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
    END IF;

    --Check if the ESN/MIN belongs to the given web user
    n_web_user_objid := sa.customer_info.get_web_user_attributes (cst.esn, 'WEB_USER_ID');

    IF    n_web_user_objid IS NOT NULL
      AND NVL(io_rtr_header_type.trans_detail(i).web_user_objid, 11111) <> n_web_user_objid
    THEN
      io_rtr_header_type.trans_detail(i).error_code    := '152'; --GIVEN MIN/ESN DOES NOT BELONG TO THE GIVEN WEB USER ID
      io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' , io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
      CONTINUE;
    END IF;

    --DO NAP Check
    IF io_rtr_header_type.trans_detail(i).order_line_action_type <> 'REDEMPTION'
    THEN
      IF cst.technology = 'GSM' THEN
        sa.nap_service_pkg.get_list (io_rtr_header_type.trans_detail(i).zipcode,cst.esn, NULL, io_rtr_header_type.trans_detail(i).sim, NULL, NULL);
      ELSE
        sa.nap_service_pkg.get_list (io_rtr_header_type.trans_detail(i).zipcode,cst.esn, NULL, NULL, NULL, NULL);
      END IF;
      dbms_output.put_line('Inside Validation - nap_SERVICE_pkg.big_tab.count: '||nap_service_pkg.big_tab.COUNT);

      IF sa.nap_service_pkg.big_tab.COUNT < 1 THEN
        io_rtr_header_type.trans_detail(i).error_code    := '126'; --SIM IS NOT COMPATIBLE
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' , io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
    END IF;

    rtr_pkg.sub_info3(cst.min,
                      cst.esn,
                      io_rtr_header_type.trans_detail(i).zipcode,
                      io_rtr_header_type.trans_detail(i).part_num_parent,
                      l_part_status,
                      l_plan_name,
                      l_part_number,
                      l_description,
                      l_customer_price,
                      l_future_date,
                      cst.bus_org_id,
                      io_rtr_header_type.trans_detail(i).error_code,
                      io_rtr_header_type.trans_detail(i).error_message);

    dbms_output.put_line('cst.esn                                        : '||cst.esn);
    dbms_output.put_line('cst.min                                        : '||cst.min);
    dbms_output.put_line('io_rtr_header_type.trans_detail(i).error_code  : '||io_rtr_header_type.trans_detail(i).error_code);
    dbms_output.put_line('l_part_number                                  : '||l_part_number);
    dbms_output.put_line('l_plan_name                                    : '||l_plan_name);

    IF io_rtr_header_type.trans_detail(i).error_code = '8' AND io_rtr_header_type.trans_detail(i).order_line_action_type='REACTIVATION'
    THEN
      io_rtr_header_type.trans_detail(i).error_code := '0';
    ELSIF io_rtr_header_type.trans_detail(i).error_code != '0'
    THEN
      io_rtr_header_type.trans_detail(i).error_message:= sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
      CONTINUE;
    END IF;

    IF UPPER(l_plan_name) LIKE '%ADD%ON%'
    THEN
      -- CHECK IF THE BRAND IS CONFIGURED TO ALLOW ADD ON THROUGH RTR.
      -- IF ALLOWED, THEN DO NOT RAISE AN ERROR
      cst.sub_brand := sa.customer_info.get_sub_brand ( i_min => cst.min);
      --
      BEGIN
        SELECT addon_rtr_applicable_flag
        INTO   c_addon_flag
        FROM   table_bus_org
        WHERE  org_id =  NVL(cst.sub_brand,cst.bus_org_id);
      EXCEPTION
      WHEN OTHERS
      THEN
        c_addon_flag := 'N';
      END;

      IF c_addon_flag != 'Y' OR UPPER(io_rtr_header_type.trans_detail(i).order_line_action_type) IN ('ACTIVATION','REACTIVATION','ADD_TO_RESERVE')
      THEN
        io_rtr_header_type.trans_detail(i).error_code    := '4';
        io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;

    END IF;

    -- Retrieving  esn part status
    BEGIN
      SELECT ct.x_code_name
      INTO   io_rtr_header_type.trans_detail(i).esn_status
      FROM   table_part_inst pi,
             table_x_code_table ct
      WHERE  pi.part_serial_no   = cst.esn
      AND    pi.x_domain           = 'PHONES'
      AND    pi.x_part_inst_status = ct.x_code_number;
    EXCEPTION
    WHEN OTHERS
    THEN
      io_rtr_header_type.trans_detail(i).esn_status:=NULL;
    END;

    -- Retrieving web user objid
    cst := cst.get_web_user_attributes;
    io_rtr_header_type.trans_detail(i).web_user_objid := cst.web_user_objid;

    -- Retrieving part class
    IF io_rtr_header_type.trans_detail(i).pin_part_class IS NULL THEN
    io_rtr_header_type.trans_detail(i).pin_part_class := cst.get_part_class ( i_part_num => io_rtr_header_type.trans_detail(i).Part_Num_Parent );
    END IF;

    -- Retrieving queued cards
    cst.queued_cards := cst.get_esn_queued_cards ( i_esn =>cst.esn );

    IF cst.queued_cards IS NOT NULL
    THEN
      io_rtr_header_type.trans_detail(i).reserved_cards := cst.queued_cards.COUNT;
    ELSE
      io_rtr_header_type.trans_detail(i).reserved_cards := 0;
    END IF;

    --All validation passed for this line item
    l_rtr_header_type.trans_detail(i).status 	       := 'VALIDATED';
    io_rtr_header_type.trans_detail(i).status 	     := 'VALIDATED';
    io_rtr_header_type.trans_detail(i).error_code    := '0';
    io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');

  END LOOP;

 -- CHECK WHETHER ALL ORDER LINE ITEMS BELONG TO THE SAME ACCOUNT OR ALL SHOULD NOT BELONG TO ANY ACCOUNT.
 -- DUMMY ACCOUNT IS TO BE TREATED AS NOT BELONGING TO ANY ACCOUNT
 SELECT COUNT( DISTINCT( sa.customer_info.get_web_user_attributes ( i_esn => detail.esn, i_value => 'WEB_USER_ID' ) ) )
  INTO l_valid_account_cnt
  FROM TABLE(CAST(io_rtr_header_type.trans_detail AS rtr_trans_detail_tab)) detail
  WHERE sa.account_maintenance_pkg.get_account_status ( i_esn => detail.esn ) = 'VALID_ACCOUNT';

 IF l_valid_account_cnt > 1
  THEN
    o_error_code     := '106' ;
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
 END IF;

 --Check if one of the line items failed
  BEGIN
    SELECT  'Y'
    INTO    l_rtr_trans_exists
    FROM    TABLE(CAST(io_rtr_header_type.trans_detail AS rtr_trans_detail_tab)) detail
    WHERE   NVL(detail.error_code,'0') <> '0'
    AND     ROWNUM = 1;
  EXCEPTION
  WHEN OTHERS
  THEN
    l_rtr_trans_exists := 'N';
  END;

  IF l_rtr_trans_exists = 'Y'
  THEN
    o_error_code     := '107' ;
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  --Executing the function rtr_trans_header_type.ins to STORE the
  io_rtr_header_type.status := 'VALIDATED';
  io_rtr_header_type.objid := check_trans_rec.objid;
 -- io_rtr_header_type := io_rtr_header_type.ins;

  l_rtr_header_type.status := 'VALIDATED';
  l_rtr_header_type.objid := check_trans_rec.objid;
  l_rtr_header_type := l_rtr_header_type.ins;

  io_rtr_header_type.response := l_rtr_header_type.response;

  IF io_rtr_header_type.response <> 'SUCCESS'
  THEN
    o_error_code     := '135';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') || io_rtr_header_type.response;
  ELSE
    o_error_code     := '0';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
  END IF;
  --Invoke this procedure to log rtr transactions
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                           i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                           i_error_number          => o_error_code                                      ,
                           i_error_message         => o_error_message                                   ,
                           o_response              => l_response
                           );
  dbms_output.put_line ('l_response:'||l_response);

EXCEPTION
WHEN OTHERS
THEN
  o_error_code     := '99';
  o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||SUBSTR(sqlerrm,1,500);
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                           i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                           i_error_number          => o_error_code                                      ,
                           i_error_message         => o_error_message                                   ,
                           o_response              => l_response
                           );
END validate_order;

PROCEDURE  submit_order ( io_rtr_header_type    IN OUT  rtr_trans_header_type,
                          o_error_code          OUT     VARCHAR2,
                          o_error_message       OUT     VARCHAR2
                        )
IS
  CURSOR dealer_curs ( p_rtr_merchant_id IN VARCHAR2 )
  IS
    SELECT s.site_id,
           ib.objid ib_objid
    FROM   sa.table_inv_bin ib,
           sa.table_site S,
           sa.x_partner_id pi
    WHERE  1=1
    AND    ib.bin_name     = s.site_id
    AND    s.site_id       = pi.x_site_id
    AND    pi.x_status     = 'Active'
    AND    pi.x_partner_id = p_rtr_merchant_id;

  dealer_rec dealer_curs%rowtype;

  CURSOR cu_pin_dtl (c_red_code VARCHAR2)
  IS
    SELECT pi.objid pin_objid ,
      part_to_esn2part_inst ,
      x_ext ,
      bo.objid bo_objid ,
      pi.x_part_inst_status ,
      pn.x_redeem_units
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid    = pi.n_part_inst2part_mod
    AND pn.objid      = ML.PART_INFO2PART_NUM
    AND BO.OBJID      = PN.PART_NUM2BUS_ORG
    AND pi.x_red_code = c_red_code;
  rec_pin_dtl cu_pin_dtl%rowtype;

CURSOR CU_ESN_DTL (c_esn  VARCHAR2)
IS
  SELECT pi.objid esn_objid ,
    x_ext ,
    bo.objid bo_objid ,
    pi.x_part_inst_status ,
    bo.org_id brand_name ,
    BO.ORG_FLOW,
    pi.x_part_inst2site_part -- CR14786
  FROM table_part_inst pi ,
    table_mod_level ml ,
    table_part_num pn ,
    table_bus_org bo
  WHERE ml.objid        = pi.n_part_inst2part_mod
  AND pn.objid          = ml.part_info2part_num
  AND bo.objid          = pn.part_num2bus_org
  AND pi.part_serial_no = c_esn;
rec_esn_dtl cu_esn_dtl%ROWTYPE;

  CURSOR pin_part_num_curs(c_pin_part_num IN VARCHAR2) IS
    SELECT m.objid mod_level_objid,
           bo.org_id,
           pn.x_upc,
           pn.part_number,
           pn.x_redeem_days
      FROM table_part_num pn,
           table_mod_level m,
           table_bus_org bo
     WHERE 1=1
       AND pn.part_number = c_pin_part_num
       AND m.part_info2part_num = pn.objid
       AND bo.objid = pn.part_num2bus_org;

  pin_part_num_rec pin_part_num_curs%rowtype;

  rh rtr_trans_header_type;
  rth                       sa.rtr_trans_header_type := io_rtr_header_type;
  c_discount_code_tbl       sa.discount_code_tab := sa.discount_code_tab();
  l_part_num_list           sa.part_num_mapping_tab;
  n_part_num_service_days   NUMBER;
  c_err_code                NUMBER;
  c_err_msg                 VARCHAR2(4000);
  l_response                VARCHAR2(2000);
  n_seq_rtr_trans_log     NUMBER :=  NULL;
BEGIN
  --Invoke this procedure to log rtr transactions
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log    ,
                           i_Step                  => 'SUBMIT_ORDER'       ,
                           i_rtr_vendor_name       => io_rtr_header_type.rtr_vendor_name       ,
                           i_rtr_remote_trans_id   => io_rtr_header_type.rtr_remote_trans_id            ,
                           i_rtr_merch_store_name  => io_rtr_header_type.rtr_merch_store_name              ,
                           i_rtr_request           => sa.rtr_trans_header_tab(io_rtr_header_type)         ,
                           o_response              => l_response
                           );
  dbms_output.put_line ('l_response:'||l_response);
  --Validate inputs
  IF io_rtr_header_type IS NULL
  THEN
    o_error_code     := '100';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  IF io_rtr_header_type.trans_detail IS NULL
  THEN
    o_error_code     := '101';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  ELSIF io_rtr_header_type.trans_detail.count = 0
  THEN
    o_error_code     := '108';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;
  FOR i IN 1..io_rtr_header_type.trans_detail.COUNT
  LOOP
    IF io_rtr_header_type.trans_detail(i).part_num_parent IS NULL AND io_rtr_header_type.trans_detail(i).pin_part_class IS NOT NULL
    THEN
       l_part_num_list := sa.part_num_mapping_tab
                           (
                              sa.part_num_mapping_type
                                   (
                                           NULL,                                              --APP_PART_NUMBER
                                           NULL,                                              --APP_AR_PART_NUMBER
                                           io_rtr_header_type.trans_detail(i).pin_part_class, --PART_CLASS_NAME
                                           NULL,                                              --SERVICE_PLAN_OBJID
                                           NULL,                                              --SERVICE_PLAN_NAME
                                           NULL,                                              --SERVICE_PLAN_GROUP
                                           NULL                                               --SERVICE_PLAN_TYPE
                                     )
                             );

       sa.service_plan.get_billing_part_num(
                                            io_part_num_list => l_part_num_list,
                                            o_error_code     => io_rtr_header_type.trans_detail(i).error_code,
                                            o_error_message  => io_rtr_header_type.trans_detail(i).error_message
                                            );
      --Assign the part number
      io_rtr_header_type.trans_detail(i).part_num_parent := l_part_num_list(1).app_part_number;
      rth.trans_detail(i).part_num_parent := l_part_num_list(1).app_part_number;
    END IF;
  END LOOP;

  --Retrieve the order header and details from database
  rh := rtr_trans_header_type(io_rtr_header_type.RTR_REMOTE_TRANS_ID,io_rtr_header_type.RTR_VENDOR_NAME);

  IF rh.response <> 'SUCCESS'
  THEN
      o_error_code     := '146'; --GIVEN ORDER DOES NOT EXIST
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH'); --rh.response;
      merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                               i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                               i_error_number          => o_error_code                                      ,
                               i_error_message         => o_error_message                                   ,
                               o_response              => l_response
                               );
        RETURN;
  ELSIF rh.status in ('COMPLETED','FAILED')  then
      o_error_code     := '145'; -- GIVEN ORDER EXISTS WITH STATUS ||rh.status
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
      --Invoke this procedure to log rtr transactions
      merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                               i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                               i_error_number          => o_error_code                                      ,
                               i_error_message         => o_error_message                                   ,
                               o_response              => l_response
                               );
        RETURN;
  ELSIF rh.status = 'VALIDATED' then
      --if io_rtr_header_type <> rh then
      l_response  := io_rtr_header_type.compare (i_rtr_trans_header_type => rh);
      if l_response <> 'SUCCESS'
      then
          o_error_code     := '147'; -- ORDER DATA DOES NOT MATCH WITH THE PREVIOUS VALIDATED DATA
          o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||' '||l_response;
          merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                                   i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                                   i_error_number          => o_error_code                                      ,
                                   i_error_message         => o_error_message                                   ,
                                   o_response              => l_response
                                   );
          RETURN;
      end if;
  ELSIF rh.status = 'INITIATED' THEN
    o_error_code     := '134'; -- GIVEN ORDER WAS ALREADY SUBMITTED AND IN PROGRESS
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||' '||l_response;
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  OPEN dealer_curs (io_rtr_header_type.rtr_vendor_name);
  FETCH dealer_curs INTO dealer_rec;
  IF dealer_curs%notfound
  THEN
    CLOSE dealer_curs;
    o_error_code := '1';
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||io_rtr_header_type.rtr_vendor_name;
    --Invoke this procedure to log rtr transactions
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;
  CLOSE dealer_curs;


  FOR i IN 1..rth.trans_detail.COUNT
  LOOP
    rth.trans_detail(i).site_id := dealer_rec.site_id;

    IF rth.trans_detail(i).min IS NULL AND rth.trans_detail(i).esn IS NULL
    THEN
      rth.trans_detail(i).error_code    := '102';
      rth.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,rth.trans_detail(i).error_code ,'ENGLISH');
      CONTINUE;
    ELSIF rth.trans_detail(i).min IS NULL
    THEN
      -- Incident_1784412 C95008 Changed to use util_pkg. Simple Mobile Dealers are receiving a i??device is already activei?? error message upon activation in RTR/API.
      rth.trans_detail(i).min := sa.util_pkg.get_min_by_esn (rth.trans_detail(i).esn);
    ELSIF rth.trans_detail(i).esn IS NULL
    THEN
      -- Incident_1784412 C95008 Changed to use util_pkg. Simple Mobile Dealers are receiving a i??device is already activei?? error message upon activation in RTR/API.
      rth.trans_detail(i).esn := sa.util_pkg.get_esn_by_min (rth.trans_detail(i).min);
    END IF;
  END LOOP;

  --Executing the function rtr_trans_header_type.ins to submit the order
  rth.objid := rh.objid;

  io_rtr_header_type := rth.ins;

  IF io_rtr_header_type.response <> 'SUCCESS'
  THEN
    o_error_code     := '123';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') || rth.response;
  ELSE
    o_error_code     := '0';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
  END IF;
  --Invoke this procedure to log rtr transactions
   merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                            i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                            i_error_number          => o_error_code                                      ,
                            i_error_message         => o_error_message                                   ,
                            o_response              => l_response
                            );
  dbms_output.put_line ('l_response:'||l_response);
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    o_error_code     := '99';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||SUBSTR(sqlerrm,1,500);
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
END submit_order;

PROCEDURE  update_order ( io_rtr_header_type    IN OUT  rtr_trans_header_type,
                          o_error_code          OUT     VARCHAR2,
                          o_error_message       OUT     VARCHAR2
                        )
IS
  l_response              VARCHAR2(2000);
  rh                      rtr_trans_header_type;
  l_detail_cnt            NUMBER := 0;
  l_success_dtl_cnt       NUMBER := 0;
  n_seq_rtr_trans_log     NUMBER :=  NULL;
BEGIN
  --Invoke this procedure to log rtr transactions
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log    ,
                           i_Step                  => 'UPDATE_ORDER'       ,
                           i_rtr_vendor_name       => io_rtr_header_type.rtr_vendor_name       ,
                           i_rtr_remote_trans_id   => io_rtr_header_type.rtr_remote_trans_id            ,
                           i_rtr_merch_store_name  => io_rtr_header_type.rtr_merch_store_name              ,
                           i_rtr_request           => sa.rtr_trans_header_tab(io_rtr_header_type)         ,
                           o_response              => l_response
                           );
  dbms_output.put_line ('l_response:'||l_response);

  --Validate inputs
  IF io_rtr_header_type IS NULL
  THEN
    o_error_code     := '100';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  IF io_rtr_header_type.trans_detail IS NULL
  THEN
    o_error_code     := '101';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  ELSIF io_rtr_header_type.trans_detail.count = 0
  THEN
    o_error_code     := '108';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

  --Retrieve the order header and details from database
  rh := rtr_trans_header_type(io_rtr_header_type.RTR_REMOTE_TRANS_ID, io_rtr_header_type.RTR_VENDOR_NAME);

  IF rh.response <> 'SUCCESS'
  THEN
      o_error_code     := '146'; -- GIVEN ORDER DOES NOT EXIST
      o_error_message  := rh.response;
      merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                               i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                               i_error_number          => o_error_code                                      ,
                               i_error_message         => o_error_message                                   ,
                               o_response              => l_response
                               );
      RETURN;
  -- ELSIF rh.status in ('COMPLETED','FAILED')  then
      -- o_error_code     := '145'; -- GIVEN ORDER EXISTS WITH STATUS ||rh.status
      -- o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
      -- RETURN;
  -- ELSIF rh.status in('VALIDATED', 'INITIATED', 'SUBMITTED') then
      -- l_response  := io_rtr_header_type.compare (i_rtr_trans_header_type => rh);
      -- if l_response <> 'SUCCESS'
      -- then
          -- o_error_code     := '148'; -- ORDER DATA DOES NOT MATCH WITH THE PREVIOUS SUBMITTED DATA
          -- o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||' '||l_response;
          -- RETURN;
      -- end if;
  END IF;

  io_rtr_header_type.status                       := NULL;

  FOR i IN 1..io_rtr_header_type.trans_detail.COUNT
  LOOP
    --Assigning the detail part num to null to avoid updating the original part number
    io_rtr_header_type.trans_detail(i).part_num_parent := NULL;

    IF io_rtr_header_type.trans_detail(i).status = 'COMPLETED' THEN

       IF io_rtr_header_type.trans_detail(i).order_detail_id	IS NULL
       THEN
          io_rtr_header_type.trans_detail(i).error_code    := '137';
          io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
          io_rtr_header_type.trans_detail(i).status        := 'FAILED';
          --CONTINUE;
       END IF;

       IF io_rtr_header_type.trans_detail(i).order_line_action_type = 'CANCEL'
       THEN
         io_rtr_header_type.trans_detail(i).rtr_trans_type  := 'REMOVE';
         io_rtr_header_type.trans_detail(i).pin_status_code := '44'    ;
         io_rtr_header_type.status                          := 'COMPLETED';
       ELSE
         --Fetching PIN DETAILS based on process order detail ID
         BEGIN
          SELECT smp,
                 pin_status
            INTO io_rtr_header_type.trans_detail(i).serial_num,
                 io_rtr_header_type.trans_detail(i).pin_status_code
            FROM (SELECT part_serial_no SMP,
                         x_part_inst_status PIN_STATUS
                  FROM   table_part_inst
                  WHERE  x_red_code = io_rtr_header_type.trans_detail(i).red_code
                  AND    x_domain = 'REDEMPTION CARDS'
                  UNION
                  SELECT x_smp SMP,
                         DECODE(UPPER(x_result),'COMPLETED','41') PIN_STATUS
                  FROM   table_x_red_card
                  WHERE  x_red_code = io_rtr_header_type.trans_detail(i).red_code);
         EXCEPTION
          WHEN OTHERS THEN
            io_rtr_header_type.trans_detail(i).serial_num := NULL;
            io_rtr_header_type.trans_detail(i).pin_status_code := NULL;
         END;

         --Unable to fetch PIN details, mark as FAILED
         IF io_rtr_header_type.trans_detail(i).serial_num IS NULL OR io_rtr_header_type.trans_detail(i).pin_status_code IS NULL THEN
               io_rtr_header_type.trans_detail(i).error_code    := '138';
               io_rtr_header_type.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,io_rtr_header_type.trans_detail(i).error_code ,'ENGLISH');
               io_rtr_header_type.trans_detail(i).status        := 'FAILED';
               --CONTINUE;
         END IF;
       END IF; --io_rtr_header_type.trans_detail(i).order_line_action_type = 'CANCEL'

       io_rtr_header_type.trans_detail(i).extract_flag := 'N';
       io_rtr_header_type.response_code                := 'SUCCESS';
    END IF;

    IF io_rtr_header_type.trans_detail(i).status        = 'FAILED' THEN
         io_rtr_header_type.status                       := 'FAILED';
	ELSIF io_rtr_header_type.trans_detail(i).status        = 'COMPLETED' THEN
        SELECT COUNT(*),
          NVL(SUM(DECODE( status, 'COMPLETED',1,0) ),0)  INTO l_detail_cnt,l_success_dtl_cnt
        FROM sa.x_rtr_trans_detail
        WHERE RTR_TRANS_HEADER_OBJID = io_rtr_header_type.objid
        AND objid                   <> io_rtr_header_type.trans_detail(i).objid ;
	    IF l_detail_cnt = l_success_dtl_cnt THEN
           io_rtr_header_type.status                       := 'COMPLETED';
        END IF;
    END IF;

  END LOOP;

  if io_rtr_header_type.status = 'COMPLETED' and io_rtr_header_type.order_id is null then
      o_error_code     := '149'; -- ORDER ID IS MANDATORY FOR COMPLETED TRANSACTION
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
      merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                               i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                               i_error_number          => o_error_code                                      ,
                               i_error_message         => o_error_message                                   ,
                               o_response              => l_response
                               );
      RETURN;
  END IF;

  --Executing the function rtr_trans_header_type.upd to update the order details
  io_rtr_header_type := io_rtr_header_type.upd (i_rtr_trans_header_type => io_rtr_header_type);

  IF io_rtr_header_type.response <> 'SUCCESS'
  THEN
    o_error_code     := '124';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') || io_rtr_header_type.response;
  ELSE
   o_error_code     := '0';
   o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
  END IF;
  --Invoke this procedure to log rtr transactions
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                           i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                           i_error_number          => o_error_code                                      ,
                           i_error_message         => o_error_message                                   ,
                           o_response              => l_response
                           );
  dbms_output.put_line ('l_response:'||l_response);

  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    o_error_code     := '99';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||SQLERRM;
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
END update_order;

PROCEDURE  process_rtr_outbound ( o_error_code          OUT     VARCHAR2,
                                  o_error_message       OUT     VARCHAR2
                                )
AS
CURSOR stg_cur IS
  SELECT rtr.tf_red_code
    FROM  sa.tf_rtr_multi_trans_stg rtr
   WHERE rtr.tf_pin_status_code = '44';

  TYPE stg_cur_tab IS TABLE OF stg_cur%ROWTYPE;
  v_stg_cur_tab stg_cur_tab;

CURSOR detail_cur IS
 SELECT  detail.objid
  FROM   sa.x_rtr_trans_header header
         JOIN sa.x_rtr_trans_detail detail ON ( header.objid = detail.rtr_trans_header_objid )
  WHERE  detail.extract_flag IN ('P', 'N')
     AND detail.pin_status_code IN ('40','400','44','41')
     AND header.trans_date < sysdate - ( to_number(get_param_value ( i_param_name => 'RTR_MULTI_TRANS_PROCESS_FAIL_MINUTES_INTERVAL') ) / (24*60) )
     AND NVL(header.response_code,'NON') != 'SUCCESS'	;

  TYPE detail_cur_tab IS TABLE OF detail_cur%ROWTYPE;
  v_detail_cur_tab detail_cur_tab;

BEGIN
--Truncate staging table before loading data
 BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.tf_rtr_multi_trans_stg REUSE STORAGE';
 EXCEPTION
  WHEN OTHERS THEN
    o_error_code     := '109';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||SUBSTR(SQLERRM,1,500);
    RETURN;
 END;

--Loading data into the staging table
  INSERT /*+ APPEND*/
  INTO sa.tf_rtr_multi_trans_stg
  (
         rtr_trans_detail_objid       ,
         TF_PART_NUM_PARENT           ,
         TF_SERIAL_NUM                ,
         TF_RED_CODE                  ,
         RTR_VENDOR_NAME              ,
         RTR_MERCH_STORE_NUM          ,
         TF_PIN_STATUS_CODE           ,
         TF_TRANS_DATE                ,
         TF_EXTRACT_FLAG              ,
         TF_EXTRACT_DATE              ,
         TF_SITE_ID                   ,
         RTR_TRANS_TYPE               ,
         RTR_REMOTE_TRANS_ID          ,
         TF_SOURCESYSTEM              ,
         RTR_MERCH_REG_NUM            ,
         TF_UPC                       ,
         TF_MIN                       ,
         X_RESPONSE_CODE              ,
         RTR_MERCH_STORE_NAME         ,
         RTR_ESN                      ,
         X_FIN_CUST_ID                ,
         S_NAME                       ,
         CARD_PART_INST_STATUS        ,
         amount                       ,
         status                       ,
         discount_amount
  )
  SELECT detail.objid                             rtr_trans_detail_objid   ,
         detail.part_num_parent                   tf_part_num_parent       ,
         detail.serial_num                        tf_serial_num            ,
         detail.red_code                          tf_red_code              ,
         header.rtr_vendor_name                   rtr_vendor_name          ,
         header.rtr_merch_store_num               rtr_merch_store_num      ,
         detail.pin_status_code                   tf_pin_status_code       ,
         header.trans_date                        tf_trans_date            ,
         detail.extract_flag                      tf_extract_flag          ,
         detail.extract_date                      tf_extract_date          ,
         detail.site_id                           tf_site_id               ,
         detail.rtr_trans_type                    rtr_trans_type           ,
         header.rtr_remote_trans_id               rtr_remote_trans_id      ,
         header.sourcesystem                      tf_sourcesystem          ,
         header.rtr_merch_reg_num                 rtr_merch_reg_num        ,
         detail.upc                               tf_upc                   ,
         detail.min                               tf_min                   ,
         header.response_code                     x_response_code          ,
         header.rtr_merch_store_name              rtr_merch_store_name     ,
         detail.esn                               rtr_esn                  ,
         s.x_fin_cust_id                          x_fin_cust_id            ,
         s.s_name                                 s_name                   ,
         (SELECT pi.x_part_inst_status
          FROM table_part_inst pi
         WHERE pi.x_red_code = detail.red_code)   card_part_inst_status     ,
         detail.amount                            amount                    ,
         detail.status                            status                    ,
         SUM(discount.discount_amount)            discount_amount
  FROM   sa.x_rtr_trans_header header
         JOIN sa.x_rtr_trans_detail detail ON ( header.objid = detail.rtr_trans_header_objid )
         LEFT OUTER JOIN sa.x_rtr_trans_dtl_discount discount ON ( detail.objid = discount.rtr_trans_detail_objid )
         JOIN sa.table_site s   ON ( s.site_id = detail.site_id )
  WHERE  detail.extract_flag IN ('P', 'N')
     AND detail.pin_status_code IN ('40','400','44','41')
     AND header.trans_date < SYSDATE - ( to_number(get_param_value ( i_param_name => 'RTR_MULTI_TRANS_PROCESS_EXTRACT_MINUTES_INTERVAL') ) / (24*60) )--1/48
     AND NVL(header.response_code,'NON') = 'SUCCESS'
  GROUP BY
         detail.objid                             ,
         detail.part_num_parent                   ,
         detail.serial_num                        ,
         detail.red_code                          ,
         header.rtr_vendor_name                   ,
         header.rtr_merch_store_num               ,
         detail.pin_status_code                   ,
         header.trans_date                        ,
         detail.extract_flag                      ,
         detail.extract_date                      ,
         detail.site_id                           ,
         detail.rtr_trans_type                    ,
         header.rtr_remote_trans_id               ,
         header.sourcesystem                      ,
         header.rtr_merch_reg_num                 ,
         detail.upc                               ,
         detail.min                               ,
         header.response_code                     ,
         header.rtr_merch_store_name              ,
         detail.esn                               ,
         s.x_fin_cust_id                          ,
         s.s_name                                 ,
         detail.amount                            ,
         detail.status                            ;


  COMMIT;
  --update table_part_inst status to 44 for all the invalid PINs the RTR trans table
  OPEN stg_cur;
  LOOP
      FETCH stg_cur BULK COLLECT INTO v_stg_cur_tab limit 1000;

      EXIT WHEN v_stg_cur_tab.count = 0;

      FORALL i IN v_stg_cur_tab.first .. v_stg_cur_tab.last
        UPDATE /*+ INDEX(pi IND_PART_INST_REDCODE_N13) */
              table_part_inst pi
           SET pi.x_part_inst_status = '44',
               pi.status2x_Code_Table = ( SELECT objid
                                          FROM   sa.table_x_code_table
                                          WHERE  x_code_type = 'CS'
                                          AND    x_code_number = '44'
                                          AND    ROWNUM = 1
                                         )
         WHERE pi.x_red_code = v_stg_cur_tab(i).tf_red_code
           AND pi.x_part_inst_status != '44';
  END LOOP;
  CLOSE stg_cur;

  --update x_rtr_trans_detail extract_flag to 'F' for all the NON-SUCESS transactions
  OPEN detail_cur;
  LOOP
      FETCH detail_cur BULK COLLECT INTO v_detail_cur_tab limit 1000;

      EXIT WHEN v_detail_cur_tab.count = 0;

      FORALL i IN v_detail_cur_tab.first .. v_detail_cur_tab.last
        UPDATE sa.x_rtr_trans_detail rtr
           SET rtr.extract_flag = 'F'
         WHERE objid=v_detail_cur_tab(i).objid;
  END LOOP;
  CLOSE detail_cur;

  COMMIT;
  o_error_code     := '0';
  o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
EXCEPTION
  WHEN OTHERS THEN
    o_error_code     := '99';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||SUBSTR(SQLERRM,1,500);
END process_rtr_outbound;

PROCEDURE  sync_rtr_outbound ( o_error_code          OUT     VARCHAR2,
                               o_error_message       OUT     VARCHAR2
                             )
AS
CURSOR stg_cur IS
  SELECT *
    FROM sa.tf_rtr_multi_trans_stg
   WHERE tf_extract_flag = 'Y';

  TYPE stg_cur_tab IS TABLE OF stg_cur%ROWTYPE;
  v_stg_cur_tab stg_cur_tab;

BEGIN
--Truncate staging table before loading data
 BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.tf_rtr_multi_trans_stg REUSE STORAGE';
 EXCEPTION
  WHEN OTHERS THEN
    o_error_code     := '109';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||SUBSTR(SQLERRM,1,500);
    RETURN;
 END;

--Loading data into the staging table
 INSERT /*+ APPEND*/
  INTO sa.tf_rtr_multi_trans_stg
  (
      rtr_trans_detail_objid       ,
      TF_PART_NUM_PARENT           ,
      TF_SERIAL_NUM                ,
      TF_RED_CODE                  ,
      RTR_VENDOR_NAME              ,
      RTR_MERCH_STORE_NUM          ,
      TF_PIN_STATUS_CODE           ,
      TF_TRANS_DATE                ,
      TF_EXTRACT_FLAG              ,
      TF_EXTRACT_DATE              ,
      TF_SITE_ID                   ,
      RTR_TRANS_TYPE               ,
      RTR_REMOTE_TRANS_ID          ,
      TF_SOURCESYSTEM              ,
      RTR_MERCH_REG_NUM            ,
      TF_UPC                       ,
      TF_MIN                       ,
      X_RESPONSE_CODE              ,
      RTR_MERCH_STORE_NAME         ,
      RTR_ESN                      ,
      X_FIN_CUST_ID                ,
      S_NAME                       ,
      CARD_PART_INST_STATUS        ,
      amount                       ,
      status                       ,
      discount_amount              ,
      insert_timestamp	         ,
      update_timestamp
  )
 SELECT
      rtr_trans_detail_objid      ,
      TF_PART_NUM_PARENT          ,
      TF_SERIAL_NUM               ,
      TF_RED_CODE                 ,
      RTR_VENDOR_NAME             ,
      RTR_MERCH_STORE_NUM         ,
      TF_PIN_STATUS_CODE          ,
      TF_TRANS_DATE               ,
      TF_EXTRACT_FLAG             ,
      TF_EXTRACT_DATE             ,
      TF_SITE_ID                  ,
      RTR_TRANS_TYPE              ,
      RTR_REMOTE_TRANS_ID         ,
      TF_SOURCESYSTEM             ,
      RTR_MERCH_REG_NUM           ,
      TF_UPC                      ,
      TF_MIN                      ,
      X_RESPONSE_CODE             ,
      RTR_MERCH_STORE_NAME        ,
      RTR_ESN                     ,
      X_FIN_CUST_ID               ,
      S_NAME                      ,
      CARD_PART_INST_STATUS       ,
      amount                      ,
      status                      ,
      discount_amount             ,
      insert_timestamp	          ,
      update_timestamp
  FROM tf.tf_rtr_multi_trans_stg@OFSPRD;

  COMMIT;
  --update x_rtr_trans_detail extract flag back in CLFY
  OPEN stg_cur;
  LOOP
      FETCH stg_cur BULK COLLECT INTO v_stg_cur_tab limit 1000;

      EXIT WHEN v_stg_cur_tab.count = 0;

      FORALL i IN v_stg_cur_tab.first .. v_stg_cur_tab.last
        UPDATE sa.x_rtr_trans_detail
           SET extract_flag = v_stg_cur_tab(i).tf_extract_flag,
               extract_date = v_stg_cur_tab(i).tf_extract_date
         WHERE objid = v_stg_cur_tab(i).rtr_trans_detail_objid;

  END LOOP;
  CLOSE stg_cur;

  COMMIT;
  o_error_code     := '0';
  o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
EXCEPTION
  WHEN OTHERS THEN
    o_error_code     := '99';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||SUBSTR(SQLERRM,1,500);
END sync_rtr_outbound;
----------------------------------------------------------------------------------------------------
PROCEDURE cancel_order_unused ( io_rtr_header_type          IN OUT  rtr_trans_header_type,
                                i_rtr_transid_add_fund      IN      VARCHAR2,
                                o_error_code                OUT     VARCHAR2,
                                o_error_message             OUT     VARCHAR2
                              )
----------------------------------------------------------------------------------------------------
AS
  CURSOR trans_dtl_cur (c_header_objid  NUMBER)
  IS
    SELECT *
    FROM   x_rtr_trans_detail
    WHERE  rtr_trans_header_objid = c_header_objid;

  n_cancel_trans_header_objid     NUMBER;
  trans_dtl_rec                   trans_dtl_cur%ROWTYPE;
  dtl_trans_count                 NUMBER := 0;
  c_pin_status                    VARCHAR2(10);
  c_allowed_cancellation_time     VARCHAR2(10) := '10';
  n_ineligible_transactions       NUMBER := 0;
  rth                             rtr_trans_header_type := io_rtr_header_type;
  rtd                             rtr_trans_detail_tab := sa.rtr_trans_detail_tab();
BEGIN
  IF i_rtr_transid_add_fund IS NULL
  THEN
    o_error_code := '113';
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    RETURN;
  END IF;

  --Get the traansaction header
  BEGIN
    SELECT objid,
           NULL,
           order_id,
           rtr_vendor_name,
           rtr_merch_store_num,
           trans_date,
           sourcesystem,
           rtr_merch_reg_num,
           response_code,
           rtr_merch_store_name,
           status,
           tender_amount,
           estimated_amount,
           total_discount,
           insert_timestamp,
           update_timestamp
    INTO   n_cancel_trans_header_objid,
           rth.objid,
           rth.order_id,
           rth.rtr_vendor_name,
           rth.rtr_merch_store_num,
           rth.trans_date,
           rth.sourcesystem,
           rth.rtr_merch_reg_num,
           rth.response_code,
           rth.rtr_merch_store_name,
           rth.status,
           rth.tender_amount,
           rth.estimated_amount,
           rth.total_discount,
           rth.insert_timestamp,
           rth.update_timestamp
    FROM   x_rtr_trans_header
    WHERE  order_id = i_rtr_transid_add_fund;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_error_code := '114';
      o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||i_rtr_transid_add_fund;
      RETURN;
    WHEN OTHERS THEN
      o_error_code := '115';
      o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||i_rtr_transid_add_fund||'. '||SQLERRM;
      RETURN;
  END;

  IF rth.trans_detail IS NULL
  THEN
    --Get the transaction details
    FOR trans_dtl_rec IN trans_dtl_cur (n_cancel_trans_header_objid)
    LOOP
      dtl_trans_count := dtl_trans_count + 1;
      rtd.extend(1);

      rtd(dtl_trans_count) := rtr_trans_detail_type ( NULL,                                 --OBJID
                                                      trans_dtl_rec.order_detail_id,        --ORDER_DETAIL_ID
                                                      NULL,                                 --RTR_TRANS_HEADER_OBJID
                                                      trans_dtl_rec.part_num_parent,        --PART_NUM_PARENT
                                                      trans_dtl_rec.serial_num,             --SERIAL_NUM
                                                      trans_dtl_rec.red_code,               --RED_CODE
                                                      '44',                                 --PIN_STATUS_CODE
                                                      NULL,                                 --PIN_SERVICE_DAYS
                                                      'N',                                  --EXTRACT_FLAG
                                                      NULL,                                 --EXTRACT_DATE
                                                      trans_dtl_rec.site_id,                --SITE_ID
                                                      'REMOVE',                             --RTR_TRANS_TYPE
                                                      trans_dtl_rec.upc,                    --UPC
                                                      trans_dtl_rec.min,                    --MIN
                                                      trans_dtl_rec.esn,                    --ESN
                                                      trans_dtl_rec.amount,                 --AMOUNT
                                                      NULL,                                 --STATUS
                                                      'CANCEL',                             --ORDER_LINE_ACTION_TYPE
                                                      NULL,                                 --ZIPCODE
                                                      NULL,                                 --CARD_ACTION
                                                      trans_dtl_rec.sim,                    --SIM
                                                      NULL,                                 --ERROR_CODE
                                                      NULL,                                 --ERROR_MESSAGE
                                                      NULL,                                 --INSERT_TIMESTAMP
                                                      NULL,                                 --UPDATE_TIMESTAMP
                                                      NULL,                                 --TRANS_DTL_DISCOUNTS
                                                      NULL,                                 --ESN_STATUS
                                                      NULL,                                 --WEB_USER_OBJID
                                                      NULL,                                 --ACCOUNT_TYPE
                                                      NULL,                                 --PIN_PART_CLASS
                                                      NULL,                                 --RESERVED_CARDS
                                                      NULL                                  --CALL_TRANS_OBJID
                                                    );
    END LOOP;
  ELSE --rth.trans_detail IS NOT NULL
    FOR i IN 1..rth.trans_detail.count
    LOOP
      --Fetch detail trans details
      BEGIN
        SELECT NULL,
               order_detail_id,
               NULL,
               part_num_parent,
               serial_num,
               red_code,
               '44',
               'N',
               NULL,
               site_id,
               'REMOVE',
               upc,
               min,
               esn,
               amount,
               NULL,
               sim,
               NULL,
               NULL,
               'CANCEL'
        INTO   rth.trans_detail(i).objid,
               rth.trans_detail(i).order_detail_id,
               rth.trans_detail(i).rtr_trans_header_objid,
               rth.trans_detail(i).part_num_parent,
               rth.trans_detail(i).serial_num,
               rth.trans_detail(i).red_code,
               rth.trans_detail(i).pin_status_code,
               rth.trans_detail(i).extract_flag,
               rth.trans_detail(i).extract_date,
               rth.trans_detail(i).site_id,
               rth.trans_detail(i).rtr_trans_type,
               rth.trans_detail(i).upc,
               rth.trans_detail(i).min,
               rth.trans_detail(i).esn,
               rth.trans_detail(i).amount,
               rth.trans_detail(i).status,
               rth.trans_detail(i).sim,
               rth.trans_detail(i).insert_timestamp,
               rth.trans_detail(i).update_timestamp,
               rth.trans_detail(i).order_line_action_type
        FROM   x_rtr_trans_detail
        WHERE  objid = rth.trans_detail(i).objid;
      EXCEPTION
        WHEN OTHERS THEN
          o_error_code := '116';
          o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||i_rtr_transid_add_fund||'. '||SQLERRM;
          RETURN;
      END;
    END LOOP;

  END IF; --rth.trans_detail IS NULL

  --assign back the trans detials
  rth.trans_detail := rtd;

  --Validate transaction detials eligibility for cancellation
  FOR i IN 1..rth.trans_detail.COUNT
  LOOP
    IF rth.trans_detail(i).esn IS NULL
    THEN
      rth.trans_detail(i).error_code := '117';
      rth.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,rth.trans_detail(i).error_code ,'ENGLISH');
      n_ineligible_transactions := n_ineligible_transactions + 1;
    ELSIF rth.trans_detail(i).serial_num IS NULL AND rth.trans_detail(i).red_code IS NULL
    THEN
      rth.trans_detail(i).error_code := '118';
      rth.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,rth.trans_detail(i).error_code ,'ENGLISH');
      n_ineligible_transactions := n_ineligible_transactions + 1;
    END IF;

    --Check if the given PIN is still in QUEUED status
    BEGIN
      SELECT pi_card.x_part_inst_status
      INTO   c_pin_status
      FROM   table_part_inst pi_esn,
             table_part_inst pi_card
      WHERE  pi_esn.part_serial_no = rth.trans_detail(i).esn
      AND    pi_esn.x_domain = 'PHONES'
      AND    pi_esn.objid = pi_card.part_to_esn2part_inst
      AND    pi_card.x_domain = 'REDEMPTION CARDS'
      AND    (pi_card.part_serial_no = rth.trans_detail(i).serial_num OR pi_card.x_red_code = rth.trans_detail(i).red_code);

      IF c_pin_status = '400'
      THEN
        rth.trans_detail(i).status := 'INITIATED';
        rth.trans_detail(i).error_code := '0';
        rth.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,rth.trans_detail(i).error_code ,'ENGLISH');
        CONTINUE;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --Check if the given PIN was redeemed in past X min/hours
        BEGIN
          SELECT '0',
                 'PIN HAS BEEN REDEEMED ALREADY',
                 'INITIATED'
          INTO   rth.trans_detail(i).error_code,
                 rth.trans_detail(i).error_message,
                 rth.trans_detail(i).status
          FROM   table_x_red_card
          WHERE  (x_red_code = rth.trans_detail(i).red_code OR x_smp = rth.trans_detail(i).serial_num)
          AND    x_red_date >= (SYSDATE - ( to_number(get_param_value ( i_param_name => 'RTR_MULTI_TRANS_ALLOWED_CANCEL_MINUTES_INTERVAL') ) / (24*60) )  );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          rth.trans_detail(i).error_code := '119';
          rth.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,rth.trans_detail(i).error_code ,'ENGLISH');
          n_ineligible_transactions := n_ineligible_transactions + 1;
          CONTINUE;
        END;
      WHEN OTHERS THEN
        rth.trans_detail(i).error_code := '120';
        rth.trans_detail(i).error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,rth.trans_detail(i).error_code ,'ENGLISH')||SQLERRM;
        n_ineligible_transactions := n_ineligible_transactions + 1;
    END;
  END LOOP;

  IF n_ineligible_transactions > 0
  THEN
    o_error_code := '121';
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
  ELSE
    --Create cancel transactions
    rth.status := 'INITIATED';
    io_rtr_header_type := rth.ins;

    o_error_code := '0';
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_error_code    := '122';
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||SQLERRM;
END cancel_order_unused;

PROCEDURE cancel_order ( io_rtr_header_type          IN OUT  rtr_trans_header_type,
                         i_rtr_transid_add_fund      IN      VARCHAR2,
                         o_error_code                OUT     VARCHAR2,
                         o_error_message             OUT     VARCHAR2
                       ) is
rht rtr_trans_header_type;
pq                      number;
pq_cnt                  number := 0;
pins_queued             boolean := false;
l_response              VARCHAR2(2000);
c_is_cancel_initiated   VARCHAR2(1);
c_rtr_remote_trans_id   VARCHAR2(100);
n_cancel_line_cnt       NUMBER;
n_seq_rtr_trans_log     NUMBER :=  NULL;
n_activation_line_cnt   NUMBER:= 0; --CR49520
begin
  --Invoke this procedure to log rtr transactions
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log    ,
                           i_Step                  => 'CANCEL_ORDER'       ,
                           i_rtr_vendor_name       => io_rtr_header_type.rtr_vendor_name       ,
                           i_rtr_remote_trans_id   => io_rtr_header_type.rtr_remote_trans_id            ,
                           i_rtr_merch_store_name  => io_rtr_header_type.rtr_merch_store_name              ,
                           i_rtr_request           => sa.rtr_trans_header_tab(io_rtr_header_type)         ,
                           o_response              => l_response
                           );
  dbms_output.put_line ('l_response:'||l_response);

  IF i_rtr_transid_add_fund IS NULL
  THEN
    o_error_code := '113'; --ORDER ID TO BE CANCELLED IS NOT PASSED
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  END IF;

--Check if the cancel order was already initiated
BEGIN
  SELECT 'Y'
  INTO   c_is_cancel_initiated
  FROM   X_RTR_TRANS_HEADER
  WHERE  original_order_id = i_rtr_transid_add_fund
  AND    action = 'CANCEL'
  AND    status   ='INITIATED'  ;
EXCEPTION
  WHEN OTHERS THEN
    c_is_cancel_initiated := 'N';
END;

IF c_is_cancel_initiated = 'Y'
THEN
  o_error_code := '153'; --CANCELLATION WAS ALREADY INITIATED FOR GIVEN ORDER ID
  o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||i_rtr_transid_add_fund;
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                           i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                           i_error_number          => o_error_code                                      ,
                           i_error_message         => o_error_message                                   ,
                           o_response              => l_response
                           );
  RETURN;
END IF;

--Fetch the rtr_remote_trans_id
BEGIN
  SELECT rth.rtr_remote_trans_id,
         (select count(1) from x_process_order_detail where process_order_objid = po.objid AND order_status='CANCELLED'),
         (select count(1) from x_process_order_detail where process_order_objid = po.objid AND order_type='ACTIVATION') --CR49520
  INTO   c_rtr_remote_trans_id,
         n_cancel_line_cnt,
         n_activation_line_cnt --CR49520
  FROM   X_RTR_TRANS_HEADER rth, x_process_order po
  WHERE  rth.order_id = i_rtr_transid_add_fund
  AND    rth.rtr_vendor_name = io_rtr_header_type.rtr_vendor_name
  AND    rth.order_id = po.order_id
  AND    rth.status   ='COMPLETED';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    o_error_code := '114'; --CANNOT FIND GIVEN ORDER ID
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||i_rtr_transid_add_fund;
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
  WHEN OTHERS THEN
    o_error_code := '115'; --ERROR WHILE FETCHING TRANS HEADER OF GIVEN ORDER ID
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||i_rtr_transid_add_fund||'. '||SQLERRM;
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    RETURN;
END;

IF n_cancel_line_cnt > 0
THEN
    o_error_code := '151'; --GIVEN ORDER ID WAS ALREADY CANCELLED
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH')||i_rtr_transid_add_fund||'. '||SQLERRM;
--CR49520 changes start
ELSIF n_activation_line_cnt > 0
THEN
  o_error_code := '119'; --TRANSACTION IS NOT ELIGIBLE FOR CANCELLATION
  o_error_message := 'ORDER WITH ACTIVATION '||sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ;
ELSIF c_rtr_remote_trans_id = io_rtr_header_type.rtr_remote_trans_id
THEN
  o_error_code := '154'; --GIVEN REMOTE TRANSACTION ID FOR CANCELLATION ALREADY EXIST
  o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ;
END IF;

IF o_error_code IS NOT NULL
THEN
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                           i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                           i_error_number          => o_error_code                                      ,
                           i_error_message         => o_error_message                                   ,
                           o_response              => l_response
                           );
  RETURN;
END IF;
--CR49520 changes end

rht := rtr_trans_header_type(c_rtr_remote_trans_id, io_rtr_header_type.rtr_vendor_name);

for i in 1..rht.trans_detail.count
loop
  select count(*)
  into pq
  from sa.table_part_inst pi
  where x_red_code = rht.trans_detail(i).red_code;
pq_cnt  := pq_cnt+pq;
end loop;

if pq_cnt = rht.trans_detail.count then
   pins_queued := true;
end if;

if  (sysdate - rht.update_timestamp)*24*60  >
   to_number(get_param_value ('RTR_MULTI_TRANS_ALLOWED_CANCEL_MINUTES_INTERVAL'))
then
  if not pins_queued then
    o_error_code := '119'; --TRANSACTION IS NOT ELIGIBLE FOR CANCELLATION
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ;
    merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                             i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                             i_error_number          => o_error_code                                      ,
                             i_error_message         => o_error_message                                   ,
                             o_response              => l_response
                             );
    return;
  end if;
end if;

rht.objid := null;
rht.order_id := null;
rht.response_code := NULL;
rht.rtr_remote_trans_id := io_rtr_header_type.rtr_remote_trans_id;
rht.action := 'CANCEL';
rht.status := 'INITIATED';
rht.insert_timestamp := sysdate;
rht.update_timestamp := sysdate;


for i in 1..rht.trans_detail.count
loop
    rht.trans_detail(i).objid := null;
    rht.trans_detail(i).order_detail_id := null;
    rht.trans_detail(i).insert_timestamp := sysdate;
    rht.trans_detail(i).update_timestamp := sysdate;
    rht.trans_detail(i).order_line_action_type := 'CANCEL';
    rht.trans_detail(i).extract_flag := 'N';
    rht.trans_detail(i).extract_date := null;
    --rht.trans_detail(i).pin_status_code := '44';
    --Fetching PIN status_code
    BEGIN
     SELECT pin_status
       INTO rht.trans_detail(i).pin_status_code
       FROM (SELECT x_part_inst_status PIN_STATUS
             FROM   table_part_inst
             WHERE  x_red_code = rht.trans_detail(i).red_code
             AND    x_domain = 'REDEMPTION CARDS'
             UNION
             SELECT DECODE(UPPER(x_result),'COMPLETED','41') PIN_STATUS
             FROM   table_x_red_card
             WHERE  x_red_code = rht.trans_detail(i).red_code);
    EXCEPTION
     WHEN OTHERS THEN
       rht.trans_detail(i).pin_status_code := NULL;
    END;
    rht.trans_detail(i).rtr_trans_type := 'REMOVE';
    rht.trans_detail(i).status := 'INITIATED';

    FOR j in 1..rht.trans_detail(i).trans_dtl_discounts.count
    LOOP
      rht.trans_detail(i).trans_dtl_discounts(j).objid := null;
    END LOOP;
end loop;

-- Now header is located and all cancelable details verified
rht := rht.ins;
io_rtr_header_type := rht;

if io_rtr_header_type.response = 'SUCCESS'
THEN
    o_error_code := 0;
    --Update the original order id in the cancel transaction
    UPDATE sa.x_rtr_trans_header
    SET    original_order_id = i_rtr_transid_add_fund
    WHERE  objid = io_rtr_header_type.objid;
else
    o_error_code := 150;
    o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') || io_rtr_header_type.response;
end if;

--Invoke this procedure to log rtr transactions
 merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                          i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                          i_error_number          => o_error_code                                      ,
                          i_error_message         => o_error_message                                   ,
                          o_response              => l_response
                          );
dbms_output.put_line ('l_response:'||l_response);
EXCEPTION
WHEN OTHERS THEN
  o_error_code     := '99';
  o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||SUBSTR(sqlerrm,1,500);
  merge_rtr_trans_log (    io_rtr_trans_log_objid  => n_seq_rtr_trans_log                               ,
                           i_rtr_response          => sa.rtr_trans_header_tab(io_rtr_header_type)       ,
                           i_error_number          => o_error_code                                      ,
                           i_error_message         => o_error_message                                   ,
                           o_response              => l_response
                           );
end cancel_order;


PROCEDURE  get_order_status ( i_rtr_vendor_name        IN      VARCHAR2                  ,
                              io_esn                   IN OUT  VARCHAR2                  ,
                              io_min                   IN OUT  VARCHAR2                  ,
                              io_order_id              IN OUT  VARCHAR2                  ,
                              io_rtr_trans_type	       IN OUT  VARCHAR2                  ,
                              o_order_status           OUT     VARCHAR2                  ,
                              o_trans_date             OUT     DATE                      ,
                              o_error_code             OUT     VARCHAR2                  ,
                              o_error_message          OUT     VARCHAR2
                             ) IS

  CURSOR rtr_order_id
  IS
    SELECT
      CASE
        WHEN cancelled_count > 1           THEN 'CANCELLED'
        WHEN failed_count > 1              THEN 'FAILED'
        WHEN order_count = completed_count THEN 'COMPLETED'
        ELSE 'IN PROGRESS'
      END order_status,
    order_count       ,
    trans_date
    FROM
      (SELECT COUNT(*)                             order_count,
        SUM(DECODE(ORDER_STATUS,'FAILED',1,'SUBMISSION_FAILED',1,'CASE_NOT_GENERATED',1,0)) failed_count,
        SUM(DECODE(ORDER_STATUS,'COMPLETED',1,'COMPLETED_CRM',1,'COMPLETED_BRM',1,0))  completed_count,
        SUM(DECODE(ORDER_STATUS,'CANCELLED',1,0))  cancelled_count,
        MAX(header.trans_date)	                   trans_date
      FROM sa.x_rtr_trans_header header
      JOIN sa.x_process_order po           ON (header.order_id = po.order_id)
      JOIN sa.x_process_order_detail pod   ON (po.objid        = pod.process_order_objid)
      WHERE header.order_id        = io_order_id
        AND header.rtr_vendor_name = i_rtr_vendor_name
        AND pod.order_type	       = io_rtr_trans_type
      );
  rtr_order_id_rec rtr_order_id%ROWTYPE;

  CURSOR rtr_esn_min
  IS
    WITH detail AS
      (SELECT /*+ materialize */  *
      FROM sa.x_rtr_trans_detail detail
      WHERE detail.esn    = io_esn
         OR detail.min    = io_min
      )
    SELECT header.order_id,
      detail.esn,
      detail.min,
      detail.rtr_trans_type,
      CASE WHEN pod.order_status IN ('SUBMISSION_FAILED','CASE_NOT_GENERATED','FAILED') THEN 'FAILED'
           WHEN pod.order_status IN ('COMPLETED','COMPLETED_CRM','COMPLETED_BRM') THEN 'COMPLETED'
           ELSE 'IN PROGRESS'
      END order_status,
      header.trans_date
    FROM sa.x_rtr_trans_header header
    JOIN detail   ON ( header.objid  = detail.rtr_trans_header_objid )
    JOIN sa.x_process_order_detail pod   ON (detail.order_detail_id = pod.objid)
    WHERE 1                    = 1
    AND header.rtr_vendor_name = i_rtr_vendor_name
    AND detail.rtr_trans_type  = NVL(io_rtr_trans_type,detail.rtr_trans_type )
    AND header.order_id        = NVL(io_order_id , header.order_id)
    ORDER BY header.trans_date DESC;
  rtr_esn_min_rec rtr_esn_min%ROWTYPE;

  CURSOR rtr_port_esn_min
  IS
    WITH POD AS
      (SELECT /*+ materialize */  xpod.*
      FROM sa.x_process_order xpo
	  JOIN sa.x_process_order_detail xpod ON (xpo.objid  = xpod.process_order_objid)
      WHERE (xpod.esn     = io_esn
          OR xpod.min     = io_min
          OR xpo.order_id = io_order_id )
         AND xpod.order_type= io_rtr_trans_type
      )
    SELECT po.order_id,
      pod.esn,
      pod.min,
      pod.order_type,
      CASE WHEN pod.order_status IN ('FAILED','SUBMISSION_FAILED') THEN 'FAILED'
           WHEN pod.order_status IN ('CASE_GENERATED')	           THEN 'CASE_GENERATED'
           ELSE 'IN PROGRESS'
      END order_status ,
      pod.insert_timestamp
    FROM sa.x_process_order po
    JOIN pod   ON ( po.objid  = pod.process_order_objid )
    WHERE 1                    = 1
    AND EXISTS (SELECT 1 FROM sa.x_rtr_trans_header header
                  JOIN sa.x_rtr_trans_detail detail   ON ( header.objid  = detail.rtr_trans_header_objid )
                  WHERE header.rtr_vendor_name = i_rtr_vendor_name
                    AND detail.rtr_trans_type  = 'ADD_TO_RESERVE'
                    AND detail.esn             = pod.esn
                    AND detail.insert_timestamp <= pod.insert_timestamp
					)
    ORDER BY pod.insert_timestamp DESC;
  rtr_port_esn_min_rec rtr_port_esn_min%ROWTYPE;


BEGIN
 o_error_code := '0'; --SUCCESS
 o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');

 IF io_esn IS NULL AND io_min IS NULL AND  io_order_id IS NULL
  THEN
    o_error_code     := '100'; --INPUT IS NULL
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    RETURN;
 END IF;

 IF io_rtr_trans_type IS NULL
  THEN
    o_error_code     := '140'; --INVALID TRNSACTION TYPE
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    RETURN;
 END IF;

--If action is PORT then check if status of PORT process order.
--If iti??s CASE_GENERATED and no record of TAS, respond with IN PROGRESS.
--If iti??s FAILED/SUBMISSION_FAILED, respond with FAILED.And for any other status IN PROGRESS
--If iti??s CASE_GENERATED and TAS COMPLETEPORT record status is COMPLETED, respond with COMPLETED.
--Any Other status of COMPLETEPORT, respond with IN PROGRESS.
 IF io_rtr_trans_type = 'PORT' THEN
    --Checking status of PORT process order
    OPEN rtr_port_esn_min;
    FETCH rtr_port_esn_min INTO rtr_port_esn_min_rec;
    IF rtr_port_esn_min%NOTFOUND THEN
       o_error_code     := '114'                              ;  --ORDER NOT FOUND
       o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
       CLOSE rtr_port_esn_min;
       RETURN;
    END IF;
    CLOSE rtr_port_esn_min;
    io_esn                 := rtr_port_esn_min_rec.esn                ;
    io_min                 := rtr_port_esn_min_rec.min                ;
    io_order_id            := rtr_port_esn_min_rec.order_id           ;
    io_rtr_trans_type      := rtr_port_esn_min_rec.order_type         ;
    o_trans_date           := rtr_port_esn_min_rec.insert_timestamp   ;
    o_order_status         := rtr_port_esn_min_rec.order_status       ;
    IF o_order_status IN ('FAILED','IN PROGRESS') THEN
       RETURN;
    END IF;
    -- The port status is CASE_GENERATED
    SELECT
      CASE WHEN COUNT(*)>=1 THEN 'COMPLETED'  ELSE 'IN PROGRESS' END INTO o_order_status
    FROM x_process_order_detail
    WHERE order_type='COMPLETEPORT'
    AND esn         = io_esn
    AND order_status IN ('COMPLETED','COMPLETED_CRM','COMPLETED_BRM')
    AND insert_timestamp >= o_trans_date	  ;

    RETURN;
 END IF; --io_rtr_trans_type = 'PORT'

 --OTHER THAN PORT SCENARIO
 --Fetch order details based on ESN or MIN
 IF (io_esn IS NOT NULL OR  io_min IS NOT NULL)
 THEN
   OPEN rtr_esn_min;
   FETCH rtr_esn_min INTO rtr_esn_min_rec;
   IF rtr_esn_min%NOTFOUND THEN
      o_error_code     := '114'                              ;  --ORDER NOT FOUND
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
      CLOSE rtr_esn_min;
      RETURN;
   END IF;
   CLOSE rtr_esn_min;
   io_esn                 := rtr_esn_min_rec.esn                ;
   io_min                 := rtr_esn_min_rec.min                ;
   io_order_id            := rtr_esn_min_rec.order_id           ;
   io_rtr_trans_type      := rtr_esn_min_rec.rtr_trans_type     ;
   o_trans_date           := rtr_esn_min_rec.trans_date         ;
   o_order_status         := rtr_esn_min_rec.order_status       ;
   RETURN;
 END IF;

 --Fetch Order status based on order_id
 OPEN rtr_order_id;
 FETCH rtr_order_id INTO rtr_order_id_rec;
 IF rtr_order_id%FOUND AND rtr_order_id_rec.order_count <> 0 THEN
      o_order_status   := rtr_order_id_rec.order_status    ;
      o_trans_date     := rtr_order_id_rec.trans_date      ;
  ELSE
      o_error_code     := '114'                              ;  --CANNOT FIND GIVEN ORDER ID
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') || ': '|| io_order_id;
  END IF;
 CLOSE rtr_order_id;
 RETURN;

EXCEPTION
WHEN OTHERS THEN
  o_error_code     := '99';
  o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||SUBSTR(sqlerrm,1,500);
END get_order_status;

--CR49520 changes start - New overloaded procedure
PROCEDURE  get_order_status ( i_rtr_vendor_name        IN      VARCHAR2                  ,
                              io_esn                   IN OUT  VARCHAR2                  ,
                              io_min                   IN OUT  VARCHAR2                  ,
                              io_order_id              IN OUT  VARCHAR2                  ,
                              io_rtr_trans_type	       IN OUT  VARCHAR2                  ,
                              o_order_status           OUT     VARCHAR2                  ,
                              o_trans_date             OUT     DATE                      ,
                              o_error_code             OUT     VARCHAR2                  ,
                              o_error_message          OUT     VARCHAR2                  ,
                              o_ord_details            OUT     rtr_order_detail_tab
                             )
IS
  CURSOR rtr_order_id
  IS
    SELECT
      CASE
        WHEN cancelled_count > 1           THEN 'CANCELLED'
        WHEN failed_count > 1              THEN 'FAILED'
        WHEN order_count = completed_count THEN 'COMPLETED'
        ELSE 'IN PROGRESS'
      END order_status,
    order_count       ,
    trans_date
    FROM
      (SELECT COUNT(*)                             order_count,
        SUM(DECODE(ORDER_STATUS,'FAILED',1,'SUBMISSION_FAILED',1,'CASE_NOT_GENERATED',1,0)) failed_count,
        SUM(DECODE(ORDER_STATUS,'COMPLETED',1,'COMPLETED_CRM',1,'COMPLETED_BRM',1,0))  completed_count,
        SUM(DECODE(ORDER_STATUS,'CANCELLED',1,0))  cancelled_count,
        MAX(header.trans_date)	                   trans_date
      FROM sa.x_rtr_trans_header header
      JOIN sa.x_process_order po           ON (header.order_id = po.order_id)
      JOIN sa.x_process_order_detail pod   ON (po.objid        = pod.process_order_objid)
      WHERE header.order_id        = io_order_id
        AND header.rtr_vendor_name = i_rtr_vendor_name
        AND pod.order_type	       = io_rtr_trans_type
      );
  rtr_order_id_rec rtr_order_id%ROWTYPE;

  CURSOR rtr_esn_min
  IS
    WITH detail AS
      (SELECT /*+ materialize */  *
      FROM sa.x_rtr_trans_detail detail
      WHERE detail.esn    = io_esn
         OR detail.min    = io_min
      )
    SELECT header.order_id,
      detail.esn,
      detail.min,
      detail.rtr_trans_type,
      CASE WHEN pod.order_status IN ('SUBMISSION_FAILED','CASE_NOT_GENERATED','FAILED') THEN 'FAILED'
           WHEN pod.order_status IN ('COMPLETED','COMPLETED_CRM','COMPLETED_BRM') THEN 'COMPLETED'
           ELSE 'IN PROGRESS'
      END order_status,
      header.trans_date
    FROM sa.x_rtr_trans_header header
    JOIN detail   ON ( header.objid  = detail.rtr_trans_header_objid )
    JOIN sa.x_process_order_detail pod   ON (detail.order_detail_id = pod.objid)
    WHERE 1                    = 1
    AND header.rtr_vendor_name = i_rtr_vendor_name
    AND detail.rtr_trans_type  = NVL(io_rtr_trans_type,detail.rtr_trans_type )
    AND header.order_id        = NVL(io_order_id , header.order_id)
    ORDER BY header.trans_date DESC;
  rtr_esn_min_rec rtr_esn_min%ROWTYPE;

  CURSOR rtr_port_esn_min
  IS
    WITH POD AS
      (SELECT /*+ materialize */  xpod.*
      FROM sa.x_process_order xpo
    JOIN sa.x_process_order_detail xpod ON (xpo.objid  = xpod.process_order_objid)
      WHERE (xpod.esn     = io_esn
          OR xpod.min     = io_min
          OR xpo.order_id = io_order_id )
         AND xpod.order_type= io_rtr_trans_type
      )
    SELECT po.order_id,
      pod.esn,
      pod.min,
      pod.order_type,
      CASE WHEN pod.order_status IN ('FAILED','SUBMISSION_FAILED') THEN 'FAILED'
           WHEN pod.order_status IN ('CASE_GENERATED')	           THEN 'CASE_GENERATED'
           ELSE 'IN PROGRESS'
      END order_status ,
      pod.insert_timestamp
    FROM sa.x_process_order po
    JOIN pod   ON ( po.objid  = pod.process_order_objid )
    WHERE 1                    = 1
    AND EXISTS (SELECT 1 FROM sa.x_rtr_trans_header header
                  JOIN sa.x_rtr_trans_detail detail   ON ( header.objid  = detail.rtr_trans_header_objid )
                  WHERE header.rtr_vendor_name = i_rtr_vendor_name
                    AND detail.rtr_trans_type  = 'ADD_TO_RESERVE'
                    AND detail.esn             = pod.esn
                    AND detail.insert_timestamp <= pod.insert_timestamp
          )
    ORDER BY pod.insert_timestamp DESC;
  rtr_port_esn_min_rec rtr_port_esn_min%ROWTYPE;
BEGIN
  o_error_code := '0'; --SUCCESS
  o_error_message := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');

  IF io_esn IS NULL AND io_min IS NULL AND  io_order_id IS NULL
  THEN
    o_error_code     := '100'; --INPUT IS NULL
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    RETURN;
  END IF;

  IF io_rtr_trans_type IS NULL
  THEN
    o_error_code     := '140'; --INVALID TRNSACTION TYPE
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
    RETURN;
  END IF;

  --If action is PORT then check if status of PORT process order.
  --If iti??s CASE_GENERATED and no record of TAS, respond with IN PROGRESS.
  --If iti??s FAILED/SUBMISSION_FAILED, respond with FAILED.And for any other status IN PROGRESS
  --If iti??s CASE_GENERATED and TAS COMPLETEPORT record status is COMPLETED, respond with COMPLETED.
  --Any Other status of COMPLETEPORT, respond with IN PROGRESS.
  IF io_rtr_trans_type = 'PORT' THEN
    --Checking status of PORT process order
    OPEN rtr_port_esn_min;
    FETCH rtr_port_esn_min INTO rtr_port_esn_min_rec;

    IF rtr_port_esn_min%NOTFOUND
    THEN
      o_error_code     := '114'                              ;  --ORDER NOT FOUND
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
      CLOSE rtr_port_esn_min;
      RETURN;
    END IF;
    CLOSE rtr_port_esn_min;

    io_esn                 := rtr_port_esn_min_rec.esn                ;
    io_min                 := rtr_port_esn_min_rec.min                ;
    io_order_id            := rtr_port_esn_min_rec.order_id           ;
    io_rtr_trans_type      := rtr_port_esn_min_rec.order_type         ;
    o_trans_date           := rtr_port_esn_min_rec.insert_timestamp   ;
    o_order_status         := rtr_port_esn_min_rec.order_status       ;

    IF o_order_status IN ('FAILED','IN PROGRESS')
    THEN
      RETURN;
    END IF;

    -- The port status is CASE_GENERATED
    SELECT CASE
             WHEN COUNT(*)>=1 THEN 'COMPLETED'
             ELSE 'IN PROGRESS'
           END
      INTO o_order_status
      FROM x_process_order_detail
     WHERE order_type='COMPLETEPORT'
       AND esn         = io_esn
       AND order_status IN ('COMPLETED','COMPLETED_CRM','COMPLETED_BRM')
       AND insert_timestamp >= o_trans_date	  ;
      RETURN;
  END IF; --io_rtr_trans_type = 'PORT'

  --OTHER THAN PORT SCENARIO
  --Fetch order details based on ESN or MIN
  IF (io_esn IS NOT NULL OR  io_min IS NOT NULL)
  THEN
    OPEN rtr_esn_min;
    FETCH rtr_esn_min INTO rtr_esn_min_rec;

    IF rtr_esn_min%NOTFOUND THEN
      o_error_code     := '114'                              ;  --ORDER NOT FOUND
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH');
      CLOSE rtr_esn_min;
      RETURN;
    END IF;

    CLOSE rtr_esn_min;

    io_esn                 := rtr_esn_min_rec.esn                ;
    io_min                 := rtr_esn_min_rec.min                ;
    io_order_id            := rtr_esn_min_rec.order_id           ;
    io_rtr_trans_type      := rtr_esn_min_rec.rtr_trans_type     ;
    o_trans_date           := rtr_esn_min_rec.trans_date         ;
    o_order_status         := rtr_esn_min_rec.order_status       ;
  ELSIF io_order_id IS NOT NULL
  THEN
    --Fetch Order status based on order_id
    OPEN rtr_order_id;
    FETCH rtr_order_id INTO rtr_order_id_rec;

    IF rtr_order_id%FOUND AND rtr_order_id_rec.order_count <> 0
    THEN
      o_order_status   := rtr_order_id_rec.order_status    ;
      o_trans_date     := rtr_order_id_rec.trans_date      ;
    ELSE
      o_error_code     := '114'                              ;  --CANNOT FIND GIVEN ORDER ID
      o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') || ': '|| io_order_id;
    END IF;
    CLOSE rtr_order_id;
  END IF;

  IF o_order_status = 'COMPLETED'
  THEN
    SELECT *
      BULK COLLECT
      INTO o_ord_details
      FROM (SELECT rtr_order_detail_type(dtl.objid,
                                         CASE
                                           WHEN dtl.order_type IN ('ACTIVATION', 'ADD_TO_RESERVE')
                                           THEN
                                             dtl.esn
                                           WHEN dtl.order_type IN ('REDEMPTION', 'REACTIVATION')
                                           THEN
                                             dtl.min
                                         END,
                                         CASE
                                           WHEN dtl.order_status IN ('COMPLETED', 'FAILED')
                                           THEN
                                             dtl.order_status
                                           ELSE
                                             NULL
                                         END
                                         )
              FROM x_process_order hdr,
                   x_process_order_detail dtl,
                   x_rtr_trans_header rh
             WHERE hdr.order_id = io_order_id
               AND hdr.order_id = rh.order_id
               AND hdr.objid = dtl.process_order_objid
               AND rh.sourcesystem = 'RTR');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    o_error_code     := '99';
    o_error_message  := sa.get_code_fun('RTR_MULTI_TRANS_PKG' ,o_error_code ,'ENGLISH') ||SUBSTR(sqlerrm,1,500);
END get_order_status;
--CR49520 changes end
END rtr_multi_trans_pkg;
/