CREATE OR REPLACE TRIGGER sa."TRIG_X_RED_CARD"
BEFORE INSERT OR UPDATE
ON sa.TABLE_X_RED_CARD REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE

  CURSOR check_throttling_curs IS
    SELECT tc.*,
           ( SELECT cte.account_group_id
 	           FROM   table_x_call_trans_ext cte
             WHERE  cte.call_trans_ext2call_trans = ct.objid) group_id,
           NVL(sa.brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => sa.util_pkg.get_bus_org_id ( i_esn => ct.x_service_id ) ),'N') shared_group_flag
    FROM   table_x_call_trans ct,
           w3ci.table_x_throttling_cache tc
    WHERE  1 = 1
    AND    ct.objid = :NEW.red_card2call_trans
    AND    ( tc.x_esn = ct.x_service_id
	         or tc.x_min = ct.x_min)
    AND    tc.x_status IN ('A','P');

  CURSOR check_plan_curs IS
    SELECT  ct.x_transact_date
    FROM    table_x_call_trans ct
    WHERE   ct.x_action_type+0 IN ( 1, 3, 6)
    AND     ct.objid = :NEW.red_card2call_trans
    AND     NOT EXISTS ( SELECT 1    --vas ILD's
                         FROM   table_mod_level ml,
                                table_part_num pn,
                                table_part_class pc,
                                vas_programs_view pv
                         WHERE  ml.objid               = :NEW.x_red_card2part_mod
                         AND    ml.part_info2part_num  = pn.objid
                         AND    pn.domain              = 'REDEMPTION CARDS'
                         AND    pn.part_num2part_class = pc.objid
                         AND    pc.name                = pv.vas_card_class
                         UNION
                         SELECT 1   -- ILD service plans
                         FROM   adfcrm_serv_plan_class_matview pc,
                                sa.service_plan_feat_pivot_mv spmv,
                                table_mod_level ml,
                                table_part_num pn
                         WHERE  pc.sp_objid         = spmv.service_plan_objid
                         AND    pc.part_class_objid = pn.part_num2part_class
                         AND    spmv.service_plan_group   = 'ADD_ON_ILD'
                         AND    ml.objid            = :NEW.x_red_card2part_mod
                         AND    pn.objid            = ml.part_info2part_num
                         AND    pn.domain           = 'REDEMPTION CARDS'
                         )  ;

  check_plan_rec check_plan_curs%rowtype;

  t_error_message     VARCHAR2(300) := NULL;
  c_throttle_source   VARCHAR2(50)  := 'RED_CARD_TRIG';
  l_accnt_grp_id      NUMBER;
  c_error_message     VARCHAR2 (1000);

BEGIN
  --
  IF (INSERTING AND :NEW.x_result='Completed') OR
     (UPDATING  AND :OLD.x_result != 'Completed' AND :NEW.x_result = 'Completed') THEN
    --
    OPEN check_plan_curs;
    FETCH check_plan_curs INTO check_plan_rec;
      --
      IF check_plan_curs%FOUND THEN
        --
        FOR check_throttling_rec IN check_throttling_curs LOOP
          --accnt group id
          BEGIN
            SELECT DISTINCT agm.account_group_id
            INTO   l_accnt_grp_id
            FROM   table_x_call_trans_ext cte,
                   x_account_group_member agm
            WHERE  1 = 1
            AND    cte.call_trans_ext2call_trans =  :NEW.red_card2call_trans
            AND    cte.account_group_id IS NOT NULL
            AND    agm.account_group_id = cte.account_group_id
            AND    UPPER(agm.status) = 'ACTIVE';
          EXCEPTION
            WHEN OTHERS THEN
            NULL;
          END;

          -- ttoff stg
          BEGIN
            INSERT
            INTO w3ci.x_stg_ttoff_transactions
                 (objid                    ,
                  esn                      ,
                  MIN                      ,
                  throttle_source_system   ,
                  insert_timestamp         ,
                  shared_group_flag        ,
                  account_group_id  )
            VALUES
                  (w3ci.seq_x_stg_ttoff_transactions.nextval,
                   check_throttling_rec.x_esn ,
                   check_throttling_rec.x_min ,
                   c_throttle_source,
                   SYSDATE,
                   NVL(check_throttling_rec.shared_group_flag,'N'),
                   l_accnt_grp_id
                   );

          EXCEPTION
            WHEN OTHERS THEN
            c_error_message := SQLERRM;
            sa.ota_util_pkg.err_log ( p_action       => 'EXCEPTION WHILE INSEERT INTO TTOFF STG' ,
                                      p_error_date   => SYSDATE ,
                                      p_key          => check_throttling_rec.x_esn ,
                                      p_program_name => 'trig_x_red_card' ,
                                      p_error_text   => c_error_message);
          END;

        END LOOP;
      END IF;
    CLOSE check_plan_curs;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  --
  IF CHECK_PLAN_CURS%ISOPEN THEN
    CLOSE CHECK_PLAN_CURS;
  END IF;
  --
  t_error_message :=  t_error_message||' objid:'||:new.objid||':'||SQLCODE ||':'||SQLERRM;
  sa.ota_util_pkg.err_log(p_action        => 'check throttling'
                          ,p_error_date   => SYSDATE
                          ,p_key          => :new.x_smp
                          ,p_program_name => 'trig_x_red_card'
                          ,p_error_text   => t_error_message);

END;
/