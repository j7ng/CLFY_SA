CREATE OR REPLACE PACKAGE sa."SP_RUNTIME_PROMO"
IS
   /*****************************************************************
    * Package Name: sp_runtime_promo
    * Description: The package is called by IVR and Clarify
    *              to get free units of runtime promotion for a ESN
    *
    * Created by: SL
    * Date:  11/14/2000
    *
    * History
    * -------------------------------------------------------------
    * 05/03/01          SL                 Add Stack Day     050301
    * 05/17/01          SL                 Add promo code Parameter
    *                                      051701
    * 08/16/02          SL                 Promotional code project
    *                                      add more params
   * 05/08/06 1.2       VA             CR5221-1 changes
   * 05/12/06 1.3       VA          Fix for CR5221-1
   * 10/13/06 1.4    CL       CR5631
   * 10/28/06 1.5    CL      CR5631-Commented out the functions that are not in use
   * 11/07/06 1.6  VA       Same as in CLFYKOZ
   * 30/01/06 1.7  TZ       CR5854   add objid input parameter to procedure main and doruntimepromo
     06/14/07 1.8  CI       CR6209;  block promo on free airtime
    *****************************************************************/
   TYPE red_card_rec_t IS RECORD (
      red_code        VARCHAR2 (30),
      units           NUMBER,
      access_days     NUMBER,
      part_num        VARCHAR2 (30),
      annual_status   VARCHAR2 (10),
      part_type       VARCHAR2 (20),                             -- sl 050301
      x_promo_code    VARCHAR2 (10),                            -- gp 04/02/03
      is_free_corp    number(1)                                 --CR6209
   );

   TYPE red_card_tab_t IS TABLE OF red_card_rec_t
      INDEX BY BINARY_INTEGER;

--CR5221-1 Start
   TYPE promo_t IS RECORD (
      x_promo_code   VARCHAR2 (30),
      x_units        NUMBER,
      p_objid        NUMBER,
      p_type         VARCHAR2 (30)
   );

   TYPE promo_tab_t IS TABLE OF promo_t
      INDEX BY BINARY_INTEGER;

--CR5221-1 End
   --12/12/00
   TYPE promo_rec_t IS RECORD (
      promo_objid   NUMBER,
      units         NUMBER,
      access_days   NUMBER,
      MESSAGE       LONG,
      promo_code    VARCHAR (50),
      promo_usage   NUMBER
   );

   /*************************************************************************
   * Procedure: main
   * Description: Scan through all the runtime promotion for the ESN.
   *              If qulified, insert a row into table_x_pending_redemption
   *
   **************************************************************************/
