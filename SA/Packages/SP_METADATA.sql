CREATE OR REPLACE PACKAGE sa."SP_METADATA" IS
--------------------------------------------------------------------------------------------
--$RCSfile: SP_METADATA_PKG.sql,v $
--$Revision: 1.24 $
--$Author: smeganathan $
--$Date: 2017/10/30 21:54:20 $
--$ $Log: SP_METADATA_PKG.sql,v $
--$ Revision 1.24  2017/10/30 21:54:20  smeganathan
--$ changes in vas added logic to retrieve part number based on billing program
--$
--$ Revision 1.23  2017/10/24 20:49:53  smeganathan
--$ changes in vas proration service
--$
--$ Revision 1.22  2017/10/23 18:57:37  smeganathan
--$ new overloaded procedure vas proration service added
--$
--$ Revision 1.21  2017/09/28 21:44:47  smeganathan
--$ new procedures for VAS proration
--$
--$ Revision 1.20  2017/09/20 22:07:31  smeganathan
--$ New procedures for proration logic
--$
--$ Revision 1.19  2017/04/19 18:59:16  tbaney
--$ CR48480 Corrected default for parameter.
--$
--$ Revision 1.18  2017/04/19 17:34:42  tbaney
--$ Added /
--$
--$ Revision 1.17  2017/04/19 17:28:12  tbaney
--$ CR48480 Affiliated Partners.
--$
--$ Revision 1.16  2016/08/03 21:54:20  rpednekar
--$ CR41745 - Added wrapper procedure with original inputs to modified procedure getcartmetadata
--$
--$ Revision 1.15  2016/08/02 21:08:33  rpednekar
--$ CR41745 - Added new function is_salestax_only and output parameters to procedure getcartmetadata
--$
--$ Revision 1.12  2015/04/14 23:18:09  vmadhawnadella
--$ ADD LOGIC  FOR $10.00 TEXT ONLY CARD.
--$
--$ Revision 1.11  2014/04/01 21:42:02  jchacon
--$ *** empty log message ***
--$
--$ Revision 1.10  2013/11/01 17:57:49  icanavan
--$ ADDED Datatax field calculation
--$
--$ Revision 1.8  2012/11/30 22:53:36  mmunoz
--$ CR18994 CR22380: Changes merged with revision 1.7 (signature of procedure GETCARTMETADATA to handle warranty amount)
--$
--------------------------------------------------------------------------------------------
PROCEDURE getprice_tot( p_part_number IN VARCHAR2, p_source IN varchar2,
                        p_retail_price  OUT NUMBER, p_redeem_units  OUT NUMBER,
                        p_redeem_days OUT NUMBER ,p_result  OUT NUMBER) ;

function  GETPRICE( P_PART_NUMBER in varchar2, P_SOURCE in varchar2 ) return number;
/* CR15373 WMMC pm Start new input parameter for CC id and Brand Name */
--- CR41745 Start wrapper with old signature
  PROCEDURE getcartmetadata
  (
    p_partnumbers     IN VARCHAR2
   ,p_promos          IN VARCHAR2
   ,v_esn             IN VARCHAR2
   ,p_cc_id           IN NUMBER
   ,p_source          IN VARCHAR2
   ,p_type            IN VARCHAR2
   ,p_brand_name      IN VARCHAR2
   ,p_itemprice       in varchar2  --cwl 10/9/12 CR19041
   ,p_totb_pn         OUT NUMBER
   ,p_tota_pn         OUT NUMBER
   ,p_totb_air        OUT NUMBER
   ,p_tota_air        OUT NUMBER
   ,p_totb_wty        OUT NUMBER   --CR18994 -- CR22380
   ,p_totb_dta        OUT NUMBER   --CR26033 -- CR26274
   ,p_totb_TXT        OUT NUMBER   --CR32572
   ,p_tot_MODEL_TYPE  OUT NUMBER   -- CR27269 -- CR27270 (alert car)
   ,p_model_type      OUT VARCHAR2 -- CR27269 -- CR27270 (alert car)
   ,p_tot_disc        OUT NUMBER
   ,op_count          OUT NUMBER
   ,op_result         OUT NUMBER
   ,op_msg            OUT VARCHAR2

  ) ;

