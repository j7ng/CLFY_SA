CREATE OR REPLACE FUNCTION sa."GET_DATA_MTG_SOURCE" (p_esn VARCHAR2)  RETURN VARCHAR2
IS
/***********************************************************************************************/
/* Copyright (r) 2016 Tracfone Wireless Inc. All rights reserved                               */
/*                                                                                             */
/*                                                                                             */
/*                                                                                             */
/* Rev      Date        Who         Purpose                                                    */
/* -------  ----------- ----------  ---------------------------------------------              */
/* 1.0      11/22/2016  Tim         Check for PPE devices.
/***********************************************************************************************/


   v_mtg_source      x_product_config.voice_mtg_source%type := NULL;
   v_parent_name     table_x_parent.x_parent_name%type;
   v_brand           pcpv_mv.bus_org%type;
   v_device_type     pcpv_mv.device_type%type;
   v_splan_group     x_serviceplanfeaturevalue_def.value_name%type;

BEGIN

   BEGIN
     SELECT p.x_parent_name parent_name,
            pcpv.bus_org bus_org_id,
            device_type,
            sa.get_serv_plan_value(sa.UTIL_PKG.get_service_plan_id(pi_esn.part_serial_no),
                                                                   'SERVICE_PLAN_GROUP') service_plan_group
     INTO   v_parent_name,
            v_brand,
            v_device_type,
            v_splan_group
     FROM   table_part_inst pi_esn,
            table_part_inst pi_min,
            table_x_parent p,
            table_x_carrier_group cg,
            table_x_carrier c,
            table_mod_level ml,
            table_part_num pn,
            pcpv_mv pcpv
     WHERE  pi_esn.part_serial_no = p_esn
       AND  pi_esn.x_domain = 'PHONES'
       AND  pi_min.part_to_esn2part_inst = pi_esn.objid
       AND  pi_min.x_domain = 'LINES'
       and  c.objid = pi_min.part_inst2carrier_mkt
       AND  c.carrier2carrier_group = cg.objid
       AND  cg.x_carrier_group2x_parent = p.objid
       AND  pi_esn.n_part_inst2part_mod = ml.objid
       AND  ml.part_info2part_num = pn.objid
       AND  pn.domain = 'PHONES'
       AND  pn.part_num2part_class = pcpv.pc_objid;

   EXCEPTION WHEN OTHERS THEN

     -- It's null.
     -- CR47909 Tim 2/12017 Return PPE as default.
     v_mtg_source := 'PPE';
     RETURN v_mtg_source;

   END;

   BEGIN

      SELECT NVL(data_mtg_source,'PPE')  mtg_source
        INTO v_mtg_source
        FROM (
              SELECT data_mtg_source
                FROM x_product_config
               WHERE 1= 1
                 AND brand_name = v_brand
                 AND device_type = v_device_type
                 AND parent_name = v_parent_name
                 AND NVL(service_plan_group,'X') = CASE WHEN service_plan_group IS NOT NULL
                                                             AND
                                                             service_plan_group = v_splan_group
                                                        THEN service_plan_group
                                                        ELSE 'X'
                                                         END
                       ORDER BY  CASE WHEN service_plan_group = v_splan_group
                                      THEN 1
                                      ELSE 2
                                        END)
       WHERE ROWNUM = 1;

   EXCEPTION WHEN OTHERS THEN
     -- It's null.
     -- CR47909 Tim 2/12017 Return PPE as default.
     v_mtg_source := 'PPE';
     RETURN v_mtg_source;

   END;


      -- Success
      RETURN v_mtg_source;

EXCEPTION

   WHEN OTHERS THEN
      -- CR47909 Tim 2/12017 Return PPE as default.
      v_mtg_source := 'PPE';
      RETURN v_mtg_source;

END get_data_mtg_source;
/