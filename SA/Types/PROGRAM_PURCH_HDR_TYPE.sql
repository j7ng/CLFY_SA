CREATE OR REPLACE TYPE sa.program_purch_hdr_type AS OBJECT
-----------------------------------------------------------------------
--$RCSfile: program_purch_hdr_type_spec.sql,v $
--$Revision: 1.2 $
--$Author: sinturi $
--$Date: 2017/12/06 18:41:58 $
--$ $Log: program_purch_hdr_type_spec.sql,v $
--$ Revision 1.2  2017/12/06 18:41:58  sinturi
--$ Modified grant script
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
--$
-------------------------------------------------------------------------
(
  program_purch_hdr_objid NUMBER,
  rqst_source             VARCHAR2(20),
  rqst_type               VARCHAR2(20),
  rqst_date               DATE,
  ics_applications        VARCHAR2(50),
  merchant_id             VARCHAR2(30),
  merchant_ref_NUMBER     VARCHAR2(30),
  offer_num               VARCHAR2(10),
  quantity                NUMBER,
  merchant_product_sku    VARCHAR2(30),
  payment_line2program    NUMBER,
  product_code            VARCHAR2(30),
  ignore_avs              VARCHAR2(10),
  user_po                 VARCHAR2(30),
  avs                     VARCHAR2(30),
  disable_avs             VARCHAR2(30),
  customer_hostname       VARCHAR2(60),
  customer_ipaddress      VARCHAR2(30),
  auth_request_id         VARCHAR2(30),
  auth_code               VARCHAR2(30),
  auth_type               VARCHAR2(30),
  ics_rcode               VARCHAR2(10),
  ics_rflag               VARCHAR2(30),
  ics_rmsg                VARCHAR2(255),
  request_id              VARCHAR2(30),
  auth_avs                VARCHAR2(30),
  auth_response           VARCHAR2(60),
  auth_time               VARCHAR2(20),
  auth_rcode              NUMBER,
  auth_rflag              VARCHAR2(30),
  auth_rmsg               VARCHAR2(255),
  bill_request_time       VARCHAR2(20),
  bill_rcode              NUMBER,
  bill_rflag              VARCHAR2(30),
  bill_rmsg               VARCHAR2(60),
  bill_trans_ref_no       VARCHAR2(30),
  customer_firstname      VARCHAR2(20),
  customer_lastname       VARCHAR2(20),
  customer_phone          VARCHAR2(20),
  customer_email          VARCHAR2(50),
  status                  VARCHAR2(20),
  bill_address1           VARCHAR2(200),
  bill_address2           VARCHAR2(200),
  bill_city               VARCHAR2(30),
  bill_state              VARCHAR2(60),
  bill_zip                VARCHAR2(60),
  bill_country            VARCHAR2(20),
  esn                     VARCHAR2(20),
  amount                  NUMBER,
  tax_amount              NUMBER,
  auth_amount             NUMBER,
  bill_amount             NUMBER,
  userid                  VARCHAR2(20),
  credit_code             VARCHAR2(10),
  purch_hdr2creditcard    NUMBER,
  purch_hdr2bank_acct     NUMBER,
  purch_hdr2user          NUMBER,
  purch_hdr2esn           NUMBER,
  purch_hdr2rmsg_codes    NUMBER,
  purch_hdr2cr_purch      NUMBER,
  prog_hdr2pymt_src       NUMBER,
  prog_hdr2web_user       NUMBER,
  prog_hdr2prog_batch     NUMBER,
  payment_type            VARCHAR2(30),
  e911_taamount           NUMBER,
  usf_taxamount           NUMBER,
  rcrf_tax_amount         NUMBER,
  process_date            DATE,
  discount_amount         NUMBER,
  priority                NUMBER,
  response                VARCHAR2(1000),
  numeric_value           NUMBER ,
  varchar2_value          VARCHAR2(1000),
  CONSTRUCTOR FUNCTION program_purch_hdr_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION program_purch_hdr_type ( i_program_purch_hdr_objid IN NUMBER) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_esn IN VARCHAR2, o_program_purch_hdr_objid OUT NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_program_purch_hdr_type IN program_purch_hdr_type) RETURN program_purch_hdr_type,
  MEMBER FUNCTION ins RETURN program_purch_hdr_type,
  MEMBER FUNCTION upd ( i_program_purch_hdr_type IN program_purch_hdr_type) RETURN program_purch_hdr_type
);
/
CREATE OR REPLACE TYPE BODY sa.program_purch_hdr_type AS
-----------------------------------------------------------------------
--$RCSfile: program_purch_hdr_type.sql,v $
--$Revision: 1.3 $
--$Author: sinturi $
--$Date: 2017/12/06 18:42:35 $
--$ $Log: program_purch_hdr_type.sql,v $
--$ Revision 1.3  2017/12/06 18:42:35  sinturi
--$ Modified grant names
--$
--$ Revision 1.2  2017/12/06 17:45:48  sinturi
--$ Modified seq name
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
--$
-------------------------------------------------------------------------

  CONSTRUCTOR FUNCTION program_purch_hdr_type RETURN SELF AS RESULT AS
  BEGIN
    -- TODO: Implementation required for FUNCTION program_purch_hdr_type.program_purch_hdr_type
    RETURN;
  END program_purch_hdr_type;

  CONSTRUCTOR FUNCTION program_purch_hdr_type ( i_program_purch_hdr_objid IN NUMBER) RETURN SELF AS RESULT AS
  BEGIN

		IF i_program_purch_hdr_objid is NOT NULL THEN
		SELF.response := 'PROGRAM PURCH HDR ID NOT PASSED';
		END IF;

		--Query the table
		select program_purch_hdr_type ( objid                      ,
                                    x_rqst_source              ,
                                    x_rqst_type                ,
                                    x_rqst_date                ,
                                    x_ics_applications         ,
                                    x_merchant_id              ,
                                    x_merchant_ref_number      ,
                                    x_offer_num                ,
                                    x_quantity                 ,
                                    x_merchant_product_sku     ,
                                    x_payment_line2program     ,
                                    x_product_code             ,
                                    x_ignore_avs               ,
                                    x_user_po                  ,
                                    x_avs                      ,
                                    x_disable_avs              ,
                                    x_customer_hostname        ,
                                    x_customer_ipaddress       ,
                                    x_auth_request_id          ,
                                    x_auth_code                ,
                                    x_auth_type                ,
                                    x_ics_rcode                ,
                                    x_ics_rflag                ,
                                    x_ics_rmsg                 ,
                                    x_request_id               ,
                                    x_auth_avs                 ,
                                    x_auth_response            ,
                                    x_auth_time                ,
                                    x_auth_rcode               ,
                                    x_auth_rflag               ,
                                    x_auth_rmsg                ,
                                    x_bill_request_time        ,
                                    x_bill_rcode               ,
                                    x_bill_rflag               ,
                                    x_bill_rmsg                ,
                                    x_bill_trans_ref_no        ,
                                    x_customer_firstname       ,
                                    x_customer_lastname        ,
                                    x_customer_phone           ,
                                    x_customer_email           ,
                                    x_status                   ,
                                    x_bill_address1            ,
                                    x_bill_address2            ,
                                    x_bill_city                ,
                                    x_bill_state               ,
                                    x_bill_zip                 ,
                                    x_bill_country             ,
                                    x_esn                      ,
                                    x_amount                   ,
                                    x_tax_amount               ,
                                    x_auth_amount              ,
                                    x_bill_amount              ,
                                    x_user                     ,
                                    x_credit_code              ,
                                    purch_hdr2creditcard       ,
                                    purch_hdr2bank_acct        ,
                                    purch_hdr2user             ,
                                    purch_hdr2esn              ,
                                    purch_hdr2rmsg_codes       ,
                                    purch_hdr2cr_purch         ,
                                    prog_hdr2x_pymt_src        ,
                                    prog_hdr2web_user          ,
                                    prog_hdr2prog_batch        ,
                                    x_payment_type             ,
                                    x_e911_tax_amount          ,
                                    x_usf_taxamount            ,
                                    x_rcrf_tax_amount          ,
                                    x_process_date             ,
                                    x_discount_amount          ,
                                    x_priority                 ,
                                    null					             ,
                                    null					             ,
                                    null
                                    )
		INTO SELF
		FROM X_PROGRAM_PURCH_HDR
		WHERE objid= i_program_purch_hdr_objid;
		--G5

		SELF.response := 'SUCCESS';

		RETURN;

	EXCEPTION
	WHEN OTHERS THEN
	SELF.response := 'PROGRAM PURCH HDR ID NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
	SELF.program_purch_hdr_objid := i_program_purch_hdr_objid;
