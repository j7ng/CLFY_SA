CREATE OR REPLACE PROCEDURE sa."SP_IVR_PURCH_AUTH_VALIDATION" (i_esn                     IN  VARCHAR2,
                                                          i_order_id                IN  VARCHAR2,
                                                          i_pymnt_src_id            IN  NUMBER  ,
                                                          i_channel                 IN  VARCHAR2,
                                                          i_brand                   IN  VARCHAR2,
                                                          i_rqst_source             IN  VARCHAR2,
                                                          i_rqst_type               IN  VARCHAR2,
                                                          i_rqst_date               IN  DATE    ,
                                                          i_payment_type            IN  VARCHAR2,
                                                          i_language				        IN  VARCHAR2,
                                                          i_card_type				        IN  VARCHAR2,
                                                          i_new_registration		    IN	VARCHAR2,
                                                          i_calling_module_id		    IN	VARCHAR2,
                                                          i_web_user_login_id		    IN	VARCHAR2,
                                                          i_agent					          IN  VARCHAR2,
                                                          i_skip_enrollment			    IN	VARCHAR2,
                                                          i_merchant_id             IN  VARCHAR2,
                                                          i_merchant_ref_number	    IN	VARCHAR2,
                                                          i_customer_hostname       IN  VARCHAR2,
                                                          i_customer_ipaddress      IN  VARCHAR2,
                                                          i_customer_firstname      IN  VARCHAR2,
                                                          i_customer_lastname       IN  VARCHAR2,
                                                          i_customer_phone          IN  VARCHAR2,
                                                          i_customer_email          IN  VARCHAR2,
                                                          i_bill_address1           IN  VARCHAR2,
                                                          i_bill_address2           IN  VARCHAR2,
                                                          i_bill_city               IN  VARCHAR2,
                                                          i_bill_state              IN  VARCHAR2,
                                                          i_bill_zip                IN  VARCHAR2,
                                                          i_bill_country            IN  VARCHAR2,
                                                          i_amount                  IN  NUMBER  ,
                                                          i_auth_amount             IN  NUMBER  ,
                                                          i_bill_amount             IN  NUMBER  ,
                                                          i_e911_amount             IN  NUMBER  ,
                                                          i_usf_taxamount           IN  NUMBER  ,
                                                          i_rcrf_tax_amount         IN  NUMBER  ,
                                                          i_discount_amount         IN  NUMBER  ,
                                                          i_tax_amount             	IN	NUMBER  ,
                                                          i_preval_purch2creditcard IN  NUMBER  ,
                                                          i_preval_purch2bank_acct	IN	NUMBER  ,
                                                          i_agent_name              IN 	VARCHAR2,
                                                          i_preval_purch2esn        IN  NUMBER  ,
                                                          i_preval_purch2pymt_src   IN  NUMBER  ,
                                                          i_preval_purch2web_user   IN  NUMBER  ,
                                                          i_preval_purch2contact    IN  NUMBER  ,
                                                          i_preval_purch2rmsg_codes IN  NUMBER  ,
                                                          i_ecom_org_id				      IN  VARCHAR2,
                                                          i_account_id				      IN  VARCHAR2,
                                                          i_idn_user_change_last	  IN  VARCHAR2,
                                                          i_pre_val_purch_dtl_typ   IN  pre_val_purch_dtl_tab_type,
                                                          o_auth_flag               OUT VARCHAR2,
                                                          o_auth_issue              OUT VARCHAR2,
                                                          o_pv_hdr_objid            OUT VARCHAR2,
                                                          o_pv_dtl_objid            OUT VARCHAR2,
                                                          o_err_str                 OUT VARCHAR2,
                                                          o_err_num                 OUT NUMBER
                                                          )
IS
--Local Variables
l_interval_secs            NUMBER                 ;
l_auth_flag                VARCHAR2(1) := 'Y'     ;
l_tran_amt_flg             VARCHAR2(1) := 'N'     ;
l_cc_val_flag              VARCHAR2(1) := 'N'     ;
l_preval_purch2user        NUMBER                 ;
l_error_number             NUMBER                 ;
l_ics_rcode                VARCHAR2(30)           ;
l_pre_val_purch_hdr_objid  NUMBER                 ;
l_pre_val_purch_dtl_objid  NUMBER                 ;

