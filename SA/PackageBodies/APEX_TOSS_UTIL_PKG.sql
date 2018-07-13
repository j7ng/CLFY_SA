CREATE OR REPLACE PACKAGE BODY sa."APEX_TOSS_UTIL_PKG"
As
  /********************************************************************************/
  /* PURPOSE  : Package has been developed to handle the transactions invoked     */
  /*            for the menu TOSS UTIL in APEX                                    */
  /********************************************************************************/
--------------------------------------------------------------------------------------------
--$RCSfile: APEX_TOSS_UTIL_PKG_BODY.sql,v $
--$Revision: 1.26 $
--$Author: hcampano $
--$Date: 2017/09/07 17:13:03 $
--$ $Log: APEX_TOSS_UTIL_PKG_BODY.sql,v $
--$ Revision 1.26  2017/09/07 17:13:03  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.25  2017/09/07 16:03:53  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.24  2017/09/01 14:36:49  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.23  2017/08/25 17:27:12  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.22  2017/05/30 16:02:16  syenduri
--$ Check-in behalf of Natalio - Done changes for WFM : Invalid Reserve Pin Changes
--$
--$ Revision 1.21  2017/05/10 18:20:58  hcampano
--$ CR49444 / REL862_TAS - CRT Miami Management Profile Update
--$
--$ Revision 1.20  2017/04/10 17:15:39  nguada
--$ reverted back to 1.17
--$
--$ Revision 1.17  2015/01/26 16:39:08  hcampano
--$ TAS_2015_03 - fixing development issues.
--$
--$ Revision 1.16  2015/01/25 15:45:36  hcampano
--$ TAS_2015_03 - fixing development issues.
--$
--$ Revision 1.15  2015/01/23 22:31:14  hcampano
--$ TAS_2015_03
--$
--$ Revision 1.14  2015/01/23 17:56:23  hcampano
--$ TAS_2015_03
--$
--$ Revision 1.13  2015/01/21 20:57:13  hcampano
--$ TAS_2015_03
--$
--$ Revision 1.12  2015/01/09 14:54:33  hcampano
--$ Changes for Brand X. TAS_2015_03
--$
--$ Revision 1.11  2014/06/24 12:23:46  hcampano
--$ 7/2014 TAS release (TAS_2014_06) overloaded sp_mark_card_invalid. CR29035
--$
--$ Revision 1.10  2014/06/18 15:57:44  hcampano
--$ 6/24 TAS release (TAS_2014_05) Airtime Card Changes
--$
--$ Revision 1.9  2014/05/29 15:37:39  hcampano
--$ TAS_2014_03B - Added new column to airtime cards func
--$
--$ Revision 1.8  2014/05/28 20:55:48  hcampano
--$ TAS_2014_03B - Rollout B, New DB objects
--$
--$ Revision 1.7  2014/05/20 12:06:09  nguada
--$ Bug Fix TAS_2014_03
--$
--$ Revision 1.6  2013/10/18 21:28:04  mmunoz
--$ CR25435
--$
--$ Revision 1.5  2013/10/18 20:37:27  mmunoz
--$ Checking 'REDEMPTION CARDS' domain in table_part_num instead of table_part_inst
--$
--$ Revision 1.4  2013/08/09 14:22:00  mmunoz
--$ CR24397 Allow change card status for parent and children
--$
--$ Revision 1.3  2013/08/08 21:02:17  mmunoz
--$ CR24397
--$
--$ Revision 1.2  2013/07/03 18:41:55  mmunoz
--$ CR24856 Implement TAS Toss Util Airtime Card Reset Button when status is null or 263
--$
--$ Revision 1.1  2012/08/30 13:52:37  mmunoz
--$ Package created to handle the transactions invoked for the menu TOSS UTIL in APEX
--$
--------------------------------------------------------------------------------------------
FUNCTION get_parent_snp_func(ip_snp_or_card_no VARCHAR2)
return varchar2
IS
 /******************************************************************/
 /* PURPOSE  : Find the parent SNP related with card               */
 /* Input parameter: part_serial_no (SNP) or red_code (PIN)        */
 /*                  associated a any card (parent or child)       */
 /* Return: part_serial_no (SNP) associated with the parent card   */
 /******************************************************************/
CURSOR get_parent_snp (
  ip_snp_or_card_no VARCHAR2
) IS
  select nvl(x_parent_part_serial_no,part_serial_no) x_parent_serial_no
    FROM table_part_inst pi
    where pi.x_red_code = ip_snp_or_card_no
    union
    select x_part_serial_no  x_parent_serial_no
    FROM sa.table_x_posa_card_inv posa
    where posa.x_red_code = ip_snp_or_card_no
    union
    select x_smp  x_parent_serial_no
    FROM sa.table_x_red_card rc
    where rc.x_red_code = ip_snp_or_card_no
    union
    select nvl(x_parent_part_serial_no,part_serial_no) x_parent_serial_no
    FROM table_part_inst pi,
         sa.table_mod_level b,
         sa.table_part_num c
    where pi.part_serial_no = ip_snp_or_card_no
     and  b.objid = pi.n_part_inst2part_mod
     and  c.objid = b.part_info2part_num
     and  c.domain = 'REDEMPTION CARDS'
    --AND pi.x_domain = 'REDEMPTION CARDS'  10/18/2013 checking this condition in table_part_num
    UNION
    select x_part_serial_no  x_parent_serial_no
    FROM sa.table_x_posa_card_inv posa,
         sa.table_mod_level b,
         sa.table_part_num c
    where posa.x_part_serial_no = ip_snp_or_card_no
     and  b.objid = posa.x_posa_inv2part_mod
     and  c.objid = b.part_info2part_num
     and  c.domain = 'REDEMPTION CARDS'
    --AND posa.x_domain = 'REDEMPTION CARDS'  10/18/2013 checking this condition in table_part_num
    union
    select x_smp  x_parent_serial_no
    FROM sa.table_x_red_card rc
    WHERE rc.x_smp = ip_snp_or_card_no;

  get_parent_snp_rec  get_parent_snp%rowtype;