--


    RETURN;
  END program_purch_hdr_type;

  MEMBER FUNCTION exist RETURN BOOLEAN AS
  BEGIN
    -- TODO: Implementation required for FUNCTION program_purch_hdr_type.exist
    RETURN NULL;
  END exist;

 MEMBER FUNCTION exist ( i_esn IN VARCHAR2, o_program_purch_hdr_objid OUT NUMBER) RETURN BOOLEAN AS
 BEGIN

		IF i_esn is  NULL THEN
		 RETURN FALSE;
		END IF;

		--Query the table

    SELECT objid INTO o_program_purch_hdr_objid
    FROM X_PROGRAM_PURCH_HDR
    WHERE objid IN
      (SELECT PGM_PURCH_DTL2PROG_HDR
      FROM X_PROGRAM_PURCH_DTL
      WHERE x_esn= i_esn
      );

		RETURN TRUE;

	EXCEPTION
	WHEN OTHERS THEN
    o_program_purch_hdr_objid := NULL;
    RETURN FALSE;
 END;

  MEMBER FUNCTION ins RETURN program_purch_hdr_type AS
  ppht   program_purch_hdr_type := SELF;
  i    program_purch_hdr_type;
BEGIN
  i := ppht.ins ( i_program_purch_hdr_type => ppht );
  RETURN i;

