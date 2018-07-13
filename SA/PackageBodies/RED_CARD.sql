CREATE OR REPLACE PACKAGE BODY sa.red_card
AS
/*******************************************************************************************************
 * --$RCSfile: red_card_pkb.sql,v $
  --$Revision: 1.27 $
  --$Author: sraman $
  --$Date: 2017/09/05 20:06:23 $
  --$ $Log: red_card_pkb.sql,v $
  --$ Revision 1.27  2017/09/05 20:06:23  sraman
  --$ CR50918 - ITQ/SQA bug fix
  --$
  --$ Revision 1.26  2017/07/26 14:18:22  sraman
  --$ CR50939 WFM Correct dates on reactivation with a PIN from Queue - Modified invalidate_queued_pins as per SOA req.
  --$
  --$ Revision 1.25  2017/07/25 15:53:41  sraman
  --$ CR50939 WFM Correct dates on reactivation with a PIN from Queue - Incorporated Review comments
  --$
  --$ Revision 1.23  2017/07/21 15:59:25  sraman
  --$ CR50939 WFM Correct dates on reactivation with a PIN from Queue - Added new proc set_queued_pins_service_days
  --$ Merged with prod code
  --$
  --$ Revision 1.19  2017/07/12 20:49:43  sraman
  --$ CR50939 WFM TAS ? Correct dates on reactivation with AT PIN from Queue - Added new proc set_queued_pins_service_days
  --$
  --$ Revision 1.18  2017/06/08 19:30:01  nsurapaneni
  --$ Code changes to procedure invalidate_queued_pins to handle NULL input for i_card_status.
  --$
  --$ Revision 1.17  2017/06/07 21:46:59  nsurapaneni
  --$ Code changes to procedure invalidate_queued_pins to set  i_card_status  to 44 in case of NULL input
  --$
  --$ Revision 1.16  2017/06/06 22:08:33  nsurapaneni
  --$ Code changes to procedure invalidate_queued_pins  to retrieve service days.
  --$
  --$ Revision 1.14  2017/06/05 23:10:25  aganesan
  --$ CR51037 New procedure added to retrieve queued and last redeemed card details
  --$
  --$ Revision 1.13  2017/06/05 15:48:13  nsurapaneni
  --$ Invalidate queued pins  code changes to retrieve successor of PIN
  --$
  --$ Revision 1.12  2017/06/02 23:19:07  nsurapaneni
  --$ Code changes to  invalidate_queued_pins procedure to assign PIN service days to Successor PIN.
  --$
  --$ Revision 1.11  2017/04/25 15:36:22  sgangineni
  --$ CR49696 - modified the logic to update the consumer as BRM_<brand>
  --$
  --$ Revision 1.10  2017/04/20 20:41:23  sgangineni
  --$ CR49696 - fix for defect #24030 - Added new parameter i_consumer in procedure p_get_reserved_softpin
  --$
  --$ Revision 1.9  2017/03/14 21:08:11  smeganathan
  --$ WFM changed error codes in new procedures for brm discount and service days
  --$
  --$ Revision 1.8  2017/03/08 00:13:15  smeganathan
  --$ CR47564 WFM added new procedures p_get_discount_code p_get_service_days and p_get_discounts_service_days
  --$
  --$ Revision 1.7  2017/03/01 21:10:44  nsurapaneni
  --$ "All or Nothing " Changes for invalidate_queued_pins procedure
  --$
  --$ Revision 1.5  2017/02/22 22:48:16  sraman
  --$ CR47564- added new procedure  GET_PIN_SMP_FROM_PARTNUM
  --$
  --$ Revision 1.4  2017/02/21 21:47:15  nsurapaneni
  --$ Added p_invalidate_pins procedure to red_card_pkb package to invalidate list of pins.
  --$
  --$ Revision 1.2  2017/01/24 21:48:22  smeganathan
  --$ CR47564 new package to generate soft pin and for card related code
  --$
  --$ Revision 1.1  2017/01/24 21:39:13  smeganathan
  --$ CR47564 new package to generate soft pin and for card related code
  --$
  --$ Revision 1.1  2017/01/19 16:34:57  SMEGANATHAN
  --$ CR47564 - Initial version
  *********************************************************************************************************/
--
-- Copied the standalone procedure to the package
--
FUNCTION fn_getsoftpin (ip_pin_part_num  IN table_part_inst.part_serial_no%TYPE,
                        ip_inv_bin_objid IN table_inv_bin.objid%TYPE DEFAULT 0,
                        p_consumer       IN table_x_cc_red_inv.x_consumer%TYPE DEFAULT NULL,--CR42260
                        op_soft_pin      OUT table_x_cc_red_inv.x_red_card_number%TYPE,
                        op_smp_number    OUT table_x_cc_red_inv.x_smp%TYPE,
                        op_err_msg       OUT VARCHAR2)
