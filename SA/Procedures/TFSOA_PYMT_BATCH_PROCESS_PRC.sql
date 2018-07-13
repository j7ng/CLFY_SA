CREATE OR REPLACE PROCEDURE sa."TFSOA_PYMT_BATCH_PROCESS_PRC" (p_pymthdr_objid IN NUMBER,   p_pymt_res_type_rt IN OUT tf_pymt_response_type) AS
/*
CURSOR c_xref(p_auth_response VARCHAR2) IS
SELECT *
FROM tfsoa_xref
WHERE auth_auth_response = p_auth_response;
*/
--l_xref c_xref % rowtype;
v_pymt_type x_payment_source.x_pymt_type%TYPE;
v_pymt_ach_trans_type_rt tf_pymt_ach_trans_type;
l_error_message VARCHAR2(255);
v_process_error NUMBER := 0;
verrcode NUMBER := 0;
verrtxt VARCHAR2(100) := NULL;
vdbreturntype tf_pymt_db_return_type := NULL;
vStep    NUMBER := 0;
BEGIN

  p_pymt_res_type_rt.error_code := 0;

  vdbreturntype := tf_pymt_db_return_type('','','','','','','','','','','','','','','',0,'','','','','','','','',0,'');

  --vdbreturntype := tf_pymt_db_return_type(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);


  -- XREF Table refer before Loggin package so we don't need to use this condition anymore. Pradip Gupta -03/22/2011
  /*
  IF p_pymt_res_type_rt.auth_auth_response IS NOT NULL THEN

    OPEN c_xref(p_pymt_res_type_rt.auth_auth_response);
    FETCH c_xref
    INTO l_xref;

    IF c_xref % FOUND THEN
      p_pymt_res_type_rt.auth_rcode := l_xref.auth_rcode;
      p_pymt_res_type_rt.auth_rflag := l_xref.auth_rflag;
      p_pymt_res_type_rt.auth_rmsg := substr(l_xref.auth_rmsg,1,55);
      p_pymt_res_type_rt.ics_rcode := l_xref.ics_rcode;
      p_pymt_res_type_rt.ics_rflag := l_xref.ics_rflag;
      p_pymt_res_type_rt.ics_rmsg := l_xref.ics_rmsg;
    END IF;

    CLOSE c_xref;
  END IF;
  */
  vstep := vstep+1;
  --------------------------------------------------------------------------------------------
  ------- Update the payment header record with the response received from the payment gateway
  ----------------------------------------------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('TFSOA_PYMT_BATCH_PROCESS_PRC: UPDATING THE X_Program_Purch_Hdr, OBJID = ' || p_pymthdr_objid);

  IF v_process_error = 0 THEN
    BEGIN

      UPDATE x_program_purch_hdr
      SET x_ics_rcode = p_pymt_res_type_rt.ics_rcode,
        x_ics_rflag = p_pymt_res_type_rt.ics_rflag,
        x_ics_rmsg = p_pymt_res_type_rt.ics_rmsg,
        x_request_id = p_pymt_res_type_rt.request_id,
        X_AUTH_REQUEST_ID   = p_pymt_res_type_rt.AUTH_REQUEST_ID,
        x_auth_avs = p_pymt_res_type_rt.auth_auth_avs,
        x_auth_response = p_pymt_res_type_rt.auth_auth_response,
        x_auth_time = p_pymt_res_type_rt.auth_auth_time,
        x_auth_rcode = p_pymt_res_type_rt.auth_rcode,
        x_auth_code = p_pymt_res_type_rt.auth_auth_code,
        x_auth_rflag = p_pymt_res_type_rt.auth_rflag,
        x_auth_rmsg = p_pymt_res_type_rt.auth_rmsg,
        x_bill_request_time = p_pymt_res_type_rt.bill_bill_request_time,
        x_bill_rcode = p_pymt_res_type_rt.bill_rcode,
        x_bill_rflag = p_pymt_res_type_rt.bill_rflag,
        x_bill_rmsg = p_pymt_res_type_rt.bill_rmsg,
        x_bill_trans_ref_no = p_pymt_res_type_rt.bill_trans_ref_no,
        x_auth_amount = p_pymt_res_type_rt.auth_auth_amount,
        x_bill_amount = p_pymt_res_type_rt.bill_bill_amount,
        x_status = decode(p_pymt_res_type_rt.ics_rcode,   '100',   decode(x_rqst_type,   'ACH_PURCH',   x_status,   'SUCCESS'),
                                                          '1',     decode(x_rqst_type,   'ACH_PURCH',   x_status,   'SUCCESS'),
                                                          'FAILED') -- Check with payment system for the rcode.
      --- Incase of ACH success, do not change the status,
      --- since real success will be only after 5 days.
      WHERE objid = p_pymthdr_objid;

    EXCEPTION
    WHEN others THEN
      v_process_error := 1;
      verrcode := 1;
      verrtxt := SUBSTR(sqlerrm,   1,   100);
    END;
  END IF;
