CREATE OR REPLACE PROCEDURE sa."NET10_DUEDATE_EXTENSION_PRC"
/********************************************************************************/
/* Name         :   net10_duedate_extension_prc
/* Type         :   Procedure
/* Purpose      :   Gives a 10-day extention for net10 phones
/* Author       :   Gerald Pintado
/* Date         :   05/23/2005
/* Revisions    :   Version  Date       Who             Purpose
/*                  -------  --------   -------         -----------------------
/*                  1.0      05/23/2005 Gpintado        CR4035 - Initial revision
/*                  1.1      05/24/2005 Gpintado        CR4035 - Added = sign
/********************************************************************************/

IS
   -- Gets all net10 phones that expire next day
   CURSOR c1
   IS
     select part_serial_no esn, warr_end_date, x_part_inst2site_part
       from table_part_inst pi, table_mod_level ml, table_part_num pn
      where 1=1
        and warr_end_date between trunc(sysdate) + 1 and trunc(sysdate) +2
        and x_part_inst_status||'' = '52'
        and n_part_inst2part_mod = ml.objid
        and pn.objid=  ml.part_info2part_num
        and pn.X_RESTRICTED_USE = '3';

   -- Gets all pending net10 phones for duedate extention
   CURSOR c2
   IS
     select a.rowid, a.*
       from sa.x_net10_ext_esn a
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
 l_ext_days number := 10;
 l_max_upd_date date := null;
 l_red_cnt number :=0;

BEGIN

   For c1_rec In c1 Loop
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
           INSERT INTO x_net10_ext_esn
              ( esn,min,old_expy_dt)
           VALUES
             (c1_rec.esn,l_sp_objid,c1_rec.warr_end_date);
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
      l_red_cnt := 0;

      Open c3(r2.esn);
      Fetch c3 Into r3;

      If c3%found Then -- Active site_part found
         Select Max(updt_dt)
           Into l_max_upd_date
           From x_net10_ext_esn t
          Where t.esn = r2.esn
            And updt_yn||''='Y';

          If l_max_upd_date is null then -- No prior extention, check activation date
             Begin
              Select x_transact_date into l_max_upd_date
                From table_x_call_trans
               Where call_trans2site_part = r3.objid
                 And x_action_type||''='1'
                 And x_result||''='Completed'
                 And rownum < 2;
             Exception
               When others then
                 Update x_net10_ext_esn
                    Set updt_yn = 'N', updt_dt = Sysdate
                  Where ROWID = r2.rowid;
               End;
          End if;

          Select Count(1)  -- check redemption exists after l_max_upd_date
            Into l_red_cnt
            From table_x_red_card rc, table_x_call_trans ct
           Where 1=1
             And ct.objid = rc.red_card2call_trans
             And ct.x_action_type||'' in ('1','6')
             And ct.x_result||''='Completed'
             And ct.x_transact_date+0 >= l_max_upd_date
             And call_trans2site_part = r3.objid;

            If l_red_cnt > 0 then
               UPDATE table_site_part
                  SET x_expire_dt = l_ext_days + x_expire_dt, warranty_date =  warranty_date + l_ext_days
                WHERE objid = r3.objid;

               UPDATE table_part_inst
                  SET warr_end_date = warr_end_date  + l_ext_days
                WHERE part_serial_no = r2.esn;

               UPDATE x_net10_ext_esn
                  SET updt_yn = 'Y', updt_dt = SYSDATE,
                      new_expy_dt = r3.x_expire_dt +  l_ext_days
               WHERE ROWID = r2.rowid;
            Else
              UPDATE x_net10_ext_esn SET updt_yn = 'N', updt_dt = SYSDATE
              WHERE ROWID = r2.rowid;
            End if;
      ELSE
       	   Update x_net10_ext_esn
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
END net10_duedate_extension_prc;
/