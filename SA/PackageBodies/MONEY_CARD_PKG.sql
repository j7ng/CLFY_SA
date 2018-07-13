CREATE OR REPLACE PACKAGE BODY sa."MONEY_CARD_PKG" is
   /***************************************************************************************************************
    * Package Name: MONEY_CARD_PKG
    * Description: The package is called by  Clarify
    *              to get info about money card promo for Walmart Money Card.
    *
    * Created by: PM
    * Date:  06/15/2011
    *
    * History
    * -------------------------------------------------------------------------------------------------------------------------------------
    * 06/15/2011         PM                 Initial Version                           	 CR15373
    *******************************************************************************************************************/

procedure validate_money_card_cc( p_credit_card_no      in      varchar2,
                                  p_brand_name          in	    varchar2,
                                  p_process             in      varchar2,
                                  --p_promo_grp_objid     out     number,
                                  p_promo_grpdtl_objid  out     number,
                                  p_promo_objid         out     number,
                                  p_promo_code          out     varchar2,
                                  p_error_code          out     number,
                                  p_error_msg           out     varchar2)
  is

  cursor cur_money_card_check is
            select pg.objid grp_objid, pg.group_name, pg_dtl.objid grpdtl_objid
            from   table_x_promotion_group pg, x_promotion_group_dtl pg_dtl
            where  1 = 1
            and    pg.objid  = pg_dtl.x_promo_grpdtl2promo_grp
            and    pg_dtl.description = substr(p_credit_card_no,1,length(pg_dtl.description))
            --and    substr(p_credit_card_no,1,length(pg.x_range_start)) between pg.x_range_start and pg.x_range_end
            and    sysdate between pg.x_start_date and nvl(pg.x_end_date,sysdate+1);
  rec_money_card_check cur_money_card_check%rowtype;


  cursor cur_act_promo(c_promo_grp_objid  number)is
            select pg.objid pg_objid, p.x_promo_code, p.objid promo_objid
            from   table_x_promotion_group pg, table_x_promotion_mtm mtm, table_x_promotion p, table_bus_org bo
            where  1 =1
            and    mtm.x_promo_mtm2x_promo_group  = pg.objid
            and    mtm.x_promo_mtm2x_promotion    = p.objid
            and    bo.objid                       = p.promotion2bus_org
            and    pg.objid                       = c_promo_grp_objid
            --and    sysdate                        <= nvl(p.x_expire_date, sysdate + 1)
            --AND    SYSDATE                        BETWEEN P.X_START_DATE AND NVL(P.X_END_DATE, SYSDATE + 1)
            --and    upper(x_promo_type)            = 'MC'||upper(p_process)
            and    x_promo_type in ('Moneycard')
            and    bo.org_id                      = p_brand_name;
  rec_act_promo   cur_act_promo%rowtype;

begin
      --p_promo_grp_objid     :=  null;
      p_promo_grpdtl_objid  :=  null;
      p_promo_objid         :=  null;
      p_promo_code          :=  null;
      p_error_code          := 0;
      p_error_msg           := 'Success';

      -- Promo Group Check.
      open cur_money_card_check;
      fetch cur_money_card_check into rec_money_card_check;
      if cur_money_card_check%found then
        --P_PROMO_GRP_OBJID := REC_MONEY_CARD_CHECK.GRP_OBJID;
        p_promo_grpdtl_objid := rec_money_card_check.grpdtl_objid;

        -- Active Promo check.
        ----
        for rec_act_promo in cur_act_promo(rec_money_card_check.grp_objid)
        loop
          if sf_promo_check(rec_act_promo.promo_objid, p_process) = 'TRUE' then
            p_promo_objid := rec_act_promo.promo_objid;
            p_promo_code  := rec_act_promo.x_promo_code;

            exit;
          end if;
        end loop;
      end if;
      close cur_money_card_check;
  exception
      when others then
        p_error_code  := sqlcode;
        p_error_msg   := substr(sqlerrm, 1, 100);

end validate_money_card_cc;

