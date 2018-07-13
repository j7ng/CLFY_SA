CREATE OR REPLACE PACKAGE sa."AUTOPAY_PROMO_PKG" IS
 /*****************************************************************
  * Package Name: autopay_promo_pkg
  * Purpose     : The package is called from the SP_RUNTIME_PROMO to get the additional
  *               promotional units
  *               due to the newly introduced
  *               plans for an ESN:
  *               1.Autopay Plan,
  *               2.Hybrid Pre Paid / Post Paid plan
  *
  * Author      : TCS
  * Date        :  05/23/2002
  * History     :
   ---------------------------------------------------------------------
    06/17/2002          TCS                 Initial version


  *********************************************************************/
 TYPE red_card_rec_t IS RECORD (
                             red_code varchar2(30),
                             units number,
                             access_days number,
                             part_num varchar2(30),
                             annual_status varchar2(10),
                             part_type varchar2(20)
                            );
 TYPE red_card_tab_t IS TABLE OF red_card_rec_t
 INDEX BY BINARY_INTEGER;

 TYPE promo_rec_t IS RECORD ( promo_objid number,
                              units number,
                              access_days number,
                              message long,
                              promo_code varchar(50),
                              x_sql_statement long  );

 /*************************************************************************
 * Procedure   : main
 * Description : Check if the ESN is registered for Autopay/Hybrid plan  and
		 if qualified ,insert a row in the x_pending_redemption.

 **************************************************************************/
 PROCEDURE main
                         ( p_esn varchar2,
                           p_units number,
                           p_units_in number,
                           p_promo_ct number,
                           p_msg_in varchar2,
                           p_promo_code_in varchar2,
                           p_site_part_objid number,
		           p_red_code01 varchar2,
                           p_red_code02 varchar2 DEFAULT NULL,
                           p_red_code03 varchar2 DEFAULT NULL,
                           p_red_code04 varchar2 DEFAULT NULL,
                           p_red_code05 varchar2 DEFAULT NULL,
                           p_red_code06 varchar2 DEFAULT NULL,
                           p_red_code07 varchar2 DEFAULT NULL,
                           p_red_code08 varchar2 DEFAULT NULL,
                           p_red_code09 varchar2 DEFAULT NULL,
                           p_red_code10 varchar2 DEFAULT NULL,
                           p_units_out OUT number,
                           p_status OUT varchar2,
                           p_msg OUT varchar2,
                           p_promo_code OUT varchar2
                           ) ;

 PROCEDURE DoautopayPromo_prc
                         ( p_esn varchar2,
                           p_units number,
                           p_units_in number,
                           p_promo_ct number,
                           p_msg_in varchar2,
                           p_promo_code_in varchar2,
			   p_site_part_objid number,
		           p_red_code01 varchar2,
                           p_red_code02 varchar2 DEFAULT NULL,
                           p_red_code03 varchar2 DEFAULT NULL,
                           p_red_code04 varchar2 DEFAULT NULL,
                           p_red_code05 varchar2 DEFAULT NULL,
                           p_red_code06 varchar2 DEFAULT NULL,
                           p_red_code07 varchar2 DEFAULT NULL,
                           p_red_code08 varchar2 DEFAULT NULL,
                           p_red_code09 varchar2 DEFAULT NULL,
                           p_red_code10 varchar2 DEFAULT NULL,
                           p_units_out OUT number,
                           p_status OUT varchar2,
                           p_msg OUT varchar2,
                           p_promo_code OUT varchar2
                           ) ;

 /******************************************
 * Function get_autopay_detai_fun
 * IN: ESN (varchar2)
 * RETURN:number
 *******************************************/
 FUNCTION get_autopay_detail_fun (p_esn varchar2) return number;

 /******************************************
 * Procedure get_red_card_info_prc
 * IN AND OUT:  redemption card record
 ********************************************/
 PROCEDURE get_red_card_info_prc(p_card_rec IN OUT red_card_rec_t) ;

 /******************************************
 * Function get_autopay_promo_info_fun
 * OUT: Autopay promo info record
 *******************************************/
  FUNCTION get_autopay_promo_info_fun RETURN promo_rec_t  ;

 /******************************************
 * Function get_hybrid_promo_info_fun
 * IN : Redemption card units.
 * OUT:  Hybrid promo info record
 *******************************************/
  FUNCTION get_hybrid_promo_info_fun(p_red_units  varchar2) RETURN promo_rec_t  ;

 /******************************************
 * Function is_autopay_plan_fun
 * IN: esn (varchar2)
 * RETURN: Boolean
 *******************************************/
 FUNCTION is_autopay_plan_fun ( p_esn varchar2) RETURN BOOLEAN;

 /******************************************
 * Function is_Hybrid_plan_fun
 * IN: esn (varchar2)
 * RETURN: Boolean
 *******************************************/
 FUNCTION is_hybrid_plan_fun ( p_esn varchar2) RETURN BOOLEAN;

 g_red_card_tab red_card_tab_t ;         -- Input parameters

END autopay_promo_pkg;
/