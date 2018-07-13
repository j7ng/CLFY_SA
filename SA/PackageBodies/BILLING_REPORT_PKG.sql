CREATE OR REPLACE PACKAGE BODY sa."BILLING_REPORT_PKG"
IS
  FUNCTION getActiveBase
     ( p_date               IN DATE,
       p_business_line      IN NUMBER DEFAULT NULL,
       p_program_id         IN NUMBER DEFAULT NULL
     )
  RETURN  NUMBER
  IS
   l_active_base   NUMBER;

   BEGIN
    if ( p_program_id is null and p_business_line is null ) then
        select  sum ( case when x_action_type in ( 'ENROLLMENT','RE_ENROLL' ) then 1
                   when x_action_type in ( 'DE_ENROLL','DEENROLLED','SUSPENDED' ) then -1
              else null
              end ) ActiveBase
        into    l_active_base
        from    x_program_trans a, x_program_enrolled e
        where   a.pgm_tran2pgm_entrolled = e.objid
		-- Added for CR6666 -- Reporting purpose
		and a.x_reason not like ('%First Time Enrollment%')
      	and a.x_reason not like ('%Secondary Esn Enrollment Attempt%')
        and a.x_reason not like ('%Whitespace required%')
        and a.x_reason not like ('%No Benefits Granted%')
        and a.x_reason not like ('%could not connect%')
        and a.x_reason not like ('%out of wait period%')
        and a.x_reason not like ('%Post Pay Now%')
        and a.x_reason not like ('%Trying to Re Enroll%')
        and a.x_enrollment_status not in ('ENROLLMENTFAILED')
        and a.x_action_type in ('ENROLLMENT', 'RE_ENROLL', 'DE_ENROLL', 'DEENROLLED', 'SUSPENDED')
		-- End of CR6666 -- Reporting purpose
        and     trunc(a.x_trans_date) <= trunc(p_date);
    elsif ( p_program_id is null and p_business_line is not null ) then
            select  sum ( case when x_action_type in ( 'ENROLLMENT','RE_ENROLL' ) then 1
                   when x_action_type in ( 'DE_ENROLL','DEENROLLED','SUSPENDED' ) then -1
              else null
              end ) ActiveBase
        into    l_active_base
        from    x_program_trans a, x_program_enrolled e
        where   a.pgm_tran2pgm_entrolled = e.objid
		-- Added for CR6666 -- Reporting purpose
		and a.x_reason not like ('%First Time Enrollment%')
      	and a.x_reason not like ('%Secondary Esn Enrollment Attempt%')
        and a.x_reason not like ('%Whitespace required%')
        and a.x_reason not like ('%No Benefits Granted%')
        and a.x_reason not like ('%could not connect%')
        and a.x_reason not like ('%out of wait period%')
        and a.x_reason not like ('%Post Pay Now%')
        and a.x_reason not like ('%Trying to Re Enroll%')
        and a.x_enrollment_status not in ('ENROLLMENTFAILED')
        and a.x_action_type in ('ENROLLMENT', 'RE_ENROLL', 'DE_ENROLL', 'DEENROLLED', 'SUSPENDED')
		-- End of CR6666 -- Reporting purpose
        and     trunc(a.x_trans_date) <= trunc(p_date)
        and     exists ( select 1 from table_web_user where a.PGM_TRANS2WEB_USER = objid and WEB_USER2BUS_ORG = p_business_line );
    elsif ( p_program_id is not null and p_business_line is null ) then
        select  sum ( case when x_action_type in ( 'ENROLLMENT','RE_ENROLL' ) then 1
                   when x_action_type in ( 'DE_ENROLL','DEENROLLED','SUSPENDED' ) then -1
              else null
              end ) ActiveBase
        into    l_active_base
        from    x_program_trans a, x_program_enrolled e
        where   a.pgm_tran2pgm_entrolled = e.objid
		-- Added for CR6666 -- Reporting purpose
		and a.x_reason not like ('%First Time Enrollment%')
      	and a.x_reason not like ('%Secondary Esn Enrollment Attempt%')
        and a.x_reason not like ('%Whitespace required%')
        and a.x_reason not like ('%No Benefits Granted%')
        and a.x_reason not like ('%could not connect%')
        and a.x_reason not like ('%out of wait period%')
        and a.x_reason not like ('%Post Pay Now%')
        and a.x_reason not like ('%Trying to Re Enroll%')
        and a.x_enrollment_status not in ('ENROLLMENTFAILED')
        and a.x_action_type in ('ENROLLMENT', 'RE_ENROLL', 'DE_ENROLL', 'DEENROLLED', 'SUSPENDED')
		-- End of CR6666 -- Reporting purpose
        and     trunc(a.x_trans_date) <= trunc(p_date)
        and     e.pgm_enroll2pgm_parameter=p_program_id;
    elsif ( p_program_id is not null and p_business_line is not null ) then
            select  sum ( case when x_action_type in ( 'ENROLLMENT','RE_ENROLL' ) then 1
                   when x_action_type in ( 'DE_ENROLL','DEENROLLED','SUSPENDED' ) then -1
              else null
              end ) ActiveBase
        into    l_active_base
        from    x_program_trans a, x_program_enrolled e
        where   a.pgm_tran2pgm_entrolled = e.objid
		-- Added for CR6666 -- Reporting purpose
		and a.x_reason not like ('%First Time Enrollment%')
      	and a.x_reason not like ('%Secondary Esn Enrollment Attempt%')
        and a.x_reason not like ('%Whitespace required%')
        and a.x_reason not like ('%No Benefits Granted%')
        and a.x_reason not like ('%could not connect%')
        and a.x_reason not like ('%out of wait period%')
        and a.x_reason not like ('%Post Pay Now%')
        and a.x_reason not like ('%Trying to Re Enroll%')
        and a.x_enrollment_status not in ('ENROLLMENTFAILED')
        and a.x_action_type in ('ENROLLMENT', 'RE_ENROLL', 'DE_ENROLL', 'DEENROLLED', 'SUSPENDED')
		-- End of CR6666 -- Reporting purpose
        and     trunc(a.x_trans_date) <= trunc(p_date)
        and     e.pgm_enroll2pgm_parameter=p_program_id
        and     exists( select 1 from table_web_user where a.PGM_TRANS2WEB_USER = objid and WEB_USER2BUS_ORG = p_business_line );
    end if;

    return l_active_base;
   EXCEPTION
      WHEN OTHERS THEN
          RETURN 0 ;
   END;-- Function GETACTIVEBASE
   -- Enter further code below as specified in the Package spec.

   PROCEDURE    BILLING_REPORT (
        p_merchant_ref_number IN VARCHAR2  ,
        o_esn               OUT VARCHAR2 ,
        o_first_name        OUT VARCHAR2 ,
        o_last_name         OUT VARCHAR2 ,
    	o_login_name        OUT VARCHAR2 ,
        o_program_name      OUT VARCHAR2 ,  -- Can be multiple programs against an Order
        o_ENROLLED_DATE     OUT VARCHAR2 ,  -- Multiple enrollment dates for each of the program
        o_amount            OUT VARCHAR2 ,  -- Amount
        o_tax_amount        OUT VARCHAR2 ,
        o_e911_tax_amount   OUT VARCHAR2 ,
        o_total_amount      OUT VARCHAR2 ,
        o_PYMT_SRC_NAME     OUT VARCHAR2 ,
        o_starred_number    OUT VARCHAR2 ,
        o_source_system     OUT VARCHAR2 ,
        o_bus_org           OUT VARCHAR2 ,
        o_charge_freq       OUT VARCHAR2
        /* All the parameters are returned as Varchar, since this is used for display purposes only */
    )
    IS
        l_starred_number        VARCHAR2(20);
        l_payment_objid         x_payment_source.objid%TYPE;

        Cursor bill_cur is
        SELECT
            A.X_ESN                 ,
            B.X_PROGRAM_NAME        ,
    	    A.X_ENROLLED_DATE       ,
            CASE when B.X_CHARGE_FRQ_CODE = 'MONTHLY'    then 'Every month'
                 when B.X_CHARGE_FRQ_CODE = 'PASTDUE'    then 'On Deactivation Protection'
                 when B.X_CHARGE_FRQ_CODE = 'LOWBALANCE' then 'On Low Balance'
                 when B.X_CHARGE_FRQ_CODE = 'PASTDUE' then 'On Deactivation Protection'
                 when B.X_CHARGE_FRQ_CODE is null then ''
                 else 'Every ' || to_number(B.X_CHARGE_FRQ_CODE) || ' day(s).'
            end ChargeFrequency     ,
            ( select ORG_ID from table_bus_org where objid = B.PROG_PARAM2BUS_ORG ) bus_org,
            a.x_sourcesystem
        FROM
            X_PROGRAM_ENROLLED A  ,
            X_PROGRAM_PARAMETERS B,
            X_PROGRAM_PURCH_DTL C ,
            X_PROGRAM_PURCH_HDR D
        WHERE
            C.PGM_PURCH_DTL2PGM_ENROLLED  = A.OBJID AND
            A.PGM_ENROLL2PGM_PARAMETER    = B.OBJID AND
            C.PGM_PURCH_DTL2PROG_HDR      = D.OBJID AND
            A.X_IS_GRP_PRIMARY            = 1       AND
            D.X_MERCHANT_REF_NUMBER       in ( p_merchant_ref_number );
    BEGIN

        -- Get the contact and the billing details (20780250GNE1M4XX)
        SELECT
            A.FIRST_NAME        ,
            A.LAST_NAME         ,
            C.S_LOGIN_NAME      ,
            D.X_PYMT_SRC_NAME   ,
            D.OBJID             ,
            to_char(B.X_AMOUNT,'$9999999990.90')  x_amount,
            to_char(B.X_TAX_AMOUNT,'$9999999990.90') x_tax_amount,
            to_char(B.X_E911_TAX_AMOUNT,'$9999999990.90') x_e911_tax_amount,
            to_char(B.X_BILL_AMOUNT,'$9999999990.90' ) x_bill_amount
            INTO
            o_first_name        ,
            o_last_name         ,
            o_login_name        ,
            o_pymt_src_name     ,
            l_payment_objid     ,
            o_amount            ,
            o_tax_amount        ,
            o_e911_tax_amount   ,
            o_total_amount
       FROM
          TABLE_CONTACT A,
          X_PROGRAM_PURCH_HDR B,
          TABLE_WEB_USER C,
          X_PAYMENT_SOURCE D
      WHERE
          B.PROG_HDR2WEB_USER          = C.OBJID AND
          C.WEB_USER2CONTACT           = A.OBJID AND
          B.PROG_HDR2X_PYMT_SRC        = D.OBJID AND
          B.X_MERCHANT_REF_NUMBER      in ( p_merchant_ref_number );


        --- For the given payment source objid, get the encrypted/starred number for the account.
        select case when a.x_pymt_type = 'ACH' then  c.X_CUSTOMER_ACCT
                else b.X_CUSTOMER_CC_NUMBER
               end FundingSource
        into   l_starred_number
        from
               x_payment_source a,
               table_x_credit_card b,
               table_x_bank_account c
       where   a.objid = l_payment_objid
         and   a.PYMT_SRC2X_CREDIT_CARD = b.objid (+)
         and   a.PYMT_SRC2X_BANK_ACCOUNT = c.objid (+);

        ---- Encrypt the card number.
        o_starred_number := '**********' || substr(l_starred_number,length(l_starred_number)-3);

       -- Since there is a possibility of enrolling mul
       FOR idx IN bill_cur
       LOOP
            IF ( o_esn is not null ) THEN
                o_esn := o_esn || ',';
            END IF;
            o_esn := o_esn || idx.x_esn;


            IF ( o_program_name is not null ) THEN
                o_program_name := o_program_name || ',';
            END IF;
            o_program_name := o_program_name || idx.x_program_name;

            IF ( o_enrolled_date is not null ) THEN
                o_enrolled_date := o_enrolled_date || ',';
            END IF;
            o_enrolled_date := o_enrolled_date || idx.x_enrolled_date;

            IF ( o_charge_freq is not null ) THEN
                o_charge_freq := o_charge_freq || ',';
            END IF;
            o_charge_freq := o_charge_freq || idx.ChargeFrequency;


            IF ( o_bus_org is not null ) THEN
                o_bus_org := o_bus_org || ',';
            END IF;
            o_bus_org := o_bus_org || idx.bus_org;

            IF ( o_source_system is not null ) THEN
                o_source_system := o_source_system || ',';
            END IF;
            o_source_system := o_source_system || idx.x_sourcesystem;

         END LOOP;

    EXCEPTION
     WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
     END; -- Procedure BILLING_REPORT

END; -- Package Body BILLING_REPORT_PKG
/