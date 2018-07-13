CREATE OR REPLACE FORCE VIEW sa.table_n_products (objid,n_itemid,n_templateid,n_optiontreeid,n_partnumber,s_n_partnumber,n_description,s_n_description,n_cost,n_imagefilename,n_modificationdate,n_revision,s_n_revision,n_partnumobjid,n_modlevelobjid,n_priceqtyobjid,n_priceqty,n_priceqtycontext,n_progname,s_n_progname,n_priceinstobjid,n_listprice,n_effectivedate,n_expirationdate,n_pricebookobjid,n_imageurl,n_domain,s_n_domain) AS
select table_N_Product.objid, table_N_Product.objid,
 table_N_Product.n_prod2N_Templates, table_N_Product.n_prod2N_CategoryTrees,
 table_part_num.part_number, table_part_num.S_part_number, table_part_num.description, table_part_num.S_description,
 table_N_Product.N_Cost, table_N_Product.N_ImageFileName,
 table_N_Product.N_ModificationDate, table_p_ml.mod_level, table_p_ml.S_mod_level,
 table_part_num.objid, table_p_ml.objid,
 table_price_qty.objid, table_price_qty.priced_qty,
 table_price_qty.context_part2mod_level, table_price_prog.name, table_price_prog.S_name,
 table_price_inst.objid, table_price_inst.price,
 table_price_inst.effective_date, table_price_inst.expire_date,
 table_price_prog.objid, table_N_Product.N_ImageURL,
 table_part_num.domain, table_part_num.S_domain
 from table_mod_level table_p_ml, table_N_Product, table_part_num, table_price_qty,
  table_price_prog, table_price_inst
 where table_price_qty.context_part2mod_level IS NOT NULL
 AND table_price_prog.objid = table_price_inst.price_inst2price_prog
 AND table_p_ml.objid = table_price_qty.priced_part2mod_level
 AND table_p_ml.objid = table_N_Product.N_Product2mod_level
 AND table_part_num.objid = table_p_ml.part_info2part_num
 AND table_price_qty.objid = table_price_inst.price_inst2price_qty
 ;