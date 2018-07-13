CREATE OR REPLACE PROCEDURE sa."SP_DUGGI_CLICK_PLAN_CHANGE"
/**************************************************************************************************/
/* Name         :   SA.SP_CLICK_PLAN_CHANGE
/* Type         :   Procedure
/* Purpose      :   Updates an ESN to have either a default click plan or a "1 click" click plan
/* Author       :   Gerald Pintado
/* Date         :   05/28/2004
/* Revisions    :   Version  Date       Who             Purpose
/*                  -------  --------   -------         -----------------------
/*                  1.0      05/28/2004 Gpintado        Initial revision
/*****************************************************************************************************/
(
   ip_esn       in  varchar2,
   ip_user      in  varchar2,
   ip_PlanType  in  varchar2,
   op_errmsg    out varchar2,
   op_error     out number)
IS
 CURSOR c_sp
 is --Get site part record
  SELECT sp.objid,sp.x_min,sp.x_zipcode,si.site_id,si.name,pn.x_dll,pn.part_number
    FROM table_site           si,
         table_inv_bin        ib,
         table_part_num       pn,
         table_mod_level      ml,
         table_part_inst      pi,
         table_site_part      sp
   WHERE si.site_id            = ib.bin_name
     AND ib.objid              = pi.part_inst2inv_bin
     AND pn.objid              = ml.part_info2part_num
     AND ml.objid              = pi.n_part_inst2part_mod
     AND pi.x_domain           = 'PHONES'
     AND sp.x_service_id       = pi.part_Serial_no
     AND sp.part_Status ||''   = 'Active'
     AND sp.x_service_id       = ip_esn;
--
 CURSOR c_cp (c_plan_type in varchar2) --Get default click plan
 is
  SELECT objid
    FROM table_x_click_plan
   WHERE x_is_default = 'Yes'
     AND x_click_type = c_plan_type;
--
--
 CURSOR c_cp2(c_plan_id in varchar2) --Get 1 clicks, click plan
 is
  SELECT objid
    FROM table_x_click_plan
   WHERE x_plan_id = c_plan_id;
--
--

 IntDll        number;
 strPlanType   varchar2(4);
 strPlanID     varchar2(10);
 strError      varchar2(100);
 IntClickObjid number := 0;
 ActiveSite    boolean := false;


--
--
 BEGIN
   FOR c_sp_rec in c_sp LOOP
      ActiveSite := true;

      IntDll := c_sp_rec.x_dll;

       -- HardCode PlanType and PlanID depending on ESNs DLL number
       If IntDLL <= 9 THEN
       	  strPlanType := 'R1';
       	  strPlanID := '1005';
       Elsif IntDLL <= 11 THEN
          strPlanType := 'R2';
          strPlanID := '1006';
       Elsif IntDLL <= 13 THEN
          strPlanType := 'R3';
          strPlanID := '1007';
       Elsif IntDLL = 14 THEN
          strPlanType := 'R4';
          strPlanID := '1008';
       Elsif IntDLL > 14 THEN
          strPlanType := 'R4';
          strPlanID := '1008';
       End if;

       --Get click plan objid for default or 1 click plans
       If ip_PlanType = 1 then --Plan with all 1 clicks requested
          	for c_cp2_rec in c_cp2(strPlanID) loop
             	IntClickObjid := c_cp2_rec.objid;
          	end loop;
       Elsif ip_PlanType = 2 then --Default plan requested
         	for c_cp_rec in c_cp(strPlanType) loop
             	IntClickObjid := c_cp_rec.objid;
          	end loop;
       End If;

       If IntClickObjid > 0 then
       	  	  -- Flags ESN's site_part to receive new click plan
       	  	  Update table_site_part
             	     set site_part2x_new_plan = IntClickObjid
          	   where part_Status = 'Active'
            	     and x_service_id = ip_esn;

	          -- Inserts into log table
	          Insert into x_click_change_log
	                (site_part,
	                 esn,
	                 cellnum,
	                 zipcode,
	                 dealer_id,
	                 dealer_name,
	                 click_change2x_plan,
	                 click_change_date,
                     agent
	                 )
	                values(c_sp_rec.objid, ip_esn, c_sp_rec.x_min, c_sp_rec.x_zipcode,
	                       c_sp_rec.site_id,c_sp_rec.name,IntClickObjid,sysdate,ip_user);

       Else
	    op_error := 1;
	    op_errmsg := 'No Click Plan Found for ' || strPlanType ||' plan type';
       End if;

  End loop;

  If Not ActiveSite then
      op_error := 1;
      op_errmsg := 'No Active Site Part Record Found';
  End if;

EXCEPTION
  WHEN OTHERS THEN
      strError := substr(SQLERRM,1,100);
      op_error := 1;
      op_errmsg:= 'Oracle Error: ' || strError;
End;
/