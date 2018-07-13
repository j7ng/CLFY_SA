CREATE TABLE sa.table_prt_domain (
  objid NUMBER,
  "NAME" VARCHAR2(40 BYTE),
  description VARCHAR2(255 BYTE),
  serialno NUMBER,
  unique_sn NUMBER,
  catalogs NUMBER,
  boms NUMBER,
  at_site NUMBER,
  at_part NUMBER,
  at_domain NUMBER,
  pt_used_bom NUMBER,
  pt_used_dom NUMBER,
  pt_used_warn NUMBER,
  inc_domain VARCHAR2(40 BYTE),
  literature NUMBER,
  is_service NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_prt_domain ADD SUPPLEMENTAL LOG GROUP dmtsora2068928837_0 (at_domain, at_part, at_site, boms, catalogs, description, dev, inc_domain, is_service, literature, "NAME", objid, pt_used_bom, pt_used_dom, pt_used_warn, serialno, unique_sn) ALWAYS;
COMMENT ON TABLE sa.table_prt_domain IS 'Determines rules for parts, which govern; e.g.,  uniqueness of serial numbers, installation at sites, inclusion in BOM and catalogs';
COMMENT ON COLUMN sa.table_prt_domain.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_prt_domain."NAME" IS 'The name of the domain';
COMMENT ON COLUMN sa.table_prt_domain.description IS 'A description of the domain';
COMMENT ON COLUMN sa.table_prt_domain.serialno IS 'Degree of uniqueness of part serial number; i.e., 0=no serial numbers, tracked only by quantity, 1=unique serial numbers across all part numbers, 2=unique serial numbers only within a part number, 3=serial numbers don"t need to be unique';
COMMENT ON COLUMN sa.table_prt_domain.unique_sn IS 'For any given site, serial number must be unique for all part numbers; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.catalogs IS 'Allow parts in the domain to be included in catalogs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.boms IS 'Allow parts in the domain to be included in BOMs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.at_site IS 'Allow parts in the domain to be installed at the top level of the Site Configuration Manager; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.at_part IS 'Allow parts in the domain to be installed under other parts in the Site Configuration Manager; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.at_domain IS 'Restricts parts in the domain to be installed only under parts in the domain specified by inc_domain; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.pt_used_bom IS 'During parts used transactions, force part installation to conform to BOM; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.pt_used_dom IS 'Apply domain rules during parts-used transactions; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_prt_domain.pt_used_warn IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_prt_domain.inc_domain IS 'Parts with at_domain=1 can only be installed under parts in the domain in Site Configuration Manager';
COMMENT ON COLUMN sa.table_prt_domain.literature IS 'Indicates whether part is a literature part; 0=no, 1=yes. Marketing collateral is an example of a literature part';
COMMENT ON COLUMN sa.table_prt_domain.is_service IS 'Indicates the part is a service part, if selected, sit_prt_role will be set when installed; i.e., 0=not a service, 1=a service';
COMMENT ON COLUMN sa.table_prt_domain.dev IS 'Row version number for mobile distribution purposes';