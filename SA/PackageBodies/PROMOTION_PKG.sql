CREATE OR REPLACE PACKAGE BODY sa."PROMOTION_PKG" AS
  /********************************************************************************************************/
  /* Name : CheckEsnTech */
  /* Type : Function    */
  /* Purpose : To return the technology of the ESN. Returns ANALOG if the ESN technology is ANALOG,*/
  /* DIGITAL if Digital, ERROR if not successful */
  /* Parameters : Input - ip_esn (ESN #) */
  /* Author : Vanisri Adapa */
  /* Date : 02/18/2002 */
  /* Revisions : Version Date Who Purpose */
  /* ------- -------- ------- ----------------------------------------------- */
  /* 1.0 02/18/2002 VAdapa Initial revision */
  /* 1.1 03/17/2003 SL Clarify Upgrade -- refurbished phones */
  /* Use x_refurb_flag in site part instead of 'R' */
  /* 1.2 04/10/2003 SL Clarify Upgrade -- sequence */
  /********************************************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: PROMOTION_PKG.sql,v $
  --$Revision: 1.50 $
  --$Author: jcheruvathoor $
  --$Date: 2018/06/04 20:06:53 $
  --$ $Log: PROMOTION_PKG.sql,v $
  --$ Revision 1.50  2018/06/04 20:06:53  jcheruvathoor
  --$ CR57150	TF Billing Summary Incorrect Amount Front End Charges
  --$
  --$ Revision 1.48  2018/01/10 20:00:55  smeganathan
  --$ changes to remove cf ancillary code and to fetch brm equivalent discount code from table_x_promotion
  --$
  --$ Revision 1.47  2017/11/08 15:55:53  jcheruvathoor
  --$ CR51519	OLTF Web Promo Code Issue Feature Phones
  --$
  --$ Revision 1.42  2017/06/27 16:17:17  smeganathan
  --$ Added close cusor in the exception of sf_promo_check
  --$
  --$ Revision 1.41  2017/06/20 18:02:06  smeganathan
  --$ merged with 6/20 production release
  --$
  --$ Revision 1.40  2017/06/01 21:15:36  smeganathan
  --$ Added logic to populate discount code in x_esn_promo_hist table
  --$
  --$ $Log: PROMOTION_PKG.sql,v $
  --$ Revision 1.50  2018/06/04 20:06:53  jcheruvathoor
  --$ CR57150	TF Billing Summary Incorrect Amount Front End Charges
  --$
  --$ Revision 1.48  2018/01/10 20:00:55  smeganathan
  --$ changes to remove cf ancillary code and to fetch brm equivalent discount code from table_x_promotion
  --$
  --$ Revision 1.47  2017/11/08 15:55:53  jcheruvathoor
  --$ CR51519	OLTF Web Promo Code Issue Feature Phones
  --$
  --$ Revision 1.42  2017/06/27 16:17:17  smeganathan
  --$ Added close cusor in the exception of sf_promo_check
  --$
  --$ Revision 1.41  2017/06/20 18:02:06  smeganathan
  --$ merged with 6/20 production release
  --$
  --$ Revision 1.39  2017/05/19 17:27:31  nkandagatla
  --$ CR49229 Promo Engine Enhancement to calculate discount amount based on promotion discount percentage
  --$
  --$ Revision 1.37  2017/05/19 14:52:13  tbaney
  --$ Modified logic to get ancillary_status_code from x_cf_ancillary_codes table.  CR48480
  --$
  --$ Revision 1.33  2017/05/15 16:51:28  tbaney
  --$ Modified logic for global temp table.
  --$
  --$ Revision 1.31  2017/05/04 18:08:15  tbaney
  --$ Added new procedure for CR48480 to get discount code.
  --$
  --$ Revision 1.30  2017/04/12 19:51:01  tbaney
  --$ Modified procedure to use global temp table.
  --$
  --$ Revision 1.29  2017/04/06 21:36:49  tbaney
  --$ Modified logic due to requirments changing.
  --$
  --$ Revision 1.25  2016/12/12 18:00:11  rpednekar
  --$ CR45740 - Success msg for data saver.
  --$
  --$ Revision 1.23  2016/12/08 15:07:12  rpednekar
  --$ CR46960 - Data promo calculation procedures added.
  --$
  --$ Revision 1.22  2016/12/06 17:08:54  mshah
  --$ 44459 - NT_Multi Plan Purchasing. Added Script ID
  --$
  --$ Revision 1.21  2016/12/02 19:39:00  mshah
  --$ 44459 - NT_Multi Plan Purchasing
  --$
  --$ Revision 1.20  2016/12/02 15:32:52  mshah
  --$ 44459 - NT_Multi Plan Purchasing
  --$
  --$ Revision 1.19  2016/10/12 14:02:23  tbaney
  --$ Added logic for CR45238 to skip site part check.
  --$
  --$ Revision 1.18  2016/09/29 18:40:54  mgovindarajan
  --$ CR45122 : Force Actication to be used as Reactivation for TF Smartphone.    Remove the Promo_batch_Prc procedure since it is not in Scope for this release.
  --$
  --$ Revision 1.17  2016/09/29 14:55:21  mgovindarajan
  --$ CR42361 : Commented the runtime_promo_objid to keep pakcage valid
  --$
  --$ Revision 1.16  2016/09/29 14:20:01  mgovindarajan
  --$ CR42361 : Allow Runtime promotion to be validated only for Tracfone
  --$
  --$ Revision 1.15  2016/09/27 18:51:33  mgovindarajan
  --$ CR42361 -- Dealer and Runtime Promtion included for TRacfone_smartphone
  --$
  --$ Revision 1.14  2016/09/21 14:24:31  mgovindarajan
  --$ CR42361 - Skip Redunits for Promotions having DATA or text for tracfone and smartphone
  --$
  --$ Revision 1.13  2016/09/16 21:02:36  mgovindarajan
  --$ CR42361 - added Validation for SMS and DATA
  --$
  --$ Revision 1.12  2016/09/13 22:19:22  mgovindarajan
  --$ CR42316 - SKIP purchase only for Tracfone and Smartphone
  --$
  --$ Revision 1.11  2016/09/13 14:01:48  mgovindarajan
  --$ CR42361 - Added RETURN to OTHERs exeption
  --$
  --$ Revision 1.10  2016/09/09 22:32:08  mgovindarajan
  --$ CR42361 - Exlcuded site part check and X_promo_hist population
  --$
  --$ Revision 1.9  2016/09/08 17:57:12  mgovindarajan
  --$ CR42361
  --$
  --$ Revision 1.8  2016/09/07 21:33:47  mgovindarajan
  --$ CR42316 new procedure added for Batch promotions
  --$
  --$ Revision 1.7  2016/09/02 20:07:11  mgovindarajan
  --$ CR42361 - Skip Site part validation for PURCHASE transaction
  --$
  --$ Revision 1.6  2016/08/25 15:53:43  vnainar
  --$ CR42361 new procedure added validate_prom_code_ext
  --$
  --$ Revision 1.5  2014/07/14 14:57:08  ahabeeb
  --$ changed the name of the new column in x_offer_info
  --$
  --$ Revision 1.4  2014/07/10 21:58:50  ahabeeb
  --$ change due to new column in x_offer_info
  --$
  --$ Revision 1.3  2012/04/16 13:12:50  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$ Revision 1.2  2012/04/03 14:41:40  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  --********************************************************************************
  --
  -- CR16379 Start KACOSTA 03/06/2012
  l_cv_package_name CONSTANT VARCHAR2(30) := 'sp_runtime_promo';
  -- CR16379 End KACOSTA 03/06/2012
  --
  FUNCTION checkesntech(ip_esn IN VARCHAR2) RETURN VARCHAR2 AS

    v_tech VARCHAR2(20);
  BEGIN

    SELECT pn.x_technology
      INTO v_tech
      FROM table_part_num  pn
          ,table_mod_level ml
          ,table_part_inst pi
     WHERE pi.n_part_inst2part_mod = ml.objid
       AND ml.part_info2part_num = pn.objid
       AND pi.part_serial_no = ip_esn;

    IF v_tech = 'ANALOG' THEN
      RETURN 'ANALOG';
    ELSE
      RETURN 'DIGITAL';
    END IF;

  EXCEPTION
    WHEN others THEN
      RETURN 'ERROR';
  END checkesntech;
  --

  /********************************************************************************************************/
  /* Name : GetObjid */
  /* Type : Function  */
  /* Purpose : To return the objid of an item (ESN / Part) if successful */
  /* Parameters : Input - ip_item_name (ESN # or Part #), ip_item_type ('E' for ESN or 'P' for Part)*/
  /* Output - op_item_objid (Objid of the item) */
  /* Author : Vanisri Adapa */
  /* Date : 12/18/2001 */
  /* Revisions : Version Date Who Purpose */
  /* ------- -------- ------- ----------------------------------------------- */
  /* 1.0 12/18/2001 VAdapa Initial revision */
  /********************************************************************************************************/
  FUNCTION getobjid
  (
    ip_item_name  IN VARCHAR2
   ,ip_item_type  IN VARCHAR2
   ,op_item_objid OUT NUMBER
  ) RETURN BOOLEAN IS
  BEGIN

    IF ip_item_type = 'E' THEN
      SELECT objid
        INTO op_item_objid
        FROM table_part_inst
       WHERE part_serial_no = ip_item_name
         AND x_domain = 'PHONES';

    ELSIF ip_item_type = 'P' THEN
      SELECT ml.objid
        INTO op_item_objid
        FROM table_mod_level ml
            ,table_part_num  pn
       WHERE pn.objid = ml.part_info2part_num
         AND pn.part_number = ip_item_name
         AND ml.active = 'Active'
         AND ml.eff_date = (SELECT MAX(eff_date)
                              FROM table_mod_level ml1
                             WHERE ml1.part_info2part_num = ml.part_info2part_num);
    END IF;

    RETURN TRUE;

  EXCEPTION

    WHEN others THEN
      RETURN FALSE;
  END getobjid;
  --

  /********************************************************************************************************/
  /* Name : SetStatus */
  /* Type : Procedure */
  /* Purpose : To set the status of an ESN as "QUALIFIED / DISQUALIFIED / REVIEW / RESUBMIT" */
  /* for the rebate / referral program. This includes setting of status for the */
  /* refurbished ESNs also */
  /* Parameters : op_msg - 'TRUE' if success, 'FALSE' if fails    */
  /* op_err - Oracle error message if the procedure fails   */
  /* op_no_offer - List of offers that do not exist in the Offer Table */
  /*    op_inv_offer - List of offers that are not valid that day the program is run */
  /* op_qual_cnt - Number of esns qualified for the UNIT offer which requires a pin code */
  /* Author : Vanisri Adapa */
  /* Date : 12/12/2001 */
  /* Revisions : Version Date Who Purpose */
  /* ------- -------- ------- ----------------------------------------------- */
  /* 1.0 12/12/2001 VAdapa Initial revision */
  /*   1.1 03/19/2002 VAdapa Modified to include the check for date validity */
  /*    of the offers   */
  /* 1.2 08/02/2002 GPintado Added cursor to check if ESN already exists in */
  /* Sell-A-Friend program */
  /********************************************************************************************************/
  PROCEDURE setstatus
  (
    op_msg       OUT VARCHAR2
   ,op_err       OUT VARCHAR2
   ,op_no_offer  OUT VARCHAR2
   ,op_inv_offer OUT VARCHAR2
   ,op_qual_cnt  OUT NUMBER
  ) IS
    --Cursor to select all the records to be processed for rebate program
    CURSOR c_getrebrefinfo IS
      SELECT a.rowid
            ,a.*
        FROM x_rebate_referral_info a
       WHERE status = 'REVIEW';

    --Cursor to check if ESN already exists in Sell-A-Friend program
    CURSOR c_getsafinfo(c_ip_service_id_3 IN VARCHAR2) IS
      SELECT 'x'
        FROM x_raf_replies
       WHERE (friend_esn = c_ip_service_id_3 OR customer_esn = c_ip_service_id_3)
         AND ROWNUM < 2;

    r_getsafinfo c_getsafinfo%ROWTYPE;
    --
    --Cursor to get the dealer information
    CURSOR c_dealinfo(c_ip_esn_1 IN VARCHAR2) IS
      SELECT ts.objid
            ,ts.site_id
            ,ts.name
        FROM table_site      ts
            ,table_inv_bin   ib
            ,table_part_inst pi
       WHERE pi.part_inst2inv_bin = ib.objid
         AND ib.bin_name = ts.site_id
         AND pi.part_serial_no = c_ip_esn_1
         AND pi.x_domain = 'PHONES';

    r_dealinfo c_dealinfo%ROWTYPE;
    --
    --Cursor to check get the first activation date for an ESN
    CURSOR c_initialactdate(c_ip_service_id IN VARCHAR2) IS
      SELECT MIN(install_date) act_date
        FROM table_site_part
       WHERE x_service_id = c_ip_service_id
         AND part_status IN ('Active'
                            ,'Inactive')
       GROUP BY x_service_id;

    r_initialactdate c_initialactdate%ROWTYPE;
    --
    --Cursor to check whether the ESN is active within 10 days of due date
    CURSOR c_checkactive
    (
      c_ip_service_id_1 IN VARCHAR2
     ,c_ip_due_date     IN DATE
    ) IS
      SELECT objid
        FROM table_site_part
       WHERE (TRUNC(service_end_dt) >= TRUNC(c_ip_due_date - 10) OR TO_CHAR(service_end_dt
                                                                           ,'dd-mon-yyyy') = '01-jan-1753' OR service_end_dt IS NULL)
         AND TRUNC(install_date) <= TRUNC(c_ip_due_date + 10)
         AND x_service_id = c_ip_service_id_1
         AND part_status IN ('Active'
                            ,'Inactive');

    r_checkactive c_checkactive%ROWTYPE;
    --
    --Cursor to check whether the ESN is a refurbished one or not
    CURSOR c_refurbesn(c_ip_service_id_2 IN VARCHAR2) IS
    /* 1.1 03/17/03 SELECT 'X'
                                                                                                                                     FROM table_site_part
                                                                                                                                     WHERE x_service_id = c_ip_service_id_2 || 'R'
                                                                                                                                     AND part_status IN ('Active', 'Inactive')
                                                                                                                                     AND ROWNUM < 2; */
      SELECT 'X'
        FROM table_site_part
       WHERE x_refurb_flag = 1
         AND x_service_id = c_ip_service_id_2
         AND part_status IN ('Active'
                            ,'Inactive')
         AND ROWNUM < 2;

    r_refurbesn c_refurbesn%ROWTYPE;
    --
    --Cursor to check the offer information
    CURSOR c_offerinfo(c_ip_offer IN VARCHAR2) IS
      SELECT offer_type
            ,promo_type
            ,part_number
            ,technology
            ,start_date
            ,end_date
            ,offerinfo2pnum
        FROM x_offer_info
       WHERE NAME = c_ip_offer;

    r_offerinfo c_offerinfo%ROWTYPE;
    --
    --Cursor to get the count for qualified ESNs for UNIT offer
    CURSOR c_qualesn IS
      SELECT COUNT(1) qual_cnt
        FROM x_rebate_referral_info
       WHERE status = 'QUALIFIED'
         AND offer_type = 'UNIT'
         AND processed_date IS NULL;

    r_qualesn c_qualesn%ROWTYPE;
    --
    --Cursor to check whether the ESN is already qualified for the rebate offer but is not refurbished
    CURSOR c_reb_qual_esn
    (
      c_ip_coupon_no IN VARCHAR2
     ,c_ip_esn       IN VARCHAR2
    ) IS
      SELECT COUNT(1) qual_esn_cnt
        FROM x_rebate_referral_info
       WHERE esn = c_ip_esn
         AND status || '' = 'QUALIFIED';

    r_reb_qual_esn c_reb_qual_esn%ROWTYPE;
    --
    --Variable Declarations
    v_esn       VARCHAR2(30);
    v_refurb_yn CHAR(1);
    v_esn_objid NUMBER;
    v_esn_tech  VARCHAR2(20);

    v_continue_flag  CHAR(1);
    v_proceed_flag   CHAR(1);
    v_processed_date DATE;
    v_qual_status    VARCHAR2(30);

    v_no_offer_cnt      NUMBER := 0;
    v_cnt               NUMBER := 0;
    v_invalid_offer_cnt NUMBER := 0;
  BEGIN

    FOR r_getrebrefinfo IN c_getrebrefinfo LOOP

      v_continue_flag  := NULL;
      v_processed_date := NULL;
      v_proceed_flag   := NULL;
      v_refurb_yn      := NULL;

      OPEN c_offerinfo(r_getrebrefinfo.offer);
      FETCH c_offerinfo
        INTO r_offerinfo;
      --
      --Skips the process if offer does not exist in the X_OFFER_INFO table or if the offer is INVALID
      --
      IF c_offerinfo%NOTFOUND THEN
        IF v_no_offer_cnt = 0 THEN
          op_no_offer    := '''' || r_getrebrefinfo.offer || '''';
          v_no_offer_cnt := v_no_offer_cnt + 1;
        ELSE
          IF INSTR(op_no_offer
                  ,r_getrebrefinfo.offer) = 0 THEN
            op_no_offer    := op_no_offer || ', ' || '''' || r_getrebrefinfo.offer || '''';
            v_no_offer_cnt := v_no_offer_cnt + 1;
          END IF;
        END IF;

        v_proceed_flag := 'N';

      ELSE
        --
        --03/19/02 VAdapa
        --
        IF SYSDATE NOT BETWEEN r_offerinfo.start_date AND r_offerinfo.end_date THEN

          IF v_invalid_offer_cnt = 0 THEN
            op_inv_offer        := '''' || r_getrebrefinfo.offer || '''';
            v_invalid_offer_cnt := v_invalid_offer_cnt + 1;
          ELSE

            IF INSTR(op_inv_offer
                    ,r_getrebrefinfo.offer) = 0 THEN
              op_inv_offer        := op_inv_offer || ', ' || '''' || r_getrebrefinfo.offer || '''';
              v_invalid_offer_cnt := v_invalid_offer_cnt + 1;
            END IF;

          END IF;

          v_proceed_flag := 'N';

        ELSE
          v_proceed_flag := 'Y';

        END IF;

      END IF; -- end of Offerinfo check

      --
      --Proceed only if the offer is VALID
      --
      IF v_proceed_flag = 'Y' THEN
        IF r_offerinfo.promo_type = 'REBATE' THEN
          v_esn := r_getrebrefinfo.esn;
        ELSIF r_offerinfo.promo_type = 'REFERRAL' THEN
          v_esn := r_getrebrefinfo.esn_referred;
        END IF;

        IF getobjid(v_esn
                   ,'E'
                   ,v_esn_objid) THEN

          OPEN c_dealinfo(v_esn);
          FETCH c_dealinfo
            INTO r_dealinfo;
          CLOSE c_dealinfo;

          OPEN c_refurbesn(v_esn);
          FETCH c_refurbesn
            INTO r_refurbesn;

          IF c_refurbesn%FOUND THEN

            v_refurb_yn := 'Y';
          ELSE
            v_refurb_yn := 'N';
          END IF;

          CLOSE c_refurbesn;

          OPEN c_initialactdate(v_esn);
          FETCH c_initialactdate
            INTO r_initialactdate;

          OPEN c_getsafinfo(v_esn);
          FETCH c_getsafinfo
            INTO r_getsafinfo;

          v_esn_tech := checkesntech(v_esn);
          --
          --Proceeds only if the offer technology matches with the ESN technology and ESN does not
          --exist in the Sell-A-Friend program
          --
          IF v_esn_tech <> 'ERROR'
             AND (v_esn_tech = r_offerinfo.technology OR r_offerinfo.technology = 'BOTH')
             AND c_getsafinfo%NOTFOUND THEN
            --
            --Set the status to 'REVIEW' if ESN is not yet activated
            --
            IF c_initialactdate%NOTFOUND THEN
              UPDATE x_rebate_referral_info
                 SET status           = 'REVIEW'
                    ,times_processed  = times_processed + 1
                    ,activate_date    = NULL
                    ,processed_date   = SYSDATE
                    ,refurb_esn       = v_refurb_yn
                    ,last_update_date = SYSDATE
               WHERE ROWID = r_getrebrefinfo.rowid;

              v_continue_flag := 'R';

            ELSIF c_initialactdate%FOUND THEN
              --
              --Set the status to 'REVIEW' if activation date is not more than 80 days
              --
              IF r_initialactdate.act_date > (SYSDATE - 80) THEN
                UPDATE x_rebate_referral_info
                   SET status           = 'REVIEW'
                      ,times_processed  = times_processed + 1
                      ,activate_date    = r_initialactdate.act_date
                      ,processed_date   = SYSDATE
                      ,refurb_esn       = v_refurb_yn
                      ,last_update_date = SYSDATE
                 WHERE ROWID = r_getrebrefinfo.rowid;

                v_continue_flag := 'R';
              END IF;
            END IF; -- end of c_InitialActDate check

            CLOSE c_initialactdate;

            IF v_continue_flag <> 'R'
               OR v_continue_flag IS NULL THEN

              OPEN c_checkactive(v_esn
                                ,r_initialactdate.act_date + 90);
              FETCH c_checkactive
                INTO r_checkactive;
              --
              --Disqualify if ESN is Inactive within 10 days of due date
              --
              IF c_checkactive%NOTFOUND THEN
                UPDATE x_rebate_referral_info
                   SET status           = 'DISQUALIFIED'
                      ,times_processed  = times_processed + 1
                      ,activate_date    = r_initialactdate.act_date
                      ,dealer_objid     = r_dealinfo.objid
                      ,dealer_id        = r_dealinfo.site_id
                      ,dealer_name      = r_dealinfo.name
                      ,part_number      = r_offerinfo.part_number
                      ,offer_type       = r_offerinfo.offer_type
                      ,promotion_type   = r_offerinfo.promo_type
                      ,processed_date   = SYSDATE
                      ,refurb_esn       = v_refurb_yn
                      ,last_update_date = SYSDATE
                 WHERE ROWID = r_getrebrefinfo.rowid;
              ELSE

                IF r_offerinfo.offer_type = 'UNIT' THEN
                  v_processed_date := NULL;
                ELSE
                  v_processed_date := SYSDATE;
                END IF;

                OPEN c_reb_qual_esn(r_getrebrefinfo.coupon_ref_no
                                   ,r_getrebrefinfo.esn);
                FETCH c_reb_qual_esn
                  INTO r_reb_qual_esn;
                CLOSE c_reb_qual_esn;
                --
                --Disqualifies if the rebate ESN is already qualified, but is not refurbished
                --
                IF r_reb_qual_esn.qual_esn_cnt > 0
                   AND v_refurb_yn = 'N' THEN
                  UPDATE x_rebate_referral_info
                     SET status           = 'DISQUALIFIED'
                        ,times_processed  = times_processed + 1
                        ,activate_date    = r_initialactdate.act_date
                        ,dealer_objid     = r_dealinfo.objid
                        ,dealer_id        = r_dealinfo.site_id
                        ,dealer_name      = r_dealinfo.name
                        ,part_number      = r_offerinfo.part_number
                        ,offer_type       = r_offerinfo.offer_type
                        ,promotion_type   = r_offerinfo.promo_type
                        ,processed_date   = SYSDATE
                        ,refurb_esn       = v_refurb_yn
                        ,last_update_date = SYSDATE
                   WHERE ROWID = r_getrebrefinfo.rowid;

                ELSE
                  --
                  --Qualify the ESN is it passes through all the checks mentioned above
                  --
                  UPDATE x_rebate_referral_info
                     SET status           = 'QUALIFIED'
                        ,times_processed  = times_processed + 1
                        ,activate_date    = r_initialactdate.act_date
                        ,dealer_objid     = r_dealinfo.objid
                        ,dealer_id        = r_dealinfo.site_id
                        ,dealer_name      = r_dealinfo.name
                        ,part_number      = r_offerinfo.part_number
                        ,offer_type       = r_offerinfo.offer_type
                        ,promotion_type   = r_offerinfo.promo_type
                        ,processed_date   = v_processed_date
                        ,refurb_esn       = v_refurb_yn
                        ,last_update_date = SYSDATE
                   WHERE ROWID = r_getrebrefinfo.rowid;
                END IF;
              END IF; -- end of CheckActive

              CLOSE c_checkactive;

            END IF; --end of 'R' flag check

          ELSE
            --
            --Disqualify the ESN if the offer technology does not match with the ESN technology
            --
            UPDATE x_rebate_referral_info
               SET status           = 'DISQUALIFIED'
                  ,times_processed  = times_processed + 1
                  ,activate_date    = r_initialactdate.act_date
                  ,dealer_objid     = r_dealinfo.objid
                  ,dealer_id        = r_dealinfo.site_id
                  ,dealer_name      = r_dealinfo.name
                  ,part_number      = r_offerinfo.part_number
                  ,offer_type       = r_offerinfo.offer_type
                  ,promotion_type   = r_offerinfo.promo_type
                  ,processed_date   = SYSDATE
                  ,refurb_esn       = v_refurb_yn
                  ,last_update_date = SYSDATE
             WHERE ROWID = r_getrebrefinfo.rowid;
          END IF; -- end of technology check for an ESN

        ELSE
          --
          --RESUBMIT if the ESN is not found in TOSS
          --
          UPDATE x_rebate_referral_info
             SET status           = 'RESUBMIT'
                ,activate_date    = NULL
                ,times_processed  = times_processed + 1
                ,processed_date   = SYSDATE
                ,refurb_esn       = v_refurb_yn
                ,last_update_date = SYSDATE
           WHERE ROWID = r_getrebrefinfo.rowid;

        END IF; --end of esn_found check;

      END IF; --end of proceed flag check

      CLOSE c_offerinfo;

      v_cnt := v_cnt + 1;

      IF MOD(v_cnt
            ,100) = 0 THEN
        COMMIT;
      END IF;

      IF c_getsafinfo%ISOPEN THEN
        CLOSE c_getsafinfo;
      END IF;

      IF c_dealinfo%ISOPEN THEN
        CLOSE c_dealinfo;
      END IF;

      IF c_initialactdate%ISOPEN THEN
        CLOSE c_initialactdate;
      END IF;

      IF c_checkactive%ISOPEN THEN
        CLOSE c_checkactive;
      END IF;

      IF c_refurbesn%ISOPEN THEN
        CLOSE c_refurbesn;
      END IF;

      IF c_offerinfo%ISOPEN THEN
        CLOSE c_offerinfo;
      END IF;

      IF c_qualesn%ISOPEN THEN
        CLOSE c_qualesn;
      END IF;

      IF c_reb_qual_esn%ISOPEN THEN
        CLOSE c_reb_qual_esn;
      END IF;
    END LOOP;

    COMMIT;

    IF NVL(v_no_offer_cnt
          ,0) = 0 THEN
      op_no_offer := NULL;
    ELSE
      op_no_offer := 'These offers ' || op_no_offer || ' do not exist in the Offer Table';
    END IF;

    IF NVL(v_invalid_offer_cnt
          ,0) = 0 THEN
      op_inv_offer := NULL;
    ELSE
      op_inv_offer := 'These offers ' || op_inv_offer || ' are not valid';
    END IF;

    OPEN c_qualesn;
    FETCH c_qualesn
      INTO r_qualesn;
    CLOSE c_qualesn;

    op_qual_cnt := NVL(r_qualesn.qual_cnt
                      ,0);
    op_msg      := 'TRUE';
    op_err      := NULL;

  EXCEPTION

    WHEN others THEN

      op_msg := 'FALSE';
      op_err := SQLERRM || ': Contact System Administrator';

      SELECT COUNT(1)
        INTO op_qual_cnt
        FROM x_rebate_referral_info
       WHERE status IN ('QUALIFIED')
         AND offer_type = 'UNIT'
         AND processed_date IS NULL;

      IF NVL(v_no_offer_cnt
            ,0) = 0 THEN
        op_no_offer := NULL;
      ELSE
        op_no_offer := 'These offers ' || op_no_offer || 'do not exist in the Offer Table';
      END IF;

      IF NVL(v_invalid_offer_cnt
            ,0) = 0 THEN
        op_inv_offer := NULL;
      ELSE
        op_inv_offer := 'These offers ' || op_inv_offer || ' are not valid';
      END IF;
  END setstatus;
  --

  /********************************************************************************************************/
  /* Name : SetTimeCode */
  /* Type : Procedure */
  /* Purpose : To set the PIN CODE for the QUALIFIED ESNs of 'UNIT' offer type */
  /* Parameters : Output - op_err, op_msg */
  /* Author : Vanisri Adapa */
  /* Date : 12/18/2001 */
  /* Revisions : Version Date Who Purpose */
  /* ------- -------- ------- ----------------------------------------------- */
  /* 1.0 12/18/2001 VAdapa Initial revision */
  /********************************************************************************************************/
  PROCEDURE settimecode
  (
    op_msg OUT VARCHAR2
   ,op_err OUT VARCHAR2
  ) IS

    CURSOR c_qualesn IS
      SELECT *
        FROM x_rebate_referral_info
       WHERE status IN ('QUALIFIED')
         AND offer_type = 'UNIT'
         AND processed_date IS NULL;

    v_err  VARCHAR2(4000);
    v_flag NUMBER := 0;
  BEGIN

    FOR r_qualesn IN c_qualesn LOOP

      IF NOT gettimecode(r_qualesn.coupon_ref_no
                        ,r_qualesn.esn
                        ,r_qualesn.esn_referred
                        ,r_qualesn.promotion_type
                        ,r_qualesn.part_number
                        ,r_qualesn.pin_code
                        ,v_err) THEN
        v_flag := 1;
        EXIT;
      END IF;
    END LOOP;

    IF v_flag = 1 THEN
      op_err := v_err;
      op_msg := 'FALSE';
    ELSE
      op_err := NULL;
      op_msg := 'TRUE';
    END IF;
  EXCEPTION
    WHEN others THEN
      op_err := SQLERRM || ': Contact System Administrator';
      op_msg := 'FALSE';
  END settimecode;
  --

  /********************************************************************************************************/
  /* Name : GetTimeCode */
  /* Type : Function          */
  /* Purpose : To get a new time code from x_promotion_code_pool and insert it into   */
  /* table_part_inst associating it with the part_number selected from the */
  /* rebate/referral program and also set the PIN CODE to the coupon referred     */
  /* Parameters : Input - ip_coupon_ref_no, ip_sub_esn, ip_ref_esn, ip_promo_type, ip_part_number */
  /* ip_pin_code */
  /* Output - op_err */
  /* Platforms : Oracle 8.0.6 AND newer versions */
  /* Author : Gerald Pintado */
  /* Date : 01/06/2000 */
  /* Revisions : Version Date Who Purpose */
  /* ------- -------- ------- ----------------------------------------------- */
  /* 1.0 01/06/2000 GPintado Initial revision */
  /* 1.1 12/14/2001 VAdapa Modified to get the data from the new table */
  /* X_REBATE_REFERRAL_INFO */
  /********************************************************************************************************/
  FUNCTION gettimecode
  (
    ip_coupon_ref_no IN VARCHAR2
   ,ip_sub_esn       IN VARCHAR2
   ,ip_ref_esn       IN VARCHAR2
   ,ip_promo_type    IN VARCHAR2
   ,ip_part_number   IN VARCHAR2
   ,ip_pin_code      IN VARCHAR2
   ,op_err           OUT VARCHAR2
  ) RETURN BOOLEAN IS
    --Cursor to get the pin code from the X_PROMOTION_CODE_POOL
    CURSOR c_getnewcode IS
      SELECT x_red_code
            ,part_serial_no
        FROM x_promotion_code_pool
       WHERE ROWNUM < 2;

    r_getnewcode c_getnewcode%ROWTYPE;
    --
    v_modlvl_objid NUMBER;
    v_esn_objid    NUMBER;
  BEGIN

    OPEN c_getnewcode;
    FETCH c_getnewcode
      INTO r_getnewcode;
    --
    --Stop processing if no codes are available in X_PROMOTION_CODE_POOL table
    --
    IF c_getnewcode%NOTFOUND THEN
      CLOSE c_getnewcode;
      op_err := 'No Codes Available';
      RETURN FALSE;
    ELSE
      DELETE x_promotion_code_pool
       WHERE part_serial_no = r_getnewcode.part_serial_no;
      COMMIT;
    END IF;

    CLOSE c_getnewcode;

    IF NOT getobjid(ip_sub_esn
                   ,'E'
                   ,v_esn_objid) THEN
      --
      --RESUBMIT if ESN is not found in TOSS
      --
      UPDATE x_rebate_referral_info
         SET status           = 'RESUBMIT'
            ,times_processed  = times_processed + 1
            ,processed_date   = SYSDATE
            ,last_update_date = SYSDATE
       WHERE coupon_ref_no = ip_coupon_ref_no;

      COMMIT;
      RETURN TRUE;
    END IF;

    IF ip_pin_code IS NULL THEN
      --
      --Assign the PIN CODE to the coupon referred (Qualified ESN for UNIT offer type)
      --

      UPDATE x_rebate_referral_info
         SET pin_code         = r_getnewcode.x_red_code
            ,times_processed  = times_processed + 1
            ,processed_date   = SYSDATE
            ,last_update_date = SYSDATE
       WHERE coupon_ref_no = ip_coupon_ref_no;

      IF SQL%ROWCOUNT = 1 THEN

        IF getobjid(ip_part_number
                   ,'P'
                   ,v_modlvl_objid) THEN
          --
          --Load the assigned PIN CODE into TOSS with '40' (RESERVED) status
          --
          INSERT INTO table_part_inst
            (objid
            ,part_serial_no
            ,x_part_inst_status
            ,x_sequence
            ,x_po_num
            ,x_red_code
            ,x_order_number
            ,x_creation_date
            ,created_by2user
            ,x_domain
            ,n_part_inst2part_mod
            ,part_inst2inv_bin
            ,part_status
            ,x_insert_date
            ,status2x_code_table
            ,part_to_esn2part_inst
            ,last_pi_date
            ,last_cycle_ct
            ,next_cycle_ct
            ,last_mod_time
            ,last_trans_time
            ,date_in_serv
            ,repair_date)
          VALUES
            (
             -- 04/10/03 seq_part_inst.nextval + (POWER (2, 28)),
             seq('part_inst')
            ,r_getnewcode.part_serial_no
            ,'40'
            ,0
            ,NULL
            ,r_getnewcode.x_red_code
            ,NULL
            ,SYSDATE
            ,268435556
            , -- SA objid in table_user
             'REDEMPTION CARDS'
            ,v_modlvl_objid
            ,
             --268488622, -- Topp Telecom Marketing objid in table_inv_bin where bin_name = 2359
             268490709
            , -- "TRACFONE REBATE" objid in table_inv_bin where bin_name = 20740
             'Active'
            ,SYSDATE
            ,982
            ,v_esn_objid
            ,TO_DATE('01-01-1753'
                    ,'DD-MM-YYYY')
            ,TO_DATE('01-01-1753'
                    ,'DD-MM-YYYY')
            ,TO_DATE('01-01-1753'
                    ,'DD-MM-YYYY')
            ,TO_DATE('01-01-1753'
                    ,'DD-MM-YYYY')
            ,TO_DATE('01-01-1753'
                    ,'DD-MM-YYYY')
            ,TO_DATE('01-01-1753'
                    ,'DD-MM-YYYY')
            ,TO_DATE('01-01-1753'
                    ,'DD-MM-YYYY'));
          COMMIT;
        ELSE
          ROLLBACK;
        END IF;
      END IF;
    ELSE

      UPDATE x_rebate_referral_info
         SET times_processed  = times_processed + 1
            ,processed_date   = SYSDATE
            ,last_update_date = SYSDATE
       WHERE coupon_ref_no = ip_coupon_ref_no;

      COMMIT;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN others THEN
      op_err := SQLERRM || ': Contact System Administrator';
      RETURN FALSE;
  END gettimecode;
  --

  /********************************************************************************************************/
  /* Name : upd_resub_coupon */
  /* Type : Procedure */
  /* Purpose : To update 'RESUBMIT' status coupons to not to process them again when the */
  /* the Express Group sends them back. */
  /* Parameters : NONE */
  /* Author : Vanisri Adapa */
  /* Date : 03/18/2002 */
  /* Revisions : Version Date Who Purpose */
  /* ------- -------- ------- ----------------------------------------------- */
  /* 1.0 03/18/2002 VAdapa Initial revision */
  /********************************************************************************************************/
  PROCEDURE upd_resub_coupon(op_msg OUT VARCHAR2) IS

    CURSOR c_resub_coupon IS
      SELECT coupon_ref_no
        FROM x_rebate_referral_info
       WHERE status = 'RESUBMIT'
         AND rec_create_date < TRUNC(SYSDATE);
  BEGIN

    FOR r_resub_coupon IN c_resub_coupon LOOP
      BEGIN
        UPDATE x_rebate_referral_info
           SET coupon_ref_no    = coupon_ref_no || '_' || TO_CHAR(seq_reb_ref_coupon.nextval)
              ,status           = 'RESUB_UPD_COUPON'
              ,last_update_date = SYSDATE
         WHERE coupon_ref_no = r_resub_coupon.coupon_ref_no;

        COMMIT;
      EXCEPTION
        WHEN others THEN
          NULL;
      END;
    END LOOP;
  END;
  --

  /********************************************************************************************************/
  /* Name : offer_maintenance */
  /* Type : Procedure */
  /* Purpose : To maintain the offer table (Inserts / Updates) */
  /* Parameters : Input - ip_offer, ip_promotype, ip_offertype, ip_offerdesc, ip_cashvalue, */
  /* ip_unitvalue, ip_partnum, ip_technology, ip_startdate, ip_enddate */
  /* Output - op_result, op_msg */
  /* Author : Gerald Pintado */
  /* Date : 03/18/2002 */
  /* Revisions : Version Date Who Purpose */
  /* ------- -------- ------- ----------------------------------------------- */
  /* 1.0 03/18/2002 GPintado Initial revision */
  /********************************************************************************************************/
  PROCEDURE offer_maintenance
  (
    ip_offer            IN sa.x_offer_info.name%TYPE
   ,ip_promotype        IN sa.x_offer_info.promo_type%TYPE
   ,ip_offertype        IN sa.x_offer_info.offer_type%TYPE
   ,ip_offerdesc        IN sa.x_offer_info.offer_desc%TYPE
   ,ip_cashvalue        IN sa.x_offer_info.cash_value%TYPE
   ,ip_unitvalue        IN sa.x_offer_info.unit_value%TYPE
   ,ip_partnum          IN sa.x_offer_info.part_number%TYPE
   ,ip_technology       IN sa.x_offer_info.technology%TYPE
   ,ip_startdate        IN sa.x_offer_info.start_date%TYPE
   ,ip_enddate          IN sa.x_offer_info.end_date%TYPE
   ,ip_pnum_objid       IN sa.x_offer_info.offerinfo2pnum%TYPE
   ,op_result          OUT NUMBER
   , /*0=Ok ,1=Error*/op_msg        OUT VARCHAR2 /*Error Message if op_result = 1 otherwise = OK*/
  ) IS

    CURSOR c_get_offer IS
      SELECT *
        FROM sa.x_offer_info
       WHERE NAME = ip_offer;

    c_get_offer_rec c_get_offer%ROWTYPE;
  BEGIN
    op_result := 0;

    OPEN c_get_offer;
    FETCH c_get_offer
      INTO c_get_offer_rec;

    IF c_get_offer%FOUND THEN

      UPDATE sa.x_offer_info
         SET promo_type    = ip_promotype
            ,offer_type    = ip_offertype
            ,offer_desc    = ip_offerdesc
            ,cash_value    = ip_cashvalue
            ,unit_value    = ip_unitvalue
            ,part_number   = ip_partnum
            ,technology    = ip_technology
            ,start_date    = ip_startdate
            ,end_date      = ip_enddate
            ,offerinfo2pnum= ip_pnum_objid
       WHERE objid = c_get_offer_rec.objid;

      op_msg := 'Update Successful';
    ELSE
      INSERT INTO sa.x_offer_info
        (objid
        ,NAME
        ,promo_type
        ,offer_type
        ,offer_desc
        ,cash_value
        ,unit_value
        ,part_number
        ,technology
        ,start_date
        ,end_date
        ,offerinfo2pnum)
      VALUES
        (sa.seq_x_offer_info.nextval
        ,ip_offer
        ,ip_promotype
        ,ip_offertype
        ,ip_offerdesc
        ,ip_cashvalue
        ,ip_unitvalue
        ,ip_partnum
        ,ip_technology
        ,ip_startdate
        ,ip_enddate
        ,ip_pnum_objid);

      op_msg := 'Insert Successful';
      COMMIT;
    END IF;
  EXCEPTION
    WHEN others THEN
      op_result := 1;
      op_msg    := 'Error has occured';
      ROLLBACK;
      RETURN;
  END;
  --
  -- CR16379 Start KACOSTA 03/06/2012
  --*******************************************
  -- Function to check if an ESN is currently enrolled
  -- into a promotion group by promotion
  --*******************************************
  --
  FUNCTION enrolled_promo_group_by_promo
  (
    p_esn        IN table_part_inst.part_serial_no%TYPE
   ,p_promo_code IN table_x_promotion.x_promo_code%TYPE
  ) RETURN INTEGER IS
    --
    CURSOR chk_promo_group_by_promo_curs
    (
      c_v_esn        table_part_inst.part_serial_no%TYPE
     ,c_v_promo_code IN table_x_promotion.x_promo_code%TYPE
    ) IS
      SELECT DISTINCT 1 enrolled_promo_group_by_promo
        FROM table_part_inst tpi
        JOIN table_x_group2esn xge
          ON tpi.objid = xge.groupesn2part_inst
        JOIN table_x_promotion txp
          ON xge.groupesn2x_promotion = txp.objid
       WHERE tpi.part_serial_no = c_v_esn
         AND tpi.x_domain = 'PHONES'
         AND SYSDATE BETWEEN NVL(xge.x_start_date
                                ,SYSDATE) AND NVL(xge.x_end_date
                                                 ,SYSDATE)
         AND txp.x_promo_code = c_v_promo_code;
    --
    chk_promo_group_by_promo_rec chk_promo_group_by_promo_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.enrolled_promo_group_by_promo';
    l_i_error_code    INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn       : ' || NVL(p_esn
                                                  ,'Value is null'));
      dbms_output.put_line('p_promo_code: ' || NVL(p_promo_code
                                                  ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Check if ESN is enrolled into promotion group by promotion';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF chk_promo_group_by_promo_curs%ISOPEN THEN
      --
      CLOSE chk_promo_group_by_promo_curs;
      --
    END IF;
    --
    OPEN chk_promo_group_by_promo_curs(c_v_esn        => p_esn
                                      ,c_v_promo_code => p_promo_code);
    FETCH chk_promo_group_by_promo_curs
      INTO chk_promo_group_by_promo_rec;
    --
    IF chk_promo_group_by_promo_curs%FOUND THEN
      --
      l_v_position := l_cv_subprogram_name || '.3';
      l_v_note     := 'Yes, ESN is enrolled into promotion group by promotion';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      chk_promo_group_by_promo_rec.enrolled_promo_group_by_promo := 1;
      --
    ELSE
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'No, ESN is enrolled into promotion group by promotion';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      chk_promo_group_by_promo_rec.enrolled_promo_group_by_promo := 0;
      --
    END IF;
    --
    CLOSE chk_promo_group_by_promo_curs;
    --
    l_v_position := l_cv_subprogram_name || '.5';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
      dbms_output.put_line('enrolled_promo_group_by_promo: ' || NVL(chk_promo_group_by_promo_rec.enrolled_promo_group_by_promo
                                                                   ,'Value is null'));
      dbms_output.put_line('p_error_code                 : ' || NVL(TO_CHAR(l_i_error_code)
                                                                   ,'Value is null'));
      dbms_output.put_line('p_error_message              : ' || NVL(l_v_error_message
                                                                   ,'Value is null'));
      --
    END IF;
    --
    RETURN chk_promo_group_by_promo_rec.enrolled_promo_group_by_promo;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      IF chk_promo_group_by_promo_curs%ISOPEN THEN
        --
        CLOSE chk_promo_group_by_promo_curs;
        --
      END IF;
      --
      RAISE;
      --
  END enrolled_promo_group_by_promo;
  --
  --*******************************************
  -- Function to check if an ESN is currently enrolled
  -- into both Double and Triple Minute program
  --*******************************************
  --
  FUNCTION is_esn_both_double_and_triple(p_esn IN table_part_inst.part_serial_no%TYPE) RETURN BOOLEAN IS
    --
    CURSOR is_esn_double_curs(c_v_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT 1
        FROM table_part_inst tpi_esn
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND EXISTS (SELECT 1
                FROM table_x_group2esn xge
                JOIN table_x_promotion_group xpg
                  ON xge.groupesn2x_promo_group = xpg.objid
               WHERE xge.groupesn2part_inst = tpi_esn.objid
                 AND SYSDATE BETWEEN NVL(xge.x_start_date
                                        ,SYSDATE) AND NVL(xge.x_end_date
                                                         ,SYSDATE)
                 AND xpg.group_name LIKE '%DBL%');
    --
    is_esn_double_rec is_esn_double_curs%ROWTYPE;
    --
    CURSOR is_esn_triple_curs(c_v_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT 1
        FROM table_part_inst tpi_esn
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND EXISTS (SELECT 1
                FROM table_x_group2esn xge
                JOIN table_x_promotion_group xpg
                  ON xge.groupesn2x_promo_group = xpg.objid
               WHERE xge.groupesn2part_inst = tpi_esn.objid
                 AND SYSDATE BETWEEN NVL(xge.x_start_date
                                        ,SYSDATE) AND NVL(xge.x_end_date
                                                         ,SYSDATE)
                 AND xpg.group_name LIKE '%X3X%');
    --
    is_esn_triple_rec is_esn_triple_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.is_esn_both_double_and_triple';
    l_b_esn_both_double_and_triple BOOLEAN := FALSE;
    l_i_error_code                 INTEGER := 0;
    l_v_error_message              VARCHAR2(32767) := 'SUCCESS';
    l_v_position                   VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note                       VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn: ' || NVL(p_esn
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Check if ESN is enrolled in the Double Minute program';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF is_esn_double_curs%ISOPEN THEN
      --
      CLOSE is_esn_double_curs;
      --
    END IF;
    --
    OPEN is_esn_double_curs(c_v_esn => p_esn);
    FETCH is_esn_double_curs
      INTO is_esn_double_rec;
    --
    IF is_esn_double_curs%FOUND THEN
      --
      l_v_position := l_cv_subprogram_name || '.3';
      l_v_note     := 'Yes, ESN in Double Minute program; check if ESN is enrolled in the Triple Minute program';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF is_esn_triple_curs%ISOPEN THEN
        --
        CLOSE is_esn_triple_curs;
        --
      END IF;
      --
      OPEN is_esn_triple_curs(c_v_esn => p_esn);
      FETCH is_esn_triple_curs
        INTO is_esn_triple_rec;
      --
      IF is_esn_triple_curs%FOUND THEN
        --
        l_b_esn_both_double_and_triple := TRUE;
        --
      END IF;
      --
      CLOSE is_esn_triple_curs;
      --
    END IF;
    --
    CLOSE is_esn_double_curs;
    --
    l_v_position := l_cv_subprogram_name || '.4';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
      IF l_b_esn_both_double_and_triple THEN
        --
        dbms_output.put_line('esn_both_double_and_triple: TRUE');
        --
      ELSE
        --
        dbms_output.put_line('esn_both_double_and_triple: FALSE');
        --
      END IF;
      --
      dbms_output.put_line('p_error_code              : ' || NVL(TO_CHAR(l_i_error_code)
                                                                ,'Value is null'));
      dbms_output.put_line('p_error_message           : ' || NVL(l_v_error_message
                                                                ,'Value is null'));
      --
    END IF;
    --
    RETURN l_b_esn_both_double_and_triple;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      IF is_esn_double_curs%ISOPEN THEN
        --
        CLOSE is_esn_double_curs;
        --
      END IF;
      --
      IF is_esn_triple_curs%ISOPEN THEN
        --
        CLOSE is_esn_triple_curs;
        --
      END IF;
      --
      RAISE;
      --
  END is_esn_both_double_and_triple;
  --
  --*******************************************
  -- Procedure to expire ESN group2esn Double Minute program record
  -- if the ESN is currently enrolled into Triple Minute program
  --*******************************************
  --
  PROCEDURE expire_double_if_esn_is_triple
  (
    p_esn           IN table_part_inst.part_serial_no%TYPE
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.expire_double_if_esn_is_triple';
    l_i_error_code    INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn: ' || NVL(p_esn
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Check if the ESN is currently enrolled into Double and Triple Minute program';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF is_esn_both_double_and_triple(p_esn => p_esn) THEN
      --
      l_v_position := l_cv_subprogram_name || '.3';
      l_v_note     := 'Yes, the ESN is currently enrolled into Double and Triple Minute program; expire group2esn double minute program record';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      UPDATE table_x_group2esn xge
         SET xge.x_end_date = SYSDATE
       WHERE EXISTS (SELECT 1
                FROM table_part_inst tpi_esn
               WHERE tpi_esn.objid = xge.groupesn2part_inst
                 AND tpi_esn.part_serial_no = p_esn)
         AND EXISTS (SELECT 1
                FROM table_x_promotion_group xpg
               WHERE xpg.objid = xge.groupesn2x_promo_group
                 AND xpg.group_name LIKE '%DBL%')
         AND SYSDATE BETWEEN NVL(xge.x_start_date
                                ,SYSDATE) AND NVL(xge.x_end_date
                                                 ,SYSDATE);
      --
      COMMIT;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.4';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                     ,'Value is null'));
      --
    END IF;
    --
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END expire_double_if_esn_is_triple;
  --
  --*******************************************
  -- Procedure to retrieve an ESN program type (promotion group)
  -- Will be display on the customer profile in WebCSR
  --*******************************************
  --
  PROCEDURE get_esn_program_type_prm_group
  (
    p_esn           IN table_part_inst.part_serial_no%TYPE
   ,p_program_type  OUT table_x_promotion_group.group_name%TYPE
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    CURSOR get_x3x_promotion_group_curs(c_v_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT xpg.group_name
        FROM table_part_inst tpi_esn
        JOIN table_x_group2esn xge
          ON tpi_esn.objid = xge.groupesn2part_inst
        JOIN table_x_promotion_group xpg
          ON xge.groupesn2x_promo_group = xpg.objid
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND SYSDATE BETWEEN NVL(xge.x_start_date
                                ,SYSDATE) AND NVL(xge.x_end_date
                                                 ,SYSDATE)
         AND xpg.group_name LIKE '%X3X%'
       ORDER BY xge.x_end_date   DESC
               ,xge.x_start_date DESC
               ,xge.objid        DESC;
    --
    get_x3x_promotion_group_rec get_x3x_promotion_group_curs%ROWTYPE;
    --
    CURSOR get_dbl_promotion_group_curs(c_v_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT xpg.group_name
        FROM table_part_inst tpi_esn
        JOIN table_x_group2esn xge
          ON tpi_esn.objid = xge.groupesn2part_inst
        JOIN table_x_promotion_group xpg
          ON xge.groupesn2x_promo_group = xpg.objid
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND SYSDATE BETWEEN NVL(xge.x_start_date
                                ,SYSDATE) AND NVL(xge.x_end_date
                                                 ,SYSDATE)
         AND xpg.group_name LIKE '%DBL%'
       ORDER BY xge.x_end_date   DESC
               ,xge.x_start_date DESC
               ,xge.objid        DESC;
    --
    get_dbl_promotion_group_rec get_dbl_promotion_group_curs%ROWTYPE;
    --
    CURSOR get_promotion_group_curs(c_v_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT xpg.group_name
        FROM table_part_inst tpi_esn
        JOIN table_x_group2esn xge
          ON tpi_esn.objid = xge.groupesn2part_inst
        JOIN table_x_promotion_group xpg
          ON xge.groupesn2x_promo_group = xpg.objid
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND SYSDATE BETWEEN NVL(xge.x_start_date
                                ,SYSDATE) AND NVL(xge.x_end_date
                                                 ,SYSDATE)
       ORDER BY xge.x_end_date   DESC
               ,xge.x_start_date DESC
               ,xge.objid        DESC;
    --
    get_promotion_group_rec get_promotion_group_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.get_esn_program_type_prm_group';
    l_b_x3x_promotion_group BOOLEAN := FALSE;
    l_b_dbl_promotion_group BOOLEAN := FALSE;
    l_i_error_code          INTEGER := 0;
    l_v_error_message       VARCHAR2(32767) := 'SUCCESS';
    l_v_position            VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note                VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_program_type        table_x_promotion_group.group_name%TYPE;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn: ' || NVL(p_esn
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Check if ESN is enrolled in the Triple Minute program';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF get_x3x_promotion_group_curs%ISOPEN THEN
      --
      CLOSE get_x3x_promotion_group_curs;
      --
    END IF;
    --
    OPEN get_x3x_promotion_group_curs(c_v_esn => p_esn);
    FETCH get_x3x_promotion_group_curs
      INTO get_x3x_promotion_group_rec;
    --
    IF get_x3x_promotion_group_curs%FOUND THEN
      --
      l_v_program_type        := get_x3x_promotion_group_rec.group_name;
      l_b_x3x_promotion_group := TRUE;
      --
    END IF;
    --
    CLOSE get_x3x_promotion_group_curs;
    --
    IF (NOT l_b_x3x_promotion_group) THEN
      --
      l_v_position := l_cv_subprogram_name || '.3';
      l_v_note     := 'Not in Triple Minute program; check if ESN is enrolled in the Double Minute program';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF get_dbl_promotion_group_curs%ISOPEN THEN
        --
        CLOSE get_dbl_promotion_group_curs;
        --
      END IF;
      --
      OPEN get_dbl_promotion_group_curs(c_v_esn => p_esn);
      FETCH get_dbl_promotion_group_curs
        INTO get_dbl_promotion_group_rec;
      --
      IF get_dbl_promotion_group_curs%FOUND THEN
        --
        l_v_program_type        := get_dbl_promotion_group_rec.group_name;
        l_b_dbl_promotion_group := TRUE;
        --
      END IF;
      --
      CLOSE get_dbl_promotion_group_curs;
      --
      IF (NOT l_b_dbl_promotion_group) THEN
        --
        l_v_position := l_cv_subprogram_name || '.4';
        l_v_note     := 'Not in Double Minute program; check if ESN is enrolled in any program';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF get_promotion_group_curs%ISOPEN THEN
          --
          CLOSE get_promotion_group_curs;
          --
        END IF;
        --
        OPEN get_promotion_group_curs(c_v_esn => p_esn);
        FETCH get_promotion_group_curs
          INTO get_promotion_group_rec;
        --
        IF get_promotion_group_curs%FOUND THEN
          --
          l_v_program_type := get_promotion_group_rec.group_name;
          --
        END IF;
        --
        CLOSE get_promotion_group_curs;
        --
      END IF;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.5';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_program_type : ' || NVL(l_v_program_type
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                     ,'Value is null'));
      --
    END IF;
    --
    p_program_type  := l_v_program_type;
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN others THEN
      --
      p_program_type  := NULL;
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_program_type : ' || NVL(p_program_type
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END get_esn_program_type_prm_group;
  -- CR16379 End KACOSTA 03/06/2012
--
  --New procedure added for CR42361
   PROCEDURE validate_promo_code_ext
  (
   p_esn                     VARCHAR2,
   p_red_code01              VARCHAR2 DEFAULT NULL,
   p_red_code02              VARCHAR2 DEFAULT NULL,
   p_red_code03              VARCHAR2 DEFAULT NULL,
   p_red_code04              VARCHAR2 DEFAULT NULL,
   p_red_code05              VARCHAR2 DEFAULT NULL,
   p_red_code06              VARCHAR2 DEFAULT NULL,
   p_red_code07              VARCHAR2 DEFAULT NULL,
   p_red_code08              VARCHAR2 DEFAULT NULL,
   p_red_code09              VARCHAR2 DEFAULT NULL,
   p_red_code10              VARCHAR2 DEFAULT NULL,
   p_technology              VARCHAR2,
   p_transaction_amount      NUMBER,
   p_source_system           VARCHAR2,
   p_promo_code              VARCHAR2,
   p_transaction_type        VARCHAR2,
   p_zipcode                 VARCHAR2,
   p_language                VARCHAR2,
   p_fail_flag               NUMBER, --CR2739
   p_discount_amount         OUT VARCHAR2,
   p_promo_units             OUT NUMBER,
   p_sms                     OUT NUMBER,
   p_data_mb                 OUT NUMBER,
   p_applicable_device_type  OUT VARCHAR2,
   p_access_days             OUT NUMBER,
   p_status                  OUT VARCHAR2,
   p_msg                     OUT VARCHAR2
 )
  --New procedure added for CR42361
IS
/******************************************************************************/
 /* Copyright 2002 Tracfone Wireless Inc. All rights reserved */
 /* */
 /* NAME: SA.VALIDATE_PROMO_CODE */
 /* PURPOSE: To validate promocode */
 /* FREQUENCY: */
 /* PLATFORMS: Oracle 8.0.6 AND newer versions. */
 /* */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- --------------------------------------------- */
 /* 1.0 08/16/02 SL Initial Revision */
 /* */
 /* 1.1 09/16/02 SL Validate promo usage before validating */
 /* transaction type so that a nicer message */
 /* will be provided to customer. */
 /* 1.2 01/28/03 GP Added PROMOENROLLMENT when checking Transaction */
 /* parameters                                      */
   /*  1.3     05/20/03   VA     Added to pass the partnumber as a bind parameter*/
   /*                            to the dynamic sql                              */
   /*  1.4     03/31/04   VA     CR2638 - Modified to pass the correct error #   */
   /*  1.5     07/08/04   VA     CR2739 - Modified to validate promocode for     */
   /*                            redeemed cards to process ivr/web failure cases */
   /*                            p_fail_flag -> 0 for non failure cases          */
   /*                                           1 for failure cases              */
   /* 1.6      05/02/05   VA     CR3609 - Promo Validation                       */
   /* 1.7      05/03/05   VA     Fix for CR3609                          */
   /* 1.8      06/09/05   VA     CR4032 - Check for start date of the promocodes */
   /* 1.9      06/13/05   VA     Fix for a bug in CR4032 (removed TRUNC check from SYSDATE)
   /* 1.10     12/09/05   VA     CR4843 -
   /* 1.10.1.0  08/15/06  VA      CR5365
   /* 1.10.1.1  08/16/06  AB      CR5365
   /* 1.10.1.2  08/16/06  AB      CR5365
   /* 1.10.1.3      06/13/07  CI      CR6209  block promo on free airtime
   /*   1.10.1.4      06/21/07  CI      CR6209  block promo on specific free airtime card only
   /*   1.10.1.5/6/7    06/27/07  VA      Same as in CLFYSIT2
   /********************************************************************************************************************/
   /* NEW PVCS STRUCTURE */
   /* 1.0         06/02/08 IC  PE203 promo code engine project move messages to x_clarify_codes table */
   /* 1.1-1.3  07/17/08 IC  CR7331 add ability to use WEBCSR PURCHASE promo                                       */
   /********************************************************************************************************************/

   l_promo_code           VARCHAR2 (30)       := LTRIM (LTRIM (p_promo_code));
   l_sp_objid             NUMBER;
   l_promo_usage          NUMBER                := 0;
   l_promo_usage_tot      NUMBER                := 0;
   l_esn                  VARCHAR2 (30)         := LTRIM (RTRIM (p_esn));
   l_technology           VARCHAR2 (30)
                                      := UPPER (LTRIM (RTRIM (p_technology)));
   l_source_system        VARCHAR2 (30)
                                   := UPPER (LTRIM (RTRIM (p_source_system)));
   l_transaction_type     VARCHAR2 (30)
                                := UPPER (LTRIM (RTRIM (p_transaction_type)));
   l_zipcode              VARCHAR2 (5)          := LTRIM (RTRIM (p_zipcode));
   l_language             VARCHAR2 (30) := UPPER (LTRIM (RTRIM (p_language)));
   l_transaction_amount   NUMBER             := NVL (p_transaction_amount, 0);
   l_fail_flag            NUMBER                := NVL (p_fail_flag, 0);
   l_brand                VARCHAR2 (100); -- CR51519

   --CR2739
   --CR42361 : Open this vaildation for Runtime Promocodes as well.
   CURSOR c_promo
   IS
      SELECT *
        FROM TABLE_X_PROMOTION
       WHERE x_promo_code = l_promo_code
             AND (UPPER (x_promo_type) ='PROMOCODE'  -- CR20399
              OR (UPPER (x_promo_type) = 'RUNTIME' AND promotion2bus_org =268438257)); --CR42361

   rec_promo              c_promo%ROWTYPE;

   CURSOR c_esn
   IS
      SELECT *
        FROM TABLE_PART_INST
       WHERE part_serial_no = l_esn;

   rec_esn                c_esn%ROWTYPE;

   CURSOR c_site_part
   IS
      SELECT *
        FROM TABLE_SITE_PART
       WHERE (   objid = NVL (l_sp_objid, 0)
              OR (x_service_id = l_esn AND part_status || '' = 'Active')
             )
         AND ROWNUM < 2;

   rec_site_part          c_site_part%ROWTYPE;

   -- CR20399 net10 promo logic
   CURSOR c_enroll_promo (p_promo varchar2)
   IS
    select ex.*
        from  X_enroll_promo_extra ex, table_X_promotion p , table_bus_org b
        where  ex.Extra_promo_objid = p.objid
          and p.x_promo_code  = p_promo
          and p.promotion2bus_org = b.objid
          and b.org_id = 'NET10';

   rec_enroll_promo         c_enroll_promo%ROWTYPE;


   CURSOR c_zip (c_promo_objid NUMBER, c_zip VARCHAR2)
   IS
      SELECT z.*
        FROM MTM_X_PROMOTION6_X_ZIP_CODE0 MTM, TABLE_X_ZIP_CODE z
       WHERE 1 = 1
         AND MTM.x_promotion2x_zip_code = c_promo_objid
         AND z.objid = x_zip_code2x_promotion
         AND z.x_zip = c_zip;

   rec_zip                c_zip%ROWTYPE;

   CURSOR c_program_zip (c_promo_objid NUMBER, c_zip VARCHAR2)
   IS
      SELECT z.*
        FROM MTM_X_PROMOTION6_X_ZIP_CODE0 MTM, TABLE_X_ZIP_CODE z
       WHERE 1 = 1
         AND MTM.x_promotion2x_zip_code + 0 IN (
                SELECT mtm2.x_promo_mtm2x_promotion
                  FROM TABLE_X_PROMOTION_MTM mtm1, TABLE_X_PROMOTION_MTM mtm2
                 WHERE mtm1.x_promo_mtm2x_promo_group =
                                                mtm2.x_promo_mtm2x_promo_group
                   AND mtm1.x_promo_mtm2x_promotion = c_promo_objid)
         AND z.objid = MTM.x_zip_code2x_promotion
         AND z.x_zip = c_zip;

   CURSOR c_red_date
   IS
      SELECT x_red_date
        FROM TABLE_X_RED_CARD
       WHERE x_red_code = p_red_code01 AND x_result = 'Completed';

   rec_red_date           c_red_date%ROWTYPE;

   TYPE partnum_tab_type IS TABLE OF TABLE_PART_NUM.part_number%TYPE
      INDEX BY BINARY_INTEGER;

   l_partnum_tab          partnum_tab_type;

   TYPE partnum_rec_tab_type IS TABLE OF TABLE_PART_NUM%ROWTYPE
      INDEX BY BINARY_INTEGER;

   l_partnum_rec_tab      partnum_rec_tab_type;

   TYPE redcard_tab_type IS TABLE OF TABLE_PART_INST.x_red_code%TYPE
      INDEX BY BINARY_INTEGER;

   l_redcard_tab          redcard_tab_type;
   l_j                    NUMBER                := 0;
   l_sql_text             VARCHAR2 (4000);
   l_cursorid             INTEGER;
   l_bind_var             VARCHAR2 (50);
   l_rc                   INTEGER;
   l_chars                VARCHAR2 (255);
   l_redunit              NUMBER                := 0;
   l_cardtype             VARCHAR2 (30);
   l_redday               NUMBER;
   l_step                 VARCHAR2 (100);
   l_ct                   NUMBER                := 0;
   l_pm_status            VARCHAR2 (30);
   l_pm_msg               VARCHAR2 (2000);
   l_is_plsql             VARCHAR2 (1)          := 'N';
   --VAdapa 05/20/03
   l_partnum              VARCHAR2 (30);
   --End 05/20/03
   l_sp_status            VARCHAR2 (20);
--CR3609
   l_pin                  VARCHAR2 (20);                        --CR4843 Start
   l_corp_free            NUMBER:=0;  --CR6209;
   l_sms                  NUMBER:=0;  --CR42361;
   l_data                 NUMBER:=0;  --CR42361;
   v_esn_grp              NUMBER;

BEGIN
   p_discount_amount := '0';
   p_promo_units := 0;
   p_access_days := 0;
   p_status := '0';
   p_msg := NULL;

   --CR6209  if cards have 'corp free' then do not process them;
   /*select count(1) INTO l_corp_free from dual where exists
     (select pi.part_serial_no, ts.name,ts.site_type, pi.x_part_inst_status, pi.x_domain
     from table_part_inst pi, table_inv_bin ib, table_site ts
     where ts.site_id=ib.bin_name
     and ib.objid=pi.part_inst2inv_bin
     and ts.name like 'CORP FREE%'
     and pi.x_domain='REDEMPTION CARDS'
     and pi.x_red_code IN
       (p_red_code01,
        p_red_code02,
        p_red_code03,
        p_red_code04,
        p_red_code05,
        p_red_code06,
        p_red_code07,
        p_red_code08,
        p_red_code09 ));

   if l_corp_free>=1 then
     p_status := '1578';
     p_msg :=  'Invalid redemption card';
     RETURN;
   end if;  */   -- this removed on 6/21/07 and will address on card by card basis below
   --END CR6209

   -- check promo code
   IF l_promo_code IS NULL
   THEN
      p_status := '1577';
    -- CR5365 Start
    -- PE203 IC
    --  p_msg := 'You did not qualify for this promotion.';
    --  p_msg := 'Error: Promotion ' || l_promo_code || ' not valid for this phone.';
         p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
    -- CR5365 End
      RETURN;
   ELSE
      -- check 5 digits promo code
      IF l_promo_code < '00000' AND l_promo_code > '99999'
      THEN
         -- p_status := '1578';
         -- p_msg :=  'Error in input parameters. Five digits promocode required.';
         -- PE203 IC
             p_status := '1564';
             p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH');
         RETURN;
      END IF;

      -- check promo code
      OPEN c_promo;

      FETCH c_promo
       INTO rec_promo;

      IF c_promo%NOTFOUND
      THEN
         CLOSE c_promo;

         p_status := '1570';
         -- CR5365 Start
         -- p_msg := 'This promo code ' || l_promo_code || ' is not valid.';
         -- p_msg := 'Error: Promotion ' || l_promo_code || ' is not valid.';
         -- CR5365 End
         -- PE203 IC
         p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
         RETURN;
      END IF;

      CLOSE c_promo;

--CR4032 Starts
      IF SYSDATE <= rec_promo.x_start_date
      THEN
         p_status := '1570';
        --  CR5365 p_msg := 'This promo code ' || l_promo_code || ' is not valid.';
        --  p_msg := 'Error: Promotion ' || l_promo_code || ' is not valid.';
       --  PE203 IC
         p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
         RETURN;
      END IF;

--CR4032 Ends
      IF l_fail_flag = 0
      THEN
--CR2739
         IF TRUNC (SYSDATE) > rec_promo.x_end_date
         THEN
            p_status := '1571';
             -- CR5365  p_msg := 'This promo code ' || l_promo_code || ' has expired.';
            --  p_msg := 'Error: Promotion ' || l_promo_code || ' has expired.';
           --  PE203 IC
           p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
           RETURN;
         END IF;
--CR2739 Changes
      ELSIF l_fail_flag = 1
      THEN
         OPEN c_red_date;

         FETCH c_red_date
          INTO rec_red_date;

         CLOSE c_red_date;

         IF TRUNC (rec_red_date.x_red_date) > rec_promo.x_end_date
         THEN
            p_status := '1571';
           -- CR5365  p_msg := 'This promo code ' || l_promo_code || ' has expired.';
           -- p_msg := 'Error: Promotion ' || l_promo_code || ' has expired.';
           --  PE203 IC
            p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;
      END IF;
      --End CR2739 Changes
      -- check language
      IF l_language IS NULL
      THEN
         -- p_status := '1578';
         -- p_msg := 'Error in input parameters. Language required.';
         -- PE203 IC
         p_status := '1565' ;
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSIF l_language NOT IN ('ENGLISH', 'SPANISH')
      THEN
            -- p_status := '1578';
            -- p_msg := 'Error in input parameters. Language is invalid.';
            -- PE203 IC
             p_status := '1566' ;
             p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
            RETURN;
      END IF;

      -- check esn
      IF l_esn IS NULL
      THEN
       --   p_status := '1578';
       --   p_msg := 'Error in input parameters. ESN required.';
       --  PE203 IC
         p_status := '1567' ;
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSE
         OPEN c_esn;

         FETCH c_esn
          INTO rec_esn;

         IF c_esn%NOTFOUND
         THEN
            CLOSE c_esn;
            p_status := '1578';
            -- p_msg := 'Error in input parameters. ESN '  || NVL (p_esn, '<NULL>') || ' is invalid.';
            -- PE203 IC
           p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ESN', p_esn);
            RETURN;
         END IF;

         CLOSE c_esn;

         l_sp_objid := rec_esn.x_part_inst2site_part;         -- GP 01/28/2003

   -- Net10 promo logic CR20399
    OPEN c_enroll_promo(p_promo_code);
    FETCH c_enroll_promo
    INTO rec_enroll_promo;

		 --CR 42361 Exlcuded this SITE PART validation for PURCHASE and TF smartphone only
         IF (l_transaction_type NOT IN ('ACTIVATION', 'REACTIVATION', 'PROMOENROLLMENT')) and
             ( c_enroll_promo%NOTFOUND )                   -- CR20399
         THEN

            IF (l_transaction_type = 'PURCHASE'  AND sa.device_util_pkg.get_smartphone_fun(p_esn) = 0  AND rec_promo.promotion2bus_org = 268438257) THEN
              --Skip the Part number check for PURCHASE and TF smartphone only
              NULL;
            ELSE
              OPEN c_site_part;

              FETCH c_site_part
               INTO rec_site_part;

              IF c_site_part%NOTFOUND and  rec_esn.x_part_inst_status not in ('50','150')  -- CR45238_TF_Fix_Promo_Validation_WEB_TAS Tim 9/14/2016
              THEN
                 CLOSE c_site_part;
                 CLOSE c_enroll_promo;  --CR20399
                   -- p_status := '1578';
                   -- p_msg := 'Error in input parameters. ESN '  || NVL (p_esn, '<NULL>') || 'has no service record.';
                   -- PE203 IC
                  p_status := '1560';
                  p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ESN', p_esn);
                 RETURN;
               END IF;

               CLOSE c_site_part;
             END IF;
         END IF;

         CLOSE c_enroll_promo; --CR20399
      END IF;

	--allow only for tracfone
        IF sa.device_util_pkg.get_smartphone_fun(p_esn) = 0  AND rec_promo.promotion2bus_org <> 268438257 THEN                                        ----- CR 23513 TF SUREPAY PHONES ARE NOT ELIGIBLE FOR PROMOTIONS- MVadlapally
      -- /* IF device_util_pkg.get_smartphone_fun(p_esn) = 0  ANTHEN                                        ----- CR 23513 TF SUREPAY PHONES ARE NOT ELIGIBLE FOR PROMOTIONS- MVadlapally
            p_status := '1577';
            p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ESN', p_esn);
            RETURN;
        END IF;

      -- check source system
      IF l_source_system IS NULL
      THEN
--          p_status := '1578';
--          p_msg := 'Error in input parameters. Source system required.';
       --  PE203 IC
         p_status := '1568' ;
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSIF (    (UPPER (rec_promo.x_source_system) <> l_source_system  AND UPPER (rec_promo.x_source_system) <> 'ALL')
             AND  (UPPER (rec_promo.x_source_system) <> l_source_system  AND UPPER(l_source_system) <> 'CLARIFY')
             -- CR7331 1.3 IC added clarify source system for webcsr purchase promos
            )
      THEN

--       DBMS_OUTPUT.PUT_LINE('UPPER (rec_promo.x_source_system = ' || UPPER (rec_promo.x_source_system));
--       DBMS_OUTPUT.PUT_LINE('l_source_system = ' || l_source_system);
--       DBMS_OUTPUT.PUT_LINE('UPPER(l_source_system)= ' || UPPER(l_source_system));


         p_status := '1575';
--CR5365 Start
--          p_msg :=
--                'This promo code '
--             || l_promo_code
--             || ' is not available on '
--             || l_source_system;
--          p_msg :=
--                'Error: Promotion '
--             || l_promo_code
--             || ' is not available on '
--             || l_source_system;
--CR5365 End
        -- PE203 IC
         p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_SOURCE_SYSTEM', l_source_system);
         p_msg := REPLACE(p_msg, '__L_PROMO_CODE', l_promo_code);
         RETURN;
      END IF;

      -- check usage
      -- 1.1 validate promo usage before validating transaction type
      --
      IF (    UPPER (rec_promo.x_transaction_type) <> 'PROGRAM'
          AND NVL (rec_promo.x_usage, 0) <> 99
         )
      THEN
         IF l_transaction_type = 'PURCHASE'
         THEN
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PURCH_HDR purh, TABLE_X_DISCOUNT_HIST disc
             WHERE purh.x_ics_rflag IN ('ACCEPT','SOK')
               AND disc.x_disc_hist2x_purch_hdr = purh.objid
               AND disc.x_esn = rec_esn.part_serial_no
               AND disc.x_disc_hist2x_promo = rec_promo.objid;
         ELSE
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PROMO_HIST PH, TABLE_X_CALL_TRANS ct
             WHERE rec_promo.objid = PH.promo_hist2x_promotion + 0
               AND ct.objid = PH.promo_hist2x_call_trans
               AND ct.call_trans2site_part = rec_esn.x_part_inst2site_part;
         END IF;

         l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;
         l_promo_usage := 0;

--CR3609 Starts
         BEGIN
            SELECT part_status
              INTO l_sp_status
              FROM TABLE_SITE_PART
             WHERE objid = rec_esn.x_part_inst2site_part;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_sp_status := NULL;
         END;

         IF NVL (l_sp_status, 'zzz') <> 'Obsolete'
         THEN
            --CR3609 Ends
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PENDING_REDEMPTION
             WHERE x_pend_red2site_part = rec_esn.x_part_inst2site_part
               AND pend_red2x_promotion = rec_promo.objid;
         --CR3609 starts
         ELSE
            DELETE FROM TABLE_X_PENDING_REDEMPTION
                  WHERE x_pend_red2site_part = rec_esn.x_part_inst2site_part;

            COMMIT;
         END IF;

         --CR3609 Ends
         l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;
         IF NVL (l_promo_usage_tot, 0) >= NVL (rec_promo.x_usage, 0)
         THEN
            p_status := '1573';
--CR5365 Start
--             p_msg :=
--                   'This promo_code '
--                || l_promo_code
--                || ' has already been used '
--                || l_promo_usage_tot
--                || ' time(s).';
--CR5365 End
--            p_msg := 'Error: Promotion '
--            || l_promo_code  || ' already used ';
         -- PE203 IC
            p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;
      END IF;

      -- Check transaction parameters
      IF (l_transaction_type IS NULL)
      THEN
                 --  PE203 IC
                 --  p_status := '1578';
                 --  p_msg := 'Error in input parameters. Transaction type is required';
                     p_status := '1569' ;
                     p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
                    RETURN;
      ELSIF l_transaction_type NOT IN  ('ACTIVATION', 'REACTIVATION',
                   'REDEMPTION',  'PURCHASE', 'PROMOENROLLMENT'
              )                                               -- GP 01/28/2003
      THEN
             -- PE203 IC
             -- p_status := '1578';
             -- p_msg := 'Error in input parameters. Transaction type '  || l_transaction_type  || ' is invalid';
           p_status := '1563';
           p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_TRANSACTION_TYPE', l_transaction_type);
         RETURN;
      ELSIF (l_transaction_type = 'PURCHASE' AND l_transaction_amount = 0)
      THEN
              --  PE203 IC
              --   p_status := '1578';
              --   p_msg := 'Error in input parameters. Transaction amount can not be 0'
              --   || ' when transaction type is PURCHASE.';
             p_status := '1572';
             p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
             RETURN;
      ELSIF (l_transaction_type <> 'PURCHASE' AND l_transaction_amount > 0)
      THEN
              -- PE203 IC
              -- p_status := '1578';
              --  p_msg :=  'Error in input parameters. Transaction amount should be 0'
              --                      || ' when transaction type is not PURCHASE.';
             p_status := '1588';
             p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      END IF;

      --CR42361: Treat the Activation as Reactivation for Tracfone SMARTPHONE only.
      IF UPPER (rec_promo.x_transaction_type) = 'REACTIVATION'
         AND l_transaction_type = 'ACTIVATION'
         AND rec_promo.promotion2bus_org = 268438257
         AND sa.device_util_pkg.get_smartphone_fun(p_esn) = 0
      THEN
        l_transaction_type := 'REACTIVATION';
      END IF;
      -- Added source system APP as well as part of CR57150
	  SELECT CASE WHEN l_source_system IN ('WEB','APP') THEN sa.util_pkg.get_bus_org_id(l_esn)
	         ELSE
			 'XXX'
			 END
		INTO l_brand
		FROM dual; --CR57150
	  /*SELECT DECODE(l_source_system,'WEB',sa.util_pkg.get_bus_org_id(l_esn),'XXX')
	    INTO l_brand
		FROM dual;*/ --CR51519
	  -- Determine Potential Transactions - Clarify remains the same
      IF UPPER (rec_promo.x_transaction_type) NOT IN ('ALL', 'PROGRAM')
      THEN
         -- CR21961 VAS_APP
         -- IF l_source_system = 'WEB'
         IF l_source_system = 'WEB' or l_source_system = 'APP'
         THEN
            IF (    UPPER (rec_promo.x_transaction_type) = 'ACTIVATION'
                AND l_transaction_type NOT IN ('ACTIVATION')
               )
            THEN
                 -- CR5365  p_msg := 'This is an activation promo code.';
                 p_status := '1580';
                -- PE203 IC
                -- p_msg := 'Error: Promotion ' || l_promo_code || ' is an activation promo code.';
                p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REACTIVATION'
                   AND l_transaction_type NOT IN ('REACTIVATION', 'PURCHASE')
                  )
            THEN
               p_status := '1579';
               --CR5365   p_msg := 'This is reactivation promo code.';
               -- PE203 IC
               -- p_msg :=  'Error: Promotion ' || l_promo_code  || ' is an reactivation promo code.';
                p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'PURCHASE'
                   AND l_transaction_type NOT IN ('REACTIVATION', 'PURCHASE')
				   AND l_brand <> 'TRACFONE' --CR51519 skipping validation for tracfone only for WEB
                  )
            THEN
                    --  03/31/04 Changes p_status := '1579';
                    p_status := '1581';
                   --  CR5365  p_msg := 'This is a purchase promo code.';
                   --  PE203 IC
                   --  p_msg := 'Error: Promotion ' || l_promo_code  || ' is an purchase promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            END IF;
         ELSIF l_source_system = 'IVR'
         THEN
            IF (    UPPER (rec_promo.x_transaction_type) = 'ACTIVATION'
                AND l_transaction_type NOT IN ('ACTIVATION')
               )
            THEN
                  p_status := '1580';
                  -- PE203 IC
                  --  p_msg := 'Error: Promotion ' || l_promo_code  || ' is an activation promo code.';
                  --  CR5365  p_msg := 'This is an activation promo code.';
                  p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REACTIVATION'
                   AND l_transaction_type NOT IN ('REACTIVATION')
                  )
            THEN
               p_status := '1579';
               --  CR5365  p_msg := 'This is reactivation promo code.';
               --  PE203 IC
               -- p_msg := 'Error: Promotion ' || l_promo_code  || ' is an reactivation promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
                   RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'PURCHASE'
                   AND l_transaction_type NOT IN ('PURCHASE')
                  )
            THEN
                   -- 1.1 purchase should only accept purchase promocode
                   p_status := '1581';
                   --  CR5365   p_msg := 'This is a purchase promo code.';
                   --  PE203 IC
                   --  p_msg := 'Error: Promotion ' || l_promo_code   || ' is an purchase promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
                  RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REDEMPTION'
                   AND l_transaction_type NOT IN
                                               ('REDEMPTION', 'REACTIVATION')
                  )
            THEN
                 -- 1.1 reactivation should take reactivations and redmeption promocode
                 p_status := '1576';
                 -- CR5365  p_msg := 'This is a redemption promo code.';
                 -- PE203 IC
                 -- p_msg := 'Error: Promotion '  || l_promo_code || ' is an redemption promo code.';
                     p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
                     RETURN;
            END IF;
         ELSE
            IF (    UPPER (rec_promo.x_transaction_type) = 'ACTIVATION'
                AND l_transaction_type NOT IN ('ACTIVATION')
               )
            THEN
               p_status := '1580';
               --  CR5365    p_msg := 'This is a activation promo code.';
               -- PE203 IC
               -- p_msg := 'Error: Promotion ' || l_promo_code   || ' is an activation promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REACTIVATION'
                   AND l_transaction_type NOT IN ('REACTIVATION')
                  )
            THEN
               p_status := '1579';
               -- CR5365  p_msg := 'This is a reactivation promo code.';
               -- PE203 IC
               -- p_msg :='Error: Promotion ' || l_promo_code || ' is an reactivation promo code.';
               p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'PURCHASE'
                   AND l_transaction_type NOT IN ('PURCHASE')
                  )
            THEN
               p_status := '1581';
               -- CR5365 p_msg := 'This is a purchase promo code.';
               -- PE203 IC
               -- p_msg :=  'Error: Promotion ' || l_promo_code || ' is an purchase promo code.';
               p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REDEMPTION'
                   AND l_transaction_type NOT IN ('REDEMPTION')
                  )
            THEN
               p_status := '1576';
               --  CR5365 p_msg := 'This is a redemption promo code.';
               -- PE203 IC
               -- p_msg := 'Error: Promotion ' || l_promo_code  || ' is an redemption promo code.';
               p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            END IF;
         END IF;

         IF (    (   l_transaction_type = 'REDEMPTION'
                  OR UPPER (rec_promo.x_transaction_type) = 'REDEMPTION'
                 )
             AND p_red_code01 IS NULL
            )
         THEN
                p_status := '1587';
                -- CR5365    p_msg := 'This promotion requires pin.';
                -- PE203 IC
                --  p_msg := 'Error: Promotion ' || l_promo_code || ' requires pin.';
                p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;
      ELSIF UPPER (rec_promo.x_transaction_type) IN ('PROGRAM')
      THEN
         SELECT COUNT (1)
           INTO l_promo_usage
           FROM TABLE_X_PENDING_REDEMPTION
          WHERE x_pend_red2site_part = rec_esn.x_part_inst2site_part
            AND pend_red2x_promotion = rec_promo.objid;

         IF l_promo_usage > 0
         THEN
            p_status := '1584';
           -- CR5365 End p_msg := 'This promotion is already pending.';
            -- PE203 IC
            -- p_msg := 'Error: Promotion ' || l_promo_code || ' is already pending.';
              p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;

         l_promo_usage_tot := 0;

         SELECT COUNT (1)
           INTO l_promo_usage
           FROM TABLE_X_PROMOTION_MTM MTM, TABLE_X_GROUP2ESN ge
          WHERE MTM.x_promo_mtm2x_promotion = rec_promo.objid
            AND ge.groupesn2x_promo_group + 0 = MTM.x_promo_mtm2x_promo_group
            AND ge.groupesn2part_inst = rec_esn.objid;

         l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;

         IF l_promo_usage_tot = 0
         THEN
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PROMO_HIST PH, TABLE_X_CALL_TRANS ct
             WHERE PH.promo_hist2x_promotion + 0 IN (
                      SELECT mtm2.x_promo_mtm2x_promotion
                        FROM TABLE_X_PROMOTION_MTM mtm1,
                             TABLE_X_PROMOTION_MTM mtm2
                       WHERE mtm1.x_promo_mtm2x_promo_group =
                                                mtm2.x_promo_mtm2x_promo_group
                         AND mtm1.x_promo_mtm2x_promotion = rec_promo.objid)
               AND ct.objid = PH.promo_hist2x_call_trans
               AND ct.call_trans2site_part = rec_esn.x_part_inst2site_part;

            l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;
         END IF;

         IF l_promo_usage_tot > 0
         THEN
              p_status := '1585';
              -- CR5365  p_msg := 'You are already a member. ';
              -- PE203 IC
              -- p_msg := '    Error : You are already a member. ';
              p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
            RETURN;
         END IF;
      END IF;

      -- check technology
      IF l_technology IS NULL
      THEN
        --  p_status := '1578';
        --  p_msg := 'Error in input parameters. Technology required.';
        --  PE203 IC
         p_status := '1589';
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSIF (    UPPER (rec_promo.x_promo_technology) <> l_technology
             AND UPPER (rec_promo.x_promo_technology) <> 'ALL'
            )
      THEN
           p_status := '1574';
           --  CR5365 p_msg := 'This promo code ' || l_promo_code || ' is not available for '  || l_technology;
           -- PE203 IC
           -- p_msg := 'Error: Promotion '|| l_promo_code || ' is not available for ' || l_technology;
           p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            p_msg := REPLACE(p_msg, '__L_TECHNOLOGY', l_technology);
         RETURN;
      END IF;

      -- check zip
      IF NVL (rec_promo.x_zip_required, 0) = 1
      THEN
         -- zip is required for this promotion
         OPEN c_zip (rec_promo.objid, p_zipcode);

         FETCH c_zip
          INTO rec_zip;

         IF c_zip%NOTFOUND
         THEN
            p_status := '1582';
            -- PE203 IC
            -- p_msg := 'Zip code ' || p_zipcode || ' is not part of this promotion. ';
             p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ZIPCODE', p_zipcode);
            RETURN;
         END IF;
      END IF;

      --CR42361:  Group Runtime Validation check. (only for Tracfone and Smartphone)
      IF rec_promo.x_group_name_filter IS NOT NULL
          AND UPPER(rec_promo.x_promo_type) = 'RUNTIME'
          AND sa.device_util_pkg.get_smartphone_fun(p_esn) = 0
          AND rec_promo.promotion2bus_org = 268438257
      THEN

          SELECT Count(1)
            INTO v_esn_grp
            FROM TABLE_X_PROMOTION_GROUP pg,
                TABLE_X_GROUP2ESN ge,
                TABLE_PART_INST pi
            WHERE 1 = 1
            AND ge.groupesn2x_promo_group = pg.objid
            AND ge.groupesn2part_inst = pi.objid
            AND pi.part_serial_no = p_esn
            AND pg.group_name = rec_promo.x_group_name_filter
            AND (SYSDATE BETWEEN pg.x_start_date AND pg.x_end_date
                  OR pg.x_end_date IS NULL);

          IF v_esn_grp <= 0 THEN
            p_msg := l_promo_code || ' is an Runtime Group promotion.  Either it is not Valid OR the ESN ' || p_esn || ' is not part of this group.';
            RETURN;
          END IF;
      END IF;

      -- get input red code/part number
      IF l_transaction_type = 'PURCHASE'
      THEN
         l_partnum_tab (0) := p_red_code01;
         l_partnum_tab (1) := p_red_code02;
         l_partnum_tab (2) := p_red_code03;
         l_partnum_tab (3) := p_red_code04;
         l_partnum_tab (4) := p_red_code05;
         l_partnum_tab (5) := p_red_code06;
         l_partnum_tab (6) := p_red_code07;
         l_partnum_tab (7) := p_red_code08;
         l_partnum_tab (8) := p_red_code09;
         l_partnum_tab (9) := p_red_code10;

         FOR i IN 0 .. 9
         LOOP
            --dbms_output.put_line('PN='||l_partnum_tab (i));
            IF l_partnum_tab (i) IS NOT NULL
            THEN
               BEGIN
                  SELECT pn.*
                    INTO l_partnum_rec_tab (i)
                    FROM TABLE_PART_NUM pn
                   WHERE pn.domain in  ('REDEMPTION CARDS','BILLING PROGRAM') --CR20399
                     AND part_number = l_partnum_tab (i);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     --  p_status := '1578';
                     --  p_msg := 'Error in input parameters. Invalid part number: ' || l_partnum_tab (i);
                      -- PE203 IC
                      p_status := '1562';
                      p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PARTNUM_TAB', l_partnum_tab (i));
                     RETURN;
               END;
            ELSE
               l_partnum_rec_tab (i) := NULL;
            END IF;
         END LOOP;
      ELSE
         l_redcard_tab (0) := p_red_code01;
         l_redcard_tab (1) := p_red_code02;
         l_redcard_tab (2) := p_red_code03;
         l_redcard_tab (3) := p_red_code04;
         l_redcard_tab (4) := p_red_code05;
         l_redcard_tab (5) := p_red_code06;
         l_redcard_tab (6) := p_red_code07;
         l_redcard_tab (7) := p_red_code08;
         l_redcard_tab (8) := p_red_code09;
         l_redcard_tab (9) := p_red_code10;
         l_j := 0;

         FOR i IN 0 .. 9
         LOOP
             --dbms_output.put_line('RC='||l_redcard_tab (i));
            IF l_fail_flag = 0                                       --CR2739
            THEN
               IF l_redcard_tab (i) IS NOT NULL
               THEN
                  BEGIN
                     SELECT pn.*
                       INTO l_partnum_rec_tab (i)
                       FROM TABLE_PART_NUM pn,
                            TABLE_MOD_LEVEL ml,
                            TABLE_PART_INST pi
                      WHERE 1 = 1
                        AND ml.part_info2part_num = pn.objid
                        AND n_part_inst2part_mod = ml.objid
                        AND x_domain || '' = 'REDEMPTION CARDS'
                        AND x_red_code = l_redcard_tab (i);


                        --CR6209
                        SELECT COUNT(1) INTO l_corp_free FROM dual WHERE EXISTS
                         (SELECT pi.part_serial_no, ts.name,ts.site_type, pi.x_part_inst_status, pi.x_domain
                          FROM TABLE_PART_INST pi, TABLE_INV_BIN ib, TABLE_SITE ts
                          WHERE ts.site_id=ib.bin_name
                          AND ib.objid=pi.part_inst2inv_bin
                          AND ts.name LIKE 'CORP FREE%' AND ts.TYPE=3
                          AND pi.x_domain='REDEMPTION CARDS'
                          AND pi.x_red_code =l_redcard_tab (i));

                          IF l_corp_free=1 THEN
                            l_partnum_rec_tab(i):=NULL;
                            l_redcard_tab (i):=NULL;
                          END IF;
                          --end CR6209

                  EXCEPTION
                     WHEN OTHERS
                     THEN
                          --  PE203 IC
                          --  p_status := '1578';
                          --  p_msg :=  'Invalid redemption card: '  || l_redcard_tab (i)  || ' ' || SQLERRM;
                          p_status := '1561';
                          p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_REDCARD_TAB', l_redcard_tab (i));
                          p_msg :=  REPLACE(p_msg, '__SQLERRM', SQLERRM);

                        RETURN;
                  END;
               ELSE
                  l_partnum_rec_tab (i) := NULL;
               END IF;