procedure validate_money_card_promo ( p_esn             in        varchar2,
                                      p_cc_objid			  in	      number,
                                      p_process         in        varchar2,
                                      p_promo_code      in        varchar2 default null,
                                      p_promo_objid			out       number,
                                      p_enroll_type     out       varchar2,
                                      p_enroll_amount   out       number,
                                      p_enroll_units    out       number,
                                      p_enroll_days     out       number,
                                      p_error_code      out       number,
                                      p_error_msg       out       varchar2 )is

    -- For recurrent only .
    cursor cur_enrollment_dtl is
              select *
              from   x_program_enrolled
              where  x_esn              = p_esn
              and    x_next_charge_date is not null
              and    x_is_grp_primary   = 1
              AND    x_wait_exp_date    IS NULL;
    rec_enrollment_dtl  cur_enrollment_dtl%rowtype;

    cursor cur_esn_dtl is
              select pn.part_num2bus_org
              from  table_part_inst pi, table_mod_level ml, table_part_num pn
              where 1 = 1
              and   ml.objid          = pi.n_part_inst2part_mod
              and   pn.objid          = ml.part_info2part_num
              and   pi.part_serial_no = p_esn;
    rec_esn_dtl    cur_esn_dtl%rowtype;

    -- Get active promo group for ESN and Credit Card.
    cursor cur_act_promo_group is
              select cc_ext.*
              from  x_money_card_cc cc_ext, x_promotion_group_dtl pg_dtl, table_x_promotion_group pg
              where 1 = 1
              and   cc_ext.x_esn                        = p_esn
              and   x_money_card2creditcard             = p_cc_objid
              and   cc_ext.x_money_card2promo_grpdtl    = pg_dtl.objid
              and   pg.objid                            =  pg_dtl.x_promo_grpdtl2promo_grp
              and   sysdate between pg.x_start_date and nvl(pg.x_end_date, sysdate+1)
              ;
    rec_act_promo_group   cur_act_promo_group%rowtype;

    cursor cur_act_promo( c_promo_grpdtl_id   number,
                          c_bus_org_objid     number,
                          c_enrolled_date     date) is
            select p.*
            from    table_x_promotion p, table_x_promotion_mtm mtm, x_promotion_group_dtl pg_dtl,
                    table_bus_org bo
            where  1 = 1
            and    mtm.x_promo_mtm2x_promotion      = p.objid
            and    bo.objid                         = p.promotion2bus_org
            and    mtm.x_promo_mtm2x_promo_group    = pg_dtl.x_promo_grpdtl2promo_grp
            and    pg_dtl.objid                     = c_promo_grpdtl_id
            and    bo.objid                         = c_bus_org_objid
            and    ( (upper(p_process) = 'RECURRING' and trunc(nvl(c_enrolled_date, sysdate)) <= trunc(p.x_end_date) ) or
                      upper(p_process) = 'ENROLLMENT'
                   )
            and    x_promo_type in ('Moneycard')
            ;
    rec_act_promo cur_act_promo%rowtype;

    cursor cur_promo_dtl(c_promo_code   varchar2)  is
            select  p.objid
                  , p.x_promo_code
                  , p.x_transaction_type
                  , p.x_discount_amount
                  , p.x_units
                  , p.x_access_days
                  , p.x_usage
                  , nvl((
                          select sum(nvl(x_usage_counter,0))
                          from   x_money_card_cc ext
                          where  ext.x_money_card2creditcard = p_cc_objid
                          and    ext.x_money_card2promotion = p.objid
                        ),0) cc_usage_count
                  , nvl((
                          select sum(nvl(x_usage_counter,0))
                          from   x_money_card_cc ext
                          where  ext.x_esn = p_esn
                          and    ext.x_money_card2promotion = p.objid
                        ),0) esn_usage_count
                  , nvl((
                          select max(x_rqst_date)
                          from  x_program_enrolled pe,
                                x_program_purch_dtl dtl,
                                x_program_purch_hdr hdr,
                                x_program_discount_hist hist
                          where 1 = 1
                          and   dtl.pgm_purch_dtl2pgm_enrolled    = pe.objid
                          and   hdr.objid                         = dtl.pgm_purch_dtl2prog_hdr
                          and   hist.pgm_discount2prog_hdr        = hdr.objid
                          and   hist.pgm_discount2x_promo         = p.objid
                          and   hdr.x_status not in ( 'FAILED','FAILPROCESSED','VALIDATIONFAILED' )
                          and   ( pe.x_esn                        = p_esn or hdr.purch_hdr2creditcard = p_cc_objid )
                        ), sysdate - 31) last_usage_date
            from   table_x_promotion p
            where  1 = 1
            and    p.x_promo_code = c_promo_code;
            --and    sysdate between p.x_start_date and p.x_end_date;
    rec_promo_dtl cur_promo_dtl%rowtype;

    exc_proc_end exception;
