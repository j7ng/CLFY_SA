CREATE OR REPLACE FUNCTION sa."GET_COS" ( i_esn        IN VARCHAR2,
                                        i_as_of_date IN DATE DEFAULT SYSDATE) RETURN VARCHAR2 AS
 --$RCSfile: get_cos.sql,v $
 --$Revision: 1.41 $
 --$Author: skota $
 --$Date: 2017/10/24 14:37:55 $
 --$ $Log: get_cos.sql,v $
 --$ Revision 1.41  2017/10/24 14:37:55  skota
 --$ Modified to get the latest cos
 --$
 --$ Revision 1.40  2017/08/22 15:57:07  mshah
 --$ CR52611 - NET10 DOUBLE DATA FOR LIFE PROMO
 --$
 --$ Revision 1.38  2017/08/18 21:35:28  mshah
 --$ CR52672 - StraightTalk PROMO BYOP New activations ???? New benefits for the $45 $55 plan
 --$
 --$ Revision 1.37  2017/08/18 13:59:35  mshah
 --$ CR52672 - StraightTalk PROMO BYOP New activations ???? New benefits for the $45 $55 plan
 --$
 --$ Revision 1.35  2017/08/17 20:56:11  mshah
 --$ CR52672 - StraightTalk PROMO BYOP New activations ???? New benefits for the $45 $55 plan
 --$
 --$ Revision 1.34  2017/08/17 16:10:47  mshah
 --$ CR52672 - StraightTalk PROMO BYOP New activations ???? New benefits for the $45 $55 plan
 --$
 --$ Revision 1.33  2017/08/16 14:57:14  mshah
 --$ CR52672 - StraightTalk PROMO BYOP New activations ???? New benefits for the $45 $55 plan
 --$
 --$ Revision 1.32  2017/08/15 15:46:32  skota
 --$ Make changes for ST Samsung Data promo
 --$
 --$ Revision 1.29  2017/08/14 16:54:00  mshah
 --$ CR52611 - NET10 DOUBLE DATA FOR LIFE PROMO
 --$
 --$ Revision 1.28  2017/08/07 21:07:57  mshah
 --$ CR52611 - NET10 DOUBLE DATA FOR LIFE PROMO
 --$
 --$ Revision 1.27  2017/05/31 18:48:50  skota
 --$ Added ST WINBAK TABLE for st reactivation Promo
 --$
 --$ Revision 1.26  2017/05/31 16:24:21  skota
 --$ Make changes for ST reactivation promo
 --$
 --$ Revision 1.25  2017/05/17 15:10:41  skota
 --$ added the card dealer in rules engine
 --$
 --$ Revision 1.24  2017/04/27 23:30:09  abustos
 --$ correct table_name
 --$
 --$ Revision 1.23  2017/04/26 22:47:53  abustos
 --$ Changes to Include activation_carrier and redemption card dealer
 --$
 --$ Revision 1.22  2017/04/25 21:19:35  abustos
 --$ Add configuration for esn part number
 --$
 --$ Revision 1.21  2016/12/05 19:49:08  pamistry
 --$ CR39916 - Removed Compensation Service Plan from process flag update
 --$
 --$ Revision 1.20  2016/12/01 00:06:27  pamistry
 --$ CR39916 - Production merge on 11/30/2016
 --$
 --$ Revision 1.19  2016/11/30 22:01:05  pamistry
 --$ CR39916 - Added Compensation Service Plan for case look up
 --$
 --$ Revision 1.18  2016/11/14 16:27:41  pamistry
 --$ CR39916 - Production merge on 11 14 2016
 --$
 --$ Revision 1.17  2016/11/01 19:12:42  pamistry
 --$ Modified the function to include Compensation flow for CR39916
 --$
 --$ Revision 1.14  2016/10/20 17:59:50  pamistry
 --$ CR39916 - Added order by to pick the latest case record
 --$
 --$ Revision 1.0  2016/10/20 14:22:50  pamistry
 --$ CR39916 - Added new logic to pick the cos value from case if found and not processed for Replacement and AWOP flow.
 --$
  rs                  sa.customer_type :=  customer_type ();
  s                   sa.customer_type;
  l_cos               sa.x_policy_rule_config.cos%TYPE;
  l_active_days       NUMBER;
  l_inctivate_promo_flag VARCHAR2(1) := 'Y';

  -- CR39916 Start - 10/05/2016 PMistry added new cursor to get cos value for compensation flow if it exists.
  cursor cur_get_cos_from_case is
      select c.x_esn, c.title, c.x_case_type, cd_cos.x_value cos_value, cd_pf.objid process_flag_objid, cd_pf.x_value process_flag_value
      from   table_case c, table_x_case_detail cd_cos, table_x_case_detail cd_pf
      where  1 = 1
      and    c.x_esn = i_esn
      and    c.title in ('Replacement Units', 'Replacement Service Plan', 'Compensation Units')
      and    c.x_case_type      = 'Units'
      and    cd_cos.detail2case = c.objid
      and    cd_pf.detail2case  = c.objid
      and    cd_cos.x_name      = 'COS'
      and    cd_pf.x_name       = 'PROCESS_FLAG'
      order by creation_time desc;

  rec_get_cos_from_case  cur_get_cos_from_case%rowtype;
  l_agent_process_flag VARCHAR2(1) := 'N';

