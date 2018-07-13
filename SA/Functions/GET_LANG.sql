CREATE OR REPLACE FUNCTION sa."GET_LANG" (
    p_action_item_id IN VARCHAR2)
  RETURN VARCHAR2
AS
  v_language     VARCHAR2(100);
  v_bucket_value NUMBER;
  CURSOR lang_cur_upd
  IS
    SELECT ig.esn,
      ig.order_type,
      sp.benefit_type,
      ig.transaction_id,
      tsp.part_status,
      tt.title,
      ct.x_reason,
      ct.x_sub_sourcesystem,
      (SELECT tp.x_parent_name
      FROM table_x_carrier tc,
        table_x_carrier_group cg,
        table_x_parent tp
      WHERE 1         = 1
      AND tp.objid    = cg.x_carrier_group2x_parent
      AND cg.objid    = tc.carrier2carrier_group
      AND tc.objid    = ct.x_call_trans2carrier
      AND tp.x_status = 'ACTIVE'
      AND ROWNUM      = 1
      ) parent_name
  FROM ig_transaction ig,
    table_task tt,
    table_x_call_trans ct,
    table_site_part tsp,
    x_service_plan_site_part spsp,
    service_plan_feat_pivot_mv sp
  WHERE ig.action_item_id    = p_action_item_id
  AND ig.action_item_id      = tt.task_id
  AND tt.x_task2x_call_trans = ct.objid
  AND ig.esn                 = tsp.x_service_id
  AND tsp.objid              =
    (SELECT MAX(tsp1.objid)
    FROM table_site_part tsp1
    WHERE tsp1.x_service_id = tsp.x_service_id
    )
  AND tsp.objid              = spsp.table_site_part_id
  AND spsp.x_service_plan_id = sp.service_plan_objid;
BEGIN
  FOR cur_rec IN lang_cur_upd
  LOOP
    v_language:=cur_rec.benefit_type;
    BEGIN
      SELECT bucket_value
      INTO v_bucket_value
      FROM
        (SELECT bucket_value
        FROM ig_transaction_buckets
        WHERE direction    ='OUTBOUND'
        AND transaction_id =cur_rec.transaction_id
        ORDER BY bucket_value DESC
        )
      WHERE ROWNUM =1;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    IF v_bucket_value = 0 THEN
      IF (cur_rec.title IN ('T-MOBILE GSM ESN CHANGE','T-MOBILE SAFELINK ESN CHANGE') AND cur_rec.parent_name LIKE 'T-MOBILE%' AND cur_rec.order_type='E' ) THEN
        v_language := 'TRANSFER' ;
      END IF;

      IF (cur_rec.title LIKE 'VERIZON%ESN CHANGE' AND cur_rec.parent_name like 'VERIZON%' AND cur_rec.order_type='E' )
      THEN
      v_language   := 'TRANSFER' ;
      END IF;

      IF (cur_rec.title LIKE 'AT&T%ESN CHANGE' AND cur_rec.parent_name like 'AT&T%' AND cur_rec.order_type='E' )
      THEN
      v_language   := 'TRANSFER' ;
      END IF;

      IF (cur_rec.title LIKE 'CINGULAR%ESN CHANGE' AND cur_rec.parent_name like 'CINGULAR%' AND cur_rec.order_type='E' )
      THEN
      v_language   := 'TRANSFER' ;
      END IF;

      IF (cur_rec.x_reason='Safelink De-Enrollment' AND
      (cur_rec.parent_name LIKE 'T-MOBILE%' OR cur_rec.parent_name LIKE 'AT&T%' OR cur_rec.parent_name LIKE 'CINGULAR%' OR cur_rec.parent_name LIKE 'VERIZON%') AND cur_rec.order_type ='R') THEN
        v_language       := 'TRANSFER' ;
      END IF;

    END IF;

     IF (cur_rec.x_reason='Safelink Re-Enrollment' AND
     (cur_rec.parent_name LIKE 'VERIZON%' OR cur_rec.parent_name LIKE 'T-MOBILE%' OR cur_rec.parent_name LIKE 'AT&T%' OR cur_rec.parent_name LIKE 'CINGULAR%' )AND cur_rec.order_type = 'CR') THEN
        v_language       := 'TRANSFER' ;
     END IF;

     IF (cur_rec.x_reason IN ('Compensation','Replacement') AND cur_rec.x_sub_sourcesystem = 'TRACFONE')
     THEN
        v_language := 'STACK';
     END IF;

     --CR 43884 for REFUND Order Type.
     IF cur_rec.order_type='REFUND' THEN
        v_language       := 'REFUND' ;
     END IF;


  END LOOP;
  RETURN v_language;
EXCEPTION
WHEN OTHERS THEN
  RETURN v_language;
END;
/