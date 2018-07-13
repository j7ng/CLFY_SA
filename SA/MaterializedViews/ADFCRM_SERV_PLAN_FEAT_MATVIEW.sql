CREATE MATERIALIZED VIEW sa.adfcrm_serv_plan_feat_matview (sp_objid,sp_mkt_name,fea_name,fea_value,fea_display)
ORGANIZATION HEAP 
REFRESH COMPLETE 
AS SELECT DISTINCT Sp.Objid Sp_Objid,
    Sp.Mkt_Name Sp_Mkt_Name,
    Spfvdef.Value_Name Fea_Name,
    spfvdef2.value_name Fea_value,
    Spfvdef2.Display_Name Fea_Display
  FROM X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
    X_SERVICEPLANFEATURE_VALUE spfv,
    X_SERVICE_PLAN_FEATURE spf,
    X_Serviceplanfeaturevalue_Def Spfvdef2,
    X_Serviceplanfeaturevalue_Def Spfvdef3,
    X_Service_Plan Sp
  WHERE spf.sp_feature2rest_value_def = spfvdef.objid
  AND spf.objid                       = spfv.spf_value2spf
  AND Spfvdef2.Objid                  = Spfv.Value_Ref
  AND Spfvdef3.Objid (+)              = Spfv.Child_Value_Ref
  AND Sp.Objid                        = Spf.Sp_Feature2service_Plan;