RETURN NUMBER
IS --return 0 if successful,else return 1;
  v_ml_objid   table_mod_level.objid%TYPE;
  o_next_value NUMBER;
  o_format     VARCHAR2 (200);
  p_status     VARCHAR2 (200);
  p_msg        VARCHAR2 (200);
  v_proc_name  VARCHAR2 (80) := 'red_card.fn_getsoftpin';
  v_action     biz_error_table.error_num%TYPE;
  v_error_msg  biz_error_table.error_text%TYPE;
  card_status  CONSTANT VARCHAR2(2) := '42';
  uerror       EXCEPTION;
BEGIN
  BEGIN
      SELECT ml.objid mod_level_objid
      INTO   v_ml_objid
      FROM   table_part_num pn,
             table_mod_level ml
      WHERE  1 = 1
             AND pn.part_number = ip_pin_part_num
             AND pn.domain = 'REDEMPTION CARDS'
             AND To_char(pn.x_redeem_units) = ml.s_mod_level
             AND ml.part_info2part_num = pn.objid;
  EXCEPTION
      WHEN OTHERS THEN
        op_err_msg := 'Unable to retrieve PIN part_number'
                      ||ip_pin_part_num;
        RETURN 1;
  END;
  --
  Next_id ('X_MERCH_REF_ID', o_next_value, o_format);
  --
  Sp_reserve_app_card (o_next_value,
                       1,
                       'REDEMPTION CARDS',
                       p_consumer,
                       p_status,
                       p_msg);
  --
  IF p_msg != 'Completed'
  THEN
    v_action := 'sp_reserve_app_card failed';
    v_error_msg := Substr(p_msg, 1, 300);
    RAISE uerror;
  ELSE
    BEGIN
        SELECT x_red_card_number,
               x_smp
        INTO   op_soft_pin, op_smp_number
        FROM   table_x_cc_red_inv
        WHERE  x_reserved_id = o_next_value;
    EXCEPTION
        WHEN OTHERS THEN
          v_action := 'Unable to retrrieve pin from cc_red_inv';
          v_error_msg := Substr(SQLERRM, 1, 300);
          RAISE uerror;
    END;
  END IF;
  --
  dbms_output.Put_line('Inserting PI rec');
  --
  INSERT INTO table_part_inst
              (objid,
               last_pi_date,
               last_cycle_ct,
               next_cycle_ct,
               last_mod_time,
               last_trans_time,
               date_in_serv,
               repair_date,
               warr_end_date,
               x_cool_end_date,
               part_status,
               hdr_ind,
               x_sequence,
               x_insert_date,
               x_creation_date,
               x_domain,
               x_deactivation_flag,
               x_reactivation_flag,
               x_red_code,
               part_serial_no,
               x_part_inst_status,
               part_inst2inv_bin,
               created_by2user,
               status2x_code_table,
               n_part_inst2part_mod,
               part_to_esn2part_inst)
  VALUES      ( Seq ('part_inst'),--objid
               To_date ('01/01/1753', 'mm/dd/yyyy'),--last_pi_date
               To_date ('01/01/1753', 'mm/dd/yyyy'),--last_cycle_ct
               To_date ('01/01/1753', 'mm/dd/yyyy'),--next_cycle_ct
               To_date ('01/01/1753', 'mm/dd/yyyy'),--last_mod_time
               SYSDATE,--last_trans_time
               To_date ('01/01/1753', 'mm/dd/yyyy'),--date_in_serv
               To_date ('01/01/1753', 'mm/dd/yyyy'),--repair_date
               To_date ('01/01/1753', 'mm/dd/yyyy'),--warr_end_date
               To_date ('01/01/1753', 'mm/dd/yyyy'),--x_cool_end_date
               'Active',--part_status
               0,--hdr_ind
               0,--x_sequence
               SYSDATE,--x_insert_date
               SYSDATE,--x_creation_date
               'REDEMPTION CARDS',--x_domain
               0,--x_deactivation_flag
               0,--x_reactivation_flag
               op_soft_pin,--x_red_code
               op_smp_number,--part_serial_no
               card_status,--x_part_inst_status
               ip_inv_bin_objid,--part_inst2inv_bin
               '',--created_by2user
               (SELECT objid
                FROM   table_x_code_table
                WHERE  x_code_number = To_char(card_status)),
               --status2x_code_table
               v_ml_objid,--n_part_inst2part_mod,
               NULL); --part_to_esn2part_inst)
  --
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    IF v_error_msg IS NULL THEN
     v_error_msg := Substr (SQLERRM, 1, 200);
    END IF;
    --
    util_pkg.Insert_error_tab_proc(ip_action => v_action,
                                   ip_key => 'PIN_PART_NUM: '||ip_pin_part_num,
                                   ip_program_name => v_proc_name,
                                   ip_error_text => v_error_msg);

    RETURN 1;
