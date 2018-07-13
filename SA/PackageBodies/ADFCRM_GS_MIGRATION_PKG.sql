CREATE OR REPLACE package body sa.adfcrm_gs_migration_pkg
is
  --------------------------------------------------------------------------------------------
  procedure do(i_one varchar2)
  is
  begin
    dbms_output.put_line(i_one);
  end do;
  --------------------------------------------------------------------------------------------
  function pin_quick_check(ip_pin varchar2)
  return varchar2
  is
    msg varchar2(30) := 'CARD_NOT_FOUND';
  begin

    for i in (select decode(TRANSACTION_STATUS,
                      'FAILED',TRANSACTION_STATUS,
                      'SUCCESS',TRANSACTION_STATUS,
                      '','CONTINUE',
                      'ERROR') TRANSACTION_STATUS
              from TMOMIG.X_GSM_MIG_BUCKETS
              where pin = ip_pin)
    loop
      if i.TRANSACTION_STATUS is null then
        msg := 'CONTINUE';
      else
        msg := i.TRANSACTION_STATUS;
      end if;
    end loop;
    return msg;
  exception
    when others then
      return msg;
  end pin_quick_check;
  --------------------------------------------------------------------------------------------
  procedure migration_qualifier(ip_esn varchar2,ip_min varchar2,ip_pin varchar2,op_tas_msg out varchar2, op_ORG_EXPIRE_DATE out date, op_new_expire_date out date, op_days_extended out varchar2, op_additional_data out number, op_card_count out number, op_card_part_number out varchar2, OP_ENABLE_BUTTON out varchar2)
  is
    v_script_id varchar2(10);
  begin
    OP_ENABLE_BUTTON := 'false';
    get_migration_script_rec := null;
    get_migration_info_rec := null;

    if ip_pin is null then
      op_tas_msg := ' There is no cash balance to convert.';
      v_script_id := '2099';
      do('SEARCH BY MIN');
      open get_migration_info_by_min(ip_esn => ip_esn,ip_min => ip_min);
      loop
      fetch get_migration_info_by_min into get_migration_info_rec;
      exit when get_migration_info_by_min%notfound;
      end loop;
      close get_migration_info_by_min;
    else
      op_tas_msg := ' Pin entered does not exist in inventory.';
      v_script_id := '2199';
      do('SEARCH BY PIN');
      open get_migration_info_by_pin(ip_esn => ip_esn, ip_min => ip_min, ip_pin => ip_pin);
      loop
      fetch get_migration_info_by_pin into get_migration_info_rec;
      exit when get_migration_info_by_pin%notfound;
      end loop;
      close get_migration_info_by_pin;

      if get_migration_info_rec.min is null then
        update TMOMIG.X_GSM_MIG_BUCKETS
        set min = ip_min
        where pin = ip_pin;
      end if;

    end if;

    if get_migration_info_rec.service_days >0 then
      op_days_extended := 'Y';
    else
      op_days_extended := 'N';
    end if;

    if (get_migration_info_rec.min is not null and get_migration_info_rec.transaction_status is null) or
       (get_migration_info_rec.pin is not null and get_migration_info_rec.transaction_status is null)
    then
      OP_ENABLE_BUTTON := 'true';
    end if;

    if get_migration_info_rec.transaction_status = 'SUCCESS' then
      if ip_pin is null then
        v_script_id := '2100';
      else
        v_script_id := '2200';
      end if;
    end if;

    if get_migration_info_rec.transaction_status = 'FAILURE' then
      if ip_pin is null then
        v_script_id := '2101';
      else
        v_script_id := '2201';
      end if;
    end if;

    if get_migration_info_rec.transaction_status not in ('SUCCESS','FAILURE') and get_migration_info_rec.transaction_status is not null then
      if ip_pin is null then
        v_script_id := '2102';
        op_tas_msg := ' Cash balance had been processed with an unknown result.';
      else
        v_script_id := '2202';
        op_tas_msg := ' Pin redemption had been processed with an unknown result.';
      end if;
      return;
    end if;

    if OP_ENABLE_BUTTON = 'true' then
      for i in (select count(*) cnt
                from table_part_inst
                where part_serial_no = ip_esn
                and x_part_inst_status = '52')
      loop
          if i.cnt = 1 then
            OP_ENABLE_BUTTON := 'true';
          else
          if v_script_id = '2099' then --CHANGE TO A CASH CARD BALANCE SCRIPT
            v_script_id := '2103';
          end if;
          if v_script_id = '2199' then -- NON MIGRADED GOSMART PIN
            v_script_id := '2203';
          end if;
          do('PHONE IS NOT ACTIVE SCRIPT');
          open get_migration_info_by_pin(ip_esn => ip_esn, ip_min => ip_min, ip_pin => ip_pin);
          loop
          fetch get_migration_info_by_pin into get_migration_info_rec;
          exit when get_migration_info_by_pin%notfound;
          end loop;
          close get_migration_info_by_pin;

          OP_ENABLE_BUTTON := 'false';
        end if;
      end loop;
    end if;

    op_org_EXPIRE_DATE := get_migration_info_rec.expire_date;
    op_new_expire_date := get_migration_info_rec.new_expire_date;
    op_additional_data := get_migration_info_rec.additional_data;
    op_card_count := get_migration_info_rec.cards;
    op_card_part_number := get_migration_info_rec.new_card_pn;

    if get_migration_info_rec.account_balance is not null or ip_pin is not null then
      open get_migration_script(ip_script_id => v_script_id,
                                ip_cash_blance_val => '($'||get_migration_info_rec.account_balance||')',
                                ip_service_end_date_val => '('||get_migration_info_rec.expire_date||')',
                                ip_days_offer_val => '('||get_migration_info_rec.service_days||')',
                                ip_new_service_end_date => '('||get_migration_info_rec.new_expire_date||')',
                                ip_data_offer_val => '('||get_migration_info_rec.additional_data||')',
                                ip_pins_offer_val => '('||get_migration_info_rec.cards||')',
                                ip_org_service_end_date => '('||get_migration_info_rec.original_site_part_expiry_date||')');
      loop
      fetch get_migration_script into get_migration_script_rec;
      exit when get_migration_script%notfound;
      end loop;
      close get_migration_script;
      op_tas_msg := get_migration_script_rec.st;
    end if;

    if op_tas_msg is null then
      op_tas_msg := 'SCRIPT MISSING BAL_'||v_script_id;
    end if;

  exception
    when others then
      op_tas_msg := 'Error while looking up the migration qualifier'||SQLERRM;
      OP_ENABLE_BUTTON := 'false';
  end migration_qualifier;
  --------------------------------------------------------------------------------------------
  procedure process_cash_balance (ip_esn varchar2,
                                  ip_min varchar2,
                                  ip_org_expire_date varchar2, -- new
                                  ip_new_expire_date varchar2, -- was date
                                  ip_days_extended varchar2, -- new
                                  ip_data_bucket_vals varchar2, -- was number
                                  ip_card_count varchar2, -- was number
                                  ip_card_part_number varchar2,
                                  op_out_num out varchar2, -- was number
                                  op_out_msg out varchar2)
  is
    n_card_count number := to_number(ip_card_count);
  begin

    do(' PROC IN VALUES');
    do(' org_expire_date    => '||ip_org_expire_date);
    do(' new_expire_date    => '||ip_new_expire_date);
    do(' additional_data    => '||ip_data_bucket_vals);
    do(' total cards        => '||ip_card_count);
    do(' v_card_part_number => '||ip_card_part_number);
    do('');
    do('CALL THE CREATE CASH BALANCE TRANS...');
    do('');

    do('VALUES INITIALIZED IN PROC');

    if ip_esn is not null and
       ip_min is not null and
       ip_new_expire_date is not null then
       op_out_num := 0;
       op_out_msg:= 'Sucess!';

        update TMOMIG.X_GSM_MIG_BUCKETS
        set original_site_part_expiry_date = to_date(ip_org_expire_date,'DD-MON-YY')
        where min = ip_min;

        sa.migration_pkg.create_cash_balance_trans(i_esn                           => ip_esn,                          -- REQUIRED
                                                   i_min                           => ip_min,                          -- REQUIRED -- ATLEAST ONE OF THESE (ESN/MIN) SHOULD ALWAYS BE PASSED
                                                   i_source_system                 => 'TAS',                           -- REQUIRED  -- SOURCE SYSTEM  FOR THIS TRANSACTION, MANDATORY PARAMETER
                                                   i_extend_service_days           => ip_days_extended,                -- Y or N
                                                   i_intl_bucket_value             => '0',                             -- REQUIRED  -- INTL BUCKET VALUE -- NO COLUMN IN THE TABLE FOR THIS
                                                   i_intl_bucket_expiration_date   => to_date(ip_new_expire_date,'DD-MON-YY'),              -- REQUIRED  -- MANDATORY IF ILD_BUCKET VLAUE IS PASSED
                                                   i_data_bucket_value             => ip_data_bucket_vals,             -- REQUIRED -- DATA BUCKET VALUE. ONE OF ILD OR DATA BUCKET MUST BE PASSED
                                                   i_data_bucket_expiration_date   => to_date(ip_new_expire_date,'DD-MON-YY'),              -- REQUIRED -- MANDATORY IF DATA_BUCKET VLAUE IS PASSED
                                                   o_err_num                       => op_out_num,                      -- ERROR NUMBER. WILL BE SENT AS "0" FOR SUCCESS
                                                   o_err_msg                       => op_out_msg                       -- ERROR MESSGAE. WILL BE SENT AS "SUCCESS" FOR SUCCESSFUL PROCESSING
                                                   );
    end if;
  exception
    when others then
      do('SQLERRM-'||sqlerrm);
  end process_cash_balance;
  --------------------------------------------------------------------------------------------
  function get_contact_objid(ip_esn varchar2)
  return varchar2
  is
    pi2c number;
    c_obj number;
    c_obj_2 number;
    c_obj_3 number;

    cursor cobjid1
    is
    select  objid
    from    table_contact
    where   objid = pi2c;
    c_objid_rec   cobjid1%ROWTYPE;

    cursor cobjid2
    is
    select pi.x_part_inst2contact  contact_objid
    from   table_web_user wu,
           table_contact con,
           table_x_contact_add_info ai,
           table_part_inst pi,
           table_x_contact_part_inst cpi
    where  pi.objid = cpi.x_contact_part_inst2part_inst
    and    cpi.x_contact_part_inst2contact = con.objid
    and    con.objid = ai.add_info2contact
    and    con.objid= wu.web_user2contact
    and    pi.x_part_inst2contact = c_obj;


    cursor cobjid3
    is
    select con.objid contact_objid
    from   table_web_user wu,
           table_contact con,
           table_x_contact_add_info ai
    where  con.objid = ai.add_info2contact
    and    con.objid= wu.web_user2contact
    and    con.objid= c_obj;

  begin
    SELECT x_part_inst2contact
    into pi2c
    FROM TABLE_PART_INST
    WHERE PART_SERIAL_NO = ip_esn;

    -- IF THIS IS NOT NULL THEN USE THIS
    --adfcrm_gs_migration_pkg.do('CHECK AGAINST CONTACT TAB');
    open cobjid1;
    loop
    fetch cobjid1 into pi2c;
    exit when cobjid1%NOTFOUND;
    end loop;
    close cobjid1;

    -- IF THIS IS HAS A VALUE, THEN USE THIS
    --adfcrm_gs_migration_pkg.do('CHECK AGAINST X_CONTACT_PART_INST TAB');
    open cobjid2;
    loop
    fetch cobjid2 into pi2c;
    exit when cobjid2%NOTFOUND;
    end loop;
    close cobjid2;
    -- IF THIS IS HAS A VALUE, THEN USE THIS
    --adfcrm_gs_migration_pkg.do('CHECK WITHOUT X_CONTACT_PART_INST TAB');
    open cobjid3;
    loop
    fetch cobjid3 into pi2c;
    exit when cobjid3%NOTFOUND;
    end loop;
    close cobjid3;

    return pi2c;
  exception
    when others then
      null;
  end get_contact_objid;
  --------------------------------------------------------------------------------------------
end adfcrm_gs_migration_pkg;
/