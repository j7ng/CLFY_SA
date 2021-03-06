CREATE OR REPLACE FUNCTION sa.psmslg3280unix (ins IN pltosl, outs IN OUT sltopl)
   RETURN NUMBER
AS
   LANGUAGE c
   NAME "pl_ota_lg_3280"
   LIBRARY sa.libpsms_ota
   WITH CONTEXT
   PARAMETERS (
      CONTEXT,
      ins,
      ins INDICATOR struct,
      ins tdo,
      outs BY REFERENCE,
      outs INDICATOR struct,
      outs tdo,
      RETURN INDICATOR
   );
/