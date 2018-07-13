CREATE OR REPLACE FUNCTION sa.PsmsOK126cunix (ins IN pltosl, outs IN OUT sltopl)
   RETURN NUMBER
AS
   LANGUAGE c
   NAME "pl_ota_ok_126C"
   LIBRARY libpsms_ota
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