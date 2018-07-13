CREATE OR REPLACE PROCEDURE sa."PROMO_INSERT" (
   p_promo_code            IN       VARCHAR2,
   p_clean_up_statement    OUT      VARCHAR2,
   p_clean_up_statement2   OUT      VARCHAR2,
   p_clean_up_statement3   OUT      VARCHAR2,
   p_insert_statement      OUT      VARCHAR2,
   p_insert_statement2     OUT      VARCHAR2,
   p_insert_statement3     OUT      VARCHAR2,
   p_error_code            OUT      NUMBER,
   p_error_text            OUT      VARCHAR2
)
IS
   /*********************************************************************************/
   /* Copyright (r) 2008 Tracfone Wireless Inc. All rights reserved               */
   /*                                                                                                                                     */
   /* Name         :   PROMO_INSERT                                                                       */
   /* Purpose     :  Main procedure of the PROMO ENGINE  PROJECT.     */
   /*                       :  Creates insert statements from parameters input  into     */
   /*                       :   the Promo Engine when the user creates a new               */
   /*                       :   promotion or needs an existing promotion redeployed  */
   /* Parameters   :   Promo code                                                                               */
   /* Platforms    :   Oracle 10g                                                                                      */
   /* Author      :   Vani Adapa                                                                                        */
   /* Date         :   08/05/08                                                                                               */
   /* Revisions   :                                                                                                              */
   /* Version  Date           Who           Purpose                                                          */
   /* -------        --------          -------           ----------------------------------------------              */
   /* 1.0            08/05/08    Vadapa    Initial revision                                                */
   /* 1.1/1.4        08/06/08    Vadapa    CR7331 - Promo Code engine project
   /* 1.5/1.6        10/20/08    VAdapa    CR8017
   /* 1.7-8          11/17/08    ICanavan  CR8017 preserve white spaces
   /* 1.10            09/01/09    NGuada    BRAND_SEP Separate the Brand and Source System
   /*                                      replace function get_restricted_use with get_brand_objid
   /*                                      update table_x_promotion.promotion2bus_org
   /* 1.11            01/13/09    VAdapa    BRAND_SEP Fix for the correct isnert statement
   /*1.12             01/21/10    VAdapa    Fix for X_AMIGO_ALLOWED flag
   /*1.13             09/26/16    MGovindarajan Add SMS and DATA for Runtime Promotion
   /*********************************************************************************/
   CURSOR c1
   IS
      SELECT *
        FROM sa.X_PROMO_UI
       WHERE x_promo_code = p_promo_code;
       --1.12
       cursor c2 (ip_bus_org in number) is
              selecT s_org_id from table_bus_org where objid=ip_bus_org;
       r2 c2%rowtype;
--1.12
   c1_rec                 c1%ROWTYPE;
   out_sql                VARCHAR2 ( 20000 ) := NULL;
   hold_sql               VARCHAR2 ( 32000 ) := 'select 1 from sa.table_part_inst pi where pi.part_serial_no = :esn ';
   l_PROMO_TYPE           VARCHAR2 ( 200 )   := NULL;
   l_DEFAULT_TYPE         VARCHAR2 ( 200 )   := NULL;
   l_TRANSACTION_TYPE     VARCHAR2 ( 200 )   := NULL;
   l_discount_amount      VARCHAR2 ( 200 )   := NULL;
   l_discount_percent     VARCHAR2 ( 200 )   := NULL;
   l_dollar_retail_cost   VARCHAR2 ( 200 )   := NULL;
   l_units_filter         VARCHAR2 ( 200 )   := NULL;
   l_group_name_filter    VARCHAR2 ( 200 )   := NULL;
   l_promo_channel        VARCHAR2 ( 200 )   := NULL;
   l_revenue_type         VARCHAR2 ( 200 )   := NULL;
   l_units_days_cnt       NUMBER             := 0;
   l_restricted_use number :=0; --1.12
   l_esn_dlr              VARCHAR2 ( 400 )   := NULL; --CR42361

BEGIN
   OPEN c1;

   FETCH c1
    INTO c1_rec;

   IF c1%NOTFOUND
   THEN
      p_error_code    := 1;
      p_error_text    := 'p_promo_code is not found';

      CLOSE c1;

      RETURN;
   END IF;

   CLOSE c1;
--1.12
open c2(c1_rec.x_bus_org);
fetch c2 into r2;
if c2%notfound then
      p_error_code    := 2;
      p_error_text    := 'p_bus_org is not found';

      CLOSE c2;

      RETURN;

