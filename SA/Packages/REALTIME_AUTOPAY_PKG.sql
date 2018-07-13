CREATE OR REPLACE PACKAGE sa."REALTIME_AUTOPAY_PKG" as
  procedure hold(p_esn in varchar2,
                 p_promo_code in varchar2,
                 p_amount in number,
                 p_program_type in number,
                 p_payment_type in varchar2,
                 p_source in varchar2,
                 p_language_flag in varchar2,
                 p_msg OUT varchar2,
                 c_p_status OUT varchar2
                 );
end;
/