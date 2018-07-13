CREATE OR REPLACE PROCEDURE sa."TAS_UNTHROTTLE_PRC" ( p_esn            in out VARCHAR2   ,
                                                  p_min            in out VARCHAR2   ,
                                                  p_user           in VARCHAR2       ,
                                                  p_msg_out        out varchar2      ,
                                                  p_error_code_out out number        ,
                                                  p_debug          in boolean default false)  is

	v_cnt      number := 0;
	v_brand    varchar2(40);
  l_result   varchar2(40) := 'UnSuccessful';
	v_objid    number;
  l_program_name varchar2(40) := 'APEX_FIX_ERRORS.UNTHROTTLE';
  c sa.customer_type := sa.customer_type();

--to log in interact table
procedure create_unthrottle_interact (esn      in varchar2,
                                      p_user   in varchar2,
                                      p_result in varchar2) is
  pragma autonomous_transaction;
  --
  cursor c_phone is
     select part_serial_no, nvl(x_part_inst2contact,0)contact
       from table_part_inst
      where part_serial_no = esn;
  c_esn c_phone%rowtype;
  --
  v_interact_id number;
  v_objid       number;
  v_message     varchar2(2000);
  v_user_objid  number;

 BEGIN
	--
	if c_phone%isopen then
	  close c_phone;
	end if;
	--
	open c_phone;
	fetch c_phone into c_esn;
	--
	if c_esn.contact > 0 then
		--
		select objid
    into   v_user_objid
    from   table_user
		where  s_login_name = upper(p_user);
		--
		v_objid   := sa.seq ( 'INTERACT' );
		v_message := esn ||' Data Unthrottle tool ' || p_result || ' Transaction';
		--
		select sa.sequ_interaction_id.nextval
    into   v_interact_id
    from   dual;
		--
		-- table_interact
		INSERT
		INTO sa.table_interact
             (objid,
              interact_id,
              create_date,
              inserted_by,
              direction,
              reason_1,
              s_reason_1,
              reason_2,
              s_reason_2,
              result,
              done_in_one,
              fee_based,
              wait_time,
              system_time,
              entered_time,
              pay_option,
              start_date,
              end_date,
              arch_ind,
              agent,
              s_agent,
              interact2user,
              interact2contact,
              x_service_type,
              serial_no )
		VALUES (
	           v_objid,
             v_interact_id,
             sysdate,
             upper(p_user),
             'Inbound',
             'Incorrect Throttle',
             'INCORRECT THROTTLE',
             'Unthrottle Customer',
             'UNTHROTTLE CUSTOMER',
             p_result,
             0,
             0,
             0,
             0,
             0,
             'None',
             sysdate,
             '31-Dec-2055',
             0,
             upper(p_user),
             upper(p_user),
             v_user_objid,
             c_esn.contact,
             'Wireless',
             esn );

		-- table_interact
		insert
        into sa.table_interact_txt
              (objid,
               notes,
               interact_txt2interact )
	    values (sa.seq ( 'INTERACT_TXT' ),
               v_message,
               v_objid );

		commit;
	end if;
    --
	close c_phone;
exception
  when others then
  rollback;
END create_unthrottle_interact;

--to log in error table
procedure write_error(p_error_text   in varchar2,
                      p_action       in varchar2,
                      p_key          in varchar2,
                      p_program_name in varchar2) is
 --
 pragma autonomous_transaction;

 BEGIN
	insert
    into error_table
        (error_text,
         error_date,
         action,
         key,
         program_name
        )
	values
       (p_error_text,
        sysdate,
        p_action,
        p_key,
        p_program_name);

	commit;

 EXCEPTION
   when others then
   rollback;
END write_error;

