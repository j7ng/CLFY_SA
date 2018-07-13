CREATE OR REPLACE PACKAGE sa."SWITCH_BASED"
IS

/********************************************************************************/
   /*    Copyright ) 2009 Tracfone  Wireless Inc. All rights reserved              */
   /*                                                                              */
   /* NAME:         SWITCH_BASED(PACKAGE SPECIFICATION)                            */
   /* PURPOSE:      switch based functionality                                     */
   /* FREQUENCY:                                                                   */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                               */
   /* REVISIONS:                                                                   */
   /* VERSION  DATE     WHO        PURPOSE                                         */
   /* ------  ----     ------      --------------------------------------------    */
   /* 1.0    04/07/09  jvalencia      Initial  Revision                            */
   /* 1.1    04/19/09  cyin           Add service plan days                        */
   /* 1.2    04/20/09  cyin           Delete Part_Inst row with T number           */
   /* 1.3    04/21/09  cyin           Error handling                               */
   /* 1.4    04/27/09  jvalencia      Update input/output parameter types          */
   /* 1.5    10/12/09  jvalencia      BUNDLE_II_A change p_switchbased to          */
   /*                                 p_msid in passive activation                 */
   /********************************************************************************/

  PROCEDURE passive_activation
    ( p_min IN VARCHAR2
      , p_esn IN VARCHAR2
      , p_msid IN VARCHAR2
      , p_err_num OUT NUMBER
      , p_err_string OUT VARCHAR2
      , p_due_date OUT DATE
    );

END SWITCH_BASED;
/