CREATE OR REPLACE FORCE VIEW sa.table_x_line_manage_view (line_objid,warr_end_date,x_min,x_status,x_deactivation_flag,x_domain,x_npa,x_nxx,x_ext,x_cool_end_date,carrier_objid,x_carrier_id,x_mkt_submkt_name,carrier_group_objid,x_carrier_group_id,x_carrier_name,x_code_name,x_msid) AS
select "LINE_OBJID","WARR_END_DATE","X_MIN","X_STATUS","X_DEACTIVATION_FLAG","X_DOMAIN","X_NPA","X_NXX","X_EXT","X_COOL_END_DATE","CARRIER_OBJID","X_CARRIER_ID","X_MKT_SUBMKT_NAME","CARRIER_GROUP_OBJID","X_CARRIER_GROUP_ID","X_CARRIER_NAME","X_CODE_NAME","X_MSID"
from    (select /*+full[table_x_code_table]*/
                /*+first_rows[105]*/
                p.objid LINE_OBJID,
                p.warr_end_date WARR_END_DATE,
                p.part_serial_no X_MIN,
                p.x_part_inst_status X_STATUS,
                p.x_deactivation_flag X_DEACTIVATION_FLAG,
                p.x_domain X_DOMAIN,
                p.x_npa X_NPA,
                p.x_nxx X_NXX,
                p.x_ext X_EXT,
                p.x_cool_end_date X_COOL_END_DATE,
                c.objid CARRIER_OBJID,
                c.x_carrier_id X_CARRIER_ID,
                c.x_mkt_submkt_name X_MKT_SUBMKT_NAME,
                g.objid CARRIER_GROUP_OBJID,
                g.x_carrier_group_id X_CARRIER_GROUP_ID,
                g.x_carrier_name X_CARRIER_NAME,
                t.x_code_name X_CODE_NAME,
                p.x_msid X_MSID
         from   table_part_inst p,
                table_x_carrier c,
                table_x_carrier_group g,
                table_x_code_table t
         where  1=1
         and    c.objid = p.part_inst2carrier_mkt
         and    g.objid = c.carrier2carrier_group
         and    t.objid = p.status2x_code_table);