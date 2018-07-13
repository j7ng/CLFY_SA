CREATE OR REPLACE PACKAGE BODY sa.service_profile_pkg AS

 --------------------------------------------------------------------------------------------
 --$RCSfile: SERVICE_PROFILE_PKG.sql,v $
 --$Revision: 1.156 $
 --$Author: skota $
 --$Date: 2018/03/27 20:17:18 $
 --$ $Log: SERVICE_PROFILE_PKG.sql,v $
 --$ Revision 1.156  2018/03/27 20:17:18  skota
 --$ Merged the prod code
 --$
 --$ Revision 1.155  2018/03/20 18:39:44  skota
 --$ Merged with latest changes
 --$
 --$ Revision 1.149  2018/03/05 16:23:25  skota
 --$ Changes for throttling error log fix for all sources
 --$
 --$ Revision 1.148  2018/02/20 21:47:19  rkommineni
 --$ Added comment for CR56198
 --$
 --$ Revision 1.147  2018/02/19 22:45:05  skota
 --$ Modified for throttling window rule
 --$
 --$ Revision 1.144  2017/10/30 14:35:03  skota
 --$ Modifed for the pageplus addons
 --$
 --$ Revision 1.143  2017/10/27 17:53:23  skota
 --$ Merged with PROD
 --$
 --$ Revision 1.142  2017/10/26 21:11:17  skota
 --$ Made changes for pageplus addons
 --$
 --$ Revision 1.141  2017/10/24 21:25:08  skota
 --$ Made changes for pageplus addons
 --$
 --$ Revision 1.140  2017/10/24 15:49:49  skota
 --$ Modified for page plus addons
 --$
 --$ Revision 1.139  2017/10/10 16:05:55  skota
 --$ Make changes for the PAGEPLUS addons
 --$
 --$ Revision 1.137  2017/08/30 20:32:02  skota
 --$ Modified for spr pageplus unique constraint vioaltions if the bad data exists in spr table
 --$
 --$ Revision 1.136  2017/08/28 18:40:30  skota
 --$ Made chanages for pageplus propagate flag
 --$
 --$ Revision 1.135  2017/07/25 19:01:00  skota
 --$ Make chnages for the page plus benefit updates
 --$
 --$ Revision 1.134  2017/07/10 21:45:00  skota
 --$ make changes for the cache curs
 --$
 --$ Revision 1.133  2017/07/07 15:10:05  mshah
 --$ CR52134 - PCRF: Fix invalid cursor for page plus renewal job
 --$
 --$ Revision 1.132  2017/06/27 16:22:40  skota
 --$ Make changes for esn change for the page plus
 --$
 --$ Revision 1.131  2017/06/21 13:57:09  skota
 --$ Merged the code with prod version
 --$
 --$ Revision 1.128  2017/05/26 21:52:10  skota
 --$ Added page plus throttle rules
 --$
 --$ Revision 1.127  2017/04/25 20:02:46  skota
 --$ Merged chnages with SPR status after TTON with get esn inquiry
 --$
 --$ Revision 1.126  2017/04/21 21:46:41  skota
 --$ modified
 --$
 --$ Revision 1.125  2017/04/21 18:23:23  skota
 --$ Make changes in get esn inquiry procedure for removing the bad data in SPR table
 --$
 --$ Revision 1.122  2017/04/05 18:19:06  sgangineni
 --$ CR47564 - WFM code merge with Rel_854 changes
 --$
 --$ Revision 1.121  2017/04/04 22:57:40  sgangineni
 --$ CR47564 - Modified as per code review comments. Added input validation check in update_program_parameter
 --$
 --$ Revision 1.118  2017/03/21 18:28:21  sgangineni
 --$ CR47564 - WFM code merge with Rel 853 changes
 --$
 --$ Revision 1.116  2017/03/15 15:04:47  rpednekar
 --$ CR47275
 --$
 --$ Revision 1.115  2017/03/07 20:25:18  rpednekar
 --$ CR47275 - New procedure PORT_OUT_PKG.CREATE_CLOSE_PORT_OUT_CASE called from insert_pageplus_spr procedure conditionally
 --$
 --$ Revision 1.113  2017/02/28 21:35:12  rpednekar
 --$ CR47275
 --$
 --$ Revision 1.112  2017/02/15 15:18:25  mshah
 --$ CR46740 Move 3C inquiry Logs to OTA Part II
 --$
 --$ Revision 1.109  2017/02/06 16:51:40  rpednekar
 --$ CR47275 - New procedure CREATE_CLOSE_PORT_OUT_CASE added and called from insert_pageplus_spr procedure conditionally
 --$
 --$ Revision 1.106  2017/01/16 22:35:34  akhan
 --$ added dataclub changes
 --$
 --$ Revision 1.105  2017/01/11 16:38:03  vlaad
 --$ Merged with 1/11 EME
 --$
 --$ Revision 1.100  2016/12/27 21:54:51  vlaad
 --$ Changes in get_esn_inquiry for new brand logic
 --$
 --$ Revision 1.96  2016/11/18 21:58:20  mshah
 --$ CR 45325  - Logging part uncommented as Intergate changes cant go to production. New CR will be created to stop the logging in CLFY
 --$
 --$ Revision 1.95  2016/10/27 18:55:00  mshah
 --$ CR45325 - Move logging for 3C inquires to OTAPRD
 --$
 --$ Revision 1.94  2016/10/26 14:45:53  mshah
 --$ CR45325 - Move logging for 3C inquires to OTAPRD
 --$
 --$ Revision 1.93  2016/10/11 16:12:00  skota
 --$ merged with prod changes
 --$
 --$ Revision 1.92  2016/10/10 16:47:47  vlaad
 --$ Added set define off
 --$
 --$ Revision 1.91  2016/10/05 19:27:27  vlaad
 --$ Changes for Page Plus CR
 --$
 --$ Revision 1.87  2016/09/20 19:11:38  vlaad
 --$ Updated logic for page plus
 --$
 --$ Revision 1.83  2016/09/08 19:07:21  sraman
 --$ CR44107 - Merged with production code released on 9/8/16
 --$
  --$ Revision 1.82  2016/09/01 20:27:46  vlaad
  --$ Updated get_esn_inquiry fir safelink_flag
  --$
  --$ Revision 1.76  2016/08/23 19:09:13  jpena
  --$ Add changes in get_esn_inquiry
  --$
  --$ Revision 1.73  2016/08/12 22:34:36  jpena
  --$ Changes for Get ESN inquiry check for errors before sending.
  --$
  --$ Merged with CR40903
  --$
  --$ Revision 1.72  2016/08/09 20:41:04  vlaad
  --$ Renamed pp_sprg_stg to x_pageplus_spr_staging
  --$
  --$ Revision 1.71  2016/08/08 16:04:14  vlaad
  --$ Updated BRAND look up logic
  --$
  --$ Revision 1.69  2016/08/05 17:05:02  vlaad
  --$ Changes in Insert_Pageplus_SPR for CR43085
  --$
  --$ Revision 1.65  2016/08/01 21:25:29  vlaad
  --$ Updated logic in insert_pageplus_spr to store MIN as MDN in SPR table for page plus
  --$
  --$ Revision 1.64  2016/08/01 15:02:37  vlaad
  --$ Updated to use pageplus_pcrf_cos_type
  --$
  --$ Revision 1.60  2016/06/23 16:03:01  vyegnamurthy
  --$ CR36349
  --$
  --$ Revision 1.59  2016/06/14 21:03:44  vyegnamurthy
  --$ Page plus changes
  --$
  --$ Revision 1.58  2016/06/02 21:58:21  pamistry
  --$ CR37756 Production merge with 06/02 release
  --$
  --$ Revision 1.57  2016/05/31 15:33:59  jpena
  --$ Merge with production changes.
  --$
  --$ Revision 1.44  2016/04/20 21:42:07  jpena
  --$ Remove call the create_member function from get_subscriber_uid
  --$
  --$ Revision 1.33  2015/12/15 22:48:36  jpena
  --$ Add logging on successful response.
  --$
  --$ Revision 1.31  2015/10/16 21:19:19  jpena
  --$ changes to allow throttle request to continue when the customer is throttled.
  --$
  --$ Revision 1.30  2015/09/14 22:58:56  kparkhi
  --$ CR38013 subscriber_status populating logic changed in get_esn_inquiry
  --$
  --$ Revision 1.29  2015/08/28 20:12:06  aganesan
  --$ CR37645 - Super carrier changes.
  --$
  --$ Revision 1.27  2015/08/24 22:17:08  jpena
  --$ Validate input params on GET_ESN_INQUIRY.
  --$
  --$ Revision 1.24  2015/08/20 20:14:55  jpena
  --$ Ignore pcrf requests.
  --$
  --$ Revision 1.23  2015/08/20 18:19:15  kparkhi
  --$ CR37435
  --$
  --$ Revision 1.21  2015/08/20 15:41:46  kparkhi
  --$ CR37435
  --$
  --$ Revision 1.13  2015/08/07 18:22:58  jpena
  --$ Add condition for parent validation.
  --$
  --$ Revision 1.10  2015/07/02 18:08:37  aganesan
  --$ CR36122 - Passing the transaction number as NULL in sp_throttling_valve procedure call.
  --$
  --$ Revision 1.8  2015/06/03 16:06:59  jpena
  --$ Add mask value input on get_esn_inquiry
  --$
  --$ Revision 1.7  2015/05/22 17:51:05  aganesan
  --$ CR34909 - Super Carrier Changes.
 --$
 --------------------------------------------------------------------------------------------

PROCEDURE add_pcrf_transaction ( i_esn                 IN  VARCHAR2 , -- either esn or min is required
                                 i_min                 IN  VARCHAR2 , -- either esn or min is required
                                 i_order_type          IN  VARCHAR2 ,
                                 i_zipcode             IN  VARCHAR2 ,
                                 i_sourcesystem        IN  VARCHAR2 ,
                                 i_pcrf_status_code    IN  VARCHAR2 DEFAULT 'Q',
                                 o_pcrf_transaction_id OUT NUMBER   ,
                                 o_err_code            OUT NUMBER   ,
                                 o_err_msg             OUT VARCHAR2 ) AS

  pcrf  pcrf_transaction_type := pcrf_transaction_type ( i_esn              => i_esn,
                                                         i_min              => i_min,
                                                         i_order_type       => i_order_type,
                                                         i_zipcode          => i_zipcode,
                                                         i_sourcesystem     => i_sourcesystem,
                                                         i_pcrf_status_code => i_pcrf_status_code);

  p     pcrf_transaction_type;

BEGIN
  -- Call add pcrf_transactiokn object oriented member function
  p := pcrf.ins;
  --
  IF p.status NOT LIKE '%SUCCESS' THEN
    o_err_code := 99;
    o_err_msg  := p.status;
    RETURN;
  END IF;
  o_pcrf_transaction_id := p.pcrf_transaction_id;
  -- When response is false return error return message and exit the call
  o_err_code := 0;
  o_err_msg  := p.status;
END add_pcrf_transaction;

PROCEDURE update_pcrf ( i_pcrf_transaction_id IN  NUMBER   ,
                        i_data_usage          IN  NUMBER   ,
                        i_pcrf_status_code    IN  VARCHAR2 ,
                        i_status_message      IN  VARCHAR2 ,
                        o_err_code            OUT NUMBER   ,
                        o_err_msg             OUT VARCHAR2 ) AS

  -- Call constructor
  pcrf  pcrf_transaction_type := pcrf_transaction_type ( i_pcrf_transaction_id => i_pcrf_transaction_id,
                                                         i_pcrf_status_code    => i_pcrf_status_code,
                                                         i_status_message      => i_status_message,
                                                         i_data_usage          => i_data_usage,
                                                         i_retry_count         => NULL);

  p  pcrf_transaction_type;

BEGIN

  -- if the pcrf transaction exists
  IF pcrf.exist THEN

    -- Call the update member function (pcrf)
    p := pcrf.upd;

    -- When the update was successful
    IF p.status NOT LIKE '%SUCCESS%' THEN
      o_err_code := 99;
      o_err_msg  := p.status;
      RETURN;
    END IF;

  END IF;

  -- When response is false return error return message and exit the call
  o_err_code := 0;
  o_err_msg := 'SUCCESS';

END update_pcrf;

PROCEDURE update_pcrf_low_prty ( i_pcrf_transaction_id IN  NUMBER   ,
                                 i_data_usage          IN  NUMBER   ,
                                 i_pcrf_status_code    IN  VARCHAR2 ,
                                 i_status_message      IN  VARCHAR2 ,
                                 o_err_code            OUT NUMBER   ,
                                 o_err_msg             OUT VARCHAR2 ) AS

  -- call constructor
  pcrf  pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => i_pcrf_transaction_id,
                                                               i_pcrf_status_code    => i_pcrf_status_code,
                                                               i_status_message      => i_status_message,
                                                               i_data_usage          => i_data_usage,
                                                               i_retry_count         => NULL);

  p  pcrf_trans_low_prty_type;

BEGIN

  -- if the pcrf transaction exists
  IF pcrf.exist THEN

    -- Call the update member function (pcrf)
    p := pcrf.upd;

    -- When the update was successful
    IF p.status NOT LIKE '%SUCCESS%' THEN
      o_err_code := 99;
      o_err_msg  := p.status;
      RETURN;
    END IF;

  END IF;

  -- When response is false return error return message and exit the call
  o_err_code := 0;
  o_err_msg := 'SUCCESS';

END update_pcrf_low_prty;

PROCEDURE update_pcrf_offer ( i_pcrf_transaction_id  IN  NUMBER   , -- either esn or min is required
                              i_offer_id             IN  VARCHAR2 ,
                              i_redemption_date      IN  DATE     , -- YYYY-MM-DD HH24:MI:SS
                              i_data_usage           IN  NUMBER   , -- either esn or min is required
                              o_err_code             OUT NUMBER   ,
                              o_err_msg              OUT VARCHAR2 ) IS

 pcrf  pcrf_transaction_detail_type := pcrf_transaction_detail_type();
 p     pcrf_transaction_detail_type := pcrf_transaction_detail_type();