--CR2739 Changes
            ELSIF l_fail_flag = 1
            THEN
               IF l_redcard_tab (i) IS NOT NULL
               THEN
                  BEGIN
                     SELECT pn.*
                       INTO l_partnum_rec_tab (i)
                       FROM TABLE_PART_NUM pn,
                            TABLE_MOD_LEVEL ml,
                            TABLE_X_RED_CARD rc
                      WHERE 1 = 1
                        AND ml.part_info2part_num = pn.objid
                        AND rc.x_red_card2part_mod = ml.objid
                        AND rc.x_result = 'Completed'
                        AND rc.x_red_code = l_redcard_tab (i);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                          -- PE203 IC
                           --   p_status := '1578';
                           --    p_msg := 'Invalid redemption card: ' || l_redcard_tab (i)   || ' '  || SQLERRM;
                           p_status := '1561';
                           p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_REDCARD_TAB', l_redcard_tab (i));
                           p_msg :=  REPLACE(p_msg, '__SQLERRM', SQLERRM);
                     RETURN;
                  END;
               ELSE
                  l_partnum_rec_tab (i) := NULL;
               END IF;
            END IF;
--End CR2739 Changes
         END LOOP;
      END IF;

      l_sql_text := rec_promo.x_sql_statement;
      l_j := 0;

      IF l_sql_text IS NOT NULL
      THEN
         l_cursorid := DBMS_SQL.open_cursor;

         BEGIN
            l_step := 'parse sql';
            DBMS_SQL.parse (l_cursorid, l_sql_text, DBMS_SQL.v7);
            l_bind_var := ' :esn ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       p_esn
                                      );
            END IF;

            l_step := 'bind source';
            l_bind_var := ' :source ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_source_system
                                      );
            END IF;

            l_step := 'bind zip';
            l_bind_var := ' :zip ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       p_zipcode
                                      );
            END IF;

            l_step := 'bind total transaction amount';
            l_bind_var := ' :tot_trans ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_transaction_amount
                                      );
            END IF;

            l_step := 'bind promo start date';
            l_bind_var := ' :promo_start_date ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       rec_promo.x_start_date
                                      );
            END IF;

            l_step := 'bind esn status';
            l_bind_var := ' :pi_status ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       rec_esn.x_part_inst_status
                                      );
            END IF;

            l_step := 'bind return status';
            l_bind_var := ' :pm_status ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_pm_status,
                                       30
                                      );
               l_is_plsql := 'Y';
            END IF;

            l_step := 'bind return status';
            l_bind_var := ' :pm_msg ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_pm_msg,
                                       2000
                                      );
               l_is_plsql := 'Y';
            END IF;

            IF sa.device_util_pkg.get_smartphone_fun(p_esn) = 0  AND rec_promo.promotion2bus_org = 268438257
                AND UPPER(rec_promo.x_promo_type) = 'RUNTIME'
            THEN
                l_step := 'bind Units for Runtime';
                l_bind_var := ' :units ';

                IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
                THEN
                   DBMS_SQL.bind_variable (l_cursorid,
                                           RTRIM (LTRIM (l_bind_var)),
                                           NVL (l_partnum_rec_tab (0).x_redeem_units, 0)
                                          );
                END IF;

                 l_step := 'bind Days for Runtime';
                l_bind_var := ' :access_days ';

                IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
                THEN
                   DBMS_SQL.bind_variable (l_cursorid,
                                           RTRIM (LTRIM (l_bind_var)),
                                           NVL (l_partnum_rec_tab (0).x_redeem_days, 0)
                                          );
                END IF;
            END IF;

            FOR i IN 0 .. 9
            LOOP
               l_bind_var := ' :units' || LTRIM (TO_CHAR (i, '09')) || ' ';
               l_step := 'bind ' || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  IF NVL (l_partnum_rec_tab (i).part_type, 'FREE') = 'PAID'
                  THEN
                     --CR42361: Avoid using the Redeem Units value for TRACFONE and SMARTPHONE and (DATA CARD OR TEXT ONLY)
                     IF sa.device_util_pkg.get_smartphone_fun(p_esn) = 0  AND rec_promo.promotion2bus_org = 268438257
                        AND l_partnum_rec_tab (i).x_card_type IN ('DATA CARD','TEXT ONLY')
                     THEN
                        l_redunit := 0;
                     ELSE
                       l_redunit :=
                                  NVL (l_partnum_rec_tab (i).x_redeem_units, 0);
                     END IF;
                  ELSE
                     l_redunit := 0;
                  END IF;

                  l_step :=
                     'bind unit: ' || l_redunit || ' l_bind_var: '
                     || l_bind_var;
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_redunit
                                         );
               END IF;

               l_step := 'bind cardtype';
               l_bind_var := ' :cardtype' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_cardtype := l_partnum_rec_tab (i).x_card_type;
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_cardtype
                                         );
               END IF;

               l_step := 'bind days';
               l_bind_var := ' :days' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_redday := NVL (l_partnum_rec_tab (i).x_redeem_days, 0);
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_redday
                                         );
               END IF;

               --VAdapa 05/20/03
               l_step := 'bind partnum';
               l_bind_var := ' :part' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_partnum := l_partnum_rec_tab (i).part_number;
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_partnum
                                         );
               END IF;

