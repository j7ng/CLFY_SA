CREATE OR REPLACE PACKAGE sa."ADFCRM_INTERNAL" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_INTERNAL_PKG.sql,v $
--$Revision: 1.13 $
--$Author: syenduri $
--$Date: 2018/01/08 19:44:04 $
--$ $Log: ADFCRM_INTERNAL_PKG.sql,v $
--$ Revision 1.13  2018/01/08 19:44:04  syenduri
--$ CR55055 Add Logic to NewCCAddedFlag in TAS Summary Report
--$
--$ Revision 1.12  2017/11/03 18:26:56  nguada
--$ CR53019
--$
--$ Revision 1.11  2017/08/23 16:01:54  mmunoz
--$ CR50120 Record Solutions Configuration Table Updates
--$
--$ Revision 1.10  2015/11/10 19:58:03  mmunoz
--$ CR38663 New function unreserved_lines_from_esn
--$
--$ Revision 1.9  2015/10/09 14:38:52  mmunoz
--$ Apollo new function get_part_class
--$
--$ Revision 1.8  2015/02/13 21:42:43  hcampano
--$ TAS_2015_05 - Added function to determine if the esn is a home_center. This is temporary location. it should be moved to device util.
--$
--$ Revision 1.7  2015/02/02 20:53:42  hcampano
--$ TAS_2015_05 - CR30702 - TAS Activity Log Improvements
--$
--$ Revision 1.6  2015/02/02 20:34:27  hcampano
--$ TAS_2015_05 - CR30702 - TAS Activity Log Improvements
--$
--$ Revision 1.5  2014/07/16 16:07:32  mmunoz
--$ added procedure write_log (hcampano)
--$
--$ Revision 1.4  2014/07/16 15:46:44  mmunoz
--$ added functions add_new_models_to_solutions  and func_ins_model_to_sol
--$
--$ Revision 1.3  2014/04/24 10:23:42  nguada
--$ Refresh solutions functions added.  TAS_2014_03
--$
--$ Revision 1.2  2013/12/09 16:27:57  mmunoz
--$ CR26679
--$
--$ Revision 1.1  2013/12/06 19:29:59  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------
  function change_password (ip_login_name in varchar2,
                                   ip_password   in varchar2,
                                   ip_new_password_1 in varchar2,
                                   ip_new_password_2 in varchar2) return varchar2;

  function func_ins_sol_model (ip_sol_id sa.adfcrm_solution.solution_id%type,
                               ip_mode   varchar2,
                               ip_login_name varchar2)   --Clean
  return number;

  function task_flow_id(p_task_id in varchar2) return varchar2;

  function task_flow_id2(p_task_id in varchar2,p_esn varchar2) return varchar2;

  function validate_user (ip_login_name in varchar2,
                                 ip_password   in varchar2) return number;

  procedure address (p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_address_objid in out number,  -- null--> Create / not null --> Update Address
                            p_err_code out varchar2,
                            p_err_msg  out varchar2);

  FUNCTION ADFCRM_TASK_FLOW_ID(
      P_TASK_ID IN VARCHAR2)
    RETURN VARCHAR2;

  function refresh_solution_models(ip_login_name varchar2) return number;

  function add_new_models_to_solutions (ip_param_list varchar2, ip_login_name varchar2)  --comma separated values with part class names
  return number;

  function func_ins_model_to_sol (ip_sol_id sa.adfcrm_solution.solution_id%type,
                                  part_class_name   varchar2,
                                  ip_login_name varchar2)
  return number;

  procedure write_log (ip_call_id sa.adfcrm_activity_log.call_id%type,
                       ip_esn sa.adfcrm_activity_log.esn%type,
                       ip_cust_id sa.adfcrm_activity_log.cust_id%type,
                       ip_smp sa.adfcrm_activity_log.smp%type,
                       ip_agent sa.adfcrm_activity_log.agent%type,
                       ip_flow_name sa.adfcrm_activity_log.flow_name%type,
                       ip_flow_description sa.adfcrm_activity_log.flow_description%type,
                       ip_status sa.adfcrm_activity_log.status%type,
                       ip_permission_name sa.adfcrm_activity_log.permission_name%type,
                       ip_reason sa.adfcrm_activity_log.reason%type
                       );

--------------------------------------------------------------------------------------------
-- OVERLOADED NEW
--------------------------------------------------------------------------------------------
  procedure write_log (ip_call_id sa.adfcrm_activity_log.call_id%type,
                       ip_esn sa.adfcrm_activity_log.esn%type,
                       ip_cust_id sa.adfcrm_activity_log.cust_id%type,
                       ip_smp sa.adfcrm_activity_log.smp%type,
                       ip_agent sa.adfcrm_activity_log.agent%type,
                       ip_flow_name sa.adfcrm_activity_log.flow_name%type,
                       ip_flow_description sa.adfcrm_activity_log.flow_description%type,
                       ip_status sa.adfcrm_activity_log.status%type,
                       ip_permission_name sa.adfcrm_activity_log.permission_name%type,
                       ip_reason sa.adfcrm_activity_log.reason%type,
                       ip_ani varchar2
                       );
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- OVERLOADED for NEW_CC_ADDED_FLAG
--------------------------------------------------------------------------------------------
  procedure write_log (ip_call_id sa.adfcrm_activity_log.call_id%type,
                       ip_esn sa.adfcrm_activity_log.esn%type,
                       ip_cust_id sa.adfcrm_activity_log.cust_id%type,
                       ip_smp sa.adfcrm_activity_log.smp%type,
                       ip_agent sa.adfcrm_activity_log.agent%type,
                       ip_flow_name sa.adfcrm_activity_log.flow_name%type,
                       ip_flow_description sa.adfcrm_activity_log.flow_description%type,
                       ip_status sa.adfcrm_activity_log.status%type,
                       ip_permission_name sa.adfcrm_activity_log.permission_name%type,
                       ip_reason sa.adfcrm_activity_log.reason%type,
                       ip_ani varchar2,
                       ip_new_cc_added varchar2
                       );
--------------------------------------------------------------------------------------------

  function is_home_center(p_esn varchar2)
  return number;

  --Apollo new function get_part_class
  function get_part_class(p_part_number varchar2)
  return varchar2;

  --CR38663
  function unreserved_lines_from_esn(ip_esn varchar2, ip_org_id varchar2)
  return varchar;

--************************************************************************************************************
--CR50120 Record Solutions Configuration Table Updates
PROCEDURE set_User_Deleted_Rows_Hist
        (ip_table_name in varchar2,
        ip_solution_id  in varchar2,
        ip_class_param_name in varchar2,
        ip_class_param_value in varchar2,
        ip_ss_id in varchar2,
        ip_token in varchar2,
        ip_case_conf_hdr_id in varchar2,
        ip_task_id in varchar2,
        ip_part_class_id in varchar2,
        ip_issue_id in varchar2,
        ip_file_id in varchar2,
        ip_tfs_id in varchar2,
        ip_login_name in varchar2);

end adfcrm_internal;
/