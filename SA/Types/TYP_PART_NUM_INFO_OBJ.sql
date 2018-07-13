CREATE OR REPLACE TYPE sa.TYP_PART_NUM_INFO_OBJ AS OBJECT (
  PART_NUM_OBJID                        NUMBER
  ,PART_NUMBER                          VARCHAR2(30 BYTE)
  ,PART_NUM_DESCRIPTION                 VARCHAR2(255 BYTE)
  ,PART_NUM_DOMAIN                      VARCHAR2(40 BYTE)
  ,UNIT_VOICE                           NUMBER
  ,UNIT_DAYS                            NUMBER
  ,TRANS_VOICE                          NUMBER
  ,TRANS_TEXT                           NUMBER
  ,TRANS_DATA                           NUMBER
  ,TRANS_DAYS                           NUMBER
  ,SP_OBJID                             NUMBER
  ,SP_MKT_NAME                          VARCHAR2(50 BYTE)
  ,PART_CLASS_OBJID                     NUMBER
  ,PART_CLASS_NAME                      VARCHAR2(40 BYTE)
)
/