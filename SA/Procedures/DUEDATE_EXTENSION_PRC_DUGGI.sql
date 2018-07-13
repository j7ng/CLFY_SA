CREATE OR REPLACE PROCEDURE sa."DUEDATE_EXTENSION_PRC_DUGGI"
/*********************************************************************************************/
/* Name         :   duedate_extension_prc
/* Type         :   Procedure
/* Purpose      :   Gives a 10-day or 15-day extension for net10/tracfone ESNs
/* Author       :   Gerald Pintado
/* Date         :   05/23/2005
/* Revisions    :   Version  Date       Who             Purpose
/*                  -------  --------   -------         -----------------------
/*                  1.0      05/23/2005 Gpintado        CR4035 - Initial revision
/*                  1.1      05/24/2005 Gpintado        CR4035 - Added = sign
/*                  1.4      06/13/2005 Gpintado        CR4089 - Add Tracfone 15 day extension
/*                  1.5      06/23/2005 Gpintado        CR4209 - Bug fix on extension days.
/*                  1.6      06/28/2005 Gpintado        CR4220 - Included reactivated customers
/*********************************************************************************************/

IS
   -- Gets all phones that expire next day
   CURSOR c1
   IS
   select tab1.part_serial_no esn, tab1.warr_end_date, tab1.x_part_inst2site_part,
          pn.X_RESTRICTED_USE
     from
          table_mod_level ml, table_part_num pn,
            (select /*+ FULL(pi) PARALLEL(pi,8) */
                    n_part_inst2part_mod,
                    part_serial_no,
                    warr_end_date,
                    x_part_inst2site_part
               from table_part_inst pi
              --where warr_end_date between '26-AUG-2005' and '27-AUG-2005'
              where warr_end_date between trunc(sysdate)and trunc(sysdate)+23.9996/24 /** 11:59:59 PM **/

                and x_part_inst_status = '52') tab1
    where 1=1
      and pn.objid=  ml.part_info2part_num
      and ml.objid = tab1.n_part_inst2part_mod;

   -- Gets all pending phones for duedate extention
   CURSOR c2
   IS
     select a.rowid, a.*
       from sa.x_duedate_ext_esn a
      where updt_yn IS NULL;

   -- Gets ESN active site_part
   CURSOR c3(ip_esn IN VARCHAR2)
   IS
     select objid, x_expire_dt
       from table_site_part
      where x_service_id = ip_esn
        and part_status ||'' = 'Active';

   r3 c3%ROWTYPE;

 l_cnt NUMBER  := 0;
 l_sp_objid NUMBER;
 l_ext_days number := 15;
 l_max_upd_date date := null;
 l_red_cnt number :=0;
 l_bus_org varchar2(25) := 'TRACFONE';

BEGIN

   For c1_rec In c1 Loop
   	  If c1_rec.x_restricted_use = 3 Then
   	  	 l_bus_org  := 'NET10';
   	  Else
   	  	 l_bus_org  := 'TRACFONE';
   	  End if;


       l_sp_objid := 0;

       Begin
        Select objid Into l_sp_objid
          From table_site_part
         Where objid = c1_rec.x_part_inst2site_part;
       Exception
       When Others Then
        Null;
       End;

       If l_sp_objid > 0 Then
           INSERT INTO x_duedate_ext_esn
              ( esn,min,old_expy_dt,x_bus_org)
           VALUES
             (c1_rec.esn,l_sp_objid,c1_rec.warr_end_date,l_bus_org);
           l_cnt := l_cnt +1;
       End If;

       IF MOD(l_cnt, 100) = 0  THEN
     	COMMIT;
       END IF;
   END LOOP;
   COMMIT;

   dbms_output.put_line('Total processed: '||l_cnt);

   l_cnt := 0;

   For r2 In c2
   Loop

      If r2.x_bus_org = 'NET10' Then
   	  	 l_ext_days := 10;
   	  ElsIF r2.x_bus_org = 'TRACFONE' THEN
   	  	 l_ext_days := 15;
   	  End if;

      l_red_cnt := 0;

     Open c3(r2.esn);
     Fetch c3 Into r3;

     IF c3%found THEN -- Active site_part found

       IF r3.x_expire_dt > trunc(sysdate)+2 THEN	/*** Active site_part (expire_dt) is already
       	                                               greater than part_inst (warr_end_date) ***/

        	    Update x_duedate_ext_esn
                Set updt_yn = 'N', updt_dt = SYSDATE
             Where ROWID = r2.rowid;
       ELSE
             Select Max(updt_dt)
               Into l_max_upd_date
               From x_duedate_ext_esn t
              Where t.esn = r2.esn
                And updt_yn||''='Y';

              If l_max_upd_date is null then -- No prior extention, check activation date
                 Begin
                  Select x_transact_date into l_max_upd_date
                    From table_x_call_trans
                   Where call_trans2site_part = r3.objid
                     And x_action_type||''in ('1','3')
                     And x_result||''='Completed'
                     And rownum < 2;
                 Exception
                   When others then
                     Update x_duedate_ext_esn
                        Set updt_yn = 'N', updt_dt = Sysdate
                      Where ROWID = r2.rowid;
                   End;
              End if;

              Select Count(1)  -- check redemption exists after l_max_upd_date
                Into l_red_cnt
                From table_x_red_card rc, table_x_call_trans ct
               Where 1=1
                 And ct.objid = rc.red_card2call_trans
                 And ct.x_action_type||'' in ('1','6','3')
                 And ct.x_result||''='Completed'
                 And ct.x_transact_date+0 >= l_max_upd_date
                 And call_trans2site_part = r3.objid;

                If l_red_cnt > 0 then
                   UPDATE table_site_part
                      SET x_expire_dt   = l_ext_days + x_expire_dt,
                          warranty_date = warranty_date + l_ext_days
                    WHERE objid = r3.objid;

                   UPDATE table_part_inst
                      SET warr_end_date = warr_end_date  + l_ext_days
                    WHERE part_serial_no = r2.esn;

                   UPDATE x_duedate_ext_esn
                      SET updt_yn = 'Y', updt_dt = SYSDATE,
                          new_expy_dt = r3.x_expire_dt +  l_ext_days
                   WHERE ROWID = r2.rowid;
                Else
                  UPDATE x_duedate_ext_esn
                     SET updt_yn = 'N', updt_dt = SYSDATE
                   WHERE ROWID = r2.rowid;
                End if;
       END IF;
     ELSE
       	   Update x_duedate_ext_esn
              Set updt_yn = 'N', updt_dt = SYSDATE
            Where ROWID = r2.rowid;
     END IF;

         CLOSE c3;
         l_cnt := l_cnt + 1;
         IF MOD(l_cnt, 100) = 0 THEN
      	    COMMIT;
         END IF;

   END LOOP;
   COMMIT;
EXCEPTION

   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM || ': Contact System Administrator');
      raise_application_error (
         -20001,
         SQLERRM || ': Contact System Administrator'
      );
END duedate_extension_prc_duggi;
/