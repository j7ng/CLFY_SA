CREATE OR REPLACE PACKAGE sa."PHONE_PKG"
AS
/****************************************************************************************************/
--$RCSfile: PHONE_PKG.sql,v $
--$Revision: 1.90 $
--$Author: rvegi $
--$Date: 2018/03/28 17:45:20 $
--$ $Log: PHONE_PKG.sql,v $
--$ Revision 1.90  2018/03/28 17:45:20  rvegi
--$ CR56982 Modified BRAND_ESN Procedure Signature to Pass Branding Channel as Input Param.
--$
--$ Revision 1.89  2018/01/09 21:02:11  sgangineni
--$ CR48260 - Merged with latest prod version
--$
--$ Revision 1.87  2017/10/19 22:59:03  tbaney
--$ Modifed logic for rebranding checks.
--$
--$ Revision 1.86  2017/09/26 21:36:35  tbaney
--$ Merged with Produciton
--$
--$ Revision 1.85  2017/09/26 21:06:26  tbaney
--$ Production merge.
--$
--$ Revision 1.81  2017/07/12 16:28:51  mshah
--$ CR47491 - Merging
--$
--$ Revision 1.80  2017/07/07 16:47:09  mshah
--$ CR47491 - TF WEB TAS CDMA BYOP Registration changes needed
--$
--$ Revision 1.79  2017/07/06 22:45:24  mshah
--$ CR47491 - TF WEB TAS CDMA BYOP Registration changes needed
--$
--$ Revision 1.72  2017/04/12 15:35:13  mshah
--$ CR46195 - ST ??? WEB TAS ??? CDMA BYOP Registration changes needed
--$
--$ Revision 1.69  2017/04/05 18:14:57  sgangineni
--$ CR47564 - WFM code merge with Rel_854 changes
--$
--$ Revision 1.66  2017/02/22 22:31:50  sraman
--$ CR47564 - Added new proc GET_ESN_MIN_DETAILS
--$
--$ Revision 1.65  2017/02/10 19:36:38  sraman
--$ added new out paramter p_account_status for WFM
--$
--$ Revision 1.64  2017/02/06 15:22:19  nmuthukkaruppan
--$ CR47564 - Added ACCOUNT_PIN in validate_phone_prc
--$
--$ Revision 1.63  2017/01/19 18:11:01  sgangineni
--$ CR47564 - Updated signature of WFM overloaded procedure validatephone_prc on top of
--$  latest production version
--$
--$ Revision 1.62  2017/01/05 20:40:34  pamistry
--$ CR47564 - Added new procedure GET_ESN_PIN_DETAILS
--$
--$ Revision 1.61  2017/01/05 19:19:22  sgangineni
--$ CR47564 -WFM Changes by Sagar - Added new overloading procedure Validate_phone_prc with security_pin as a new out param
--$
--$ Revision 1.60  2017/01/05 15:27:16  sraman
--$ WFM Changes by Sabu
--$
--$ Revision 1.59  2016/12/13 19:26:55  sgururajan
--$ Creating an Overload procedure to get sub brand along with additional phone details
--$
--$ Revision 1.58  2016/11/23 18:29:40  aganesan
--$ CR44729 Validate phone prc stored procedure modified to include new out parameter sub brand
--$
--$ Revision 1.55  2016/08/23 19:00:35  smeganathan
--$ Merged with 8/23 prod release
--$
--$ Revision 1.54  2016/08/12 20:47:55  smeganathan
--$ CR43524 added forecast end date in getesnattributes
--$
--$ Revision 1.53  2016/08/04 19:30:56  smeganathan
--$ Changed getesnattributes signature for IVR TF
--$
--$ Revision 1.52  2016/07/25 18:40:28  smeganathan
--$ CR43524 changes in getesnattributes get esn eligible
--$
--$ Revision 1.51  2016/07/25 18:38:38  smeganathan
--$ CR43524 changes in getesnattributes get esn eligible
--$
--$ Revision 1.49  2016/03/02 20:38:44  smeganathan
--$ Changes for validate pre posa
--$
--$ Revision 1.48  2016/03/01 01:08:29  smeganathan
--$ CR31456 added new procs fro validate pre posa phone
--$
--$ Revision 1.47  2016/01/27 02:25:57  aganesan
--$ CR26169 - IVR Universal Purchase.
--$
--$ Revision 1.41  2015/09/23 18:19:04  tbaney
--$ Merged with Production.
--$
--$ Revision 1.37  2015/08/31 17:24:11  vsugavanam
--$ phone in box related changes
--$
--$ Revision 1.31  2015/05/22 21:24:43  pvenkata
--$ CR32952
--$
--$ Revision 1.20  2014/05/22 15:44:44  mvadlapally
--$ CR27270 Audiovox Car Connection
--$
--$ Revision 1.18  2014/02/07 18:23:02  cpannala
--$ CR25490
--$
--$ Revision 1.16  2014/01/09 19:42:12  cpannala
--$ CR25490
--$
--$ Revision 1.15  2013/05/13 18:57:04  icanavan
--$ UBRAND NEW PROCEDURE BRAND_ESN
--$
--$ Revision 1.14  2012/10/22 21:32:24  ymillan
--$ CR19041
--$
--$ Revision 1.11  2011/10/21 18:23:06  kacosta
--$ CR16987 Add Rate Plan to Port In Cases
--$
--$ Revision 1.9  2011/09/06 19:39:27  mmunoz
--$ Merge changes CR15625 Safelink 1.8 and CR17202 Best Buy 1.7
--$
--$ Revision 1.8  2011/08/31 19:32:18  icanavan
--$ ADDED SAFELINK OUTVAR
--$
--$ Revision 1.4  2011/04/27 14:19:41  akhan
--$ added changes for multi tank querying
--$
--$ Revision 1.5  2011/08/31 icanavan
--$ CR15625 SAFELINK PROCESS IMPROVEMENTS SKIP PIN REQUIREMENT ON 53 AND 54
--$
--$ Revision 1.3  2011/02/10 14:26:47  skuthadi
--$ added 1 new OUTparameter p_service_plan_objid  to the new procedure
--$
--$ Revision 1.2  2011/02/07 21:09:47  akhan
--$ added new procedure forCR13535
--$
--1.0     08/27/09 NGuada BRAND_SEP Separate the Brand and Source System
/****************************************************************************************************/
   PROCEDURE validate_phone_prc (
      p_esn                  IN       VARCHAR2,
      p_source_system        IN       VARCHAR2,    -- CHANNEL (CHANNEL TABLE)
      p_brand_name           IN       VARCHAR2,  --BRAND NAME (BUS ORG TABLE)
      p_part_inst_objid      OUT      VARCHAR2,
      p_code_number          OUT      VARCHAR2,
      p_code_name            OUT      VARCHAR2,
      p_redemp_reqd_flg      OUT      NUMBER,
      p_warr_end_date        OUT      VARCHAR2,
      p_phone_model          OUT      VARCHAR2,
      p_phone_technology     OUT      VARCHAR2,
      p_phone_description    OUT      VARCHAR2,
      p_esn_brand            OUT      VARCHAR2,
      p_zipcode              OUT      VARCHAR2,
      p_pending_red_status   OUT      VARCHAR2,
      p_click_status         OUT      VARCHAR2,
      p_promo_units          OUT      NUMBER,
      p_promo_access_days    OUT      NUMBER,
      p_num_of_cards         OUT      NUMBER,
      p_pers_status          OUT      VARCHAR2,
      p_contact_id           OUT      VARCHAR2,
      p_contact_phone        OUT      VARCHAR2,
      p_errnum               OUT      VARCHAR2,
      p_errstr               OUT      VARCHAR2,
      p_sms_flag             OUT      NUMBER,
      p_part_class           OUT      VARCHAR2,
      p_parent_id            OUT      VARCHAR2,
      p_extra_info           OUT      VARCHAR2,
      p_int_dll              OUT      NUMBER,
      p_contact_email        OUT      VARCHAR2,
      p_min                  OUT      VARCHAR2,
      p_manufacturer         OUT      VARCHAR2,
      p_seq                  OUT      NUMBER,
      p_iccid                OUT      VARCHAR2,
      p_iccid_flag           OUT      VARCHAR2,
      p_last_call_trans      OUT      VARCHAR2,
      p_safelink_esn         OUT      VARCHAR2
   );

   PROCEDURE get_program_info (
      p_esn                  IN       VARCHAR2,
      p_service_plan_objid   OUT      VARCHAR2,
      p_service_type         OUT      VARCHAR2,
      p_program_type         OUT      VARCHAR2,
      p_next_charge_date     OUT      DATE,
      p_program_units        OUT      NUMBER,
      p_program_days         OUT      NUMBER,
      p_error_num            OUT      NUMBER
   );

   -- CR16987 Start KACOSTA 10/12/2011
   PROCEDURE get_program_info (
      p_esn                  IN       VARCHAR2,
      p_service_plan_objid   OUT      VARCHAR2,
      p_service_type         OUT      VARCHAR2,
      p_program_type         OUT      VARCHAR2,
      p_next_charge_date     OUT      DATE,
      p_program_units        OUT      NUMBER,
      p_program_days         OUT      NUMBER,
      p_rate_plan            OUT      VARCHAR2,
      p_error_num            OUT      NUMBER
   );
   -- CR16987 End KACOSTA 10/12/2011



 --CR32952
 PROCEDURE get_program_info
 (
      p_esn                  IN       VARCHAR2,
      p_service_plan_objid   OUT      VARCHAR2,
      p_service_type         OUT      VARCHAR2,
      p_program_type         OUT      VARCHAR2,
      p_next_charge_date     OUT      DATE,
      p_program_units        OUT      NUMBER,
      p_program_days         OUT      NUMBER,
      p_rate_plan            OUT      VARCHAR2,
      p_x_prg_script_id      OUT      VARCHAR2,
      p_x_prg_desc_script_id OUT      VARCHAR2,
      p_error_num            OUT      NUMBER
   );


   FUNCTION  sf_is_multitank_mode ( p_esn   IN       VARCHAR2)
   return number ;


