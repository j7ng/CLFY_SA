CREATE TABLE sa.x_comp_rules (
  ordr NUMBER,
  script VARCHAR2(100 BYTE),
  reason VARCHAR2(100 BYTE),
  detail VARCHAR2(100 BYTE),
  show_replacement NUMBER,
  require_description NUMBER
);
ALTER TABLE sa.x_comp_rules ADD SUPPLEMENTAL LOG GROUP dmtsora1939062212_0 (detail, ordr, reason, require_description, script, show_replacement) ALWAYS;