BEGIN

  -- Assign variables to constructor
  pcrf  := pcrf_transaction_detail_type ( i_pcrf_transaction_id => i_pcrf_transaction_id ,
                                          i_offer_id            => i_offer_id            ,
                                          i_redemption_date     => i_redemption_date     );

  -- Call the exist member function to validate if the pcrf transaction detail (offer) exists
  IF NOT pcrf.exist THEN
    o_err_code := 11;
    o_err_msg  := 'PCRF TRANSACTION DETAIL (OFFER) NOT FOUND';
    RETURN;
  END IF;

  -- Assign input variables to constructor
  pcrf  := pcrf_transaction_detail_type ( i_pcrf_transaction_id => i_pcrf_transaction_id,
                                          i_offer_id            => i_offer_id,
                                          i_ttl                 => NULL,
                                          i_future_ttl          => NULL,
                                          i_redemption_date     => i_redemption_date,
                                          i_offer_name          => NULL,
                                          i_data_usage          => i_data_usage);

  -- Call the update member function (pcrf)
  p := pcrf.upd;

  -- When successfull
  IF p.status NOT LIKE '%SUCCESS%' THEN
    o_err_code := 99;
    o_err_msg  := p.status;
    RETURN;
  END IF;

  -- When response is false return error return message and exit the call
  o_err_code := 0;
  o_err_msg := 'SUCCESS';

END update_pcrf_offer;

PROCEDURE update_pcrf_offer_low_prty ( i_pcrf_transaction_id  IN  NUMBER   , -- either esn or min is required
                                       i_offer_id             IN  VARCHAR2 ,
                                       i_redemption_date      IN  DATE     , -- YYYY-MM-DD HH24:MI:SS
                                       i_data_usage           IN  NUMBER   , -- either esn or min is required
                                       o_err_code             OUT NUMBER   ,
                                       o_err_msg              OUT VARCHAR2 ) IS

 pcrf  pcrf_trans_det_low_prty_type := pcrf_trans_det_low_prty_type();
 p     pcrf_trans_det_low_prty_type := pcrf_trans_det_low_prty_type();

BEGIN

  -- Assign variables to constructor
  pcrf  := pcrf_trans_det_low_prty_type ( i_pcrf_transaction_id => i_pcrf_transaction_id ,
                                          i_offer_id            => i_offer_id            ,
                                          i_redemption_date     => i_redemption_date     );

  -- Call the exist member function to validate if the pcrf transaction detail (offer) exists
  IF NOT pcrf.exist THEN
    o_err_code := 11;
    o_err_msg  := 'PCRF TRANSACTION DETAIL (OFFER) NOT FOUND';
    RETURN;
  END IF;

  -- Assign input variables to constructor
  pcrf  := pcrf_trans_det_low_prty_type ( i_pcrf_transaction_id => i_pcrf_transaction_id,
                                          i_offer_id            => i_offer_id,
                                          i_ttl                 => NULL,
                                          i_future_ttl          => NULL,
                                          i_redemption_date     => i_redemption_date,
                                          i_offer_name          => NULL,
                                          i_data_usage          => i_data_usage);

  -- Call the update member function (pcrf)
  p := pcrf.upd;

  -- When successfull
  IF p.status NOT LIKE '%SUCCESS%' THEN
    o_err_code := 99;
    o_err_msg  := p.status;
    RETURN;
  END IF;

  -- When response is false return error return message and exit the call
  o_err_code := 0;
  o_err_msg := 'SUCCESS';

END update_pcrf_offer_low_prty;

-- Procedure to add the SPR row based on ESN or MIN with all the proper validations.
PROCEDURE add_subscriber ( i_esn       IN  VARCHAR2,
                           o_err_code  OUT NUMBER,
                           o_err_msg   OUT VARCHAR2) AS

  ilog spr_transaction_log_type := spr_transaction_log_type ( i_esn          => i_esn,
                                                              i_program_step => 'PROCESS START',
                                                              i_program_name => 'SERVICE_PROFILE_PKG.ADD_SUBSCRIBER');

  ulog spr_transaction_log_type := spr_transaction_log_type ( i_program_step => 'PROCESS END');

  sub  subscriber_type := subscriber_type (i_esn => i_esn );
  s    subscriber_type;
BEGIN

  -- Log process call for internal validations
  ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

  sub.status := NULL;

  -- Call add subscriber member function
  s := sub.ins;

  IF s.status NOT LIKE '%SUCCESS' THEN
    o_err_code := 99;
    o_err_msg := s.status;
    RETURN;
  ELSE
    o_err_code := 0;
    o_err_msg := s.status;
  END IF;

  -- Log process call end
  ulog.spr_transaction_log_objid := ulog.upd( ilog.spr_transaction_log_objid, ulog.status );

END add_subscriber;

--

PROCEDURE add_subscriber_detail ( i_subscriber_spr_objid   IN  NUMBER   ,
                                  i_add_on_offer_id        IN  VARCHAR2 ,
                                  i_add_on_ttl             IN  DATE     ,
                                  i_add_on_redemption_date IN  DATE     ,
                                  i_expired_usage_date     IN  DATE     ,
                                  o_err_code               OUT NUMBER   ,
                                  o_err_msg                OUT VARCHAR2 ) AS

  detail subscriber_detail_type := subscriber_detail_type ( i_subscriber_spr_objid   => i_subscriber_spr_objid,
                                                            i_add_on_offer_id        => i_add_on_offer_id,
                                                            i_add_on_ttl             => i_add_on_ttl,
                                                            i_add_on_redemption_date => i_add_on_redemption_date,
                                                            i_expired_usage_date     => i_expired_usage_date);
  d      subscriber_detail_type;

BEGIN
  -- Call insert subscriber detail member function
  d := detail.ins;

  IF d.status NOT LIKE '%SUCCESS' THEN
    o_err_code := 99;
    o_err_msg := d.status;
  ELSE
    o_err_code := 0;
    o_err_msg := d.status;
    RETURN;
  END IF;

END add_subscriber_detail;


-- Overloaded procedure to expire the subscriber row based on MIN.
PROCEDURE delete_subscriber ( i_esn              IN  VARCHAR2,
                              i_part_inst_status IN  VARCHAR2,
                              o_err_code         OUT NUMBER,
                              o_err_msg          OUT VARCHAR2) AS

  sub subscriber_type := subscriber_type (i_esn => i_esn);

  l_expire_subscriber_flag VARCHAR2(1);
BEGIN

  -- Look for the expire subscriber flag
  BEGIN
    SELECT nvl(expire_subscriber_flag,'N')
    INTO   l_expire_subscriber_flag
    FROM   table_x_code_table
    WHERE  x_code_type = 'LS'
    AND    x_code_number = i_part_inst_status;
   EXCEPTION
     WHEN OTHERS THEN
       l_expire_subscriber_flag := 'N';
  END;

  -- Validate if the part inst status (line status) applies to delete the subscriber
  if NVL(l_expire_subscriber_flag,'N') = 'N' then
    o_err_code := 0;
    o_err_msg := 'SUCCESS';
    return;
  end if;

  IF NOT sub.exist() THEN
    o_err_code := 10;
    o_err_msg := 'SUBSCRIBER NOT FOUND';
    RETURN;
  END IF;

  --
  IF sub.del( i_esn => i_esn) THEN
    o_err_code := 0;
    o_err_msg := 'SUCCESS';
  ELSE
    o_err_code := 99;
    RETURN;
  END IF;

END delete_subscriber;

-- Overloaded procedure to expire the subscriber row based on MIN.
PROCEDURE delete_subscriber ( i_min              IN  VARCHAR2,
                              i_part_inst_status IN  VARCHAR2,
                              i_src_program_name IN  VARCHAR2 DEFAULT NULL,
                              i_sourcesystem     IN  VARCHAR2 DEFAULT NULL,
                              o_err_code         OUT NUMBER,
                              o_err_msg          OUT VARCHAR2) AS

  -- Log types
  ilog spr_transaction_log_type := spr_transaction_log_type ( i_min          => i_min,
                                                              i_program_step => 'PROCESS START',
                                                              i_program_name => 'SERVICE_PROFILE_PKG.DELETE_SUBSCRIBER',
                                                              i_message      => 'min = ' || i_min || ' | ' || 'part_inst_status = ' || i_part_inst_status || ' | ' || 'src_program_name = ' || i_src_program_name || ' | ' || 'sourcesystem = ' || i_sourcesystem);

  ulog spr_transaction_log_type;
  --

  sub subscriber_type := subscriber_type ( i_esn => NULL  ,
                                           i_min => i_min );

  l_expire_subscriber_flag VARCHAR2(1);
  l_count_deact            NUMBER;

  s        subscriber_type;
  s1       subscriber_type := subscriber_type ( i_esn => NULL  ,
                                                i_min => i_min );
  --
  pcrf     pcrf_transaction_type;
  p        pcrf_transaction_type;

BEGIN
  -- Log process call for internal validations
  ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

  -- Look for the expire subscriber flag
  begin
    select nvl(expire_subscriber_flag,'N')
    into   l_expire_subscriber_flag
    from   table_x_code_table
    where  x_code_type = 'LS'
    and    x_code_number = i_part_inst_status;
   exception
     when others then
       l_expire_subscriber_flag := 'N';
  end;

  -- Validate if the part inst status (line status) applies to delete the subscriber
  if NVL(l_expire_subscriber_flag,'N') = 'N' then
    o_err_code := 0;
    o_err_msg := 'SUCCESS';
    return;
  end if;

  -- Call function to validate if the subscriber already exists
  IF NOT sub.exist THEN
    o_err_code := 11;
    o_err_msg := 'SUBSCRIBER NOT FOUND';
    RETURN;
  END IF;

  --
  SELECT COUNT(1)
  INTO   l_count_deact
  FROM   table_x_call_trans ct,
         table_task tt,
         gw1.ig_transaction ig
  WHERE  ct.x_service_id = sub.pcrf_esn
  AND    ct.x_action_type = '2'
  AND    ct.x_result = 'Completed'
  AND    ct.objid = tt.x_task2x_call_trans
  AND    tt.task_id = ig.action_item_id
  AND    ig.order_type = 'D'
  AND    ig.status||'' = 'S';

  IF l_count_deact > 0 THEN
    -- Expire the subscriber
    IF sub.del THEN
      o_err_code := 0;
      o_err_msg := 'SUCCESS';
    ELSE
      o_err_code := 99;
      RETURN;
    END IF;

    s := subscriber_type();
    --
    IF NOT s1.exist THEN

      -- Call add subscriber member procedure
      s := s1.ins;

      -- Debug
      util_pkg.insert_error_tab ( i_action       => 'after sub ins',
                                  i_key          => s1.pcrf_esn,
                                  i_program_name => i_src_program_name,
                                  i_error_text   => 's1.ins = ' || s.status );

      IF s.status NOT LIKE '%SUCCESS%' THEN
        o_err_code := 12;
        o_err_msg  := s.status;
        -- log error
        util_pkg.insert_error_tab ( i_action       => 'creating subscriber pre-pcrf',
                                    i_key          => s1.pcrf_esn,
                                    i_program_name => i_src_program_name,
                                    i_error_text   => s.status );
        -- Exit logic when subscriber ins failed
        RETURN;
      END IF;
    END IF;

    -- Instantiate pcrf transaction table in constructor
    pcrf := pcrf_transaction_type ( i_esn              => s1.pcrf_esn,
                                    i_min              => s1.pcrf_min,
                                    i_order_type       => 'DL',
                                    i_zipcode          => s1.zipcode,
                                    i_sourcesystem     => i_sourcesystem,
                                    i_pcrf_status_code => 'Q');

    -- Call insert pcrf transaction member procedure
    p := pcrf.ins;

    IF p.status NOT LIKE '%SUCCESS' THEN
      o_err_code := 13;
      o_err_msg  := p.status;
      -- log error
      util_pkg.insert_error_tab ( i_action       => 'creating pcrf transaction',
                                  i_key          => s1.pcrf_esn,
                                  i_program_name => i_src_program_name,
                                  i_error_text   => p.status );
      -- Exit logic when subscriber ins failed
      RETURN;

    ELSE
      o_err_code := 0;
      o_err_msg  := p.status;
      -- Exit logic when subscriber ins failed
      RETURN;
    END IF;
  END IF;


  ulog := spr_transaction_log_type ( i_esn          => s1.pcrf_esn,
                                     i_program_step => 'PROCESS END');

  -- Log process call end
  ulog.spr_transaction_log_objid := ulog.upd( ilog.spr_transaction_log_objid, ulog.status );

  o_err_code := 0;
  o_err_msg  := 'SUCCESS';

END delete_subscriber;

PROCEDURE unthrottle_subscriber ( i_min       IN  VARCHAR2 ,
                                  i_esn       IN  VARCHAR2 ,
                                  o_err_code  OUT NUMBER   ,
                                  o_err_msg   OUT VARCHAR2 ) IS

  c_program_name CONSTANT VARCHAR2(50) := 'SERVICE_PROFILE_PKG.UNTHROTTLE_SUBSCRIBER';

  -- Logging start of the transaction in x_spr_transaction_log
  ilog spr_transaction_log_type := spr_transaction_log_type ( i_min          => i_min,
                                                              i_esn          => i_esn,
                                                              i_program_step => 'PROCESS START',
                                                              i_program_name => c_program_name);

  -- Logging end of the transaction in x_spr_transaction_log
  ulog spr_transaction_log_type := spr_transaction_log_type ( i_program_step => 'PROCESS END');

  --
  pcrf  pcrf_transaction_type;
  p     pcrf_transaction_type;

  --
  sub      subscriber_type := subscriber_type ( i_esn => i_esn );
  s        subscriber_type;

  l_error_code NUMBER;
  l_error_message VARCHAR2(1000);

BEGIN

  -- Unthrottle the subscriber
  w3ci.throttling.sp_expire_cache ( p_min               => i_min,
                                    p_esn               => i_esn,
                                    p_error_code        => l_error_code,
                                    p_error_message     => l_error_message,
                                    p_source            => c_program_name);

  IF l_error_code <> 0 THEN
    o_err_code := l_error_code;
    o_err_msg := l_error_message;
    RETURN;
  END IF;

  IF sub.status <> 'SUCCESS' THEN
    o_err_code := 10;
    o_err_msg := sub.status;
    RETURN;
  END IF;

  -- Instantiate pcrf transaction table in constructor
  pcrf := pcrf_transaction_type ( i_esn              => i_esn,
                                  i_min              => i_min,
                                  i_order_type       => 'UP',
                                  i_zipcode          => sub.zipcode,
                                  i_sourcesystem     => null,
                                  i_pcrf_status_code => 'Q');

  -- Call insert pcrf transaction member procedure
  p := pcrf.ins;

  IF p.status NOT LIKE '%SUCCESS' THEN
     o_err_code := 11;
     o_err_msg  := 'CREATING PCRF: ' || p.status;
     RETURN;
  END IF;

  o_err_code := 0;
  o_err_msg := 'SUCCESS';

  -- Log process call end
  ulog.spr_transaction_log_objid := ulog.upd( ilog.spr_transaction_log_objid, ulog.status );

 EXCEPTION
   WHEN others THEN
     --
     o_err_code := 99;
     o_err_msg := 'ERROR IN SERVICE_PROFILE_PKG.UNTHROTTLE_SUBSCRIBER: ' || SUBSTR(SQLERRM,1,100);
     -- log error
     util_pkg.insert_error_tab ( i_action       => 'creating pcrf transaction',
                                 i_key          => i_esn,
                                 i_program_name => c_program_name,
                                 i_error_text   => p.status );
     RAISE;
