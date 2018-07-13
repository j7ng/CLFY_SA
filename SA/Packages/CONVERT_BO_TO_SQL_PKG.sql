CREATE OR REPLACE PACKAGE sa."CONVERT_BO_TO_SQL_PKG"


AS
/*****************************************************************
  * Package Name: convert_bo_to_sql_pkg
  * Purpose     : To convert CBO methods to PLSQL procedures - Memory Leak Project
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Vani Adapa
  * Date        : 10/21/2005
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE          WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0      10/21/2005    VAdapa     Initial Revision (CR4640)
  *              1.1      10/21/2005    GPintado    Added extra parameter sp_create_call_trans
  *             1.2    10/29/2005   VAdapa      Added header information
  *             1.3    11/07/2005   CL/VA    More functions/procedures
  *            1.4      11/21/2005  CL / VA   Modified CREATESITEPART procedure
  *            1.5      11/30/2005  CL / VA    Modified SP_CREATE_CALL_TRANS (added a new IN parameter)
  *            1.6      11/30/2005  VA          Checked in with the correct code and revision
  *            1.7      12/01/2005  VA       Created a replica of SP_CREATE_CALL_TRANS procedure with more parameters
  *            1.8      03/16/06 VA     CR4811
  *            1.9/1.10  04/11/06   IC     CR4981_4982 changes
  *            1.11      05/17/06   VA     Same version as in CLFYUPGQ
  *            1.12 /1.13 09/11/06   VA    CR5581/CR5582 -Bundle for Wal-mart / SAM's
  *            1.14      02/23/07   NG    CR5848 Clear Red Card Default Boolean
  *            1.15      06/06/07    IC      CR5728 Check if Activation promotion was used in an ESN exchange case
  *
  *            1.0      10/27/08    YM     CR7984 added new procedure getdefaultpromo_new
  *            1.2      02/17/09   ICANAVAN  MERGE
  *            1.3      02/17/09   CR8507 sbabu   TF_REL_35. CompleteTranasaction cbo removal.
  *            1.4      08/27/09   NGuada BRAND_SEP Separate the Brand and Source System
  *            1.5      07/14/10  YM CR13940 add new input parameters in sp_create_call_trans_2
  ************************************************************************/
   FUNCTION checkmemberesn (p_esn IN VARCHAR2)
      RETURN VARCHAR2;

   --
   PROCEDURE dynamicenrollment (p_esn IN VARCHAR2, p_source_system IN VARCHAR2);

   --
--    PROCEDURE createsitepart (
--       p_min          IN   VARCHAR2,
--       p_esn          IN   VARCHAR2,
--       p_site_objid   IN   NUMBER,
--       p_expdate           DATE,
--       p_pin               VARCHAR2,
--       p_zipcode           VARCHAR2
--    );
   PROCEDURE createsitepart (
      p_min               IN       VARCHAR2,
      p_esn               IN       VARCHAR2,
      p_site_objid        IN       NUMBER,
      p_expdate           IN       DATE,
      p_pin               IN       VARCHAR2,
      p_zipcode           IN       VARCHAR2,
      p_site_part_objid   OUT      NUMBER,
      p_errorcode         OUT      VARCHAR2,
      p_errormessage      OUT      VARCHAR2
   );

   --
   PROCEDURE preprocess_redem_cards (
      p_esn               IN       VARCHAR2,
      p_cards             IN       VARCHAR2,
      p_isota             IN       VARCHAR2,
      p_annual_plan       OUT      NUMBER,
      p_total_units       OUT      NUMBER,
      p_redeem_days       OUT      NUMBER,
      p_errorcode         OUT      VARCHAR2,
      p_errormessage      OUT      VARCHAR2,
      p_conversion_rate   OUT      NUMBER                       --CR4981_4982
   );



   --

   FUNCTION minacchange (
      p_site_part_objid   NUMBER,
      p_sourcesystem      VARCHAR2,
      p_brand_name        VARCHAR2
   )
      RETURN BOOLEAN;

   --
   PROCEDURE acceptruntimepromo (p_part_inst_objid NUMBER);

   --
   PROCEDURE failruntimepromo (
      p_site_part_objid   NUMBER,
      p_part_inst_objid   NUMBER
   );

   --
   PROCEDURE otacompletetransaction (
      p_esn                        VARCHAR2,
      p_call_trans_objid           NUMBER,
      p_min                        VARCHAR2,
      p_num_codes_accepted         NUMBER,
      p_brand_name                 VARCHAR2,
      p_errorcode            OUT   VARCHAR2,
      p_errormessage         OUT   VARCHAR2
   );

   --
   PROCEDURE sp_create_call_trans (
      ip_esn            IN       VARCHAR2,
      ip_action_type    IN       VARCHAR2,
      ip_sourcesystem   IN       VARCHAR2,
      ip_brand_name     IN       VARCHAR2,
      ip_reason         IN       VARCHAR2,
      ip_result         IN       VARCHAR2,
      ip_ota_req_type   IN       VARCHAR2,
      ip_ota_type       IN       VARCHAR2,
      ip_total_units    IN       NUMBER,
      op_calltranobj    OUT      NUMBER,
      op_err_code       OUT      VARCHAR2,
      op_err_msg        OUT      VARCHAR2
   );

   PROCEDURE sp_create_call_trans_2 (
      ip_esn                IN       VARCHAR2,
      ip_action_type        IN       VARCHAR2,
      ip_sourcesystem       IN       VARCHAR2,
      ip_brand_name         IN       VARCHAR2,
      ip_reason             IN       VARCHAR2,
      ip_result             IN       VARCHAR2,
      ip_ota_req_type       IN       VARCHAR2,
      ip_ota_type           IN       VARCHAR2,
      ip_total_units        IN       NUMBER,
      ip_orig_login_objid   IN       NUMBER,
      ip_action_text        IN       VARCHAR2, --CR13940
      op_calltranobj        OUT      NUMBER,
      op_err_code           OUT      VARCHAR2,
      op_err_msg            OUT      VARCHAR2
   );