begin
    p_error_code  := 0;
    p_error_msg   := 'Success';

    open cur_esn_dtl;
    fetch cur_esn_dtl into rec_esn_dtl;
    if cur_esn_dtl%notfound then
      close cur_esn_dtl;
      p_error_code  := 251;
      p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
      raise exc_proc_end;
    end if;
    close cur_esn_dtl;

    open cur_act_promo_group;
    fetch cur_act_promo_group into rec_act_promo_group;


    if cur_act_promo_group%notfound then
      close cur_act_promo_group;
      --p_error_code  := 12;
      --p_error_msg   := 'No active money card group exists.';
      raise exc_proc_end;
    end if;
    close cur_act_promo_group;

    if p_process is null then
        p_error_code  := 256;
        p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
        raise exc_proc_end;
    end if;

    if upper(p_process) = 'RECURRING' then
        open cur_enrollment_dtl;
        fetch cur_enrollment_dtl into rec_enrollment_dtl;
        close cur_enrollment_dtl;
    end if;
    ----
    for i in cur_act_promo( rec_act_promo_group.x_money_card2promo_grpdtl, rec_esn_dtl.part_num2bus_org, rec_enrollment_dtl.X_ENROLLED_DATE )
    loop
        if sf_promo_check(i.objid, p_process) = 'TRUE' then
          rec_act_promo := i;
          exit;
        end if;
    end loop;

   -- PM Need to confirm which promo we need to use here.
    open cur_promo_dtl(nvl(rec_act_promo.x_promo_code,p_promo_code) );
    fetch cur_promo_dtl into rec_promo_dtl;
    close cur_promo_dtl;
    if rec_promo_dtl.esn_usage_count < nvl(rec_promo_dtl.x_usage, 0) and
       rec_promo_dtl.cc_usage_count < nvl(rec_promo_dtl.x_usage, 0) and
       nvl(rec_promo_dtl.last_usage_date, sysdate - 31) < sysdate - 30 then
          --P_PROMO_CODE      := REC_PROMO_DTL.X_PROMO_CODE;
          p_promo_objid     := rec_promo_dtl.objid;
          p_enroll_type     := rec_promo_dtl.x_transaction_type;
          p_enroll_amount   := rec_promo_dtl.x_discount_amount;
          p_enroll_units    := rec_promo_dtl.x_units;
          p_enroll_days     := rec_promo_dtl.x_access_days;

    end if;
  exception
    when exc_proc_end then
          --P_PROMO_CODE      := null;
          p_promo_objid     := null;
          p_enroll_type     := null;
          p_enroll_amount   := null;
          p_enroll_units    := null;
          p_enroll_days     := null;
end validate_money_card_promo;

procedure register_money_card ( p_esn				            in	      varchar2,
                                p_brand_name            in        varchar2,
                                p_cc_objid			        in	      number,
                                --p_promo_grp_objid       in        number,
                                p_promo_grpdtl_objid    in        number,
                                p_process               in        varchar2,
                                p_error_code      		  out       number,
                                p_error_msg			        out       varchar2) is
    cursor cur_esn_dtl is
            select pn.part_num2bus_org, pi.part_serial_no
            from  table_part_inst pi, table_mod_level ml, table_part_num pn
            where 1 = 1
            and   ml.objid          = pi.n_part_inst2part_mod
            and   pn.objid          = ml.part_info2part_num
            and   pi.part_serial_no = p_esn;
    rec_esn_dtl    cur_esn_dtl%rowtype;

    cursor cur_credit_card is
            select *
            from   table_x_credit_card
            where  objid = p_cc_objid;
    rec_credit_card  cur_credit_card%rowtype;

    cursor cur_money_card_cc is
            select *
            from   x_money_card_cc
            where  x_money_card2creditcard = p_cc_objid;
    rec_money_card_cc   cur_money_card_cc%rowtype;

    cursor cur_act_promo( c_promo_grpdtl_id   number,
                          c_brand_name        varchar2) is
            select p.*
            from    table_x_promotion p, table_x_promotion_mtm mtm, x_promotion_group_dtl pg_dtl,
                    table_bus_org bo
            where  1 = 1
            and    mtm.x_promo_mtm2x_promotion      = p.objid
            and    bo.objid                         = p.promotion2bus_org
            and    mtm.x_promo_mtm2x_promo_group    = pg_dtl.x_promo_grpdtl2promo_grp
            and    pg_dtl.objid                     = c_promo_grpdtl_id
            and    bo.org_id                        = c_brand_name
            --AND    SYSDATE BETWEEN P.X_START_DATE AND NVL(P.X_END_DATE, SYSDATE + 1)
            --and    upper(x_promo_type)              = 'MC'||upper(p_process)
            and    x_promo_type in ('Moneycard')
            ;
    rec_act_promo cur_act_promo%rowtype;

    l_ext_cnt                         number  := 0;
    l_esn_cnt_01                      number  := 0;
    l_esn_cnt_02                      number  := 0;
    l_esn_cnt_03                      number  := 0;
    l_esn_act_promo_cnt_01            number  := 0;
    l_esn_act_promo_cnt_02            number  := 0;
    l_esn_act_promo_cnt_03            number  := 0;
    l_diff_act_promo_cnt_01           number  := 0;
    l_diff_act_promo_cnt_02           number  := 0;
    l_diff_act_promo_cnt_03           number  := 0;


    exc_proc_end exception;