--End 05/20/03
--CR4843 Start
               l_step := 'bind pin';
               l_bind_var := ' :pin' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_pin := l_redcard_tab (i);
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_pin
                                         );
               END IF;

--CR4843 End

             -- CR42361 : Start : Mgovindarajan /Vnainar : 9/15/2016
             -- Bind SMS and data,   Use the X_redeem_units from part_num table if the Surepay_conv details not available.

               IF l_partnum_rec_tab (i).x_card_type IN ('DATA CARD','TEXT ONLY') THEN

                  l_step := 'datacard/text only : bind sms_data';
                  BEGIN
                    SELECT spv.sms, spv.data
                      INTO l_sms, l_data
                     FROM table_part_class pc,
                         table_part_num pn,
                         adfcrm_serv_plan_class_matview spcm,
                         service_plan_feat_pivot_mv spv
                     WHERE pc.objid = pn.part_num2part_class
                        AND pn.domain = 'REDEMPTION CARDS'
                        AND spcm.part_class_objid = pn.part_num2part_class
                        AND spcm.sp_objid= spv.service_plan_objid
                        And pn.part_number = l_partnum_rec_tab (i).part_number;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        l_sms  := NULL;
                        l_data := NULL;
                      WHEN OTHERS THEN
                        p_status := '1590';
                        p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_STEP', l_step);
                        RETURN;
                    END;

               ELSE

                  BEGIN
                     SELECT unit_text, unit_data
                        INTO l_sms, l_data
                      FROM x_surepay_conv
                     WHERE active_flag = 'Y'
                      AND X_PART_NUMBER = l_partnum_rec_tab (i).part_number;
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        l_sms  := NULL;
                        l_data := NULL;
                     WHEN OTHERS THEN
                         p_status := '1590';
                         p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_STEP', l_step);
                         RETURN;
                  END;

               END IF;

               l_step := 'bind sms';
               l_bind_var := ' :sms' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN

                 DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          NVL (l_sms, nvl(l_partnum_rec_tab (i).x_redeem_units,0))
                                         );
               END IF;

               l_step := 'bind data';
               l_bind_var := ' :data' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN

                 DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                           NVL (l_data, nvl(l_partnum_rec_tab (i).x_redeem_units,0))
                                         );
               END IF;
            -- CR42361 : End

            END LOOP;
	     dbms_output.put_line (' sql '||l_sql_text);
         EXCEPTION
            WHEN OTHERS
            THEN
                -- PE203 IC
                --  p_status := '1583';
                --  p_msg := 'Unexpected error when preparing SQL. ' || l_step;
               p_status := '1590';
               p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_STEP', l_step);
               RETURN;
         END;

         l_step := '';

         IF l_is_plsql = 'N'
         THEN
            l_step := 'define column';
            DBMS_SQL.define_column (l_cursorid, 1, l_chars, 10);
         END IF;

        -- dbms_output.put_line (' cursor '||l_cursorid);
         l_step := 'execute cursor';
         l_rc := DBMS_SQL.EXECUTE (l_cursorid);
         l_step := 'execute done';
         l_j := 0;

         IF l_is_plsql = 'N'
         THEN
            LOOP
               IF (DBMS_SQL.fetch_rows (l_cursorid) = 0 OR l_j > 0)
               THEN
                  EXIT;
               END IF;

               DBMS_SQL.column_value (l_cursorid, 1, l_chars);
               l_j := l_j + 1;
            END LOOP;
         ELSE
            l_step := 'get value status';
            DBMS_SQL.variable_value (l_cursorid, ':pm_status', l_pm_status);
            l_step := 'get value message';
            DBMS_SQL.variable_value (l_cursorid, ':pm_msg', l_pm_msg);

            IF l_pm_status = '0'
            THEN
               l_j := l_j + 1;
            ELSE
               p_status := l_pm_status;
               p_msg := l_pm_msg;
               DBMS_SQL.close_cursor (l_cursorid);
               RETURN;
            END IF;
         END IF;

         DBMS_SQL.close_cursor (l_cursorid);
      ELSE
         --
         -- if no sql defined. it will be qualified
         --
         l_j := 1;
      END IF;

      --
      -- calculation discount amount
      --
      IF l_j > 0
      THEN
         p_promo_units := NVL (rec_promo.x_units, 0);
         p_access_days := NVL (rec_promo.x_access_days, 0);

         IF l_transaction_type in ('PURCHASE', 'BPEnrollment', 'Promocode')
         THEN
            IF NVL (rec_promo.x_discount_amount, 0) > 0
            THEN
               p_discount_amount := TO_CHAR (rec_promo.x_discount_amount);
            ELSIF NVL (rec_promo.x_discount_percent, 0) > 0
            THEN
               p_discount_amount :=
                  TO_CHAR (  rec_promo.x_discount_percent
                           / 100
                           * l_transaction_amount
                          );
            END IF;

            IF l_transaction_amount <= p_discount_amount
            THEN
               p_status := '1586';
               -- PE203 IC
               -- p_msg := 'Discount amount exceeds or equals transaction amount';
               p_msg :=  Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH');
               RETURN;
            END IF;
         END IF;

          p_status := '0';
          p_applicable_device_type := rec_promo.x_device_type;

        -- IF device_util_pkg.get_smartphone_fun(p_esn) = 0 THEN
          p_sms :=rec_promo.x_sms;
          p_data_mb:=rec_promo.x_data_mb;
        -- END IF;

         IF l_language <> 'SPANISH'
         THEN
            p_msg := rec_promo.x_promotion_text;
         ELSE
            p_msg := rec_promo.x_spanish_promo_text;
         END IF;

         RETURN;
      ELSE
         p_status := '1577';
         --  CR5365    p_msg := 'You did not qualify for this promotion.';
         -- PE203 IC
         -- p_msg := 'Error: Promotion ' || l_promo_code || ' not valid for this phone.';
         p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
         RETURN;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      p_status := '1583';
      -- PE203 IC
      -- p_msg := 'Unexpected error: ' || SQLERRM;
         p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__SQLERRM', SQLERRM);

