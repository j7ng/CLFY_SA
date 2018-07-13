CREATE OR REPLACE PROCEDURE sa.Sp_reserve_app_card (p_reserve_id NUMBER,
 p_total PLS_INTEGER,
 p_domain VARCHAR2,
												 p_consumer VARCHAR2 DEFAULT NULL,--CR42260
												 p_status OUT VARCHAR2,
												 p_msg OUT VARCHAR2)
IS
 CURSOR cards_curs IS
 SELECT /*+ INDEX_DESC( ccri X_CC_RED_INV_RSVD_FLAGINDX ) */ ROWID,
 x_red_card_number
 FROM table_x_cc_red_inv ccri
 WHERE x_reserved_flag = 0
 AND x_domain = Nvl (p_domain, 'REDEMPTION CARDS')
 AND ROWNUM < 201;
 hold_card_rec cards_curs%ROWTYPE;
 cards_found NUMBER := 0;
 cards_missed NUMBER := 0;
 l_step VARCHAR2(20);
BEGIN
 IF p_total <= 0
 OR p_total IS NULL THEN
 dbms_output.Put_line ('error p_total out of range:'
 || p_total);

 p_msg := 'No reserve card in the invertory.';

 p_status := 'N';

 RETURN;
 END IF;

 l_step := 'Step 1';

 FOR cards_rec IN cards_curs LOOP
 BEGIN
 ----------------------------------------------------------------------
 l_step := 'Step 2';

 SELECT ROWID,
 x_red_card_number
 INTO hold_card_rec.ROWID, hold_card_rec.x_red_card_number
 FROM table_x_cc_red_inv
 WHERE x_reserved_flag = 0
 AND x_domain = Nvl (p_domain, 'REDEMPTION CARDS')
 AND ROWID = cards_rec.ROWID
 FOR UPDATE NOWAIT;

 l_step := 'Step 3';

 ----------------------------------------------------------------------
 UPDATE table_x_cc_red_inv
 SET x_reserved_flag = 1,
 x_reserved_stmp = SYSDATE,
 x_reserved_id = p_reserve_id,
 x_consumer = p_consumer --CR42260
 WHERE ROWID = cards_rec.ROWID;

 dbms_output.Put_line ('X_RED_CARD_NUMBER:'
 || cards_rec.x_red_card_number);

 ----------------------------------------------------------------------
 --CR48260 added conditional commit
 IF sa.globals_pkg.g_perform_commit THEN
  COMMIT;
 END IF;

 ----------------------------------------------------------------------
 cards_found := cards_found + 1;

 dbms_output.Put_line ('cards_found:'
 || cards_found);

 l_step := 'Step 4';

 IF cards_found >= p_total THEN
 l_step := 'Step 5';

 p_msg := 'Completed';

 p_status := 'Y';

 RETURN;
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
 cards_missed := cards_missed + 1;

 dbms_output.Put_line ('skip and go to next card:'
 || cards_missed);

 toss_util_pkg.Insert_error_tab_proc (
 'Inner Loop exception failed at '
 || l_step, p_reserve_id,
 'SA.SP_RESERVE_APP_CARD');

 --CR48260 added conditional commit
 IF sa.globals_pkg.g_perform_commit THEN
  COMMIT;
 END IF;

 END;
 END LOOP;

 UPDATE table_x_cc_red_inv
 SET x_reserved_flag = 0,
 x_reserved_stmp = NULL,
 x_consumer = p_consumer --CR42260
 WHERE x_reserved_id = p_reserve_id;

 --CR48260 added conditional commit
 IF sa.globals_pkg.g_perform_commit THEN
  COMMIT;
 END IF;

 toss_util_pkg.Insert_error_tab_proc (
 'No card could be reserved after 200 tries'
 , p_reserve_id, 'SA.SP_RESERVE_APP_CARD');

 --CR48260 added conditional commit
 IF sa.globals_pkg.g_perform_commit THEN
  COMMIT;
 END IF;

 dbms_output.Put_line ('loop count:'
 || ( cards_missed + cards_found )
 || ' without reserving all cards');

 p_msg := 'No reserve card in the invertory.';

 p_status := 'N';
END sp_reserve_app_card;
/