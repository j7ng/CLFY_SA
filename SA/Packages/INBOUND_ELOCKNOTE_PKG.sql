CREATE OR REPLACE PACKAGE sa."INBOUND_ELOCKNOTE_PKG" as
  procedure main_prc(
			    p_cycleNumber         varchar2,
			    p_Type_i              varchar2,
			    p_creationDate        varchar2,
			    p_transactionAmount   number,
			    p_accountNumber       varchar2,
			    p_firstName           varchar2 DEFAULT NULL,
			    p_lastName            varchar2 DEFAULT NULL,
			    p_accountStatus       varchar2,
			    p_paymentMode         number,
			    p_uniqueRecord        number,
			    p_status              varchar2 DEFAULT NULL,
			    p_enrollFeeFlag       varchar2 DEFAULT NULL,
			    p_promoCode           varchar2 DEFAULT NULL,
			    p_msg OUT varchar2,
			    c_p_status OUT varchar2);
end INBOUND_ELOCKNOTE_PKG;
/