PROCEDURE validate_security_pin(
  p_esn               IN  VARCHAR2,
  p_pin               IN  VARCHAR2,
  p_brand_name        IN  VARCHAR2,
  p_is_valid          OUT INTEGER,
  p_web_objid         OUT VARCHAR2,
  p_contact_objid     OUT VARCHAR2,
  p_error_code        OUT NUMBER,
  p_error_msg         OUT VARCHAR2
);
--cr19041
PROCEDURE validate_vas_security_pin(
  p_web_user_objid    IN varchar2,
  p_pin               IN VARCHAR2,
  p_is_valid          OUT INTEGER,
  p_web_objid         OUT VARCHAR2,
  p_contact_objid     OUT VARCHAR2,
  p_error_code        OUT NUMBER,
  p_error_msg         OUT VARCHAR2
);

PROCEDURE TECH_X_ZIPCODE
  ( p_zipcode      IN VARCHAR2,
    p_cursor       OUT SYS_REFCURSOR,
    OP_ERR_NUM     OUT NUMBER,
    OP_ERR_STRING  OUT VARCHAR2
  );

PROCEDURE BRAND_ESN
                   (
                    ip_esn     in varchar2,
                    ip_org_id  in varchar2, -- ip_brand_objid number,
                    ip_user    in varchar2,
                    op_result  out varchar2,
                    op_msg     out varchar2,
                    ip_sl_flag IN VARCHAR2 DEFAULT 'N', --50666
                    ip_zipcode IN VARCHAR2 DEFAULT NULL,
					ip_Rebrand_Channel IN VARCHAR2 DEFAULT NULL --CR56982
                   );

