CREATE OR REPLACE PROCEDURE sa."SP_AREA_CODE_CHANGE" ( p_from_npa varchar2,
                                                     p_from_nxx varchar2,
                                                     p_to_npa varchar2,
                                                     p_status OUT varchar2,
                                                     p_msg OUT varchar2)
IS
 /*****************************************************************
  * Name: sp_area_code_change
  * Description: The package is called by IVR and Clarify (FORM 1402)
  *              to do Area Code Change
  *
  * Created by: SL
  * Date:  11/27/01
  *
  * History           Who                Description
  * -------------------------------------------------------------
  * 11/27/01          SL                 Initial Version
  *                                      Replace CB code in FORM 1402
  *                                      to handle processing large
  *                                      amount of data  for non-grid-
  *                                      selection situation
  * 10/23/02          NS                 Added X_MSID for number pooling.
  * -
  * Line Status Code:
  * Code  Code Name        Code   Code Name
  * 11	  NEW              34	  PENDING AC CHANGE
  * 12	  USED             35	  AC RETURNED
  * 13	  ACTIVE           36	  AC VOIDED
  * 15	  NEWHOLD          37	  RESERVED
  * 16	  USEDHOLD         38	  RESERVED AC
  * 17	  RETURNED         39	  RESERVED USED
  * 18	  EXPIRED          60	  NTN
  * 33	  DELETED
  *****************************************************************/

 CURSOR c_old_line IS
   SELECT pi.*, carr.objid carrier_objid, carr.x_carrier_id
   FROM table_x_carrier carr,
        table_part_inst pi
   WHERE  1=1
   AND pi.part_inst2carrier_mkt = carr.objid
   AND pi.x_domain ||'' = 'LINES'
   AND pi.x_nxx = NVL(p_from_nxx,x_nxx)
   AND pi.x_npa = p_from_npa;

 TYPE line_tab_t IS TABLE OF c_old_line%ROWTYPE
 INDEX BY BINARY_INTEGER;
 old_line_tab line_tab_t;
 new_line_tab line_tab_t;
 old_line_reserved_tab line_tab_t;

 CURSOR c_new_line IS
   SELECT pi.*, carr.objid carrier_objid, carr.x_carrier_id
   FROM table_x_carrier carr,
        table_part_inst pi
   WHERE  1=1
   AND pi.part_inst2carrier_mkt = carr.objid
   AND pi.x_domain ||'' = 'LINES'
   AND pi.x_nxx = NVL(p_from_nxx,x_nxx)
   AND pi.x_npa = p_to_npa;

 CURSOR c_code IS
   SELECT *
   FROM table_x_code_table
   WHERE X_CODE_TYPE = 'LS';
 TYPE code_tab_t IS TABLE OF table_x_code_table%ROWTYPE
 INDEX BY BINARY_INTEGER;
 code_tab code_tab_t;

 CURSOR c_carr_lac ( c_carrier_id number) IS
   SELECT carr.x_carrier_id, carr.objid carr_objid,
          lac.objid lac_objid, lac.x_local_area_code
   FROM table_x_lac lac, table_x_carrier carr
   WHERE carr.carrier2personality = lac.lac2personality
   AND carr.objid = c_carrier_id;
 TYPE carr_lac_tab_t IS TABLE OF c_carr_lac%ROWTYPE;
 carr_lac_tab carr_lac_tab_t;

 CURSOR c_acct_hist (c_pi_objid number) IS
   SELECT *
   FROM table_x_account_Hist
   WHERE account_hist2part_inst = c_pi_objid
   AND (x_end_date is null OR x_end_date = to_date('01-JAN-1753','DD-MON-RRRR')) ;

 CURSOR c_site_part (c_min varchar2) IS
   SELECT *
   FROM table_site_part
   WHERE x_min = c_min
   AND part_status ||'' = 'ACTIVE';

 v_i number := 0;
 v_res number := 0;
 v_upd number := 0 ;
 v_step varchar2(500);
 v_carr_lac number := 0 ;
 v_require_code number := 0 ; -- 'RESERVED AC','PENDING AC CHANGE','AC RETURNED'
 v_current_date date := sysdate;
 v_new_pi_objid number;
 v_new_pi_pn table_part_inst.part_serial_no%TYPE;
 v_new_pi_code table_part_inst.x_part_inst_status%TYPE;
 v_new_pi_code_objid table_part_inst.status2x_code_table%TYPE;
 v_new_pi_npa table_part_inst.x_npa%TYPE;
 v_new_pi_nxx table_part_inst.x_nxx%TYPE;
 v_new_pi_userobj table_part_inst.created_by2user%TYPE;
 v_ph_pi_objid number;
 v_ph_code table_part_inst.x_part_inst_status%TYPE;
 v_ph_code_objid table_part_inst.status2x_code_table%TYPE;
 v_ph_npa table_part_inst.x_npa%TYPE;
 v_ph_pn table_part_inst.part_serial_no%TYPE;
 v_ph_creation_date date;
 v_dummy number;
 v_result1 boolean;
 v_result2 boolean;

 PROCEDURE p_get_code_objid ( f_code_number varchar2, f_code_objid OUT number)
 IS
 BEGIN
  FOR i IN 0..code_tab.count-1 LOOP
   IF code_tab(i).x_code_number = f_code_number THEN
      f_code_objid := code_tab(i).objid;
      RETURN;
   END IF;
  END LOOP;
  f_code_objid := NULL;
 END p_get_code_objid;

 PROCEDURE p_is_ac_exists (p_carrier_id number, p_area_code varchar2,
                           p_result OUT boolean)
 IS
 p_dummy number;
 BEGIN
   p_result := FALSE;
   SELECT 1 INTO p_dummy
   FROM table_x_lac lac, table_x_carrier carr
   WHERE  lac.x_local_area_code = p_area_code
   AND carr.carrier2personality = lac.lac2personality
   AND carr.objid = p_carrier_id;
   p_result := TRUE;
 EXCEPTION
  WHEN OTHERS THEN
   p_result := FALSE;
 END;

