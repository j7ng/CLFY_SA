CREATE OR REPLACE FORCE VIEW sa.table_bus_opp_view (objid,role_name,bus_objid,bus_name,s_bus_name,opp_objid,"ACTIVE",role_type,comments,focus_type,products,close_date,amount,drop_date,drop_reason) AS
select table_bus_opp_role.objid, table_bus_opp_role.role_name,
 table_bus_org.objid, table_bus_org.name, table_bus_org.S_name,
 table_bus_opp_role.opp_role2opportunity, table_bus_opp_role.active,
 table_bus_opp_role.role_type, table_bus_opp_role.comments,
 table_bus_opp_role.focus_type, table_bus_opp_role.products,
 table_bus_opp_role.close_date, table_bus_opp_role.amount,
 table_bus_opp_role.drop_date, table_bus_opp_role.drop_reason
 from table_bus_opp_role, table_bus_org
 where table_bus_opp_role.opp_role2opportunity IS NOT NULL
 AND table_bus_org.objid = table_bus_opp_role.bus_role2bus_org
 ;
COMMENT ON TABLE sa.table_bus_opp_view IS 'Used by forms Opportunity (O) Detail (9601, 9630), Quote Call Scripts (9603), O Plan (9605), O Quotes (9606), O Competitive (9607), O Forecast (9608), O Influencer (9609) and My Clarify (12000)';
COMMENT ON COLUMN sa.table_bus_opp_view.objid IS 'Bus_opp_role internal record nubmer';
COMMENT ON COLUMN sa.table_bus_opp_view.role_name IS 'Name of the business opportunity role';
COMMENT ON COLUMN sa.table_bus_opp_view.bus_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_bus_opp_view.bus_name IS 'Business organization name';
COMMENT ON COLUMN sa.table_bus_opp_view.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_bus_opp_view."ACTIVE" IS 'Indicates whether the role is active; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_bus_opp_view.role_type IS 'Type of role for the opportunity; i.e., 0=partner, 1=competitor';
COMMENT ON COLUMN sa.table_bus_opp_view.comments IS 'Comments about the role';
COMMENT ON COLUMN sa.table_bus_opp_view.focus_type IS 'Object type ID of the role-player; i.e., 173=an business organizations s role, 5000=an opportunity s role';
COMMENT ON COLUMN sa.table_bus_opp_view.products IS 'Products this bus_org is trying to sell in this opportunity';
COMMENT ON COLUMN sa.table_bus_opp_view.close_date IS 'Attempted close date for the opportunity by the bus_org';
COMMENT ON COLUMN sa.table_bus_opp_view.amount IS 'Currenty amount the bus_org is trying to close in this opportunity';
COMMENT ON COLUMN sa.table_bus_opp_view.drop_date IS 'Date on which the bus_org dropped out of the opportunity';
COMMENT ON COLUMN sa.table_bus_opp_view.drop_reason IS 'Reason the bus_org left the opportunity';