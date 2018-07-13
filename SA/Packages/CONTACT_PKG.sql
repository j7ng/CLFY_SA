CREATE OR REPLACE PACKAGE sa."CONTACT_PKG"
AS
/**********************************************************************************************/
/* */
/* Name : SA.CONTACT_PKG SPEC */
/* */
/* Purpose : Prepared for Exceeding demand for more information on our customers       */
/*                          replaces contact_prc procedures                                                                                           */
/*                                                                                            */
/* Platforms    :   Oracle 9i and above                                                       */
/*                                                                                            */
/* Author       :   NGuada                                                                    */
/*                                                                                            */
/* Date         :   08-28-2009                                                                */
/* REVISIONS:                                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     08/27/09                 Initial  Revision                                        */
/*   1.1     09/02/09                Latest                                                                                         */
/* 1.2      03/09/2011  kacosta      CR14767 Mobile Advertising Opt-In Option                 */
/*                                   Added the passing of the opt in option                   */
/* 1.3     05/04/2015  Kedar Parkhi  Added 2 new procedures sp_GetDeviceSummary and           */
/*                                   Sp_SetLanguagePref as part of CR33420.                   */
/**********************************************************************************************/
   PROCEDURE createcontact_prc (
      p_esn               IN       VARCHAR2,
      p_first_name        IN       VARCHAR2,
      p_last_name         IN       VARCHAR2,
      p_middle_name       IN       VARCHAR2,
      p_phone             IN       VARCHAR2,
      p_add1              IN       VARCHAR2,
      p_add2              IN       VARCHAR2,
      p_fax               IN       VARCHAR2,
      p_city              IN       VARCHAR2,
      p_st                IN       VARCHAR2,
      p_zip               IN       VARCHAR2,
      p_email             IN       VARCHAR2,
      p_email_status      IN       NUMBER,
      p_roadside_status   IN       NUMBER,
      p_no_name_flag      IN       NUMBER,
      p_no_phone_flag     IN       NUMBER,
      p_no_address_flag   IN       NUMBER,
      p_sourcesystem      IN       VARCHAR2,
      p_brand_name        IN       VARCHAR2,
      p_do_not_email      IN       NUMBER,
      p_do_not_phone      IN       NUMBER,
      p_do_not_mail       IN       NUMBER,
      p_do_not_sms        IN       NUMBER,
      p_ssn               IN       VARCHAR2,
      p_dob               IN       DATE,
      -- CR14767 Start kacosta 03/09/2011
      p_do_not_mobile_ads IN       NUMBER,
      -- CR14767 End kacosta 03/09/2011
      p_contact_objid     OUT      NUMBER,
      p_err_code          OUT      VARCHAR2,
      p_err_msg           OUT      VARCHAR2,
      p_add_info2web_user IN NUMBER DEFAULT NULL,  -- CR51354 Tim 9/21/17 Added four fields source_system, add_info2web_user, x_esn, x_min to table_x_contact_add_info
      p_min               IN VARCHAR2 DEFAULT NULL
   );
  PROCEDURE createcontact_prc
     (in_esn                 IN     VARCHAR2,
      in_first_name          IN     VARCHAR2,
      in_last_name           IN     VARCHAR2,
      in_middle_name         IN     VARCHAR2,
      in_phone               IN     VARCHAR2,
      in_shp_add1            IN     VARCHAR2,
      in_shp_add2            IN     VARCHAR2,
      in_shp_fax             IN     VARCHAR2,
      in_shp_city            IN     VARCHAR2,
      in_shp_st              IN     VARCHAR2,
      in_shp_zip             IN     VARCHAR2,
      in_bil_add1            IN     VARCHAR2,
      in_bil_add2            IN     VARCHAR2,
      in_bil_fax             IN     VARCHAR2,
      in_bil_city            IN     VARCHAR2,
      in_bil_st              IN     VARCHAR2,
      in_bil_zip             IN     VARCHAR2,
      in_email               IN     VARCHAR2,
      in_email_status        IN     NUMBER,
      in_roadside_status     IN     NUMBER,
      in_no_name_flag        IN     NUMBER,
      in_no_phone_flag       IN     NUMBER,
      in_no_address_flag     IN     NUMBER,
      in_sourcesystem        IN     VARCHAR2,
      in_brand_name          IN     VARCHAR2,
      in_do_not_email        IN     NUMBER,
      in_do_not_phone        IN     NUMBER,
      in_do_not_mail         IN     NUMBER,
      in_do_not_sms          IN     NUMBER,
      in_ssn                 IN     VARCHAR2,
      in_dob                 IN     DATE,
      in_do_not_mobile_ads   IN     NUMBER,
      out_contact_objid         OUT NUMBER,
      out_err_code              OUT VARCHAR2,
      out_err_msg               OUT VARCHAR2,
      in_add_info2web_user   IN     NUMBER   DEFAULT NULL,  -- CR51354 Tim 9/21/17 Added four fields source_system, add_info2web_user, x_esn, x_min to table_x_contact_add_info
      in_min                 IN     VARCHAR2 DEFAULT NULL);


