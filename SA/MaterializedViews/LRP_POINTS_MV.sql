CREATE MATERIALIZED VIEW sa.lrp_points_mv (vas_service_id,available_for_lrp_flag,points_required_to_redeem,points_accrued_by_purchase,points_accrued_by_autorefill)
ORGANIZATION HEAP 
REFRESH COMPLETE 
AS select vas_service_id,
            AVAILABLE_FOR_LRP_FLAG,
            POINTS_REQUIRED_TO_REDEEM,
            POINTS_ACCRUED_BY_PURCHASE,
            POINTS_ACCRUED_BY_AUTOREFILL
from ( select *  from sa.vas_params_view sv, table(sa.lrp_detail_tab(lrp_Detail_type(sv.vas_service_id))) lrp) PIVOT (MAX (vas_param_value)
             FOR vas_param_name
                                                IN ( 'VAS_APP_CARD',
                'VAS_CARD_CLASS',
                'VAS_ASSOCIATION',
                'VAS_BUS_ORG',
                'VAS_CATEGORY'
                ));
COMMENT ON MATERIALIZED VIEW sa.lrp_points_mv IS 'snapshot table for lrp points for VAS plans';