end if;
close c2;
if r2.s_org_id='NET10' then
l_restricted_use := 3;
else
l_restricted_use := 0;
end if;
--1.12
   IF c1_rec.x_group_name IS NOT NULL
   THEN
      p_clean_up_statement3    :=
         'delete from sa.table_x_promotion_mtm
                               WHERE X_PROMO_MTM2X_PROMOTION = (SELECT objid
                                                                  FROM sa.TABLE_X_PROMOTION
                                                                 WHERE X_PROMO_CODE = '''
         || c1_rec.x_promo_code || ''');';
      p_insert_statement3      :=
         'insert into sa.table_x_promotion_mtm(OBJID,
                                                              X_PROMO_MTM2X_PROMO_GROUP,
                                                              X_PROMO_MTM2X_PROMOTION)
                            VALUES(SA.SEQU_X_PROMOTION_MTM.NEXTVAL,
                                   SA.SEQU_X_PROMOTION.CURRVAL,
                                   (SELECT objid
                                      FROM sa.TABLE_X_PROMOTION_GROUP
                                     WHERE group_name = '''
         || c1_rec.x_group_name || '''));';

      IF c1_rec.x_esn_part IS NOT NULL
      THEN
         p_insert_statement3    :=
            p_insert_statement3
            || '
                             UPDATE sa.TABLE_PART_NUM
                                SET part_num2x_promotion = (SELECT objid
                                                                  FROM sa.TABLE_X_PROMOTION
                                                                 WHERE X_PROMO_CODE = '''
            || c1_rec.x_promo_code || ''')
                            WHERE s_part_number IN (''' || upper ( replace ( c1_rec.x_esn_part, ',', ''',''' ) )
            || ''');';
      END IF;
   ELSE
      p_clean_up_statement3    := NULL;
      p_insert_statement3      := NULL;

      IF c1_rec.x_esn_part IS NOT NULL
      THEN
         hold_sql    :=
            hold_sql
            || '
AND EXISTS (SELECT 1
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml
             WHERE pn.s_part_number IN ('''''
            || upper ( replace ( c1_rec.x_esn_part, ',', ''''',''''' ) )
            || ''''')
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod)';
      END IF;
   END IF;

   IF c1_rec.x_esn_model IS NOT NULL
   THEN
      hold_sql    :=
         hold_sql
         || '
