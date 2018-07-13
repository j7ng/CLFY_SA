CREATE OR REPLACE PACKAGE BODY sa."ALERT_PKG"
as
-- OVERLOADED get_alert line 1316
 --
 --********************************************************************************
 --$RCSfile: ALERT_PKG.sql,v $
 --$Revision: 1.98 $
 --$Author: tbaney $
 --$Date: 2018/03/30 21:25:59 $
 --$ $Log: ALERT_PKG.sql,v $
 --$ Revision 1.98  2018/03/30 21:25:59  tbaney
 --$ Added pragma and domain for table part inst.
 --$
 --$ Revision 1.97  2018/03/30 20:23:48  tbaney
 --$ Added nvl logic due to removing table default.
 --$
 --$ Revision 1.96  2018/03/21 20:13:39  tbaney
 --$ CR55585  Removed  'ACTIVATION_PG'
 --$
 --$ Revision 1.95  2018/03/05 23:25:04  rkommineni
 --$ Added one more input parameter to outage_alerts proc
 --$
 --$ Revision 1.94  2018/03/05 20:00:18  tbaney
 --$ Merged code
 --$
 --$ Revision 1.93  2018/03/02 17:17:47  rkommineni
 --$ moved the zipcode code to exception .
 --$
 --$ Revision 1.92  2018/02/27 18:26:19  rkommineni
 --$ Changes for CR55585 to capture zip code
 --$
 --$ Revision 1.91  2018/02/27 18:21:12  rkommineni
 --$ no changes, latest prod copy has been placed for CR55585 Changes
 --$
 --$ Revision 1.90  2018/02/09 19:41:11  rkommineni
 --$ added logic for Outage message should be displayed only for Redemptions
 --$
 --$ Revision 1.88  2018/02/05 16:52:16  rkommineni
 --$ commetns added for outage_alerts
 --$
 --$ Revision 1.86  2018/02/02 16:27:12  rkommineni
 --$ cr55994 multiline changes are in place
 --$
 --$ Revision 1.85  2018/01/31 19:05:07  rkommineni
 --$ Added logic for multi line check CR55994
 --$
 --$ Revision 1.83  2017/11/30 22:55:55  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$ issue w/defect 33724. removed display of message if zipcode is missing
 --$
 --$ Revision 1.82  2017/11/29 14:24:12  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$
 --$ Revision 1.81  2017/11/28 00:41:27  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$
 --$ Revision 1.80  2017/11/21 19:01:12  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$
 --$ Revision 1.79  2017/11/20 21:06:45  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$
 --$ Revision 1.78  2017/11/10 20:01:30  tbaney
 --$ Added new procedure set_carrier_outage_switch CR52609
 --$
 --$ Revision 1.77  2017/11/10 15:18:12  tbaney
 --$ Corrected typo.  CR52609
 --$
 --$ Revision 1.76  2017/11/08 16:14:57  tbaney
 --$ Added CDMA Logic
 --$
 --$ Revision 1.75  2017/11/02 19:40:24  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$
 --$ Revision 1.74  2017/10/24 09:59:12  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$
 --$ Revision 1.73  2017/10/24 09:54:07  hcampano
 --$ CR52609 ALL BRANDS - ALL - Send a message to customers during maintenance outages periods - additional commit
 --$
 --$ Revision 1.72  2017/10/13 14:05:31  hcampano
 --$ CR52609 All BRANDS - ALL - Send a message to customers during maintenance outages periods
 --$
 --$ Revision 1.71  2017/07/03 17:08:14  hcampano
 --$ CR51507	- Migration Campaign Content Control
 --$
 --$ Revision 1.70  2017/06/27 16:18:45  sraman
 --$ CR51293 - Added Winback Alert
 --$
 --$ Revision 1.69  2017/06/26 17:22:48  hcampano
 --$ CR51293 - Winback Verizon customers
 --$
 --$ Revision 1.68  2017/02/13 18:16:53  hcampano
 --$ CR47177 - TMO Band Two Migration
 --$
 --$ Revision 1.65  2016/05/19 15:36:47  hcampano
 --$ CR43010 - Block ATT Reacts + CR42592 Soft flash
 --$
 --$ Revision 1.64  2016/05/19 14:57:30  hcampano
 --$ CR43010 - Block ATT Reacts + CR42592 Soft flash
 --$
 --$ Revision 1.63  2016/05/04 12:43:23  hcampano
 --$ Alert change for 5/14 block per Jessica Rymer to prevent reactivations even after case gets created
 --$
 --$ Revision 1.62  2016/04/20 17:05:23  hcampano
 --$ CR40993 - 2G Migration Project - Simplified Activation - MERGED WITH  v1.61 vyegnamurthy's version
 --$
 --$ Revision 1.60  2016/04/14 16:41:59  hcampano
 --$ CR40993 - 2G Migration Project - Simplified Activation
 --$
 --$ Revision 1.59  2016/03/14 12:48:42  hcampano
 --$ NO CR YET - 2G Migration - Phase 2
 --$
 --$ Revision 1.58  2016/03/11 14:24:46  hcampano
 --$ NO CR YET - 2G Migration - Phase 2
 --$
 --$ Revision 1.57  2016/03/11 14:19:32  hcampano
 --$ NO CR YET - 2G Migration - Phase 2
 --$
 --$ Revision 1.56  2016/03/08 19:24:47  hcampano
 --$ NO CR YET - 2G Migration - Phase 2
 --$
 --$ Revision 1.55  2016/03/08 19:22:43  hcampano
 --$ CR41507 - 2G Post Launch Minor Fixes
 --$
 --$ Revision 1.54  2016/03/04 15:45:27  hcampano
 --$ NO CR YET - 2G Migration - Phase 2
 --$
 --$ Revision 1.53  2016/03/04 14:38:47  hcampano
 --$ CR41507 - 2G Post Launch Minor Fixes
 --$
 --$ Revision 1.52  2016/03/04 14:36:58  hcampano
 --$ 40990 - 2G Migration Project ? Micro Site
 --$
 --$ Revision 1.51  2016/03/01 14:25:31  hcampano
 --$ 40990 - 2G Migration Project ? Micro Site (fixing sql index defect)
 --$
 --$ Revision 1.50  2016/02/26 20:03:49  hcampano
 --$ 40990 - 2G Migration Project ? Micro Site
 --$
 --$ Revision 1.49  2016/02/03 17:40:58  skota
 --$ for CR40349
 --$
 --$ Revision 1.48  2016/01/30 22:08:48  skota
 --$ Modified for flash 40349
 --$
 --$ Revision 1.47  2016/01/26 23:37:05  skota
 --$ flash for 2g turn down
 --$
 --$ Revision 1.45  2015/10/16 20:39:36  smeganathan
 --$ CR38680  changes to include APP
 --$
 --$ Revision 1.44  2015/10/12 22:27:30  skota
 --$ modified
 --$
 --$ Revision 1.43  2015/10/12 22:04:08  skota
 --$ MODIFIED FOR DEFAULT FLASHES
 --$
 --$ Revision 1.42  2015/10/06 15:28:27  skota
 --$ Merged with latest productuoin copy
 --$
 --$ Revision 1.41  2015/09/30 21:10:31  skota
 --$ modified for the hot attribute
 --$
 --$ Revision 1.40  2015/09/15 13:23:46  skota
 --$ signature chnages in get alert procedure to make flashes invidual
 --$
 --$ Revision 1.37  2015/08/24 14:36:34  rpednekar
 --$ CR37101 - Added and modifed start date and end date conditons in cursors of get_alert procedure.
 --$
  --$ Revision 1.36  2015/08/19 14:27:00  ddevaraj
  --$ fOR CR37036
  --$
  --$ Revision 1.31  2015/08/07 15:48:04  ddevaraj
  --$ For CR36723
  --$
  --$ Revision 1.27  2015/07/21 19:00:25  rpednekar
  --$ Added cancel logic in cursor part_class_flash_cur in get_alert procedure.
  --$
  --$ Revision 1.25  2015/07/20 22:03:34  rpednekar
  --$ Changed if condition in cancel_alert procedure.  Changed place of opening cursor SAFELINK_FLASH_CUR.
  --$
  --$ Revision 1.24  2015/06/11 13:36:53  jarza
  --$ CR33579 - no change
  --$
  --$ Revision 1.23  2015/05/29 16:10:51  ddevaraj
  --$ for cr34722
  --$
  --$ Revision 1.22  2015/05/26 19:15:44  ddevaraj
  --$ For CR34722
  --$
  --$ Revision 1.21  2015/05/22 15:12:07  jarza
  --$ CR33579 - added start date and end date
  --$
  --$ Revision 1.19  2014/06/24 14:34:20  rramachandran
  --$ CR29510 - Safelink Alabama Short-term e911 fee solution
  --$
  --$ Revision 1.18  2014/01/28 17:41:39  icanavan
  --$ added new flash for part numbers
  --$
  --$ Revision 1.17  2013/07/11 15:10:56  ymillan
  --$ CR24422
  --$
  --$ Revision 1.16  2013/07/10 22:17:44  ymillan
  --$ CR227999 CR24253
  --$
  --$ Revision 1.15  2013/05/06 19:14:05  ymillan
  --$ CR23889
  --$
  --$ Revision 1.14  2013/02/22 20:58:22  ymillan
  --$ CR22487
  --$
  --$ Revision 1.12  2012/10/09 21:38:59  icanavan
  --$ ADDED WEBTEXT FOR HOMEPHONE
  --$
  --$ Revision 1.11  2012/10/04 13:21:21  icanavan
  --$ NEW HOMEPHONE ALERT
  --$
  --$ Revision 1.10  2012/05/17 16:48:46  mmunoz
  --$ Removing  the comment
  --$
  --$ Revision 1.9  2012/05/08 21:52:30  mmunoz
  --$ CR20202 flash for handsets enrolled in HMOs
  --$
  --$ Revision 1.8  2012/04/03 19:01:05  kacosta
  --$ CR19725 WebCSR Flash for Lifeline TX for TF and NT
  --$
  --$
  --********************************************************************************
  --
  /*****************************************************************
  * Package Body Name: alert_pkg
  * Purpose     : Get Messages
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Natalio GUada
  * Date        : 06/12/2005
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE          WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0      06/12/2006    Nguada     Initial Revision (CR4640)
  *              1.1      12/04/2006    Nguada     Generic Message by Status (CR5722-2)
  *              1.2      12/04/2006    Nguada     Generic Message by Status (CR5722-2)
  *              1.3      12/04/2006    Nguada     Generic Message by Status (CR5722-2)
  *              1.4      02/07/2007    TyZhou     Plus 30 Program content update for add airtime flow. (CR5925)
  *              1.5      02/08/2007    TyZhou     Add nvl function for GENERIC alert cursor. (CR5925)
  *              1.6      02/21/2007    TyZhou     Modify the count condition:
  The FLASH will end after the second redemption using the counter functionality. (CR5925)
  *              1.7      06/06/2007    Nguada     search for flash associtated to Contact (CR6376)
  *              1.1      12/06/2007    Nguada     CR7040
  *              1.2      07/11/2008    Nguada     CR7605 Generic Flash Unlimited
  *              1.3      07/15/2008    Nguada     CR7512 Life Line
  *              1.4      07/15/2008    Nguada     CR7512 Life Line
  *              1.5      07/15/2008    Nguada     CR7512 Life Line
  *              1.6      07/16/2009    AKhan      added slash
  *              1.7      08/27/2009    NGuada     BRAND_SEP Separate the Brand and Source System
  *              1.8      06/16/2009    NGuada     Step
  *              CVS
  *              1.4      11/22/2011    ICanavan   part class promo flash
  *              1.5/1.7  01/27/2012    ICanavan   CR19552 BYOP Activation Flash
  *              1.11     10/04/2012    ICanavan   CR22131 HOMEPHONE flash
  *              1.13/1.14 02/15/2013   YMillan    CR22487 NET10 HOMEPHONE flash
  *              1.18     01/28/2014    ICANAVAN   CR27301 NEW FLASH BY PART NUMBERS
  ***************************************************************************************/
  --CR5925
PROCEDURE dynamic_sql(
    sqlstr VARCHAR2,
    esn    VARCHAR2,
    err OUT VARCHAR2,
    f_count OUT BOOLEAN )
IS
  count_value NUMBER := 0;
BEGIN
  err     := '0';
  f_count := FALSE;
  EXECUTE IMMEDIATE sqlstr INTO count_value USING esn;
  IF count_value > 0 THEN
    f_count     := TRUE;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  err := SQLERRM;
