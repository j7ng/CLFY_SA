CREATE OR REPLACE FUNCTION sa."GETSUPPORTEDCARRS" (ip_zip in varchar2,
                                             op_carrList out carrList,
                                             op_msg out varchar2) return number
is
  v_carrList carrList := carrList();
begin
  if ip_zip is null then
    op_msg := 'ip_xip cannot be null';
    return 1;
  end if;
  for i in (select distinct carrier
          from carrListByZip
          where zip = ip_zip)
  loop
    v_carrList.extend;
    v_carrList(v_carrList.count) := i.carrier;
  end loop;
  if v_carrList.count > 0 then
     op_carrList := v_carrList;
     return 0;
  else
     op_msg := 'No Carriers found for '||ip_zip;
     return 1;
  end if;
exception
  when others then
   op_msg := 'Error:'||substr(sqlerrm,1,50);
   return 1;
end;
/