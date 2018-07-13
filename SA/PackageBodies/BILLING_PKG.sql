CREATE OR REPLACE PACKAGE BODY sa.billing_pkg
AS
--To retrieve the next cycle date for given program parameter objid
FUNCTION get_next_cycle_date(i_prog_param_objid   IN NUMBER,
                             i_current_cycle_date IN DATE
                             )
RETURN DATE
IS
   l_next_cycle_date DATE;


BEGIN --Main Section
      SELECT DECODE (x_charge_frq_code,
                     'MONTHLY',
                     ADD_MONTHS (TRUNC(SYSDATE), 1),
                     'LOWBALANCE',
                     NULL,
                     'PASTDUE',
                     NULL,
                     TRUNC(SYSDATE)+ TO_NUMBER(x_charge_frq_code))
      INTO   l_next_cycle_date
      FROM   x_program_parameters
      WHERE  objid = i_prog_param_objid;

      RETURN l_next_cycle_date;

    EXCEPTION
         WHEN OTHERS THEN
         billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_next_cycle_date'      ,
                                              i_key      =>  i_prog_param_objid                    ,
                                              i_err_num  =>  SQLCODE                               ,
                                              i_err_msg  =>  SUBSTR (SQLERRM, 1, 100)              ,
                                              i_desc     =>  'Error while retrieve next cycle date',
                                              i_severity =>  2 -- MEDIUM
                                             );
END get_next_cycle_date;
--
FUNCTION get_merchant_id(i_bus_org             IN VARCHAR2,
                         i_pgm_enroll_objid    IN NUMBER,
                         i_pgm_parameter_objid IN NUMBER,
                         i_multimerchant_flag  IN BOOLEAN)
RETURN VARCHAR2
IS
l_count NUMBER :=0;
l_merchant_id VARCHAR2(100);
BEGIN
        IF (i_multimerchant_flag = FALSE) THEN
                BEGIN
                  SELECT DECODE (i_bus_org, 'TRACFONE', 'tracfone', x_merchant_id )
                  INTO l_merchant_id
                  FROM table_x_cc_parms
                  WHERE x_bus_org = i_bus_org;

                EXCEPTION
                 WHEN OTHERS THEN

                  billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_merchant_id'   ,
                                                       i_key      =>  i_pgm_enroll_objid                          ,
                                                       i_err_num  =>  SQLCODE                            ,
                                                       i_err_msg  =>  SUBSTR (SQLERRM, 1, 100)           ,
                                                       i_desc     =>  'No merchant parameter settings found in table_x_cc_params for the business organization',
                                                       i_severity =>  2 );-- MEDIUM);
                   l_merchant_id := NULL;
                END;


        ELSE
                --------------- Multi merchant ID ----------------
                BEGIN
                  ----CR13581
                  SELECT COUNT(*)
                  INTO l_count
                  FROM Table_Web_User,
                    X_Business_Accounts,
                    x_program_enrolled
                  WHERE Web_User2contact       = Bus_Primary2contact
                  AND Pgm_Enroll2web_User      = Table_Web_User.Objid
                  AND x_program_enrolled.objid = i_pgm_enroll_objid; --

                  IF l_count > 0 THEN --Business Account B2B
                    SELECT x_merchant_id
                    INTO l_merchant_id
                    FROM Table_X_Cc_Parms
                    WHERE X_Bus_Org = 'BILLING B2B';
                  ELSE -- regular account            ---   CR13581
                    SELECT x_merchant_id
                    INTO l_merchant_id
                    FROM table_x_cc_parms
                    WHERE x_bus_org =
                      (SELECT 'BILLING '
                        ||(
                        CASE
                          WHEN x_program_name NOT IN ('Straight Talk REMOTE ALERT 30 D','Straight Talk REMOTE ALERT 365 D')
                          THEN org_id
                          ELSE 'REMOTE_ALERT'
                        END)
                      FROM table_bus_org bo,
                        x_program_parameters pp
                      WHERE bo.objid = prog_param2bus_org
                      AND pp.objid   = i_pgm_parameter_objid
                      );
                 END IF; --------CR13581
                EXCEPTION
                 WHEN OTHERS THEN
                   billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_merchant_id'   ,
                                                        i_key      =>  i_pgm_enroll_objid                 ,
                                                        i_err_num  =>  SQLCODE                            ,
                                                        i_err_msg  =>  SUBSTR (SQLERRM, 1, 100)           ,
                                                        i_desc     =>  'No merchant parameter settings found in table_x_cc_params for the business organization',
                                                       i_severity =>  2 );-- MEDIUM);
                    l_merchant_id := NULL;
                END;
        END IF;

   RETURN l_merchant_id;

EXCEPTION
 WHEN OTHERS THEN
    billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_merchant_id'   ,
                                         i_key      =>  i_pgm_enroll_objid                 ,
                                         i_err_num  =>  SQLCODE                            ,
                                         i_err_msg  =>  SUBSTR (SQLERRM, 1, 100)           ,
                                         i_desc     =>  'No merchant parameter settings found in table_x_cc_params for the business organization',
                                         i_severity =>  2 );-- MEDIUM);
    RETURN l_merchant_id;

END get_merchant_id;

--To retrieve payment type for the given payment source id
PROCEDURE get_payment_type(i_pymnt_src_objid   IN  NUMBER                   ,
                           o_pymnt_src_rec     OUT x_payment_source%ROWTYPE ,
                           o_errnum            OUT NUMBER                   ,
                           o_errstr            OUT VARCHAR2
                           )
AS
--Local Variables
l_payment_source_type VARCHAR2(30);
l_credit_card_objid   NUMBER      ;
l_bank_account_objid  NUMBER      ;

BEGIN  --Main Section

    BEGIN

        SELECT ps.*
        INTO   o_pymnt_src_rec
        FROM   x_payment_source ps
        WHERE  objid = i_pymnt_src_objid;

      EXCEPTION
            WHEN OTHERS THEN
            o_errnum  := 1025;
            o_errstr  := 'get_payment_type:  '||substr(sqlerrm,1,100);
            billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_payment_type'            ,
                                                 i_key      =>  i_pymnt_src_objid                            ,
                                                 i_err_num  =>  o_errnum                                     ,
                                                 i_err_msg  =>  o_errstr                                     ,
                                                 i_desc     =>  'Error while retrieve payment source details',
                                                 i_severity =>  2 -- MEDIUM
                                                 );
        END;

END get_payment_type;
--
PROCEDURE get_credit_card_info (i_credit_card_objid IN   NUMBER                     ,
                                o_credit_card_rec   OUT  table_x_credit_card%ROWTYPE,
                                o_errnum            OUT  NUMBER                     ,
                                o_errstr            OUT  VARCHAR2
                                )
AS
BEGIN --Main Section

         BEGIN
            SELECT objid                                                       ,
                   x_customer_cc_number                                        ,
                   x_customer_cc_expmo                                         ,
                   x_customer_cc_expyr                                         ,
                   x_cc_type                                                   ,
                   x_customer_cc_cv_number                                     ,
                   x_customer_firstname                                        ,
                   x_customer_lastname                                         ,
                   x_customer_phone                                            ,
                   x_customer_email                                            ,
                   x_max_purch_amt                                             ,
                   x_max_trans_per_month                                       ,
                   x_max_purch_amt_per_month                                   ,
                   x_changedate                                                ,
                   x_original_insert_date                                      ,
                   x_changedby                                                 ,
                   x_cc_comments                                               ,
                   x_moms_maiden                                               ,
                   x_credit_card2contact                                       ,
                   x_credit_card2address                                       ,
                   x_card_status                                               ,
                   x_max_ild_purch_amt                                         ,
                   x_max_ild_purch_month                                       ,
                   x_credit_card2bus_org                                       ,
                   x_cust_cc_num_key                                           ,
                   x_cust_cc_num_enc                                           ,
                   creditcard2cert
            INTO   o_credit_card_rec
            FROM   table_x_credit_card
            WHERE  objid = i_credit_card_objid;

        EXCEPTION
            WHEN OTHERS THEN
               o_errnum  := 1026;
               o_errstr  := 'get_credit_card_info:  '||substr(sqlerrm,1,100);
               billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_credit_card_info'         ,
                                                    i_key      =>  i_credit_card_objid                           ,
                                                    i_err_num  =>  o_errnum                                      ,
                                                    i_err_msg  =>  o_errstr                                      ,
                                                    i_desc     =>  'Error while retrieve credit card information',
                                                    i_severity =>  2
                                                    );
         END;

END get_credit_card_info;
--
PROCEDURE get_bank_info (i_bank_account_objid IN   NUMBER                      ,
                         o_bank_acount_rec    OUT  table_x_bank_account%ROWTYPE,
                         o_errnum             OUT  NUMBER                      ,
                         o_errstr             OUT  VARCHAR2
                         )
AS
BEGIN --Main Section

              BEGIN
                SELECT objid                                                     ,
                       x_bank_num                                                ,
                       x_customer_acct                                           ,
                       x_routing                                                 ,
                       DECODE(x_aba_transit, 'SAVINGS', 'S', 'CHECKING', 'C', 'CORPORATE', 'X', x_aba_transit) x_aba_transit,
                       x_bank_name                                               ,
                       x_status                                                  ,
                       regexp_replace(x_customer_firstname, '[^0-9 a-za-z]', '') ,
                       regexp_replace(x_customer_lastname, '[^0-9 a-za-z]', '')  ,
                       x_customer_phone                                          ,
                       x_customer_email                                          ,
                       x_max_purch_amt                                           ,
                       x_max_trans_per_month                                     ,
                       x_max_purch_amt_per_month                                 ,
                       x_changedate                                              ,
                       x_original_insert_date                                    ,
                       x_changedby                                               ,
                       x_cc_comments                                             ,
                       x_moms_maiden                                             ,
                       x_bank_acct2contact                                       ,
                       x_bank_acct2address                                       ,
                       x_bank_account2bus_org                                    ,
                       bank2cert                                                 ,
                       x_customer_acct_key                                       ,
                       x_customer_acct_enc
                 INTO  o_bank_acount_rec
                 FROM  table_x_bank_account
                 WHERE objid = i_bank_account_objid;
             EXCEPTION
                WHEN OTHERS THEN
                    o_errnum  := 1027;
                    o_errstr  := 'get_bank_info:  '||substr(sqlerrm,1,100);
                                        billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_bank_info'             ,
                                                                             i_key      =>  i_bank_account_objid                       ,
                                                                             i_err_num  =>  SQLCODE                                    ,
                                                                             i_err_msg  =>  SUBSTR (SQLERRM, 1, 100)                   ,
                                                                             i_desc     =>  'Error while retrieve bank account details',
                                                                             i_severity =>  2
                                                                            );
             END;
--
END get_bank_info;
--
-- To retrieve address information
PROCEDURE get_address_info(i_address_objid  IN   NUMBER               ,
                           o_address_rec    OUT table_address%ROWTYPE ,
                           o_errnum         OUT  NUMBER               ,
                           o_errstr         OUT  VARCHAR2
                           )
AS
BEGIN --Main Section

            BEGIN
              SELECT a.objid                                           ,
                     regexp_replace(a.address, '[^0-9 A-Za-z.-]', '')  ,
                     regexp_replace(a.s_address, '[^0-9 A-Za-z.-]', ''),
                     regexp_replace(a.city, '[^0-9 A-Za-z.-]', '')     ,
                     regexp_replace(a.s_city, '[^0-9 A-Za-z.-]', '')   ,
                     NVL(b.x_state,a.state)                            ,
                     regexp_replace(a.s_state, '[^0-9 A-Za-z.-]', '')  ,
                     substr(regexp_replace(a.zipcode, '[^0-9 A-Za-z.-]', ''),1,5)  ,
                     regexp_replace(a.address_2, '[^0-9 A-Za-z.-]', ''),
                     a.dev                                             ,
                     a.address2time_zone                               ,
                     a.address2country                                 ,
                     a.address2state_prov                              ,
                     a.update_stamp                                    ,
                     a.address2e911
              INTO   o_address_rec
              FROM   table_address a,
			         table_x_zip_code b
              WHERE  a.objid   = i_address_objid
			  AND    a.zipcode = b.x_zip(+);
            EXCEPTION
                WHEN OTHERS THEN
                                   o_errnum  := 1028;
                   o_errstr  := 'get_address_info:  '||substr(sqlerrm,1,100);
                   billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_address_info'   ,
                                                        i_key      =>  i_address_objid                     ,
                                                        i_err_num  =>  SQLCODE                             ,
                                                        i_err_msg  =>  SUBSTR (SQLERRM, 1, 100)            ,
                                                        i_desc     =>  'Error while retrieve address information' ,
                                                        i_severity =>  2
                                                        );
             END;
--
END get_address_info;
--
PROCEDURE insert_program_error_tab(i_source         IN   VARCHAR2              ,
                                   i_key            IN   VARCHAR2              ,
                                   i_err_num        IN   NUMBER                ,
                                   i_err_msg        IN   VARCHAR2 DEFAULT NULL ,
                                   i_desc           IN   VARCHAR2              ,
                                   i_severity       IN   VARCHAR2
                                   )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF i_err_num IS NULL THEN
    RETURN;
  END IF;

        INSERT INTO x_program_error_log
             (x_source     ,
              x_error_code ,
              x_error_msg  ,
              x_date       ,
              x_description,
              x_severity   ,
              x_key
             )
             VALUES
             (i_source   , -- Program or Location of the error raised
              i_err_num  , -- Error code
              i_err_msg  , -- Error message
              SYSDATE    , -- Error logged time stamp
              i_desc     , -- Error triggered flow or action
              i_severity , -- This will determine the High / Medium / Low severity of the error logged
              i_key        -- This will store the unique or key value like ESN / Bill account number
              );
  COMMIT;
--
END insert_program_error_tab;
--
PROCEDURE insert_prg_purch_hdr(i_objid                 IN     NUMBER   ,
                               i_rqst_source           IN     VARCHAR2 ,
                               i_rqst_type             IN     VARCHAR2 ,
                               i_credit_card_info      IN     table_x_credit_card%ROWTYPE,
                               i_bank_info             IN     table_x_bank_account%ROWTYPE,
                               i_rqst_date             IN     DATE     ,
                               i_ics_applications      IN     VARCHAR2 ,
                               i_merchant_id           IN     VARCHAR2 ,
                               i_merchant_ref_number   IN     VARCHAR2 ,
                               i_offer_num             IN     VARCHAR2 ,
                               i_quantity              IN     NUMBER   ,
                               i_merchant_product_sku  IN     VARCHAR2 ,
                               i_payment_line2program  IN     NUMBER   ,
                               i_product_code          IN     VARCHAR2 ,
                               i_ignore_avs            IN     VARCHAR2 ,
                               i_user_po               IN     VARCHAR2 ,
                               i_avs                   IN     VARCHAR2 ,
                               i_disable_avs           IN     VARCHAR2 ,
                               i_customer_hostname     IN     VARCHAR2 ,
                               i_customer_ipaddress    IN     VARCHAR2 ,
                               i_auth_request_id       IN     VARCHAR2 ,
                               i_auth_code             IN     VARCHAR2 ,
                               i_auth_type             IN     VARCHAR2 ,
                               i_ics_rcode             IN     VARCHAR2 ,
                               i_ics_rflag             IN     VARCHAR2 ,
                               i_ics_rmsg              IN     VARCHAR2 ,
                               i_request_id            IN     VARCHAR2 ,
                               i_auth_avs              IN     VARCHAR2 ,
                               i_auth_response         IN     VARCHAR2 ,
                               i_auth_time             IN     VARCHAR2 ,
                               i_auth_rcode            IN     NUMBER   ,
                               i_auth_rflag            IN     VARCHAR2 ,
                               i_auth_rmsg             IN     VARCHAR2 ,
                               i_bill_request_time     IN     VARCHAR2 ,
                               i_bill_rcode            IN     NUMBER   ,
                               i_bill_rflag            IN     VARCHAR2 ,
                               i_bill_rmsg             IN     VARCHAR2 ,
                               i_bill_trans_ref_no     IN     VARCHAR2 ,
                               i_status                IN     VARCHAR2 ,
                               i_bill_address1         IN     VARCHAR2 ,
                               i_bill_address2         IN     VARCHAR2 ,
                               i_bill_city             IN     VARCHAR2 ,
                               i_bill_state            IN     VARCHAR2 ,
                               i_bill_zip              IN     VARCHAR2 ,
                               i_bill_country          IN     VARCHAR2 ,
                               i_esn                   IN     VARCHAR2 ,
                               i_amount                IN     NUMBER   ,
                               i_tax_amount            IN     NUMBER   ,
                               i_auth_amount           IN     NUMBER   ,
                               i_bill_amount           IN     NUMBER   ,
                               i_user                  IN     VARCHAR2 ,
                               i_credit_code           IN     VARCHAR2 ,
                               i_purch_hdr2user        IN     NUMBER   ,
                               i_purch_hdr2esn         IN     NUMBER   ,
                               i_purch_hdr2rmsg_codes  IN     NUMBER   ,
                               i_purch_hdr2cr_purch    IN     NUMBER   ,
                               i_prog_hdr2x_pymt_src   IN     NUMBER   ,
                               i_prog_hdr2web_user     IN     NUMBER   ,
                               i_prog_hdr2prog_batch   IN     NUMBER   ,
                               i_payment_type          IN     VARCHAR2 ,
                               i_e911_tax_amount       IN     NUMBER   ,
                               i_usf_tax_amount        IN     NUMBER   ,
                               i_rcrf_tax_amount       IN     NUMBER   ,
                               i_process_date          IN     DATE     ,
                               i_discount_amount       IN     NUMBER   ,
                               i_priority              IN     NUMBER   ,
                               o_errnum                OUT    NUMBER   ,
                               o_errstr                OUT    VARCHAR2
                               )
