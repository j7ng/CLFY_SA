CREATE OR REPLACE FUNCTION sa."LRP_TEST_RATE_PLAN_F" (p_esn IN VARCHAR2)
       RETURN VARCHAR2 IS
	   rec LRP_template_final%ROWTYPE;
       c_carrier VARCHAR2(255);
     cursor c is
       WITH parts
            AS ( SELECT ml.objid                                        mod_level_objid,
                        pn.objid                                        part_objid,
                        pn.part_number                                  part_number,
                        pn.description                                  part_description,
                        pn.domain                                       part_domain,
                        bo.name                                         part_brand,
                        bo.objid                                        part_bus_org_objid,
                        pn.x_technology                                 part_technology,
                        pn.x_data_capable                               part_data_capable,
                        pn.x_ota_allowed                                part_ota_allowed,
                        x_dll                                           part_dll,
                        x_redeem_days                                   part_x_redeem_days,
                        x_redeem_units                                  part_x_redeem_units,
                        part_num2x_promotion                            part_num2x_promotion,
                        pc.objid                                        class_objid,
                        pc.name                                         class_name,
                        pc.x_model_number                               class_model_number,
                        pc.description                                  class_description,
                        Nvl( To_number( pp.data_speed )
						   , Nvl( To_number( pn.x_data_capable ), 0 ) ) data_speed,
                        pp.manufacturer,
                        pp.non_ppe,
                        pp.device_type                                  device_type,
                        pp.phone_gen,
                        pp.operating_system,
                        pp.balance_metering,
                        pp.meid_phone
                 FROM   TABLE_MOD_LEVEL ml,
                        TABLE_PART_NUM pn,
                        TABLE_PART_CLASS pc,
                        TABLE_BUS_ORG bo,
                        --SA.PCPV_MV pp
                        sa.pcpv pp
                 WHERE  1 = 1 AND
                        pn.objid = ml.part_info2part_num AND
                        pc.objid(+) = pn.part_num2part_class AND
                        bo.objid = pn.part_num2bus_org AND
                        pp.pc_objid(+) = pc.objid ),
            carriers
            AS ( SELECT ca.objid          carrier_objid,
                        ca.x_carrier_id   carrier_id,
                        cg.objid          carrier_group_objid,
                        cg.x_carrier_name carrier_group_carrier_name,
                        pa.objid          parent_objid,
                        pa.x_parent_id    parent_id,
                        pa.x_parent_name  parent_name
                 FROM   TABLE_X_CARRIER ca,
                        TABLE_X_CARRIER_GROUP cg,
                        TABLE_X_PARENT pa
                 WHERE  1 = 1 AND
                        cg.objid = ca.carrier2carrier_group AND
                        pa.objid = cg.x_carrier_group2x_parent ),
            safelink
            AS (SELECT 'SAFELINK|'||X_ENROLLMENT_STATUS sl_status
                      ,X_ESN
                FROM
                     (SELECT E.X_ENROLLMENT_STATUS
                           , RANK () OVER( PARTITION BY E.X_ESN
                                           ORDER BY    CASE WHEN E.X_ENROLLMENT_STATUS = 'ENROLLED'
                                                            THEN 1
                                                            ELSE 2
                                                       END
                                                     , E.X_ENROLLED_DATE DESC
						                             , E.OBJID           DESC ) LLRANK
                           , E.X_ESN
                        FROM X_PROGRAM_ENROLLED         E
                           , X_PROGRAM_PARAMETERS       P
                       WHERE 1=1
                         AND P.OBJID = E.PGM_ENROLL2PGM_PARAMETER
                         AND UPPER(P.X_PROGRAM_NAME) LIKE 'LIFE%')
                WHERE LLRANK = 1)
       SELECT row_rank,
              objid,
              x_service_id,
              x_min,
              x_msid,
              x_iccid,
              site_part_status,
              install_date,
              x_expire_dt,
              x_actual_expire_dt,
              update_stamp,
              site_part2x_new_plan,
              site_part2x_plan,
              part_class_objid,
              part_class_name,
              part_class_model_number,
              part_technology,
              part_brand,
              part_data_capable,
              part_number,
              data_speed,
              device_type,
              manufacturer,
              phone_gen,
              operating_system,
              non_ppe,
              carrier_objid,
              carrier_group_objid,
              carrier_group_carrier_name,
              carrier_parent_id,
              carrier_parent_name,
              service_plan_objid,
              service_plan_name,
              service_plan_description,
              call_trans_objid,
              call_trans_date,
              call_trans_reason,
              task_rate_plan,
              task_date,
              task_objid,
              ig_action_item_id,
              ig_update_date,
              ig_rate_plan
       FROM   ( SELECT Rank ( )
                         over(
                           PARTITION BY s.x_service_id
                           ORDER BY s.install_date    DESC, s.objid          DESC
       					          , x.x_transact_date DESC, x.objid          DESC
       						      , t.comp_date       DESC, t.objid          DESC
       						      , g.update_date     DESC, g.transaction_id DESC) row_rank,
                       s.objid,
                       s.x_service_id,
                       s.x_min,
                       s.x_msid,
                       s.x_iccid,
                       s.part_status                                    site_part_status,
                       s.install_date,
                       s.x_expire_dt,
                       s.x_actual_expire_dt,
                       s.update_stamp,
                       s.site_part2x_new_plan,
                       s.site_part2x_plan,
                       p.class_objid                                    part_class_objid,
                       p.class_name                                     part_class_name,
                       p.class_model_number                             part_class_model_number,
                       p.part_technology,
                       p.part_brand||'|'||k.sl_status part_brand,
                       p.part_data_capable,
                       p.part_number,
                       p.data_speed,
                       p.device_type,
                       p.manufacturer,
                       p.phone_gen,
                       p.operating_system,
                       p.non_ppe,
                       c.carrier_objid                                  carrier_objid,
                       c.carrier_group_objid,
                       c.carrier_group_carrier_name,
                       c.parent_id                                      carrier_parent_id,
                       c.parent_name                                    carrier_parent_name,
                       pp.objid                                         service_plan_objid,
                       pp.mkt_name                                      service_plan_name,
                       pp.description                                   service_plan_description,
                       x.objid                                          call_trans_objid,
                       x.x_transact_date                                call_trans_date,
                       x.x_reason                                       call_trans_reason,
                       t.x_rate_plan                                    task_rate_plan,
                       t.comp_date                                      task_date,
                       t.objid                                          task_objid,
                       g.action_item_id                                 ig_action_item_id,
                       g.update_date                                    ig_update_date,
                       g.rate_plan                                      ig_rate_plan
                FROM   sa.TABLE_SITE_PART          s,
                       sa.X_SERVICE_PLAN_SITE_PART ss,
                       sa.X_SERVICE_PLAN           pp,
                       sa.TABLE_PART_INST          i,
                       parts                       p,
                       carriers                    c,
                       sa.TABLE_X_CALL_TRANS       x,
                       sa.TABLE_TASK               t,
                       GW1.IG_TRANSACTION          g,
                       safelink                    k
                WHERE  1 = 1 AND
                       s.x_service_id           = i.part_serial_no     AND
                       ss.table_site_part_id(+) = s.objid              AND
                       pp.objid(+)              = ss.x_service_plan_id AND
                       x.call_trans2site_part   = s.objid              AND
                       t.x_task2x_call_trans(+) = x.objid              AND
                       g.action_item_id(+)      = t.task_id            AND
                       i.n_part_inst2part_mod   = p.mod_level_objid    AND
                       x.x_call_trans2carrier   = c.carrier_objid      AND
                       p.part_domain            = 'PHONES'             AND
                       i.x_domain               = 'PHONES'             AND
                       k.X_ESN(+)               = i.part_serial_no     AND
                       i.part_serial_no         = p_esn
                       --'014553006232674'
               )
       WHERE  row_rank = 1;
	   r c%rowtype;
    BEGIN
	   OPEN  c;
	   FETCH c into r;
       CLOSE c;
       rec := NULL;
       rec.sp_x_min_src                 := r.x_min;
       rec.pi_mdn_part_inst2carrier_mkt := r.carrier_objid;
       rec.sp_objid_src                 := r.objid;
       rec.sp_x_service_id_src          := r.x_service_id;
       rec.pn_data_capable              := r.part_data_capable;
       rec.pn_x_technology              := r.part_technology;
       rec.pn_part_number               := r.part_number;
       rec.spl_service_plan_desc        := r.service_plan_description;
       rec.ct_x_reason_src              := r.call_trans_reason;
	   rec.ct_x_call_trans2carrier_src  := r.carrier_objid;
	   rec.carrier_rate_plan            := NULL;
	   rec.last_redemption_type         := NULL;
	   rec.ct_x_transact_date_src       := r.call_trans_date;
	   rec.exception_table_flag         := 'N';
	   rec.pc_x_model_number            := r.part_class_model_number;
	   rec.carrier_status_alt           := UPPER(r.site_part_status);
       rec.spl_service_plan_desc := r.service_plan_objid||'|'||r.service_plan_description||'|'||r.service_plan_name||'|'||r.site_part2x_plan||'|'||r.site_part2x_new_plan;
       rec.pc_non_ppe := r.data_speed||'|'||r.manufacturer||'|'||r.device_type||'|'||r.phone_gen||'|'||r.operating_system||'||'||r.non_ppe;
       rec.brand      := r.part_brand||'|';

       --dbms_output.put_line(p_esn||'|'||rec.sp_x_min_src||'|'||r.part_class_model_number||'|'||r.part_brand||'|'||r.data_speed||'|'||rec.spl_service_plan_desc);

       c_carrier := substr(r.carrier_group_carrier_name,1,3);

       if c_carrier like 'AT%'  then c_carrier := 'ATT';     end if;
       if c_carrier like 'VER%' then c_carrier := 'VERIZON'; end if;
       if c_carrier like 'SPR%' then c_carrier := 'SPRINT';  end if;
       if c_carrier like 'T-M%' then c_carrier := 'TMOBILE'; end if;
       IF c_carrier IN ('VERIZON','SPRINT', 'TMOBILE','ATT') THEN
          dbms_output.put_line('carrier = '||r.carrier_group_carrier_name);
          RETURN LRP_rate_plan_rules_f(c_carrier, rec, true);
       ELSE
          RETURN 'rate plan not available for '||r.carrier_group_carrier_name;
       END IF;

END LRP_test_rate_plan_f;
/