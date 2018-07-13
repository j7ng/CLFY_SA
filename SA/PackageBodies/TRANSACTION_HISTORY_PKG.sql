CREATE OR REPLACE PACKAGE BODY sa.transaction_history_pkg
AS
/*******************************************************************************************************
 --$RCSfile: transaction_history_pkg.sql,v $
 --$Revision: 1.30 $
 --$Author: vlaad $
 --$Date: 2017/08/08 21:43:40 $
 --$ $Log: transaction_history_pkg.sql,v $
 --$ Revision 1.30  2017/08/08 21:43:40  vlaad
 --$ Merged with 8/8 BAU
 --$
 --$ Revision 1.21  2017/06/06 17:49:51  smeganathan
 --$ Merged code with 6/6 production release
 --$
 --$ Revision 1.20  2017/06/01 22:38:34  abustos
 --$ CR48604 - TF - WEB - 4.0 Display Transaction and Support history for ESNs in Stolen and Ri
 --$
 --$ Revision 1.19  2017/05/30 21:45:57  mshah
 --$ CR48604 - TF - WEB - 4.0 Display Transaction and Support history for ESNs in Stolen and Ri
 --$
 --$ Revision 1.18  2017/05/26 21:20:56  mshah
 --$ 48604 - TF - WEB - 4.0 Display Transaction and Support history for ESNs in Stolen and Ri
 --$
 --$ Revision 1.17  2017/04/18 16:15:29  smeganathan
 --$ Merged with WFM production release
 --$
 --$ Revision 1.16  2017/03/10 23:20:21  sgangineni
 --$ CR47564 - WFM Changes - Added new output service_plan_short_description to the get_transaction_history procedure.
 --$
 --$ Revision 1.15  2017/02/23 19:14:41  smeganathan
 --$ CR48428 changes to fix production issue
 --$
 --$ Revision 1.14  2017/02/23 17:32:20  smeganathan
 --$ CR48428 changes to production issue
 --$
 --$ Revision 1.13  2017/01/17 21:06:29  smeganathan
 --$ CR47023 code fix for transaction history
 --$
 --$ Revision 1.12  2016/11/28 16:11:35  smeganathan
 --$ CR44680 changes to get the service plan descriptions for Tracfone brand
 --$
 --$ Revision 1.11  2016/11/14 19:45:32  smeganathan
 --$ CR44680 changes to get the service plan descriptions for Tracfone brand
 --$
 --$ Revision 1.10  2016/11/08 17:06:24  smeganathan
 --$ CR46350 changes to exclude the gencode transactions in history
 --$
 --$ Revision 1.9  2016/08/26 22:15:38  smeganathan
 --$ CR43248 changes for getting group details
 --$
 --$ Revision 1.8  2016/08/23 21:22:36  smeganathan
 --$ CR43248 changes to get group details in the transaction summary
 --$
 --$ Revision 1.2  2015/11/17 18:51:00  sethiraj
 --$ CR39329 - Included Purchase, Refund, Upgrade, Port In transactions
 --$
 --$ Revision 1.1  2015/07/30 10:00:00  sethiraj
 --$ CR35913 My Accounts App - Phase II
 --$
 * Description: This procedure gets the transaction summary of the ESN
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
--
-- CR44680 added below function to get the Script text
FUNCTION fn_get_script_text_by_scriptid(ip_sourcesystem   IN  VARCHAR2,
                                        ip_brand_name     IN  VARCHAR2,
                                        ip_language       IN VARCHAR2 DEFAULT 'ENGLISH', -- CR48846
                                        ip_script_id      IN  VARCHAR2)
RETURN VARCHAR2
IS
  l_script_type            VARCHAR2(50);
  l_script_id              VARCHAR2(50);
  l_objid                  VARCHAR2(50);
  l_description            VARCHAR2(2000);
  l_script_text            VARCHAR2(2000);
  l_publish_by             VARCHAR2(2000);
  l_publish_date           DATE;
  l_sm_link                VARCHAR2(2000);
  --
BEGIN
  --
  l_script_type := substr(ip_script_id,0,instr(ip_script_id,'_')-1);
  l_script_id   := substr(ip_script_id,instr(ip_script_id,'_')+1);
  --
  scripts_pkg.get_script_prc (ip_sourcesystem   => ip_sourcesystem,
                              ip_brand_name     => ip_brand_name,
                              ip_script_type    => l_script_type,
                              ip_script_id      => l_script_id,
                              ip_language       => ip_language, -- CR48846
                              ip_carrier_id     => null,
                              ip_part_class     => null,
                              op_objid          => l_objid,
                              op_description    => l_description,
                              op_script_text    => l_script_text,
                              op_publish_by     => l_publish_by,
                              op_publish_date   => l_publish_date,
                              op_sm_link        => l_sm_link);

  RETURN l_script_text;
EXCEPTION
WHEN OTHERS THEN
  RETURN null;
END;
--
-- CR44680 added below procedure to the script IDs based on Part number
PROCEDURE get_script_id(ip_part_number    IN    VARCHAR2,
                        p_script_id1      OUT   VARCHAR2,
                        p_script_id2      OUT   VARCHAR2)
AS
  --
  CURSOR get_script_id_info(ip_part_number   table_part_num.part_number%TYPE)
  IS
  SELECT tx.x_web_description,
         tx.x_sp_web_description
  FROM   table_part_num pn,
         table_x_pricing tx
  WHERE tx.x_pricing2part_num = pn.objid
  AND   tx.x_channel = 'APP'
  AND   SYSDATE BETWEEN tx.x_start_date AND tx.x_end_date
  AND   pn.part_number = ip_part_number;
  --
  l_script_id1    TABLE_X_PRICING.X_WEB_DESCRIPTION%TYPE;
  l_script_id2    TABLE_X_PRICING.X_SP_WEB_DESCRIPTION%TYPE;
  --
BEGIN
--
  OPEN get_script_id_info(ip_part_number);
  FETCH get_script_id_info
  INTO  l_script_id1,l_script_id2;
  CLOSE get_script_id_info;
  --
  p_script_id1 := l_script_id1;
  p_script_id2 := l_script_id2;
  --
EXCEPTION
WHEN OTHERS THEN
  p_script_id1 := NULL;
  p_script_id2 := NULL;
END get_script_id;
--
PROCEDURE get_transaction_history( ip_esn                    IN  VARCHAR2,
                                   ip_brand                  IN  VARCHAR2,
                                   out_transaction_hist_cur  OUT sys_refcursor,
                                   p_err_num                 OUT NUMBER ,
                                   p_err_string              OUT VARCHAR2 )
AS
  --
  CURSOR device_nick_name_cur
  IS
  SELECT cpi.x_esn_nick_name
  FROM   table_x_contact_part_inst cpi ,
         table_part_inst pi
  WHERE  cpi.x_contact_part_inst2part_inst = pi.objid
  AND    cpi.x_esn_nick_name               IS NOT NULL
  AND    pi.part_serial_no                 = ip_esn
  AND    ROWNUM < 2;
  --
  CURSOR service_plan_cur ( c_red_card2call_trans   table_x_red_card.red_card2call_trans%TYPE)
  IS
  SELECT spc.sp_objid objid
  FROM   table_x_red_card rc,
         table_mod_level ml,
         table_part_num pn,
         table_part_class pc,
         adfcrm_serv_plan_class_matview spc
  WHERE  pc.objid               = pn.part_num2part_class
  AND    spc.part_class_objid   = pn.part_num2part_class
  AND    ml.part_info2part_num  = pn.objid
  AND    rc.x_red_card2part_mod = ml.objid
  AND    rc.red_card2call_trans = c_red_card2call_trans;
  --
  -- CR43248 added below cursor
  CURSOR get_group_detail
  IS
  SELECT xagm.account_group_id,
         xag.account_group_name
  FROM   (SELECT  MAX(agm.objid) objid
          FROM    x_account_group_member agm
          WHERE   agm.esn     =   ip_esn
          AND     agm.status  <>  'EXPIRED'
          AND     SYSDATE BETWEEN agm.start_date AND NVL(agm.end_date,SYSDATE)) agm1,
         x_account_group_member xagm,
         x_account_group        xag
  WHERE  xag.objid    =   xagm.account_group_id
  AND    agm1.objid   =   xagm.objid
  AND    xagm.esn     =   ip_esn;
  --
  out_transaction_hist_tab  sa.transaction_hist_tab ;
  device_nick_name_rec      device_nick_name_cur%rowtype;
  l_device_name             table_x_contact_part_inst.x_esn_nick_name%TYPE;
  v_service_plan_id         NUMBER;
  v_location                VARCHAR2(1000);
  -- CR43248 Changes starts.
  l_group_id                x_account_group_member.account_group_id%TYPE;
  l_group_name              x_account_group.account_group_name%TYPE;
  get_group_detail_rec      get_group_detail%rowtype;
  -- CR43248 Changes ends
  -- CR44680 Changes Starts..
  l_source_system           VARCHAR2(24);
  l_script_id1              TABLE_X_PRICING.X_WEB_DESCRIPTION%TYPE;
  l_script_id2              TABLE_X_PRICING.X_SP_WEB_DESCRIPTION%TYPE;
  -- CR44680 Changes Ends
  --

  l_not_active_esn          VARCHAR2(2) := 'N'; --48604

BEGIN
  IF ip_esn      IS NULL
  THEN
    p_err_num    := 444;
    p_err_string := 'ESN cannot be NULL';
    RETURN;
  END IF;
  -- Get Device Nick Name from Table_X_Contact_Part_Inst based on Input ESN from the cursor
  OPEN device_nick_name_cur;
  FETCH device_nick_name_cur INTO device_nick_name_rec;
  IF (device_nick_name_cur%found AND device_nick_name_rec.x_esn_nick_name IS NOT NULL)
  THEN
    l_device_name := device_nick_name_rec.x_esn_nick_name;
  END IF;
  CLOSE device_nick_name_cur;
  --
  -- CR43248 added the below to get group details
  OPEN get_group_detail;
  FETCH get_group_detail INTO get_group_detail_rec;
  IF get_group_detail%FOUND THEN
    l_group_id   := get_group_detail_rec.account_group_id;
    l_group_name := get_group_detail_rec.account_group_name;
  END IF;
  CLOSE get_group_detail;
  --
  -- Get Phone Attributes from TABLE_X_ACT_DEACT_HIST based on Input ESN and assign the same to the output
  /*SELECT sa.transaction_hist_rec(hist.call_trans_objid,
                                 hist.date_time,
                                 hist.action_text,
                                 hist.x_min,
                                 l_device_name ,
                                 0 ,
                                 NULL ,
                                 NULL ,
                                 NULL ,
                                 NULL )
         BULK COLLECT
  INTO   out_transaction_hist_tab
  FROM   table_x_act_deact_hist hist
  WHERE  hist.x_service_id= ip_esn
  ORDER BY hist.date_time DESC;
  */

  --48604
  BEGIN --{
   SELECT  'Y'
   INTO    l_not_active_esn
   FROM    table_part_inst tpi
   WHERE   tpi.x_part_inst_status <> '52' --IN ('53', '56') --Stolen, Risk Assesment
   AND     tpi.x_domain = 'PHONES'
   AND     tpi.part_serial_no = ip_esn
   AND     ROWNUM = 1;

  EXCEPTION
  WHEN OTHERS THEN
   l_not_active_esn := 'N';
  END; --}

  -- CR44680 added brand condition to get the transaction history for Tracfone and other brands
  IF ip_brand NOT IN ('TRACFONE')
  THEN
    SELECT sa.transaction_hist_rec(call_trans_objid,
                                   NULL,
                                   date_time,
                                   action_text,
                                   x_min,
                                   l_device_name,
                                   Service_Plan_Id,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   l_group_id,
                                   l_group_name,
                                   NULL --CR47564 WFM Changes
                                   )
           BULK COLLECT
    INTO   out_transaction_hist_tab
    FROM (
          SELECT hist.call_trans_objid    call_trans_objid,
                 hist.date_time           date_time,
                 hist.action_text         Action_Text,
                 hist.x_min               x_min,
                 0                        Service_Plan_Id
          FROM   table_x_act_deact_hist hist
          WHERE  hist.x_service_id  = ip_esn
          AND    hist.action_text   IN ('ACTIVATION','REACTIVATION','DEACTIVATION','REDEMPTION')
          AND    NOT EXISTS ( SELECT 'Y'     -- CR46350 changed condition
                              FROM   x_program_gencode
                              WHERE  x_esn                 = hist.x_service_id
                              AND    hist.call_trans_objid = gencode2call_trans)
          UNION
          SELECT  pdt.objid               call_trans_objid,
                  pd.X_RQST_DATE          date_time,
                  'PURCHASE'              action_text,
                  tsp.x_min               x_min,
                  spsp.X_SERVICE_PLAN_ID  Service_Plan_Id
          FROM    x_program_purch_hdr       pd,
                  x_program_purch_dtl       pdt,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp
          WHERE   nvl(pd.X_ICS_RCODE,'0') IN ('1', '100')                 --Successful payments
          AND     pd.X_MERCHANT_ID        IS NOT NULL                     --Exclude BML
          AND     pd.X_PAYMENT_TYPE       NOT IN ('REFUND', 'OTAPURCH')   --Exclude Refunds and mobile billing
          AND     pd.X_AMOUNT             >= 20                           --Exclude HPP (as of now identifying HPP based on dollar amount)
          AND     pd.X_MERCHANT_ID        NOT LIKE '%wusa%'
          AND     pd.objid                = pdt.pgm_purch_dtl2prog_hdr
          AND     pdt.x_esn               = ip_esn
          AND     pdt.x_esn               = tsp.x_service_id
          AND     tsp.part_status         = 'Active'
          AND     tsp.objid               = spsp.table_site_part_id
          UNION
          SELECT  rf.objid                call_trans_objid,
                  rf.X_RQST_DATE          date_time,
                  'REFUND'                action_text,
                  tsp.x_min               x_min,
                  spsp.X_SERVICE_PLAN_ID  Service_Plan_Id
          FROM    x_program_purch_hdr       rf,
                  x_program_purch_hdr       sl,
                  x_program_purch_dtl       pdt,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp
          WHERE   rf.X_PAYMENT_TYPE       =  'REFUND'
          AND     nvl(rf.X_ICS_RCODE,'0') IN ('1', '100')
          AND     rf.purch_hdr2cr_purch   = sl.objid
          AND     sl.objid                = pdt.pgm_purch_dtl2prog_hdr
          AND     pdt.x_esn               = ip_esn
          AND     pdt.x_esn               = tsp.x_service_id
          AND     tsp.part_status         = 'Active'
          AND     tsp.objid               = spsp.table_site_part_id
          UNION
          SELECT  ct.objid                call_trans_objid,
                  ct.X_TRANSACT_DATE      date_time,
                  'PORT IN'               action_text,
                  ct.x_min                x_min,
                  spsp.X_SERVICE_PLAN_ID  Service_Plan_Id
          FROM    TABLE_TASK                T,
                  TABLE_X_ORDER_TYPE        OT,
                  TABLE_X_CALL_TRANS        ct,
                  table_case                tc,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp
          WHERE   ot.x_order_type     like '%Port%'
          AND     OT.OBJID              = T.X_TASK2X_ORDER_TYPE
          AND     ct.x_service_id       = ip_esn
          AND     ct.x_result           = 'Completed'
          AND     t.X_TASK2X_CALL_TRANS = ct.objid
          AND     t.objid               = tc.x_case2task
          AND     tc.x_case_type        ='Port In'
          AND     ct.x_service_id       = tsp.x_service_id
          AND     tsp.part_status       = 'Active'
          AND     tsp.objid             = spsp.table_site_part_id
          UNION
          SELECT  tc.objid                  call_trans_objid,
                  tc.CREATION_TIME          date_time,
                  'UPGRADE'                 action_text,
                  tc.x_min                  x_min,
                  spsp.X_SERVICE_PLAN_ID    Service_Plan_Id
          FROM    table_case                tc,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp
          WHERE   UPPER(tc.X_CASE_TYPE)    = 'PHONE UPGRADE'
          AND     tc.x_esn                 = ip_esn
          AND     tc.x_esn                 = tsp.x_service_id
          AND     tsp.part_status          = 'Active'
          AND     tsp.objid                = spsp.table_site_part_id
          UNION
          SELECT  pt.objid                        call_trans_objid,
                  pt.x_trans_date                 date_time,
                  'ENROLL IN AUTO REFILL'         action_text,
                  tsp.x_min                       x_min, -- pp.x_prog_class, enr.x_enrollment_status,
                  spsp.X_SERVICE_PLAN_ID          Service_Plan_Id
          FROM   x_program_enrolled         enr,
                 x_program_trans            pt,
                 x_program_parameters       pp,
                 table_site_part            tsp,
                 x_service_plan_site_part   spsp
          WHERE  enr.x_esn                     = ip_esn
          AND    pt.PGM_TRAN2PGM_ENTROLLED     = enr.objid
          AND    pt.pgm_trans2site_part        = tsp.objid
          AND    pt.x_Action_type              = 'ENROLLMENT'
          AND    enr.pgm_enroll2pgm_parameter  = pp.objid
          AND    enr.x_enrollment_status       IN ('ENROLLED','ENROLLMENTPENDING')
          AND    enr.x_next_charge_date        > SYSDATE
          AND    tsp.part_status               = 'Active'
          AND    tsp.objid                     = spsp.table_site_part_id
          UNION
          SELECT pt.objid                          call_trans_objid,
                 pt.x_trans_date                   date_time,
                 'ENROLL IN EASY EXCHANGE'         action_text,
                 tsp.x_min                         x_min, --pp.x_prog_class, enr.x_enrollment_status,
                 spsp.X_SERVICE_PLAN_ID            Service_Plan_Id
          FROM   x_program_enrolled         enr,
                 x_program_parameters       pp,
                 x_program_trans            pt,
                 table_site_part            tsp,
                 x_service_plan_site_part   spsp
          WHERE  enr.x_esn                     = ip_esn
          AND    enr.x_enrollment_status       = 'ENROLLED_NO_ACCOUNT'
          AND    pt.PGM_TRAN2PGM_ENTROLLED     = enr.objid
          AND    pt.pgm_trans2site_part        = tsp.objid
          AND    enr.x_next_charge_date        > SYSDATE
          AND    enr.pgm_enroll2pgm_parameter  = pp.objid
          AND    pp.x_prog_class               = 'WARRANTY'
          AND    tsp.part_status               = 'Active'
          AND    tsp.objid                     = spsp.table_site_part_id
          ) x
          ORDER BY x.date_time;
    --
    v_location := 'Getting the count for Transaction History';
    IF out_transaction_hist_tab.count = 0  THEN
      p_err_num          := 11900;
      p_err_string       := 'Transaction history could not be found';
      dbms_output.put_line('Transaction history could not be found');
      RETURN;
    END IF;
    -- Populate Service_Plan_Description1 - 4 fields
    FOR i IN 1 ..out_transaction_hist_tab.count
    LOOP
      -- Initialize v_service_plan_id to NULL for every iteration of hte loop.
      v_service_plan_id := NULL;
      --
      OPEN service_plan_cur(out_transaction_hist_tab(i).call_trans_objid);
      FETCH service_plan_cur INTO v_service_plan_id;
      CLOSE service_plan_cur;
      --
      IF v_service_plan_id IS NULL AND out_transaction_hist_tab(i).Service_Plan_Id <> 0
      THEN
        v_service_plan_id :=  out_transaction_hist_tab(i).Service_Plan_Id;
      END IF;
      --
      IF v_service_plan_id IS NULL --AND out_transaction_hist_tab(i).action_text <> 'ACTIVATION'
      THEN
        v_service_plan_id := ADFCRM_TRANSACTION_SUMMARY.get_service_plan_added (ip_esn, out_transaction_hist_tab(i).call_trans_objid, null);
      END IF;
      --
      IF v_service_plan_id IS NOT NULL
      THEN
        out_transaction_hist_tab(i).service_plan_id           := v_service_plan_id;
        out_transaction_hist_tab(i).service_plan_description1 := sa.queue_card_pkg.fn_get_script_text_by_sp_desc(v_service_plan_id,'MOBILE_DESCRIPTION1', ip_brand );
        out_transaction_hist_tab(i).service_plan_description2 := sa.queue_card_pkg.fn_get_script_text_by_sp_desc(v_service_plan_id,'MOBILE_DESCRIPTION2', ip_brand );
        out_transaction_hist_tab(i).service_plan_description3 := sa.queue_card_pkg.fn_get_script_text_by_sp_desc(v_service_plan_id,'MOBILE_DESCRIPTION3', ip_brand );
        out_transaction_hist_tab(i).service_plan_description4 := sa.queue_card_pkg.fn_get_script_text_by_sp_desc(v_service_plan_id,'MOBILE_DESCRIPTION4', ip_brand );
        --CR47564 WFM Changes start
        out_transaction_hist_tab(i).service_plan_short_description := sa.queue_card_pkg.fn_get_script_text_by_sp_desc(v_service_plan_id,'SHORT_SCRIPT', ip_brand );
        --CR47564 WFM Changes end
      ELSE
        dbms_output.put_line('Service Plan ID is not found for the ESN: '|| ip_esn || ' and Call Transaction Objid: '||out_transaction_hist_tab(i).call_trans_objid);
      END IF;
    END LOOP;
  ELSE   -- CR44680

  --48604 Start
  IF l_not_active_esn = 'N'
  THEN --{
    SELECT sa.transaction_hist_rec(call_trans_objid,
                                   part_number,
                                   date_time,
                                   action_text,
                                   x_min,
                                   l_device_name,
                                   Service_Plan_Id,
                                   service_plan_description1,
                                   service_plan_description2,
                                   NULL,
                                   NULL,
                                   l_group_id,
                                   l_group_name,
                                   NULL --CR47564 WFM Changes
                                   )
           BULK COLLECT
    INTO   out_transaction_hist_tab
    FROM (
          SELECT  hist.call_trans_objid    call_trans_objid,
                  pn.part_number           part_number,
                  hist.date_time           date_time,
                  hist.action_text         Action_Text,
                  hist.x_min               x_min,
                  SERVICE_PLAN_ID          Service_Plan_Id,
                  NULL                     service_plan_description1,
                  NULL                     service_plan_description2
          FROM   table_x_act_deact_hist   hist,
                 table_part_num    pn,
                 table_mod_level   ml,
                 table_x_red_card  rc
          WHERE  hist.x_service_id       = ip_esn
          AND    hist.action_text        IN ('ACTIVATION','REACTIVATION','DEACTIVATION','REDEMPTION')
          AND    hist.CALL_TRANS_OBJID    = rc.RED_CARD2CALL_TRANS(+)
          AND    rc.X_RED_CARD2PART_MOD   = ml.objid (+)
          AND    ml.PART_INFO2PART_NUM    = pn.objid (+)
          UNION
          SELECT  pdt.objid               call_trans_objid,
                  ''                      part_number,
                  pd.X_RQST_DATE          date_time,
                  'PURCHASE'              action_text,
                  tsp.x_min               x_min,
                  spsp.X_SERVICE_PLAN_ID  Service_Plan_Id,
                  pp.X_PRG_SCRIPT_ID      service_plan_description1,
                  pp.X_PRG_DESC_SCRIPT_ID service_plan_description2
          FROM    x_program_purch_hdr       pd,
                  x_program_purch_dtl       pdt,
                  x_program_enrolled        pe,
                  x_program_parameters      pp,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp
          WHERE   nvl(pd.X_ICS_RCODE,'0') IN ('1', '100')                 --Successful payments
          AND     pd.X_MERCHANT_ID        IS NOT NULL                     --Exclude BML
          AND     pd.X_PAYMENT_TYPE       NOT IN ('REFUND', 'OTAPURCH')   --Exclude Refunds and mobile billing
          AND     pd.X_AMOUNT             >= 20                           --Exclude HPP (as of now identifying HPP based on dollar amount)
          AND     pd.X_MERCHANT_ID        NOT LIKE '%wusa%'
          AND     pd.objid                = pdt.pgm_purch_dtl2prog_hdr
          AND     pdt.x_esn               = ip_esn
          AND     pdt.PGM_PURCH_DTL2PGM_ENROLLED  =  pe.objid
          AND     pe.PGM_ENROLL2PGM_PARAMETER   =  pp.objid
          AND     pdt.x_esn               = tsp.x_service_id
          AND     tsp.part_status         = 'Active'
          AND     tsp.objid               = spsp.table_site_part_id
          UNION
          SELECT  phdr.objid               call_trans_objid,
                  pn.part_number           part_number,
                  X_TRANSACT_DATE          date_time,
                  'PURCHASE'               action_text,
                  tsp.x_min                x_min,
                  spsp.X_SERVICE_PLAN_ID   Service_Plan_Id,
                  NULL                     service_plan_description1,
                  NULL                     service_plan_description2
          FROM    table_x_red_card   rc,
                  table_x_purch_dtl  pdtl,
                  table_x_purch_hdr  phdr,
                  table_x_call_trans ct,
                  table_mod_level    ml,
                  table_part_num     pn,
                  table_site_part    tsp,
                  x_service_plan_site_part  spsp
          WHERE  phdr.x_esn             = ip_esn
          AND    rc.RED_CARD2CALL_TRANS = ct.objid
          AND    pdtl.x_red_card_number = rc.x_red_code
          AND    pdtl.x_smp             = rc.x_smp
          AND    rc.X_RED_CARD2PART_MOD = ml.objid
          AND    ml.PART_INFO2PART_NUM  = pn.objid
          AND    phdr.objid             = pdtl.x_purch_dtl2x_purch_hdr
          AND    phdr.x_esn             = ct.x_service_id
          AND    phdr.x_ics_rcode       in ('1','100')
          AND    phdr.x_ics_rflag       in ('SOK', 'ACCEPT')
          AND    ct.x_service_id        =  tsp.x_service_id
          AND    tsp.part_status        = 'Active'
          AND    tsp.objid              =  spsp.table_site_part_id
          UNION
          SELECT  rf.objid                  call_trans_objid,
                  (SELECT pn.part_number
                   FROM   table_part_num            pn,
                          table_mod_level           ml
                   WHERE  rc.X_RED_CARD2PART_MOD   = ml.objid
                   AND    ml.PART_INFO2PART_NUM    = pn.objid
                   AND    rownum < 2)       part_number,
                  rf.X_RQST_DATE            date_time,
                  'REFUND'                  action_text,
                  tsp.x_min                 x_min,
                  spsp.X_SERVICE_PLAN_ID    Service_Plan_Id,
                  NULL                      service_plan_description1,
                  NULL                      service_plan_description2
          FROM    x_program_purch_hdr       rf,
                  x_program_purch_hdr       sl,
                  x_program_purch_dtl       pdt,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp,
                  table_x_call_trans        ct,
                  table_x_red_card          rc
          WHERE   rf.X_PAYMENT_TYPE       =  'REFUND'
          AND     nvl(rf.X_ICS_RCODE,'0') IN ('1', '100')
          AND     rf.purch_hdr2cr_purch   = sl.objid
          AND     sl.objid                = pdt.pgm_purch_dtl2prog_hdr
          AND     pdt.x_esn               = ip_esn
          AND     pdt.x_esn               = tsp.x_service_id
          AND     tsp.part_status         = 'Active'
          AND     tsp.objid               = spsp.table_site_part_id
          AND     tsp.objid               = ct.CALL_TRANS2SITE_PART
          AND     ct.objid                = rc.RED_CARD2CALL_TRANS
          UNION
          SELECT  ct.objid                call_trans_objid,
                  (SELECT pn.part_number
                   FROM   table_part_num            pn,
                          table_mod_level           ml
                   WHERE  rc.X_RED_CARD2PART_MOD   = ml.objid
                   AND    ml.PART_INFO2PART_NUM    = pn.objid
                   AND    rownum < 2)     part_number,
                  ct.X_TRANSACT_DATE      date_time,
                  'PORT IN'               action_text,
                  ct.x_min                x_min,
                  spsp.X_SERVICE_PLAN_ID  Service_Plan_Id,
                  NULL                    service_plan_description1,
                  NULL                    service_plan_description2
          FROM    TABLE_TASK                T,
                  TABLE_X_ORDER_TYPE        OT,
                  TABLE_X_CALL_TRANS        ct,
                  table_case                tc,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp,
                  table_x_red_card          rc
          WHERE   ot.x_order_type     like '%Port%'
          AND     OT.OBJID              = T.X_TASK2X_ORDER_TYPE
          AND     ct.x_service_id       = ip_esn
          AND     ct.x_result           = 'Completed'
          AND     t.X_TASK2X_CALL_TRANS = ct.objid
          AND     t.objid               = tc.x_case2task
          AND     tc.x_case_type        ='Port In'
          AND     ct.x_service_id       = tsp.x_service_id
          AND     tsp.part_status       = 'Active'
          AND     tsp.objid             = spsp.table_site_part_id
          AND     tsp.objid             = ct.CALL_TRANS2SITE_PART
          AND     ct.objid              = rc.RED_CARD2CALL_TRANS (+)
          UNION
          SELECT  tc.objid                  call_trans_objid,
                  (SELECT pn.part_number
                   FROM   table_part_num            pn,
                          table_mod_level           ml
                   WHERE  rc.X_RED_CARD2PART_MOD   = ml.objid
                   AND    ml.PART_INFO2PART_NUM    = pn.objid
                   AND    rownum < 2)       part_number,
                  tc.CREATION_TIME          date_time,
                  'UPGRADE'                 action_text,
                  tc.x_min                  x_min,
                  spsp.X_SERVICE_PLAN_ID    Service_Plan_Id,
                  NULL                      service_plan_description1,
                  NULL                      service_plan_description2
          FROM    table_case                tc,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp,
                  table_x_call_trans        ct,
                  table_x_red_card          rc
          WHERE   UPPER(tc.X_CASE_TYPE)    = 'PHONE UPGRADE'
          AND     tc.x_esn                 = ip_esn
          AND     tc.x_esn                 = tsp.x_service_id
          AND     tsp.part_status          = 'Active'
          AND     tsp.objid                = spsp.table_site_part_id
          AND     tsp.objid               = ct.CALL_TRANS2SITE_PART
          AND     ct.objid                = rc.RED_CARD2CALL_TRANS (+)
          UNION
          SELECT pt.objid                        call_trans_objid,
                 pn.part_number                  part_number,
                 pt.x_trans_date                 date_time,
                 'ENROLL IN AUTO REFILL'         action_text,
                 tsp.x_min                       x_min,
                 spsp.X_SERVICE_PLAN_ID          Service_Plan_Id,
                 NULL                            service_plan_description1,
                 NULL                            service_plan_description2
          FROM   x_program_enrolled         enr,
                 x_program_trans            pt,
                 x_program_parameters       pp,
                 table_site_part            tsp,
                 x_service_plan_site_part   spsp,
                 TABLE_PART_NUM             PN,
                 table_part_num             pn2,
                 table_part_num             pn3,
                 X_MTM_PART_NUM2PROG_PARAMETERS mpp
          WHERE  enr.x_esn                     = ip_esn
          AND    pt.PGM_TRAN2PGM_ENTROLLED     = enr.objid
          AND    pt.pgm_trans2site_part        = tsp.objid
          AND    pt.x_Action_type              = 'ENROLLMENT'
          AND    enr.pgm_enroll2pgm_parameter  = pp.objid
          AND    enr.x_enrollment_status       IN ('ENROLLED','ENROLLMENTPENDING')
          AND    enr.x_next_charge_date        > SYSDATE
          AND    tsp.part_status               = 'Active'
          AND    tsp.objid                     = spsp.table_site_part_id
          and    mpp.PART_NUMBER_OBJID         = pn.OBJID
          and    mpp.PROGRAM_PARAM_OBJID        = pp.objid
          and    pp.PROG_PARAM2PRTNUM_ENRLFEE   = pn2.objid
          and    pp.PROG_PARAM2PRTNUM_MONFEE    = pn3.objid
          UNION
          SELECT pt.objid                          call_trans_objid,
                 pn.part_number                    part_number,
                 pt.x_trans_date                   date_time,
                 'ENROLL IN EASY EXCHANGE'         action_text,
                 tsp.x_min                         x_min,
                 spsp.X_SERVICE_PLAN_ID            Service_Plan_Id,
                 NULL                              service_plan_description1,
                 NULL                              service_plan_description2
          FROM   x_program_enrolled         enr,
                 x_program_parameters       pp,
                 x_program_trans            pt,
                 table_site_part            tsp,
                 x_service_plan_site_part   spsp,
                 TABLE_PART_NUM             PN
          WHERE  enr.x_esn                     = ip_esn
          AND    enr.x_enrollment_status       = 'ENROLLED_NO_ACCOUNT'
          AND    pt.PGM_TRAN2PGM_ENTROLLED     = enr.objid
          AND    pt.pgm_trans2site_part        = tsp.objid
          AND    enr.x_next_charge_date        > SYSDATE
          AND    enr.pgm_enroll2pgm_parameter  = pp.objid
          AND    pp.x_prog_class               = 'WARRANTY'
          AND    tsp.part_status               = 'Active'
          AND    tsp.objid                     = spsp.table_site_part_id
          and    pp.PROG_PARAM2PRTNUM_ENRLFEE  = pn.OBJID
          ) x
          ORDER BY x.date_time;

    ELSE -- }{ l_not_active_esn = 'Y'
    SELECT sa.transaction_hist_rec(call_trans_objid,
                                   part_number,
                                   date_time,
                                   action_text,
                                   x_min,
                                   l_device_name,
                                   Service_Plan_Id,
                                   service_plan_description1,
                                   service_plan_description2,
                                   NULL,
                                   NULL,
                                   l_group_id,
                                   l_group_name,
                                   NULL --CR47564 WFM Changes
                                   )
           BULK COLLECT
    INTO   out_transaction_hist_tab
    FROM (
          --Query1
          SELECT  hist.call_trans_objid    call_trans_objid,
                  pn.part_number           part_number,
                  hist.date_time           date_time,
                  hist.action_text         Action_Text,
                  hist.x_min               x_min,
                  SERVICE_PLAN_ID          Service_Plan_Id,
                  NULL                     service_plan_description1,
                  NULL                     service_plan_description2
          FROM   table_x_act_deact_hist   hist,
                 table_part_num    pn,
                 table_mod_level   ml,
                 table_x_red_card  rc
          WHERE  hist.x_service_id       = ip_esn
          AND    hist.action_text        IN ('ACTIVATION','REACTIVATION','DEACTIVATION','REDEMPTION')
          AND    hist.CALL_TRANS_OBJID    = rc.RED_CARD2CALL_TRANS(+)
          AND    rc.X_RED_CARD2PART_MOD   = ml.objid (+)
          AND    ml.PART_INFO2PART_NUM    = pn.objid (+)
          UNION
          --Query2
          SELECT  pdt.objid               call_trans_objid,
                  ''                      part_number,
                  pd.X_RQST_DATE          date_time,
                  'PURCHASE'              action_text,
                  tsp.x_min               x_min,
                  spsp.X_SERVICE_PLAN_ID  Service_Plan_Id,
                  pp.X_PRG_SCRIPT_ID      service_plan_description1,
                  pp.X_PRG_DESC_SCRIPT_ID service_plan_description2
          FROM    x_program_purch_hdr       pd,
                  x_program_purch_dtl       pdt,
                  x_program_enrolled        pe,
                  x_program_parameters      pp,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp
          WHERE   nvl(pd.X_ICS_RCODE,'0') IN ('1', '100')                 --Successful payments
          AND     pd.X_MERCHANT_ID        IS NOT NULL                     --Exclude BML
          AND     pd.X_PAYMENT_TYPE       NOT IN ('REFUND', 'OTAPURCH')   --Exclude Refunds and mobile billing
          AND     pd.X_AMOUNT             >= 20                           --Exclude HPP (as of now identifying HPP based on dollar amount)
          AND     pd.X_MERCHANT_ID        NOT LIKE '%wusa%'
          AND     pd.objid                = pdt.pgm_purch_dtl2prog_hdr
          AND     pdt.x_esn               = ip_esn
          AND     pdt.PGM_PURCH_DTL2PGM_ENROLLED  =  pe.objid
          AND     pe.PGM_ENROLL2PGM_PARAMETER   =  pp.objid
          AND     pdt.x_esn               = tsp.x_service_id
          --AND     tsp.part_status         = 'Active'
          AND     tsp.objid               = (SELECT MAX(a.objid)
                                             FROM   table_site_part a
                                             WHERE  a.x_service_id = tsp.x_service_id)
          AND     tsp.objid               = spsp.table_site_part_id
          UNION
          --Query3
          SELECT  phdr.objid               call_trans_objid,
                  pn.part_number           part_number,
                  X_TRANSACT_DATE          date_time,
                  'PURCHASE'               action_text,
                  tsp.x_min                x_min,
                  spsp.X_SERVICE_PLAN_ID   Service_Plan_Id,
                  NULL                     service_plan_description1,
                  NULL                     service_plan_description2
          FROM    table_x_red_card   rc,
                  table_x_purch_dtl  pdtl,
                  table_x_purch_hdr  phdr,
                  table_x_call_trans ct,
                  table_mod_level    ml,
                  table_part_num     pn,
                  table_site_part    tsp,
                  x_service_plan_site_part  spsp
          WHERE  phdr.x_esn             = ip_esn
          AND    rc.RED_CARD2CALL_TRANS = ct.objid
          AND    pdtl.x_red_card_number = rc.x_red_code
          AND    pdtl.x_smp             = rc.x_smp
          AND    rc.X_RED_CARD2PART_MOD = ml.objid
          AND    ml.PART_INFO2PART_NUM  = pn.objid
          AND    phdr.objid             = pdtl.x_purch_dtl2x_purch_hdr
          AND    phdr.x_esn             = ct.x_service_id
          AND    phdr.x_ics_rcode       in ('1','100')
          AND    phdr.x_ics_rflag       in ('SOK', 'ACCEPT')
          AND    ct.x_service_id        =  tsp.x_service_id
          --AND    tsp.part_status        = 'Active'
          AND     tsp.objid               = (SELECT MAX(a.objid)
                                             FROM   table_site_part a
                                             WHERE  a.x_service_id = tsp.x_service_id)
          AND    tsp.objid              =  spsp.table_site_part_id
          UNION
          --Query4
          SELECT  rf.objid                  call_trans_objid,
                  /*(SELECT pn.part_number
                   FROM   table_part_num            pn,
                          table_mod_level           ml
                   WHERE  rc.X_RED_CARD2PART_MOD   = ml.objid
                   AND    ml.PART_INFO2PART_NUM    = pn.objid
                   AND    rownum < 2)*/
                  NULL                      part_number,
                  rf.X_RQST_DATE            date_time,
                  'REFUND'                  action_text,
                  tsp.x_min                 x_min,
                  spsp.X_SERVICE_PLAN_ID    Service_Plan_Id,
                  NULL                      service_plan_description1,
                  NULL                      service_plan_description2
          FROM    x_program_purch_hdr       rf,
                  x_program_purch_hdr       sl,
                  x_program_purch_dtl       pdt,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp
                  --table_x_call_trans        ct,
                  --table_x_red_card          rc
          WHERE   rf.X_PAYMENT_TYPE       =  'REFUND'
          AND     nvl(rf.X_ICS_RCODE,'0') IN ('1', '100')
          AND     rf.purch_hdr2cr_purch   = sl.objid
          AND     sl.objid                = pdt.pgm_purch_dtl2prog_hdr
          AND     pdt.x_esn               = ip_esn
          AND     pdt.x_esn               = tsp.x_service_id
         -- AND     tsp.part_status         = 'Active'
          AND     tsp.objid               = (SELECT MAX(a.objid)
                                             FROM   table_site_part a
                                             WHERE  a.x_service_id = tsp.x_service_id)
          AND     tsp.objid               = spsp.table_site_part_id
          --AND     tsp.objid               = ct.CALL_TRANS2SITE_PART
          --AND     ct.objid                = rc.RED_CARD2CALL_TRANS
          UNION
          --Query5
          SELECT  ct.objid                call_trans_objid,
                  (SELECT pn.part_number
                   FROM   table_part_num            pn,
                          table_mod_level           ml
                   WHERE  rc.X_RED_CARD2PART_MOD   = ml.objid
                   AND    ml.PART_INFO2PART_NUM    = pn.objid
                   AND    rownum < 2)     part_number,
                  ct.X_TRANSACT_DATE      date_time,
                  'PORT IN'               action_text,
                  ct.x_min                x_min,
                  spsp.X_SERVICE_PLAN_ID  Service_Plan_Id,
                  NULL                    service_plan_description1,
                  NULL                    service_plan_description2
          FROM    TABLE_TASK                T,
                  TABLE_X_ORDER_TYPE        OT,
                  TABLE_X_CALL_TRANS        ct,
                  table_case                tc,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp,
                  table_x_red_card          rc
          WHERE   ot.x_order_type     like '%Port%'
          AND     OT.OBJID              = T.X_TASK2X_ORDER_TYPE
          AND     ct.x_service_id       = ip_esn
          AND     ct.x_result           = 'Completed'
          AND     t.X_TASK2X_CALL_TRANS = ct.objid
          AND     t.objid               = tc.x_case2task
          AND     tc.x_case_type        ='Port In'
          AND     ct.x_service_id       = tsp.x_service_id
          --AND     tsp.part_status       = 'Active'
          AND     tsp.objid             = spsp.table_site_part_id
          AND     tsp.objid             = ct.CALL_TRANS2SITE_PART
          AND     ct.objid              = rc.RED_CARD2CALL_TRANS (+)
          UNION
          --Query6
          SELECT distinct tc.objid                  call_trans_objid,  --CR51344
                  (SELECT pn.part_number
                   FROM   table_part_num            pn,
                          table_mod_level           ml
                   WHERE  rc.X_RED_CARD2PART_MOD   = ml.objid
                   AND    ml.PART_INFO2PART_NUM    = pn.objid
                   AND    rownum < 2)       part_number,
                  tc.CREATION_TIME          date_time,
                  'UPGRADE'                 action_text,
                  tc.x_min                  x_min,
                  spsp.X_SERVICE_PLAN_ID    Service_Plan_Id,
                  NULL                      service_plan_description1,
                  NULL                      service_plan_description2
          FROM    table_case                tc,
                  table_site_part           tsp,
                  x_service_plan_site_part  spsp,
                  table_x_call_trans        ct,
                  table_x_red_card          rc
          WHERE   UPPER(tc.X_CASE_TYPE)    = 'PHONE UPGRADE'
          AND     tc.x_esn                 = ip_esn
          AND     tc.x_esn                 = tsp.x_service_id
          --AND     tsp.part_status          = 'Active'
          AND     tsp.objid                = spsp.table_site_part_id
          AND     tsp.objid               = ct.CALL_TRANS2SITE_PART
          AND     ct.objid                = rc.RED_CARD2CALL_TRANS     --CR51344
          UNION
          --Query7
          SELECT pt.objid                        call_trans_objid,
                 pn.part_number                  part_number,
                 pt.x_trans_date                 date_time,
                 'ENROLL IN AUTO REFILL'         action_text,
                 tsp.x_min                       x_min,
                 spsp.X_SERVICE_PLAN_ID          Service_Plan_Id,
                 NULL                            service_plan_description1,
                 NULL                            service_plan_description2
          FROM   x_program_enrolled         enr,
                 x_program_trans            pt,
                 x_program_parameters       pp,
                 table_site_part            tsp,
                 x_service_plan_site_part   spsp,
                 TABLE_PART_NUM             PN,
                 table_part_num             pn2,
                 table_part_num             pn3,
                 X_MTM_PART_NUM2PROG_PARAMETERS mpp
          WHERE  enr.x_esn                      = ip_esn
          AND    pt.PGM_TRAN2PGM_ENTROLLED      = enr.objid
          AND    pt.pgm_trans2site_part         = tsp.objid
          AND    pt.x_Action_type               = 'ENROLLMENT'
          AND    enr.pgm_enroll2pgm_parameter   = pp.objid
          AND    enr.x_enrollment_status       IN ('ENROLLED','ENROLLMENTPENDING','DEENROLLED','READYTOREENROLL')
          --AND    enr.x_next_charge_date        > SYSDATE
          --AND    tsp.part_status               = 'Active'
          /*AND     tsp.objid                      = (SELECT MAX(a.objid)
                                                    FROM   table_site_part a
                                                    WHERE  a.x_service_id = tsp.x_service_id)*/
          AND    tsp.objid                      = spsp.table_site_part_id
          and    mpp.PART_NUMBER_OBJID          = pn.OBJID
          and    mpp.PROGRAM_PARAM_OBJID        = pp.objid
          and    pp.PROG_PARAM2PRTNUM_ENRLFEE   = pn2.objid
          and    pp.PROG_PARAM2PRTNUM_MONFEE    = pn3.objid
          UNION
          --Query8
          SELECT pt.objid                          call_trans_objid,
                 pn.part_number                    part_number,
                 pt.x_trans_date                   date_time,
                 'ENROLL IN EASY EXCHANGE'         action_text,
                 tsp.x_min                         x_min,
                 spsp.X_SERVICE_PLAN_ID            Service_Plan_Id,
                 NULL                              service_plan_description1,
                 NULL                              service_plan_description2
          FROM   x_program_enrolled         enr,
                 x_program_parameters       pp,
                 x_program_trans            pt,
                 table_site_part            tsp,
                 x_service_plan_site_part   spsp,
                 TABLE_PART_NUM             PN
          WHERE  enr.x_esn                     = ip_esn
          AND    enr.x_enrollment_status       = 'ENROLLED_NO_ACCOUNT'
          AND    pt.PGM_TRAN2PGM_ENTROLLED     = enr.objid
          AND    pt.pgm_trans2site_part        = tsp.objid
          --AND    enr.x_next_charge_date        > SYSDATE
          AND    enr.pgm_enroll2pgm_parameter  = pp.objid
          AND    pp.x_prog_class               = 'WARRANTY'
          --AND    tsp.part_status               = 'Active'
          AND    tsp.objid                     = spsp.table_site_part_id
          and    pp.PROG_PARAM2PRTNUM_ENRLFEE  = pn.OBJID
          ) x
          ORDER BY x.date_time;
    END IF; -- }
    --48604 End
    v_location := 'Getting the count for Transaction History';
    IF out_transaction_hist_tab.count = 0  THEN
      p_err_num          := 11900;
      p_err_string       := 'Transaction history could not be found';
      dbms_output.put_line('Transaction history could not be found');
      RETURN;
    END IF;
    -- Populate Service_Plan_Description1 - 4 fields
    FOR i IN 1 ..out_transaction_hist_tab.count
    LOOP
      --  Intialize variables
      l_script_id1  :=  NULL;
      l_script_id2  :=  NULL;
      --
      IF  NVL(out_transaction_hist_tab(i).Service_Plan_Id, 0) = 0
      THEN
        out_transaction_hist_tab(i).Service_Plan_Id := ADFCRM_TRANSACTION_SUMMARY.get_service_plan_added (ip_esn, out_transaction_hist_tab(i).call_trans_objid, null);
      END IF;
      --
      IF out_transaction_hist_tab(i).service_plan_description1 IS NULL AND
         out_transaction_hist_tab(i).Part_number IS NOT NULL
      THEN
        get_script_id (ip_part_number =>  out_transaction_hist_tab(i).Part_number,
                       p_script_id1   =>  l_script_id1,
                       p_script_id2   =>  l_script_id2);
      ELSIF out_transaction_hist_tab(i).service_plan_description1 IS NOT NULL AND
            out_transaction_hist_tab(i).Part_number IS NULL
      THEN
        l_script_id1    :=  out_transaction_hist_tab(i).service_plan_description1;
        l_script_id2    :=  out_transaction_hist_tab(i).service_plan_description2;
      ELSE
        l_script_id1    :=  NULL;
        l_script_id2    :=  NULL;
      END IF;
      --
      IF out_transaction_hist_tab(i).service_plan_description1 IS NULL
      THEN
        l_source_system :=  'APP';
      ELSE
        l_source_system :=  'ALL';
      END IF;
      --
      IF l_script_id1 IS NOT NULL
      THEN
       out_transaction_hist_tab(i).service_plan_description1 := fn_get_script_text_by_scriptid(ip_sourcesystem  => l_source_system,
                                                                                               ip_brand_name    => ip_brand,
                                                                                               ip_language      => 'ENGLISH', -- CR48846
                                                                                               ip_script_id     => l_script_id1);
      END IF;
      --
      IF l_script_id2 IS NOT NULL
      THEN
       out_transaction_hist_tab(i).service_plan_description2 := fn_get_script_text_by_scriptid(ip_sourcesystem  => l_source_system,
                                                                                               ip_brand_name    => ip_brand,
                                                                                               ip_language      => 'ENGLISH', -- CR48846
                                                                                               ip_script_id     => l_script_id2);
      END IF;
      --
    END LOOP;
  END IF;  -- CR44680
  -- Move the Data from the Object to the Cursor
  OPEN out_transaction_hist_cur
  FOR
  SELECT call_trans_objid,
         part_number,                 -- CR44680
         date_time,
         action_text,
         x_min,
         x_esn_nick_name,
         service_plan_id,
         service_plan_description1,
         service_plan_description2,
         service_plan_description3,
         service_plan_description4,
         group_id,                    -- CR43248 added
         group_name,                   -- CR43248 added
         service_plan_short_description --CR47564
  FROM TABLE (CAST(out_transaction_hist_tab AS sa.transaction_hist_tab )) ;
  --
  p_err_num    := 0;
  p_err_string := 'SUCCESS';
  --
