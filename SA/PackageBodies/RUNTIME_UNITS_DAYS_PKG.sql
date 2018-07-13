CREATE OR REPLACE PACKAGE BODY sa."RUNTIME_UNITS_DAYS_PKG"
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
/* 1.1      08/20/08      CL       Fix defect #282 for CR7331 (Promocode)
/* 1.2      09/15/16    MG/VN      CR42361 - Add new functions for UNITS_DAYS_SMS_and_DATA
/**************************************************************************/
   TYPE units_type IS TABLE OF VARCHAR2 (30)
      INDEX BY BINARY_INTEGER;

/**************************************/
/* FUNCTION    :   SPLIT_FUNC
/**************************************/
   FUNCTION split_func (p_bigstr IN VARCHAR2)
      RETURN units_type
   IS
      tmp_tab    units_type;
      l_smlstr   VARCHAR2 (200) := NULL;
      l_bigstr   VARCHAR2 (200) := p_bigstr;
      l_idxval   NUMBER         := 0;
      l_cnt      NUMBER         := 1;
   BEGIN
      LOOP
         l_idxval := INSTR (l_bigstr, ',');
         l_idxval := NVL (l_idxval, 0);

         IF l_idxval = 0
         THEN
            l_smlstr := l_bigstr;
         ELSE
            l_smlstr := SUBSTR (l_bigstr, 1, l_idxval - 1);
            l_bigstr := SUBSTR (l_bigstr, l_idxval + 1);
         END IF;

         tmp_tab (l_cnt) := l_smlstr;
         DBMS_OUTPUT.put_line (l_smlstr);
         l_cnt := l_cnt + 1;
         EXIT WHEN l_idxval = 0;
      END LOOP;

      DBMS_OUTPUT.put_line ('returning');
      RETURN tmp_tab;
   END;

/********************************************/
/* FUNCTION    :   UNITS_AND_DAYS
/********************************************/
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
      RETURN NUMBER
   IS
      units_tab   units_type;
      days_tab    units_type;
   BEGIN
      units_tab := split_func (p_trans_type_lvl2);
      days_tab := split_func (p_trans_type_lvl3);

      FOR i IN units_tab.FIRST .. units_tab.LAST
      LOOP
         FOR j IN days_tab.FIRST .. days_tab.LAST
         LOOP
            IF    (units_tab (i) = p_units00 AND days_tab (j) = p_days00)
               OR (units_tab (i) = p_units01 AND days_tab (j) = p_days01)
               OR (units_tab (i) = p_units02 AND days_tab (j) = p_days02)
               OR (units_tab (i) = p_units03 AND days_tab (j) = p_days03)
               OR (units_tab (i) = p_units04 AND days_tab (j) = p_days04)
               OR (units_tab (i) = p_units05 AND days_tab (j) = p_days05)
               OR (units_tab (i) = p_units06 AND days_tab (j) = p_days06)
               OR (units_tab (i) = p_units07 AND days_tab (j) = p_days07)
               OR (units_tab (i) = p_units08 AND days_tab (j) = p_days08)
               OR (units_tab (i) = p_units09 AND days_tab (j) = p_days09)
            THEN
               RETURN 1;
            END IF;
         END LOOP;
      END LOOP;

      RETURN 0;
   END;

/********************************************/
/* FUNCTION    :   UNITS_OR_DAYS
/********************************************/
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
      RETURN NUMBER
   IS
      units_tab   units_type;
   BEGIN
      DBMS_OUTPUT.put_line ('p_trans_type_lvl:' || p_trans_type_lvl);
      DBMS_OUTPUT.put_line ('p_units00:' || p_units00);
      DBMS_OUTPUT.put_line ('p_units01:' || p_units01);
      DBMS_OUTPUT.put_line ('p_units02:' || p_units02);
      DBMS_OUTPUT.put_line ('p_units03:' || p_units03);
      DBMS_OUTPUT.put_line ('p_units04:' || p_units04);
      DBMS_OUTPUT.put_line ('p_units05:' || p_units05);
      DBMS_OUTPUT.put_line ('p_units06:' || p_units06);
      DBMS_OUTPUT.put_line ('p_units07:' || p_units07);
      DBMS_OUTPUT.put_line ('p_units08:' || p_units08);
      DBMS_OUTPUT.put_line ('p_units09:' || p_units09);

      IF p_trans_type_lvl = '1'
      THEN
         IF    (1 < p_units00)
            OR (1 < p_units01)
            OR (1 < p_units02)
            OR (1 < p_units03)
            OR (1 < p_units04)
            OR (1 < p_units05)
            OR (1 < p_units06)
            OR (1 < p_units07)
            OR (1 < p_units08)
            OR (1 < p_units09)
         THEN
            RETURN 1;
         END IF;
      ELSE
         DBMS_OUTPUT.put_line ('before split function');
         units_tab := split_func (p_trans_type_lvl);
         DBMS_OUTPUT.put_line ('after split function');

         FOR i IN units_tab.FIRST .. units_tab.LAST
         LOOP
            DBMS_OUTPUT.put_line ('units_tab(i):' || units_tab (i));

            IF    (units_tab (i) = p_units00)
               OR (units_tab (i) = p_units01)
               OR (units_tab (i) = p_units02)
               OR (units_tab (i) = p_units03)
               OR (units_tab (i) = p_units04)
               OR (units_tab (i) = p_units05)
               OR (units_tab (i) = p_units06)
               OR (units_tab (i) = p_units07)
               OR (units_tab (i) = p_units08)
               OR (units_tab (i) = p_units09)
            THEN
               RETURN 1;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   END;