AND EXISTS (SELECT 1
              FROM sa.TABLE_PART_CLASS pc, sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml
             WHERE pc.x_model_number IN ('''''
         || upper ( replace ( c1_rec.x_esn_model, ',', ''''',''''' ) )
         || ''''')
               AND pc.objid = pn.part_num2part_class
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod)';
   END IF;

   IF c1_rec.X_PROMO_REQD_FLAG = 'N' AND c1_rec.X_TRANS_TYPE = 'ACTIVATION' AND c1_rec.X_TRANS_TYPE_LVL1 = 'NO'
      AND c1_rec.X_PROMO_BENEFIT = 'DOUBLE'
   THEN
      hold_sql          := 'RTDBL000';
      l_PROMO_TYPE      := 'ActivationCombo';
      l_DEFAULT_TYPE    := 'COMBO';
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'Y' AND c1_rec.X_TRANS_TYPE = 'ACTIVATION'
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC', 'NO' )
         AND c1_rec.X_PROMO_BENEFIT IN ( 'UNITS', 'DAYS', 'UNITS_DAYS' ,
                                        'UNITS_DAYS_SMS_DATA',
                                        'UNITS_DAYS_DATA',
                                        'UNITS_SMS_DATA',
                                        'UNITS_DATA',
                                        'UNITS_SMS',
                                        'DAYS_SMS_DATA',
                                        'DAYS_SMS',
                                        'DAYS_DATA',
                                        'SMS_DATA',
                                        'SMS',
                                        'DATA'
         )
   THEN
      l_PROMO_TYPE          := 'Promocode';
      l_TRANSACTION_TYPE    := 'ACTIVATION';
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'Y' AND c1_rec.X_TRANS_TYPE = 'REDEMPTION'
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC' )
         AND c1_rec.X_PROMO_BENEFIT IN ( 'UNITS', 'DAYS', 'UNITS_DAYS' ,
                                        'UNITS_DAYS_SMS_DATA',
                                        'UNITS_DAYS_DATA',
                                        'UNITS_SMS_DATA',
                                        'UNITS_DATA',
                                        'UNITS_SMS',
                                        'DAYS_SMS_DATA',
                                        'DAYS_SMS',
                                        'DAYS_DATA',
                                        'SMS_DATA',
                                        'SMS',
                                        'DATA'
         )
   THEN
      l_PROMO_TYPE          := 'Promocode';
      --CR8017
      --l_TRANSACTION_TYPE    := 'REDEMPTION';
      l_TRANSACTION_TYPE    := 'ALL';
      --CR8017
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'Y' AND c1_rec.X_TRANS_TYPE = 'REACTIVATION'
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC' )
         AND c1_rec.X_PROMO_BENEFIT IN ( 'UNITS', 'DAYS', 'UNITS_DAYS',
                                        'UNITS_DAYS_SMS_DATA',
                                        'UNITS_DAYS_DATA',
                                        'UNITS_SMS_DATA',
                                        'UNITS_DATA',
                                        'UNITS_SMS',
                                        'DAYS_SMS_DATA',
                                        'DAYS_SMS',
                                        'DAYS_DATA',
                                        'SMS_DATA',
                                        'SMS',
                                        'DATA'
                                        )
   THEN
      l_PROMO_TYPE          := 'Promocode';
      l_TRANSACTION_TYPE    := 'REACTIVATION';
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'Y' AND c1_rec.X_TRANS_TYPE = 'PURCHASE'
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC' )
         AND c1_rec.X_PROMO_BENEFIT IN ( 'UNITS', 'DAYS', 'UNITS_DAYS',
                                        'UNITS_DAYS_SMS_DATA',
                                        'UNITS_DAYS_DATA',
                                        'UNITS_SMS_DATA',
                                        'UNITS_DATA',
                                        'UNITS_SMS',
                                        'DAYS_SMS_DATA',
                                        'DAYS_SMS',
                                        'DAYS_DATA',
                                        'SMS_DATA',
                                        'SMS',
                                        'DATA'
                                        )
   THEN
      l_PROMO_TYPE          := 'Promocode';
      l_TRANSACTION_TYPE    := 'PURCHASE';
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'Y' AND c1_rec.X_TRANS_TYPE = 'PURCHASE'
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC' ) AND c1_rec.X_PROMO_BENEFIT IN ( 'DISC_AMT', 'DISC_PERC' )
   THEN
      l_PROMO_TYPE          := 'Promocode';
      l_TRANSACTION_TYPE    := 'PURCHASE';

      IF c1_rec.X_PROMO_BENEFIT = 'DISC_AMT'
      THEN
         l_discount_amount    := c1_rec.x_discount_value;
      ELSIF c1_rec.X_PROMO_BENEFIT = 'DISC_PERC'
      THEN
         l_discount_PERCENT    := c1_rec.x_discount_value;
      END IF;
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'Y' AND c1_rec.X_TRANS_TYPE = 'BP_ENROLL'
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC' )
         AND c1_rec.X_PROMO_BENEFIT IN ( 'DISC_AMT', 'UNITS', 'DAYS', 'UNITS_DAYS',
                                        'UNITS_DAYS_SMS_DATA',
                                        'UNITS_DAYS_DATA',
                                        'UNITS_SMS_DATA',
                                        'UNITS_DATA',
                                        'UNITS_SMS',
                                        'DAYS_SMS_DATA',
                                        'DAYS_SMS',
                                        'DAYS_DATA',
                                        'SMS_DATA',
                                        'SMS',
                                        'DATA')
   THEN
      l_PROMO_TYPE          := 'BPEnrollment';
      l_TRANSACTION_TYPE    := 'ONETIME';
      l_revenue_type        := 'FREE';

      IF c1_rec.x_promo_channel = 'ALL'
      THEN
         l_promo_channel    := NULL;
      ELSE
         l_promo_channel    := c1_rec.x_promo_channel;
      END IF;

      IF c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY' )
      THEN
         hold_sql    :=
              'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL and :p_esn IS NOT NULL ';
      ELSE
         hold_sql    :=
            'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE X_PROGRAM_NAME IN ('''''
            || replace (LTRIM ( RTRIM ( c1_rec.X_TRANS_TYPE_LVL2 ) ),',',''''',''''' )
            || ''''') AND OBJID=:p_program_param_id  and :p_esn IS NOT NULL ';
      END IF;

      IF c1_rec.x_esn_part IS NOT NULL
      THEN
         IF c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY' )
         THEN
            hold_sql    :=
               'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL and 0 < (select count(1)
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
             WHERE pn.s_part_number IN ('''''
               || upper ( replace ( c1_rec.x_esn_part, ',', ''''',''''' ) )
               || ''''')
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod
               AND pi.part_serial_no = :p_esn )';
         ELSE
            hold_sql    :=
               'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE X_PROGRAM_NAME IN ('''''
               || replace (LTRIM ( RTRIM ( c1_rec.X_TRANS_TYPE_LVL2 ) ),',',''''',''''' )
               || ''''') AND OBJID=:p_program_param_id and 0 < (select count(1)
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
             WHERE pn.s_part_number IN ('''''
               || upper ( replace ( c1_rec.x_esn_part, ',', ''''',''''' ) )
               || ''''')
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod
               AND pi.part_serial_no = :p_esn )';
         END IF;
      END IF;

      IF c1_rec.x_esn_model IS NOT NULL
      THEN
         IF c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY' )
         THEN
            hold_sql    :=
               'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL and 0 < (select count(1)
              FROM sa.TABLE_PART_CLASS pc, sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
             WHERE pc.x_model_number IN ('''''
               || upper ( replace ( c1_rec.x_esn_model, ',', ''''',''''' ) )
               || ''''')
               AND pc.objid = pn.part_num2part_class
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod
               AND pi.part_serial_no = :p_esn )';
         ELSE
            hold_sql    :=
               'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE X_PROGRAM_NAME IN ('''''
               || replace (LTRIM ( RTRIM ( c1_rec.X_TRANS_TYPE_LVL2 ) ),',',''''',''''' )
               || ''''') AND OBJID=:p_program_param_id and 0 < (select count(1
)
              FROM sa.TABLE_PART_CLASS pc, sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
             WHERE pc.x_model_number IN ('''''
               || upper ( replace ( c1_rec.x_esn_model, ',', ''''',''''' ) )
               || ''''')
               AND pc.objid = pn.part_num2part_class
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod
               AND pi.part_serial_no = :p_esn )';
         END IF;
      END IF;

      IF c1_rec.x_esn_tech IS NOT NULL
      THEN
         IF c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY' )
         THEN
            hold_sql    :=
               'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL
AND 0 < (SELECT COUNT(1)
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
                WHERE pn.x_technology = '''''
               || c1_rec.x_esn_tech
               || '''''
                  AND pn.objid = ml.part_info2part_num
                  AND ml.objid = pi.n_part_inst2part_mod
                  AND pi.part_serial_no = :p_esn)';
         ELSE
            hold_sql    :=
               'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE X_PROGRAM_NAME IN ('''''
               || replace (LTRIM ( RTRIM ( c1_rec.X_TRANS_TYPE_LVL2 ) ),',',''''',''''' )
               || ''''') AND OBJID=:p_program_param_id 0 < (select count(1)
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
                WHERE pn.x_technology = '''''
               || c1_rec.x_esn_tech
               || '''''
                  AND pn.objid = ml.part_info2part_num
                  AND ml.objid = pi.n_part_inst2part_mod
                  AND pi.part_serial_no = :p_esn)';
         END IF;
      END IF;

      l_discount_amount     := c1_rec.x_discount_value;

      IF c1_rec.X_PROMO_BENEFIT = 'DISC_AMT'
      THEN
         l_dollar_retail_cost    := c1_rec.x_discount_value;
      END IF;
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'Y' AND c1_rec.X_TRANS_TYPE = 'BP_MONTHLY'
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC' )
         AND c1_rec.X_PROMO_BENEFIT IN ( 'DISC_AMT', 'UNITS', 'DAYS', 'UNITS_DAYS',
                                        'UNITS_DAYS_SMS_DATA',
                                        'UNITS_DAYS_DATA',
                                        'UNITS_SMS_DATA',
                                        'UNITS_DATA',
                                        'UNITS_SMS',
                                        'DAYS_SMS_DATA',
                                        'DAYS_SMS',
                                        'DAYS_DATA',
                                        'SMS_DATA',
                                        'SMS',
                                        'DATA')
   THEN
      l_PROMO_TYPE          := 'BPEnrollment';
      l_TRANSACTION_TYPE    := c1_rec.X_TRANS_TYPE_LVL3;
      l_revenue_type        := 'FREE';

      IF c1_rec.x_promo_channel = 'ALL'
      THEN
         l_promo_channel    := NULL;
      ELSE
         l_promo_channel    := c1_rec.x_promo_channel;
      END IF;

      IF c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY' )
      THEN
         hold_sql    :=
              'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL and :p_esn IS NOT NULL ';
      ELSE
         hold_sql    :=
            'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE X_PROGRAM_NAME IN ('''''
            || replace (LTRIM ( RTRIM ( c1_rec.X_TRANS_TYPE_LVL2 ) ),',',''''',''''' )
            || ''''') AND OBJID=:p_program_param_id and :p_esn IS NOT NULL';
      END IF;

      IF c1_rec.x_esn_part IS NOT NULL
      THEN
         hold_sql    :=
            'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL and 0 < (select count(1)
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
             WHERE pn.s_part_number IN ('''''
            || upper ( replace ( c1_rec.x_esn_part, ',', ''''',''''' ) )
            || ''''')
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod
               AND pi.part_serial_no = :p_esn )';
      END IF;

      IF c1_rec.x_esn_model IS NOT NULL
      THEN
         hold_sql    :=
            'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL and 0 < (select count(1)
              FROM sa.TABLE_PART_CLASS pc, sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
             WHERE pc.x_model_number IN ('''''
            || upper ( replace ( c1_rec.x_esn_model, ',', ''''',''''' ) )
            || ''''')
               AND pc.objid = pn.part_num2part_class
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod
               AND pi.part_serial_no = :p_esn )';
      END IF;

      IF c1_rec.x_esn_tech IS NOT NULL
      THEN
         hold_sql    :=
            'select COUNT(*) from X_PROGRAM_PARAMETERS WHERE :p_program_param_id IS NOT NULL
AND 0 < (SELECT COUNT(1)
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_INST pi
                WHERE pn.x_technology = '''''
            || c1_rec.x_esn_tech
            || '''''
                  AND pn.objid = ml.part_info2part_num
                  AND ml.objid = pi.n_part_inst2part_mod
                  AND pi.part_serial_no = :p_esn)';
      END IF;

      IF c1_rec.X_PROMO_BENEFIT = 'DISC_AMT'
      THEN
         l_dollar_retail_cost    := c1_rec.x_discount_value;
         l_discount_amount       := c1_rec.x_discount_value;
      END IF;
   ELSIF c1_rec.X_PROMO_REQD_FLAG = 'N'
         AND c1_rec.X_TRANS_TYPE IN ( 'ACTIVATION', 'REACTIVATION', 'REDEMPTION', 'PURCHASE' )
         AND c1_rec.X_TRANS_TYPE_LVL1 IN ( 'ANY', 'SPEC' )
         AND c1_rec.X_PROMO_BENEFIT IN ( 'UNITS', 'DAYS', 'UNITS_DAYS',
                                        'UNITS_DAYS_SMS_DATA',
                                        'UNITS_DAYS_DATA',
                                        'UNITS_SMS_DATA',
                                        'UNITS_DATA',
                                        'UNITS_SMS',
                                        'DAYS_SMS_DATA',
                                        'DAYS_SMS',
                                        'DAYS_DATA',
                                        'SMS_DATA',
                                        'SMS',
                                        'DATA')
   THEN
      l_PROMO_TYPE    := 'Runtime';

      -- BRAND_SEP
      --hold_sql        := hold_sql || ' AND Get_Restricted_Use ( :esn ) = ' || c1_rec.x_bus_org;
      hold_sql        := hold_sql || ' AND Get_brand_objid ( :esn ) = ' || c1_rec.x_bus_org;

      IF c1_rec.x_esn_tech IS NOT NULL
      THEN
         hold_sql    :=
            hold_sql
            || '