BEGIN  --Main Section

   -- To retrieve the transaction interval seconds.
   BEGIN
       SELECT prm.x_param_value
       INTO   l_interval_secs
       FROM   table_x_parameters prm
       WHERE  prm.x_param_name = 'TRANSACTION_INTERVAL';
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
       o_err_num      := -1;
       o_err_str      := 'Transaction Parameter configuration missing. Please check';
       RETURN;

       WHEN OTHERS THEN
       o_err_num      := -2;
       o_err_str      := 'Parameter Configuration Error: '||substr(sqlerrm,1,100);
       RETURN;
   END;

   --To validate the transaction amount is within the specified range.
 BEGIN
  --
   IF i_channel IS NOT NULL THEN
     --
     IF i_channel <> 'B2C' THEN
        --
        IF i_brand = 'STRAIGHT_TALK' THEN
          BEGIN
             SELECT 'Y'
             INTO   l_tran_amt_flg
             FROM   table_x_cc_parms cp
             WHERE  cp.x_bus_org = i_channel||' '||i_brand
             AND    i_auth_amount BETWEEN cp.x_min_purch_amt AND cp. x_max_purch_amt;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             l_tran_amt_flg := 'N';
             o_err_num      := -3;
             o_err_str      := 'Authorization Amount is not within the specified range for ST';

           WHEN TOO_MANY_ROWS THEN
             l_tran_amt_flg := 'Y';
          END;
       ELSE
         BEGIN
             SELECT 'Y'
             INTO   l_tran_amt_flg
             FROM   table_x_cc_parms cp
             WHERE  cp.x_bus_org = i_channel
             AND    i_auth_amount BETWEEN cp.x_min_purch_amt AND cp. x_max_purch_amt;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             l_tran_amt_flg := 'N';
             o_err_num      := -4;
             o_err_str      := 'Authorization Amount is not within the specified range';
            WHEN TOO_MANY_ROWS THEN
              l_tran_amt_flg := 'Y';
         END;
       END IF;
     ELSE
       BEGIN
         SELECT 'Y'
         INTO   l_tran_amt_flg
         FROM   table_x_cc_parms cp
         WHERE  cp.x_bus_org = i_channel||' '||i_brand
         AND    i_auth_amount BETWEEN cp.x_min_purch_amt AND cp. x_max_purch_amt;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_tran_amt_flg := 'N';
                o_err_num      := -5;
                o_err_str      := 'Authorization Amount is not within the specified range for B2C';
           WHEN TOO_MANY_ROWS THEN
                l_tran_amt_flg := 'Y';
       END;
     END IF;
     --
    ELSE
       o_err_num      := -6;
       o_err_str      := 'Channel Cannot be NULL';
       RETURN;
    END IF;
 END;

   --To set the authorization flag based on the business logic
   BEGIN
       SELECT 'N'
       INTO   l_auth_flag
       FROM   x_biz_purch_hdr ph1,
              x_biz_purch_hdr ph2
       WHERE  ph1.x_esn                   = i_esn
       AND    ph2.prog_hdr2x_pymt_src     = i_pymnt_src_id
       AND    ph1.objid                   = ph2.objid
       AND    ph1.x_payment_type           IN ('AUTH','REFUND')
       AND    ph1.x_auth_amount            = i_auth_amount
       AND    (SYSDATE - ph1.x_rqst_date)  < l_interval_secs;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_auth_flag := 'Y';

       WHEN TOO_MANY_ROWS THEN
            l_auth_flag := 'N';
            o_err_num      := -6;
            o_err_str      := 'Transaction exists for given ESN and Payment source ID';
   END;

     --To check whether for the given payment source ID has valid credit card billing information.
     BEGIN
        IF I_RQST_SOURCE <> 'IVR' THEN -- CR47992
			SELECT
			CASE
			  WHEN cc.x_customer_cc_expmo  IS NOT NULL
			  AND  cc.x_customer_cc_expyr  IS NOT NULL
			  AND  addr.address            IS NOT NULL
			  AND  addr.city               IS NOT NULL
			  AND  addr.state              IS NOT NULL
			  AND  addr.zipcode            IS NOT NULL
			  THEN 'Y'
			  ELSE
			  'N'
			END
			INTO   l_cc_val_flag
			FROM   x_payment_source             ps,
				   table_x_credit_card          cc,
				   table_address                addr
			WHERE  ps.objid                  = i_pymnt_src_id
			AND    ps.pymt_src2x_credit_card = cc.objid
			AND    cc.x_credit_card2address  = addr.objid;
        ELSIF I_RQST_SOURCE = 'IVR' THEN -- CR47992 starts
			SELECT
			CASE
			  WHEN cc.x_customer_cc_expmo  IS NOT NULL
			  AND  cc.x_customer_cc_expyr  IS NOT NULL
			  AND  addr.zipcode            IS NOT NULL
			  THEN 'Y'
			  ELSE
			  'N'
			END
			INTO   l_cc_val_flag
			FROM   x_payment_source             ps,
				   table_x_credit_card          cc,
				   table_address                addr
			WHERE  ps.objid                  = i_pymnt_src_id
			AND    ps.pymt_src2x_credit_card = cc.objid
			AND    cc.x_credit_card2address  = addr.objid;
		END IF; -- CR47992 Ends

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_cc_val_flag := 'N';
            o_err_num      := -5;
            o_err_str      := 'Billing information is ndoe for given payment source id';

       WHEN TOO_MANY_ROWS THEN
            l_cc_val_flag := 'Y';
    END;

   --Checking the flag values to assign Authorized or Not Authorized.
   IF (l_auth_flag  = 'Y' AND  l_tran_amt_flg = 'Y' AND l_cc_val_flag = 'Y') THEN

      o_auth_flag  := 'Y'         ;
      o_auth_issue := 'Authorized';

    --Set error output variables for success scenario.
      o_err_num := 0              ;
      o_err_str := 'SUCCESS'      ;

   ELSE
      o_auth_flag  := 'N'             ;
      o_auth_issue := 'Not Authorized';

     IF i_agent_name IS NOT NULL THEN
      BEGIN
        SELECT  usr.objid
        INTO    l_preval_purch2user
        FROM    table_user usr
        WHERE   s_login_name = upper(i_agent_name);
      EXCEPTION
        WHEN OTHERS THEN
        NULL;
      END;
    END IF;

    BEGIN
        SELECT pc.x_code_num
        INTO   l_error_number
        FROM   table_x_purch_codes pc
        WHERE  pc.x_app        =  'CyberSource'
        AND    pc.x_code_type  =  'rflag'
        AND    pc.x_code_value =  'ERROR'
        AND    pc.x_language   =  'English'
        AND    pc.x_ics_rcode  =  l_ics_rcode;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
        WHEN TOO_MANY_ROWS THEN
        NULL;
        WHEN OTHERS THEN
        NULL;
    END;

   --Authorization failure error logging into x_pre_val_purch_hdr table.
   BEGIN
       --To assign the sequence next val to x_pre_val_purch_hdr.objid column
       SELECT sa.sequ_x_pre_val_purch_hdr.nextval
       INTO   l_pre_val_purch_hdr_objid
       FROM   DUAL;

       INSERT INTO sa.x_pre_val_purch_hdr
       (objid                           ,
        x_rqst_source                   ,
        x_rqst_type                     ,
        x_rqst_date                     ,
        x_payment_type                  ,
        x_brand_name                    ,
        x_language                      ,
        x_card_type                     ,
        x_new_registration              ,
        x_calling_module_id             ,
        x_web_user_login_id             ,
        x_agent                         ,
        x_skip_enrollment               ,
        x_merchant_id                   ,
        x_esn	                          ,
        x_merchant_ref_number           ,
        x_customer_hostname             ,
        x_customer_ipaddress            ,
        x_customer_firstname            ,
        x_customer_lastname             ,
        x_customer_phone                ,
        x_customer_email                ,
        x_bill_address1                 ,
        x_bill_address2                 ,
        x_bill_city                     ,
        x_bill_state                    ,
        x_bill_zip                      ,
        x_bill_country                  ,
        x_amount                        ,
        x_auth_amount                   ,
        x_bill_amount                   ,
        x_e911_amount                   ,
        x_usf_taxamount                 ,
        x_rcrf_tax_amount               ,
        x_discount_amount               ,
        x_tax_amount                    ,
        x_preval_purch2creditcard       ,
        x_preval_purch2bank_acct        ,
        x_preval_purch2user             ,
        x_preval_purch2esn              ,
        x_preval_purch2pymt_src         ,
        x_preval_purch2web_user         ,
        x_preval_purch2contact          ,
        x_preval_purch2rmsg_codes       ,
        x_error_number                  ,
        x_ecom_org_id                   ,
        x_c_orderid                     ,
        x_account_id                    ,
        x_idn_user_change_last          ,
        x_dte_change_last
        )
        VALUES
       (l_pre_val_purch_hdr_objid           ,
        i_rqst_source                       ,
        i_rqst_type                         ,
        i_rqst_date                         ,
        i_payment_type                      ,
        i_brand                             ,
        i_language                          ,
        i_card_type                         ,
        i_new_registration                  ,
        i_calling_module_id                 ,
        i_web_user_login_id                 ,
        i_agent                             ,
        i_skip_enrollment                   ,
        i_merchant_id                       ,
        i_esn	                              ,
        i_merchant_ref_number               ,
        i_customer_hostname                 ,
        i_customer_ipaddress                ,
        i_customer_firstname                ,
        i_customer_lastname                 ,
        i_customer_phone                    ,
        i_customer_email                    ,
        i_bill_address1                     ,
        i_bill_address2                     ,
        i_bill_city                         ,
        i_bill_state                        ,
        i_bill_zip                          ,
        i_bill_country                      ,
        i_amount                            ,
        i_auth_amount                       ,
        i_bill_amount                       ,
        i_e911_amount                       ,
        i_usf_taxamount                     ,
        i_rcrf_tax_amount                   ,
        i_discount_amount                   ,
        i_tax_amount                        ,
        i_preval_purch2creditcard           ,
        i_preval_purch2bank_acct            ,
        l_preval_purch2user                 ,
        i_preval_purch2esn                  ,
        i_preval_purch2pymt_src             ,
        i_preval_purch2web_user             ,
        i_preval_purch2contact              ,
        i_preval_purch2rmsg_codes           ,
        l_error_number                      ,
        i_ecom_org_id                       ,
        i_order_id                          ,
        i_account_id                        ,
        i_idn_user_change_last              ,
        SYSDATE
        );

        --Assigning pre val purch header objid to the out variable.
        o_pv_hdr_objid := l_pre_val_purch_hdr_objid;

      EXCEPTION
        WHEN OTHERS THEN
         o_err_num := -6;
         o_err_str := 'sp_ivr_purch_auth_validation - Insert x_pre_val_purch_hdr: '||substr(sqlerrm,1,100);
      END;

      --Authorization failure error logging into x_pre_val_purch_dtl table.
      BEGIN
          IF i_pre_val_purch_dtl_typ.COUNT > 0 THEN

              FOR i IN i_pre_val_purch_dtl_typ.FIRST .. i_pre_val_purch_dtl_typ.LAST
              LOOP

                --To assign the sequence next val to x_pre_val_purch_dtl.objid column
                SELECT sa.sequ_x_pre_val_purch_dtl.nextval
                INTO   l_pre_val_purch_dtl_objid
                FROM   DUAL;

                INSERT INTO sa.x_pre_val_purch_dtl
                (objid                            ,
                 x_part_numbers                   ,
                 x_card_qty                       ,
                 x_esn                            ,
                 x_program_type                   ,
                 x_program_name                   ,
                 x_cc_schedule_date               ,
                 x_count_esn_primary              ,
                 x_count_esn_secondary            ,
                 x_cc_scheduled                   ,
                 x_preval_purch2promotion         ,
                 x_promo_code                     ,
                 x_preval_pur_dtl2program         ,
                 x_preval_pur_dtl2pre_purch_hdr   ,
                 x_idn_user_change_last           ,
                 x_dte_change_last
                 )
                 VALUES
                (l_pre_val_purch_dtl_objid                               ,
                 i_pre_val_purch_dtl_typ(i).part_numbers                 ,
                 i_pre_val_purch_dtl_typ(i).card_qty                     ,
                 i_pre_val_purch_dtl_typ(i).esn                          ,
                 i_pre_val_purch_dtl_typ(i).program_type                 ,
                 i_pre_val_purch_dtl_typ(i).program_name                 ,
                 i_pre_val_purch_dtl_typ(i).cc_schedule_date             ,
                 i_pre_val_purch_dtl_typ(i).count_esn_primary            ,
                 i_pre_val_purch_dtl_typ(i).count_esn_secondary          ,
                 i_pre_val_purch_dtl_typ(i).cc_scheduled                 ,
                 i_pre_val_purch_dtl_typ(i).preval_purch2promotion       ,
                 i_pre_val_purch_dtl_typ(i).promo_code                   ,
                 i_pre_val_purch_dtl_typ(i).preval_pur_dtl2program       ,
                 i_pre_val_purch_dtl_typ(i).preval_pur_dtl2pre_purch_hdr ,
                 i_idn_user_change_last                                  ,
                 SYSDATE
                 );

            END LOOP;

         END IF;

        EXCEPTION
         WHEN OTHERS THEN
          o_err_num := -7;
          o_err_str := 'sp_ivr_purch_auth_validation - Insert x_pre_val_purch_dtl: '||substr(sqlerrm,1,100);
      END;

   END IF;

  EXCEPTION
   WHEN OTHERS THEN
      o_err_num := -10;
      o_err_str := 'sp_ivr_purch_auth_validation:  '||substr(sqlerrm,1,100);

      util_pkg.insert_error_tab ( i_action       => 'Purchase Auth Validation'     ,
                                  i_key          => i_esn                          ,
                                  i_program_name => 'sp_ivr_purch_auth_validation' ,
                                  i_error_text   => o_err_str
                                  );

END;
/