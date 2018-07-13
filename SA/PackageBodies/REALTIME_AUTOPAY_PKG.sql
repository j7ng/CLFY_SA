CREATE OR REPLACE PACKAGE BODY sa."REALTIME_AUTOPAY_PKG" as
/*****************************************************************************************************
  --  History
  --REVISIONS    VERSION  DATE        WHO               PURPOSE
  -------------------------------------------------------------------------
  --                1.0   02012003      CWL                  Initial Version
* 		    1.1   04/10/03       SL                 Clarify Upgrade
*                                                                       - sequence
  --                1.2	  05102003     Suganthi		    CR 1157 Correct Autopay Details table
  ****************************************************************************************************/

  procedure hold(p_esn in varchar2,
                 p_promo_code in varchar2,
                 p_amount in number,
                 p_program_type in number,
                 p_payment_type in varchar2,
                 p_source in varchar2,
                 p_language_flag in varchar2,
                 p_msg OUT varchar2,
                 c_p_status OUT varchar2 )is
------------------------------------------------------------
    cursor user_curs(c_login_name in varchar2) is
      select objid
        from table_user
       where s_login_name = upper(c_login_name);
    user_rec user_curs%rowtype;
------------------------------------------------------------
    cursor contact_curs(c_site_objid in number) is
      select c.*
        from table_contact c,
             table_contact_role cr
       where c.objid = cr.contact_role2contact
         and cr.CONTACT_ROLE2SITE=c_site_objid;
    contact_rec contact_curs%rowtype;
------------------------------------------------------------
    CURSOR sp_curs_c(c_esn in varchar2) iS
      Select sp.objid                    site_part_objid,
             sp.site_part2site           site_part2site,
             sp.x_min                    x_min,
             sp.x_expire_dt              x_expire_dt,
             ca.objid                    carrier_objid,
             ir.inv_role2site            site_objid,
             ca.x_carrier_id             x_carrier_id,
             sp.site_objid               cust_site_objid,
             sp.state_code               v_state_code
        from
             table_x_carrier  ca,
             table_part_inst  pi2, ---x_Domain=Line
             table_inv_role   ir,
             table_inv_bin    ib,
             table_part_inst  pi,  ---x_Domain=Phone
             table_site_part  sp
       where ca.objid                 = pi2.part_inst2carrier_mkt
         and initcap(pi2.x_domain)    = 'Lines'
         and pi2.part_serial_no       = sp.x_min
         and ir.inv_role2inv_locatn   = ib.inv_bin2inv_locatn
         and ib.objid                 = pi.part_inst2inv_bin
         and pi.x_part_inst2site_part = sp.objid
         and sp.x_service_id          = c_esn
         and sp.part_status         = 'Active';
    sp_curs_rec sp_curs_c%rowtype;
------------------------------------------------------------
    cursor c1(c_esn in varchar2) is
      select objid
        from table_x_autopay_details
       where x_esn = c_esn
         and x_program_type = 3
         and x_status = 'A'
         and x_receive_status is null;
    c1_rec c1%rowtype;
------------------------------------------------------------
    cursor c2(c_esn in varchar2,
              c_promo_code in varchar2,
              c_payment_type in varchar2,
              c_amount in number,
              c_program_type in number,
              c_source in varchar2) is
      select 1
        from table_x_autopay_details
       where x_esn = c_esn
         and X_RECEIVE_STATUS = 'R'
         and x_promocode      = c_promo_code
         and x_payment_type   = c_payment_type
         and X_ENROLL_AMOUNT  = c_amount
         and x_program_type   = c_program_type
         and x_source         = c_source;
    c2_rec c2%rowtype;
------------------------------------------------------------
    cursor promo_curs(c_promo_code in varchar2) is
      select objid
        from table_x_promotion
       where x_promo_code = c_promo_code;
    promo_rec promo_curs%rowtype;
------------------------------------------------------------------
    CURSOR cur_ph_c(c_esn in varchar2) IS
      SELECT *
        FROM TABLE_PART_INST
       where part_serial_no = p_esn
         AND x_domain = 'PHONES';
    rec_ph cur_ph_c%ROWTYPE;