BEGIN
   OPEN get_parent_snp(ip_snp_or_card_no);
   FETCH get_parent_snp INTO get_parent_snp_rec;
   CLOSE get_parent_snp;
   return get_parent_snp_rec.x_parent_serial_no;
END get_parent_snp_func;
--------------------------------------------------------------------------------
-- OVERLOADED
--------------------------------------------------------------------------------
function airtime_cards(ip_search_type varchar2, ip_search_value varchar2)
return airtime_cards_tab
pipelined
is
  cursor c1 (red_card varchar2)
  is
  select *
  from table(sa.apex_toss_util_pkg.airtime_cards(red_card));

  cursor c1_by_group(group_id varchar2)
  is
  select *
  from table(sa.apex_toss_util_pkg.airtime_cards_by_group_id(group_id => group_id));

  cursor c2 (reserved_for_esn varchar2,x_service_id varchar2,card_number varchar2)
  is
  select distinct c.id_number case_id,d.x_value reference_pin
  from   table_x_case_detail d,
         table_case c
  where  detail2case = c.objid
  and    d.x_name like 'REFERENCE_PIN'
  and    d.x_value = card_number
  and    (c.x_esn = reserved_for_esn
  or     c.x_esn = x_service_id);

begin

  airtime_cards_rslt.card_no := null;
  airtime_cards_rslt.part_number := null;
  airtime_cards_rslt.description := null;
  airtime_cards_rslt.x_result := null;
  airtime_cards_rslt.access_days := null;
  airtime_cards_rslt.card_units := null;
  airtime_cards_rslt.snp_esn := null;
  airtime_cards_rslt.source_sys := null;
  airtime_cards_rslt.x_transact_date := null;
  airtime_cards_rslt.status := null;
  airtime_cards_rslt.status_desc := null;
  airtime_cards_rslt.dealer_id := null;
  airtime_cards_rslt.dealer_name := null;
  airtime_cards_rslt.reserved_for_esn := null;
  airtime_cards_rslt.change_card_status := null;
  airtime_cards_rslt.mark_card_invalid := null;
  airtime_cards_rslt.part_serial_no := null;
  airtime_cards_rslt.x_service_id := null;
  airtime_cards_rslt.current_min := null;
  airtime_cards_rslt.account_group_name := null;
  airtime_cards_rslt.account_group_id := null;
  airtime_cards_rslt.s_login_name := null;
  airtime_cards_rslt.call_trans_objid := null;
  airtime_cards_rslt.org_id := null;

  if ip_search_type is null then
    return;
  end if;

  if ip_search_value is null then
    return;
  end if;

  if upper(ip_search_type) = 'ESN' then
    for i in (select x_red_code
              from   table_x_red_card,
                     table_mod_level,
                     table_part_num,
                     table_part_class
              where  part_info2part_num = table_part_num.objid
              and    x_red_card2part_mod= table_mod_level.objid
              and    table_part_class.objid = part_num2part_class
              and    red_card2call_trans in (select call_trans_objid
                                             from   table_x_act_deact_hist
                                             WHERE  X_SERVICE_ID = ip_search_value))
    loop
      for j in c1(i.x_red_code)
      loop
        airtime_cards_rslt.card_no := j.card_no;
        airtime_cards_rslt.part_number := j.part_number;
        airtime_cards_rslt.description := j.description;
        airtime_cards_rslt.x_result := j.x_result;
        airtime_cards_rslt.access_days := j.access_days;
        airtime_cards_rslt.card_units := j.card_units;
        airtime_cards_rslt.snp_esn := j.snp_esn;
        airtime_cards_rslt.source_sys := j.source_sys;
        airtime_cards_rslt.x_transact_date := j.x_transact_date;
        airtime_cards_rslt.status := j.status;
        airtime_cards_rslt.status_desc := j.status_desc;
        airtime_cards_rslt.dealer_id := j.dealer_id;
        airtime_cards_rslt.dealer_name := j.dealer_name;
        airtime_cards_rslt.reserved_for_esn := j.reserved_for_esn;
        airtime_cards_rslt.change_card_status := j.change_card_status;
        airtime_cards_rslt.mark_card_invalid := j.mark_card_invalid;
        airtime_cards_rslt.part_serial_no := j.part_serial_no;
        airtime_cards_rslt.x_service_id := j.x_service_id;
        airtime_cards_rslt.current_min := j.current_min;
        airtime_cards_rslt.call_trans_objid := j.call_trans_objid;

        for k in c2(j.reserved_for_esn,j.x_service_id,j.card_no)
        loop
          airtime_cards_rslt.related_cases := airtime_cards_rslt.related_cases ||chr(10)||'TICKET: '||k.case_id; --||' REF PIN: '||k.reference_pin;
        end loop;

        airtime_cards_rslt.account_group_name := j.account_group_name;
        airtime_cards_rslt.account_group_id := j.account_group_id;
        airtime_cards_rslt.s_login_name := j.s_login_name;

        pipe row (airtime_cards_rslt);
      end loop;
    end loop;
  end if;

  if upper(ip_search_type) = 'PIN' then
    for j in c1(ip_search_value)
    loop
      airtime_cards_rslt.card_no := j.card_no;
      airtime_cards_rslt.part_number := j.part_number;
      airtime_cards_rslt.description := j.description;
      airtime_cards_rslt.x_result := j.x_result;
      airtime_cards_rslt.access_days := j.access_days;
      airtime_cards_rslt.card_units := j.card_units;
      airtime_cards_rslt.snp_esn := j.snp_esn;
      airtime_cards_rslt.source_sys := j.source_sys;
      airtime_cards_rslt.x_transact_date := j.x_transact_date;
      airtime_cards_rslt.status := j.status;
      airtime_cards_rslt.status_desc := j.status_desc;
      airtime_cards_rslt.dealer_id := j.dealer_id;
      airtime_cards_rslt.dealer_name := j.dealer_name;
      airtime_cards_rslt.reserved_for_esn := j.reserved_for_esn;
      airtime_cards_rslt.change_card_status := j.change_card_status;
      airtime_cards_rslt.mark_card_invalid := j.mark_card_invalid;
      airtime_cards_rslt.part_serial_no := j.part_serial_no;
      airtime_cards_rslt.x_service_id := j.x_service_id;
      airtime_cards_rslt.current_min := j.current_min;
      airtime_cards_rslt.call_trans_objid := j.call_trans_objid;

      for k in c2(j.reserved_for_esn,j.x_service_id,j.card_no)
      loop
        airtime_cards_rslt.related_cases := airtime_cards_rslt.related_cases ||chr(10)||'TICKET: '||k.case_id; --||' REF PIN: '||k.reference_pin;
      end loop;

      airtime_cards_rslt.account_group_name := j.account_group_name;
      airtime_cards_rslt.account_group_id := j.account_group_id;
      airtime_cards_rslt.s_login_name := j.s_login_name;

      pipe row (airtime_cards_rslt);
    end loop;
  end if;
  ------------------------------------------------------------------------------
  -- NEW SECTION FOR GROUP ID
  ------------------------------------------------------------------------------
  if upper(ip_search_type) = 'GROUP_ID' then
  --------------------------------------------------------------------------------
    for i in c1_by_group(group_id => ip_search_value)
    loop
      airtime_cards_rslt.card_no := i.card_no;
      airtime_cards_rslt.part_number := i.part_number;
      airtime_cards_rslt.description := i.description;
      airtime_cards_rslt.x_result := i.x_result;
      airtime_cards_rslt.access_days := i.access_days;
      airtime_cards_rslt.card_units := i.card_units;
      airtime_cards_rslt.snp_esn := i.snp_esn;
      airtime_cards_rslt.source_sys := i.source_sys;
      airtime_cards_rslt.x_transact_date := i.x_transact_date;
      airtime_cards_rslt.status := i.status;
      airtime_cards_rslt.status_desc := i.status_desc;
      airtime_cards_rslt.dealer_id := i.dealer_id;
      airtime_cards_rslt.dealer_name := i.dealer_name;
      airtime_cards_rslt.reserved_for_esn := i.reserved_for_esn;
      airtime_cards_rslt.change_card_status := i.change_card_status;
      airtime_cards_rslt.mark_card_invalid := i.mark_card_invalid;
      airtime_cards_rslt.part_serial_no := i.part_serial_no;
      airtime_cards_rslt.x_service_id := i.x_service_id;
      airtime_cards_rslt.current_min := i.current_min;
      airtime_cards_rslt.call_trans_objid := i.call_trans_objid;

      for k in c2(i.reserved_for_esn,i.x_service_id,i.card_no)
      loop
        airtime_cards_rslt.related_cases := airtime_cards_rslt.related_cases ||chr(10)||'TICKET: '||k.case_id; --||' REF PIN: '||k.reference_pin;
      end loop;

      airtime_cards_rslt.account_group_name := i.account_group_name;
      airtime_cards_rslt.account_group_id := i.account_group_id;
      airtime_cards_rslt.s_login_name := i.s_login_name;
      airtime_cards_rslt.x_service_id := i.part_serial_no;

      pipe row (airtime_cards_rslt);
    end loop;
  end if;
  ------------------------------------------------------------------------------
  -- END NEW SECTION
  ------------------------------------------------------------------------------
  return;
