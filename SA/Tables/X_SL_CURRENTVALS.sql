CREATE TABLE sa.x_sl_currentvals (
  objid NUMBER,
  lid NUMBER,
  x_current_esn VARCHAR2(30 BYTE),
  x_current_active CHAR,
  x_current_enrolled CHAR,
  x_current_active_date DATE,
  x_current_enrolled_date DATE,
  x_current_ticket_id VARCHAR2(20 BYTE),
  x_current_shipped CHAR,
  x_current_pgm_start_date DATE,
  x_current_pe_id NUMBER,
  x_minutes_sent_dt DATE,
  x_minutes_delivered_dt DATE,
  x_minutes_received_dt DATE,
  x_deenroll_reason VARCHAR2(300 BYTE),
  x_invoice_reason VARCHAR2(200 BYTE),
  x_original_ship_date DATE,
  x_current_min VARCHAR2(30 BYTE),
  x_benefit_delvd_esn VARCHAR2(30 BYTE),
  x_benefit_delvd_min VARCHAR2(30 BYTE),
  x_benefit_delvd_pe_id NUMBER,
  x_benefit_delvd_carrier_id NUMBER(22),
  x_benefit_delvd_carrier_name VARCHAR2(30 BYTE),
  x_benefit_delvd_phone_status VARCHAR2(20 BYTE),
  x_benefit_delvd_act_zipcode VARCHAR2(20 BYTE),
  x_benefit_delvd_part_num VARCHAR2(30 BYTE),
  x_ship_address_1 VARCHAR2(200 BYTE),
  x_ship_address_2 VARCHAR2(200 BYTE),
  x_ship_city VARCHAR2(30 BYTE),
  x_ship_state VARCHAR2(60 BYTE),
  x_ship_zipcode VARCHAR2(60 BYTE),
  x_ship_date DATE,
  x_tracking_no VARCHAR2(30 BYTE),
  x_ota_status VARCHAR2(30 BYTE),
  x_ota_units NUMBER(22),
  x_firstcall_date TIMESTAMP,
  original_deenroll_reason VARCHAR2(400 BYTE)
);
COMMENT ON TABLE sa.x_sl_currentvals IS 'This table represent the current state for several parameters associated to Safe Link Services.  It summarize various pieces of data in a single table.';
COMMENT ON COLUMN sa.x_sl_currentvals.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_sl_currentvals.lid IS '3rd Party Customer ID';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_active IS 'Active Phone: Y.N';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_enrolled IS 'Phone Enrolled in SafeLink Plans: Y,N';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_active_date IS 'Activation Date for Current ESN';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_enrolled_date IS 'Enrollment Date for Current ESN';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_ticket_id IS 'Reference table_case, id_number';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_shipped IS 'Status Shipped?  Y,N';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_pgm_start_date IS 'Current Program Start Date';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_pe_id IS 'Reference to x_program_enrolled';
COMMENT ON COLUMN sa.x_sl_currentvals.x_minutes_sent_dt IS 'Latest date that minutes were sent';
COMMENT ON COLUMN sa.x_sl_currentvals.x_minutes_delivered_dt IS 'Latest date that minutes were delivered';
COMMENT ON COLUMN sa.x_sl_currentvals.x_minutes_received_dt IS 'Latest date that minutes were received';
COMMENT ON COLUMN sa.x_sl_currentvals.x_deenroll_reason IS 'Re-enrollment reason';
COMMENT ON COLUMN sa.x_sl_currentvals.x_invoice_reason IS 'Invoice Reason';
COMMENT ON COLUMN sa.x_sl_currentvals.x_original_ship_date IS 'Original Shipment Date';
COMMENT ON COLUMN sa.x_sl_currentvals.x_current_min IS 'LINE NUMBER/PHONE NUMBER';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_esn IS 'ESN AT BENEFITS DELIVERY TIME ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_min IS 'MIN AT BENEFITS DELIVERY TIME ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_pe_id IS 'OBJID RELATED WITH CUSTOMER PROGRAM ENROLLED AT BENEFITS DELIVERY TIME ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_carrier_id IS 'CARRIER ID AT BENEFITS DELIVERY TIME ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_carrier_name IS 'CARRIER NAME AT BENEFITS DELIVERY TIME ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_phone_status IS 'PHONE STATUS AT BENEFITS DELIVERY TIME ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_act_zipcode IS 'ZIP USED TO ACTIVATE PHONE ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_benefit_delvd_part_num IS 'BILLING PART NUMBER (AT BENEFITS DELIVERY TIME) ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ship_address_1 IS 'ADDRESS THAT PHONE WAS SHIPPED TO FROM THE TICKET ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ship_address_2 IS 'ADDRESS THAT PHONE WAS SHIPPED TO FROM THE TICKET ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ship_city IS 'CITY THAT PHONE WAS SHIPPED TO FROM THE TICKET ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ship_state IS 'STATE THAT PHONE WAS SHIPPED TO FROM THE TICKET ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ship_zipcode IS 'ZIPCODE THAT PHONE WAS SHIPPED TO FROM THE TICKET ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ship_date IS 'SHIPMENT DATE WHEN THAT PHONE WAS SHIPPED TO FROM THE TICKET ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_tracking_no IS 'TRACKING NUMBER TO ENSURE THAT PHONE WAS RECEIVED ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ota_status IS 'OTA PSMS TEXT STATUS RELATED UNITS DELIVERED';
COMMENT ON COLUMN sa.x_sl_currentvals.x_ota_units IS 'TOTAL UNITS DELIVERED OTA FROM AUDIT DEPT, INCLUDES ALL PROMO UNITS ';
COMMENT ON COLUMN sa.x_sl_currentvals.x_firstcall_date IS 'Indicates First Call Date ';