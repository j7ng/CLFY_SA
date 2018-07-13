CREATE OR REPLACE FUNCTION sa.APEX_ESN_MIN_HIST
(
  IP_REQUEST IN VARCHAR2,
  IP_ESN IN VARCHAR2,
  IP_MIN IN VARCHAR2,
  IP_TRANS_TYPE IN VARCHAR2,
  IP_DAYS IN VARCHAR2,
  IP_MSID IN VARCHAR2,
  IP_RED_CARD IN VARCHAR2,
  IP_LINE_TRANS_TYPE IN VARCHAR2
) RETURN VARCHAR2 AS

  sqlstr varchar2(1000);

BEGIN

  if IP_REQUEST = 'ACTIVATION_DEACTIVATION' then

    if IP_ESN is null and IP_MIN is null then
      sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    else
      sqlstr := 'select action_text transaction_type, contact_x_cust_id customer, agent ,carrier, market,
      esn, x_iccid sim, x_min min,x_technology technology,dealer,result
      from table_x_act_deact_hist  WHERE  1=1 ';
      if IP_ESN is not null then
          sqlstr:=sqlstr|| ' and esn like '''||IP_ESN||'%''';
      end if;
      if IP_MIN is not null then
         sqlstr:=sqlstr||' and x_min like '''||IP_MIN||'%''';
      end if;
      if IP_DAYS <> 'ALL' then
         sqlstr:=sqlstr||' and date_time >= sysdate - '||IP_DAYS;
      end if;
      if IP_TRANS_TYPE <> 'ALL' then
         sqlstr:=sqlstr|| 'and action_type = '''||IP_TRANS_TYPE||'''';
      end if;
    end if;
  elsif IP_REQUEST = 'LINE_HISTORY' then

    if IP_MSID is null and IP_MIN is null then
      sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    else

    sqlstr := 'select  x_min min,x_msid msid, x_change_reason transaction_type,x_change_date change_date,
    agent, x_carrier_name carrier ,x_mkt_submkt_name market
    from table_x_line_hist_view where 1=1 ';

    if IP_MIN is not null then
      sqlstr := sqlstr || ' and x_min = '''||IP_MIN||'''';
    end if;
    if ip_msid is not null then
      sqlstr := sqlstr || ' and x_msid = '''||IP_MSID||'''';
    end if;
    if IP_LINE_TRANS_TYPE <> 'ALL' then
       sqlstr := sqlstr || ' and x_change_reason = '''||upper(IP_LINE_TRANS_TYPE)||'''';
    end if;
    if IP_DAYS <> 'ALL' then
       sqlstr := sqlstr || ' and x_change_date >= sysdate - '||IP_DAYS;
    end if;
    end if;
  elsif IP_REQUEST = 'REDEMPTION' then

    if IP_ESN is null and IP_MIN is null and IP_RED_CARD is null then
       sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    else
       sqlstr:='select action_text,date_time red_date,contact_x_cust_id customer,
       agent,carrier,market,esn,x_min min,x_technology tech,dealer,red_code,units,result
       from  table_x_redemp_hist  where 1 = 1  ';

       if IP_ESN is not null then

          sqlstr := sqlstr || ' and esn = '''||IP_ESN||'''';
       end if;

       if IP_MIN is not null then

          sqlstr := sqlstr || ' and x_min = '''||IP_MIN||'''';
       end if;

       if IP_RED_CARD is not null then
          sqlstr := sqlstr || ' and red_code = '''||IP_RED_CARD||'''';
       end if;

       if IP_DAYS <> 'ALL' then

          sqlstr := sqlstr || ' and date_time  >= sysdate - '||IP_DAYS;
       end if;

    end if;

  elsif IP_REQUEST = 'PHONE_HISTORY' then

    if IP_ESN is null then
       sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    else
       sqlstr:= 'select x_esn esn,x_change_reason trans_type,x_change_date change_date,
                 agent,site_id dealer_id  from table_x_phone_hist where 1=1 ';
       if IP_ESN is not null then
          sqlstr := sqlstr || ' and x_esn = '''||IP_ESN||'''';
       end if;
       if IP_DAYS <> 'ALL' then
          sqlstr := sqlstr || ' and x_change_date  >= sysdate - '||IP_DAYS;
       end if;
    end if;

  elsif IP_REQUEST = 'PROMOTION_HISTORY' then

    if IP_ESN is null and IP_MIN is null then
      sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    else

      sqlstr:= ' select  action_text trans_type,date_time promo_date,contact_x_cust_id cust_id,agent,carrier,market,esn,
      x_min min,x_technology tech,dealer,x_promo_code promo_code,x_promo_type promo_type,
      x_units promo_units,result  from table_x_promo_hist_view where 1=1 ';

       if IP_ESN is not null then
          sqlstr := sqlstr || ' and esn = '''||IP_ESN||'''';
       end if;

       if IP_MIN is not null then
          sqlstr := sqlstr || ' and x_min = '''||IP_MIN||'''';
       end if;

       if IP_DAYS <> 'ALL' then
          sqlstr := sqlstr || ' and date_time  >= sysdate - '||IP_DAYS;
       end if;

  end if;


return sqlstr;

end if;
end;
/