end;
--------------------------------------------------------------------------------
function airtime_cards(ip_snp_or_card_no varchar2)
return airtime_cards_tab
pipelined
is
 /**********************************************************************/
 /* PURPOSE  : Return information about all cards related with a       */
 /*            part_serial_no (SNP) or red_code (PIN) (parent/child)   */
 /* Input parameter: part_serial_no (SNP) or red_code (PIN)            */
 /*                  associated a any card (parent or child)           */
 /* Return: Rows associated with the input given (parent and children) */
 /**********************************************************************/
  ip_snp  table_part_inst.part_serial_no%type;

  -- IF THE ESN IS PASSED, DONT GET THE GROUP FROM THE ESN BECAUSE
  -- THE ESN MAY NO LONGER BE PART OF THAT GROUP,
  -- GET THE GROUP FROM THE CALL TRANS
  -- ALSO THE GROUP MAY ALREADY NOLOGER BE ACTIVE
  cursor c3 (ip_search_value varchar2)
  is
  select g.account_group_name ,e.account_group_id,
         sa.apex_toss_util_pkg.get_my_account_email(ip_esn => sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'GROUP_ID', ip_search_value => e.account_group_id)) s_login_name
  from    table_x_call_trans c,
          table_x_call_trans_ext e,
          x_account_group g
  where e.call_trans_ext2call_trans = c.objid
  and e.account_group_id  = g.objid
  and c.objid = ip_search_value;

  --IF NO CALL TRANS IS PASSED MUST LOOK FOR IT BY ESN
  cursor c3point2(ip_search_value varchar2)
  is
  select distinct g.account_group_name ,e.account_group_id,
         sa.apex_toss_util_pkg.get_my_account_email(ip_esn => sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'GROUP_ID', ip_search_value => e.account_group_id)) s_login_name
  from    table_x_call_trans c,
          table_x_call_trans_ext e,
          x_account_group g
  where e.call_trans_ext2call_trans = c.objid
  and e.account_group_id  = g.objid
  and c.x_service_id = ip_search_value;