END validate_promo_code_ext;

-- new procedure added for CR42361

--CR44459  Starts
--Procedure to out promo ref cursor based on brand
PROCEDURE get_purchase_promos
                             (
                             i_brand       IN  VARCHAR2,
                             o_purchpromos OUT SYS_REFCURSOR,
                             o_error_code  OUT VARCHAR2,
                             o_error_msg   OUT VARCHAR2
                             )
IS
BEGIN --{

 o_error_code := '0';
 o_error_msg  := '';

 OPEN o_purchpromos FOR
 SELECT NULL PART_NUMBER,   -- Part Number
        NULL QUANTITY,      -- Quantity
        NULL DISCOUNT,      -- Discount amt
        NULL PROMO_CODE,    -- Promo Code
        NULL BRAND          -- Brand
 FROM DUAL;

 OPEN o_purchpromos FOR
 SELECT  pn.part_number         PART_NUMBER,
         po.quantity            QUANTITY,
         pro.x_discount_amount  DISCOUNT,
         pro.x_promo_code       PROMO_CODE,
         bo.org_id              BRAND,
         pr.x_script_id         PROMO_SCRIPT_ID
 FROM    sa.table_part_num      pn,
         sa.table_bus_org       bo,
         sa.x_purchase_offers   po,
         sa.table_x_promotion   pro,
         sa.x_enroll_promo_rule pr
 WHERE   pn.part_num2bus_org = bo.objid
 AND     UPPER(org_id)       = UPPER(i_brand)
 AND     pn.part_number      = po.part_number
 AND     pro.objid           = po.purch2promo
 AND     TRUNC(SYSDATE) BETWEEN pro.x_start_date AND pro.x_end_date
 AND     pr.promo_objid      = pro.objid
 ORDER   BY pr.x_priority;

 DBMS_OUTPUT.PUT_LINE('get_purchase_promos i_brand='||i_brand);

EXCEPTION
 WHEN OTHERS THEN
   o_error_code := '100';
   o_error_msg  := 'Error in get_purchase_promos due to '||sqlerrm;
   DBMS_OUTPUT.PUT_LINE('get_purchase_promos exception '||sqlerrm);
END get_purchase_promos; --}

