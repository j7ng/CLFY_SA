CREATE OR REPLACE TYPE sa.bi_mtg_src_type
AS
OBJECT
(
  mtg_type                    VARCHAR2(50),
  mtg_src                     VARCHAR2(50),
  trans_id                    VARCHAR2(50),
  x_timeout_minutes_threshold NUMBER(22),
  x_daily_attempts_threshold  NUMBER(22),
  CONSTRUCTOR  FUNCTION bi_mtg_src_type RETURN SELF AS  RESULT
);
/