END fn_getsoftpin;
--
-- Generate the soft pin and attach it to ESN with RESERVED status
PROCEDURE p_get_reserved_softpin  ( i_esn             IN  VARCHAR2,
                                    i_pin_part_num    IN  VARCHAR2,
                                    i_inv_bin_objid   IN  NUMBER    DEFAULT 0,
                                    o_soft_pin        OUT VARCHAR2,
                                    o_smp_number      OUT VARCHAR2,
                                    o_err_str         OUT VARCHAR2,
                                    o_err_num         OUT NUMBER,
                                    i_consumer        IN  VARCHAR2 DEFAULT NULL--CR49696
                                  )
IS
--Local variables declaration
l_soft_pin             NUMBER;
l_esn_count            NUMBER;
l_part_num_cnt         NUMBER;
l_inv_bin_objid        NUMBER;
l_site_id              VARCHAR2(200);
c_consumer             VARCHAR2(30) := NULL;
--
BEGIN
--
  IF  i_esn           IS NULL  OR
      i_pin_part_num  IS NULL
  THEN
    o_err_num := '921';
    o_err_str := 'ESN OR Pin Part number Cannot be NULL';
    RETURN;
  END IF;
  --
  --check ESN
  BEGIN
     SELECT 1
     INTO  l_esn_count
     FROM  table_part_inst pi_esn
     WHERE pi_esn.part_serial_no =  i_esn
     AND   pi_esn.x_domain       = 'PHONES';
     --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_num := '922'                ;
      o_err_str := 'ESN cannot be found';
      RETURN;
    WHEN OTHERS THEN
      o_err_num := '923';
      o_err_str := 'p_get_reserved_softpin - ESN Validation: '||substr(sqlerrm,1,100);
      RETURN;
  END;
  --
	-- validate pin part number.
  BEGIN
     SELECT 1
     INTO   l_part_num_cnt
     FROM   table_part_num  pn
     WHERE  1 = 1
     AND    pn.part_number             = i_pin_part_num
     AND    pn.domain                  = 'REDEMPTION CARDS';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_num := '924'                            ;
      o_err_str := 'Pin Part Number cannot be found';
      RETURN;
    WHEN OTHERS THEN
      o_err_num := '925';
      o_err_str := 'p_get_reserved_softpin : Invalid Pin Part Number'||substr(sqlerrm,1,100);
      RETURN;
  END;
  --
  IF i_inv_bin_objid = 0
  THEN
    -- Get site id
    BEGIN
      SELECT tp.X_PARAM_VALUE
      INTO   l_site_id
      FROM   table_x_parameters tp
      WHERE  tp.X_PARAM_NAME      = 'TF_INB_CC_SALES'
      AND    tp.objid             =  (SELECT MAX(tp1.objid)
                                      FROM  table_x_parameters tp1
                                      WHERE tp1.X_PARAM_NAME =  tp.X_PARAM_NAME);
    EXCEPTION
      WHEN OTHERS THEN
      o_err_num := '926';
      o_err_str := 'p_get_reserved_softpin : No record exists in Inventory BIN'||substr(sqlerrm,1,100);
      RETURN;
    END;
    --
    BEGIN
      SELECT inv.objid
      INTO   l_inv_bin_objid
      FROM   table_inv_bin inv
      WHERE  inv.location_name = l_site_id ;
    EXCEPTION
      WHEN OTHERS THEN
      o_err_num := '927';
      o_err_str := 'p_get_reserved_softpin : No record exists in Inventory BIN'||substr(sqlerrm,1,100);
      RETURN;
    END;
    --
  ELSE
    l_inv_bin_objid := i_inv_bin_objid;
  END IF;
  --
  --CR49696 changes start
  IF i_consumer IS NULL
  THEN
    IF sa.customer_info.get_brm_notification_flag (i_esn => i_esn) = 'Y'
    THEN
      c_consumer := 'BRM_'|| sa.customer_info.get_bus_org_id (i_esn => i_esn);
    END IF;
  ELSE
    c_consumer := i_consumer;
  END IF;
  --CR49696 changes end

  --getsoftpin procedure call to retrieve the soft pin and SMP.
  l_soft_pin:= red_card.fn_getsoftpin  (ip_pin_part_num  => i_pin_part_num  ,
                                        ip_inv_bin_objid => l_inv_bin_objid ,
                                        p_consumer       => c_consumer      , --CR49696
                                        op_soft_pin      => o_soft_pin      ,
                                        op_smp_number    => o_smp_number    ,
                                        op_err_msg       => o_err_str);
  --
  -- Update the PIN status to RESERVED and attach it to ESN
  UPDATE  table_part_inst
  SET     x_part_inst_status    = '40',  -- RESERVED
          status2x_code_table   = ( SELECT  objid
                                    FROM    table_x_code_table
                                    WHERE   x_code_number = '40'),
          part_to_esn2part_inst = ( SELECT  objid
                                    FROM    table_part_inst
                                    WHERE   part_serial_no  = i_esn
                                    AND     x_domain        = 'PHONES')
  WHERE   x_red_code  =   o_soft_pin
  AND     x_domain    =   'REDEMPTION CARDS';
  --
  o_err_num :=  0;
  o_err_str :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_num := '930';
    o_err_str := 'red_card.p_get_reserved_softpin:  '||substr(sqlerrm,1,100);