END unthrottle_subscriber;

-- Get the short description of the parent name based on the logic from the previous get inquiry process
FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2 IS

  l_short_parent_name VARCHAR2(40);

BEGIN
  --
  l_short_parent_name := CASE i_parent_name
                           WHEN 'T-MOBILE'                 THEN 'TMO'
                           WHEN 'T-MOBILE SAFELINK'        THEN 'TMO'
                           WHEN 'T-MOBILE PREPAY PLATFORM' THEN 'TMO'
                           WHEN 'T-MOBILE SIMPLE'          THEN 'TMO'
                           WHEN 'CINGULAR'                 THEN 'ATT'
                           WHEN 'CLARO'                    THEN 'CLR'
                           WHEN 'CLARO SAFELINK'           THEN 'CLR'
                           WHEN 'VERIZON PREPAY PLATFORM'  THEN 'VZW'
                           WHEN 'VERIZON'                  THEN 'VZW'
                           WHEN 'VERIZON SAFELINK'         THEN 'VZW'
                           WHEN 'VERIZON WIRELESS'         THEN 'VZW'
                           WHEN 'AT&T SAFELINK'            THEN 'ATT'
                           WHEN 'AT&T WIRELESS'            THEN 'ATT'
                           WHEN 'ATT WIRELESS'             THEN 'ATT'
                           WHEN 'AT&T PREPAY PLATFORM'     THEN 'ATT'
                           WHEN 'AT&T_NET10'     		   THEN 'ATT'
                           WHEN 'DOBSON CELLULAR'     	   THEN 'ATT'
                           WHEN 'DOBSON GSM'     		   THEN 'ATT'
                           WHEN 'SPRINT'     			   THEN 'SPRINT'
                           WHEN 'SPRINT_NET10'     		   THEN 'SPRINT'
                           WHEN 'WIRELESS_NET10'     	   THEN 'VZW'
                           WHEN 'VERIZON_PPP_SAFELINK'     THEN 'VZW'
                           ELSE i_parent_name
                         END;
  --
  RETURN l_short_parent_name;

 EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END get_short_parent_name;

-- get the throttle parameter flag based on the source and carrier parent name
FUNCTION fn_get_throttle_flag ( i_source          IN  VARCHAR2 ,
	                            i_carrier         IN  VARCHAR2 ,
                                o_parameter_name  OUT VARCHAR2 ) RETURN VARCHAR2 IS

  c_throttle_flag  sa.table_x_parameters.x_param_value%TYPE := 'Y'; -- -- Possible values Y and N

BEGIN

  -- set the throttle parameter name
  BEGIN
    SELECT CASE
             WHEN i_source = 'PCRF'      AND i_carrier = 'ATT' THEN 'THROTTLE_PCRF_ATT_ESN'
             WHEN i_source = 'PCRF'      AND i_carrier = 'TMO' THEN 'THROTTLE_PCRF_TMO_ESN'
             WHEN i_source = 'PCRF'      AND i_carrier = 'VZW' THEN 'THROTTLE_PCRF_VZW_ESN'
             WHEN i_source = 'SYNIVERSE' AND i_carrier = 'ATT' THEN 'THROTTLE_SYNIVERSE_ATT_ESN'
             WHEN i_source = 'SYNIVERSE' AND i_carrier = 'TMO' THEN 'THROTTLE_SYNIVERSE_TMO_ESN'
	     ELSE NULL
           END parameter_name
    INTO   o_parameter_name
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       o_parameter_name := NULL;
  END;

  -- get the throttle flag from the parameter table
  BEGIN
    SELECT x_param_value throttle_flag
    INTO   c_throttle_flag
    FROM   sa.table_x_parameters
    WHERE  x_param_name = o_parameter_name;
   EXCEPTION
     WHEN others THEN
       c_throttle_flag := 'Y';
  END;
  --
  RETURN c_throttle_flag;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN('Y');
END fn_get_throttle_flag;

--
PROCEDURE throttle_subscriber ( i_source                 IN  VARCHAR2, -- PCRF or SYNIVERSE or TMO
                                i_min                    IN  VARCHAR2,
                                i_parent_name            IN  VARCHAR2,
                                i_usage_tier_id          IN  NUMBER,
                                i_cos                    IN  VARCHAR2 DEFAULT NULL,
                                i_policy_name            IN  VARCHAR2,
                                i_entitlement            IN  VARCHAR2 DEFAULT 'DEFAULT',
                                i_threshold_reached_time IN  DATE DEFAULT SYSDATE,
                                o_err_code               OUT NUMBER,
                                o_err_msg                OUT VARCHAR2,
                                i_last_redemption_date   IN  DATE DEFAULT NULL) IS

  ilog spr_transaction_log_type;
  --
  sub  subscriber_type  := subscriber_type();
  s    subscriber_type  := subscriber_type();
  --
  sms  spr_sms_stg_type := spr_sms_stg_type();
  sms1 spr_sms_stg_type;
  --
  pd   policy_mapping_config_type := policy_mapping_config_type();
  p1   policy_mapping_config_type := policy_mapping_config_type();
  --
  c_throttle_flag       sa.table_x_parameters.x_param_value%TYPE := 'Y';
  c_policy_name         VARCHAR2(30);
  c_transaction_num	VARCHAR2(50);
  --CR39047
  c_parameter_name      VARCHAR2(100);
  c_transaction_num_out VARCHAR2(100);
  c_trans_event_name    VARCHAR2(100);
  c_trans_event_desc	VARCHAR2(200);
  d_creation_time       DATE := SYSDATE; -- use sysdate to ignore incoming parameter
