CREATE OR REPLACE package sa.adfcrm_cust_pymt_info is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CUST_PYMT_INFO_PKG.sql,v $
--$Revision: 1.4 $
--$Author: mmunoz $
--$Date: 2015/05/29 21:50:30 $
--$ $Log: ADFCRM_CUST_PYMT_INFO_PKG.sql,v $
--$ Revision 1.4  2015/05/29 21:50:30  mmunoz
--$ CR34207	: added contact_objid in new functions
--$
--$ Revision 1.3  2015/05/28 21:54:16  mmunoz
--$ CR34207	TAS Consent to Save CC Info
--$
--$ Revision 1.2  2014/10/28 21:29:31  mmunoz
--$ CR31050	Migration of existing ACH accounts to DataPower Tokenization
--$
--$ Revision 1.1  2014/07/11 18:29:18  mmunoz
--$ new functions  insert_ach and update_ach
--$
--------------------------------------------------------------------------------------------
  function insert_ach (
		ip_bank_num varchar2,
		ip_customer_acct varchar2,
		ip_routing varchar2,
		ip_bank_name varchar2,
		ip_status varchar2,
		ip_customer_firstname varchar2,
		ip_customer_lastname varchar2,
		ip_customer_phone varchar2,
		ip_customer_email varchar2,
		ip_max_purch_amt varchar2,
		ip_changedby varchar2,
		ip_cc_comments varchar2,
		ip_bank_acct2contact varchar2,
		ip_bank_acct2address varchar2,
		ip_org_id varchar2,
		ip_aba_transit varchar2,
		ip_bank2cert varchar2,
		ip_customer_acct_key varchar2,
		ip_customer_acct_enc varchar2,
		ip_key_transport_algo varchar2,
		ip_algo varchar2
  ) return varchar2;
------------------------------------------------------------------------------------
  function update_ach (
		ip_bank_acnt_objid varchar2,
		ip_bank_num varchar2,
		ip_customer_firstname varchar2,
		ip_customer_lastname varchar2,
		ip_customer_phone varchar2,
		ip_customer_email varchar2,
		ip_changedby varchar2,
		ip_cc_comments varchar2,
		ip_aba_transit varchar2
  ) return varchar2;

------------------------------------------------------------------------------------
--CR34207 new function insert_cc_no_consent
  function insert_cc_no_consent (
    ip_cc_objid number,
    ip_web_user_objid number,
    ip_contact_objid number
  )
  return varchar2;
------------------------------------------------------------------------------------
--CR34207 new function delete_cc_no_consent
  function delete_cc_no_consent (
    ip_cc_objid number,
    ip_web_user_objid number,
    ip_contact_objid number
  )
  return varchar2;

end adfcrm_cust_pymt_info;
/