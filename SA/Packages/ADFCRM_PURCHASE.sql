CREATE OR REPLACE package sa.ADFCRM_PURCHASE is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_PURCHASE_PKG.sql,v $
--$Revision: 1.3 $
--$Author: mmunoz $
--$Date: 2017/02/23 22:59:09 $
--$ $Log: ADFCRM_PURCHASE_PKG.sql,v $
--$ Revision 1.3  2017/02/23 22:59:09  mmunoz
--$ CR46822 New parameter in create_payment_source
--$
--$ Revision 1.2  2014/07/14 18:55:53  mmunoz
--$ added function create_payment_source_ach
--$
--$ Revision 1.1  2013/12/06 22:19:18  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------

  function activation_failed(ip_min varchar2,
                                    ip_esn varchar2,
                                    ip_task_objid number,
                                    ip_user varchar2,
                                    ip_call_trans_objid varchar2,
                                    ip_order_type varchar2,
                                    ip_error_code_dd varchar2 -- drop down list
                                    ) return varchar2;

  function activation_successful(ip_min varchar2,
                                        ip_esn varchar2,
                                        ip_technology varchar2,
                                        ip_task_id varchar2,
                                        ip_task_objid number,
                                        ip_status varchar2,
                                        ip_user varchar2,
                                        ip_call_trans_objid varchar2,
                                        ip_order_type varchar2,
                                        ip_carrier_objid number) return varchar2;

  procedure calculate_taxes_prc (ip_zipcode          in varchar2,
                                        ip_partnumbers      in varchar2,
                                        ip_esn              in varchar2,
                                        ip_cc_id            in number, --Credit Card objid
                                        ip_promo            in varchar2,
                                        ip_brand_name       in varchar2,
                                        ip_transaction_type in varchar2, --'ACTIVATION', 'REACTIVATION','REDEMPTION','PURCHASE', 'PROMOENROLLMENT'
                                        op_combstaxamt     out number,
                                        op_e911amt         out number,
                                        op_usfamt          out number,
                                        op_rcrfamt         out number,
                                        op_subtotalamount  out number,
                                        op_totaltaxamount  out number,
                                        op_totalcharges    out number,
                                        op_combstaxrate    out number,
                                        op_e911rate        out number,
                                        op_usfrate         out number,
                                        op_rcrfrate        out number,
                                        op_result          out number,
                                        op_msg             out varchar2);

  function create_payment_source (p_cc_objid in varchar2,
                                  p_web_user_objid in varchar2,
                                  p_link_to_web_user in varchar2 DEFAULT 'Y') return varchar2;

  --------------------------------------------------------------------------------------------
  function create_payment_source_ach(p_ach_objid in varchar2,
                                     p_web_user_objid in varchar2) return varchar2;
end adfcrm_purchase;
/