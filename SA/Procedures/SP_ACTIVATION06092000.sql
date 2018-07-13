CREATE OR REPLACE PROCEDURE sa."SP_ACTIVATION06092000"
   (var_insert_or_update in varchar2,
    var_part_status IN VARCHAR2,
    var_phone IN VARCHAR2,
    var_esn IN VARCHAR2,
    var_cust_id IN VARCHAR2,
    var_carrier_id IN NUMBER,
    var_dealer_id IN VARCHAR2,
    var_action IN NUMBER,
    var_reason_code IN VARCHAR2,
    var_line_worked IN VARCHAR2,
    var_line_worked_by IN VARCHAR2,
    var_line_worked_dt IN DATE,
    var_islocked IN VARCHAR2,
    var_locked_by IN VARCHAR2,
    var_action_type_id IN NUMBER,
    var_ig_status IN VARCHAR2,
    var_ig_error IN VARCHAR2,
    var_cust_pin IN VARCHAR2,
    var_phone_manufacturer IN VARCHAR2,
    var_initial_act_date IN DATE,
    var_end_user_name IN VARCHAR2) is
cursor cur_flag is
    SELECT x_esn_change_flag
      FROM
      table_x_carrier c,
      table_x_carrier_rules cr
      WHERE c.x_carrier_id = var_carrier_id
             and c.objid  = cr.objid
  and rownum = 1;
flag_rec cur_flag%rowtype;
cursor c2 is
    SELECT 1
    FROM x_min_esn_change
    WHERE x_min = var_phone;
var_flag NUMBER;
var_act NUMBER := 0;
var_action_loc varchar2(1);
var_min number;
BEGIN
   IF var_part_status = 'Active' then
 var_action_loc := 'A';
   ELSIF var_part_status = 'Inactive' and var_action = 1 then
 var_action_loc := 'D';
   ELSE var_action_loc := 'S';
   end if;
  var_flag := 0;
    open cur_flag;
      fetch cur_flag into flag_rec;
--    IF flag_rec.x_esn_change_flag = 1 and var_action_loc = 'S' then
      IF var_action_loc = 'S' then
        INSERT INTO x_min_esn_change (X_TRANSACTION_ID,
                                      X_ATTACHED_DATE,
                                      X_MIN,
                                      X_OLD_ESN,
                                      X_DETACH_DT,
                                      X_NEW_ESN)
                              VALUES (seq_x_transact_id.nextval + (power(2,28)),
                                      NULL,
                                      var_phone,
                                      var_esn,
                                      sysdate,
                                      NULL);
         var_act := 1;
      END IF;
    close cur_flag;
    open c2;
 fetch c2 into var_min;
      if c2%found and var_action_loc = 'A' then
--------------------------
   /* update esn_change */
--------------------------
        UPDATE x_min_esn_change
        SET X_ATTACHED_DATE = sysdate,
            X_NEW_ESN       = var_esn
        WHERE x_min           = var_phone and
      X_ATTACHED_DATE is null and
    X_NEW_ESN is null;
   var_act := 1;
      END IF;
    close c2;
 /* populate monitor table */
 /* Updated by JR 5/10/00 */
if var_reason_code <> 'AC CHANGE' or var_reason_code is null then
  INSERT INTO x_monitor (X_MONITOR_ID,
   X_DATE_MVT,
   X_PHONE,
   X_ESN,
   X_CUST_ID,
   X_CARRIER_ID,
   X_DEALER_ID,
   X_ACTION,
   X_REASON_CODE,
   X_LINE_WORKED,
   X_LINE_WORKED_BY,
   X_LINE_WORKED_DATE,
   X_ISLOCKED,
   X_LOCKED_BY,
   X_ACTION_TYPE_ID,
   X_IG_STATUS,
   X_IG_ERROR,
   X_PIN,
   X_MANUFACTURER,
   X_INITIAL_ACT_DATE,
   X_END_USER)
  VALUES
   ((seq_x_monitor_id.nextval + (power(2,28))),
   sysdate,
   var_phone,
   var_esn,
   var_cust_id,
--   concat('1',lpad(var_carrier_id,9,'0')),
   to_char(var_carrier_id),
   var_dealer_id,
   var_action_loc,
   var_reason_code,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   var_act,
   NULL,
   NULL,
   var_cust_pin,
   var_phone_manufacturer,
   var_initial_act_date,
   var_end_user_name);
end if;
END SP_ACTIVATION06092000;
/