AND EXISTS (SELECT 1
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml
             WHERE pn.x_technology = '''''
            || c1_rec.x_esn_tech
            || '''''
               AND pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod)';
      END IF;

      IF c1_rec.x_pd_chk_flag = 'Y'
      THEN
         hold_sql    :=
            hold_sql
            || '
AND NOT EXISTS (SELECT 1
                  FROM sa.TABLE_SITE_PART sp
                 WHERE sp.x_service_id = pi.part_serial_no
                   AND sp.x_deact_reason LIKE ''''PASTDUE%''''
                   AND sp.service_end_dt BETWEEN '''''
            || c1_rec.x_start_date || '''''
                                             AND ''''' || c1_rec.x_end_date || ''''')';
      END IF;

      IF c1_rec.X_TRANS_TYPE_LVL1 = 'SPEC' AND c1_rec.X_TRANS_TYPE_LVL2 IS NOT NULL
      THEN

        --CR42361: Allow runtime promotions to include SMS and Data
        -- This is only for Tracfone/smartphone where SMS/DAta present.
        IF c1_rec.X_TRANS_TYPE_LVL4 IS NULL AND c1_rec.X_TRANS_TYPE_LVL5 IS NULL
        THEN
           hold_sql          := hold_sql || '
  AND :units IN (' ||           c1_rec.X_TRANS_TYPE_LVL2 || ')';
           l_units_filter    := c1_rec.X_TRANS_TYPE_LVL2;
        ELSE
          --CR42361: Add Unit, Days, SMS and Data only for Group Runtime promotion
          -- If the Runtime does not have promotion then, use the BAU of adding Units/Access_days.
          IF c1_rec.x_esn_qual = 'GROUP' AND c1_rec.x_group_name IS NOT NULL
          THEN
              hold_sql          :=
                     hold_sql || '
              AND ( sa.Runtime_Units_Days_Pkg.units_days_sms_data (''''' || NVL(c1_rec.X_TRANS_TYPE_LVL2, 0) || ''''','''''
                   || NVL(c1_rec.X_TRANS_TYPE_LVL3, 0) || ''''','''''
                    || NVL(c1_rec.X_TRANS_TYPE_LVL4, 0) || ''''','''''
                     || NVL(c1_rec.X_TRANS_TYPE_LVL5, 0)
                     || ''''', :units00 , :days00 , :sms00 , :data00 ,
                     :units01 , :days01 , :sms01 , :data01 ,
                      :units02 , :days02 , :sms02 , :data02 ,
                      :units03 , :days03 , :sms03 , :data03 ,
                      :units04 , :days04 ,  :sms04 , :data04 ,
                      :units05 , :days05 ,  :sms05 , :data05 ,
                     :units06 , :days06 ,  :sms06 , :data06 ,
                     :units07 , :days07 ,  :sms07 , :data07 ,
                     :units08 , :days08 ,  :sms08 , :data08 ,
                     :units09 , :days09 ,  :sms09 , :data09 )= 1)';
            ELSE
              hold_sql          := hold_sql || '
              AND :units IN (' ||           c1_rec.X_TRANS_TYPE_LVL2 || ')';

              IF c1_rec.X_TRANS_TYPE_LVL3 IS NOT NULL
              THEN
                 hold_sql    := hold_sql || '
                AND :access_days IN (' || c1_rec.X_TRANS_TYPE_LVL3 || ')';
              END IF;

            END IF;
            l_units_filter    := c1_rec.X_TRANS_TYPE_LVL2;
        END IF;
      END IF;

      IF c1_rec.X_TRANS_TYPE_LVL1 = 'ANY' AND c1_rec.X_TRANS_TYPE_LVL2 IS NULL
      THEN
         hold_sql          := hold_sql || '
AND :units IS NOT NULL';
         l_units_filter    := c1_rec.X_TRANS_TYPE_LVL2;
      END IF;

      IF c1_rec.X_TRANS_TYPE_LVL1 = 'SPEC' AND c1_rec.X_TRANS_TYPE_LVL3 IS NOT NULL
          AND c1_rec.X_TRANS_TYPE_LVL4 IS NULL AND c1_rec.X_TRANS_TYPE_LVL5 IS NULL
      THEN
         hold_sql    := hold_sql || '
AND :access_days IN (' || c1_rec.X_TRANS_TYPE_LVL3 || ')';
      END IF;

      IF c1_rec.x_esn_qual = 'GROUP' AND c1_rec.x_group_name IS NOT NULL
      THEN
         hold_sql    :=
            hold_sql
            || '
AND EXISTS (SELECT 1
              FROM sa.TABLE_X_PROMOTION_GROUP pg,
                   sa.TABLE_X_GROUP2ESN ge
             WHERE pg.group_name = '''''
            || c1_rec.x_group_name
            || '''''
               AND ge.groupesn2x_promo_group+0 = pg.objid
               AND ge.groupesn2part_inst = pi.objid)';
      END IF;

      IF NVL ( c1_rec.X_PROMO_USAGE, 0 ) > 0 AND NVL ( c1_rec.X_PROMO_USAGE, 0 ) <> 99
      THEN
         hold_sql    :=
            hold_sql || '
AND ' ||    c1_rec.x_promo_usage || ' > Get_Promo_Usage_Fun( :esn , x_part_inst2site_part,''''' || c1_rec.x_promo_code
            || ''''')';
      END IF;

      IF c1_rec.x_act_channel IS NOT NULL
      THEN
         hold_sql    :=
            hold_sql || '
