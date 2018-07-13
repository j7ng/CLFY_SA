CREATE OR REPLACE PACKAGE sa.BILLING_BUNDLE_PKG
IS
	PROCEDURE SP_GET_WEBACCT_INFO(
		IP_ESN              							IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
		, IP_ELIG_PROG1_ARRAY         					IN  sa.TYP_VARCHAR2_ARRAY
		, IP_ELIG_PROG2_ARRAY         					IN  sa.TYP_VARCHAR2_ARRAY
		, OP_PROG1_ESN_INFO_TAB       					OUT sa.TYP_ESN_INFO_TABLE
		, OP_PROG2_ESN_INFO_TAB       					OUT sa.TYP_ESN_INFO_TABLE
		, OP_BUNDLE_PROMO_ELIGIBLE    					OUT NUMBER
		, OP_ERROR_CODE             					OUT NUMBER
		, OP_ERROR_MSG              					OUT VARCHAR2);

	FUNCTION FN_CHECK_ST_BUNDLE_FAMILY(
		IP_ESN                        					IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
		, IP_PROMO_OBJID              					IN  sa.TABLE_X_PROMOTION.OBJID%TYPE)
		RETURN NUMBER;

	PROCEDURE SP_REGISTER_BUNDLE_PROMO(
		IP_ESN              							IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
		, IP_PROMO_OBJID    							IN  sa.TABLE_X_PROMOTION.OBJID%TYPE
		, IP_PROGRAM_ENROLLED_OBJID	  					IN  sa.X_PROGRAM_ENROLLED.OBJID%TYPE
		, OP_ERROR_CODE             					OUT NUMBER
		, OP_ERROR_MSG              					OUT VARCHAR2)
		;
	PROCEDURE SP_GET_BUNDLED_PROMO_OBJID(
		IP_ESN              							IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
		, IP_PROGRAM_ENROLLED_OBJID	  					IN  sa.X_PROGRAM_ENROLLED.OBJID%TYPE
		, OP_PROMO_OBJID								OUT sa.TABLE_X_PROMOTION.OBJID%TYPE
		, OP_ERROR_CODE             					OUT NUMBER
		, OP_ERROR_MSG              					OUT VARCHAR2);

	PROCEDURE SP_DEENROLL_BUNDLE_PROG(
		IP_ESN              							IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
		, IP_PROGRAM_ENROLLED_OBJID	  					IN  sa.X_PROGRAM_ENROLLED.OBJID%TYPE
		, OP_ERROR_CODE             					OUT NUMBER
		, OP_ERROR_MSG              					OUT VARCHAR2)
		;
	PROCEDURE SP_DEENROLL_BUNDLE_ESN(
		IP_ESN              							IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
		, OP_ERROR_CODE             					OUT NUMBER
		, OP_ERROR_MSG              					OUT VARCHAR2)
		;
	PROCEDURE SP_INSERT_PROG_PURCH_DTL
		(
			IP_OBJID						            IN	sa.X_PROGRAM_PURCH_DTL.OBJID%TYPE
			,IP_X_ESN						            IN	sa.X_PROGRAM_PURCH_DTL.X_ESN%TYPE
			,IP_X_AMOUNT					          	IN	sa.X_PROGRAM_PURCH_DTL.X_AMOUNT%TYPE
			,IP_X_CHARGE_DESC				        	IN	sa.X_PROGRAM_PURCH_DTL.X_CHARGE_DESC%TYPE
			,IP_X_CYCLE_START_DATE			    		IN	sa.X_PROGRAM_PURCH_DTL.X_CYCLE_START_DATE%TYPE
			,IP_X_CYCLE_END_DATE			      		IN	sa.X_PROGRAM_PURCH_DTL.X_CYCLE_END_DATE%TYPE
			,IP_PGM_PURCH_DTL2PGM_ENROLLED				IN	sa.X_PROGRAM_PURCH_DTL.PGM_PURCH_DTL2PGM_ENROLLED%TYPE
			,IP_PGM_PURCH_DTL2PROG_HDR		  			IN	sa.X_PROGRAM_PURCH_DTL.PGM_PURCH_DTL2PROG_HDR%TYPE
			,IP_PGM_PURCH_DTL2PENAL_PEND	  			IN	sa.X_PROGRAM_PURCH_DTL.PGM_PURCH_DTL2PENAL_PEND%TYPE
			,IP_X_TAX_AMOUNT				        	IN	sa.X_PROGRAM_PURCH_DTL.X_TAX_AMOUNT%TYPE
			,IP_X_E911_TAX_AMOUNT			      		IN	sa.X_PROGRAM_PURCH_DTL.X_E911_TAX_AMOUNT%TYPE
			,IP_X_USF_TAXAMOUNT				      		IN	sa.X_PROGRAM_PURCH_DTL.X_USF_TAXAMOUNT%TYPE
			,IP_X_RCRF_TAX_AMOUNT			      		IN	sa.X_PROGRAM_PURCH_DTL.X_RCRF_TAX_AMOUNT%TYPE
			,IP_X_PRIORITY					        	IN	sa.X_PROGRAM_PURCH_DTL.X_PRIORITY%TYPE
			,OP_STATUS_CODE					        	OUT NUMBER
			,OP_STATUS_MESSAGE				      		OUT VARCHAR2
		);
	PROCEDURE SP_INSERT_PROG_PURCH_HDR
		(
		IP_OBJID										IN	sa.X_PROGRAM_PURCH_HDR.OBJID%TYPE
		, IP_X_RQST_SOURCE								IN	sa.X_PROGRAM_PURCH_HDR.X_RQST_SOURCE%TYPE
		, IP_X_RQST_TYPE								IN	sa.X_PROGRAM_PURCH_HDR.X_RQST_TYPE%TYPE
		, IP_X_RQST_DATE								IN	sa.X_PROGRAM_PURCH_HDR.X_RQST_DATE%TYPE
		, IP_X_ICS_APPLICATIONS							IN	sa.X_PROGRAM_PURCH_HDR.X_ICS_APPLICATIONS%TYPE
		, IP_X_MERCHANT_ID								IN	sa.X_PROGRAM_PURCH_HDR.X_MERCHANT_ID%TYPE
		, IP_X_MERCHANT_REF_NUMBER						IN	sa.X_PROGRAM_PURCH_HDR.X_MERCHANT_REF_NUMBER%TYPE
		, IP_X_OFFER_NUM								IN	sa.X_PROGRAM_PURCH_HDR.X_OFFER_NUM%TYPE
		, IP_X_QUANTITY									IN	sa.X_PROGRAM_PURCH_HDR.X_QUANTITY%TYPE
		, IP_X_MERCHANT_PRODUCT_SKU						IN	sa.X_PROGRAM_PURCH_HDR.X_MERCHANT_PRODUCT_SKU%TYPE
		, IP_X_PAYMENT_LINE2PROGRAM						IN	sa.X_PROGRAM_PURCH_HDR.X_PAYMENT_LINE2PROGRAM%TYPE
		, IP_X_PRODUCT_CODE								IN	sa.X_PROGRAM_PURCH_HDR.X_PRODUCT_CODE%TYPE
		, IP_X_IGNORE_AVS								IN	sa.X_PROGRAM_PURCH_HDR.X_IGNORE_AVS%TYPE
		, IP_X_USER_PO									IN	sa.X_PROGRAM_PURCH_HDR.X_USER_PO%TYPE
		, IP_X_AVS										IN	sa.X_PROGRAM_PURCH_HDR.X_AVS%TYPE
		, IP_X_DISABLE_AVS								IN	sa.X_PROGRAM_PURCH_HDR.X_DISABLE_AVS%TYPE
		, IP_X_CUSTOMER_HOSTNAME						IN	sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_HOSTNAME%TYPE
		, IP_X_CUSTOMER_IPADDRESS						IN	sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_IPADDRESS%TYPE
		, IP_X_AUTH_REQUEST_ID							IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_REQUEST_ID%TYPE
		, IP_X_AUTH_CODE								IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_CODE%TYPE
		, IP_X_AUTH_TYPE								IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_TYPE%TYPE
		, IP_X_ICS_RCODE								IN	sa.X_PROGRAM_PURCH_HDR.X_ICS_RCODE%TYPE
		, IP_X_ICS_RFLAG								IN	sa.X_PROGRAM_PURCH_HDR.X_ICS_RFLAG%TYPE
		, IP_X_ICS_RMSG									IN	sa.X_PROGRAM_PURCH_HDR.X_ICS_RMSG%TYPE
		, IP_X_REQUEST_ID								IN	sa.X_PROGRAM_PURCH_HDR.X_REQUEST_ID%TYPE
		, IP_X_AUTH_AVS									IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_AVS%TYPE
		, IP_X_AUTH_RESPONSE							IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_RESPONSE%TYPE
		, IP_X_AUTH_TIME								IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_TIME%TYPE
		, IP_X_AUTH_RCODE								IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_RCODE%TYPE
		, IP_X_AUTH_RFLAG								IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_RFLAG%TYPE
		, IP_X_AUTH_RMSG								IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_RMSG%TYPE
		, IP_X_BILL_REQUEST_TIME						IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_REQUEST_TIME%TYPE
		, IP_X_BILL_RCODE								IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_RCODE%TYPE
		, IP_X_BILL_RFLAG								IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_RFLAG%TYPE
		, IP_X_BILL_RMSG								IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_RMSG%TYPE
		, IP_X_BILL_TRANS_REF_NO						IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_TRANS_REF_NO%TYPE
		, IP_X_CUSTOMER_FIRSTNAME						IN	sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_FIRSTNAME%TYPE
		, IP_X_CUSTOMER_LASTNAME						IN	sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_LASTNAME%TYPE
		, IP_X_CUSTOMER_PHONE							IN	sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_PHONE%TYPE
		, IP_X_CUSTOMER_EMAIL							IN	sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_EMAIL%TYPE
		, IP_X_STATUS									IN	sa.X_PROGRAM_PURCH_HDR.X_STATUS%TYPE
		, IP_X_BILL_ADDRESS1							IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_ADDRESS1%TYPE
		, IP_X_BILL_ADDRESS2							IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_ADDRESS2%TYPE
		, IP_X_BILL_CITY								IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_CITY%TYPE
		, IP_X_BILL_STATE								IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_STATE%TYPE
		, IP_X_BILL_ZIP									IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_ZIP%TYPE
		, IP_X_BILL_COUNTRY								IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_COUNTRY%TYPE
		, IP_X_ESN										IN	sa.X_PROGRAM_PURCH_HDR.X_ESN%TYPE
		, IP_X_AMOUNT									IN	sa.X_PROGRAM_PURCH_HDR.X_AMOUNT%TYPE
		, IP_X_TAX_AMOUNT								IN	sa.X_PROGRAM_PURCH_HDR.X_TAX_AMOUNT%TYPE
		, IP_X_AUTH_AMOUNT								IN	sa.X_PROGRAM_PURCH_HDR.X_AUTH_AMOUNT%TYPE
		, IP_X_BILL_AMOUNT								IN	sa.X_PROGRAM_PURCH_HDR.X_BILL_AMOUNT%TYPE
		, IP_X_USER										IN	sa.X_PROGRAM_PURCH_HDR.X_USER%TYPE
		, IP_X_CREDIT_CODE								IN	sa.X_PROGRAM_PURCH_HDR.X_CREDIT_CODE%TYPE
		, IP_PURCH_HDR2CREDITCARD						IN	sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2CREDITCARD%TYPE
		, IP_PURCH_HDR2BANK_ACCT						IN	sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2BANK_ACCT%TYPE
		, IP_PURCH_HDR2USER								IN	sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2USER%TYPE
		, IP_PURCH_HDR2ESN								IN	sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2ESN%TYPE
		, IP_PURCH_HDR2RMSG_CODES						IN	sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2RMSG_CODES%TYPE
		, IP_PURCH_HDR2CR_PURCH							IN	sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2CR_PURCH%TYPE
		, IP_PROG_HDR2X_PYMT_SRC						IN	sa.X_PROGRAM_PURCH_HDR.PROG_HDR2X_PYMT_SRC%TYPE
		, IP_PROG_HDR2WEB_USER							IN	sa.X_PROGRAM_PURCH_HDR.PROG_HDR2WEB_USER%TYPE
		, IP_PROG_HDR2PROG_BATCH						IN	sa.X_PROGRAM_PURCH_HDR.PROG_HDR2PROG_BATCH%TYPE
		, IP_X_PAYMENT_TYPE								IN	sa.X_PROGRAM_PURCH_HDR.X_PAYMENT_TYPE%TYPE
		, IP_X_E911_TAX_AMOUNT							IN	sa.X_PROGRAM_PURCH_HDR.X_E911_TAX_AMOUNT%TYPE
		, IP_X_USF_TAXAMOUNT							IN	sa.X_PROGRAM_PURCH_HDR.X_USF_TAXAMOUNT%TYPE
		, IP_X_RCRF_TAX_AMOUNT							IN	sa.X_PROGRAM_PURCH_HDR.X_RCRF_TAX_AMOUNT%TYPE
		, IP_X_PROCESS_DATE								IN	sa.X_PROGRAM_PURCH_HDR.X_PROCESS_DATE%TYPE
		, IP_X_DISCOUNT_AMOUNT							IN	sa.X_PROGRAM_PURCH_HDR.X_DISCOUNT_AMOUNT%TYPE
		, IP_X_PRIORITY									IN	sa.X_PROGRAM_PURCH_HDR.X_PRIORITY%TYPE
		, OP_STATUS_CODE					        	OUT NUMBER
		, OP_STATUS_MESSAGE				      			OUT VARCHAR2
		);
	PROCEDURE SP_INSERT_X_CC_PROG_TRANS
		(
		IP_OBJID										IN	sa.X_CC_PROG_TRANS.OBJID%TYPE
		, IP_X_IGNORE_BAD_CV							IN	sa.X_CC_PROG_TRANS.X_IGNORE_BAD_CV%TYPE
		, IP_X_IGNORE_AVS								IN	sa.X_CC_PROG_TRANS.X_IGNORE_AVS%TYPE
		, IP_X_AVS										IN	sa.X_CC_PROG_TRANS.X_AVS%TYPE
		, IP_X_DISABLE_AVS								IN	sa.X_CC_PROG_TRANS.X_DISABLE_AVS%TYPE
		, IP_X_AUTH_AVS									IN	sa.X_CC_PROG_TRANS.X_AUTH_AVS%TYPE
		, IP_X_AUTH_CV_RESULT							IN	sa.X_CC_PROG_TRANS.X_AUTH_CV_RESULT%TYPE
		, IP_X_SCORE_FACTORS							IN	sa.X_CC_PROG_TRANS.X_SCORE_FACTORS%TYPE
		, IP_X_SCORE_HOST_SEVERITY						IN	sa.X_CC_PROG_TRANS.X_SCORE_HOST_SEVERITY%TYPE
		, IP_X_SCORE_RCODE								IN	sa.X_CC_PROG_TRANS.X_SCORE_RCODE%TYPE
		, IP_X_SCORE_RFLAG								IN	sa.X_CC_PROG_TRANS.X_SCORE_RFLAG%TYPE
		, IP_X_SCORE_RMSG								IN	sa.X_CC_PROG_TRANS.X_SCORE_RMSG%TYPE
		, IP_X_SCORE_RESULT								IN	sa.X_CC_PROG_TRANS.X_SCORE_RESULT%TYPE
		, IP_X_SCORE_TIME_LOCAL							IN	sa.X_CC_PROG_TRANS.X_SCORE_TIME_LOCAL%TYPE
		, IP_X_CUSTOMER_CC_NUMBER						IN	sa.X_CC_PROG_TRANS.X_CUSTOMER_CC_NUMBER%TYPE
		, IP_X_CUSTOMER_CC_EXPMO						IN	sa.X_CC_PROG_TRANS.X_CUSTOMER_CC_EXPMO%TYPE
		, IP_X_CUSTOMER_CC_EXPYR						IN	sa.X_CC_PROG_TRANS.X_CUSTOMER_CC_EXPYR%TYPE
		, IP_X_CUSTOMER_CVV_NUM							IN	sa.X_CC_PROG_TRANS.X_CUSTOMER_CVV_NUM%TYPE
		, IP_X_CC_LASTFOUR								IN	sa.X_CC_PROG_TRANS.X_CC_LASTFOUR%TYPE
		, IP_X_CC_TRANS2X_CREDIT_CARD					IN	sa.X_CC_PROG_TRANS.X_CC_TRANS2X_CREDIT_CARD%TYPE
		, IP_X_CC_TRANS2X_PURCH_HDR						IN	sa.X_CC_PROG_TRANS.X_CC_TRANS2X_PURCH_HDR%TYPE
		, OP_STATUS_CODE					        	OUT NUMBER
		, OP_STATUS_MESSAGE				      			OUT VARCHAR2
		);
	PROCEDURE SP_INSERT_X_ACH_PROG_TRANS
		(
		IP_OBJID										IN sa.X_ACH_PROG_TRANS.OBJID%TYPE
		, IP_X_BANK_NUM									IN sa.X_ACH_PROG_TRANS.X_BANK_NUM%TYPE
		, IP_X_ECP_ACCOUNT_NO							IN sa.X_ACH_PROG_TRANS.X_ECP_ACCOUNT_NO%TYPE
		, IP_X_ECP_ACCOUNT_TYPE							IN sa.X_ACH_PROG_TRANS.X_ECP_ACCOUNT_TYPE%TYPE
		, IP_X_ECP_RDFI									IN sa.X_ACH_PROG_TRANS.X_ECP_RDFI%TYPE
		, IP_X_ECP_SETTLEMENT_METHOD					IN sa.X_ACH_PROG_TRANS.X_ECP_SETTLEMENT_METHOD%TYPE
		, IP_X_ECP_PAYMENT_MODE						    IN sa.X_ACH_PROG_TRANS.X_ECP_PAYMENT_MODE%TYPE
		, IP_X_ECP_DEBIT_REQUEST_ID						IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_REQUEST_ID%TYPE
		, IP_X_ECP_VERFICATION_LEVEL					IN sa.X_ACH_PROG_TRANS.X_ECP_VERFICATION_LEVEL%TYPE
		, IP_X_ECP_REF_NUMBER							IN sa.X_ACH_PROG_TRANS.X_ECP_REF_NUMBER%TYPE
		, IP_X_ECP_DEBIT_REF_NUMBER						IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_REF_NUMBER%TYPE
		, IP_X_ECP_DEBIT_AVS							IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_AVS%TYPE
		, IP_X_ECP_DEBIT_AVS_RAW						IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_AVS_RAW%TYPE
		, IP_X_ECP_RCODE								IN sa.X_ACH_PROG_TRANS.X_ECP_RCODE%TYPE
		, IP_X_ECP_TRANS_ID								IN sa.X_ACH_PROG_TRANS.X_ECP_TRANS_ID%TYPE
		, IP_X_ECP_REF_NO								IN sa.X_ACH_PROG_TRANS.X_ECP_REF_NO%TYPE
		, IP_X_ECP_RESULT_CODE							IN sa.X_ACH_PROG_TRANS.X_ECP_RESULT_CODE%TYPE
		, IP_X_ECP_RFLAG								IN sa.X_ACH_PROG_TRANS.X_ECP_RFLAG%TYPE
		, IP_X_ECP_RMSG									IN sa.X_ACH_PROG_TRANS.X_ECP_RMSG%TYPE
		, IP_X_ECP_CREDIT_REF_NUMBER					IN sa.X_ACH_PROG_TRANS.X_ECP_CREDIT_REF_NUMBER%TYPE
		, IP_X_ECP_CREDIT_TRANS_ID						IN sa.X_ACH_PROG_TRANS.X_ECP_CREDIT_TRANS_ID%TYPE
		, IP_X_DECLINE_AVS_FLAGS						IN sa.X_ACH_PROG_TRANS.X_DECLINE_AVS_FLAGS%TYPE
		, IP_ACH_TRANS2X_PURCH_HDR						IN sa.X_ACH_PROG_TRANS.ACH_TRANS2X_PURCH_HDR%TYPE
		, IP_ACH_TRANS2X_BANK_ACCOUNT					IN sa.X_ACH_PROG_TRANS.ACH_TRANS2X_BANK_ACCOUNT%TYPE
		, IP_ACH_TRANS2PGM_ENROLLED						IN sa.X_ACH_PROG_TRANS.ACH_TRANS2PGM_ENROLLED%TYPE
		, OP_STATUS_CODE					        	OUT NUMBER
		, OP_STATUS_MESSAGE				      			OUT VARCHAR2
		);
	PROCEDURE SP_GET_PAYMENT_SOURCE
		(
		IP_PAY_SOURCE_OBJID 							IN 	sa.X_PAYMENT_SOURCE.OBJID%TYPE
		, OP_PE_PAYMENT_SOURCE							OUT sa.X_PAYMENT_SOURCE.OBJID%TYPE
		, OP_PAYMENT_SOURCE_TYPE						OUT sa.X_PAYMENT_SOURCE.X_PYMT_TYPE%TYPE
		, OP_CREDIT_CARD_OBJID							OUT sa.X_PAYMENT_SOURCE.PYMT_SRC2X_CREDIT_CARD%TYPE
		, OP_BANK_ACCOUNT_OBJID							OUT sa.X_PAYMENT_SOURCE.PYMT_SRC2X_BANK_ACCOUNT%TYPE
		, OP_RESULT       								OUT NUMBER
		, OP_MSG          								OUT VARCHAR2
		);

	FUNCTION FN_GET_NEXT_CYCLE_DATE(
		IP_PROG_PARAM_OBJID   							IN NUMBER,
		IP_CURRENT_CYCLE_DATE 					        IN DATE )
		RETURN DATE;

	PROCEDURE SP_GET_CREDIT_CARD_INFO
		(
			IP_CREDIT_CARD_OBJID						IN sa.TABLE_X_CREDIT_CARD.OBJID%TYPE
			, OP_CREDIT_CARD_REC 						OUT sa.TABLE_X_CREDIT_CARD%ROWTYPE
			, OP_RESULT       							OUT NUMBER
			, OP_MSG          							OUT VARCHAR2
		);
	PROCEDURE SP_GET_BANK_ACCOUNT
		(
			L_BANK_ACCOUNT_OBJID						IN sa.TABLE_X_BANK_ACCOUNT.OBJID%TYPE
			, OP_BANK_ACCT_REC 		  					OUT sa.TABLE_X_BANK_ACCOUNT%ROWTYPE
			, OP_RESULT       							OUT NUMBER
			, OP_MSG          							OUT VARCHAR2
		);
	PROCEDURE SP_GET_ADDRESS_INFO
		(
			IP_ADDRESS_OBJID 							IN 		sa.TABLE_ADDRESS.OBJID%TYPE
			, OP_ADDRESS_REC							OUT 	sa.TABLE_ADDRESS%ROWTYPE
			, OP_RESULT       							OUT NUMBER
			, OP_MSG         							OUT VARCHAR2
		);
	PROCEDURE SP_RECURRING_PAYMENT_BUNDLE(
		IP_BUS_ORG                    					IN VARCHAR2 DEFAULT 'TRACFONE'
		, IP_PRIORITY                 					IN VARCHAR2 DEFAULT NULL
		, OP_RESULT                   					OUT NUMBER
		, OP_MSG                      					OUT VARCHAR2
		);
	PROCEDURE SP_BUNDLE_ELIGIBLE_ESN
		(IP_PROCESS_DATE								IN 	DATE
		, OP_RESULT       								OUT NUMBER
		, OP_MSG          								OUT VARCHAR2  )
		;
	PROCEDURE SP_RECON_BUNDLED_ESNS
		(IP_ESN											IN sa.X_PROGRAM_ENROLLED.X_ESN%TYPE
		,IP_PROG_ENR_OBJID								IN sa.X_PROGRAM_ENROLLED.OBJID%TYPE
		, IP_PROG_PURCH_HDR_X_STATUS					IN sa.X_PROGRAM_PURCH_HDR.X_STATUS%TYPE
		, OP_RESULT       								OUT NUMBER
		, OP_MSG          								OUT VARCHAR2)
    ;
END BILLING_BUNDLE_PKG;
/