END p_get_reserved_softpin;
--

-- Procedure to invalidate pins
PROCEDURE invalidate_queued_pins ( i_red_card_pin_tab IN OUT red_card_pin_tab ,
                                   i_card_status      IN     VARCHAR2 DEFAULT '44',
                                   o_err_num          OUT    NUMBER,
                                   o_err_str          OUT    VARCHAR2 ) IS
  c_pin               VARCHAR2(100);
  c_card_status       VARCHAR2(100);
  c_esn               VARCHAR2(100);
BEGIN

  c_card_status:=NVL(i_card_status,'44');

  IF i_red_card_pin_tab IS NULL THEN
    o_err_num := 100;
    o_err_str := 'PINS NOT FOUND';
    RETURN;
  END IF;

  IF i_red_card_pin_tab.COUNT = 0 THEN
    o_err_num := 101;
    o_err_str := 'PINS NOT PASSED';
    RETURN;
  END IF;

  -- Loop through to check for invalid pins
  FOR rec in 1..i_red_card_pin_tab.COUNT
    LOOP
      BEGIN
        SELECT pi.x_red_code
        INTO   c_pin
        FROM   table_part_inst pi
        WHERE  pi.x_red_code = i_red_card_pin_tab(rec).pin
        AND    pi.x_domain = 'REDEMPTION CARDS';
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        o_err_num := 102;
        o_err_str := 'PIN NOT FOUND: ' || i_red_card_pin_tab(rec).pin;
        RETURN;
       WHEN OTHERS THEN
        o_err_num := 103;
        o_err_str := 'INVALID PIN PASSED: ' || i_red_card_pin_tab(rec).pin;
        RETURN;
      END;
  END LOOP;

  /* Update status , part_to_esn2part_inst and
   status2x_code_table in table_part_inst table */
  FOR rec in 1..i_red_card_pin_tab.COUNT
  LOOP
    --Get ESN correponds to the QUEUED PIN
    BEGIN
        c_esn := NULL;
        SELECT pi_esn.part_serial_no INTO c_esn
        FROM table_part_inst pi_card,
             table_part_inst pi_esn
        WHERE pi_card.x_red_code = i_red_card_pin_tab(rec).pin
        AND pi_esn.objid         = pi_card.part_to_esn2part_inst
        AND pi_card.x_domain     = 'REDEMPTION CARDS'
        AND ROWNUM               =1;
    EXCEPTION
        WHEN OTHERS THEN
        NULL;
    END;

    UPDATE table_part_inst pi
    SET    x_part_inst_status    = c_card_status ,
           part_to_esn2part_inst = NULL ,
           status2x_Code_Table = ( SELECT objid
                                   FROM   sa.table_x_code_table
                                   WHERE  x_code_type = 'CS'
                                   AND    x_code_number = c_card_status
                                   AND    ROWNUM = 1
                                 )
    WHERE  pi.x_red_code   = i_red_card_pin_tab(rec).pin
    AND    pi.x_domain     = 'REDEMPTION CARDS';

    i_red_card_pin_tab(rec).updated_status := 'Y';
    i_red_card_pin_tab(rec).message        := 'SUCCESS';
    i_red_card_pin_tab(rec).no_of_days     := customer_info.get_esn_pin_redeem_days(i_esn => c_esn,i_pin => i_red_card_pin_tab(rec).pin);
    i_red_card_pin_tab(rec).min            := customer_info.get_min ( i_esn => c_esn  );

  END LOOP;

  o_err_num := 0;
  o_err_str := 'SUCCESS';

  -- Exception Block
EXCEPTION
  WHEN OTHERS THEN
    o_err_num := 104;
    o_err_str := substr(SQLERRM,1,1000);
END invalidate_queued_pins;


--Procedure to accept list of ESN/MIN/part number , generate pin and add to reserve
PROCEDURE    GET_PIN_SMP_FROM_PARTNUM(
    op_plan_partnum_pin_det_tab IN OUT plan_partnum_pin_det_tab,
    o_err_code OUT VARCHAR2,
    o_err_msg OUT VARCHAR2 )
IS
  l_soft_pin   VARCHAR2(30);
  l_smp_number VARCHAR2(30);
  l_ret_value  NUMBER;
  l_err_msg    VARCHAR2(200);
  l_err_num    VARCHAR2(50);
  cst sa.customer_type := sa.customer_type();

  CURSOR c_part_num_det (c_part_num VARCHAR2)
  IS
    SELECT mv.service_plan_objid,
      mv.mkt_name AS service_plan_name,
      mv.plan_purchase_part_number,
      mv.service_plan_group
    FROM service_plan_feat_pivot_mv mv
    WHERE mv.plan_purchase_part_number=c_part_num;
  c_part_num_det_rec c_part_num_det%ROWTYPE;

