CREATE TABLE sa.microsoftdtproperties (
  "ID" NUMBER NOT NULL CONSTRAINT microsoft_nn_id CHECK ("ID" IS NOT NULL),
  objectid NUMBER,
  property VARCHAR2(64 BYTE) NOT NULL CONSTRAINT microsoft_nn_property CHECK ("PROPERTY" IS NOT NULL),
  "VALUE" VARCHAR2(255 BYTE),
  lvalue LONG RAW,
  "VERSION" NUMBER DEFAULT (0) NOT NULL CONSTRAINT microsoft_nn_version CHECK ("VERSION" IS NOT NULL)
);
ALTER TABLE sa.microsoftdtproperties ADD SUPPLEMENTAL LOG GROUP dmtsora1668767055_0 ("ID", objectid, property, "VALUE", "VERSION") ALWAYS;