begin
  ip_snp := apex_toss_util_pkg.get_parent_snp_func(ip_snp_or_card_no);
  if length(ip_snp) > 0
  then
  for i in (select a.x_red_code card_no,
                   c.part_number,
                   c.description,
                   bo.org_id,
                   a.x_result,
                   c.x_redeem_days access_days,
                   nvl(a.x_total_units,c.x_redeem_units) card_units,
                   a.part_serial_no snp_esn,
                   --If the air time card has not been redeemed, source_sys should stay empty.
                   case a.status
                   when '45' then c.x_sourcesystem -- always pull this value from part num, not call trans, if 45
                   when '41' then nvl(a.x_sourcesystem,c.x_sourcesystem)  --Redeemed
                   else null
                   end  source_sys,
                   a.x_transact_date x_transact_date,
                   a.status,
                   d.x_code_name status_desc,
                   f.site_id dealer_id,
                   f.name dealer_name,
                   PI.PART_SERIAL_NO RESERVED_FOR_ESN,
                   --decode(nvl(a.x_parent_part_serial_no,a.part_serial_no),a.part_serial_no,             --Allow change card status only when snp is parent CR21806
                          decode(a.status,'40','Un-Reserve'
                                        ,'400','Un-Reserve'
                                          ,'43','Reset_Voided'
                                          ,'263','Reset'
                                          ,'45','Reset_POSA'
                                          ,NULL,'Reset','')
                   --                       ,'')
                                          change_card_status,
                   --decode(nvl(a.x_parent_part_serial_no,a.part_serial_no),a.part_serial_no,             --Allow Mark Card Invalid only when snp is parent CR21806
                           decode(a.status,'40','Mark Invalid'
                                          ,'400','Mark Invalid'
                                          ,'42','Mark Invalid'
                                          ,'43','Mark Invalid','')
                    --                      ,'')
                                          Mark_Card_Invalid,
                    a.part_serial_no,
                    a.x_service_id, -- reserved should be showing, queued is not clear
                    a.current_min,
                    a.call_trans_objid
            FROM   (SELECT A.objid, A.part_serial_no,
                           decode(a.status2x_code_table,null,null,a.x_part_inst_status) status, a.x_red_code, a.x_part_inst_status partstatus,
                           a.n_part_inst2part_mod join_mov_level, a.part_inst2inv_bin join_inv_bin,null x_result, null x_transact_date,
                           a.part_to_esn2part_inst, null x_sourcesystem, null x_total_units,
                           null x_service_id, x_parent_part_serial_no, null current_min, null call_trans_objid
                    FROM   sa.table_part_inst A
                    WHERE  1=1
                    and    a.part_serial_no = ip_snp --'1173418412502
                    --and    a.x_domain = 'REDEMPTION CARDS'  10/18/2013 checking this condition in table_part_num
                    union
                    -- get chidren SNPs CR21806
                    SELECT A.objid, A.part_serial_no,
                           decode(a.status2x_code_table,null,null,a.x_part_inst_status) status, a.x_red_code, a.x_part_inst_status partstatus,
                           a.n_part_inst2part_mod join_mov_level, a.part_inst2inv_bin join_inv_bin,null x_result, null x_transact_date,
                           a.part_to_esn2part_inst, null x_sourcesystem, null x_total_units,
                           null x_service_id, x_parent_part_serial_no, null current_min, null call_trans_objid
                    FROM   sa.table_part_inst A
                    where  a.part_serial_no like ip_snp||'%'
                    and    a.x_parent_part_serial_no = ip_snp
                    --and    a.x_domain = 'REDEMPTION CARDS'  10/18/2013 checking this condition in table_part_num
                    union
                    select a.objid, a.x_part_serial_no part_serial_no, a.x_posa_inv_status status, a.x_red_code,
                           a.x_posa_inv_status partstatus,a.x_posa_inv2part_mod join_mov_level, a.x_posa_inv2inv_bin join_inv_bin,null x_result,
                           null x_transact_date, null part_to_esn2part_inst, null x_sourcesystem, null x_total_units,
                           null x_service_id, null x_parent_part_serial_no, null current_min, null call_trans_objid
                    from   sa.table_x_posa_card_inv a
                    where  1=1
                    and    a.x_part_serial_no = ip_snp
                    --and    a.x_domain = 'REDEMPTION CARDS'   10/18/2013 checking this condition in table_part_num
                    union
                    select rc.objid, rc.x_smp part_serial_no, '41' status, rc.x_red_code, '41' partstatus,
                           rc.x_red_card2part_mod join_mov_level, rc.x_red_card2inv_bin join_inv_bin,
                           ct.x_result ,ct.x_transact_date, null  part_to_esn2part_inst, ct.x_sourcesystem, ct.x_total_units,
                           sp.x_service_id x_service_id, null x_parent_part_serial_no,sp.x_min current_min -- CHANGE X_MIN+X_SERVICE_ID
                           , ct.objid call_trans_objid
                    from   sa.table_x_red_card rc,
                           sa.table_x_call_trans ct,
                           sa.table_site_part sp -- NEW
                    where  1=1
                    and    ct.objid = rc.red_card2call_trans
                    and    sp.objid = ct.call_trans2site_part
                    and    rc.x_smp like ip_snp||'%'                                        -- get parent and chidren SNPs CR21806
                    and    (regexp_like(rc.x_smp,'.*[^0123456789]$') or x_smp = ip_snp)     -- get parent and chidren SNPs CR21806
                    ) a,
                   sa.table_mod_level b,
                   sa.table_part_num c,
                   sa.table_inv_bin e,
                   sa.table_site f,
                   sa.table_x_code_table d,
                   sa.table_part_inst pi,
                   sa.table_bus_org bo
            where 1 = 1
            and  b.objid = a.join_mov_level
            and  c.objid = b.part_info2part_num
            --and  c.domain = 'REDEMPTION CARDS'
            and  e.objid = a.join_inv_bin
            and  f.site_id = e.bin_name
            and  d.x_code_number(+) = a.partstatus
            and  c.part_num2bus_org = bo.objid
            and  pi.objid (+) = a.part_to_esn2part_inst)
  loop
    airtime_cards_rslt.card_no := i.card_no;
    airtime_cards_rslt.part_number := i.part_number;
    airtime_cards_rslt.description := i.description;
    airtime_cards_rslt.x_result := i.x_result;
    airtime_cards_rslt.access_days := i.access_days;
    airtime_cards_rslt.card_units := i.card_units;
    airtime_cards_rslt.snp_esn := i.snp_esn;
    airtime_cards_rslt.source_sys := i.source_sys;
    airtime_cards_rslt.x_transact_date := i.x_transact_date;
    airtime_cards_rslt.status := i.status;
    airtime_cards_rslt.status_desc := i.status_desc;
    airtime_cards_rslt.dealer_id := i.dealer_id;
    airtime_cards_rslt.dealer_name := i.dealer_name;
    airtime_cards_rslt.reserved_for_esn := i.reserved_for_esn;

    if i.org_id = 'WFM' then
          airtime_cards_rslt.change_card_status := null;
          if i.status in ('40','400','42','43') then
             airtime_cards_rslt.mark_card_invalid := 'Mark Invalid';
          else
             airtime_cards_rslt.mark_card_invalid := null;
          end if;
    else
       if i.source_sys = 'MULTI DENOM RED CARD'
         and i.status = '45'
       then
         airtime_cards_rslt.change_card_status := 'Assign_Denomination';
       else
         airtime_cards_rslt.change_card_status := i.change_card_status;
       end if;
       airtime_cards_rslt.mark_card_invalid := i.mark_card_invalid;
    end if;

    airtime_cards_rslt.part_serial_no := i.part_serial_no;
    airtime_cards_rslt.x_service_id := i.x_service_id;
    airtime_cards_rslt.current_min := i.current_min;
    airtime_cards_rslt.call_trans_objid := i.call_trans_objid;
    airtime_cards_rslt.org_id := i.org_id;

    if i.call_trans_objid is not null then
      for h in c3(i.call_trans_objid)
      loop
        airtime_cards_rslt.account_group_name := h.account_group_name;
        airtime_cards_rslt.account_group_id := h.account_group_id;
        airtime_cards_rslt.s_login_name := h.s_login_name;
      end loop;
    else
      for h in c3point2(i.reserved_for_esn)
      loop
        airtime_cards_rslt.account_group_name := h.account_group_name;
        airtime_cards_rslt.account_group_id := h.account_group_id;
        airtime_cards_rslt.s_login_name := h.s_login_name;
      end loop;
    end if;

    pipe row (airtime_cards_rslt);
  end loop;
  end if;
  return;