PROCEDURE sp_GetDeviceSummary
(
	ip_MIN                IN varchar2,
	RESPONSE_CODE      OUT number,
	RESPONSE_MESSAGE   OUT varchar2,
	ESN                OUT varchar2,
	ESN_STATUS	      OUT varchar2,
	REPORTING_LINE     OUT varchar2,
	BRAND_NAME         OUT varchar2,
	CARRIER_ID         OUT number,
	CARRIER_NAME       OUT varchar2,
	IVR_PLAN_ID    	  OUT number,
	DEVICE_TYPE        OUT varchar2,
	LANG_PREF	      OUT varchar2,
	LANG_PREF_UPD_TIME    OUT date
);

PROCEDURE Sp_SetLanguagePref
(
    ip_MIN                IN varchar2,
    ip_LANG_PREF	      IN varchar2,
	RESPONSE_CODE      OUT number,
	RESPONSE_MESSAGE   OUT varchar2
);

--CR44729 Go Smart --Start
PROCEDURE updatecontact_prc
 (i_contact_objid     IN NUMBER  ,
  i_esn               IN VARCHAR2 ,
  i_first_name        IN VARCHAR2 ,
  i_last_name         IN VARCHAR2 ,
  i_middle_name       IN VARCHAR2 ,
  i_phone             IN VARCHAR2 ,
  i_add1              IN VARCHAR2 ,
  i_add2              IN VARCHAR2 ,
  i_fax               IN VARCHAR2 ,
  i_city              IN VARCHAR2 ,
  i_st                IN VARCHAR2 ,
  i_zip               IN VARCHAR2 ,
  i_email             IN VARCHAR2 ,
  i_email_status      IN NUMBER   ,
  i_roadside_status   IN NUMBER   ,
  i_no_name_flag      IN NUMBER   ,
  i_no_phone_flag     IN NUMBER   ,
  i_no_address_flag   IN NUMBER   ,
  i_sourcesystem      IN VARCHAR2 ,
  i_brand_name        IN VARCHAR2 ,
  i_do_not_email      IN NUMBER   ,
  i_do_not_phone      IN NUMBER   ,
  i_do_not_mail       IN NUMBER   ,
  i_do_not_sms        IN NUMBER   ,
  i_ssn               IN VARCHAR2 ,
  i_dob               IN DATE     ,
  i_do_not_mobile_ads IN NUMBER   ,
  o_err_code          OUT VARCHAR2,
  o_err_msg           OUT VARCHAR2
  );
--CR44729 Go Smart --End

--CR45761
procedure get_customer_contact_info	(ip_esn				VARCHAR2
					,op_x_do_not_email	OUT	VARCHAR2
					,op_x_do_not_phone	OUT	VARCHAR2
					,op_x_do_not_sms	OUT	VARCHAR2
					,op_x_do_not_mail	OUT	VARCHAR2
					,op_error_code		OUT	VARCHAR2
					,op_error_msg		OUT	VARCHAR2
					);
--CR45761

--CR47564 WFM --Start
PROCEDURE get_security_pin
 (i_min               IN VARCHAR2 ,
  i_esn               IN VARCHAR2,
  o_pin               OUT VARCHAR2,
  o_err_code          OUT VARCHAR2,
  o_err_msg           OUT VARCHAR2
  );
PROCEDURE update_security_pin
 (i_min               IN VARCHAR2 ,
  i_esn               IN VARCHAR2,
  i_pin               IN VARCHAR2 ,
  o_err_code          OUT VARCHAR2,
  o_err_msg           OUT VARCHAR2
  );
