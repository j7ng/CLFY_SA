CREATE OR REPLACE PACKAGE sa."RUNTIME_UNITS_DAYS_PKG"
AS
/**************************************************************************/
/* Name         :   SA.RUNTIME_UNITS_DAYS_PKG
/* Purpose      :   Written for the new Promo Engine
/*
/* Author       :  Curt Liindner
/* Date          :  08/01/2008
/* Revisions    :
/* Version  Date      Who      Purpose
/* -------   --------          -------  --------------------------
/* 1.0      08/01/08      CL       Initial revision
/* 1.1      09/15/16    MG/VN       CR42361 : SmartphonesBYOP
/**************************************************************************/
   FUNCTION units_and_days (
      p_trans_type_lvl2   IN   VARCHAR2,
      p_trans_type_lvl3   IN   VARCHAR2,
      p_units00           IN   NUMBER,
      p_days00            IN   NUMBER,
      p_units01           IN   NUMBER,
      p_days01            IN   NUMBER,
      p_units02           IN   NUMBER,
      p_days02            IN   NUMBER,
      p_units03           IN   NUMBER,
      p_days03            IN   NUMBER,
      p_units04           IN   NUMBER,
      p_days04            IN   NUMBER,
      p_units05           IN   NUMBER,
      p_days05            IN   NUMBER,
      p_units06           IN   NUMBER,
      p_days06            IN   NUMBER,
      p_units07           IN   NUMBER,
      p_days07            IN   NUMBER,
      p_units08           IN   NUMBER,
      p_days08            IN   NUMBER,
      p_units09           IN   NUMBER,
      p_days09            IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION units_or_days (
      p_trans_type_lvl   IN   VARCHAR2,
      p_units00          IN   NUMBER,
      p_units01          IN   NUMBER,
      p_units02          IN   NUMBER,
      p_units03          IN   NUMBER,
      p_units04          IN   NUMBER,
      p_units05          IN   NUMBER,
      p_units06          IN   NUMBER,
      p_units07          IN   NUMBER,
      p_units08          IN   NUMBER,
      p_units09          IN   NUMBER
   )
      RETURN NUMBER;

   --CR42361 Start
     FUNCTION units_days_sms_data (
      p_trans_type_lvl2  IN   VARCHAR2,
      p_trans_type_lvl3   IN   VARCHAR2,
      p_trans_type_lvl4   IN   VARCHAR2,
      p_trans_type_lvl5   IN   VARCHAR2,
      p_units00           IN   NUMBER,
      p_days00            IN   NUMBER,
      p_sms00           IN   NUMBER,
      p_data00            IN   NUMBER,
      p_units01           IN   NUMBER,
      p_days01            IN   NUMBER,
      p_sms01           IN   NUMBER,
      p_data01            IN   NUMBER,
      p_units02           IN   NUMBER,
      p_days02            IN   NUMBER,
      p_sms02           IN   NUMBER,
      p_data02            IN   NUMBER,
      p_units03           IN   NUMBER,
      p_days03            IN   NUMBER,
      p_sms03           IN   NUMBER,
      p_data03            IN   NUMBER,
      p_units04           IN   NUMBER,
      p_days04            IN   NUMBER,
      p_sms04           IN   NUMBER,
      p_data04            IN   NUMBER,
      p_units05           IN   NUMBER,
      p_days05            IN   NUMBER,
      p_sms05           IN   NUMBER,
      p_data05            IN   NUMBER,
      p_units06           IN   NUMBER,
      p_days06            IN   NUMBER,
      p_sms06           IN   NUMBER,
      p_data06            IN   NUMBER,
      p_units07           IN   NUMBER,
      p_days07            IN   NUMBER,
      p_sms07           IN   NUMBER,
      p_data07            IN   NUMBER,
      p_units08           IN   NUMBER,
      p_days08            IN   NUMBER,
      p_sms08           IN   NUMBER,
      p_data08            IN   NUMBER,
      p_units09           IN   NUMBER,
      p_days09            IN   NUMBER,
      p_sms09           IN   NUMBER,
      p_data09            IN   NUMBER
   )
       RETURN NUMBER;

   --CR42361 End
END;
/