vstep := vstep+1;
  IF v_process_error = 1 THEN
    p_pymt_res_type_rt.error_code := verrcode;
    p_pymt_res_type_rt.error_desc := verrtxt;
  END IF;
vstep := vstep+1;
  ---------------------------------------------------------------------------------------------------------
  --- Get the Payment Type.
  ---------------------------------------------------------------------------------------------------------

  IF v_process_error = 0 THEN
    BEGIN
      SELECT b.x_pymt_type
      INTO v_pymt_type
      FROM x_program_purch_hdr a,
        x_payment_source b
      WHERE a.prog_hdr2x_pymt_src = b.objid
       AND a.objid = p_pymthdr_objid;

    EXCEPTION
    WHEN no_data_found THEN
      v_process_error := 1;
      verrcode := 2;
      verrtxt := '-TFSOA_PYMT_BATCH_PROCESS_PRC: CC Tran Record Not Found';
      --raise_application_error(-20001,   '-TFSOA_PYMT_BATCH_PROCESS_PRC: CC Tran Record Not Found');
    END;
  END IF;
vstep := vstep+1;
  IF v_process_error = 1 THEN
    p_pymt_res_type_rt.error_code := verrcode;
    p_pymt_res_type_rt.error_desc := verrtxt;
  END IF;
vstep := vstep+1;
  ---------------------------------------------------------------------------------------------------------
  --- Update ACH Transaction/ CC Transaction tables as well
  ---------------------------------------------------------------------------------------------------------

  IF v_process_error = 0 THEN

    IF v_pymt_type = 'CREDITCARD' THEN
      DBMS_OUTPUT.PUT_LINE('TFSOA_PYMT_BATCH_PROCESS_PRC: updating X_Cc_Prog_Trans');

      UPDATE x_cc_prog_trans
      SET x_auth_avs = p_pymt_res_type_rt.auth_auth_avs,
        x_auth_cv_result = p_pymt_res_type_rt.auth_cv_result
      WHERE x_cc_trans2x_purch_hdr = p_pymthdr_objid;

      IF SQL % rowcount = 0 THEN
        v_process_error := 1;
        verrcode := 3;
        verrtxt := '-TFSOA_PYMT_BATCH_PROCESS_PRC: CC Tran Record Not Found';
        -- raise_application_error(-20002,   '-TFSOA_PYMT_BATCH_PROCESS_PRC: CC Tran Record Not Found');
      END IF;

      ELSIF v_pymt_type = 'ACH' THEN
        DBMS_OUTPUT.PUT_LINE('TFSOA_PYMT_BATCH_PROCESS_PRC: updating X_Ach_Prog_Trans');
        v_pymt_ach_trans_type_rt := p_pymt_res_type_rt.ach_trans;

        UPDATE x_ach_prog_trans
        SET x_ecp_debit_request_id = v_pymt_ach_trans_type_rt.DEBIT_REQUEST_ID,
          x_ecp_debit_avs = v_pymt_ach_trans_type_rt.debit_avs_code,
          x_ecp_debit_avs_raw = v_pymt_ach_trans_type_rt.debit_avs_raw,
          x_ecp_rcode = v_pymt_ach_trans_type_rt.debit_ecp_rcode,
          x_ecp_trans_id = v_pymt_ach_trans_type_rt.DEBIT_ECP_TRANS_ID,
          x_ecp_result_code = v_pymt_ach_trans_type_rt.DEBIT_ECP_RESULT_CODE,
          x_ecp_rflag = v_pymt_ach_trans_type_rt.DEBIT_ECP_RFLAG,
          x_ecp_rmsg = v_pymt_ach_trans_type_rt.DEBIT_ECP_RMSG,
          x_ecp_debit_ref_number = v_pymt_ach_trans_type_rt.DEBIT_ECP_REF_NUMBER,
          x_ecp_ref_no = v_pymt_ach_trans_type_rt.DEBIT_ECP_REF_NO
        WHERE ach_trans2x_purch_hdr = p_pymthdr_objid;

        IF SQL % rowcount = 0 THEN
          v_process_error := 1;
          verrcode := 4;
          verrtxt := '-TFSOA_PYMT_BATCH_PROCESS_PRC: ACH Tran Record Not Found';
          -- raise_application_error(-20003,   '-TFSOA_PYMT_BATCH_PROCESS_PRC: ACH Tran Record Not Found');
        END IF;

      END IF;

      IF v_process_error = 1 THEN
        p_pymt_res_type_rt.error_code := verrcode;
        p_pymt_res_type_rt.error_desc := verrtxt;
      END IF;