END;
  -- THIS IS THE ORIGINAL SIGNATURE
  -- WHICH NOW CALLS THE NEW ONE

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- OVERLOADED get_alert
--------------------------------------------------------------------------------
            procedure get_alert ( esn            varchar2,
                                  step           number,
                                  channel        varchar2 default 'IVR',     -- Channel to display flash   --CR37075
                                  title          out varchar2, -- Alert Title
                                  csr_text       out varchar2, -- Text to be used in WEBCSR
                                  eng_text       out varchar2, -- Web Text English
                                  spa_text       out varchar2, -- Web Text Spanish
                                  ivr_scr_id     out varchar2, -- IVR script ID
                                  tts_english    out varchar2, -- Text to Speech English
                                  tts_spanish    out varchar2, -- Text to Speech Spanish
                                  hot            out varchar2, -- 0 Let customer continue, 1 Transfer
                                  err            out varchar2, -- Error Number
                                  msg            out varchar2,-- Additional Messages
                                  op_url         out varchar2,
                                  op_url_text_en out varchar2,
                                  op_url_text_es out varchar2,
                                  op_sms_text    out varchar2,
                                  alert_objid           out varchar2,  -- OVERLOADED -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                                  is_alert_suppressible out varchar2)  -- OVERLOADED -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
            is
              ------------------------------------------------------------------
              -- PLUGGING IN NEW 2G VARIABLES
              ------------------------------------------------------------------
              v_part_inst_status varchar2(30);
              v_phone_gen varchar2(30);
              v_brand varchar2(30);
              v_x_queue_name varchar2(30);
              v_class_name varchar2(30);
              v_zipcode table_site_part.x_zipcode%type;
              v_customer_min varchar2(100);
              ------------------------------------------------------------------
              v_not_used varchar2(200);


              -- Additional Messages
              -- BRAND_SEP
              l_safelink_in number := 0;

              cursor c_alert( esn varchar2, step number )
              is
                select al.*
                from sa.table_alert al,
                  sa.table_part_inst pi
                where (alert2contract = pi.objid
                or alert2contact      = pi.x_part_inst2contact)
                and pi.part_serial_no = esn
                and pi.x_domain       = 'PHONES'
                and al.active         > 0
                and al.start_date    <= sysdate
                and al.end_date      >= sysdate
                and nvl(al.x_step,0)  = step
                and sa.alert_pkg.get_alert_suppression( esn, al.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
                order by al.start_date;
              rec_alert c_alert%rowtype;
              cursor c_alert_generic( esn varchar2, step number )
              is
                select al.*
                from sa.table_alert al,
                  sa.table_part_inst pi,
                  sa.table_mod_level ml,
                  sa.table_part_num pn
                where pi.part_serial_no = esn
                and pi.x_domain         = 'PHONES'
                and ml.objid            = pi.n_part_inst2part_mod
                and pn.objid            = ml.part_info2part_num
                and al.alert2lead       = pi.status2x_code_table
                and pn.part_num2bus_org = al.alert2bus_org
                and al.active           > 0
                and nvl(al.x_step,0)    = step
                and al.start_date      < sysdate + 1
                and al.end_date        > sysdate - 1
                and al.type             = 'GENERIC'
                and al.alert2bus_org  = pn.part_num2bus_org --CR22487 net10 home phone
                and sa.alert_pkg.get_alert_suppression( esn, al.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
                order by al.start_date;
              rec_alert_generic c_alert_generic%rowtype;
              cancel        boolean;
              cancel_err    varchar2(2000);
              f_count       boolean; --CR5925
              condition_err varchar2(2000);
              -- CR5925
              -- CR7605 START NGUADA

               ------------FOR CR34722
                cursor safelink_flash_cur
              is
                select *
                from table_alert al
                where title = 'SafeLink 2G/3G Migration Pilot'
              -- Start added by Rahul
              and al.active         > 0
                and al.start_date      < sysdate + 1
                and al.end_date        > sysdate - 1
              -- End added by Rahul
                and rownum        < 2;
              safelink_flash_rec safelink_flash_cur%rowtype;

              v_esn_count number :=0;
              p_esn varchar2(100);

              ---------------FOR CR34722
              ------------FOR CR36723
                cursor safelink_ivr_flash
              is
                select *
                from table_alert al
                where title = 'SL TFN-IVR Flash'
              and al.active         > 0
                and al.start_date      < sysdate + 1
                and al.end_date        > sysdate - 1
                and rownum        < 2;
              safelink_ivr_flash_rec safelink_ivr_flash%rowtype;

                --CR 2G TURNDOWN CR40349
                cursor cur_2g_turndown_flash
                is
                    select  al.*
                from table_alert al
		WHERE title = '2G Turndown'
		AND al.type = 'SQL'
              	and al.active         > 0
                and al.start_date      < sysdate + 1
                and al.end_date        > sysdate - 1
    		AND rownum        < 2;

               rec_2g_turndown_flash cur_2g_turndown_flash%rowtype;


			  --CR Reachout CR42046
                cursor cur_Reachout_flash
                is
                    select  al.*
                from table_alert al
		WHERE title = 'REACHOUT'
		AND al.type = 'SQL'
              	and al.active         > 0
                and al.start_date      < sysdate + 1
                and al.end_date        > sysdate - 1
                and sa.alert_pkg.get_alert_suppression( esn, al.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
    		AND rownum        < 2;

               rec_Reachout_flash cur_Reachout_flash%rowtype;
              ---------------FOR CR36723

              cursor program_flash_cur(program_name varchar2)
              is
                select *
                from table_alert a
                where title =
                  (select x_param_value
                  from table_x_parameters
                  where x_param_name = program_name
                  )
              and nvl(x_step,0) = step -- should give alert if the i/p step matches to x_step for the given ESN
              and start_date      < sysdate + 1
              and end_date        > sysdate - 1
              and sa.alert_pkg.get_alert_suppression( esn, a.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
              and rownum        < 2;
              program_flash_rec program_flash_cur%rowtype;
              -- CR29510 START RRS
              cursor program_flash_same_title_cur(c_objid x_program_parameters.objid%type)
              is
                select a.* from table_alert a, mtm_alert2part_class mtm
                where a.objid = mtm.alert_objid
                and mtm.pgm_parameter2objid = c_objid
                and nvl(x_step,0) = step
              and start_date      < sysdate + 1
                and end_date        > sysdate - 1
                and sa.alert_pkg.get_alert_suppression( esn, a.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
                and rownum < 2;
              program_flash_same_title_rec program_flash_same_title_cur%rowtype;
              -- CR29510 END
              cursor program_membership_cur(program_name varchar2, esn varchar2)
              is
                select '1'
                from x_program_enrolled pe,
                  x_program_parameters pp
                where pe.pgm_enroll2pgm_parameter=pp.objid
                and pp.x_prog_class              =program_name
                and pe.x_enrollment_status       ='ENROLLED'
                and x_esn                        =esn;
              program_membership_rec program_membership_cur%rowtype;
              -- CR7512 END
              -- CR19725 Start kacosta 02/29/2012
              cursor program_membership_sl_tx_curs(c_v_esn x_program_enrolled.x_esn%type)
              is
                select '1'
                from x_program_enrolled xpe
                join x_program_parameters xpp
                on xpe.pgm_enroll2pgm_parameter = xpp.objid
                where xpe.x_esn                 = c_v_esn
                and xpe.x_enrollment_status     = 'ENROLLED'
                and xpp.x_prog_class            = 'LIFELINE'
                and xpp.x_program_name         in ('Lifeline - Texas State Net10' ,'Lifeline - Texas State TracFone');
              program_membership_sl_tx_rec program_membership_sl_tx_curs%rowtype;
              --CR19725 End kacosta 02/29/2012
              -- CR29510 Start
              cursor program_membership_sl_al_curs(c_v_esn x_program_enrolled.x_esn%type)
              is
                select xpp.objid
                from x_program_enrolled xpe
                join x_program_parameters xpp
                on xpe.pgm_enroll2pgm_parameter = xpp.objid
                where xpe.x_esn = c_v_esn
                and xpe.x_enrollment_status = 'ENROLLED'
                and xpp.x_prog_class = 'LIFELINE'
                and xpp.x_program_name in ('Lifeline - AL - 1','Lifeline - AL - 2',
                'Lifeline - AL - 3','Lifeline - AL - 4' ,'Lifeline - IN - 1','Lifeline - IN - 2','Lifeline - IN - 3','Lifeline - IN - 4',
              'Lifeline - OR - 0');
              program_membership_sl_al_rec program_membership_sl_al_curs%rowtype;
              --CR29510 End RRS 06/23/2014
               -- CR23889 Start ymillan 05/06/2013
              cursor program_membership_sl_bb_curs(c_v_esn x_program_enrolled.x_esn%type)
              is
                select '1'
                from x_program_enrolled xpe
                join x_program_parameters xpp
                on xpe.pgm_enroll2pgm_parameter = xpp.objid
                where xpe.x_esn                 = c_v_esn
                and xpe.x_enrollment_status     = 'ENROLLED'
                and xpp.x_prog_class            = 'LIFELINE'
                and xpp.x_program_name         like 'Lifeline - % - BB%';
              program_membership_sl_bb_rec program_membership_sl_bb_curs%rowtype;
              --CR23889 end ymillan 05/06/2013

              -- CR19094 1 NEW CURSORS
              cursor part_class_flash_cur(esn varchar2)
              is
                select a.*
                from table_part_num pn,
                  table_mod_level ml,
                  table_part_inst pi,
                  mtm_alert2part_class mtm,
                  table_alert a
                where 1                    =1
                and pi.part_serial_no      = esn
                and pi.x_domain            ='PHONES'
                and ml.objid               = pi.n_part_inst2part_mod
                and pn.objid               = ml.part_info2part_num
                and pn.part_num2part_class = mtm.part_class_objid
                and a.objid                = mtm.alert_objid
                and a.alert2bus_org        = pn.part_num2bus_org --CR22487 net10 home phone
              and a.start_date      < sysdate + 1
                and a.end_date        > sysdate - 1
                and sa.alert_pkg.get_alert_suppression( esn, a.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
              ;
               part_class_flash_rec part_class_flash_cur%rowtype;
              -- CR19094 END

              -- CR27301 FLASH BY PART NUMBER start
              cursor part_number_flash_cur(esn varchar2)
              is
                select a.*
                from table_part_num pn,
                  table_mod_level ml,
                  table_part_inst pi,
                  mtm_alert2part_class mtm,
                  table_alert a
                where 1                    =1
                and pi.part_serial_no      = esn
                and pi.x_domain            ='PHONES'
                and ml.objid               = pi.n_part_inst2part_mod
                and pn.objid               = ml.part_info2part_num
                and pn.objid               = mtm.part_number_objid
                and a.objid                = mtm.alert_objid
                and a.alert2bus_org        = pn.part_num2bus_org
              and a.start_date      < sysdate + 1
                and a.end_date        > sysdate - 1
                and sa.alert_pkg.get_alert_suppression( esn, a.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
              ;
               part_number_flash_rec part_number_flash_cur%rowtype;
              -- CR27301 FLASH BY PART NUMBER end

              -- CR22131 Home Phone Flash
              cursor hp_alert_cur(esn varchar2)
              is
                select 'HOMEPHONE' x_title, b.objid brand
                from table_part_inst pi,table_mod_level ml,table_part_num pn,table_part_class pc,
                  table_x_part_class_params pcp,table_x_part_class_values pv, table_bus_org b
                where 1=1
                and pi.n_part_inst2part_mod=ml.objid
                and ml.part_info2part_num  =pn.objid
                and pn.part_num2part_class =pc.objid
                and pv.value2class_param   =pcp.objid
                and pv.value2part_class    =pc.objid
                and pcp.x_param_name       ='DEVICE_TYPE'
                and pv.x_param_value       ='WIRELESS_HOME_PHONE'
                and pn.domain              ='PHONES'
                and pn.part_num2bus_org    = b.objid
                and pi.part_serial_no      = esn ;
              hp_alert_rec hp_alert_cur%rowtype;
              cursor hp_flash_cur (x_title varchar2, brand number )
              is
                select * from table_alert where title = x_title
                and alert2bus_org = brand  --'HOMEPHONE' CR22487
              and start_date      < sysdate + 1
                and end_date        > sysdate - 1
              ;
              hp_flash_rec hp_flash_cur%rowtype;
              -- CR22131 Home Phone Flash END

              -- CR19552 BYOP
              cursor activation_alert_cur(esn varchar2)
              is
                select get_param_by_name_fun(pc.name,'ACTIVATION_ALERT_TITLE') x_title
                from table_part_inst pi,table_mod_level ml,table_part_num pn,table_part_class pc
                where 1                   = 1
                and pi.part_serial_no     = esn
                and ml.objid              = pi.n_part_inst2part_mod
                and pn.objid              = ml.part_info2part_num
                and pc.objid              = pn.part_num2part_class
                and pi.x_part_inst_status = '50' ;

              activation_alert_rec activation_alert_cur%rowtype;
              cursor activation_flash_cur( x_title varchar2)
              is
                select * from table_alert a where title = x_title
              and start_date      < sysdate + 1
                and end_date        > sysdate - 1
                and sa.alert_pkg.get_alert_suppression( esn, a.objid, channel ) = 'N' -- CRCR55156_Update_TAS_Flash_agent_view_System_Improvement
              ;
              activation_flash_rec activation_flash_cur%rowtype;

            procedure assign_output_param_prog
            is
            begin
            /*
              eng_text    := NVL(program_flash_rec.x_web_text_english,'Flash text not available for ('||program_flash_rec.title||')');
              spa_text    := NVL(program_flash_rec.x_web_text_spanish,eng_text);
              title       := program_flash_rec.title;
              hot         := program_flash_rec.hot;
              ivr_scr_id  := program_flash_rec.x_ivr_script_id;
              tts_english := program_flash_rec.x_tts_english;
              tts_spanish := program_flash_rec.x_tts_spanish;
              csr_text    := program_flash_rec.alert_text;
              msg         := 'Alert Found';
             */
                if  channel in ( 'WEB','APP') then -- CR38680 added APP
                          eng_text    := program_flash_rec.x_web_text_english;
                    spa_text    := program_flash_rec.x_web_text_spanish;
                    hot         := program_flash_rec.hot;
                      if eng_text is not null or spa_text is not null then
                       title       := program_flash_rec.title;
                       msg         := 'Alert Found';
                      end if;
              elsif channel = 'TAS' then
                        csr_text    := program_flash_rec.alert_text;
                    hot         := program_flash_rec.hot;
                      if csr_text is not null then
                           title       := program_flash_rec.title;
                                 msg         := 'Alert Found';
                    end if;
              elsif nvl(channel,'IVR') = 'IVR' then
                         tts_english := program_flash_rec.x_tts_english;
                     tts_spanish := program_flash_rec.x_tts_spanish;
                     title       := program_flash_rec.title;
                     msg         := 'Alert Found';
                       hot         := program_flash_rec.hot;
                             ivr_scr_id  := program_flash_rec.x_ivr_script_id;
                end if;
            end;
            begin --get_alert
              --ALERT TYPE:  NULL:Time based cancel, SQL: Sql Cancel, COUNT: Display Count, SQLCOUNT Sql Cancel and Display Count
              --             GENERIC: Status Base Message, link by (alert2lead = part_inst2x_code_table AND part_num2bus_org = alert2bus_org)
              -- CANCEL SQL: should be of the format 'select count(*)' parameters ESN start_date end_date
              -- BRAND_SEP
              cancel_err    := '0';
              err           := '0';
              msg           := 'No Alert Found';
              cancel        := false;
              condition_err := '0';   --CR5925
              f_count       := false; --CR5925
              title         := null;
              alert_objid   := null;         -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
              is_alert_suppressible := 'N';  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement

              ------------------------------------------------------------------
              ------------------------------------------------------------------
              -- PLUGGING IN NEW OUTAGE ALERT
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              begin
                  select sa.alert_pkg.outage_restriction(ip_brand => nvl(mv.sub_brand,mv.bus_org)) show_hide2
                  into   v_not_used
                  from   pcpv_mv mv,
                         table_part_class pc,
                         table_part_num pn,
                         table_mod_level m,
                         table_part_inst i
                  where 1=1
                  and   pc.objid = mv.pc_objid
                  and   i.x_domain = 'PHONES'
                  and   pc.objid = pn.part_num2part_class
                  and   pn.objid = m.part_info2part_num
                  and   m.objid  = i.n_part_inst2part_mod
                  and   i.part_serial_no =  esn;
              exception
                when others then
                  v_not_used := 'SHOW';
              end;

              if v_not_used = 'SHOW' then
                  alert_pkg.outage_alerts(ip_esn =>esn,
                                          ip_channel => channel,
                                          ip_display_point => 'BEFORE',
                                          ip_flow => '',
                                          ip_language => 'ENGLISH',
                                          op_outage_title => title,
                                          op_outage_alert => csr_text);
              end if;
              v_not_used := null;
              -- IVR IS OUT OF SCOPE FOR NOW
              -- 611 IS GOING TO CALL THE OUTAGE ALERT DIRECTLY THRU SOA
              if channel not in ('IVR','611') then
                if title is not null then
                  if channel = 'WEB' then
                    eng_text := csr_text;
                    alert_pkg.outage_alerts(ip_esn =>esn,
                                            ip_channel => channel,
                                            ip_display_point => 'BEFORE',
                                            ip_flow => '',
                                            ip_language => 'SPANISH',
                                            op_outage_title => title,
                                            op_outage_alert => spa_text);
                    csr_text := null;
                  end if;

                  msg := 'Alert Found';
                  return;
                end if;
              end if;
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              -- PLUGGING IN NEW WINBACK ALERT VALIDATIONS
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              winback_alert(esn => esn,step => step,channel => channel,title => title,csr_text => csr_text,eng_text => eng_text,spa_text => spa_text,ivr_scr_id => ivr_scr_id,
    						tts_english => tts_english,tts_spanish => tts_spanish,hot => hot,err => err,op_msg => msg,op_url => op_url,op_url_text_en => op_url_text_en,
    						op_url_text_es => op_url_text_es,op_sms_text => op_sms_text,op_bus_org => v_brand);
			  if msg = 'Alert Found' then
                return;
              end if;
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              -- END PLUGGING IN NEW DYNAMIC MIGRATION VALIDATIONS
              ------------------------------------------------------------------
              ------------------------------------------------------------------

              ------------------------------------------------------------------
              ------------------------------------------------------------------
              -- PLUGGING IN NEW DYNAMIC MIGRATION VALIDATIONS
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              sa.tech_migration_pkg.campaign_alerts(esn => esn,search_types => null,step => step,channel => channel,title => title,csr_text => csr_text,eng_text => eng_text,spa_text => spa_text,ivr_scr_id => ivr_scr_id,
                                                   tts_english => tts_english,tts_spanish => tts_spanish,hot => hot,err => err,op_msg => msg,op_url => op_url,op_url_text_en => op_url_text_en,op_url_text_es => op_url_text_es,
                                                   op_sms_text => op_sms_text,op_bus_org => v_brand, op_case_action => v_not_used, op_case_type => v_not_used, op_case_title => v_not_used, op_case_hdr_objid => v_not_used,
                                                   op_case_repl_pn =>v_not_used,OP_CAMPAIGN_MIGRATION =>v_not_used);

              if msg = 'Alert Found' then
                return;
              end if;
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              -- END PLUGGING IN NEW DYNAMIC MIGRATION VALIDATIONS
              ------------------------------------------------------------------
              ------------------------------------------------------------------

              ------------------------------------------------------------------
              ------------------------------------------------------------------
              -- PLUGGING IN NEW 2G VALIDATIONS
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              migration_alert(esn => esn,step => step,channel => channel,title => title,csr_text => csr_text,eng_text => eng_text,spa_text => spa_text,ivr_scr_id => ivr_scr_id,
                              tts_english => tts_english,tts_spanish => tts_spanish,hot => hot,err => err,op_msg => msg,op_url => op_url,op_url_text_en => op_url_text_en,
                              op_url_text_es => op_url_text_es,op_sms_text => op_sms_text,op_bus_org => v_brand);

              -- ESN IS NOT 2G SO CONTINUE
              if msg = 'Alert Found' then
                return;
              end if;
              ------------------------------------------------------------------
              ------------------------------------------------------------------
              -- END PLUGGIN IN NEW 2G VALIDATIONS
              ------------------------------------------------------------------
              ------------------------------------------------------------------


                -------FOR CR34722
                p_esn  :=esn;

            begin
              select count(1) into v_esn_count
              from table_x_safelink_flash
              where esn=p_esn
              and flag is null;---for CR36723
              exception
              when others then
              v_esn_count:=0;
            end;

              dbms_output.put_line('V_ESN_COUNT'||v_esn_count);
            if v_esn_count > 0 then

            open safelink_flash_cur;
            fetch safelink_flash_cur into  safelink_flash_rec;
            if safelink_flash_cur%found then
            dbms_output.put_line('found');
               dbms_output.put_line('SAFELINK_FLASH_REC.TYPE'||safelink_flash_rec.type);
               dbms_output.put_line('SAFELINK_FLASH_REC.x_cancel_sql'||safelink_flash_rec.x_cancel_sql);
               dbms_output.put_line('p_esn'||p_esn);
               dbms_output.put_line('SAFELINK_FLASH_REC.start_date'||safelink_flash_rec.start_date);
               dbms_output.put_line('SAFELINK_FLASH_REC.end_date'||safelink_flash_rec.end_date);


               cancel_alert(safelink_flash_rec.type, safelink_flash_rec.x_cancel_sql, p_esn, safelink_flash_rec.start_date , safelink_flash_rec.end_date, cancel_err, cancel);

                 dbms_output.put_line('cancel_err'||cancel_err);

                if cancel then
                /*  UPDATE sa.table_alert
                  SET active    = 0,
                    modify_stmp = SYSDATE
                  WHERE objid   = rec_alert.objid;
                  COMMIT;*/
                  msg := 'Alert Canceled';
                   dbms_output.put_line('msg'||msg);
                else
                   dbms_output.put_line('SAFELINK_FLASH_CUR found');
                  /*
                 eng_text    :=NVL(SAFELINK_FLASH_REC.x_web_text_english, 'Flash text not available for ('||SAFELINK_FLASH_REC.title||')');
                    spa_text    := NVL(SAFELINK_FLASH_REC.x_web_text_spanish,eng_text);
                    title       := SAFELINK_FLASH_REC.title;
                    hot         := SAFELINK_FLASH_REC.hot;
                    ivr_scr_id  := SAFELINK_FLASH_REC.x_ivr_script_id;
                    tts_english := SAFELINK_FLASH_REC.x_tts_english;
                    tts_spanish := SAFELINK_FLASH_REC.x_tts_spanish;
                    csr_text    := SAFELINK_FLASH_REC.alert_text;
                    msg         := 'Alert Found';
                   */
                  if channel in ( 'WEB','APP') then -- CR38680 added APP
                            eng_text    := safelink_flash_rec.x_web_text_english;
                        spa_text    := safelink_flash_rec.x_web_text_spanish;
                      hot         := safelink_flash_rec.hot;
                      if eng_text is not null  or spa_text is not null then
                      title       := safelink_flash_rec.title;
                      msg         := 'Alert Found';
                      end if;
                elsif channel = 'TAS' then
                       csr_text    := safelink_flash_rec.alert_text;
                     hot         := safelink_flash_rec.hot;
                       if csr_text is not null then
                          title       := safelink_flash_rec.title;
                                msg         := 'Alert Found';
                       end if;
                elsif nvl(channel,'IVR') = 'IVR' then
                           tts_english := safelink_flash_rec.x_tts_english;
                       tts_spanish := safelink_flash_rec.x_tts_spanish;
                       hot         := safelink_flash_rec.hot;
                               ivr_scr_id  := safelink_flash_rec.x_ivr_script_id;
                       title       := safelink_flash_rec.title;
                       msg         := 'Alert Found';
                  end if;
             dbms_output.put_line('eng_text'||eng_text);
            end if;
            end if;
            alert_objid             := safelink_flash_rec.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
            is_alert_suppressible   := NVL(safelink_flash_rec.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
            close safelink_flash_cur;
            end if;

              dbms_output.put_line('eng_text'||eng_text);

              -----END CR34722

              -------------------------for CR36723
              if msg <> 'Alert Found' then
              begin
            select count(1) into v_esn_count
            from table_x_safelink_flash
            where esn=p_esn
            and flag='SLTFN';
            exception
            when others then
            v_esn_count:=0;
            end;

              dbms_output.put_line('V_ESN_COUNT'||v_esn_count);
            if v_esn_count > 0 then

            open safelink_ivr_flash;
            fetch safelink_ivr_flash into  safelink_ivr_flash_rec;
            if safelink_ivr_flash%found then
            dbms_output.put_line('found');
               dbms_output.put_line('SAFELINK_IVR_FLASH_REC.TYPE=='||safelink_ivr_flash_rec.type);
               dbms_output.put_line('SAFELINK_IVR_FLASH_REC.x_cancel_sql=='||safelink_ivr_flash_rec.x_cancel_sql);
               dbms_output.put_line('p_esn=='||p_esn);
               dbms_output.put_line('SAFELINK_IVR_FLASH_REC.start_date=='||safelink_ivr_flash_rec.start_date);
               dbms_output.put_line('SAFELINK_IVR_FLASH_REC.end_date=='||safelink_ivr_flash_rec.end_date);



                   dbms_output.put_line('SAFELINK_IVR_FLASH found');
                 /*
                    eng_text    :=NVL(SAFELINK_IVR_FLASH_REC.x_web_text_english, 'Flash text not available for ('||SAFELINK_IVR_FLASH_REC.title||')');
                    spa_text    := NVL(SAFELINK_IVR_FLASH_REC.x_web_text_spanish,eng_text);
                    title       := SAFELINK_IVR_FLASH_REC.title;
                    hot         := SAFELINK_IVR_FLASH_REC.hot;
                    ivr_scr_id  := SAFELINK_IVR_FLASH_REC.x_ivr_script_id;
                    tts_english := SAFELINK_IVR_FLASH_REC.x_tts_english;
                    tts_spanish := SAFELINK_IVR_FLASH_REC.x_tts_spanish;
                    csr_text    := SAFELINK_IVR_FLASH_REC.alert_text;
                    msg         := 'Alert Found';
                   */
                  if channel in ( 'WEB','APP') then -- CR38680 added APP

                      eng_text    := safelink_ivr_flash_rec.x_web_text_english;
                    spa_text    := safelink_ivr_flash_rec.x_web_text_spanish;
                    hot         := safelink_ivr_flash_rec.hot;
                     if eng_text is not null  or spa_text is not null then
                      title       := safelink_ivr_flash_rec.title;
                      msg         := 'Alert Found';
                      end if;
                elsif channel = 'TAS' then
                     csr_text    := safelink_ivr_flash_rec.alert_text;
                   hot         := safelink_ivr_flash_rec.hot;
                   if csr_text is not null then
                      title       := safelink_ivr_flash_rec.title;
                            msg         := 'Alert Found';
                   end if;
                elsif nvl(channel,'IVR') = 'IVR' then
                           tts_english := safelink_ivr_flash_rec.x_tts_english;
                       tts_spanish := safelink_ivr_flash_rec.x_tts_spanish;
                       hot         := safelink_ivr_flash_rec.hot;
                               ivr_scr_id  := safelink_ivr_flash_rec.x_ivr_script_id;
                       title       := safelink_ivr_flash_rec.title;
                       msg         := 'Alert Found';
                  end if;
             dbms_output.put_line('eng_text'||eng_text);
            end if;
            alert_objid             := safelink_ivr_flash_rec.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
            is_alert_suppressible   := NVL(safelink_ivr_flash_rec.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
            close safelink_ivr_flash;
            end if;
            end if;
              dbms_output.put_line('eng_text'||eng_text);

            ----------------------------------2G TURNDOWN START CR40349
          if msg <> 'Alert Found' then
            begin
              select count(1) into v_esn_count
              from table_x_safelink_flash
              where esn=p_esn
              and flag = '2G';---for CR40349
            exception
              when others then
                v_esn_count:=0;
            end;

            dbms_output.put_line('V_ESN_COUNT'||v_esn_count);
            if v_esn_count > 0 then
              open cur_2g_turndown_flash;
              fetch cur_2g_turndown_flash into  rec_2g_turndown_flash;
              if cur_2g_turndown_flash%found then
                dbms_output.put_line('found');
                dbms_output.put_line('cur_2g_turndown_flash.TYPE'||rec_2g_turndown_flash.type);
                dbms_output.put_line('cur_2g_turndown_flash.x_cancel_sql'||rec_2g_turndown_flash.x_cancel_sql);
                dbms_output.put_line('p_esn'||p_esn);
                dbms_output.put_line('cur_2g_turndown_flash.start_date'||rec_2g_turndown_flash.start_date);
                dbms_output.put_line('cur_2g_turndown_flash.end_date'||rec_2g_turndown_flash.end_date);

                cancel_alert(rec_2g_turndown_flash.type, rec_2g_turndown_flash.x_cancel_sql, p_esn, rec_2g_turndown_flash.start_date , rec_2g_turndown_flash.end_date, cancel_err, cancel);

                dbms_output.put_line('cancel_err'||cancel_err);

                if cancel then
                  msg := 'Alert Canceled';
                  dbms_output.put_line('msg'||msg);
                else
       		  DBMS_OUTPUT.PUT_LINE('2G TRUNDOWN_FLASH_CUR found');
                  if channel in ( 'WEB','APP') then
                      eng_text    := rec_2g_turndown_flash.x_web_text_english;
                      spa_text    := rec_2g_turndown_flash.x_web_text_spanish;
                      hot         := rec_2g_turndown_flash.hot;
                      if eng_text is not null  or spa_text is not null then
                        title       := rec_2g_turndown_flash.title;
                        msg         := 'Alert Found';
                      end if;
                  elsif channel = 'TAS' then
                    csr_text    := rec_2g_turndown_flash.alert_text;
                    hot         := rec_2g_turndown_flash.hot;
                    if csr_text is not null then
                      title       := rec_2g_turndown_flash.title;
                      msg         := 'Alert Found';
                    end if;
                  elsif nvl(channel,'IVR') = 'IVR' then
                    tts_english := rec_2g_turndown_flash.x_tts_english;
                    tts_spanish := rec_2g_turndown_flash.x_tts_spanish;
                    hot         := rec_2g_turndown_flash.hot;
                    ivr_scr_id  := rec_2g_turndown_flash.x_ivr_script_id;
                    title       := rec_2g_turndown_flash.title;
                    msg         := 'Alert Found';
                  end if;
                  dbms_output.put_line('eng_text'||eng_text);
                end if;
              end if;
              alert_objid             := rec_2g_turndown_flash.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
              is_alert_suppressible   := NVL(rec_2g_turndown_flash.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
              close cur_2g_turndown_flash;
            end if;
          end if;
            ----------------------------------- 2G TURNDOWN END CR40349
			----------------------------------REACHOUT START CR42046
          if msg <> 'Alert Found' then
            begin
              select count(1) into v_esn_count
              from table_x_safelink_flash
              where esn=p_esn
              and flag = 'REACHOUT';---for CR40349
            exception
              when others then
                v_esn_count:=0;
            end;

            dbms_output.put_line('V_ESN_COUNT'||v_esn_count);
            if v_esn_count > 0 then
              open cur_Reachout_flash;
              fetch cur_Reachout_flash into  rec_Reachout_flash;
              if cur_Reachout_flash%found then
                dbms_output.put_line('found');
                dbms_output.put_line('cur_Reachout_flash.TYPE'||rec_Reachout_flash.type);
                dbms_output.put_line('cur_Reachout_flash.x_cancel_sql'||rec_Reachout_flash.x_cancel_sql);
                dbms_output.put_line('p_esn'||p_esn);
                dbms_output.put_line('cur_Reachout_flash.start_date'||rec_Reachout_flash.start_date);
                dbms_output.put_line('cur_Reachout_flash.end_date'||rec_Reachout_flash.end_date);

                cancel_alert(rec_Reachout_flash.type, rec_Reachout_flash.x_cancel_sql, p_esn, rec_Reachout_flash.start_date , rec_Reachout_flash.end_date, cancel_err, cancel);

                dbms_output.put_line('cancel_err'||cancel_err);

                if cancel then
                  msg := 'Alert Canceled';
                  dbms_output.put_line('msg'||msg);
                else
       		  DBMS_OUTPUT.PUT_LINE('cur_Reachout_flash found');
                  if channel in ( 'WEB','APP') then
                      eng_text    := rec_Reachout_flash.x_web_text_english;
                      spa_text    := rec_Reachout_flash.x_web_text_spanish;
                      hot         := rec_Reachout_flash.hot;
                      if eng_text is not null  or spa_text is not null then
                        title       := rec_Reachout_flash.title;
                        msg         := 'Alert Found';
                      end if;
                  elsif channel = 'TAS' then
                    csr_text    := rec_Reachout_flash.alert_text;
                    hot         := rec_Reachout_flash.hot;
                    if csr_text is not null then
                      title       := rec_Reachout_flash.title;
                      msg         := 'Alert Found';
                    end if;
                  elsif nvl(channel,'IVR') = 'IVR' then
                    tts_english := rec_Reachout_flash.x_tts_english;
                    tts_spanish := rec_Reachout_flash.x_tts_spanish;
                    hot         := rec_Reachout_flash.hot;
                    ivr_scr_id  := rec_Reachout_flash.x_ivr_script_id;
                    title       := rec_Reachout_flash.title;
                    msg         := 'Alert Found';
                  end if;
                  dbms_output.put_line('eng_text'||eng_text);
                end if;
              end if;
              alert_objid             := rec_Reachout_flash.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
              is_alert_suppressible   := NVL(rec_Reachout_flash.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
              close cur_Reachout_flash;
            end if;
          end if;
            ----------------------------------- REACHOUT END CR42046

                -----END CR36723
              if msg <> 'Alert Found' then
              open c_alert(esn,step);
              fetch c_alert into rec_alert;
              if c_alert%found then
                cancel_alert(rec_alert.type, rec_alert.x_cancel_sql, esn, rec_alert.start_date , rec_alert.end_date, cancel_err, cancel);
                if cancel then
                  update sa.table_alert
                  set active    = 0,
                    modify_stmp = sysdate
                  where objid   = rec_alert.objid;
                  commit;
                  msg := 'Alert Canceled';
                else

                /*
                  csr_text    := rec_alert.alert_text;
                  eng_text    := NVL(rec_alert.x_web_text_english, 'Flash text not available for ('||rec_alert.title||')');
                  spa_text    := NVL(rec_alert.x_web_text_spanish, eng_text);
                  title       := rec_alert.title;
                  hot         := rec_alert.hot;
                  ivr_scr_id  := rec_alert.x_ivr_script_id;
                  tts_english := rec_alert.x_tts_english;
                  tts_spanish := rec_alert.x_tts_spanish;
                  msg         := 'Alert Found';
               */
                  if channel in ( 'WEB','APP') then -- CR38680 added APP
                          eng_text    := rec_alert.x_web_text_english;
                    spa_text    := rec_alert.x_web_text_spanish;
                    hot         := rec_alert.hot;
                      if eng_text is not null or spa_text is not null then
                      title       := rec_alert.title;
                      msg         := 'Alert Found';
                      end if;

                elsif channel = 'TAS' then
                     csr_text    := rec_alert.alert_text;
                   hot         := rec_alert.hot;
                   if csr_text is not null then
                      title       := rec_alert.title;
                            msg         := 'Alert Found';
                   end if;
                elsif  nvl(channel,'IVR') = 'IVR' then

                         tts_english := rec_alert.x_tts_english;
                       tts_spanish := rec_alert.x_tts_spanish;
                       hot         := rec_alert.hot;
                               ivr_scr_id  := rec_alert.x_ivr_script_id;
                       title       := rec_alert.title;
                       msg         := 'Alert Found';
                  end if;
                  if rec_alert.type like '%COUNT%' then
                    update sa.table_alert
                    set active    = active - 1,
                      modify_stmp = sysdate
                    where objid   = rec_alert.objid;
                    commit;
                  end if;
                end if;
                alert_objid             := rec_alert.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                is_alert_suppressible   := NVL(rec_alert.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                close c_alert;
              else
                alert_objid             := rec_alert.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                is_alert_suppressible   := NVL(rec_alert.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                close c_alert;
                open c_alert_generic(esn,step);
                fetch c_alert_generic into rec_alert_generic;
                if c_alert_generic%found then
                  --CR5925 Begin
                  if nvl(rec_alert_generic.x_eval_sql, 0)    = 0 then
                /*
                    csr_text                                := rec_alert_generic.alert_text;
                    eng_text                                := NVL(rec_alert_generic.x_web_text_english, 'Flash text not available for ('||rec_alert.title||')');
                    spa_text                                := NVL(rec_alert_generic.x_web_text_spanish, eng_text);
                    title                                   := rec_alert_generic.title;
                    hot                                     := rec_alert_generic.hot;
                    ivr_scr_id                              := rec_alert_generic.x_ivr_script_id;
                    tts_english                             := rec_alert_generic.x_tts_english;
                    tts_spanish                             := rec_alert_generic.x_tts_spanish;
                    msg                                     := 'Alert Found';
                */
                  if channel in ( 'WEB','APP') then -- CR38680 added APP
                      eng_text    := rec_alert_generic.x_web_text_english;
                  spa_text    := rec_alert_generic.x_web_text_spanish;
                  hot         := rec_alert_generic.hot;
                      if eng_text is not null or  spa_text is not null then
                      title       := rec_alert_generic.title;
                      msg         := 'Alert Found';
                      end if;
                elsif channel = 'TAS' then
                     csr_text    := rec_alert_generic.alert_text;
                   hot         := rec_alert_generic.hot;
                   if csr_text is not null then
                      title       := rec_alert_generic.title;
                            msg         := 'Alert Found';
                   end if;
                elsif  nvl(channel,'IVR') = 'IVR' then

                         tts_english := rec_alert_generic.x_tts_english;
                       tts_spanish := rec_alert_generic.x_tts_spanish;
                       hot         := rec_alert_generic.hot;
                               ivr_scr_id  := rec_alert_generic.x_ivr_script_id;
                       title       := rec_alert_generic.title;
                       msg         := 'Alert Found';
                    end if;
                  elsif nvl(rec_alert_generic.x_eval_sql, 0) = 1 and rec_alert_generic.x_condition_sql is not null then
                    dynamic_sql (rec_alert_generic.x_condition_sql, esn, condition_err, f_count);
                    if f_count then
                    /*
                 eng_text    := NVL(rec_alert_generic.x_web_text_english, 'Flash text not available for ('||rec_alert.title||')');
                      spa_text    := NVL(rec_alert_generic.x_web_text_spanish, eng_text);
                      title       := rec_alert_generic.title;
                      hot         := rec_alert_generic.hot;
                      ivr_scr_id  := rec_alert_generic.x_ivr_script_id;
                      tts_english := rec_alert_generic.x_tts_english;
                      tts_spanish := rec_alert_generic.x_tts_spanish;
                      csr_text    := rec_alert_generic.alert_text;
                      msg         := 'Alert Found';
                 */
                if channel in ( 'WEB','APP') then -- CR38680 added APP
                      eng_text    := rec_alert_generic.x_web_text_english;
                  spa_text    := rec_alert_generic.x_web_text_spanish;
                  hot         := rec_alert_generic.hot;
                      if eng_text is not null or spa_text is not null then
                      title       := rec_alert_generic.title;
                      msg         := 'Alert Found';
                      end if;
                elsif channel = 'TAS' then
                     csr_text    := rec_alert_generic.alert_text;
                   hot         := rec_alert_generic.hot;
                   if csr_text is not null then
                      title       := rec_alert_generic.title;
                            msg         := 'Alert Found';
                   end if;
                elsif  nvl(channel,'IVR') = 'IVR' then

                         tts_english := rec_alert_generic.x_tts_english;
                       tts_spanish := rec_alert_generic.x_tts_spanish;
                       hot         := rec_alert_generic.hot;
                               ivr_scr_id  := rec_alert_generic.x_ivr_script_id;
                       title       := rec_alert_generic.title;
                       msg         := 'Alert Found';
                    end if;
                    end if;
                  end if;
                  --CR5925 End
                end if;
                alert_objid             := rec_alert_generic.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                is_alert_suppressible   := NVL(rec_alert_generic.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                close c_alert_generic;
              end if;
              if cancel_err <> '0' then
                msg         := 'Error in cancel sql';
                err         := cancel_err;
              end if;
              --CR5925 Begin
              if condition_err <> '0' then
                msg            := msg || 'Error in condition sql';
                err            := err || condition_err;
              end if;
              end if;
              --CR5925 End
              -- CR7605 START NGUADA 7/11/2008
              if msg <> 'Alert Found' then
                open program_membership_cur('UNLIMITED',esn);
                fetch program_membership_cur into program_membership_rec;
                if program_membership_cur%found then
                  close program_membership_cur;
                  open program_flash_cur('UNLIMITED');
                  fetch program_flash_cur into program_flash_rec;
                  if program_flash_cur%found then
                    assign_output_param_prog;
                  end if;
                  close program_flash_cur;
                else
                  close program_membership_cur;
                end if;
              end if;
              --CR20202 Start mmunoz May/2012 the order of precedence when an ESN is enrolled in both LIFELINE and HMO programs is HMO goes first
              if msg <> 'Alert Found' then
                open program_membership_cur('HMO',esn);
                fetch program_membership_cur into program_membership_rec;
                if program_membership_cur%found then
                  close program_membership_cur;
                  open program_flash_cur('HMO');
                  fetch program_flash_cur into program_flash_rec;
                  if program_flash_cur%found then
                    assign_output_param_prog;
                  end if;
                  alert_objid             := program_flash_rec.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                  is_alert_suppressible   := NVL(program_flash_rec.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                  close program_flash_cur;
                else
                  close program_membership_cur;
                end if;
              end if;
              --CR20202 End May/2012
              --CR19725 Start Kacosta 02/29/2012
              if msg <> 'Alert Found' then
                --
                if program_membership_sl_tx_curs%isopen then
                  --
                  close program_membership_sl_tx_curs;
                  --
                end if;
                --
                open program_membership_sl_tx_curs(c_v_esn => esn);
                fetch program_membership_sl_tx_curs into program_membership_sl_tx_rec;
                --
                if program_membership_sl_tx_curs%found then
                  --
                  if program_flash_cur%isopen then
                    --
                    close program_flash_cur;
                    --
                  end if;
                  --
                  open program_flash_cur(program_name => 'LIFELINE TEXAS');
                  fetch program_flash_cur into program_flash_rec;
                  --
                  if program_flash_cur%found then
                    assign_output_param_prog;
                  end if;
                  --
                  close program_flash_cur;
                  --
                end if;
                --
                close program_membership_sl_tx_curs;
                --
              end if;
              --CR19725 End Kacosta 02/29/2012
              --CR29510 Begin RRS 06/23/2014
               if msg <> 'Alert Found' then
                --
                if program_membership_sl_al_curs%isopen then
                  --
                  close program_membership_sl_al_curs;
                  --
                end if;
                --
                open program_membership_sl_al_curs(c_v_esn => esn);
                fetch program_membership_sl_al_curs into program_membership_sl_al_rec;
                --
                if program_membership_sl_al_curs%found then
                  --
                  if program_flash_same_title_cur%isopen then
                    --
                    close program_flash_same_title_cur;
                    --
                  end if;
                  --
                  open program_flash_same_title_cur(program_membership_sl_al_rec.objid);
                  fetch program_flash_same_title_cur into program_flash_same_title_rec;
                  --
                  if program_flash_same_title_cur%found then
                    program_flash_rec.x_web_text_english := program_flash_same_title_rec.x_web_text_english;
                    program_flash_rec.x_web_text_spanish := program_flash_same_title_rec.x_web_text_spanish;
                    program_flash_rec.title := program_flash_same_title_rec.title;
                    program_flash_rec.hot := program_flash_same_title_rec.hot;
                    program_flash_rec.x_ivr_script_id := program_flash_same_title_rec.x_ivr_script_id;
                    program_flash_rec.x_tts_english := program_flash_same_title_rec.x_tts_english;
                    program_flash_rec.x_tts_spanish := program_flash_same_title_rec.x_tts_spanish;
                    program_flash_rec.alert_text := program_flash_same_title_rec.alert_text;
                    assign_output_param_prog;
                  end if;
                  --
                  close program_flash_same_title_cur;
                  --
                end if;
                --
                close program_membership_sl_al_curs;
                --
               end if;
               --CR29510 End RRS 06/23/2014
              --CR23889 Begin ymillan 05/06/2013
              if msg <> 'Alert Found' then
                --
                if program_membership_sl_bb_curs%isopen then
                  --
                  close program_membership_sl_bb_curs;
                  --
                end if;
                --
                open program_membership_sl_bb_curs(c_v_esn => esn);
                fetch program_membership_sl_bb_curs into program_membership_sl_bb_rec;
                --
                if program_membership_sl_bb_curs%found then
                  --
                  if program_flash_cur%isopen then
                    --
                    close program_flash_cur;
                    --
                  end if;
                  --
                  open program_flash_cur(program_name => 'LIFELINE BROADBAND');
                  fetch program_flash_cur into program_flash_rec;
                  --
                  if program_flash_cur%found then
                    assign_output_param_prog;
                  end if;
                  --
                  close program_flash_cur;
                  --
                end if;
                --
                -- CLOSE PROGRAM_MEMBERSHIP_SL_TX_CURS;
                close program_membership_sl_bb_curs;  -- CR24422
                --
              end if;
              --CR23889 End ymillan 05/06/2013

              if msg <> 'Alert Found' then
                open program_membership_cur('LIFELINE',esn);
                fetch program_membership_cur into program_membership_rec;
                if program_membership_cur%found then
                  close program_membership_cur;
                  open program_flash_cur('LIFELINE');
                  fetch program_flash_cur into program_flash_rec;
                  if program_flash_cur%found then
                    assign_output_param_prog;
                  end if;
                  close program_flash_cur;
                else
                  close program_membership_cur;
                end if;
              end if;
              -- CR7605 END


              -- CR19094 BEGIN
              -- part_class_promo_cur
              ---------------------------
              -- CR22131 Home Phone Flash
              if msg <> 'Alert Found' then
                open hp_alert_cur(esn) ;
                fetch hp_alert_cur into hp_alert_rec ;
                if hp_alert_cur%found then
                  --dbms_output.put_line('FOUND ' || ESN) ;
                  close hp_alert_cur ;
                  open hp_flash_cur(hp_alert_rec.x_title,hp_alert_rec.brand);
                  fetch hp_flash_cur into hp_flash_rec;
                  if hp_flash_cur%found then
                    -- eng_text := NULL ;
                    --spa_text := NULL ;
                /*
                    eng_text    := NVL(HP_flash_rec.x_web_text_english,'Flash text not available for ('||HP_flash_rec.title||')');
                    spa_text    := NVL(HP_flash_rec.x_web_text_spanish,eng_text);
                    title       := HP_flash_rec.title;
                    hot         := HP_flash_rec.hot;
                    ivr_scr_id  := HP_flash_rec.x_ivr_script_id;
                    tts_english := HP_flash_rec.x_tts_english;
                    tts_spanish := HP_flash_rec.x_tts_spanish;
                    csr_text    := HP_flash_rec.alert_text;
                    msg         := 'Alert Found';
                */
                if channel in ( 'WEB','APP') then -- CR38680 added APP
                          eng_text    := hp_flash_rec.x_web_text_english;
                      spa_text    := hp_flash_rec.x_web_text_spanish;
                    hot         := hp_flash_rec.hot;
                      if eng_text is not null or spa_text is not null then
                      title       := hp_flash_rec.title;
                      msg         := 'Alert Found';
                      end if;
                elsif channel = 'TAS' then
                     csr_text    := hp_flash_rec.alert_text;
                   hot         := hp_flash_rec.hot;
                   if csr_text is not null then
                      title       := hp_flash_rec.title;
                            msg         := 'Alert Found';
                   end if;
                elsif  nvl(channel,'IVR') = 'IVR' then

                         tts_english := hp_flash_rec.x_tts_english;
                       tts_spanish := hp_flash_rec.x_tts_spanish;
                       hot         := hp_flash_rec.hot;
                               ivr_scr_id  := hp_flash_rec.x_ivr_script_id;
                       title       := hp_flash_rec.title;
                       msg         := 'Alert Found';
                end if;
                  end if ;
                  alert_objid             := hp_flash_rec.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                  is_alert_suppressible   := NVL(hp_flash_rec.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                  close hp_flash_cur;
                else
                  close hp_alert_cur ;
                end if ;
              end if ;
              -------------------------------
              if msg <> 'Alert Found' then
                open part_class_flash_cur(esn);
                fetch part_class_flash_cur into part_class_flash_rec;
                if part_class_flash_cur%found then

              cancel_alert(part_class_flash_rec.type, part_class_flash_rec.x_cancel_sql, p_esn, part_class_flash_rec.start_date , part_class_flash_rec.end_date, cancel_err, cancel);

                 dbms_output.put_line('cancel_err'||cancel_err);

                if cancel then
                /*  UPDATE sa.table_alert
                  SET active    = 0,
                    modify_stmp = SYSDATE
                  WHERE objid   = rec_alert.objid;
                  COMMIT;*/
                  msg := 'Alert Canceled';
                   dbms_output.put_line('msg'||msg);
                else
                  /*
                  eng_text    := NVL(part_class_flash_rec.x_web_text_english,'Flash text not available for ('||part_class_flash_rec.title||')');
                  spa_text    := NVL(part_class_flash_rec.x_web_text_spanish,eng_text);
                  title       := part_class_flash_rec.title;
                  hot         := part_class_flash_rec.hot;
                  ivr_scr_id  := part_class_flash_rec.x_ivr_script_id;
                  tts_english := part_class_flash_rec.x_tts_english;
                  tts_spanish := part_class_flash_rec.x_tts_spanish;
                  csr_text    := part_class_flash_rec.alert_text;
                  msg         := 'Alert Found';
                 */
                  if channel in ( 'WEB','APP') then -- CR38680 added APP
                      eng_text    := part_class_flash_rec.x_web_text_english;
                  spa_text    := part_class_flash_rec.x_web_text_spanish;
                  hot         := part_class_flash_rec.hot;
                      if eng_text is not null or spa_text is not null then
                      title       := part_class_flash_rec.title;
                      msg         := 'Alert Found';
                      end if;
                elsif channel = 'TAS' then
                     csr_text    := part_class_flash_rec.alert_text;
                   hot         := part_class_flash_rec.hot;
                   if csr_text is not null then
                      title       := part_class_flash_rec.title;
                            msg         := 'Alert Found';
                   end if;
                elsif  nvl(channel,'IVR') = 'IVR' then

                         tts_english := part_class_flash_rec.x_tts_english;
                       tts_spanish := part_class_flash_rec.x_tts_spanish;
                       hot         := part_class_flash_rec.hot;
                               ivr_scr_id  := part_class_flash_rec.x_ivr_script_id;
                       title       := part_class_flash_rec.title;
                       msg         := 'Alert Found';
                end if;
              end if;

                end if;
                alert_objid             := part_class_flash_rec.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                is_alert_suppressible   := NVL(part_class_flash_rec.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                close part_class_flash_cur;
                    --CR19725 Start Kacosta 02/29/2012
                --Invalid Cursor was being raised because cursor was never opened
                --else
                -- close part_class_flash_cur;
                --CR19725 End Kacosta 02/29/2012
              end if;
              -- CR19094 END
              -- CR19552 BYOP

              -- CR27301 FLASH BY PART NUMBER start
                if msg <> 'Alert Found' then
                open part_number_flash_cur(esn);
                fetch part_number_flash_cur into part_number_flash_rec;
                if part_number_flash_cur%found then
              /*
                  eng_text    := NVL(part_number_flash_rec.x_web_text_english,'Flash text not available for ('||part_number_flash_rec.title||')');
                  spa_text    := NVL(part_number_flash_rec.x_web_text_spanish,eng_text);
                  title       := part_number_flash_rec.title;
                  hot         := part_number_flash_rec.hot;
                  ivr_scr_id  := part_number_flash_rec.x_ivr_script_id;
                  tts_english := part_number_flash_rec.x_tts_english;
                  tts_spanish := part_number_flash_rec.x_tts_spanish;
                  csr_text    := part_number_flash_rec.alert_text;
                  msg         := 'Alert Found';
              */
                  if channel in ( 'WEB','APP') then -- CR38680 added APP
                      eng_text    := part_number_flash_rec.x_web_text_english;
                  spa_text    := part_number_flash_rec.x_web_text_spanish;
                  hot         := part_number_flash_rec.hot;
                      if eng_text is not null or spa_text is not null then
                      title       := part_number_flash_rec.title;
                      msg         := 'Alert Found';
                      end if;
                  elsif channel = 'TAS' then
                     csr_text    := part_number_flash_rec.alert_text;
                   hot         := part_number_flash_rec.hot;
                   if csr_text is not null then
                      title       := part_number_flash_rec.title;
                            msg         := 'Alert Found';
                   end if;
                elsif  nvl(channel,'IVR') = 'IVR' then

                         tts_english := part_number_flash_rec.x_tts_english;
                       tts_spanish := part_number_flash_rec.x_tts_spanish;
                       hot         := part_number_flash_rec.hot;
                       ivr_scr_id  := part_number_flash_rec.x_ivr_script_id;
                       title       := part_number_flash_rec.title;
                       msg         := 'Alert Found';
                  end if;
                end if;
                alert_objid             := part_number_flash_rec.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                is_alert_suppressible   := NVL(part_number_flash_rec.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                close part_number_flash_cur;
              end if ;
              -- CR27301 FLASH BY PART NUMBER end

              if msg <> 'Alert Found' then
                open activation_alert_cur(esn);
                fetch activation_alert_cur into activation_alert_rec;
                if activation_alert_cur%found then
                  close activation_alert_cur;
                  open activation_flash_cur(activation_alert_rec.x_title);
                  fetch activation_flash_cur into activation_flash_rec;
                  if activation_flash_cur%found then
                 /*
                    eng_text    := NVL(activation_flash_rec.x_web_text_english,'Flash text not available for ('||activation_flash_rec.title||')');
                    spa_text    := NVL(activation_flash_rec.x_web_text_spanish,eng_text);
                    title       := activation_flash_rec.title;
                    hot         := activation_flash_rec.hot;
                    ivr_scr_id  := activation_flash_rec.x_ivr_script_id;
                    tts_english := activation_flash_rec.x_tts_english;
                    tts_spanish := activation_flash_rec.x_tts_spanish;
                    csr_text    := activation_flash_rec.alert_text;
                    msg         := 'Alert Found';
                 */
                  if channel in ( 'WEB','APP') then -- CR38680 added APP
                      eng_text    := activation_flash_rec.x_web_text_english;
                  spa_text    := activation_flash_rec.x_web_text_spanish;
                  hot         := activation_flash_rec.hot;
                      if eng_text is not null or spa_text is not null then
                      title       := activation_flash_rec.title;
                      msg         := 'Alert Found';
                      end if;
                  elsif channel = 'TAS' then
                     csr_text    := activation_flash_rec.alert_text;
                   hot         := activation_flash_rec.hot;
                   if csr_text is not null then
                      title       := activation_flash_rec.title;
                            msg         := 'Alert Found';
                   end if;
                elsif  nvl(channel,'IVR') = 'IVR' then

                         tts_english := activation_flash_rec.x_tts_english;
                       tts_spanish := activation_flash_rec.x_tts_spanish;
                       hot         := activation_flash_rec.hot;
                       ivr_scr_id  := activation_flash_rec.x_ivr_script_id;
                       title       := activation_flash_rec.title;
                       msg         := 'Alert Found';
                    end if;
                  end if;
                  alert_objid             := activation_flash_rec.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                  is_alert_suppressible   := NVL(activation_flash_rec.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                  close activation_flash_cur;
                else
                  close activation_alert_cur;
                end if;
                -- CR19552 BYOP
              end if;

              -- THIS WAS ADDED FOR CBO HAVING ISSUES PROCESSING NULL
              -- ADDED FOR NET10 AND TRACFONE ONLY
              if msg != 'Alert Found' or msg is null then
                if v_brand in ('NET10','TRACFONE') and channel != 'IVR' then
                  hot := '-1';
                end if;
                  err := 0;
                  msg := 'No Alert found';
                  return;
              end if;


            exception
            when others then
              if c_alert%isopen then
                alert_objid             := rec_alert.objid;                  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                is_alert_suppressible   := NVL(rec_alert.is_alert_suppressible,'N');  -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
                close c_alert;
              end if;
              err := sqlerrm;
            end get_alert;
--------------------------------------------------------------------------------
-- OVERLOADED
PROCEDURE get_alert(esn  varchar2,
                    step number,              --Sequence Step for Display
                    channel varchar2 default 'IVR',         -- Channel to display flash   --CR37075
                    title    out varchar2,       -- Alert Title
                    csr_text out varchar2,    -- Text to be used in WEBCSR
                    eng_text out varchar2,    -- Web Text English
                    spa_text out varchar2,    -- Web Text Spanish
                    ivr_scr_id out varchar2,  -- IVR script ID
                    tts_english out varchar2, -- Text to Speech English
                    tts_spanish out varchar2, -- Text to Speech Spanish
                    hot out varchar2,         -- 0 Let customer continue, 1 Transfer
                    err out varchar2,         -- Error Number
                    msg out varchar2)
is
  v_dismissed_variable varchar2(4000);
  v_alert_objid            number;
  v_is_alert_suppressible  varchar2(1);
begin
  get_alert (esn            => esn,
             step           => step,
             channel        => channel,     -- Channel to display flash   --CR37075
             title          => title, -- Alert Title
             csr_text       => csr_text, -- Text to be used in WEBCSR
             eng_text       => eng_text, -- Web Text English
             spa_text       => spa_text, -- Web Text Spanish
             ivr_scr_id     => ivr_scr_id, -- IVR script ID
             tts_english    => tts_english, -- Text to Speech English
             tts_spanish    => tts_spanish, -- Text to Speech Spanish
             hot            => hot, -- 0 Let customer continue, 1 Transfer
             err            => err, -- Error Number
             msg            => msg,-- Additional Messages
             op_url         => v_dismissed_variable,
             op_url_text_en => v_dismissed_variable,
             op_url_text_es => v_dismissed_variable,
             op_sms_text    => v_dismissed_variable,
             alert_objid           => v_alert_objid,             -- OVERLOADED -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
             is_alert_suppressible => v_is_alert_suppressible);  -- OVERLOADED -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
end get_alert;
procedure get_alert ( esn            varchar2,
                      step           number,
                      channel        varchar2 default 'IVR',     -- Channel to display flash   --CR37075
                      title          out varchar2, -- Alert Title
                      CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                      eng_text       out varchar2, -- Web Text English
                      SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                      ivr_scr_id     out varchar2, -- IVR script ID
                      tts_english    OUT varchar2, -- Text to Speech English
                      tts_spanish    out varchar2, -- Text to Speech Spanish
                      HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                      err            out varchar2, -- Error Number
                      msg            out varchar2,-- Additional Messages
                      OP_URL         OUT VARCHAR2,
                      OP_URL_TEXT_EN OUT VARCHAR2,
                      op_url_text_es out varchar2,
                      OP_SMS_TEXT    OUT VARCHAR2)
is
  v_dismissed_variable varchar2(4000);
  v_alert_objid            number;
  v_is_alert_suppressible  varchar2(1);
begin
  get_alert (esn            => esn,
             step           => step,
             channel        => channel,     -- Channel to display flash   --CR37075
             title          => title, -- Alert Title
             csr_text       => csr_text, -- Text to be used in WEBCSR
             eng_text       => eng_text, -- Web Text English
             spa_text       => spa_text, -- Web Text Spanish
             ivr_scr_id     => ivr_scr_id, -- IVR script ID
             tts_english    => tts_english, -- Text to Speech English
             tts_spanish    => tts_spanish, -- Text to Speech Spanish
             hot            => hot, -- 0 Let customer continue, 1 Transfer
             err            => err, -- Error Number
             msg            => msg,-- Additional Messages
             op_url         => v_dismissed_variable,
             op_url_text_en => v_dismissed_variable,
             op_url_text_es => v_dismissed_variable,
             op_sms_text    => v_dismissed_variable,
             alert_objid           => v_alert_objid,             -- OVERLOADED -- CR55156_Update_TAS_Flash_agent_view_System_Improvement
             is_alert_suppressible => v_is_alert_suppressible);  -- OVERLOADED -- CR55156_Update_TAS_Flash_agent_view_System_Improvement);
end get_alert;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure get_alert_2pos (esn            varchar2,
                            step           number,
                            channel        varchar2,     -- Channel to display flash
                            title          out varchar2, -- Alert Title
                            CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                            eng_text       out varchar2, -- Web Text English
                            SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                            ivr_scr_id     out varchar2, -- IVR script ID
                            tts_english    OUT varchar2, -- Text to Speech English
                            tts_spanish    out varchar2, -- Text to Speech Spanish
                            HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                            err            out varchar2, -- Error Number
                            msg            out varchar2,-- Additional Messages
                            OP_URL         OUT VARCHAR2,
                            op_url_text_en out varchar2,
                            op_url_text_es out varchar2,
                            op_sms_text    out varchar2)
  is
    v_brand varchar2(30);
  begin
    -- THE STEP IN THIS SIGNATURE IS MOOT. WE SHOULD CONSIDER REMOVING IT.
    migration_alert(esn => esn,step => 2,channel => channel,title => title,csr_text => csr_text,eng_text => eng_text,spa_text => spa_text,ivr_scr_id => ivr_scr_id,
                    tts_english => tts_english,tts_spanish => tts_spanish,hot => hot,err => err,op_msg => msg,op_url => op_url,op_url_text_en => op_url_text_en,
                    op_url_text_es => op_url_text_es,op_sms_text => op_sms_text,op_bus_org => v_brand);
    return;
  end get_alert_2pos;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure migration_alert(esn            varchar2,
                            step           number,
                            channel        varchar2,     -- Channel to display flash
                            title          out varchar2, -- Alert Title
                            CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                            eng_text       out varchar2, -- Web Text English
                            SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                            ivr_scr_id     out varchar2, -- IVR script ID
                            tts_english    OUT varchar2, -- Text to Speech English
                            tts_spanish    out varchar2, -- Text to Speech Spanish
                            HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                            err            out varchar2, -- Error Number
                            op_msg         out varchar2, -- Additional Messages
                            OP_URL         OUT VARCHAR2,
                            op_url_text_en out varchar2,
                            op_url_text_es out varchar2,
                            op_sms_text    out varchar2,
                            op_bus_org     out varchar2)
  is
    ------------------------------------------------------------------
    -- PLUGGING IN NEW 2G VARIABLES
    ------------------------------------------------------------------
    v_part_inst_status varchar2(30);
    v_phone_gen varchar2(30);
    v_brand varchar2(30);
    v_x_queue_name varchar2(30);
    v_class_name varchar2(30);
    v_zipcode table_site_part.x_zipcode%type;
    v_customer_min varchar2(100);
    v_case_status varchar2(10) := 'NO_CASE';
    ------------------------------------------------------------------
  begin
    op_msg := 'No Alert Found';
    err           := '0';
    -- CREATED ORIGINALLY FOR 2GMIGRATION BUT WITH INTENTIONS TO EXPAND ANYTIME
    -- IF A NEW MIGRATION ALERT IS REQUIRED
    sa.tech_migration_pkg.get_device_info(p_esn => esn,
                                          p_min => null,
                                          op_code_number => v_part_inst_status,
                                          op_phone_gen => v_phone_gen,
                                          op_brand => v_brand,
                                          op_queue_name => v_x_queue_name,
                                          op_part_class => v_class_name,
                                          op_zipcode => v_zipcode);
    op_bus_org := v_brand;

    -- ESN MUST BE 2G
    if v_phone_gen = '2G' then
      -- NEW REQUIREMENT DUE FOR 5/14
      -- BLOCK ALL ACTIVATIONS+REACTIVATIONS
      -- ONLY CHECK ACTIVE PHONES FOR A WAREHOUSE CASE ANY OTHER PHONE BLOCK
      if sa.tech_migration_pkg.has_a_warehouse_case(ip_esn => esn, ip_flash_start_date => null) is not null then
        v_case_status := 'HAS_CASE';
          -- if v_part_inst_status = '52' then
          -- check ship date >5 then
          -- WE MIGHT ONE DAY NEED A NEW ALERT LETTING THE CUSTOMER KNOW THEY CANNOT CONTINUE
          -- return;
          -- end if;
      end if;

      --------------------------------------------------------------------------
      -- ALERT PRIORITY
      -- 0. HAS CASE CHECK
      -- 1. ESN driven flash HOT
      -- 2. ESN driven flash COLD
      -- 3. Part Class driven HOT
      -- 4. Part Class driven COLD
      --------------------------------------------------------------------------

      -- HAS CASE HOT ALERT CHECK (THE VALUES HERE ARE NO_CASE,HAS_CASE,SHIPPED - "SHIPPED IS PENDING AT THE MOMENT")
      if v_case_status = 'HAS_CASE' then
        for i in (select a.title,a.x_web_text_english,a.x_web_text_spanish,a.x_tts_english,a.x_tts_spanish,a.x_ivr_script_id,a.hot,a.alert_text,a.url_text_en,a.url_text_es,a.url,a.sms_message,a.start_date
                  from  table_alert a,
                        table_x_alert_by_carrier  c
                  where 1=1
                  and   c.alert_objid = a.objid
                  and   c.case_status = 'HAS_CASE'
                  and   c.status = v_part_inst_status
                  and   (c.carrier = v_x_queue_name
                  or     c.carrier = 'ALL')
                  and    nvl(a.end_date,sysdate+1) > sysdate
                  and   a.x_step = decode(step,0,1,null,1,'',1,step)
                  and   a.hot = 1
                )
        loop
          csr_text          := i.alert_text;
          title             := i.title;
          eng_text          := i.x_web_text_english;
          spa_text          := i.x_web_text_spanish;
          tts_english       := i.x_tts_english;
          tts_spanish       := i.x_tts_spanish;
          hot               := i.hot;
          ivr_scr_id        := i.x_ivr_script_id;
          op_sms_text       := i.sms_message;
          op_url_text_en    := i.url_text_en; -- WILL BE SCRIPT ID DRIVEN
          op_url_text_es    := i.url_text_es; -- WILL BE SCRIPT ID DRIVEN
          op_url            := i.url;
        end loop;
      end if;

      -- 1. ESN driven flash HOT
      if title is null and v_case_status = 'NO_CASE' then
        for j in (select a.title,a.x_web_text_english,a.x_web_text_spanish,a.x_tts_english,a.x_tts_spanish,a.x_ivr_script_id,a.hot,a.alert_text,a.url_text_en,a.url_text_es,a.url,a.sms_message,a.start_date
                  from   table_alert a,
                         esn_to_alert m,
                         table_x_alert_by_carrier c
                  where  1=1
                  and    a.objid = m.alert_objid
                  and    a.objid = c.alert_objid
                  and    m.x_esn = esn
                  and    c.case_status = 'NO_CASE'
                  and    c.status = v_part_inst_status
                  and   (c.carrier = v_x_queue_name
                  or     c.carrier = 'ALL')
                  and    nvl(a.end_date,sysdate+1) >= sysdate
                  and    alert2bus_org in (select objid
                                           from table_bus_org
                                           where org_id = v_brand)
                  and   a.x_step = decode(step,0,1,null,1,'',1,step)
                  and   a.hot = 1
                  )
        loop
          if j.title like '2G Migration Alert Text%' then
            csr_text          := j.alert_text;
            title             := j.title;
            eng_text          := j.x_web_text_english;
            spa_text          := j.x_web_text_spanish;
            tts_english       := j.x_tts_english;
            tts_spanish       := j.x_tts_spanish;
            hot               := j.hot;
            ivr_scr_id        := j.x_ivr_script_id;
            op_sms_text       := j.sms_message;
            op_url_text_en    := j.url_text_en;
            op_url_text_es    := j.url_text_es;
            op_url            := j.url;
          end if;
        end loop;
      end if;

      -- 2. ESN driven flash COLD
      if title is null and v_case_status = 'NO_CASE' then
        for j in (select a.title,a.x_web_text_english,a.x_web_text_spanish,a.x_tts_english,a.x_tts_spanish,a.x_ivr_script_id,a.hot,a.alert_text,a.url_text_en,a.url_text_es,a.url,a.sms_message,a.start_date
                  from   table_alert a,
                         esn_to_alert m,
                         table_x_alert_by_carrier c
                  where  1=1
                  and    a.objid = m.alert_objid
                  and    a.objid = c.alert_objid
                  and    m.x_esn = esn
                  and    c.case_status = 'NO_CASE'
                  and    c.case_status = v_case_status
                  and    c.status = v_part_inst_status
                  and   (c.carrier = v_x_queue_name
                  or     c.carrier = 'ALL')
                  and    nvl(a.end_date,sysdate+1) >= sysdate
                  and    alert2bus_org in (select objid
                                           from table_bus_org
                                           where org_id = v_brand)
                  and   a.x_step = decode(step,0,1,null,1,'',1,step)
                  and   a.hot = 0
                  )
        loop
          if j.title like '2G Migration Alert Text%' then
            csr_text          := j.alert_text;
            title             := j.title;
            eng_text          := j.x_web_text_english;
            spa_text          := j.x_web_text_spanish;
            tts_english       := j.x_tts_english;
            tts_spanish       := j.x_tts_spanish;
            hot               := j.hot;
            ivr_scr_id        := j.x_ivr_script_id;
            op_sms_text       := j.sms_message;
            op_url_text_en    := j.url_text_en;
            op_url_text_es    := j.url_text_es;
            op_url            := j.url;
          end if;
        end loop;
      end if;

      -- 3. Part Class driven HOT
      if title is null and v_case_status = 'NO_CASE' then
        for i in (select a.title,a.x_web_text_english,a.x_web_text_spanish,a.x_tts_english,a.x_tts_spanish,a.x_ivr_script_id,a.hot,a.alert_text,a.url_text_en,a.url_text_es,a.url,a.sms_message,a.start_date
                  from   table_alert a,
                         table_x_alert_by_carrier m,
                         alert_by_carrier_to_pc c2p
                  where  a.title like '2G Migration Alert Text%'
                  and    a.objid = m.alert_objid
                  and    m.alert_objid = c2p.carrier_alert_objid
                  and    m.status = v_part_inst_status
                  and    m.case_status = 'NO_CASE'
                  and   (m.carrier = v_x_queue_name
                  or     m.carrier = 'ALL')
                  and   (c2p.part_class = v_class_name
                  or     c2p.part_class = 'ALL')
                  and    nvl(a.end_date,sysdate+1) > sysdate
                  and    alert2bus_org in (select objid
                                           from table_bus_org
                                           where org_id = v_brand)
                  and   a.x_step = decode(step,0,1,null,1,'',1,step)
                  and   a.hot = 1
                )
        loop
          csr_text          := i.alert_text;
          title             := i.title;
          eng_text          := i.x_web_text_english;
          spa_text          := i.x_web_text_spanish;
          tts_english       := i.x_tts_english;
          tts_spanish       := i.x_tts_spanish;
          hot               := i.hot;
          ivr_scr_id        := i.x_ivr_script_id;
          op_sms_text       := i.sms_message;
          op_url_text_en    := i.url_text_en; -- WILL BE SCRIPT ID DRIVEN
          op_url_text_es    := i.url_text_es; -- WILL BE SCRIPT ID DRIVEN
          op_url            := i.url;
        end loop;
      end if;

      -- 4. Part Class driven COLD
      if title is null and v_case_status = 'NO_CASE' then
        for i in (select a.title,a.x_web_text_english,a.x_web_text_spanish,a.x_tts_english,a.x_tts_spanish,a.x_ivr_script_id,a.hot,a.alert_text,a.url_text_en,a.url_text_es,a.url,a.sms_message,a.start_date
                  from   table_alert a,
                         table_x_alert_by_carrier m,
                         alert_by_carrier_to_pc c2p
                  where  a.title like '2G Migration Alert Text%'
                  and    a.objid = m.alert_objid
                  and    m.alert_objid = c2p.carrier_alert_objid
                  and    m.status = v_part_inst_status
                  and    m.case_status = 'NO_CASE'
                  and   (m.carrier = v_x_queue_name
                  or     m.carrier = 'ALL')
                  and   (c2p.part_class = v_class_name
                  or     c2p.part_class = 'ALL')
                  and    nvl(a.end_date,sysdate+1) > sysdate
                  and    alert2bus_org in (select objid
                                           from table_bus_org
                                           where org_id = v_brand)
                  and   a.x_step = decode(step,0,1,null,1,'',1,step)
                  and   a.hot = 0
                )
        loop
          csr_text          := i.alert_text;
          title             := i.title;
          eng_text          := i.x_web_text_english;
          spa_text          := i.x_web_text_spanish;
          tts_english       := i.x_tts_english;
          tts_spanish       := i.x_tts_spanish;
          hot               := i.hot;
          ivr_scr_id        := i.x_ivr_script_id;
          op_sms_text       := i.sms_message;
          op_url_text_en    := i.url_text_en; -- WILL BE SCRIPT ID DRIVEN
          op_url_text_es    := i.url_text_es; -- WILL BE SCRIPT ID DRIVEN
          op_url            := i.url;
        end loop;
      end if;

      if title is not null then
        for i in (
                  select l.part_serial_no
                  from   table_part_inst p,
                         table_part_inst l
                  where  1=1
                  and    p.x_domain = 'PHONES'
                  and    l.x_domain = 'LINES'
                  and    p.objid = l.part_to_esn2part_inst
                  and    p.part_serial_no = esn
                  and rownum <2
                  )
        loop
          v_customer_min := 'customermin='||i.part_serial_no;
        end loop;
      end if;

      if title is not null then
        if op_url is not null then
          if v_customer_min is not null then
            op_url := op_url||'?'||v_customer_min||'&last4ofesn='||substr(esn,length(esn)-3);
          else
            op_url := op_url||'?last4ofesn='||substr(esn,length(esn)-3);
          end if;
        end if;

        op_msg := 'Alert Found';
      end if;
    end if;

  end migration_alert;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE cancel_alert(
  TYPE   VARCHAR2,
  sqlstr VARCHAR2,
  esn    VARCHAR2,
  start_date DATE,
  end_date DATE,
  err OUT VARCHAR2,
  CANCEL OUT BOOLEAN )
IS
  count_value NUMBER := 0;
BEGIN
  err    := '0';
  CANCEL := FALSE;
  dbms_output.put_line('coming inside');
  dbms_output.put_line('TYPE'||TYPE);
  IF TYPE LIKE '%SQL%'
  OR UPPER(sqlstr) LIKE '%SELECT%'	--- Added by Rahul for defect 3576 raised for CR33579
  THEN
  dbms_output.put_line('TYPE'||TYPE);
  dbms_output.put_line('sqlstr'||sqlstr);
  dbms_output.put_line('esn'||esn);
  dbms_output.put_line('start_date'||start_date);
  dbms_output.put_line('end_date'||end_date);
  /* Commented and modified by Rahul for defect 3576 raised for CR33579
  EXECUTE IMMEDIATE sqlstr INTO count_value USING esn,
		  start_date,
		  end_date;
	*/

	IF UPPER(sqlstr) LIKE '%ESN%' AND UPPER(sqlstr) LIKE '%START_DATE%' AND UPPER(sqlstr) LIKE '%END_DATE%'  -- If else added by Rahul for defect 3576 raised for CR33579
	THEN
		EXECUTE IMMEDIATE sqlstr INTO count_value USING esn,
		start_date,
		end_date;

	ELSIF UPPER(sqlstr) LIKE '%ESN%' AND UPPER(sqlstr) LIKE '%END_DATE%'
	THEN

		EXECUTE IMMEDIATE sqlstr INTO count_value USING esn,end_date;

	ELSIF UPPER(sqlstr) LIKE '%ESN%' AND UPPER(sqlstr) NOT LIKE '%END_DATE%' AND UPPER(sqlstr) NOT LIKE '%START_DATE%'
	THEN

		EXECUTE IMMEDIATE sqlstr INTO count_value USING esn;

	ELSE

		EXECUTE IMMEDIATE sqlstr INTO count_value;

	END IF;




  IF count_value > 0 THEN
    CANCEL      := TRUE;
  END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN
  err := SQLERRM;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
   function r_migration_alert_obj (ip_brand varchar2, ip_type varchar2, ip_hot varchar2, ip_position varchar2, ip_url varchar2, ip_status varchar2)
   return varchar2
   is
    r_obj number;
    v_title table_alert.title%type;
   begin

    select '2G Migration Alert Text - '||objid
    into v_title
    from migration_flash_key_values
    where 1=1
    and brand = ip_brand
    and action = ip_type
    and has_microsite_url = ip_url
    and hot_or_cold = ip_hot
    and phone_status = ip_status
    and position = ip_position;

    select objid
    into r_obj
    from table_alert where title = v_title;

    return r_obj;
    exception
      when others then
        dbms_output.put_line('r_migration_alert_obj - ip_type ==>'||ip_type||', ip_brand ==>'||ip_brand||', ip_hot ==>'||ip_hot||', ip_url ==>'||ip_url||', ip_status ==>'||ip_status);
   end r_migration_alert_obj;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure winback_alert(esn            varchar2,
                          step           number,
                          channel        varchar2,     -- Channel to display flash
                          title          out varchar2, -- Alert Title
                          CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                          eng_text       out varchar2, -- Web Text English
                          SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                          ivr_scr_id     out varchar2, -- IVR script ID
                          tts_english    OUT varchar2, -- Text to Speech English
                          tts_spanish    out varchar2, -- Text to Speech Spanish
                          HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                          err            out varchar2, -- Error Number
                          op_msg         out varchar2, -- Additional Messages
                          OP_URL         OUT VARCHAR2,
                          op_url_text_en out varchar2,
                          op_url_text_es out varchar2,
                          op_sms_text    out varchar2,
                          op_bus_org     out varchar2)
  is
  CURSOR c_getwinback (i_esn VARCHAR2) IS
  SELECT al.*
	FROM x_portout_winback_log log,
	     table_alert al
	WHERE PORT_OUT_STATUS='CASE CREATED'
	AND ESN              = i_esn
	AND title            = 'Port out Winback Offer'
	AND rownum           =1;

 r_getwinback c_getwinback%ROWTYPE;

  begin
    op_msg := 'No Alert Found';
    err           := '0';
	For i in c_getwinback (i_esn => esn)
	loop
	      csr_text          := i.alert_text;
          title             := i.title;
          eng_text          := i.x_web_text_english;
          spa_text          := i.x_web_text_spanish;
          tts_english       := i.x_tts_english;
          tts_spanish       := i.x_tts_spanish;
          hot               := i.hot;
          ivr_scr_id        := i.x_ivr_script_id;
          op_sms_text       := i.sms_message;
          op_url_text_en    := i.url_text_en; -- WILL BE SCRIPT ID DRIVEN
          op_url_text_es    := i.url_text_es; -- WILL BE SCRIPT ID DRIVEN
          op_url            := i.url;
          op_msg := 'Alert Found';
	end loop;
    EXCEPTION
	  WHEN OTHERS THEN
		 err := '99';
  end winback_alert;
--------------------------------------------------------------------------------
-- CR52609 START All BRANDS - ALL - Send a message to customers during maintenance outages periods

procedure outage_alerts(ip_esn varchar2,
                          ip_channel varchar2,
                          ip_display_point varchar2,
                          ip_flow varchar2,
                          ip_language varchar2,
                          op_outage_title out varchar2,
                          op_outage_alert out varchar2,
                          ip_multi_line varchar2 default 'N', -- As part of CR we added a flag to identify single line or multiline. If 'Y' means mutiline.
                          ip_zip_code IN VARCHAR2 default NULL) -- As part of CR55585 to capture zip code while activation flow.
  is
    -- column x_web_text_english for alert message
    -- column type for CARR_OUTAGE
    -- column title = Carrier outage message for [x_queue_name]
    v_this_min                varchar2(30);
    v_sim_profile             varchar2(30);
    v_x_zipcode               varchar2(30);
    v_carrier_parent          varchar2(80);
    v_zip_list                long;         -- alert_text long in database  -- use for zip_code_list
    v_x_cancel_sql            varchar2(4000); -- use column x_cancel_sql this for display time (BEFORE/AFTER/BOTH)
    v_x_step                  number; -- use column x_step for on/off switch 1 = ON / 0 = OFF
    v_outage_alert_title      varchar2(80);
    v_outage_type             varchar2(80);
    v_tech                    varchar2(30);
    v_web_user_objid          number; -- added as part of CR55994 for muti line check
    v_brand                   varchar2(30);

    function ret_esn_min(ip_esn varchar2,ip_esn_min varchar2)
    return varchar2
    is
      v_min varchar2(30);
    begin
      if ip_esn_min is not null then
        v_min := ip_esn_min;
      else
        -- RESERVED MIN
        for i in (
                  select lpi.part_serial_no x_min
                  from table_part_inst lpi
                  where lpi.part_to_esn2part_inst = (select objid
                                                     from table_part_inst
                                                     where part_serial_no = ip_esn
                                                     and x_domain = 'PHONES')
                  and lpi.x_domain = 'LINES'
                  and length(lpi.part_serial_no) = 10
                  and rownum < 2
                  )
        loop
          v_min := i.x_min;
        end loop;
        -- IF FOUND IN SITE PART, USE THAT THEN
        for i in (
                  select  x_min
                  from    sa.table_part_inst pi,
                          sa.table_site_part sp
                  where   pi.x_domain = 'PHONES'
                  and     pi.x_part_inst2site_part = sp.objid
                  and     pi.part_serial_no = ip_esn
                  )
        loop
          v_min := i.x_min;
        end loop;
      end if;
      return v_min;
    end ret_esn_min;
  begin
  /* added as part of CR55994 for muti line check outages*/
--if ip_multi_line = 'Y' THEN

   v_brand := util_pkg.get_bus_org_id(ip_esn);
   -- CR55585  Removed  'ACTIVATION_PG',
   if v_brand = 'SIMPLE_MOBILE' and ip_channel = 'TAS' and ip_flow IN('ENROLLMENT_PG','UPGRADE_PORT_WFM_PG')  -- Added as part of CR55994 for "Outage message should be displayed only for Redemptions"
   then return;
    end if;   -- -- added as part of CR55994 for muti line check

--    v_web_user_objid  := SA.util_pkg.get_web_user_objid(ip_esn);
    v_web_user_objid  := sa.customer_info.get_web_user_attributes (ip_esn, 'WEB_USER_ID'); -- Changed for CR55585

    FOR i IN (SELECT ip_esn IP_ESN FROM DUAL
           UNION
          SELECT pi.part_serial_no IP_ESN
            FROM table_web_user wu, table_x_contact_part_inst cpi,table_part_inst pi
            WHERE wu.web_user2contact = cpi.x_contact_part_inst2contact
              AND cpi.x_contact_part_inst2part_inst = pi.objid
              AND wu.objid = v_web_user_objid
              AND pi.x_part_inst_status = 52
              AND (ip_multi_line = 'Y' OR (ip_flow = 'REDEPTION_PURCHASE_WFM_PG' OR ip_flow = 'ENROLLMENT_PG'))) loop  -- added as part of CR55994 for muti line check

    -- GET THE ESN'S MIN AND GET CARRIER PARENT INFO
    v_this_min := ret_esn_min(ip_esn =>i.IP_ESN,ip_esn_min =>'');

    begin
      select  x_zipcode
      into    v_x_zipcode
      from    sa.table_part_inst pi,
              sa.table_site_part sp
      where   pi.x_domain = 'PHONES'
      and     pi.x_part_inst2site_part = sp.objid
      and     pi.part_serial_no = i.IP_ESN;
    exception
      when others then
  -- CR55585 code start
        begin
      SELECT zipcode into v_x_zipcode
    FROM   table_x_contact_part_inst cpi,
           table_web_user wu,
           table_part_inst inst,
           table_contact tc
    WHERE  1 = 1
    AND    wu.web_user2contact = cpi.x_contact_part_inst2contact
    and x_contact_part_inst2part_inst = inst.objid
    and cpi.x_contact_part_inst2contact = tc.objid
    and inst.x_domain = 'PHONES'
    and inst.part_serial_no =  i.IP_ESN;

    exception
      when others then
       v_x_zipcode:= ip_zip_code; -- As part of CR55585 to capture zip code while activation flow
    end;
    -- CR55585 code end
    end;

    -- GET THE CARRIER
    for i in (
              select cp.x_queue_name
              from   sa.table_x_carrier car,
                     sa.table_x_carrier_group cg,
                     sa.table_x_parent cp,
                     sa.table_part_inst pi
              where  1=1
              and    cp.x_status in ('Active','ACTIVE')
              and    car.objid = pi.part_inst2carrier_mkt
              and    car.carrier2carrier_group = cg.objid
              and    cg.x_carrier_group2x_parent = cp.objid
              and    pi.part_serial_no = v_this_min
              )
    loop
      v_carrier_parent := i.x_queue_name;
    end loop;

    -- IF YOU FAILED IN GETTING THE CARRIER BY MIN, THEN TRY BY SIM
    if v_carrier_parent is null then
      for j in (
                select pn.part_number sim_profile
                from   table_x_sim_inv sim
                       ,table_part_inst pi
                       ,table_mod_level ml
                       ,table_part_num pn
                       ,table_x_code_table cd
                where pi.x_iccid = sim.x_sim_serial_no
                and   ml.objid = sim.x_sim_inv2part_mod
                and   pn.objid = ml.part_info2part_num
                and   cd.x_code_type = 'SIM'
                and   cd.x_code_number = sim.x_sim_inv_status
                and   pi.part_serial_no = i.IP_ESN
                and   pi.x_domain = 'PHONES'
               )
      loop
        v_sim_profile := j.sim_profile;
      end loop;

      if v_sim_profile is not null then
        for k in (
                  select cp.x_queue_name
                  from table_x_carrier car,
                       carriersimpref csp,
                       sa.table_x_carrier_group cg,
                       sa.table_x_parent cp
                  where car.x_mkt_submkt_name = csp.carrier_name
                  and    car.carrier2carrier_group = cg.objid
                  and    cg.x_carrier_group2x_parent = cp.objid
                  and sim_profile = v_sim_profile)
        loop
          v_carrier_parent := k.x_queue_name;
        end loop;
      end if;

    end if;

    -- IF A SIM IS NOT FOUND THEN IF IT'S CDMA, ASSUME IT'S A VERIZON CDMA
    if v_carrier_parent is null then
      select  get_param_by_name_fun(pc.name,'TECHNOLOGY') tech
      into    v_tech
      from    sa.table_part_inst pi,
              sa.table_site_part sp,
              sa.table_mod_level m,
              table_part_num pn,
              table_part_class pc
      where   pi.x_domain = 'PHONES'
      and     pi.x_part_inst2site_part = sp.objid
      and     pi.part_serial_no = i.IP_ESN
      and     m.part_info2part_num = pn.objid
      and     pi.n_part_inst2part_mod = m.objid
      and     pn.part_num2part_class = pc.objid;

      if v_tech = 'CDMA' and v_x_zipcode is not null then
          select  x_queue_name
          into   v_carrier_parent
          from    (select  p.x_queue_name
                   from     carrierpref          e
                          ,table_x_carrier       c
                          ,npanxx2carrierzones   b
                          ,carrierzones          a
                          ,table_x_parent        p
                          ,table_x_carrier_group cg
                  where   a.county         = e.county
                  and     e.st         = b.state
                  and     e.carrier_id = b.carrier_id
                  and     e.carrier_id = c.x_carrier_id
                  and     b.frequency1 in ( '1900' ,'800' )
                  and     ( b.tdma_tech    = 'CDMA' or b.cdma_tech = 'CDMA' or b.gsm_tech  = 'CDMA')
                  and     a.zone            = b.zone
                  and     b.state           = a.st
                  and     a.zip             = v_x_zipcode
                  and     p.objid           = cg.x_carrier_group2x_parent
                  and     upper(p.x_status) = 'ACTIVE'
                  and     cg.objid          = c.carrier2carrier_group
                  and     cg.x_status       = 'ACTIVE'
                  order by new_rank)
          where  rownum = 1;
      end if;
    end if;

    select l.title,e.description,e.addnl_info
    into   v_outage_type,v_outage_alert_title,op_outage_title
    from table_gbst_elm e,
         table_gbst_lst l
    where e.gbst_elm2gbst_lst = l.objid
    and   l.title like '%OUTAGE%'
    and   e.description like '%'||v_carrier_parent||'_'||ip_channel||'_'||ip_display_point||'_'||decode(upper(ip_language),'EN','ENGLISH','ES','SPANISH',upper(ip_language))
    and rownum < 2;

    if ip_flow is not null then
      -- CREATED MAINLY FOR TAS'S COMPLEX TRANSACTION SUMMARY FLOW
      -- HOWEVER ALL CHANNELS CAN BE CONFIGURED THIS AS WELL.
      -- CURRENTLY ALL THE FLOWS HAVE THE SAME TEXT, BUT, IF THIS CHANGES, WE WOULD HAVE TO
      -- CHANGE THE CONFIGURATION TO OUTAGE_TYPE + CARRIER + CHANNEL + DISPLAY_POINT + LANGUAGE
      for i in (
                select count(*) cnt
                from sa.table_gbst_elm e,
                     sa.table_gbst_lst l
                where e.gbst_elm2gbst_lst = l.objid
                and   l.title = v_outage_type
                and  e.s_title = ip_channel
                and  e.description = ip_flow
                )
      loop
        if i.cnt = 0 then
          dbms_output.put_line('NO FLOW CONFIG FOR ('||ip_channel||','||ip_flow||')');
          op_outage_title := null;
          return;
        end if;
      end loop;
    end if;

    select x_web_text_english,alert_text,x_cancel_sql
    into op_outage_alert,v_zip_list,v_x_cancel_sql
    from table_alert
    where title = v_outage_alert_title
    and x_step = 1
    and alert2contact = -1
    and ALERT2SITE = -1
    and alert2contract = -1
    ;

    op_outage_alert := substr(op_outage_alert,0,2000);
--    dbms_output.put_line('ESN MIN  =>'||v_this_min);
--    dbms_output.put_line('CARRIER  =>'||v_carrier_parent);
--    dbms_output.put_line('ZIP LIST =>'||v_zip_list);
--    dbms_output.put_line('CUST ZIP =>'||v_x_zipcode);
--    dbms_output.put_line('DISPLAY  =>'||v_x_cancel_sql);
--    dbms_output.put_line('FOUND IT ('||nvl(instr(v_zip_list,v_x_zipcode),0)||')');

--  REMOVED THIS BECAUSE OF DEFECT 33724 THIS PROC WILL REQUIRE A SIGNATURE CHANGE
--  AND ACCEPT A ZIPCODE FOR ACTIVATION FLOW
--	if v_x_zipcode is null and (ip_flow like '%ACTIVATION%' or nvl(instr('GRP_ACT_PORT_PURCHASE_PG,COMPLETE_PORT_PG',ip_flow),0)>0) then
--      -- IF NO ZIPCODE IS FOUND
--      -- BUT, CARRIER OPS TURNED ON THE ALERT FLAG
--      -- SHOW THE MESSAGE ANYWAY
--      -- THIS IS AN ISOLATED ISSUE PERTAINING ONLY TO ACTIVATION
--      return;
--    end if;

    DBMS_OUTPUT.PUT_LINE('ESN: ' || i.ip_esn);
    if nvl(instr(v_zip_list,v_x_zipcode),0)<=0 then
      op_outage_title := null;
      op_outage_alert := null;
    end if;

if op_outage_title is not null then
    return;
    end if;
 end loop;   -- -- added as part of CR55994 for muti line check

  exception
    when others then
      op_outage_title := null;
      dbms_output.put_line('NO OUTAGE CONFIG FOR ('||v_outage_type||'_'||v_carrier_parent||'_'||ip_channel||'_'||ip_display_point||'_'||ip_language||')');
  end outage_alerts;
  -- TEMP FUNCTION UNTIL ALL BRANDS ARE ENABLED
  function outage_restriction(ip_brand varchar2)
  return varchar2
  is
    ret_val varchar2(10) := 'SHOW';
  begin
    -- IF NO RESTRICTION EXISTS RETURN SHOW
    -- IF A RESTRICTION TO NOW SHOW EXISTS RETURN DONT_SHOW
    select decode(instr(e.description,ip_brand),'0','SHOW','DONT_SHOW') show_status
    into ret_val
    from table_gbst_elm e,
         table_gbst_lst l
    where e.gbst_elm2gbst_lst = l.objid
    and   l.title like '%OUTAGE%'
    and  e.s_title = 'BRAND_EXCEPTION'
    and rownum < 2;
    return ret_val;
  exception
    when others then
      return ret_val;
  end outage_restriction;

  procedure set_carrier_outage_switch (
                                       ip_affected_carrier varchar2,
                                       ip_affected_zipcodes varchar2,
                                       ip_user_decision number -- 1=ON, 0=OFF
                                       )
  is
  begin
    update table_alert
    set alert_text = ip_affected_zipcodes,
        x_step = ip_user_decision
    where title like 'CARR_OUTAGE'||'_'||ip_affected_carrier||'%'
    and alert2contact = '-1'
    and alert2site = '-1'
    and alert2contract = '-1';

  exception
    when others then
      null;
  end set_carrier_outage_switch;


  -- CR52609  END All BRANDS - ALL - Send a message to customers during maintenance outages periods

   FUNCTION get_alert_suppression(i_esn         IN    VARCHAR2,
                                  i_alert_objid IN    NUMBER,
                                  i_channel     IN    VARCHAR2
                                 )
  RETURN VARCHAR2
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;
     v_is_alert_suppressed VARCHAR2(1) := 'N';
  BEGIN
     IF i_channel = 'TAS' THEN
        SELECT 'Y'
          INTO v_is_alert_suppressed
          FROM table_alert_suppression
         WHERE x_esn = i_esn
           AND alert_objid = i_alert_objid;
        RETURN v_is_alert_suppressed; -- Y
     ELSE
        RETURN v_is_alert_suppressed;  -- N
     END IF;
  EXCEPTION WHEN OTHERS THEN
    RETURN v_is_alert_suppressed;
  END;
  PROCEDURE set_alert_suppression(i_esn           IN      VARCHAR2,
                                  i_alert_objid   IN      NUMBER,
                                  i_agent_id      IN      VARCHAR2,
                                  o_err_code         OUT  VARCHAR2,
                                  o_err_msg          OUT  VARCHAR2
                                 )
  IS
  v_creation_date date := sysdate;
  BEGIN
  o_err_code := '0';
  o_err_msg  := 'Success';
         merge into table_alert_suppression m using dual on (x_esn = i_esn and alert_objid = i_alert_objid)
         when not matched then insert (
                                       x_esn,
                                       alert_objid,
                                       agent_id,
                                       creation_date
                                      )
                                       values
                                      (
                                       i_esn,
                                       i_alert_objid,
                                       i_agent_id,
                                       v_creation_date
                                      )
             when matched then update set agent_id = i_agent_id,
                                          creation_date = v_creation_date;
  COMMIT;
    EXCEPTION WHEN OTHERS THEN
     o_err_code := SQLCODE;
     o_err_msg  := SQLERRM;
  END;
END ALERT_PKG;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/ALERT_PKG.sql 	CR55994: 1.85
/