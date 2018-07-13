CREATE OR REPLACE TYPE sa.mtg_source_type
AS OBJECT
(
    voice_mtg_source          VARCHAR2(50) ,
    sms_mtg_source            VARCHAR2(50) ,
    data_mtg_source           VARCHAR2(50) ,
    ild_mtg_source            VARCHAR2(50) ,
    bal_cfg_id_web            NUMBER,
    bal_cfg_id_ivr            NUMBER,
    mtg_nameval       	      Keys_Tbl,
    CONSTRUCTOR  FUNCTION mtg_source_type RETURN SELF AS  RESULT
);
/
CREATE OR REPLACE TYPE  BODY sa.mtg_source_type
IS
CONSTRUCTOR FUNCTION mtg_source_type RETURN SELF AS RESULT IS
BEGIN
   SELF.mtg_nameval   := Keys_Tbl();
   RETURN;
END;
END;
/