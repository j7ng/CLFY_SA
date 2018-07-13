CREATE OR REPLACE function sa.GET_TEST_SIM_jt
                 (sim_part_number in varchar2)
                  return varchar2 is
cursor c1 is
select * from table_x_sim_inv
where X_SIM_INV_STATUS='253'
AND x_sim_serial_no LIKE '890126%'
and X_CREATED_BY2USER<>0
and rownum < 2;
cursor c2 (sim_part_number varchar2) is
select nvl(max(ml.objid),0) objid
from sa.table_mod_level ml, sa.table_part_num pn
where pn.part_number = sim_part_number
and pn.objid = ml.part_info2part_num;
sim_number varchar2(30);
r2 c2%rowtype;
 function Add_Check_Digit_Sim(old_sim in varchar2)
return varchar2 is
      sim number;
      tot      NUMBER         := 0;
      val      NUMBER         := 0;
      inter_num number :=0;
      check_num number :=0;
   begin
       sim := old_sim;
       FOR i IN REVERSE 1 .. LENGTH (sim) LOOP
            IF TO_NUMBER (SUBSTR (TO_CHAR (i), LENGTH (i), 1)) IN
                                                               (1, 3, 5, 7, 9,11,13,15,17,19) THEN
                  val := SUBSTR (sim, i, 1) * 2;
                  tot := tot + SUBSTR (val, 1, 1);
                  tot := tot + NVL (SUBSTR (val, 2, 1), 0);
                 ELSE
                  tot := tot + SUBSTR (sim, i, 1);
               END IF;
            END LOOP;
            ---adding the check_digit
            inter_num := tot*9;
            check_num :=substr(inter_num, length(inter_num),1);
            sim :=sim||check_num;
             return sim;
end;
begin
open c2(sim_part_number);
fetch c2 into r2;
if r2.objid>0
then
   for r1 in c1 loop
   
   if length(r1.x_sim_serial_no) >19 
   then sim_number := substr(r1.x_sim_serial_no,1,19);
   elsif  length(r1.x_sim_serial_no) <19 
   then sim_number := rpad(r1.x_sim_serial_no,19,9);
   else
       sim_number := trim(both ' ' from  r1.x_sim_serial_no);
   end if;    
       sim_number := trim(both chr(10) from  sim_number);
       if sim_part_number='TF256PSIMV9RM'  or sim_part_number='TF256PSIMV9'
       then
        sim_number :=  '891'||substr( sim_number,4) ;
        sim_number := Add_Check_Digit_Sim(sim_number);
       end if;
            if sim_part_number='TF128PSIMCL7DD' 
       then
        sim_number :=  '890111'||substr( sim_number,7) ;
        sim_number := Add_Check_Digit_Sim(sim_number);
       end if;
       delete from table_x_sim_inv
       where x_sim_serial_no = sim_number
       and x_sim_inv_status <> '253';
       update sa.table_x_sim_inv
       set x_sim_inv2part_mod = r2.objid,
           x_sim_serial_no = sim_number,
           X_CREATED_BY2USER=0
       where objid = r1.objid;
       update sa.table_part_inst
       set x_iccid = null
       where x_iccid = sim_number;
       commit;
       return sim_number;
   end loop;
else
 dbms_output.put_line('Part number: '||sim_part_number||' does not exist!');
 return 0;
end if;
close c2;
end;
/