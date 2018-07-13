CREATE OR REPLACE FORCE VIEW sa.table_extactcase (contact_objid,elm_objid,clarify_state,id_number,title,s_title,age,"CONDITION",s_condition,status,s_status,last_name,s_last_name,first_name,s_first_name,creation_time,location_objid,is_supercase,x_case_type,x_retailer_name,x_phone_model,x_carrier_name,x_carrier_id,x_esn,x_iccid,x_min,x_replacement_units,login_name,s_login_name,issue) AS
SELECT table_contact.objid,
    table_case.objid,
    table_condition.condition,
    table_case.id_number,
    table_case.title,
    table_case.S_title,
    table_condition.wipbin_time,
    table_condition.title,
    table_condition.S_title,
    table_gbst_elm.title,
    table_gbst_elm.S_title,
    table_contact.last_name,
    table_contact.S_last_name,
    table_contact.first_name,
    table_contact.S_first_name,
    table_case.creation_time,
    table_case.case_reporter2site,
    table_case.is_supercase,
    table_case.x_case_type,
    table_case.x_retailer_name,
    table_case.x_phone_model,
    table_case.x_carrier_name,
    table_case.x_carrier_id,
    table_case.x_esn,
    table_case.x_iccid,
    table_case.x_min,
    table_case.x_replacement_units,
    table_user.login_name,
    table_user.S_login_name,
    table_case.case_type_lvl1
  FROM table_contact,
    table_case,
    table_condition,
    table_gbst_elm,
    table_user
  WHERE table_condition.objid        = table_case.case_state2condition
  AND table_user.objid               = table_case.case_owner2user
  AND table_contact.objid            = table_case.case_reporter2contact
  AND table_case.case_reporter2site IS NOT NULL
  AND table_gbst_elm.objid           = table_case.casests2gbst_elm;