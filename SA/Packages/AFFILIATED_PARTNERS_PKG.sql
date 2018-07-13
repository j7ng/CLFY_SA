CREATE OR REPLACE PACKAGE sa."AFFILIATED_PARTNERS_PKG" AS

/*************************************************************************************************************************************
 * $Revision: 1.12 $
 * $Author: sraman $
 * $Date: 2017/12/19 19:47:59 $
 * $Log: affiliated_partners_pkg.sql,v $
 * Revision 1.12  2017/12/19 19:47:59  sraman
 * Added new parameter i_web_user_objid
 *
 * Revision 1.11  2017/12/14 22:08:21  sraman
 * added new procedure p_get_emp_discount_name
 *
 * Revision 1.10  2017/05/04 18:10:36  tbaney
 * Merged 48169 and 48480.
 *
 * Revision 1.9  2017/05/02 15:59:00  mshah
 * CR48169 - Existing Customer on Auto-Refill for Affiliated Partner Discount
 *
  * Revision 1.6  2016/12/28 16:06:41  mshah
  * CR47013 - Add new fields First name and Last name
  *
  * Revision 1.5  2016/11/11 19:59:01  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.4  2016/11/08 16:16:06  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.3  2016/11/07 23:16:58  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.2  2016/11/07 17:49:15  mshah
  * CR44011 - Affiliated Partner Discount
  *
  *************************************************************************************************************************************/

--Created to validate partner, domain and partner code
PROCEDURE validate_partner
                          (
                           i_email         IN  VARCHAR2, --customers email
                           i_partner_code  IN  VARCHAR2, --partner code
                           i_emp_id        IN  VARCHAR2,
                           i_brand         IN  VARCHAR2 DEFAULT NULL,
                           i_firstName     IN  VARCHAR2, --47013
                           i_lastName      IN  VARCHAR2, --47013
                           o_token         OUT VARCHAR2, --unique token
                           o_status        OUT VARCHAR2, --VALID, INVALID
                           o_ref_id        OUT NUMBER,   --Aff. Partner OBJID
                           o_errcode       OUT VARCHAR2,
                           o_errmsg        OUT VARCHAR2
                          );

PROCEDURE ins_validate_emp
                          (
                           i_email        IN  VARCHAR2,
                           i_partner_code IN  VARCHAR2,
                           i_token        IN  VARCHAR2,
                           i_partner_name IN  VARCHAR2,
                           i_emp_id       IN  VARCHAR2,
                           i_brand        IN  VARCHAR2,
                           i_firstName    IN  VARCHAR2, --47013
                           i_lastName     IN  VARCHAR2, --47013
                           o_errcode      OUT VARCHAR2,
                           o_errmsg       OUT VARCHAR2
                           );

PROCEDURE validate_insert_employee_email
                                       (
                                        i_token        IN  VARCHAR2,
                                        o_email        OUT VARCHAR2,
                                        o_errcode      OUT VARCHAR2,
                                        o_errmsg       OUT VARCHAR2
                                        );

FUNCTION check_email_present
                            (
                            i_email        IN VARCHAR2,
                            i_partner_name IN VARCHAR2,
                            i_status       IN VARCHAR2,
                            i_partner_type IN VARCHAR2   -- CR48480
                            ) RETURN BOOLEAN  ;


PROCEDURE add_affpart_promo_to_cust(i_email   IN  table_x_employee_discount.login_name%TYPE,
                                    i_days    IN  NUMBER,
                                    o_errcode OUT NUMBER,
                                    o_errmsg  OUT VARCHAR2
                                    );

-- CR48480 changes starts..
--
-- Procedure to validated the partner for  MEMBER_ENROLL program
--
PROCEDURE p_validate_partner  ( i_partner_name    IN    VARCHAR2,
                                i_brand           IN    VARCHAR2,
                                i_partner_type    IN    VARCHAR2  DEFAULT 'MEMBER_ENROLL',
                                o_valid_partner   OUT   VARCHAR2,
                                o_err_code        OUT   VARCHAR2,
                                o_err_msg         OUT   VARCHAR2);
--
-- Commenting out new procedures, this is future use..
/*
-- Procedure to enroll customer into member signup program
--
PROCEDURE p_enroll_customer ( i_webuser_objid         IN    NUMBER,
                              i_login_name            IN    VARCHAR2,
                              i_brand                 IN    VARCHAR2,
                              i_partner_name          IN    VARCHAR2,
                              o_err_code              OUT   VARCHAR2,
                              o_err_msg               OUT   VARCHAR2);
--
-- Get partner attributes from table_affiliated_partners
--
PROCEDURE p_get_partner_attributes  ( i_partner_name    IN    VARCHAR2,
                                      i_brand           IN    VARCHAR2,
                                      i_partner_type    IN    VARCHAR2,
                                      o_partner_rec     OUT   SYS_REFCURSOR,
                                      o_err_code        OUT   VARCHAR2,
                                      o_err_msg         OUT   VARCHAR2);
--
-- Procedure to check whether ESN is enrolled for the program
--
PROCEDURE p_check_esn_enroll    (i_esn              IN    VARCHAR2,
                                 i_brand            IN    VARCHAR2,
                                 i_partner_name     IN    VARCHAR2  DEFAULT 'AMAZON_WEB_ORDERS',
                                 o_program_enroll   OUT   VARCHAR2,
                                 o_err_code         OUT   VARCHAR2,
                                 o_err_msg          OUT   VARCHAR2);
--
-- Procedure to check whether the web user is enrolled for the program
--
PROCEDURE p_check_user_enroll   ( i_login_name      IN    VARCHAR2,
                                  i_web_user_objid  IN    VARCHAR2,
                                  i_brand           IN    VARCHAR2,
                                  i_partner_name    IN    VARCHAR2  DEFAULT 'AMAZON_WEB_ORDERS',
                                  o_program_enroll  OUT   VARCHAR2,
                                  o_err_code        OUT   VARCHAR2,
                                  o_err_msg         OUT   VARCHAR2);
--
-- Procedure to check whether discount is eligible for the ESN
--
PROCEDURE p_check_discount_eligibile  (i_esn                  IN    VARCHAR2,
                                       i_brand                IN    VARCHAR2,
                                       i_partner_name         IN    VARCHAR2  DEFAULT 'AMAZON_WEB_ORDERS',
                                       o_dealer_name          OUT   VARCHAR2,
                                       o_discount_eligibile   OUT   VARCHAR2,
                                       o_err_code             OUT   VARCHAR2,
                                       o_err_msg              OUT   VARCHAR2);
--
*/
--
-- CR48480 changes ends.

---CR48260 SM MLD STARTS
PROCEDURE p_get_emp_discount_name  ( i_email           IN    VARCHAR2,
                                     i_brand           IN    VARCHAR2,
                                     i_webuser_objid   IN    NUMBER  ,
                                     o_discount_name   OUT   VARCHAR2,
                                     o_err_code        OUT   VARCHAR2,
                                     o_err_msg         OUT   VARCHAR2);
---CR48260 SM MLD ENDS
END affiliated_partners_pkg;
/