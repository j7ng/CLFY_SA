CREATE TABLE sa.table_x_amigo_pers (
  objid NUMBER,
  x_pid NUMBER,
  x_freenum1 VARCHAR2(20 BYTE),
  x_freenum2 VARCHAR2(20 BYTE),
  x_freenum3 VARCHAR2(20 BYTE),
  x_restrict_callop NUMBER,
  x_restrict_ld NUMBER,
  x_restrict_intl NUMBER,
  x_restrict_roam NUMBER,
  x_partner VARCHAR2(20 BYTE),
  x_favored VARCHAR2(20 BYTE),
  x_neutral VARCHAR2(20 BYTE),
  x_soc_id VARCHAR2(30 BYTE),
  x_amigo_pers2x_soc NUMBER
);
ALTER TABLE sa.table_x_amigo_pers ADD SUPPLEMENTAL LOG GROUP dmtsora110137499_0 (objid, x_amigo_pers2x_soc, x_favored, x_freenum1, x_freenum2, x_freenum3, x_neutral, x_partner, x_pid, x_restrict_callop, x_restrict_intl, x_restrict_ld, x_restrict_roam, x_soc_id) ALWAYS;