AND ''''' || c1_rec.x_act_channel
            || ''''' = SELECT x_sourcesystem
   FROM (SELECT x_sourcesystem
           FROM sa.TABLE_X_CALL_TRANS ct
          WHERE 1=1
            AND x_service_id = :esn
            AND x_result||'''''' = ''''Completed''''
            AND x_action_text = ''''ACTIVATION''''
          ORDER BY x_transact_date DESC)
  WHERE ROWNUM <2';
      END IF;

      IF c1_rec.X_LAST_REDMP_CHANNEL IS NOT NULL
      THEN
         hold_sql    :=
            hold_sql || '
AND ''''' || c1_rec.X_LAST_REDMP_CHANNEL
            || ''''' = SELECT x_sourcesystem
   FROM (SELECT x_sourcesystem
           FROM sa.TABLE_X_CALL_TRANS ct
          WHERE 1=1
            AND x_service_id = :esn
            AND x_result||'''''' = ''''Completed''''
            AND x_action_text = ''''REDEMPTION''''
          ORDER BY x_transact_date DESC)
  WHERE ROWNUM <2';
      END IF;
   END IF;

   IF c1_rec.X_TRANS_TYPE NOT IN ( 'BP_ENROLL', 'BP_MONTHLY' )
   THEN
      l_revenue_type    := 'PAID';

      IF c1_rec.X_PROMO_REQD_FLAG = 'Y'
      THEN
         l_PROMO_TYPE       := 'Promocode';
         l_promo_channel    := c1_rec.x_promo_channel;

         -- BRAND_SEP
         --hold_sql           := hold_sql || ' AND Get_Restricted_Use ( :esn ) = ' || c1_rec.x_bus_org;
         hold_sql           := hold_sql || ' AND Get_brand_objid ( :esn ) = ' || c1_rec.x_bus_org;
         hold_sql           := hold_sql || '
AND SYSDATE >= :promo_start_date   --' ;

         IF c1_rec.x_esn_tech IS NOT NULL
         THEN
            hold_sql    :=
               hold_sql
               || '
AND EXISTS (SELECT 1
              FROM sa.TABLE_PART_NUM pn,
                   sa.TABLE_MOD_LEVEL ml
                WHERE pn.x_technology = '''''
               || c1_rec.x_esn_tech
               || '''''
                  AND pn.objid = ml.part_info2part_num
                  AND ml.objid = pi.n_part_inst2part_mod)';
         END IF;

         IF c1_rec.x_pd_chk_flag = 'Y'
         THEN
            hold_sql    :=
               hold_sql
               || '