--CR42361
  /********************************************/
  /* FUNCTION    :   UNITS_DAYS_SMS_DATA
  /********************************************/
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
      RETURN NUMBER
   IS
      units_tab   units_type;
      days_tab    units_type;
      sms_tab     units_type;
      data_tab    units_type;
   BEGIN

      units_tab := split_func (p_trans_type_lvl2);
      days_tab := split_func (p_trans_type_lvl3);
      sms_tab := split_func (p_trans_type_lvl4);
      data_tab := split_func (p_trans_type_lvl5);

      FOR i IN units_tab.FIRST .. units_tab.LAST
      LOOP
          dbms_output.put_line(' ');
          dbms_output.put_line('UNITS :'||i|| ' - ' ||units_tab(i));
         FOR j IN days_tab.FIRST .. days_tab.LAST
         LOOP
              dbms_output.put_line(' ');
               dbms_output.put_line('UNITS :'||i|| ' - ' ||units_tab(i));
               dbms_output.put_line('DAYS :'||j|| ' - ' ||days_tab(j));
            FOR k IN sms_tab.FIRST .. sms_tab.LAST
            LOOP
                dbms_output.put_line(' ');
               dbms_output.put_line('UNITS :'||i|| ' - ' ||units_tab(i));
               dbms_output.put_line('DAYS :'||j|| ' - ' ||days_tab(j));
               dbms_output.put_line('SMS :'||k|| ' - ' ||sms_tab(k));

               FOR l IN data_tab.FIRST .. data_tab.LAST
               LOOP
               dbms_output.put_line(' ');
               dbms_output.put_line('UNITS :'||i|| ' - ' ||units_tab(i));
               dbms_output.put_line('DAYS :'||j|| ' - ' ||days_tab(j));
               dbms_output.put_line('SMS :'||k|| ' - ' ||sms_tab(k));
                dbms_output.put_line('DATA :'||l|| ' - ' ||data_tab(l));
                  IF    (units_tab (i) = p_units00 AND days_tab (j) = p_days00 AND sms_tab (k) = p_sms00 AND data_tab (l) = p_data00)
                     OR (units_tab (i) = p_units01 AND days_tab (j) = p_days01 AND sms_tab (k) = p_sms01 AND data_tab (l) = p_data01)
                     OR (units_tab (i) = p_units02 AND days_tab (j) = p_days02 AND sms_tab (k) = p_sms02 AND data_tab (l) = p_data02)
                     OR (units_tab (i) = p_units03 AND days_tab (j) = p_days03 AND sms_tab (k) = p_sms03 AND data_tab (l) = p_data03)
                     OR (units_tab (i) = p_units04 AND days_tab (j) = p_days04 AND sms_tab (k) = p_sms04 AND data_tab (l) = p_data04)
                     OR (units_tab (i) = p_units05 AND days_tab (j) = p_days05 AND sms_tab (k) = p_sms05 AND data_tab (l) = p_data05)
                     OR (units_tab (i) = p_units06 AND days_tab (j) = p_days06 AND sms_tab (k) = p_sms06 AND data_tab (l) = p_data06)
                     OR (units_tab (i) = p_units07 AND days_tab (j) = p_days07 AND sms_tab (k) = p_sms07 AND data_tab (l) = p_data07)
                     OR (units_tab (i) = p_units08 AND days_tab (j) = p_days08 AND sms_tab (k) = p_sms08 AND data_tab (l) = p_data08)
                     OR (units_tab (i) = p_units09 AND days_tab (j) = p_days09 AND sms_tab (k) = p_sms09 AND data_tab (l) = p_data09)
                  THEN
                     RETURN 1;
                  END IF;
              END LOOP;
            END LOOP;
         END LOOP;
      END LOOP;

      RETURN 0;
   END;
--CR42361 - End
END;
/