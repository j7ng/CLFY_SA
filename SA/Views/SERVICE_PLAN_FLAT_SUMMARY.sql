CREATE OR REPLACE FORCE VIEW sa.service_plan_flat_summary (sp_objid,sp_mkt_name,fea_name,fea_value,fea_display,part_class_objid,part_class_name) AS
Select Distinct Sp.Objid Sp_Objid,Sp.Mkt_Name Sp_Mkt_Name,
                  Spfvdef.Value_Name Fea_Name,
                  spfvdef2.value_name Fea_value,
                  Spfvdef2.Display_Name Fea_Display,
                  part_class_objid,part_class_name
           FROM
            X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
            X_SERVICEPLANFEATURE_VALUE spfv,
            X_SERVICE_PLAN_FEATURE spf,
            X_Serviceplanfeaturevalue_Def Spfvdef2,
            X_Serviceplanfeaturevalue_Def Spfvdef3,
            X_Service_Plan Sp,
           (select sp.objid serv_objid,pc.objid part_class_objid,pc.name part_class_name
           FROM
            X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
            X_SERVICEPLANFEATURE_VALUE spfv,
            X_SERVICE_PLAN_FEATURE spf,
            X_Serviceplanfeaturevalue_Def Spfvdef2,
            X_Serviceplanfeaturevalue_Def Spfvdef3,
            X_Service_Plan Sp,
            Mtm_Partclass_X_Spf_Value_Def Mtm,
            table_part_class pc
           Where
            spf.sp_feature2rest_value_def = spfvdef.objid and
            spf.objid = spfv.spf_value2spf and
            Spfvdef2.Objid = Spfv.Value_Ref And
            Spfvdef3.Objid (+)= Spfv.Child_Value_Ref
            And Spfvdef.Value_Name = 'SUPPORTED PART CLASS'
            And Sp.Objid = Spf.Sp_Feature2service_Plan
            And Spfvdef2.Objid = Mtm.Spfeaturevalue_Def_Id
            And Pc.Objid = Mtm.Part_Class_Id) sp_pc_table
           Where
            spf.sp_feature2rest_value_def = spfvdef.objid and
            spf.objid = spfv.spf_value2spf and
            Spfvdef2.Objid = Spfv.Value_Ref And
            Spfvdef3.Objid (+)= Spfv.Child_Value_Ref
            And Sp.Objid = Spf.Sp_Feature2service_Plan
            and sp.objid = sp_pc_table.serv_objid;