CREATE TABLE sa.x_metrics_failed_enrollment (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(30 BYTE),
  x_reason VARCHAR2(255 BYTE),
  enroll2pgm_enrolled NUMBER,
  enroll2contact NUMBER
);
ALTER TABLE sa.x_metrics_failed_enrollment ADD SUPPLEMENTAL LOG GROUP dmtsora467799141_0 (enroll2contact, enroll2pgm_enrolled, objid, x_esn, x_reason) ALWAYS;