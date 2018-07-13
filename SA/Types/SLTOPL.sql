CREATE OR REPLACE TYPE sa."SLTOPL"                                                                          AS OBJECT
(
	errorCode_struct        PL_ERROR_CODE_STRUCTURE,
	transID_struct          PL_TRANSID_STRUCTURE,
	psmsCode_struct         PL_PSMS_CODE_STRUCTURE,
	cmdCode_struct          PL_COMCODE_ARRAY,
	inquiryAck_struct       PL_INQUIRACK_ARRAY,
	redemption_struct       PL_REDEMPTION_STRUCTURE,
	ackReturn_struct        PL_ACKRETURN_STRUCTURE,
	unused_struct           PL_UNUSED_STRUCTURE
)
/