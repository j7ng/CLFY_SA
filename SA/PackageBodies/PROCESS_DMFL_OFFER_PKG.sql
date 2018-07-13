CREATE OR REPLACE PACKAGE BODY sa."PROCESS_DMFL_OFFER_PKG"
/*************************************************************************************************/
/*                                                                                          	   */
/* Name         :   PROCESS_DMFL_OFFER_PKG                                                       */
/*                                                                                               */
/* Purpose      :   To manage the new offer for Double minutes clients                           */
/*                                                                                               */
/* Platforms    :   Oracle 10g                                                    			         */
/*                                                                                          	   */
/* Author       :   Vanisri Adapa                                                        	  		 */
/*                                                                                          	   */
/* Date         :   06-24-2009																	                                 */
/* REVISIONS:                                                         							             */
/* VERSION  DATE        WHO          PURPOSE                                  					         */
/* -------  ---------- 	-----  		 -------------------------------------   			         */
/*  1.0     06/24/09 Vanisri		 Initial  Revision                                       */
/*  1.1-1.3 07/02/09 Icanavan    Remove case creation                                          */
/*  1.6     07/09/09 Ymillan     Add error handle for Exception                              */
/*  1.7     07/14/10 YMillan     CR13940 add input into call SP.create_call_trans_2                */
/***********************************************************************************************/
AS
 /***************************************************************************************************************
 Program Name       :  	sp_extra_minutes
 Program Type       :  	Stored procedure
 Program Arguments  :  	p_esn
                        p_pi_objid
                        p_offer_units
                        p_offer_days
                        p_sourcesystem
                        p_sub_sourcesystem
                        p_case_objid
 Returns            :  	p_errorcode
                        p_errormessage
 Program Called     :  	None
 Description        :  	This stored procedure is used to add extra minutes to table_x_call_trans and insert additional record
                        into table_x_pending_redemption
 Modified By            Modification     CR             Description
                          Date           Number
 =============          ============     ======      ===================================
 Jai Arza        	  	    08/27/2014     CR26067  	        Rewrote the complete logic
***************************************************************************************************************/
   PROCEDURE sp_extra_minutes(
      p_esn                 IN VARCHAR2,
      p_pi_objid            IN NUMBER,
      p_cards               IN VARCHAR2,
      p_offer_units         IN NUMBER,
      p_offer_days          IN NUMBER,
      p_sourcesystem        IN VARCHAR2,
      p_sub_sourcesystem    IN VARCHAR2,
      p_case_idnumber       IN VARCHAR2,--sa.table_case.id_number%type,
      p_errorcode           OUT VARCHAR2,
      p_errormessage        OUT VARCHAR2
   )
   IS
    v_replace_units   sa.table_part_num.x_redeem_units%type:=0;
    v_sp_objid        sa.table_site_part.objid%type;
    v_x_min           sa.table_site_part.x_min%type;
    v_carrierobjid    sa.table_x_carrier.objid%type;
    v_dealerobjid     sa.table_site.objid%type;
    v_ct_objid        sa.table_x_call_trans.objid%type;
    v_pr_objid        sa.table_x_pending_redemption.objid%type;
    v_chgReason       VARCHAR2(30) := 'DMFL OFFER ACCEPTED' ;
    v_count	          PLS_INTEGER:=0;

    CURSOR part_inst_c(
          v_pi_objid VARCHAR2
        )
    Is
     Select pi.*,bo.org_id
     From   sa.Table_Part_Inst Pi
            ,sa.Table_Mod_Level Ml
            ,sa.Table_Part_Num Pn
            ,sa.Table_Bus_Org Bo
     Where  Pi.Objid = v_pi_objid
     And    Ml.Objid=Pi.N_Part_Inst2part_Mod
     And    Pn.Objid = Ml.Part_Info2part_Num
     and    bo.objid = pn.part_num2bus_org;
     Rec_Part_Inst_C    Part_Inst_C%Rowtype;

    BEGIN
      --get part Inst record
      OPEN part_inst_c(p_pi_objid);
      FETCH part_inst_c
      INTO rec_part_inst_c;
      CLOSE part_inst_c;

      DBMS_OUTPUT.PUT_LINE('Start of PROCESS_DMFL_OFFER_PKG.sp_extra_minutes');
      BEGIN
        SELECT  objid
                , x_min
        INTO    v_sp_objid
                , v_x_min
        FROM    sa.table_site_part
        WHERE   x_service_id = rec_part_inst_c.part_serial_no
        AND     ROWNUM < 2
        ORDER BY install_date DESC;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE;
      END;
      DBMS_OUTPUT.PUT_LINE('v_sp_objid: '||v_sp_objid);
      DBMS_OUTPUT.PUT_LINE('v_x_min: '||v_x_min);

      --To get carrier info
      BEGIN
        SELECT  x_call_trans2carrier
        INTO    v_carrierobjid
        FROM (
            SELECT x_call_trans2carrier
            FROM  table_x_call_trans
            WHERE x_service_id=rec_part_inst_c.part_serial_no
            order by objid desc
            )
        WHERE rownum=1;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE;
      END;
      DBMS_OUTPUT.PUT_LINE('v_carrierobjid: '||v_carrierobjid);
      -- To get Dealer Info
      BEGIN
         SELECT g.objid
         INTO   v_dealerobjid
         FROM   sa.table_site g, sa.table_inv_role h, sa.table_inv_locatn e, sa.table_inv_bin d, sa.table_part_inst f
         WHERE  g.objid = e.inv_locatn2site
         AND    e.objid = h.inv_role2inv_locatn
         AND    e.objid = d.inv_bin2inv_locatn
         AND    d.objid = f.part_inst2inv_bin
         AND    f.part_serial_no = rec_part_inst_c.part_serial_no;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_dealerobjid:=NULL;
        WHEN OTHERS THEN
          RAISE;
      END;
      DBMS_OUTPUT.PUT_LINE('v_dealerobjid: '||v_dealerobjid);
      FOR REDEM_CARD IN ( SELECT  pi.objid card_objid,
                                  pi.part_serial_no,
                                  pi.x_red_code,
                                  pn.x_redeem_days,
                                  NVL (pn.x_redeem_units, 0) x_redeem_units,
                                  part_inst2inv_bin,
                                  n_part_inst2part_mod,
                                  x_insert_date,
                                  x_creation_date,
                                  x_order_number,
                                  x_po_num
                          FROM    table_part_num pn, table_mod_level ml, table_part_inst pi
                          WHERE   1 = 1
                          AND     pn.objid = ml.part_info2part_num
                          AND     ml.objid = pi.n_part_inst2part_mod
                          AND     pi.x_red_code = p_cards
                          AND     pi.x_domain='REDEMPTION CARDS'
                          AND     pi.x_part_inst_status IN ('42'))
      LOOP
        v_replace_units := p_offer_units - redem_card.x_redeem_units;
        v_ct_objid := sa.Seq('x_call_trans');
        DBMS_OUTPUT.PUT_LINE('v_replace_units: '||v_replace_units);
        DBMS_OUTPUT.PUT_LINE('v_ct_objid: '||v_ct_objid);

        -- insert into call Trans
        INSERT INTO sa.table_x_call_trans(
          objid
          ,call_trans2site_part
          ,x_action_type
          ,x_call_trans2carrier
          ,x_call_trans2dealer
          ,x_call_trans2user
          ,x_line_status
          ,x_min
          ,x_service_id
          ,x_sourcesystem
          ,x_transact_date
          ,x_total_units
          ,x_action_text
          ,x_reason
          ,x_result
          ,x_sub_sourcesystem
          ,x_iccid
          ,x_ota_req_type
          ,x_ota_type
          ,x_call_trans2x_ota_code_hist
          ,x_new_due_date
          ,update_stamp
          )
        VALUES
        (
          v_ct_objid--objid
          ,v_sp_objid--,call_trans2site_part
          ,'8'--,x_action_type
          ,v_carrierobjid--,x_call_trans2carrier
          ,v_dealerobjid--,x_call_trans2dealer
          ,'268435556'--,x_call_trans2user
          ,NULL--,x_line_status
          ,v_x_min--,x_min
          ,rec_part_inst_c.part_serial_no--,x_service_id
          ,'WEBCSR'--,x_sourcesystem
          ,SYSDATE--,x_transact_date
          ,v_replace_units--,x_total_units
          ,'CUST SERVICE'--,x_action_text
          ,v_chgReason--,x_reason
          ,'Completed'--,x_result
          ,rec_part_inst_c.org_id--,x_sub_sourcesystem
          ,NULL--,x_iccid
          ,NULL--,x_ota_req_type
          ,NULL--,x_ota_type
          ,NULL--,x_call_trans2x_ota_code_hist
          ,NULL--,x_new_due_date
          ,SYSDATE--,update_stamp
          )
          ;
          V_COUNT	:= SQL%ROWCOUNT;
          DBMS_OUTPUT.PUT_LINE('Count of records inserted into table_x_call_trans: '||V_COUNT);
          V_COUNT := 0;
        FOR X_PROMOTION IN (
                              SELECT  *
                              FROM    (
                                      SELECT  objid
                                              ,DECODE(SUBSTR(x_promo_code,LENGTH(x_promo_code)), 'D',x_access_days,x_units) replace_units
                                              ,x_revenue_type
                                      FROM table_x_promotion
                                      WHERE x_promo_type    ='Replacement'
                                      AND promotion2bus_org =
                                                          (
                                                            SELECT objid FROM table_bus_org WHERE s_org_id = rec_part_inst_c.org_id
                                                          )
                                      )
                              WHERE   replace_units=v_replace_units
                            )
        LOOP
          v_pr_objid:=sa.Seq('x_pending_redemption');
          DBMS_OUTPUT.PUT_LINE('v_pr_objid: '||v_pr_objid);
          INSERT INTO sa.table_x_pending_redemption
            (
              objid
              ,pend_red2x_promotion
              ,x_pend_red2site_part
              ,x_pend_type
              ,pend_redemption2esn
              ,x_case_id
              ,x_granted_from2x_call_trans
              ,redeem_in2call_trans
              ,pend_red2prog_purch_hdr
            )
          VALUES
            (
              v_pr_objid--objid
              ,x_promotion.objid--,pend_red2x_promotion
              ,NULL--,x_pend_red2site_part
              ,x_promotion.x_revenue_type--,x_pend_type
              ,p_pi_objid--,pend_redemption2esn
              ,p_case_idnumber--,x_case_id
              ,v_ct_objid--,x_granted_from2x_call_trans
              ,NULL--,redeem_in2call_trans
              ,NULL--,pend_red2prog_purch_hdr
            );
            V_COUNT	:= SQL%ROWCOUNT;
            DBMS_OUTPUT.PUT_LINE('Count of records inserted into table_x_pending_redemption: '||V_COUNT);
            V_COUNT := 0;
        END LOOP;
      END LOOP;
      DBMS_OUTPUT.PUT_LINE('End of PROCESS_DMFL_OFFER_PKG.sp_extra_minutes');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END sp_extra_minutes;
 /***************************************************************************************************************
 Program Name       :  	main
 Program Type       :  	Stored procedure
 Program Arguments  :  	p_esn
                        p_offer_units
                        p_offer_days
                        p_sourcesystem
                        p_sub_sourcesystem
                        p_case_objid
 Returns            :  	p_errorcode
                        p_errormessage
 Program Called     :  	None
 Description        :  	This stored procedure is used to handle logic when we redem a double minutes benefit
                        over an esn which already has the double minutes benefit attached to it.
 Modified By            Modification     CR             Description
                          Date           Number
 =============          ============     ======      ===================================
 Jai Arza        	  	    08/27/2014     CR26067  	        Rewrote the complete logic
***************************************************************************************************************/
    PROCEDURE main(
      p_esn                 IN VARCHAR2,
      p_cards               IN VARCHAR2,
      p_offer_units         IN NUMBER,
      p_offer_days          IN NUMBER,
      p_sourcesystem        IN VARCHAR2,
      p_sub_sourcesystem    IN VARCHAR2,
      p_case_objid          IN NUMBER,
      p_errorcode           OUT VARCHAR2,
      p_errormessage        OUT VARCHAR2
   )
   IS
      v_pi_objid              sa.table_part_inst.objid%type := 0 ;
      v_case_idnumber         sa.table_case.id_number%type := 0 ;
      v_op_return             VARCHAR2(200) :=' ' ;
      v_op_returnMsg          VARCHAR2(200) :=' ' ;
      v_program_name          VARCHAR2 (80) := 'PROCESS_DMFL_OFFER_PKG.MAIN';
      v_action                VARCHAR2 (500) := NULL;
      e_esn_exception         EXCEPTION;
      e_case_exception        EXCEPTION;
      e_compunits_exception   EXCEPTION;
      e_compdays_exception    EXCEPTION;
   BEGIN
      DBMS_OUTPUT.PUT_LINE('Start of PROCESS_DMFL_OFFER_PKG.MAIN');
      DBMS_OUTPUT.PUT_LINE('p_esn: '||p_esn);
      DBMS_OUTPUT.PUT_LINE('p_cards: '||p_cards);
      DBMS_OUTPUT.PUT_LINE('p_offer_units: '||p_offer_units);
      DBMS_OUTPUT.PUT_LINE('p_offer_days:' ||p_offer_days);
      DBMS_OUTPUT.PUT_LINE('p_sourcesystem: '||p_sourcesystem);
      DBMS_OUTPUT.PUT_LINE('p_sub_sourcesystem: '||p_sub_sourcesystem);
      DBMS_OUTPUT.PUT_LINE('p_case_objid: '||p_case_objid);
      v_program_name := 'PROCESS_DMFL_OFFER_PKG.MAIN';
      BEGIN
        select  objid
        into    v_pi_objid
        from    sa.table_part_inst
        where   part_serial_no = p_esn
        and     x_domain = 'PHONES';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          raise e_esn_exception;
        WHEN OTHERS THEN
          raise;
      END;

      BEGIN
        select  id_number
        into    v_case_idnumber
        from    sa.table_case
        where   objid = p_case_objid;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           raise e_case_exception;
        WHEN OTHERS THEN
            raise;
      END;

      sp_extra_minutes(
        p_esn,
        v_pi_objid,
        p_cards,
        p_offer_units,
        p_offer_days,
        p_sourcesystem,
        p_sub_sourcesystem,
        v_case_idnumber,
        p_errorcode,
        p_errormessage
          );

      COMMIT;
      p_errorcode:='000';
      p_errormessage:='Success';
      DBMS_OUTPUT.PUT_LINE('End of PROCESS_DMFL_OFFER_PKG.MAIN');
  EXCEPTION
      WHEN e_esn_exception THEN
          p_errorcode:='100';
          p_errormessage:='ESN not found';
          v_action := p_esn||' ESN not found, please provide a valid ESN';
          ota_util_pkg.err_log(  v_action, --p_action
                                  SYSDATE, --p_error_date
                                  P_ESN, --p_key
                                  v_program_name,--p_program_name
                                  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK ||';'|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
                               );
          rollback;
      WHEN e_case_exception THEN
          p_errorcode:='110';
          p_errormessage:='Case not found';
          v_action := p_case_objid||' Case not found, please provide a valid case';
          ota_util_pkg.err_log(  v_action, --p_action
                                  SYSDATE, --p_error_date
                                  P_ESN, --p_key
                                  v_program_name,--p_program_name
                                  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK ||';'|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
                               );
          rollback;
      WHEN OTHERS THEN
         p_errorcode := SQLCODE;
         p_errormessage := SUBSTR(SQLERRM,1,200);
         v_action := 'Generic Error';
         ota_util_pkg.err_log(  v_action, --p_action
                                  SYSDATE, --p_error_date
                                  P_ESN, --p_key
                                  v_program_name,--p_program_name
                                  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK ||';'|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
                               );
         RAISE;
 END main;

END process_dmfl_offer_pkg;
/