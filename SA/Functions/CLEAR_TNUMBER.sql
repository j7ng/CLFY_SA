CREATE OR REPLACE function sa.clear_tnumber(v_esn in varchar2, p_ac in varchar2) 
return varchar2 is
cursor cur (p_esn varchar2 )
is
sELECT  pi.objid esnobjid, pi.part_serial_no esn,part_number,pi.x_part_inst_status phone_status , ln.objid lineid, ln.PART_SERIAL_NO linenum
  FROM table_part_inst pi, table_mod_level ml,  table_part_inst ln,
       table_part_num pn
  WHERE  pi.n_part_inst2part_mod = ml.objid
   AND   pi.x_domain = 'PHONES'
  AND   pi.x_part_inst_status || '' = '52'
 AND   ml.part_info2part_num = pn.objid
   AND   pn.domain = 'PHONES'
   and pi.objid=ln.PART_TO_ESN2PART_INST
 and ln.PART_SERIAL_NO like 'T%'
   and ln.x_domain='LINES'
 and pi.part_serial_no = p_esn;
cursor ig (p_esn varchar2 , p_min varchar2)
is
select action_item_id , TECHNOLOGY_FLAG tech from ig_transaction where esn=p_esn and min=p_min;
l_cur cur%rowtype;
l_ig   ig%rowtype;
p_areacode varchar2(10) := nvl(p_ac, '305');
v_min varchar2(30);
v_nxx varchar2(10);
v_ext varchar2(10);
begin
if length(p_areacode)<>3 then p_areacode:='305'; end if;
open cur(v_esn);
fetch cur into l_cur;
if cur%found
then
 if l_cur.phone_status <> '52' then
 DBMS_OUTPUT.PUT_LINE('PHONE STATUS IS '||l_cur.phone_status);
 RETURN v_ESN||' IS NOT ACTIVE';
 else 
   select substr(  dbms_random.value(1000,9999) , 1, 4) into v_ext  from dual;
   select substr(  dbms_random.value(200,999) , 1, 3) into v_nxx  from dual;
   v_min := p_areacode||v_nxx||v_ext;
   open ig(l_cur.esn, l_cur.linenum);
   fetch ig into l_ig;
     if ig%found 
     then
        if l_ig.tech ='C'
        then 
            update ig_transaction set min=v_min, msid=v_min, status='W' , new_msid_flag='Y'  where action_item_id = l_ig.action_item_id ;
        elsif l_ig.tech  ='G'
        then 
             update ig_transaction set msid=v_min, status='W' , new_msid_flag='Y' where action_item_id = l_ig.action_item_id ;
        end if;
          DBMS_OUTPUT.PUT_LINE('DUMMY MIN IS '||v_min);
        return v_esn||' IS ATTACHED TO MIN '||v_min;
        commit;
    else
                return v_esn||' WITH '||v_min||' IS MISSING FROM IG_TRANSACTION TABLE';        
     end if;
   close ig;   
 end if;
else
DBMS_OUTPUT.PUT_LINE('PHONE NOT FOUND OR NO LINE ATTACHED OR NO T NUMBER');
RETURN v_ESN||' IS NOT GOOD';
END IF;
close cur;
commit;
end;
/