BEGIN
   data_club_pkg.handle_throttling_event ( i_esn=> util_pkg.get_esn_by_min(i_min),
                                           i_throttle_params  =>'|i_source='||i_source||
                                                '|i_min='||i_min||
                                                '|i_parent_name='||i_parent_name||
                                                '|i_usage_tier_id='||i_usage_tier_id||
                                                '|i_cos='||i_cos||
                                                '|i_policy_name='||i_policy_name||
                                                '|i_entitlement='||i_entitlement||
                                                '|i_threshold_reached_time='||
                                                to_char(i_threshold_reached_time,'MM/DD/YYYY HH24:MI:SS'),
                                           o_throttle_flag  => c_throttle_flag );
  IF (c_throttle_flag = 'N') then
  -- This is a data club LOWBALANCE auto-enrolled esn. No need to throttle
    return;

  end if;

  IF i_usage_tier_id IS NULL THEN
    o_err_code       := 10;
    o_err_msg        := 'MISSING TIER INPUT PARAMETER';

    -- Logging start of the transaction in x_spr_transaction_log
    ilog := spr_transaction_log_type ( i_min                    => i_min,
                                       i_program_step           => 'PROCESS END',
				                       i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                       i_message                => 'VALIDATING TIER',
                                       i_response_code          => o_err_code,
                                       i_response_message       => o_err_msg,
                                       i_throttle_source        => i_source,
                                       i_parent_name            => i_parent_name,
                                       i_usage_tier_id          => i_usage_tier_id,
                                       i_cos                    => i_cos,
                                       i_policy_name            => i_policy_name,
                                       i_entitlement            => i_entitlement,
                                       i_threshold_reached_time => d_creation_time,
                                       i_last_redemption_date   => i_last_redemption_date);
    --
    ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

    -- exit the routine
    RETURN;
  END IF;
  IF i_source  IS NULL THEN
    o_err_code := 11;
    o_err_msg  := 'MISSING SOURCE INPUT PARAMETER';

    -- Logging start of the transaction in x_spr_transaction_log
    ilog  := spr_transaction_log_type ( i_min                    => i_min,
                                        i_program_step           => 'PROCESS END',
                                        i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                        i_message                => 'VALIDATING SOURCE',
                                        i_response_code          => o_err_code,
                                        i_response_message       => o_err_msg,
                                        i_throttle_source        => i_source,
                                        i_parent_name            => i_parent_name,
                                        i_usage_tier_id          => i_usage_tier_id,
                                        i_cos                    => i_cos,
                                        i_policy_name            => i_policy_name,
                                        i_entitlement            => i_entitlement,
                                        i_threshold_reached_time => d_creation_time,
                                        i_last_redemption_date   => i_last_redemption_date);
    --
    ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
    RETURN;
  END IF;

  IF i_min IS NULL THEN
    o_err_code := 12;
    o_err_msg  := 'MISSING MIN INPUT PARAMETER';

    -- Logging transaction in x_spr_transaction_log
    ilog  := spr_transaction_log_type ( i_min                    => i_min,
                                        i_program_step           => 'PROCESS END',
                                        i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                        i_message                => 'VALIDATING MIN',
                                        i_response_code          => o_err_code,
                                        i_response_message       => o_err_msg,
                                        i_throttle_source        => i_source,
                                        i_parent_name            => i_parent_name,
                                        i_usage_tier_id          => i_usage_tier_id,
                                        i_cos                    => i_cos,
                                        i_policy_name            => i_policy_name,
                                        i_entitlement            => i_entitlement,
                                        i_threshold_reached_time => d_creation_time,
                                        i_last_redemption_date   => i_last_redemption_date);

    --
    ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
    --
    RETURN;
  END IF;

  IF i_source = 'PCRF' AND ( i_parent_name IS NULL OR i_usage_tier_id IS NULL )
  THEN
    o_err_code := 13;
    o_err_msg  := 'MISSING MIN/PARENT NAME/TIER INPUT PARAMETERS';

    -- Logging transaction in x_spr_transaction_log
    ilog  := spr_transaction_log_type ( i_min                    => i_min,
                                        i_program_step           => 'PROCESS END',
                                        i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                        i_message                => 'VALIDATING MIN/PARENT NAME/TIER',
                                        i_response_code          => o_err_code,
                                        i_response_message       => o_err_msg,
                                        i_throttle_source        => i_source,
                                        i_parent_name            => i_parent_name,
                                        i_usage_tier_id          => i_usage_tier_id,
                                        i_cos                    => i_cos,
                                        i_policy_name            => i_policy_name,
                                        i_entitlement            => i_entitlement,
                                        i_threshold_reached_time => d_creation_time,
                                        i_last_redemption_date   => i_last_redemption_date);

    --
    ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
    --
    RETURN;
  END IF;

  -- Syniverse SOURCE
  IF i_source = 'SYNIVERSE' THEN

    -- Syniverse should always send the policy name
    IF i_policy_name IS NULL THEN
      o_err_code     := 14;
      o_err_msg      := 'MISSING POLICY INPUT PARAMETER';

      -- Logging transaction in x_spr_transaction_log
      ilog  := spr_transaction_log_type ( i_min                    => i_min,
                                          i_program_step           => 'PROCESS END',
                                          i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                          i_message                => 'VALIDATING POLICY',
                                          i_response_code          => o_err_code,
                                          i_response_message       => o_err_msg,
                                          i_throttle_source        => i_source,
                                          i_parent_name            => i_parent_name,
                                          i_usage_tier_id          => i_usage_tier_id,
                                          i_cos                    => i_cos,
                                          i_policy_name            => i_policy_name,
                                          i_entitlement            => i_entitlement,
                                          i_threshold_reached_time => d_creation_time,
                                          i_last_redemption_date   => i_last_redemption_date);

      --
      ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
      --
      RETURN;
    END IF;
  END IF;

  -- Call constructor to get the subscriber spr row by min
  sub := subscriber_type ( i_esn => NULL ,
                           i_min => i_min );

  -- Verify if the subscriber exists
  IF sub.status <> 'SUCCESS' THEN

    -- Get the ESN for a provided min
    sub.pcrf_esn := sa.util_pkg.get_esn_by_min ( i_min => i_min );

    -- Call subscriber constructor to instantiate the subscriber values
    sub := subscriber_type (i_esn => sub.pcrf_esn );

    -- Synchronize the subscriber row after it was throttled
    s := sub.ins;

    -- Assign cos and parent when inserting a new subscriber
    sub.pcrf_cos         := s.pcrf_cos;
    sub.pcrf_parent_name := s.pcrf_parent_name;

    IF s.status NOT LIKE '%SUCCESS%' THEN
      o_err_code := 15;
      o_err_msg  := s.status; --
      -- Logging transaction in x_spr_transaction_log
      ilog := spr_transaction_log_type ( i_min                    => i_min,
                                         i_program_step           => 'PROCESS END',
                                         i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                         i_message                => 'INSERTING SPR',
                                         i_response_code          => o_err_code,
                                         i_response_message       => o_err_msg,
                                         i_throttle_source        => i_source,
                                         i_parent_name            => i_parent_name,
                                         i_usage_tier_id          => i_usage_tier_id,
                                         i_cos                    => i_cos,
                                         i_policy_name            => i_policy_name,
                                         i_entitlement            => i_entitlement,
                                         i_threshold_reached_time => d_creation_time,
                                         i_last_redemption_date   => i_last_redemption_date);
      --
      ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
      --
      RETURN;
    END IF;
  END IF;

  --
  IF sub.pcrf_cos IS NULL THEN
    o_err_code    := 16;
    o_err_msg     := 'SUBSCRIBER COS NOT FOUND';

    -- Logging transaction in x_spr_transaction_log
    ilog := spr_transaction_log_type ( i_min                    => i_min,
                                       i_program_step           => 'PROCESS END',
                                       i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                       i_message                => 'VALIDATING COS',
                                       i_response_code          => o_err_code,
                                       i_response_message       => o_err_msg,
                                       i_throttle_source        => i_source,
                                       i_parent_name            => i_parent_name,
                                       i_usage_tier_id          => i_usage_tier_id,
                                       i_cos                    => i_cos,
                                       i_policy_name            => i_policy_name,
                                       i_entitlement            => i_entitlement,
                                       i_threshold_reached_time => d_creation_time,
                                       i_last_redemption_date   => i_last_redemption_date);

    --
    ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

    --
    RETURN;
  END IF;

  -- Validate if the line is active
  IF sub.part_inst_status != 'Active' THEN

    o_err_code            := 17;
    o_err_msg             := 'LINE IS NOT ACTIVE';

    -- Logging transaction in x_spr_transaction_log
    ilog  := spr_transaction_log_type ( i_min                    => i_min,
                                        i_program_step           => 'PROCESS END',
                                        i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                        i_message                => 'VALIDATING LINE STATUS',
                                        i_response_code          => o_err_code,
                                        i_response_message       => o_err_msg,
                                        i_throttle_source        => i_source,
                                        i_parent_name            => i_parent_name,
                                        i_usage_tier_id          => i_usage_tier_id,
                                        i_cos                    => i_cos,
                                        i_policy_name            => i_policy_name,
                                        i_entitlement            => i_entitlement,
                                        i_threshold_reached_time => d_creation_time,
                                        i_last_redemption_date   => i_last_redemption_date);

    --
    ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

    --
    RETURN;
  END IF;

  -- added for x_policy_mapping_config parent name changes.
  sub.pcrf_parent_name := get_short_parent_name( i_parent_name => sub.pcrf_parent_name);
  s.pcrf_parent_name   := get_short_parent_name( i_parent_name => s.pcrf_parent_name);

  -- When the source is SYNIVERSE
  IF i_source = 'SYNIVERSE' THEN
    -- Verify if the policy name exists
    IF p1.get_policy_id ( i_policy_name => i_policy_name) <= 0 THEN

      o_err_code := 21;
      o_err_msg  := 'POLICY NAME NOT FOUND IN THROTTLING POLICY TABLE (' || i_policy_name || ')';

      -- Logging transaction in x_spr_transaction_log
      ilog := spr_transaction_log_type ( i_min                    => i_min,
                                         i_program_step           => 'PROCESS END',
                                         i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                         i_message                => 'VALIDATING POLICY',
                                         i_response_code          => o_err_code,
                                         i_response_message       => o_err_msg,
                                         i_throttle_source        => i_source,
                                         i_parent_name            => i_parent_name,
                                         i_usage_tier_id          => i_usage_tier_id,
                                         i_cos                    => i_cos,
                                         i_policy_name            => i_policy_name,
                                         i_entitlement            => i_entitlement,
                                         i_threshold_reached_time => d_creation_time,
                                         i_last_redemption_date   => i_last_redemption_date);

      --
      ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

      --
      RETURN;
    END IF;
    -- Assign policy name type value for Syniverse
    pd.policy_name := i_policy_name;
  END IF;

  -- Assign input entitlement
  p1.entitlement := i_entitlement;

  -- Override entitlement for SYNIVERSE
  IF i_source = 'SYNIVERSE' THEN
    BEGIN
      SELECT entitlement
      INTO   p1.entitlement
      FROM   sa.x_policy_mapping_config
      WHERE  cos = sub.pcrf_cos
      AND    parent_name = NVL(i_parent_name, sub.pcrf_parent_name)
      AND    usage_tier_id = i_usage_tier_id
      AND    ROWNUM = 1;
    EXCEPTION
    WHEN OTHERS THEN
      o_err_code := 22;
      o_err_msg  := 'ENTITLEMENT NOT FOUND IN POLICY MAPPING CONFIG FOR SYNIVERSE';
      -- Logging transaction in x_spr_transaction_log
      ilog := spr_transaction_log_type ( i_min                    => i_min,
                                         i_program_step           => 'PROCESS END',
                                         i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                         i_message                => 'VALIDATING ENTITLEMENT',
                                         i_response_code          => o_err_code,
                                         i_response_message       => o_err_msg,
                                         i_throttle_source        => i_source,
                                         i_parent_name            => i_parent_name,
                                         i_usage_tier_id          => i_usage_tier_id,
                                         i_cos                    => i_cos,
                                         i_policy_name            => i_policy_name,
                                         i_entitlement            => i_entitlement,
                                         i_threshold_reached_time => d_creation_time,
                                         i_last_redemption_date   => i_last_redemption_date);

      --
      ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

      --
      RETURN;
    END;
  END IF;

  -- Call constructor to get policy mapping configuration
  pd := policy_mapping_config_type ( i_cos           => NVL(i_cos, sub.pcrf_cos),
                                     i_parent_name   => NVL(i_parent_name, sub.pcrf_parent_name),
                                     i_usage_tier_id => i_usage_tier_id,
                                     i_entitlement   => p1.entitlement );


  IF pd.policy_name IS NULL OR pd.policy_objid IS NULL
  THEN
    IF i_source     != 'SYNIVERSE' THEN
      o_err_code    := 23;
      o_err_msg     := 'POLICY CONFIGURATION NOT FOUND';
      -- Logging transaction in x_spr_transaction_log
      ilog := spr_transaction_log_type ( i_min                    => i_min,
                                         i_program_step           => 'PROCESS END',
                                         i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                         i_message                => 'VALIDATING POLICY CONFIG',
                                         i_response_code          => o_err_code,
                                         i_response_message       => o_err_msg,
                                         i_throttle_source        => i_source,
                                         i_parent_name            => i_parent_name,
                                         i_usage_tier_id          => i_usage_tier_id,
                                         i_cos                    => i_cos,
                                         i_policy_name            => i_policy_name,
                                         i_entitlement            => i_entitlement,
                                         i_threshold_reached_time => d_creation_time,
                                         i_last_redemption_date   => i_last_redemption_date);

      --
      ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

      --
      RETURN;
    END IF;
  END IF;


  -- Set policy name and transaction num
  SELECT ( CASE
             WHEN i_source = 'PCRF' THEN NVL(pd.policy_name, i_policy_name)
             ELSE i_policy_name
           END ),
         ( CASE
             WHEN i_source = 'TMO' THEN 'TMOFLEX'
             ELSE i_source
           END)
  INTO   c_policy_name,
         c_transaction_num
  FROM   DUAL;
  -- Set policy name and transaction num

  -- Determine carrier parent name
  s.pcrf_parent_name := CASE
                          WHEN i_parent_name IS NULL THEN pd.parent_name
                          WHEN pd.parent_name IS NULL THEN sub.pcrf_parent_name
                          ELSE s.pcrf_parent_name
                        END;

  IF i_source != 'SYNIVERSE' THEN
    --
    BEGIN
      SELECT 1
      INTO   pd.numeric_value
      FROM   w3ci.table_x_throttling_policy
      WHERE  x_policy_name = pd.policy_name;
     EXCEPTION
      WHEN no_data_found THEN
        -- Customer is not currently throttled, so continue the process
        o_err_code := 24;
        o_err_msg  := 'POLICY NAME NOT FOUND: ' || pd.policy_name;

        -- Logging transaction in x_spr_transaction_log
        ilog := spr_transaction_log_type ( i_min                    => i_min,
                                           i_program_step           => 'PROCESS END',
                                           i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                           i_message                => 'VALIDATING THROTTLING POLICY NAME',
                                           i_response_code          => o_err_code,
                                           i_response_message       => o_err_msg,
                                           i_throttle_source        => i_source,
                                           i_parent_name            => i_parent_name,
                                           i_usage_tier_id          => i_usage_tier_id,
                                           i_cos                    => i_cos,
                                           i_policy_name            => i_policy_name,
                                           i_entitlement            => i_entitlement,
                                           i_threshold_reached_time => d_creation_time,
                                           i_last_redemption_date   => i_last_redemption_date);
        --
        ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
        --
        -- Exit the routine
        RETURN;
      WHEN OTHERS THEN
        -- Continue the process
        o_err_code := 25;
        o_err_msg  := 'ERROR SEARCHING FOR POLICY: ' || SUBSTR(SQLERRM,1,100);
        -- Logging transaction in x_spr_transaction_log
        ilog := spr_transaction_log_type ( i_min                    => i_min,
                                           i_program_step           => 'PROCESS END',
                                           i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                           i_message                => 'VALIDATING POLICY CONFIG',
                                           i_response_code          => o_err_code,
                                           i_response_message       => o_err_msg,
                                           i_throttle_source        => i_source,
                                           i_parent_name            => i_parent_name,
                                           i_usage_tier_id          => i_usage_tier_id,
                                           i_cos                    => i_cos,
                                           i_policy_name            => i_policy_name,
                                           i_entitlement            => i_entitlement,
                                           i_threshold_reached_time => d_creation_time,
                                           i_last_redemption_date   => i_last_redemption_date);
        --
        ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
        --
        RETURN;
    END;
  END IF; -- IF i_source != 'SYNIVERSE'

  -- Start of CR39047
  -- Throttling a ESN based on its Source and Carrier
  c_throttle_flag := fn_get_throttle_flag ( i_source          => i_source ,
	                                        i_carrier         => NVL(s.pcrf_parent_name,sub.pcrf_parent_name) ,
                                            o_parameter_name  => c_parameter_name );

  -- skip throttling when the parameter is set to 'N'
  IF c_throttle_flag = 'N' THEN
    o_err_code       := 0;
    o_err_msg        := 'Skipped inserting Throttling record, based on flag set for I_SOURCE:'||I_SOURCE||'; Carrier: '||NVL(s.pcrf_parent_name,sub.pcrf_parent_name);
    -- Logging start of the transaction in x_spr_transaction_log
    ilog := spr_transaction_log_type ( i_min                    => i_min,
                                       i_program_step           => 'PROCESS END',
                                       i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                       i_message                => 'SKIPPED THROTTLING',
                                       i_response_code          => o_err_code,
                                       i_response_message       => o_err_msg,
                                       i_throttle_source        => i_source,
                                       i_parent_name            => i_parent_name,
                                       i_usage_tier_id          => i_usage_tier_id,
                                       i_cos                    => i_cos,
                                       i_policy_name            => i_policy_name,
                                       i_entitlement            => i_entitlement,
                                       i_threshold_reached_time => d_creation_time,
                                       i_last_redemption_date   => i_last_redemption_date);

    --
    ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );

    o_err_msg  := 'SUCCESS';

     -- Log in the w3ci.table_x_throttling_transaction to keep track of transaction
    IF NOT w3ci.throttling.f_t_transaction ( f_rule_id              => NULL,
                                             f_min                  => i_min,
                                             f_esn                  => sub.pcrf_esn,
                                             f_transact_type        => pd.throttle_transact_type,
                                             f_transaction_date     => d_creation_time,
                                             f_transaction_num      => c_transaction_num,
                                             f_transaction_num_out  => c_transaction_num_out,
                                             f_event_name           => c_trans_event_name,
                                             f_event_desc           => c_trans_event_desc,
                                             f_error_code           => o_err_code,
                                             f_error_message        => o_err_msg,
                                             f_policy_name          => c_policy_name,
                                             f_propagate_flag_value => sub.propagate_flag,
                                             f_parent_name          => i_parent_name,
                                             f_usage_tier_id        => NVL(i_usage_tier_id,pd.usage_tier_id),
                                             f_cos                  => NVL(i_cos,pd.cos),
                                             f_entitlement          => i_entitlement,
                                             f_transact_status      => 'C',
                                             f_api_status           => 'C' ,
                                             f_api_message          => 'THROTTLING NOT PERFORMED FROM PARAMETER ' || c_parameter_name )
    THEN
      util_pkg.insert_error_tab ( i_action       => 'Call to function W3CI.throttling.f_t_transaction is failed',
                                  i_key          => i_min,
                                  i_program_name => 'service_profile_pkg.throttle_subscriber',
                                  i_error_text   => o_err_code||' - ' || o_err_msg );
    END IF;

    --
    RETURN;

  END IF;
  --End of CR39047

  -- call the original throttle process
  w3ci.throttling.sp_throttling_valve ( p_min                  => sub.pcrf_min,
                                        p_esn                  => sub.pcrf_esn,
                                        p_policy_name          => c_policy_name,
	                                    p_creation_date        => d_creation_time,
	                                    p_transaction_num      => c_transaction_num,
	                                    p_error_code           => o_err_code,
	                                    p_error_message        => o_err_msg,
	                                    p_parent_name          => NVL(s.pcrf_parent_name,sub.pcrf_parent_name),
	                                    p_propagate_flag_value => sub.propagate_flag,
	                                    p_usage_tier_id        => NVL(i_usage_tier_id,pd.usage_tier_id),
	                                    p_cos                  => NVL(i_cos , pd.cos),
	                                    p_entitlement          => NVL(i_entitlement, pd.entitlement),
	                                    p_transact_type        => pd.throttle_transact_type,
	                                    p_transact_status      => pd.throttle_transact_status ,
                                        i_last_redemption_date => i_last_redemption_date     );
  --
  IF o_err_code != 0 THEN
    RETURN;
  END IF;

  -- Call subscriber constructor to instantiate the subscriber values
  sub := subscriber_type (i_esn => sub.pcrf_esn );

   -- Determine if the customer is throttled and retrieve the throttling policy information
   -- to syncronize spr after throttling upd_spr_throttle_status
  sub.status := sub.upd_spr_throttle_status (i_esn => sub.pcrf_esn,
                                             i_min => sub.pcrf_min);

  dbms_output.put_line ('throttle spr status');
  -- Synchronize the subscriber row after it was throttled
  --s := sub.ins;

  IF pd.usage_percentage IS NULL THEN
    BEGIN
      SELECT usage_percentage
      INTO   pd.usage_percentage
      FROM   x_usage_tier
      WHERE  usage_tier_id = i_usage_tier_id;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  END IF;
  --
  IF pd.usage_percentage IS NOT NULL THEN
    -- Assign retention sms values
    sms := spr_sms_stg_type ( i_esn           => sub.pcrf_esn,
                              i_usage_percent => pd.usage_percentage );

    -- Insert retention sms row
    sms1 := sms.ins;

    IF sms1.status <> 'SUCCESS' THEN
      o_err_code   := 26;
      o_err_msg    := sms1.status;
      -- Logging transaction in x_spr_transaction_log
      ilog := spr_transaction_log_type ( i_min                    => i_min,
                                         i_program_step           => 'PROCESS END',
                                         i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                         i_message                => 'CREATING SMS',
                                         i_response_code          => o_err_code,
                                         i_response_message       => o_err_msg,
                                         i_throttle_source        => i_source,
                                         i_parent_name            => i_parent_name,
                                         i_usage_tier_id          => i_usage_tier_id,
                                         i_cos                    => i_cos,
                                         i_policy_name            => i_policy_name,
                                         i_entitlement            => i_entitlement,
                                         i_threshold_reached_time => d_creation_time,
                                         i_last_redemption_date   => i_last_redemption_date);
      --
      ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
      --
      RETURN;
    END IF;
  END IF;
  --
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';
  --


 EXCEPTION
   WHEN OTHERS THEN
     --
     o_err_code := 99;
     o_err_msg  := 'ERROR IN SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER: ' || SUBSTR(SQLERRM,1,400);

     -- Logging transaction in x_spr_transaction_log
     ilog := spr_transaction_log_type ( i_min                    => i_min,
                                        i_program_step           => 'PROCESS END',
                                        i_program_name           => 'SERVICE_PROFILE_PKG.THROTTLE_SUBSCRIBER',
                                        i_message                => 'EXCEPTION WHEN OTHERS',
                                        i_response_code          => o_err_code,
                                        i_response_message       => o_err_msg,
                                        i_throttle_source        => i_source,
                                        i_parent_name            => i_parent_name,
                                        i_usage_tier_id          => i_usage_tier_id,
                                        i_cos                    => i_cos,
                                        i_policy_name            => i_policy_name,
                                        i_entitlement            => i_entitlement,
                                        i_threshold_reached_time => d_creation_time,
                                        i_last_redemption_date   => i_last_redemption_date);
     --
     ilog.spr_transaction_log_objid := ilog.ins ( ilog.status );
     --
     RETURN;
