CREATE OR REPLACE TYPE sa.bi_mtg_trans_type
AS
OBJECT
(
  objid                       NUMBER(22) ,
  esn                         VARCHAR2(30) ,
  inquiry_type                VARCHAR2(100) ,
  mtg_src_tab                 bi_mtg_src_tab,
  trans_creation_date         DATE,
  CONSTRUCTOR  FUNCTION bi_mtg_trans_type RETURN SELF AS  RESULT
);
/