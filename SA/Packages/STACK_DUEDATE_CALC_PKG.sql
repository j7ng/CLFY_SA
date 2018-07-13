CREATE OR REPLACE PACKAGE sa."STACK_DUEDATE_CALC_PKG"
IS
/********************************************************************************/
   /*    Copyright ) 2004 Tracfone  Wireless Inc. All rights reserved              */
   /*                                                                              */
   /* NAME:         STACK_DUEDATE_CALC(PACKAGE SPECIFICATION)                      */
   /* PURPOSE:      To calculate the stacking days for an esn during redemption    */
   /* FREQUENCY:                                                                   */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                               */
   /* REVISIONS:                                                                   */
   /* VERSION  DATE     WHO        PURPOSE                                         */
   /* ------  ----     ------      --------------------------------------------    */
   /* 1.0    01/15/04  VAdapa      Initial  Revision                               */
   /* 1.1    08/27/04  VAdapa      CR3181 - Fix for DMPP Issue                     */
   /* 1.2    09/22/04  VAdapa      CR3190 - Net 10 Changes                         */
   /* 1.3    06/20/05  VAdapa      CR4184 - EME Winback Double minute/double day Promo on any non-annual redeemed cards
   /* 1.4    07/22/05  VAdapa      CR4282 -  NET10 - Increase Service Days on 300 and 600 minute airtime cards
   /* 1.5    08/119/05 VAdapa      CR4392
   /* 1.6    03/23/06  Nguada      CR5161 Filter Double Access for Net10 cards
   /* 1.7/1.8 /1.9 02/01/07 VAdapa CR5848 - Tracfone and Net10 Airtime Price Change
                                   Remove the Stacking limit based on table_x_parameter setting - Added a new function
   /* 1.8    03/09/07  RSI         CR4479  - Billing Platform changes

  /* new pvcs structure
  /* 1.0      8/27/09 NGuada     BRAND_SEP Separate the Brand and Source System
  /********************************************************************************/
   TYPE red_card_rec_t IS RECORD (
      red_code           VARCHAR2 (30),
      units              NUMBER,
      access_days        NUMBER,
      part_num           VARCHAR2 (30),
      annual_status      VARCHAR2 (10),
      part_type          VARCHAR2 (20),
      x_promo_code       VARCHAR2 (10),
      brand_name         VARCHAR2 (30)
   );

   TYPE red_card_tab_t IS TABLE OF red_card_rec_t
      INDEX BY BINARY_INTEGER;

   g_red_card_tab       red_card_tab_t;                    -- Input parameters
   g_ann_card_tab       red_card_tab_t;                         -- Annual card
   g_non_ann_card_tab   red_card_tab_t;                     -- Non-Annual card
   g_dmpp_card_tab      red_card_tab_t;                            --DMPP card
   g_net10_card_tab     red_card_tab_t;                           --NET10 card

   --
   /********************************************************************************
   * Function  :   CALC_REG_CARD_DD
   * Purpose   :   To calculate the days to stack for a non-annual plan esn when
   *               redeeming non-annual plan card
   /********************************************************************************/
   FUNCTION calc_reg_card_dd (
      p_esn              IN   VARCHAR2,                               --CR4184
      p_curr_expy_date   IN   DATE,
      p_ann_card_cnt     IN   NUMBER,
      p_dmpp_card_cnt    IN   NUMBER,
      p_promo_days       IN   NUMBER                                  --CR4392
   )
      RETURN DATE;

   --
   /********************************************************************************
   * Function  :   CALC_APDM_REG_CARD_DD
   * Purpose   :   To calculate the days to stack for an annual plan esn when
   *               redeeming non-annual plan card
   /********************************************************************************/
   FUNCTION calc_apdm_reg_card_dd (
      p_esn              IN   VARCHAR2,                               --CR4184
      p_curr_expy_date   IN   DATE,
      p_ann_card_cnt     IN   NUMBER,
      p_dmpp_card_cnt    IN   NUMBER,
      p_promo_days       IN   NUMBER                                  --CR4392
   )
      RETURN DATE;

   --
   /********************************************************************************
   * Function  :   CALC_365_CARD_DD
   * Purpose   :   To calculate the days to stack when redeeming an annual plan card
   *               or a double minute prepaid plan card
   /********************************************************************************/
   FUNCTION calc_365_card_dd (
      p_curr_expy_date   IN   DATE,
      p_promo_days       IN   NUMBER                                  --CR4392
   )
      RETURN DATE;

   --
   /********************************************************************************
   * Procedure :   PUT_DMPP_INFO
   * Purpose   :   To calculate the days to stack for double minutes
   /********************************************************************************/
   FUNCTION put_dmpp_info (
      p_esn              IN   VARCHAR2,
      p_esn_type         IN   VARCHAR2,
      p_curr_expy_date   IN   DATE,
      p_sourcesystem     IN   VARCHAR2                                --CR3181
   )
      RETURN BOOLEAN;

   --
   /********************************************************************************
   * Procedure :   MAIN
   * Purpose   :   Calls to calculate the days to stack for non-annual or annual or
   *               double minute card redemptions
   /********************************************************************************/
   PROCEDURE main (
      p_esn                   VARCHAR2,
      p_esn_type              VARCHAR2,
      p_red_code01            VARCHAR2,
      p_red_code02            VARCHAR2 DEFAULT NULL,
      p_red_code03            VARCHAR2 DEFAULT NULL,
      p_red_code04            VARCHAR2 DEFAULT NULL,
      p_red_code05            VARCHAR2 DEFAULT NULL,
      p_red_code06            VARCHAR2 DEFAULT NULL,
      p_red_code07            VARCHAR2 DEFAULT NULL,
      p_red_code08            VARCHAR2 DEFAULT NULL,
      p_red_code09            VARCHAR2 DEFAULT NULL,
      p_red_code10            VARCHAR2 DEFAULT NULL,
      p_curr_due_date         VARCHAR2,
      p_trans_type            VARCHAR2,
      p_sourcesystem          VARCHAR2,                               --CR3181
      p_promo_days            NUMBER,                                 --CR4392
      p_new_due_date    OUT   VARCHAR2,
      p_status          OUT   VARCHAR2,
      p_msg             OUT   VARCHAR2
   );

   --
   /********************************************************************************
   * Procedure :   GET_RED_CARD_INFO
   * Purpose   :   To get the card info
   /********************************************************************************/
   PROCEDURE get_red_card_info (p_card_rec IN OUT red_card_rec_t);

   --
   /********************************************************************************
   * Function :   IS_AP_TRANS_SAMEDAY
   * Purpose   :  To find whether esn has any annual plan card transactions done
               on the same day
   /********************************************************************************/
   FUNCTION is_ap_trans_sameday (p_esn IN VARCHAR2)
      RETURN BOOLEAN;

   --
   /********************************************************************************
   * Function :   IS_AE_ESN
   * Purpose   :  To find whether the esn is an annual service esn (i.e. esn's part
               number is attached to one year service promotion)
   /********************************************************************************/
   FUNCTION is_ae_esn (p_esn IN VARCHAR2)
      RETURN BOOLEAN;

   --CR3190 Start
   /********************************************************************************
   * Function  :   CALC_NET10_DD
   * Purpose   :   To calculate the due date for Net 10 Phones (No Stacking)
   /********************************************************************************/
   FUNCTION calc_net10_dd (
      p_esn              IN   VARCHAR2,                               --CR4282
      p_curr_expy_date   IN   DATE,
      p_access_days      IN   NUMBER,
      p_units            IN   NUMBER                                  --CR4282
   )
      RETURN DATE;

   --CR3190 End
   --
   --CR4184 starts
   /********************************************************************************
   * Procedure :   GET_STACKDAYS_MULTIPLIER
   * Purpose   :   To get the days and stack multiplier values for an esn
   /********************************************************************************/
   PROCEDURE get_stackdays_multiplier (
      p_esn                IN       VARCHAR2,
      p_days_multiplier    OUT      NUMBER,
      p_stack_multiplier   OUT      NUMBER
   );

   --CR4184 Ends
   --CR4282 starts
   /********************************************************************************
   * Procedure :   GET_NET10DAYS_MULTIPLIER
   * Purpose   :   To get the days multiplier values for a NET10 esn
   /********************************************************************************/
   PROCEDURE get_net10days_multiplier (
      p_esn               IN       VARCHAR2,
      p_units             IN       NUMBER,
      p_days              IN       NUMBER,
      p_days_multiplier   OUT      NUMBER
   );

--CR4282 Ends
--CR5848
   FUNCTION calc_nolimit_dd (
      p_esn              IN   VARCHAR2,                               --CR4282
      p_curr_expy_date   IN   DATE,
      p_access_days      IN   NUMBER,
      p_promo_days       IN   NUMBER
   )
      RETURN DATE;
--CR5848
END stack_duedate_calc_pkg;
/