begin
  p_error_code  := 0;
  p_error_msg   := 'Success';

    -- ESN check.
    if p_esn is not null then
      open cur_esn_dtl;
      fetch cur_esn_dtl into rec_esn_dtl;
      if cur_esn_dtl%notfound then
        close cur_esn_dtl;
        p_error_code  := 251;
        p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
        raise exc_proc_end;
      end if;
      close cur_esn_dtl;
    end if;

    -- Credit Card check.
    if p_cc_objid is not null then
      open cur_credit_card;
      fetch cur_credit_card into rec_credit_card;
      if cur_credit_card%notfound then
        close cur_credit_card;
        p_error_code  := 253;
        p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
        raise exc_proc_end;
      end if;
      close cur_credit_card;
    else
        p_error_code  := 252;
        p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
        raise exc_proc_end;
    end if;

    if p_promo_grpdtl_objid is null then
        p_error_code  := 254;
        p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
        raise exc_proc_end;
    end if;

    if p_brand_name is null then
        p_error_code  := 255;
        p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
        raise exc_proc_end;
    end if;

    if p_process is null then
        p_error_code  := 256;
        p_error_msg   := sa.get_code_fun ('MONEY_CARD_PKG', p_error_code, 'ENGLISH');
        raise exc_proc_end;
    end if;

