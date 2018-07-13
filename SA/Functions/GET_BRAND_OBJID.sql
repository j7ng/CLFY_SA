CREATE OR REPLACE FUNCTION sa."GET_BRAND_OBJID" (p_esn VARCHAR2)
   RETURN NUMBER
IS
/***********************************************************************************************/
/* Copyright (r) 2009 Tracfone Wireless Inc. All rights reserved                               */
/*                                                                                             */
/* Name         :   GET_BRAND_OBJID                                                            */
/* Purpose      :   Brand Separation - Replaces the get_restricted_use function                */
/* Parameters   :                                                                              */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                            */
/* Author       :   Natalio Guada                                                              */
/* Date         :   08/31/2009                                                                 */
/* Revisions    :                                                                              */
/*                                                                                             */
/* NEW PVCS STRUCTURE /NEW_PLSQL/CODE                                                          */
/*                                                                                             */
/* Rev      Date        Who         Purpose                                                    */
/* -------  ----------- ----------  ---------------------------------------------              */
/* 1.0      08/31/2009  NGuada      Initial                                                    */
/* 1.1      08/31/2009  VAdapa                    Latest (Added the close cursor in the right place)
/***********************************************************************************************/
   CURSOR c_esn
   IS
      SELECT bo.*
        FROM table_part_num pn,
             table_mod_level ml,
             table_part_inst pi,
             table_bus_org bo
       WHERE 1 = 1
         AND ml.part_info2part_num = pn.objid
         AND pi.n_part_inst2part_mod = ml.objid
         AND pi.part_serial_no = p_esn
         AND pn.part_num2bus_org = bo.objid;

   l_part_num_rec    c_esn%ROWTYPE;
   l_default_brand   NUMBER          := 268438257;
BEGIN
   OPEN c_esn;

   FETCH c_esn
    INTO l_part_num_rec;

   IF c_esn%NOTFOUND
   THEN
      CLOSE c_esn;

      RETURN l_default_brand;
   ELSE
      CLOSE c_esn;

      RETURN l_part_num_rec.objid;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      IF c_esn%ISOPEN
      THEN
         CLOSE c_esn;
      END IF;

      RETURN l_default_brand;
END;
/