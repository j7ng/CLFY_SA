CREATE MATERIALIZED VIEW sa.vas_programs_mv (vas_service_id,vas_name,product_id,vas_bus_org,vas_product_type,vas_category,vas_group_name,vas_description_english,vas_description_spanish,vas_is_active,vas_start_date,vas_end_date,vas_price,vas_vendor,vas_association,vas_recurring_days,service_days,grace_period,vas_sponsor,vas_tax_calculation,vas_type,vas_app_card,vas_card_class,part_class_objid,program_parameters_objid,auto_pay_program_objid,x_promotion_objid,offer_expiry,reenroll_allow_flag,show_due_before_days,proration_flag,direct_cancel_flag,transfer_on_upgrade_flag,transfer_on_replacement_flag,refund_on_upgrade_flag,refund_on_replacement_flag,refund_on_cancellation_flag,electronic_refund_days,mobile_plan_type,mobile_description,mobile_description2,mobile_description3,mobile_description4,ild_rates_url,available_for_lrp_flag,points_required_to_redeem,points_accrued_by_purchase,points_accrued_by_autorefill)
ORGANIZATION HEAP 
REFRESH COMPLETE 
AS select vas_service_id,
            vas_name,
            "'PRODUCT_ID'",
            "'VAS_BUS_ORG'",
            "'VAS_PRODUCT_TYPE'",
            "'VAS_CATEGORY'",
            "'VAS_GROUP_NAME'",
            "'VAS_DESCRIPTION_ENGLISH'",
            "'VAS_DESCRIPTION_SPANISH'",
            "'VAS_IS_ACTIVE'",
            to_date("'VAS_START_DATE'",'MM/DD/YYYY'),
            to_date("'VAS_END_DATE'",'MM/DD/YYYY') ,
            "'VAS_PRICE'",
            "'VAS_VENDOR'",
            "'VAS_ASSOCIATION'",
            "'VAS_RECURRING_DAYS'",
            "'SERVICE_DAYS'",
            "'GRACE_PERIOD'",
            "'VAS_SPONSOR'",
            "'VAS_TAX_CALCULATION'",
            "'VAS_TYPE'",
            "'VAS_APP_CARD'",
            "'VAS_CARD_CLASS'",
            "'PART_CLASS_OBJID'",
            "'PROGRAM_PARAMETERS_OBJID'",
            "'AUTO_PAY_PROGRAM_OBJID'", -- CR49058
            "'X_PROMOTION_OBJID'",
            "'OFFER_EXPIRY'" ,-- CR49058
            "'REENROLL_ALLOW_FLAG'",  -- CR49058
            "'SHOW_DUE_BEFORE_DAYS'",-- CR49058
            "'PRORATION_FLAG'",  -- CR49058
            "'DIRECT_CANCEL_FLAG'",-- CR49058
            "'TRANSFER_ON_UPGRADE_FLAG'", -- CR49058
            "'TRANSFER_ON_REPLACEMENT_FLAG'", -- CR49058
            "'REFUND_ON_UPGRADE_FLAG'",-- CR49058
            "'REFUND_ON_REPLACEMENT_FLAG'",-- CR49058
            "'REFUND_ON_CANCELLATION_FLAG'",-- CR49058
            "'ELECTRONIC_REFUND_DAYS'",-- CR49058
            MOBILE_PLAN_TYPE,
            MOBILE_DESCRIPTION,
            MOBILE_DESCRIPTION2,
            MOBILE_DESCRIPTION3,
            MOBILE_DESCRIPTION4,
            ILD_RATES_URL,
            --CR48643
            AVAILABLE_FOR_LRP_FLAG,
            POINTS_REQUIRED_TO_REDEEM,
            POINTS_ACCRUED_BY_PURCHASE,
            POINTS_ACCRUED_BY_AUTOREFILL
from ( select sv.*,lrp.AVAILABLE_FOR_LRP_FLAG, lrp.POINTS_REQUIRED_TO_REDEEM, lrp.POINTS_ACCRUED_BY_PURCHASE, lrp.POINTS_ACCRUED_BY_AUTOREFILL  from sa.vas_params_view sv, lrp_points_mv lrp where sv.vas_service_id = lrp.vas_service_id) PIVOT (MAX (vas_param_value)
             FOR vas_param_name
                                                IN ( 'VAS_APP_CARD',
                'VAS_CARD_CLASS',
                'VAS_ASSOCIATION',
                'VAS_BUS_ORG',
                'VAS_CATEGORY',
                'VAS_DESCRIPTION_ENGLISH',
                'VAS_DESCRIPTION_SPANISH',
                'VAS_IS_ACTIVE',
                'VAS_START_DATE',
                'VAS_END_DATE',
                'VAS_PRICE',
                'VAS_PRODUCT_TYPE',
                'VAS_RECURRING_DAYS',
                'SERVICE_DAYS',
                'GRACE_PERIOD',
                'VAS_SPONSOR',
                'VAS_TAX_CALCULATION',
                'VAS_TYPE',
                'VAS_VENDOR',
                'PRODUCT_ID',
                'PART_CLASS_OBJID',
                'PROGRAM_PARAMETERS_OBJID',
                'AUTO_PAY_PROGRAM_OBJID',-- CR49058
                'X_PROMOTION_OBJID',
                'VAS_GROUP_NAME',
                'OFFER_EXPIRY', -- CR49058
                'REENROLL_ALLOW_FLAG', -- CR49058
                'SHOW_DUE_BEFORE_DAYS', -- CR49058
                'PRORATION_FLAG',  -- CR49058
                'DIRECT_CANCEL_FLAG',-- CR49058
                'TRANSFER_ON_UPGRADE_FLAG', -- CR49058
                'TRANSFER_ON_REPLACEMENT_FLAG',-- CR49058
                'REFUND_ON_UPGRADE_FLAG',-- CR49058
                'REFUND_ON_REPLACEMENT_FLAG',-- CR49058
                'REFUND_ON_CANCELLATION_FLAG',-- CR49058
                'ELECTRONIC_REFUND_DAYS'-- CR49058
                ));
COMMENT ON MATERIALIZED VIEW sa.vas_programs_mv IS 'snapshot table for view SA.VAS_PROGRAMS_MV';