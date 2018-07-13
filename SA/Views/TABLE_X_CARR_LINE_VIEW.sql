CREATE OR REPLACE FORCE VIEW sa.table_x_carr_line_view (line_objid,part_mod,part_serial_no,part_status,part_bin,warr_end_date,x_insert_date,x_sequence,x_creation_date,x_po_num,x_red_code,x_domain,x_deactivation_flag,x_reactivation_flag,x_cool_end_date,x_part_inst_status,x_npa,x_nxx,x_ext,carrier_objid,x_carrier_id,x_mkt_submkt_name,x_submkt_of,x_city,x_state,x_tapereturn_charge,x_country_code,x_activeline_percent,carrier_group_objid,x_carrier_group_id,x_carrier_name) AS
select table_part_inst.objid, table_part_inst.part_mod,
 table_part_inst.part_serial_no, table_part_inst.part_status,
 table_part_inst.part_bin, table_part_inst.warr_end_date,
 table_part_inst.x_insert_date, table_part_inst.x_sequence,
 table_part_inst.x_creation_date, table_part_inst.x_po_num,
 table_part_inst.x_red_code, table_part_inst.x_domain,
 table_part_inst.x_deactivation_flag, table_part_inst.x_reactivation_flag,
 table_part_inst.x_cool_end_date, table_part_inst.x_part_inst_status,
 table_part_inst.x_npa, table_part_inst.x_nxx,
 table_part_inst.x_ext, table_x_carrier.objid,
 table_x_carrier.x_carrier_id, table_x_carrier.x_mkt_submkt_name,
 table_x_carrier.x_submkt_of, table_x_carrier.x_city,
 table_x_carrier.x_state, table_x_carrier.x_tapereturn_charge,
 table_x_carrier.x_country_code, table_x_carrier.x_activeline_percent,
 table_x_carrier_group.objid, table_x_carrier_group.x_carrier_group_id,
 table_x_carrier_group.x_carrier_name
 from table_part_inst, table_x_carrier, table_x_carrier_group
 where table_x_carrier_group.objid = table_x_carrier.carrier2carrier_group
 AND table_x_carrier.objid = table_part_inst.part_inst2carrier_mkt (+)
 ;