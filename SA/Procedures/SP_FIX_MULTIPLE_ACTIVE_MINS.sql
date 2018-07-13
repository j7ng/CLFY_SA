CREATE OR REPLACE PROCEDURE sa."SP_FIX_MULTIPLE_ACTIVE_MINS"
/********************************************************************************/
/* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved                  */
/*                                                                              */
/* Name         :   sp_fix_multiple_active_mins.sql                             */
/* Purpose      :   updates site_part and part_inst records to inactive when    */
/*                  proven through the procedure                                */
/* Parameters   :   None                                                        */
/* Platforms    :   Oracle 8.0.6 AND newer versions                             */
/* Author	      :   Gerald Pintado                          					          */
/*                  Tracfone			                                    	        */
/* Date         :   September 17,2002                                           */
/* Revisions	:   Version  Date      Who       Purpose                          */
/*                  -------  --------  -------   ------------------------------ */
/*                  1.0                          Initial                        */
/*                  1.1      04/17/03  SL        Clarify Upgrade - sequence     */
/*                  1.2      07/17/06  GP        CR5430: Complete rewrite of    */
/*                                               procedure. Only deactivates    */
/*                                               site_parts w/ no call trans    */
/********************************************************************************/
Is
-- Gets all MINs currently Active with more than one site_part
-- but does not exist in the analysis table.
Cursor c1
Is
 Select a.x_min,count(1)
   From table_site_part a
  Where a.part_status = 'Active'
    and not exists (select 'x'
                      from sa.x_multi_active_MINs b
                     where b.x_service_id = a.x_service_id
                       and b.x_min = a.x_min)
  Group by a.x_min Having Count(1) > 1;


-- Get Active site_part records
Cursor c2 (c_min In Varchar2)
Is
 Select objid site_part_objid,x_min,x_service_id
   From table_site_part
  Where x_min = c_min
    And part_status = 'Active';

-- Get Count of Activation/Reactivation call_trans record
Cursor c3 (c_site_part_objid In Varchar2)
Is
 Select count(1) cnt_call_trans
   From table_x_call_trans
  Where call_trans2site_part = c_site_part_objid
    And x_action_type in ('1','3');


counter number := 0;
v_sa_objid number;
cntActive number :=0;
cntInactive number :=0;

TYPE x_objid_tab IS TABLE OF table_site_part.objid%TYPE
      INDEX BY BINARY_INTEGER;

Active_objidArray   x_objid_tab;
Inactive_objidArray x_objid_tab;

Begin

Select objid Into v_sa_objid
  From table_user
 Where s_login_name = 'SA';

 For c1_rec in c1 loop
 	 /* Initialize all variables */
     cntActive := 0;
     cntInactive :=0;
     Active_objidArray.DELETE;
     Inactive_objidArray.DELETE;

        /* Get Active site_part records for each Multi-Active MIN */
        For c2_rec in c2 (c1_rec.x_min) Loop

        	 /* Get Count of Activation/Reactivation call_trans record */
           For c3_rec in c3 (c2_rec.site_part_objid) Loop

           	    /* Collect all site_part records w/no call trans */
             If c3_rec.cnt_call_trans = 0 then
             	  cntInactive := cntInactive+1;
                Inactive_objidArray(cntInactive) := c2_rec.site_part_objid;
             Else
                /* Collect all site_part records w/ call trans */
             	  cntActive := cntActive+1;
                Active_objidArray(cntActive) := c2_rec.site_part_objid;
             End if;

           End Loop;
        End Loop;


   /* Once all variables have been collected continue to Insert or Update */
   If Inactive_objidArray.count = 0 then

      FOR i IN Active_objidArray.FIRST..Active_objidArray.LAST
      LOOP

   	     /*** insert into table for furthur analysis  ***/
   	    Insert into x_multi_active_MINs
           (call_trans_objid,x_service_id,x_min,x_carrier_id,
            x_technology,x_line_status,x_transact_date,
            x_action_type,x_sourcesystem,x_result)

        Select a.objid,a.x_service_id,a.x_min,b.x_carrier_id,
               e.x_technology,a.x_line_status,a.x_transact_date,
               a.x_action_type,a.x_sourcesystem,a.x_result
          From table_x_call_trans a,
               table_x_carrier b,
               table_site_part c,
               table_mod_level d,
               table_part_num e
         Where 1=1
           And d.part_info2part_num   = e.objid
           And c.site_part2part_info  = d.objid
           And a.call_trans2site_part = c.objid
           And a.x_call_trans2carrier = b.objid
           And a.x_action_type in ('1','3')
           And a.call_trans2site_part = Active_objidArray(i);

           commit;

      END LOOP;
   Else
      FOR i IN Inactive_objidArray.FIRST..Inactive_objidArray.LAST
      LOOP

         Update table_site_part
            Set part_status    = 'Inactive',
                service_end_dt = Sysdate,
                x_deact_reason = 'MOVING/WRONGNUM'
          Where objid = Inactive_objidArray(i);

         Update table_part_inst
            Set x_part_inst_status     = '51',
                status2x_code_table    = 987,
                last_trans_time        = Sysdate
          Where x_part_inst_status||'' = '52'
            And x_part_inst2site_part  = Inactive_objidArray(i);

          Insert Into table_x_call_trans
                      (
                        objid,
                        call_trans2site_part,
                        x_action_type,
                        x_call_trans2carrier,
                        x_call_trans2dealer,
                        x_call_trans2user,
                        x_min,
                        x_service_id,
                        x_sourcesystem,
                        x_transact_date,
                        x_reason,
                        x_result
                      )
               Select sa.seq('x_call_trans'),
                      a.objid site_part_objid,
                      '2' as x_action_type,
                      b.part_inst2carrier_mkt,
                      e.objid dealer_objid,
                      v_sa_objid,
                      a.x_min,
                      a.x_service_id,
                      'MULTIPLE_ACTIVE_BATCH' as x_sourcesystem,
                      sysdate as x_transact_date,
                      'WN-SYSTEM ISSUED' as x_reason,
                      'Completed' as x_result
                 From table_site_part a,
                      table_part_inst b,
                      table_part_inst c,
                      table_inv_bin d,
                      table_site e
                Where a.objid = Inactive_objidArray(i)
                  And a.x_min = b.part_serial_no
                  And a.x_service_id = c.part_serial_no
                  And c.part_inst2inv_bin = d.objid
                  And d.bin_name = e.site_id;
           counter := counter + 1;
      END LOOP;
      commit;
   End if;

 End Loop;
 dbms_output.put_line('Records Updated: '|| counter);
Exception
 When others then
  dbms_output.put_line(SQLERRM);

End sp_fix_multiple_active_mins;
/