FUNCTION sf_promo_check
(
 i_promo_objid   IN  VARCHAR2,
 i_param1        IN  VARCHAR2 DEFAULT NULL,
 i_param1_value  IN  VARCHAR2 DEFAULT NULL,
 i_param2        IN  VARCHAR2 DEFAULT NULL,
 i_param2_value  IN  VARCHAR2 DEFAULT NULL,
 i_param3        IN  VARCHAR2 DEFAULT NULL,
 i_param3_value  IN  VARCHAR2 DEFAULT NULL,
 i_param4        IN  VARCHAR2 DEFAULT NULL,
 i_param4_value  IN  VARCHAR2 DEFAULT NULL,
 i_param5        IN  VARCHAR2 DEFAULT NULL,
 i_param5_value  IN  VARCHAR2 DEFAULT NULL,
 i_param6        IN  VARCHAR2 DEFAULT NULL,
 i_param6_value  IN  VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
IS
 CURSOR cur_promo_detail
 IS
 SELECT *
 FROM   table_x_promotion
 WHERE  objid = i_promo_objid;

	rec_promo_detail cur_promo_detail%ROWTYPE;
 v_sql_statement  VARCHAR2(4000);
 v_cursor         INTEGER;
 v_result_cursor  INTEGER;
 v_bind_var       VARCHAR2(200);
 v_counter        VARCHAR2(200);

BEGIN --{

 DBMS_OUTPUT.PUT_LINE('sf_promo_check start...');
 DBMS_OUTPUT.PUT_LINE('i_promo_objid='||i_promo_objid);
 DBMS_OUTPUT.PUT_LINE('i_param1='||i_param1||' i_param1_value='||i_param1_value);
 DBMS_OUTPUT.PUT_LINE('i_param2='||i_param2||' i_param2_value='||i_param2_value);
 DBMS_OUTPUT.PUT_LINE('i_param3='||i_param3||' i_param3_value='||i_param3_value);
 DBMS_OUTPUT.PUT_LINE('i_param4='||i_param4||' i_param4_value='||i_param4_value);
 DBMS_OUTPUT.PUT_LINE('i_param5='||i_param5||' i_param5_value='||i_param5_value);
 DBMS_OUTPUT.PUT_LINE('i_param6='||i_param6||' i_param6_value='||i_param6_value);

 OPEN  cur_promo_detail;

 FETCH cur_promo_detail
 INTO  rec_promo_detail;

 CLOSE cur_promo_detail;

		IF rec_promo_detail.x_sql_statement IS NOT NULL
  THEN --{
   v_sql_statement := rec_promo_detail.x_sql_statement;
   v_cursor        := dbms_sql.open_cursor;
   dbms_sql.parse(v_cursor, v_sql_statement, dbms_sql.v7);

   v_bind_var := i_param1;
   IF NVL(INSTR(v_sql_statement, v_bind_var) ,0) > 0 AND v_bind_var IS NOT NULL THEN
   dbms_sql.bind_variable(v_cursor, v_bind_var, i_param1_value);
   END IF;

   v_bind_var := i_param2;
   IF NVL(INSTR(v_sql_statement, v_bind_var) ,0) > 0 AND v_bind_var IS NOT NULL THEN
   dbms_sql.bind_variable(v_cursor, v_bind_var, i_param2_value);
   END IF;

   v_bind_var := i_param3;
   IF NVL(INSTR(v_sql_statement, v_bind_var) ,0) > 0 AND v_bind_var IS NOT NULL THEN
   dbms_sql.bind_variable(v_cursor, v_bind_var, i_param3_value);
   END IF;

   v_bind_var := i_param4;
   IF NVL(INSTR(v_sql_statement, v_bind_var) ,0) > 0 AND v_bind_var IS NOT NULL THEN
   dbms_sql.bind_variable(v_cursor, v_bind_var, i_param4_value);
   END IF;

   v_bind_var := i_param5;
   IF NVL(INSTR(v_sql_statement, v_bind_var) ,0) > 0 AND v_bind_var IS NOT NULL THEN
   dbms_sql.bind_variable(v_cursor, v_bind_var, i_param5_value);
   END IF;

   v_bind_var := i_param6;
   IF NVL(INSTR(v_sql_statement, v_bind_var) ,0) > 0 AND v_bind_var IS NOT NULL THEN
   dbms_sql.bind_variable(v_cursor, v_bind_var, i_param6_value);
   END IF;

		dbms_sql.define_column(v_cursor, 1, v_counter, 10);
		v_result_cursor := dbms_sql.execute(v_cursor);

		IF NVL(dbms_sql.fetch_rows(v_cursor) ,0) > 0 THEN
		dbms_sql.column_value(v_cursor, 1, v_counter);
		END IF;
		dbms_sql.close_cursor(v_cursor);

  END IF; --}

 DBMS_OUTPUT.PUT_LINE('sf_promo_check end v_counter='||v_counter);

  IF TO_NUMBER(v_counter) > 0 THEN
   RETURN 1;
  ELSE
   RETURN 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  IF  dbms_sql.is_open (v_cursor)
  THEN
    dbms_sql.close_cursor(v_cursor);
  END IF;
  --
  RETURN 0;
END sf_promo_check; --}

PROCEDURE get_eligible_promo
(
 i_promo_type  IN  VARCHAR2,
 i_part_number IN  VARCHAR2 DEFAULT NULL,
 i_quantity    IN  VARCHAR2 DEFAULT NULL,
 o_promo_code  OUT VARCHAR2,
 o_promo_objid OUT VARCHAR2,
 o_discount    OUT VARCHAR2,
 o_error_code  OUT VARCHAR2,
 o_error_msg   OUT VARCHAR2
)
IS

   l_price number;

	CURSOR  cur_active_promos
	IS
 SELECT 	p.*
 FROM    table_x_promotion p
 WHERE   x_promo_type    = 	i_promo_type
 AND     SYSDATE BETWEEN p.x_start_date AND p.x_end_date;

	v_promo_check		NUMBER;

BEGIN --{

 o_error_code := '0';
 o_error_msg  := '';

	FOR i IN cur_active_promos
	LOOP --{
  IF i.x_sql_statement IS NOT NULL
  THEN --{

   IF i_promo_type = 'Purchase'
   THEN --{
   v_promo_check := sf_promo_check(
                                   i.objid,
                                   'p_part_number', --param1
                                   i_part_number,   --param1 value
                                   'p_quantity',    --param2
                                   i_quantity,      --param2 value
                                   'p_promo_objid', --param3
                                   i.objid          --param3 value
                                   );
   END IF; --}

   IF TO_NUMBER(v_promo_check) > 0
   THEN --{
    o_promo_objid     := i.objid;
    o_promo_code      := i.x_promo_code;
        --o_discount        := i.x_discount_amount; --CR49229
-- START CR49229

       SELECT tp.x_retail_price into l_price
       FROM table_x_pricing tp
            ,table_part_num  pn
       WHERE 1 = 1
         AND tp.x_end_date > SYSDATE
         AND tp.x_pricing2part_num = pn.objid
         AND pn.part_number = i_part_number
	 and rownum <=1;

      IF NVL (i.x_discount_amount, 0) > 0
            THEN
               o_discount := TO_CHAR (i.x_discount_amount);
            ELSIF NVL (i.x_discount_percent, 0) > 0
            THEN
               o_discount :=
                  TO_CHAR (  i.x_discount_percent
                           / 100
                           * l_price
                          );

	dbms_output.put_line('O_Discount...' || o_discount);

            END IF;

-- END CR49229
    dbms_output.put_line('Promo present...' || v_promo_check);
    RETURN;
   ELSE
    dbms_output.put_line('No Promos ' || v_promo_check);
   END IF; --}
  END IF; --}
 END LOOP; --}

EXCEPTION
 WHEN OTHERS THEN
  o_error_code := '100';
  o_error_msg  := 'Error in get_eligible_promo due to '||sqlerrm;
END get_eligible_promo; --}
--CR44459  Ends


-- CR48480_Amazon_Activation_Integration_Release


PROCEDURE get_authenticated_promos
                                   (
                                    i_esn                    IN     VARCHAR2,
                                    i_program_objid          IN     NUMBER,
                                    i_partner_name           IN     VARCHAR2,
                                    i_ar_promo_flag          IN     VARCHAR2,
                                    o_promo_objid               OUT NUMBER,
                                    o_promo_code                OUT VARCHAR2,
                                    o_script_id                 OUT VARCHAR2,
                                    o_error_code                OUT NUMBER,
                                    o_error_msg                 OUT VARCHAR2,
                                    i_ignore_attached_promo IN VARCHAR2 DEFAULT 'N'
                                   )

IS

   cst               sa.customer_type    :=  sa.customer_type ();
   o_valid_partner   sa.table_affiliated_partners.partner_name%type;
   v_promo_check	 NUMBER;



    CURSOR esn_promo_curs
		IS
	SELECT pp.objid pp_objid
	  FROM x_program_enrolled pe
	      ,x_program_parameters pp
	WHERE pe.x_esn          		= 	i_esn
      AND pe.pgm_enroll2pgm_parameter		= 	pp.objid
      AND pp.objid                		= 	i_program_objid
      AND pe.x_enrollment_status		=	'ENROLLED'
      ;

    rec_esn_promo		esn_promo_curs%ROWTYPE;

    CURSOR cur_esn_detail
    IS
	SELECT bo.org_id brand_name ,
           pi.*
      FROM table_part_inst pi ,
           table_mod_level ml ,
           table_part_num pn ,
           table_bus_org bo
      WHERE 1            = 1
        AND part_serial_no = i_esn
        AND ml.objid = pi.n_part_inst2part_mod
        AND pn.objid = ml.part_info2part_num
        AND bo.objid = pn.part_num2bus_org;
    rec_esn_detail cur_esn_detail%ROWTYPE;

    CURSOR cur_enrolled_promo(c_brand_name VARCHAR2)
    IS
	SELECT pr.x_script_id ,
           p.x_promo_code ,
           grp2esn.*
      FROM x_enroll_promo_grp2esn grp2esn ,
           table_x_promotion p ,
           x_enroll_promo_rule pr ,
           table_bus_org bo
     WHERE 1           = 1
       AND grp2esn.x_esn = i_esn
       AND p.objid       = grp2esn.promo_objid
       AND EXISTS (SELECT pe.x_enrollment_status
                     FROM x_program_enrolled pe
                    WHERE objid                = grp2esn.program_enrolled_objid
                      AND x_esn                  = i_esn
                      AND pe.x_enrollment_status = 'ENROLLED'
                   )
    AND pr.promo_objid = grp2esn.promo_objid
    AND bo.objid       = p.promotion2bus_org
    AND bo.org_id      = c_brand_name
    ORDER BY pr.x_priority;
    rec_enrolled_promo cur_enrolled_promo%ROWTYPE;

	CURSOR cur_eligible_promo ( c_brand_name IN VARCHAR2 ,c_part_inst_status IN VARCHAR2 )
    IS
	SELECT pr.x_script_id ,
           p.x_promo_code ,
           grp2esn.*
      FROM x_enroll_promo_grp2esn grp2esn ,
           table_x_promotion p ,
           x_enroll_promo_rule pr ,
           table_bus_org bo
     WHERE 1           = 1
       AND grp2esn.x_esn = i_esn
       AND p.objid       = grp2esn.promo_objid
       AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
       AND NOT EXISTS (SELECT pe.x_enrollment_status
                         FROM x_program_enrolled pe
                        WHERE objid                = grp2esn.program_enrolled_objid
                          AND x_esn                  = i_esn
                          AND pe.x_enrollment_status = 'ENROLLED'
                        )
       AND pr.promo_objid = grp2esn.promo_objid
       AND bo.objid       = p.promotion2bus_org
       AND bo.org_id      = c_brand_name
       ORDER BY pr.x_priority;
       rec_eligible_promo cur_eligible_promo%ROWTYPE;

	CURSOR cur_active_promos
	    IS
    SELECT p.*
      FROM table_x_promotion p,
           x_enroll_promo_rule pr
     WHERE x_promo_type = CASE WHEN i_ar_promo_flag = 'N'
                               THEN 'Purchase'
                               WHEN i_ar_promo_flag = 'Y'
                               THEN 'BPEnrollment'
                               ELSE NULL
                                END
       AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
       AND p.objid = pr.promo_objid (+)
     ORDER
        BY pr.x_priority;

   BEGIN

   o_error_code := 0;
   o_error_msg  := 'Success';

      IF NVL(i_ar_promo_flag,'X') NOT IN ('Y','N') THEN

         o_error_code := '10';
         o_error_msg  := 'Invalid Auto Refill flag. Must be Y or N. '||i_ar_promo_flag;
         RETURN;

      END IF;


      sa.affiliated_partners_pkg.p_validate_partner  (i_partner_name,
                                                      cst.get_bus_org_id (i_esn),
                                                      'MEMBER_ENROLL',
                                                      o_valid_partner,
                                                      o_error_code,
                                                      o_error_msg);



      IF o_valid_partner = 'N' THEN

         o_error_code := '20';
         o_error_msg  := 'Invalid Partner Name. '||i_partner_name;
         RETURN;

      END IF;

      IF NVL(i_ignore_attached_promo,'N') = 'N'
	     THEN
	     -- Check for Billing program
	     OPEN esn_promo_curs;
	     FETCH esn_promo_curs INTO	rec_esn_promo;

            IF esn_promo_curs%FOUND OR i_program_objid IS NULL THEN

               CLOSE esn_promo_curs;
               OPEN cur_enrolled_promo(rec_esn_detail.brand_name);
               FETCH cur_enrolled_promo INTO rec_enrolled_promo;
               IF cur_enrolled_promo%FOUND AND rec_enrolled_promo.promo_objid IS NOT NULL THEN
                  CLOSE cur_enrolled_promo; -- cursor close issue
                  o_promo_objid                                                := rec_enrolled_promo.promo_objid;
                  o_promo_code                                                 := rec_enrolled_promo.x_promo_code;
                  o_script_id                                                  := rec_enrolled_promo.x_script_id;
                 -- CLOSE cur_enrolled_promo;
                  dbms_output.put_line('found cur_enrolled_promo');
                  RETURN;
               END IF;
               CLOSE cur_enrolled_promo;
               -- Eligible ESN driven active promotion.
               OPEN cur_eligible_promo(rec_esn_detail.brand_name ,rec_esn_detail.x_part_inst_status);
               FETCH cur_eligible_promo INTO rec_eligible_promo;
               IF cur_eligible_promo%FOUND AND rec_enrolled_promo.promo_objid IS NOT NULL THEN
                  CLOSE cur_eligible_promo;  -- cursor close issue
                  o_promo_objid                                                := rec_enrolled_promo.promo_objid;
                  o_promo_code                                                 := rec_enrolled_promo.x_promo_code;
                  o_script_id                                                  := rec_enrolled_promo.x_script_id;
                  --CLOSE cur_eligible_promo;
                  dbms_output.put_line('found cur_eligible_promo');
                  RETURN;
               END IF;

               CLOSE cur_eligible_promo;

            ELSE

              CLOSE esn_promo_curs;

            END IF;
      END IF;

      IF  o_valid_partner =  'Y' THEN

        -- Put the esn in the table so we can tell that we called the promo check from here.
        begin
            INSERT INTO affiliated_partners_esn
              (x_esn)
              VALUES
              (i_esn);

         exception when others then
            dbms_output.put_line('Unable to insert '||i_esn||' '||sqlerrm);
         end;



      	FOR i IN cur_active_promos
      	LOOP
             IF i.x_sql_statement IS NOT NULL THEN

                v_promo_check := sf_promo_check(
                                                i.objid,
                                                'p_esn',                        --param1
                                                 i_esn,                         --param1 value
                                                 'promo_objid',                 --param2
                                                 i.objid,                       --param2 value
                                                 'p_program_id',                --param3
                                                 i_program_objid,               --param3 value
                                                 NULL,                          --param4
                                                 NULL,                          --param4 value
                                                 NULL,                          --param5
                                                 NULL                           --param5 value
                                                );
             END IF;

         IF TO_NUMBER(v_promo_check) > 0
         THEN
         --
         -- look for the script id.
         --
          BEGIN
            dbms_output.put_line('i.objid'||i.objid);

             SELECT x_script_id
               INTO o_script_id
               FROM x_enroll_promo_rule pr
              WHERE promo_objid = i.objid
                AND rownum < 2;

          EXCEPTION WHEN OTHERS THEN
             o_script_id := NULL;
          END;

          o_promo_objid     := i.objid;
          o_promo_code      := i.x_promo_code;
          dbms_output.put_line('Promo present...' || v_promo_check);

          BEGIN

             DELETE FROM affiliated_partners_esn WHERE x_esn = i_esn;

          EXCEPTION WHEN OTHERS THEN
             NULL;
          END;


          RETURN;
         ELSE
          dbms_output.put_line('No Promos ' || v_promo_check);
         END IF;

       END LOOP;
             BEGIN

                DELETE FROM affiliated_partners_esn WHERE x_esn = i_esn;
             EXCEPTION WHEN OTHERS THEN
                NULL;
             END;

             RETURN;

        END IF;


   EXCEPTION
      WHEN others THEN
        --
        IF esn_promo_curs%ISOPEN
        THEN
          CLOSE esn_promo_curs;
        END IF;
        --
        IF cur_enrolled_promo%ISOPEN
        THEN
          CLOSE cur_enrolled_promo;
        END IF;
         --
        IF cur_eligible_promo%ISOPEN
        THEN
          CLOSE cur_eligible_promo;
        END IF;
        --
        o_error_code := SQLCODE;
        o_error_msg  := 'ERROR GETTING AUTHENTICATED PROMOS : ' || SQLERRM;
        --
   END get_authenticated_promos;

PROCEDURE  get_esn_promo_discount_code
                                        (
                                         i_esn             IN      VARCHAR2,
                                         i_promo_objid     IN      VARCHAR2,
                                         o_discount_code       OUT VARCHAR2,
                                         o_error_code          OUT NUMBER,
                                         o_error_msg           OUT VARCHAR2
                                        )

IS


   BEGIN

   o_error_code := 0;
   o_error_msg  := 'Success';

      IF i_esn IS NULL
         AND
         i_promo_objid IS NULL THEN

         o_error_code := '10';
         o_error_msg  := 'ESN / PROMO objid cannot be NULL';
         RETURN;

      END IF;

      BEGIN
        -- CR48260 removed x_cf_ancillary_code association and retrieved brm_equivalent directly from table_x_promotion
        SELECT brm_equivalent_discount_code
        INTO o_discount_code
        FROM (
               SELECT brm_equivalent_discount_code
               FROM (
                     SELECT 1 order_col,
                            brm_equivalent_discount_code
                     FROM (
                            SELECT txp.brm_equivalent_discount_code
                               FROM table_x_promotion txp,
                                    x_enroll_promo_grp2esn xp
                              WHERE txp.objid   = xp.promo_objid
                                AND xp.x_esn    = i_esn
                                AND SYSDATE BETWEEN txp.x_start_date and txp.x_end_date
                              ORDER BY txp.x_start_date DESC
                             )
                     WHERE ROWNUM = 1
                     UNION
                     SELECT  2 order_col,
                             txp.brm_equivalent_discount_code
                     FROM   table_x_promotion txp
                     WHERE  txp.objid = i_promo_objid
                     )
               ORDER BY order_col)
        WHERE ROWNUM = 1;
      --
      EXCEPTION WHEN OTHERS THEN

         o_discount_code := NULL;
         o_error_code := '20';
         o_error_msg  := 'ESN / PROMO not valid ';

      END;

   EXCEPTION
      WHEN others THEN
        --
        o_discount_code := NULL;
        o_error_code    := SQLCODE;
        o_error_msg     := 'ERROR GETTING PROMO DISCOUNT : ' || SQLERRM;
        --
   END get_esn_promo_discount_code;


-- CR48480_Amazon_Activation_Integration_Release End



--CR46315 -- CR46960

	FUNCTION sf_data_promo_check(
	p_promo_objid   	IN VARCHAR2 ,
	p_esn           	IN VARCHAR2 ,
	p_service_plan_id  	IN VARCHAR2,
	p_transaction		IN VARCHAR2
	)
	RETURN NUMBER
	IS
		CURSOR cur_promo_detail
		IS
		SELECT * FROM table_x_promotion WHERE objid = p_promo_objid;
		rec_promo_detail cur_promo_detail%ROWTYPE;
		l_sql_statement VARCHAR2(4000);
		l_cursor        INTEGER;
		l_result_cursor INTEGER;
		l_bind_var      VARCHAR2(200);
		l_counter       VARCHAR2(200);
	BEGIN

		OPEN cur_promo_detail;
		FETCH cur_promo_detail INTO rec_promo_detail;
		CLOSE cur_promo_detail;
		dbms_output.put_line('1');
		IF rec_promo_detail.x_sql_statement IS NOT NULL THEN
		-- Open Cursor.
		l_sql_statement := rec_promo_detail.x_sql_statement;
		dbms_output.put_line('2:' || rec_promo_detail.x_sql_statement);
		l_cursor := dbms_sql.open_cursor;
		-- Parse SQL Statement.
		dbms_sql.parse(l_cursor ,l_sql_statement ,dbms_sql.v7);
		dbms_output.put_line('3');
		-- Bind Variables.
		l_bind_var                                   := ':p_esn';
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_esn);
		END IF;
		l_bind_var := ':p_service_plan_id';
		dbms_output.put_line('4');
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_service_plan_id);
		END IF;
		l_bind_var := ':p_transaction';
		dbms_output.put_line('5');
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_transaction);
		END IF;
		l_bind_var := ':promo_objid';
		dbms_output.put_line('6');
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_promo_objid);
		END IF;
		-- describe defines
		dbms_sql.define_column(l_cursor ,1 ,l_counter ,10);
		dbms_output.put_line('7');
		-- Execute SQL.
		l_result_cursor := dbms_sql.execute(l_cursor);
		-- Fetch result.
		dbms_output.put_line('8');
		IF NVL(dbms_sql.fetch_rows(l_cursor) ,0) > 0 THEN
		dbms_sql.column_value(l_cursor ,1 ,l_counter);
		dbms_output.put_line('9:' || l_counter);
		END IF;
		dbms_sql.close_cursor(l_cursor); --CL EM "Open Cursor Issue" 07/26/2012
		-----------===============
		END IF;
		IF TO_NUMBER(l_counter) > 0 THEN
		RETURN 1;
		ELSE
		RETURN 0;
		END IF;
	END sf_data_promo_check;


