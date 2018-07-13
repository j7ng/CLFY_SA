CREATE OR REPLACE PACKAGE sa."PROMOTION_PKG" AS
  --
  --********************************************************************************
  --$RCSfile: PROMOTION_PKG.sql,v $
  --$Revision: 1.17 $
  --$Author: smeganathan $
  --$Date: 2017/06/01 21:12:23 $
  --$ $Log: PROMOTION_PKG.sql,v $
  --$ Revision 1.17  2017/06/01 21:12:23  smeganathan
  --$ Added parameter ip_discount_list to procedure sp_ins_esn_promo_hist
  --$
  --$ Revision 1.16  2017/05/04 18:10:49  tbaney
  --$ Added new procedure for CR48480 to get discount code.
  --$
  --$ Revision 1.15  2017/04/13 12:57:10  tbaney
  --$ Added additional parameter for CBO
  --$
  --$ Revision 1.14  2017/04/06 21:36:29  tbaney
  --$ Modified logic due to requirments changing.
  --$
  --$ Revision 1.10  2016/12/02 19:37:59  mshah
  --$ 44459 - NT_Multi Plan Purchasing
  --$
  --$ Revision 1.9  2016/12/02 15:29:01  mshah
  --$ 44459 - NT_Multi Plan Purchasing
  --$
  --$ Revision 1.8  2016/09/29 18:44:13  mgovindarajan
  --$ CR45122: Removed the Promo_batch_prc since it is out of scope for this release.
  --$
  --$ Revision 1.7  2016/09/07 21:30:28  mgovindarajan
  --$ CR42361 New procedure added for Batch
  --$
  --$ Revision 1.6  2016/08/25 15:46:40  vnainar
  --$ CR42361 new procedure added
  --$
  --$ Revision 1.5  2014/07/14 14:59:18  ahabeeb
  --$ changed name of the new column in x_offer_info
  --$
  --$ Revision 1.4  2014/07/10 21:57:29  ahabeeb
  --$ signature change due to new x_offer_info column
  --$
  --$ Revision 1.3  2012/04/16 13:12:51  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$ Revision 1.2  2012/04/03 15:11:27  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  --********************************************************************************
  --
  -- CR16379 Start KACOSTA 03/06/2012
  l_b_debug BOOLEAN := FALSE;
  -- CR16379 End KACOSTA 03/06/2012
  --
  FUNCTION checkesntech(ip_esn IN VARCHAR2) RETURN VARCHAR2;
  --
  FUNCTION getobjid
  (
    ip_item_name  IN VARCHAR2
   ,ip_item_type  IN VARCHAR2
   ,op_item_objid OUT NUMBER
  ) RETURN BOOLEAN;
  --
  PROCEDURE setstatus
  (
    op_msg       OUT VARCHAR2
   ,op_err       OUT VARCHAR2
   ,op_no_offer  OUT VARCHAR2
   ,op_inv_offer OUT VARCHAR2
   ,op_qual_cnt  OUT NUMBER
  );
  --
  PROCEDURE settimecode
  (
    op_msg OUT VARCHAR2
   ,op_err OUT VARCHAR2
  );
  --
  FUNCTION gettimecode
  (
    ip_coupon_ref_no IN VARCHAR2
   ,ip_sub_esn       IN VARCHAR2
   ,ip_ref_esn       IN VARCHAR2
   ,ip_promo_type    IN VARCHAR2
   ,ip_part_number   IN VARCHAR2
   ,ip_pin_code      IN VARCHAR2
   ,op_err           OUT VARCHAR2
  ) RETURN BOOLEAN;
  --
  PROCEDURE upd_resub_coupon(op_msg OUT VARCHAR2);
  --
  PROCEDURE offer_maintenance
  (
    ip_offer      IN sa.x_offer_info.name%TYPE
   ,ip_promotype  IN sa.x_offer_info.promo_type%TYPE
   ,ip_offertype  IN sa.x_offer_info.offer_type%TYPE
   ,ip_offerdesc  IN sa.x_offer_info.offer_desc%TYPE
   ,ip_cashvalue  IN sa.x_offer_info.cash_value%TYPE
   ,ip_unitvalue  IN sa.x_offer_info.unit_value%TYPE
   ,ip_partnum    IN sa.x_offer_info.part_number%TYPE
   ,ip_technology IN sa.x_offer_info.technology%TYPE
   ,ip_startdate  IN sa.x_offer_info.start_date%TYPE
   ,ip_enddate    IN sa.x_offer_info.end_date%TYPE
   ,ip_pnum_objid IN sa.x_offer_info.offerinfo2pnum%TYPE
   ,op_result     OUT NUMBER
   , /*0=Ok ,1=Error*/op_msg        OUT VARCHAR2 /*Error Message if op_result = 1 otherwise = OK*/
  );
  --
  -- CR16379 Start KACOSTA 03/06/2012
  --*******************************************
  -- Function to check if an ESN is currently enrolled
  -- into a promotion group by promotion
  --*******************************************
  --
  FUNCTION enrolled_promo_group_by_promo
  (
    p_esn        IN table_part_inst.part_serial_no%TYPE
   ,p_promo_code IN table_x_promotion.x_promo_code%TYPE
  ) RETURN INTEGER;
  --
  --*******************************************
  -- Function to check if an ESN is currently enrolled
  -- into both Double and Triple Minute program
  --*******************************************
  --
  FUNCTION is_esn_both_double_and_triple(p_esn IN table_part_inst.part_serial_no%TYPE) RETURN BOOLEAN;
  --
  --*******************************************
  -- Procedure to expire ESN group2esn Double Minute program record
  -- if the ESN is currently enrolled into Triple Minute program
  --*******************************************
  --
  PROCEDURE expire_double_if_esn_is_triple
  (
    p_esn           IN table_part_inst.part_serial_no%TYPE
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --
  --*******************************************
  -- Procedure to retrieve an ESN program type (promotion group)
  -- Will be display on the customer profile in WebCSR
  --*******************************************
  --
  PROCEDURE get_esn_program_type_prm_group
  (
    p_esn           IN table_part_inst.part_serial_no%TYPE
   ,p_program_type  OUT table_x_promotion_group.group_name%TYPE
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  );
  -- CR16379 End KACOSTA 03/06/2012

  --New procedure added for CR42361
   PROCEDURE validate_promo_code_ext
  (
   p_esn                     VARCHAR2,
   p_red_code01              VARCHAR2 DEFAULT NULL,
   p_red_code02              VARCHAR2 DEFAULT NULL,
   p_red_code03              VARCHAR2 DEFAULT NULL,
   p_red_code04              VARCHAR2 DEFAULT NULL,
   p_red_code05              VARCHAR2 DEFAULT NULL,
   p_red_code06              VARCHAR2 DEFAULT NULL,
   p_red_code07              VARCHAR2 DEFAULT NULL,
   p_red_code08              VARCHAR2 DEFAULT NULL,
   p_red_code09              VARCHAR2 DEFAULT NULL,
   p_red_code10              VARCHAR2 DEFAULT NULL,
   p_technology              VARCHAR2,
   p_transaction_amount      NUMBER,
   p_source_system           VARCHAR2,
   p_promo_code              VARCHAR2,
   p_transaction_type        VARCHAR2,
   p_zipcode                 VARCHAR2,
   p_language                VARCHAR2,
   p_fail_flag               NUMBER, --CR2739
   p_discount_amount         OUT VARCHAR2,
   p_promo_units             OUT NUMBER,
   p_sms                     OUT NUMBER,
   p_data_mb                 OUT NUMBER,
   p_applicable_device_type  OUT VARCHAR2,
   p_access_days             OUT NUMBER,
   p_status                  OUT VARCHAR2,
   p_msg                     OUT VARCHAR2
 );

 --New procedure added for CR42361
--

--CR44459  Starts
--Procedure to out promo ref cursor based on brand
PROCEDURE get_purchase_promos
                             (
                             i_brand       IN  VARCHAR2,
                             o_purchpromos OUT SYS_REFCURSOR,
                             o_error_code  OUT VARCHAR2,
                             o_error_msg   OUT VARCHAR2
                             );

FUNCTION sf_promo_check
                      (
                       i_promo_objid   IN  VARCHAR2,
                       i_param1        IN  VARCHAR2 DEFAULT NULL,
                       i_param1_value  IN  VARCHAR2 DEFAULT NULL,
                       i_param2        IN  VARCHAR2 DEFAULT NULL,
                       i_param2_value  IN  VARCHAR2 DEFAULT NULL,
                       i_param3        IN  VARCHAR2 DEFAULT NULL,
                       i_param3_value  IN  VARCHAR2 DEFAULT NULL,
                       i_param4        IN  VARCHAR2 DEFAULT NULL,
                       i_param4_value  IN  VARCHAR2 DEFAULT NULL,
                       i_param5        IN  VARCHAR2 DEFAULT NULL,
                       i_param5_value  IN  VARCHAR2 DEFAULT NULL,
                       i_param6        IN  VARCHAR2 DEFAULT NULL,
                       i_param6_value  IN  VARCHAR2 DEFAULT NULL
                      )
                      RETURN NUMBER;

PROCEDURE get_eligible_promo
                           (
                            i_promo_type  IN  VARCHAR2,
                            i_part_number IN  VARCHAR2 DEFAULT NULL,
                            i_quantity    IN  VARCHAR2 DEFAULT NULL,
                            o_promo_code  OUT VARCHAR2,
                            o_promo_objid OUT VARCHAR2,
                            o_discount    OUT VARCHAR2,
                            o_error_code  OUT VARCHAR2,
                            o_error_msg   OUT VARCHAR2
                           );
--CR44459  Ends

-- CR48480_Amazon_Activation_Integration_Release

PROCEDURE get_authenticated_promos
                                   (
                                    i_esn                    IN     VARCHAR2,  -- ESN.
                                    i_program_objid          IN     NUMBER,    -- Billing program objid.
                                    i_partner_name           IN     VARCHAR2,  -- Partner name ex: AMAZON WEB ORDERS, Best Buy, Ebay
                                    i_ar_promo_flag          IN     VARCHAR2,  -- Onetime Purchase or Enrollment BPEnrollment
                                    o_promo_objid               OUT NUMBER,
                                    o_promo_code                OUT VARCHAR2,
                                    o_script_id                 OUT VARCHAR2,
                                    o_error_code                OUT NUMBER,
                                    o_error_msg                 OUT VARCHAR2,
                                    i_ignore_attached_promo IN VARCHAR2 DEFAULT 'N'
                                  );

PROCEDURE  get_esn_promo_discount_code
                                        (
                                         i_esn             IN      VARCHAR2,
                                         i_promo_objid     IN      VARCHAR2,
                                         o_discount_code       OUT VARCHAR2,
                                         o_error_code          OUT NUMBER,
                                         o_error_msg           OUT VARCHAR2
                                        );

-- CR48480_Amazon_Activation_Integration_Release End

--CR46315

FUNCTION sf_data_promo_check
                           (
                           p_promo_objid     IN VARCHAR2,
                           p_esn             IN VARCHAR2,
                           p_service_plan_id IN VARCHAR2,
                           p_transaction     IN VARCHAR2
                           )
                           RETURN NUMBER;

PROCEDURE SP_GET_ELIGIBLE_DATA_PROMO
                                   (
                                   p_promo_type          VARCHAR2,
                                   p_esn                 VARCHAR2,
                                   p_calltrans_objid     VARCHAR2,
                                   p_action_type         VARCHAR2,
                                   p_ig_order_type       VARCHAR2,
                                   op_promo_code     OUT VARCHAR2,
                                   op_promo_objid    OUT VARCHAR2,
                                   op_error_code     OUT VARCHAR2,
                                   op_error_msg      OUT VARCHAR2
                                   );

PROCEDURE sp_ins_esn_promo_hist(ip_esn			           IN 	VARCHAR2,
                                ip_calltrans_id	       IN 	VARCHAR2,
                                ip_promo_objid         IN 	VARCHAR2,
                                ip_expiration_date     IN 	VARCHAR2,
                                ip_bucket_id           IN 	VARCHAR2,
                                op_error_code          OUT 	VARCHAR2,
                                op_error_msg           OUT 	VARCHAR2,
                                ip_discount_list       IN   sa.discount_code_tab DEFAULT NULL   -- CR48480
                                );

PROCEDURE update_promo_hist(
                           IP_ESN         IN  VARCHAR2,
                           OP_ERROR_CODE  OUT VARCHAR2,
                           OP_ERROR_MSG   OUT VARCHAR2
                           );

END promotion_pkg;
/