BEGIN
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

  -- Input Validation

   IF op_plan_partnum_pin_det_tab IS NULL THEN
    o_err_code                        := '101';
    o_err_msg                         := 'PIN detail list is NULL';
    RETURN;
  END IF;

  IF op_plan_partnum_pin_det_tab.count = 0  THEN
    o_err_code                        := '102';
    o_err_msg                         := 'PIN detail list has no input value';
    RETURN;
  END IF;

  -- Update op_plan_partnum_pin_det_tab variables
  FOR i IN 1 .. op_plan_partnum_pin_det_tab.count
  LOOP
     IF op_plan_partnum_pin_det_tab(i).esn IS NULL AND op_plan_partnum_pin_det_tab(i).min IS NULL THEN
	      o_err_code               := '103';
          o_err_msg                := 'ESN and MIN are mising';
		  op_plan_partnum_pin_det_tab(i).response := o_err_msg;
		  continue;
	   END IF;

     IF op_plan_partnum_pin_det_tab(i).esn IS NULL THEN
        op_plan_partnum_pin_det_tab(i).esn := cst.get_esn ( i_min => (op_plan_partnum_pin_det_tab(i).min) );
	   END IF;

     IF op_plan_partnum_pin_det_tab(i).min IS NULL THEN
        op_plan_partnum_pin_det_tab(i).min := cst.get_min ( i_esn => (op_plan_partnum_pin_det_tab(i).esn) );
	 END IF;

    --get plan details
    OPEN c_part_num_det (op_plan_partnum_pin_det_tab(i).plan_part_number);
    FETCH c_part_num_det INTO c_part_num_det_rec;
    IF c_part_num_det%FOUND THEN
       op_plan_partnum_pin_det_tab(i).service_plan_objid := c_part_num_det_rec.service_plan_objid;
       op_plan_partnum_pin_det_tab(i).service_plan_name  := c_part_num_det_rec.service_plan_name;
       op_plan_partnum_pin_det_tab(i).service_plan_group := c_part_num_det_rec.service_plan_group;
    END IF;
    CLOSE c_part_num_det;

    --generate PIN and SMP for those many quantity
    FOR j IN 1 .. op_plan_partnum_pin_det_tab(i).part_number_quantity
    LOOP
      RED_CARD.p_get_reserved_softpin (i_esn           => op_plan_partnum_pin_det_tab(i).esn,
                                       i_pin_part_num  =>op_plan_partnum_pin_det_tab(i).plan_part_number ,
                                       i_inv_bin_objid => 0,
                                       o_soft_pin      => l_soft_pin,
                                       o_smp_number    => l_smp_number,
                                       o_err_str       => l_err_msg,
                                       o_err_num       => l_err_num
                                       );
      IF l_err_num <> '0' THEN -- p_get_reserved_softpin failed
        o_err_code   := l_err_num;
        o_err_msg    := l_err_msg;
        op_plan_partnum_pin_det_tab(i).response := l_err_msg;
        continue;
      END IF;
      -- set values
      op_plan_partnum_pin_det_tab(i).pin_list.extend;
      op_plan_partnum_pin_det_tab(i).smp_list.extend;
      op_plan_partnum_pin_det_tab(i).pin_list(j) := l_soft_pin;
      op_plan_partnum_pin_det_tab(i).smp_list(j) := l_smp_number;
      op_plan_partnum_pin_det_tab(i).response    := 'SUCCESS';
    END LOOP;
  END LOOP;

  --Exception Block
EXCEPTION
WHEN OTHERS THEN
  o_err_code := '99';
  o_err_msg  := 'Failed in when others' || SUBSTR(SQLERRM, 1,200);
END GET_PIN_SMP_FROM_PARTNUM;
--
-- Procedure to get the discount code list based on the PIN
PROCEDURE p_get_discount_code ( i_pin                   IN    VARCHAR2,
                                o_discount_code_list    OUT   discount_code_tab,
                                o_err_code              OUT   VARCHAR2,
                                o_err_msg               OUT   VARCHAR2) IS
--
  c_smp      VARCHAR2(30); -- CR52051  Data Type change
