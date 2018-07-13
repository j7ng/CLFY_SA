CREATE OR REPLACE Package Body sa.Apex_Luts_Pkg
As
--------------------------------------------------------------------------------------------
--$RCSfile: APEX_LUTS_PKG_BODY.sql,v $
--$Revision: 1.8 $
--$Author: mmunoz $
--$Date: 2013/01/25 22:57:38 $
--$ $Log: APEX_LUTS_PKG_BODY.sql,v $
--$ Revision 1.8  2013/01/25 22:57:38  mmunoz
--$ CR23043 ADF Oracle Application - Third Release
--$
--$ Revision 1.7  2012/08/30 14:00:29  mmunoz
--$ CR21806: Functionality for airtime cards was moved to APEX_TOSS_UTIL_PKG
--$
--------------------------------------------------------------------------------------------
Function Split(
    P_In_String Varchar2,
    P_Delim     Varchar2)
  Return Integer_Varray
Is
  I      Number        :=0;
  Pos    Number        :=0;
  Lv_Str Varchar2(500) := P_In_String;
  Ids Integer_Varray   := Integer_Varray();
Begin
  -- determine first chuck of string
  Pos := Instr(Lv_Str,P_Delim,1,1);
  -- while there are chunks left, loop
  If Pos = 0 And Lv_Str Is Not Null Then
    Ids.Extend;
    Ids(1) := To_Number(Lv_Str);
  End If;
  While ( Pos != 0)
  Loop
    -- increment counter
    I := I + 1;
    -- create array element for chuck of string
    Ids.Extend;
    Ids(I) := Substr(Lv_Str,1,Pos-1);
    -- remove chunk from string
    Lv_Str := Substr(Lv_Str,Pos+1,Length(Lv_Str));
    -- determine next chunk
    Pos := Instr(Lv_Str,P_Delim,1,1);
    -- no last chunk, add to array
    If Pos = 0 Then
      Ids.Extend;
      Ids(I+1) := To_Number(Lv_Str);
    End If;
  End Loop;
  -- return array
  Return Ids;
End Split;

Function Zero_Zone(
    Ip_State     In Varchar2,
    Ip_Line_Type In varchar2)
    Return zero_zone_array
As
  Sqlstr Varchar2(2000);
  Rep_Cur	 Sys_Refcursor;
  Rep_Array Zero_Zone_Array;

  v_State           Varchar2(2);
  v_Zone            Varchar2(100);
  v_Market_Area     Varchar2(33);
  v_Marketid        Float(126);
  v_Carrier_Id      Float(126);
  v_Carrier_Name   Varchar2(255);
  v_Sid             varchar(10);


Begin
   Rep_Array := Zero_Zone_Array();

   Sqlstr:='SELECT DISTINCT a.STATE, a.MRKT_AREA,a.MARKETID,a.ZONE, a.CARRIER_ID,a.CARRIER_NAME,a.SID';
   Sqlstr:=Sqlstr||' FROM sa.npanxx2carrierZones A, sa.table_x_carrier ca, sa.table_x_carrier_group ca2, sa.table_x_parent ca3 ';
   if ip_state <> 'ALL' then
       sqlstr:=sqlstr||' Where A.STATE = '''||ip_state||''' ';
       sqlstr:=sqlstr||' AND not exists(select c.npa FROM  sa.npanxx2carrierZones C,SA.LUTS_LINE_SCAN D WHERE ';
   Else
       sqlstr:=sqlstr||' WHERE not exists(select c.npa FROM  sa.npanxx2carrierZones C,SA.LUTS_LINE_SCAN D WHERE ';
   End If;

   If Ip_Line_Type= '0' Then
          Sqlstr:=Sqlstr||' (d.part_stat = ''11'') ';
   Elsif Ip_Line_Type= '1' Then
          Sqlstr:=Sqlstr||' (d.part_stat = ''12'') ';
   Elsif Ip_Line_Type ='2' Then
           Sqlstr:=Sqlstr||' (d.part_stat = ''11'' or d.part_stat = ''12'' ) ';
   Else
           Sqlstr:=Sqlstr||' (d.part_stat = ''11'' or d.part_stat = ''12'' ) ';
   end if;

   sqlstr:=sqlstr||' and a.zone  = c.zone and a.state = c.state and a.carrier_id = c.carrier_id and a.MARKETID = c.MARKETID and a.sid = c.sid  and c.npa = d.npa(+) and c.nxx = d.nxx(+) and c.carrier_id = d.carrier_id(+) )';
   sqlstr:=sqlstr||' and a.carrier_id =  ca.x_carrier_id';
   Sqlstr:=Sqlstr||' and ca.x_status =''ACTIVE''';
   Sqlstr:=Sqlstr||' and ca.x_carrier_id in (select x_carrier_id from table_x_carrier,table_x_carrier_group,table_x_parent where carrier2carrier_group=table_x_carrier_group.objid and x_carrier_group2x_parent = table_x_parent.objid and nvl(x_next_available,0) = 0 ) ';
   Sqlstr:=Sqlstr||' and ca.carrier2carrier_group = ca2.objid ';
   sqlstr:=sqlstr||' and ca2.x_carrier_group2x_parent = ca3.objid ';
   sqlstr:=sqlstr||' and ca3.x_no_inventory = 0 ';
   sqlstr:=sqlstr||' and exists (select ''x'' from table_x_carrierdealer ';
   sqlstr:=sqlstr||'             where x_carrier_id = ca.x_carrier_id)';

   Dbms_Output.Put_Line(Sqlstr);

   Open rep_cur For Sqlstr;
  Loop
      Fetch rep_cur Into  V_State,V_Market_Area,V_Marketid,V_Zone,V_Carrier_Id,V_Carrier_Name,V_Sid;
      Rep_Array.Extend;
      Rep_Array(Rep_Array.Count) := Zero_Zone_obj(V_State,v_zone,V_Market_Area,V_Marketid,V_Carrier_Id,V_Carrier_Name,V_Sid);
      Exit When rep_cur%Notfound;
  End Loop;

   Return Rep_Array;