END ins;


  MEMBER FUNCTION ins ( i_program_purch_hdr_type IN program_purch_hdr_type ) RETURN program_purch_hdr_type AS
    ppht  program_purch_hdr_type := i_program_purch_hdr_type;
BEGIN

  IF ppht.program_purch_hdr_objid IS NULL THEN
    ppht.program_purch_hdr_objid  := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
  END IF;

  --Assign Time stamp attributes
  IF  ppht.rqst_date  IS NULL THEN
   ppht.rqst_date  := SYSDATE;
  END IF;

  IF ppht.process_date IS NULL THEN
   ppht.process_date  := SYSDATE;
  END IF;

								  INSERT
								  INTO X_PROGRAM_PURCH_HDR
								  (
                  objid                     ,
									x_rqst_source              ,
									x_rqst_type                ,
									x_rqst_date                ,
									x_ics_applications         ,
									x_merchant_id              ,
									x_merchant_ref_number      ,
									x_offer_num                ,
									x_quantity                 ,
									x_merchant_product_sku     ,
									x_payment_line2program     ,
									x_product_code             ,
									x_ignore_avs               ,
									x_user_po                  ,
									x_avs                      ,
									x_disable_avs              ,
									x_customer_hostname        ,
									x_customer_ipaddress       ,
									x_auth_request_id          ,
									x_auth_code                ,
									x_auth_type                ,
									x_ics_rcode                ,
									x_ics_rflag                ,
									x_ics_rmsg                 ,
									x_request_id               ,
									x_auth_avs                 ,
									x_auth_response            ,
									x_auth_time                ,
									x_auth_rcode               ,
									x_auth_rflag               ,
									x_auth_rmsg                ,
									x_bill_request_time        ,
									x_bill_rcode               ,
									x_bill_rflag               ,
									x_bill_rmsg                ,
									x_bill_trans_ref_no        ,
									x_customer_firstname       ,
									x_customer_lastname        ,
									x_customer_phone           ,
									x_customer_email           ,
									x_status                   ,
									x_bill_address1            ,
									x_bill_address2            ,
									x_bill_city                ,
									x_bill_state               ,
									x_bill_zip                 ,
									x_bill_country             ,
									x_esn                      ,
									x_amount                   ,
									x_tax_amount               ,
									x_auth_amount              ,
									x_bill_amount              ,
									x_user                     ,
									x_credit_code              ,
									purch_hdr2creditcard       ,
									purch_hdr2bank_acct        ,
									purch_hdr2user             ,
									purch_hdr2esn              ,
									purch_hdr2rmsg_codes       ,
									purch_hdr2cr_purch         ,
									prog_hdr2x_pymt_src        ,
									prog_hdr2web_user          ,
									prog_hdr2prog_batch        ,
									x_payment_type             ,
									x_e911_tax_amount          ,
									x_usf_taxamount            ,
									x_rcrf_tax_amount          ,
									x_process_date             ,
									x_discount_amount          ,
									x_priority
									 )
									VALUES
									(
									ppht.program_purch_hdr_objid,
									ppht.rqst_source            ,
									ppht.rqst_type              ,
									ppht.rqst_date              ,
									ppht.ics_applications       ,
									ppht.merchant_id            ,
									ppht.merchant_ref_NUMBER    ,
									ppht.offer_num              ,
									ppht.quantity               ,
									ppht.merchant_product_sku   ,
									ppht.payment_line2program   ,
									ppht.product_code           ,
									ppht.ignore_avs             ,
									ppht.user_po                ,
									ppht.avs                    ,
									ppht.disable_avs            ,
									ppht.customer_hostname      ,
									ppht.customer_ipaddress     ,
									ppht.auth_request_id        ,
									ppht.auth_code              ,
									ppht.auth_type              ,
									ppht.ics_rcode              ,
									ppht.ics_rflag              ,
									ppht.ics_rmsg               ,
									ppht.request_id             ,
									ppht.auth_avs               ,
									ppht.auth_response          ,
									ppht.auth_time              ,
									ppht.auth_rcode             ,
									ppht.auth_rflag             ,
									ppht.auth_rmsg              ,
									ppht.bill_request_time      ,
									ppht.bill_rcode             ,
									ppht.bill_rflag             ,
									ppht.bill_rmsg              ,
									ppht.bill_trans_ref_no      ,
									ppht.customer_firstname     ,
									ppht.customer_lastname      ,
									ppht.customer_phone         ,
									ppht.customer_email         ,
									ppht.status                 ,
									ppht.bill_address1          ,
									ppht.bill_address2          ,
									ppht.bill_city              ,
									ppht.bill_state             ,
									ppht.bill_zip               ,
									ppht.bill_country           ,
									ppht.esn                    ,
									ppht.amount                 ,
									ppht.tax_amount               ,
									ppht.auth_amount            ,
									ppht.bill_amount            ,
									ppht.userid                 ,
									ppht.credit_code            ,
									ppht.purch_hdr2creditcard   ,
									ppht.purch_hdr2bank_acct    ,
									ppht.purch_hdr2user         ,
									ppht.purch_hdr2esn          ,
									ppht.purch_hdr2rmsg_codes   ,
									ppht.purch_hdr2cr_purch     ,
									ppht.prog_hdr2pymt_src      ,
									ppht.prog_hdr2web_user      ,
									ppht.prog_hdr2prog_batch    ,
									ppht.payment_type           ,
									ppht.e911_taamount          ,
									ppht.usf_taxamount          ,
									ppht.rcrf_tax_amount        ,
									ppht.process_date           ,
									ppht.discount_amount        ,
									ppht.priority
									);

  -- set Success Response
   ppht.response  := CASE WHEN ppht.response IS NULL THEN 'SUCCESS' ELSE ppht.response || '|SUCCESS' END;
 RETURN ppht;
