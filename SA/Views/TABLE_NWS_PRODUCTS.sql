CREATE OR REPLACE FORCE VIEW sa.table_nws_products (objid,n_templateid,n_optiontreeid,n_partnumber,s_n_partnumber,n_description,s_n_description,n_imagefilename,n_modificationdate,n_cost,n_partnumobjid,n_modlevelobjid,n_revision,s_n_revision,n_imageurl,n_domain,s_n_domain) AS
select table_n_p.objid, table_n_p.n_prod2N_Templates,
 table_n_p.n_prod2N_CategoryTrees, table_pn.part_number, table_pn.S_part_number,
 table_pn.description, table_pn.S_description, table_n_p.N_ImageFileName,
 table_n_p.N_ModificationDate, table_n_p.N_Cost,
 table_pn.objid, table_ml.objid,
 table_ml.mod_level, table_ml.S_mod_level, table_n_p.N_ImageURL,
 table_pn.domain, table_pn.S_domain
 from table_N_Product table_n_p, table_mod_level table_ml, table_part_num table_pn
 where table_ml.objid = table_n_p.N_Product2mod_level
 AND table_pn.objid = table_ml.part_info2part_num
 ;