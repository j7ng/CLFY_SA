CREATE MATERIALIZED VIEW sa.adfcrm_serv_plan_class_matview (sp_objid,sp_mkt_name,part_class_objid,part_class_name)
ORGANIZATION HEAP 
REFRESH COMPLETE 
AS SELECT DISTINCT Sp.Objid Sp_Objid,
    Sp.Mkt_Name Sp_Mkt_Name,
    part_class_objid,
    part_class_name
  FROM X_Service_Plan Sp,
    (SELECT sp.objid serv_objid,
      pc.objid part_class_objid,
      pc.name part_class_name
    FROM X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
      X_SERVICEPLANFEATURE_VALUE spfv,
      X_SERVICE_PLAN_FEATURE spf,
      X_Serviceplanfeaturevalue_Def Spfvdef2,
      X_Serviceplanfeaturevalue_Def Spfvdef3,
      X_Service_Plan Sp,
      Mtm_Partclass_X_Spf_Value_Def Mtm,
      table_part_class pc
    WHERE spf.sp_feature2rest_value_def = spfvdef.objid
    AND spf.objid                       = spfv.spf_value2spf
    AND Spfvdef2.Objid                  = Spfv.Value_Ref
    AND Spfvdef3.Objid (+)              = Spfv.Child_Value_Ref
    AND Spfvdef.Value_Name              = 'SUPPORTED PART CLASS'
    AND Sp.Objid                        = Spf.Sp_Feature2service_Plan
    AND Spfvdef2.Objid                  = Mtm.Spfeaturevalue_Def_Id
    AND Pc.Objid                        = Mtm.Part_Class_Id
    ) sp_pc_table
  WHERE sp.objid = sp_pc_table.serv_objid;