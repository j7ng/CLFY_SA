CREATE OR REPLACE FUNCTION sa."CHECK_UNL_FAMILY40" (p_esn in varchar2, p_program_id in number)
return number
AS
/************************************************************************************************************************************/
/**  return 0 doesn't have account ,                                                                                                */
/*            not found any ESn in the same account enroll into family promo related                                                 */
/**  return 1 found any ESn in the same account enroll into family promo related                                                     */
/************************************************************************************************************************************/
l_default  number := 0;

/** web objid associated to ESN account **/
cursor webxESN_cur (v_esn varchar2 )is
select web.objid
from table_part_inst pi, table_x_contact_part_inst cpi ,table_web_user  web
where pi.part_serial_no = v_esn
  and pi.objid = cpi.x_contact_part_inst2part_inst
  and cpi.x_contact_part_inst2contact = web.web_user2contact;
webxESN_rec   webxESN_cur%rowtype;

/** list of ESN in the same account except origigal ESN **/
cursor ESNSxacc_cur (v_web number, v_esn varchar2 ) is
select pi.part_serial_no
from table_part_inst pi, table_x_contact_part_inst cpi ,table_web_user  web
where web.objid = v_web
  and pi.objid = cpi.x_contact_part_inst2part_inst
  and cpi.x_contact_part_inst2contact = web.web_user2contact
  and pi.part_serial_no not in (v_esn);
ESNSxacc_rec   ESNSxacc_cur%rowtype;

/** check if ESN is enrolled into progran unlimited 40 ***/
cursor Esnxprogram_cur(v_program_id number, v_esn varchar2) is
 select pi.part_serial_no
    from x_program_parameters pp, x_program_enrolled pe, table_part_inst pi
    where pp.objid = pe.PGM_ENROLL2PGM_PARAMETER
      and pe.x_esn = v_esn
       and pe.x_esn = pi.part_serial_no
    and pi.x_part_inst_status = '52'
    and pi.x_domain = 'PHONES'
  --  and pp.objid = v_program_id; -- unlimited net10 5801160 comment for change that included cross company
    and pp.x_program_name in ('UNLIMITED $40 MONTHLY PLAN');
Esnxprogram_rec   Esnxprogram_cur%rowtype;

/**check if ESN is enrolled in promotion unlimited 40 */
 cursor Enrolled_promo_cur(p_esn   varchar2) is
          select  pr.x_script_id, p.x_promo_code, grp2esn.*
          from   x_enroll_promo_grp2esn grp2esn, table_x_promotion p, x_enroll_promo_rule pr, table_bus_org bo
          where  1 = 1
          and    grp2esn.x_esn          = p_esn
          and    sysdate          between grp2esn.x_start_date and nvl(grp2esn.x_end_date, sysdate + 1)
          and    p.objid                = grp2esn.promo_objid
          and    sysdate          between p.x_start_date and p.x_end_date
          and    pr.promo_objid         = grp2esn.promo_objid
          and    bo.objid               = p.promotion2bus_org
          and  (( p.objid in (select promo_id from x_promotion_relation where relationship_type = 'PARENT_CHILD')) or
                ( p.objid in (select related_promo_id from x_promotion_relation where relationship_type = 'PARENT_CHILD'))         )
          order by pr.x_priority;
Enrolled_promo_rec   Enrolled_promo_cur%rowtype;

BEGIN
  open webxESN_cur(p_esn);
  fetch webxESN_cur
   into webxESN_rec;
   -- check web objid for account
  if webxESN_cur%notfound then
      close webxESN_cur;
      dbms_output.put_line( 'do not have account ');
     return l_default;  --- doesn't have account
  else
        ---  check list of esn associated to the account
        for ESNSxacc_rec in ESNSxacc_cur( webxESN_rec.objid,p_esn) loop
          open Esnxprogram_cur(p_program_id, ESNSxacc_rec.part_serial_no);
          fetch Esnxprogram_cur
           into Esnxprogram_rec;
           -- check if alter esn is enrolled in unl 40
          if Esnxprogram_cur%found then
              dbms_output.put_line( 'found any ESN in the same account enrolled into program_id '||ESNSxacc_rec.part_serial_no);
               --check if alter ESN is enrolled in promotion unl40 or unl family 40
              for Enrolled_promo_rec in Enrolled_promo_cur( ESNSxacc_rec.part_serial_no) loop
                 dbms_output.put_line( 'ESN is enrolled in promotion unl or unl family '||ESNSxacc_rec.part_serial_no);
                 l_default := 1;
                close Esnxprogram_cur;
                 close webxESN_cur;
                 return l_default;
              end loop;
               dbms_output.put_line( 'found any ESN in the same account enrolled into program_id but is not enrolled in promo unl 40'||ESNSxacc_rec.part_serial_no);
          end if;
          close Esnxprogram_cur;
    end loop;
  end if;
  close webxESN_cur;
  dbms_output.put_line( 'not found any ESN in the same account enrolled into program_id ') ;
  return l_default; -- not found any ESn in the same account enroll into program_id
exception
  when others then
    return l_default;
end;
/