PROCEDURE Getesnattributes(
      In_Esn     IN Table_Part_Inst.Part_Serial_No%Type,
      Io_Key_Tbl IN OUT Keys_Tbl);
PROCEDURE Setesnattributes(
      In_Esn     IN VARCHAR2,
      io_KEY_TBL IN OUT KEYs_TBL);

-- Overloading procedure CR27270 Car Connection
PROCEDURE validate_phone_prc (p_esn                  IN     VARCHAR2,
                            p_source_system        IN     VARCHAR2,
                            p_brand_name           IN     VARCHAR2,
                            p_part_inst_objid         OUT VARCHAR2,
                            p_code_number             OUT VARCHAR2,
                            p_code_name               OUT VARCHAR2,
                            p_redemp_reqd_flg         OUT NUMBER,
                            p_warr_end_date           OUT VARCHAR2,
                            p_phone_model             OUT VARCHAR2,
                            p_phone_technology        OUT VARCHAR2,
                            p_phone_description       OUT VARCHAR2,
                            p_esn_brand               OUT VARCHAR2,
                            p_zipcode                 OUT VARCHAR2,
                            p_pending_red_status      OUT VARCHAR2,
                            p_click_status            OUT VARCHAR2,
                            p_promo_units             OUT NUMBER,
                            p_promo_access_days       OUT NUMBER,
                            p_num_of_cards            OUT NUMBER,
                            p_pers_status             OUT VARCHAR2,
                            p_contact_id              OUT VARCHAR2,
                            p_contact_phone           OUT VARCHAR2,
                            p_errnum                  OUT VARCHAR2,
                            p_errstr                  OUT VARCHAR2,
                            p_sms_flag                OUT NUMBER,
                            p_part_class              OUT VARCHAR2,
                            p_parent_id               OUT VARCHAR2,
                            p_extra_info              OUT VARCHAR2,
                            p_int_dll                 OUT NUMBER,
                            p_contact_email           OUT VARCHAR2,
                            p_min                     OUT VARCHAR2,
                            p_manufacturer            OUT VARCHAR2,
                            p_seq                     OUT NUMBER,
                            p_iccid                   OUT VARCHAR2,
                            p_iccid_flag              OUT VARCHAR2,
                            p_last_call_trans         OUT VARCHAR2,
                            p_safelink_esn            OUT VARCHAR2,
                            p_preactv_benefits        OUT VARCHAR2 );


 -- OverLoading Procedure for Sub brand
 PROCEDURE validate_phone_prc (p_esn                  IN     VARCHAR2,
                            p_source_system        IN     VARCHAR2,
                            p_brand_name           IN     VARCHAR2,
                            p_part_inst_objid         OUT VARCHAR2,
                            p_code_number             OUT VARCHAR2,
                            p_code_name               OUT VARCHAR2,
                            p_redemp_reqd_flg         OUT NUMBER,
                            p_warr_end_date           OUT VARCHAR2,
                            p_phone_model             OUT VARCHAR2,
                            p_phone_technology        OUT VARCHAR2,
                            p_phone_description       OUT VARCHAR2,
                            p_esn_brand               OUT VARCHAR2,
                            p_zipcode                 OUT VARCHAR2,
                            p_pending_red_status      OUT VARCHAR2,
                            p_click_status            OUT VARCHAR2,
                            p_promo_units             OUT NUMBER,
                            p_promo_access_days       OUT NUMBER,
                            p_num_of_cards            OUT NUMBER,
                            p_pers_status             OUT VARCHAR2,
                            p_contact_id              OUT VARCHAR2,
                            p_contact_phone           OUT VARCHAR2,
                            p_errnum                  OUT VARCHAR2,
                            p_errstr                  OUT VARCHAR2,
                            p_sms_flag                OUT NUMBER,
                            p_part_class              OUT VARCHAR2,
                            p_parent_id               OUT VARCHAR2,
                            p_extra_info              OUT VARCHAR2,
                            p_int_dll                 OUT NUMBER,
                            p_contact_email           OUT VARCHAR2,
                            p_min                     OUT VARCHAR2,
                            p_manufacturer            OUT VARCHAR2,
                            p_seq                     OUT NUMBER,
                            p_iccid                   OUT VARCHAR2,
                            p_iccid_flag              OUT VARCHAR2,
                            p_last_call_trans         OUT VARCHAR2,
                            p_safelink_esn            OUT VARCHAR2,
                            p_preactv_benefits        OUT VARCHAR2,
						       	p_sub_brand               OUT VARCHAR2);
