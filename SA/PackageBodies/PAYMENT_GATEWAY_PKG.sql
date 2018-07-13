CREATE OR REPLACE PACKAGE BODY sa.PAYMENT_GATEWAY_PKG
AS
/*******************************************************************************************************
  * --$RCSfile: PAYMENT_GATEWAY_PKG.SQL,v $
  --$Revision: 1.23 $
  --$Author: pamistry $
  --$Date: 2016/08/31 16:16:33 $
  --$ $Log: PAYMENT_GATEWAY_PKG.SQL,v $
  --$ Revision 1.23  2016/08/31 16:16:33  pamistry
  --$ CR41473 - LRP2 Added nvl check for RQST_SOURCE based on code review comment in P_WRITE_PYMT_AUTH_REQ_DATA procedure
  --$
  --$ Revision 1.22  2016/07/29 17:33:12  pamistry
  --$ CR41473 - LRP2 Modify P_WRITE_PYMT_TRANS_REPLY_DATA and P_WRITE_PYMT_AUTH_REQ_DATA to process Charge
  --$
  --$ Revision 1.21  2016/05/23 19:13:15  nmuthukkaruppan
  --$ CR38620- eBay Changes - Adding ROLLBACK in the exception block
  --$
  --$ Revision 1.20  2016/04/21 18:12:21  nmuthukkaruppan
  --$ CR 38620: eBay Integration and Store Front
  --$
  --$ Revision 1.19  2016/03/22 16:22:36 smeganathan
  --$ CR41786 - merchant ref num fix
  * Description: This package includes procedures
  * that are required for the Payment Gateway Springform services
  *
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
PROCEDURE P_WRITE_PYMT_AUTH_REQ_DATA(
    In_Org_Id      IN VARCHAR2,
    In_Brand       IN VARCHAR2,
    In_Language    IN VARCHAR2,
    In_Promocode   IN VARCHAR2,
    in_purch_hdr   IN purch_hdr_rec,
    In_ADDRESS     IN ADDRESS_REC,
    In_Purch_Dtl   IN Purch_Dtl_Tbl,
    In_Request_Xml IN CLOB,
    Out_Purch_Hdr_Objid OUT NUMBER,
    Out_X_Payment_Objid OUT NUMBER,
    OUT_WEB_USER_ObjID OUT NUMBER,
    Out_Error_Msg OUT VARCHAR2,
    OUT_Error_num OUT NUMBER)
IS
  l_credit_card NUMBER;
  --  l_BANK_ACcount  NUMBER;
  --  l_WEB_USER      NUMBER;
  --  l_billing_email VARCHAR2 (80);
  l_purch_objid NUMBER;
  i_count PLS_INTEGER := 0;
  --  L_Pymt_Cnt Pls_Integer := 0;
  l_X_Payment_Objid         NUMBER;
  authreq_validation_failed EXCEPTION;
  l_merchant_ref_number           VARCHAR2 (100);   -- CR41786
  ---
  CURSOR pymt_cur (pymt_src_id NUMBER)
  IS
    SELECT Ps.X_Pymt_Type,
      Ps.Pymt_Src2x_Altpymtsource,
      ps.pymt_src2x_credit_card,
      Ps.Pymt_Src2web_User,
      ps.pymt_src2x_bank_account,
      Alt.X_Alt_Pymt_Source,
      Alt.X_Alt_Pymt_Source_Type
    FROM X_Payment_Source Ps ,
      Table_X_Altpymtsource Alt
    WHERE Ps.Pymt_Src2x_Altpymtsource = Alt.Objid
    AND Ps.X_Status                   = 'ACTIVE'
    AND Ps.Objid                      = Pymt_Src_Id;
  pymt_rec pymt_cur%ROWTYPE;
  --
  -----
  CURSOR OBJID_CUR
  IS
    SELECT OBJID
    FROM X_PYMT_PROCESSOR
    WHERE X_NAME = 'LOYALTY_PTS'
    AND X_TYPE   = 'TF_POINTS_PYMT_TYPE'
    AND X_ACTIVE = 'Y';
  OBJID_REC X_PYMT_PROCESSOR.OBJID%TYPE;
  -----
BEGIN
  IF (in_purch_hdr.in_C_ORDERID IS NULL) THEN
    OUT_Error_num               := -367;
    out_error_msg               := 'Error. Invalid or null value received for  in_purch_hdr.in_C_ORDERID';
    --sa.get_code_fun('PAYMENT_GATEWAY_PKG', out_error_num, 'ENGLISH');
    raise authreq_validation_failed;
  END IF;
  IF (In_Brand    IS NULL) THEN
    OUT_Error_num := -339;
    out_error_msg := 'Error. Unsupported or Null values received for IN_BRAND';
    --sa.get_code_fun('PAYMENT_GATEWAY_PKG', out_error_num, 'ENGLISH');
    raise authreq_validation_failed;
  END IF;
  IF (NVL(in_purch_hdr.IN_RQST_SOURCE,'XX')  != 'API' AND in_purch_hdr.in_channel IS NULL) THEN     -- CR41473 PMistry 07/27/2016
    OUT_Error_num             := -368;
    out_error_msg             := 'Error. Invalid or null value received for in_purch_hdr.in_channel';
    --sa.get_code_fun('PAYMENT_GATEWAY_PKG', out_error_num, 'ENGLISH');
    raise authreq_validation_failed;
  END IF;
  IF (in_purch_hdr.in_pymt_src_id IS NULL) THEN
    OUT_Error_num                 := -369;
    out_error_msg                 := 'Error. Invalid or null value received for in_purch_hdr.in_pymt_src_id';
    --sa.get_code_fun('PAYMENT_GATEWAY_PKG', out_error_num, 'ENGLISH');
    raise authreq_validation_failed;
  END IF;
  OPEN pymt_cur (in_purch_hdr.in_pymt_src_id);
  FETCH pymt_cur INTO pymt_rec;
  IF pymt_cur%NOTFOUND THEN
    OUT_Error_num := -370; ---'payment source id required'
    --out_error_msg := sa.get_code_fun ('PAYMENT_GATEWAY_PKG', out_error_num, 'ENGLISH');
    out_error_msg := 'Error. Invalid or null value received for payment source id';
    CLOSE pymt_cur;
    raise authreq_validation_failed;
  ElsIf Pymt_Rec.X_Pymt_Type != 'APS' OR NVL(Pymt_Rec.X_Alt_Pymt_Source, 'AAA') != 'LOYALTY_PTS' THEN
    Out_Error_Num            := -371;
    out_error_msg            := 'Error. Invalid or null value received for Payment Type';
    CLOSE Pymt_Cur;
    raise authreq_validation_failed;
  ELSE
    OUT_WEB_USER_ObjID := pymt_rec.Pymt_Src2web_User;
  END IF;
  CLOSE pymt_cur;
  l_purch_objid     := sa.Sequ_Biz_Purch_Hdr.Nextval;
  l_X_Payment_Objid := sa.SEQ_X_PAYMENT.NEXTVAL;
  --
  l_merchant_ref_number := B2B_PKG.b2b_merchant_ref_number (In_Purch_Hdr.In_Channel); -- CR41786
  --
  BEGIN
    INSERT
    INTO x_biz_purch_hdr
      (
        OBJID,
        X_RQST_SOURCE,
        Channel,
        ecom_Org_Id,
        ORDER_TYPE,
        C_ORDERID,
        ACCOUNT_ID,
        X_AUTH_REQUEST_ID,
        GROUPIDENTIFIER,
        X_RQST_TYPE,
        X_RQST_DATE,
        X_ICS_APPLICATIONS,
        X_MERCHANT_REF_NUMBER, -- CR41786
        X_OFFER_NUM,
        X_QUANTITY,
        X_IGNORE_AVS,
        X_AVS,
        X_DISABLE_AVS,
        X_CUSTOMER_HOSTNAME,
        X_CUSTOMER_IPADDRESS,
        X_CUSTOMER_FIRSTNAME,
        X_CUSTOMER_LASTNAME,
        X_CUSTOMER_PHONE,
        X_CUSTOMER_EMAIL,
        X_STATUS,
        X_BILL_ADDRESS1,
        X_BILL_ADDRESS2,
        X_BILL_CITY,
        x_bill_state,
        x_bill_zip,
        X_BILL_COUNTRY,
        X_SHIP_ADDRESS1,
        X_SHIP_ADDRESS2,
        X_SHIP_CITY,
        x_ship_state,
        x_ship_zip,
        X_SHIP_COUNTRY,
        X_ESN,
        X_AMOUNT,
        X_Tax_Amount,
        X_Sales_Tax_Amount,
        X_E911_TAX_AMOUNT,
        X_USF_TAXAMOUNT,
        X_RCRF_TAX_AMOUNT,
        X_ADD_TAX1,
        X_ADD_TAX2,
        DISCOUNT_AMOUNT,
        FREIGHT_AMOUNT,
        X_AUTH_AMOUNT,
        X_USER,
        PURCH_HDR2CREDITCARD,
        PURCH_HDR2BANK_ACCT,
        PURCH_HDR2OTHER_FUNDS,
        PROG_HDR2X_PYMT_SRC,
        PROG_HDR2WEB_USER,
        X_PAYMENT_TYPE,
        X_Process_Date,
        X_Promo_Code,
        Purch_Hdr2altpymtsource
      )
      VALUES
      (
        l_purch_objid,
        in_purch_hdr.IN_RQST_SOURCE,
        In_Purch_Hdr.In_Channel,
        in_Org_Id,
        in_purch_hdr.in_order_type,
        in_purch_hdr.IN_c_orderid,
        Pymt_Rec.Pymt_Src2web_User,
        in_purch_hdr.IN_AUTH_REQUEST_ID,
        In_Purch_Hdr.In_Groupidentifier,
        in_purch_hdr.IN_RQST_TYPE,
        SYSDATE, ---in_purch_hdr.IN_RQST_DATE ,
        in_purch_hdr.IN_ICS_APPLICATIONS,
        l_merchant_ref_number, -- CR41786
        in_purch_hdr.IN_OFFER_NUM,
        in_purch_hdr.IN_QUANTITY,
        in_purch_hdr.in_ignore_avs,
        in_purch_hdr.IN_AVS,
        in_purch_hdr.IN_DISABLE_AVS,
        in_purch_hdr.IN_CUSTOMER_HOSTNAME,
        in_purch_hdr.in_customer_ipaddress,
        in_purch_hdr.IN_CUSTOMER_FIRSTNAME,
        in_purch_hdr.IN_CUSTOMER_LASTNAME,
        in_purch_hdr.IN_CUSTOMER_PHONE,
        In_Purch_Hdr.In_Customer_Email,
        'INCOMPLETE',
        in_address.X_BILL_ADDRESS1,
        in_address.X_BILL_ADDRESS2,
        in_address.X_BILL_CITY,
        in_address.X_BILL_STATE,
        in_address.X_BILL_ZIP,
        in_address.X_BILL_COUNTRY,
        in_address.X_SHIP_ADDRESS1,
        in_address.X_SHIP_ADDRESS2,
        in_address.X_SHIP_CITY,
        in_address.X_SHIP_STATE,
        in_address.X_SHIP_ZIP,
        in_address.X_SHIP_COUNTRY,
        in_purch_hdr.IN_esn,
        in_purch_hdr.IN_AMOUNT,
        In_Purch_Hdr.In_Tax_Amount,
        in_purch_hdr.IN_sales_TAX_AMOUNT,
        in_purch_hdr.IN_E911_TAX_AMOUNT,
        in_purch_hdr.IN_USF_TAXAMOUNT,
        in_purch_hdr.IN_RCRF_TAX_AMOUNT,
        in_purch_hdr.IN_ADD_TAX1,
        in_purch_hdr.IN_ADD_TAX2,
        in_purch_hdr.IN_DISCOUNT_AMOUNT,
        in_purch_hdr.IN_FREIGHT_AMOUNT,
        In_Purch_Hdr.In_Auth_Amount,
        IN_PURCH_HDR.IN_user,
        pymt_rec.pymt_src2x_credit_card,
        pymt_rec.pymt_src2x_bank_account,
        in_purch_hdr.IN_OTHER_FUNDS,
        in_purch_hdr.in_pymt_src_id,
        Pymt_Rec.Pymt_Src2web_User,
        --'PRE_AUTH',
                'PRE_'||In_Purch_Hdr.In_Ics_Applications,      -- CR41473 PMistry 07/27/2016 Modify to consider the generic call for any payment type.
        In_Purch_Hdr.In_Process_Date,
        In_Promocode,
        pymt_rec.Pymt_Src2x_Altpymtsource
      );
  EXCEPTION
  WHEN OTHERS THEN
    --
    OUT_ERROR_NUM := -372;
    OUT_ERROR_MSG := 'Insert Not Success' || (SUBSTR (SQLERRM, 1, 300))|| ' - ' ||dbms_utility.format_error_backtrace ;
    raise authreq_validation_failed;
  END;
  IF in_Purch_dtl.COUNT > 0 THEN
    FOR i_count IN in_Purch_dtl.FIRST .. in_Purch_dtl.LAST
    LOOP
      BEGIN
        INSERT
        INTO X_BIZ_PURCH_DTL
          (
            OBJID,
            X_ESN,
            X_AMOUNT,
            LINE_NUMBER,
            part_number,
            biz_PURCH_DTL2biz_PURCH_HDR,
            X_QUANTITY,
            DOMAIN,
            SALES_RATE,
            SALESTAX_AMOUNT,
            E911_RATE,
            X_E911_TAX_AMOUNT,
            USF_RATE,
            X_USF_TAXAMOUNT,
            RCRF_RATE,
            X_RCRF_TAX_AMOUNT,
            TOTAL_TAX_AMOUNT,
            TOTAL_AMOUNT,
            FREIGHT_AMOUNT,
            FREIGHT_METHOD,
            FREIGHT_CARRIER,
            DISCOUNT_AMOUNT,
            ADD_TAX_1,
            ADD_TAX_2
          )
          VALUES
          (
            sequ_biz_purch_dtl.NEXTVAL,
            in_Purch_dtl (i_count).IN_X_ESN,
            in_Purch_dtl (i_count).IN_LINE_AMOUNT,
            in_Purch_dtl (i_count).IN_LINE_NUMBER,
            in_Purch_dtl (i_count).IN_PART_NUMBER,
            l_purch_objid, ------- HDR OBJID
            in_Purch_dtl (i_count).IN_LINE_QUANTITY,
            in_Purch_dtl (i_count).IN_DOMAIN,
            in_Purch_dtl (i_count).IN_SALES_RATE,
            in_Purch_dtl (i_count).IN_SALESTAX_AMOUNT,
            in_Purch_dtl (i_count).IN_E911_RATE,
            in_Purch_dtl (i_count).IN_E911_TAX_AMOUNT,
            in_Purch_dtl (i_count).IN_USF_RATE,
            in_Purch_dtl (i_count).IN_USF_TAXAMOUNT,
            in_Purch_dtl (i_count).IN_RCRF_RATE,
            in_Purch_dtl (i_count).IN_RCRF_TAX_AMOUNT,
            in_Purch_dtl (i_count).IN_TOTAL_TAX_AMOUNT,
            in_Purch_dtl (i_count).IN_TOTAL_AMOUNT,
            in_Purch_dtl (i_count).IN_LINE_FREIGHT_AMOUNT,
            in_Purch_dtl (i_count).IN_LINE_FREIGHT_METHOD,
            in_Purch_dtl (i_count).IN_LINE_FREIGHT_CARRIER,
            in_Purch_dtl (i_count).IN_LINE_DISCOUNT_AMOUNT,
            in_Purch_dtl (i_count).IN_ADD_TAX_1,
            in_Purch_dtl (i_count).IN_ADD_TAX_2
          );
      END;
    END LOOP;
  END IF;
  INSERT
  INTO X_PAYMENT
    (
      OBJID,
      X_ORDER_ID,
      X_PYMT_STATUS,
      X_CREATE_DATE,
      X_UPDATE_DATE,
      X_AMOUNT,
      X_TAX_AMOUNT
    )
    VALUES
    (
      l_X_Payment_Objid,
      In_Purch_Hdr.In_C_Orderid,
      --'AUTH_PENDING',
              In_Purch_Hdr.In_Ics_Applications||'_'||In_Purch_Hdr.in_status,   -- CR41473 PMistry 07/27/2016 Modify to consider the generic call for any payment type.
      Sysdate,
      Sysdate,
      In_Purch_Hdr.In_Auth_Amount,
      In_Purch_Hdr.In_Tax_Amount
    );
  IF In_Purch_Dtl.Count > 0 THEN
    OPEN OBJID_CUR;
    FETCH OBJID_CUR INTO OBJID_REC;
    IF OBJID_CUR%FOUND THEN
      INSERT
      INTO X_TRANSACTION
        (
          OBJID,
          X_TRANS2PAYMENT,
          X_TRANS2PROCESSOR,
          X_TRANS_TYPE ,
          X_TRANS_DATE ,
          X_TRANS_STATUS,
          X_TRANS2PAYMENT_SOURCE,
          X_AMOUNT,
          X_Tax_Amount,
          X_REQUEST
        )
        VALUES
        (
          sequ_biz_purch_dtl.NEXTVAL,
          l_X_Payment_Objid, ------- X_Payment OBJID
          OBJID_REC,              -- LOYALTY_PTS on X_Pymt_Processor
          --'AUTH',
          In_Purch_Hdr.In_Ics_Applications,            -- CR41473 PMistry 07/27/2016 Modify to consider the generic call for any payment type.                                              -- CR41473 PMistry 07/27/2016 Modify to consider the generic call for any payment type.
          SYSDATE,
          --'AUTH_PENDING' ,
          In_Purch_Hdr.In_Ics_Applications||'_'||In_Purch_Hdr.in_status,             -- CR41473 PMistry 07/27/2016 Modify to consider the generic call for any payment type.                -- CR41473 PMistry 07/27/2016 Modify to consider the generic call for any payment type.
          in_purch_hdr.in_pymt_src_id,
          In_Purch_Hdr.In_Auth_Amount,
          In_Purch_Hdr.In_Tax_Amount,
          IN_request_XML
        );
    END IF;
    CLOSE OBJID_CUR;
  END IF;
  OUT_X_PAYMENT_OBJID := l_X_Payment_Objid;
  Out_Purch_Hdr_Objid := l_purch_objid;
  OUT_Error_MSg       := 'Success';
  OUT_ERROR_NUM       := 0;
EXCEPTION
WHEN authreq_validation_failed THEN
  --OUT_ERROR_NUM := SQLCODE;
  --OUT_ERROR_MSG := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => IN_PURCH_HDR.IN_C_ORDERID, IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.P_WRITE_PYMT_AUTH_REQ_DATA', ip_error_text => OUT_Error_MSg);
WHEN OTHERS THEN
  -- rollback;
  --
  OUT_ERROR_NUM := -99;
  OUT_ERROR_MSG := SUBSTR (SQLERRM, 1, 300)|| ' - ' ||dbms_utility.format_error_backtrace ;
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => IN_PURCH_HDR.IN_C_ORDERID, IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.P_WRITE_PYMT_AUTH_REQ_DATA', ip_error_text => OUT_Error_MSg);
END P_WRITE_PYMT_AUTH_REQ_DATA;
PROCEDURE P_GET_PYMT_SOURCE_DETAILS
  (
    p_pymt_src_id IN NUMBER,
    out_rec OUT typ_pymt_src_dtls_rec,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2
  )
IS
BEGIN
  -- will override the data required for Loyalty reward
  Payment_Services_Pkg.Getpaymentsourcedetails(p_pymt_src_id =>p_pymt_src_id, Out_Rec =>Out_Rec, Out_Err_Num => Out_Err_Num, Out_Err_Msg => Out_Err_Msg );
EXCEPTION
WHEN OTHERS THEN
  out_err_num := -99;
  out_err_msg := SUBSTR (SQLERRM, 1, 300)|| ' - ' ||dbms_utility.format_error_backtrace ;
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => TO_CHAR (P_PYMT_SRC_ID), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.P_GET_PYMT_SOURCE_DETAILS', iP_ERROR_TEXT => out_err_msg);
  ---
  ---
END P_GET_PYMT_SOURCE_DETAILS;
--
PROCEDURE p_getpaymentsource
  (
    In_Login_Name    IN VARCHAR2,
    In_Bus_Org_Id    IN VARCHAR2,
    In_Esn           IN VARCHAR2,
    In_Min           IN VARCHAR2,
    in_PYMT_SRC_TYPE IN VARCHAR2,
    OUT_tbl OUT pymt_src_tbl,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2
  )
IS
  --
  -- PYMT_SRC_OBJ  TYP_PYMT_SRC_OBJ := TYP_PYMT_SRC_OBJ (NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  DTL_PYMT_SRC PYMT_SRC_TBL := PYMT_SRC_TBL (NULL);
  l_WU_OBJID NUMBER;
  l_Bo_Objid NUMBER;
  --  Boobjid       NUMBER;
  --  Brand         VARCHAR2 (40);
  l_esn_wu_objid NUMBER;
  --
BEGIN
  IF in_login_name IS NULL OR in_BUS_ORG_ID IS NULL THEN
    Out_Err_Num    := 701; ---'Login name and bus org required'
    Out_Err_Msg    := sa.Get_Code_Fun (ip_program_name => 'SA.PAYMENT_SERVICES_PKG',
                                       ip_clfy_code => Out_Err_Num,
                                       ip_language => 'ENGLISH');
    RETURN;
  END IF;
  --
  B2B_PKG.get_esn_web_user (in_login_name => in_login_name,
    IN_BUS_ORG    => in_bus_org_id,
    in_esn        => in_esn,
    in_min        => in_min,
    out_wu_objid  => l_WU_OBJID,
    out_esn_wuobjid => l_esn_wu_objid,
    out_bo_objid => l_Bo_Objid,
    out_err_num => out_err_num,
    out_Err_msg => out_err_msg);
  --
  IF ( (l_WU_OBJID IS NOT NULL) OR (l_esn_wu_objid IS NOT NULL)) AND ( (in_pymt_src_type IS NULL) OR (in_pymt_src_type = 'LOYALTY_PTS')) THEN
    --
    SELECT TYP_PYMT_SRC_OBJ (ps.objid, ps.x_pymt_type, ps.x_status, ps.x_is_default, ps.x_billing_email, NULL, NULL) BULK COLLECT
    INTO dtl_pymt_src
    FROM x_payment_source ps,
      Table_X_Altpymtsource aps,
      table_web_user wu
    WHERE ps.X_PYMT_TYPE             = 'APS'
    AND ps.PYMT_SRC2X_ALTPYMTSOURCE IS NOT NULL
    AND ps.x_status                  = 'ACTIVE'
    AND ps.PYMT_SRC2X_ALTPYMTSOURCE  = aps.objid
    AND ps.pymt_src2web_user         = wu.objid
    AND WU.OBJID                     = NVL (l_WU_OBJID, l_esn_wu_objid)
    AND aps.X_Alt_Pymt_Source        = in_PYMT_SRC_TYPE;
    --
  ELSE
    --
    payment_services_pkg.Getpaymentsource( In_Login_Name => In_Login_Name , In_Bus_Org_Id => In_Bus_Org_Id , In_Esn => In_Esn , In_Min => In_Min , in_PYMT_SRC_TYPE => in_PYMT_SRC_TYPE, OUT_tbl => dtl_pymt_src , Out_Err_Num => Out_Err_Num , Out_Err_Msg => Out_Err_Msg);
  END IF;
  --
  Out_Err_Num := '0';
  Out_Err_Msg := 'Success';
  OUT_TBL     := dtl_pymt_src;
  --
EXCEPTION
WHEN OTHERS THEN
  out_err_num := -99;
  out_err_msg := SUBSTR (SQLERRM, 1, 300)|| ' - ' ||dbms_utility.format_error_backtrace ;
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => TO_CHAR (In_Esn), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.P_GET_PYMT_SOURCE_DETAILS', iP_ERROR_TEXT => out_err_msg);
  --
END p_getpaymentsource;
--
PROCEDURE P_WRITE_PYMT_TRANS_REPLY_DATA(
    in_Purch_Hdr_Objid   IN NUMBER,
    In_X_Payment_Objid   IN NUMBER,
    in_Rqst_Type         IN VARCHAR2, -- AUTH, SETTLEMENT, CANCEL, REFUND
    In_X_Transaction_Id  IN VARCHAR2,
    In_Tf_Transaction_Id IN VARCHAR2,
    IN_TRANS_STATUS      IN NUMBER, --0 for success
    In_Trans_Msg         IN VARCHAR2,
    IN_response_XML      IN CLOB,
    Out_Error_Msg OUT VARCHAR2,
    OUT_Error_num OUT NUMBER )
IS
  transreply_input_failed EXCEPTION;
BEGIN
  IF (in_Purch_Hdr_Objid IS NULL) THEN
    OUT_Error_num        := -373;
    out_error_msg        := 'Error. Invalid or null value received for in_Purch_Hdr_Objid';
    raise transreply_input_failed;
  ELSIF In_X_Payment_Objid IS NULL THEN
    OUT_Error_num          := -374;
    out_error_msg          := 'Error. Invalid or null value received for  In_X_Payment_Objid';
    raise transreply_input_failed;
  ELSIF in_Rqst_Type IS NULL THEN
    OUT_Error_num    := -375;
    out_error_msg    := 'Error. Invalid or null value received for in_Rqst_Type';
    raise transreply_input_failed;
  ELSIF IN_TRANS_STATUS IS NULL THEN
    OUT_Error_num       := -378;
    out_error_msg       := 'Error. Invalid or null value received for IN_TRANS_STATUS';
    raise transreply_input_failed;
  ELSIF In_X_Transaction_Id IS NULL AND In_Trans_Status = 0 THEN
    OUT_Error_num           := -376;
    out_error_msg           := 'Error. Invalid or null value received for In_X_Transaction_Id';
    raise transreply_input_failed;
  ELSIF In_Tf_Transaction_Id IS NULL AND In_Trans_Status = 0 THEN
    OUT_Error_num            := -377;
    out_error_msg            := 'Error. Invalid or null value received for In_Tf_Transaction_Id';
    raise transreply_input_failed;
  ELSIF In_Trans_Msg IS NULL THEN
    OUT_Error_num    := -379;
    out_error_msg    := 'Error. Invalid or null value received for In_Trans_Msg';
    raise transreply_input_failed;
  END IF;
  IF In_Trans_Status = 0 THEN --Sucess
    BEGIN
      UPDATE X_Biz_Purch_Hdr
      SET X_payment_type  =in_Rqst_Type,
        X_Ics_Rcode       =100,
        X_Ics_Rflag       ='ACCEPT',
        X_Ics_Rmsg        ='ACCEPT',
        X_Auth_Avs        =100,
        X_Auth_Response   =100,
        X_Auth_Rcode      =100,
        X_Auth_Rmsg       ='ACCEPT',
        X_Auth_Rflag      ='ACCEPT',
        X_Status          ='SUCCESS',
        X_Auth_Request_Id = In_Tf_Transaction_Id
      WHERE Objid         =In_Purch_Hdr_Objid;
      UPDATE X_PAYMENT
      SET X_Trans_Id  = In_Tf_Transaction_Id,
        X_Pymt_Status =
        CASE in_Rqst_Type
          WHEN 'AUTH'
          THEN 'AUTH_SUCCESS'
          WHEN 'SETTLEMENT'
          THEN 'SETTLE_SUCCESS'
          WHEN 'CANCEL'
          THEN 'CANCEL_SUCCESS'
          WHEN 'REFUND'
          THEN 'REFUND_SUCCESS'
          WHEN 'CHARGE'                                  -- CR41473 PMistry 07/27/2016
          THEN 'CHARGE_SUCCESS'                          -- CR41473 PMistry 07/27/2016
        END,
        X_UPDATE_DATE = SYSDATE
      WHERE Objid     =In_X_Payment_Objid;
      FOR X_Trans IN
      (SELECT      *
      FROM X_TRANSACTION
      WHERE X_Trans_Status =
        CASE in_Rqst_Type
          WHEN 'AUTH'
          THEN 'AUTH_PENDING'
          WHEN 'SETTLEMENT'
          THEN 'SETTLE_PENDING'
          WHEN 'CANCEL'
          THEN 'CANCEL_PENDING'
          WHEN 'REFUND'
          THEN 'REFUND_PENDING'
          WHEN 'CHARGE'                                 -- CR41473 PMistry 07/27/2016
          THEN 'CHARGE_PENDING'                         -- CR41473 PMistry 07/27/2016
        END
      AND X_TRANS2PAYMENT = In_X_Payment_Objid
      )
      LOOP
        INSERT
        INTO X_TRANSACTION
          (
            OBJID,
            X_TRANS2PAYMENT,
            X_TRANS2PROCESSOR,
            X_TRANS_TYPE ,
            X_TRANS_DATE ,
            X_TRANS_STATUS,
            X_TRANS2PAYMENT_SOURCE,
            X_Amount,
            X_Tax_Amount,
            X_Transaction_Id,
            X_RESPONSE
          )
          VALUES
          (
            Sequ_Biz_Purch_Dtl.Nextval,
            In_X_Payment_Objid,   ------- X_Payment OBJID
            X_Trans.X_Trans2processor, -- LOYALTY_PTS on X_Pymt_Processor
            X_Trans.X_TRANS_TYPE,
            Sysdate,
            CASE in_Rqst_Type
              WHEN 'AUTH'
              THEN 'AUTH_SUCCESS'
              WHEN 'SETTLEMENT'
              THEN 'SETTLE_SUCCESS'
              WHEN 'CANCEL'
              THEN 'CANCEL_SUCCESS'
              WHEN 'REFUND'
              THEN 'REFUND_SUCCESS'
              WHEN 'CHARGE'                                  -- CR41473 PMistry 07/27/2016
              THEN 'CHARGE_SUCCESS'                          -- CR41473 PMistry 07/27/2016
            END,
            X_Trans.X_Trans2payment_Source,
            X_Trans.X_Amount,
            X_Trans.X_Tax_Amount,
            In_X_Transaction_Id,
            IN_response_XML
          );
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      --
      Out_Error_Num := -380;
      Out_Error_Msg := 'Not Able to Update/insert' || (SUBSTR (Sqlerrm, 1, 300))|| ' - ' ||dbms_utility.format_error_backtrace ;
      RETURN;
    END;
  ELSE -- for failure
    BEGIN
      UPDATE X_Biz_Purch_Hdr
      SET X_payment_type  =in_Rqst_Type,
        X_Ics_Rcode       =203,
        X_Ics_Rflag       ='REJECT',
        X_Ics_Rmsg        ='REJECT',
        X_Auth_Response   =303,
        X_Auth_Rcode      =203,
        X_Auth_Rmsg       ='REJECT',
        X_Auth_Rflag      ='REJECT',
        X_Status          ='FAILED',
        X_Auth_Request_Id = In_Tf_Transaction_Id
      WHERE Objid         =In_Purch_Hdr_Objid;
      UPDATE X_PAYMENT
      SET X_Trans_Id  = In_Tf_Transaction_Id,
        X_Pymt_Status =
        CASE in_Rqst_Type
          WHEN 'AUTH'
          THEN 'AUTH_FAILED'
          WHEN 'SETTLEMENT'
          THEN 'SETTLE_FAILED'
          WHEN 'CANCEL'
          THEN 'CANCEL_FAILED'
          WHEN 'REFUND'
          THEN 'REFUND_FAILED'
          WHEN 'CHARGE'                                       -- CR41473 PMistry 07/27/2016
          THEN 'CHARGE_FAILED'                                -- CR41473 PMistry 07/27/2016
        END,
        X_UPDATE_DATE = SYSDATE
      WHERE Objid     =In_X_Payment_Objid;
      FOR X_Trans IN
      (SELECT      *
      FROM X_TRANSACTION
      WHERE X_Trans_Status =
        CASE in_Rqst_Type
          WHEN 'AUTH'
          THEN 'AUTH_PENDING'
          WHEN 'SETTLEMENT'
          THEN 'SETTLE_PENDING'
          WHEN 'CANCEL'
          THEN 'CANCEL_PENDING'
          WHEN 'REFUND'
          THEN 'REFUND_PENDING'
          WHEN 'CHARGE'                                    -- CR41473 PMistry 07/27/2016
          THEN 'CHARGE_PENDING'                            -- CR41473 PMistry 07/27/2016
        END
      AND X_TRANS2PAYMENT = In_X_Payment_Objid
      )
      LOOP
        INSERT
        INTO X_TRANSACTION
          (
            OBJID,
            X_TRANS2PAYMENT,
            X_TRANS2PROCESSOR,
            X_TRANS_TYPE ,
            X_TRANS_DATE ,
            X_TRANS_STATUS,
            X_TRANS2PAYMENT_SOURCE,
            X_Amount,
            X_Tax_Amount,
            X_Transaction_Id,
            X_RESPONSE
          )
          VALUES
          (
            Sequ_Biz_Purch_Dtl.Nextval,
            In_X_Payment_Objid,   ------- X_Payment OBJID
            X_Trans.X_Trans2processor, -- LOYALTY_PTS on X_Pymt_Processor
            X_Trans.X_TRANS_TYPE,
            Sysdate,
            CASE in_Rqst_Type
              WHEN 'AUTH'
              THEN 'AUTH_FAILED'
              WHEN 'SETTLEMENT'
              THEN 'SETTLE_FAILED'
              WHEN 'CANCEL'
              THEN 'CANCEL_FAILED'
              WHEN 'REFUND'
              THEN 'REFUND_FAILED'
              WHEN 'CHARGE'                                     -- CR41473 PMistry 07/27/2016
              THEN 'CHARGE_FAILED'                              -- CR41473 PMistry 07/27/2016
            END,
            X_Trans.X_Trans2payment_Source,
            X_Trans.X_Amount,
            X_Trans.X_Tax_Amount,
            In_X_Transaction_Id,
            IN_response_XML
          );
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      --
      Out_Error_Num := -380;
      Out_Error_Msg := 'Not Able to Update/insert' || (SUBSTR (Sqlerrm, 1, 300))|| ' - ' ||dbms_utility.format_error_backtrace ;
      RETURN;
    END;
  END IF;
  OUT_Error_num := 0;
  Out_Error_Msg := 'Success';
EXCEPTION
WHEN transreply_input_failed THEN
  sa.ota_util_pkg.err_log ( p_action => 'Validation Failed', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'PAYMENT_GATEWAY_PKG.P_WRITE_PYMT_TRANS_REPLY_DATADETAILS', p_error_text => out_error_msg );
WHEN OTHERS THEN
  OUT_Error_num := -99;
  Out_Error_Msg := SUBSTR (SQLERRM, 1, 300)|| ' - ' ||dbms_utility.format_error_backtrace ;
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => TO_CHAR (in_Purch_Hdr_Objid), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.P_WRITE_PYMT_TRANS_REPLY_DATADETAILS', iP_ERROR_TEXT => Out_Error_Msg);
  ---
  ---
END P_WRITE_PYMT_TRANS_REPLY_DATA;
PROCEDURE P_WRITE_PYMT_TRANS_REQ_DATA
  (
    In_TF_REL_TRANS_ID IN VARCHAR2,
    In_Rqst_Type       IN VARCHAR2, -- SETTLEMENT, CANCEL, REFUND
    IN_request_XML     IN CLOB,
    Out_Purch_Hdr_Objid OUT NUMBER,
    Out_X_Payment_Objid OUT NUMBER,
    Out_Web_User_Objid OUT NUMBER,
    Out_Orderid OUT VARCHAR2,
    Out_Trans_id OUT VARCHAR2,
    OUT_pymt_src_id OUT NUMBER,
    Out_Error_Msg OUT VARCHAR2,
    OUT_Error_num OUT NUMBER
  )
IS
  l_purch_objid         NUMBER;
  l_X_Payment_Objid     NUMBER;
  V_Rel_Purch_Objid     NUMBER;
  V_rel_X_Payment_Objid NUMBER;
  transreq_input_failed EXCEPTION;
  CURSOR biz_hdr_cur
  IS
    SELECT *
    FROM X_Biz_Purch_Hdr
    WHERE X_Payment_Type =
      CASE In_Rqst_Type
        WHEN 'SETTLEMENT'
        THEN 'AUTH'
        WHEN 'CANCEL'
        THEN 'AUTH'
        WHEN 'REFUND'
        THEN 'SETTLEMENT'
      END
    AND X_STATUS          = 'SUCCESS'
    AND x_auth_request_id = In_TF_REL_TRANS_ID;
  Biz_Hdr_Rec Biz_Hdr_Cur%Rowtype;
  CURSOR validate_complete_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE X_Payment_Type  = in_Rqst_Type
    AND x_auth_request_id = In_TF_REL_TRANS_ID;
  validate_complete_rec validate_complete_cur%ROWTYPE;
  Dtls_Result_Set Purch_Dtl_Tbl;
BEGIN
  -- Toc validate prior trsaction is success. Example AUTH need to success for Settlement
  IF trim(in_Rqst_Type) IS NULL THEN
    Out_Error_Num       := -375;
    Out_Error_Msg       := 'Error. Invalid or null value received for In_Rqst_Type';
    raise transreq_input_failed;
  END IF;
  OPEN biz_hdr_cur;
  FETCH biz_hdr_cur INTO biz_hdr_rec;
  IF biz_hdr_cur%NOTFOUND THEN
    Out_Error_Num := -376;
    Out_Error_Msg := 'Error. Transaction Id does not exist with Success to proceed for requested payment.';
    CLOSE biz_hdr_cur;
    raise transreq_input_failed;
  END IF;
  CLOSE Biz_Hdr_Cur;
  OPEN validate_complete_cur;
  FETCH validate_complete_cur
  INTO validate_complete_rec;
  IF validate_complete_cur%Found THEN
    Out_Error_Num := -380;
    Out_Error_Msg := 'Error. Invalid or null value received for In_TF_REL_TRANS_ID';
    CLOSE validate_complete_cur;
    raise transreq_input_failed;
  END IF;
  CLOSE validate_complete_cur;
  l_purch_objid     := sa.Sequ_Biz_Purch_Hdr.Nextval;
  l_X_Payment_Objid := sa.Seq_X_PAYMENT.Nextval;
  FOR biz_hdr_rec IN
  (SELECT          *
  FROM X_Biz_Purch_Hdr
  WHERE X_Payment_Type =
    CASE In_Rqst_Type
      WHEN 'SETTLEMENT'
      THEN 'AUTH'
      WHEN 'CANCEL'
      THEN 'AUTH'
      WHEN 'REFUND'
      THEN 'SETTLEMENT'
    END
  AND x_auth_request_id = In_TF_REL_TRANS_ID
  )
  LOOP
    V_Rel_Purch_Objid  := Biz_Hdr_Rec.Objid;
    Out_Web_User_Objid := Biz_Hdr_Rec.Prog_Hdr2web_User;
    Out_Orderid        := Biz_Hdr_Rec.C_Orderid;
    OUT_pymt_src_id    := Biz_Hdr_Rec.PROG_HDR2X_PYMT_SRC;
    INSERT
    INTO x_biz_purch_hdr
      (
        objid,
        x_rqst_source,
        channel,
        ecom_org_id,
        order_type,
        c_orderid,
        account_id,
        x_auth_request_id,
        groupidentifier,
        x_rqst_type,
        x_rqst_date,
        x_ics_applications,
        x_merchant_id,
        x_merchant_ref_number,
        x_offer_num,
        x_quantity,
        x_ignore_avs,
        x_avs,
        x_disable_avs,
        x_customer_hostname,
        x_customer_ipaddress,
        x_auth_code,
        x_ics_rcode,
        x_ics_rflag,
        x_ics_rmsg,
        x_request_id,
        x_auth_request_token,
        x_auth_avs,
        x_auth_response,
        x_auth_time,
        x_auth_rcode,
        x_auth_rflag,
        x_auth_rmsg,
        x_bill_request_time,
        x_bill_rcode,
        x_bill_rflag,
        x_bill_rmsg,
        x_bill_trans_ref_no,
        x_score_rcode,
        x_score_rflag,
        x_score_rmsg,
        x_customer_firstname,
        x_customer_lastname,
        x_customer_phone,
        x_customer_email,
        x_status,
        x_bill_address1,
        x_bill_address2,
        x_bill_city,
        x_bill_state,
        x_bill_zip,
        x_bill_country,
        x_ship_address1,
        x_ship_address2,
        x_ship_city,
        x_ship_state,
        x_ship_zip,
        x_ship_country,
        x_esn,
        x_amount,
        x_tax_amount,
        x_sales_tax_amount,
        x_e911_tax_amount,
        x_usf_taxamount,
        x_rcrf_tax_amount,
        x_add_tax1,
        x_add_tax2,
        discount_amount,
        freight_amount,
        x_auth_amount,
        x_bill_amount,
        x_user,
        purch_hdr2creditcard,
        purch_hdr2bank_acct,
        purch_hdr2other_funds,
        prog_hdr2x_pymt_src,
        prog_hdr2web_user,
        x_payment_type,
        X_Process_Date,
        X_Promo_Code,
        Purch_Hdr2altpymtsource
      )
      VALUES
      (
        l_purch_objid,
        biz_hdr_rec.x_rqst_source,
        biz_hdr_rec.channel,
        Biz_Hdr_Rec.Ecom_Org_Id,
        CASE in_Rqst_Type
          WHEN 'SETTLEMENT'
          THEN Biz_Hdr_Rec.Order_Type
          WHEN 'CANCEL'
          THEN 'CANCEL'
          WHEN 'REFUND'
          THEN 'RETURN'
        END,
        biz_hdr_rec.c_orderid,
        biz_hdr_rec.account_id,
        NULL,
        Biz_Hdr_Rec.Groupidentifier,
        biz_hdr_rec.x_rqst_type,
        sysdate,
        in_Rqst_Type,
        biz_hdr_rec.x_merchant_id,
        biz_hdr_rec.x_merchant_ref_number || '_'|| SUBSTR(in_Rqst_Type,1,3), -- CR41786
        biz_hdr_rec.x_offer_num,
        biz_hdr_rec.x_quantity,
        biz_hdr_rec.x_ignore_avs,
        biz_hdr_rec.x_avs,
        biz_hdr_rec.x_disable_avs,
        Biz_Hdr_Rec.X_Customer_Hostname,
        biz_hdr_rec.x_customer_ipaddress,
        biz_hdr_rec.x_auth_code,
        biz_hdr_rec.x_ics_rcode,
        biz_hdr_rec.x_ics_rflag,
        biz_hdr_rec.x_ics_rmsg,
        biz_hdr_rec.x_request_id,
        biz_hdr_rec.x_auth_request_token,
        biz_hdr_rec.x_auth_avs,
        biz_hdr_rec.x_auth_response,
        biz_hdr_rec.x_auth_time,
        biz_hdr_rec.x_auth_rcode,
        biz_hdr_rec.x_auth_rflag,
        biz_hdr_rec.x_auth_rmsg,
        biz_hdr_rec.x_bill_request_time,
        biz_hdr_rec.x_bill_rcode,
        biz_hdr_rec.x_bill_rflag,
        biz_hdr_rec.x_bill_rmsg,
        biz_hdr_rec.x_bill_trans_ref_no,
        biz_hdr_rec.x_score_rcode,
        biz_hdr_rec.x_score_rflag,
        biz_hdr_rec.x_score_rmsg,
        biz_hdr_rec.x_customer_firstname,
        biz_hdr_rec.x_customer_lastname,
        biz_hdr_rec.x_customer_phone,
        biz_hdr_rec.x_customer_email,
        'INCOMPLETE',
        biz_hdr_rec.x_bill_address1,
        biz_hdr_rec.x_bill_address2,
        biz_hdr_rec.x_bill_city,
        biz_hdr_rec.x_bill_state,
        biz_hdr_rec.x_bill_zip,
        biz_hdr_rec.x_bill_country,
        biz_hdr_rec.x_ship_address1,
        biz_hdr_rec.x_ship_address2,
        biz_hdr_rec.x_ship_city,
        biz_hdr_rec.x_ship_state,
        biz_hdr_rec.x_ship_zip,
        biz_hdr_rec.x_ship_country,
        biz_hdr_rec.x_esn,
        biz_hdr_rec.x_amount,
        biz_hdr_rec.x_tax_amount,
        biz_hdr_rec.x_sales_tax_amount,
        biz_hdr_rec.x_e911_tax_amount,
        biz_hdr_rec.x_usf_taxamount,
        biz_hdr_rec.x_rcrf_tax_amount,
        biz_hdr_rec.x_add_tax1,
        biz_hdr_rec.x_add_tax2,
        biz_hdr_rec.discount_amount,
        biz_hdr_rec.freight_amount,
        biz_hdr_rec.X_Auth_Amount,
        biz_hdr_rec.x_bill_amount,
        biz_hdr_rec.x_user,
        biz_hdr_rec.purch_hdr2creditcard,
        biz_hdr_rec.purch_hdr2bank_acct,
        biz_hdr_rec.purch_hdr2other_funds,
        biz_hdr_rec.prog_hdr2x_pymt_src,
        biz_hdr_rec.prog_hdr2web_user,
        CASE in_Rqst_Type
          WHEN 'SETTLEMENT'
          THEN 'PRE_SETTLEMENT'
          WHEN 'CANCEL'
          THEN 'PRE_CANCEL'
          WHEN 'REFUND'
          THEN 'PRE_REFUND'
        END,
        Biz_Hdr_Rec.X_Process_Date,
        Biz_Hdr_Rec.X_Promo_Code,
        Biz_Hdr_Rec.Purch_Hdr2altpymtsource
      );
  END LOOP;
  SELECT Purch_dtl_rec (x_esn, x_amount, line_number, part_number, x_quantity, domain, sales_rate, salestax_amount, e911_rate, x_e911_tax_amount, usf_rate, x_usf_taxamount, rcrf_rate, x_rcrf_tax_amount, total_tax_amount, total_amount, freight_amount, freight_method, freight_carrier, discount_amount, add_tax_1, add_tax_2) BULK COLLECT
  INTO dtls_result_set
  FROM x_biz_purch_dtl
  WHERE biz_purch_dtl2biz_purch_hdr = V_Rel_Purch_Objid;
  FOR i_count IN dtls_result_set.FIRST .. dtls_result_set.LAST
  LOOP
    INSERT
    INTO x_biz_purch_dtl
      (
        objid,
        x_esn,
        x_amount,
        line_number,
        part_number,
        biz_purch_dtl2biz_purch_hdr,
        x_quantity,
        domain,
        sales_rate,
        salestax_amount,
        e911_rate,
        x_e911_tax_amount,
        usf_rate,
        x_usf_taxamount,
        rcrf_rate,
        x_rcrf_tax_amount,
        total_tax_amount,
        total_amount,
        freight_amount,
        freight_method,
        freight_carrier,
        discount_amount,
        add_tax_1,
        add_tax_2
      )
      VALUES
      (
        sequ_biz_purch_dtl.NEXTVAL,
        dtls_result_set (i_count).in_x_esn,
        dtls_result_set (i_count).in_line_amount,
        dtls_result_set (i_count).in_line_number,
        dtls_result_set (i_count).in_part_number,
        l_purch_objid, -------> hdr objid
        dtls_result_set (i_count).in_line_quantity,
        dtls_result_set (i_count).in_domain,
        dtls_result_set (i_count).in_sales_rate,
        dtls_result_set (i_count).in_salestax_amount,
        dtls_result_set (i_count).in_e911_rate,
        dtls_result_set (i_count).in_e911_tax_amount,
        dtls_result_set (i_count).in_usf_rate,
        dtls_result_set (i_count).in_usf_taxamount,
        dtls_result_set (i_count).in_rcrf_rate,
        dtls_result_set (i_count).in_rcrf_tax_amount,
        dtls_result_set (i_count).in_total_tax_amount,
        dtls_result_set (i_count).in_total_amount,
        dtls_result_set (i_count).in_line_freight_amount,
        dtls_result_set (i_count).in_line_freight_method,
        dtls_result_set (i_count).in_line_freight_carrier,
        dtls_result_set (i_count).in_line_discount_amount,
        dtls_result_set (i_count).in_add_tax_1,
        dtls_result_set (i_count).in_add_tax_2
      );
  END LOOP;
  FOR X_PAY IN
  (SELECT    *
    FROM X_PAYMENT
    WHERE X_PYMT_STATUS =
      CASE in_Rqst_Type
        WHEN 'SETTLEMENT'
        THEN 'AUTH_SUCCESS'
        WHEN 'CANCEL'
        THEN 'AUTH_SUCCESS'
        WHEN 'REFUND'
        THEN 'SETTLE_SUCCESS'
      END
    AND X_TRANS_ID = In_TF_REL_TRANS_ID
  )
  LOOP
    V_rel_X_Payment_Objid := X_PAY.Objid;
    INSERT
    INTO X_PAYMENT
      (
        Objid,
        X_REL_TRANS_ID,
        X_ORDER_ID,
        X_PYMT_STATUS,
        X_CREATE_DATE,
        X_UPDATE_DATE,
        X_AMOUNT,
        X_TAX_AMOUNT
      )
      VALUES
      (
        l_X_Payment_Objid,
        In_TF_REL_TRANS_ID,
        X_PAY.X_ORDER_ID,
        CASE in_Rqst_Type
          WHEN 'SETTLEMENT'
          THEN 'SETTLE_PENDING'
          WHEN 'CANCEL'
          THEN 'CANCEL_PENDING'
          WHEN 'REFUND'
          THEN 'REFUND_PENDING'
        END ,
        Sysdate,
        Sysdate,
        X_PAY.X_AMOUNT,
        X_Pay.X_TAX_AMOUNT
      );
  END LOOP;
  FOR X_Trans IN
  (SELECT      *
    FROM X_TRANSACTION
    WHERE X_Trans_Status =
      CASE in_Rqst_Type
        WHEN 'SETTLEMENT'
        THEN 'AUTH_SUCCESS'
        WHEN 'CANCEL'
        THEN 'AUTH_SUCCESS'
        WHEN 'REFUND'
        THEN 'SETTLE_SUCCESS'
      END
    AND X_TRANS2PAYMENT = V_rel_X_Payment_Objid
  )
  LOOP
    INSERT
    INTO X_TRANSACTION
      (
        OBJID,
        X_TRANS2PAYMENT,
        X_TRANS2PROCESSOR,
        X_TRANS_TYPE ,
        X_TRANS_DATE ,
        X_TRANS_STATUS,
        X_TRANS2PAYMENT_SOURCE,
        X_AMOUNT,
        X_Tax_Amount,
        X_REQUEST
      )
      VALUES
      (
        Sequ_Biz_Purch_Dtl.Nextval,
        l_X_Payment_Objid,    ------- X_Payment OBJID
        X_Trans.X_Trans2processor, -- LOYALTY_PTS on X_Pymt_Processor
        in_Rqst_Type,
        Sysdate,
        CASE in_Rqst_Type
          WHEN 'AUTH'
          THEN 'AUTH_PENDING'
          WHEN 'SETTLEMENT'
          THEN 'SETTLE_PENDING'
          WHEN 'CANCEL'
          THEN 'CANCEL_PENDING'
          WHEN 'REFUND'
          THEN 'REFUND_PENDING'
        END,
        X_Trans.X_Trans2payment_Source,
        X_Trans.X_Amount,
        X_Trans.X_Tax_Amount,
        IN_request_XML
      );
    Out_Trans_id := X_Trans.x_transaction_id;
  END LOOP;
  Out_X_Payment_Objid := l_X_Payment_Objid;
  Out_Purch_Hdr_Objid := l_purch_objid;
  OUT_Error_num       := 0;
  Out_Error_Msg       := 'Success';
EXCEPTION
WHEN transreq_input_failed THEN
  sa.ota_util_pkg.err_log ( p_action => 'Validation Failed', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'PAYMENT_GATEWAY_PKG.P_WRITE_PYMT_TRANS_REQ_DATA', p_error_text => out_error_msg );
WHEN OTHERS THEN
  OUT_Error_num := -99;
  Out_Error_Msg := SUBSTR (SQLERRM, 1, 300)|| ' - ' ||dbms_utility.format_error_backtrace ;
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => TO_CHAR (In_TF_REL_TRANS_ID), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.P_WRITE_PYMT_TRANS_REQ_DATA', iP_ERROR_TEXT => Out_Error_Msg);
  ---
  ---
END P_WRITE_PYMT_TRANS_REQ_DATA;

--CR38620 - Added for Ebay Integration - Start
PROCEDURE P_FETCH_PYMT_DATA
(In_Transaction_Id  IN VARCHAR2,
 Out_X_Total_Amount  OUT NUMBER,
 Out_Error_Msg       OUT VARCHAR2,
 OUT_Error_num       OUT  NUMBER
)
IS
  CURSOR refundpost_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE x_auth_request_id  = In_Transaction_Id
      AND UPPER (x_payment_type) IN ('REFUND')
	  AND x_status = 'PENDING';

    refundpost_rec refundpost_cur%ROWTYPE;
	transreq_input_failed   EXCEPTION;

  CURSOR valid_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE x_auth_request_id  = In_Transaction_Id
      AND UPPER (x_payment_type) IN ('REFUND')
	    AND x_status in ('SUCCESS','FAILED');

     valid_rec valid_cur%ROWTYPE;

BEGIN
     OPEN valid_cur ;
     FETCH valid_cur INTO valid_rec;

     OPEN refundpost_cur ;
     FETCH refundpost_cur INTO refundpost_rec;
	  --> Validation rule 1 - Checking if the Refund was already processed:
    IF valid_cur%FOUND THEN
        IF valid_rec.x_status = 'SUCCESS' THEN
          OUT_Error_num      := 1;
          Out_Error_Msg      := 'Refund already processed';
        ELSE
          OUT_Error_num      := 1;
          Out_Error_Msg      := 'Refund already processed, and it is failed';
        END IF;

        CLOSE valid_cur;
        raise transreq_input_failed;
    --> Validation rule 2 - Checking if the Refund was initiated:
    ELSIF refundpost_cur%NOTFOUND THEN
		 OUT_Error_num    := 1;
		 Out_Error_Msg    := 'Refund was not initiated yet, please initiate';

		 CLOSE refundpost_cur;
		 raise transreq_input_failed;
    ELSE
      IF NVL(refundpost_rec.x_auth_amount,0) = 0 THEN
       OUT_Error_num    := 1;
       Out_Error_Msg    := 'Refund amount cannot be Zero';

       CLOSE refundpost_cur;
       raise transreq_input_failed;
      ELSE
        Out_X_Total_Amount :=	refundpost_rec.x_auth_amount;
      END IF;
		END IF;
	 CLOSE refundpost_cur;
   CLOSE valid_cur;

  Out_Error_Num := 0;
  Out_Error_Msg := 'SUCCESS';
EXCEPTION
  WHEN transreq_input_failed THEN
	sa.UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input Validation Failed', IP_KEY => 'In_Transaction_Id: '||In_Transaction_Id , IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.p_fetch_pymt_data', ip_error_text => Out_Error_Msg);
	ROLLBACK;
  WHEN OTHERS THEN
    OUT_Error_num      := 1;
    Out_Error_Msg := ( 'P_FETCH_PYMT_DATA failed due to' || SQLERRM || '.');
    sa.UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'In_Transaction_Id'||In_Transaction_Id , IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.p_fetch_pymt_data', ip_error_text => Out_Error_Msg);
    ROLLBACK;
END P_FETCH_PYMT_DATA;

PROCEDURE P_WRITE_EBAY_PYMT_TRANS_REQ
(
In_Transaction_Id    IN    VARCHAR2,
In_Rqst_Type          IN    VARCHAR2,
In_request_XML        IN    CLOB,
Out_Purch_Hdr_Objid   OUT   NUMBER,
Out_X_Payment_Objid   OUT   NUMBER,
Out_Error_Msg         OUT   VARCHAR2,
OUT_Error_num         OUT   NUMBER
)
IS
  CURSOR biz_hdr_cur
  IS
    SELECT *
    FROM X_Biz_Purch_Hdr
    WHERE X_Payment_Type ='REFUND'
    AND X_STATUS       = 'PENDING'
    AND x_auth_request_id = In_Transaction_Id;
  biz_hdr_rec biz_hdr_cur%Rowtype;

  CURSOR OBJID_CUR
  IS
    SELECT OBJID
    FROM X_PYMT_PROCESSOR
    WHERE X_NAME = 'EBAY_PAYPAL'
    AND X_TYPE   = 'TF_EBAY_PAYPAL_PYMT_TYPE'
    AND X_ACTIVE = 'Y';
  OBJID_REC X_PYMT_PROCESSOR.OBJID%TYPE;

  l_X_Payment_Objid     NUMBER;
  transreq_input_failed EXCEPTION;

BEGIN
 -- NULL Check
 IF In_Transaction_Id IS NULL  THEN
    Out_Error_Num    := 1;
    Out_Error_Msg    := 'Transaction_Id cannot be NULL';
    raise transreq_input_failed;
 ELSIF In_Rqst_Type IS NULL THEN
    Out_Error_Num    := 1;
    Out_Error_Msg    := 'Rqst_Type cannot be NULL';
    raise transreq_input_failed;
 END IF;

 l_X_Payment_Objid := sa.SEQ_X_PAYMENT.NEXTVAL;
 OPEN biz_hdr_cur;
 FETCH biz_hdr_cur INTO biz_hdr_rec;

 IF biz_hdr_cur%FOUND THEN
	 INSERT
		INTO X_PAYMENT
		  (
			Objid,
			X_REL_TRANS_ID,
			X_ORDER_ID,
			X_PYMT_STATUS,
			X_CREATE_DATE,
			X_UPDATE_DATE,
			X_AMOUNT,
			X_TAX_AMOUNT
		  )
		  VALUES
		  (
			l_X_Payment_Objid,
			In_Transaction_Id,
			biz_hdr_rec.c_orderid,
			 CASE in_Rqst_Type
			  WHEN 'REFUND'
			  THEN 'REFUND_PENDING'
			END,
			SYSDATE,
			SYSDATE,
			biz_hdr_rec.X_AMOUNT,
			biz_hdr_rec.X_TAX_AMOUNT
		  );

		OPEN OBJID_CUR;
		FETCH OBJID_CUR INTO OBJID_REC;
		IF OBJID_CUR%FOUND THEN
			INSERT
			INTO X_TRANSACTION
			  (
				OBJID,
				X_TRANS2PAYMENT,
				X_TRANS2PROCESSOR,
				X_TRANS_TYPE ,
				X_TRANS_DATE ,
				X_TRANS_STATUS,
				X_TRANS2PAYMENT_SOURCE,
				X_AMOUNT,
				X_Tax_Amount,
				X_REQUEST
			  )
			  VALUES
			  (
				Sequ_Biz_Purch_Dtl.Nextval,
				l_X_Payment_Objid,         -- X_Payment OBJID
				OBJID_REC,           -- EBAY_PAYPAL on X_Pymt_Processor
				in_Rqst_Type,
				Sysdate,
				CASE in_Rqst_Type
				  WHEN 'REFUND'
				  THEN 'REFUND_PENDING'
				END,
				biz_hdr_rec.prog_hdr2x_pymt_src,
				biz_hdr_rec.X_AMOUNT,
				biz_hdr_rec.X_TAX_AMOUNT,
				IN_request_XML
			  );
		END IF;
END IF;

CLOSE OBJID_CUR;
CLOSE biz_hdr_cur;

  Out_X_Payment_Objid := l_X_Payment_Objid;
  Out_Purch_Hdr_Objid := biz_hdr_rec.objid;
  OUT_Error_num       := 0;
  Out_Error_Msg       := 'SUCCESS';

EXCEPTION
WHEN transreq_input_failed THEN
   sa.UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input Validation Failed', IP_KEY => 'In_Transaction_Id: '||TO_CHAR (In_Transaction_Id), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.p_write_ebay_pymt_trans_req ', iP_ERROR_TEXT => Out_Error_Msg);
   ROLLBACK;
WHEN OTHERS THEN
  OUT_Error_num := -99;
  Out_Error_Msg := SUBSTR (SQLERRM, 1, 300)|| ' - ' ||dbms_utility.format_error_backtrace ;
  sa.UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'In_Transaction_Id '||TO_CHAR (In_Transaction_Id), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.p_write_ebay_pymt_trans_req ', iP_ERROR_TEXT => Out_Error_Msg);
  ROLLBACK;
END P_WRITE_EBAY_PYMT_TRANS_REQ ;

PROCEDURE P_WRITE_EBAY_PYMT_TRANS_REPLY
(
In_X_Payment_Objid    IN    NUMBER,
In_Rqst_Type          IN    VARCHAR2,
In_Tf_Transaction_Id  IN    VARCHAR2,
In_trans_status       IN    NUMBER,
In_Trans_Msg          IN    VARCHAR2,
In_response_XML       IN    CLOB,
Out_Error_Msg         OUT   VARCHAR2,
OUT_Error_num         OUT   NUMBER
)
IS
  l_X_Payment_Objid       NUMBER;
  transreply_input_failed EXCEPTION;
BEGIN
  IF In_X_Payment_Objid IS NULL THEN
    OUT_Error_num       := -374;
    out_error_msg       := 'X_Payment_Objid cannot be NULL';
    raise transreply_input_failed;
  ELSIF in_Rqst_Type IS NULL THEN
    OUT_Error_num       := -375;
    out_error_msg       := 'Rqst_Type cannot be NULL';
    raise transreply_input_failed;
  ELSIF In_trans_status IS NULL THEN
    OUT_Error_num       := -378;
    out_error_msg       := 'Trans_Status cannot be NULL';
    raise transreply_input_failed;
  ELSIF In_Tf_Transaction_Id IS NULL  THEN
    OUT_Error_num       := -376;
    out_error_msg       := 'Tf_Transaction_Id cannot be NULL';
    raise transreply_input_failed;
  ELSIF In_Trans_Msg IS NULL THEN
    OUT_Error_num       := -379;
    out_error_msg       := 'In_Trans_Msg cannot be NULL';
    raise transreply_input_failed;
  END IF;
    BEGIN
      UPDATE X_PAYMENT
      SET X_Trans_Id  = In_Tf_Transaction_Id,
          X_Pymt_Status =
          CASE in_Rqst_Type
            WHEN 'REFUND'
            THEN
               CASE In_Trans_Status
                 WHEN  0   THEN 'REFUND_SUCCESS'
                 WHEN  -1   THEN 'REFUND_FAILED'
               END
          END,
          X_UPDATE_DATE = SYSDATE
      WHERE Objid    = In_X_Payment_Objid;

	 FOR X_Trans IN
      (SELECT      *
       FROM X_TRANSACTION
       WHERE X_Trans_Status =
         CASE in_Rqst_Type
           WHEN 'REFUND'
           THEN 'REFUND_PENDING'
         END
      AND X_TRANS2PAYMENT = In_X_Payment_Objid
      )
      LOOP
        INSERT
        INTO X_TRANSACTION
          (
            OBJID,
            X_TRANS2PAYMENT,
            X_TRANS2PROCESSOR,
            X_TRANS_TYPE ,
            X_TRANS_DATE ,
            X_TRANS_STATUS,
            X_TRANS2PAYMENT_SOURCE,
            X_Amount,
            X_Tax_Amount,
            X_Transaction_Id,
            X_RESPONSE
          )
          VALUES
          (
            Sequ_Biz_Purch_Dtl.Nextval,
            In_X_Payment_Objid,        -- X_Payment OBJID
            X_Trans.X_Trans2processor, -- EBAY_PAYPAL on X_Pymt_Processor
            X_Trans.X_TRANS_TYPE,
            SYSDATE,
            CASE in_Rqst_Type
              WHEN 'REFUND'
              THEN
                CASE In_Trans_Status
                   WHEN  0   THEN 'REFUND_SUCCESS'
                   WHEN  -1   THEN 'REFUND_FAILED'
                 END
            END,
            X_Trans.X_Trans2payment_Source,
            X_Trans.X_Amount,
            X_Trans.X_Tax_Amount,
            NULL,
            In_response_XML
          );
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      Out_Error_Num := -380;
      Out_Error_Msg := 'Error in Update/insert' || (SUBSTR (Sqlerrm, 1, 300))|| ' - ' ||dbms_utility.format_error_backtrace ;
      raise transreply_input_failed;
    END;

  OUT_Error_num := 0;
  Out_Error_Msg := 'SUCCESS';
EXCEPTION
WHEN transreply_input_failed THEN
   sa.UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input Validation Failed', IP_KEY => 'In_Transaction_Id: ' ||TO_CHAR (In_Tf_Transaction_Id) || 'In_X_Payment_Objid: '||TO_CHAR (In_X_Payment_Objid), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.p_write_pymt_trans_reply', iP_ERROR_TEXT => Out_Error_Msg);
   ROLLBACK;
WHEN OTHERS THEN
  OUT_Error_num := -99;
  Out_Error_Msg := SUBSTR (SQLERRM, 1, 300)|| ' - ' ||dbms_utility.format_error_backtrace ;
  sa.UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'In_Transaction_Id: ' ||TO_CHAR (In_Tf_Transaction_Id) || 'In_X_Payment_Objid: '||TO_CHAR (In_X_Payment_Objid), IP_PROGRAM_NAME => 'PAYMENT_GATEWAY_PKG.p_write_pymt_trans_reply', iP_ERROR_TEXT => Out_Error_Msg);
  ROLLBACK;
END P_WRITE_EBAY_PYMT_TRANS_REPLY;
--CR38620 - Added for Ebay Integration - End
END PAYMENT_GATEWAY_PKG;
/