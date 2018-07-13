CREATE TABLE sa.email_status_update (
  esn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.email_status_update ADD SUPPLEMENTAL LOG GROUP dmtsora107965019_0 (esn) ALWAYS;