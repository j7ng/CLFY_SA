CREATE OR REPLACE TYPE sa.ZIP_SCRIPT_REC_TYPE IS OBJECT
 ( ZIP_CODE VARCHAR2(10 BYTE)  -- Provided by caller
  ,FOOTER_TEXT VARCHAR2(4000 BYTE)  -- Populated by proc
  ,E911_TEXT VARCHAR2(4000 BYTE)  -- Populated by the proc
  ,RESULT NUMBER -- Populated by the proc
 )
/