AS
BEGIN --Main Section

    BEGIN
        --Inserting record into x_program_purch_hdr
        INSERT INTO x_program_purch_hdr
                   (objid                  ,
                    x_rqst_source          ,
                    x_rqst_type            ,
                    x_rqst_date            ,
                    x_ics_applications     ,
                    x_merchant_id          ,
                    x_merchant_ref_number  ,
                    x_offer_num            ,
                    x_quantity             ,
                    x_merchant_product_sku ,
                    x_payment_line2program ,
                    x_product_code         ,
                    x_ignore_avs           ,
                    x_user_po              ,
                    x_avs                  ,
                    x_disable_avs          ,
                    x_customer_hostname    ,
                    x_customer_ipaddress   ,
                    x_auth_request_id      ,
                    x_auth_code            ,
                    x_auth_type            ,
                    x_ics_rcode            ,
                    x_ics_rflag            ,
                    x_ics_rmsg             ,
                    x_request_id           ,
                    x_auth_avs             ,
                    x_auth_response        ,
                    x_auth_time            ,
                    x_auth_rcode           ,
                    x_auth_rflag           ,
                    x_auth_rmsg            ,
                    x_bill_request_time    ,
                    x_bill_rcode           ,
                    x_bill_rflag           ,
                    x_bill_rmsg            ,
                    x_bill_trans_ref_no    ,
                    x_customer_firstname   ,
                    x_customer_lastname    ,
                    x_customer_phone       ,
                    x_customer_email       ,
                    x_status               ,
                    x_bill_address1        ,
                    x_bill_address2        ,
                    x_bill_city            ,
                    x_bill_state           ,
                    x_bill_zip             ,
                    x_bill_country         ,
                    x_esn                  ,
                    x_amount               ,
                    x_tax_amount           ,
                    x_auth_amount          ,
                    x_bill_amount          ,
                    x_user                 ,
                    x_credit_code          ,
                    purch_hdr2creditcard   ,
                    purch_hdr2bank_acct    ,
                    purch_hdr2user         ,
                    purch_hdr2esn          ,
                    purch_hdr2rmsg_codes   ,
                    purch_hdr2cr_purch     ,
                    prog_hdr2x_pymt_src    ,
                    prog_hdr2web_user      ,
                    prog_hdr2prog_batch    ,
                    x_payment_type         ,
                    x_e911_tax_amount      ,
                    x_usf_taxamount        ,
                    x_rcrf_tax_amount      ,
                    x_process_date         ,
                    x_discount_amount      ,
                    x_priority
                    )
            VALUES(i_objid                 ,
                  i_rqst_source            ,
                  DECODE(i_rqst_type,'ACH','ACH_PURCH','CREDITCARD','CREDITCARD_PURCH',NULL),
                  i_rqst_date              ,
                  i_ics_applications       ,
                  i_merchant_id            ,
                  i_merchant_ref_number    ,
                  i_offer_num              ,
                  i_quantity               ,
                  i_merchant_product_sku   ,
                  i_payment_line2program   ,
                  i_product_code           ,
                  i_ignore_avs             ,
                  i_user_po                ,
                  i_avs                    ,
                  i_disable_avs            ,
                  i_customer_hostname      ,
                  i_customer_ipaddress     ,
                  i_auth_request_id        ,
                  i_auth_code              ,
                  i_auth_type              ,
                  i_ics_rcode              ,
                  i_ics_rflag              ,
                  i_ics_rmsg               ,
                  i_request_id             ,
                  i_auth_avs               ,
                  i_auth_response          ,
                  i_auth_time              ,
                  i_auth_rcode             ,
                  i_auth_rflag             ,
                  i_auth_rmsg              ,
                  i_bill_request_time      ,
                  i_bill_rcode             ,
                  i_bill_rflag             ,
                  i_bill_rmsg              ,
                  i_bill_trans_ref_no      ,
                  DECODE(i_rqst_type, 'ACH',
                                                 NVL(i_bank_info.x_customer_firstname,'No Name Provided'),
                                                 'CREDITCARD',
                                                 NVL(i_credit_card_info.x_customer_firstname,'No Name Provided'),
                                                 NULL
                                                 )                 ,
                  DECODE(i_rqst_type, 'ACH',
                                                 NVL(i_bank_info.x_customer_lastname,'No Name Provided'),
                                                 'CREDITCARD',
                                                 NVL(i_credit_card_info.x_customer_lastname,'No Name Provided'),
                                                 NULL
                                                 ),
                  DECODE(i_rqst_type, 'ACH',
                                                 i_bank_info.x_customer_phone,
												 'CREDITCARD',
                                                 i_credit_card_info.x_customer_phone,
                                                 NULL
                                                 ),
                  DECODE(i_rqst_type, 'ACH',
                                                 NVL(i_bank_info.x_customer_email,'null@cybersource.com'),
                                                 'CREDITCARD',
                                                 NVL(i_credit_card_info.x_customer_email,'null@cybersource.com'),
                                                 NULL
                                                 )                 ,
                  i_status                 ,
                  i_bill_address1          ,
                  i_bill_address2          ,
                  i_bill_city              ,
                  i_bill_state             ,
                  i_bill_zip               ,
                  i_bill_country           ,
                  i_esn                    ,
                  i_amount                 ,
                  i_tax_amount             ,
                  i_auth_amount            ,
                  i_bill_amount            ,
                  i_user                   ,
                  i_credit_code            ,
                  DECODE(i_rqst_type,'CREDITCARD',i_credit_card_info.objid,NULL) ,
                  DECODE(i_rqst_type,'ACH',i_bank_info.objid,NULL)               ,
                  i_purch_hdr2user         ,
                  i_purch_hdr2esn          ,
                  i_purch_hdr2rmsg_codes   ,
                  i_purch_hdr2cr_purch     ,
                  i_prog_hdr2x_pymt_src    ,
                  i_prog_hdr2web_user      ,
                  i_prog_hdr2prog_batch    ,
                  i_payment_type           ,
                  i_e911_tax_amount        ,
                  i_usf_tax_amount         ,
                  i_rcrf_tax_amount        ,
                  i_process_date           ,
                  i_discount_amount        ,
                  i_priority
                  );
        EXCEPTION
                WHEN OTHERS THEN
                                   o_errnum  := 1029;
                   o_errstr  := 'insert_prg_purch_hdr:  '||substr(sqlerrm,1,100);
                   billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.insert_prg_purch_hdr'      ,
                                                        i_key      =>  i_esn                                      ,
                                                        i_err_num  =>  o_errnum                                   ,
                                                        i_err_msg  =>  o_errstr                                   ,
                                                        i_desc     =>  'Error while insert into program purch hdr',
                                                        i_severity =>  1
                                                        );
        END;
--
END  insert_prg_purch_hdr;
--
PROCEDURE insert_prg_purch_dtl(i_objid                        IN   NUMBER   ,
                               i_esn                          IN   VARCHAR2 ,
                               i_amount                       IN   NUMBER   ,
                               i_charge_desc                  IN   VARCHAR2 ,
                               i_cycle_start_date             IN   DATE     ,
                               i_cycle_end_date               IN   DATE     ,
                               i_pgm_purch_dtl2pgm_enrolled   IN   NUMBER   ,
                               i_pgm_purch_dtl2prog_hdr       IN   NUMBER   ,
                               i_pgm_purch_dtl2penal_pend     IN   NUMBER   ,
                               i_tax_amount                   IN   NUMBER   ,
                               i_e911_tax_amount              IN   NUMBER   ,
                               i_usf_tax_amount               IN   NUMBER   ,
                               i_rcrf_tax_amount              IN   NUMBER   ,
                               i_priority                     IN   NUMBER   ,
                               o_errnum                       OUT  NUMBER   ,
                               o_errstr                       OUT  VARCHAR2
                               )
AS
BEGIN --Main Section

     BEGIN
      -- Inserting record into x_program_purch_dtl table
      INSERT INTO x_program_purch_dtl
                 (objid                      ,
                  x_esn                      ,
                  x_amount                   ,
                  x_charge_desc              ,
                  x_cycle_start_date         ,
                  x_cycle_end_date           ,
                  pgm_purch_dtl2pgm_enrolled ,
                  pgm_purch_dtl2prog_hdr     ,
                  pgm_purch_dtl2penal_pend   ,
                  x_tax_amount               ,
                  x_e911_tax_amount          ,
                  x_usf_taxamount            ,
                  x_rcrf_tax_amount          ,
                  x_priority
                  )
          VALUES (i_objid                      ,
                  i_esn                        ,
                  i_amount                     ,
                  i_charge_desc                ,
                  i_cycle_start_date           ,
                  i_cycle_end_date             ,
                  i_pgm_purch_dtl2pgm_enrolled ,
                  i_pgm_purch_dtl2prog_hdr     ,
                  i_pgm_purch_dtl2penal_pend   ,
                  i_tax_amount                 ,
                  i_e911_tax_amount            ,
                  i_usf_tax_amount             ,
                  i_rcrf_tax_amount            ,
                  i_priority
                  );
     EXCEPTION
              WHEN OTHERS THEN
                  o_errnum  := 1030;
              o_errstr  := 'insert_prg_purch_dtl:  '||substr(sqlerrm,1,100);
              billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.insert_prg_purch_dtl'      ,
                                                   i_key      =>  i_esn                                       ,
                                                   i_err_num  =>  o_errnum                                   ,
                                                   i_err_msg  =>  o_errstr                                   ,
                                                   i_desc     =>  'Error while insert into program purch dtl',
                                                   i_severity =>  1
                                                   );
     END;
--
END insert_prg_purch_dtl;
--
PROCEDURE insert_cc_prg_trans(i_objid                     IN   NUMBER   ,
                              i_ignore_bad_cv             IN   VARCHAR2 ,
                              i_ignore_avs                IN   VARCHAR2 ,
                              i_avs                       IN   VARCHAR2 ,
                              i_disable_avs               IN   VARCHAR2 ,
                              i_auth_avs                  IN   VARCHAR2 ,
                              i_auth_cv_result            IN   VARCHAR2 ,
                              i_score_factors             IN   VARCHAR2 ,
                              i_score_host_severity       IN   VARCHAR2 ,
                              i_score_rcode               IN   NUMBER   ,
                              i_score_rflag               IN   VARCHAR2 ,
                              i_score_rmsg                IN   VARCHAR2 ,
                              i_score_result              IN   VARCHAR2 ,
                              i_score_time_local          IN   VARCHAR2 ,
                              i_customer_cc_number        IN   VARCHAR2 ,
                              i_customer_cc_expmo         IN   VARCHAR2 ,
                              i_customer_cc_expyr         IN   VARCHAR2 ,
                              i_customer_cvv_num          IN   VARCHAR2 ,
                              i_cc_lastfour               IN   VARCHAR2 ,
                              i_cc_trans2x_credit_card    IN   NUMBER   ,
                              i_cc_trans2x_purch_hdr      IN   NUMBER   ,
                              o_errnum                    OUT  NUMBER   ,
                              o_errstr                    OUT  VARCHAR2
                              )
AS
BEGIN --Main Section

         BEGIN
             --Inserting record into x_cc_prog_trans table
              INSERT INTO x_cc_prog_trans
                         (objid                   ,
                          x_ignore_bad_cv         ,
                          x_ignore_avs            ,
                          x_avs                   ,
                          x_disable_avs           ,
                          x_auth_avs              ,
                          x_auth_cv_result        ,
                          x_score_factors         ,
                          x_score_host_severity   ,
                          x_score_rcode           ,
                          x_score_rflag           ,
                          x_score_rmsg            ,
                          x_score_result          ,
                          x_score_time_local      ,
                          x_customer_cc_number    ,
                          x_customer_cc_expmo     ,
                          x_customer_cc_expyr     ,
                          x_customer_cvv_num      ,
                          x_cc_lastfour           ,
                          x_cc_trans2x_credit_card,
                          x_cc_trans2x_purch_hdr
                          )
                   VALUES(i_objid                 ,
                          i_ignore_bad_cv         ,
                          i_ignore_avs            ,
                          i_avs                   ,
                          i_disable_avs           ,
                          i_auth_avs              ,
                          i_auth_cv_result        ,
                          i_score_factors         ,
                          i_score_host_severity   ,
                          i_score_rcode           ,
                          i_score_rflag           ,
                          i_score_rmsg            ,
                          i_score_result          ,
                          i_score_time_local      ,
                          i_customer_cc_number    ,
                          i_customer_cc_expmo     ,
                          i_customer_cc_expyr     ,
                          i_customer_cvv_num      ,
                          i_cc_lastfour           ,
                          i_cc_trans2x_credit_card,
                          i_cc_trans2x_purch_hdr
                          );
         EXCEPTION
                WHEN OTHERS THEN
                o_errnum  := 1031;
                o_errstr  := 'insert_cc_prg_trans:  '||substr(sqlerrm,1,100);
                billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.insert_cc_prg_trans'             ,
                                                     i_key      =>  i_cc_trans2x_purch_hdr                           ,
                                                     i_err_num  =>  o_errnum                                         ,
                                                     i_err_msg  =>  o_errstr                                         ,
                                                     i_desc     =>  'Error while insert record into x_cc_prog_trans' ,
                                                     i_severity =>  1
                                                     );
         END;
--
END insert_cc_prg_trans;
--
PROCEDURE insert_ach_prg_trans(i_objid                    IN    NUMBER   ,
                               i_bank_num                 IN    VARCHAR2 ,
                               i_ecp_account_no           IN    VARCHAR2 ,
                               i_ecp_account_type         IN    VARCHAR2 ,
                               i_ecp_rdfi                 IN    VARCHAR2 ,
                               i_ecp_settlement_method    IN    VARCHAR2 ,
                               i_ecp_payment_mode         IN    VARCHAR2 ,
                               i_ecp_debit_request_id     IN    VARCHAR2 ,
                               i_ecp_verfication_level    IN    VARCHAR2 ,
                               i_ecp_ref_number           IN    VARCHAR2 ,
                               i_ecp_debit_ref_number     IN    VARCHAR2 ,
                               i_ecp_debit_avs            IN    VARCHAR2 ,
                               i_ecp_debit_avs_raw        IN    VARCHAR2 ,
                               i_ecp_rcode                IN    VARCHAR2 ,
                               i_ecp_trans_id             IN    VARCHAR2 ,
                               i_ecp_ref_no               IN    VARCHAR2 ,
                               i_ecp_result_code          IN    VARCHAR2 ,
                               i_ecp_rflag                IN    VARCHAR2 ,
                               i_ecp_rmsg                 IN    VARCHAR2 ,
                               i_ecp_credit_ref_number    IN    VARCHAR2 ,
                               i_ecp_credit_trans_id      IN    VARCHAR2 ,
                               i_decline_avs_flags        IN    VARCHAR2 ,
                               i_ach_trans2x_purch_hdr    IN    NUMBER   ,
                               i_ach_trans2x_bank_account IN    NUMBER   ,
                               i_ach_trans2pgm_enrolled   IN    NUMBER   ,
                               o_errnum                   OUT   NUMBER   ,
                               o_errstr                   OUT   VARCHAR2
                               )
AS
BEGIN --Main Section

          BEGIN
             --Inserting record into x_cc_prog_trans table
             INSERT INTO x_ach_prog_trans
                        (objid                   ,
                         x_bank_num              ,
                         x_ecp_account_no        ,
                         x_ecp_account_type      ,
                         x_ecp_rdfi              ,
                         x_ecp_settlement_method ,
                         x_ecp_payment_mode      ,
                         x_ecp_debit_request_id  ,
                         x_ecp_verfication_level ,
                         x_ecp_ref_number        ,
                         x_ecp_debit_ref_number  ,
                         x_ecp_debit_avs         ,
                         x_ecp_debit_avs_raw     ,
                         x_ecp_rcode             ,
                         x_ecp_trans_id          ,
                         x_ecp_ref_no            ,
                         x_ecp_result_code       ,
                         x_ecp_rflag             ,
                         x_ecp_rmsg              ,
                         x_ecp_credit_ref_number ,
                         x_ecp_credit_trans_id   ,
                         x_decline_avs_flags     ,
                         ach_trans2x_purch_hdr   ,
                         ach_trans2x_bank_account,
                         ach_trans2pgm_enrolled
                         )
                  VALUES(i_objid                   ,
                         i_bank_num                ,
                         i_ecp_account_no          ,
                         i_ecp_account_type        ,
                         i_ecp_rdfi                ,
                         i_ecp_settlement_method   ,
                         i_ecp_payment_mode        ,
                         i_ecp_debit_request_id    ,
                         i_ecp_verfication_level   ,
                         i_ecp_ref_number          ,
                         i_ecp_debit_ref_number    ,
                         i_ecp_debit_avs           ,
                         i_ecp_debit_avs_raw       ,
                         i_ecp_rcode               ,
                         i_ecp_trans_id            ,
                         i_ecp_ref_no              ,
                         i_ecp_result_code         ,
                         i_ecp_rflag               ,
                         i_ecp_rmsg                ,
                         i_ecp_credit_ref_number   ,
                         i_ecp_credit_trans_id     ,
                         i_decline_avs_flags       ,
                         i_ach_trans2x_purch_hdr   ,
                         i_ach_trans2x_bank_account,
                         i_ach_trans2pgm_enrolled
                         );
          EXCEPTION
                WHEN OTHERS THEN
                o_errnum  := 1032;
                o_errstr  := 'insert_ach_prg_trans:  '||substr(sqlerrm,1,100);
                billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.insert_ach_prg_trans'            ,
                                                     i_key      =>  i_ach_trans2x_purch_hdr                          ,
                                                     i_err_num  =>  o_errnum                                         ,
                                                     i_err_msg  =>  o_errstr                                         ,
                                                     i_desc     =>  'Error while insert record into x_ach_prog_trans',
                                                     i_severity =>  1
                                                     );
          END;

END insert_ach_prg_trans;

--
PROCEDURE get_x_cert_info(i_x_bank_cc_account     IN NUMBER   ,
                                                  i_bank_cc_acount_objid  IN NUMBER   ,
                                                  i_pymnt_x_status        IN VARCHAR2 ,
                                                  i_bank_cc_acct2address  IN NUMBER   ,
                                                  i_address_objid         IN NUMBER   ,
                                                  i_address_country_objid IN NUMBER   ,
                                                  i_bank_cc2cert          IN NUMBER   ,
                                                  o_x_cert                OUT VARCHAR2,
                                                  o_x_key_algo            OUT VARCHAR2,
                                                  o_x_cc_algo             OUT VARCHAR2,
                                                  o_country_name          OUT VARCHAR2,
                                                  o_errnum                OUT NUMBER  ,
                                                  o_errstr                OUT VARCHAR2
                                                  )
AS
BEGIN --Main Section

          SELECT cert.x_cert     ,
                         cert.x_key_algo ,
                         cert.x_cc_algo  ,
                         NVL(tc.s_name,'USA')
          INTO   o_x_cert        ,
                         o_x_key_algo    ,
                         o_x_cc_algo     ,
                         o_country_name
          FROM   x_cert cert,
                         sa.table_country tc
          WHERE  i_x_bank_cc_account     = i_bank_cc_acount_objid
          AND    i_pymnt_x_status        = 'ACTIVE'
          AND    i_bank_cc_acct2address  = i_address_objid
          AND    i_address_country_objid = tc.objid(+)
          AND    i_bank_cc2cert          = cert.objid;
EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  o_errnum := 1033;
                  o_errstr := 'get_x_cert_info:  '||SUBSTR(sqlerrm,1,100);
                  --
                  billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.get_x_cert_info'           ,
                                                                                           i_key      => i_x_bank_cc_account                        ,
                                                                                           i_err_num  => o_errnum                                   ,
                                                                                           i_err_msg  => o_errstr                                   ,
                                                                                           i_desc     => 'No Data found while reterive from x_cert',
                                                                                           i_severity => 2
                                                                                          );
                WHEN OTHERS THEN
                  o_errnum := 1034;
                  o_errstr := 'get_x_cert_info:  '||SUBSTR(sqlerrm,1,100);
                  --
                  billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.get_x_cert_info'                            ,
                                                                                           i_key      => i_x_bank_cc_account                                         ,
                                                                                           i_err_num  => o_errnum                                                    ,
                                                                                           i_err_msg  => o_errstr                                                    ,
                                                                                           i_desc     => 'Error while reterive record from x_cert',
                                                                                           i_severity => 2
                                                       );
END get_x_cert_info;
--
--To insert into x_program_trans table for successful transaction
PROCEDURE insert_program_trans(i_enrollment_status      IN  VARCHAR2,
							   i_enroll_status_reason   IN  VARCHAR2,
							   i_float_given            IN  NUMBER  ,
							   i_cooling_given          IN  NUMBER  ,
							   i_grace_period_given     IN  NUMBER  ,
							   i_trans_date             IN  DATE    ,
							   i_action_text            IN  VARCHAR2,
							   i_action_type            IN  VARCHAR2,
							   i_reason                 IN  VARCHAR2,
							   i_sourcesystem           IN  VARCHAR2,
							   i_esn                    IN  VARCHAR2,
							   i_exp_date               IN  DATE    ,
							   i_cooling_exp_date       IN  DATE    ,
							   i_update_status          IN  VARCHAR2,
							   i_update_user            IN  VARCHAR2,
							   i_pgm_tran2pgm_enrolled  IN  NUMBER  ,
							   i_pgm_trans2web_user     IN  NUMBER  ,
							   i_pgm_trans2site_part    IN  NUMBER  ,
							   o_errnum                 OUT NUMBER  ,
							   o_errstr                 OUT VARCHAR2
							   )
