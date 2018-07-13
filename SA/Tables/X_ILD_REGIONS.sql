CREATE TABLE sa.x_ild_regions (
  region_name_english VARCHAR2(60 BYTE) NOT NULL,
  region_name_spanish VARCHAR2(60 BYTE),
  display_flag NUMBER(1) DEFAULT 0 NOT NULL CONSTRAINT chk_x_ild_regions CHECK (DISPLAY_FLAG IN ('1','0')),
  ild_region2bus_org NUMBER NOT NULL,
  transaction_date DATE DEFAULT sysdate,
  CONSTRAINT pk_x_ild_regions PRIMARY KEY (region_name_english,ild_region2bus_org)
);
COMMENT ON TABLE sa.x_ild_regions IS 'ILD REGIONS ';
COMMENT ON COLUMN sa.x_ild_regions.region_name_english IS 'Region Name in English';
COMMENT ON COLUMN sa.x_ild_regions.region_name_spanish IS 'Region Name in Spanish';
COMMENT ON COLUMN sa.x_ild_regions.display_flag IS 'Does ILD Region have calling available';
COMMENT ON COLUMN sa.x_ild_regions.ild_region2bus_org IS 'Bus org Objid';
COMMENT ON COLUMN sa.x_ild_regions.transaction_date IS 'Latest date Region was updated';