CREATE OR REPLACE FUNCTION sa."GET_TRANSACTION_COS" ( i_call_trans_objid IN NUMBER ) RETURN VARCHAR2 IS

  /**************************************************************************************
  * Function Name: get_transaction_cos
  * Description :  Gets the redemption code for the input call_trans_id and
  *                returns the COS Value for the redemption code
  * Return      :  COS Value
  * Created by  : Srinivasan Ethiraj (sethiraj)
  * Date        : 03/10/2016
  *
  * History
  * -----------------------------------------------------------------------------------
  * Date        Version   Modified by     Description
  * -----------------------------------------------------------------------------------
  * 03/10/2016  1.0       sethiraj        Initial Release - CR37756
  **************************************************************************************/
  --
  c  customer_type := customer_type ();

  l_red_code      varchar2(100);
  --
BEGIN

    -- getting the transaction cos from call trans extension
    -- CR44497
    BEGIN
     SELECT transaction_cos
       INTO c.cos
       FROM table_x_call_trans_ext
      WHERE call_trans_ext2call_trans = i_call_trans_objid;
      --
      IF  c.cos IS NOT NULL  THEN
        RETURN c.cos;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
       NULL;
    END;

    -- To get the redemption code for the given call trans obj id
    --
    BEGIN
      SELECT rc.x_red_code
      INTO   l_red_code
      FROM   table_x_call_trans ct,
             table_x_red_card rc
      WHERE  ct.objid = i_call_trans_objid --799745806 -- == call trans objid
      AND    ct.objid = rc.red_card2call_trans;
     EXCEPTION
       WHEN no_data_found THEN
         -- Optionally if the redeemed card is not found then go to the call trans extension as an alternative
         BEGIN
           SELECT mv.cos
           INTO   c.cos
           FROM   table_x_call_trans_ext ce,
                  sa.service_plan_feat_pivot_mv mv
           WHERE  call_trans_ext2call_trans = i_call_trans_objid --799745806 -- == call trans objid
           AND    ce.service_plan_id          = mv.service_plan_objid;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
         IF c.cos IS NOT NULL THEN
           RETURN c.cos;
         END IF;
       WHEN OTHERS THEN
         NULL;
    END;

    -- if the redeemed card is not found then do not proceed and return a 0
    IF l_red_code IS NULL THEN
      RETURN('0');
    END IF;

    --
    -- To get the COS value for the redemption code
    --
    BEGIN
      SELECT DISTINCT mv.cos
      INTO   c.cos
      FROM   sa.x_serviceplanfeaturevalue_def a,
             sa.mtm_partclass_x_spf_value_def b, -- card
             sa.x_serviceplanfeature_value spfv,
             sa.x_service_plan_feature spf,
             sa.x_service_plan sp,
             sa.service_plan_feat_pivot_mv mv
      WHERE  1 = 1
      AND    b.part_class_id IN ( SELECT pn.part_num2part_class
                                  FROM   table_part_inst rc,
                                         table_mod_level ml,
                                         table_part_num pn
                                  WHERE  1 = 1
                                  AND    rc.x_red_code = l_red_code
                                  AND    ml.objid      = rc.n_part_inst2part_mod
                                  AND    pn.objid      = ml.part_info2part_num
                                  --
                                  UNION
                                  SELECT pn.part_num2part_class
                                  FROM   table_x_red_card rc,
                                         table_mod_level ml,
                                         table_part_num pn
                                  WHERE  1 = 1
                                  AND    rc.x_red_code = l_red_code
                                  AND    ml.objid      = rc.x_red_card2part_mod
                                  AND    pn.objid      = ml.part_info2part_num
                                    --
                                )
      AND    spfv.value_ref = a.objid
      AND    spf.objid      = spfv.spf_value2spf
      AND    sp.objid       = spf.sp_feature2service_plan
      AND    a.objid        = b.spfeaturevalue_def_id
      AND    sp.objid       = mv.service_plan_objid;
     EXCEPTION
       WHEN others THEN
         BEGIN
           SELECT mv.cos
           INTO   c.cos
           FROM   table_x_call_trans_ext ce,
                  sa.service_plan_feat_pivot_mv mv
           WHERE  call_trans_ext2call_trans = i_call_trans_objid
           AND    ce.service_plan_id = mv.service_plan_objid;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
         END;
    END;

    -- return retrieved COS value
    RETURN c.cos;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN('0');
END get_transaction_cos;
/