END throttle_subscriber;

-- Function to retrieve the subscriber uid based on ESN.
FUNCTION get_subscriber_uid ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 AS

  -- Get the unique subscriber id from the member table
  CURSOR sub_uid_cur IS
    SELECT subscriber_uid
    FROM   x_account_group_member
    WHERE  esn = i_esn
    AND    status IN ('ACTIVE','PENDING_ENROLLMENT')
    ORDER BY status,
             member_order DESC;

  sub_uid_rec  sub_uid_cur%ROWTYPE;
BEGIN

  -- To restrict function calls without an esn
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- Find the UID from the account group member table
  OPEN sub_uid_cur;
  FETCH sub_uid_cur into sub_uid_rec;
  CLOSE sub_uid_cur;

  RETURN NVL(sub_uid_rec.subscriber_uid,0);
 EXCEPTION
   WHEN others THEN
     RETURN 0;
END get_subscriber_uid;


PROCEDURE get_pcrf_data_usage ( i_pcrf_transaction_id    IN NUMBER   ,
                                o_data_usage             OUT NUMBER ,
                                o_total_addon_data_usage OUT NUMBER ,
                                o_total_data_usage       OUT NUMBER ,
                                o_hi_speed_data_usage    OUT NUMBER ) IS

  -- Call the constructor (by pcrf_transaction_id) to find the pcrf transaction information
  pcrf pcrf_transaction_type := pcrf_transaction_type ( i_pcrf_transaction_id => i_pcrf_transaction_id );

  -- Call the constructor (by pcrf_transaction_id) to find the pcrf transaction information
  lpcrf pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => i_pcrf_transaction_id );

BEGIN

  IF pcrf.status NOT LIKE '%SUCCESS%' THEN
    --CR44107 added below IF statement to return if PCRF did not update the usage
   IF lpcrf.pcrf_status_code in ('Q','L') THEN
      RETURN;
   END IF;
    -- Return the pcrf_transaction_type values
    o_data_usage := lpcrf.data_usage;
    o_total_addon_data_usage := lpcrf.addon_data_balance; --CR49890 ST AddOn Balance
    --o_total_addon_data_usage := lpcrf.total_addon_data_usage;
    o_total_data_usage := lpcrf.total_data_usage;
    o_hi_speed_data_usage := lpcrf.hi_speed_data_usage;
  ELSE
    --CR44107 added below IF statement to return if PCRF did not update the usage
    IF pcrf.pcrf_status_code in ('Q','L') THEN
       RETURN;
    END IF;
    -- Return the pcrf_transaction_type values
    o_data_usage := pcrf.data_usage;
    o_total_addon_data_usage := pcrf.addon_data_balance; --CR49890 ST AddOn Balance
    --o_total_addon_data_usage := pcrf.total_addon_data_usage;
    o_total_data_usage := pcrf.total_data_usage;
    o_hi_speed_data_usage := pcrf.hi_speed_data_usage;

  END IF;

END;


-- Added new logic to replace the old W3CI.C3I_INQUIRY_PKG.GET_3CI_ESN_INQUIRY2
PROCEDURE get_esn_inquiry ( i_esn                 IN     VARCHAR2,
                            i_alt_min             IN     VARCHAR2,
                            i_alt_msid            IN     VARCHAR2,
                            i_alt_subscriber_uid  IN     VARCHAR2,
                            i_alt_wf_mac_id       IN     VARCHAR2,
                            o_subscriber          OUT    subscriber_type,
                            o_err_code            OUT    NUMBER  ,
                            o_err_msg             OUT    VARCHAR2,
                            o_mask_value          IN     VARCHAR2 DEFAULT NULL) AS

--Commented for CR45325
/*  inq  spr_inquiry_log_type := spr_inquiry_log_type ( i_esn            => i_esn,
                                                      i_min            => i_alt_min,
                                                      i_msid           => i_alt_msid,
                                                      i_subscriber_id  => i_alt_subscriber_uid,
                                                      i_wf_mac_id      => i_alt_wf_mac_id);*/
  sub  subscriber_type := subscriber_type();
  l_spr_inquiry_log_objid NUMBER; --CR45325
  --CR44729 Go Smart
  ct   customer_type  := customer_type();
  rms subscriber_type := subscriber_type();
  rs  subscriber_type := subscriber_type();
  s   subscriber_type := subscriber_type();
BEGIN

  --CR45325 - Call commented to stop logging in X_SPR_INQUERY_LOG
  -- Log inquiries to keep a trace of calling program and parameters
  --inq.spr_inquiry_log_objid := inq.ins( inq.status );


  -- Validate input parameters
  IF ( i_esn IS NULL AND
       i_alt_min IS NULL AND
       i_alt_msid IS NULL AND
       i_alt_subscriber_uid IS NULL AND
       i_alt_wf_mac_id IS NULL )
  THEN

    o_err_code := 99;
    o_err_msg := 'NO INPUT PARAMETER PASSED';

    -- Save changes
    COMMIT;

    -- Exit routine
    RETURN;

  END IF;


  IF i_esn is NOT NULL OR i_alt_min is NOT NULL OR i_alt_msid IS NOT NULL THEN

        ct.esn := NVL(i_esn,sa.util_pkg.get_esn_by_min ( NVL(i_alt_min,i_alt_msid ) ));
        ct.min := NVL(i_alt_min,sa.util_pkg.get_min_by_esn ( NVL(i_esn, ct.esn) ));


      s := subscriber_type (i_esn => ct.esn,
                            i_min => ct.min);

    IF s.status NOT LIKE '%SUCCESS%' THEN
       -- Delete SPR by ESN
       rms := subscriber_type ( i_esn => ct.esn );
       rs  := rms.remove;

       -- Delete SPR by MIN
       rms := subscriber_type ( i_esn => NULL,
                              i_min => ct.min );
       rs  := rms.remove;
    END IF;
  END IF;
  -- Call the get constructor to return the self values
  o_subscriber := sub.get ( i_esn           => i_esn,
                            i_min           => i_alt_min,
                            i_msid          => i_alt_msid,
                            i_subscriber_id => i_alt_subscriber_uid,
                            i_wf_mac_id     => i_alt_wf_mac_id,
                            o_err_code      => o_err_code,
                            o_err_msg       => o_err_msg);

  -- CR44688: changes to search for the subscriber once again when an error occurred refreshing the spr
  IF o_subscriber.status NOT LIKE '%SUCCESS%' THEN
    --
    sub := subscriber_type ( i_esn           => i_esn ,
                             i_min           => i_alt_min ,
                             i_msid          => i_alt_msid ,
                             i_subscriber_id => i_alt_subscriber_uid ,
                             i_wf_mac_id     => i_alt_wf_mac_id );
    --
    IF sub.status LIKE '%SUCCESS%' THEN
      o_subscriber := sub;
    END IF;
    --
  END IF;
  --

  -- Save changes
  COMMIT;

  --CR44729
  -- initialize customer_type
  ct := customer_type( i_esn => o_subscriber.pcrf_esn );


  -- Assign Subscriber_status
  IF o_subscriber.subscriber_status = 'ACT'
  THEN
    o_subscriber.subscriber_status := 'Active';
  END IF;


  --Added for CR45325
  SELECT sequ_spr_inquiry_log.NEXTVAL
  INTO   l_spr_inquiry_log_objid
  FROM   DUAL;

  --Added for CR45325
  -- Temporary fix for the pcrf transaction id
  --o_subscriber.pcrf_transaction_id := inq.spr_inquiry_log_objid;
  o_subscriber.pcrf_transaction_id := l_spr_inquiry_log_objid;

  -- Override propagate flag to mask the value
  BEGIN
    SELECT CASE o_subscriber.propagate_flag
             WHEN -1 THEN 0
             WHEN 0  THEN 0
             WHEN 1  THEN 1
             WHEN 2  THEN 2
             WHEN 3  THEN 0
             WHEN 4  THEN 2
             WHEN 5  THEN 0
             ELSE o_subscriber.propagate_flag
           END
    INTO   o_subscriber.propagate_flag
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;
  --

  -- Override BRAND to mask the value
  -- CR44729 GO SMART
  -- CHANGING THE HARDCODED LOGIC TO A LOOK UP ON TABLE_BUS_ORG
/*BEGIN
    SELECT CASE o_subscriber.brand
             WHEN 'NET10'          THEN 'NT'
             WHEN 'TRACFONE'       THEN 'TF'
             WHEN 'STRAIGHT_TALK'  THEN 'ST'
             WHEN 'SIMPLE_MOBILE'  THEN 'SM'
             WHEN 'TELCEL'         THEN 'TC'
             WHEN 'TOTAL_WIRELESS' THEN 'TW'
             WHEN 'PAGEPLUS'       THEN 'PP'
             ELSE o_subscriber.brand
           END
    INTO   o_subscriber.brand
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;*/

  -- GET W3CI ACRONYM
  -- FOR GO_SMART, THE LOOK UP SHOULD BE ON SUB_BRAND
  BEGIN

    SELECT w3ci_acronym
    INTO   o_subscriber.brand
    FROM   table_bus_org
    WHERE  org_id = nvl(ct.get_sub_brand, o_subscriber.brand);

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
  END;


  -- Override COS to mask the value
  BEGIN
    SELECT CASE o_subscriber.pcrf_cos
             WHEN 'DEFAULT' THEN 'TFDEFAULT'
             ELSE o_subscriber.pcrf_cos
           END
    INTO   o_subscriber.pcrf_cos
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- format conversion factor
  SELECT NVL2(o_subscriber.conversion_factor, o_subscriber.conversion_factor, '1'),
         NVL2(o_subscriber.contact_objid, o_subscriber.contact_objid, 0),
         NVL2(o_subscriber.web_user_objid, o_subscriber.web_user_objid, 0)
  INTO   o_subscriber.conversion_factor,
         o_subscriber.contact_objid,
         o_subscriber.web_user_objid
  FROM   DUAL;

  -- CR43143 hide program_parameter_id and Lifelline ID and send only 'Y/N'
  select nvl2(o_subscriber.program_parameter_id,'Y','N'),
         nvl2(o_subscriber.lifeline_id,'Y','N')
  into   o_subscriber.program_parameter_id,
         o_subscriber.lifeline_id
  from dual;
  -- CR43143 END

  -- If an error occurred return it back to the caller program
  IF o_err_code <> 0 THEN
    --
    RETURN;
    --
  END IF;


 EXCEPTION
   WHEN OTHERS THEN
     --
     o_err_code := 99;
     o_err_msg := 'ERROR IN SERVICE_PROFILE_PKG.GET_ESN_INQUIRY: ' || SQLERRM;
     RAISE;
END get_esn_inquiry;

-- CR37756 PMistry 03/03/2016 Added new procedure for Simple Mobile.
PROCEDURE get_pcrf_data_balance ( i_pcrf_transaction_id    IN  NUMBER ,
                                  o_addon_balance          OUT NUMBER ,
                                  o_hi_speed_total_balance OUT NUMBER ,
                                  o_hi_speed_balance       OUT NUMBER ,
                                  o_err_code               OUT NUMBER  ,
                                  o_err_msg                OUT VARCHAR2) AS

  --Call the constructor (by pcrf_transaction_id) to find the pcrf transaction information
  pcrf pcrf_transaction_type := pcrf_transaction_type ( i_pcrf_transaction_id => i_pcrf_transaction_id );

  -- Call the constructor (by pcrf_transaction_id) to find the pcrf transaction information
  lpcr pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => i_pcrf_transaction_id );

BEGIN

  IF pcrf.status NOT LIKE '%SUCCESS%' THEN
   --CR44107 added below IF statement to return error if PCRF did not update the usage.
    IF lpcr.pcrf_status_code in ('Q','L') THEN
      o_err_code := 1;
      o_err_msg := 'PENDING';
      RETURN;
    END IF;

    o_addon_balance          := lpcr.addon_data_balance;
    o_hi_speed_total_balance := lpcr.hi_speed_total_data_balance;
    o_hi_speed_balance       := lpcr.hi_speed_data_balance;
  ELSE
    --CR44107 added below IF statement to return error if PCRF did not update the usage.
    IF pcrf.pcrf_status_code in ('Q','L') THEN
       o_err_code := 1;
       o_err_msg := 'PENDING';
       RETURN;
    END IF;
    o_addon_balance          := pcrf.addon_data_balance;
    o_hi_speed_total_balance := pcrf.hi_speed_total_data_balance;
    o_hi_speed_balance       := pcrf.hi_speed_data_balance;
  END IF;

  o_err_code := 0;
  o_err_msg := 'SUCCESS';

 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := 99;
     o_err_msg := 'ERROR IN SERVICE_PROFILE_PKG.GET_PCRF_DATA_BALANCE: ' || SQLERRM;
     RAISE;
END get_pcrf_data_balance;


PROCEDURE create_pageplus_addon_benefit(  i_esn               IN VARCHAR2,
                                          i_min               IN VARCHAR2,
                                          i_plan_value        IN NUMBER,
                                          i_satus             IN VARCHAR2,
                                          i_start_date        IN DATE ,
                                          i_end_date          IN DATE ,
                                          i_page_stg_id       IN NUMBER,
                                          o_err_code          OUT NUMBER ,
                                          o_err_msg           OUT VARCHAR2)

