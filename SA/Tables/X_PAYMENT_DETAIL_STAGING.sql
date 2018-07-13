CREATE TABLE sa.x_payment_detail_staging (
  "ID" VARCHAR2(100 BYTE) NOT NULL,
  payment_details XMLTYPE,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_payment_detail_staging PRIMARY KEY ("ID")
);
COMMENT ON TABLE sa.x_payment_detail_staging IS 'Staging table to hold payment details';