/********************************* cwl speed up promo */
   FUNCTION test_rt_fun (p_units IN VARCHAR2, p_type IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION test_promo_rt_fun (p_promo_code IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION test_access_days_rt_fun (p_access_days IN NUMBER)
      RETURN NUMBER;

   FUNCTION test_group_rt_fun (p_group_name IN VARCHAR2)
      RETURN NUMBER;

   TYPE group_t IS RECORD (
      x_group_name   VARCHAR2 (30)
   );

   TYPE group_tab_t IS TABLE OF group_t
      INDEX BY BINARY_INTEGER;

   g_group_name_tab     group_tab_t;

/********************************* cwl speed up promo */
   PROCEDURE main (
      p_esn                      VARCHAR2,
      p_units                    NUMBER,
      p_access_days              NUMBER,
      p_red_code01               VARCHAR2,
      p_red_code02               VARCHAR2 DEFAULT NULL,
      p_red_code03               VARCHAR2 DEFAULT NULL,
      p_red_code04               VARCHAR2 DEFAULT NULL,
      p_red_code05               VARCHAR2 DEFAULT NULL,
      p_red_code06               VARCHAR2 DEFAULT NULL,
      p_red_code07               VARCHAR2 DEFAULT NULL,
      p_red_code08               VARCHAR2 DEFAULT NULL,
      p_red_code09               VARCHAR2 DEFAULT NULL,
      p_red_code10               VARCHAR2 DEFAULT NULL,
      p_source_system            VARCHAR2,                         -- 08/14/02
      p_promo_code               VARCHAR2,                         -- 08/14/02
      p_transaction_type         VARCHAR2,                         -- 08/14/02
      p_zipcode                  VARCHAR2,                         -- 08/14/02
      p_language                 VARCHAR2,                         -- 08/14/02
      p_objid                    NUMBER,                           -- 01/30/07          CR5854  call transaction id
      p_units_out          OUT   NUMBER,
      p_access_days_out    OUT   NUMBER,
      p_status             OUT   VARCHAR2,
      p_msg                OUT   VARCHAR2,
      p_promo_out_code     OUT   VARCHAR2                          --051701 SL
   );

   PROCEDURE doruntimepromo (
      p_esn                      VARCHAR2,
      p_units                    NUMBER,
      p_access_days              NUMBER,
      p_red_code01               VARCHAR2,
      p_red_code02               VARCHAR2 DEFAULT NULL,
      p_red_code03               VARCHAR2 DEFAULT NULL,
      p_red_code04               VARCHAR2 DEFAULT NULL,
      p_red_code05               VARCHAR2 DEFAULT NULL,
      p_red_code06               VARCHAR2 DEFAULT NULL,
      p_red_code07               VARCHAR2 DEFAULT NULL,
      p_red_code08               VARCHAR2 DEFAULT NULL,
      p_red_code09               VARCHAR2 DEFAULT NULL,
      p_red_code10               VARCHAR2 DEFAULT NULL,
      p_source_system            VARCHAR2,                         -- 08/14/02
      p_promo_code               VARCHAR2,                         -- 08/14/02
      p_transaction_type         VARCHAR2,                         -- 08/14/02
      p_zipcode                  VARCHAR2,                         -- 08/14/02
      p_language                 VARCHAR2,                         -- 08/14/02
      p_objid                    NUMBER,                           -- 01/30/07          CR5854      call transaction id
      p_units_out          OUT   NUMBER,
      p_access_days_out    OUT   NUMBER,
      p_status             OUT   VARCHAR2,
      p_msg                OUT   VARCHAR2,
      p_promo_out_code     OUT   VARCHAR2                          --051701 SL
   );

   /******************************************
   * Function get_esn_objid
   * IN: varchar2
   * RETURN: number  -- objid
   *******************************************/
   FUNCTION get_esn_objid (p_esn VARCHAR2)
      RETURN NUMBER;

   /******************************************
    * Function get_esn_part_inst_objid
    * IN: varchar2
    * OUT: number  -- objid
   *******************************************/
   FUNCTION get_esn_part_inst_objid (p_esn VARCHAR2)
      RETURN NUMBER;

   /******************************************
   * Function is_annual_plan
   * IN: esn (varchar2)
   * RETURN: Boolean
   *******************************************/
   FUNCTION is_annual_plan (p_esn VARCHAR2)
      RETURN BOOLEAN;

   /******************************************
   * Function get_ann_promogrp_objid
   * Description: get annual promotion group objid
   * IN: None
   * OUT: Number
   *******************************************/-- 08/16/02 FUNCTION get_ann_promogrp_objid  RETURN Number;
   FUNCTION get_promogrp_objid (p_group_name VARCHAR2)
      RETURN NUMBER;

   /******************************************
   * Procedure get_red_card_info
   * IN:  redemption card record
   * OUT: Boolean
   *******************************************/
   PROCEDURE get_red_card_info (p_card_rec IN OUT red_card_rec_t);

   /******************************************
   * Procedure get_ann_promo_info
   * IN AND OUT:  promo info record promo_rec
   *******************************************/--12/12/00 FUNCTION get_ann_promo_info RETURN promo_rec  ;
   FUNCTION get_ann_promo_info
      RETURN promo_rec_t;

   g_red_card_tab       red_card_tab_t;                    -- Input parameters
   g_ann_card_tab       red_card_tab_t;                         -- Annual card
   g_non_ann_card_tab   red_card_tab_t;                     -- Non-Annual card
   g_promo_tab          promo_tab_t;                               -- CR5221-1

   PROCEDURE debug01;

/*******************************************
--  10/18/02 Changes
  * Procedure get_esn_info
  * IN: varchar2
  * OUT: date,varchar2 -- ship date and status
/*******************************************/
   PROCEDURE get_esn_info (
      p_esn           IN       VARCHAR2,
      esn_ship_date   OUT      DATE,
      esn_status      OUT      VARCHAR2
   );

--End 10/18/02 Changes
/*******************************************/
   PROCEDURE crea_promo_arr (
      p_promo_code         VARCHAR2,
      p_units              NUMBER,
      p_counter            NUMBER,
      p_objid              NUMBER,
      p_type               VARCHAR2,
      p_is_check     OUT   NUMBER
   );
END;
/