PROCEDURE SP_GET_ELIGIBLE_DATA_PROMO
(p_promo_type			VARCHAR2
,p_esn				VARCHAR2
,p_calltrans_objid		VARCHAR2
,p_action_type			VARCHAR2
,p_ig_order_type		VARCHAR2
,op_promo_code		OUT	VARCHAR2
,op_promo_objid		OUT	VARCHAR2
,op_error_code		OUT	VARCHAR2
,op_error_msg		OUT	VARCHAR2
)
IS
	CURSOR cur_esn_detail
	IS
	SELECT bo.org_id brand_name ,
	pi.*
	FROM table_part_inst pi ,
	table_mod_level ml ,
	table_part_num pn ,
	table_bus_org bo
	WHERE 1            = 1
	AND part_serial_no = p_esn
	--and    x_part_inst_status = '52'
	AND ml.objid = pi.n_part_inst2part_mod
	AND pn.objid = ml.part_info2part_num
	AND bo.objid = pn.part_num2bus_org;
	rec_esn_detail cur_esn_detail%ROWTYPE;

	CURSOR cur_active_promos(c_brand_name VARCHAR2)
	IS
	SELECT 	p.*
	FROM table_x_promotion p ,
	table_bus_org bo
	WHERE 1          = 1
	AND x_promo_type = 	p_promo_type
	AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
	AND bo.objid       = p.promotion2bus_org
	AND bo.org_id      = c_brand_name
	;

	lv_service_plan_objid	NUMBER;
	lv_transaction_type	VARCHAR2(100);
	l_promo_check		NUMBER;




