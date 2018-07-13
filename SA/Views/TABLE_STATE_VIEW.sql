CREATE OR REPLACE FORCE VIEW sa.table_state_view (objid,"NAME",s_name,code,defstate,country_objid,country,s_country,full_name) AS
select table_state_prov.objid, table_state_prov.name, table_state_prov.S_name,
 table_state_prov.code, table_state_prov.is_default,
 table_country.objid, table_country.name, table_country.S_name,
 table_state_prov.full_name
 from table_state_prov, table_country
 where table_country.objid (+) = table_state_prov.state_prov2country
 ;