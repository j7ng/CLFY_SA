CREATE OR REPLACE PACKAGE sa.red_card
AS
/*******************************************************************************************************
 * --$RCSfile: red_card_pkg.sql,v $
  --$Revision: 1.11 $
  --$Author: sraman $
  --$Date: 2017/07/12 20:47:32 $
  --$ $Log: red_card_pkg.sql,v $
  --$ Revision 1.11  2017/07/12 20:47:32  sraman
  --$ CR50939 WFM TAS a?? Correct dates on reactivation with AT PIN from Queue
  --$
  --$ Revision 1.10  2017/06/05 23:07:30  aganesan
  --$ CR51037 New procedure to retrieve queued and redeemed card details
  --$
  --$ Revision 1.9  2017/04/26 19:13:51  sgangineni
  --$ CR49696 - removed grant to rrp
  --$
  --$ Revision 1.8  2017/04/20 20:39:40  sgangineni
  --$ CR49696 - fix for defect #24030 - Added new parameter i_consumer in procedure p_get_reserved_softpin
  --$
  --$ Revision 1.7  2017/03/08 00:11:10  smeganathan
  --$ CR47564 WFM added new procedures p_get_discount_code p_get_service_days and p_get_discounts_service_days
  --$
  --$ Revision 1.6  2017/02/22 23:03:24  sraman
  --$ CR47564- added new procedure  GET_PIN_SMP_FROM_PARTNUM
  --$
  --$ Revision 1.5  2017/02/22 22:49:14  sraman
  --$ CR47564- added new procedure  GET_PIN_SMP_FROM_PARTNUM
  --$
  --$ Revision 1.4  2017/02/21 21:50:57  nsurapaneni
  --$ Added p_invalidate_pins procedure to red_card package to invalidate pins
  --$
  --$ Revision 1.1  2017/01/24 21:34:27  smeganathan
  --$ CR47564 new package to generate soft pin and for card related code
  --$
  --$ Revision 1.1  2017/01/19 16:34:57  SMEGANATHAN
  --$ CR47564 - Initial version
  *********************************************************************************************************/
--
-- Copied the standalone procedure to the package
FUNCTION fn_getsoftpin (ip_pin_part_num  IN table_part_inst.part_serial_no%TYPE,
                        ip_inv_bin_objid IN table_inv_bin.objid%TYPE DEFAULT 0,
                        p_consumer       IN table_x_cc_red_inv.x_consumer%TYPE DEFAULT NULL,
                        op_soft_pin      OUT table_x_cc_red_inv.x_red_card_number%TYPE,
                        op_smp_number    OUT table_x_cc_red_inv.x_smp%TYPE,
                        op_err_msg       OUT VARCHAR2)
RETURN NUMBER;
--
-- Generate the soft pin and attach it to ESN with RESERVED status
PROCEDURE p_get_reserved_softpin  ( i_esn             IN  VARCHAR2,
                                    i_pin_part_num    IN  VARCHAR2,
                                    i_inv_bin_objid   IN  NUMBER    DEFAULT 0,
                                    o_soft_pin        OUT VARCHAR2,
                                    o_smp_number      OUT VARCHAR2,
                                    o_err_str         OUT VARCHAR2,
                                    o_err_num         OUT NUMBER,
                                    i_consumer        IN  VARCHAR2 DEFAULT NULL--CR49696
                                  );

-- Procedure to invalidate pins.
PROCEDURE invalidate_queued_pins(i_red_card_pin_tab IN OUT red_card_pin_tab ,
                                    i_card_status      IN     VARCHAR2 DEFAULT '44',
                                    o_err_num          OUT    NUMBER,
                                    o_err_str          OUT    VARCHAR2);

--Procedure to accept list of ESN/MIN/part number , generate pin and add to reserve
PROCEDURE    GET_PIN_SMP_FROM_PARTNUM( op_plan_partnum_pin_det_tab IN OUT plan_partnum_pin_det_tab,
                                       o_err_code OUT VARCHAR2,
                                       o_err_msg OUT VARCHAR2 );
--
-- Procedure to get the discount code list based on the PIN
PROCEDURE p_get_discount_code ( i_pin                   IN    VARCHAR2,
                                o_discount_code_list    OUT   discount_code_tab,
                                o_err_code              OUT   VARCHAR2,
                                o_err_msg               OUT   VARCHAR2);
--
-- Procedure to get the BRM service days based on the PIN
PROCEDURE p_get_service_days ( i_pin                   IN    VARCHAR2,
                               o_service_days          OUT   NUMBER,
                               o_err_code              OUT   VARCHAR2,
                               o_err_msg               OUT   VARCHAR2);
--
-- Procedure to get the BRM service days based on the PIN
PROCEDURE p_get_discounts_service_days ( i_pin                   IN    VARCHAR2,
                                         o_discount_code_list    OUT   discount_code_tab,
                                         o_service_days          OUT   NUMBER,
                                         o_err_code              OUT   VARCHAR2,
                                         o_err_msg               OUT   VARCHAR2);
--

--CR51037 - WFM -  Start
FUNCTION get_service_plan_group(i_plan_part_number IN VARCHAR2)
RETURN VARCHAR2;
--
PROCEDURE get_esn_pin_redeem_details(i_esn                    IN  VARCHAR2 DEFAULT NULL ,
                                     i_min                    IN  VARCHAR2 DEFAULT NULL ,
				     o_redeem_pin_details_tbl OUT redeem_pin_details_tab,
				     o_error_num              OUT NUMBER                ,
				     o_error_msg              OUT VARCHAR2
				    );
--CR51037 - WFM -  End

PROCEDURE set_queued_pins_service_days ( i_red_card_pin_tab IN     red_card_pin_days_tab ,
                                         o_err_num          OUT    NUMBER,
                                         o_err_str          OUT    VARCHAR2 );


END red_card;
/