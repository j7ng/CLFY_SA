CREATE OR REPLACE PACKAGE sa."BYOP_SERVICE_PKG"
AS
--
 /**************************************************************************************************************/
 --$RCSfile: BYOP_SERVICE_PKG.sql,v $
 --$Revision: 1.51 $
 --$Author: abustos $
 --$Date: 2018/05/02 19:33:10 $
 --$ $Log: BYOP_SERVICE_PKG.sql,v $
 --$ Revision 1.51  2018/05/02 19:33:10  abustos
 --$ CR57569 - New output parameter o_original_sim in p_cdma_byop_check
 --$
 --$ Revision 1.50  2018/03/08 17:48:07  abustos
 --$ New parameter for islostorstolen_flag in last_vd_ig_trans
 --$
 --$ Revision 1.49  2017/11/20 22:01:34  jcheruvathoor
 --$ CR49064	CR49064 Net10 Business APIs BYOP CDMA
 --$
 --$ Revision 1.47  2017/10/03 19:00:27  oimana
 --$ CR51833 - Package Body merged with 1.177
 --$
 --$ Revision 1.46  2017/08/18 18:08:17  jcheruvathoor
 --$ CR48202	BYOP CDMA Activation Web Registration
 --$
 --$ Revision 1.45  2017/07/11 15:23:45  mshah
 --$ CR51418 - ALLOWING VZ DISCOUNT 1 for VZ
 --$
 --$ Revision 1.44  2017/05/25 16:45:12  nkandagatla
 --$ CR49186 - Verizon Validate Device Check
 --$
 --$ Revision 1.43  2016/11/17 23:09:10  smeganathan
 --$ CR45378 changes done to get buy_sim
 --$
 --$ Revision 1.42  2016/10/7 18:33:34  mgovindarajan
 --
 --
 /***************************************************************************************************************
  * Package Name: SA.BYOP_SERVICE_PKG
  * Description: The package is called for
  * to validate and register BYOP transaction.
 ***************************************************************************************************************/