--
BEGIN
  --
  o_discount_code_list  :=  discount_code_tab ();
  --
  -- Input validation
  IF i_pin IS NULL
  THEN
    o_err_code := 301;
    o_err_msg  := 'PIN CANNOT BE NULL';
    RETURN;
  END IF;
  --
  --
  SELECT sa.customer_info.convert_pin_to_smp ( i_red_card_code => i_pin )
  INTO   c_smp
  FROM   DUAL;
  --
  IF c_smp IS NULL
  THEN
    o_err_code := 302;
    o_err_msg  := 'INVALID PIN';
    RETURN;
  END IF;
  --
  BEGIN
    SELECT discount_code_type(dl.discount_code)
    BULK COLLECT
    INTO   o_discount_code_list
    FROM   x_part_inst_ext piext,
           TABLE(piext.discount_code_list) dl
    WHERE  piext.smp = c_smp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_code := 303;
      o_err_msg  := 'PIN not found in x_part_inst_ext table';
      RETURN;
    WHEN OTHERS THEN
      o_err_code := SQLCODE;
      o_err_msg  := SQLERRM;
      RETURN;
  END;
  --
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';
--
 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := 330;
     o_err_msg := 'ERROR IN RED_CARD.P_GET_DISCOUNT_CODE:  '||substr(sqlerrm,1,100);
END p_get_discount_code;
--
-- Procedure to get the BRM service days based on the PIN
PROCEDURE p_get_service_days ( i_pin                   IN    VARCHAR2,
                               o_service_days          OUT   NUMBER,
                               o_err_code              OUT   VARCHAR2,
                               o_err_msg               OUT   VARCHAR2)
IS
--
  c_smp      VARCHAR2(30); -- CR52051  Data Type change
--
BEGIN
  --
  -- Input validation
  IF i_pin IS NULL
  THEN
    o_err_code := 401;
    o_err_msg  := 'PIN CANNOT BE NULL';
    RETURN;
  END IF;
  --
  --
  SELECT sa.customer_info.convert_pin_to_smp ( i_red_card_code => i_pin )
  INTO   c_smp
  FROM   DUAL;
  --
  IF c_smp IS NULL
  THEN
    o_err_code := 402;
    o_err_msg  := 'INVALID PIN';
    RETURN;
  END IF;
  --
  BEGIN
    SELECT piext.brm_service_days
    INTO   o_service_days
    FROM   x_part_inst_ext piext
    WHERE  piext.smp = c_smp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_code := 403;
      o_err_msg  := 'PIN not found in x_part_inst_ext table';
      RETURN;
    WHEN OTHERS THEN
      o_err_code := SQLCODE;
      o_err_msg  := SQLERRM;
      RETURN;
  END;
  --
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';
--
 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := 430;
     o_err_msg := 'ERROR IN RED_CARD.P_GET_SERVICE_DAYS:  '||substr(sqlerrm,1,100);
END p_get_service_days;
--
-- Procedure to get the BRM service days and discounts based on the PIN
PROCEDURE p_get_discounts_service_days ( i_pin                   IN    VARCHAR2,
                                         o_discount_code_list    OUT   discount_code_tab,
                                         o_service_days          OUT   NUMBER,
                                         o_err_code              OUT   VARCHAR2,
                                         o_err_msg               OUT   VARCHAR2)
IS
--
  c_smp      VARCHAR2(30); -- CR52051  Data Type change
--
BEGIN
  --
  -- Input validation
  IF i_pin IS NULL
  THEN
    o_err_code := 501;
    o_err_msg  := 'PIN CANNOT BE NULL';
    RETURN;
  END IF;
  --
  --
  SELECT sa.customer_info.convert_pin_to_smp ( i_red_card_code => i_pin )
  INTO   c_smp
  FROM   DUAL;
  --
  IF c_smp IS NULL
  THEN
    o_err_code := 502;
    o_err_msg  := 'INVALID PIN';
    RETURN;
  END IF;
  --
  BEGIN
    SELECT piext.brm_service_days
    INTO   o_service_days
    FROM   x_part_inst_ext piext
    WHERE  piext.smp = c_smp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_code := 503;
      o_err_msg  := 'PIN not found in x_part_inst_ext table';
      RETURN;
    WHEN OTHERS THEN
     o_err_code := SQLCODE;
     o_err_msg  := SQLERRM;
     RETURN;
  END;
  --
  BEGIN
    SELECT discount_code_type(dl.discount_code)
    BULK COLLECT
    INTO   o_discount_code_list
    FROM   x_part_inst_ext piext,
           TABLE(piext.discount_code_list) dl
    WHERE  piext.smp = c_smp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_code := 504;
      o_err_msg  := 'PIN not found in x_part_inst_ext table';
      RETURN;
    WHEN OTHERS THEN
     o_err_code := SQLCODE;
     o_err_msg  := SQLERRM;
     RETURN;
  END;
  --
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';
--
 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := 530;
     o_err_msg := 'ERROR IN RED_CARD.P_GET_SERVICE_DAYS:  '||substr(sqlerrm,1,100);
