CREATE OR REPLACE package sa.adfcrm_gs_migration_pkg
is
  --------------------------------------------------------------------------------------------
  cursor get_migration_script(ip_script_id varchar2, ip_cash_blance_val varchar2,ip_service_end_date_val varchar2, ip_days_offer_val varchar2, ip_new_service_end_date varchar2, ip_data_offer_val varchar2, ip_pins_offer_val varchar2, ip_org_service_end_date varchar2)
  is
  select replace(
          replace(
           replace(
             replace(
               replace(
                 replace(
                   replace(x_script_text,'[cash_balance]',ip_cash_blance_val),
                                           '[Service_end_date]',ip_service_end_date_val),
                                             '[days_offer]',ip_days_offer_val),
                                               '[new_service_end_date]',ip_new_service_end_date),
                                                 '[data_offer]',ip_data_offer_val),
                                                  '[pins_offer]',ip_pins_offer_val),
                                                  '[org_service_end_date]',ip_org_service_end_date) st
  from table_x_scripts
  where x_script_id = ip_script_id
  and x_script_type = 'BAL'
  and script2bus_org = 536876746; --GENERIC
  get_migration_script_rec get_migration_script%rowtype;
  --------------------------------------------------------------------------------------------
  cursor get_migration_info_by_min(ip_esn varchar2,ip_min varchar2)
  is
  select to_date(expire_date)+to_number(nvl(service_days,0))new_expire_date,expire_date,service_days,pin,min,account_balance,additional_data,cards,new_card_pn,transaction_status,original_site_part_expiry_date
  from   (
          select max(x_expire_dt) expire_date
          from table_site_part
          where x_service_id = ip_esn
          and x_min = ip_min
          and part_status in ('Active','Inactive','CarrierPending','NotMigrated')
          ) a,
          (
          select pin,min,plan_name,account_balance,additional_data,service_days,cards,ica_balance,ild_usage_in_nov,new_plan,insert_timestamp, new_card_pn,transaction_status,original_site_part_expiry_date
          from TMOMIG.X_GSM_MIG_BUCKETS
          where min = ip_min
          and pin is null
          and rownum <2 -- safeguard in case there are dups in the data
          )b;

  --------------------------------------------------------------------------------------------
  cursor get_migration_info_by_pin(ip_esn varchar2,ip_min varchar2,ip_pin varchar2)
  is
  select to_date(expire_date)+to_number(nvl(service_days,0))new_expire_date,expire_date,service_days,pin,min,account_balance,additional_data,cards,new_card_pn,transaction_status,original_site_part_expiry_date
  from   (
          select max(x_expire_dt) expire_date
          from table_site_part
          where x_service_id = ip_esn --'260642101827215'--
          and x_min = ip_min --'3059587421'--
          and part_status in ('Active','Inactive','CarrierPending','NotMigrated')
          ) a,
          (
          select pin,min,plan_name,account_balance,additional_data,service_days,cards,ica_balance,ild_usage_in_nov,new_plan,insert_timestamp, new_card_pn,transaction_status,original_site_part_expiry_date
          from TMOMIG.X_GSM_MIG_BUCKETS
          where pin = ip_pin --'1234123412'--
          and rownum <2 -- safeguard in case there are dups in the data
          )b;

  get_migration_info_rec get_migration_info_by_pin%rowtype;
  --------------------------------------------------------------------------------------------
  procedure do(i_one varchar2); -- dbmsoutput.put_line
  --------------------------------------------------------------------------------------------
  function pin_quick_check(ip_pin varchar2) return varchar2;
  --------------------------------------------------------------------------------------------
  procedure migration_qualifier(ip_esn varchar2,ip_min varchar2,ip_pin varchar2,op_tas_msg out varchar2, op_ORG_EXPIRE_DATE out date, op_new_expire_date out date, op_days_extended out varchar2, op_additional_data out number, op_card_count out number, op_card_part_number out varchar2, OP_ENABLE_BUTTON out varchar2);
  --------------------------------------------------------------------------------------------
  procedure process_cash_balance (ip_esn varchar2, -- OVERLOAD
                                  ip_min varchar2,
                                  ip_org_expire_date varchar2, -- new
                                  ip_new_expire_date varchar2, -- was date
                                  ip_days_extended varchar2, -- new
                                  ip_data_bucket_vals varchar2, -- was number
                                  ip_card_count varchar2, -- was number
                                  ip_card_part_number varchar2,
                                  op_out_num out varchar2, -- was number
                                  op_out_msg out varchar2);
  --------------------------------------------------------------------------------------------
  function get_contact_objid(ip_esn varchar2)
  return varchar2;
  --------------------------------------------------------------------------------------------
end adfcrm_gs_migration_pkg;
/