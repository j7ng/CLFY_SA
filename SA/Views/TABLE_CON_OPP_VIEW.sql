CREATE OR REPLACE FORCE VIEW sa.table_con_opp_view (objid,con_objid,opp_objid,first_name,s_first_name,last_name,s_last_name,phone,role_name,focus_type,"ACTIVE","ID",s_id,objective,"NAME",s_name,proj_name,purch_date,comments,orientation,time_spent,your_status,con_title,owner_objid,stage_objid,curr_objid,stage,s_stage,"OWNER",s_owner,currency,s_currency,sub_scale) AS
select table_con_opp_role.objid, table_contact.objid,
 table_opportunity.objid, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_con_opp_role.role_name, table_con_opp_role.focus_type,
 table_con_opp_role.active, table_opportunity.id, table_opportunity.S_id,
 table_opportunity.objective, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.proj_name, table_opportunity.purch_date,
 table_con_opp_role.comments, table_con_opp_role.orientation,
 table_con_opp_role.time_spent, table_con_opp_role.your_status,
 table_contact.title, table_user.objid,
 table_cycle_stage.objid, table_currency.objid,
 table_cycle_stage.name, table_cycle_stage.S_name, table_user.login_name, table_user.S_login_name,
 table_currency.name, table_currency.S_name, table_currency.sub_scale
 from table_con_opp_role, table_contact, table_opportunity,
  table_user, table_cycle_stage, table_currency
 where table_user.objid = table_opportunity.opp_owner2user
 AND table_currency.objid = table_opportunity.opp2currency
 AND table_contact.objid = table_con_opp_role.opp_role2contact
 AND table_opportunity.objid = table_con_opp_role.con_role2opportunity
 AND table_cycle_stage.objid = table_opportunity.opp2cycle_stage
 ;
COMMENT ON TABLE sa.table_con_opp_view IS 'Used by the Opportunity tab in the Contact form (773), tab Opportunity Contacts of form Opportunity Detail (9601,9630), Account (11650), My Clarify (12000), and Opportunity (13000)';
COMMENT ON COLUMN sa.table_con_opp_view.objid IS 'Con_opp_role internal record number';
COMMENT ON COLUMN sa.table_con_opp_view.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_con_opp_view.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_con_opp_view.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_con_opp_view.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_con_opp_view.phone IS 'Contact phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_con_opp_view.role_name IS 'Name of the role. This is a user-defined popup with defaul name Roles In The Buying';
COMMENT ON COLUMN sa.table_con_opp_view.focus_type IS 'Object type ID of the role-player; i.e., 45=a contact s role, 5000=an opportunity s role';
COMMENT ON COLUMN sa.table_con_opp_view."ACTIVE" IS 'Indicates whether the role is active; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_con_opp_view."ID" IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_con_opp_view.objective IS 'Sales objective for this opportunity';
COMMENT ON COLUMN sa.table_con_opp_view."NAME" IS 'Name given to the opportunity';
COMMENT ON COLUMN sa.table_con_opp_view.proj_name IS 'Customer s project name for the opportunity';
COMMENT ON COLUMN sa.table_con_opp_view.purch_date IS 'When the opportunity is expected to close';
COMMENT ON COLUMN sa.table_con_opp_view.comments IS 'Comments about the role';
COMMENT ON COLUMN sa.table_con_opp_view.orientation IS 'Decision orientation is a function of style, not job function. This is a user-defined popup with default name Decision Orientation';
COMMENT ON COLUMN sa.table_con_opp_view.time_spent IS 'Indicates the time spent with the person. This is from a user-defined popup with default name Time Spent';
COMMENT ON COLUMN sa.table_con_opp_view.your_status IS 'Indicates the status of the Sales Rep with this person. This is a user-defined popup with default name Your Status';
COMMENT ON COLUMN sa.table_con_opp_view.con_title IS 'Contact s title';
COMMENT ON COLUMN sa.table_con_opp_view.owner_objid IS ' Opportunity owner internal record number';
COMMENT ON COLUMN sa.table_con_opp_view.stage_objid IS 'Opportunity stage internal record number';
COMMENT ON COLUMN sa.table_con_opp_view.curr_objid IS 'Opportunity currency internal record number';
COMMENT ON COLUMN sa.table_con_opp_view.stage IS 'Status/Stage of opportunity';
COMMENT ON COLUMN sa.table_con_opp_view."OWNER" IS 'User login name of the opportunity owner';
COMMENT ON COLUMN sa.table_con_opp_view.currency IS 'Name of the currency the opportunity is denominated in';
COMMENT ON COLUMN sa.table_con_opp_view.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';