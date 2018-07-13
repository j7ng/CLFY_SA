CREATE OR REPLACE FUNCTION sa."ADFCRM_GLOBAL_SEARCH" (p_val VARCHAR2)
   RETURN VARCHAR2
IS

  v_esn varchar2(30);

  cursor sim_c(p_sim varchar2) is
  select x_sim_serial_no
  from sa.table_x_sim_inv
  where x_sim_serial_no = p_sim;

  sim_r sim_c%rowtype;
BEGIN

   -- serial number search
   begin
   select part_serial_no
   into v_esn
   from sa.table_part_inst
   where part_serial_no = trim(p_val)
   and x_domain = 'PHONES';
   exception
   when others then null;
   end;

   if v_esn is not null then
      return v_esn;
   end if;

   -- SIM search
   begin
   select part_serial_no
   into v_esn
   from sa.table_part_inst
   where x_iccid = trim(p_val)
   and x_domain = 'PHONES';
   exception
   when others then null;
   end;

   if v_esn is not null then
      return v_esn;
   end if;

   -- MIN search
   begin
   select part_serial_no
   into v_esn
   from sa.table_part_inst
   where objid in (select part_to_esn2part_inst
                   from sa.table_part_inst
                   where part_serial_no = trim(p_val)
                   and x_domain = 'LINES')
   and x_domain = 'PHONES';
   exception
   when others then null;
   end;

   if v_esn is not null then
      return v_esn;
   end if;

   --Orphan SIM
   open sim_c(trim(p_val));
   fetch sim_c into sim_r;
   if sim_c%found then
      close sim_c;
      return 'The SIM provided is not associated to a phone/service.';
   else
      close sim_c;
      return 'Invalid ESN / MIN / SIM';
   end if;


END;
/