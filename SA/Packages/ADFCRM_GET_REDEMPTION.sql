CREATE OR REPLACE PACKAGE sa."ADFCRM_GET_REDEMPTION"
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_GET_REDEMPTION_PKG.sql,v $
--$Revision: 1.6 $
--$Author: hcampano $
--$Date: 2017/08/30 22:17:40 $
--$ $Log: ADFCRM_GET_REDEMPTION_PKG.sql,v $
--$ Revision 1.6  2017/08/30 22:17:40  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.5  2017/08/30 18:41:04  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.4  2015/08/24 21:49:26  mmunoz
--$ CR36725 added red card status
--$
--$ Revision 1.3  2014/07/18 20:16:24  mmunoz
--$ added red_amount in type esnRedemption_rec
--$
--$ Revision 1.2  2014/05/29 15:39:38  mmunoz
--$ Added language in get_summary
--$
--$ Revision 1.1  2014/04/30 21:34:03  mmunoz
--$ CR17975
--$
--------------------------------------------------------------------------------------------

  type esnRedemption_rec is record
  (red_esn           varchar2(400),
   red_parent        varchar2(400),
   red_group         varchar2(400),
   red_trans_id      varchar2(400),
   red_trans_date    date,
   red_trans_units   varchar2(400),
   red_type          varchar2(400),
   red_card          varchar2(400),
   red_part_class    varchar2(400),
   red_part_number   varchar2(400),
   red_units         varchar2(400),
   red_sms           varchar2(400),
   red_data          varchar2(400),
   red_days          varchar2(400),
   red_service_plan  varchar2(400),
   red_promo_desc    varchar2(4000),
   red_promo_units   varchar2(400),
   red_promo_type    varchar2(400),
   red_prog_name     varchar2(400),
   red_prog_class    varchar2(400),
   red_sweep_and_add_flag   varchar2(400),
   red_prog_units    varchar2(400),
   red_vas           varchar2(400),
   red_amount        number,
   red_card_status   varchar2(400)
  );

  type esnredemption_tab is table of esnredemption_rec;

  type red_card_record is record
  (esn            sa.table_part_inst.part_serial_no%type,
   call_trans_id  sa.table_x_call_trans.objid%type,
   transact_date  date,
   x_red_code     sa.table_part_inst.x_red_code%type,
   pc_objid       sa.table_part_class.objid%type,
   part_class     sa.table_part_class.name%type,
   part_number    sa.table_part_num.part_number%type,
   x_redeem_units sa.table_part_num.x_redeem_units%type,
   x_redeem_days  sa.table_part_num.x_redeem_days%type,
   x_card_type    sa.table_part_num.x_card_type%type,
   x_red_code_status     sa.table_part_inst.x_part_inst_status%type
   );

  function get_redeem_calc_date (ip_esn varchar2
                                 ,ip_date date)
  ------------------------------------------------------------------
  --  Get the latest date between the input date, initial activation
  --  date and latest clear time tank record (CR17975)
  return date;

  function get_summary(
    ip_esn in varchar2,
    ip_date in date,
    p_language in varchar2
  )
  RETURN esnRedemption_tab pipelined;

  function is_multi_denom(ip_snp varchar2)
  return varchar2;

END ADFCRM_GET_REDEMPTION;
/