end airtime_cards;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function airtime_cards_by_group_id(group_id varchar2)
return airtime_cards_tab
pipelined
is

begin

  if length(group_id) > 0
  then
  for i in (select a.x_red_code card_no,
                   c.part_number,
                   c.description,
                   bo.org_id,
                   a.x_result,
                   c.x_redeem_days access_days,
                   nvl(a.x_total_units,c.x_redeem_units) card_units,
                   a.part_serial_no snp_esn,
                   --If the air time card has not been redeemed, source_sys should stay empty.
                   case a.status
                   when '41' then nvl(a.x_sourcesystem,c.x_sourcesystem)  --Redeemed
                   else null
                   end  source_sys,
                   a.x_transact_date x_transact_date,
                   a.status,
                   d.x_code_name status_desc,
                   f.site_id dealer_id,
                   f.name dealer_name,
                   PI.PART_SERIAL_NO RESERVED_FOR_ESN,
                          decode(a.status,'40','Un-Reserve'
                                        ,'400','Un-Reserve'
                                          ,'43','Reset_Voided'
                                          ,'263','Reset'
                                          ,'45','Reset_POSA'
                                          ,NULL,'Reset','')
                                          change_card_status,
                           decode(a.status,'40','Mark Invalid'
                                          ,'400','Mark Invalid'
                                          ,'42','Mark Invalid'
                                          ,'43','Mark Invalid','')
                                          Mark_Card_Invalid,
                    a.part_serial_no,
                    a.x_service_id, -- reserved should be showing, queued is not clear
                    a.current_min,
                    a.call_trans_objid,
                    a.account_group_id,
                    a.account_group_name
            FROM   (select rc.objid, rc.x_smp part_serial_no, '41' status, rc.x_red_code, '41' partstatus,
                           rc.x_red_card2part_mod join_mov_level, rc.x_red_card2inv_bin join_inv_bin,
                           ct.x_result ,ct.x_transact_date, null  part_to_esn2part_inst, ct.x_sourcesystem, ct.x_total_units,
                           sp.x_service_id x_service_id, null x_parent_part_serial_no,sp.x_min current_min -- CHANGE X_MIN+X_SERVICE_ID
                           , ct.objid call_trans_objid,
                           g.objid account_group_id,
                           g.account_group_name
                    from    sa.table_x_call_trans ct,
                            sa.table_x_call_trans_ext e,
                            sa.x_account_group g,
                            sa.table_x_red_card rc,
                            sa.table_site_part sp
                    where 1=1
                    and    ct.objid = rc.red_card2call_trans
                    and    sp.objid = ct.call_trans2site_part
                    and e.call_trans_ext2call_trans = ct.objid
                    and e.account_group_id  = g.objid
                    and e.account_group_id = group_id
                    union
                    select A.objid, A.part_serial_no,
                           decode(a.status2x_code_table,null,null,a.x_part_inst_status) status, a.x_red_code, a.x_part_inst_status partstatus,
                           a.n_part_inst2part_mod join_mov_level, a.part_inst2inv_bin join_inv_bin,null x_result, null x_transact_date,
                           a.part_to_esn2part_inst, null x_sourcesystem, null x_total_units,
                           null x_service_id, x_parent_part_serial_no, null current_min, null call_trans_objid,
                           b.account_group_id, b.account_group_name
                    from   table_part_inst a,
                          (select pi.objid, g.account_group_name , g.objid account_group_id
                           from   x_account_group_member m,
                                  table_part_inst pi,
                                  x_account_group g
                           where  1=1
                           and    m.account_group_id = g.objid
                           and    m.esn = pi.part_serial_no
                           and    m.account_group_id = group_id
                           and    m.status != 'EXPIRED') b
                    where  a.part_to_esn2part_inst = b.objid
                    and    a.x_domain = 'REDEMPTION CARDS'
                    -- TODO (ATM NOT SURE WE NEED TO DO THIS) - get chidren SNPs CR21806
                    ) a,
                   sa.table_mod_level b,
                   sa.table_part_num c,
                   sa.table_inv_bin e,
                   sa.table_site f,
                   sa.table_x_code_table d,
                   sa.table_part_inst pi,
                   sa.table_bus_org bo
            where 1 = 1
            and  b.objid = a.join_mov_level
            and  c.objid = b.part_info2part_num
            and  c.part_num2bus_org = bo.objid
            and  e.objid = a.join_inv_bin
            and  f.site_id = e.bin_name
            and  d.x_code_number(+) = a.partstatus
            and  pi.objid (+) = a.part_to_esn2part_inst)
  loop
    airtime_cards_rslt.card_no := i.card_no;
    airtime_cards_rslt.part_number := i.part_number;
    airtime_cards_rslt.description := i.description;
    airtime_cards_rslt.x_result := i.x_result;
    airtime_cards_rslt.access_days := i.access_days;
    airtime_cards_rslt.card_units := i.card_units;
    airtime_cards_rslt.snp_esn := i.snp_esn;
    airtime_cards_rslt.source_sys := i.source_sys;
    airtime_cards_rslt.x_transact_date := i.x_transact_date;
    airtime_cards_rslt.status := i.status;
    airtime_cards_rslt.status_desc := i.status_desc;
    airtime_cards_rslt.dealer_id := i.dealer_id;
    airtime_cards_rslt.dealer_name := i.dealer_name;
    airtime_cards_rslt.reserved_for_esn := i.reserved_for_esn;
    if i.org_id = 'WFM' then
          airtime_cards_rslt.change_card_status := null;
          if i.status in ('40','400','42','43') then
             airtime_cards_rslt.mark_card_invalid := 'Mark Invalid';
          else
             airtime_cards_rslt.mark_card_invalid := null;
          end if;
    else
       airtime_cards_rslt.change_card_status := i.change_card_status;
       airtime_cards_rslt.mark_card_invalid := i.mark_card_invalid;
    end if;
    airtime_cards_rslt.part_serial_no := i.part_serial_no;
    airtime_cards_rslt.x_service_id := i.x_service_id;
    airtime_cards_rslt.current_min := i.current_min;
    airtime_cards_rslt.call_trans_objid := i.call_trans_objid;
    airtime_cards_rslt.account_group_name := i.account_group_name;
    airtime_cards_rslt.account_group_id := i.account_group_id;
    airtime_cards_rslt.s_login_name := sa.apex_toss_util_pkg.get_my_account_email(ip_esn => sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'GROUP_ID', ip_search_value => group_id));

    pipe row (airtime_cards_rslt);
  end loop;
  end if;
  return;