AS
BEGIN --Main Section

  INSERT INTO x_program_trans(objid                  ,
							  x_enrollment_status    ,
							  x_enroll_status_reason ,
							  x_float_given          ,
							  x_cooling_given        ,
							  x_grace_period_given   ,
							  x_trans_date           ,
							  x_action_text          ,
							  x_action_type          ,
							  x_reason               ,
							  x_sourcesystem         ,
							  x_esn                  ,
							  x_exp_date             ,
							  x_cooling_exp_date     ,
							  x_update_status        ,
							  x_update_user          ,
							  pgm_tran2pgm_entrolled ,
							  pgm_trans2web_user     ,
							  pgm_trans2site_part
				              )
				       VALUES(billing_seq ('X_PROGRAM_TRANS'),
							  i_enrollment_status            ,
							  i_enroll_status_reason         ,
							  i_float_given                  ,
							  i_cooling_given                ,
							  i_grace_period_given           ,
							  i_trans_date                   ,
							  i_action_text                  ,
							  i_action_type                  ,
							  i_reason                       ,
							  i_sourcesystem                 ,
							  i_esn                          ,
							  i_exp_date                     ,
							  i_cooling_exp_date             ,
							  i_update_status                ,
							  i_update_user                  ,
							  i_pgm_tran2pgm_enrolled        ,
							  i_pgm_trans2web_user           ,
							  i_pgm_trans2site_part
						      );
		EXCEPTION
                WHEN OTHERS THEN
                    o_errnum  := 1045;
                    o_errstr  := 'insert_program_trans:  '||SUBSTR(SQLERRM,1,100);
                    billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.insert_program_trans'      ,
                                                         i_key      =>  i_esn                                      ,
                                                         i_err_num  =>  o_errnum                                   ,
                                                         i_err_msg  =>  o_errstr                                   ,
                                                         i_desc     =>  'Error while insert into x_programs_trans' ,
                                                         i_severity =>  1
                                                         );
END insert_program_trans;
--
--To insert into x_billing_log table for successful transaction
PROCEDURE insert_billing_log(i_log_category         IN  VARCHAR2,
							 i_log_title            IN  VARCHAR2,
							 i_log_date             IN  DATE    ,
							 i_details              IN  VARCHAR2,
							 i_additional_details   IN  VARCHAR2,
							 i_program_name         IN  VARCHAR2,
							 i_nickname             IN  VARCHAR2,
							 i_esn                  IN  VARCHAR2,
							 i_originator           IN  VARCHAR2,
							 i_contact_first_name   IN  VARCHAR2,
							 i_contact_last_name    IN  VARCHAR2,
							 i_agent_name           IN  VARCHAR2,
							 i_sourcesystem         IN  VARCHAR2,
							 i_billing_log2web_user IN  NUMBER  ,
							 o_errnum               OUT NUMBER  ,
							 o_errstr               OUT VARCHAR2
							 )
AS
BEGIN --Main Section

	INSERT INTO x_billing_log(objid               ,
							  x_log_category      ,
							  x_log_title         ,
							  x_log_date          ,
							  x_details           ,
							  x_additional_details,
							  x_program_name      ,
							  x_nickname          ,
							  x_esn               ,
							  x_originator        ,
							  x_contact_first_name,
							  x_contact_last_name ,
							  x_agent_name        ,
							  x_sourcesystem      ,
							  billing_log2web_user
							 )
					   VALUES(billing_seq ('x_billing_log'),
							  i_log_category               ,
							  i_log_title                  ,
							  i_log_date                   ,
							  i_details                    ,
							  i_additional_details         ,
							  i_program_name               ,
							  i_nickname                   ,
							  i_esn                        ,
							  i_originator                 ,
							  i_contact_first_name         ,
							  i_contact_last_name          ,
							  i_agent_name                 ,
							  i_sourcesystem               ,
							  i_billing_log2web_user
							  );
		EXCEPTION
                WHEN OTHERS THEN
                    o_errnum  := 1046;
                    o_errstr  := 'insert_billing_log:  '||SUBSTR(SQLERRM,1,100);
                    billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.insert_billing_log'    ,
                                                         i_key      =>  i_esn                                  ,
                                                         i_err_num  =>  o_errnum                               ,
                                                         i_err_msg  =>  o_errstr                               ,
                                                         i_desc     =>  'Error while insert into x_billing_log',
                                                         i_severity =>  1
                                                         );
END insert_billing_log;
--
PROCEDURE rt_recurring_payment (i_enrollment_hdr      IN     rt_rec_pymnt_enrl_hdr_type,--Enrollment Header
                                i_enrollment_dtl      IN     rt_rec_pymnt_enrl_dtl_tab ,--Enrollment Details
                                o_prg_purch_hdr_objid OUT    NUMBER                                    ,
                                o_rt_rec_pymnt_dtl    OUT    rt_rec_pymnt_dtl_tab      ,
                                o_errnum              OUT    NUMBER                    ,
                                o_errstr              OUT    VARCHAR2
                                )
