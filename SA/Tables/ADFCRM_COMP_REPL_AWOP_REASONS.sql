CREATE TABLE sa.adfcrm_comp_repl_awop_reasons (
  objid NUMBER NOT NULL,
  script VARCHAR2(100 BYTE) NOT NULL,
  reason VARCHAR2(100 BYTE) NOT NULL,
  flow VARCHAR2(100 BYTE) NOT NULL,
  brand_name VARCHAR2(100 BYTE) NOT NULL,
  CONSTRAINT adfcrm_comp_repl_awop_pk PRIMARY KEY (script,reason,flow,brand_name)
);
COMMENT ON TABLE sa.adfcrm_comp_repl_awop_reasons IS 'Reasons for Compensation, Replacement or Activation without payment (AWOP).';
COMMENT ON COLUMN sa.adfcrm_comp_repl_awop_reasons.objid IS 'Unique internal identifier';
COMMENT ON COLUMN sa.adfcrm_comp_repl_awop_reasons.script IS 'Script that describe the transaction.';
COMMENT ON COLUMN sa.adfcrm_comp_repl_awop_reasons.reason IS 'Reason that justify the transaction.';
COMMENT ON COLUMN sa.adfcrm_comp_repl_awop_reasons.flow IS 'Identify the flow; Compensation (COMP), Replacement (REPL) or Activation without payment (AWOP).';
COMMENT ON COLUMN sa.adfcrm_comp_repl_awop_reasons.brand_name IS 'Brand name for which applies the congiguration';