--- CR41745 End wrapper with old signature

  PROCEDURE getcartmetadata
  (
    p_partnumbers     IN VARCHAR2
   ,p_promos          IN VARCHAR2
   ,v_esn             IN VARCHAR2
   ,p_cc_id           IN NUMBER
   ,p_source          IN VARCHAR2
   ,p_type            IN VARCHAR2
   ,p_brand_name      IN VARCHAR2
   ,p_itemprice       in varchar2  --cwl 10/9/12 CR19041
   ,p_totb_pn         OUT NUMBER
   ,p_tota_pn         OUT NUMBER
   ,p_totb_air        OUT NUMBER
   ,p_tota_air        OUT NUMBER
   ,p_totb_wty        OUT NUMBER   --CR18994 -- CR22380
   ,p_totb_dta        OUT NUMBER   --CR26033 -- CR26274
   ,p_totb_TXT        OUT NUMBER   --CR32572
   ,p_tot_MODEL_TYPE  OUT NUMBER   -- CR27269 -- CR27270 (alert car)
   ,p_model_type      OUT VARCHAR2 -- CR27269 -- CR27270 (alert car)
   ,p_tot_disc        OUT NUMBER
   ,op_count          OUT NUMBER
   ,op_result         OUT NUMBER
   ,op_msg            OUT VARCHAR2
   ,op_salestaxonly_b_amt		OUT NUMBER		--- CR41745
   ,op_salestaxonly_a_amt		OUT NUMBER		--- CR41745
   ,op_activation_chrg_b_amt		OUT NUMBER		--- CR41745
   ,op_activation_chrg_a_amt		OUT NUMBER		--- CR41745
   ,p_ar_promo_flag         IN VARCHAR2   DEFAULT 'N'           --- CR48480 'Y' 'N'
   ,p_partner_name          IN VARCHAR2   DEFAULT NULL          --- CR48480 Partner name ex: AMAZON WEB ORDERS, Best Buy, Ebay
  ) ;
/* CR15373 WMMC pm End */

PROCEDURE getcartmetadata_B2B(P_partnumbers IN VARCHAR2, P_promos  IN VARCHAR2,
                          v_esn                          IN VARCHAR2,P_source                IN VARCHAR2,
                          P_type       IN VARCHAR2, P_TOTB_PN OUT NUMBER, P_TOTA_PN OUT NUMBER,
                          P_TOTB_Air OUT NUMBER, P_TOTA_Air OUT NUMBER,  P_TOT_disc OUT NUMBER,
                          Op_count OUT number , Op_result OUT NUMBER,
                          Op_msg OUT VARCHAR2);

  Function MODEL_TAXES
  (p_esn  IN sa.table_part_inst.part_serial_no%type)
  RETURN VARCHAR2;

FUNCTION is_salestax_only (p_part_number  IN sa.table_part_num.part_number%type)
RETURN NUMBER;
--
-- CR49058 changes starts..
--
-- new procedure to get billing program based on part number
--
PROCEDURE  p_get_billing_program  ( i_part_number     IN    VARCHAR2,
                                    o_program_id      OUT   VARCHAR2,
                                    o_error_code      OUT   VARCHAR2,
                                    o_error_msg       OUT   VARCHAR2);
--
--new procedure to get part number based on billing program
--
PROCEDURE  p_get_part_number    ( i_program_parameter_id      IN    VARCHAR2,
                                  o_part_number               OUT   VARCHAR2,
                                  o_error_code                OUT   VARCHAR2,
                                  o_error_msg                 OUT   VARCHAR2);
--
-- new procedure to calculate the prorated amount based on the partnumber
PROCEDURE  p_get_prorated_amount  ( i_esn               IN    VARCHAR2,
                                    i_part_number       IN    VARCHAR2,
                                    i_price_channel     IN    VARCHAR2,
                                    i_prorated_days     IN    NUMBER,
                                    i_service_days      IN    NUMBER,
                                    o_prorated_amount   OUT   NUMBER,
                                    o_error_code        OUT   VARCHAR2,
                                    o_error_msg         OUT   VARCHAR2
                                  );
--
PROCEDURE p_vas_proration_service ( i_esn                   IN    VARCHAR2,
                                    i_vas_service_id        IN    VARCHAR2,
                                    i_current_expiry_date   IN    DATE,
                                    i_current_status        IN    VARCHAR2,
                                    i_part_number           IN    VARCHAR2,
                                    i_source                IN    VARCHAR2,
                                    o_prorated_service_days OUT   NUMBER,
                                    o_prorated_amount       OUT   NUMBER,
                                    o_error_code            OUT   VARCHAR2,
                                    o_error_msg             OUT   VARCHAR2
                                  );
--
PROCEDURE  p_vas_proration_service( i_esn               IN    VARCHAR2,
                                    i_part_number       IN    VARCHAR2,
                                    i_source            IN    VARCHAR2,
                                    o_prorated_amount   OUT   NUMBER,
                                    o_error_code        OUT   VARCHAR2,
                                    o_error_msg         OUT   VARCHAR2
                                  );
--
PROCEDURE  p_vas_proration_service  ( i_esn                       IN      VARCHAR2,
                                      i_source                    IN      VARCHAR2,
                                      io_part_number_details_tab  IN OUT  part_number_details_tab,
                                      o_error_code                OUT     VARCHAR2,
                                      o_error_msg                 OUT     VARCHAR2 );
-- CR49058 changes ends.
--
END SP_METADATA;
/