--
BEGIN

  --get the esn by min
  p_esn := c.get_esn (i_min => p_min);

  --
	IF p_esn is null and p_min is null then
    	p_msg_out := 'NO ESN OR MIN';
    	p_error_code_out  := -5;
      RETURN;
	END IF;

	-- getting brand for the esn
	BEGIN
		select bo.s_org_id
		into   v_brand
		from   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_bus_org bo
		where  1 = 1
		and    pi.n_part_inst2part_mod = ml.objid
		and    ml.part_info2part_num   = pn.objid
		and    pn.part_num2bus_org     = bo.objid
		and    pi.part_serial_no       = p_esn;
	EXCEPTION
	  WHEN OTHERS THEN
		--
		p_msg_out        := 'FAILED TO GET BRAND';
		p_error_code_out := -2;

		--logging error table
		write_error( p_error_text   => 'unthrottle('|| p_esn || ','|| p_min || ','|| p_user || ','|| p_msg_out || ','|| p_error_code_out || ','||')',
                 p_action       => p_msg_out,
                 p_key          => COALESCE(p_min,p_esn,'NO MIN OR ESN'),
                 p_program_name => l_program_name );

		--logging interact table
		create_unthrottle_interact(	esn      => p_esn,
                                p_user   => p_user,
                                p_result => l_result);
    RETURN;
	END;

  --checking case information
	BEGIN
		select count(*)
		into   v_cnt
		from   sa.table_case tc,
			     sa.table_condition tcon
		where  tc.x_esn = p_esn
		and    (tc.x_min = p_min or tc.x_msid = p_min)
		and    tc.modify_stmp >= sysdate-2/24
		and    tc.s_title = 'DATA THROTTLE ISSUE'
		and    upper(tc.x_case_type) = 'ERD'
		and    tc.case_state2condition = tcon.objid
		and    tcon.s_title = 'CLOSED';

		--
		IF 	v_cnt = 0 then
			--
		  p_msg_out        := 'NO RECENT DATA THROTTLE ISSUE CASES FOUND';
		  p_error_code_out := -2;

			--logging error table
			write_error( p_error_text   => 'unthrottle('|| p_esn || ','|| p_min || ','|| p_user || ','|| p_msg_out || ','|| p_error_code_out || ','||')',
			             p_action       => p_msg_out,
                   p_key          => coalesce(p_min,p_esn,'NO MIN OR ESN'),
                   p_program_name => l_program_name );

			--logging interact table
			create_unthrottle_interact(esn      => p_esn,
								                 p_user   => p_user,
                                 p_result => l_result);
			RETURN; -- no case found
		END IF;
	END;

	--Unthrottling
	w3ci.throttling.sp_expire_cache( p_min                       => p_min           ,
                                   p_esn                       => p_esn           ,
                                   p_error_code                => p_error_code_out,
                                   p_error_message             => p_msg_out       ,
                                   p_bypass_off                => NULL            ,
                                   p_source                    => 'TAS'           ,
                                   p_source_bypass_trans_queue => 'Y');


  COMMIT;

  IF p_error_code_out = 0 and p_msg_out = 'SUCCESS' then
     --
     p_msg_out  := 'ESN UNTHROTTLED SUCCESSFULLY';
     l_result   := 'Successful';
     --
	   sa.apex_fix_errors.log_msg( esn      => p_esn                 ,
                                 msg      => p_msg_out             ,
                                 brand_in => nvl(v_brand,'UNKNOWN'),
                                 log_type => 'Log');
  ELSE
     p_msg_out  := NVL(p_msg_out,'FAILED TO UNTHROTTLE THE ESN');
  END IF;

  --
	create_unthrottle_interact( esn     =>  p_esn,
                              p_user  =>  p_user,
                              p_result => l_result);
EXCEPTION
  WHEN OTHERS THEN
    --
    p_msg_out        := 'Failed to UN-Throttle '||SQLERRM;
    p_error_code_out := -1;

    --logging error table
		write_error( p_error_text   => 'unthrottle('|| p_esn || ','|| p_min || ','|| p_user || ','|| p_msg_out || ','|| p_error_code_out || ','||')',
                 p_action       => p_msg_out,
                 p_key          => COALESCE(p_min,p_esn,'NO MIN OR ESN'),
                 p_program_name => l_program_name );
		--
		create_unthrottle_interact( esn      =>  p_esn,
                                p_user   =>  p_user,
                                p_result => l_result);

END tas_unthrottle_prc;
/