/*********************************************************************
procedure: p_get_latest_upgrade_esn
date     : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN looks for any upgrade cases on the
             ESN and return the lastest ESN.
**********************************************************************/
procedure p_get_latest_upgrade_esn     (in_esn          in    varchar2,
                                        out_esn         out    varchar2,
                                        out_case_date   out    date,
                                        out_error_code  out   number,
                                        out_error_msg   out   varchar2
                                        );
/*********************************************************************
procedure: p_get_latest_port_esn
date     : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN looks for any port cases on the
             ESN and return the lastest ESN.
**********************************************************************/
procedure p_get_latest_port_esn     (in_esn          in    varchar2,
                                        out_esn         out    varchar2,
                                        out_case_date   out    date,
                                        out_error_code  out   number,
                                        out_error_msg   out   varchar2
                                        );
/*********************************************************************
procedure: p_get_latest_replacement_esn
date     : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN looks for any replacement cases on the
             ESN and return the lastest ESN.
**********************************************************************/
procedure p_get_latest_replacement_esn (in_esn          in    varchar2,
                                        out_esn         out    varchar2,
                                        out_case_date   out    date,
                                        out_error_code  out   number,
                                        out_error_msg   out   varchar2
                                        );
/*********************************************************************
procedure  : p_get_latest_esn
date       : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN calls the p_get_latest_replacement_esn
             ,p_get_latest_port_esn, p_get_latest_upgrade_esn and returns
             latest ESN.
**********************************************************************/
procedure p_get_latest_esn   (  in_esn          in    varchar2,
                                out_esn         out    varchar2,
                                out_case_date   out    date,
                                out_esn_case    out    varchar2,
                                out_error_code  out   number,
                                out_error_msg   out   varchar2
                              )  ;
