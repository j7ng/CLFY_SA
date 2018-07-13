CREATE TABLE sa.lacases_inport_queue (
  id_number VARCHAR2(255 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  title VARCHAR2(80 BYTE),
  creation_time DATE,
  "CONDITION" VARCHAR2(80 BYTE)
);
ALTER TABLE sa.lacases_inport_queue ADD SUPPLEMENTAL LOG GROUP dmtsora423333792_0 ("CONDITION", creation_time, id_number, title, x_esn, x_min) ALWAYS;