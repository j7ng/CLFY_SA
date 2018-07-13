CREATE OR REPLACE PROCEDURE sa."GET_ELIGIBLE_DEVICE_TYPES" ( i_bus_org          IN  VARCHAR2,
                                                        o_eligible_devices OUT ELIGIBLE_DEVICES_TAB,
                                                        o_error_code       OUT VARCHAR2,
                                                        o_error_message    OUT VARCHAR2)
IS

  c_biz_line varchar2(100);
begin

  IF i_bus_org is null then
    o_error_code := '-1';
    o_error_message := 'Brand cannot be NULL';
    return;
  end if;

  c_biz_line := case when i_bus_org='TOTAL_WIRELESS' then 'TOTAL WIRELESS'
            when i_bus_org='STRAIGHT_TALK' then 'STRAIGHT TALK'
            when i_bus_org='TRACFONE' then 'TF'
            when i_bus_org='SIMPLE_MOBILE' then 'SIMPLE MOBILE'
            else i_bus_org end ;

  SELECT sa.eligible_devices_type (service_plan_objid,
                                   LISTAGG( device_type,',') WITHIN GROUP(ORDER BY device_type )
                                   )
    BULK COLLECT
    INTO  o_eligible_devices
  FROM
    ( SELECT DISTINCT service_plan_objid,
      CASE device_type
        WHEN 'MOBILE_BROADBAND'         THEN 'HOTSPOT'
        WHEN 'BYOP'                     THEN 'SMARTPHONE'
        WHEN 'BYOT'                     THEN 'SMARTPHONE'
        WHEN 'WIRELESS_HOME_PHONE'      THEN 'HOMEPHONE'
        ELSE device_type
      END device_type
    FROM sa.service_plan_feat_pivot_mv spfpm,
      sa.adfcrm_serv_plan_class_matview adf,
      sa.pcpv_mv pc
    WHERE 1                   =1
    AND adf.sp_objid          = spfpm.service_plan_objid
    AND adf.part_class_objid  = pc.pc_objid
    AND biz_line              = c_biz_line
    AND service_plan_purchase = 'AVAILABLE'
    )
  GROUP BY service_plan_objid;


  o_error_code := '0';
  o_error_message := 'Success';

exception
when others
then
  o_error_code := '500';
  o_error_message := 'Error while retrieving eligible devices: ' || SQLERRM;
end;
/