EXCEPTION
WHEN OTHERS THEN
  ppht.response := ppht.response || '|ERROR INSERTING X_PROGRAM_PURCH_HDR RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN ppht;
END ins;



MEMBER FUNCTION upd ( i_program_purch_hdr_type IN program_purch_hdr_type ) RETURN program_purch_hdr_type AS
    ppht  program_purch_hdr_type := i_program_purch_hdr_type;
BEGIN

  --Assign Time stamp attributes
  IF  ppht.rqst_date  IS NULL THEN
   ppht.rqst_date  := SYSDATE;
  END IF;

  IF ppht.process_date IS NULL THEN
   ppht.process_date  := SYSDATE;
  END IF;

  UPDATE X_PROGRAM_PURCH_HDR
  SET
  x_rqst_source              = NVL(ppht.rqst_source            ,x_rqst_source              ),
  x_rqst_type                = NVL(ppht.rqst_type              ,x_rqst_type                ),
  x_rqst_date                = NVL(ppht.rqst_date              ,x_rqst_date                ),
  x_ics_applications         = NVL(ppht.ics_applications       ,x_ics_applications         ),
  x_merchant_id              = NVL(ppht.merchant_id            ,x_merchant_id              ),
  x_merchant_ref_number      = NVL(ppht.merchant_ref_NUMBER    ,x_merchant_ref_number      ),
  x_offer_num                = NVL(ppht.offer_num              ,x_offer_num                ),
  x_quantity                 = NVL(ppht.quantity               ,x_quantity                 ),
  x_merchant_product_sku     = NVL(ppht.merchant_product_sku   ,x_merchant_product_sku     ),
  x_payment_line2program     = NVL(ppht.payment_line2program   ,x_payment_line2program     ),
  x_product_code             = NVL(ppht.product_code           ,x_product_code             ),
  x_ignore_avs               = NVL(ppht.ignore_avs             ,x_ignore_avs               ),
  x_user_po                  = NVL(ppht.user_po                ,x_user_po                  ),
  x_avs                      = NVL(ppht.avs                    ,x_avs                      ),
  x_disable_avs              = NVL(ppht.disable_avs            ,x_disable_avs              ),
  x_customer_hostname        = NVL(ppht.customer_hostname      ,x_customer_hostname        ),
  x_customer_ipaddress       = NVL(ppht.customer_ipaddress     ,x_customer_ipaddress       ),
  x_auth_request_id          = NVL(ppht.auth_request_id        ,x_auth_request_id          ),
  x_auth_code                = NVL(ppht.auth_code              ,x_auth_code                ),
  x_auth_type                = NVL(ppht.auth_type              ,x_auth_type                ),
  x_ics_rcode                = NVL(ppht.ics_rcode              ,x_ics_rcode                ),
  x_ics_rflag                = NVL(ppht.ics_rflag              ,x_ics_rflag                ),
  x_ics_rmsg                 = NVL(ppht.ics_rmsg               ,x_ics_rmsg                 ),
  x_request_id               = NVL(ppht.request_id             ,x_request_id               ),
  x_auth_avs                 = NVL(ppht.auth_avs               ,x_auth_avs                 ),
  x_auth_response            = NVL(ppht.auth_response          ,x_auth_response            ),
  x_auth_time                = NVL(ppht.auth_time              ,x_auth_time                ),
  x_auth_rcode               = NVL(ppht.auth_rcode             ,x_auth_rcode               ),
  x_auth_rflag               = NVL(ppht.auth_rflag             ,x_auth_rflag               ),
  x_auth_rmsg                = NVL(ppht.auth_rmsg              ,x_auth_rmsg                ),
  x_bill_request_time        = NVL(ppht.bill_request_time      ,x_bill_request_time        ),
  x_bill_rcode               = NVL(ppht.bill_rcode             ,x_bill_rcode               ),
  x_bill_rflag               = NVL(ppht.bill_rflag             ,x_bill_rflag               ),
  x_bill_rmsg                = NVL(ppht.bill_rmsg              ,x_bill_rmsg                ),
  x_bill_trans_ref_no        = NVL(ppht.bill_trans_ref_no      ,x_bill_trans_ref_no        ),
  x_customer_firstname       = NVL(ppht.customer_firstname     ,x_customer_firstname       ),
  x_customer_lastname        = NVL(ppht.customer_lastname      ,x_customer_lastname        ),
  x_customer_phone           = NVL(ppht.customer_phone         ,x_customer_phone           ),
  x_customer_email           = NVL(ppht.customer_email         ,x_customer_email           ),
  x_status                   = NVL(ppht.status                 ,x_status                   ),
  x_bill_address1            = NVL(ppht.bill_address1          ,x_bill_address1            ),
  x_bill_address2            = NVL(ppht.bill_address2          ,x_bill_address2            ),
  x_bill_city                = NVL(ppht.bill_city              ,x_bill_city                ),
  x_bill_state               = NVL(ppht.bill_state             ,x_bill_state               ),
  x_bill_zip                 = NVL(ppht.bill_zip               ,x_bill_zip                 ),
  x_bill_country             = NVL(ppht.bill_country           ,x_bill_country             ),
  x_esn                      = NVL(ppht.esn                    ,x_esn                      ),
  x_amount                   = NVL(ppht.amount                 ,x_amount                   ),
  x_tax_amount               = NVL(ppht.tax_amount             ,x_tax_amount               ),
  x_auth_amount              = NVL(ppht.auth_amount            ,x_auth_amount              ),
  x_bill_amount              = NVL(ppht.bill_amount            ,x_bill_amount              ),
  x_user                     = NVL(ppht.userid                 ,x_user                     ),
  x_credit_code              = NVL(ppht.credit_code            ,x_credit_code              ),
  purch_hdr2creditcard       = NVL(ppht.purch_hdr2creditcard   ,purch_hdr2creditcard       ),
  purch_hdr2bank_acct        = NVL(ppht.purch_hdr2bank_acct    ,purch_hdr2bank_acct        ),
  purch_hdr2user             = NVL(ppht.purch_hdr2user         ,purch_hdr2user             ),
  purch_hdr2esn              = NVL(ppht.purch_hdr2esn          ,purch_hdr2esn              ),
  purch_hdr2rmsg_codes       = NVL(ppht.purch_hdr2rmsg_codes   ,purch_hdr2rmsg_codes       ),
  purch_hdr2cr_purch         = NVL(ppht.purch_hdr2cr_purch     ,purch_hdr2cr_purch         ),
  prog_hdr2x_pymt_src        = NVL(ppht.prog_hdr2pymt_src      ,prog_hdr2x_pymt_src        ),
  prog_hdr2web_user          = NVL(ppht.prog_hdr2web_user      ,prog_hdr2web_user          ),
  prog_hdr2prog_batch        = NVL(ppht.prog_hdr2prog_batch    ,prog_hdr2prog_batch        ),
  x_payment_type             = NVL(ppht.payment_type           ,x_payment_type             ),
  x_e911_tax_amount          = NVL(ppht.e911_taamount          ,x_e911_tax_amount          ),
  x_usf_taxamount            = NVL(ppht.usf_taxamount          ,x_usf_taxamount            ),
  x_rcrf_tax_amount          = NVL(ppht.rcrf_tax_amount        ,x_rcrf_tax_amount          ),
  x_process_date             = NVL(ppht.process_date           ,x_process_date             ),
  x_discount_amount          = NVL(ppht.discount_amount        ,x_discount_amount          ),
  x_priority                 = NVL(ppht.priority               , x_priority                )
  WHERE objid = ppht.program_purch_hdr_objid;
  -- set Success Response
  ppht := program_purch_hdr_type ( i_program_purch_hdr_objid => ppht.program_purch_hdr_objid);
  ppht.response  := 'SUCCESS';
 RETURN ppht;
EXCEPTION
WHEN OTHERS THEN
  ppht.response := ppht.response || '|ERROR UPDATING X_PROGRAM_PURCH_HDR RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN ppht;
END upd;


END;
/