BEGIN

 -- Validate the ESN is passed
 IF i_esn IS NULL THEN
     RETURN NULL;
 END IF;

  -- CR39916 Start - 10/05/2016 PMistry Get the cos value from case if the ESN have compensation flow.
  open cur_get_cos_from_case;
  fetch cur_get_cos_from_case into rec_get_cos_from_case;
  if cur_get_cos_from_case%found and  nvl(rec_get_cos_from_case.process_flag_value,'X') = 'N' then
    close cur_get_cos_from_case;

    -- update the process flag so that the cos value will not get picked up from case for second time.
    --update TABLE_X_CASE_DETAIL
    --set   x_value = 'Y'
    --where objid = rec_get_cos_from_case.process_flag_objid;

    return rec_get_cos_from_case.cos_value;

  end if;
  close cur_get_cos_from_case;
  -- CR39916 End

   -- Call the SA.get_cos_attributes method from the subscriber type
   s := rs.get_cos_attributes ( i_esn => i_esn );

  -- Get the cos value from a subscriber list
  BEGIN
    SELECT cos,   'Y'
    INTO   l_cos, l_agent_process_flag
    FROM   x_policy_rule_subscriber
    WHERE  esn = i_esn
    AND    i_as_of_date BETWEEN start_date AND NVL(end_date,SYSDATE)
    AND    inactive_flag = 'N';
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;

 -- Return the cos value from the subscriber list when available
 IF l_cos IS NOT NULL THEN
 RETURN sa.util_pkg.get_cos_by_red_date(l_cos, S.last_redemption_date);
 END IF;

 -- Get the cos value from st_winback list
  BEGIN
    SELECT inactive_flag
    INTO   l_inctivate_promo_flag
    FROM   sa.st_winback
    WHERE  esn = i_esn
    AND    inactive_flag = 'N';
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;

 -- Calculate the amount of days a customer has been active
  IF s.install_date IS NOT NULL THEN
    l_active_days := FLOOR(i_as_of_date - s.install_date);
  END IF;

  -- Select the COS value from the rule table
  BEGIN
    SELECT cos
    INTO   l_cos
    FROM   ( SELECT cos
             FROM   x_policy_rule_config xprc
             WHERE  1 = 1
             AND    SYSDATE BETWEEN xprc.start_date AND xprc.end_date -- rule is not expired
             AND    xprc.inactive_flag = 'N' -- rule is active
             AND    ( ( xprc.install_date_applicable_flag = 'Y' AND
                        s.install_date BETWEEN xprc.activation_date_from AND xprc.activation_date_to
                      )
                      OR xprc.install_date_applicable_flag = 'N'
                    )
             AND    ( ( xprc.activate_date_applicable_flag = 'Y' AND --52567
                        (
                         (s.activation_date BETWEEN xprc.activation_date_from AND xprc.activation_date_to)
                         OR
                         (l_agent_process_flag = 'Y')
                        )
                      )
                      OR xprc.activate_date_applicable_flag = 'N'
                    )
             AND    ( ( xprc.latest_activation_date_flag = 'Y' AND --52672
                        s.latest_activation_date BETWEEN xprc.activation_date_from AND xprc.activation_date_to
                      )
                      OR xprc.latest_activation_date_flag = 'N'
                    )
             AND    ( ( xprc.active_days_applicable_flag = 'Y' AND
                        l_active_days BETWEEN xprc.active_days_from AND xprc.active_days_to
                      )
                      OR xprc.active_days_applicable_flag = 'N'
                    )
             AND    ( ( xprc.install_date_by_min = 'Y' AND
                        (
                         (s.install_date_by_min BETWEEN xprc.activation_date_from AND xprc.activation_date_to)
                         OR
                         (l_agent_process_flag = 'Y')
                         )
                      )
                      OR xprc.install_date_by_min = 'N'
                    )
             AND    ( ( ( xprc.parent_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_parent
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    (parent_name = s.parent_name
                                           OR (parent_name = s.activation_parent_name AND xprc.activation_carrier_flag = 'Y')) -- subscriber's carrier parent name
                                   AND    inactive_flag = 'N'
                                 )
                         )
                         OR xprc.parent_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.part_class_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_part_class
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    part_class_objid = s.part_class_objid -- subscriber's part class
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.part_class_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.part_number_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_part_num
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    (esn_part_number = s.esn_part_number OR red_card_part_number = s.service_plan_part_number)-- subscriber's part number
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.part_number_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.service_plan_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_service_plan
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    ((service_plan_objid = s.service_plan_objid   and reactivation_flag = 'N') -- subscriber's service plan
                                          OR (service_plan_objid = s.service_plan_objid and reactivation_flag = 'Y' and l_inctivate_promo_flag = 'N' ))
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.service_plan_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.dealer_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_dealer
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    ( (site_id in (s.site_id, s.dealer_id) and card_dealer_applicable_flag = 'N' ) -- subscriber's dealer
                                             OR (site_id = s.card_dealer_id      and card_dealer_applicable_flag = 'Y' )
                                          )
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.dealer_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.brand_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_brand
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    bus_org_objid = s.bus_org_objid -- subscriber's brand
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.brand_applicable_flag = 'N'
                      )
                      AND
                      --CR52672 start
                      ( ( xprc.activation_service_plan_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.X_POLICY_RULE_ACTIVATION_SP
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    (SERVICE_PLAN_OBJID = s.activation_service_plan
                                          OR
                                          SERVICE_PLAN_OBJID = s.latest_activation_service_plan)
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.activation_service_plan_flag = 'N'
                      )
                      --CR52672 end
                    )
              ORDER BY priority -- order by the priority hierarchy
            )
     WHERE ROWNUM = 1; -- only return one rule

     DBMS_OUTPUT.PUT_LINE('COS from query: ' || l_cos);

     --
     IF l_cos IS NOT NULL THEN
       NULL;
     END IF;
     --
    EXCEPTION
     WHEN others THEN
       DBMS_OUTPUT.PUT_LINE('COS from query NOT FOUND');
       NULL;
  END;

  --CR44497
  -- If a rule was not determined
  --  IF l_cos IS NULL THEN
  --    -- Use original function to get the COS
  --    l_cos := get_esn_cos_value ( i_esn        => i_esn,
  --                                 i_as_of_date => i_as_of_date );
  --  END IF;

  -- If a rule was not found use the get_cos_attributes cos value
  IF l_cos IS NULL THEN
    l_cos := s.cos;
  END IF;

  RETURN sa.util_pkg.get_cos_by_red_date(l_cos, S.last_redemption_date);

 EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
END get_cos;
/