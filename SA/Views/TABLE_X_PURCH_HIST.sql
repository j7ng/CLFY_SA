CREATE OR REPLACE FORCE VIEW sa.table_x_purch_hist (x_purch_dtl_objid,x_redcard_num,x_smp,x_price,x_units,x_purch_hdr_objid,x_esn,x_cc_lastfour,x_rqst_source,x_rqst_type,x_rqst_date,x_merchant_ref_number,x_amount,x_ics_rcode,x_ics_rflag,x_ics_rmsg,x_credit_card_objid,x_customer_cc_number,x_bank_account_objid,x_customer_bankacct,login_name,s_login_name,x_bill_amount) AS
select table_x_purch_dtl.objid, table_x_purch_dtl.x_red_card_number,
 table_x_purch_dtl.x_smp, table_x_purch_dtl.x_price,
 table_x_purch_dtl.x_units, table_x_purch_hdr.objid,
 table_x_purch_hdr.x_esn, table_x_purch_hdr.x_cc_lastfour,
 table_x_purch_hdr.x_rqst_source, table_x_purch_hdr.x_rqst_type,
 table_x_purch_hdr.x_rqst_date, table_x_purch_hdr.x_merchant_ref_number,
 table_x_purch_hdr.x_amount, table_x_purch_hdr.x_ics_rcode,
 table_x_purch_hdr.x_ics_rflag, table_x_purch_hdr.x_ics_rmsg,
 table_x_credit_card.objid, table_x_credit_card.x_customer_cc_number,
 table_x_bank_account.objid, table_x_bank_account.x_customer_acct,
 table_user.login_name, table_user.S_login_name, table_x_purch_hdr.x_bill_amount
 from table_x_purch_dtl, table_x_purch_hdr, table_x_credit_card,
  table_x_bank_account, table_user, table_contact
 where table_contact.objid = table_x_purch_hdr.x_purch_hdr2contact
 AND table_user.objid = table_x_purch_hdr.x_purch_hdr2user
 AND table_x_credit_card.objid = table_x_purch_hdr.x_purch_hdr2creditcard
 AND table_x_purch_hdr.objid = table_x_purch_dtl.x_purch_dtl2x_purch_hdr
 AND table_x_bank_account.objid = table_x_purch_hdr.x_purch_hdr2bank_acct
 ;