AS
BEGIN
  -- Required parameters
  IF i_esn IS NULL OR i_min IS NULL THEN
    --
    o_err_code := 2;
    o_err_msg  := 'ESN/MIN is mandatory.';
    -- Exit the program
    RETURN;
  END IF;

  -- Create the account group benefit record
  INSERT
  INTO x_pageplus_addon_benefit
    ( OBJID             ,
      PCRF_ESN          ,
      PCRF_MIN          ,
      PLAN_VALUE        ,
      STATUS            ,
      START_DATE        ,
      END_DATE          ,
      PAGEPLUS_STG_ID   ,
      INSERT_TIMESTAMP  ,
      UPDATE_TIMESTAMP
     )
    VALUES
    ( sa.sequ_account_group_benefit.NEXTVAL ,
      i_esn                                 ,
      i_min                                 ,
      i_plan_value                          ,
      i_satus                               ,
      i_start_date                          ,
      i_end_date                            ,
      i_page_stg_id                         ,
      SYSDATE                               ,
      SYSDATE
     );

  o_err_code := 0;
  o_err_msg  := 'Success';
EXCEPTION
WHEN OTHERS THEN
  -- Log error message
    o_err_code := 1;
    o_err_msg  := 'Unhandled exception : ' || SQLERRM;

END create_pageplus_addon_benefit;

-- update benefit
PROCEDURE pp_upd_benefit ( i_benefit_objid IN NUMBER,
                          i_pcrf_esn       IN VARCHAR2,
                          i_pcrf_min       IN VARCHAR2,
                          i_pcrf_base_ttl  IN DATE )