BEGIN

	OP_ERROR_CODE	:=	'0';
	OP_ERROR_MSG	:=	'success';

	OPEN cur_esn_detail;
	FETCH cur_esn_detail INTO rec_esn_detail;

	IF cur_esn_detail%NOTFOUND THEN
		dbms_output.put_line('ESN details not found');
		CLOSE cur_esn_detail;
		RETURN;
	END IF;
	CLOSE cur_esn_detail;


	BEGIN

	SELECT svp.objid
	INTO	lv_service_plan_objid
	FROM table_x_call_trans ct
	,table_part_inst pi
	,table_site_part sp
	,x_service_plan_site_part spsp
	,x_service_plan svp
	WHERE     1	=	1
	AND ct.x_service_id = pi.part_serial_no
	AND ct.objid	=	p_calltrans_objid
	AND pi.x_part_inst2site_part = sp.objid
	AND spsp.x_service_plan_id = svp.objid
	and spsp.table_site_part_id = sp.objid
	AND ROWNUM = 1
	;

	EXCEPTION WHEN OTHERS
	THEN

		lv_service_plan_objid	:=	NULL;

	END;

	IF p_action_type = '111'
	THEN
		lv_transaction_type	:=	'PORT-CREDIT';


	ELSIF	 p_action_type = '6'
	THEN
		lv_transaction_type	:=	'REDEMPTION';

	ELSIF 	p_ig_order_type IN ( 'A','AP','E') AND p_action_type = '1'
	THEN
		lv_transaction_type	:=	'ACTIVATION';

	ELSIF	p_ig_order_type IN ( 'A','AP','E') AND p_action_type = '3'
	THEN
		lv_transaction_type	:=	'REACTIVATION';

	ELSIF   p_ig_order_type IN ('PIR','IPI','EPIR','E') AND lv_service_plan_objid IS NOT NULL
	THEN

		lv_transaction_type	:=	'PORT-IN';

	END IF;


	FOR rec_active_promos IN cur_active_promos(rec_esn_detail.brand_name)
	LOOP


		IF rec_active_promos.x_sql_statement IS NOT NULL THEN
	--      dbms_output.put_line('x_sql_statement');
		l_promo_check := sa.promotion_pkg.sf_data_promo_check(rec_active_promos.objid ,p_esn ,lv_service_plan_objid ,lv_transaction_type);
	--      dbms_output.put_line('x_sql_statement2');
		IF TO_NUMBER(l_promo_check) > 0 THEN
		op_promo_objid            := rec_active_promos.objid;
		op_promo_code             := rec_active_promos.x_promo_code;
			dbms_output.put_line('rec_active_promos.objid:' || rec_active_promos.objid);
			dbms_output.put_line('p_esn:' || p_esn);
			dbms_output.put_line('REC_ACTIVE_PROMOS.objid:' || rec_active_promos.objid);
		RETURN;
		ELSE
		dbms_output.put_line('promo fails:' || l_promo_check);

		END IF;
		END IF;

	END LOOP;
