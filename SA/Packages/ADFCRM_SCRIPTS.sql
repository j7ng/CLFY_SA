CREATE OR REPLACE PACKAGE sa."ADFCRM_SCRIPTS" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_SCRIPTS_PKG.sql,v $
--$Revision: 1.12 $
--$Author: hcampano $
--$Date: 2017/01/06 15:55:32 $
--$ $Log: ADFCRM_SCRIPTS_PKG.sql,v $
--$ Revision 1.12  2017/01/06 15:55:32  hcampano
--$ CR44729 - GO Smart
--$
--$ Revision 1.11  2016/11/01 22:06:32  amishra
--$ CR 45463, 44787 : Changes for BOGO promotion in transaction summary
--$
--$ Revision 1.10  2016/05/09 20:59:41  mmunoz
--$ CR39151: Added ip_source_system varchar2 default 'TAS'  in function solution_script_func
--$
--$ Revision 1.9  2016/02/17 16:33:52  hcampano
--$ TAS_2016_04A
--$
--$ Revision 1.8  2015/10/27 15:56:18  syenduri
--$ TAS_2015_21 - CR# 36435 - TAS Repl/Comp Changes
--$
--$ Revision 1.7  2015/05/26 15:57:26  mmunoz
--$ CR32952 new function get_generic_brand_script
--$
--$ Revision 1.6  2015/01/27 21:56:30  mmunoz
--$ Included  function get_text_with_tokens
--$
--$ Revision 1.5  2014/06/04 00:38:46  mmunoz
--$ Changes for solution_token_func
--$
--$ Revision 1.4  2014/04/21 16:22:51  mmunoz
--$ TAS_2014_02
--$
--$ Revision 1.3  2014/03/31 22:39:25  mmunoz
--$ CR26941 Added get_script_message
--$
--$ Revision 1.2  2014/03/14 20:10:00  nguada
--$ CR27598    Change x_service_plan descriptions
--$
--$ Revision 1.1  2013/12/06 22:19:34  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------

  function get_script_by_class (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_part_class  varchar2) return varchar2;

  function get_script_by_class_ss (ip_script_type varchar2,
                                   ip_script_id varchar2,
                                   ip_language varchar2,
                                   ip_part_class  varchar2,
                                   ip_sourcesystem varchar2) return varchar2;

  function get_script_by_esn (ip_script_type varchar2,
                              ip_script_id varchar2,
                              ip_language varchar2,
                              ip_esn  varchar2) return varchar2;
  --------------------------------------------------------------------------------------------
  function solution_script_func (ip_solution_name sa.adfcrm_solution.solution_name%type,
                                 ip_esn sa.table_part_inst.part_serial_no%type,
                                 ip_language varchar2,
                                 ip_param_list varchar2) return clob;

  function solution_script_func (ip_solution_name sa.adfcrm_solution.solution_name%type,
                                 ip_esn sa.table_part_inst.part_serial_no%type,
                                 ip_language varchar2,
                                 ip_param_list varchar2,
                                 ip_transaction_id varchar2,
                                 ip_case_id varchar2,
								 ip_source_system varchar2 default 'TAS',
                                 ip_check_condition varchar2 default 'BOGO=NO') return clob;
  --------------------------------------------------------------------------------------------
  function solution_token_func (ip_esn varchar2,
                                ip_params_list varchar2,
                                ip_token varchar2) return varchar2;

  function solution_token_func (ip_esn varchar2,
                                ip_call_id varchar2,
                                ip_purchase_id varchar2,
								ip_language varchar2,
								ip_token varchar2
								) return varchar2;
  --------------------------------------------------------------------------------------------
  function update_ticker (v_tf_script_text in varchar2,
                          v_nt_script_text in varchar2,
                          v_tf_objid in varchar2,
                          v_nt_objid in varchar2,
                          v_login_name in varchar2) return varchar2;

function get_feature_value (p_sp_objid  in number,
                            p_feature   in varchar2) return varchar2;


  function get_generic_script  (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_sourcesystem  varchar2) return varchar2;

  function get_plan_description (p_sp_objid in number,
                                 p_language in varchar2,
                                 p_sourcesystem in varchar2) return varchar2;

  function get_script_message(ip_function varchar2,            --USE THE FUNCTIONALITY NAME
                                ip_flow varchar2,                --USE THE PERMISSION NAME TO ACCESS THE PAGE, DEFAULT ALL
                                ip_language varchar2,            --ENGLISH,SPANISH
                                ip_sourcesystem  varchar2,       --TAS
                                ip_esn varchar2,
                                ip_pin_value varchar2
                                ) return varchar2;

  function get_text_with_tokens (ip_esn in varchar2,
                                ip_part_class in varchar2,
                                ip_transaction_id in varchar2,
                                ip_param_list in varchar2,
                                ip_language in varchar2,
                                ip_script_text in clob,
                                ip_sourcesystem in varchar2)
  return clob;

  --CR32952 new function get_generic_brand_script
  function get_generic_brand_script  (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_sourcesystem  varchar2,
                                ip_brand_name varchar2) return varchar2;

  function get_plan_desc_frm_cvge_script (p_sp_objid in number,
                                 p_language in varchar2,
                                 p_sourcesystem in varchar2) return varchar2;


  function get_alert_block_script (ip_permission in varchar2,
                                   ip_alert_title in varchar2,
                                   ip_esn in varchar2,
                                   ip_language in varchar2,
                                   ip_sourcesystem in varchar2) return varchar2;

  function get_script_brand(ip_pc varchar2)
  return varchar2;

  function get_script_brand(ip_pc_objid number)
  return varchar2;
end;
/