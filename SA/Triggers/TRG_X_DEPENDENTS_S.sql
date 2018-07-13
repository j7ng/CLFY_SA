CREATE OR REPLACE TRIGGER sa.TRG_X_DEPENDENTS_S
AFTER UPDATE
ON sa.TABLE_X_DEPENDENTS
DECLARE
/*******************************************************************************
 * Trigger Name: TRG_X_DEPENDENTS_S
 *
 * Created By: SL
 * Creation Date: 02/22/02
 *
 * Description: For Roadside Application, the trigger will update/insert ftp
 *              record when any dependent information changes
 *
 *******************************************************************************/
 v_contact_objid    number;
 v_road_ftp_objid 	number;
 v_member_id 		varchar2(30);
 v_dep1_first_name	varchar2(40);
 v_dep1_last_name	varchar2(40);
 v_dep2_first_name	varchar2(40);
 v_dep2_last_name	varchar2(40);
 v_dep3_first_name	varchar2(40);
 v_dep3_last_name	varchar2(40);
 v_dep4_first_name	varchar2(40);
 v_dep4_last_name	varchar2(40);
 v_dependent_count	number;
 v_step varchar2(100);
BEGIN
 --v_step := 'getting contact objid';

 IF sp_trg_global.v_rec_tab.count > 0 THEN
    FOR i in 0..sp_trg_global.v_rec_tab.count-1 LOOP

     v_contact_objid := sp_trg_global.v_rec_tab(i).contact_objid;
     v_road_ftp_objid := sp_trg_global.v_rec_tab(i).road_ftp_objid;

     v_dependent_count := 0;
     v_step := 'getting address';
     FOR c_depent_rec IN (SELECT x_first_name, x_last_name FROM table_x_dependents
                              WHERE x_dependents2contact = v_contact_objid ) LOOP
           v_dependent_count := v_dependent_count + 1;

           IF v_dependent_count = 1 THEN
             v_dep1_first_name := c_depent_rec.x_first_name;
             v_dep1_last_name := c_depent_rec.x_last_name;
           ELSIF v_dependent_count = 2 THEN
             v_dep2_first_name := c_depent_rec.x_first_name;
             v_dep2_last_name := c_depent_rec.x_last_name;
           ELSIF v_dependent_count = 3 THEN
             v_dep3_first_name := c_depent_rec.x_first_name;
             v_dep3_last_name := c_depent_rec.x_last_name;
           ELSIF v_dependent_count = 4 THEN
             v_dep4_first_name := c_depent_rec.x_first_name;
             v_dep4_last_name := c_depent_rec.x_last_name;
           END IF;

       END LOOP;

       IF v_dependent_count > 0 AND v_contact_objid IS NOT NULL THEN
         UPDATE x_road_ftp
         SET dep1_first_name = v_dep1_first_name,
             dep1_last_name = v_dep1_last_name,
             dep2_first_name = v_dep2_first_name,
             dep2_last_name = v_dep2_last_name,
             dep3_first_name = v_dep3_first_name,
             dep3_last_name = v_dep3_last_name,
             dep4_first_name = v_dep4_first_name,
             dep4_last_name = v_dep4_last_name ,
             dependent_count = v_dependent_count
         WHERE objid =   v_road_ftp_objid;
       END IF;
     END LOOP;
  sp_trg_global.v_rec_tab.delete;
  sp_trg_global.v_index := null;
 END IF;
EXCEPTION
  WHEN OTHERS THEN
   RAISE_APPLICATION_ERROR(-20001,'Error occured when '||v_step||' '||sqlerrm);
END;
/