AS

  --Output Type variables
  l_rt_rec_pymnt_dtl_tab   sa.rt_rec_pymnt_dtl_tab   := sa.rt_rec_pymnt_dtl_tab();
  ll_rt_rec_pymnt_dtl_tab  sa.rt_rec_pymnt_dtl_tab   := sa.rt_rec_pymnt_dtl_tab();
  pymt_src_dtls            sa.typ_pymt_src_dtls_rec;

  --Declaring variable to access customer type
  cst    sa.customer_type := sa.customer_type();

  --Row type variables
  l_pymnt_src_rec       x_payment_source%ROWTYPE     ;
  l_credit_card_rec     table_x_credit_card%ROWTYPE  ;
  l_address_rec         table_address%ROWTYPE        ;
  l_bank_acount_rec     table_x_bank_account%ROWTYPE ;
  l_pgm_enrolled_rec    x_program_enrolled%ROWTYPE   ;

  --Local variables declaration
  l_esn                    VARCHAR2(30)                  ;
  l_pymt_src_objid         NUMBER       := NULL          ;
  l_charge_desc            VARCHAR2(255)                 ;
  l_next_cycle_date        DATE                          ;
  l_merchant_id            VARCHAR2(30)                  ;
  l_merchant_ref_no        VARCHAR2(50)                  ;
  l_pph_objid              NUMBER                        ;
  l_ppd_objid              NUMBER                        ;
  l_inst_purch_hdr         NUMBER       := 0             ;
  l_x_cert                 x_cert.x_cert%TYPE            ;
  l_x_key_algo             x_cert.x_key_algo%TYPE        ;
  l_x_cc_algo              x_cert.x_cc_algo%TYPE         ;
  l_country_name           table_country.s_name%TYPE     ;
  l_card_exp               table_x_parameters.x_param_value%TYPE;
  l_dup_chk                NUMBER    := 0                ;
  l_payment_staging_tbl_objid NUMBER                     ;
  bmultimerchantflag      BOOLEAN := TRUE                ;
  l_amount                NUMBER                         ;
  l_priority              NUMBER                         ;

  BEGIN  --MAIN SECTION

 --Initializing output collection o_rt_rec_pymnt_dtl variable to NULL
 o_rt_rec_pymnt_dtl :=  sa.rt_rec_pymnt_dtl_tab(sa.rt_rec_pymnt_dtl_type(NULL,
                                                                         NULL,
																		 NULL,
																		 NULL,
																		 NULL,
																		 NULL,
																		 NULL,
																		 NULL,
																		 sa.typ_pymt_src_dtls_rec(NULL,
																								  NULL,
                                                                                                  NULL,
                                                                                                  NULL,
                                                                                                  NULL,
                                                                                                  sa.typ_creditcard_info(NULL,
																														 NULL,
																														 NULL,
																														 NULL,
																														 NULL,
																														 NULL,
																														 NULL,
																														 NULL,
																														 NULL,
																														 NULL
																														 ),
																														  NULL,
																														  NULL,
																														  NULL,
																														  sa.address_type_rec(NULL,
																																			  NULL,
																																			  NULL,
																																			  NULL,
																																			  NULL,
																																			  NULL
																																			  ),
																								  NULL,
                                                                                                  sa.typ_ach_info(NULL,
																												  NULL,
																												  NULL,
																												  NULL,
																												  NULL,
																												  NULL,
																												  NULL,
																												  NULL),
                                                                                                  sa.typ_aps_info(NULL,
																												  NULL,
																												  NULL)
                                                                                                  )

                                                                            )
                                                );

      --Condition to check whether enrollment details IS NOT NULL
      IF i_enrollment_dtl.COUNT = 0 THEN
         o_errnum := 956;
         o_errstr := 'Enrollment details cannot be null';

                 billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
         RETURN;
      END IF;

          --Condition to check whether enrollment Header IS NOT NULL

           IF i_enrollment_hdr IS NULL THEN
          o_errnum := 957;
          o_errstr := 'Enrollment Header cannot be null';

                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
          RETURN;
       END IF;

           if i_enrollment_hdr.sales_tax_amount Is NULL THEN
                  o_errnum := 958;
          o_errstr := 'Sales tax Amount cannot be null';

                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                  RETURN;
           END IF;

           if i_enrollment_hdr.e911_tax_amount Is NULL THEN
                  o_errnum := 959;
          o_errstr := 'e911_tax_amount cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                  RETURN;
           END IF;

           if i_enrollment_hdr.usf_tax_amount Is NULL THEN
                  o_errnum := 960;
          o_errstr := 'usf_tax_amoun cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                  RETURN;
           END IF;

           if i_enrollment_hdr.rcrf_tax_amount Is NULL THEN
                  o_errnum := 961;
          o_errstr := 'rcrf_tax_amount cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                  RETURN;
           END IF;

           if i_enrollment_hdr.total_tax_amount Is NULL THEN
                  o_errnum := 962;
          o_errstr := 'total_tax_amount cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                  RETURN;
           END IF;

           if i_enrollment_hdr.amount_without_tax Is NULL THEN
                  o_errnum := 963;
          o_errstr := 'amount_without_tax cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                  RETURN;
           END IF;

           if i_enrollment_hdr.total_amount Is NULL THEN
                  o_errnum := 964;
          o_errstr := 'total_amount cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_hdr.bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                  RETURN;
           END IF;


          -- Get magic expiry date for credit card
          BEGIN

				   SELECT x_param_value
				   INTO   l_card_exp
				   FROM   table_x_parameters
				   WHERE  x_param_name = 'CC_MAGIC_EXPIRY_DATE';

                   EXCEPTION
                   WHEN NO_DATA_FOUND THEN

                   l_card_exp := '12-2099';
                   o_errnum   := 965;
                   o_errstr   := 'No data found in x_param_value';

                   billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                                                            i_key      =>  i_enrollment_hdr.bill_acct_num        ,
                                                                                            i_err_num  =>  o_errnum                              ,
                                                                                            i_err_msg  =>  o_errstr                              ,
                                                                                            i_desc     =>  'No data found in x_param_value'      ,
                                                                                            i_severity =>  1
                                                                                            );
      END;

       --Loop through the input i_enrollment_dtl type
       FOR i_enrl_rec IN i_enrollment_dtl.FIRST..i_enrollment_dtl.LAST
        LOOP

                 o_errnum := 0;
                          l_pymnt_src_rec    := NULL;
                          l_credit_card_rec  := NULL;
                          l_address_rec      := NULL;
                          l_bank_acount_rec  := NULL;
                          l_pgm_enrolled_rec := NULL;

                   IF ( i_enrollment_dtl(i_enrl_rec).billing_part_num IS NULL ) THEN

                                o_errnum := 966;
                                o_errstr := 'billing part number cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                     RETURN;
                   END IF;

                   IF ( i_enrollment_dtl(i_enrl_rec).rec_pymnt_next_chrg_dt IS NULL ) THEN

                                o_errnum := 967;
                                o_errstr := 'rec_pymnt_next_chrg_dt cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                     RETURN;
                   END IF;

                   IF ( i_enrollment_dtl(i_enrl_rec).pymt_src_objid IS NULL ) then

                                o_errnum := 968;
                                o_errstr := 'Payment source objid cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                     RETURN;
                   END IF;

                   IF ( i_enrollment_dtl(i_enrl_rec).prg_enrol_objid IS NULL ) then

                                o_errnum := 969;
                                o_errstr := 'Program enrolled objid cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                     RETURN;
                   END IF;

                   IF ( i_enrollment_dtl(i_enrl_rec).ESN IS NULL ) then

                                o_errnum := 970;
                                o_errstr := 'ESN cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;

                    IF ( i_enrollment_dtl(i_enrl_rec).sales_tax_amount IS NULL ) then

                                o_errnum := 971;
                                o_errstr := 'sales_tax_amount cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;


                    IF ( i_enrollment_dtl(i_enrl_rec).e911_tax_amount IS NULL ) then

                                o_errnum := 972;
                                o_errstr := 'e911_tax_amount cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;

                     IF ( i_enrollment_dtl(i_enrl_rec).usf_tax_amount IS NULL ) then

                                o_errnum := 973;
                                o_errstr := 'usf_tax_amount cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;


                     IF ( i_enrollment_dtl(i_enrl_rec).rcrf_tax_amount IS NULL ) then

                                o_errnum := 974;
                                o_errstr := 'rcrf_tax_amount cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;


                     IF ( i_enrollment_dtl(i_enrl_rec).total_tax_amount IS NULL ) then

                                o_errnum := 975;
                                o_errstr := 'total_tax_amount cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;

                    IF ( i_enrollment_dtl(i_enrl_rec).amount_without_tax IS NULL ) then

                                o_errnum := 976;
                                o_errstr := 'amount_without_tax cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;

                    IF ( i_enrollment_dtl(i_enrl_rec).total_amount IS NULL ) then

                                o_errnum := 977;
                                o_errstr := 'total_amount cannot be null';
                                --
                                billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN     ,
                                                     i_err_num  =>  o_errnum                             ,
                                                     i_err_msg  =>  o_errstr                             ,
                                                     i_desc     =>  'Input data cannot be NULL'          ,
                                                     i_severity =>  1
                                                     );
                     RETURN;
                   END IF;

                    --To check whether payment source objid is NULL and assign the payment source objid from enrollment details
                    IF l_pymt_src_objid IS NULL THEN

                       l_pymt_src_objid  := i_enrollment_dtl(i_enrl_rec).pymt_src_objid  ;

                    END IF;

			         l_amount := i_enrollment_hdr.amount_without_tax - NVL(i_enrollment_hdr.discount_amt,0);

                        --To validate and check duplicate transaction is not allowed
                        SELECT COUNT(1)
                        INTO   l_dup_chk
                        FROM   x_program_purch_dtl ppd,
                               x_program_purch_hdr pph
                        WHERE  ppd.pgm_purch_dtl2pgm_enrolled = i_enrollment_dtl(i_enrl_rec).prg_enrol_objid
                        AND    ppd.pgm_purch_dtl2prog_hdr     = pph.objid
						AND    ppd.x_esn                      = i_enrollment_dtl(i_enrl_rec).esn
						AND    pph.prog_hdr2x_pymt_src        = i_enrollment_dtl(i_enrl_rec).pymt_src_objid
						AND    pph.x_amount                   = l_amount
                        AND    TRUNC(pph.x_rqst_date)         = TRUNC(SYSDATE)
			AND EXISTS
			(
			SELECT 1
			FROM rec_pymnt_staging_tbl
			WHERE x_rec_pymnt_stg2prg_purch_hdr = pph.objid
			);

                                --Call get_payment_type to retrieve payment source type for details
                                 get_payment_type(i_pymnt_src_objid   => i_enrollment_dtl(i_enrl_rec).pymt_src_objid ,
                                                              o_pymnt_src_rec     => l_pymnt_src_rec                             ,
                                                              o_errstr            => o_errstr                                    ,
                                                              o_errnum            => o_errnum
                                                             );


                                        if (nvl(o_errnum,0) <> 0) then
                                        --GOTO next_record;
					continue;
                                        end if;

                    --Condition to check whether the payment type is 'CREDIT CARD' or 'ACH'
                                        IF l_pymnt_src_rec.x_pymt_type = 'CREDITCARD' THEN

                                                        --Call get_credit_card_info procedure to retrieve credit card information
                                                        get_credit_card_info (i_credit_card_objid => l_pymnt_src_rec.pymt_src2x_credit_card,
                                                                                                  o_credit_card_rec   => l_credit_card_rec                     ,
                                                                                                  o_errnum            => o_errnum                              ,
                                                                                                  o_errstr            => o_errstr
                                                                                                  );
                            if (nvl(o_errnum,0) <> 0) then
                                                      --  GOTO next_record;
						      continue;
                                                        end if;

                                                        --Call get_address_info procedure to retrieve address information
                                                        get_address_info(i_address_objid  => l_credit_card_rec.x_credit_card2address ,
                                                                                         o_address_rec    => l_address_rec                           ,
                                                                                         o_errnum         => o_errnum                                ,
                                                                                         o_errstr         => o_errstr
                                                                                        );
                                                        if (nvl(o_errnum,0) <> 0) then
                                                        --GOTO next_record;
							continue;
                                                        end if;

                                                        --Call get_x_cert_info procedure to retrieve CERT information
                                                        get_x_cert_info (i_x_bank_cc_account     => l_pymnt_src_rec.pymt_src2x_credit_card  ,
																		 i_bank_cc_acount_objid  => l_credit_card_rec.objid                 ,
																		 i_pymnt_x_status        => 'ACTIVE'                                ,
																		 i_bank_cc_acct2address  => l_credit_card_rec.x_credit_card2address ,
																		 i_address_objid         => l_address_rec.objid                     ,
																		 i_address_country_objid => l_address_rec.address2country           ,
																		 i_bank_cc2cert          => l_credit_card_rec.creditcard2cert       ,
																		 o_x_cert                => l_x_cert                                ,
																		 o_x_key_algo            => l_x_key_algo                            ,
																		 o_x_cc_algo             => l_x_cc_algo                             ,
																		 o_country_name          => l_country_name                          ,
																		 o_errnum                => o_errnum                                ,
																		 o_errstr                => o_errstr
																		);

                                                        if (nvl(o_errnum,0) <> 0) then
                                                        --GOTO next_record;
							continue;
                                                        end if;

                                        ELSIF l_pymnt_src_rec.x_pymt_type = 'ACH' THEN

                                                        -- To retrieve the bank account information for details
                                                        get_bank_info(i_bank_account_objid  => l_pymnt_src_rec.pymt_src2x_bank_account,
                                                                                  o_bank_acount_rec     => l_bank_acount_rec                      ,
                                                                                  o_errnum              => o_errnum                               ,
                                                                                  o_errstr              => o_errstr
                                                                                  );

                                                        if (nvl(o_errnum,0) <> 0) then
                                                        --  GOTO next_record;
						                                continue;
                                                        end if;

                                                         --Call get_address_info procedure to retrieve address information for details
                                                        get_address_info(i_address_objid  => l_bank_acount_rec.x_bank_acct2address,
                                                                                          o_address_rec    => l_address_rec                       ,
                                                                                          o_errnum         => o_errnum                            ,
                                                                                          o_errstr         => o_errstr
                                                                                          );

                                                        if (nvl(o_errnum,0) <> 0) then
                                                        --GOTO next_record;
							                            continue;
                                                        end if;

                                                         --Call get_x_cert_info procedure to retrieve CERT information for details
                                                         get_x_cert_info (i_x_bank_cc_account     => l_pymnt_src_rec.pymt_src2x_bank_account,
																		  i_bank_cc_acount_objid  => l_bank_acount_rec.objid                ,
																		  i_pymnt_x_status        => 'ACTIVE'                               ,
																		  i_bank_cc_acct2address  => l_bank_acount_rec.x_bank_acct2address  ,
																		  i_address_objid         => l_address_rec.objid                    ,
																		  i_address_country_objid => l_address_rec.address2country          ,
																		  i_bank_cc2cert          => l_bank_acount_rec.bank2cert            ,
																		  o_x_cert                => l_x_cert                               ,
																		  o_x_key_algo            => l_x_key_algo                           ,
																		  o_x_cc_algo             => l_x_cc_algo                            ,
																		  o_country_name          => l_country_name                         ,
																		  o_errnum                => o_errnum                               ,
																		  o_errstr                => o_errstr
																		 ) ;
                                                        if (nvl(o_errnum,0) <> 0) then
                                                        --GOTO next_record;
							                            continue;
                                                        end if;

                                        END IF;

                        BEGIN
                  --To retrieve program enrolled record for the given program enrolled objid
                  SELECT pe.*
                  INTO   l_pgm_enrolled_rec
                  FROM   x_program_enrolled pe
                  WHERE  pe.objid = i_enrollment_dtl(i_enrl_rec).prg_enrol_objid;

                EXCEPTION
                   WHEN OTHERS THEN
                   o_errnum  := 980;
                   o_errstr  := 'rt_recurring_payment:  '||substr(sqlerrm,1,100);
                   billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment'          ,
                                                        i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN               ,
                                                        i_err_num  =>  o_errnum                                       ,
                                                        i_err_msg  =>  o_errstr                                       ,
                                                        i_desc     =>  'Error while retrieve program enrolled record' ,
                                                        i_severity =>  1
                                                        );
                                 --       GOTO next_record;

                END;
                  --
                  IF l_pgm_enrolled_rec.x_esn IS NULL THEN

                     --Insert record into x_program_error_log table
                     o_errnum  := 981;
                     o_errstr  := 'ESN IS NULL IN X_PROGRAM_ENROLLED TABLE';
                                         --
                     billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment'     ,
                                                          i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN          ,
                                                          i_err_num  =>  o_errnum                                  ,
                                                          i_err_msg  =>  o_errstr                                  ,
                                                          i_desc     =>  'ESN IS NULL IN X_PROGRAM_ENROLLED TABLE' ,
                                                          i_severity =>  1
                                                          );
                    -- GOTO next_record;
                    continue;
                                  --
                  END IF; --END IF for l_pgm_enrolled_rec.x_esn IS NULL condition


               BEGIN
                 --Retrieve the next cycle date
                 SELECT get_next_cycle_date(l_pgm_enrolled_rec.pgm_enroll2pgm_parameter,
                                            l_pgm_enrolled_rec.x_next_charge_date
                                            )
                 INTO   l_next_cycle_date
                 FROM   DUAL;

               EXCEPTION
                   WHEN OTHERS THEN
                   o_errnum  := 982;
                   o_errstr  := 'rt_recurring_payment:  '||substr(sqlerrm,1,100);
                                   --
                   billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment' ,
                                                        i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN      ,
                                                        i_err_num  =>  o_errnum                              ,
                                                        i_err_msg  =>  o_errstr                              ,
                                                        i_desc     =>  'Error while retrieve next cycle date',
                                                        i_severity =>  1
                                                        );
               END;
               --
               l_charge_desc         := 'Program charges for the cycle '||TO_CHAR(l_pgm_enrolled_rec.x_next_charge_date,'MM/DD/YYYY');
               --
               IF (l_next_cycle_date IS NOT NULL) THEN
                   l_charge_desc       := l_charge_desc || ' ' || ' to ' || TO_CHAR (l_next_cycle_date - 1, 'MM/DD/YYYY');
               END IF;


               IF  l_dup_chk > 0 THEN


                 BEGIN
                     SELECT ppd.objid,
                            pph.objid
                        INTO   l_ppd_objid,
                               l_pph_objid
                        FROM   x_program_purch_dtl ppd,
                               x_program_purch_hdr pph
                        WHERE  ppd.pgm_purch_dtl2pgm_enrolled = i_enrollment_dtl(i_enrl_rec).prg_enrol_objid
                        AND    ppd.pgm_purch_dtl2prog_hdr     = pph.objid
                                    AND    ppd.x_esn                      = i_enrollment_dtl(i_enrl_rec).esn
                                    AND    pph.prog_hdr2x_pymt_src        = i_enrollment_dtl(i_enrl_rec).pymt_src_objid
                                    AND    pph.x_amount                   = l_amount
                        AND    TRUNC(pph.x_rqst_date)         = TRUNC(SYSDATE);


                 EXCEPTION
                 WHEN OTHERS THEN
                               o_errnum := 978;
                                o_errstr := 'Error in selecting Duplicate Transaction';

                                billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment'                    ,
                                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).prg_enrol_objid             ,
                                                                     i_err_num  =>  o_errnum                                                 ,
                                                                     i_err_msg  =>  o_errstr || ' - ' || substr(sqlerrm,1,100)                                                ,
                                                                     i_desc     =>  'Duplicate Transaction' ,
                                                                     i_severity =>  1
                                                                     );
                                RETURN;
                 END;



                                  l_merchant_id := get_merchant_id(cst.get_bus_org_id(i_esn => l_esn)   ,
                                                           i_enrollment_dtl(i_enrl_rec).prg_enrol_objid ,
                                                           l_pgm_enrolled_rec.pgm_enroll2pgm_parameter  ,
                                                           bmultimerchantflag
                                                           ) ;

                  -- Assignment for Merchant Reference Number
                  l_merchant_ref_no := merchant_ref_number;  -- function
                  --
                  SELECT sa.rt_rec_pymnt_dtl_type(i_enrollment_dtl(i_enrl_rec).bill_acct_num                                                                                            ,
                                                                                i_enrollment_dtl(i_enrl_rec).webuser_objid                                                                                            ,
                                                                                i_enrollment_dtl(i_enrl_rec).bill_num                                                                                                 ,
                                                                                i_enrollment_dtl(i_enrl_rec).prg_enrol_objid                                                                                          ,
                                                                                l_merchant_ref_no                                                                                                                     ,
                                                                                l_merchant_id                                                                                                                         ,
                                                                                NULL                                                                                                                                  ,
                                                                                l_ppd_objid                                                                                                                           ,
                                      typ_pymt_src_dtls_rec(l_pymnt_src_rec.objid                                                                                           ,
                                                                                                l_pymnt_src_rec.x_pymt_type                                                                                     ,
                                                                                                l_pymnt_src_rec.x_status                                                                                        ,
                                                                                                l_pymnt_src_rec.x_is_default                                                                                    ,
                                                                                                l_pymnt_src_rec.x_billing_email                                                                                 ,
                                                                                                DECODE(l_pymnt_src_rec.x_pymt_type                                                                              ,
                                                                                                          'CREDITCARD'                                                                                             ,
                                                                                                          typ_creditcard_info(l_credit_card_rec.x_customer_cc_number                                               ,
                                                                                                                                          l_credit_card_rec.x_cc_type                                                          ,
                                                                                                                                          (CASE
                                                                                                                                           WHEN TO_DATE(l_credit_card_rec.x_customer_cc_expmo||l_credit_card_rec.x_customer_cc_expyr,'MMYYYY') < TRUNC(SYSDATE,'MM')
                                                                                                                                           THEN l_card_exp
                                                                                                                                           ELSE l_credit_card_rec.x_customer_cc_expmo||'-'||l_credit_card_rec.x_customer_cc_expyr
                                                                                                                                           END
                                                                                                                                           )                                                                                   ,
                                                                                                                                          NULL                                                                                 ,
                                                                                                                                          NULL                                                                                 ,
                                                                                                                                          l_credit_card_rec.x_cust_cc_num_enc                                                  ,
                                                                                                                                          l_credit_card_rec.x_cust_cc_num_key                                                  ,
                                                                                                                                          l_x_cc_algo                                                                          ,
                                                                                                                                          l_x_key_algo                                                                         ,
                                                                                                                                          l_x_cert)                                                                            ,
                                                                                                                                          NULL)                                                                                ,
                                                                                                DECODE(l_pymnt_src_rec.x_pymt_type,'CREDITCARD',l_credit_card_rec.x_customer_firstname,l_bank_acount_rec.x_customer_firstname),
                                                                                                DECODE(l_pymnt_src_rec.x_pymt_type,'CREDITCARD',l_credit_card_rec.x_customer_lastname,l_bank_acount_rec.x_customer_lastname),
                                                                                                NVL(DECODE(l_pymnt_src_rec.x_pymt_type,'CREDITCARD',l_credit_card_rec.x_customer_email,l_bank_acount_rec.x_customer_email),'null@cybersource.com'),
                                                                                                address_type_rec(l_address_rec.address                                                                          ,
                                                                                                                          l_address_rec.address_2                                                                        ,
                                                                                                                          l_address_rec.city                                                                             ,
                                                                                                                          l_address_rec.state                                                                            ,
                                                                                                                          l_country_name                                                                                 ,
                                                                                                                          l_address_rec.zipcode)                                                                         ,
                                                                                                NULL                                                                                                                          ,
                                                                                                DECODE(l_pymnt_src_rec.x_pymt_type                                                                                            ,
                                                                                                                'ACH'                                                                                                                  ,
                                                                                            typ_ach_info(l_bank_acount_rec.x_routing                                                                               ,
                                                                                                                  l_bank_acount_rec.x_customer_acct                                                                         ,
                                                                                                                  l_bank_acount_rec.x_aba_transit                                                                           ,
                                                                                                                  l_bank_acount_rec.x_customer_acct_key                                                                     ,
                                                                                                                  l_bank_acount_rec.x_customer_acct_enc                                                                     ,
                                                                                                                  l_x_cert                                                                                                  ,
                                                                                                                  l_x_key_algo                                                                                              ,
                                                                                                                  l_x_cc_algo)                                                                                              ,
                                                                                                                         NULL)                                                                                                     ,
                                                                                        typ_aps_info(NULL,NULL,NULL)
                                                                                           )
                                                )
                                                BULK COLLECT INTO l_rt_rec_pymnt_dtl_tab
                                                FROM DUAL;


                      o_prg_purch_hdr_objid := l_pph_objid;
                      o_rt_rec_pymnt_dtl    := l_rt_rec_pymnt_dtl_tab;

                     o_errnum  := 0;
                     o_errstr  := 'Success';
                     RETURN;

              END IF;

		     l_merchant_id := get_merchant_id(cst.get_bus_org_id(i_esn => l_esn)           ,
                                                           i_enrollment_dtl(i_enrl_rec).prg_enrol_objid ,
                                                           l_pgm_enrolled_rec.pgm_enroll2pgm_parameter  ,
                                                           bmultimerchantflag
                                                           ) ;

                  -- Assignment for Merchant Reference Number
                          l_merchant_ref_no := merchant_ref_number;  -- function

		     IF (i_enrollment_dtl(i_enrl_rec).priority IS NULL OR i_enrollment_dtl(i_enrl_rec).priority = 0) THEN
					  --To retrieve the priority value for given program enrolled objid
					  BEGIN
						  SELECT mtm.x_priority
						  INTO   l_priority
						  FROM   x_program_enrolled     pe,
								 x_program_parameters   pp,
								 mtm_batch_process_type mtm
						  WHERE  pe.objid                    = i_enrollment_dtl(i_enrl_rec).prg_enrol_objid
						  AND    pe.pgm_enroll2pgm_parameter = pp.objid
						  AND    pp.objid                    = mtm.x_prgm_objid;
					  EXCEPTION
                         WHEN OTHERS THEN
						        o_errnum := 1044;
                                o_errstr := 'Invalid Priority';
                                billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment'        ,
                                                                     i_key      =>  i_enrollment_dtl(i_enrl_rec).prg_enrol_objid ,
                                                                     i_err_num  =>  o_errnum                                     ,
                                                                     i_err_msg  =>  o_errstr || ' - ' || substr(sqlerrm,1,100)   ,
                                                                     i_desc     =>  'Invalid Priority'                           ,
                                                                     i_severity =>  1
                                                                     );
                      END;
				  ELSE
  					l_priority := i_enrollment_dtl(i_enrl_rec).priority;
				  END IF;
			-- inserting into purchase header table

			if (l_inst_purch_hdr = 0) then -- start of header insert

			--Generate and assign x_program_purch_hdr table objid
			l_pph_objid := billing_seq('X_PROGRAM_PURCH_HDR');

                 o_errnum := 0;

                  get_payment_type(i_pymnt_src_objid  => l_pymt_src_objid ,
                           o_pymnt_src_rec     => l_pymnt_src_rec ,
                           o_errstr            => o_errstr        ,
                           o_errnum            => o_errnum
                           );

          IF l_pymnt_src_rec.x_pymt_type = 'CREDITCARD' THEN


           --Invoke insert_cc_prg_trans procedure to insert record into x_cc_prog_trans table
            insert_cc_prg_trans(i_objid                     => billing_seq('X_CC_PROG_TRANS')           ,
                                i_ignore_bad_cv             => NULL                                     ,
                                i_ignore_avs                => NULL                                     ,
                                i_avs                       => NULL                                     ,
                                i_disable_avs               => NULL                                     ,
                                i_auth_avs                  => NULL                                     ,
                                i_auth_cv_result            => NULL                                     ,
                                i_score_factors             => NULL                                     ,
                                i_score_host_severity       => NULL                                     ,
                                i_score_rcode               => NULL                                     ,
                                i_score_rflag               => NULL                                     ,
                                i_score_rmsg                => NULL                                     ,
                                i_score_result              => NULL                                     ,
                                i_score_time_local          => NULL                                     ,
                                i_customer_cc_number        => l_credit_card_rec.x_customer_cc_number   ,
                                i_customer_cc_expmo         => l_credit_card_rec.x_customer_cc_expmo    ,
                                i_customer_cc_expyr         => l_credit_card_rec.x_customer_cc_expyr    ,
                                i_customer_cvv_num          => l_credit_card_rec.x_customer_cc_cv_number,
                                i_cc_lastfour               => NULL                                     ,
                                i_cc_trans2x_credit_card    => l_credit_card_rec.objid                  ,
                                i_cc_trans2x_purch_hdr      => l_pph_objid                              ,
                                o_errnum                    => o_errnum                                 ,
                                o_errstr                    => o_errstr
                                );

           --Condition to check for payment source type is ACH
           ELSIF l_pymnt_src_rec.x_pymt_type = 'ACH' THEN

          --Call this procedure to insert record into x_ach_prog_trans table
          insert_ach_prg_trans(i_objid                    => billing_seq ('X_ACH_PROG_TRANS') ,
                               i_bank_num                 => l_bank_acount_rec.x_bank_num     ,
                               i_ecp_account_no           => l_bank_acount_rec.x_customer_acct,
                               i_ecp_account_type         => l_bank_acount_rec.x_aba_transit  ,
                               i_ecp_rdfi                 => l_bank_acount_rec.x_routing      ,
                               i_ecp_settlement_method    => 'A'                              ,
                               i_ecp_payment_mode         => NULL                             ,
                               i_ecp_debit_request_id     => NULL                             ,
                               i_ecp_verfication_level    => 1                                ,
                               i_ecp_ref_number           => NULL                             ,
                               i_ecp_debit_ref_number     => NULL                             ,
                               i_ecp_debit_avs            => NULL                             ,
                               i_ecp_debit_avs_raw        => NULL                             ,
                               i_ecp_rcode                => NULL                             ,
                               i_ecp_trans_id             => NULL                             ,
                               i_ecp_ref_no               => NULL                             ,
                               i_ecp_result_code          => NULL                             ,
                               i_ecp_rflag                => NULL                             ,
                               i_ecp_rmsg                 => NULL                             ,
                               i_ecp_credit_ref_number    => NULL                             ,
                               i_ecp_credit_trans_id      => NULL                             ,
                               i_decline_avs_flags        => 'Yes'                            ,
                               i_ach_trans2x_purch_hdr    => l_pph_objid                      ,
                               i_ach_trans2x_bank_account => l_bank_acount_rec.objid          ,
                               i_ach_trans2pgm_enrolled   => NULL                             ,
                               o_errnum                   => o_errnum                         ,
                               o_errstr                   => o_errstr
                               );
         --
         END IF; -- End if for payment source type condition


          --Invoke insert_prg_purch_hdr procedure to insert record into x_program_purch_hdr table
          insert_prg_purch_hdr(i_objid                 => l_pph_objid                                       ,
                               i_rqst_source           => l_pgm_enrolled_rec.x_sourcesystem                 ,
                               i_rqst_type             => l_pymnt_src_rec.x_pymt_type                       ,
                               i_credit_card_info      => l_credit_card_rec                                 ,
                               i_bank_info             => l_bank_acount_rec                                 ,
                               i_rqst_date             => SYSDATE                                           ,
                               i_ics_applications      => 'ccAuthService_run,ccCaptureService_run'          ,
                               i_merchant_id           => l_merchant_id                                     ,
                               i_merchant_ref_number   => l_merchant_ref_no                                 ,
                               i_offer_num             => NULL                                              ,
                               i_quantity              => 1                                                 ,
                               i_merchant_product_sku  => NULL                                              ,
                               i_payment_line2program  => NULL                                              ,
                               i_product_code          => NULL                                              ,
                               i_ignore_avs            => 'Yes'                                             ,
                               i_user_po               => NULL                                              ,
                               i_avs                   => NULL                                              ,
                               i_disable_avs           => NULL                                              ,
                               i_customer_hostname     => NULL                                              ,
                               i_customer_ipaddress    => NULL                                              ,
                               i_auth_request_id       => NULL                                              ,
                               i_auth_code             => NULL                                              ,
                               i_auth_type             => NULL                                              ,
                               i_ics_rcode             => NULL                                              ,
                               i_ics_rflag             => NULL                                              ,
                               i_ics_rmsg              => NULL                                              ,
                               i_request_id            => NULL                                              ,
                               i_auth_avs              => NULL                                              ,
                               i_auth_response         => NULL                                              ,
                               i_auth_time             => NULL                                              ,
                               i_auth_rcode            => NULL                                              ,
                               i_auth_rflag            => NULL                                              ,
                               i_auth_rmsg             => NULL                                              ,
                               i_bill_request_time     => NULL                                              ,
                               i_bill_rcode            => NULL                                              ,
                               i_bill_rflag            => NULL                                              ,
                               i_bill_rmsg             => NULL                                              ,
                               i_bill_trans_ref_no     => NULL                                              ,
                               i_status                => 'INITIATED'                                       ,
                               i_bill_address1         => NVL(l_address_rec.address  ,'No Address Provided'),
                               i_bill_address2         => NVL(l_address_rec.address_2,'No Address Provided'),
                               i_bill_city             => l_address_rec.city                                ,
                               i_bill_state            => l_address_rec.state                               ,
                               i_bill_zip              => l_address_rec.zipcode                             ,
                               i_bill_country          => 'USA'                                             ,
                               i_esn                   => NULL                                              ,
                               i_amount                => i_enrollment_hdr.amount_without_tax  - NVL(i_enrollment_hdr.discount_amt,0) ,
                               i_tax_amount            => i_enrollment_hdr.sales_tax_amount                 ,
                               i_auth_amount           => NULL                                              ,
                               i_bill_amount           => NULL                                              ,
                               i_user                  => 'BRM'                                             ,
                               i_credit_code           => NULL                                              ,
                               i_purch_hdr2user        => NULL                                              ,
                               i_purch_hdr2esn         => NULL                                              ,
                               i_purch_hdr2rmsg_codes  => NULL                                              ,
                               i_purch_hdr2cr_purch    => NULL                                              ,
                               i_prog_hdr2x_pymt_src   => l_pymt_src_objid                                  ,
                               i_prog_hdr2web_user     => l_pgm_enrolled_rec.pgm_enroll2web_user            ,
                               i_prog_hdr2prog_batch   => NULL                                              ,
                               i_payment_type          => 'RECURRING'                                       ,
                               i_e911_tax_amount       => i_enrollment_hdr.e911_tax_amount                  ,
                               i_usf_tax_amount        => i_enrollment_hdr.usf_tax_amount                   ,
                               i_rcrf_tax_amount       => i_enrollment_hdr.rcrf_tax_amount                  ,
                               i_process_date          => SYSDATE                                           ,
                               i_discount_amount       => i_enrollment_hdr.discount_amt                     ,
                               i_priority              => NVL(l_priority,20)                                ,
                               o_errnum                => o_errnum                                          ,
                               o_errstr                => o_errstr
                               );

			 l_inst_purch_hdr := 1;  -- to avoid duplicate entry
                --
                END IF; -- End of header insert



               --Generate and assign x_program_purch_dtl table objid
                           l_ppd_objid := billing_seq('X_PROGRAM_PURCH_DTL');

                -- Call procedure to insert record into x_program_purch_dtl table
                insert_prg_purch_dtl (i_objid                      => l_ppd_objid                                     ,
                                      i_esn                        => i_enrollment_dtl(i_enrl_rec).esn                ,
                                      i_amount                     => i_enrollment_dtl(i_enrl_rec).amount_without_tax ,
                                      i_charge_desc                => l_charge_desc                                   ,
                                      i_cycle_start_date           => l_pgm_enrolled_rec.x_next_charge_date           ,
                                      i_cycle_end_date             => l_next_cycle_date                               ,
                                      i_pgm_purch_dtl2pgm_enrolled => l_pgm_enrolled_rec.objid                        ,
                                      i_pgm_purch_dtl2prog_hdr     => l_pph_objid                                     ,
                                      i_pgm_purch_dtl2penal_pend   => NULL                                            ,
                                      i_tax_amount                 => i_enrollment_dtl(i_enrl_rec).sales_tax_amount   ,
                                      i_e911_tax_amount            => i_enrollment_dtl(i_enrl_rec).e911_tax_amount    ,
                                      i_usf_tax_amount             => i_enrollment_dtl(i_enrl_rec).usf_tax_amount     ,
                                      i_rcrf_tax_amount            => i_enrollment_dtl(i_enrl_rec).rcrf_tax_amount    ,
                                      i_priority                   => NVL(l_priority,20)                              ,
                                      o_errnum                     => o_errnum                                        ,
                                      o_errstr                     => o_errstr
                                      );

                   --Invoke sp_insert_payment_staging_tbl procedure to insert record into rec_pymnt_staging_tbl table
                  sp_insert_payment_staging_tbl(i_prog_enrolled_objid    =>  i_enrollment_dtl(i_enrl_rec).prg_enrol_objid                    ,
												i_prog_purch_hdr_objid   =>  l_pph_objid                    ,
												i_program_gencode_objid  =>  NULL                           ,
												i_x_cc_red_inv_objid     =>  NULL                           ,
												i_rqst_source            =>  'BRM'                          ,
												i_rqst_type              =>  'RECURRING'                    ,
												i_rqst_date              =>  NULL                           ,
												i_flow_id                =>  i_enrollment_hdr.bill_acct_num ,
												i_flow                   =>  'BRM_RECURRING_CHARGE_PREPARE' ,
												i_milestone              =>  'PREPARE_RECURRING_CHARGE'     ,
												i_flow_status            =>  'PREP_COMPLETE'                ,
												i_milestone_status       =>  'SUCCESS'                      ,
												i_err_code               =>  NULL                           ,
												i_err_msg                =>  NULL                           ,
												o_rec_purch_stage_objid  =>  l_payment_staging_tbl_objid    ,
												o_errnum                 =>  o_errnum                       ,
												o_errstr                 =>  o_errstr
                                                );


                        -- To check whether promo code is not null
                        IF i_enrollment_dtl(i_enrl_rec).promo_code IS NOT NULL THEN

                                        BEGIN
                      --Inserting record into x_program_discount_hist
                                          INSERT INTO x_program_discount_hist
                                                                 (objid                     ,
                                                                  x_discount_amount         ,
                                                                  pgm_discount2x_promo      ,
                                                                  pgm_discount2pgm_enrolled ,
                                                                  pgm_discount2prog_hdr     ,
                                                                  pgm_discount2web_user
                                                                  )
                                                   VALUES(billing_seq ('X_PROGRAM_DISCOUNT_HIST')       ,
                                                                  NULL                                          ,
                                                                  NULL                                          ,
                                                              i_enrollment_dtl(i_enrl_rec).prg_enrol_objid  ,
                                                                  l_pph_objid                                   ,
                                                                  l_pgm_enrolled_rec.pgm_enroll2web_user
                                                                  );
                                                   EXCEPTION
                                                                 WHEN OTHERS THEN
                                                                 o_errnum  := 979;
                                                                 o_errstr  := 'rt_recurring_payment:  '||substr(sqlerrm,1,100);
                                                                 --
                           billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment'                    ,
                                                                i_key      =>  i_enrollment_dtl(i_enrl_rec).ESN                         ,
                                                                i_err_num  =>  o_errnum                                                 ,
                                                                i_err_msg  =>  o_errstr                                                 ,
                                                                i_desc     =>  'Error while insert record into x_program_discount_hist' ,
                                                                i_severity =>  1
                                       );
                                    END;
                --
                                END IF;  --End if for promo code condition



                          l_esn := i_enrollment_dtl(i_enrl_rec).esn;


        SELECT sa.rt_rec_pymnt_dtl_type(i_enrollment_dtl(i_enrl_rec).bill_acct_num                                                                                            ,
                                                                                i_enrollment_dtl(i_enrl_rec).webuser_objid                                                                                            ,
                                                                                i_enrollment_dtl(i_enrl_rec).bill_num                                                                                                 ,
                                                                                i_enrollment_dtl(i_enrl_rec).prg_enrol_objid                                                                                          ,
                                                                                l_merchant_ref_no                                                                                                                     ,
                                                                                l_merchant_id                                                                                                                         ,
                                                                                NULL                                                                                                                                  ,
                                                                                l_ppd_objid                                                                                                                           ,
                                                                                typ_pymt_src_dtls_rec(l_pymnt_src_rec.objid                                                                                           ,
                                                                                                              l_pymnt_src_rec.x_pymt_type                                                                                     ,
                                                                                                              l_pymnt_src_rec.x_status                                                                                        ,
                                                                                                              l_pymnt_src_rec.x_is_default                                                                                    ,
                                                                                                              l_pymnt_src_rec.x_billing_email                                                                                 ,
                                                                                                              DECODE(l_pymnt_src_rec.x_pymt_type                                                                              ,
                                                                                                                                 'CREDITCARD'                                                                                             ,
                                                                                                                                         typ_creditcard_info(l_credit_card_rec.x_customer_cc_number                                               ,
                                                                                                                                                             l_credit_card_rec.x_cc_type                                                          ,
                                                                                                                                                                                 (CASE
                                                                                                                                                                                  WHEN TO_DATE(l_credit_card_rec.x_customer_cc_expmo||l_credit_card_rec.x_customer_cc_expyr,'MMYYYY') < TRUNC(SYSDATE,'MM')
                                                                                                                                                                                  THEN l_card_exp
                                                                                                                                                                                  ELSE l_credit_card_rec.x_customer_cc_expmo||'-'||l_credit_card_rec.x_customer_cc_expyr
                                                                                                                                                                                  END
                                                                                                                                                                                  )                                                                                   ,
                                                                                                                                                             NULL                                                                                 ,
                                                                                                                                                             NULL                                                                                 ,
                                                                                                                                                             l_credit_card_rec.x_cust_cc_num_enc                                                  ,
                                                                                                                                                             l_credit_card_rec.x_cust_cc_num_key                                                  ,
                                                                                                                                                             l_x_cc_algo                                                                          ,
                                                                                                                                                             l_x_key_algo                                                                         ,
                                                                                                                                                             l_x_cert)                                                                            ,
                                                                                                                                                                                 NULL)                                                                                ,
                                                                                                              NVL(l_bank_acount_rec.x_customer_firstname,l_credit_card_rec.x_customer_firstname)                              ,
                                                                                                              NVL(l_bank_acount_rec.x_customer_lastname,l_credit_card_rec.x_customer_lastname)                                ,
                                                                                                              NVL(l_bank_acount_rec.x_customer_email,NVL(l_credit_card_rec.x_customer_email,'null@cybersource.com'))                                  ,
                                                                                                              address_type_rec(l_address_rec.address                                                                          ,
                                                                                                                                                   l_address_rec.address_2                                                                        ,
                                                                                                                                                   l_address_rec.city                                                                             ,
                                                                                                                                                   l_address_rec.state                                                                            ,
                                                                                                                                                   l_country_name                                                                                 ,
                                                                                                                                                   l_address_rec.zipcode)                                                                         ,
                                                                                                NULL                                                                                                                          ,
                                                                                                DECODE(l_pymnt_src_rec.x_pymt_type                                                                                            ,
                                                                                                       'ACH'                                                                                                                  ,
                                                                                                           typ_ach_info(l_bank_acount_rec.x_routing                                                                               ,
                                                                                                                                    l_bank_acount_rec.x_customer_acct                                                                         ,
                                                                                                                                    l_bank_acount_rec.x_aba_transit                                                                           ,
                                                                                                                                    l_bank_acount_rec.x_customer_acct_key                                                                     ,
                                                                                                                                    l_bank_acount_rec.x_customer_acct_enc                                                                     ,
                                                                                                                                    l_x_cert                                                                                                  ,
                                                                                                                                    l_x_key_algo                                                                                              ,
                                                                                                                                    l_x_cc_algo)                                                                                              ,
                                                                                                                                        NULL)                                                                                                     ,
                                                                                                       typ_aps_info(NULL                                                                                                      ,
                                                                                                                                NULL                                                                                                      ,
                                                                                                                                NULL)
                                                                                                            )
                                                                                )
                                                BULK COLLECT INTO ll_rt_rec_pymnt_dtl_tab
                                                FROM DUAL;




                        --Extend the collection variable
                          l_rt_rec_pymnt_dtl_tab.extend;
                        --
                        l_rt_rec_pymnt_dtl_tab(l_rt_rec_pymnt_dtl_tab.LAST) := ll_rt_rec_pymnt_dtl_tab(1);

                       -- <<next_record>> -- to continue to get next record in loop

                      --  NULL;

         END LOOP; --This is the end loop for i_enrollment_dtl input parameter

                o_prg_purch_hdr_objid := l_pph_objid;
                o_rt_rec_pymnt_dtl    := l_rt_rec_pymnt_dtl_tab;

                if(nvl(o_errnum,0) = 0) then
                o_errnum  := 0;
                o_errstr  := 'Success';
                end if;

    --Exception Handling for Main Section
    EXCEPTION
    WHEN OTHERS THEN
           o_errnum  := 983;
           o_errstr  := '-rt_recurring_payment:  '||SUBSTR(SQLERRM,1,100);
           --
           billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.rt_recurring_payment',
                                                i_key      =>  i_enrollment_hdr.bill_acct_num       ,
                                                i_err_num  =>  o_errnum                             ,
                                                i_err_msg  =>  o_errstr                             ,
                                                i_desc     =>  'Main Exception - Recurring Payment' ,
                                                i_severity =>  1
                                               );
