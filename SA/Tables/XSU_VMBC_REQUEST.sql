CREATE TABLE sa.xsu_vmbc_request (
  requesttype VARCHAR2(200 BYTE),
  requestid VARCHAR2(200 BYTE),
  enrollrequest VARCHAR2(200 BYTE),
  lid VARCHAR2(200 BYTE),
  contact VARCHAR2(200 BYTE),
  "NAME" VARCHAR2(200 BYTE),
  address VARCHAR2(200 BYTE),
  address2 VARCHAR2(200 BYTE),
  city VARCHAR2(200 BYTE),
  "STATE" VARCHAR2(200 BYTE),
  zip VARCHAR2(200 BYTE),
  zip2 VARCHAR2(200 BYTE),
  country VARCHAR2(200 BYTE),
  homenumber VARCHAR2(200 BYTE),
  email VARCHAR2(200 BYTE),
  allowprerecorded VARCHAR2(200 BYTE),
  emailpref VARCHAR2(200 BYTE),
  "APPLICATION" VARCHAR2(200 BYTE),
  applydate VARCHAR2(200 BYTE),
  esn VARCHAR2(200 BYTE),
  iscustomer VARCHAR2(200 BYTE),
  tracfonenumber VARCHAR2(200 BYTE),
  qualifystatus VARCHAR2(200 BYTE),
  qualifymethod VARCHAR2(200 BYTE),
  qualifytype VARCHAR2(200 BYTE),
  qualifyprograms VARCHAR2(800 BYTE),
  qualifydate VARCHAR2(200 BYTE),
  unqualifycode VARCHAR2(200 BYTE),
  retailercode VARCHAR2(200 BYTE),
  channeltype VARCHAR2(200 BYTE),
  bribeminutes VARCHAR2(200 BYTE),
  registrationlanguage VARCHAR2(200 BYTE),
  batchdate DATE,
  "PLAN" VARCHAR2(40 BYTE),
  ref_fname VARCHAR2(200 BYTE),
  ref_lname VARCHAR2(200 BYTE),
  ref_min VARCHAR2(200 BYTE),
  ref_lid VARCHAR2(200 BYTE),
  ref_status VARCHAR2(200 BYTE),
  external_account VARCHAR2(200 BYTE),
  x_campaign VARCHAR2(100 BYTE),
  x_promotion VARCHAR2(50 BYTE),
  x_promocode VARCHAR2(50 BYTE),
  x_shp_address VARCHAR2(50 BYTE),
  x_shp_address2 VARCHAR2(50 BYTE),
  x_shp_city VARCHAR2(50 BYTE),
  x_shp_state VARCHAR2(50 BYTE),
  x_shp_zip VARCHAR2(30 BYTE),
  addressiscommercial CHAR,
  addressisduplicated CHAR,
  addressisinvalid CHAR,
  addressistemporary CHAR,
  stateidname VARCHAR2(200 BYTE),
  stateidvalue VARCHAR2(200 BYTE),
  adl VARCHAR2(200 BYTE),
  usacform VARCHAR2(200 BYTE),
  celltelephone VARCHAR2(200 BYTE),
  eligiblefirstname VARCHAR2(200 BYTE),
  eligiblelastname VARCHAR2(200 BYTE),
  eligiblemiddlenameinitial VARCHAR2(200 BYTE),
  haspromotionalplan VARCHAR2(200 BYTE),
  hmodisclaimer CHAR,
  ipaddress VARCHAR2(200 BYTE),
  personid VARCHAR2(200 BYTE),
  personisinvalid CHAR,
  shippingaddresshash VARCHAR2(200 BYTE),
  stateagencyqualification CHAR,
  transferflag CHAR,
  old_lid VARCHAR2(200 BYTE),
  status VARCHAR2(200 BYTE),
  lastmodified VARCHAR2(200 BYTE),
  dobisinvalid CHAR,
  ssnisinvalid CHAR,
  disablemanualverification VARCHAR2(200 BYTE),
  device_type VARCHAR2(200 BYTE),
  byop_device_state VARCHAR2(200 BYTE),
  byop_carrier VARCHAR2(200 BYTE),
  byop_sim VARCHAR2(200 BYTE),
  byop_esn VARCHAR2(200 BYTE),
  byop_act_zip VARCHAR2(200 BYTE),
  data_source VARCHAR2(50 BYTE),
  job_data_id VARCHAR2(20 BYTE)
);
COMMENT ON COLUMN sa.xsu_vmbc_request.external_account IS 'SHORT NAME FOR HEALTH MAINTENANCE ORGANIZATION  (HMO)  CONCATENATED WITH HMO ACCOUNT NUMBER';
COMMENT ON COLUMN sa.xsu_vmbc_request.addressiscommercial IS 'Indicates if the Address is a Commercial Address ';
COMMENT ON COLUMN sa.xsu_vmbc_request.addressisduplicated IS 'Indicates if the Address in the Application Is Duplicated ';
COMMENT ON COLUMN sa.xsu_vmbc_request.addressisinvalid IS 'Indicates if the Address in the Application Is Invalid ';
COMMENT ON COLUMN sa.xsu_vmbc_request.addressistemporary IS 'Indicates if the Address is Temporary ';
COMMENT ON COLUMN sa.xsu_vmbc_request.stateidname IS 'Indicates if State ID name for the column STATEIDVALUE ';
COMMENT ON COLUMN sa.xsu_vmbc_request.stateidvalue IS 'Indicates if State ID Value for the column STATEIDNAME ';
COMMENT ON COLUMN sa.xsu_vmbc_request.adl IS 'Indicates ADL ';
COMMENT ON COLUMN sa.xsu_vmbc_request.usacform IS 'Indicates ADL ';
COMMENT ON COLUMN sa.xsu_vmbc_request.celltelephone IS 'Applicants previous Cell Phone (no SafeLink) ';
COMMENT ON COLUMN sa.xsu_vmbc_request.eligiblefirstname IS 'Eligible Persons First Name ';
COMMENT ON COLUMN sa.xsu_vmbc_request.eligiblelastname IS 'Eligible Persons Last Name ';
COMMENT ON COLUMN sa.xsu_vmbc_request.eligiblemiddlenameinitial IS 'Eligible Persons Middle Name Initial ';
COMMENT ON COLUMN sa.xsu_vmbc_request.haspromotionalplan IS 'Indicates if the Applicant will receive a Promotional Plan ';
COMMENT ON COLUMN sa.xsu_vmbc_request.hmodisclaimer IS 'Indicates if the Applicant accepted the HMO Disclaimer ';
COMMENT ON COLUMN sa.xsu_vmbc_request.ipaddress IS 'Applicants IP Address ';
COMMENT ON COLUMN sa.xsu_vmbc_request.personid IS 'Applicants Id ';
COMMENT ON COLUMN sa.xsu_vmbc_request.personisinvalid IS 'Indicated if the Applicant was deemed Invalid by NLAD ';
COMMENT ON COLUMN sa.xsu_vmbc_request.shippingaddresshash IS 'Shipping Address Id ';
COMMENT ON COLUMN sa.xsu_vmbc_request.stateagencyqualification IS 'Indicates if the Application was Qualified using a State Agency ';
COMMENT ON COLUMN sa.xsu_vmbc_request.transferflag IS 'Inticates if the customer will be Transferred insted of Enrolled in NLAD ';
COMMENT ON COLUMN sa.xsu_vmbc_request.old_lid IS 'Old Life Line ID ';
COMMENT ON COLUMN sa.xsu_vmbc_request.status IS 'Actual status name ';
COMMENT ON COLUMN sa.xsu_vmbc_request.lastmodified IS 'Applicantion Last Modification Date ';
COMMENT ON COLUMN sa.xsu_vmbc_request.dobisinvalid IS 'Indicates if the DOB in the Application Is Invalid ';
COMMENT ON COLUMN sa.xsu_vmbc_request.ssnisinvalid IS 'Indicates if the SSN in the Application Is Invalid ';
COMMENT ON COLUMN sa.xsu_vmbc_request.disablemanualverification IS 'Indicates if Manual Verification is Disabled for this Enrollment ';
COMMENT ON COLUMN sa.xsu_vmbc_request.device_type IS 'Indicates device type as HOME_PHONE, CELL, BYOP... ';
COMMENT ON COLUMN sa.xsu_vmbc_request.byop_device_state IS 'Determines if the Device the customer is going to bring is either Locked or Unlocked. ';
COMMENT ON COLUMN sa.xsu_vmbc_request.byop_carrier IS 'Determines what carrier is the phone that is going to be used compatible with. ';
COMMENT ON COLUMN sa.xsu_vmbc_request.byop_sim IS 'Determines what type of SIM is compatible with the phone intended to be used. ';
COMMENT ON COLUMN sa.xsu_vmbc_request.byop_esn IS 'Determines what is the ESN / IMEI / Serial Number of the phone intended to be used. ';
COMMENT ON COLUMN sa.xsu_vmbc_request.byop_act_zip IS 'Determines what ZIP code was entered via the service availability and preferred carrier (for GSM only) by the customer. ';
COMMENT ON COLUMN sa.xsu_vmbc_request.data_source IS 'Indicates data source as VMBC, SOLIX';