end airtime_cards_by_group_id;
--------------------------------------------------------------------------------
  procedure sp_mark_card_invalid (
   ip_snp    in varchar2      --assumption ip_snp is the parent snp
  ,op_result out number
  ,op_msg    out varchar2
  )  is
  begin
   op_result := 0;
   op_msg    := 'sucess';
   Update /*+ INDEX (PI IND_PART_INST_PSERIAL_U11) */
          sa.TABLE_PART_INST pi
   SET    pi.X_PART_INST_STATUS = 44,
          pi.PART_TO_ESN2PART_INST = NULL,
          pi.STATUS2X_CODE_TABLE = 1144
   WHERE  pi.part_serial_no = ip_snp
   AND    EXISTS (SELECT 'X'
                  FROM   sa.table_mod_level b,
                         sa.table_part_num c
                  WHERE  b.objid = pi.n_part_inst2part_mod
                    and  c.objid = b.part_info2part_num
                    and  c.domain = 'REDEMPTION CARDS');
   --AND    pi.x_domain = 'REDEMPTION CARDS';

--CR21806 to invalidate children SNPs
   update /*+ INDEX (PI IND_PART_INST_PSERIAL_U11) */
          table_part_inst pi
   SET    X_PART_INST_STATUS = 44,
          PART_TO_ESN2PART_INST = NULL,
          status2x_code_table = 1144
   where  pi.part_serial_no like ip_snp||'%'
   and    pi.x_parent_part_serial_no = ip_snp
   AND    EXISTS (SELECT 'X'
                  FROM   sa.table_mod_level b,
                         sa.table_part_num c
                  WHERE  b.objid = pi.n_part_inst2part_mod
                    and  c.objid = b.part_info2part_num
                    and  c.domain = 'REDEMPTION CARDS');
   --and    pi.x_domain = 'REDEMPTION CARDS';

   COMMIT;
   exception
      when others then
        ROLLBACK;
        op_result := -1;
        op_msg    := sqlerrm;
  end sp_mark_card_invalid;
