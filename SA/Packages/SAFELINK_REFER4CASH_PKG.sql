CREATE OR REPLACE PACKAGE sa.SAFELINK_REFER4CASH_PKG
IS


    /*===============================================================================================*/
    /*                                                                                               */
    /* Purpose: Package to create and update customer information who enrolled                       */
    /*          in safelink customer referral program.                                               */
    /* REVISIONS  DATE       WHO            PURPOSE                                                  */
    /* --------------------------------------------------------------------------------------------- */
    /*            7/25/2013 MVadlapally  Initial                                                     */
    /*===============================================================================================*/

  PROCEDURE validate_email (
      in_login        IN     table_web_user.s_login_name%TYPE,
      out_ref_objid      OUT x_user_referrers.objid%TYPE,
      out_err_num        OUT NUMBER,
      out_err_msg        OUT VARCHAR2);

  PROCEDURE sp_safelink_validation (
      in_login_name        IN     table_web_user.login_name%TYPE,
      in_password          IN     table_web_user.password%TYPE,
      in_first_name        IN     table_contact.first_name%TYPE,
      in_last_name         IN     table_contact.last_name%TYPE,
      in_dob               IN     table_contact.x_dateofbirth%TYPE,
      out_user_ref_objid      OUT x_user_referrers.objid%TYPE,
      out_err_num             OUT NUMBER,
      out_err_msg             OUT VARCHAR2);

  PROCEDURE sp_create_referrer_acnt (
      in_login_name        IN     table_web_user.login_name%TYPE,
      in_password          IN     table_web_user.password%TYPE,
      in_first_name        IN     table_contact.first_name%TYPE,
      in_last_name         IN     table_contact.last_name%TYPE,
      in_phone_num         IN     table_contact.x_mobilenumber%TYPE,
      in_dob               IN     table_contact.x_dateofbirth%TYPE,
      in_secret_questn     IN     table_web_user.x_secret_questn%TYPE,
      in_secret_ans        IN     table_web_user.x_secret_ans%TYPE,
      in_brand_name        IN     table_bus_org.s_org_id%TYPE,
      in_client_status     IN     x_user_referrers.x_client_status%TYPE,
      in_bil_address1      IN     table_contact.address_1%TYPE,
      in_bil_address2      IN     table_contact.address_2%TYPE,
      in_bil_city          IN     table_contact.city%TYPE,
      in_bil_state         IN     table_contact.state%TYPE,
      in_bil_country       IN     table_contact.country%TYPE,
      in_bil_zip           IN     table_contact.zipcode%TYPE,
      in_shp_address1      IN     table_contact.address_1%TYPE,
      in_shp_address2      IN     table_contact.address_2%TYPE,
      in_shp_city          IN     table_contact.city%TYPE,
      in_shp_state         IN     table_contact.state%TYPE,
      in_shp_country       IN     table_contact.country%TYPE,
      in_shp_zip           IN     table_contact.zipcode%TYPE,
      out_user_ref_objid      OUT x_user_referrers.objid%TYPE,
      out_web_user_objid      OUT table_web_user.objid%TYPE,
      out_err_num             OUT NUMBER,
      out_err_msg             OUT VARCHAR2);

  PROCEDURE sp_update_referrer_acnt (
      in_user_ref_objid       IN     x_user_referrers.objid%TYPE,
      in_ref_id               IN     x_user_referrers.x_referrer_id%TYPE,
      in_ref_promo_code       IN     x_user_referrers.x_ref_promo_code%TYPE,
      in_cashcard_da          IN     x_user_referrers.x_cashcard_da%TYPE,
      in_cashcard_proxy       IN     x_user_referrers.x_cashcard_proxy%TYPE,
      in_cashcard_person_id   IN     x_user_referrers.x_cashcard_person_id%TYPE,
      in_client_acnt_id       IN     x_user_referrers.x_client_acnt_id%TYPE,
      in_client_acnt_num      IN     x_user_referrers.x_client_acnt_num%TYPE,
      in_client_status        IN     x_user_referrers.x_client_status%TYPE,
      in_valid                IN     x_user_referrers.x_validated%TYPE,
      in_payment_type         IN     x_user_referrers.x_payout_option%TYPE,
      out_err_num                OUT NUMBER,
      out_err_msg                OUT VARCHAR2);


  PROCEDURE sp_get_referrer_acnt_info (
      in_ref_id           IN       x_user_referrers.x_referrer_id%TYPE,
      in_client_acnt_id   IN       x_user_referrers.x_client_acnt_id%TYPE,
      in_client_acnt_num  IN       x_user_referrers.x_client_acnt_num%TYPE,
      in_cashcard_prsn_id IN       x_user_referrers.x_cashcard_person_id%TYPE,
      in_ref_promocode    IN       x_user_referrers.x_ref_promo_code%TYPE,
      in_loginid          IN       table_web_user.s_login_name%TYPE,
      in_pswd             IN       table_web_user.password%TYPE,
      in_brand            IN       table_bus_org.s_name%TYPE,
      out_ref_objid            OUT x_user_referrers.objid%TYPE,
      out_ref_id               OUT x_user_referrers.x_referrer_id%TYPE,
      out_program_id           OUT x_user_referrers.x_program_id%TYPE,
      out_ref_promo_code       OUT x_user_referrers.x_ref_promo_code%TYPE,
      out_cashcard_da          OUT x_user_referrers.x_cashcard_da%TYPE,
      out_cashcard_proxy       OUT x_user_referrers.x_cashcard_proxy%TYPE,
      out_cashcard_person_id   OUT x_user_referrers.x_cashcard_person_id%TYPE,
      out_client_acnt_id       OUT x_user_referrers.x_client_acnt_id%TYPE,
      out_client_acnt_num      OUT x_user_referrers.x_client_acnt_num%TYPE,
      out_client_status        OUT x_user_referrers.x_client_status%TYPE,
      out_valid                OUT x_user_referrers.x_validated%TYPE,
      out_payment_type         OUT x_user_referrers.x_payout_option%TYPE,
      out_fname                OUT table_contact.first_name%TYPE,
      out_lname                OUT table_contact.last_name%TYPE,
      out_email                OUT table_contact.e_mail%TYPE,
      out_phone_num            OUT table_contact.x_mobilenumber%TYPE,
      out_dob                  OUT table_contact.x_dateofbirth%TYPE,
      out_web_objid            OUT table_web_user.objid%TYPE,
      out_x_secret_questn      OUT table_web_user.x_secret_questn%TYPE,
      out_x_secret_ans         OUT table_web_user.x_secret_ans%TYPE,
      out_bil_address1         OUT table_contact.address_1%TYPE,
      out_bil_address2         OUT table_contact.address_2%TYPE,
      out_bil_city             OUT table_contact.city%TYPE,
      out_bil_state            OUT table_contact.state%TYPE,
      out_bil_country          OUT table_contact.country%TYPE,
      out_bil_zip              OUT table_contact.zipcode%TYPE,
      out_shp_address1         OUT table_contact.address_1%TYPE,
      out_shp_address2         OUT table_contact.address_2%TYPE,
      out_shp_city             OUT table_contact.city%TYPE,
      out_shp_state            OUT table_contact.state%TYPE,
      out_shp_country          OUT table_contact.country%TYPE,
      out_shp_zip              OUT table_contact.zipcode%TYPE,
      out_err_num              OUT NUMBER,
      out_err_msg              OUT VARCHAR2);

  PROCEDURE sp_upd_referrer_personal_info (
      in_web_objid         IN     table_web_user.objid%TYPE,

      in_current_email     IN     table_web_user.s_login_name%TYPE,
      in_brand_name        IN     table_bus_org.s_org_id%TYPE,

      in_new_email         IN     table_contact.e_mail%TYPE,
      in_new_pass          IN     table_web_user.password%TYPE,
      in_fname             IN     table_contact.first_name%TYPE,
      in_lname             IN     table_contact.last_name%TYPE,
      in_phone_num         IN     table_contact.x_mobilenumber%TYPE,
      in_dob               IN     table_contact.x_dateofbirth%TYPE,
      in_x_secret_questn   IN     table_web_user.x_secret_questn%TYPE,
      in_x_secret_ans      IN     table_web_user.x_secret_ans%TYPE,
      in_bil_address1      IN     table_contact.address_1%TYPE,
      in_bil_address2      IN     table_contact.address_2%TYPE,
      in_bil_city          IN     table_contact.city%TYPE,
      in_bil_state         IN     table_contact.state%TYPE,
      in_bil_country       IN     table_contact.country%TYPE,
      in_bil_zip           IN     table_contact.zipcode%TYPE,
      in_shp_address1      IN     table_contact.address_1%TYPE,
      in_shp_address2      IN     table_contact.address_2%TYPE,
      in_shp_city          IN     table_contact.city%TYPE,
      in_shp_state         IN     table_contact.state%TYPE,
      in_shp_country       IN     table_contact.country%TYPE,
      in_shp_zip           IN     table_contact.zipcode%TYPE,
      out_err_num             OUT NUMBER,
      out_err_msg             OUT VARCHAR2);


  FUNCTION get_client_status (in_login    table_web_user.s_login_name%TYPE,
                              in_brand    table_bus_org.s_org_id%TYPE)
      RETURN x_user_referrers.x_client_status%TYPE;
END;
/