END rt_recurring_payment;
--

PROCEDURE rt_rec_payment_recon (i_bill_acct_num          IN  VARCHAR2                     ,
                                i_bill_num               IN  VARCHAR2                     ,
                                i_webuser_objid          IN  NUMBER                       ,
                                i_src_system             IN  VARCHAR2                     ,
                                i_pymt_src_objid         IN  NUMBER                       ,
								i_prg_purch_hdr_objid    IN  NUMBER                       ,
								i_rt_rec_pymnt_dtl       IN  rt_rec_pymnt_dtl_type        ,
								i_rt_rec_pymnt_auth_dtl  IN  rt_rec_pymnt_auth_dtl_type   ,
								i_rt_rec_pymnt_bill_dtl  IN  rt_rec_pymnt_bill_dtl_type   ,
								i_rt_rec_pymnt_ics_dtl   IN  rt_rec_pymnt_ics_dtl_type    ,
								i_rt_rec_pymnt_resp_dtl  IN  rt_rec_pymnt_resp_dtl_type   ,
								i_rt_rec_pymnt_score_dtl IN  rt_rec_pymnt_score_dtl_type  ,
                                o_errnum                 OUT NUMBER                       ,
                                o_errstr                 OUT VARCHAR2
                                )
AS
  --Row type variable for program enrolled record
  l_pgm_purch_rec x_program_purch_hdr%ROWTYPE;
  l_enroll_rec    x_program_enrolled%ROWTYPE;

  --Local variables
  l_pgm_enrolled_objid NUMBER      ;
  l_merchant_ref_num   VARCHAR2(30);
  l_merchant_id        VARCHAR2(30);
  l_prog_purch_objid   NUMBER      ;


BEGIN --Main Section starts

o_errnum := 0;

     --Input parameter NULL check validation
          IF i_prg_purch_hdr_objid IS NULL THEN
                 o_errnum  := 984;
                 o_errstr  := 'program purchase hdr objid cannot be null';
                 billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_rec_payment_recon' ,
                                                        i_key      =>  i_bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                 RETURN;
          END IF;


  IF (i_rt_rec_pymnt_dtl IS NOT NULL and i_rt_rec_pymnt_dtl.prg_enrol_objid IS NULL) THEN
                 o_errnum  := 991;
                 o_errstr  := 'payment details program enroll objid cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_rec_payment_recon' ,
                                                        i_key      =>  i_bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                 RETURN;
          END IF;

          IF (i_rt_rec_pymnt_auth_dtl IS NOT NULL AND i_rt_rec_pymnt_auth_dtl.prg_purch_hdr_objid IS NULL) THEN
                 o_errnum  := 992;
                 o_errstr  := 'payment auth program purchase objid cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_rec_payment_recon' ,
                                                        i_key      =>  i_bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                 RETURN;
          END IF;

          IF (i_rt_rec_pymnt_bill_dtl IS NOT NULL AND i_rt_rec_pymnt_bill_dtl.prg_purch_hdr_objid IS NULL) THEN
                 o_errnum  := 993;
                 o_errstr  := 'payment bill program purchase objid cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_rec_payment_recon' ,
                                                        i_key      =>  i_bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                 RETURN;
          END IF;

          IF (i_rt_rec_pymnt_ics_dtl IS NOT NULL AND i_rt_rec_pymnt_ics_dtl.prg_purch_hdr_objid IS NULL) THEN
                 o_errnum := 994;
                 o_errstr := 'payment ics program purchase objid cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_rec_payment_recon' ,
                                                        i_key      =>  i_bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                 RETURN;
          END IF;

          IF (i_rt_rec_pymnt_resp_dtl IS NOT NULL AND i_rt_rec_pymnt_resp_dtl.prg_purch_hdr_objid IS NULL) THEN
                 o_errnum := 995;
                 o_errstr := 'payment resp program purchase objid cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_rec_payment_recon' ,
                                                        i_key      =>  i_bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                 RETURN;
          END IF;

          IF (i_rt_rec_pymnt_score_dtl IS NOT NULL AND i_rt_rec_pymnt_score_dtl.prg_purch_hdr_objid IS NULL) THEN
                 o_errnum := 996;
                 o_errstr := 'payment score program purchase objid cannot be null';
                  billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.rt_rec_payment_recon' ,
                                                        i_key      =>  i_bill_acct_num     ,
                                                        i_err_num  =>  o_errnum                             ,
                                                        i_err_msg  =>  o_errstr                             ,
                                                        i_desc     =>  'Input data cannot be NULL'          ,
                                                        i_severity =>  1
                                                        );
                 RETURN;
          END IF;



        BEGIN
          --To check whether record exists in X_PROGRAM_PURCH_HDR
          SELECT pe.*
          INTO   l_pgm_purch_rec
          FROM   x_program_purch_hdr pe
          WHERE  pe.objid = i_prg_purch_hdr_objid;

        EXCEPTION
                        WHEN OTHERS THEN
                          o_errnum := 997;
                          o_errstr := 'rt_rec_payment_recon:  '||SUBSTR(sqlerrm,1,100);
                          billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon'           ,
															   i_key      => i_bill_num                                      ,
															   i_err_num  => o_errnum                                        ,
															   i_err_msg  => o_errstr                                        ,
															   i_desc     => 'Error while retrieve program purch hdr record' ,
															   i_severity => 1
															   );
                          RETURN;
        END;

                  --Condition to check whether status in INTIATED or FAILED
                  IF l_pgm_purch_rec.x_status in ('INITIATED', 'FAILED') THEN

                        BEGIN
                                -- Updating x_program_purch_hdr table with AUTH/ICS/Bill column for given objid
                            UPDATE x_program_purch_hdr
                                                         SET    x_rqst_date          = SYSDATE                                       ,
                                           x_avs                = i_rt_rec_pymnt_auth_dtl.auth_avs_raw          ,
                                           x_auth_request_id    = i_rt_rec_pymnt_auth_dtl.auth_request_id       ,
                                           x_auth_code          = i_rt_rec_pymnt_auth_dtl.auth_auth_code        ,
                                           x_ics_rcode          = i_rt_rec_pymnt_ics_dtl.ics_rcode              ,
                                           x_ics_rflag          = i_rt_rec_pymnt_ics_dtl.ics_rflag              ,
                                           x_ics_rmsg           = i_rt_rec_pymnt_ics_dtl.ics_rmsg               ,
                                           x_request_id         = i_rt_rec_pymnt_resp_dtl.requestid             ,
                                           x_auth_avs           = i_rt_rec_pymnt_auth_dtl.auth_auth_avs         ,
                                           x_auth_response      = i_rt_rec_pymnt_auth_dtl.auth_auth_response    ,
                                           x_auth_time          = i_rt_rec_pymnt_auth_dtl.auth_auth_time        ,
                                           x_auth_rcode         = i_rt_rec_pymnt_auth_dtl.auth_rcode            ,
                                           x_auth_rflag         = i_rt_rec_pymnt_auth_dtl.auth_rflag            ,
                                           x_auth_rmsg          = i_rt_rec_pymnt_auth_dtl.auth_rmsg             ,
                                           x_bill_request_time  = i_rt_rec_pymnt_bill_dtl.bill_bill_request_time,
                                           x_bill_rcode         = i_rt_rec_pymnt_bill_dtl.bill_rcode            ,
                                           x_bill_rmsg          = i_rt_rec_pymnt_bill_dtl.bill_rmsg             ,
                                           x_bill_rflag         = i_rt_rec_pymnt_bill_dtl.bill_rflag            ,
                                           x_bill_trans_ref_no  = i_rt_rec_pymnt_bill_dtl.bill_trans_ref_no     ,
                                           x_status             = 'PROCESSED'                                   ,
                                           x_auth_amount        = i_rt_rec_pymnt_auth_dtl.auth_auth_amount      ,
                                           x_bill_amount        = i_rt_rec_pymnt_bill_dtl.bill_bill_amount      ,
                                                                   purch_hdr2rmsg_codes = (SELECT objid
                                                                                                          FROM   sa.table_x_purch_codes
                                                                                                          WHERE  x_app        = 'CyberSource'
                                                                                                          AND    x_code_type  = 'rflag'
                                                                                                          AND    x_code_value = i_rt_rec_pymnt_ics_dtl.ics_rflag
                                                                                                          AND    x_language   = 'English'
																										  AND    x_ics_rcode  = i_rt_rec_pymnt_ics_dtl.ics_rcode
                                                                                                          )
                                                                  WHERE objid = l_pgm_purch_rec.objid;

                                EXCEPTION
                                    WHEN OTHERS THEN
                                        o_errnum := 998;
                                        o_errstr := '-rt_rec_payment_recon:  '||SUBSTR(sqlerrm,1,100);
                                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon'              ,
                                                                                                             i_key      => i_bill_num                                         ,
                                                                                                             i_err_num  => o_errnum                                           ,
                                                                                                             i_err_msg  => o_errstr                                           ,
                                                                                                             i_desc     => 'Error in while updating x_program_purch_hdr table',
                                                                                                             i_severity => 1
																					    );

                     RETURN;
                        END;

                         IF i_rt_rec_pymnt_dtl.pymt_src_dtls.payment_type = 'CREDITCARD' THEN
                         --
                                BEGIN
                                        --Updating record in x_cc_prog_trans table
                                        UPDATE x_cc_prog_trans
                                        SET    x_auth_cv_result           = i_rt_rec_pymnt_auth_dtl.auth_cv_result       ,
											   x_score_factors            = i_rt_rec_pymnt_score_dtl.score_factors       ,
											   x_score_host_severity      = i_rt_rec_pymnt_score_dtl.score_host_severity ,
											   x_score_rcode              = i_rt_rec_pymnt_score_dtl.score_rcode         ,
											   x_score_rflag              = i_rt_rec_pymnt_score_dtl.score_rflag         ,
											   x_score_rmsg               = i_rt_rec_pymnt_score_dtl.score_rmsg          ,
											   x_score_result             = i_rt_rec_pymnt_score_dtl.score_score_result  ,
											   x_score_time_local         = i_rt_rec_pymnt_score_dtl.score_time_local
                                        WHERE  x_cc_trans2x_purch_hdr     = l_pgm_purch_rec.objid;

                                EXCEPTION
                                    WHEN OTHERS THEN
                                        o_errnum := 999; --Error code needs to modified
                                        o_errstr := '-rt_rec_payment_recon:  '||SUBSTR(SQLERRM,1,100);
                                        --
                                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon'          ,
                                                                                                             i_key      => i_bill_num                                     ,
                                                                                                             i_err_num  => o_errnum                                       ,
                                                                                                             i_err_msg  => o_errstr                                       ,
                                                                                                             i_desc     => 'Error in while updating x_cc_prog_trans table',
                                                                                                             i_severity => 1
                                                                                                                 );
								RETURN;
                     END;
                        --
                        ELSIF  i_rt_rec_pymnt_dtl.pymt_src_dtls.payment_type = 'ACH' THEN
                        --
                                        BEGIN
                                                --Updating record in x_ach_prog_trans table
                                                UPDATE x_ach_prog_trans
                                                  SET  x_ecp_debit_request_id    = NULL ,
													   x_ecp_debit_avs           = NULL ,
													   x_ecp_debit_avs_raw       = NULL ,
													   x_ecp_rcode               = NULL ,
													   x_ecp_trans_id            = NULL ,
													   x_ecp_result_code         = NULL ,
													   x_ecp_rflag               = NULL ,
													   x_ecp_rmsg                = NULL ,
													   x_ecp_debit_ref_number    = NULL ,
													   x_ecp_ref_no              = NULL
                                                 WHERE ach_trans2x_purch_hdr   = l_pgm_purch_rec.objid;
                                        EXCEPTION
                                                WHEN OTHERS THEN
                                                o_errnum := 1000;
                                                o_errstr := '-rt_rec_payment_recon:  '||SUBSTR(SQLERRM,1,100);
                                                billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon'          ,
                                                                                                                         i_key      => i_bill_num                                     ,
                                                                                                                         i_err_num  => o_errnum                                       ,
                                                                                                                         i_err_msg  => o_errstr                                       ,
                                                                                                                         i_desc     => 'Error in while updating x_ach_prog_trans table',
                                                                                                                         i_severity => 1
                                                                                                                         );
										RETURN;
                                        END;
                        END IF;

                                BEGIN
                                        -- Update rec_pymnt_staging_tbl table  to mark it as RECON_COMPLETE status
                                        UPDATE rec_pymnt_staging_tbl
                                        SET    update_timestamp = SYSDATE,
                                               X_RQST_DATE      = SYSDATE,
                                                   X_FLOW           = 'BRM_RECURRING_CHARGE_PROCESS',
                                                   X_MILESTONE      = 'PROCESS_RECURRING_CHARGE',
                                                   X_FLOW_STATUS    = 'RECON_COMPLETE',
                                                   X_MILESTONE_STATUS = 'SUCCESS',
						   X_ERROR_CODE       = null,
						   X_ERROR_MSG        = null
                                        WHERE  x_rec_pymnt_stg2prg_purch_hdr            = l_pgm_purch_rec.objid;

                                EXCEPTION
                                        WHEN OTHERS THEN
                                        o_errnum := 1001;
                                        o_errstr := '-rt_rec_payment_recon:  '||SUBSTR(sqlerrm,1,100);
                                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon'                ,
                                                                                                                 i_key      => i_bill_num                                           ,
                                                                                                                 i_err_num  => o_errnum                                             ,
                                                                                                                 i_err_msg  => o_errstr                                             ,
                                                                                                                 i_desc     => 'Error in while updating rec_pymnt_staging_tbl table',
                                                                                                                 i_severity => 1
                                                                                                                 );
								RETURN;
                                END;
                   END IF;


				--CR45279 changes - Start
				BEGIN
					SELECT r.*
					INTO   l_enroll_rec
					FROM   x_program_enrolled r
					WHERE  objid = i_rt_rec_pymnt_dtl.prg_enrol_objid;
				EXCEPTION
				   WHEN OTHERS THEN
				        o_errnum := 1047;
                        o_errstr := '-rt_rec_payment_recon:  '||SUBSTR(sqlerrm,1,100);
                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon' ,
														     i_key      => i_bill_num                            ,
														     i_err_num  => o_errnum                              ,
														     i_err_msg  => o_errstr                              ,
														     i_desc     => 'Error while retrieve from x_program_enrolled'          ,
														     i_severity => 1
														    );
				END;

				IF o_errnum = 0 THEN

					BEGIN
						UPDATE x_program_enrolled
						SET    x_charge_date = SYSDATE
						WHERE  objid = l_enroll_rec.objid;
					EXCEPTION
					   WHEN OTHERS THEN
							o_errnum := 1049;
							o_errstr := '-rt_rec_payment_recon:  '||SUBSTR(SQLERRM,1,100);
							billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon'                     ,
																 i_key      => i_bill_num                                                ,
																 i_err_num  => o_errnum                                                  ,
																 i_err_msg  => o_errstr                                                  ,
																 i_desc     => 'Error while updating x_charge_date in x_program_enrolled',
																 i_severity => 1
																 );
					END;

				 -- Call procedure to insert record into x_program_trans table
                 insert_program_trans(i_enrollment_status      => l_enroll_rec.x_enrollment_status         ,
									  i_enroll_status_reason   => 'Recurring payment received successfully',
									  i_float_given            => NULL                                     ,
									  i_cooling_given          => NULL                                     ,
									  i_grace_period_given     => NULL                                     ,
									  i_trans_date             => SYSDATE                                  ,
									  i_action_text            => 'Payment Receipt'                        ,
									  i_action_type            => 'RECURRING_PAYMENT'                      ,
									  i_reason                 => NULL                                     ,
									  i_sourcesystem           => i_src_system                             ,
									  i_esn                    => l_enroll_rec.x_esn                       ,
									  i_exp_date               => l_enroll_rec.x_exp_date                  ,
									  i_cooling_exp_date       => l_enroll_rec.x_cooling_exp_date          ,
									  i_update_status          => 'I'                                      ,
									  i_update_user            => 'BRM'                                    ,
									  i_pgm_tran2pgm_enrolled  => l_enroll_rec.objid                       ,
									  i_pgm_trans2web_user     => i_webuser_objid                          ,
									  i_pgm_trans2site_part    => l_enroll_rec.pgm_enroll2site_part        ,
									  o_errnum                 => o_errnum                                 ,
									  o_errstr                 => o_errstr
									  );

				-- Call procedure to insert record into x_billing_log table
				insert_billing_log(i_log_category         => 'Payment'                                ,
								   i_log_title            => 'RECURRING_PAYMENT'                      ,
								   i_log_date             => SYSDATE                                  ,
								   i_details              => 'Recurring payment received successfully',
								   i_additional_details   => NULL                                     ,
								   i_program_name         => NULL                                     ,
								   i_nickname             => NULL                                     ,
								   i_esn                  => l_enroll_rec.x_esn                       ,
								   i_originator           => NULL                                     ,
								   i_contact_first_name   => NULL                                     ,
								   i_contact_last_name    => NULL                                     ,
								   i_agent_name           => 'BRM'                                    ,
								   i_sourcesystem         => i_src_system                             ,
								   i_billing_log2web_user => i_webuser_objid                          ,
								   o_errnum               => o_errnum                                 ,
								   o_errstr               => o_errstr
								   );
				END IF;
				--CR45279 changes - End

				o_errnum  := 0;
                o_errstr  := 'Success';

