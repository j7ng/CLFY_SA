CREATE TABLE sa.x_part_num_hist (
  objid NUMBER,
  notes VARCHAR2(255 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  domain VARCHAR2(40 BYTE),
  s_domain VARCHAR2(40 BYTE),
  part_number VARCHAR2(30 BYTE),
  s_part_number VARCHAR2(30 BYTE),
  model_num VARCHAR2(20 BYTE),
  s_model_num VARCHAR2(20 BYTE),
  "ACTIVE" VARCHAR2(20 BYTE),
  std_warranty NUMBER,
  warr_start_key NUMBER,
  unit_measure VARCHAR2(8 BYTE),
  sn_track NUMBER,
  "FAMILY" VARCHAR2(20 BYTE),
  line VARCHAR2(20 BYTE),
  repair_type VARCHAR2(20 BYTE),
  part_type VARCHAR2(20 BYTE),
  weight VARCHAR2(20 BYTE),
  "DIMENSION" VARCHAR2(20 BYTE),
  dom_serialno NUMBER,
  dom_uniquesn NUMBER,
  dom_catalogs NUMBER,
  dom_boms NUMBER,
  dom_at_site NUMBER,
  dom_at_parts NUMBER,
  dom_at_domain NUMBER,
  dom_pt_used_bom NUMBER,
  dom_pt_used_dom NUMBER,
  dom_pt_used_warn NUMBER,
  incl_domain VARCHAR2(40 BYTE),
  is_sppt_prog NUMBER,
  prog_type NUMBER,
  dom_literature NUMBER,
  p_standalone NUMBER,
  p_as_parent NUMBER,
  p_as_child NUMBER,
  dom_is_service NUMBER,
  dev NUMBER,
  struct_type NUMBER,
  x_manufacturer VARCHAR2(20 BYTE),
  x_retailcost NUMBER(8,2),
  x_redeem_days NUMBER,
  x_redeem_units NUMBER,
  x_dll NUMBER,
  x_programmable_flag NUMBER,
  x_card_type VARCHAR2(20 BYTE),
  x_purch_qty NUMBER,
  x_purch_card NUMBER,
  x_technology VARCHAR2(20 BYTE),
  x_upc VARCHAR2(30 BYTE),
  x_web_description VARCHAR2(255 BYTE),
  x_display_seq NUMBER,
  x_web_card_desc VARCHAR2(100 BYTE),
  x_card_plan VARCHAR2(30 BYTE),
  x_wholesale_price NUMBER(8,2),
  x_sp_web_card_desc VARCHAR2(100 BYTE),
  x_product_code VARCHAR2(10 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_restricted_use NUMBER,
  x_cardless_bundle VARCHAR2(30 BYTE),
  part_num2part_class NUMBER,
  part_num2domain NUMBER,
  part_num2site NUMBER,
  x_exch_digital2part_num NUMBER,
  part_num2default_preload NUMBER,
  part_num2x_promotion NUMBER,
  x_extd_warranty NUMBER,
  x_ota_allowed VARCHAR2(10 BYTE),
  x_ota_dll VARCHAR2(10 BYTE),
  x_ild_type NUMBER,
  partnum_hist2part_num NUMBER,
  partnum_hist2user NUMBER,
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  triggering_record_type VARCHAR2(6 BYTE)
);
ALTER TABLE sa.x_part_num_hist ADD SUPPLEMENTAL LOG GROUP dmtsora504774621_0 ("ACTIVE", description, "DIMENSION", domain, dom_at_domain, dom_at_parts, dom_at_site, dom_boms, dom_catalogs, dom_pt_used_bom, dom_pt_used_dom, dom_pt_used_warn, dom_serialno, dom_uniquesn, "FAMILY", incl_domain, is_sppt_prog, line, model_num, notes, objid, part_number, part_type, repair_type, sn_track, std_warranty, s_description, s_domain, s_model_num, s_part_number, unit_measure, warr_start_key, weight) ALWAYS;
ALTER TABLE sa.x_part_num_hist ADD SUPPLEMENTAL LOG GROUP dmtsora504774621_1 (dev, dom_is_service, dom_literature, part_num2domain, part_num2part_class, part_num2site, prog_type, p_as_child, p_as_parent, p_standalone, struct_type, x_cardless_bundle, x_card_plan, x_card_type, x_display_seq, x_dll, x_exch_digital2part_num, x_manufacturer, x_product_code, x_programmable_flag, x_purch_card, x_purch_qty, x_redeem_days, x_redeem_units, x_restricted_use, x_retailcost, x_sourcesystem, x_sp_web_card_desc, x_technology, x_upc, x_web_card_desc, x_web_description, x_wholesale_price) ALWAYS;
ALTER TABLE sa.x_part_num_hist ADD SUPPLEMENTAL LOG GROUP dmtsora504774621_2 (osuser, partnum_hist2part_num, partnum_hist2user, part_num2default_preload, part_num2x_promotion, triggering_record_type, x_change_date, x_extd_warranty, x_ild_type, x_ota_allowed, x_ota_dll) ALWAYS;
ALTER TABLE sa.x_part_num_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1204878597_1 (dev, dom_is_service, dom_literature, part_num2domain, part_num2part_class, part_num2site, prog_type, p_as_child, p_as_parent, p_standalone, struct_type, x_cardless_bundle, x_card_plan, x_card_type, x_display_seq, x_dll, x_exch_digital2part_num, x_manufacturer, x_product_code, x_programmable_flag, x_purch_card, x_purch_qty, x_redeem_days, x_redeem_units, x_restricted_use, x_retailcost, x_sourcesystem, x_sp_web_card_desc, x_technology, x_upc, x_web_card_desc, x_web_description, x_wholesale_price) ALWAYS;
ALTER TABLE sa.x_part_num_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1204878597_2 (osuser, partnum_hist2part_num, partnum_hist2user, part_num2default_preload, part_num2x_promotion, triggering_record_type, x_change_date, x_extd_warranty, x_ild_type, x_ota_allowed, x_ota_dll) ALWAYS;
COMMENT ON TABLE sa.x_part_num_hist IS 'This table record all the changes performed on the table: table_part_num for audit purpouse.';
COMMENT ON COLUMN sa.x_part_num_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_part_num_hist.notes IS 'Comments about the part number';
COMMENT ON COLUMN sa.x_part_num_hist.description IS 'Description of the product';
COMMENT ON COLUMN sa.x_part_num_hist.s_description IS 'uppercase Description of the product';
COMMENT ON COLUMN sa.x_part_num_hist.domain IS 'Name of the domain for the part num. See object prt_domain';
COMMENT ON COLUMN sa.x_part_num_hist.s_domain IS 'uppercase Name of the domain for the part num. See object prt_domain';
COMMENT ON COLUMN sa.x_part_num_hist.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.x_part_num_hist.s_part_number IS 'uppercase Part number/name';
COMMENT ON COLUMN sa.x_part_num_hist.model_num IS 'Marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.x_part_num_hist.s_model_num IS 'uppercase Marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.x_part_num_hist."ACTIVE" IS 'Active/inactive/obsolete';
COMMENT ON COLUMN sa.x_part_num_hist.std_warranty IS 'Defines length of standard warranty for part';
COMMENT ON COLUMN sa.x_part_num_hist.warr_start_key IS 'Indicates whether warranty starts from shipment or installation';
COMMENT ON COLUMN sa.x_part_num_hist.unit_measure IS 'Unit of measure for part number; e.g., roll, set, etc';
COMMENT ON COLUMN sa.x_part_num_hist.sn_track IS 'Track part for serialization; i.e., 0=by quantity, 1=by serial number';
COMMENT ON COLUMN sa.x_part_num_hist."FAMILY" IS 'Marketing product family the part belongs to. This is a user-defined popup with default name FAMILY and level name lev1';
COMMENT ON COLUMN sa.x_part_num_hist.line IS 'Marketing product line, within family, of the part. This is a user-defined popup with default name FAMILY and level name lev2';
COMMENT ON COLUMN sa.x_part_num_hist.repair_type IS 'Shows whether the part is repairable or expendable';
COMMENT ON COLUMN sa.x_part_num_hist.part_type IS 'Assigns a part type (separate from a domain). This is from a user-defined popup with default name PART_TYPE';
COMMENT ON COLUMN sa.x_part_num_hist.weight IS 'Packaged weight of the part';
COMMENT ON COLUMN sa.x_part_num_hist."DIMENSION" IS 'Packaged dimensions of part';
COMMENT ON COLUMN sa.x_part_num_hist.dom_serialno IS 'Serial number s degree of uniqueness; i.e., 0=no serial numbers, tracked only by quantity, 1=unique across all part numbers, 2=unique within a part number, 3=not unique';
COMMENT ON COLUMN sa.x_part_num_hist.dom_uniquesn IS 'For any given site, serial number must be unique for all part numbers; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_catalogs IS 'Allow part to be included in BOMs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_boms IS 'Allow part to be included in BOMs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_at_site IS 'Part may be installed at either site or under another part.  0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_at_parts IS 'Domain allows parts to be installed under other parts in the Site Configuration Manager; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_at_domain IS 'Bin must be included in another domain?  0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_pt_used_bom IS 'During parts-used transactions, force part installation to conform to BOM; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_pt_used_dom IS 'Apply domain rules during parts-used transactions; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.x_part_num_hist.dom_pt_used_warn IS 'Warning for parts used';
COMMENT ON COLUMN sa.x_part_num_hist.incl_domain IS 'Domain of the part under which the current part must be installed. If empty, part may be installed directly under the site';
COMMENT ON COLUMN sa.x_part_num_hist.is_sppt_prog IS 'Indicates application category of the part: i.e., 0=physical part, 1=service part, 2=product literature';
COMMENT ON COLUMN sa.x_part_num_hist.prog_type IS 'If support program, indicates whether program is site-based or product-based; i.e., 0=product, 1=site, default=0. Reserved; not used';
COMMENT ON COLUMN sa.x_part_num_hist.dom_literature IS 'Indicates whether part is a literature part; 0=no, 1=yes. Marketing collateral is an example of a literature part';
COMMENT ON COLUMN sa.x_part_num_hist.p_standalone IS 'Indicates whether the part may receive standalone pricing;  i.e. 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.x_part_num_hist.p_as_parent IS 'Indicates whether the part may be priced with options under it;  i.e. 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.x_part_num_hist.p_as_child IS 'Indicates whether the part may be priced as an option;  i.e. 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.x_part_num_hist.dom_is_service IS 'Indicates the part is a service part, if selected, sit_prt_role will be set when installed; i.e., 0=not a service, 1=a service, default=0';
COMMENT ON COLUMN sa.x_part_num_hist.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.x_part_num_hist.struct_type IS 'The record type of the object; i.e., 0=service contract, 1=sales item, 2=eOrder, 3=shopping list';
COMMENT ON COLUMN sa.x_part_num_hist.x_manufacturer IS 'Manufacturer of the Part';
COMMENT ON COLUMN sa.x_part_num_hist.x_retailcost IS 'Retail Cost of the Part, Obsolete';
COMMENT ON COLUMN sa.x_part_num_hist.x_redeem_days IS 'Days for Redemption';
COMMENT ON COLUMN sa.x_part_num_hist.x_redeem_units IS 'Number of Units that can be redeemed';
COMMENT ON COLUMN sa.x_part_num_hist.x_dll IS 'DLL Code';
COMMENT ON COLUMN sa.x_part_num_hist.x_programmable_flag IS ' Flag that denote whether part is programmable';
COMMENT ON COLUMN sa.x_part_num_hist.x_card_type IS 'Annual Plan Card, ANNUAL';
COMMENT ON COLUMN sa.x_part_num_hist.x_purch_qty IS 'dummy field for form 1209; number of redcards customer wants to purchase';
COMMENT ON COLUMN sa.x_part_num_hist.x_purch_card IS '1 = this is an airtime redemption redcard customer can buy directly from Topp;  0 = not';
COMMENT ON COLUMN sa.x_part_num_hist.x_technology IS 'Holds the phone technology such as analog or digital';
COMMENT ON COLUMN sa.x_part_num_hist.x_upc IS 'UPC for Redemption Cards...Maybe ESN s in future';
COMMENT ON COLUMN sa.x_part_num_hist.x_web_description IS 'Description used by Web.';
COMMENT ON COLUMN sa.x_part_num_hist.x_display_seq IS 'Display sequence for the WEB';
COMMENT ON COLUMN sa.x_part_num_hist.x_web_card_desc IS 'Description used by Web.';
COMMENT ON COLUMN sa.x_part_num_hist.x_card_plan IS 'Plan the card gives access to';
COMMENT ON COLUMN sa.x_part_num_hist.x_wholesale_price IS 'Wholesale Cost of the Part';
COMMENT ON COLUMN sa.x_part_num_hist.x_sp_web_card_desc IS 'spanish description for the web';
COMMENT ON COLUMN sa.x_part_num_hist.x_product_code IS 'Brand Code as define by OFS';
COMMENT ON COLUMN sa.x_part_num_hist.x_sourcesystem IS 'Sourcesystem';
COMMENT ON COLUMN sa.x_part_num_hist.x_restricted_use IS 'Flag to determine if part has a restricted use.  0 = none, 1 = Amigo, 2 = TracFone Only';
COMMENT ON COLUMN sa.x_part_num_hist.x_cardless_bundle IS 'Cardless Bundled - Airtime Part Number associated';
COMMENT ON COLUMN sa.x_part_num_hist.part_num2part_class IS 'Reference to Part Class Objid';
COMMENT ON COLUMN sa.x_part_num_hist.part_num2domain IS 'Reference to domain table';
COMMENT ON COLUMN sa.x_part_num_hist.part_num2site IS 'Reference to Site Table';
COMMENT ON COLUMN sa.x_part_num_hist.x_exch_digital2part_num IS 'Self Reference, Obsolete';
COMMENT ON COLUMN sa.x_part_num_hist.part_num2default_preload IS 'Reference to default preload table, obsolete';
COMMENT ON COLUMN sa.x_part_num_hist.part_num2x_promotion IS 'Reference to table_x_promotion';
COMMENT ON COLUMN sa.x_part_num_hist.x_extd_warranty IS 'part Number is Candidate for Extended Warranty';
COMMENT ON COLUMN sa.x_part_num_hist.x_ota_allowed IS 'OTA allowed for that part number';
COMMENT ON COLUMN sa.x_part_num_hist.x_ota_dll IS 'OTA DLL';
COMMENT ON COLUMN sa.x_part_num_hist.x_ild_type IS 'ILD template for the ESN: 0, 1, 2';
COMMENT ON COLUMN sa.x_part_num_hist.x_change_date IS 'date for the record change';
COMMENT ON COLUMN sa.x_part_num_hist.osuser IS 'Operating System User that made the change';
COMMENT ON COLUMN sa.x_part_num_hist.triggering_record_type IS 'Type of action that trigger the record creation.';