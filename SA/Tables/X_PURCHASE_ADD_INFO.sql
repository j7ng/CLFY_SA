CREATE TABLE sa.x_purchase_add_info (
  objid NUMBER,
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_created_on DATE,
  x_afs_reason_code VARCHAR2(50 BYTE),
  x_afs_result VARCHAR2(50 BYTE),
  x_hostserverity VARCHAR2(50 BYTE),
  x_consumer_local_time VARCHAR2(30 BYTE),
  x_afs_factor_code VARCHAR2(100 BYTE),
  x_addr_info_code VARCHAR2(100 BYTE),
  x_internet_info_code VARCHAR2(100 BYTE),
  x_suspicious_info_code VARCHAR2(100 BYTE),
  x_velocity_info_code VARCHAR2(100 BYTE),
  x_score_model_used VARCHAR2(100 BYTE),
  x_bin_country VARCHAR2(50 BYTE),
  x_card_scheme VARCHAR2(100 BYTE),
  x_device_fp_cookiesenabled VARCHAR2(30 BYTE),
  x_device_fp_flash_enabled VARCHAR2(30 BYTE),
  x_device_fp_images_enabled VARCHAR2(30 BYTE),
  x_device_fp_java_scrpt_enabled VARCHAR2(30 BYTE),
  x_device_fp_true_ip_address VARCHAR2(30 BYTE),
  x_device_fp_true_ip_addr_attbr VARCHAR2(100 BYTE),
  x_dav_reason_code VARCHAR2(50 BYTE),
  x_address_type VARCHAR2(30 BYTE),
  x_bar_code VARCHAR2(50 BYTE),
  x_barcode_checkdigit VARCHAR2(30 BYTE),
  x_match_score VARCHAR2(50 BYTE),
  x_std_addr VARCHAR2(100 BYTE),
  x_std_addr_noapt VARCHAR2(100 BYTE),
  x_std_city VARCHAR2(100 BYTE),
  x_std_county VARCHAR2(100 BYTE),
  x_std_csp VARCHAR2(100 BYTE),
  x_std_state VARCHAR2(50 BYTE),
  x_std_postal_code VARCHAR2(50 BYTE),
  x_std_country VARCHAR2(50 BYTE),
  x_std_iso_country VARCHAR2(50 BYTE),
  x_us_info VARCHAR2(50 BYTE)
);