CREATE OR REPLACE FORCE VIEW sa.table_x_carr_srch_view (carrier_objid,x_carrier_id,x_mkt_submkt_name,x_submkt_of,x_city,x_state,x_tapereturn_charge,x_country_code,x_activeline_percent,carrier_group_objid,x_carrier_group_id,x_carrier_name,x_group_status,x_carrier_status,x_parent_objid,x_parent_x_parent_name,x_parent_x_parent_id,x_parent_x_status) AS
select table_x_carrier.objid, table_x_carrier.x_carrier_id,
 table_x_carrier.x_mkt_submkt_name, table_x_carrier.x_submkt_of,
 table_x_carrier.x_city, table_x_carrier.x_state,
 table_x_carrier.x_tapereturn_charge, table_x_carrier.x_country_code,
 table_x_carrier.x_activeline_percent, table_x_carrier_group.objid,
 table_x_carrier_group.x_carrier_group_id, table_x_carrier_group.x_carrier_name,
 table_x_carrier_group.x_status, table_x_carrier.x_status,
 table_x_parent.objid, table_x_parent.x_parent_name,
 table_x_parent.x_parent_id, table_x_parent.x_status
 from table_x_carrier, table_x_carrier_group, table_x_parent
 where table_x_parent.objid (+) = table_x_carrier_group.x_carrier_group2x_parent
 AND table_x_carrier_group.objid = table_x_carrier.carrier2carrier_group
 ;
COMMENT ON TABLE sa.table_x_carr_srch_view IS 'Used by Carrier Search Screen; FORM #1130';
COMMENT ON COLUMN sa.table_x_carr_srch_view.carrier_objid IS 'Carrier internal record number';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_carrier_id IS 'Carrier market ID number';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_mkt_submkt_name IS 'Carrier market name';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_submkt_of IS 'Parent market to current market';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_city IS 'Market coverage city';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_state IS 'Market coverage state';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_tapereturn_charge IS 'Market tape return charge';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_country_code IS 'Market country code';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_activeline_percent IS 'Market active line percent';
COMMENT ON COLUMN sa.table_x_carr_srch_view.carrier_group_objid IS 'Carrier group internal record number';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_carrier_group_id IS 'Carrier group ID number';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_carrier_name IS 'Carrier group name';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_group_status IS ' ACTIVE or INACTIVE';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_carrier_status IS ' ACTIVE or INACTIVE';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_parent_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_parent_x_parent_name IS 'Name of carrier parent';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_parent_x_parent_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_carr_srch_view.x_parent_x_status IS 'TBD';