EXCEPTION
        WHEN OTHERS THEN
          o_errnum := 1002;
          o_errstr := '-rt_rec_payment_recon:  '||SUBSTR(SQLERRM,1,100);
          billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.rt_rec_payment_recon' ,
											   i_key      => i_bill_num                            ,
											   i_err_num  => o_errnum                              ,
											   i_err_msg  => o_errstr                              ,
											   i_desc     => 'Main Exception - Reconcile'          ,
											   i_severity => 1
											   );
END rt_rec_payment_recon;

--This procedure will insert records into recurring payment staging table
PROCEDURE sp_insert_payment_staging_tbl(i_prog_enrolled_objid    IN  NUMBER  ,
										i_prog_purch_hdr_objid   IN  NUMBER  ,
										i_program_gencode_objid  IN  NUMBER  ,
										i_x_cc_red_inv_objid     IN  NUMBER  ,
										i_rqst_source            IN  VARCHAR2,
										i_rqst_type              IN  VARCHAR2,
										i_rqst_date              IN  DATE    ,
										i_flow_id                IN  VARCHAR2,
										i_flow                   IN  VARCHAR2,
										i_milestone              IN  VARCHAR2,
										i_flow_status            IN  VARCHAR2,
										i_milestone_status       IN  VARCHAR2,
										i_err_code               IN  VARCHAR2,
										i_err_msg                IN  VARCHAR2,
										o_rec_purch_stage_objid  OUT NUMBER  ,
										o_errnum                 OUT NUMBER  ,
										o_errstr                 OUT VARCHAR2
										)
AS

l_payment_staging_tbl_objid NUMBER;

BEGIN --Main Section

  BEGIN

        SELECT objid
		INTO   l_payment_staging_tbl_objid
		FROM   rec_pymnt_staging_tbl
        WHERE  x_rec_pymnt_stg2prg_purch_hdr = i_prog_purch_hdr_objid
        AND    x_rec_pymnt_stg2prg_enrolled =  i_prog_enrolled_objid;

         UPDATE rec_pymnt_staging_tbl
		 SET    x_rqst_source                 =  NVL(i_rqst_source,x_rqst_source)                         ,
				x_rqst_type                   =  NVL(i_rqst_type,x_rqst_type)                             ,
				x_rqst_date                   =  NVL(i_rqst_date,SYSDATE)                                 ,
				x_rec_pymnt_stg2prg_gencode   =  NVL(i_program_gencode_objid,x_rec_pymnt_stg2prg_gencode) ,
				x_rec_pymnt_stg2x_cc_red_inv  =  NVL(i_x_cc_red_inv_objid,x_rec_pymnt_stg2x_cc_red_inv)   ,
				x_flow_id                     =  NVL(i_flow_id,x_flow_id)                                 ,
				x_flow                        =  NVL(i_flow,x_flow)                                       ,
				x_milestone                   =  NVL(i_milestone,x_milestone)                             ,
				x_flow_status                 =  NVL(i_flow_status,x_flow_status)                         ,
				x_milestone_status            =  NVL(i_milestone_status,x_milestone_status)               ,
				x_error_code                  =  NVL(i_err_code,x_error_code )                            ,
				x_error_msg                   =  NVL(i_err_msg,x_error_msg)                               ,
				update_timestamp              =  SYSDATE                                                  ,
				updated_by                    = 'CORECBO'
		WHERE   x_rec_pymnt_stg2prg_purch_hdr = i_prog_purch_hdr_objid
		AND     x_rec_pymnt_stg2prg_enrolled  = i_prog_enrolled_objid;

      EXCEPTION
	     WHEN NO_DATA_FOUND THEN

          --Generate and assign sequence value
          SELECT sequ_payment_staging_tbl.NEXTVAL
          INTO   l_payment_staging_tbl_objid
          FROM   DUAL;

			--Inserting record into rec_pymnt_staging_tbl table
			INSERT INTO rec_pymnt_staging_tbl(objid                         ,
											  x_rqst_source                 ,
											  x_rqst_type                   ,
											  x_rqst_date                   ,
											  x_rec_pymnt_stg2prg_enrolled  ,
											  x_rec_pymnt_stg2prg_purch_hdr ,
											  x_rec_pymnt_stg2prg_gencode   ,
											  x_rec_pymnt_stg2x_cc_red_inv  ,
											  x_flow_id                     ,
											  x_flow                        ,
											  x_milestone                   ,
											  x_flow_status                 ,
											  x_milestone_status            ,
											  x_error_code                  ,
											  x_error_msg                   ,
											  x_status                      ,
											  insert_timestamp              ,
											  update_timestamp              ,
											  created_by                    ,
											  updated_by
											  )
									  VALUES(l_payment_staging_tbl_objid ,
											 i_rqst_source               ,
											 i_rqst_type                 ,
											 NVL(i_rqst_date,SYSDATE)    ,
											 i_prog_enrolled_objid       ,
											 i_prog_purch_hdr_objid      ,
											 i_program_gencode_objid     ,
											 i_x_cc_red_inv_objid        ,
											 i_flow_id                   ,
											 i_flow                      ,
											 i_milestone                 ,
											 i_flow_status               ,
											 i_milestone_status          ,
											 i_err_code                  ,
											 i_err_msg                   ,
											 NULL                        ,
											 SYSDATE                     ,
											 NULL                        ,
											 'CORECBO'                   ,
											 NULL
											 );

         END;

        -- Output variables assignment
        o_rec_purch_stage_objid := l_payment_staging_tbl_objid;
        o_errnum                := 0                          ;
        o_errstr                := 'SUCCESS'                  ;

  EXCEPTION
          WHEN OTHERS THEN
                o_errnum := 1003;
                o_errstr := 'sp_insert_payment_staging_tbl :  '||SUBSTR(sqlerrm,1,100);
                --
                billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.sp_insert_payment_staging_tbl '                        ,
													 i_key      => i_prog_enrolled_objid                                                  ,
													 i_err_num  => o_errnum                                                               ,
													 i_err_msg  => o_errstr                                                               ,
													 i_desc     => 'Error while insert into rec_pymnt_staging_tbl' ||i_prog_enrolled_objid,
													 i_severity => 1
													 );
END sp_insert_payment_staging_tbl ;

--This procedure will perform the prefulfillment process for benefit delivery
PROCEDURE payment_pre_fulfillment   (i_esn                   IN  VARCHAR2 ,
                                     i_prog_purch_hdr_objid  IN  NUMBER   ,
                                     i_app_plan_part_num     IN  VARCHAR2 ,
                                     i_source_system         IN  VARCHAR2 ,
                                     o_soft_pin              OUT VARCHAR2 ,
                                     o_smp_number            OUT VARCHAR2 ,
                                     o_esn_status            OUT VARCHAR2 ,
                                     o_service_end_date      OUT VARCHAR2 ,
                                     o_forecast_date         OUT VARCHAR2 ,
                                     o_zipcode               OUT VARCHAR2 ,
                                     o_errnum                OUT NUMBER   ,
                                     o_errstr                OUT VARCHAR2
                                    )
AS
--local variables declaration
 l_rec_pymnt_staging_tbl  rec_pymnt_staging_tbl%ROWTYPE ;
 l_table_x_cc_red_inv     table_x_cc_red_inv%ROWTYPE    ;
 l_rec_part_inst          table_part_inst%ROWTYPE       ;
 l_rec_prog_enroll_tbl    x_program_enrolled%ROWTYPE    ;
 l_card_status            CONSTANT VARCHAR2(2) := '40'  ;
 o_next_value             NUMBER                        ;
 o_format                 VARCHAR2(200)                 ;
 p_status                 VARCHAR2(200)                 ;
 p_msg                    VARCHAR2(200)                 ;
 l_site_id                VARCHAR2(200)                 ;
 l_inv_bin_objid          NUMBER                        ;
 l_table_x_cc_red_inv_objid NUMBER                      ;
 cst     sa.customer_type := sa.customer_type();
 cstdtl  sa.customer_type;

BEGIN --Main Section

