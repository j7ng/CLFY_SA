CREATE OR REPLACE FUNCTION sa.is_splan_swapped(ip_esn IN VARCHAR2)
RETURN NUMBER IS

--Returns 0 if not swapped and 1 if swapped
 l_start_date DATE;
 l_cnt NUMBER;
 l_splan VARCHAR2(30);
 l_parent_count NUMBER;
 since_last_hour VARCHAR2(30);
 TYPE l_parent_type IS VARRAY(2) OF VARCHAR2(200);
 l_parent l_parent_type := l_parent_type('','');
BEGIN
  SELECT count(*)
  INTO l_cnt
  FROM sa.x_service_plan_hist
  WHERE plan_hist2site_part IN
             (SELECT objid
              FROM table_site_part sp
              WHERE x_service_id=ip_esn
              AND part_status = 'Active');
  IF l_cnt < 2 THEN
     RETURN 0;
  ELSE
     SELECT decode(MAX(trunc(x_start_date)),
                     trunc(SYSDATE),'TRUE',
                     decode(trunc(MAX(x_start_date),'HH24'),
                            trunc(SYSDATE-1/24,'HH24'),'TRUE','FALSE'))
     INTO since_last_hour
     FROM sa.x_service_plan_hist
     WHERE plan_hist2site_part IN
             (SELECT objid
              FROM table_site_part sp
              WHERE x_service_id=ip_esn
              AND part_status = 'Active');
     IF since_last_hour <> 'TRUE' THEN
         RETURN 0;
     ELSE
         FOR sp IN (SELECT ROWNUM  rn, A.*
                    FROM (SELECT plan_hist2service_plan splan_objid,x_start_date
                    FROM sa.x_service_plan_hist sph
                    WHERE plan_hist2site_part IN
                        (SELECT objid
                         FROM table_site_part sp
                         WHERE x_service_id=ip_esn
                         AND part_status = 'Active')
                         ORDER BY x_start_date DESC) A
                    WHERE ROWNUM < 3)
         LOOP
           BEGIN
               SELECT DISTINCT spfvdef2.value_name
               INTO l_parent(sp.rn)
               FROM x_serviceplanfeaturevalue_def spfvdef,
                    x_serviceplanfeature_value spfv,
                    x_service_plan_feature spf,
                    x_serviceplanfeaturevalue_def spfvdef2,
                    x_service_plan sp
               WHERE 1=1
               AND sp.objid  = sp.splan_objid
               AND spf.sp_feature2service_plan = sp.objid
               AND spf.sp_feature2rest_value_def = spfvdef.objid
               AND spf.objid = spfv.spf_value2spf
               AND spfvdef2.objid = spfv.value_ref
               AND spfvdef.value_name = 'PARENT';

           EXCEPTION
                WHEN no_data_found THEN
                  l_parent(sp.rn) := sp.rn;
           END;

        END loop;
        IF l_parent(1) <> l_parent(2) THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;

     END IF;
  END IF;
EXCEPTION
 WHEN no_data_found THEN
 RETURN 0;
END;
/