CREATE OR REPLACE PACKAGE BODY sa.PAYMENT_METHOD_PKG AS
  /********************************************************************************/
  /*    Copyright 2009 Tracfone  Wireless Inc. All rights reserved                */
  /*                                                                              */
  /* NAME     : PAYMENT_METHOD_PKG                                                */
  /* PURPOSE  : Package to handle all payment method related functionality        */
  /* FREQUENCY:                                                                   */
  /* PLATFORMS:                                                                   */
  /* REVISIONS:                                                                   */
  /*                                                                              */
  /* CR 16988: SOA 2011 project                                                   */
  /* VERSION DATE     WHO        PURPOSE                                          */
  /* ------- -------- ---------- -------------------------------------------------*/
  /* 1.0     06/21/11 vgeorge    Initial  Revision                                */
  /*                             Package body has been developed to support the   */
  /*                             payment method related features                  */
  /********************************************************************************/
  PROCEDURE retrieve_creditcard_list(
  p_esn                    IN table_part_inst.part_serial_no%TYPE,
  p_filter_out_expired        IN integer,
  p_result_set                 OUT sys_refcursor,
  p_error_code               OUT NUMBER,
  p_error_msg               OUT VARCHAR2
  )IS
  v_card_status varchar2(20);
  sql_stmt    varchar2(2000);
  sql_stmt2    varchar2(100);
  sql_stmt3    varchar2(300);
  sql_stmt4    varchar2(100);
  sql_stmt5    varchar2(400);
  BEGIN
    v_card_status := 'ALL';
    p_error_code  := 0;
    p_error_msg   := 'Success';
        sql_stmt :=            'SELECT';
        sql_stmt  := sql_stmt || '    PYMT.OBJID PYMT_OBJID,';
        sql_stmt  := sql_stmt || '    web.objid WEB_OBJID,';
        sql_stmt  := sql_stmt || '    contact.objid CONTACT_OBJID,';
        sql_stmt  := sql_stmt || '    cc.OBJID CC_OBJID,';
        sql_stmt  := sql_stmt || '    X_CREDIT_CARD2ADDRESS BILLING_OBJID,';
        sql_stmt  := sql_stmt || '    PYMT.X_PYMT_SRC_NAME SRCNAME,';
        sql_stmt  := sql_stmt || '    PYMT.X_PYMT_TYPE PYMTTYPE,';
        sql_stmt  := sql_stmt || '    PYMT.X_IS_DEFAULT ISDEFAULT,';
        sql_stmt  := sql_stmt || '    X_CUSTOMER_CC_NUMBER ACTNUMBER,';
        sql_stmt  := sql_stmt || '    pymt.x_status PYMTSTATUS,';
        sql_stmt  := sql_stmt || '    upper(cc.x_cc_type) ACTTYPE,';
        sql_stmt  := sql_stmt || '    cc.X_CUSTOMER_CC_CV_NUMBER SECURENUM,';
        sql_stmt  := sql_stmt || '    cc.x_customer_cc_expmo EXPIRY_MONTH,';
        sql_stmt  := sql_stmt || '    cc.x_customer_cc_expyr EXPIRY_YEAR,';
        sql_stmt  := sql_stmt || '    PYMT.X_BILLING_EMAIL,';
        sql_stmt  := sql_stmt || '    adds.ADDRESS,';
        sql_stmt  := sql_stmt || '    adds.ADDRESS_2,';
        sql_stmt  := sql_stmt || '    adds.CITY,adds.STATE,';
        sql_stmt  := sql_stmt || '    adds.ZIPCODE,';
        sql_stmt  := sql_stmt || '    cc.X_CUSTOMER_FIRSTNAME,';
        sql_stmt  := sql_stmt || '    cc.X_CUSTOMER_LASTNAME,';
        sql_stmt  := sql_stmt || '    cc.X_CUSTOMER_PHONE,';
        sql_stmt  := sql_stmt || '    X_MAX_PURCH_AMT';
    sql_stmt  := sql_stmt || '    FROM';
        sql_stmt  := sql_stmt || '    TABLE_ADDRESS                 adds,';
        sql_stmt  := sql_stmt || '    X_PAYMENT_SOURCE              pymt,';
        sql_stmt  := sql_stmt || '    TABLE_WEB_USER                web,';
        sql_stmt  := sql_stmt || '    TABLE_X_CREDIT_CARD           cc,';
        sql_stmt  := sql_stmt || '    MTM_CONTACT46_X_CREDIT_CARD3  mtmcc,';
        sql_stmt  := sql_stmt || '    TABLE_X_CONTACT_PART_INST     conpi,';
        sql_stmt  := sql_stmt || '    TABLE_PART_INST               pi,';
        sql_stmt  := sql_stmt || '    TABLE_CONTACT                 contact';
    sql_stmt  := sql_stmt || '    WHERE   adds.objid = cc.x_credit_card2address';
    sql_stmt  := sql_stmt ||   '  AND   pymt.x_pymt_type = ''CREDITCARD''';
        sql_stmt3  := sql_stmt3 || '  AND   pymt.pymt_src2x_credit_card = cc.objid';
        sql_stmt3  := sql_stmt3 || '  AND   pymt.pymt_src2web_user = web.objid';
        sql_stmt3  := sql_stmt3 || '  AND   web.web_user2contact = conpi.x_contact_part_inst2contact';
        sql_stmt5  := sql_stmt5 || '  AND   cc.objid = mtmcc.mtm_credit_card2contact';
        sql_stmt5  := sql_stmt5 || '  AND   mtmcc.mtm_contact2x_credit_card = conpi.x_contact_part_inst2contact';
        sql_stmt5  := sql_stmt5 || '  AND   conpi.x_contact_part_inst2part_inst = pi.objid';
        sql_stmt5  := sql_stmt5 || '  AND   contact.OBJID = web.WEB_USER2CONTACT';
    sql_stmt5  := sql_stmt5 || '  AND   pi.part_serial_no = to_char(:1)';           --- input parameter p_esn
    IF p_filter_out_expired = '1' THEN
        v_card_status := 'ACTIVE';
        /*** add the restriction about card status in the query ****/
            sql_stmt2  := '  AND   pymt.x_status = '''|| v_card_status ||'''';             --- v_card_status
            sql_stmt4  := '  AND   cc.x_card_status = '''|| v_card_status ||'''';             --- v_card_status
        sql_stmt  := sql_stmt || sql_stmt2 || sql_stmt3 || sql_stmt4 || sql_stmt5;
        ELSE
            v_card_status := 'ALL';
        sql_stmt  := sql_stmt || sql_stmt3 || sql_stmt5;
        END IF;
    OPEN p_result_set FOR sql_stmt USING p_esn;
  EXCEPTION
  WHEN OTHERS THEN
    p_error_code  := SQLCODE;
    p_error_msg   := SUBSTR(SQLERRM, 1, 100);
  END retrieve_creditcard_list;
END PAYMENT_METHOD_PKG;
/