-- Change made on 02/01/2011 Pradip Gupta
     -- IF(p_pymt_res_type_rt.ics_rcode NOT IN('1',   '100')) THEN
        l_error_message := sa.billing_payment_recon_pkg.payment_log(p_pymthdr_objid);
     -- END IF;

      -- Return Selection


     IF(p_pymt_res_type_rt.ics_rcode NOT IN('1',   '100')) THEN
       BEGIN
           SELECT  c.x_esn ESN,
                   c.pgm_enroll2pgm_parameter PROGRAM_ID,
                   a.x_ics_rcode ICS_RCODE,
                   a.x_rqst_type REQUEST_TYPE,
                   a.prog_hdr2x_pymt_src PAYMENT_SOURCE_ID,
                   c.X_SOURCESYSTEM,
                   bo.org_id,
                   c.X_LANGUAGE,
                   a.x_merchant_ref_number MERCHANT_REF_NUMBER,
                   a.prog_hdr2web_user WEB_USER_ID,
                   a.objid PURCHASE_HEADER_ID,
                   c.objid PROGRAM_ENROLL_ID,
                   d.X_PROGRAM_NAME,
                   nvl(c.x_grace_period,0) X_GRACE_PERIOD,
                   f.first_name,
                   f.last_name
           INTO  vDbReturnType.ESN,
                 vDbReturnType.PROGRAM_ID,
                 vDbReturnType.ICS_RCODE,
                 vDbReturnType.REQUEST_TYPE,
                 vDbReturnType.PAYMENT_SOURCE_ID,
                 vDbReturnType.SOURCE_SYSTEM,
                 vDbReturnType.ORG_ID,
                 vDbReturnType.LANGUAGE,
                 vDbReturnType.MERCHANT_REF_NUMBER,
                 vDbReturnType.WEB_USER_ID,
                 vDbReturnType.PURCHASE_HEADER_ID,
                 vDbReturnType.PROGRAM_ENROLL_ID,
                 vDbReturnType.PROGRAM_NAME,
                 vDbReturnType.GRACE_PERIOD,
                 vDbReturnType.CUSTOMER_FIRST_NAME,
                 vDbReturnType.CUSTOMER_LAST_NAME

           FROM table_contact f,
                table_web_user e,
                x_program_parameters d,
                x_program_enrolled c,
                x_program_purch_dtl b,
                x_program_purch_hdr a,
                table_bus_org bo
          WHERE 1=1
            AND f.objid = e.WEB_USER2CONTACT
            AND e.objid = a.prog_hdr2web_user
            AND d.objid = c.PGM_ENROLL2PGM_PARAMETER
            AND c.x_is_grp_primary =1
            AND c.objid = b.pgm_purch_dtl2pgm_enrolled
            AND b.pgm_purch_dtl2prog_hdr = a.objid
            AND d.prog_param2bus_org = bo.objid
            AND a.x_status||'' = 'FAILED'
            AND a.objid= p_pymthdr_objid;

       EXCEPTION
         WHEN OTHERS THEN
         vstep := 98;

              vDbReturnType.ESN                     := NULL;
              vDbReturnType.PROGRAM_ID              := NULL;
              vDbReturnType.ICS_RCODE               := NULL;
              vDbReturnType.REQUEST_TYPE            := NULL;
              vDbReturnType.PAYMENT_SOURCE_ID       := NULL;
              vDbReturnType.SOURCE_SYSTEM           := NULL;
              vDbReturnType.ORG_ID                  := NULL;
              vDbReturnType.LANGUAGE                := NULL;
              vDbReturnType.MERCHANT_REF_NUMBER     := NULL;
              vDbReturnType.WEB_USER_ID             := NULL;
              vDbReturnType.PURCHASE_HEADER_ID      := NULL;
              vDbReturnType.PROGRAM_ENROLL_ID       := NULL;
              vDbReturnType.PROGRAM_NAME            := NULL;
              vDbReturnType.GRACE_PERIOD            := NULL;
              vDbReturnType.CUSTOMER_FIRST_NAME     := NULL;
              vDbReturnType.CUSTOMER_LAST_NAME      := NULL;

       END;
     ELSE


            -- vDbReturnType.CUSTOMER_FIRST_NAME           := 'PRADIP - '||p_pymthdr_objid;
            -- vDbReturnType.CUSTOMER_LAST_NAME            := 'PRADIP';



       BEGIN

       -- Change made on 2/2/2011 Take out x_program_notify table now - Pradip Gupta(Oracle)
       /*
           SELECT   a.objid,
                    b.first_name,
                    b.last_name,
                    a.x_esn,
                    a.x_language,
                    a.x_program_name,
                    a.x_source_system,
                    bo.org_id,
                    a.pgm_notify2web_user webUserObjId,
                    c.prog_hdr2x_pymt_src paymentSourceObjId,
                    x_bill_amount,
                    TO_CHAR(TO_DATE (SUBSTR (c.x_bill_request_time, 1, 10),'YYYY/MM/DD'),'MM/DD/YYYY') paymentdate,
                    c.x_merchant_ref_number
           INTO  vDbReturnType.PROGRAM_NOTIFY_OBJ_ID,
                 vDbReturnType.CUSTOMER_FIRST_NAME,
                 vDbReturnType.CUSTOMER_LAST_NAME,
                 vDbReturnType.ESN,
                 vDbReturnType.LANGUAGE,
                 vDbReturnType.PROGRAM_NAME,
                 vDbReturnType.SOURCE_SYSTEM,
                 vDbReturnType.ORG_ID,
                 vDbReturnType.WEB_USER_ID,
                 vDbReturnType.PAYMENT_SOURCE_ID,
                 vDbReturnType.BILL_AMOUNT,
                 vDbReturnType.BILL_REQUEST_TIME,
                 vDbReturnType.MERCHANT_REF_NUMBER
           FROM
                x_payment_source d,
                x_program_purch_hdr c,
                table_contact b,
                table_web_user web,
                x_program_notify a,
                x_program_parameters pp,
                table_bus_org bo
          WHERE 1=1
            AND d.objid = c.prog_hdr2x_pymt_src
            AND c.objid = a.pgm_notify2purch_hdr
            AND b.objid = web.web_user2contact
            AND web.objid = a.pgm_notify2web_user
            AND pp.objid = a.pgm_notify2pgm_objid
            AND bo.objid = pp.prog_param2bus_org
            AND TRUNC (a.x_process_date) <= SYSDATE
            AND a.x_notify_process = 'PAYMENT_HDR_SUCCESS'
            AND a.x_notify_status = 'PENDING'
            and c.objid = p_pymthdr_objid
            and a.objid = (select max(objid) from x_program_notify where pgm_notify2purch_hdr = p_pymthdr_objid);
            */
            SELECT  c.x_esn ESN,
                   c.pgm_enroll2pgm_parameter PROGRAM_ID,
                   a.x_ics_rcode ICS_RCODE,
                   a.x_rqst_type REQUEST_TYPE,
                   a.prog_hdr2x_pymt_src PAYMENT_SOURCE_ID,
                   c.X_SOURCESYSTEM,
                   bo.org_id,
                   c.X_LANGUAGE,
                   a.x_merchant_ref_number MERCHANT_REF_NUMBER,
                   a.prog_hdr2web_user WEB_USER_ID,
                   a.objid PURCHASE_HEADER_ID,
                   c.objid PROGRAM_ENROLL_ID,
                   d.X_PROGRAM_NAME,
                   nvl(c.x_grace_period,0) X_GRACE_PERIOD,
                   f.first_name,
                   f.last_name,
                   a.x_bill_amount,
                   TO_CHAR(TO_DATE (SUBSTR (a.x_bill_request_time, 1, 10),'YYYY/MM/DD'),'MM/DD/YYYY') paymentdate,
                   a.x_merchant_ref_number
           INTO  vDbReturnType.ESN,
                 vDbReturnType.PROGRAM_ID,
                 vDbReturnType.ICS_RCODE,
                 vDbReturnType.REQUEST_TYPE,
                 vDbReturnType.PAYMENT_SOURCE_ID,
                 vDbReturnType.SOURCE_SYSTEM,
                 vDbReturnType.ORG_ID,
                 vDbReturnType.LANGUAGE,
                 vDbReturnType.MERCHANT_REF_NUMBER,
                 vDbReturnType.WEB_USER_ID,
                 vDbReturnType.PURCHASE_HEADER_ID,
                 vDbReturnType.PROGRAM_ENROLL_ID,
                 vDbReturnType.PROGRAM_NAME,
                 vDbReturnType.GRACE_PERIOD,
                 vDbReturnType.CUSTOMER_FIRST_NAME,
                 vDbReturnType.CUSTOMER_LAST_NAME,
                 vDbReturnType.BILL_AMOUNT,
                 vDbReturnType.BILL_REQUEST_TIME,
                 vDbReturnType.MERCHANT_REF_NUMBER
           FROM table_contact f,
                table_web_user e,
                x_program_parameters d,
                x_program_enrolled c,
                x_program_purch_dtl b,
                x_program_purch_hdr a,
                table_bus_org bo
          WHERE 1=1
            AND f.objid = e.WEB_USER2CONTACT
            AND e.objid = a.prog_hdr2web_user
            AND d.objid = c.PGM_ENROLL2PGM_PARAMETER
            AND c.x_is_grp_primary =1
            AND c.objid = b.pgm_purch_dtl2pgm_enrolled
            AND b.pgm_purch_dtl2prog_hdr = a.objid
            AND d.prog_param2bus_org = bo.objid
            AND a.objid= p_pymthdr_objid;

            /* 02/25/2011 Pradip Gupta
            SELECT   NULL,
                    b.first_name,
                    b.last_name,
                    --a.x_esn,
                    b1.x_esn,
                    --a.x_language,
                    c1.x_language,
                    --a.x_program_name,
                    pp.x_program_name,
                    --a.x_source_system,
                    c1.X_SOURCESYSTEM,
                    bo.org_id,
                    --a.pgm_notify2web_user webUserObjId,
                    web.objid webUserObjId,
                    c.prog_hdr2x_pymt_src paymentSourceObjId,
                    x_bill_amount,
                    TO_CHAR(TO_DATE (SUBSTR (c.x_bill_request_time, 1, 10),'YYYY/MM/DD'),'MM/DD/YYYY') paymentdate,
                    c.x_merchant_ref_number
           INTO  vDbReturnType.PROGRAM_NOTIFY_OBJ_ID,
                 vDbReturnType.CUSTOMER_FIRST_NAME,
                 vDbReturnType.CUSTOMER_LAST_NAME,
                 vDbReturnType.ESN,
                 vDbReturnType.LANGUAGE,
                 vDbReturnType.PROGRAM_NAME,
                 vDbReturnType.SOURCE_SYSTEM,
                 vDbReturnType.ORG_ID,
                 vDbReturnType.WEB_USER_ID,
                 vDbReturnType.PAYMENT_SOURCE_ID,
                 vDbReturnType.BILL_AMOUNT,
                 vDbReturnType.BILL_REQUEST_TIME,
                 vDbReturnType.MERCHANT_REF_NUMBER

           FROM
                x_payment_source d,
                x_program_purch_hdr c,
                x_program_enrolled c1,
                table_contact b,
                x_program_purch_dtl b1,
                table_web_user web,
                x_program_notify a,
                x_program_parameters pp,
                table_bus_org bo
          WHERE 1=1
            AND d.objid = c.prog_hdr2x_pymt_src
            AND c.objid = a.pgm_notify2purch_hdr
            AND b.objid = web.web_user2contact
            AND b1.pgm_purch_dtl2prog_hdr = c.objid
            AND c1.x_is_grp_primary =1
            AND c1.objid = b1.pgm_purch_dtl2pgm_enrolled
            AND web.objid = a.pgm_notify2web_user
            AND pp.objid = a.pgm_notify2pgm_objid
            AND bo.objid = pp.prog_param2bus_org
            AND TRUNC (a.x_process_date) <= SYSDATE
            --AND a.x_notify_process = 'PAYMENT_HDR_SUCCESS'
            --AND a.x_notify_status = 'PENDING'
            and c.objid = p_pymthdr_objid;
           -- and a.objid = (Select DECODE((select max(objid) from x_program_notify where pgm_notify2purch_hdr = p_pymthdr_objid),NULL,a.objid ,(select max(objid) from x_program_notify where pgm_notify2purch_hdr = p_pymthdr_objid)) from dual);
            --and a.objid = (select max(objid) from x_program_notify where pgm_notify2purch_hdr = p_pymthdr_objid);
*/
       EXCEPTION
         WHEN OTHERS THEN

              verrcode := -99;
              --p_pymt_res_type_rt.error_code := -99;
              --p_pymt_res_type_rt.error_desc := SQLCODE ||'('||vstep||')'|| '-TFSOA_PYMT_BATCH_PROCESS_PRC: No data Found';

              vDbReturnType.PROGRAM_NOTIFY_OBJ_ID         := NULL;
              vDbReturnType.CUSTOMER_FIRST_NAME           := NULL;
              vDbReturnType.CUSTOMER_LAST_NAME            := NULL;
              vDbReturnType.ESN                           := NULL;
              vDbReturnType.LANGUAGE                      := NULL;
              vDbReturnType.PROGRAM_NAME                  := NULL;
              vDbReturnType.SOURCE_SYSTEM                 := NULL;
              vDbReturnType.ORG_ID                        := NULL;
              vDbReturnType.WEB_USER_ID                   := NULL;
              vDbReturnType.PAYMENT_SOURCE_ID             := NULL;
              vDbReturnType.BILL_AMOUNT                   := NULL;
              vDbReturnType.BILL_REQUEST_TIME             := NULL;
              vDbReturnType.MERCHANT_REF_NUMBER           := NULL;

       END;

     END IF;

END IF;
vstep := vstep+1;
 -- Update the reply Type
      p_pymt_res_type_rt.db_response := vdbreturntype;

    EXCEPTION
    WHEN no_data_found THEN
       p_pymt_res_type_rt.error_code := -20004;
      p_pymt_res_type_rt.error_desc := SQLCODE ||'('||vstep||')'|| '-TFSOA_PYMT_BATCH_PROCESS_PRC: No data Found';
      --raise_application_error(-20004,   );
    WHEN others THEN
      p_pymt_res_type_rt.error_code := -900;
      p_pymt_res_type_rt.error_desc := SQLCODE ||'('||vstep||')'|| '-TFSOA_PYMT_BATCH_PROCESS_PRC: ' || SUBSTR(sqlerrm,   1,   170);
    END tfsoa_pymt_batch_process_prc;
/