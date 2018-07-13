CREATE OR REPLACE PROCEDURE sa.CLEAN_TNUMBER_PRC (
   ip_esn      IN       VARCHAR2,
   p_out_num   OUT      NUMBER,
   p_out_msg   OUT      VARCHAR2
)
IS
/********************************************************************************************/
   /*  Copyright   2002 Tracfone  Wireless Inc. All rights reserved                            */
   /*                                                                                          */
   /* NAME     :       CLEAN_TNUMBER_PRC                                                       */
   /* PURPOSE  :       This procedure is called from the method validate_phone_prc             */
   /*                  to delet any T-Numbers attached to the esn for certain statuses         */
   /* FREQUENCY:                                                                               */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                           */
   /*                                                                                          */
   /* REVISIONS:                                                                               */
   /* VERSION  DATE       WHO               PURPOSE                                            */
   /* -------  ---------- -----             ---------------------------------------------      */
   /*  1.0     04/10/08   VAdapa            Initial   Revision                                 */
   /*  1.1     04/16/08   VAdapa            Latest, changed the grants, removed the TMODATA label
   /*  1.2     08/11/08   VAdapa            CDMA Next Available
   /*  1.3-.5  05/05/09   VAdapa            CR8663 - Wal-Mart Monthly Plans
/***************************************************************************************************/
   /* NEW CVS STRUCTURE \PLSQL_CVS\PLSQL\SA\Procedures                                         */
   /* 1.1    03/12/10            NGuada      Migrate from PVCS to CVS                          */
   /* 1.2    05/06/10            Skuthadi    CR11971 ST_GSM  modified c_get_nonppe             */
   /* 1.3    07/23/10            Vadapa      ST_GSM_II                                         */
   /* 1.4-1.5  07/28/10          Vadapa      ST_GSM_II DO NOT CLEAN T-NUM FOR PORT IN     */
/*    1.8     06/18/12           Clindner    CR19821 Net10 Activation engine               */
/***************************************************************************************************/
   CURSOR c_get_esn_status
   IS
      SELECT x_part_inst_status,nvl(x_port_in,0) x_port_in,objid   --CR19821
        FROM table_part_inst
       WHERE part_serial_no = ip_esn;

   r_get_esn_status   c_get_esn_status%ROWTYPE;

   --
   CURSOR c_get_tline
   IS
      SELECT   piesn.objid esn_objid, pimin.objid line_objid,
               pimin.part_serial_no line
          FROM table_part_inst piesn, table_part_inst pimin
         WHERE pimin.part_to_esn2part_inst = piesn.objid
          AND piesn.part_serial_no = ip_esn
      ORDER BY pimin.part_serial_no DESC;

   --
   --CDMA NA
   CURSOR c_get_tech
   IS
      SELECT nvl(x_technology,'NONE') x_technology               --CR19821
        FROM table_mod_level ml, table_part_num pn, table_part_inst pi
       WHERE pi.n_part_inst2part_mod + 0 = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND part_serial_no = ip_esn;

   r_get_tech         c_get_tech%ROWTYPE;

   --CDMA NA
   --CR8663
   CURSOR c_get_nonppe
   IS
   SELECT nvl(v.x_param_value,0) x_param_value, bo.org_id     --CR19821
   FROM table_x_part_class_values v, table_x_part_class_params n,
   table_part_num pn, table_mod_level ml, table_part_inst pi,table_bus_org bo
   WHERE 1 = 1
   AND pn.part_num2bus_org = bo.objid               -- CR11971 use bus org
   AND bo.org_id in ('NET10', 'STRAIGHT_TALK')                  -- ST_GSM CR19821
   AND v.value2part_class = pn.part_num2part_class
   AND v.value2class_param = n.objid
   AND n.x_param_name = 'NON_PPE'
   AND pn.objid = ml.part_info2part_num
   AND ml.objid = pi.n_part_inst2part_mod
   AND pi.part_serial_no = ip_esn;
   r_get_nonppe c_get_nonppe%ROWTYPE;
   l_nonppe NUMBER := 0;
--CR8663
BEGIN
--CR19821
   p_out_num := 0;
   p_out_msg := 'Success';
   OPEN c_get_esn_status;
     FETCH c_get_esn_status  INTO r_get_esn_status;
     IF c_get_esn_status%NOTFOUND THEN
       p_out_num := 1;
       p_out_msg := 'ESN not found';
       CLOSE c_get_esn_status;
       RETURN;
     end if;
   CLOSE c_get_esn_status;
   dbms_output.put_line('r_get_esn_status.x_part_inst_status:'||r_get_esn_status.x_part_inst_status);
   IF r_get_esn_status.x_part_inst_status != '52' then
     dbms_output.put_line('part_status = 52 ');
     DELETE FROM table_part_inst
      WHERE part_to_esn2part_inst = r_get_esn_status.objid
        and part_serial_no||'' like 'T%';      --CR19821
     COMMIT;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      p_out_num := 2;
      p_out_msg := 'Exception occurred';
      RETURN;
END;
/