----
    for i in cur_act_promo( p_promo_grpdtl_objid, p_brand_name )
    loop
        if sf_promo_check(i.objid, p_process) = 'TRUE' then
          rec_act_promo := i;
          exit;
        end if;
    end loop;

    open cur_money_card_cc;
    loop
      fetch cur_money_card_cc into rec_money_card_cc;
      exit when cur_money_card_cc%notfound;

      l_ext_cnt := nvl(l_ext_cnt,0) + 1;
      -- Null ESN Count.
      if rec_money_card_cc.x_esn is null then
        l_esn_cnt_01  := nvl(l_esn_cnt_01,0) + 1;
        if nvl(rec_money_card_cc.x_money_card2promotion,0) = nvl(rec_act_promo.objid,0) then
          l_esn_act_promo_cnt_01  := nvl(l_esn_act_promo_cnt_01,0) + 1;
        elsif nvl(rec_money_card_cc.x_money_card2promotion,0) <> nvl(rec_act_promo.objid,0) then
          l_diff_act_promo_cnt_01 := nvl(l_diff_act_promo_cnt_01,0) + 1;
        end if;
      -- Same ESN Count.
      elsif rec_money_card_cc.x_esn = nvl(rec_esn_dtl.part_serial_no,'x') then
        l_esn_cnt_02  := nvl(l_esn_cnt_02,0) + 1;
        if nvl(rec_money_card_cc.x_money_card2promotion,0) = nvl(rec_act_promo.objid,0) then
          l_esn_act_promo_cnt_02  := nvl(l_esn_act_promo_cnt_02,0) + 1;
        elsif nvl(rec_money_card_cc.x_money_card2promotion,0) <> nvl(rec_act_promo.objid,0) then
          l_diff_act_promo_cnt_02 := nvl(l_diff_act_promo_cnt_02,0) + 1;
        end if;
      -- Other ESN Count.
      elsif rec_money_card_cc.x_esn <> nvl(rec_esn_dtl.part_serial_no,'x') then
        l_esn_cnt_03  := nvl(l_esn_cnt_03,0) + 1;
        if nvl(rec_money_card_cc.x_money_card2promotion,0) = nvl(rec_act_promo.objid,0) then
          l_esn_act_promo_cnt_03  := nvl(l_esn_act_promo_cnt_03,0) + 1;
        elsif nvl(rec_money_card_cc.x_money_card2promotion,0) <> nvl(rec_act_promo.objid,0) then
          l_diff_act_promo_cnt_03 := nvl(l_diff_act_promo_cnt_03,0) + 1;
        end if;
      end if;
    end loop;

    if l_ext_cnt > 0 then
      -- Null ESN for CC, with Active promo.
      if l_esn_cnt_01 > 0 and l_esn_act_promo_cnt_01 > 0 and l_esn_cnt_02 = 0 and l_esn_cnt_03 = 0 then
        if p_esn is not null then
          update x_money_card_cc
          set     x_esn = p_esn
          where   x_money_card2creditcard     = p_cc_objid
          and     x_money_card2promotion      = rec_act_promo.objid
          and     x_money_card2promo_grpdtl   = p_promo_grpdtl_objid;
        end if;
      -- Null ESN for CC, with Inactive promo.
      elsif l_esn_cnt_01 > 0 and l_diff_act_promo_cnt_01 > 0 and l_esn_cnt_02 = 0 and l_esn_cnt_03 = 0 then
        if p_esn is not null then
          update x_money_card_cc
          set     x_esn = p_esn,
                  x_money_card2promotion      = rec_act_promo.objid
          where   x_money_card2creditcard     = p_cc_objid
          and     x_esn is null;
        end if;
      -- Same ESN for CC, without Active and Inactive promo.
      elsif l_esn_cnt_02 > 0 and l_esn_act_promo_cnt_02 = 0 and l_diff_act_promo_cnt_02 = 0 then
        if p_esn is not null then
          update x_money_card_cc
          set     x_money_card2promotion      = rec_act_promo.objid
          where   x_money_card2creditcard     = p_cc_objid
          and     x_esn                       = p_esn
          and     x_money_card2promo_grpdtl   = p_promo_grpdtl_objid;
        end if;
      -- Same ESN for CC, without Active promo but inactive promo.
      elsif l_esn_cnt_02 > 0 and l_esn_act_promo_cnt_02 = 0 and l_diff_act_promo_cnt_02 > 0 then
        if p_esn is not null then
          insert into x_money_card_cc (   objid
                                        , x_esn
                                        , x_usage_counter
                                        , x_last_modified_date
                                        , x_money_card2creditcard
                                        --, x_money_card2promo_grp
                                        , x_money_card2promotion
                                        , x_money_card2promo_grpdtl)
                              values (   seq_money_card_cc.nextval
                                        , p_esn
                                        , 0
                                        , sysdate
                                        , p_cc_objid
                                        --, p_promo_grp_objid
                                        , rec_act_promo.objid
                                        , p_promo_grpdtl_objid);
        end if;
      -- Other ESN for CC.
      elsif l_esn_cnt_03 > 0 and l_esn_cnt_02 = 0 then
        if p_esn is not null then
          insert into x_money_card_cc (   objid
                                        , x_esn
                                        , x_usage_counter
                                        , x_last_modified_date
                                        , x_money_card2creditcard
                                        --, x_money_card2promo_grp
                                        , x_money_card2promotion
                                        , x_money_card2promo_grpdtl)
                              values (   seq_money_card_cc.nextval
                                        , p_esn
                                        , 0
                                        , sysdate
                                        , p_cc_objid
                                        --, p_promo_grp_objid
                                        , rec_act_promo.objid
                                        , p_promo_grpdtl_objid);
        end if;
      end if;
    -- No CC Entry in extension table.
    else
      insert into x_money_card_cc (   objid
                                    , x_esn
                                    , x_usage_counter
                                    , x_last_modified_date
                                    , x_money_card2creditcard
                                    --, x_money_card2promo_grp
                                    , x_money_card2promotion
                                    , x_money_card2promo_grpdtl)
                          values (   seq_money_card_cc.nextval
                                    , p_esn
                                    , 0
                                    , sysdate
                                    , p_cc_objid
                                    --, p_promo_grp_objid
                                    , rec_act_promo.objid
                                    , p_promo_grpdtl_objid);

    end if;

    commit;

  exception
      when exc_proc_end then
        null;
end register_money_card;