/*********************************************************************
procedure  : p_get_esn_attributes
date       : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes input ESN and a key table containing attributes of
             the ESN that need to be looked up and returned. The
             procedure looks for the latest ESN if any based on upgrade
             and exchange cases and if found returns the attributes for
             the latest ESN.
**********************************************************************/
PROCEDURE p_get_updated_esn_attributes
     (
      In_Esn IN Table_Part_Inst.Part_Serial_No%Type,
      Io_Key_Tbl IN OUT Keys_Tbl,
      out_err_code out number,
      out_err_msg out varchar2,
      ip_org_id   IN     VARCHAR2 DEFAULT NULL   --CR46193
      );
/*********************************************************************
procedure  : p_set_esn_status_used
date       : 08/26/2015
description: Procedure developed as part of phone in a box project.
             This procedure is used to set the status of given ESN
             to USED status from RISK ASSESMENT status.
**********************************************************************/
PROCEDURE p_set_esn_status_used(
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2,
    ip_zero_out_max VARCHAR2,
    out_error_code  OUT number,
    out_message     OUT VARCHAR2);
-- CR43524
PROCEDURE Getesnattributes(io_esn                      IN OUT VARCHAR2,
                           io_min                      IN OUT VARCHAR2,
                           o_esn_brand                 OUT    VARCHAR2,
                           o_esn_status                OUT    VARCHAR2,
                           o_esn_sub_status            OUT    VARCHAR2,
                           o_esn_plan_grp              OUT    VARCHAR2,
                           o_my_acc_login              OUT    VARCHAR2,
                           o_web_user_objid            OUT    VARCHAR2,
                           o_part_class                OUT    VARCHAR2, --phone pc
                           o_part_num                  OUT    VARCHAR2, --phone_part_num
                           o_num_pin_queued            OUT    NUMBER  ,
                           o_last_redm_plan_part_num   OUT    VARCHAR2,
                           o_last_redm_plan_pc         OUT    VARCHAR2,
                           o_enrl_autref_flag          OUT    VARCHAR2,
                           o_enrl_objid                OUT    NUMBER,
                           o_enrl_dbl_min_promo_flag   OUT    VARCHAR2,
                           o_enrl_trpl_min_promo_flag  OUT    VARCHAR2,
                           o_enrl_hpp_flag             OUT    VARCHAR2,
                           o_is_hpp_eligible           OUT    VARCHAR2,
                           o_enrl_hpp_price            OUT    NUMBER  ,
                           o_enrl_ild_flag             OUT    VARCHAR2,
                           o_phone_technology          OUT    VARCHAR2,
                           o_sim_number                OUT    VARCHAR2,
                           o_zipcode                   OUT    VARCHAR2,
                           o_dev_type                  OUT    VARCHAR2,
                           o_flash_id                  OUT    VARCHAR2,
                           o_flash_txt                 OUT    VARCHAR2,
                           o_service_end_date          OUT    VARCHAR2,
                           o_forecast_end_date         OUT    VARCHAR2,
                           o_base_plan                 OUT    VARCHAR2,
                           o_curr_splanid              OUT    NUMBER,
                           o_splan_type                OUT    VARCHAR2,
                           o_curr_splan_name           OUT    VARCHAR2,
                           o_is_promo_eligible         OUT    VARCHAR2,
                           o_is_safelink               OUT    VARCHAR2,
                           o_contact_objid             OUT    NUMBER,
                           o_errnum                    OUT    VARCHAR2,
                           o_errstr                    OUT    VARCHAR2
                           );
