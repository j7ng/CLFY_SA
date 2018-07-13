CREATE TABLE sa.table_csc_admin (
  objid NUMBER,
  compliance_level NUMBER,
  document_status NUMBER,
  distribution NUMBER,
  language VARCHAR2(30 BYTE),
  copyright VARCHAR2(255 BYTE),
  disclaimer VARCHAR2(255 BYTE),
  rights VARCHAR2(255 BYTE),
  server_id NUMBER,
  dev NUMBER,
  problem2csc_problem NUMBER(*,0),
  solution2csc_solution NUMBER(*,0),
  admin2csc_statement NUMBER(*,0)
);
ALTER TABLE sa.table_csc_admin ADD SUPPLEMENTAL LOG GROUP dmtsora604234370_0 (admin2csc_statement, compliance_level, copyright, dev, disclaimer, distribution, document_status, language, objid, problem2csc_problem, rights, server_id, solution2csc_solution) ALWAYS;
COMMENT ON TABLE sa.table_csc_admin IS 'Each solution document has one ADMINISTRATIVE object. The ADMINISTRATIVE form includes objects that provide administrative information about an individual solution document';
COMMENT ON COLUMN sa.table_csc_admin.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_admin.compliance_level IS 'Level of compliance to the Solution Exchange Standard of this Solution document';
COMMENT ON COLUMN sa.table_csc_admin.document_status IS 'Completion level of this Solution document; i.e., 0=draft, 1=reviewed, 2=published. Default=0';
COMMENT ON COLUMN sa.table_csc_admin.distribution IS 'Intended distribution-audience for the Solution document; i.e., 0=proprietary, 1=internal, 2=partner, 3=public. Default=0';
COMMENT ON COLUMN sa.table_csc_admin.language IS 'Language of the content in the document (the English name of the language)';
COMMENT ON COLUMN sa.table_csc_admin.copyright IS 'Indicates all necessary copyright information';
COMMENT ON COLUMN sa.table_csc_admin.disclaimer IS 'Describes any disclaimer the owner has about the information';
COMMENT ON COLUMN sa.table_csc_admin.rights IS 'Describes any information about rights to the knowledge';
COMMENT ON COLUMN sa.table_csc_admin.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_admin.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_admin.problem2csc_problem IS 'Related CSC problem';
COMMENT ON COLUMN sa.table_csc_admin.solution2csc_solution IS 'Related CSC solution';
COMMENT ON COLUMN sa.table_csc_admin.admin2csc_statement IS 'Related CSC statement';