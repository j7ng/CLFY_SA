CREATE OR REPLACE FORCE VIEW sa.table_bus_site_ind (ind_objid,ind_name,s_ind_name,bus_objid,bus_name,s_bus_name,objid,role_name,site_objid,site_id,site_name,s_site_name) AS
select table_industry.objid, table_industry.name, table_industry.S_name,
 table_bus_org.objid, table_bus_org.name, table_bus_org.S_name,
 table_bus_site_role.objid, table_bus_site_role.role_name,
 table_site.objid, table_site.site_id,
 table_site.name, table_site.S_name
 from mtm_bus_org13_industry0, table_industry, table_bus_org, table_bus_site_role,
  table_site
 where table_bus_org.objid = mtm_bus_org13_industry0.bus_industry2industry
 AND mtm_bus_org13_industry0.bus_industry2bus_org = table_industry.objid 
 AND table_bus_org.objid = table_bus_site_role.bus_site_role2bus_org
 AND table_site.objid = table_bus_site_role.bus_site_role2site
 ;
COMMENT ON TABLE sa.table_bus_site_ind IS 'Retrieves Account, Site and Industry info. Used by forms Select Contact (SC) Quoted Part (9661), SC Installed Part (9662), SC (9663), SC for Campaign (9664) and SC by Industry (9667)';
COMMENT ON COLUMN sa.table_bus_site_ind.ind_objid IS 'Industry internal record number';
COMMENT ON COLUMN sa.table_bus_site_ind.ind_name IS 'Name of the industry';
COMMENT ON COLUMN sa.table_bus_site_ind.bus_objid IS 'Business organization internal record number';
COMMENT ON COLUMN sa.table_bus_site_ind.bus_name IS 'Business organization name';
COMMENT ON COLUMN sa.table_bus_site_ind.objid IS 'Business site role internal record number';
COMMENT ON COLUMN sa.table_bus_site_ind.role_name IS 'Business site role name';
COMMENT ON COLUMN sa.table_bus_site_ind.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_bus_site_ind.site_id IS 'Unique identifier of the site';
COMMENT ON COLUMN sa.table_bus_site_ind.site_name IS 'Name of the site';