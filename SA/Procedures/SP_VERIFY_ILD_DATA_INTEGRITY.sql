CREATE OR REPLACE PROCEDURE sa."SP_VERIFY_ILD_DATA_INTEGRITY"
   /********************************************************************************/
   /* Name         :   sp_verify_ild_data_integrity_prc
/* Platforms    :   Oracle 8.0.6 AND newer versions
/* Date         :   02/28/07
/* Revisions    :
/*
/* Version  Date        Who       Purpose
/* -------  --------    -------   --------------------------------------
/*  1.0	    02/28/07        	  Initial Release
/*  1.1     06/29/07    NG      Expanded to Include other ILD Types
/*  1.2     06/29/07    NG      Expanded to Include other ILD Types
/************* NEW PVCS FOLDER **************************************************/
/* 1.0     09/17/08    NG       Remove reset on low units   CR7323
/* 1.2     01/19/11    Skuthadi CR15157 to skip updating x_redemtion_menu for ST ESNS */
/* 1.4     07/17/12    ICanavan CR20451 | CR20854: Add TELCEL Brand                   */
/**************************************************************************************/
   ( p_esn IN VARCHAR2 )
IS
   CURSOR cur_pn
   IS
   SELECT PN.OBJID PN_OBJID, PI.OBJID PI_OBJID, PN.X_ILD_TYPE,PN.X_DLL,
          PN.PART_NUM2PART_CLASS,BO.ORG_ID,BO.ORG_FLOW -- ADD ORG_FLOW FOR TELCEL
   FROM table_part_num pn, table_part_inst pi, table_mod_level ml,table_bus_org bo
   WHERE pn.objid = ml.part_info2part_num
   AND ML.OBJID = PI.N_PART_INST2PART_MOD
   AND PN.PART_NUM2BUS_ORG = bo.objid
   -- CR20451 | CR20854: Add TELCEL Brand
   --AND pn.x_restricted_use = 3
   AND BO.ORG_FLOW IN ('2','3') -- ADDED THIS LINE REMOVED THE ONE ABOVE
   AND pi.x_part_inst_status = '52'
   AND pi.part_serial_no = p_esn
   AND pi.x_domain = 'PHONES';
   rec_pn cur_pn%ROWTYPE;

-- CR15157 - modified above cursor cur_pn to get part class and bus org
--(as Restricted Use = 3 can be for NET10 as well as ST)


   CURSOR cur_ota_f(
      c_pi_objid IN NUMBER
   )
   IS
   SELECT objid of_objid,
      x_redemption_menu,
      x_handset_lock,
      x_low_units,
      x_psms_destination_addr,
      x_ild_prog_status
   FROM table_x_ota_features
   WHERE x_ota_features2part_inst = c_pi_objid;
   rec_ota_f cur_ota_f%ROWTYPE;

   CURSOR cur_psms_address
   IS
   SELECT table_x_parent.X_OTA_PSMS_ADDRESS
   FROM table_x_carrier, table_x_carrier_group, table_x_parent
   WHERE table_x_carrier.CARRIER2CARRIER_GROUP = table_x_carrier_group.objid
   AND table_x_carrier_group.X_CARRIER_GROUP2X_PARENT=table_x_parent.objid
   AND table_x_carrier.objid IN (SELECT table_part_inst.PART_INST2CARRIER_MKT
                                              FROM table_part_inst
							                  WHERE part_serial_no IN (SELECT x_min FROM table_site_part
							                                                        WHERE x_service_id = p_esn
													                                AND PART_STATUS = 'Active'));

   rec_psms_address cur_psms_address%rowtype;

   L_PSMS varchar2(30);
   OTA_FOUND number:=0;

BEGIN


   OPEN cur_psms_address;
   FETCH cur_psms_address INTO rec_psms_address;
   IF (cur_psms_address %FOUND)  then
      l_psms := nvl(rec_psms_address.X_OTA_PSMS_ADDRESS,'31778');
   ELSE
      l_psms := '31778';
   END IF;
   CLOSE cur_psms_address;


   for rec_pn in cur_pn loop

      IF rec_pn.x_dll IN ( 14, 19, 21)
      AND rec_pn.x_ild_type <> 2
      THEN
         UPDATE table_part_num SET x_ild_type = 2
         WHERE objid = rec_pn.pn_objid;
      END IF;
      IF rec_pn.x_dll IN ( 15, 16, 20, 24, 26)
      AND rec_pn.x_ild_type <> 1
      THEN
         UPDATE table_part_num SET x_ild_type = 1
         WHERE objid = rec_pn.pn_objid;
      END IF;
      IF (rec_pn.x_dll IN (22, 23, 25)
      OR rec_pn.x_dll >= 27)
      AND rec_pn.x_ild_type <> 3
      THEN
         UPDATE table_part_num SET x_ild_type = 3
         WHERE objid = rec_pn.pn_objid;
      END IF;

      IF (rec_pn.x_dll IN (22, 23, 25)  OR rec_pn.x_dll >= 27) THEN

         FOR rec_ota_f in cur_ota_f(rec_pn.pi_objid) loop
            ota_found:=1;
            IF rec_ota_f.x_redemption_menu != 'Y'
            THEN
                -- CR15157 Starts
                -- CR20451 | CR20854: Add TELCEL Brand
                -- IF REC_PN.ORG_ID = 'STRAIGHT_TALK' THEN
               IF REC_PN.ORG_FLOW = '3' THEN
                NULL;
                -- ESN is STs skip the update of x_redemption_menu
               ELSE
                -- CR15157 Ends
                 UPDATE TABLE_X_OTA_FEATURES
                  SET x_redemption_menu = 'Y'
                 WHERE OBJID = REC_OTA_F.OF_OBJID;
               END IF;

            END IF;
            IF rec_ota_f.x_handset_lock != 'Y'
            THEN
               UPDATE table_x_ota_features SET x_handset_lock = 'Y'
               WHERE objid = rec_ota_f.of_objid;
            END IF;
/*
            -- CR7323 Start
            IF rec_ota_f.x_low_units != 'N'
            THEN
               UPDATE table_x_ota_features SET x_low_units = 'N'
               WHERE objid = rec_ota_f.of_objid;
            END IF;
            -- CR7323 End
*/
            IF rec_ota_f.x_psms_destination_addr != l_psms
            THEN
               UPDATE table_x_ota_features SET x_psms_destination_addr = l_psms
               WHERE objid = rec_ota_f.of_objid;
            END IF;
            IF rec_ota_f.x_ild_prog_status != 'Completed'
            THEN
               UPDATE table_x_ota_features SET x_ild_prog_status = 'Completed'
               WHERE objid = rec_ota_f.of_objid;
            END IF;
         END LOOP;
         IF ota_found = 0 then
            INSERT
            INTO table_x_ota_features(
               objid,
               dev,
               x_redemption_menu,
               x_handset_lock,
               x_low_units,
               x_ota_features2part_num,
               x_ota_features2part_inst,
               x_psms_destination_addr,
               x_ild_account,
               x_ild_carr_status,
               x_ild_prog_status,
               x_ild_counter,
               x_close_count,
               x_current_conv_rate
            )             VALUES(
               sa.seq('x_ota_features'),
               0,
               'Y',
               'Y',
               'N',
               NULL,
               rec_pn.pi_objid,
               l_psms,
               NULL,
               'Inactive',
               'Completed',
               0,
               0,
               3
            );
         END IF;
      END IF;
   end loop;

   COMMIT;
   EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END SP_VERIFY_ILD_DATA_INTEGRITY;
/