CREATE OR REPLACE PACKAGE sa."ADFCRM_COMMHISTORY_PKG" AS

  type get_commhist_rec is record
      (change_date table_x_cai_log.change_date%type,
      add_info2contact  table_x_cai_log.add_info2contact%type,
      new_sms_Val table_x_cai_log.new_sms_Val%type,
      new_mail_Val table_x_cai_log.new_mail_Val%type,
      new_ph_Val table_x_cai_log.new_ph_Val%type,
      new_em_Val table_x_cai_log.new_em_Val%type,

      login_name varchar2(250),
      x_min table_x_cai_log.x_min%type,
      SOURCE_SYSTEM table_x_cai_log.SOURCE_SYSTEM%type

  );

  type get_commhist_rec_tab is table of get_commhist_rec;

  function get_smshistory_func(
    ip_contact_objid in number,
    ip_date in varchar2)
  return get_commhist_rec_tab pipelined;

  function get_mailhistory_func(
    ip_contact_objid in number,
    ip_date in varchar2)
  return get_commhist_rec_tab pipelined;

    function get_phonehistory_func(
    ip_contact_objid in number,
    ip_date in varchar2)
  return get_commhist_rec_tab pipelined;

    function get_emailhistory_func(
    ip_contact_objid in number,
    ip_date in varchar2)
  return get_commhist_rec_tab pipelined;

END ADFCRM_COMMHISTORY_PKG;
/