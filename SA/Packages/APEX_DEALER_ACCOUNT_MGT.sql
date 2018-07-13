CREATE OR REPLACE PACKAGE sa.apex_dealer_account_mgt AS
--
  TYPE split_tbl_ty IS TABLE OF VARCHAR2(500);
--
  PROCEDURE load_file (p_user  IN VARCHAR2, p_group IN VARCHAR2);
--
  PROCEDURE create_smob_users (
  ip_firstname          IN VARCHAR2,
  ip_lastname          IN VARCHAR2,
  ip_address_1           IN VARCHAR2,
  ip_address_2        IN VARCHAR2,
  ip_city                 IN VARCHAR2,
  ip_state               IN VARCHAR2,
  ip_zip                   IN VARCHAR2,
  ip_phone              IN VARCHAR2,
  ip_email               IN  VARCHAR2,
  ip_dob                 IN DATE,
  ip_title               IN VARCHAR2,
  ip_role                IN VARCHAR2,
  ip_prov_status   IN  VARCHAR2,
  ip_deal_phone     IN  VARCHAR2,
  ip_term_accept   IN  DATE,
  ip_ma                   IN VARCHAR2,
  ip_user                IN VARCHAR2,
  op_message         OUT   VARCHAR2);
--
  PROCEDURE reset_pwd (p_user IN VARCHAR2, p_login IN VARCHAR2, p_sd IN VARCHAR2, p_pin IN VARCHAR2, p_msg OUT VARCHAR2);
--
  PROCEDURE create_smob_user (p_user IN VARCHAR2);
--
  PROCEDURE create_smob_user_fraud (p_user IN VARCHAR2);
--
 END apex_dealer_account_mgt;
/