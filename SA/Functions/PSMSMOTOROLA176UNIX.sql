CREATE OR REPLACE FUNCTION sa.PSMSMotorola176Unix
   (
    INS  IN PLTOSL,
    OUTS  IN OUT SLTOPL
   )
   RETURN NUMBER
   AS
   LANGUAGE C
   NAME "pl_ota_motov176"
   LIBRARY sa.LIBPSMS_OTA
   WITH CONTEXT
   PARAMETERS
   (
    CONTEXT,
    INS,
    INS    INDICATOR STRUCT,
    INS    TDO,
    OUTS   BY REFERENCE,
    OUTS   INDICATOR STRUCT,
    OUTS   TDO,
    RETURN INDICATOR
     );
/