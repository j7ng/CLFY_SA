CREATE OR REPLACE PACKAGE sa."VALIDATE_RED_CARD_PKG" AS
/******************************************************************************/
 /* Copyright 2002 Tracfone Wireless Inc. All rights reserved */
 /* */
 /* NAME: SA.VALIDATE_RED_CARD_PKG */
 /* PURPOSE: To validate REDEMPTION CARDS */
 /* FREQUENCY: */
 /* PLATFORMS: Oracle 9.2.0.7 AND newer versions.                             */
   /*                                                                            */
   /* REVISIONS:                                                                 */
   /* VERSION  DATE        WHO          PURPOSE                                  */
   /* -------  ---------- -----  ---------------------------------------------   */
   /*  1.0/1.10     09/12/2007   GKharche     Initial  Revision                               */
   /* Defect # 1351 - Adding a new cursor,variable and IF condition to handle Status 40 card        */
   /* 1.11          11/15/07        VAdapa        CR6962 - Redemption Failures (CBO)
   /******************************************************************************/
   /*NEW PLSQL STRUCTURE */
   /* 1.1          04/24/09        ICanavan  CR8663 - Walmart switch base
   /* 1.2          08/26/09        NGuada    BRAND_SEP references to x_restricted_use
   /*                                        and amigo are updated with table_bus_org values
   /******************************************************************************/
   TYPE rc_out IS REF CURSOR;

--------------------------------------
-- PROCEDURE OVERLOADED NOT NOT MODIFY
--------------------------------------
   PROCEDURE main (
      strredcard           IN       VARCHAR2,
      strsmpnumber         IN       VARCHAR2,
      strsourcesys         IN       VARCHAR2,
      stresn               IN       VARCHAR2,
      strsubsourcesystem   IN       VARCHAR2 DEFAULT NULL,
      strstatus            OUT      VARCHAR2,
      intunits             OUT      INTEGER,
      intdays              OUT      INTEGER,
      intamigo             OUT      INTEGER,
      strmsgnum            OUT      VARCHAR2,
      strmsgstr            OUT      VARCHAR2,
      strerrorpin          OUT      VARCHAR2
   );

   PROCEDURE main (
      strredcard     IN       VARCHAR2,
      strsmpnumber   IN       VARCHAR2,
      strsourcesys   IN       VARCHAR2,
      stresn         IN       VARCHAR2,
      po_refcursor     OUT SYS_REFCURSOR
   );

   PROCEDURE getredcard (
      strredcard     IN       VARCHAR2,
      strsmpnumber   IN       VARCHAR2,
      rc_rc          IN OUT   rc_out
   );

   PROCEDURE getpartinstredcard2part (
      strredcard   IN       VARCHAR2,
      rc_pric2     IN OUT   rc_out
   );

   PROCEDURE inlasttransaction (
      stresn        IN       VARCHAR2,
      strredcard    IN       VARCHAR2,
      p_blnreturn   OUT      BOOLEAN
   );

   PROCEDURE getpartinstredcard (
      strredcard     IN       VARCHAR2,
      strsmpnumber   IN       VARCHAR2,
      p_rc_pric      IN OUT   rc_out
   );

   PROCEDURE getposacardinvredcard (
      strredcard    IN       VARCHAR2,
      p_intreturn   OUT      INTEGER
   );

   PROCEDURE resetposacard (strselid IN VARCHAR2, strreason IN VARCHAR2);

   PROCEDURE getredcard2calltrans (
      strcalltransid   IN       NUMBER,
      rc2ct_rc         IN OUT   rc_out
   );

   PROCEDURE getpartclass (strredcard IN VARCHAR2, pc_rc IN OUT rc_out);

   procedure process_batch(
        ip_strRedCardList IN VARCHAR2,
        ip_strSmpNumber IN VARCHAR2,
        ip_strSourceSys IN VARCHAR2,
        ip_strEsn IN VARCHAR2,
        op_result_set out sys_refcursor);

   type out_rec_ty is record(
          strRedCard   varchar2(30),
          strstatus    VARCHAR2(100),
          intunits     NUMBER,
          intdays      NUMBER,
          strcardbrand VARCHAR2(100),
          strmsgnum    VARCHAR2(30),
          strmsgstr    VARCHAR2(100),
          strerrorpin   VARCHAR2(500),
          description  VARCHAR2(255),
          partnumber VARCHAR2(30),
          cardtype       VARCHAR2(20),
          parttype       VARCHAR2(20) ,
          x_web_card_desc VARCHAR2(100),
          x_sp_web_card_desc VARCHAR2(100),
          x_ild_type  NUMBER );
    -- CR 28465 WEBCSR Migration - Net10 + TracFone

   type out_tab_ty is table of out_rec_ty;
   out_tab out_tab_ty := out_tab_ty();
   function get_coll return out_tab_ty pipelined;

-- Validate pre posa card for WARP
PROCEDURE validate_pre_posa ( i_red_card           IN      VARCHAR2       ,
                              i_smp_number         IN      VARCHAR2       ,
                              i_sourcesystem       IN      VARCHAR2       ,
                              io_esn               IN OUT  VARCHAR2       ,
                              i_bus_org_id         IN      VARCHAR2       ,
                              i_client_id          IN      VARCHAR2       ,
                              o_refcursor          OUT     SYS_REFCURSOR  ,
                              o_available_capacity OUT     NUMBER         ,
							  o_err_code           OUT     NUMBER         ,
                              o_err_msg            OUT     VARCHAR2       );

--New function added for CR47988 IS_SL_RED_PN
FUNCTION IS_SL_RED_PN
                    (
                     p_part_num table_part_num.part_number%TYPE
                    )
RETURN VARCHAR2;

--New function added for CR47988 IS_SL_RED_PN
FUNCTION is_safelink(p_esn IN VARCHAR2,
                     p_min IN VARCHAR2)
RETURN VARCHAR2;

--New Function to determine if ESN is compatible with ST Add On Plans CR49890
FUNCTION is_addon_exclusion
                           (i_esn IN VARCHAR2)
RETURN VARCHAR2;

END validate_red_card_pkg;
/