procedure modify_usage  ( p_purch_hdr_id          in        number,
                          p_error_code      		  out       number,
                          p_error_msg			        out       varchar2) is


  cursor cur_charge_dtl (c_purch_hdr_id number) is
            select  dtl.x_esn, cc.objid cc_objid, hist.pgm_discount2x_promo promo_objid
            from    x_program_purch_hdr hdr, x_program_purch_dtl dtl, x_program_discount_hist hist,
                    x_payment_source ps, table_x_credit_card cc
            where   1 = 1
            and     dtl.pgm_purch_dtl2prog_hdr   = hdr.objid
            and     hist.pgm_discount2prog_hdr   = hdr.objid
            and     ps.objid                     = hdr.prog_hdr2x_pymt_src
            and     cc.objid                     = ps.pymt_src2x_credit_card
            and     hdr.objid                    = c_purch_hdr_id;--92512005;
  rec_charge_dtl cur_charge_dtl%rowtype;

  l_purch_hdr_id      number;
begin
  p_error_code  := 0;
  p_error_msg   := 'Success';

  if p_purch_hdr_id < 0 then
    l_purch_hdr_id := p_purch_hdr_id * -1;
  end if;

  open cur_charge_dtl(nvl(l_purch_hdr_id, p_purch_hdr_id));
  fetch cur_charge_dtl into rec_charge_dtl;
  close cur_charge_dtl;

  if rec_charge_dtl.x_esn is not null then
    update x_money_card_cc
    set    x_usage_counter        = nvl(x_usage_counter,0) + 1 * ( nvl(l_purch_hdr_id, p_purch_hdr_id) / p_purch_hdr_id) ,
           --X_USAGE_DATE           = sysdate,
           x_last_modified_date   = sysdate
    where x_esn                   = rec_charge_dtl.x_esn
    and   x_money_card2creditcard = rec_charge_dtl.cc_objid
    and   x_money_card2promotion  = rec_charge_dtl.promo_objid;
  end if;
  commit;
end modify_usage;


function sf_promo_check ( p_promo_id   in number default null,
                          p_process    in varchar2 ) return varchar2
is

  cursor cur_promo_dtl is
          select p.*
          from   table_x_promotion p
          where  p.objid = p_promo_id;
  rec_promo_dtl   cur_promo_dtl%rowtype;

  l_sql_statement   varchar2(4000);
  l_cursor          integer;
  l_result_cursor   integer;
  l_bind_var        varchar2(200);
  l_counter         varchar2(200);
  l_promo_objid     table_x_promotion.objid%type;

begin
  open cur_promo_dtl;
  --LOOP
    fetch cur_promo_dtl into rec_promo_dtl;
    --exit when cur_promo_dtl%notfound;

    l_sql_statement := rec_promo_dtl.x_sql_statement;
    if l_sql_statement is not null then

      begin
        -- Open Cursor.
        l_cursor  :=  dbms_sql.open_cursor;
        -- Parse SQL Statement.
        dbms_sql.parse(l_cursor, l_sql_statement, dbms_sql.v7 );


        -- Bind Variables.
        l_bind_var  := ':promo_objid';

        if nvl(instr(l_sql_statement,l_bind_var),0) > 0 then
           dbms_sql.bind_variable (l_cursor,l_bind_var,p_promo_id);
        end if;

        l_bind_var  := ':process';

        if nvl(instr(l_sql_statement,l_bind_var),0) > 0 then
           dbms_sql.bind_variable (l_cursor,l_bind_var,p_process);
        end if;


        -- describe defines
        dbms_sql.define_column(l_cursor, 1, l_counter, 10);


        -- Execute SQL.
        l_result_cursor := dbms_sql.execute(l_cursor);

        -- Fetch result.
        if nvl(dbms_sql.fetch_rows (l_cursor),0) > 0 then
          dbms_sql.column_value (l_cursor, 1, l_counter);
        end if;
        if to_number(l_counter) > 0 then
          return 'TRUE';
        else
          return 'FALSE';
        end if;
      exception
        when others then
          null;
      end;

    end if;

  --end loop;
end sf_promo_check;

