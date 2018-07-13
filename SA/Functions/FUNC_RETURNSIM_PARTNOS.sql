CREATE OR REPLACE FUNCTION sa."FUNC_RETURNSIM_PARTNOS" (
                                                  ip_byop_type IN VARCHAR2,
                                                  ip_brand     IN VARCHAR2 ) RETURN VARCHAR2
   AS

   ret_Simpartno VARCHAR2(50);

   CURSOR c_simpartnumber(ip_brand IN VARCHAR2)
   IS
     SELECT pn.part_number
       FROM table_mod_level ml,
            table_part_num pn ,
            x_byop_part_num bpn
      WHERE 1                     = 1
        AND bpn.x_org_id          = ip_brand
        AND bpn.x_byop_type       = ip_byop_type
        AND pn.part_number        = bpn.x_part_number
        AND ml.part_info2part_num = pn.objid;
   BEGIN

      OPEN c_simpartnumber(ip_brand);

     FETCH c_simpartnumber
      INTO ret_Simpartno ;

    RETURN ret_Simpartno;

   END func_returnSim_partnos;
/