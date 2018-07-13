CREATE OR REPLACE FUNCTION sa.PSMSSAMT401GUNIX (ins IN pltosl, outs IN OUT sltopl)
   RETURN NUMBER
AS
   LANGUAGE c
   NAME "pl_ota_sam_T401G"
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