procedure web_user_discount ( p_web_user_id             in        number,
                              p_discount_amount         out       number,
                              p_error_code      		    out       number,
                              p_error_msg			          out       varchar2 ) is

  cursor cur_prog_purch_dtl is
            select  dtl.x_esn, cc.objid cc_objid, hist.pgm_discount2x_promo, hist.x_discount_amount
            from    x_program_purch_hdr hdr, table_web_user w,
                    x_program_purch_dtl dtl,
                    x_program_discount_hist  hist,
                    x_payment_source ps, table_x_credit_card cc
            where   1 = 1
            and     w.objid   = hdr.prog_hdr2web_user
            and     w.objid   = p_web_user_id
            and     hdr.objid = dtl.pgm_purch_dtl2prog_hdr
            and     hdr.objid = hist.pgm_discount2prog_hdr
            and     ps.objid  = hdr.prog_hdr2x_pymt_src
            and     cc.objid  = ps.pymt_src2x_credit_card
            and     to_char(hdr.x_rqst_date, 'MON-YYYY' ) =  to_char(sysdate,'MON-YYYY');


   cursor cur_cc_ext_dtl (  c_esn         varchar2,
                            c_cc_id       number,
                            c_promo_id    number ) is
            select '1'
            from   x_money_card_cc
            where  x_esn                                      = c_esn
            and    x_money_card2creditcard                    = c_cc_id
            and    x_money_card2promotion                     = c_promo_id
            and    to_char(x_last_modified_date,'MON-YYYY' )  =  to_char(sysdate,'MON-YYYY');
  rec_cc_ext_dtl   cur_cc_ext_dtl%rowtype;



begin
  p_error_code  := 0;
  p_error_msg   := 'Success';
  p_discount_amount := 0;
  if p_web_user_id is not null then
    for rec_prog_purch_dtl in cur_prog_purch_dtl
    loop
      open cur_cc_ext_dtl (  rec_prog_purch_dtl.x_esn,
                              rec_prog_purch_dtl.cc_objid,
                              rec_prog_purch_dtl.pgm_discount2x_promo);
      fetch cur_cc_ext_dtl into rec_cc_ext_dtl;
      if cur_cc_ext_dtl%found then
        p_discount_amount := p_discount_amount + rec_prog_purch_dtl.x_discount_amount;
      end if;
      close cur_cc_ext_dtl;
    end loop;

  end if;

end web_user_discount;



procedure validate_money_card_ccid( p_cc_id               in      number,
                                    p_brand_name          in	    varchar2,
                                    p_process             in      varchar2,
                                    --P_PROMO_GRP_OBJID     OUT     NUMBER,
                                    p_promo_grpdtl_objid  out     number,
                                    p_promo_objid         out     number,
                                    p_promo_code          out     varchar2,
                                    p_error_code          out     number,
                                    p_error_msg           out     varchar2) is


/*
  cursor cur_money_card_check is
            select grpdtl.x_promo_grpdtl2promo_grp, ext.*
            from   x_payment_source ps, table_x_credit_card cc, x_money_card_cc ext, x_promotion_group_dtl grpdtl
            where  1 = 1
            and    ps.objid                 = p_pymt_src_id
            and    cc.objid                 = ps.pymt_src2x_credit_card
            and    x_money_card2creditcard  = cc.objid
            and    grpdtl.objid             = ext.X_MONEY_CARD2PROMO_GRPDTL;
*/
  cursor cur_money_card_check is
            select grpdtl.x_promo_grpdtl2promo_grp, ext.*
            from   x_money_card_cc ext, x_promotion_group_dtl grpdtl
            where  1 = 1
            and    x_money_card2creditcard  = p_cc_id
            and    grpdtl.objid             = ext.x_money_card2promo_grpdtl;

  rec_money_card_check cur_money_card_check%rowtype;


  cursor cur_act_promo(c_promo_grp_objid  number)is
            select pg.objid pg_objid, p.x_promo_code, p.objid promo_objid
            from   table_x_promotion_group pg, table_x_promotion_mtm mtm, table_x_promotion p, table_bus_org bo
            where  1 =1
            and    mtm.x_promo_mtm2x_promo_group  = pg.objid
            and    mtm.x_promo_mtm2x_promotion    = p.objid
            and    bo.objid                       = p.promotion2bus_org
            and    pg.objid                       = c_promo_grp_objid
            --and    sysdate                        <= nvl(p.x_expire_date, sysdate + 1)
            --AND    SYSDATE                        BETWEEN P.X_START_DATE AND NVL(P.X_END_DATE, SYSDATE + 1)
            --and    upper(x_promo_type)            = 'MC'||upper(p_process)
            and    x_promo_type in ('Moneycard')
            and    bo.org_id                      = p_brand_name;
  rec_act_promo   cur_act_promo%rowtype;

