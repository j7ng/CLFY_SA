CREATE TABLE sa.x_menu (
  orderby NUMBER,
  mkey VARCHAR2(100 BYTE),
  "CATEGORY" VARCHAR2(100 BYTE),
  lang VARCHAR2(50 BYTE),
  description VARCHAR2(300 BYTE),
  netcsr VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  webcsr VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  ivr VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  web VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  netweb VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  netivr VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  manufpartclass VARCHAR2(50 BYTE)
);
ALTER TABLE sa.x_menu ADD SUPPLEMENTAL LOG GROUP dmtsora1169030196_0 ("CATEGORY", description, ivr, lang, manufpartclass, mkey, netcsr, netivr, netweb, orderby, web, webcsr) ALWAYS;