------------------------------------------------------------
    cursor site_part_curs(c_esn in varchar2) is
      select objid,site_part2site
        from table_site_part
       where x_service_id = c_esn
         and part_status = 'Active';
    site_part_rec site_part_curs%rowtype;
------------------------------------------------------------
    v_part_inst_objid number;
    v_call_tran_seq number; --04/10/03
  begin
------------------------------------------------------------
    c_p_status := 'S';
------------------------------------------------------------
    v_part_inst_objid := SP_RUNTIME_PROMO.get_esn_part_inst_objid(p_esn);
------------------------------------------------------------
    open site_part_curs(p_esn);
      fetch site_part_curs into site_part_rec;
      if site_part_curs%notfound then
        insert into x_autopay_pending
         (OBJID                                  ,
          X_CREATION_DATE                        ,
          X_ESN                                  ,
          X_PROGRAM_TYPE                         ,
          X_ACCOUNT_STATUS                       ,
          X_STATUS                               ,
          X_START_DATE                           ,
          X_END_DATE                             ,
          X_CYCLE_NUMBER                         ,
          X_PROGRAM_NAME                         ,
          X_ENROLL_DATE                          ,
          X_FIRST_NAME                           ,
          X_LAST_NAME                            ,
          X_RECEIVE_STATUS                       ,
          X_AGENT_ID                             ,
          X_AUTOPAY_DETAILS2SITE_PART            ,
          X_AUTOPAY_DETAILS2X_PART_INST          ,
          X_AUTOPAY_DETAILS2CONTACT              ,
          X_TRANSACTION_TYPE                     ,
          X_SOURCE_FLAG                          ,
          X_ADDRESS1                             ,
          X_CITY                                 ,
          X_STATE                                ,
          X_ZIPCODE                              ,
          X_CONTACT_PHONE                        ,
          X_TRANSACTION_AMOUNT                   ,
          X_PROMOCODE                            ,
          X_ENROLL_FEE_FLAG                      ,
          X_UNIQUERECORD         ,
          X_ENROLL_AMOUNT        ,
          X_SOURCE               ,
          X_LANGUAGE_FLAG        ,
          X_PAYMENT_TYPE         )
        values(
          -- 04/10/03 SEQ_X_AUTOPAY_DETAILS.nextval + power(2,28),
          seq('x_autopay_details'),
          NULL,--sysdate,  -- CR 1157
          p_esn,
          p_program_type,
          null,
          'A',
          sysdate,--null,  -- CR 1157
          null,
          null,
          (decode(p_program_type,2,'AutoPay',
                                 3,'Bonus Plan',
                                 4,'Deactivation Protection')),
          sysdate, --null,  -- CR 1157
          null,
          null,
          'R',
          null,
          null,
          v_part_inst_objid,
          null,
          null,
          'R',
          null,
          null,
          null,
          null,
          null,
          null,
          p_promo_code,
          null,
          null,
          p_amount,
          p_source,
          p_language_flag,
          p_payment_type
          );
        commit;
        return;
      end if;
    close site_part_curs;
------------------------------------------------------------
    open user_curs('SA');
      fetch user_curs into user_rec;
    close user_curs;
------------------------------------------------------------
    open promo_curs(p_promo_code);
      fetch promo_curs into promo_rec;
      if promo_curs%notfound then
        promo_rec.objid := null;
      end if;
    close promo_curs;
------------------------------------------------------------
    OPEN sp_curs_c(p_esn);
      Fetch sp_curs_c into sp_curs_rec;
    CLOSE sp_curs_c;
--------------------------------------------------
    open contact_curs(sp_curs_rec.site_part2site);
      fetch contact_curs into contact_rec;
    close contact_curs;
------------------------------------------------------------
    OPEN cur_ph_c(p_esn);
      FETCH cur_ph_c INTO rec_ph;
    CLOSE cur_ph_c;
------------------------------------------------------------
    open c1(p_esn);
      fetch c1 into c1_rec;
      if c1%found then
        update table_x_autopay_details
           set X_RECEIVE_STATUS = 'R',
               x_promocode      = p_promo_code,
               x_payment_type   = p_payment_type,
               X_ENROLL_AMOUNT  = p_amount,
               x_program_type   = p_program_type,
               x_source         = p_source,
               X_LANGUAGE_FLAG  = p_language_flag
         where objid = c1_rec.objid;
      else
