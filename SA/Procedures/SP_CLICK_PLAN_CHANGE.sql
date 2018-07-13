CREATE OR REPLACE PROCEDURE sa."SP_CLICK_PLAN_CHANGE"
/**************************************************************************************************/
/* Name         :   SA.SP_CLICK_PLAN_CHANGE
/* Type         :   Procedure
/* Purpose      :   Updates an ESN to have either a default click plan or a "1 click" click plan
/* Author       :   Gerald Pintado
/* Date         :   05/28/2004
/* Revisions    :   Version  Date       Who             Purpose
/*                  -------  --------   -------         -----------------------
/*                  1.0      05/28/2004 Gpintado        Initial revision
/*                  1.1      09/05/2007 MJordan/VAdapa  CR6668 - Added the condition for dll > 14
/*                  ?.?      09/7/2011  NGuada          Updated to new Click Plan Logic
/*****************************************************************************************************/
(
   ip_esn       in  varchar2,
   ip_user      in  varchar2,
   ip_PlanType  in  varchar2,
   op_errmsg    out varchar2,
   op_error     out number)
IS
CURSOR c_sp
Is --Get site part record
  SELECT sp.objid,sp.x_min,sp.x_zipcode,si.site_id,si.name,pn.x_dll,pn.part_number,bo.org_id,pn.x_technology
    FROM table_site           si,
         table_inv_bin        ib,
         table_part_num       pn,
         table_mod_level      ml,
         Table_Part_Inst      Pi,
         Table_Site_Part      Sp,
         table_bus_org        bo
   WHERE si.site_id            = ib.bin_name
     AND ib.objid              = pi.part_inst2inv_bin
     AND pn.objid              = ml.part_info2part_num
     AND ml.objid              = pi.n_part_inst2part_mod
     AND pi.x_domain           = 'PHONES'
     AND sp.x_service_id       = pi.part_Serial_no
     AND sp.part_Status ||''   = 'Active'
     And Sp.X_Service_Id       = Ip_Esn
     AND Pn.Part_Num2bus_Org   = bo.objid;

strError      varchar2(100);
IntClickObjid number := 0;
ActiveSite    boolean := false;--
--
BEGIN
   FOR c_sp_rec in c_sp LOOP
      ActiveSite := true;
       If Ip_Plantype = 1 Then --Plan with all 1 clicks requested
         If C_Sp_Rec.Org_id='TRACFONE' then
           If C_Sp_Rec.X_Technology = 'GSM' Then
              Intclickobjid:=5009;
           Elsif C_Sp_Rec.X_Technology = 'CDMA' Then
              Intclickobjid:=5006;
           End If;
         Elsif C_Sp_Rec.Org_id='NET1O' Then
           If C_Sp_Rec.X_Technology = 'GSM' Then
              Intclickobjid:=5004;
           Elsif C_Sp_Rec.X_Technology = 'CDMA' Then
              Intclickobjid:=5003;
           End If;
         end if;
       Elsif Ip_Plantype = 2 Then --Default plan requested
          Intclickobjid := Assigned_Click( C_Sp_Rec.Part_Number);
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
        Op_Error := 1;
        op_errmsg := 'No Click Plan Found.';
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