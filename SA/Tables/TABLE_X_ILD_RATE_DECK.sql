CREATE TABLE sa.table_x_ild_rate_deck (
  objid NUMBER,
  dev NUMBER,
  x_rate_deck VARCHAR2(10 BYTE),
  x_800_number VARCHAR2(30 BYTE),
  x_click_rate NUMBER(4,2)
);
ALTER TABLE sa.table_x_ild_rate_deck ADD SUPPLEMENTAL LOG GROUP dmtsora915886550_0 (dev, objid, x_800_number, x_click_rate, x_rate_deck) ALWAYS;
COMMENT ON TABLE sa.table_x_ild_rate_deck IS 'ILD Rate Deck';
COMMENT ON COLUMN sa.table_x_ild_rate_deck.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ild_rate_deck.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ild_rate_deck.x_rate_deck IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_rate_deck.x_800_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_rate_deck.x_click_rate IS 'TBD';