AND NOT EXISTS (SELECT 1
                  FROM sa.TABLE_SITE_PART sp
                 WHERE sp.x_service_id = pi.part_serial_no
                   AND sp.x_deact_reason LIKE ''''PASTDUE%''''
                   AND sp.service_end_dt BETWEEN '''''
               || c1_rec.x_start_date || '''''
                                             AND ''''' || c1_rec.x_end_date || ''''')';
         END IF;

         IF c1_rec.X_TRANS_TYPE_LVL4 IS NULL AND c1_rec.X_TRANS_TYPE_LVL5 IS NULL
         THEN

           IF c1_rec.X_TRANS_TYPE_LVL2 IS NOT NULL AND c1_rec.X_TRANS_TYPE_LVL3 IS NOT NULL
              AND c1_rec.X_TRANS_TYPE_LVL1 = 'SPEC'
           THEN
              hold_sql          :=
                 hold_sql || '
  AND ( sa.Runtime_Units_Days_Pkg.units_and_days (''''' || c1_rec.X_TRANS_TYPE_LVL2 || ''''','''''
                 || c1_rec.X_TRANS_TYPE_LVL3
                 || ''''', :units00 , :days00 ,  :units01 , :days01 ,  :units02 , :days02 ,
   :units03 , :days03 ,  :units04 , :days04 ,  :units05 , :days05 ,
   :units06 , :days06 ,  :units07 , :days07 ,  :units08 , :days08 ,  :units09 , :days09 )= 1)';
              dbms_output.put_line ('hold_sql length:' || LENGTH ( hold_sql ) );
              l_units_filter    := c1_rec.X_TRANS_TYPE_LVL2;
           ELSIF c1_rec.X_TRANS_TYPE_LVL2 IS NOT NULL AND c1_rec.X_TRANS_TYPE_LVL1 = 'SPEC'
           THEN
              hold_sql          :=
                 hold_sql || '
  AND ( sa.Runtime_Units_Days_Pkg.units_or_days (''''' || c1_rec.X_TRANS_TYPE_LVL2
                 || ''''',
   :units00 , :units01 , :units02 , :units03 , :units04 , :units05 , :units06 , :units07 , :units08 , :units09 )=1)';
              dbms_output.put_line ('hold_sql length:' || LENGTH ( hold_sql ) );
              l_units_filter    := c1_rec.X_TRANS_TYPE_LVL2;
           ELSIF c1_rec.X_TRANS_TYPE_LVL2 IS NULL AND c1_rec.X_TRANS_TYPE_LVL1 = 'ANY'
           THEN
              hold_sql          :=
                 hold_sql
                 || '
  AND ( sa.Runtime_Units_Days_Pkg.units_or_days (1,
   :units00 , :units01 , :units02 , :units03 , :units04 , :units05 , :units06 , :units07 , :units08 , :units09 )=1)';
              dbms_output.put_line ('hold_sql length:' || LENGTH ( hold_sql ) );
              l_units_filter    := c1_rec.X_TRANS_TYPE_LVL2;
           ELSIF c1_rec.X_TRANS_TYPE_LVL3 IS NOT NULL AND c1_rec.X_TRANS_TYPE_LVL1 = 'SPEC'
           THEN
              hold_sql          :=
                 hold_sql || '
  AND ( sa.Runtime_Units_Days_Pkg.units_or_days (''''' || c1_rec.X_TRANS_TYPE_LVL3
                 || ''''',
   :days00 , :days01 , :days02 , :days03 , :days04 , :days05 , :days06 , :days07 , :days08 , :days09 )=1)';
              dbms_output.put_line ('hold_sql length:' || LENGTH ( hold_sql ) );
              l_units_filter    := c1_rec.X_TRANS_TYPE_LVL3;
           END IF;

        ELSE

            --CR42361 Start
            --CR42361 : New section for UNITS, DAYS, SMS and DATA
            hold_sql          :=
                   hold_sql || '
    AND ( sa.Runtime_Units_Days_Pkg.units_days_sms_data (''''' || NVL(c1_rec.X_TRANS_TYPE_LVL2, 0) || ''''','''''
                 || NVL(c1_rec.X_TRANS_TYPE_LVL3, 0) || ''''','''''
                  || NVL(c1_rec.X_TRANS_TYPE_LVL4, 0) || ''''','''''
                   || NVL(c1_rec.X_TRANS_TYPE_LVL5, 0)
                   || ''''', :units00 , :days00 , :sms00 , :data00 ,
                   :units01 , :days01 , :sms01 , :data01 ,
                    :units02 , :days02 , :sms02 , :data02 ,
                    :units03 , :days03 , :sms03 , :data03 ,
                    :units04 , :days04 ,  :sms04 , :data04 ,
                    :units05 , :days05 ,  :sms05 , :data05 ,
                   :units06 , :days06 ,  :sms06 , :data06 ,
                   :units07 , :days07 ,  :sms07 , :data07 ,
                   :units08 , :days08 ,  :sms08 , :data08 ,
                   :units09 , :days09 ,  :sms09 , :data09 )= 1)';
                dbms_output.put_line ('hold_sql length:' || LENGTH ( hold_sql ) );
                --l_units_filter    := c1_rec.X_TRANS_TYPE_LVL4;

             END IF;
            --CR42361 End

         IF c1_rec.x_esn_qual = 'GROUP' AND c1_rec.x_group_name IS NOT NULL
         THEN
            hold_sql    :=
               hold_sql
               || '
AND EXISTS (SELECT 1
              FROM sa.TABLE_X_PROMOTION_GROUP pg,
                   sa.TABLE_X_GROUP2ESN ge
             WHERE pg.group_name = '''''
               || c1_rec.x_group_name
               || '''''
               AND ge.groupesn2x_promo_group+0 = pg.objid
               AND ge.groupesn2part_inst = pi.objid)';
         END IF;

         IF NVL ( c1_rec.X_PROMO_USAGE, 0 ) > 0 AND NVL ( c1_rec.X_PROMO_USAGE, 0 ) <> 99
         THEN
            hold_sql    :=
               hold_sql || '
AND ' ||       c1_rec.x_promo_usage || ' > Get_Promo_Usage_Fun( :esn , x_part_inst2site_part,'''''
               || c1_rec.x_promo_code || ''''')';
         END IF;

         IF c1_rec.x_act_channel IS NOT NULL
         THEN
            hold_sql    :=
               hold_sql || '
AND ''''' ||   c1_rec.x_act_channel
               || ''''' = SELECT x_sourcesystem
    FROM (SELECT x_sourcesystem
            FROM sa.TABLE_X_CALL_TRANS ct
           WHERE 1=1
             AND x_service_id = :esn
             AND x_result||'''''' = ''''Completed''''
             AND x_action_text = ''''ACTIVATION''''
           ORDER BY x_transact_date DESC)
   WHERE ROWNUM <2';
         END IF;

         IF c1_rec.X_LAST_REDMP_CHANNEL IS NOT NULL
         THEN
            hold_sql    :=
               hold_sql || '