--
FUNCTION valid_reg_pin(
    p_red_code IN VARCHAR2,
    p_org_id   IN VARCHAR2,
    p_part_number OUT VARCHAR2)
  RETURN VARCHAR2;
  PROCEDURE valid_carriers_by_brand(
      p_brand IN VARCHAR2,
      p_att OUT VARCHAR2,
      p_tmo OUT VARCHAR2,
      p_verizon OUT VARCHAR2,
      p_sprint OUT VARCHAR2);
  FUNCTION zip_tech_carrier(
      p_zip  IN VARCHAR2,
      p_tech IN VARCHAR2)
    RETURN parent_name_object;
  FUNCTION hex2dec18(
      p_esn IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION verify_carrier_zip(
      p_part_number IN VARCHAR2,
      P_ZIP         IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION verify_carrier_coverage(
      P_CARRIER IN VARCHAR2,
      p_org_id  IN VARCHAR2,
      P_ZIP     IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION VERIFY_ESN(
      P_ESN IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION VERIFY_BYOP_ESN(
      P_ESN IN VARCHAR2)
    RETURN VARCHAR2;
  PROCEDURE update_esn_new(
      p_esn                 IN VARCHAR2,
      p_byop_status         IN VARCHAR2,
      p_BYOP_INSERTION_TYPE IN VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2);
  PROCEDURE last_vd_ig_trans(
      p_esn     IN VARCHAR2,
      p_bus_org IN VARCHAR2,
      p_phone_gen OUT VARCHAR2,    ------> LTE, NON_LTE
      p_phone_model OUT VARCHAR2,  ------> APPL
      p_technology OUT VARCHAR2,   ------> CDMA
      p_sim_reqd OUT VARCHAR2,     ------> YES,NO
      p_original_sim OUT VARCHAR2, ------> 1234567890756735
      p_carrier OUT VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2 );
  PROCEDURE st_last_vd_ig_trans(
      P_ESN IN VARCHAR2,
      p_carrier OUT VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2);
  PROCEDURE insert_vd_ig_trans(
      P_ESN IN VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2);
  PROCEDURE st_insert_vd_ig_trans(
      P_ESN IN VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2);
  PROCEDURE insert_byop_tracking(
      p_esn               IN VARCHAR2,
      p_byop_type         IN VARCHAR2,
      p_byop_manufacturer IN VARCHAR2,
      p_byop_model        IN VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2);
  PROCEDURE insert_esn_prenew(
      p_esn                 IN VARCHAR2,
      p_old_esn             IN VARCHAR2,
      p_org_id              IN VARCHAR2,
      p_byop_type           IN VARCHAR2,
      p_BYOP_MANUFACTURER   IN VARCHAR2,
      p_BYOP_MODEL          IN VARCHAR2,
      p_BYOP_INSERTION_TYPE IN VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2,
      p_sim IN VARCHAR2,
    p_zip                 IN VARCHAR2
    --	CR41804
	,ip_NAC_offer_flag	IN VARCHAR2 	DEFAULT NULL
	,ip_SP_offer_flag	IN VARCHAR2 	DEFAULT NULL
	,ip_carrier_name	IN VARCHAR2	DEFAULT NULL
    --	CR41804
	,p_part_num OUT VARCHAR2  -- CR48202
    );
  PROCEDURE process_pin(
      p_esn        IN VARCHAR2,
      p_red_code   IN VARCHAR2,
      p_source_sys IN VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2);
  PROCEDURE getcasedetails(
      p_id_number IN VARCHAR2,
      p_ACCOUNT OUT VARCHAR2,
      p_PIN OUT VARCHAR2,
      p_NAME OUT VARCHAR2,
      p_LAST_NAME OUT VARCHAR2,
      p_HOME_PHONE OUT VARCHAR2,
      p_ADDRESS_1 OUT VARCHAR2,
      p_ADDRESS_2 OUT VARCHAR2,
      p_CITY OUT VARCHAR2,
      p_STATE OUT VARCHAR2,
      p_ZIP_CODE OUT VARCHAR2,
      p_EMAIL OUT VARCHAR2,
      p_SS_LAST_4_DIGITS OUT VARCHAR2);
  PROCEDURE updatecasedetails(
      p_id_number        IN VARCHAR2,
      p_ACCOUNT          IN VARCHAR2,
      p_PIN              IN VARCHAR2,
      p_NAME             IN VARCHAR2,
      p_LAST_NAME        IN VARCHAR2,
      p_HOME_PHONE       IN VARCHAR2,
      p_ADDRESS_1        IN VARCHAR2,
      p_ADDRESS_2        IN VARCHAR2,
      p_CITY             IN VARCHAR2,
      p_STATE            IN VARCHAR2,
      p_ZIP_CODE         IN VARCHAR2,
      p_EMAIL            IN VARCHAR2,
      p_SS_LAST_4_DIGITS IN VARCHAR2);
  PROCEDURE currentcachepolicy(
      p_esn IN VARCHAR2,
      p_status OUT VARCHAR2,
      p_policy_name OUT VARCHAR2,
      p_policy_description OUT VARCHAR2);
  PROCEDURE card_status(
      p_red_code IN VARCHAR2,
      p_status OUT VARCHAR2,
      p_units OUT VARCHAR2,
      p_days OUT VARCHAR2,
      p_brand OUT VARCHAR2,
      p_part_type OUT VARCHAR2,
      p_card_type OUT VARCHAR2,
      p_out_code OUT NUMBER,
      p_out_desc OUT VARCHAR2);
  PROCEDURE reg_card_usable(
      p_red_code IN VARCHAR2,
      p_out_code OUT NUMBER,
      p_out_desc OUT VARCHAR2);
  PROCEDURE validate_byop_sim(
      ip_esn         IN VARCHAR2,
      ip_sim         IN VARCHAR2,
      ip_zip         IN VARCHAR2,
      ip_carrier     IN VARCHAR2,
      ip_bus_org     IN VARCHAR2,
      ip_phone_model IN VARCHAR2,
      ip_byop_type   IN VARCHAR2,
      out_sim_profile OUT VARCHAR2,
      out_sim_compatible OUT VARCHAR2,
      out_sim_type OUT VARCHAR2,
      out_err_num OUT VARCHAR2,
      out_err_msg OUT VARCHAR2 );
  FUNCTION get_byop_sim_type(
      p_sim_partnum IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION get_byop_type(
      ip_carrier     IN VARCHAR2,
      ip_phone_model IN VARCHAR2,
      ip_sim_type    IN VARCHAR2,
      ip_phone_gen   IN VARCHAR2,
      ip_technology  IN VARCHAR2,
      ip_brand       IN VARCHAR2,
      ip_byop_type   IN VARCHAR2 	DEFAULT NULL)  -- CR44390 Added new parameter to handle BYOTs
    RETURN VARCHAR2;

        PROCEDURE insert_esn_prenew_tas_remove(
      p_esn                 IN VARCHAR2,
      p_old_esn             IN VARCHAR2,
      p_org_id              IN VARCHAR2,
      p_byop_type           IN VARCHAR2,
      p_BYOP_MANUFACTURER   IN VARCHAR2,
      p_BYOP_MODEL          IN VARCHAR2,
      p_BYOP_INSERTION_TYPE IN VARCHAR2,
      p_error_num OUT NUMBER,
      p_error_code OUT VARCHAR2,
      p_sim IN VARCHAR2);
        PROCEDURE last_vd_ig_trans_tas_remove(
                p_esn     IN VARCHAR2,
                p_bus_org IN VARCHAR2,
                p_phone_gen OUT VARCHAR2,
                p_phone_model OUT VARCHAR2,
                p_technology OUT VARCHAR2,
                p_sim_reqd OUT VARCHAR2,
                p_original_sim OUT VARCHAR2,
                p_carrier OUT VARCHAR2,
                p_error_num OUT NUMBER,
                p_error_code OUT VARCHAR2);
-- CR31456  Changes starts.
FUNCTION fn_verify_carrier_dev_type( i_carrier        IN    VARCHAR2,
                                     i_brand          IN    VARCHAR2,
                                     i_zip            IN    VARCHAR2,
                                     i_device_type    IN    VARCHAR2
                                   )
RETURN VARCHAR2;
--
PROCEDURE p_carrierlist_byop_brand_zip ( i_zip              IN    VARCHAR2,
                                         i_brand            IN    VARCHAR2,
                                         i_device_type      IN    VARCHAR2,
                                         i_technology       IN    VARCHAR2 default NULL,
                                         o_avlbl_carrier    OUT   VARCHAR2,
                                         o_result_code      OUT   VARCHAR2,
                                         o_result_msg       OUT   VARCHAR2
                                       );
--
PROCEDURE p_byop_coverage_check_wrp  ( i_zip             IN   VARCHAR2,
                                       i_brand           IN   VARCHAR2,
                                       i_device_type     IN   VARCHAR2,
                                       i_carrier         IN   VARCHAR2,
                                       i_technology      IN   VARCHAR2  default NULL,
                                       o_avlbl_carrier   OUT  VARCHAR2,
                                       o_result_code     OUT  VARCHAR2,
                                       o_result_msg      OUT  VARCHAR2
                                      );
--
PROCEDURE p_create_vd_ig_trans(i_esn          IN    VARCHAR2,
                               i_esn_hex      IN    VARCHAR2,
                               i_order_type   IN    VARCHAR2,
                               i_template     IN    VARCHAR2,
                               i_account_num  IN    VARCHAR2,
                               i_status       IN    VARCHAR2,
                               o_result_code  OUT   VARCHAR2,
                               o_result_msg   OUT   VARCHAR2);
--
PROCEDURE p_cdma_byop_check  ( i_esn          IN  VARCHAR2,
                               i_zip          IN  VARCHAR2,
                               i_carrier      IN  VARCHAR2,
                               i_brand        IN  VARCHAR2,
                               o_buy_sim      OUT VARCHAR2, -- CR45378
                               o_active       OUT VARCHAR2,
                               o_lte          OUT VARCHAR2,
                               o_result_code  OUT VARCHAR2,
                               o_result_msg   OUT VARCHAR2,
                               o_original_sim OUT VARCHAR2  -- CR57569
                              );
--
PROCEDURE p_cdma_byop_registration (i_esn         IN    VARCHAR2, -- IMEI / MEID
                                    i_carrier     IN    VARCHAR2,
                                    i_zip         IN    VARCHAR2,
                                    i_sim         IN    VARCHAR2,
                                    i_red_code    IN    VARCHAR2, -- Network Access Code
                                    i_brand       IN    VARCHAR2,
                                    i_byop_type   IN    VARCHAR2, -- Device Type
                                    i_source      IN    VARCHAR2,
                                    o_result_code OUT   VARCHAR2,
                                    o_result_msg  OUT   VARCHAR2
                                    );
--
PROCEDURE p_check_activation_scenario (i_flow_scenario          IN  VARCHAR2,
                                       i_from_phone_scenario    IN  VARCHAR2,
                                       i_to_phone_scenario      IN  VARCHAR2,
                                       i_from_esn               IN  VARCHAR2,
                                       i_to_esn                 IN  VARCHAR2,
                                       i_pin_reqd               OUT VARCHAR2);
-- CR31456  Changes Ends.
 /*********CR39192 Overloaded procedures added **********************/
PROCEDURE last_vd_ig_trans(
                           p_esn          IN VARCHAR2,
                           p_bus_org      IN VARCHAR2,
                           p_zipcode      IN VARCHAR2,
                           p_phone_gen    OUT VARCHAR2,    ------> LTE, NON_LTE
                           p_phone_model  OUT VARCHAR2,  ------> APPL
                           p_technology   OUT VARCHAR2,   ------> CDMA
                           p_sim_reqd     OUT VARCHAR2,     ------> YES,NO
                           p_original_sim OUT VARCHAR2, ------> 1234567890756735
                           p_carrier      IN OUT VARCHAR2,
                           p_islostorstolen OUT VARCHAR2,
                           p_error_num    OUT NUMBER,
                           p_error_code   OUT VARCHAR2 );
PROCEDURE st_last_vd_ig_trans(
                              p_esn        IN VARCHAR2,
                              p_carrier    IN OUT VARCHAR2,
                              p_zipcode    IN VARCHAR2,
                              p_error_num  OUT NUMBER,
                              p_error_code OUT VARCHAR2);
PROCEDURE insert_vd_ig_trans(
                             p_esn        IN VARCHAR2,
                             p_carrier    IN VARCHAR2,
                             p_zipcode    IN VARCHAR2,
                             p_error_num  OUT NUMBER,
                             p_error_code OUT VARCHAR2);
PROCEDURE st_insert_vd_ig_trans(
                                p_esn        IN VARCHAR2,
                                p_carrier    IN VARCHAR2,
                                p_zipcode    IN VARCHAR2,
                                p_error_num  OUT NUMBER,
                                p_error_code OUT VARCHAR2);
PROCEDURE last_vd_ig_trans_tas_remove(
                                      p_esn           IN VARCHAR2,
                                      p_bus_org       IN VARCHAR2,
                                      p_zipcode       IN VARCHAR2,
                                      p_phone_gen     OUT VARCHAR2,
                                      p_phone_model   OUT VARCHAR2,
                                      p_technology    OUT VARCHAR2,
                                      p_sim_reqd      OUT VARCHAR2,
                                      p_original_sim  OUT VARCHAR2,
                                      p_carrier       IN OUT VARCHAR2,
                                      p_islostorstolen OUT VARCHAR2,
                                      p_error_num     OUT NUMBER,
                                      p_error_code    OUT VARCHAR2);
   /*********CR39192 Overloaded procedures added **********************/
--CR41804
PROCEDURE generate_attach_free_pin (in_esn               IN   table_part_inst.part_serial_no%TYPE,
                                    in_pin_part_num      IN   table_part_inst.part_serial_no%TYPE,
                                    in_inv_bin_objid     IN   table_inv_bin.objid%TYPE,
                                    in_reserve_status    IN   table_part_inst.x_part_inst_status%TYPE DEFAULT '400',
                                    out_soft_pin         OUT  table_x_cc_red_inv.x_red_card_number%TYPE,
                                    out_smp_number       OUT  table_x_cc_red_inv.x_smp%TYPE,
                                    out_err_num          OUT  NUMBER,
                                    out_err_msg          OUT  VARCHAR2);
--CR41804

PROCEDURE last_vd_ig_trans ( p_esn IN VARCHAR2,
                             p_bus_org      IN  VARCHAR2,
                             p_zipcode      IN  VARCHAR2,
                             p_phone_gen    OUT VARCHAR2, ------> LTE, NON_LTE
                             p_phone_model  OUT VARCHAR2, ------> APPL
                             p_technology   OUT VARCHAR2, ------> CDMA
                             p_sim_reqd     OUT VARCHAR2, ------> YES,NO
                             p_original_sim OUT VARCHAR2, ------> 1234567890756735
                             p_carrier      IN OUT VARCHAR2,
                             p_islostorstolen OUT VARCHAR2,
                             p_recordcode     OUT VARCHAR2, --CR51418 ALLOWING VZ DISCOUNT 1 for VZ
                             p_error_num    OUT NUMBER,
                             p_error_code   OUT  VARCHAR2 ,
                             p_retmsg_lang  IN     VARCHAR2 DEFAULT 'ENG', -- CR49064
                             p_retmsg       OUT    VARCHAR2 ,              --CR49064
                             p_timediff     OUT    NUMBER	 ,              --CR53201
                             p_islostorstolen_flag IN  VARCHAR2 DEFAULT 'N'  --CR54759
							);
--CR49064
PROCEDURE get_ret_msg ( p_esn          IN  VARCHAR2,
                        p_carrier      IN  VARCHAR2,
                        p_retmsg_lang  IN  VARCHAR2 DEFAULT 'ENG',
                        p_retmsg       OUT VARCHAR2
                      );
END BYOP_SERVICE_PKG;
/