END p_get_discounts_service_days;
--
--CR51037 -WFM -Start
FUNCTION get_service_plan_group(i_plan_part_number IN VARCHAR2)
RETURN VARCHAR2
IS
c_service_plan_group VARCHAR2(30);
BEGIN

 SELECT spf.service_plan_group
 INTO   c_service_plan_group
 FROM   table_part_num                   pn   ,
        table_part_class                 pc   ,
        table_mod_level                  ml   ,
        service_plan_feat_pivot_mv       spf  ,
	sa.mtm_partclass_x_spf_value_def mtm  ,
	sa.x_serviceplanfeaturevalue_def spfvd,
	x_service_plan_feature           xspf ,
        x_service_plan                   sp   ,
	x_serviceplanfeature_value       spfv
 WHERE  pn.part_number            = i_plan_part_number
 AND    pn.part_num2part_class    = pc.objid
 AND    pc.objid                  = mtm.part_class_id
 AND    mtm.spfeaturevalue_def_id = spfvd.objid
 AND    spfv.value_ref            = spfvd.objid
 AND    xspf.objid                = spfv.spf_value2spf
 AND    sp.objid                  = xspf.sp_feature2service_plan
 AND    spf.service_plan_objid    = sp.objid
 AND    pn.objid                  = ml.part_info2part_num
 AND    pn.domain                 = 'REDEMPTION CARDS';

 RETURN c_service_plan_group;

EXCEPTION
  WHEN OTHERS THEN
       RETURN NULL;
END get_service_plan_group;

PROCEDURE get_esn_pin_redeem_details(i_esn                    IN  VARCHAR2 DEFAULT NULL ,
                                     i_min                    IN  VARCHAR2 DEFAULT NULL ,
                                     o_redeem_pin_details_tbl OUT redeem_pin_details_tab,
                                     o_error_num              OUT NUMBER                ,
                                     o_error_msg                OUT VARCHAR2
				    )
IS
cst sa.customer_type  := sa.customer_type();
queued_cards          sa.customer_queued_card_tab := sa.customer_queued_card_tab();
c_esn                 VARCHAR2(30);

BEGIN

 IF i_esn IS NULL AND i_min IS NULL THEN
    o_error_num := 100;
    o_error_msg   := 'Both ESN and MIN cannot be NULL';
    RETURN;
 ELSIF i_esn IS NULL AND i_min IS NOT NULL THEN
    c_esn := sa.customer_info.get_esn(i_min=> i_min);
 ELSE
    c_esn := i_esn;
 END IF;

 --Retrieve queued cards for given ESN
 queued_cards := cst.get_esn_queued_cards (i_esn => c_esn);

 SELECT  redeem_pin_details_type(pin             ,
                                 pin_part_number ,
				 pin_part_class  ,
				 pin_plan_type   ,
				 pin_service_days,
				 pin_status
				 )
 BULK COLLECT INTO o_redeem_pin_details_tbl
 FROM (SELECT
      sa.customer_info.convert_smp_to_pin(i_smp =>smp)                            pin            ,
      qc.part_number                                                              pin_part_number,
      (SELECT pc.name
       FROM  table_part_class pc,
	     table_part_num   pn
       WHERE pn.part_number         = qc.part_number
       AND   pn.part_num2part_class = pc.objid
       )                                                                          pin_part_class  ,
       sa.red_card.get_service_plan_group(i_plan_part_number => part_number) pin_plan_type   ,
       NVL(queued_days,0)                                                         pin_service_days,
       'QUEUED'                                                                   pin_status
 FROM   TABLE(CAST(queued_cards AS customer_queued_card_tab)) qc
 UNION
  SELECT rc.x_red_code                                                                 pin             ,
         pn.part_number                                                                pin_part_number ,
         pc.name                                                                       pin_part_class  ,
         sa.red_card.get_service_plan_group(i_plan_part_number => pn.part_number) pin_plan_type   ,
         ext.x_total_days                                                              pin_service_days,
	 'REDEEMED'                                                                    pin_status
 FROM   table_x_call_trans               ct ,
        table_x_call_trans_ext           ext,
        table_x_red_card                 rc ,
        table_part_num                   pn ,
        table_part_class                 pc ,
        table_mod_level                  ml
 WHERE  rc.red_card2call_trans    = ct.objid
 AND    pn.part_num2part_class    = pc.objid
 AND    ml.objid                  = rc.x_red_card2part_mod
 AND    pn.objid                  = ml.part_info2part_num
 AND    pn.domain                 = 'REDEMPTION CARDS'
 AND    ct.objid                  = ext.call_trans_ext2call_trans
 AND    ct.objid = ( SELECT MAX(objid)
                     FROM   table_x_call_trans xct
                     WHERE  x_action_type IN ( '1', '3', '6')
		     AND    x_service_id = c_esn
		     AND    x_result     = 'Completed'
                     AND EXISTS ( SELECT 1
                                  FROM   x_serviceplanfeaturevalue_def       a,
                                         sa.mtm_partclass_x_spf_value_def    b,
                                         sa.x_serviceplanfeaturevalue_def    c,
                                         sa.mtm_partclass_x_spf_value_def    d,
                                         x_serviceplanfeature_value       spfv,
                                         x_service_plan_feature           spf ,
                                         x_service_plan                   sp
                                  WHERE  a.objid = b.spfeaturevalue_def_id
                                  AND    b.part_class_id in ( SELECT pn.part_num2part_class
                                                              FROM   table_x_red_card rc,
                                                              -- validate there is a base service plan redemption from red card
                                                                     table_mod_level ml,
                                                                     table_part_num  pn
                                                              WHERE  1 = 1
                                                              AND    rc.red_card2call_trans = xct.objid
                                                              AND    ml.objid               = rc.x_red_card2part_mod
                                                              AND    pn.objid               = ml.part_info2part_num
                                                              AND    pn.domain              = 'REDEMPTION CARDS'
                                                            )
                                -- Include the base service plans only (not the add on)
                                AND NOT EXISTS ( SELECT 1
                                                 FROM   sa.service_plan_feat_pivot_mv
                                                 WHERE  service_plan_objid = sp.objid
                                                 AND    service_plan_group in('ADD_ON_DATA','ADD_ON_ILD')
                                               )
                                  AND    c.objid = d.spfeaturevalue_def_id
                                  AND    d.part_class_id = ( SELECT pn.part_num2part_class
                                                             FROM   table_part_inst pi,
                                                                    table_mod_level ml,
                                                                    table_part_num  pn
                                                             WHERE  1 = 1
                                                             AND    pi.part_serial_no   = xct.x_service_id
                                                             AND    pi.x_domain         = 'PHONES'
                                                             AND    ml.objid            = pi.n_part_inst2part_mod
                                                             AND    pn.objid            = ml.part_info2part_num
                                                             AND    pn.domain           = 'PHONES'
                                                           )
                                  AND    a.value_name   = c.value_name
                                  AND    spfv.value_ref = c.objid
                                  AND    spf.objid      = spfv.spf_value2spf
                                  AND    sp.objid       = spf.sp_feature2service_plan
                                )
                   )
       );
  --SUCCESS
  o_error_num := 0;
  o_error_msg   := 'Success';