--
PROCEDURE get_cust_profile_data(i_esn                       IN   VARCHAR2,
                                i_min                       IN   VARCHAR2,
                                o_my_acc_login              OUT  VARCHAR2,
                                o_web_user_objid            OUT  VARCHAR2,
                                o_num_of_ccards             OUT  NUMBER  ,
                                o_list_of_ccards            OUT  typ_creditcard_tbl,
                                o_contact_objid             OUT  VARCHAR2,
                                o_errnum                    OUT  VARCHAR2,
                                o_errstr                    OUT  VARCHAR2
                                );
-- CR43524
PROCEDURE   get_esn_eligible  (i_esn                       IN  VARCHAR2,
                               i_min                       IN  VARCHAR2,
                               o_esn_eligible              OUT VARCHAR2,
                               o_valid_result              OUT VARCHAR2,
                               o_esn_issue                 OUT VARCHAR2,
                               o_errnum                    OUT VARCHAR2,
                               o_errstr                    OUT VARCHAR2);
--
PROCEDURE get_retention_decision(i_esn                       IN     VARCHAR2,
                                 i_brand                     IN     VARCHAR2,
                                 i_source_system             IN     VARCHAR2,
                                 i_flow                      IN     VARCHAR2,
                                 i_src_part_num              IN     VARCHAR2,
                                 i_dest_part_num             IN     VARCHAR2,
                                 i_esn_enrolled              IN     VARCHAR2,
                                 i_language                  IN     VARCHAR2,
                                 o_action                    OUT    VARCHAR2,
                                 o_warn_script_id            OUT    VARCHAR2,
                                 o_warn_script_txt           OUT    VARCHAR2,
                                 o_spl_script_id             OUT    VARCHAR2,
                                 o_spl_script_txt            OUT    VARCHAR2,
                                 o_errnum                    OUT    VARCHAR2,
                                 o_errstr                    OUT    VARCHAR2
                                 );
--
PROCEDURE validate_pre_posa_phone(
  p_esn IN VARCHAR2 ,
  p_source_system IN VARCHAR2 , -- CHANNEL (CHANNEL TABLE)
  p_brand_name IN VARCHAR2 , --BRAND NAME (BUS ORG TABLE)
  p_part_inst_objid OUT VARCHAR2 ,
  p_code_number OUT VARCHAR2 ,
  p_code_name OUT VARCHAR2 ,
  p_redemp_reqd_flg OUT NUMBER ,
  p_warr_end_date OUT VARCHAR2 ,
  p_phone_model OUT VARCHAR2 ,
  p_phone_technology OUT VARCHAR2 ,
  p_phone_description OUT VARCHAR2 ,
  p_esn_brand OUT VARCHAR2 ,
  p_zipcode OUT VARCHAR2 ,
  p_pending_red_status OUT VARCHAR2 ,
  p_click_status OUT VARCHAR2 ,
  p_promo_units OUT NUMBER ,
  p_promo_access_days OUT NUMBER ,
  p_num_of_cards OUT NUMBER ,
  p_pers_status OUT VARCHAR2 ,
  p_contact_id OUT VARCHAR2 ,
  p_contact_phone OUT VARCHAR2 ,
  p_errnum OUT VARCHAR2 ,
  p_errstr OUT VARCHAR2 ,
  p_sms_flag OUT NUMBER ,
  p_part_class OUT VARCHAR2 ,
  p_parent_id OUT VARCHAR2 ,
  p_extra_info OUT VARCHAR2 ,
  p_int_dll OUT NUMBER ,
  p_contact_email OUT VARCHAR2 ,
  p_min OUT VARCHAR2 ,
  p_manufacturer OUT VARCHAR2 ,
  p_seq OUT NUMBER ,
  p_iccid OUT VARCHAR2 ,
  p_iccid_flag OUT VARCHAR2 ,
  p_last_call_trans OUT VARCHAR2 ,
  p_safelink_esn OUT VARCHAR2,
  p_preactv_benefits OUT VARCHAR2);
