CREATE OR REPLACE FORCE VIEW sa.table_tr_filter_view (objid,extract_date,case_id,site_id,approved,district,s_district,region,s_region,bill_state,s_bill_state,prim_state,s_prim_state,ship_state,s_ship_state,bill_country,s_bill_country,prim_country,s_prim_country,ship_country,s_ship_country,site_name,s_site_name) AS
select table_trans_record.objid, table_trans_record.extract_date,
 table_case.id_number, table_c_site.site_id,
 table_trans_record.approved, table_c_site.district, table_c_site.S_district,
 table_c_site.region, table_c_site.S_region, table_bill_addr.state, table_bill_addr.S_state,
 table_prim_addr.state, table_prim_addr.S_state, table_ship_addr.state, table_ship_addr.S_state,
 table_bill_country.name, table_bill_country.S_name, table_prim_country.name, table_prim_country.S_name,
 table_ship_country.name, table_ship_country.S_name, table_c_site.name, table_c_site.S_name
 from table_address table_bill_addr, table_address table_prim_addr, table_address table_ship_addr, table_country table_bill_country, table_country table_prim_country, table_country table_ship_country, table_site table_c_site, table_trans_record, table_case
 where table_bill_country.objid = table_bill_addr.address2country
 AND table_bill_addr.objid = table_c_site.cust_billaddr2address
 AND table_ship_country.objid = table_ship_addr.address2country
 AND table_prim_country.objid = table_prim_addr.address2country
 AND table_case.objid = table_trans_record.trans_record2case
 AND table_c_site.objid = table_trans_record.trans_record2site
 AND table_ship_addr.objid = table_c_site.cust_shipaddr2address
 AND table_prim_addr.objid = table_c_site.cust_primaddr2address
 ;