o_errnum := 0;
    --
        IF i_esn IS NULL THEN
              o_errnum := 1004;
              o_errstr := 'ESN cannot be null';
                   billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.payment_pre_fulfillment' ,
                                                        i_key      =>  i_esn                                      ,
                                                        i_err_num  =>  o_errnum                                   ,
                                                        i_err_msg  =>  o_errstr                                   ,
                                                        i_desc     =>  'Input data cannot be NULL'                ,
                                                        i_severity =>  1
														);

                   sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                                 i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                 i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
                                                 i_flow_status          =>   'BD_INITIATED'                  ,
                                                 i_milestone_status     =>   'FAILED'                        ,
                                                 i_errnum               =>    o_errnum||'_BUSINESS'          ,
                                                 i_errstr               =>    o_errstr                       ,
                                                 o_errnum               =>    o_errnum                       ,
                                                 o_errstr               =>    o_errstr
												 );
              RETURN;
        ELSIF i_prog_purch_hdr_objid IS NULL THEN
                  o_errnum := 1005;
                  o_errstr := 'Purchase Header objid cannot be null';
                   billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.payment_pre_fulfillment' ,
                                                        i_key      =>  i_esn                                      ,
                                                        i_err_num  =>  o_errnum                                   ,
                                                        i_err_msg  =>  o_errstr                                   ,
                                                        i_desc     =>  'Input data cannot be NULL'                ,
                                                        i_severity =>  1
														);

                   sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
                                                 i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                 i_milestone            =>   'PRE_BENIFIT_DELIVERY',
                                                 i_flow_status          =>   'BD_INITIATED' ,
                                                 i_milestone_status     =>   'FAILED',
                                                 i_errnum               =>    o_errnum||'_BUSINESS',
                                                 i_errstr               =>    o_errstr ,
                                                 o_errnum               =>    o_errnum,
                                                 o_errstr               =>    o_errstr
												 );
                  RETURN;
        ELSIF i_app_plan_part_num IS NULL THEN
                  o_errnum := 1006;
                  o_errstr := 'pin part num cannot be null';
                   billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.payment_pre_fulfillment' ,
                                                        i_key      =>  i_esn                                      ,
                                                        i_err_num  =>  o_errnum                                   ,
                                                        i_err_msg  =>  o_errstr                                   ,
                                                        i_desc     =>  'Input data cannot be NULL'                ,
                                                        i_severity =>  1
														);

                   sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                                 i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                 i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
                                                 i_flow_status          =>   'BD_INITIATED'                  ,
                                                 i_milestone_status     =>   'FAILED'                        ,
                                                 i_errnum               =>    o_errnum||'_BUSINESS'          ,
                                                 i_errstr               =>    o_errstr                       ,
                                                 o_errnum               =>    o_errnum                       ,
                                                 o_errstr               =>    o_errstr
												 );
                  RETURN;
        ELSIF i_source_system IS NULL THEN
                   o_errnum := 1007;
                   o_errstr := 'Source cannot be null';
                   billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.payment_pre_fulfillment' ,
                                                        i_key      =>  i_esn                                      ,
                                                        i_err_num  =>  o_errnum                                   ,
                                                        i_err_msg  =>  o_errstr                                   ,
                                                        i_desc     =>  'Input data cannot be NULL'                ,
                                                        i_severity =>  1
														);

                   sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                                 i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                 i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
                                                 i_flow_status          =>   'BD_INITIATED'                  ,
                                                 i_milestone_status     =>   'FAILED'                        ,
                                                 i_errnum               =>    o_errnum||'_BUSINESS'          ,
                                                 i_errstr               =>    o_errstr                       ,
                                                 o_errnum               =>    o_errnum                       ,
                                                 o_errstr               =>    o_errstr
												 );
                  RETURN;
    END IF;
	--
       cstdtl             := cst.retrieve ( i_esn => i_esn );
       o_forecast_date    := cstdtl.warranty_date           ;
       o_esn_status       := cstdtl.esn_part_inst_status    ;
   --  o_service_end_date := cstdtl.expiration_date         ;  --CR46209
       o_zipcode          := cstdtl.zipcode                 ;

    --CR46209 - Changes to consider only the ACTIVE site part records
	  BEGIN
	    SELECT MAX(sp.x_expire_dt)
		INTO   o_service_end_date
		FROM   table_site_part sp
		WHERE  1 = 1
		AND    sp.x_service_id = i_esn
		AND    ( ( sp.part_status = 'Active' AND
				   sp.x_min IN ( SELECT pi_min.part_serial_no
								 FROM   table_part_inst pi_esn,
										table_part_inst pi_min
								 WHERE  1 = 1
								 AND    pi_esn.part_serial_no = sp.x_service_id
								 AND    pi_esn.x_domain       = 'PHONES'
								 AND    pi_esn.objid          = pi_min.part_to_esn2part_inst
								 AND    pi_min.x_domain       = 'LINES'
							   )
				 )
				);
	  EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_errnum  := 1050;
            o_errstr  := 'Error in getting the o_service_end_date';
                        --
                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'            ,
                                                             i_key      => i_esn                                               ,
                                                             i_err_num  => o_errnum                                            ,
                                                             i_err_msg  => o_errstr,
                                                             i_desc     => 'Error while retrieve o_service_end_date' ,
                                                             i_severity => 1
															 );
	  END;
		DBMS_OUTPUT.PUT_LINE('o_service_end_date' ||o_service_end_date);


      --
      BEGIN
       --
           SELECT tbl.*
           INTO   l_rec_prog_enroll_tbl
           FROM   x_program_enrolled tbl
           WHERE objid IN (SELECT  DISTINCT ppd.pgm_purch_dtl2pgm_enrolled
							FROM   x_program_purch_dtl ppd,
								   x_program_purch_hdr pph
							WHERE  pph.objid                      = i_prog_purch_hdr_objid
							AND    ppd.x_esn                      = i_esn
							AND    ppd.pgm_purch_dtl2prog_hdr     = pph.objid
							);
       --
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            o_errnum  := 1039;
            o_errstr  := 'Invalid ESN';
                        --
                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'            ,
                                                             i_key      => i_esn                                               ,
                                                             i_err_num  => o_errnum                                            ,
                                                             i_err_msg  => '-payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100),
                                                             i_desc     => 'Error while retrieve x_program_enrolled record'    ,
                                                             i_severity => 1
															 );
                        --
                        sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                                      i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                      i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
                                                      i_flow_status          =>   'BD_INITIATED'                  ,
                                                      i_milestone_status     =>   'FAILED'                        ,
                                                      i_errnum               =>    o_errnum||'_BUSINESS'          ,
                                                      i_errstr               =>    o_errstr                       ,
                                                      o_errnum               =>    o_errnum                       ,
                                                      o_errstr               =>    o_errstr
													  );
        RETURN;
		--
		WHEN OTHERS THEN
            o_errnum  := 1040;
            o_errstr  := '-payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100);
                        --
                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'         ,
                                                             i_key      => i_esn                                            ,
                                                             i_err_num  => o_errnum                                         ,
                                                             i_err_msg  => o_errstr                                         ,
                                                             i_desc     => 'Error while retrieve x_program_enrolled record' ,
                                                             i_severity => 1
															 );

                        sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                                      i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                      i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
                                                      i_flow_status          =>   'BD_INITIATED'                  ,
                                                      i_milestone_status     =>   'FAILED'                        ,
                                                      i_errnum               =>    o_errnum||'_SYSTEM'            ,
                                                      i_errstr               =>    o_errstr                       ,
                                                      o_errnum               =>    o_errnum                       ,
                                                      o_errstr               =>    o_errstr
													  );
        RETURN;
   END;

   BEGIN
       --
           SELECT tbl.*
           INTO   l_rec_pymnt_staging_tbl
           FROM   rec_pymnt_staging_tbl tbl
           WHERE  x_rec_pymnt_stg2prg_purch_hdr  = i_prog_purch_hdr_objid;
       --
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            o_errnum  := 1008;
            o_errstr  := 'Invalid Purchase hdr objid';
                        --
                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'            ,
                                                             i_key      => i_esn                                               ,
                                                             i_err_num  => o_errnum                                            ,
                                                             i_err_msg  => '-payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100),
                                                             i_desc     => 'Error while retrieve rec_pymnt_staging_tbl record' ,
                                                             i_severity => 1
															 );
        RETURN;
                --
                WHEN OTHERS THEN
            o_errnum  := 1009;
            o_errstr  := '-payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100);
                        --
                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'            ,
                                                             i_key      => i_esn                                               ,
                                                             i_err_num  => o_errnum                                            ,
                                                             i_err_msg  => o_errstr                                            ,
                                                             i_desc     => 'Error while retrieve rec_pymnt_staging_tbl record' ,
                                                             i_severity => 1
															 );
        RETURN;
   END;
   --
   IF ( -- Retry scenario for transaction failed at SOA/spring farm service after successful pre_fulfilment procedure call
        ( NVL(l_rec_pymnt_staging_tbl.x_flow_status,'N') ='BD_INITIATED' AND
          NVL(l_rec_pymnt_staging_tbl.x_milestone_status,'N')='SUCCESS'  AND
          NVL(l_rec_pymnt_staging_tbl.x_rec_pymnt_stg2x_cc_red_inv,0) IS NOT NULL)
        OR
	     --Retry scenario after failure in spring farm benefits delivery call ,spring farm updated flow status to BD_CALL
        (NVL(l_rec_pymnt_staging_tbl.x_flow_status,'N') ='BD_CALL' AND
		 NVL(l_rec_pymnt_staging_tbl.x_milestone_status,'N') IN ('SUCCESS','FAILED')))THEN

	    -- Retrieve the existing soft pin and other ESN attributes and return
	    BEGIN
		--
	      SELECT x_red_code    ,
	             part_serial_no
	      INTO   o_soft_pin    ,
	             o_smp_number
          FROM   table_part_inst
          WHERE  x_red_code  IN (SELECT x_red_card_number
		                         FROM   table_x_cc_red_inv
								 WHERE  objid =l_rec_pymnt_staging_tbl.x_rec_pymnt_stg2x_cc_red_inv
								 )
	      AND    x_part_inst_status = l_card_status;
		--
	    EXCEPTION
			   WHEN OTHERS THEN
			   NULL;
        END;

	   --
       o_errnum           := 0;
       o_errstr           := 'Success';

       RETURN;

   ELSE -- all other scenarios generate pin

            --Get next_id
            next_id ('X_MERCH_REF_ID',
                     o_next_value    ,
                     o_format
                    );

                --To retrieve invoke the sp_reserve_app_card procedure call
                sp_reserve_app_card (o_next_value      ,
                                     1                 ,
                                     'REDEMPTION CARDS',
                                     i_source_system   ,
                                     p_status          ,
                                     p_msg
                                     );

                IF p_msg != 'Completed' THEN
                   o_errnum  := 1010;
                   o_errstr  := '-payment_pre_fulfillment:  '||'sp_reserve_app_card failed';
                   --
                   billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'   ,
                                                        i_key      => i_esn                                      ,
                                                        i_err_num  => o_errnum                                   ,
                                                        i_err_msg  => o_errstr                                   ,
                                                        i_desc     => 'Error while retrieve sp_reserve_app_card' ,
                                                        i_severity => 1
														);

				 --Invoke the update staging table stored procedure
                 sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
                                               i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                               i_milestone            =>   'PRE_BENIFIT_DELIVERY',
                                               i_flow_status          =>   'BD_INITIATED' ,
                                               i_milestone_status     =>   'FAILED',
                                               i_errnum               =>    o_errnum ,
                                               i_errstr               =>    o_errstr ,
                                               o_errnum               =>    o_errnum,
                                               o_errstr               =>    o_errstr
											   );
                    RETURN;
                ELSE
                   BEGIN
                   --
                         SELECT x_red_card_number,
                                x_smp
                         INTO   o_soft_pin,
                                o_smp_number
                         FROM   table_x_cc_red_inv
                         WHERE  x_reserved_id = o_next_value;
                   --
                   EXCEPTION
                         WHEN OTHERS THEN
                              o_errnum  := 1011;
                              o_errstr  := '-payment_pre_fulfillment:  '||SUBSTR(SQLERRM,1,100);
                  --
                                  billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'         ,
                                                                       i_key      => i_esn                                            ,
                                                                       i_err_num  => o_errnum                                         ,
                                                                       i_err_msg  => o_errstr                                         ,
                                                                       i_desc     => 'Error while retrieve table_x_cc_red_inv record' ,
                                                                       i_severity => 1
																	   );
                --Invoke the update staging table stored procedure
                 sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                               i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                               i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
                                               i_flow_status          =>   'BD_INITIATED'                  ,
                                               i_milestone_status     =>   'FAILED'                        ,
                                               i_errnum               =>    o_errnum                       ,
                                               i_errstr               =>    o_errstr                       ,
                                               o_errnum               =>    o_errnum                       ,
                                               o_errstr               =>    o_errstr
											   );
                        RETURN;
                   --
                   END;
                --
                END IF;
    --Retrieve SITE ID from table_x_parameters table
    BEGIN
        SELECT x_param_value
        INTO   l_site_id
        FROM   table_x_parameters
        WHERE  x_param_name      = 'TF_BILL_PF'
        AND    ROWNUM            = 1 ;
    EXCEPTION
             WHEN OTHERS THEN
              o_errnum  := 1012;
              o_errstr  := '-payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100);
              --
                          billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment',
                                                               i_key      => i_esn                                         ,
                                                               i_err_num  => o_errnum                                      ,
                                                               i_err_msg  => o_errstr                                      ,
                                                               i_desc     => 'Error while retrieve table_x_parameters'     ,
                                                               i_severity => 1
                                                               );
                          sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
                                                        i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                        i_milestone            =>   'PRE_BENIFIT_DELIVERY',
                                                        i_flow_status          =>   'BD_INITIATED' ,
                                                        i_milestone_status     =>   'FAILED',
                                                        i_errnum               =>    o_errnum ,
                                                        i_errstr               =>    o_errstr ,
                                                        o_errnum               =>    o_errnum,
                                                        o_errstr               =>    o_errstr
														);
                          RETURN;

          END;

      BEGIN
        --
        SELECT inv.objid
        INTO   l_inv_bin_objid
        FROM   table_inv_bin inv
        WHERE  inv.location_name = l_site_id ;
        --
      EXCEPTION
          WHEN OTHERS THEN
                       o_errnum  := 1013;
                       o_errstr  := '-payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100);
                           --
                           billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'         ,
                                                                i_key      => i_esn                                ,
                                                                i_err_num  => o_errnum                             ,
                                                                i_err_msg  => o_errstr                             ,
                                                                i_desc     => 'Error while retrieve table_inv_bin' ,
                                                                i_severity => 1
																);

                          sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
                                                        i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                        i_milestone            =>   'PRE_BENIFIT_DELIVERY',
                                                        i_flow_status          =>   'BD_INITIATED' ,
                                                        i_milestone_status     =>   'FAILED',
                                                        i_errnum               =>    o_errnum ,
                                                        i_errstr               =>    o_errstr ,
                                                        o_errnum               =>    o_errnum,
                                                        o_errstr               =>    o_errstr
														);
                          RETURN;


      END;

    --Inserting record into table_part_inst table
        BEGIN
                INSERT INTO table_part_inst (objid                ,
                                             last_pi_date         ,
                                             last_cycle_ct        ,
                                             next_cycle_ct        ,
                                             last_mod_time        ,
                                             last_trans_time      ,
                                             date_in_serv         ,
                                             repair_date          ,
                                             warr_end_date        ,
                                             x_cool_end_date      ,
                                             part_status          ,
                                             hdr_ind              ,
                                             x_sequence           ,
                                             x_insert_date        ,
                                             x_creation_date      ,
                                             x_domain             ,
                                             x_deactivation_flag  ,
                                             x_reactivation_flag  ,
                                             x_red_code           ,
                                             part_serial_no       ,
                                             x_part_inst_status   ,
                                             part_inst2inv_bin    ,
                                             created_by2user      ,
                                             status2x_code_table  ,
                                             n_part_inst2part_mod ,
                                             part_to_esn2part_inst
                                            )
							        VALUES (seq ('part_inst') , --objid
											NULL              , --last_pi_date
											NULL              , --last_cycle_ct
											NULL              , --next_cycle_ct
											NULL              , --last_mod_time
											SYSDATE           , --last_trans_time
											NULL              , --date_in_serv
											NULL              , --repair_date
											NULL              , --warr_end_date
											NULL              , --x_cool_end_date
											'Active'          , --part_status
											 0                , --hdr_ind
											 0                , --x_sequence
											 SYSDATE          , --x_insert_date
											 SYSDATE          , --x_creation_date
											 'REDEMPTION CARDS' , --x_domain
											 0                , --x_deactivation_flag
											 0                , --x_reactivation_flag
											 o_soft_pin       , --x_red_code
											 o_smp_number     , --part_serial_no
											 l_card_status    , --x_part_inst_status
											 l_inv_bin_objid  , --part_inst2inv_bin
											 NULL             , --created_by2user
											 ( SELECT objid
											   FROM  table_x_code_table
											   WHERE x_code_number = to_char(l_card_status)
											 )                  ,--status2x_code_table
											 (SELECT m.objid
											  FROM table_part_num pn,
												   table_mod_level m,
												   table_bus_org bo
											  WHERE 1 = 1
											  AND pn.part_number       = i_app_plan_part_num
											  AND m.part_info2part_num = pn.objid
											  AND bo.objid             = pn.part_num2bus_org
											  )                  , --n_part_inst2part_mod
											 cstdtl.esn_part_inst_objid -- Juda
										      );
        --
      EXCEPTION
          WHEN OTHERS THEN
			   o_errnum  := 1014;
			   o_errstr  := '-payment_pre_fulfillment:  '||SUBSTR(SQLERRM,1,100);
				   --
				   billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment',
																							i_key      => i_esn                                   ,
																							i_err_num  => o_errnum                                ,
																							i_err_msg  => o_errstr                                ,
																							i_desc     => 'Error while insert table_part_inst'    ,
																							i_severity => 1
																							);
				  sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
												i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
												i_milestone            =>   'PRE_BENIFIT_DELIVERY',
												i_flow_status          =>   'BD_INITIATED' ,
												i_milestone_status     =>   'FAILED',
												i_errnum               =>    o_errnum ||'_SYSTEM',
												i_errstr               =>    o_errstr ,
												o_errnum               =>    o_errnum,
												o_errstr               =>    o_errstr
												);
                   RETURN;

    END;

        BEGIN

		    --Retrieve OBJID from table_x_cc_red_inv table for soft pin and SMP number
			SELECT inv.objid
			INTO   l_table_x_cc_red_inv_objid
			FROM   table_x_cc_red_inv inv
			WHERE  inv.x_red_card_number = o_soft_pin
			AND    inv.x_smp             = o_smp_number;

        EXCEPTION
          WHEN OTHERS THEN
                       o_errnum  := 1015;
                       o_errstr  := '-payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100);

                            billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_pre_fulfillment'             ,
                                                                 i_key      => i_esn                                                ,
                                                                 i_err_num  => o_errnum                                             ,
                                                                 i_err_msg  => o_errstr                                             ,
                                                                 i_desc     => 'Error while retrieve objid from table_x_cc_red_inv' ,
                                                                 i_severity => 1
																 );

                          sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                                        i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                        i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
                                                        i_flow_status          =>   'BD_INITIATED'                  ,
                                                        i_milestone_status     =>   'FAILED'                        ,
                                                        i_errnum               =>    o_errnum||'_SYSTEM'            ,
                                                        i_errstr               =>    o_errstr                       ,
                                                        o_errnum               =>    o_errnum                       ,
                                                        o_errstr               =>    o_errstr
														);
                         RETURN;
      END;

         --Updating the staging table
        BEGIN
             --
			 UPDATE rec_pymnt_staging_tbl
			 SET    update_timestamp             = SYSDATE,
					x_rqst_date                  = SYSDATE,
					x_rec_pymnt_stg2x_cc_red_inv = l_table_x_cc_red_inv_objid,
					x_flow                       = 'BRM_RECURRING_DELIVER_BENEFITS',
					x_milestone                  = 'PRE_BENIFIT_DELIVERY',
					x_flow_status                = 'BD_INITIATED',
					x_milestone_status           = 'SUCCESS',
				    x_error_code                 = NULL,
				    x_error_msg                  = NULL
		     WHERE  x_rec_pymnt_stg2prg_purch_hdr  = i_prog_purch_hdr_objid;
                --
            EXCEPTION
            WHEN OTHERS THEN
				  o_errnum := 1035;
				  o_errstr := 'payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100);
				  --
				  billing_pkg.insert_program_error_tab(i_source    => 'sa.billing_pkg.payment_pre_fulfillment'     ,
													   i_key       => i_esn                                        ,
													   i_err_num   => o_errnum                                     ,
													   i_err_msg   => o_errstr                                     ,
													   i_desc      => 'Error while process payment_pre_fulfillment',
													   i_severity  => 1
													   );

				 sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
											   i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
											   i_milestone            =>   'PRE_BENIFIT_DELIVERY',
											   i_flow_status          =>   'BD_INITIATED' ,
											   i_milestone_status     =>   'FAILED',
											   i_errnum               =>    o_errnum||'_SYSTEM' ,
											   i_errstr               =>    o_errstr ,
											   o_errnum               =>    o_errnum,
											   o_errstr               =>    o_errstr
											   );

                          RETURN;
                END;
    --
    END IF;

        IF(NVL(o_errnum,0) = 0) THEN
                o_errnum  := 0;
                o_errstr  := 'Success';
        END IF;

EXCEPTION
  WHEN OTHERS THEN
       o_errnum := 1017;
       o_errstr := 'payment_pre_fulfillment:  '||SUBSTR(sqlerrm,1,100);
       --
     billing_pkg.insert_program_error_tab(i_source    => 'sa.billing_pkg.payment_pre_fulfillment',
                                          i_key       => i_esn                                   ,
                                          i_err_num   => o_errnum                                ,
                                          i_err_msg   => o_errstr                                ,
                                          i_desc      => 'Main Exception - Recon',
                                          i_severity  => 1
                                          );
		sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
								      i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
								      i_milestone            =>   'PRE_BENIFIT_DELIVERY'          ,
								      i_flow_status          =>   'BD_INITIATED'                  ,
								      i_milestone_status     =>   'FAILED'                        ,
								      i_errnum               =>    o_errnum||'_SYSTEM'            ,
								      i_errstr               =>    o_errstr                       ,
								      o_errnum               =>    o_errnum                       ,
								      o_errstr               =>    o_errstr
								      );
END payment_pre_fulfillment;
--
PROCEDURE  payment_post_fulfillment(i_esn                  IN   VARCHAR2 ,
                                    i_prog_purch_hdr_objid IN   NUMBER   ,
                                    i_smp_number           IN   VARCHAR2 ,
                                    i_call_trans_objid     IN   NUMBER   ,
                                    i_prog_enrolled_objid  IN   NUMBER   ,
	                                i_fullfillment_type    IN   VARCHAR2 ,
                                    o_prg_gencode_objid    OUT  NUMBER   ,
                                    o_errnum               OUT  NUMBER   ,
                                    o_errstr               OUT  VARCHAR2
									)
AS
--Local variables
l_rec_pymnt_staging_tbl  rec_pymnt_staging_tbl%ROWTYPE;
l_enroll_rec             x_program_enrolled%ROWTYPE;
l_prg_gencode_objid      x_program_gencode.objid%type;
l_ppf_next_cycle_date    DATE;
l_next_cycle_date        DATE;
l_current_cycle_date     DATE;
l_pgm_param_objid        NUMBER;
l_stg_cnt                NUMBER := 0;
l_call_trans_objid       NUMBER := 0;
l_bus_org                VARCHAR2(80);
l_priority               NUMBER;