--CR47564 - New Overloading procedure createcontact_prc with security_pin as a new IN parameter --vidyasagar--
PROCEDURE createcontact_prc (p_esn                 IN VARCHAR2,
                             p_first_name          IN VARCHAR2,
                             p_last_name           IN VARCHAR2,
                             p_middle_name         IN VARCHAR2,
                             p_phone               IN VARCHAR2,
                             p_add1                IN VARCHAR2,
                             p_add2                IN VARCHAR2,
                             p_fax                 IN VARCHAR2,
                             p_city                IN VARCHAR2,
                             p_st                  IN VARCHAR2,
                             p_zip                 IN VARCHAR2,
                             p_email               IN VARCHAR2,
                             p_email_status        IN NUMBER,
                             p_roadside_status     IN NUMBER,
                             p_no_name_flag        IN NUMBER,
                             p_no_phone_flag       IN NUMBER,
                             p_no_address_flag     IN NUMBER,
                             p_sourcesystem        IN VARCHAR2,
                             p_brand_name          IN VARCHAR2,
                             p_do_not_email        IN NUMBER,
                             p_do_not_phone        IN NUMBER,
                             p_do_not_mail         IN NUMBER,
                             p_do_not_sms          IN NUMBER,
                             p_ssn                 IN VARCHAR2,
                             p_dob                 IN DATE, -- CR14767 Start kacosta 03/09/2011
                             p_do_not_mobile_ads   IN NUMBER, -- CR14767 End kacosta 03/09/2011
                             p_security_pin        IN VARCHAR2, -- CR47564
                             p_contact_objid       OUT NUMBER,
                             p_err_code            OUT VARCHAR2,
                             p_err_msg             OUT VARCHAR2
                            );
--CR47564 - End of Overloading procedure createcontact_prc with security_pin as a new IN parameter --vidyasagar--
-- CR47564 new function (was from trg_web_user2)
FUNCTION fn_get_social_media_links(p_wu_objid IN NUMBER)
RETURN VARCHAR2;
-- CR47564 new procedure to get min and security pin for the contact
PROCEDURE p_get_min_security_pin (i_web_user_objid      IN    NUMBER,
                                  i_web_user2bus_org    IN    NUMBER,
                                  i_min                 IN    VARCHAR2 DEFAULT NULL,
                                  i_esn                 IN    VARCHAR2 DEFAULT NULL,
                                  i_action              IN    VARCHAR2,
                                  o_min_contact_pin     OUT   VARCHAR2,
                                  o_mins                OUT   VARCHAR2,
                                  o_err_code            OUT   VARCHAR2,
                                  o_err_msg             OUT   VARCHAR2);
--
-- procedure that will be called from trigger on web user
PROCEDURE p_get_min_security_pin (i_web_user_objid      IN    NUMBER,
                                  i_web_user2bus_org    IN    NUMBER,
                                  i_web_contact         IN    NUMBER,
                                  i_action              IN    VARCHAR2,
                                  o_min_contact_pin     OUT   VARCHAR2,
                                  o_mins                OUT   VARCHAR2,
                                  o_err_code            OUT   VARCHAR2,
                                  o_err_msg             OUT   VARCHAR2);
--
PROCEDURE p_update_ldap ( i_esn               IN    VARCHAR2,
                          o_error_code        OUT   NUMBER,
                          o_error_msg         OUT   VARCHAR2);
--
PROCEDURE p_update_contact_pin  ( i_esn               IN    VARCHAR2,
                                  i_ig_order_type     IN    VARCHAR2,
                                  i_program_name      IN    VARCHAR2 DEFAULT  'SP_INSERT_IG_TRANSACTION',
                                  i_ig_status         IN    VARCHAR2,
                                  i_ig_transaction_id IN    VARCHAR2,
                                  o_error_code        OUT   NUMBER,
                                  o_error_msg         OUT   VARCHAR2);
--CR47564 WFM --End


-- CR52329_ST_WEB_Customize_Communication_Preference Tim 10/30/2017
-- get_customer_contact_info_tab

PROCEDURE upd_customer_contact_info_tab(io_customer_contact_info_tab IN OUT customer_contact_info_type_tab,
                                        o_error_code                    OUT VARCHAR2,
                                        error_msg                       OUT VARCHAR2
                                       );

-- CR52329_ST_WEB_Customize_Communication_Preference Tim 10/30/2017
-- get_customer_contact_info_tab

PROCEDURE get_customer_contact_info_tab(io_customer_contact_info_tab IN OUT customer_contact_info_type_tab,
                                        o_error_code                    OUT VARCHAR2,
                                        error_msg                       OUT VARCHAR2
                                       );




END contact_pkg;
/