BEGIN
 v_i := 0;
 old_line_tab.delete;
 old_line_reserved_tab.delete;
 new_line_tab.delete;
 -- Validate existing lines
 FOR c_old_line_rec in c_old_line LOOP

   old_line_tab(v_i) := c_old_line_rec;
   v_i := v_i + 1;
   IF c_old_line_rec.x_part_inst_status
      NOT IN ('11','12','13','15','16','17','18','33','35','36','37','39') THEN
    p_status := 'F';
    p_msg := 'Area Code change could not be processed because the range of '||
             'lines specified contains lines that have a status of Reserved AC '||
             ' or Pending AC Change';
    RETURN;
   END IF;
   v_result1 := FALSE;
   v_result2 := FALSE;
   p_is_ac_exists(c_old_line_rec.part_inst2carrier_mkt,
                  p_from_npa, v_result1);
   p_is_ac_exists(c_old_line_rec.part_inst2carrier_mkt,
                  p_to_npa, v_result2);

   IF  NOT ( v_result1 AND v_result2) THEN
     p_status := 'F';
     p_msg := 'Local Area Code '||p_from_npa||' Or '||p_to_npa||
              ' is not defined for Carrier '|| c_old_line_rec.x_carrier_id;
     RETURN;
   END IF;
 END LOOP;

 IF old_line_tab.count <= 0 THEN
   p_status := 'F';
   IF p_from_nxx IS NULL THEN
    p_msg := 'No lines exists under area code '||p_from_npa;
   ELSE
    p_msg := 'No lines exists under area code '||p_from_npa||' and nxx '||p_from_nxx;
   END IF;
   RETURN;
 END IF;

 -- Validate new lines
 v_i := 0;
 FOR c_new_line_rec IN c_new_line LOOP
   new_line_tab(v_i) := c_new_line_rec;
   v_i := v_i + 1;
   IF c_new_line_rec.x_part_inst_status NOT IN ('17','18','35','36','33') THEN
    p_status := 'F';
    p_msg := 'Area Code change could not be processed because the line '||
                p_to_npa || c_new_line_rec.x_nxx||c_new_line_rec.x_ext ||
                'already exists  in the new Area code. ';
    RETURN;
   END IF;
 END LOOP;

 -- get code information
 v_i := 0;
 FOR c_code_rec IN c_code LOOP
   code_tab(v_i) := c_code_rec;
   v_i := v_i + 1;
   IF c_code_rec.x_code_name
       IN ('RESERVED AC','PENDING AC CHANGE','AC RETURNED') THEN
      v_require_code := v_require_code + 1;
   END IF;
 END LOOP;

 IF v_require_code <> 3 THEN
    p_status := 'F';
    p_msg := 'Problem retrieving Status code records from code table. '||
             'Area Code Change not processed.';
    RETURN;
 END IF;

 --
 -- perform Area Code Change
 --
 FOR v_i IN 0..old_line_tab.count-1 LOOP
  v_new_pi_pn := p_to_npa||old_line_tab(v_i).x_nxx||old_line_tab(v_i).x_ext;
  v_new_pi_npa := p_to_npa;
  BEGIN
    SELECT objid INTO v_new_pi_userobj
    FROM table_user
    WHERE s_login_name = upper(user) and rownum < 2;
  EXCEPTION
    WHEN OTHERS THEN
     BEGIN
      SELECT objid INTO v_new_pi_userobj
      FROM table_user
      WHERE s_login_name = upper(user) and rownum < 2;
     EXCEPTION
      WHEN OTHERS THEN
       v_new_pi_userobj := old_line_tab(v_i).created_by2user;
     END;
  END;

  IF old_line_tab(v_i).x_part_inst_status = '37' THEN
   --save reserved line to a list
   old_line_reserved_tab(v_res) := old_line_tab(v_i);
   v_res := v_res + 1;
   goto next_line;
  ELSIF old_line_tab(v_i).x_part_inst_status in ('17','18','33','35','36') THEN
   goto next_line;
  ELSE
   IF old_line_tab(v_i).x_part_inst_status = '13' THEN
     -- update 'ACTIVE' status to 'PENDING AC CHANGE'
    v_new_pi_code := '34'; -- PENDING AC CHANGE
    p_get_code_objid ( v_new_pi_code, v_new_pi_code_objid);
    UPDATE table_part_inst
    SET x_part_inst_status = v_new_pi_code
        ,status2x_code_table = v_new_pi_code_objid
    WHERE objid = old_line_tab(v_i).objid;

    -- get new code for new line
    v_new_pi_code := '38'; -- RESERVED AC
    v_new_pi_code_objid := NULL;
    p_get_code_objid(v_new_pi_code,v_new_pi_code_objid);
   ELSIF old_line_tab(v_i).x_part_inst_status IN ('11','12','15','16') THEN
    v_new_pi_code := '35'; --AC RETURNED
    v_new_pi_code_objid := NULL;
    p_get_code_objid(v_new_pi_code,v_new_pi_code_objid);
    UPDATE table_part_inst
    SET x_part_inst_status = v_new_pi_code
        ,status2x_code_table = v_new_pi_code_objid
    WHERE objid = old_line_tab(v_i).objid;
   ELSE
    v_new_pi_code := old_line_tab(v_i).x_part_inst_status;
    v_new_pi_code_objid := old_line_tab(v_i).status2x_code_table;
   END IF;

   -- 04/10/03 SELECT seq_part_inst.nextval + power(2,28)
   SELECT sa.seq('part_inst')
   INTO v_new_pi_objid
   FROM dual;
   v_step  := 'Create part_inst';
   INSERT INTO table_part_inst (
     OBJID ,
     PART_GOOD_QTY,
     PART_BAD_QTY ,
     PART_SERIAL_NO ,
     PART_MOD       ,
     PART_BIN       ,
     LAST_PI_DATE   ,
     PI_TAG_NO      ,
     LAST_CYCLE_CT  ,
     NEXT_CYCLE_CT  ,
     LAST_MOD_TIME  ,
     LAST_TRANS_TIME ,
     TRANSACTION_ID ,
     DATE_IN_SERV   ,
     WARR_END_DATE  ,
     REPAIR_DATE    ,
     PART_STATUS    ,
     PICK_REQUEST   ,
     GOOD_RES_QTY   ,
     BAD_RES_QTY    ,
     DEV            ,
     X_INSERT_DATE  ,
     X_SEQUENCE     ,
     X_CREATION_DATE,
     X_PO_NUM       ,
     X_RED_CODE     ,
     X_DOMAIN       ,
     X_DEACTIVATION_FLAG ,
     X_REACTIVATION_FLAG ,
     X_COOL_END_DATE ,
     X_PART_INST_STATUS  ,
     X_NPA          ,
     X_NXX          ,
     X_EXT          ,
     X_ORDER_NUMBER ,
     PART_INST2INV_BIN ,
     N_PART_INST2PART_MOD,
     FULFILL2DEMAND_DTL,
     PART_INST2X_PERS  ,
     PART_INST2X_NEW_PERS ,
     PART_INST2CARRIER_MKT,
     CREATED_BY2USER      ,
     STATUS2X_CODE_TABLE  ,
     PART_TO_ESN2PART_INST,
     X_PART_INST2SITE_PART,
     X_LD_PROCESSED       ,
     DTL2PART_INST        ,
     ECO_NEW2PART_INST    ,
     HDR_IND              ,
	 X_MSID ) VALUES (   --Nitin : Added X_MSID for number pooling
     v_new_pi_objid ,
     old_line_tab(v_i).PART_GOOD_QTY,
     old_line_tab(v_i).PART_BAD_QTY ,
     v_new_pi_pn ,
     old_line_tab(v_i).PART_MOD       ,
     old_line_tab(v_i).PART_BIN       ,
     old_line_tab(v_i).LAST_PI_DATE   ,
     old_line_tab(v_i).PI_TAG_NO      ,
     old_line_tab(v_i).LAST_CYCLE_CT  ,
     old_line_tab(v_i).NEXT_CYCLE_CT  ,
     old_line_tab(v_i).LAST_MOD_TIME  ,
     old_line_tab(v_i).LAST_TRANS_TIME ,
     old_line_tab(v_i).TRANSACTION_ID ,
     old_line_tab(v_i).DATE_IN_SERV   ,
     old_line_tab(v_i).WARR_END_DATE  ,
     old_line_tab(v_i).REPAIR_DATE    ,
     old_line_tab(v_i).PART_STATUS    ,
     old_line_tab(v_i).PICK_REQUEST   ,
     old_line_tab(v_i).GOOD_RES_QTY   ,
     old_line_tab(v_i).BAD_RES_QTY    ,
     old_line_tab(v_i).DEV            ,
     old_line_tab(v_i).X_INSERT_DATE  ,
     old_line_tab(v_i).X_SEQUENCE     ,
     v_current_date,
     old_line_tab(v_i).X_PO_NUM       ,
     old_line_tab(v_i).X_RED_CODE     ,
     old_line_tab(v_i).X_DOMAIN       ,
     old_line_tab(v_i).X_DEACTIVATION_FLAG ,
     old_line_tab(v_i).X_REACTIVATION_FLAG ,
     old_line_tab(v_i).X_COOL_END_DATE ,
     v_new_pi_code  ,
     v_new_pi_npa          ,
     old_line_tab(v_i).X_NXX          ,
     old_line_tab(v_i).X_EXT          ,
     old_line_tab(v_i).X_ORDER_NUMBER ,
     old_line_tab(v_i).PART_INST2INV_BIN ,
     old_line_tab(v_i).N_PART_INST2PART_MOD,
     old_line_tab(v_i).FULFILL2DEMAND_DTL,
     old_line_tab(v_i).PART_INST2X_PERS  ,
     old_line_tab(v_i).PART_INST2X_NEW_PERS ,
     old_line_tab(v_i).PART_INST2CARRIER_MKT,
     v_new_pi_userobj  ,
     v_new_pi_code_objid  ,
     old_line_tab(v_i).PART_TO_ESN2PART_INST,
     old_line_tab(v_i).X_PART_INST2SITE_PART,
     old_line_tab(v_i).X_LD_PROCESSED       ,
     old_line_tab(v_i).DTL2PART_INST        ,
     old_line_tab(v_i).ECO_NEW2PART_INST    ,
     old_line_tab(v_i).HDR_IND              ,
     v_new_pi_pn  --Nitin : Added X_MSID value for number pooling
     );

     -- terminate old account hist record and add new one
     FOR c_acct_hist_rec IN c_acct_hist(old_line_tab(v_i).objid) LOOP
      v_step := 'Update table_x_account_hist';
      UPDATE table_x_account_hist
      SET x_end_date = v_current_date
      WHERE objid = c_acct_hist_rec.objid;

      v_step := 'Insert table_x_account_hist';
      INSERT INTO table_x_account_hist (
        OBJID                  ,
        ACCOUNT_HIST2PART_INST ,
        ACCOUNT_HIST2X_ACCOUNT ,
        ACCOUNT_HIST2X_PI_HIST ,
        X_END_DATE             ,
        X_START_DATE  ) VALUES (
        -- 04/10/03 seq_x_account_hist.nextval + power(2,28),
        sa.seq('x_account_hist'),
        v_new_pi_objid,
        c_acct_hist_rec.account_hist2x_account,
        c_acct_hist_rec.account_hist2x_pi_hist,
        to_date('01-JAN-1753','DD-MON-RRRR'),
        v_current_date
        );
     END LOOP;

     -- Write to pi_Hist for existing line
     FOR i IN 0..1 LOOP
      -- i
      -- 0 Write to pi_Hist for existing line
      -- 1 Write to pi_Hist for new line
      IF i = 0 THEN
        v_ph_code := old_line_tab(v_i).x_part_inst_status;
        v_ph_code_objid := old_line_tab(v_i).status2x_code_table;
        v_ph_npa := old_line_tab(v_i).x_npa;
        v_ph_pn := old_line_tab(v_i).part_serial_no;
        v_ph_creation_date := old_line_tab(v_i).x_creation_date;
        v_ph_pi_objid := old_line_tab(v_i).objid;
        v_step := 'Write to pi_Hist for existing line';
      ELSIF i = 1 THEN
        v_ph_code := v_new_pi_code;
        v_ph_code_objid := v_new_pi_code_objid;
        v_ph_npa := v_new_pi_npa;
        v_ph_pn := v_new_pi_pn;
        v_ph_creation_date := v_current_date;
        v_ph_pi_objid := v_new_pi_objid;
        v_step := 'Write to pi_Hist for new line';
      END IF;

      INSERT INTO table_x_pi_hist (
       OBJID                          ,
       STATUS_HIST2X_CODE_TABLE       ,
       X_CHANGE_DATE                  ,
       X_CHANGE_REASON                ,
       X_COOL_END_DATE                ,
       X_CREATION_DATE                ,
       X_DEACTIVATION_FLAG            ,
       X_DOMAIN                       ,
       X_EXT                          ,
       X_INSERT_DATE                  ,
       X_NPA                          ,
       X_NXX                          ,
       X_OLD_EXT                      ,
       X_OLD_NPA                      ,
       X_OLD_NXX                      ,
       X_PART_BIN                     ,
       X_PART_INST_STATUS             ,
       X_PART_MOD                     ,
       X_PART_SERIAL_NO               ,
       X_PART_STATUS                  ,
       X_PI_HIST2CARRIER_MKT          ,
       X_PI_HIST2INV_BIN              ,
       X_PI_HIST2PART_INST            ,
       X_PI_HIST2PART_MOD             ,
       X_PI_HIST2USER                 ,
       X_PI_HIST2X_NEW_PERS           ,
       X_PI_HIST2X_PERS               ,
       X_PO_NUM                       ,
       X_REACTIVATION_FLAG            ,
       X_RED_CODE                     ,
       X_SEQUENCE                     ,
       X_WARR_END_DATE                ,
       DEV                            ,
       FULFILL_HIST2DEMAND_DTL        ,
       PART_TO_ESN_HIST2PART_INST     ,
       X_BAD_RES_QTY                  ,
       X_DATE_IN_SERV                 ,
       X_GOOD_RES_QTY                 ,
       X_LAST_CYCLE_CT                ,
       X_LAST_MOD_TIME                ,
       X_LAST_PI_DATE                 ,
       X_LAST_TRANS_TIME              ,
       X_NEXT_CYCLE_CT                ,
       X_ORDER_NUMBER                 ,
       X_PART_BAD_QTY                 ,
       X_PART_GOOD_QTY                ,
       X_PI_TAG_NO                    ,
       X_PICK_REQUEST                 ,
       X_REPAIR_DATE                  ,
       X_TRANSACTION_ID               ,
       X_PI_HIST2SITE_PART            ,
	   X_MSID   ) VALUES (  --Nitin : Added X_MSID for number pooling
       -- 04/10/03 seq_x_pi_hist.nextval + power(2,28)  ,
       sa.seq('x_pi_hist')                         ,
       v_ph_code_objid                             ,
       v_current_date                              ,
       'AC CHANGE'                                 ,
       old_line_tab(v_i).x_cool_end_date           ,
       v_ph_creation_date                          ,
       old_line_tab(v_i).x_deactivation_flag       ,
       old_line_tab(v_i).x_domain                  ,
       old_line_tab(v_i).x_ext                     ,
       old_line_tab(v_i).x_insert_date             ,
       v_ph_npa                                    ,
       old_line_tab(v_i).x_nxx                     ,
       null                                        ,
       null                                        ,
       null                                        ,
       old_line_tab(v_i).part_bin                  ,
       v_ph_code                                   ,
       old_line_tab(v_i).part_mod                  ,
       v_ph_pn,        -- Nitin: Fixed bug (old_line_tab(v_i).part_serial_no - should not be used here)
       old_line_tab(v_i).part_status               ,
       old_line_tab(v_i).part_inst2carrier_mkt     ,
       old_line_tab(v_i).part_inst2inv_bin         ,
       v_ph_pi_objid                               ,
       old_line_tab(v_i).n_part_inst2part_mod      ,
       v_new_pi_userobj                            ,
       old_line_tab(v_i).part_inst2x_new_pers      ,
       old_line_tab(v_i).part_inst2x_pers          ,
       old_line_tab(v_i).x_po_num                  ,
       old_line_tab(v_i).x_reactivation_flag       ,
       old_line_tab(v_i).x_red_code                ,
       old_line_tab(v_i).x_sequence                ,
       old_line_tab(v_i).warr_end_date             ,
       old_line_tab(v_i).dev                       ,
       old_line_tab(v_i).fulfill2demand_dtl        ,
       old_line_tab(v_i).part_to_esn2part_inst     ,
       old_line_tab(v_i).bad_res_qty               ,
       old_line_tab(v_i).date_in_serv              ,
       old_line_tab(v_i).good_res_qty              ,
       old_line_tab(v_i).last_cycle_ct             ,
       old_line_tab(v_i).last_mod_time             ,
       old_line_tab(v_i).last_pi_date              ,
       old_line_tab(v_i).last_trans_time           ,
       old_line_tab(v_i).next_cycle_ct             ,
       old_line_tab(v_i).x_order_number            ,
       old_line_tab(v_i).part_bad_qty              ,
       old_line_tab(v_i).part_good_qty             ,
       old_line_tab(v_i).pi_tag_no                 ,
       old_line_tab(v_i).pick_request              ,
       old_line_tab(v_i).repair_date               ,
       old_line_tab(v_i).transaction_id            ,
       old_line_tab(v_i).x_part_inst2site_part     ,
	   v_ph_pn                --Nitin : Added X_MSID value for number pooling
       );

     END LOOP;
  END IF;
  v_upd := v_upd + 1;
  IF mod(v_upd,1000) = 0 THEN
     commit;
  END IF;
  <<next_line>>
  null;
 END LOOP;
 commit;

 p_status := 'S';
 p_msg := 'AC Change Completed.';
 IF old_line_reserved_tab.count > 0 THEN
  FOR i IN 0..old_line_reserved_tab.count-1 LOOP
    IF i = 0 THEN
      p_msg := p_msg || ' The following '||old_line_reserved_tab.count||
               ' MIN(s) are reserved by NAP and could not be updated: '||
               old_line_reserved_tab(i).part_serial_no||',';
    ELSIF i <> old_line_reserved_tab.count THEN
      p_msg := p_msg ||old_line_reserved_tab(i).part_serial_no||',';
    ELSE
      p_msg := p_msg ||old_line_reserved_tab(i).part_serial_no||'.';
    END IF;
  END LOOP;
  p_msg := substr(p_msg,1,200);
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  rollback;
  p_status := 'F';
  p_msg := v_new_pi_objid||v_step||v_new_pi_pn||' Error in procedure sp_area_code_change: '||
           substr(sqlerrm,1,100);
END;
/