AS
BEGIN
 IF i_benefit_objid IS NULL OR i_pcrf_esn IS NULL OR i_pcrf_min IS NULL THEN
    RETURN;
 END IF;

 --
 update x_pageplus_addon_benefit
 set    pcrf_esn = i_pcrf_esn,
        pcrf_min = i_pcrf_min,
        end_date = trunc(i_pcrf_base_ttl + 30) + 0.99999
 where  objid    = i_benefit_objid;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END pp_upd_benefit;


 procedure insert_pageplus_spr ( i_pcrf_min                  in  varchar2,
                                 i_pcrf_mdn                  in  varchar2,
                                 i_pcrf_esn                  in  varchar2,
                                 i_pcrf_base_ttl             in  date    ,
                                 i_pp_event_timestamp        in  date    ,
                                 i_future_ttl                in  date    ,
                                 i_brand                     in  varchar2,
                                 i_phone_manufacturer        in  varchar2,
                                 i_phone_model               in  varchar2,
                                 i_content_delivery_format   in  varchar2,
                                 i_denomination              in  varchar2,
                                 i_conversion_factor         in  varchar2,
                                 i_rate_plan                 in  varchar2,
                                 i_service_plan_type         in  varchar2,
                                 i_service_plan_id           in  number  ,
                                 i_queued_days               in  number  ,
                                 i_language                  in  varchar2,
                                 i_part_inst_status          in  varchar2,
                                 i_subscriber_spr_objid      in  number  ,
                                 i_wf_mac_id                 in  varchar2,
                                 i_subscriber_status         in  varchar2,
                                 i_zipcode                   in  varchar2,
                                 i_status                    in  varchar2,
                                 i_technology                in  varchar2,
                                 i_part_class_name           in  varchar2,
                                 i_device_type               in  varchar2,
                                 i_iccid                     in  varchar2,
                                 i_imsi                      in  varchar2,
                                 i_action                    in  varchar2,
                                 o_error_num                 out number ,
                                 o_error_text                out varchar2,
                                 i_addon_value               in  number  default null) as

   sub                 subscriber_type ;
   sub_del             subscriber_type;
   sub_old             subscriber_type := subscriber_type();
   spr                 subscriber_type := subscriber_type();
   pcrf                pcrf_transaction_type;
   c_insert_flag       varchar2(1);
   c_delete_flag       varchar2(1);
   c_update_flag       varchar2(1);
   c_redemption_flag   varchar2(1);
   c_ttoff_flag        varchar2(1);
   c_ttoff_chk_red_dt_flag  varchar2(1);
   n_bus_org_objid     number;
   n_pp_spr_stg_objid  number;
   cos_type            pageplus_pcrf_cos_type;
   n_spr_dup_count     number;

   --CR45742 adding new variable to hold return value from deactservice
   c_return_val        VARCHAR2(4000);
   n_port_out_check    NUMBER;
   n_user_objid        NUMBER := 0;
   l_addon_flag        VARCHAR2(1);
   op_account_group_id  NUMBER;
   l_service_paln_id   NUMBER;
   op_account_group_member_id NUMBER;
   op_err_code                NUMBER;
   op_err_msg                 VARCHAR2(2000);
   o_account_group_benefit_id NUMBER;
   o_account_group_member_id  NUMBER;
   --CR47275
   lv_port_out_case_error_code	VARCHAR2(10);
   lv_port_out_case_error_msg	VARCHAR2(500);

   sub_det  sa.subscriber_detail_type := sa.subscriber_detail_type ();
   sd       sa.subscriber_detail_type := sa.subscriber_detail_type ();

   --CR47275

   cursor cache_cur (c_esn in varchar2,
                     c_min in varchar2) is
    select *
    from   w3ci.table_x_throttling_cache
    where  objid in (
                     select max(objid) from w3ci.table_x_throttling_cache where x_min = c_min AND x_status in ('P','A')
                     union
                     select max(objid) from w3ci.table_x_throttling_cache WHERE x_esn = c_esn and x_status in ('P','A')
                    )
    order by x_creation_date desc;
    cache_rec cache_cur%rowtype;

    l_throttle_flag VARCHAR2(1) := 'N';


   BEGIN

   -- if the request is for esn_change, then call constructor method to populate
   -- subscriber_type using mdn instead of esn
   if i_action = 'ESN_CHANGE' then
      --dbms_output.put_line('MDN :'||i_pcrf_mdn);

      sub_old := sa.subscriber_type (i_esn => null,
                                     i_min => i_pcrf_mdn );

      sub := subscriber_type( i_esn => null,
                              i_min => i_pcrf_mdn );

      -- Also call the remove method for removing any entries of the NEW ESN from SPR table
      -- But before that, set MIN to null so that only delete by ESN flow is executed
      sub_del          := subscriber_type(i_esn => i_pcrf_esn);
      sub_del.pcrf_min := null;
      sub_del          := sub_del.remove();

     if sub_del.status != 'SUCCESS' then
        sub.status := sub_del.status;
     end if;

   elsif i_action = 'MDN_CHANGE' then

     sub_old := sa.subscriber_type (i_esn => i_pcrf_esn );

     -- For MDN Change, initialize using ESN
     sub := subscriber_type( i_esn => i_pcrf_esn );
     -- and delete the existing MDN entry
     -- But before that, set ESN to null so that only delete by MIN flow is executed
     sub_del          := subscriber_type( i_esn => null,
                                          i_min => i_pcrf_mdn);
     sub_del.pcrf_esn := null;
     sub_del          := sub_del.remove();

     if sub_del.status != 'SUCCESS' then
        sub.status := sub_del.status;
     end if;

   else
     -- otherwise, call the the constructor method using esn
     sub_old := sa.subscriber_type (i_esn => null,
                                    i_min => i_pcrf_mdn );


     sub     := subscriber_type( i_esn => i_pcrf_esn);


     --

   end if;

   if sub_old.addons.count > 0 then
     for i in 1 .. sub_old.addons.count loop
       pp_upd_benefit (sub_old.addons(i).acct_grp_benefit_objid, i_pcrf_esn, i_pcrf_mdn, i_pcrf_base_ttl);
     end loop;
   end if;

   if sub.addons.count > 0 then
     for i in 1 .. sub.addons.count loop
       pp_upd_benefit (sub.addons(i).acct_grp_benefit_objid, i_pcrf_esn, i_pcrf_mdn, i_pcrf_base_ttl);
     end loop;
   end if;

   if i_addon_value is not null then
      l_addon_flag := 'Y';
   end if;

   begin
    select objid
    into   n_bus_org_objid
    from   table_bus_org
    where  org_id = 'PAGEPLUS';
   exception
    when no_data_found then
       o_error_num := 110;
       o_error_text := 'BRAND NOT FOUND';
   end;
   --
   -- Get LAST_REDEMPTION_DATE
   if i_action = 'RESERVE_BALANCE' then
      -- Rule 4 ???? For RESERVE_BALANCE, the redemption date should be start of next day.
      sub.pcrf_last_redemption_Date := i_pcrf_base_ttl + interval '1' second;
   else
      --Rule 3 ???? Last redemption date for ALL actions OTHER THAN RESERVE_BALANCE should be calculated using below formula:
      --PCRF_LAST_REDEMPTION_DATE = (PCRF_BASE_TTL - 1 calendar month) + 1 day
      --Covert the above formula into a date and add 1 minute
      sub.pcrf_last_redemption_Date := trunc((add_months(i_pcrf_base_ttl,-1)+1));
   end if;

   --Rule 5 ???? If the last_Redemption_date calculated using above formula turns out to be in future (i.e. greater than system date), then default it to system date.
   if sub.pcrf_last_redemption_Date > sysdate then
      sub.pcrf_last_redemption_Date := sysdate;
   end if;

   -- Get COS and Propogate Flag value
   cos_type := pageplus_pcrf_cos_type(i_bundle_code     => i_service_plan_type,
                                      i_redemption_date => nvl(sub.pcrf_last_redemption_Date, SYSDATE));


   -- Create new subscriber and group IDs if empty


   -- get group id
   begin
    select pcrf_group_id, pcrf_subscriber_id
    into   sub.pcrf_group_id, sub.pcrf_subscriber_id
    from   x_subscriber_spr
    where  (pcrf_esn = i_pcrf_esn OR pcrf_min = i_pcrf_mdn);
   exception
    when others then
     sub.pcrf_group_id      := null;
     sub.pcrf_subscriber_id := null;
   end;

   if sub.pcrf_subscriber_id is null then
      sub.pcrf_subscriber_id := randomuuid();
   end if;

   if sub.pcrf_group_id is null then
      sub.pcrf_group_id := randomuuid();
   end if;

   -- Default subscriber type parameters
   sub.pcrf_cos         := cos_type.cos_value;
   sub.propagate_flag   := cos_type.propagate_flag;
   sub.bus_org_objid    := n_bus_org_objid;
   sub.pcrf_parent_name := 'VERIZON PREPAY PLATFORM';
   sub.service_plan_id  := 0;
   sub.brand            := 'PAGEPLUS';
   sub.dealer_id        := 0;
   sub.queued_days      := 0;
   sub.contact_objid    := 0;
   sub.web_user_objid   := 0;
   sub.language         := 'ENGLISH' ;

     -- Insert into pageplus staging table start
   begin
     insert
     into sa.x_pageplus_spr_staging
          ( objid                      ,
            pcrf_min                   ,
            pcrf_mdn                   ,
            pcrf_esn                   ,
            pcrf_subscriber_id         ,
            pcrf_parent_name           ,
            service_plan_id            ,
            pcrf_cos                   ,
            pcrf_base_ttl              ,
            future_ttl                 ,
            event_timestamp            ,
            brand                      ,
            phone_manufacturer         ,
            phone_model                ,
            content_delivery_format    ,
            denomination               ,
            conversion_factor          ,
            rate_plan                  ,
            propagate_flag             ,
            service_plan_type          ,
            queued_days                ,
            language                   ,
            bus_org_objid              ,
            part_inst_status           ,
            wf_mac_id                  ,
            subscriber_status_code     ,
            zipcode                    ,
            insert_timestamp           ,
            update_timestamp           ,
            imsi                       ,
            action                     ,
            spr_status                 ,
            pcrf_group_id              ,
            addon_flag
           )
     values
         ( sequ_x_pageplus_spr_staging.NEXTVAL,
           i_pcrf_min                         ,
           i_pcrf_mdn                         ,
           i_pcrf_esn                         ,
           sub.pcrf_subscriber_id             ,
           sub.pcrf_parent_name               ,
           sub.service_plan_id                ,
           sub.pcrf_cos                       ,
           i_pcrf_base_ttl                    ,
           i_future_ttl                       ,
           i_pp_event_timestamp               ,
           sub.brand                          ,
           i_phone_manufacturer               ,
           i_phone_model                      ,
           i_content_delivery_format          ,
           i_denomination                     ,
           i_conversion_factor                ,
           i_rate_plan                        ,
           sub.propagate_flag                 ,
           i_service_plan_type                ,
           sub.queued_days                    ,
           i_language                         ,
           sub.bus_org_objid                  ,
           i_part_inst_status                 ,
           i_wf_mac_id                        ,
           i_subscriber_status                , -- subscriber_status_code
           i_zipcode                          ,
           sysdate                            ,
           sysdate                            ,
           i_imsi                             ,
           upper(trim(i_action))              ,
           sub_del.status                     ,
           sub.pcrf_group_id                  ,
           l_addon_flag                       )
       returning objid into n_pp_spr_stg_objid;
    exception
     when others then
      o_error_num  := 110;
      o_error_text  := 'ERROR INSERTING PP SPR STAGING RECORD: ' || substr(dbms_utility.format_error_backtrace(),1,3000);
      return;
   end;
   -- Insert into pageplus staging table end

  --CR45742
   -- IF THE EVENT IS PORT_OUT, THEN DIRECTLY CALL DEACTSERVICE PROCEDURE
   -- NO NEED TO UPDATE THE SPR/PCRFM TABLES AS DEACTSERVICE WILL INTERNALLY CREATE DL ON PCRF
   BEGIN
     SELECT objid
     INTO   n_user_objid
     FROM   table_user
     WHERE  s_login_name = (SELECT UPPER(USER) FROM DUAL);
   EXCEPTION
    WHEN OTHERS THEN
      -- default to SA objid
      n_user_objid := 268435556;
      --RETURN;
   END;


   IF UPPER(TRIM(i_action)) = 'PORT_OUT' THEN --{
     service_deactivation_code.deactservice( ip_sourcesystem    => 'PAGEPLUS',
                                             ip_userobjid       => n_user_objid,
                                             ip_esn             => sub.pcrf_esn,
                                             ip_min             => sub.pcrf_min,
                                             ip_deactreason     => 'PORT OUT', -- REASON FROM X_DEACT_REASON_CONFIG
                                             intbypassordertype => NULL,
                                             ip_newesn          => NULL,
                                             ip_samemin         => NULL,
                                             op_return          => c_return_val,
                                             op_returnmsg       => o_error_text );

     IF UPPER(c_return_val)  = 'TRUE' THEN
        UPDATE x_pageplus_spr_staging
        SET    spr_status = 'SUCCESS'
        WHERE  objid      = n_pp_spr_stg_objid;

	      port_out_pkg.create_close_port_out_case( ip_esn	                => sub.pcrf_esn ,
                                                   ip_create_task_flag      => 'Y' ,
						                           ip_create_case_flag      => 'Y' ,
						                           ip_close_case_flag       => 'Y'  ,
						                           ip_new_service_provider	=> 'PAGE PLUS',
						                           op_error_code	        => lv_port_out_case_error_code,
						                           op_error_msg	            => lv_port_out_case_error_msg	);

     ELSE
        UPDATE x_pageplus_spr_staging
        SET    spr_status = o_error_text
        WHERE  objid      = n_pp_spr_stg_objid;
     END IF;  --UPPER(op_return)  = 'TRUE'

     -- RETURN TO CALLER, THIS IS THE END OF PROCESSING PORT_OUT
     -- REGARDLESS OF SUCCESS/FAILURE
     RETURN;
   END IF;   --IF UPPER(TRIM(i_action)) = 'PORT_OUT' --}
   -- END CHANGES FOR  CR45742
   -- Get the action flag
   begin
     select nvl(delete_flag,'N'),
            nvl(update_flag,'N'),
            nvl(insert_flag,'N'),
            nvl(redemption_flag,'N'),
            ttoff_flag,
            ttoff_chk_red_dt_flag
     into   c_delete_flag,
            c_update_flag,
            c_insert_flag,
            c_redemption_flag,
            c_ttoff_flag,
            c_ttoff_chk_red_dt_flag
     from   sa.x_pageplus_subscriber_action
     where  action_code = upper(trim(i_action));
   exception
   when no_data_found then
     o_error_num  := 112;
     o_error_text := 'ACTION CODE NOT FOUND IN x_pageplus_subscriber_action TABLE. SUBSCRIBER TABLE NOT UPDATED';

     update x_pageplus_spr_staging
        set spr_status = o_error_text
     where objid       = n_pp_spr_stg_objid;
     return;
   end;

   --CR44881
   -- Rule 1 (if pcrf_base_ttl is null then no updates on SPR/PCRF)
   if i_pcrf_base_ttl is null then
      update x_pageplus_spr_staging
      set    spr_status  = 'IGNORE - NO TTL',
             pcrf_status = 'IGNORE - NO TTL'
      where  objid       = n_pp_spr_stg_objid;
      --
      o_error_num  := 110;
      o_error_text := 'BASE TTL IS NULL, IGNORING THIS RECORD';
      return;
   end if;

   -- Get LAST_REDEMPTION_DATE

   if i_action = 'RESERVE_BALANCE' then
     --
     update x_pageplus_spr_staging
     set    renewal_processed = 'N'
     where  objid             = n_pp_spr_stg_objid;
     --
     o_error_num  := 110;
     o_error_text := 'RESERVE_BALANCE, WILL BE PROCESSED IN OVERNIGHT BATCH';
     return;
   end if;

   -- POPULATE THE SUBSCRIBER_TYPE
   -- Value sent in MDN column is used to make calls and hence thats what should be stored in MIN column of SPR and PCRF tables
   sub.pcrf_min                := i_pcrf_mdn;
   sub.pcrf_esn                := i_pcrf_esn;
   sub.pcrf_mdn                := i_pcrf_mdn;
   sub.pcrf_base_ttl           := nvl(i_pcrf_base_ttl,sub.pcrf_base_ttl) ;
   sub.future_ttl              := nvl(i_future_ttl,sub.future_ttl) ;
   --sub.phone_manufacturer      := nvl(i_phone_manufacturer,sub.phone_manufacturer) ;
   --sub.phone_model             := nvl(i_phone_model,sub.phone_model) ;
   --CR45824
   sub.phone_manufacturer      := coalesce(i_phone_manufacturer,sub.phone_manufacturer,'PP_Mnf') ;
   sub.phone_model             := coalesce(i_phone_model,sub.phone_model,'PP_Model') ;
   --End 45824
   sub.content_delivery_format := nvl(i_content_delivery_format,sub.content_delivery_format) ;
   sub.denomination            := nvl(i_denomination,sub.denomination) ;
   sub.conversion_factor       := nvl(i_conversion_factor,sub.conversion_factor) ;
   --sub.rate_plan               := nvl(i_rate_plan,sub.rate_plan) ;
   --sub.service_plan_type       := nvl(i_service_plan_type,sub.service_plan_type) ;
   --CR45824
   sub.rate_plan               := coalesce(i_rate_plan,sub.rate_plan,'PP_RP') ;
   sub.service_plan_type       := coalesce(i_service_plan_type,sub.service_plan_type,'PP_SP') ;
   --END CR45824
   sub.queued_days             := nvl(i_queued_days,sub.queued_days) ;
   --sub.part_inst_status        := nvl(i_part_inst_status,sub.part_inst_status) ;
   sub.part_inst_status        := 'Active';
   sub.subscriber_spr_objid    := nvl(i_subscriber_spr_objid,sub.subscriber_spr_objid) ;
   sub.wf_mac_id               := nvl(i_wf_mac_id,sub.wf_mac_id) ;
   sub.subscriber_status       := nvl(i_subscriber_status,sub.subscriber_status) ;
   sub.zipcode                 := nvl(i_zipcode,sub.zipcode) ;
   sub.status                  := nvl(i_status,sub.status) ;
   sub.technology              := nvl(i_technology,sub.technology) ;
   sub.part_class_name         := nvl(i_part_class_name,sub.part_class_name) ;
   sub.device_type             := nvl(i_device_type,sub.device_type) ;
   sub.iccid                   := nvl(i_iccid,sub.iccid) ;
   sub.imsi                    := nvl(i_imsi,sub.imsi) ;
   --

 --Rule 2 ???? The following 5 fields should serve as a composite primary key for ANY action. i.e. if values of these 5 fields are same as that in SPR table, ignore the transaction. SPR_STATUS and PCRF_STATUS for such entries in staging table will be updated as "IGNORE ???? DUPLICATE TRANSACTION"
   --The fields are:
   --1. PCRF_MIN (same as PCRF_MDN)
   --2. PCRF_ESN
   --3. PCRF_COS,
   --4. PCRF_BASE_TTL
   --5. PCRF_LAST_REDEMPTION_DATE
 ------check explain plan with data
  if l_addon_flag != 'Y' then
     select count(*)
     into  n_spr_dup_count
     from  x_subscriber_spr
     where pcrf_mdn                  = sub.pcrf_mdn
     and   pcrf_esn                  = sub.pcrf_esn
     and   pcrf_cos                  = sub.pcrf_cos
     and   pcrf_base_ttl             = sub.pcrf_base_ttl
     and   pcrf_last_redemption_date = sub.pcrf_last_redemption_date;

     if n_spr_dup_count > 0 then
      update x_pageplus_spr_staging
      set    spr_status        = 'IGNORE - DUPLICATE TRANSACTION',
             pcrf_status       = 'IGNORE - DUPLICATE TRANSACTION',
             -- Marking renewal processed so that it doesnt get picked in renewal job
             renewal_processed = decode(action,'RESERVE_BALANCE','Y',renewal_processed)
      where  objid             = n_pp_spr_stg_objid;
      o_error_num  := 110;
      o_error_text := 'THIS IS A DUPLICATE TRANSACTION, IGNORING THIS RECORD';
      return;
     end if;
  end if;

   if c_insert_flag = 'Y' then

     spr  := subscriber_type (i_esn => sub.pcrf_esn,
                              i_min => sub.pcrf_min );

     IF spr.status NOT LIKE '%SUCCESS%' THEN
        -- Delete SPR by ESN
        sub_del  := subscriber_type (i_esn => sub.pcrf_esn );
        sub_del  := sub_del.remove();

        -- Delete SPR by MIN
        sub_del  := subscriber_type (i_esn => NULL,
                                     i_min => sub.pcrf_min );
        sub_del  := sub_del.remove();
     END IF;

     sub.status := sub.save ( sub => sub );

   elsif c_update_flag = 'Y' then

     spr  := subscriber_type (i_esn => sub.pcrf_esn,
                              i_min => sub.pcrf_min );

     IF spr.status NOT LIKE '%SUCCESS%' THEN
        -- Delete SPR by ESN
        sub_del  := subscriber_type (i_esn => sub.pcrf_esn );
        sub_del  := sub_del.remove();

        -- Delete SPR by MIN
        sub_del  := subscriber_type (i_esn => NULL,
                                     i_min => sub.pcrf_min );
        sub_del  := sub_del.remove();
     END IF;

     sub.status := sub.save(sub => sub);

   elsif c_delete_flag = 'Y' then

     sub := sub.del(sub => sub);
   elsif c_redemption_flag = 'Y' then

     sub := sub.update_dates(sub => sub);
     null;
   else
     sub.status := 'IGNORE';
   end if;

    --insert into AGM

   if l_addon_flag = 'Y' then
      -- create benefit for addon
      create_pageplus_addon_benefit(  i_esn             => i_pcrf_esn,
                                      i_min             => i_pcrf_mdn,
                                      i_plan_value      => i_addon_value,
                                      i_satus           => 'ACTIVE',
                                      i_start_date      => SYSDATE ,
                                      i_end_date        => trunc(i_pcrf_base_ttl + 30) + 0.9999,
                                      i_page_stg_id     => n_pp_spr_stg_objid,
                                      o_err_code        => o_error_num,
                                      o_err_msg         => o_error_text);


   end if;


   -- spr detail
   IF NOT sd.pp_ins ( i_mdn => i_pcrf_mdn, o_result => sd.status ) THEN
       o_error_text := '|ERROR INSERTING ADD ONS: ' || sd.status;
   END IF;

   -- Update status in x_pageplus_spr_staging table
   update x_pageplus_spr_staging
   set spr_status = substr(sub.status,1,4000)
   where objid = n_pp_spr_stg_objid;

   if sub.status not like '%SUCCESS%' then
    o_error_num := 100;
    o_error_text := sub.status;
    return;
   end if;

   -- Instantiate pcrf transaction table in constructor
   pcrf := pcrf_transaction_type ( i_esn              => sub.pcrf_esn ,
                                   i_min              => sub.pcrf_min ,
                                   i_order_type       => 'UP'         ,
                                   i_zipcode          => sub.zipcode  ,
                                   i_sourcesystem     => 'TAS'        ,
                                   i_pcrf_status_code => 'Q'          );

     -- Call insert pcrf transaction member function to create the x_pcrf_transaction
   pcrf := pcrf.ins;

   -- Update status in x_pageplus_spr_staging table
   update x_pageplus_spr_staging
   set    pcrf_status = substr(pcrf.status,1,4000)
   where  objid = n_pp_spr_stg_objid;

   -- redundant, remove
   if pcrf.status not like '%SUCCESS%' then
     o_error_num := 110;
     o_error_text := pcrf.status;
     return;
   end if;

   --page plus unthottling
   open cache_cur (sub.pcrf_esn, sub.pcrf_min);
    fetch cache_cur into cache_rec;
    if cache_cur%found then
       close cache_cur;
       --
       if c_ttoff_chk_red_dt_flag = 'Y' THEN
          --
          if sub_old.pcrf_last_redemption_Date != sub.pcrf_last_redemption_date OR
             sub_old.pcrf_cos                  != sub.pcrf_cos                  OR
             sub_old.pcrf_subscriber_id        != sub.pcrf_subscriber_id        THEN
             --
             l_throttle_flag := 'Y';

          end if;

       end if; --red_card_flag

       if (c_ttoff_flag = 'Y' and c_ttoff_chk_red_dt_flag = 'N')
          OR l_addon_flag = 'Y'
          OR (c_ttoff_flag = 'Y' and c_ttoff_chk_red_dt_flag = 'Y' and l_throttle_flag = 'Y') then
           --
          BEGIN
           w3ci.throttling.sp_expire_cache_pp ( p_min           => sub.pcrf_min,
                                                p_esn           => sub.pcrf_esn,
                                                p_error_code    => o_error_num ,
                                                p_error_message => o_error_text,
                                                p_source        => 'PAGEPLUS_EVENT',
                                                i_cos           => sub.pcrf_cos,
                                                i_threshold     => NULL);

          EXCEPTION
            WHEN OTHERS THEN
              o_error_text := SQLERRM;
              sa.ota_util_pkg.err_log ( p_action       => 'PAGEPLUS_TTOFF_EVENT',
                                        p_error_date   => SYSDATE ,
                                        p_key          => nvl(sub.pcrf_esn, sub.pcrf_min) ,
                                        p_program_name => 'SERVICE_PROFILE_PKG' ,
                                        p_error_text   => o_error_text);
          END;
       end if; --ttoff
    else
      close cache_cur;
    end if; --cache_cur

   --
   o_error_num := 0;
   o_error_text := 'SUCCESS';

   exception
    when others then
      o_error_num := 999;
      o_error_text := 'ERROR CREATING PAGEPLUS SPR: ' || SQLERRM;
 end insert_pageplus_spr;

 -- CR44881 Added new procedure for page_plus_renewals
 procedure process_pageplus_renewal
 is
  sub  subscriber_type;
  sub_del  subscriber_type := subscriber_type();
  pcrf pcrf_transaction_type;

  sub_det  sa.subscriber_detail_type := sa.subscriber_detail_type ();
  sd       sa.subscriber_detail_type := sa.subscriber_detail_type ();

  cursor cache_cur (c_esn in varchar2,
                    c_min in varchar2) is
  select *
  from   w3ci.table_x_throttling_cache
  where  objid in (select max(objid) from w3ci.table_x_throttling_cache where x_min = c_min AND x_status in ('P','A')
                   union
                   select max(objid) from w3ci.table_x_throttling_cache WHERE x_esn = c_esn and x_status in ('P','A'))
  order by x_creation_date desc;
  cache_rec cache_cur%rowtype;
  o_error_num number;
  o_error_text varchar2 (500);

 begin
  for pp_ren_cur in ( select *
                      from   x_pageplus_spr_staging
                      where  action            = 'RESERVE_BALANCE'
                      and    renewal_processed = 'N'
                      and    pcrf_base_ttl     <= sysdate
                      )
  loop

   -- mdn and esn
   sub := subscriber_type( i_esn => pp_ren_cur.pcrf_esn,
                           i_min => pp_ren_cur.pcrf_mdn );

