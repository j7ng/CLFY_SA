CREATE OR REPLACE TRIGGER sa."SITE_PART_TRIGGER"
AFTER INSERT OR UPDATE OF PART_STATUS
ON sa.TABLE_SITE_PART REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 WHEN (
UPPER(new.instance_name) <> 'ROADSIDE'
      ) declare
    /******************************************************************************
    * Name: SITE_PART_TRIGGER
    *
    * History
    * Version             Date             Who            Description
    * ============        ============     ============== ==========================
    * 1.0                                                 Initial Version
    * 1.1                 04/10/03         SL             Clarify Upgrade - sequence
    ********************************************************************************/
  cursor get_site is
    select s.site_id
      from table_site s
     where s.objid = :new.site_part2site;
  site_rec get_site%rowtype;
  cursor get_dealer is
    select ib.bin_name site_id
      from
           table_inv_bin ib,
           table_part_inst pi
     where 1=1
                  and ib.objid               = pi.part_inst2inv_bin
                  and pi.x_domain            = 'PHONES'
                  and pi.part_serial_no      = :new.x_service_id
                  and rownum = 1;
  dealer_rec get_dealer%rowtype;
  cursor get_carrier_group is
    select c.x_carrier_id
      from table_x_carrier c,
           table_part_inst pi
     where c.objid           = pi.part_inst2carrier_mkt
                  and pi.x_domain       = 'LINES'
                  and pi.part_serial_no = :new.x_min
                  and rownum = 1;
  carrier_group_rec get_carrier_group%rowtype;
  cursor get_part_num is
    select pn.x_manufacturer
      from table_part_num pn,
           table_mod_level ml
     where pn.objid = ml.part_info2part_num
       and ml.objid = :new.site_part2part_info;
  part_num_rec get_part_num%rowtype;
  cursor get_contact is
    select c.last_name||', '||c.first_name name
      from table_contact      c,
           table_contact_role cr
     where c.objid  = cr.contact_role2contact
       and cr.contact_role2site = :new.site_part2site
       and rownum = 1;
  contact_rec get_contact%rowtype;
  insert_or_update varchar2(1);
BEGIN
  if inserting then
    insert_or_update := 'I';
  else
    insert_or_update := 'U';
  end if;
  if :new.part_status in ('Active','Inactive') and
     :new.part_status != :old.part_status then
    open get_carrier_group;
      fetch get_carrier_group into carrier_group_rec;
    close get_carrier_group;
    sp_activation(insert_or_update,
                  :new.part_status,
                  :new.x_min,
                  :new.x_service_id,
                  site_rec.site_id,
                  carrier_group_rec.x_carrier_id,
                  dealer_rec.site_id,
                  :new.x_notify_carrier,
                  :new.x_deact_reason,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  0,
                  NULL,
                  NULL,
                  :new.x_pin,
                  part_num_rec.x_manufacturer,
                  :new.install_date,
                 contact_rec.name);
  end if;
  END;  -- end of x_call_trans_trigger
/