End Zero_Zone;
function master_inv( Ip_State In Varchar2,
                     Ip_Carr_List in varchar2,
                     print_totals in number default 0)
 return sa.master_inv_array as
  mia sa.master_inv_array := sa.master_inv_array();
  mi  sa.master_inv_obj  := sa.master_inv_obj('','','','','','','','','','','','','','','',
                                              '','','','','','','','','','','','');
  mi_totals  sa.master_inv_obj  := sa.master_inv_obj('','Totals ===>','','','','','','','','','','',
                                                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  a1   number;
  a2   number;
  a3   number;
  a4   number;
  ext  varchar2(20);
  rest varchar(1000); -- CHANGED FROM 200 TO 1000
  carr_array Integer_varray := Integer_varray();
  i number := 1;
begin
  rest := nvl(ip_carr_list,0);
  loop
    carr_array.extend;
    exit when instr(rest,',') = 0;
    carr_array(i):= substr(rest,1,instr(rest,',')-1);
    rest := substr(rest,instr(rest,',')+1);
   i:= i+1;
  end loop;
  carr_array(i) := rest;

  for i in 1..carr_array.count
  loop
    dbms_output.put_line(carr_array(i));
  end loop;
  for rec in (select distinct a.state,
                    a.zone,
                    a.marketid ,
                    a.mrkt_area ,
                    a.carrier_id,
                    a.carrier_name,
                    a.technology,
                    a.frequency1,
                    a.frequency2,
                    a.sid,
                    a.lead_time,
                    a.target_level
                  from sa.npanxx2carrierzones a,
                       sa.luts_line_scan b
                  where a.npa      = b.npa
                  and a.nxx        = b.nxx
                  and a.carrier_id = b.carrier_id
                  --and a.carrier_id in ('101280','111280','121280')
                  and a.carrier_id in (select * from table(carr_array))
                  and a.state = nvl(ip_state ,a.state))
 loop
     select x.state,
            x.zone,
            x.sid,
            x.marketid,
            x.carrier_id,
            x.new_avail_total,
            x.used_avail_total,
            x.cooling_total,
            x.active_total,
            x.new_hold_total,
            x.used_hold_total,
            x.new_avail_total +x.used_avail_total avail_total,
            rec.target_level/100*active_total max_inventory
     into   mi.state,
            mi.zone,
            mi.sid,
            mi.marketid,
            mi.carrier_id,
            mi.new_available,
            mi.used_available,
            mi.cooling_lines,
            mi.active_lines,
            mi.newhold_available,
            mi.usedhold_available,
            mi.total_available,
            mi.max_inventory
     from (select a.state,
                  a.zone,
                  a.sid,
                  a.marketid,
                  a.carrier_id,
                  sum(decode(b.part_stat,'11',b.available,0)) new_avail_total,
                  sum(decode(b.part_stat,'12',b.available,0)) used_avail_total,
                  sum(decode(b.part_stat,'99',b.available,0)) cooling_total,
                  sum(decode(b.part_stat,'13',b.available,0)) active_total,
                  sum(decode(b.part_stat,'15',b.available,0)) new_hold_total,
                  sum(decode(b.part_stat,'16',b.available,0)) used_hold_total
            from sa.npanxx2carrierzones a,
                  sa.luts_line_scan b
            where a.npa      = b.npa
             and a.nxx        = b.nxx
             and a.carrier_id = b.carrier_id
             and a.state      = rec.state
             and a.zone       = rec.zone
             and a.sid        = rec.sid
             and a.marketid   = rec.marketid
             and a.carrier_id = rec.carrier_id
            group by a.state,
                  a.zone,
                  a.marketid ,
                  a.mrkt_area ,
                  a.carrier_id,
                  a.carrier_name,
                  a.sid) x;
       --vzone;
       mi.market_name  := rec.mrkt_area;
       mi.carrier_name := rec.carrier_name;
       mi.technology   := rec.technology;
       mi.frequency1   := rec.frequency1;
       mi.frequency2   := rec.frequency2;
       mi.sid          := rec.sid;
       mi.lead_time    := rec.lead_time;
       mi.target_inv_level := rec.target_level;
       if ( mi.total_available - mi.max_inventory < 0) then
           mi.excessive_inventory := 0;
       else
           mi.excessive_inventory := round(mi.total_available - mi.max_inventory);
       end if;
       begin
           select av_activations,
                  max_activations
           into mi.average_utilization,
                mi.max_utilization
           from sa.line_utilization
           where state    = rec.state
            and zone       = rec.zone
            and sid        = rec.sid
            and marketid   = rec.marketid
            and carrier_id = rec.carrier_id;
       exception
            when NO_DATA_FOUND then
              mi.average_utilization:= 0;
              mi.max_utilization:= 0;
       end;
       mi.excess := round(mi.max_utilization-mi.average_utilization);
       if rec.target_level = 0 then
          mi.cushion  :=0;
       elsif (mi.max_utilization + mi.average_utilization)/2 *rec.lead_time < 5 then
          mi.cushion :=5;
       else
          mi.cushion:= round((mi.max_utilization + mi.average_utilization)/2 *rec.lead_time);
       end if;
       if rec.target_level = 0 then
          mi.reorder_point := 0;
       else
          mi.reorder_point:= round(mi.cushion + (mi.average_utilization * rec.lead_time)+ mi.excess);
       end if;
       a1 := mi.cushion - mi.total_available;
       a3 := round((mi.active_lines + rec.lead_time*mi.average_utilization)*rec.target_level/100
                    -mi.total_available + rec.lead_time*mi.average_utilization);
       a4 := (round(mi.average_utilization) * 15) - mi.total_available;
       if mi.total_available < mi.reorder_point then
           a2 := greatest(a3,a4);
       else
           a2 := 0;
       end if;
       mi.suggested_amount   := greatest(a1,a2);
       if mi.suggested_amount < 0 then
          mi.suggested_amount := 0;
       end if;
       mia.extend;
       mia(mia.count) := mi;

       mi_totals.NEW_AVAILABLE       := mi_totals.NEW_AVAILABLE + mi.NEW_AVAILABLE;
       mi_totals.USED_AVAILABLE      := mi_totals.USED_AVAILABLE + mi.USED_AVAILABLE;
       mi_totals.NEWHOLD_AVAILABLE   := mi_totals.NEWHOLD_AVAILABLE + mi.NEWHOLD_AVAILABLE;
       mi_totals.USEDHOLD_AVAILABLE  := mi_totals.USEDHOLD_AVAILABLE + mi.USEDHOLD_AVAILABLE;
       mi_totals.ACTIVE_LINES        := mi_totals.ACTIVE_LINES + mi.ACTIVE_LINES;
       mi_totals.TOTAL_AVAILABLE     := mi_totals.TOTAL_AVAILABLE + mi.TOTAL_AVAILABLE;
       mi_totals.COOLING_LINES       := mi_totals.COOLING_LINES + mi.COOLING_LINES;
       mi_totals.EXCESSIVE_INVENTORY := mi_totals.EXCESSIVE_INVENTORY + mi.EXCESSIVE_INVENTORY;
       mi_totals.AVERAGE_UTILIZATION := mi_totals.AVERAGE_UTILIZATION + mi.AVERAGE_UTILIZATION;
       mi_totals.MAX_UTILIZATION     := mi_totals.MAX_UTILIZATION + mi.MAX_UTILIZATION;
       mi_totals.EXCESS              := mi_totals.EXCESS + mi.EXCESS;
       mi_totals.CUSHION             := mi_totals.CUSHION + mi.CUSHION;
       mi_totals.REORDER_POINT       := mi_totals.REORDER_POINT + mi.REORDER_POINT;
       mi_totals.SUGGESTED_AMOUNT    := mi_totals.SUGGESTED_AMOUNT + mi.SUGGESTED_AMOUNT;
       mi_totals.MAX_INVENTORY       := mi_totals.MAX_INVENTORY + mi.MAX_INVENTORY;


 end loop;
 if print_totals = 1 then
       mia.extend;
       mia(mia.count) := mi_totals;
 end if;
return mia;
end;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
End Apex_Luts_Pkg;
/