--
PROCEDURE simulate_phone_active(
      ip_esn_num        IN VARCHAR2,
      ip_upc_code       IN VARCHAR2,
      ip_date           IN VARCHAR2,
      ip_time           IN VARCHAR2,
      ip_trans_id       IN VARCHAR2,
      ip_trans_type     IN VARCHAR2,
      ip_merchant_id    IN VARCHAR2,
      ip_store_detail   IN VARCHAR2,
      op_error_code     OUT VARCHAR2,
      op_error_msg      OUT VARCHAR2,
      ip_sourcesystem   IN VARCHAR2 := 'POSA'
   );
FUNCTION simulate_posa_phone_swp(
      ip_part_serial_no   IN VARCHAR2,
      ip_domain           IN VARCHAR2,
      ip_action           IN VARCHAR2,
      ip_store_detail     IN VARCHAR2,
      ip_store_id         IN VARCHAR2,
      ip_trans_id         IN VARCHAR2,
      ip_sourcesystem     IN VARCHAR2,
      ip_trans_date       IN DATE,
      ip_prog_caller      IN VARCHAR2
      )
      RETURN BOOLEAN;
--
--CR43088  WARP 2.0
PROCEDURE unbrand_esn(ip_esn           IN  VARCHAR2,
                      ip_bus_org_id    IN  VARCHAR2,
                      ip_user          IN  VARCHAR2,
                      op_error_code    OUT VARCHAR2,
                      op_error_msg     OUT VARCHAR2 );
--CR43088 WARP 2.0

--CR44729 GoSmart --Start
PROCEDURE get_sub_brand(i_esn       IN  VARCHAR2,
                        o_sub_brand OUT VARCHAR2,
                        o_errnum    OUT NUMBER  ,
                        o_errstr    OUT VARCHAR2
						);

PROCEDURE get_sub_brand(i_contact_objid IN   NUMBER  ,
                        o_sub_brand     OUT  VARCHAR2,
                        o_errnum        OUT  NUMBER  ,
                        o_errstr        OUT  VARCHAR2
						);

PROCEDURE get_sub_brand(i_login_name IN  VARCHAR2,
                        o_sub_brand  OUT VARCHAR2,
                        o_errnum     OUT NUMBER  ,
                        o_errstr     OUT VARCHAR2
						);
--CR44729 GoSmart --End

--CR47564 WFM -- Start
PROCEDURE get_esn_plan_details( op_esn_plan_partnum_det_tab IN OUT ESN_PLAN_PARTNUM_DET_TAB,
                                o_err_code                  OUT VARCHAR2,
                                o_err_msg                   OUT VARCHAR2
							  );

PROCEDURE GET_ESN_PIN_DETAILS( op_esn_pin_smp_tab IN OUT ESN_PIN_SMP_DET_TAB,
                                o_err_code                  OUT VARCHAR2,
                                o_err_msg                   OUT VARCHAR2	  );
