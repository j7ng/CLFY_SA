CREATE OR REPLACE FUNCTION sa."GET_RESTRICTED_USE" ( p_esn varchar2)
return number
is
  cursor c_esn is
    select pn.*
    from table_part_num pn, table_mod_level ml,
         table_part_inst pi
    where 1=1
    and ml.part_info2part_num = pn.objid
    and pi.n_part_inst2part_mod = ml.objid
    and pi.part_serial_no = p_esn;
 l_part_num_rec c_esn%rowtype;
 l_default_restricted_use number :=0;

begin
  open c_esn;
  fetch c_esn into l_part_num_rec;
  if c_esn%notfound then
    return l_default_restricted_use;
    close c_esn;
  else
    close c_esn;
    return l_part_num_rec.x_restricted_use;
  end if;
exception
  when others then
    return l_default_restricted_use;
end;
/