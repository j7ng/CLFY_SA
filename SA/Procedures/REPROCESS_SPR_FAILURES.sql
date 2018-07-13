CREATE OR REPLACE PROCEDURE sa."REPROCESS_SPR_FAILURES" (i_max_rows_limit         IN  NUMBER DEFAULT 1000,
                                                          i_max_reprocess_count    IN  NUMBER DEFAULT 48)
IS

/*************************************************************************************************************************************
  * $Revision: 1.8 $
  * $Author: mdave $
  * $Date: 2018/05/22 15:45:01 $
  * $Log: REPROCESS_SPR_FAILURES.sql,v $
  * Revision 1.8  2018/05/22 15:45:01  mdave
  * CR57251
  *
  * Revision 1.7  2016/12/16 15:10:33  skota
  * modified for the ig pcrf log table
  *
  * Revision 1.6  2016/12/05 20:24:36  skota
  * reprocee enhancement
  *
  * Revision 1.5  2016/11/30 14:45:22  skota
  * modified
  *
  * Revision 1.4  2016/11/04 16:27:44  skota
  * added the in parameter to process the count
  *
  * Revision 1.3  2016/11/03 14:49:24  skota
  * added row num logic
  *
  * Revision 1.2  2016/10/31 13:12:54  skota
  * Mofiied the spr reprocess table column name
  *
  * Revision 1.1  2016/10/21 15:44:17  skota
  * Reprocess spr failures
  *
  *************************************************************************************************************************************/

 --
 igt      ig_transaction_type;
 ig       ig_transaction_type;
 --
 sub      subscriber_type;
 s        subscriber_type;
 --
 ipl ig_pcrf_log_type := ig_pcrf_log_type();
 ip  ig_pcrf_log_type := ig_pcrf_log_type();
 --
 l_min varchar2(30);
 l_epir_flag   VARCHAR2(1) := 'N';
 --
 CURSOR get_spr_reprocess_data is
	select *
	from ( select *
		     from   sa.x_spr_reprocess_log
		     where  reprocess_flag = 'N'
		     and    program_name in ('IGATE_IN3')
		     and    reprocess_count < i_max_reprocess_count
		     order by objid )
	where ROWNUM <= i_max_rows_limit;

 l_error_code number;
 l_error_msg  varchar2(300);

BEGIN
    --
    FOR i in get_spr_reprocess_data LOOP
		-- retieve the subcriber info by esn
		sub := subscriber_type ( i_esn => i.esn );

    -- get the latest min by esn
		begin
			select x_min
			into   l_min
			from   sa.table_site_part
			where  objid = (select max(objid)
							        from   sa.table_site_part
							        where  x_service_id = i.esn);
		exception
		 when others then
			l_min := i.min;
		end;

		-- get the sub info by min
		s := subscriber_type(i_esn => NULL,
							           i_min => l_min );

		-- ig_pcrf_log
		ipl := ig_pcrf_log_type ();
		ip  := ig_pcrf_log_type ();

		-- logic to avoid duplicate execution of the update_pcrf_subscriber
		IF NOT ipl.exist ( i_transaction_id => i.ig_transaction_id )then
      --
      IF NOT (sub.exist OR s.exist) then -- spr exists esn/min
        -- calling update_subscriber procedure
				sa.update_pcrf_subscriber (i_esn                 => i.esn                   ,
                                   i_action_type         => NULL                    ,
                                   i_reason              => NULL                    ,
											             i_src_program_name    => 'REPROCESS_SPR_FAILURES',
											             i_sourcesystem        => NULL                    ,
                                   i_ig_order_type       => i.ig_order_type         ,
											             i_transaction_id      => i.ig_transaction_id     ,
											             o_error_code          => l_error_code            ,
											             o_error_msg           => l_error_msg             );

				--spr success
				if  l_error_code = 0 and l_error_msg like '%SUCCESS%' then
					--setting the reprocess flag
					update sa.x_spr_reprocess_log
						set  reprocess_flag   = 'Y',
                 response         = l_error_msg,
							   reprocess_count  = reprocess_count+1,
                 update_timestamp = SYSDATE
					where  objid = i.objid;

					--update tranaction_id in ig_spr_log
					ipl := ig_pcrf_log_type ();
					ip  := ig_pcrf_log_type ();

          --log the pcrf ig log
					if not ipl.exist ( i_transaction_id => i.ig_transaction_id )then
					  --
						ip := ipl.ins ( i_transaction_id => i.ig_transaction_id );
						commit;
					end if;
					--
				end if;

			ELSE  -- spr exists

				--
                BEGIN
                 SELECT X_PARAM_VALUE
                 INTO   l_epir_flag
                 FROM   sa.table_x_parameters
                 WHERE  X_PARAM_NAME =  i.ig_order_type;
                EXCEPTION
                 WHEN OTHERS THEN
                   l_epir_flag := 'N';
                END;
        --checking, is spr (either by esn/min) has been updated by other channel after failure logged
				if (i.insert_timestamp > sub.update_timestamp) or (i.insert_timestamp > s.update_timestamp) or (s.brand = 'NET10' AND l_epir_flag = 'Y') then

					--
					-- calling update_subscriber procedure
					sa.update_pcrf_subscriber (i_esn                 => i.esn                   ,
                                     i_action_type         => NULL                    ,
												             i_reason              => NULL                    ,
												             i_src_program_name    => 'REPROCESS_SPR_FAILURES',
												             i_sourcesystem        => NULL                    ,
												             i_ig_order_type       => i.ig_order_type         ,
												             i_transaction_id      => i.ig_transaction_id     ,
												             o_error_code          => l_error_code            ,
												             o_error_msg           => l_error_msg             );

					if  l_error_code = 0 and l_error_msg like '%SUCCESS%' then

						--setting the reprocess flag
						update sa.x_spr_reprocess_log
            set    reprocess_flag   = 'Y',
								   response         = l_error_msg,
								   reprocess_count  = reprocess_count+1,
								   update_timestamp = SYSDATE
						where  objid            = i.objid;

						--update tranaction_id in ig_spr_log
						ipl := ig_pcrf_log_type ();
						ip  := ig_pcrf_log_type ();

						-- logic to avoid duplicate execution of the update_pcrf_subscriber
						if not ipl.exist ( i_transaction_id => i.ig_transaction_id )then
							--log the pcrf ig log
							ip := ipl.ins ( i_transaction_id => i.ig_transaction_id );
							commit;
						end if;

					end if;

				else --spr updated after the failure
					   --no need to reprocess
					update sa.x_spr_reprocess_log
						 set reprocess_flag   = 'Y',
							   response         = 'NEWER SPR TRANSACTION FOUND',
							   update_timestamp = SYSDATE
					where  objid = i.objid;

          -- logic to avoid duplicate execution of the update_pcrf_subscriber
					if not ipl.exist ( i_transaction_id => i.ig_transaction_id )then
						--log the pcrf ig log
						ip := ipl.ins ( i_transaction_id => i.ig_transaction_id );
						commit;
					end if;

				end if;
			--
			END IF;

    ELSE  --pcrf log exits
        --
      	update sa.x_spr_reprocess_log
           set reprocess_flag   = 'Y',
							 response         = 'ALREADY PROCESSED THROUGH IG',
							 update_timestamp = SYSDATE
         where objid = i.objid;
    END IF;
    commit;
  END LOOP;

EXCEPTION
   WHEN OTHERS THEN
    RAISE;
END reprocess_spr_failures;
/