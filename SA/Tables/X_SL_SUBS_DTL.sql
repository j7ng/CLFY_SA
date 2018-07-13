CREATE TABLE sa.x_sl_subs_dtl (
  lid NUMBER,
  x_addressiscommercial CHAR,
  x_addressisduplicated CHAR,
  x_addressisinvalid CHAR,
  x_addressistemporary CHAR,
  x_stateidname VARCHAR2(40 BYTE),
  x_stateidvalue VARCHAR2(40 BYTE),
  x_adl VARCHAR2(50 BYTE),
  x_usacform VARCHAR2(50 BYTE),
  x_celltelephone VARCHAR2(10 BYTE),
  x_eligiblefirstname VARCHAR2(50 BYTE),
  x_eligiblelastname VARCHAR2(50 BYTE),
  x_eligiblemiddlenameinitial VARCHAR2(50 BYTE),
  x_haspromotionalplan VARCHAR2(50 BYTE),
  x_hmodisclaimer CHAR,
  x_ipaddress VARCHAR2(30 BYTE),
  x_personid NUMBER,
  x_personisinvalid CHAR,
  x_shippingaddresshash VARCHAR2(30 BYTE),
  x_stateagencyqualification CHAR,
  x_transferflag CHAR,
  x_old_lid NUMBER,
  x_status VARCHAR2(30 BYTE),
  x_lastmodified VARCHAR2(50 BYTE),
  x_dobisinvalid CHAR,
  x_ssnisinvalid CHAR,
  x_disablemanualverification VARCHAR2(30 BYTE),
  x_qualify_type VARCHAR2(10 BYTE),
  x_qualify_programs VARCHAR2(800 BYTE),
  x_channel_type VARCHAR2(10 BYTE),
  x_language VARCHAR2(10 BYTE),
  x_byop_device_state VARCHAR2(100 BYTE),
  x_byop_carrier VARCHAR2(100 BYTE),
  x_byop_sim VARCHAR2(100 BYTE),
  x_byop_esn VARCHAR2(30 BYTE),
  x_byop_act_zip NUMBER
);
COMMENT ON COLUMN sa.x_sl_subs_dtl.lid IS '3rd Party Customer ID';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_addressiscommercial IS 'Indicates if the Address is a Commercial Address ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_addressisduplicated IS 'Indicates if the Address in the Application Is Duplicated ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_addressisinvalid IS 'Indicates if the Address in the Application Is Invalid ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_addressistemporary IS 'Indicates if the Address is Temporary ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_stateidname IS 'Indicates if State ID name for the column STATEIDVALUE ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_stateidvalue IS 'Indicates if State ID Value for the column STATEIDNAME ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_adl IS 'Indicates ADL ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_usacform IS 'Indicates ADL ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_celltelephone IS 'Applicants previous Cell Phone (no SafeLink) ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_eligiblefirstname IS 'Eligible Persons First Name ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_eligiblelastname IS 'Eligible Persons Last Name ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_eligiblemiddlenameinitial IS 'Eligible Persons Middle Name ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_haspromotionalplan IS 'Indicates if the Applicant will receive a Promotional Plan ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_hmodisclaimer IS 'Indicates if the Applicant accepted the HMO Disclaimer ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_ipaddress IS 'Applicants IP Address ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_personid IS 'Applicants Id ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_personisinvalid IS 'Indicated if the Applicant was deemed Invalid by NLAD ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_shippingaddresshash IS 'Shipping Address Id ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_stateagencyqualification IS 'Indicates if the Application was Qualified using a State Agency ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_transferflag IS 'Inticates if the customer will be Transferred instead of Enrolled in NLAD ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_old_lid IS 'Old Life Line ID ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_status IS 'Actual status name ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_lastmodified IS 'Applicantion Last Modification Date ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_dobisinvalid IS 'Indicates if the DOB in the Application Is Invalid ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_ssnisinvalid IS 'Indicates if the SSN in the Application Is Invalid ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_disablemanualverification IS 'Indicates if Manual Verification is Disabled for this Enrollment ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_qualify_type IS 'Indicates qualify type ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_qualify_programs IS 'Indicates program qualified ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_channel_type IS 'Indicates the channel type ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_language IS 'Indicates the language ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_byop_device_state IS 'Indicates the byop device state ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_byop_carrier IS 'Indicates the carrier like TMO, ATT.... ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_byop_sim IS 'Indicates SIM size like NANO, DUAL.... ';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_byop_esn IS 'Indicates  BYOP ESN';
COMMENT ON COLUMN sa.x_sl_subs_dtl.x_byop_act_zip IS 'Indicates BYOP_ACT_ZIP';