EXCEPTION WHEN OTHERS
THEN

NULL;

END SP_GET_ELIGIBLE_DATA_PROMO;
--
PROCEDURE sp_ins_esn_promo_hist(ip_esn			           IN 	VARCHAR2,
                                ip_calltrans_id	       IN 	VARCHAR2,
                                ip_promo_objid         IN 	VARCHAR2,
                                ip_expiration_date     IN 	VARCHAR2,
                                ip_bucket_id           IN 	VARCHAR2,
                                op_error_code          OUT 	VARCHAR2,
                                op_error_msg           OUT 	VARCHAR2,
                                ip_discount_list       IN   sa.discount_code_tab DEFAULT NULL   -- CR48480
                                )
IS
--
BEGIN
--
	op_error_code	:=	'0';
	op_error_msg	:=	'success';
  --
	INSERT INTO sa.x_esn_promo_hist
	(objid
	,esn
	,promo_hist2call_trans
	,promo_hist2x_promotion
	,insert_timestamp
	,expiration_date
	,bucket_id
  ,discount_code_list
	)
	VALUES
	(sa.sequ_esn_promo_hist_objid.nextval
	,ip_esn
	,ip_calltrans_id
	,ip_promo_objid
	,SYSDATE
	,ip_expiration_date
	,ip_bucket_id
  ,CASE WHEN ip_discount_list IS NOT NULL
        THEN ip_discount_list
        ELSE NULL
   END  -- CR48480
	);
--
EXCEPTION WHEN OTHERS
THEN
	op_error_code	:=	'99';
	op_error_msg	:=	'Exception SP_INS_ESN_PROMO_HIST '	||sqlerrm;
END sp_ins_esn_promo_hist;
--
PROCEDURE update_promo_hist(IP_ESN 			VARCHAR2
			,OP_ERROR_CODE          OUT 	VARCHAR2
			,OP_ERROR_MSG           OUT 	VARCHAR2
			)
IS

ctp      case_type := case_type();
ct       case_type := case_type();

BEGIN

	OP_ERROR_CODE	:=	'0';
	OP_ERROR_MSG	:=	'success';


          ctp := case_type ();
          ct  := case_type ();

          -- call case type member function to get the latest case data
          ct := ctp.get ( i_esn        => IP_ESN ,
                          i_case_title => '%PHONE%UPGRADE%' );

          IF ct.reference_esn IS NOT NULL
	  THEN

		INSERT INTO sa.X_ESN_PROMO_HIST
		(OBJID
		,ESN
		,PROMO_HIST2CALL_TRANS
		,PROMO_HIST2X_PROMOTION
		,INSERT_TIMESTAMP
		,EXPIRATION_DATE
		,BUCKET_ID
		)
		SELECT
		sa.sequ_esn_promo_hist_objid.nextval
		,IP_ESN
		,PROMO_HIST2CALL_TRANS
		,PROMO_HIST2X_PROMOTION
		,SYSDATE
		,EXPIRATION_DATE
		,BUCKET_ID
		FROM sa.X_ESN_PROMO_HIST
		WHERE ESN = ct.reference_esn
		AND NVL(EXPIRATION_DATE,SYSDATE + 1)	> SYSDATE
		;


		UPDATE sa.X_ESN_PROMO_HIST
		SET EXPIRATION_DATE = SYSDATE
		WHERE ESN = ct.reference_esn
		AND NVL(EXPIRATION_DATE,SYSDATE + 1)	> SYSDATE
		;


	  END IF;




EXCEPTION WHEN OTHERS
THEN

	OP_ERROR_CODE	:=	'99';
	OP_ERROR_MSG	:=	SQLERRM;

END;
--CR46315 -- CR46960
--
END promotion_pkg;
/