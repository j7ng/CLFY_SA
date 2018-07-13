CREATE OR REPLACE PACKAGE BODY sa."RAF_PROMO_PKG"
AS
/****************************************************************************************/
/* Name         :   RAF_PENDING_RECS                                                    */
/* Type         :   Procedure                                                           */
/* Purpose      :   To return all records that are pending Airtime codes                */
/* Parameters   :   Input  - No input  params                                           */
/*                  Output - No output params                                           */
/* Author       :   Gerald Pintado                                                      */
/* Date         :   05/30/2002                                                          */
/* Revisions    :   Version  Date       Who             Purpose                         */
/*                  -------  --------   -------         -----------------------         */
/*                  1.0      05/30/2002 Gpintado        Initial revision                */
/*                  1.1      04/17/2003 SL              Clarify Upgrade - sequence      */
/*                  1.2      06/16/2003 GP              friend_email validation         */
/*                  1.3      10/14/2005 NG              CR4548 delay granting of units  */
/*                  1.4      11/02/2005 GP              CR4548 fixed varchar2 issue     */
/****************************************************************************************/
PROCEDURE RAF_PENDING_RECS
IS
  --Cursor to get blast information
  CURSOR c_blast IS
    SELECT *
    FROM x_raf_blast_info;

  --Cursor to get records that need pin codes
  -- c_cust_pin_req: 0 = required, 1 = not required
  -- c_friend_pin_req: 0 = required, 1 = not required
  --
  CURSOR c_GetPendingRecs (c_blast_id number,c_cust_pin_req number, c_friend_pin_req number)
  Is
  SELECT ROWID,Customer_ESN,Friend_ESN, Friend_email
  FROM x_raf_replies
  WHERE card_objid_customer = decode(c_cust_pin_req,0,0,card_objid_customer)
  AND   card_objid_friend   = decode(c_friend_pin_req,0,0,card_objid_friend)
  AND   units_sent <> 'F' -- Not a Fraud record
  AND   register_date < sysdate -3 -- Delay Granting by 3 days
  AND   blast_id = c_blast_id;

  -- Declare pin code objid variables
  v_pin_customer varchar2(35);
  v_pin_referred varchar2(35);
  v_cust_pin_req NUMBER;
  v_friend_pin_req NUMBER;
  v_friend_ct NUMBER;
  v_result BOOLEAN;
  v_viral_flag VARCHAR2(1) := '1' ;  -- 1=friend's friend

BEGIN

 FOR c_blast_rec IN c_blast LOOP

  IF c_blast_rec.customer_part_num is not null THEN
   v_cust_pin_req := 0;
  ELSE
   v_cust_pin_req := 1;
  END IF;

  IF c_blast_rec.friend_part_num is not null THEN
   v_friend_pin_req := 0;
  ELSE
   v_friend_pin_req := 1;
  END IF;

  FOR r_GetPendingRecs IN c_GetPendingRecs(c_blast_rec.blast_id,v_cust_pin_req,v_friend_pin_req) LOOP
    -- Get units for customer ESN
    /*IF raf_award_units(r_GetPendingRecs.CustomerESN,'TS0060FREEREBATE',v_pin_customer) THEN
       -- Get units for friend ESN
       IF raf_award_units(r_GetPendingRecs.FriendESN,'TS0060FREEREBATE',v_pin_referred) THEN
        -- Updates x_raf_replies table with new pin code objids
        UPDATE x_raf_replies
        SET
         pinrefcustomer = v_pin_customer,
         pinreffriend   = v_pin_referred
        WHERE ROWID = r_GetPendingRecs.ROWID;
       END IF;
    END IF;*/
    If r_GetPendingRecs.friend_email is not null then

       v_friend_ct := 0;
       SELECT count(1) INTO v_friend_ct
       FROM x_raf_friends rf
       WHERE upper(rf.friend_email) = upper(r_GetPendingRecs.friend_email)
       AND rf.customer_esn = r_GetPendingRecs.customer_esn
       AND rf.blast_id = c_blast_rec.blast_id;

       IF v_friend_ct = 0 THEN
        INSERT INTO x_raf_friends
        (BLAST_ID         ,
         CUSTOMER_ESN     ,
         FRIEND_EMAIL     ,
         SUBMISSION_DATE  ,
         VIRAL_FLAG )  VALUES
        (c_blast_rec.blast_id,
         r_GetPendingRecs.customer_esn,
         r_GetPendingRecs.friend_email,
         trunc(sysdate),
         v_viral_flag -- friend's friend
         );
       END IF;

    END IF;

    v_pin_customer:= null;
    v_pin_referred:= null;

    IF v_cust_pin_req = 0 THEN
      v_result := raf_award_units(r_GetPendingRecs.Customer_ESN, c_blast_rec.customer_part_num,v_pin_customer);
    END IF;

    IF v_friend_pin_req = 0 THEN
      v_result := raf_award_units(r_GetPendingRecs.Friend_ESN, c_blast_rec.friend_part_num,v_pin_referred);
    END IF;

	IF v_pin_referred = 'Phone Inactive' or v_pin_customer = 'Phone Inactive'  THEN

	   --Units associated to inactive services will not be granted
	   --either customer or referred.
       UPDATE x_raf_replies
       SET units_sent = 'F'
       WHERE ROWID = r_GetPendingRecs.ROWID;

	ELSE
	   IF v_pin_customer IS NOT NULL OR v_pin_referred IS NOT NULL THEN
       UPDATE x_raf_replies
         SET
         card_objid_customer = nvl(v_pin_customer,0),
         card_objid_friend   = nvl(v_pin_referred,0)
     WHERE ROWID = r_GetPendingRecs.ROWID;
	   END IF;
    END IF;

  END LOOP; -- each replies

 END LOOP; -- each blast
 COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  dbms_output.put_line(SQLERRM || ': Contact System Administrator');
  raise_application_error(-20001, SQLERRM || ': Contact System Administrator');