-- CR56198 BEGIN.
   IF sub.status NOT LIKE '%SUCCESS%' THEN
      -- mdn only
      sub := subscriber_type( i_esn => NULL,
                              i_min => pp_ren_cur.pcrf_mdn );

      IF sub.status NOT LIKE '%SUCCESS%' THEN
         -- esn only
         sub := subscriber_type( i_esn => pp_ren_cur.pcrf_esn);
         --
         IF sub.status LIKE '%SUCCESS%' THEN
            -- dummy mdn exists
            sub_del := subscriber_type( i_esn => NULL,
                                        i_min => pp_ren_cur.pcrf_mdn);
            IF sub_del.pcrf_esn <> sub.pcrf_esn THEN
               sub_del  := sub_del.remove();
            END IF;
         END IF;
      ELSE -- mdn exits
         -- dummy esn exists in SPR
         sub_del := subscriber_type( i_esn => pp_ren_cur.pcrf_esn);
         IF sub_del.pcrf_min <> sub.pcrf_min THEN
            sub_del  := sub_del.remove();
         END IF;
         --
      END IF;
   END IF;

   BEGIN
    SELECT pcrf_group_id
    INTO   sub.pcrf_group_id
    FROM   sa.x_subscriber_spr
    WHERE  (pcrf_min = pp_ren_cur.pcrf_mdn OR pcrf_esn = pp_ren_cur.pcrf_esn)
    AND    ROWNUM < 2;
   EXCEPTION
    WHEN OTHERS THEN
     NULL;
   END;
-- CR56198 ENDS

   --populate subscriber type
   sub.pcrf_base_ttl             := add_months(pp_ren_cur.pcrf_base_ttl,1);
   sub.future_ttl                := add_months(pp_ren_cur.future_ttl,1);
   sub.pcrf_min                  := pp_ren_cur.pcrf_mdn;
   sub.pcrf_esn                  := pp_ren_cur.pcrf_esn;
   sub.pcrf_mdn                  := pp_ren_cur.pcrf_mdn;
   sub.pcrf_last_redemption_Date := pp_ren_cur.pcrf_base_ttl + interval '1' second;
   sub.pcrf_parent_name          := pp_ren_cur.pcrf_parent_name;
   sub.service_plan_id           := pp_ren_cur.service_plan_id;
   sub.pcrf_cos                  := pp_ren_cur.pcrf_cos;
   sub.propagate_flag            := pp_ren_cur.propagate_flag;
   sub.dealer_id                 := 0;
   sub.queued_days               := pp_ren_cur.queued_days;
   sub.brand                     := pp_ren_cur.brand;
   sub.bus_org_objid             := pp_ren_cur.bus_org_objid;
   sub.service_plan_type         := coalesce( pp_ren_cur.service_plan_type,sub.service_plan_type,'PP_SP' );
   sub.language                  := coalesce( pp_ren_cur.language,sub.language,'ENGLISH' );
   --sub.part_inst_status          := nvl(pp_ren_cur.part_inst_status,sub.part_inst_status);
   sub.part_inst_status          := 'Active';
   sub.wf_mac_id                 := nvl(pp_ren_cur.wf_mac_id,sub.wf_mac_id);
   sub.zipcode                   := nvl(pp_ren_cur.zipcode,sub.zipcode);
   sub.imsi                      := nvl(pp_ren_cur.imsi,sub.imsi);
   sub.pcrf_subscriber_id        := nvl(sub.pcrf_subscriber_id,pp_ren_cur.pcrf_subscriber_id);
   sub.pcrf_group_id             := nvl(sub.pcrf_group_id,pp_ren_cur.pcrf_group_id);
   sub.phone_manufacturer        := coalesce(pp_ren_cur.phone_manufacturer,sub.phone_manufacturer,'PP_Mnf');
   sub.phone_model               := coalesce(pp_ren_cur.phone_model,sub.phone_model,'PP_Model');
   sub.content_delivery_format   := nvl(pp_ren_cur.content_delivery_format,sub.content_delivery_format);
   sub.denomination              := nvl(pp_ren_cur.denomination,sub.denomination);
   sub.conversion_factor         := nvl(pp_ren_cur.conversion_factor,sub.conversion_factor);
   sub.rate_plan                 := coalesce(pp_ren_cur.rate_plan,sub.rate_plan,'PP_RP');
   sub.subscriber_status         := nvl(pp_ren_cur.subscriber_status_code, sub.subscriber_status);

   -- CALL THE SAVE METHOD TO INSERT THE SPR
   sub.status := sub.save ( sub => sub );

   if sub.status LIKE '%SUCCESS%' then

     --
     for i in 1 .. sub.addons.count loop
        pp_upd_benefit (sub.addons(i).acct_grp_benefit_objid, sub.pcrf_esn, sub.pcrf_min, sub.pcrf_base_ttl);
     end loop;

     -- spr detail
     IF NOT sd.pp_ins ( i_mdn => sub.pcrf_min, o_result => sd.status ) THEN
       o_error_text := '|ERROR INSERTING ADD ONS: ' || sd.status;
     END IF;

     -- Instantiate pcrf transaction table in constructor
     pcrf := pcrf_transaction_type ( i_esn              => sub.pcrf_esn ,
                                     i_min              => sub.pcrf_min ,
                                     i_order_type       => 'UP'         ,
                                     i_zipcode          => sub.zipcode  ,
                                     i_sourcesystem     => 'TAS'        ,
                                     i_pcrf_status_code => 'Q'          );

      -- Call insert pcrf transaction member function to create the x_pcrf_transaction
     pcrf := pcrf.ins;

     -- Update status in x_pageplus_spr_staging table
     update x_pageplus_spr_staging
     set    spr_status        = 'SUCCESS',
            pcrf_group_id     = sub.pcrf_group_id,
            pcrf_subscriber_id = sub.pcrf_subscriber_id,
            pcrf_status       = substr(pcrf.status,1,4000),
            renewal_processed = 'Y'
     where  objid             = pp_ren_cur.objid;
   else
    update x_pageplus_spr_staging
    set    spr_status        = substr(sub.status,1,4000),
            pcrf_group_id     = sub.pcrf_group_id,
            pcrf_subscriber_id = sub.pcrf_subscriber_id,
            renewal_processed = 'Y'
    where  objid             = pp_ren_cur.objid;
   end if;

   --page plus unthottling
   if sub.status LIKE '%SUCCESS%' then
      open cache_cur (sub.pcrf_esn, sub.pcrf_min);
      fetch cache_cur into cache_rec;
         if cache_cur%found then
            close cache_cur;
            --
            BEGIN
               w3ci.throttling.sp_expire_cache_pp ( p_min           => sub.pcrf_min,
                                                    p_esn           => sub.pcrf_esn,
                                                    p_error_code    => o_error_num ,
                                                    p_error_message => o_error_text,
                                                    p_source        => 'PAGEPLUS_EVENT',
                                                    i_cos           => sub.pcrf_cos,
                                                    i_threshold     => NULL);
            EXCEPTION
              WHEN OTHERS THEN
                o_error_text := SQLERRM;
                sa.ota_util_pkg.err_log ( p_action       => 'PAGEPLUS_TTOFF_EVENT_RENEWAL',
                                          p_error_date   => SYSDATE ,
                                          p_key          => nvl(sub.pcrf_esn, sub.pcrf_min) ,
                                          p_program_name => 'SERVICE_PROFILE_PKG' ,
                                          p_error_text   => o_error_text);
            END;
         else
           close cache_cur;
         end if; --cache_cur
   end if; --sub status

  end loop;
 end;

--New procedure get_subscriber_info added for CR45325
PROCEDURE get_subscriber_info ( i_esn                 IN     VARCHAR2,
                                i_alt_min             IN     VARCHAR2,
                                i_alt_msid            IN     VARCHAR2,
                                i_alt_subscriber_uid  IN     VARCHAR2,
                                i_alt_wf_mac_id       IN     VARCHAR2,
                                o_subscriber          OUT    subscriber_type,
                                o_err_code            OUT    NUMBER  ,
                                o_err_msg             OUT    VARCHAR2,
                                o_mask_value          IN     VARCHAR2 DEFAULT NULL) AS
--Commented for CR45325
/*  inq  spr_inquiry_log_type := spr_inquiry_log_type ( i_esn            => i_esn,
                                                      i_min            => i_alt_min,
                                                      i_msid           => i_alt_msid,
                                                      i_subscriber_id  => i_alt_subscriber_uid,
                                                      i_wf_mac_id      => i_alt_wf_mac_id); */
  sub  subscriber_type := subscriber_type();
  l_spr_inquiry_log_objid NUMBER; --CR45325
BEGIN

  --CR45325 - Call commented to stop logging in X_SPR_INQUERY_LOG
  -- Log inquiries to keep a trace of calling program and parameters
  --inq.spr_inquiry_log_objid := inq.ins( inq.status );


  -- Validate input parameters
  IF ( i_esn IS NULL AND
       i_alt_min IS NULL AND
       i_alt_msid IS NULL AND
       i_alt_subscriber_uid IS NULL AND
       i_alt_wf_mac_id IS NULL )
  THEN
    o_err_code := 99;
    o_err_msg := 'NO INPUT PARAMETER PASSED';
    -- Exit routine
    RETURN;
  END IF;

  -- CR44688: changes to search for the subscriber once again when an error occurred refreshing the spr
    sub := subscriber_type ( i_esn           => i_esn ,
                             i_min           => i_alt_min ,
                             i_msid          => i_alt_msid ,
                             i_subscriber_id => i_alt_subscriber_uid ,
                             i_wf_mac_id     => i_alt_wf_mac_id );
    --
    IF sub.status LIKE '%SUCCESS%' THEN
      o_subscriber := sub;
    END IF;

    -- Save changes
  COMMIT;

  -- Assign Subscriber_status
  IF o_subscriber.subscriber_status = 'ACT'
  THEN
    o_subscriber.subscriber_status := 'Active';
  END IF;


  --Added for CR45325
  BEGIN --{
   SELECT sequ_spr_inquiry_log.NEXTVAL
   INTO   l_spr_inquiry_log_objid
   FROM   DUAL;
  EXCEPTION
   WHEN OTHERS THEN
   o_err_code := 99;
   o_err_msg  := 'ERROR IN get_subscriber_info sequ_spr_inquiry_log: ' || SQLERRM;
  END; --}

  --Added for CR45325
  -- Temporary fix for the pcrf transaction id
  -- o_subscriber.pcrf_transaction_id := inq.spr_inquiry_log_objid;
  o_subscriber.pcrf_transaction_id := l_spr_inquiry_log_objid;

  -- Override propagate flag to mask the value
  BEGIN
    SELECT CASE o_subscriber.propagate_flag
             WHEN -1 THEN 0
             WHEN 0  THEN 0
             WHEN 1  THEN 1
             WHEN 2  THEN 2
             WHEN 3  THEN 0
             WHEN 4  THEN 2
             WHEN 5  THEN 0
             ELSE o_subscriber.propagate_flag
           END
    INTO   o_subscriber.propagate_flag
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;
  --

  -- Override BRAND to mask the value
  BEGIN
    SELECT CASE o_subscriber.brand
             WHEN 'NET10'          THEN 'NT'
             WHEN 'TRACFONE'       THEN 'TF'
             WHEN 'STRAIGHT_TALK'  THEN 'ST'
             WHEN 'SIMPLE_MOBILE'  THEN 'SM'
             WHEN 'TELCEL'         THEN 'TC'
             WHEN 'TOTAL_WIRELESS' THEN 'TW'
             WHEN 'PAGEPLUS'       THEN 'PP'
             ELSE o_subscriber.brand
           END
    INTO   o_subscriber.brand
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- Override COS to mask the value
  BEGIN
    SELECT CASE o_subscriber.pcrf_cos
             WHEN 'DEFAULT' THEN 'TFDEFAULT'
             ELSE o_subscriber.pcrf_cos
           END
    INTO   o_subscriber.pcrf_cos
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- format conversion factor
  SELECT NVL2(o_subscriber.conversion_factor, o_subscriber.conversion_factor, '1'),
         NVL2(o_subscriber.contact_objid, o_subscriber.contact_objid, 0),
         NVL2(o_subscriber.web_user_objid, o_subscriber.web_user_objid, 0)
  INTO   o_subscriber.conversion_factor,
         o_subscriber.contact_objid,
         o_subscriber.web_user_objid
  FROM   DUAL;

  -- CR43143 hide program_parameter_id and Lifelline ID and send only 'Y/N'
  select nvl2(o_subscriber.program_parameter_id,'Y','N'),
         nvl2(o_subscriber.lifeline_id,'Y','N')
  into   o_subscriber.program_parameter_id,
         o_subscriber.lifeline_id
  from dual;
  -- CR43143 END

  -- If an error occurred return it back to the caller program
  IF o_err_code <> 0 THEN
    --
    RETURN;
    --
  END IF;


 EXCEPTION
   WHEN OTHERS THEN
     --
     o_err_code := 99;
     o_err_msg := 'ERROR IN SERVICE_PROFILE_PKG.GET_SUBSCRIBER_INFO: ' || SQLERRM;
     RAISE;
END get_subscriber_info;

--CR47564 Start
--New procedure to update program parameter id in x_subscription_spr
PROCEDURE update_program_parameter (i_min                IN    VARCHAR2,
                                    i_part_class_name    IN    VARCHAR2,
                                    i_action             IN    VARCHAR2,
                                    o_err_code           OUT   NUMBER,
                                    o_err_msg            OUT   VARCHAR2)
AS
  sub                 sa.subscriber_type := sa.subscriber_type();
  n_program_param_id  NUMBER:=NULL;
BEGIN
  IF   i_action IS NULL
    OR i_part_class_name IS NULL
    OR i_min IS NULL
  THEN
    o_err_code := '101';
    o_err_msg := 'Required inputs cannot be null. All inputs min, part calss and action are required';
    RETURN;
  END IF;

  IF i_action = 'ENROLL' THEN
    BEGIN
      SELECT pc_objid
      INTO   n_program_param_id
      FROM   sa.pcpv_mv
      WHERE  part_class = i_part_class_name;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;
  END IF;

   --Invoking the member function of subscriber type
  sub.status := sub.update_program_param_id ( i_min	             =>	i_min,
                                              i_program_param_id => n_program_param_id);

  IF sub.status = 'SUCCESS'
  THEN
    o_err_code := 0;
  ELSE
    o_err_code := 101;
    o_err_msg := sub.status;
  END IF;

EXCEPTION
	 WHEN OTHERS
	 THEN
		 sub.status := 'Unexpected error in SERVICE_PROFILE_PKG.update_program_parameter. Error-'||SUBSTR(SQLERRM,1,2000);
		 o_err_code := 102;
		 o_err_msg := sub.status;
END update_program_parameter;
--CR47564 end

END SERVICE_PROFILE_PKG;
/