--------------------------------------------------------------------------------
-- OVERLOADED sp_mark_card_invalid
--------------------------------------------------------------------------------
  procedure sp_mark_card_invalid (
   ip_snp    in varchar2      --assumption ip_snp is the parent snp
  ,ip_esn    in varchar2
  ,op_result out number
  ,op_msg    out varchar2
  )  is

   esn_objid number;
  begin
   op_result := 0;
   op_msg    := 'sucess';

   select objid
   into   esn_objid
   from   table_part_inst
   where  part_serial_no = ip_esn;

   update /*+ INDEX (PI IND_PART_INST_PSERIAL_U11) */
          sa.TABLE_PART_INST pi
   set    pi.x_part_inst_status = 44,
          pi.PART_TO_ESN2PART_INST = esn_objid, --NULL, CR29035
          pi.STATUS2X_CODE_TABLE = 1144
   WHERE  pi.part_serial_no = ip_snp
   AND    EXISTS (SELECT 'X'
                  FROM   sa.table_mod_level b,
                         sa.table_part_num c
                  WHERE  b.objid = pi.n_part_inst2part_mod
                    and  c.objid = b.part_info2part_num
                    and  c.domain = 'REDEMPTION CARDS');
   --AND    pi.x_domain = 'REDEMPTION CARDS';

--CR21806 to invalidate children SNPs
   update /*+ INDEX (PI IND_PART_INST_PSERIAL_U11) */
          table_part_inst pi
   SET    X_PART_INST_STATUS = 44,
          PART_TO_ESN2PART_INST = esn_objid, --NULL, CR29035
          status2x_code_table = 1144
   where  pi.part_serial_no like ip_snp||'%'
   and    pi.x_parent_part_serial_no = ip_snp
   AND    EXISTS (SELECT 'X'
                  FROM   sa.table_mod_level b,
                         sa.table_part_num c
                  WHERE  b.objid = pi.n_part_inst2part_mod
                    and  c.objid = b.part_info2part_num
                    and  c.domain = 'REDEMPTION CARDS');
   --and    pi.x_domain = 'REDEMPTION CARDS';

   COMMIT;
   exception
      when others then
        ROLLBACK;
        op_result := -1;
        if instr(sqlerrm,'no data found')>0 then
          op_msg := 'ESN Required';
        else
          op_msg    := sqlerrm;
        end if;
  end sp_mark_card_invalid;
--------------------------------------------------------------------------------
  procedure sp_ResetVoided_Unreserve (
   ip_snp    in varchar2      --assumption ip_snp is the parent snp
  ,op_result out number
  ,op_msg    out varchar2
  )  is
  begin
   op_result := 0;
   op_msg    := 'sucess';
   Update TABLE_PART_INST pi
   SET    X_PART_INST_STATUS = 42,
          PART_TO_ESN2PART_INST = NULL,
          status2x_code_table = 984
   WHERE  pi.part_serial_no = ip_snp
   AND    EXISTS (SELECT 'X'
                  FROM   sa.table_mod_level b,
                         sa.table_part_num c
                  WHERE  b.objid = pi.n_part_inst2part_mod
                    and  c.objid = b.part_info2part_num
                    and  c.domain = 'REDEMPTION CARDS');
   --AND    pi.x_domain = 'REDEMPTION CARDS';

   COMMIT;
   exception
      when others then
        ROLLBACK;
        op_result := -1;
        op_msg    := sqlerrm;
  end sp_resetvoided_unreserve;
--------------------------------------------------------------------------------
  -- THIS IS FOR GROUP ACCOUNTS ONLY
  function get_my_account_email(ip_esn varchar2)
  return varchar2
  as
    s_login_name varchar2(50);
  begin
    select web.s_login_name
    into   s_login_name
    from   table_web_user web,
           table_x_contact_part_inst conpi,
           table_part_inst pi
    where   1=1
    and   pi.objid = conpi.x_contact_part_inst2part_inst
    and   conpi.x_contact_part_inst2contact = web.web_user2contact
    and   pi.part_serial_no = ip_esn;

    return s_login_name;
  exception
    when others then
      return null;
  end get_my_account_email;