END raf_pending_recs;
/****************************************************************************************/
/* Name         :   RAF_AWARD_UNITS                                                     */
/* Type         :   Function                                                            */
/* Purpose      :   To return the objid of a new PIN CODE                               */
/* Parameters   :   Input   - ip_esn, ip_part_number(PARTNUMBER)                        */
/*                  Output  - op_pin_objid (Objid of the pin code)                      */
/* Author       :   Gerald Pintado                                                      */
/* Date         :   05/30/2002                                                          */
/* Revisions    :   Version  Date       Who             Purpose                         */
/*                  -------  --------   -------         --------------------------------*/
/*                  1.0      05/30/2002 Gpintado        Initial revision                */
/****************************************************************************************/
FUNCTION RAF_AWARD_UNITS(
         ip_esn                IN       VARCHAR2,
         ip_part_number        IN       VARCHAR2,
         op_pin_objid         OUT       VARCHAR2
         ) RETURN BOOLEAN
IS
--Cursor to get the pin code from the X_PROMOTION_CODE_POOL
CURSOR c_getnewcode
IS
 SELECT rowid,x_red_code, part_serial_no
  FROM x_promotion_code_pool
  WHERE ROWNUM < 2;
 r_getnewcode     c_getnewcode%ROWTYPE;
--Cursor to get new part_inst objid
CURSOR cur_seq_part_inst
 IS
 --SELECT seq_part_inst.NEXTVAL +(POWER(2,28)) val
 select seq('part_inst') val
 FROM dual;
 rec_seq_part_inst		cur_seq_part_inst%ROWTYPE;
--
-- Looking for active site part before granting units
CURSOR cur_act_site_part
IS
select 'X'
from table_site_part
where x_service_id = ip_esn
and part_status = 'Active';

rec_act_site_part  cur_act_site_part%ROWTYPE;
--
 v_modlvl_objid   NUMBER;
 v_esn_objid      NUMBER;
BEGIN
  OPEN cur_act_site_part;
  FETCH cur_act_site_part into rec_act_site_part;
  IF cur_act_site_part%found THEN -- Active Service Found
    CLOSE cur_act_site_part;
    IF sa.promotion_pkg.getobjid(ip_esn, 'E', v_esn_objid)
    THEN
         IF sa.promotion_pkg.getobjid(ip_part_number, 'P', v_modlvl_objid)
         THEN
           OPEN c_getnewcode;
           FETCH c_getnewcode INTO r_getnewcode;
           -- return false if no codes are found
           IF c_getnewcode%notfound THEN
             CLOSE c_getnewcode;
             RETURN FALSE;
           Else
             DELETE x_promotion_code_pool
             WHERE rowid = r_getnewcode.rowid;
             COMMIT;
           END IF;
           CLOSE c_getnewcode;
--
--       Get part_inst objid
         OPEN cur_seq_part_inst;
         FETCH cur_seq_part_inst INTO rec_seq_part_inst;
         CLOSE cur_seq_part_inst;
--
--       Assign part inst objid to output param
         op_pin_objid := rec_seq_part_inst.val;
--
--       Load the assigned PIN CODE into TOSS with '40' (RESERVED) status
         INSERT INTO table_part_inst
                           (
                             objid,
                             part_serial_no,
                             x_part_inst_status,
                             x_sequence,
                             x_po_num,
                             x_red_code,
                             x_order_number,
                             x_creation_date,
                             created_by2user,
                             x_domain,
                             n_part_inst2part_mod,
                             part_inst2inv_bin,
                             part_status,
                             x_insert_date,
                             status2x_code_table,
                             part_to_esn2part_inst,
                             last_pi_date,
                             last_cycle_ct,
                             next_cycle_ct,
                             last_mod_time,
                             last_trans_time,
                             date_in_serv,
                             repair_date
                           )
                    VALUES(
                             op_pin_objid,
                             r_getnewcode.part_serial_no,
                             '40',
                             0,
                             NULL,
                             r_getnewcode.x_red_code,
                             NULL,
                             SYSDATE,
                             268435556,   -- SA objid in table_user
                             'REDEMPTION CARDS',
                             v_modlvl_objid,
                             268491209,-- "TRACFONE PROMOTION - SELL A FRIEND" objid in table_inv_bin where bin_name = 20840
                             'Active',
                             SYSDATE,
                             982,
                             v_esn_objid,
                             TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                             TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                             TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                             TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                             TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                             TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                             TO_DATE ('01-01-1753', 'DD-MM-YYYY')
                           );
           COMMIT;
         ELSE
          RETURN FALSE;
         END IF;
    ELSE
     RETURN FALSE;
    END IF;
 ELSE
    CLOSE cur_act_site_part;
    op_pin_objid := 'Phone Inactive';
	RETURN FALSE;
 END IF;
 RETURN TRUE; -- If all succeeds than return true
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  dbms_output.put_line(SQLERRM || ': Contact System Administrator');
  RETURN FALSE;
END raf_award_units;
END RAF_PROMO_PKG;
/