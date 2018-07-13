CREATE TABLE sa.x_payment_simulator (
  x_payment_number VARCHAR2(80 BYTE),
  x_ics_rcode NUMBER,
  x_ics_rflag VARCHAR2(30 BYTE),
  x_ics_rmsg VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_payment_simulator ADD SUPPLEMENTAL LOG GROUP dmtsora455207065_0 (x_ics_rcode, x_ics_rflag, x_ics_rmsg, x_payment_number) ALWAYS;