CREATE OR REPLACE PROCEDURE sa."GET_ESN_LIMIT_TYPES_PRC" ( i_esn              IN  VARCHAR2,
                                o_data_limit_type  OUT VARCHAR2,
				o_voice_limit_type OUT VARCHAR2,
				o_sms_limit_type   OUT VARCHAR2,
				o_error_num        OUT NUMBER,
				o_error_msg        OUT VARCHAR2
                              )
IS
   c                     sa.customer_type := sa.customer_type();
   n_service_plan_objid  NUMBER;
   c_short_paretnt_name  VARCHAR2(40);
   c_min                 VARCHAR2(40);
BEGIN

  IF i_esn IS NULL
  THEN
    o_error_num := 702;
    o_error_msg := 'ESN SHOULD BE PASSED';
    RETURN;
  END IF;

  n_service_plan_objid := c.get_service_plan_objid(i_esn => i_esn );
  c_short_paretnt_name := c.get_short_parent_name(i_esn => i_esn );
  c_min                := c.get_min(i_esn => i_esn );

  IF c_min IS NOT NULL AND ( n_service_plan_objid IS NULL OR n_service_plan_objid = 252 ) THEN
    o_sms_limit_type   := 'CAPPED';
    o_voice_limit_type := 'CAPPED';
    o_data_limit_type  := 'CAPPED';
    o_error_num        := 0;
    o_error_msg        := 'SUCCESS';
    return;
  END IF;

  BEGIN
    SELECT CASE WHEN NVL(sms,'X') IN ( '0','NA','X')
            THEN 'NONE'
            WHEN UPPER(sms) LIKE '%UNLIMITED%'
            THEN 'UNLIMITED'
            ELSE 'CAPPED'
           END sms,
           CASE WHEN NVL(voice,'X') IN ( '0','NA','X')
            THEN 'NONE'
            WHEN UPPER(voice) LIKE '%UNLIMITED%'
            THEN 'UNLIMITED'
            ELSE 'CAPPED'
           END voice
    INTO   o_sms_limit_type,
           o_voice_limit_type
    FROM   service_plan_feat_pivot_mv
    WHERE  service_plan_objid = n_service_plan_objid
    AND    rownum = 1;
  EXCEPTION

  WHEN OTHERS THEN
    o_error_num := 703;
    o_error_msg := 'SERVICE PLAN IS NOT AVAILABLE IN SERVICE_PLAN_FEAT_PIVOT_MV TABLE';
    RETURN;
  END;

  BEGIN
    SELECT CASE WHEN NVL(mv.data,'X') IN ('X', 'NA')
			 THEN 'NONE'
			 WHEN tp.DATA_SUSPENDED_FLAG = 'Y'
			 THEN 'CAPPED'
			 WHEN tp.DATA_SUSPENDED_FLAG IS NULL
			 THEN 'UNLIMITED'
			 ELSE 'NONE'
		   END  data
    INTO   o_data_limit_type
    FROM   service_plan_feat_pivot_mv mv,
           x_policy_mapping_config pc,
           w3ci.table_x_throttling_policy tp
    WHERE  mv.service_plan_objid = n_service_plan_objid
    AND    mv.cos = pc.cos
    AND    pc.parent_name = c_short_paretnt_name
    AND    pc.usage_tier_id = 2
    AND    pc.policy_objid = tp.objid
    AND    rownum = 1;
  EXCEPTION
  WHEN OTHERS THEN
    o_error_num := 703;
    o_error_msg := 'SERVICE PLAN IS NOT AVAILABLE IN SERVICE_PLAN_FEAT_PIVOT_MV TABLE';
    RETURN;
  END;

  o_error_num := 0;
  o_error_msg := 'SUCCESS';

END get_esn_limit_types_prc;
/