CREATE OR REPLACE FUNCTION sa.PSMSMotorola170Unix(
                                        INS  in PLTOSL,
                                        OUTS  in out SLTOPL
                                   )
    RETURN NUMBER
    AS
    LANGUAGE C
    NAME "pl_ota_motov170"
    LIBRARY sa.LIBPSMS_OTA
    WITH CONTEXT
    PARAMETERS
     (
       CONTEXT,
       INS,
       INS INDICATOR STRUCT,
       INS TDO,
       OUTS BY REFERENCE,
       OUTS INDICATOR STRUCT,
       OUTS TDO,
       RETURN INDICATOR
     );
/