--/*
        open c2(p_esn,
                p_promo_code,
                p_payment_type,
                p_amount,
                p_program_type,
                p_source);
          fetch c2 into c2_rec;
          if c2%found then
            return;
          end if;
        close c2;
--*/
        -- 04/10/03
        --
        select seq('x_call_trans') into v_call_tran_seq
        from dual;
        INSERT INTO TABLE_X_CALL_TRANS
            (objid,
             call_trans2site_part,
             x_action_type,
             x_call_trans2carrier,
             x_call_trans2dealer,
             x_call_trans2user,
             x_line_status,
             x_min,
             x_service_id,
             x_sourcesystem,
             x_transact_date,
             x_total_units,
             x_action_text,
             x_reason,
             x_result,
             x_sub_sourcesystem
            )
        VALUES(
            --04/10/03 (seq_x_call_trans.NEXTVAL + POWER (2, 28)),
             v_call_tran_seq,
             sp_curs_rec.site_part_objid,
             '82',
             sp_curs_rec.carrier_objid,
             sp_curs_rec.site_objid,
             user_rec.objid,
             '13',
             sp_curs_rec.x_min,
             p_esn,
             'AUTOPAY_BATCH',
             sysdate,
             0,
             'STAYACT SUBSCRIBE', --'Enrollment',     -- CR 1157
             decode(p_program_type,2,'(2)Autopay',3,'(3)Double Min',4,'(4)DPP' ), --'STAYACT SUBSCRIBE',  -- CR 1157
             'Completed',
             '202');
          INSERT INTO table_x_autopay_details
            (OBJID                          ,
             X_CREATION_DATE                 ,
             X_ENROLL_DATE	            ,
             X_START_DATE		    ,
             X_ESN                          ,
             X_PROGRAM_TYPE                 ,
             X_ACCOUNT_STATUS               ,
             X_STATUS                       ,
             X_PROGRAM_NAME                 ,
             X_RECEIVE_STATUS               ,
             X_AUTOPAY_DETAILS2SITE_PART    ,
             X_AUTOPAY_DETAILS2X_PART_INST  ,
             X_AUTOPAY_DETAILS2CONTACT      ,
             X_PROMOCODE                    ,
             X_ENROLL_AMOUNT                ,
             X_SOURCE                       ,
             X_LANGUAGE_FLAG                ,
             X_PAYMENT_TYPE)
          VALUES
            (-- 04/10/03 SEQ_X_AUTOPAY_DETAILS.nextval + power(2,28),
             seq('x_autopay_details'),
             NULL, --sysdate, -- CR 1157
             sysdate,
             sysdate,
             p_esn,
             p_program_type,
             3,
             'A',
             (decode(p_program_type,2,'AutoPay',
                                    3,'Bonus Plan',
                                    4,'Deactivation Protection')),
             'R',
             sp_curs_rec.site_part_objid,
             v_part_inst_objid,
             contact_rec.objid,
             p_promo_code,
             p_amount,
             p_source,
             p_LANGUAGE_FLAG,
             p_PAYMENT_TYPE);
        if promo_rec.objid is not null then
          insert into table_x_promo_hist
           (OBJID                  ,
           PROMO_HIST2X_CALL_TRANS,
           PROMO_HIST2X_PROMOTION)
          values
          (-- 04/10/03 SEQ_X_PROMO_HIST.nextval + power(2,28),
           -- 04/10/03 seq_x_call_trans.currval + power(2,28),
           seq('x_promo_hist'),
           v_call_tran_seq,
           promo_rec.objid);
        end if;
        IF p_program_type in( 2,3) and( sp_curs_rec.x_expire_dt-sysdate ) < 90 THEN          --Check for 90 Days
          if p_program_type in (2,3) then
            IF (sp_curs_rec.x_expire_dt-sysdate) < 58 then  --Check for 58 days
              sp_curs_rec.x_expire_dt := sp_curs_rec.x_expire_dt + 32;       --32 Free Days
            ELSE
              sp_curs_rec.x_expire_dt := sp_curs_rec.x_expire_dt + 90-(sp_curs_rec.x_expire_dt-sysdate);
            END IF;
          end if;