EXCEPTION
WHEN OTHERS THEN
  p_err_num    := sqlcode;
  p_err_string := sqlerrm;
  ota_util_pkg.err_log(p_action => v_location, p_error_date => SYSDATE, p_key => substr(ip_esn||';'||ip_brand, 1, 50), p_program_name => 'TRANSACTION_HISTORY_PKG.get_transaction_history', p_error_text => p_err_string);
END get_transaction_history;
--

--CR48846 Mobile channel activation
PROCEDURE get_last_cc_transaction(
    i_esn                    IN  VARCHAR2,
    i_paymnt_src_id          IN  NUMBER,
    o_transaction_id         OUT VARCHAR2,
    o_transaction_date       OUT DATE,
    o_total_amount           OUT NUMBER,
    o_tax_amount             OUT NUMBER,
    o_err_num                OUT NUMBER,
    o_err_msg                OUT VARCHAR2  )

IS

BEGIN

  IF i_esn IS NULL THEN
    o_err_num := 1;
    o_err_msg := 'ESN NOT PASSED';
    RETURN;
  END IF;

  IF i_paymnt_src_id IS NULL THEN
    o_err_num := 2;
    o_err_msg := 'PAYMENT SOURCE NOT PASSED';
    RETURN;
  END IF;

  BEGIN
    SELECT x_rqst_date
          ,x_merchant_ref_number
          ,x_auth_amount
          ,x_tax_amount
    INTO   o_transaction_date
          ,o_transaction_id
          ,o_total_amount
          ,o_tax_amount
    FROM   (SELECT   x_rqst_date
                    ,phdr.x_merchant_ref_number
                    ,phdr.x_auth_amount
                    ,phdr.x_tax_amount
            FROM     x_program_purch_hdr phdr, x_program_purch_dtl pdtl
            WHERE    pdtl.pgm_purch_dtl2prog_hdr = phdr.objid
            AND      phdr.x_rqst_type = 'CREDITCARD_PURCH'
            AND      pdtl.x_esn = i_esn
            AND      phdr.prog_hdr2x_pymt_src = i_paymnt_src_id
            AND      NVL(phdr.x_auth_amount,0) <> 0 -- DEFECT 27775 Added this condition as SOA orchestration is wrong for purchase with enrollement cases and creates a $0 entry in enrolled table as well as actual amount entry in table_X_purch_hdr
            UNION ALL
            SELECT   hdr.x_rqst_date
                    ,hdr.x_merchant_ref_number
                    ,hdr.x_auth_amount
                    ,   NVL(hdr.x_tax_amount, 0)
                      + NVL(hdr.x_e911_amount, 0)
                      + NVL(hdr.x_usf_taxamount, 0)
                      + NVL(hdr.x_rcrf_tax_amount, 0) x_tax_amount
            FROM     table_x_purch_hdr hdr, x_payment_source ps
            WHERE    ps.pymt_src2x_credit_card = hdr.x_purch_hdr2creditcard
            AND      hdr.x_esn = i_esn
            AND      hdr.x_rqst_type = 'cc_purch'
            AND      ps.objid = i_paymnt_src_id
            ORDER BY 1 DESC)
    WHERE  ROWNUM = 1;
    o_err_num := 0;
    o_err_msg := 'SUCCESS';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_num := 3;
      o_err_msg := 'NO PURCHASE HISTORY FOUND';
    WHEN OTHERS THEN
      o_err_num := 4;
      o_err_msg := 'ERROR GETTING PURCHASE HISTORY '||SQLERRM;
  END;
EXCEPTION
  WHEN OTHERS THEN
    o_err_num := 5;
    o_err_msg := 'UNEXPECTED ERROR '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
END get_last_cc_transaction;

END transaction_history_pkg;
/