EXCEPTION
  WHEN OTHERS THEN
       o_error_num := -1;
       o_error_msg   := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 300);
       RETURN;
--
END get_esn_pin_redeem_details;
--CR51037 -WFM -End
--
-- Procedure to set the BRM_service days of Queued pins. SOA sends the PIN/BRM_service_days
PROCEDURE set_queued_pins_service_days ( i_red_card_pin_tab IN     red_card_pin_days_tab ,
                                         o_err_num          OUT    NUMBER,
                                         o_err_str          OUT    VARCHAR2 ) IS
  c_pin                 VARCHAR2(30);
BEGIN

  IF i_red_card_pin_tab IS NULL THEN
    o_err_num := 100;
    o_err_str := 'PINS NOT FOUND';
    RETURN;
  END IF;

  IF i_red_card_pin_tab.COUNT = 0 THEN
    o_err_num := 101;
    o_err_str := 'PINS NOT PASSED';
    RETURN;
  END IF;

  -- Loop through to check for invalid pins
  FOR rec in 1..i_red_card_pin_tab.COUNT
    LOOP
      BEGIN
        SELECT pi.x_red_code
        INTO   c_pin
        FROM   table_part_inst pi
        WHERE  pi.x_red_code = i_red_card_pin_tab(rec).pin
        AND    pi.x_domain = 'REDEMPTION CARDS';
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        o_err_num := 102;
        o_err_str := 'PIN NOT FOUND: ' || i_red_card_pin_tab(rec).pin;
        RETURN;
       WHEN OTHERS THEN
        o_err_num := 103;
        o_err_str := 'INVALID PIN PASSED: ' || i_red_card_pin_tab(rec).pin;
        RETURN;
      END;
  END LOOP;

  /* Update BRM_Service_days in x_part_inst_ext table */
  FOR rec in 1..i_red_card_pin_tab.COUNT
  LOOP
     BEGIN
       UPDATE x_part_inst_ext pi_ext
       SET brm_service_days         = i_red_card_pin_tab(rec).brm_service_days
       WHERE pi_ext.part_inst_objid = (SELECT pi.objid
                                      FROM table_part_inst pi
                                      WHERE pi.x_red_code = i_red_card_pin_tab(rec).pin
                                      AND pi.x_domain     = 'REDEMPTION CARDS'
                                      );
     EXCEPTION
       WHEN OTHERS THEN
	     ROLLBACK;
        o_err_num := 104;
        o_err_str := 'UPDATE x_part_inst_ext Failed: ' || i_red_card_pin_tab(rec).pin ||SUBSTR(SQLERRM,1,500);
        RETURN;
     END;
   END LOOP;

  o_err_num := 0;
  o_err_str := 'SUCCESS';

  -- Exception Block
EXCEPTION
  WHEN OTHERS THEN
    o_err_num := 105;
    o_err_str := SUBSTR(SQLERRM,1,1000);
END set_queued_pins_service_days;
--
END red_card;
/