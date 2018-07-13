CREATE OR REPLACE PROCEDURE sa."GET_MOBILE_COMPLETE_URL_BY_ESN" (ip_sourcesystem in varchar2, -- WEB,WEBCSR
                                          ip_language     in varchar2, -- ENGLISH, SPANISH
                                          ip_esn          in varchar2,
                                          op_outmsg       out varchar2)
is
  v_pc varchar2(40);
  v_url varchar2(200);
  v_err_no varchar2(10);
  v_err_str varchar2(200);
  v_lang varchar2(8);
begin

  if lower(ip_language) = 'en'
  or ip_language is null then
    v_lang := 'ENGLISH';
  elsif lower(ip_language) = 'es' then
    v_lang := 'SPANISH';
  else
    v_lang := ip_language;
  end if;

  begin
    select pc.name pc
    into   v_pc
    from   table_part_inst p,
           table_mod_level m,
           table_part_num pn,
           table_part_class pc
    where  1=1
    and    p.part_serial_no = ip_esn
    and    p.n_part_inst2part_mod = m.objid
    and    m.part_info2part_num = pn.objid
    and    pn.part_num2part_class = pc.objid;
  exception
    when others then
      v_err_str := 'PART CLASS NOT FOUND FOR '||ip_esn;
      goto end_proc;
  end;

  sa.get_mobile_complete_url(ip_sourcesystem,
                             v_lang,
                             v_pc,
                             v_url,
                             v_err_no,
                             v_err_str,
                             null --ip_instruction -- SPECIFIC TUTORIAL
                             );


  <<end_proc>>

  if v_url is null then
    op_outmsg := 'ERROR '||v_err_str;
  else
    op_outmsg := v_url;
  end if;

end get_mobile_complete_url_by_esn;
/