BEGIN --Main Section

    o_errnum  := 0;
	BEGIN
		 SELECT COUNT(*)
		 INTO
		 l_stg_cnt
		 FROM   rec_pymnt_staging_tbl
		 WHERE  x_rec_pymnt_stg2prg_purch_hdr  = i_prog_purch_hdr_objid
		 AND    x_flow_status                  = 'BD_COMPLETED';
	 EXCEPTION
		WHEN OTHERS THEN
		l_stg_cnt :=0;
	END;

	  --To retrieve the priority value for given program enrolled objid
	  BEGIN
		  SELECT NVL(mtm.x_priority,20)
		  INTO   l_priority
		  FROM   x_program_enrolled     pe,
				 x_program_parameters   pp,
				 mtm_batch_process_type mtm
		  WHERE  pe.objid                    = i_prog_enrolled_objid
		  AND    pe.pgm_enroll2pgm_parameter = pp.objid
		  AND    pp.objid                    = mtm.x_prgm_objid;
      EXCEPTION
         WHEN OTHERS THEN
          	      o_errnum := 1043;
                  o_errstr := 'Invalid Priority';
                  --
                  billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.payment_post_fulfillment',
                                                       i_key      =>  i_esn                                    ,
                                                       i_err_num  =>  o_errnum                                 ,
                                                       i_err_msg  =>  o_errstr                                 ,
                                                       i_desc     =>  'Invalid Priority'                       ,
                                                       i_severity =>  1
													   );
	  END;

        IF i_esn IS NULL THEN
                  o_errnum := 1018;
                  o_errstr := 'ESN cannot be null';
                  --
                  billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.payment_post_fulfillment'   ,
                                                       i_key      =>  i_esn                                       ,
                                                       i_err_num  =>  o_errnum                                    ,
                                                       i_err_msg  =>  o_errstr                                    ,
                                                       i_desc     =>  'Input data cannot be NULL'                 ,
                                                       i_severity =>  1
													   );

                 sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
                                               i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                               i_milestone            =>   'POST_BENIFIT_DELIVERY'         ,
                                               i_flow_status          =>   'BD_COMPLETED'                  ,
                                               i_milestone_status     =>   'FAILED'                        ,
                                               i_errnum               =>    o_errnum||'_BUSINESS'          ,
                                               i_errstr               =>    o_errstr                       ,
                                               o_errnum               =>    o_errnum                       ,
                                               o_errstr               =>    o_errstr
                                               );
                 RETURN;

        ELSIF i_prog_purch_hdr_objid IS NULL THEN
		--
			o_errnum := 1019;
			o_errstr := 'Purchase Header cannot be null';
				--
			billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.payment_post_fulfillment' ,
												 i_key      =>  i_esn                                       ,
												 i_err_num  =>  o_errnum                                    ,
												 i_err_msg  =>  o_errstr                                    ,
												 i_desc     =>  'Input data cannot be NULL'                 ,
												 i_severity =>  1);

		 sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
									   i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
									   i_milestone            =>   'POST_BENIFIT_DELIVERY',
									   i_flow_status          =>   'BD_COMPLETED' ,
									   i_milestone_status     =>   'FAILED',
									   i_errnum               =>    o_errnum||'_BUSINESS',
									   i_errstr               =>    o_errstr ,
									   o_errnum               =>    o_errnum,
									   o_errstr               =>    o_errstr
									   );
		 RETURN;

        ELSIF i_smp_number IS NULL THEN
		--
                    o_errnum := 1020;
                    o_errstr := 'PIN part num cannot be null';
                        --
                    billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.payment_post_fulfillment' ,
                                                         i_key      =>  i_esn                                       ,
                                                         i_err_num  =>  o_errnum                                    ,
                                                         i_err_msg  =>  o_errstr                                    ,
                                                         i_desc     =>  'Input data cannot be NULL'                 ,
                                                         i_severity =>  1
														 );

                 sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
                                               i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                               i_milestone            =>   'POST_BENIFIT_DELIVERY',
                                               i_flow_status          =>   'BD_COMPLETED' ,
                                               i_milestone_status     =>   'FAILED',
                                               i_errnum               =>    o_errnum||'_BUSINESS',
                                               i_errstr               =>    o_errstr ,
                                               o_errnum               =>    o_errnum,
                                               o_errstr               =>    o_errstr
                                               );
                 RETURN;

        ELSIF i_call_trans_objid IS NULL  AND l_stg_cnt =0 THEN

                    o_errnum := 1021;
                    o_errstr := 'ct cannot be null';
                    --
                    billing_pkg.insert_program_error_tab(i_source     =>  'sa.billing_pkg.payment_post_fulfillment' ,
                                                         i_key      =>  i_esn                                       ,
                                                         i_err_num  =>  o_errnum                                    ,
                                                         i_err_msg  =>  o_errstr                                    ,
                                                         i_desc     =>  'Input data cannot be NULL'                 ,
                                                         i_severity =>  1
                                                        );

                    sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid          ,
											      i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
											      i_milestone            =>   'POST_BENIFIT_DELIVERY'         ,
											      i_flow_status          =>   'BD_COMPLETED'                  ,
											      i_milestone_status     =>   'FAILED'                        ,
											      i_errnum               =>    o_errnum||'_BUSINESS'          ,
											      i_errstr               =>    o_errstr                       ,
											      o_errnum               =>    o_errnum                       ,
											      o_errstr               =>    o_errstr
											      );

                  RETURN;
        END IF;

   --To retrieve the record from staging table for the given program purch header objid
   BEGIN
                SELECT tbl.*
                INTO   l_rec_pymnt_staging_tbl
                FROM   rec_pymnt_staging_tbl tbl
                WHERE  x_rec_pymnt_stg2prg_purch_hdr  = i_prog_purch_hdr_objid;
    EXCEPTION
		WHEN NO_DATA_FOUND THEN
				 o_errnum  := 1022;
				 o_errstr  := '-payment_post_fulfillment:  '||SUBSTR(sqlerrm,1,100);
				 --
				billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_post_fulfillment'           ,
													 i_key      => i_esn                                               ,
													 i_err_num  => o_errnum                                            ,
													 i_err_msg  => o_errstr                                            ,
													 i_desc     => 'Error while retrieve rec_pymnt_staging_tbl record' ,
													 i_severity => 1
													 );
				 sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
											   i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
											   i_milestone            =>   'POST_BENIFIT_DELIVERY',
											   i_flow_status          =>   'BD_COMPLETED' ,
											   i_milestone_status     =>   'FAILED',
											   i_errnum               =>    o_errnum||'_SYSTEM',
											   i_errstr               =>    o_errstr ,
											   o_errnum               =>    o_errnum,
											   o_errstr               =>    o_errstr
											   );
				RETURN;
   END;

   --retry scenario failure in service after successful procedure execution
     IF      NVL(l_rec_pymnt_staging_tbl.x_flow_status,'N') = 'BD_COMPLETED'
	     AND NVL(l_rec_pymnt_staging_tbl.X_MILESTONE_STATUS,'N') = 'SUCCESS'
         AND NVL(l_rec_pymnt_staging_tbl.x_rec_pymnt_stg2prg_gencode,0) IS NOT NULL  THEN
        --
		o_prg_gencode_objid := l_rec_pymnt_staging_tbl.x_rec_pymnt_stg2prg_gencode;
		o_errnum  := 0;
		o_errstr  := 'Success';
		--
		RETURN;

    ELSE --all other scenarios

        l_prg_gencode_objid :=  sa.seq_x_program_gencode.NEXTVAL;

        BEGIN
		  --Insert record into x_program gencode table
          IF i_call_trans_objid IS NULL  THEN

		  BEGIN
		   SELECT red_card2call_trans
		   INTO   l_call_trans_objid
		   FROM   table_x_red_card
		   WHERE  x_smp = i_smp_number;

		  EXCEPTION
			 WHEN OTHERS THEN
			   o_errnum := '1041';
			   o_errstr := '-payment_post_fulfillment:  '||SUBSTR(sqlerrm,1,100);

				  billing_pkg.insert_program_error_tab(i_source    => 'sa.billing_pkg.payment_post_fulfillment'  ,
													   i_key       => i_esn                                      ,
													   i_err_num   => o_errnum                                   ,
													   i_err_msg   => o_errstr                                   ,
													   i_desc      => 'SMP is not valid'                         ,
													   i_severity  => 1
													   );

          END;

         END IF;

		 --To retrieve the brand name loc type (example like SM for simple mobile)
		 BEGIN
		 --
			SELECT bo.loc_type
			INTO   l_bus_org
			FROM   x_program_enrolled   pe,
			       x_program_parameters pp,
			       table_bus_org        bo
			WHERE  pe.objid                     = i_prog_enrolled_objid
			AND    pe.pgm_enroll2pgm_parameter  = pp.objid
			AND    pp.prog_param2bus_org        = bo.objid
			AND    bo.brm_applicable_flag       = 'Y';

		 EXCEPTION
			 WHEN OTHERS THEN
				   o_errnum := '1042';
				   o_errstr := '-payment_post_fulfillment:  '||SUBSTR(sqlerrm,1,100);
				   --
				   billing_pkg.insert_program_error_tab(i_source    => 'sa.billing_pkg.payment_post_fulfillment'  ,
														i_key       => i_esn                                      ,
														i_err_num   => o_errnum                                   ,
														i_err_msg   => o_errstr                                   ,
														i_desc      => 'Unable to retrieve Bus Org Loc Type'      ,
														i_severity  => 1
														);
		 END;

          INSERT INTO x_program_gencode

                (objid                 ,
                 x_esn                 ,
                 x_insert_date         ,
                 x_post_date           ,
                 x_status              ,
                 x_error_num           ,
                 x_error_string        ,
                 x_update_stamp        ,
                 gencode2prog_purch_hdr,
                 gencode2call_trans    ,
                 x_ota_trans_id        ,
                 x_sweep_and_add_flag  ,
                 x_priority            ,
                 sw_flag               ,
		         x_smp
                 )
                VALUES
                (l_prg_gencode_objid     ,
                 i_esn                   ,
                 SYSDATE                 ,
                 NULL                    ,
                 l_bus_org||'PROCESSED'  ,
                 NULL                    ,
                 NULL                    ,
                 SYSDATE                 ,
                 i_prog_purch_hdr_objid  ,
                 NVL(i_call_trans_objid ,l_call_trans_objid)     ,
                 NULL                    ,
                 NULL                    ,
                 l_priority              ,
                 NULL                    ,
		         i_smp_number
                );

        EXCEPTION
                WHEN OTHERS THEN
                          o_errnum := 1036;
                          o_errstr := '-payment_post_fulfillment:  '||SUBSTR(SQLERRM,1,100);
                      --
                        sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
                                                      i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                      i_milestone            =>   'POST_BENIFIT_DELIVERY',
                                                      i_flow_status          =>   'BD_COMPLETED' ,
                                                      i_milestone_status     =>   'FAILED',
                                                      i_errnum               =>    o_errnum||'_SYSTEM',
                                                      i_errstr               =>    o_errstr ,
                                                      o_errnum               =>    o_errnum,
                                                      o_errstr               =>    o_errstr
													  );
                          --
                          billing_pkg.insert_program_error_tab(i_source    => 'sa.billing_pkg.payment_post_fulfillment'  ,
                                                               i_key       => i_esn                                      ,
                                                               i_err_num   => o_errnum                                   ,
                                                               i_err_msg   => o_errstr                                   ,
                                                               i_desc      => 'Error while insert into x_program_gencode',
                                                               i_severity  => 1
                                                               );
                           RETURN;

    END;

	BEGIN
		 SELECT x_next_charge_date      ,
				pgm_enroll2pgm_parameter
		 INTO   l_current_cycle_date    ,
				l_pgm_param_objid
		 FROM   x_program_enrolled
		 WHERE  objid =i_prog_enrolled_objid;

	EXCEPTION
	        WHEN OTHERS THEN
			l_current_cycle_date:= null;
			l_pgm_param_objid :=null;
	END ;

	--Updating NEXT CHARGE DATE based on fulfillment type and next cycle date
	IF (i_fullfillment_type ='REFILL_NOW' AND l_current_cycle_date IS NOT NULL) THEN

        l_next_cycle_date := get_next_cycle_date(i_prog_param_objid   => l_pgm_param_objid,
                                                 i_current_cycle_date => l_current_cycle_date
												 );

			IF l_next_cycle_date > 	l_current_cycle_date THEN
			--
				UPDATE 	x_program_enrolled
				SET 	x_next_charge_date = l_next_cycle_date,
						x_update_stamp     = SYSDATE
				WHERE 	objid              = i_prog_enrolled_objid;
		    END IF;
	--
	END IF;

        BEGIN
               UPDATE rec_pymnt_staging_tbl
               SET    update_timestamp               = SYSDATE                        ,
				      x_rqst_date                    = SYSDATE                        ,
				      x_rec_pymnt_stg2prg_gencode    = l_prg_gencode_objid            ,
				      x_flow                         = 'BRM_RECURRING_DELIVER_BENEFITS',
				      x_milestone                    = 'POST_BENIFIT_DELIVERY'        ,
				      x_flow_status                  = 'BD_COMPLETED'                 ,
				      x_milestone_status             = 'SUCCESS'                      ,
			          x_error_code                   = NULL                           ,
		              x_error_msg                    = NULL
            WHERE     x_rec_pymnt_stg2prg_purch_hdr  = i_prog_purch_hdr_objid;
        --
        EXCEPTION
                WHEN OTHERS THEN
                          o_errnum := 1037;
                          o_errstr := '-payment_post_fulfillment:  '||SUBSTR(SQLERRM,1,100);
                      --
                        sp_update_payment_staging_tbl(i_prog_purch_hdr_objid =>   i_prog_purch_hdr_objid,
                                                      i_flow                 =>   'BRM_RECURRING_DELIVER_BENEFITS',
                                                      i_milestone            =>   'POST_BENIFIT_DELIVERY',
                                                      i_flow_status          =>   'BD_COMPLETED' ,
                                                      i_milestone_status     =>   'FAILED',
                                                      i_errnum               =>    o_errnum||'_SYSTEM' ,
                                                      i_errstr               =>    o_errstr ,
                                                      o_errnum               =>    o_errnum,
                                                      o_errstr               =>    o_errstr
													  );
                          --
                          billing_pkg.insert_program_error_tab(i_source    => 'sa.billing_pkg.payment_post_fulfillment'  ,
                                                               i_key       => i_esn                                      ,
                                                               i_err_num   => o_errnum                                   ,
                                                               i_err_msg   => o_errstr                                   ,
                                                               i_desc      => 'Error while update rec_pymnt_staging_tbl' ,
                                                               i_severity  => 1
                                                               );
                            RETURN;
        END;
        --
        o_prg_gencode_objid := l_prg_gencode_objid;
  --
  END IF;
               --CR45279 changes - Start
				BEGIN
					SELECT r.*
					INTO   l_enroll_rec
					FROM   x_program_enrolled r
					WHERE  objid = i_prog_enrolled_objid;
				EXCEPTION
				   WHEN OTHERS THEN
				        o_errnum := 1048;
                        o_errstr := '-payment_post_fulfillment:  '||SUBSTR(sqlerrm,1,100);
                        billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_post_fulfillment'      ,
														     i_key      => i_prog_enrolled_objid                          ,
														     i_err_num  => o_errnum                                       ,
														     i_err_msg  => o_errstr                                       ,
														     i_desc     => 'Error while retrieve from x_program_enrolled' ,
														     i_severity => 1
														    );
				END;

				IF o_errnum = 0 THEN

				 -- Call procedure to insert record into x_program_trans table
                 insert_program_trans(i_enrollment_status      => l_enroll_rec.x_enrollment_status         ,
									  i_enroll_status_reason   => 'Recurring payment received successfully',
									  i_float_given            => NULL                                     ,
									  i_cooling_given          => NULL                                     ,
									  i_grace_period_given     => NULL                                     ,
									  i_trans_date             => SYSDATE                                  ,
									  i_action_text            => 'Payment Receipt'                        ,
									  i_action_type            => 'RECURRING_PAYMENT'                      ,
									  i_reason                 => NULL                                     ,
									  i_sourcesystem           => l_enroll_rec.x_sourcesystem              ,
									  i_esn                    => l_enroll_rec.x_esn                       ,
									  i_exp_date               => l_enroll_rec.x_exp_date                  ,
									  i_cooling_exp_date       => l_enroll_rec.x_cooling_exp_date          ,
									  i_update_status          => 'I'                                      ,
									  i_update_user            => 'BRM'                                    ,
									  i_pgm_tran2pgm_enrolled  => l_enroll_rec.objid                       ,
									  i_pgm_trans2web_user     => l_enroll_rec.pgm_enroll2web_user         ,
									  i_pgm_trans2site_part    => l_enroll_rec.pgm_enroll2site_part        ,
									  o_errnum                 => o_errnum                                 ,
									  o_errstr                 => o_errstr
									  );

					    -- Call procedure to insert record into x_billing_log table
						insert_billing_log(i_log_category         => 'Payment'                                ,
										   i_log_title            => 'RECURRING_PAYMENT'                      ,
										   i_log_date             => SYSDATE                                  ,
										   i_details              => 'Recurring payment received successfully',
										   i_additional_details   => NULL                                     ,
										   i_program_name         => NULL                                     ,
										   i_nickname             => NULL                                     ,
										   i_esn                  => l_enroll_rec.x_esn                       ,
										   i_originator           => NULL                                     ,
										   i_contact_first_name   => NULL                                     ,
										   i_contact_last_name    => NULL                                     ,
										   i_agent_name           => 'BRM'                                    ,
										   i_sourcesystem         => l_enroll_rec.x_sourcesystem              ,
										   i_billing_log2web_user => l_enroll_rec.pgm_enroll2web_user         ,
										   o_errnum               => o_errnum                                 ,
										   o_errstr               => o_errstr
										   );
				END IF;
				--CR45279 changes - End
--
      o_errnum  := 0;
      o_errstr  := 'Success';

EXCEPTION
        WHEN OTHERS THEN
          o_errnum := 1024;
          o_errstr := '-payment_post_fulfillment:  '||SUBSTR(sqlerrm,1,100);
          --
          billing_pkg.insert_program_error_tab(i_source   => 'sa.billing_pkg.payment_post_fulfillment'  ,
                                                i_key      => i_esn                                     ,
                                                i_err_num  => o_errnum                                  ,
                                                i_err_msg  => o_errstr                                  ,
                                                i_desc     => 'Main Exception - post fulfillment'       ,
                                                i_severity => 1
												);
END payment_post_fulfillment;
--
PROCEDURE sp_update_payment_staging_tbl(i_prog_purch_hdr_objid   IN  NUMBER   ,
                                        i_flow                   IN  VARCHAR2 ,
                                        i_milestone              IN  VARCHAR2 ,
                                        i_flow_status            IN  VARCHAR2 ,
                                        i_milestone_status       IN  VARCHAR2 ,
                                        i_errnum                 IN  VARCHAR2 ,
                                        i_errstr                 IN  VARCHAR2 ,
                                        o_errnum                 OUT NUMBER   ,
                                        o_errstr                 OUT VARCHAR2
                                        )
AS
	BEGIN --Main section

          UPDATE rec_pymnt_staging_tbl
          SET    x_flow                    = i_flow            ,
		         x_flow_status             = i_flow_status     ,
                 update_timestamp          = SYSDATE           ,
                 x_rqst_date               = SYSDATE           ,
		         x_milestone               = i_milestone       ,
                 x_milestone_status        = i_milestone_status,
		         x_error_code              = i_errnum          ,
	 	         x_error_msg               = i_errstr
          WHERE  x_rec_pymnt_stg2prg_purch_hdr  = i_prog_purch_hdr_objid;

	EXCEPTION
	WHEN OTHERS THEN
		o_errnum  := 1038;
		o_errstr  := 'sp_update_payment_staging_tbl:  '||SUBSTR(SQLERRM,1,100);
					--
		billing_pkg.insert_program_error_tab(i_source   =>  'sa.billing_pkg.get_payment_type'         ,
											 i_key      =>  i_prog_purch_hdr_objid                    ,
											 i_err_num  =>  o_errnum                                  ,
											 i_err_msg  =>  o_errstr                                  ,
											 i_desc     =>  'Error while update rec_pymnt_staging_tbl',
											 i_severity =>  2
											 );
END sp_update_payment_staging_tbl;
--
END billing_pkg;
/