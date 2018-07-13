CREATE OR REPLACE TYPE sa.PINSTATUS_REC
IS
 object
  (
    SMP            VARCHAR2 (30 BYTE),
    STATUS         VARCHAR2  (50 BYTE)
    );
/