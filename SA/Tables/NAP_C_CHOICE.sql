CREATE TABLE sa.nap_c_choice (
  zip VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  given_line VARCHAR2(30 BYTE),
  choice VARCHAR2(30 BYTE),
  action_date DATE
);
ALTER TABLE sa.nap_c_choice ADD SUPPLEMENTAL LOG GROUP dmtsora743579415_0 (action_date, choice, esn, given_line, zip) ALWAYS;
COMMENT ON TABLE sa.nap_c_choice IS 'NAP_DIGITAL line assignment log';
COMMENT ON COLUMN sa.nap_c_choice.zip IS 'Zip Code';
COMMENT ON COLUMN sa.nap_c_choice.esn IS 'Phone Serial number';
COMMENT ON COLUMN sa.nap_c_choice.given_line IS 'Mobile Phone Number';
COMMENT ON COLUMN sa.nap_c_choice.choice IS 'Choice Level: A,B,C,D';
COMMENT ON COLUMN sa.nap_c_choice.action_date IS 'Timestamp';