------------------------------------------------------------------------------------------
          UPDATE table_site_part
             SET X_EXPIRE_DT   = sp_curs_rec.x_expire_dt,
                 WARRANTY_DATE = sp_curs_rec.x_expire_dt
           where S_SERIAL_NO   = p_esn
             and part_status   = 'Active';
------------------------------------------------------------------------------------------
          UPDATE table_part_inst
             SET warr_end_date  = sp_curs_rec.x_expire_dt
           WHERE x_domain       = 'PHONES'
             AND part_serial_no = p_esn;
------------------------------------------------------------------------------------------
          INSERT INTO TABLE_X_PI_HIST
          (objid,
           status_hist2x_code_table,
           x_change_date,
           x_change_reason,
           x_cool_end_date,
           x_creation_date,
           x_deactivation_flag,
           x_domain,
           x_ext,
           x_insert_date,
           x_npa,
           x_nxx,
           x_old_ext,
           x_old_npa,
           x_old_nxx,
           x_part_bin,
           x_part_inst_status,
           x_part_mod,
           x_part_serial_no,
           x_part_status,
           x_pi_hist2carrier_mkt,
           x_pi_hist2inv_bin,
           x_pi_hist2part_inst,
           x_pi_hist2part_mod,
           x_pi_hist2user,
           x_pi_hist2x_new_pers,
           x_pi_hist2x_pers,
           x_po_num,
           x_reactivation_flag,
           x_red_code,
           x_sequence,
           x_warr_end_date,
           dev,
           fulfill_hist2demand_dtl,
           part_to_esn_hist2part_inst,
           x_bad_res_qty,
           x_date_in_serv,
           x_good_res_qty,
           x_last_cycle_ct,
           x_last_mod_time,
           x_last_pi_date,
           x_last_trans_time,
           x_next_cycle_ct,
           x_order_number,
           x_part_bad_qty,
           x_part_good_qty,
           x_pi_tag_no,
           x_pick_request,
           x_repair_date,
           x_transaction_id)
          VALUES
          ( --04/10/03 seq_x_pi_hist.NEXTVAL + POWER (2, 28),
           seq('x_pi_hist'),
           rec_ph.status2x_code_table,
           SYSDATE,
           (decode(p_program_type,2,'Autopay Plan Batch',
                                  3,'Bonus Plan Batch',
                                  4,'Deact Plan Batch')),
           rec_ph.x_cool_end_date,
           rec_ph.x_creation_date,
           rec_ph.x_deactivation_flag,
           rec_ph.x_domain,
           rec_ph.x_ext,
           rec_ph.x_insert_date,
           rec_ph.x_npa,
           rec_ph.x_nxx,
           NULL,
           NULL,
           NULL,
           rec_ph.part_bin,
           82,
           rec_ph.part_mod,
           rec_ph.part_serial_no,
           rec_ph.part_status,
           rec_ph.part_inst2carrier_mkt,
           rec_ph.part_inst2inv_bin,
           rec_ph.objid,
           rec_ph.n_part_inst2part_mod,
           rec_ph.created_by2user,
           rec_ph.part_inst2x_new_pers,
           rec_ph.part_inst2x_pers,
           rec_ph.x_po_num,
           rec_ph.x_reactivation_flag,
           rec_ph.x_red_code,
           rec_ph.x_sequence,
           rec_ph.warr_end_date,
           rec_ph.dev,
           rec_ph.fulfill2demand_dtl,
           rec_ph.part_to_esn2part_inst,
           rec_ph.bad_res_qty,
           rec_ph.date_in_serv,
           rec_ph.good_res_qty,
           rec_ph.last_cycle_ct,
           rec_ph.last_mod_time,
           rec_ph.last_pi_date,
           rec_ph.last_trans_time,
           rec_ph.next_cycle_ct,
           rec_ph.x_order_number,
           rec_ph.part_bad_qty,
           rec_ph.part_good_qty,
           rec_ph.pi_tag_no,
           rec_ph.pick_request,
           rec_ph.repair_date,
           rec_ph.transaction_id);
        end if;
      end if;
    close c1;
    commit;
  EXCEPTION WHEN OTHERS THEN
    c_p_status := 'F';
    p_msg := 'Failure >> '||SUBSTR(SQLERRM,1,100);
  end;
end;
/