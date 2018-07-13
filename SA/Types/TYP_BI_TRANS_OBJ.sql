CREATE OR REPLACE TYPE sa.typ_bi_trans_obj
as
  object
  (
    objid                       NUMBER(22) ,
    esn                         VARCHAR2(30) ,
    voice_mtg_source            VARCHAR2(50),
    voice_trans_id              VARCHAR2(50) ,
    text_mtg_source             VARCHAR2(50),
    text_trans_id               VARCHAR2(50),
    data_mtg_source             VARCHAR2(50),
    data_trans_id               VARCHAR2(50),
    ild_mtg_source              VARCHAR2(50),
    ild_trans_id                VARCHAR2(50),
    trans_creation_date         DATE ,
    X_TIMEOUT_MINUTES_THRESHOLD NUMBER(22),
    X_DAILY_ATTEMPTS_THRESHOLD  NUMBER(22)
  );
/