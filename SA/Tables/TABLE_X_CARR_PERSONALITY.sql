CREATE TABLE sa.table_x_carr_personality (
  objid NUMBER,
  x_freenum1 VARCHAR2(20 BYTE),
  x_freenum2 VARCHAR2(20 BYTE),
  x_freenum3 VARCHAR2(20 BYTE),
  x_pid NUMBER,
  x_restrict_ld NUMBER,
  x_restrict_callop NUMBER,
  x_restrict_intl NUMBER,
  x_restrict_roam NUMBER,
  x_favored VARCHAR2(20 BYTE),
  x_neutral VARCHAR2(20 BYTE),
  x_partner VARCHAR2(20 BYTE),
  x_soc_id VARCHAR2(30 BYTE),
  x_carr_personality2x_soc NUMBER,
  x_restrict_inbound NUMBER,
  x_restrict_outbound NUMBER
);
ALTER TABLE sa.table_x_carr_personality ADD SUPPLEMENTAL LOG GROUP dmtsora495166031_0 (objid, x_carr_personality2x_soc, x_favored, x_freenum1, x_freenum2, x_freenum3, x_neutral, x_partner, x_pid, x_restrict_callop, x_restrict_inbound, x_restrict_intl, x_restrict_ld, x_restrict_outbound, x_restrict_roam, x_soc_id) ALWAYS;
COMMENT ON TABLE sa.table_x_carr_personality IS 'Stores all the carrier personality information';
COMMENT ON COLUMN sa.table_x_carr_personality.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carr_personality.x_freenum1 IS 'Free Numbers for the Carrier Market';
COMMENT ON COLUMN sa.table_x_carr_personality.x_freenum2 IS 'Free Numbers for the Carrier Market';
COMMENT ON COLUMN sa.table_x_carr_personality.x_freenum3 IS 'Free Numbers for the Carrier Market';
COMMENT ON COLUMN sa.table_x_carr_personality.x_pid IS 'Personality Id';
COMMENT ON COLUMN sa.table_x_carr_personality.x_restrict_ld IS 'Flag that shows whether the customer can call Long Distance: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_carr_personality.x_restrict_callop IS 'Flag that denotes whether the customer can call the operator: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_carr_personality.x_restrict_intl IS 'Flag that shows whether the customer can call international: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_carr_personality.x_restrict_roam IS 'Flag that shows whether the customer can call roaming: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_carr_personality.x_favored IS 'Favored tag for TDMA technology such as tracfone or roam';
COMMENT ON COLUMN sa.table_x_carr_personality.x_neutral IS 'Neutral tag for TDMA technology such as tracfone or roam';
COMMENT ON COLUMN sa.table_x_carr_personality.x_partner IS 'Partner tag for TDMA technology such as tracfone or roam';
COMMENT ON COLUMN sa.table_x_carr_personality.x_soc_id IS 'SOC Id';
COMMENT ON COLUMN sa.table_x_carr_personality.x_carr_personality2x_soc IS 'SOC for the carrier personality';
COMMENT ON COLUMN sa.table_x_carr_personality.x_restrict_inbound IS 'Flag that shows whether there is any restriction on incoming calls: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_carr_personality.x_restrict_outbound IS 'Flag that shows whether there is any restriction on outbound calls: 0=no, 1=yes';