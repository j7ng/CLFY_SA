CREATE TABLE sa.smp_vdm_paging_carrier_info (
  paging_server_name VARCHAR2(255 BYTE),
  paging_carrier_id NUMBER NOT NULL,
  paging_carrier_name VARCHAR2(128 BYTE) NOT NULL,
  paging_carrier_type NUMBER NOT NULL,
  paging_carrier_timeout NUMBER(10) NOT NULL,
  paging_carrier_conn_delay NUMBER(10) NOT NULL,
  paging_carrier_protocol VARCHAR2(128 BYTE),
  phone_country_code NUMBER(10) NOT NULL,
  phone_area_code NUMBER(10) NOT NULL,
  phone_number VARCHAR2(128 BYTE) NOT NULL,
  phone_number_suffix VARCHAR2(128 BYTE)
);
ALTER TABLE sa.smp_vdm_paging_carrier_info ADD SUPPLEMENTAL LOG GROUP dmtsora390357539_0 (paging_carrier_conn_delay, paging_carrier_id, paging_carrier_name, paging_carrier_protocol, paging_carrier_timeout, paging_carrier_type, paging_server_name, phone_area_code, phone_country_code, phone_number, phone_number_suffix) ALWAYS;