--------------------------------------------------------------------------------
procedure tas_denom (ip_snp_prefix varchar2,
	                 ip_snp varchar2,
	                 ip_upc_no varchar2,
	                 ip_incident_id varchar2,
	                 ip_login_name varchar2,
	                 ip_notes varchar2, -- LONG COLUMN
	                 op_err_no out varchar2,
	                 op_err_msg out varchar2)
  is
    ip_date varchar2(200);
    ip_time varchar2(200);
    op_out_units number;
    op_bhn_code varchar2(200);
    v_dummy varchar2(200);
    v_snp_prefix varchar2(30);
  begin
    v_snp_prefix := sa.get_param_value('BHN');
    if v_snp_prefix is null then
      op_err_msg := 'Failed - BHN SNP Prefix parameter missing';
      return;
    end if;
    dbms_output.put_line('v_snp_prefix    = '||v_snp_prefix);
    dbms_output.put_line('ip_snp          = '||ip_snp);
    dbms_output.put_line('ip_upc_no       = '||ip_upc_no);
    dbms_output.put_line('ip_incident_id  = '||ip_incident_id);
    dbms_output.put_line('ip_login_name   = '||ip_login_name);
    dbms_output.put_line('ip_notes        = '||ip_notes);
    dbms_output.put_line('op_err_no       = '||op_err_no);
    dbms_output.put_line('op_err_msg      = '||op_err_msg);
    op_err_msg := 'Success';

    if ip_notes is null then
      op_err_msg := 'Failed - Notes Missing';
      return;
    end if;

--  SELECT to_char(SYSDATE,'MMDDYYYY') this_date,
--         to_char(SYSDATE,'HH24MISS') this_time
--  into IP_DATE,IP_TIME
--  FROM DUAL;

    sa.posa_lite.posa_transaction_controller (ip_sourcesystem => 'BHN', -- PER VIVEK ON 8/11 CHANGE TO BHN FROM TAS
	                                          ip_action_type => 'A',
	                                          ip_serial_no => v_snp_prefix||ip_snp,
	                                          ip_date => ip_date,
	                                          ip_time => ip_time,
	                                          ip_trans_id => null,
	                                          ip_trans_type => null,
	                                          ip_merchant_id => null,
	                                          ip_store_detail => null,
	                                          ip_access_code => null,
	                                          ip_auth_code => null,
	                                          ip_reg_no => null,
	                                          ip_upc => ip_upc_no,
	                                          op_out_units => op_out_units,
	                                          op_out_code => op_err_no,
	                                          op_bhn_code => op_bhn_code,
                                            i_incident_id => ip_incident_id,
                                            o_response => op_err_msg);

    dbms_output.put_line('op_out_units = '||op_out_units);
    dbms_output.put_line('op_bhn_code = '||op_bhn_code);

    if instr(op_err_msg,'INVALID')>0 then
      op_err_msg := 'Failed - Error No ('||op_err_no||') BHN Code ('||op_bhn_code||') Msg - '||op_err_msg;
    else
    op_err_msg := adfcrm_scripts.get_generic_script (
                                                     ip_script_type => 'POSA',
                                                     ip_script_id => '5003',
                                                     ip_language => 'ENGLISH',
                                                     ip_sourcesystem => 'TAS'
                                                     );
    end if;

    toppapp.sp_tu_log (ip_agent        => ip_login_name
                      ,ip_action       => '511' -- NEEDS AN ENTRY FOR THIS (SELECT * from toppapp.x_tu_actions x where "Action_Id" = ip_action_id)
                      ,ip_esn          => ''
                      ,ip_min          => ''
                      ,ip_smp          => ip_snp
                      ,ip_reason       => 'snp_prefix:'||ip_snp_prefix||' - snp:'||ip_snp||' - upc:'||ip_upc_no||' - units:'||op_out_units||' - errno:'||op_err_no||' - bhn_code:'||op_bhn_code||' - agent_notes:'||ip_notes
                      ,ip_storeid      => ''
                      ,op_result       => v_dummy
                      ,op_msg          => v_dummy
                      );

  exception
    when others then
      op_err_msg := 'Failed - '||sqlerrm;
  end tas_denom;
--------------------------------------------------------------------------------
  procedure tas_denom (ip_snp_prefix varchar2,
                       ip_snp varchar2,
                       ip_upc_no varchar2,
                       ip_incident_id varchar2,
                       ip_login_name varchar2,
                       ip_notes varchar2, -- LONG COLUMN
                       ip_confirm varchar2,
                       op_action out varchar2,
                       op_err_no out varchar2,
                       op_err_msg out varchar2)
  is
  begin
    if ip_confirm = 'N' then
      for i in (
                select description
                from table_part_num
                where 1=1
                and s_domain = 'REDEMPTION CARDS'
--                and x_sourcesystem = 'REDEMPTION CARD' -- ADDRESSING DEFECT #30631
                and x_upc = ip_upc_no
                )
      loop
        op_err_no := '0';
        op_action := 'Y';
        op_err_msg := 'Are you sure you want to apply ('||i.description||') ?';
      end loop;
      if op_action is null then
        op_action := 'N';
        op_err_no := '-20000';
        op_err_msg := 'UPC Provided not found.';
      end if;
    else
      tas_denom (ip_snp_prefix => ip_snp_prefix,
                 ip_snp => ip_snp,
                 ip_upc_no => ip_upc_no,
                 ip_incident_id => ip_incident_id,
                 ip_login_name => ip_login_name,
                 ip_notes => ip_notes,
                 op_err_no => op_err_no,
                 op_err_msg => op_err_msg);
    end if;
  end tas_denom;
--------------------------------------------------------------------------------
end;
/