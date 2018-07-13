CREATE OR REPLACE PROCEDURE sa."UNTHROTTLE_SUBSCRIBER" (i_div    IN  NUMBER DEFAULT 1,
                                                   i_rem    IN  NUMBER DEFAULT 0,
                                                   i_source IN  VARCHAR2         )
IS

  -- get throttled esns
  cursor get_throttled_esns (p_interval number)
  is
  select ROWID, tt.*
  from   w3ci.x_stg_ttoff_transactions tt
  where  insert_timestamp < sysdate -  numtodsinterval(p_interval, 'SECOND')
  and    mod(objid, i_div) = i_rem
  and    throttle_source_system = i_source
  order by objid;

  --get the members in the group to  unthrottle
  cursor group_id_curs ( c_account_group_id in number ) is
  select agm.esn,
         agm.master_flag,
         ( select pi_min.part_serial_no
           from   table_part_inst pi_esn,
                  table_part_inst pi_min
           where  pi_esn.part_serial_no = agm.esn
           and    pi_esn.x_domain = 'PHONES'
           and    pi_min.part_to_esn2part_inst = pi_esn.objid
           and    pi_min.x_domain = 'LINES'
           and    rownum = 1 ) min
  from   sa.x_account_group_member agm
  where  1 = 1
  and    agm.account_group_id = c_account_group_id
  and    upper(agm.status) = 'ACTIVE';

  l_interval NUMBER;
  c_error_code NUMBER;
  c_error_message VARCHAR2(1000);
  n_throttle_priority number;

BEGIN --Main Section

  -- get the interval time to unthrottle
	begin
	  select x_param_value
	  into   l_interval
	  from   sa.table_x_parameters
	  where  x_param_name = 'TTOFF_INTERVAL';
	exception
	   when others then
    	 l_interval  := 10; --seconds
	end;

  -- get the throttled esns to unthrottle
  FOR rec_throttled_esn IN get_throttled_esns (l_interval)
	LOOP
    --
    BEGIN
        n_throttle_priority := w3ci.throttling.get_transaction_priority ( i_throttle_transaction_type => 'TTOFF'           ,
                                                                          i_throttle_source           => rec_throttled_esn.throttle_source_system ,
                                                                          i_sourcesystem              => NULL );
    EXCEPTION
        when others then
          n_throttle_priority := 1;
    END;

    -- Non group plans
    if rec_throttled_esn.shared_group_flag  = 'N' THEN
      --
      c_error_code    := 0;
      c_error_message := NULL;

      begin
        w3ci.throttling.sp_expire_cache ( p_min           => rec_throttled_esn.min ,
                                          p_esn           => rec_throttled_esn.esn ,
                                          p_error_code    => c_error_code         ,
                                          p_error_message => c_error_message      ,
                                          p_bypass_off    => NULL                 ,
                                          p_source        => rec_throttled_esn.throttle_source_system    ,
                                          i_priority      => n_throttle_priority  );
      exception when others then
        c_error_message := SQLERRM;
        c_error_code    := 1;
        sa.ota_util_pkg.err_log ( p_action       => 'w3ci.throttling.sp_expire_cache',
                                  p_error_date   => SYSDATE ,
                                  p_key          => rec_throttled_esn.esn ,
                                  p_program_name => rec_throttled_esn.throttle_source_system,
                                  p_error_text   => c_error_message);
      end;

    else  -- shared group plans
      IF rec_throttled_esn.account_group_id is NULL THEN
        BEGIN
          SELECT account_group_id
          INTO   rec_throttled_esn.account_group_id
          FROM   x_account_group_member
          WHERE  UPPER(status) <> 'EXPIRED'
          AND    esn = rec_throttled_esn.esn;
        EXCEPTION
         WHEN OTHERS THEN
           c_error_code := 1;
           c_error_message := 'unthrottle_subscriber:  Group info not found';
           util_pkg.insert_error_tab ( i_action       => 'ACCT GROUPID VALIDATION ',
                                       i_key          => rec_throttled_esn.esn,
                                       i_program_name => 'unthrottle_subscriber',
                                       i_error_text   => c_error_message );
          --CONTINUE;
        END;
      END IF;

      FOR group_rec in group_id_curs (rec_throttled_esn.account_group_id) LOOP
      --
          c_error_code    := 0;
          c_error_message := NULL;
          -- unthrottle subscriber
          begin
            w3ci.throttling.sp_expire_cache ( p_min           => group_rec.min    ,
                                              p_esn           => group_rec.esn    ,
                                              p_error_code    => c_error_code        ,
                                              p_error_message => c_error_message     ,
                                              p_bypass_off    => NULL                ,
                                              p_source        => rec_throttled_esn.throttle_source_system ,
                                              i_priority      => n_throttle_priority );
          exception when others then
            c_error_message := SQLERRM;
            c_error_code    := 1;
            sa.ota_util_pkg.err_log ( p_action       => 'w3ci.throttling.sp_expire_cache group plans',
                                      p_error_date   => SYSDATE ,
                                      p_key          => group_rec.esn ,
                                      p_program_name => rec_throttled_esn.throttle_source_system ,
                                      p_error_text   => c_error_message);
          end;

      END LOOP;

    end if;

   begin
     -- archive the stg table to history table
     insert into w3ci.x_ttoff_transactions_hist
                 (objid                 ,
                  esn                   ,
                  min                   ,
                  throttle_source_system,
                  insert_timestamp      ,
                  update_timestamp      ,
                  ttoff_flag            ,
                  shared_group_flag     ,
                  account_group_id      ,
                  status
                 )
         values  (w3ci.seq_x_ttoff_transactions_hist.nextval,
                  rec_throttled_esn.esn,
                  rec_throttled_esn.min,
                  rec_throttled_esn.throttle_source_system,
                  rec_throttled_esn.insert_timestamp,
                  SYSDATE,
                  CASE WHEN c_error_code = 0 THEN 'Y' ELSE 'N' END,
                  rec_throttled_esn.SHARED_GROUP_FLAG,
                  rec_throttled_esn.ACCOUNT_GROUP_ID,
                  CASE WHEN c_error_code = 0 THEN 'SUCCESS' ELSE 'FAILED' END

                 );

      -- remove the data from stg table
     DELETE FROM w3ci.x_stg_ttoff_transactions where rowid = rec_throttled_esn.rowid;

     commit;
   exception
    when others then
      null;
   end;

	END LOOP;
   commit;
EXCEPTION
   WHEN OTHERS THEN
    c_error_code := 1;
    c_error_message := 'unthrottle_subscriber:  '||substr(sqlerrm,1,400);
    util_pkg.insert_error_tab ( i_action       => 'Exception ',
                                i_key          => NULL,
                                i_program_name => 'unthrottle_subscriber',
                                i_error_text   => c_error_message );
END unthrottle_subscriber;
/