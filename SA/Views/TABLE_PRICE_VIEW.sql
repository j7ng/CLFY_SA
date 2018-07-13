CREATE OR REPLACE FORCE VIEW sa.table_price_view (part_mod,price_inst,price_prog,"NAME",s_name,price,description,"TYPE",display,effective_date,expire_date,prog_eff_date,prog_exp_date) AS
select table_price_inst.price_inst2part_info, table_price_inst.objid,
 table_price_prog.objid, table_price_prog.name, table_price_prog.S_name,
 table_price_inst.price, table_price_prog.description,
 table_price_prog.type, table_price_prog.display,
 table_price_inst.effective_date, table_price_inst.expire_date,
 table_price_prog.effective_date, table_price_prog.expire_date
 from table_price_inst, table_price_prog
 where table_price_prog.objid = table_price_inst.price_inst2price_prog
 AND table_price_inst.price_inst2part_info IS NOT NULL
 ;
COMMENT ON TABLE sa.table_price_view IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_price_view.part_mod IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_price_view.price_inst IS 'Price instance internal record number';
COMMENT ON COLUMN sa.table_price_view.price_prog IS 'Price program internal record number';
COMMENT ON COLUMN sa.table_price_view."NAME" IS 'Name of the price program';
COMMENT ON COLUMN sa.table_price_view.price IS 'Price for a given product';
COMMENT ON COLUMN sa.table_price_view.description IS 'Description of the pricing program';
COMMENT ON COLUMN sa.table_price_view."TYPE" IS 'Price type; i.e., Standard Cost, Transfer Price, List Price, Repair Price, or Exchange Price';
COMMENT ON COLUMN sa.table_price_view.display IS 'If true, display pricing program in list box on parts look-up form';
COMMENT ON COLUMN sa.table_price_view.effective_date IS 'Date the price instance becomes effective';
COMMENT ON COLUMN sa.table_price_view.expire_date IS 'Last date the price instance is effective';
COMMENT ON COLUMN sa.table_price_view.prog_eff_date IS 'Date the price program becomes effective';
COMMENT ON COLUMN sa.table_price_view.prog_exp_date IS 'Last date the price program is effective';