AND ''''' ||   c1_rec.X_LAST_REDMP_CHANNEL
               || ''''' = SELECT x_sourcesystem
    FROM (SELECT x_sourcesystem
            FROM sa.TABLE_X_CALL_TRANS ct
           WHERE 1=1
             AND x_service_id = :esn
             AND x_result||'''''' = ''''Completed''''
             AND x_action_text = ''''REDEMPTION''''
           ORDER BY x_transact_date DESC)
   WHERE ROWNUM <2';
         END IF;

      END IF;
   END IF;

    --device type check
	 IF c1_rec.x_device_type is NOT NULL AND  c1_rec.x_device_type <> 'ANY'
	 THEN

	   hold_sql  :=
	           hold_sql
		   || '
		   AND sa.get_device_type(:esn) IN ('''''||replace(c1_rec.x_device_type,',',''''',''''')||''''')';

   END IF;

   --CR42361: Dealer Promo Check for Tracfone only
   IF c1_rec.x_bus_org = 268438257 AND c1_rec.x_esn_dealer is NOT NULL
   THEN
        l_esn_dlr := ''''||replace(c1_rec.x_esn_dealer, ',', ''''',''''')||'''';
        hold_sql  :=
	           hold_sql
		   || '
       AND exists (Select 1
            from sa.table_part_inst pi,
                 sa.Table_Site site,
                 sa.Table_Inv_Bin Ib,
                 sa.Table_Inv_Locatn Il
            where pi.part_serial_no = :esn
            And pi.x_domain=''''PHONES''''
            And Ib.Objid = Pi.Part_Inst2inv_Bin
            And Il.Objid = Ib.Inv_Bin2inv_Locatn
            And Site.Objid = Il.Inv_Locatn2site
            And Ib.bin_name IN (''' || l_esn_dlr || '''))';
   END IF;


     dbms_output.put_line ('hold_sql :' || hold_sql  );
     dbms_output.put_line ('transaction :' || l_transaction_type  );
   p_clean_up_statement     := 'delete from sa.table_x_promotion where X_PROMO_CODE = ''' || c1_rec.x_promo_code || ''';';
   p_clean_up_statement2    :='delete from sa.X_PROMOTION_ADDL_INFO WHERE X_PROMO_ADDL2X_PROMO = (SELECT objid FROM sa.TABLE_X_PROMOTION WHERE X_PROMO_CODE = '''|| c1_rec.x_promo_code || ''');';



   p_insert_statement       :=
      'insert into sa.table_x_promotion(OBJID  ,
PROMOTION2BUS_ORG,
X_PROMO_CODE,
X_PROMO_TYPE,
X_DOLLAR_RETAIL_COST,
X_START_DATE,
X_END_DATE,
X_UNITS,
X_ACCESS_DAYS,
X_PROMOTION_TEXT,
X_IS_DEFAULT,
X_SQL_STATEMENT,
X_REVENUE_TYPE,
X_DEFAULT_TYPE,
X_REDEEMABLE,
X_PROMO_TECHNOLOGY,
X_SPANISH_PROMO_TEXT,
X_USAGE,
X_DISCOUNT_AMOUNT,
X_DISCOUNT_PERCENT,
X_SOURCE_SYSTEM,
X_TRANSACTION_TYPE,
X_ZIP_REQUIRED,
X_PROMO_DESC,
X_AMIGO_ALLOWED,
X_PROGRAM_TYPE,
X_SHIP_START_DATE,
X_SHIP_END_DATE,
X_REFURBISHED_ALLOWED,
X_SPANISH_SHORT_TEXT,
X_ENGLISH_SHORT_TEXT,
X_ALLOW_STACKING,
X_UNITS_FILTER,
X_ACCESS_DAYS_FILTER,
X_PROMO_CODE_FILTER,
X_GROUP_NAME_FILTER,
X_SMS,
X_DATA_MB,
X_DEVICE_TYPE
)
VALUES(SA.SEQU_X_PROMOTION.NEXTVAL,'
      || '''' ||c1_rec.x_bus_org||''',' || '''' || c1_rec.x_promo_code || ''',' || '''' || l_promo_type || ''',' || NVL ( l_dollar_retail_cost, 0 ) || ','
      || '''' || c1_rec.x_start_date || ''',' || '''' || c1_rec.x_end_date || ''',' || NVL ( c1_rec.x_bonus_units, 0 )
      || ',' || NVL ( c1_rec.x_bonus_days, 0 ) || ',' || '''' || REPLACE ( c1_rec.X_PROMO_DESC, '''', '''''' ) || ''','
      || 'null,' || '''' || hold_sql || ''',' || '''' || l_revenue_type || ''',' || '''' || l_default_type || ''','
      || 'null,' || 'null,' || 'null,' || NVL ( c1_rec.x_promo_usage, 0 ) || ',' || NVL ( l_discount_amount, 0 ) || ','
      || NVL ( l_discount_percent, 0 ) || ',' || '''' || l_promo_channel || ''',' || '''' || l_transaction_type || ''','
      || 'null,' || '''' || REPLACE ( c1_rec.x_promo_desc, '''', '''''' ) || ''',' || l_restricted_use--c1_rec.x_bus_org 1.12
      || ',' || 'null,'|| 'null,' || 'null,' || 'null,' || 'null,' || 'null,' || 'null,' || '''' || l_units_filter || ''',' || 'null,'
      || 'null,' || '''' || c1_rec.x_group_name || ''','
      || NVL(c1_rec.x_bonus_sms,0)
      || ','
      || NVL(c1_rec.x_bonus_data_mb,0)
      || ','
      || ''''
      || c1_rec.x_device_type
      ||''');';
   p_insert_statement2      :=
      'insert into sa.X_PROMOTION_ADDL_INFO( X_ACTIVE,
                                                                  X_DLL_ALLOW,
                                                                  X_SITE_OBJID,
                                                                  X_PROMO_ADDL2X_PROMO,
                                                                  X_DELIVERY_METHOD,
                                                                  X_COST_CENTER_NO)
                                                           VALUES('
      || 'NULL,' || 'null,' || 'null,' || 'SA.SEQU_X_PROMOTION.currval,' || 'null,' || '''' || c1_rec.x_bus_org || ''');';
END;
/