begin
      p_promo_grpdtl_objid  :=  null;
      p_promo_objid         :=  null;
      p_promo_code          :=  null;
      p_error_code          := 0;
      p_error_msg           := 'Success';

      -- Promo Group Check.
      open cur_money_card_check;
      fetch cur_money_card_check into rec_money_card_check;
      if cur_money_card_check%found then
        p_promo_grpdtl_objid := rec_money_card_check.X_MONEY_CARD2PROMO_GRPDTL;

        -- Active Promo check.
        ----
        for rec_act_promo in cur_act_promo(rec_money_card_check.x_promo_grpdtl2promo_grp)
        loop
          if sf_promo_check(rec_act_promo.promo_objid, p_process) = 'TRUE' then
            p_promo_objid := rec_act_promo.promo_objid;
            p_promo_code  := rec_act_promo.x_promo_code;

            exit;
          end if;
        end loop;
      end if;
      close cur_money_card_check;
  exception
      when others then
        p_error_code  := sqlcode;
        p_error_msg   := substr(sqlerrm, 1, 100);

end validate_money_card_ccid;

/*
FUNCTION SF_WEB_USER_DISCOUNT ( P_WEB_USER_ID             IN        NUMBER ) RETURN NUMBER IS

  CURSOR CUR_PROG_PURCH_DTL IS
            SELECT  dtl.x_esn, cc.objid cc_objid, hist.PGM_DISCOUNT2X_PROMO, HIST.X_DISCOUNT_AMOUNT
            FROM    X_PROGRAM_PURCH_HDR HDR, TABLE_WEB_USER W,
                    X_PROGRAM_PURCH_DTL DTL,
                    X_PROGRAM_DISCOUNT_HIST  HIST,
                    x_payment_source ps, table_x_credit_card cc
            WHERE   1 = 1
            AND     W.OBJID   = HDR.PROG_HDR2WEB_USER
            AND     W.OBJID   = P_WEB_USER_ID
            AND     HDR.OBJID = DTL.PGM_PURCH_DTL2PROG_HDR
            AND     HDR.OBJID = HIST.PGM_DISCOUNT2PROG_HDR
            AND     PS.OBJID  = HDR.PROG_HDR2X_PYMT_SRC
            AND     CC.OBJID  = PS.PYMT_SRC2X_CREDIT_CARD
            AND     TO_CHAR(HDR.X_RQST_DATE, 'MON-YYYY' ) =  TO_CHAR(SYSDATE,'MON-YYYY');


   CURSOR CUR_CC_EXT_DTL (  C_ESN         VARCHAR2,
                            C_CC_ID       NUMBER,
                            C_PROMO_ID    NUMBER ) IS
            SELECT '1'
            FROM   X_MONEY_CARD_CC
            WHERE  X_ESN                                      = C_ESN
            AND    X_MONEY_CARD2CREDITCARD                    = C_CC_ID
            AND    X_MONEY_CARD2PROMOTION                     = C_PROMO_ID
            AND    TO_CHAR(X_LAST_MODIFIED_DATE,'MON-YYYY' )  =  TO_CHAR(SYSDATE,'MON-YYYY');
  rec_cc_ext_dtl   cur_cc_ext_dtl%rowtype;

  P_DISCOUNT_AMOUNT   number;

BEGIN
  P_DISCOUNT_AMOUNT := 0;
  IF P_WEB_USER_ID IS NOT NULL then
    FOR REC_PROG_PURCH_DTL IN CUR_PROG_PURCH_DTL
    LOOP
      OPEN CUR_CC_EXT_DTL (  REC_PROG_PURCH_DTL.X_ESN,
                              REC_PROG_PURCH_DTL.CC_OBJID,
                              REC_PROG_PURCH_DTL.PGM_DISCOUNT2X_PROMO);
      FETCH CUR_CC_EXT_DTL INTO REC_CC_EXT_DTL;
      IF CUR_CC_EXT_DTL%FOUND THEN
        P_DISCOUNT_AMOUNT := P_DISCOUNT_AMOUNT + rec_prog_purch_dtl.X_DISCOUNT_AMOUNT;
      end if;
    end loop;

  END IF;
  return P_DISCOUNT_AMOUNT;
END SF_WEB_USER_DISCOUNT;
*/
end money_card_pkg;
/