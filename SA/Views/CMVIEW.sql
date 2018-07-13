CREATE OR REPLACE FORCE VIEW sa.cmview (id_number,case_type,title,s_title,carrier_mkt_name,esn,phone_model,"MIN","CONDITION",cond_objid,case_objid,s_condition,status,creation_time,x_iccid,created_by) AS
SELECT c.id_number,
    c.x_case_type case_type,
    c.title title,
    c.s_title s_title,
    c.x_carrier_name carrier_mkt_name,
    c.x_esn esn,
    c.x_phone_model phone_model,
    c.x_min MIN,
    co.title condition,
    co.objid cond_objid,
    c.objid case_objid,
    co.s_title s_condition,
    gb.title status ,
    c.creation_time,
    c.x_iccid,
    us.login_name
  FROM table_case c,
    table_condition co,
    table_gbst_elm gb,
    table_user us
  WHERE 1           =1
  AND co.objid      = c.case_state2condition
  AND gb.objid      = c.casests2gbst_elm
  AND us.objid      = c.case_originator2user
  AND creation_time > TRUNC(sysdate)-90;