--Function Overloaded, Do not modify
   FUNCTION get_default_click_plan (
      p_dll              IN   NUMBER,
      p_restricted_use   IN   VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION get_default_click_plan (p_esn_objid IN NUMBER)
      RETURN NUMBER;

--
   FUNCTION get_dealer_click_plan (p_esn_objid IN NUMBER)
      RETURN NUMBER;

--
   PROCEDURE update_click (
      p_esn_objid              IN   NUMBER,
      p_call_trans_objid       IN   NUMBER,
      p_new_click_plan_objid   IN   NUMBER,
      p_site_part_objid        IN   NUMBER
   );

--
   FUNCTION getvoicemailnum (p_esn_objid IN NUMBER)
      RETURN VARCHAR2;

--
   PROCEDURE updatefreevoicemail (
      p_esn_objid    IN   NUMBER,
      p_fvm_status   IN   NUMBER,
      p_fvm_number   IN   VARCHAR2
   );

--
   FUNCTION getfreevoicemailstatus (p_esn_objid IN NUMBER)
      RETURN VARCHAR2;

--
   PROCEDURE updateflags (
      p_esn_objid              IN   NUMBER,
      p_call_trans_objid       IN   NUMBER,
      p_new_click_plan_objid   IN   NUMBER,
      p_site_part_objid        IN   NUMBER,
      p_code_type              IN   VARCHAR2,
      p_x_type                 IN   VARCHAR2
   );

--
   FUNCTION getpromodetails (p_esn IN VARCHAR2, p_red_card_objid IN VARCHAR2)
      RETURN VARCHAR2;

--
   PROCEDURE clearredcards (
      p_call_trans_objid   IN   NUMBER,
      p_esn_objid          IN   NUMBER,
      p_blnboolstatus      IN   BOOLEAN DEFAULT TRUE
   );

--
   FUNCTION checknoinvcarrier (p_iccid IN VARCHAR2, p_zip IN VARCHAR2)
      RETURN NUMBER;

--
   FUNCTION updatecodehistory (p_call_trans_objid IN NUMBER)
      RETURN BOOLEAN;

--
   FUNCTION getdefaultpromocode (
      p_restricted_use   IN   NUMBER,
      p_program_type     IN   NUMBER,
      p_esn_status       IN   VARCHAR2
   )
      RETURN VARCHAR2;

--
   FUNCTION getdefaultpromo (p_tech IN VARCHAR2, p_call_trans_objid IN NUMBER)
      RETURN NUMBER;

--
   PROCEDURE getdefaultpromo_new (
      p_call_trans_objid   IN   NUMBER,
      p_objid_pm           IN   NUMBER
   );

--
   FUNCTION getdealerpromo (
      p_site_objid         IN   NUMBER,
      p_call_trans_objid   IN   NUMBER
   )
      RETURN NUMBER;

--
   FUNCTION getoldsitepart (
      p_esn           IN   VARCHAR2,
      p_part_status   IN   VARCHAR2,
      p_status        IN   NUMBER
   )
      RETURN NUMBER;

--
   FUNCTION getwebpromo (p_call_trans_objid IN NUMBER)
      RETURN NUMBER;

--
   PROCEDURE codeaccepted (p_call_trans_objid IN NUMBER);

--
   PROCEDURE otacodeacceptedupdate (
      p_call_trans_objid   IN       NUMBER,
      p_time_code          OUT      VARCHAR2,
      p_ild                OUT      VARCHAR2,
      p_error_number       OUT      VARCHAR2,
      p_error_code         OUT      VARCHAR2
   );

--
   PROCEDURE otacodeaccepted (p_call_trans_objid IN NUMBER);

--CR5581/CR5582
   PROCEDURE enroll_for_tech_exch (
      p_esn                 IN       VARCHAR2,
      p_replacement_units   OUT      NUMBER,
      p_process_flag        IN       NUMBER
            DEFAULT 0    --flag to check if the call is from CBO or procedure
   );

--CR5581/CR5582

   -- CR5728
   FUNCTION activationpromoused (p_esn IN VARCHAR2)
      RETURN VARCHAR2;

--CR8507
-- sbabu   TF_REL_35. CompleteTranasaction cbo removal.
-- Added wrapper SP clearredcards_sql, minacchange_sql
   FUNCTION minacchange_sql (
      p_site_part_objid   IN   NUMBER,
      p_sourcesystem      IN   VARCHAR2,
      p_brand_name        IN   VARCHAR2
   )
      RETURN NUMBER;

--
   PROCEDURE clearredcards_sql (
      p_call_trans_objid   IN   NUMBER,
      p_esn_objid          IN   NUMBER,
      p_blnboolstatus      IN   NUMBER
   );
---CR8507

   -- CR23513  TF Surepay
  PROCEDURE preprocess_redem_cards
  (
    p_esn             IN VARCHAR2
   ,p_cards           IN VARCHAR2
   ,p_isota           IN VARCHAR2
   ,p_annual_plan     OUT NUMBER
   ,p_voice_units     OUT NUMBER
   ,p_redeem_days     OUT NUMBER
   ,p_errorcode       OUT VARCHAR2
   ,p_errormessage    OUT VARCHAR2
   ,p_conversion_rate OUT NUMBER
   ,p_redeem_text     OUT NUMBER
   ,p_redeem_data     OUT NUMBER
  );

   -- CR23513  TF Surepay
PROCEDURE sp_set_call_trans_ext (
    in_calltranobj          IN     table_x_call_trans.objid%TYPE,
    in_total_days           IN     table_x_call_trans_ext.x_total_days%TYPE,
    in_total_text           IN     table_x_call_trans_ext.x_total_sms_units%TYPE,
    in_total_data           IN     table_x_call_trans_ext.x_total_data_units%TYPE,
    out_err_code            OUT    VARCHAR2,
    out_err_msg             OUT    VARCHAR2,
    --CR46581 GO SMART
    -- ADDED OPTIONAL PARAMETER FOR ILD and INTL BUCKET
    i_ild_bucket_sent_flag  IN     VARCHAR2 DEFAULT NULL,
    i_intl_bucket_sent_flag IN     VARCHAR2 DEFAULT NULL,
    in_red_code             IN     VARCHAR2 DEFAULT NULL, --CR47564 added by Sagar
    in_discount_code_list   IN     discount_code_tab DEFAULT NULL, --CR47564 added by Sagar
    i_bucket_id_list        IN     ig_transaction_bucket_tab DEFAULT NULL --CR47564 added by Sagar
    );

    PROCEDURE sp_create_call_trans_soa (
      ip_esn            IN       VARCHAR2,
      ip_action_type    IN       VARCHAR2,
      ip_sourcesystem   IN       VARCHAR2,
      ip_brand_name     IN       VARCHAR2,
      ip_reason         IN       VARCHAR2,
      ip_result         IN       VARCHAR2,
      ip_ota_req_type   IN       VARCHAR2,
      ip_ota_type       IN       VARCHAR2,
      ip_total_units    IN       NUMBER,
      op_calltranobj    OUT      NUMBER,
      op_err_code       OUT      VARCHAR2,
      op_err_msg        OUT      VARCHAR2
   );

    PROCEDURE update_call_trans_extension(  in_call_trans_id    IN  NUMBER ,
                                            o_response          OUT VARCHAR2 );

FUNCTION CHECK_DATA_SAVER
(IP_ESN			IN 	VARCHAR2
)
RETURN 	VARCHAR2
;

PROCEDURE CREATE_ACTION_ORDER_TYPE	(	ip_esn 					VARCHAR2
						,ip_action_type_name			VARCHAR2
						,ip_user				VARCHAR2
						,ip_source_system			VARCHAR2
						,ip_ct_reason				VARCHAR2
						,ip_transmission_method			VARCHAR2
						,op_call_trans_objid		OUT	NUMBER
						,op_ig_transaction_id		OUT	VARCHAR2
						,op_error_code			OUT	VARCHAR2
						,op_error_msg			OUT	VARCHAR2
						)
;


PROCEDURE update_data_saver
						(IP_ESN 				VARCHAR2
						,IP_ACTION_TYPE_NAME			VARCHAR2
						,IP_USER				VARCHAR2
						,IP_SOURCESYSTEM			VARCHAR2
						,OP_ERROR_CODE			OUT	VARCHAR2
						,OP_ERROR_MSG			OUT	VARCHAR2
						)
;

END CONVERT_BO_TO_SQL_PKG;
/