--CR47564 WFM -- END
   --CR47564 - New Overloading procedure Validate_phone_prc with security_pin as a new out param
   PROCEDURE validate_phone_prc (
      p_esn                  IN       VARCHAR2,
      p_source_system        IN       VARCHAR2,    -- CHANNEL (CHANNEL TABLE)
      p_brand_name           IN       VARCHAR2,  --BRAND NAME (BUS ORG TABLE)
      p_part_inst_objid      OUT      VARCHAR2,
      p_code_number          OUT      VARCHAR2,
      p_code_name            OUT      VARCHAR2,
      p_redemp_reqd_flg      OUT      NUMBER,
      p_warr_end_date        OUT      VARCHAR2,
      p_phone_model          OUT      VARCHAR2,
      p_phone_technology     OUT      VARCHAR2,
      p_phone_description    OUT      VARCHAR2,
      p_esn_brand            OUT      VARCHAR2,
      p_zipcode              OUT      VARCHAR2,
      p_pending_red_status   OUT      VARCHAR2,
      p_click_status         OUT      VARCHAR2,
      p_promo_units          OUT      NUMBER,
      p_promo_access_days    OUT      NUMBER,
      p_num_of_cards         OUT      NUMBER,
      p_pers_status          OUT      VARCHAR2,
      p_contact_id           OUT      VARCHAR2,
      p_contact_phone        OUT      VARCHAR2,
      p_errnum               OUT      VARCHAR2,
      p_errstr               OUT      VARCHAR2,
      p_sms_flag             OUT      NUMBER,
      p_part_class           OUT      VARCHAR2,
      p_parent_id            OUT      VARCHAR2,
      p_extra_info           OUT      VARCHAR2,
      p_int_dll              OUT      NUMBER,
      p_contact_email        OUT      VARCHAR2,
      p_min                  OUT      VARCHAR2,
      p_manufacturer         OUT      VARCHAR2,
      p_seq                  OUT      NUMBER,
      p_iccid                OUT      VARCHAR2,
      p_iccid_flag           OUT      VARCHAR2,
      p_last_call_trans      OUT      VARCHAR2,
      p_safelink_esn         OUT      VARCHAR2,
      p_preactv_benefits	  OUT		  VARCHAR2,
      p_sub_brand				  OUT		  VARCHAR2,
      p_security_pin			  OUT		  VARCHAR2,
      p_account_pin               OUT VARCHAR2,
      p_account_status            OUT VARCHAR2
   );
PROCEDURE GET_ESN_MIN_DETAILS( op_esn_min_status_det_tab IN OUT esn_min_status_det_tab,
                                o_err_code                  OUT VARCHAR2,
                                o_err_msg                   OUT VARCHAR2	  );

   --CR47564 - End of Overloading procedure Validate_phone_prc with security_pin as a new out param
--CR46195
PROCEDURE get_cdma_rebrand_pn
                            (
                             i_esn       IN     VARCHAR2,
                             i_is_lte    IN     VARCHAR2,
                             i_org_id    IN     VARCHAR2,
                             o_to_pn        OUT VARCHAR2,
                             o_rebrand      OUT VARCHAR2,
                             o_errnum       OUT VARCHAR2,
                             o_errstr       OUT VARCHAR2,
                             i_zip_code  IN     VARCHAR2,
                             o_new_sim_part_num OUT VARCHAR2
                            );

FUNCTION eligible_ppe_pn(i_part_num IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_sim_compatible(p_esn IN VARCHAR2, p_part_num IN VARCHAR2)
RETURN VARCHAR2;

--CR50154 ST LTO made it as public
PROCEDURE get_last_red_details(ip_esn         IN  VARCHAR2,
							   op_red_partno  OUT VARCHAR2,
							   op_red_pc      OUT VARCHAR2,
							   op_code        OUT NUMBER,
							   op_msg         OUT VARCHAR2
							   );

--50666
PROCEDURE get_sl_equi_phone
                          (
                           i_esn       IN     VARCHAR2,
                           i_org_id    IN     VARCHAR2,
                           o_to_pn        OUT VARCHAR2,
                           o_rebrand      OUT VARCHAR2,
                           o_errnum       OUT VARCHAR2,
                           o_errstr       OUT VARCHAR2
                          );
--CR48260 changes start
PROCEDURE get_multi_esn_attributes ( i_customer_tab   IN OUT sa.customer_tab,
                                     o_err_code       OUT   NUMBER,
                                     o_err_msg        OUT   VARCHAR2
                                   );
--CR48260 changes start
END phone_pkg;
/