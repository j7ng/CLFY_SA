CREATE OR REPLACE FORCE VIEW sa.splan_feat_pivot (splan_objid,sp_mkt_name,benefit_type,biz_line,block_ttoff_for_sp,broadband,carrier_bucket,carrier_bucket_intl,carrier_bucket_verizon,click_type,"COS",exception_cos,"EXCEPTIONS",coverage_script,data_counter_days_tmobile,"DATA",data_display,data_roam,handset_voice,ild,ild_permited,ild_product,ild_roam,international_sms_allowed,intl_roam_data,intl_roam_sms,intl_roam_voice,"PARENT",plan_type,plan_purchase_part_number,product_selection,promo_type,recurring_service_plan,rim_rate_plan,safelink_only,script_type,service_days,service_plan_group,service_plan_purchase,short_script,sibling_priority,sms,sms_display,sms_roam,sp_add_promo_script,supported_part_class,switch_based,tax_type,trans_summ_script,voice,voice_display,voice_roam,number_of_lines) AS
SELECT a.splan_objid,a.sp_mkt_name,a.benefit_type,a.biz_line,a.block_ttoff_for_sp,a.broadband,a.carrier_bucket,a.carrier_bucket_intl,
       a.carrier_bucket_verizon,a.click_type,a.cos,a.exception_cos,a.exceptions,a.coverage_script,a.data_counter_days_tmobile,a.data,a.data_display,a.data_roam,
       a.handset_voice,a.ild,a.ild_permited,a.ild_product,a.ild_roam,a.international_sms_allowed,a.intl_roam_data,a.intl_roam_sms,
       a.intl_roam_voice,a.parent,a.plan_type,a.plan_purchase_part_number,a.product_selection,a.promo_type,a.recurring_service_plan,
       a.rim_rate_plan,a.safelink_only,a.script_type,a.service_days,a.service_plan_group,a.service_plan_purchase,a.short_script,
       a.sibling_priority,a.sms,a.sms_display,a.sms_roam,a.sp_add_promo_script,a.supported_part_class,a.switch_based,a.tax_type,
       a.trans_summ_script,a.voice,a.voice_display,a.voice_roam, a.number_of_lines
FROM   table_part_num pn,
       ( SELECT *
         FROM   ( SELECT objid splan_objid, sp_mkt_name,fea_name,fea_display
                  FROM   adfcrm_serv_plan_feat_matview,
                         x_service_plan sp
                  WHERE  sp_objid = sp.objid
                )
         pivot ( MAX(fea_display) FOR fea_name IN ( 'BENEFIT_TYPE' as BENEFIT_TYPE,
                                                    'BIZ LINE' as BIZ_LINE,
                                                    'BLOCK_TTOFF_FOR_SP' as BLOCK_TTOFF_FOR_SP,
                                                    'BROADBAND' as BROADBAND,
                                                    'CARRIER_BUCKET' as CARRIER_BUCKET,
                                                    'CARRIER_BUCKET_INTL' as CARRIER_BUCKET_INTL,
                                                    'CARRIER_BUCKET_VERIZON' as CARRIER_BUCKET_VERIZON,
                                                    'CLICK TYPE' as CLICK_TYPE,
                                                    'COS' as COS,
                                                    'EXCEPTION_COS' as EXCEPTION_COS,
                                                    'EXCEPTIONS' AS exceptions,
                                                    'COVERAGE_SCRIPT' as COVERAGE_SCRIPT,
                                                    'DATA COUNTER DAYS TMOBILE' as DATA_COUNTER_DAYS_TMOBILE,
                                                    'DATA' as DATA,
                                                    'DATA_DISPLAY' as DATA_DISPLAY,
                                                    'DATA_ROAM' as DATA_ROAM,
                                                    'HANDSET VOICE' as HANDSET_VOICE,
                                                    'ILD' as ILD,
                                                    'ILD_PERMITED' as ILD_PERMITED,
                                                    'ILD_PRODUCT' as ILD_PRODUCT,
                                                    'ILD_ROAM' as ILD_ROAM,
                                                    'INTERNATIONAL_SMS_ALLOWED' as INTERNATIONAL_SMS_ALLOWED,
                                                    'INTL_ROAM_DATA' as INTL_ROAM_DATA,
                                                    'INTL_ROAM_SMS' as INTL_ROAM_SMS,
                                                    'INTL_ROAM_VOICE' as INTL_ROAM_VOICE,
                                                    'PARENT' as PARENT,
                                                    'PLAN TYPE' as PLAN_TYPE,
                                                    'PLAN_PURCHASE_PART_NUMBER' as PLAN_PURCHASE_PART_NUMBER,
                                                    'PRODUCT_SELECTION' as PRODUCT_SELECTION,
                                                    'PROMO TYPE' as PROMO_TYPE,
                                                    'RECURRING_SERVICE_PLAN' as RECURRING_SERVICE_PLAN,
                                                    'RIM_RATE_PLAN' as RIM_RATE_PLAN,
                                                    'SAFELINK_ONLY' as SAFELINK_ONLY,
                                                    'SCRIPT TYPE' as SCRIPT_TYPE,
                                                    'SERVICE DAYS' as SERVICE_DAYS,
                                                    'SERVICE_PLAN_GROUP' as SERVICE_PLAN_GROUP,
                                                    'SERVICE_PLAN_PURCHASE' as SERVICE_PLAN_PURCHASE,
                                                    'SHORT_SCRIPT' as SHORT_SCRIPT,
                                                    'SIBLING PRIORITY' as SIBLING_PRIORITY,
                                                    'SMS' as SMS,
                                                    'SMS_DISPLAY' as SMS_DISPLAY,
                                                    'SMS_ROAM' as SMS_ROAM,
                                                    'SP_ADD_PROMO_SCRIPT' as SP_ADD_PROMO_SCRIPT,
                                                    'SUPPORTED PART CLASS' as SUPPORTED_PART_CLASS,
                                                    'SWITCH BASED' as SWITCH_BASED,
                                                    'TAX TYPE' as TAX_TYPE,
                                                    'TRANS_SUMM_SCRIPT' as TRANS_SUMM_SCRIPT,
                                                    'VOICE' as VOICE,
                                                    'VOICE_DISPLAY' as VOICE_DISPLAY,
                                                    'VOICE_ROAM' as VOICE_ROAM,
                                                    'NUMBER_OF_LINES' as number_of_lines
                                                  )
               )
       ) a
WHERE  plan_purchase_part_number = pn.part_number(+);