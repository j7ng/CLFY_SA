CREATE OR REPLACE PACKAGE BODY sa.udp_tx_logging_pkg as

-- Create transaction record
PROCEDURE udp_log_tx_process (
        p_dealer_username       IN VARCHAR2,
        p_functionname          IN VARCHAR2,
        p_transaction_date      DATE,
        p_app_uri               IN VARCHAR2,
        p_app_name              IN VARCHAR2,
        p_remote_ip             IN VARCHAR2,
        p_sim                   IN VARCHAR2,
        p_min                   IN VARCHAR2,
        p_esn                   IN VARCHAR2, -- CR31151
        p_sequence              IN VARCHAR2, -- CR31151
        p_employee_id            IN VARCHAR2 default null,
        p_rental_agreement_no   IN VARCHAR2 default null,
        p_call_trans_objid      IN NUMBER, -- CR36213
        o_txid                  OUT NUMBER,
        o_err_code              OUT VARCHAR2,
        o_err_msg               OUT VARCHAR2)
AS
    t_objid  NUMBER;
BEGIN
   o_txid := 0;
   IF p_dealer_username IS NULL THEN
      o_err_code := '500';
      o_err_msg  := 'Dealer Username is required';
   ELSIF p_functionname IS NULL THEN
      o_err_code := '501';
      o_err_msg  := 'Function Name is required';
   ELSIF p_transaction_date IS NULL THEN
      o_err_code := '502';
      o_err_msg  := 'Transaction Date is required';
   ELSE
      BEGIN
          -- insert new transaction record
          SELECT sa.SEQ_UDP_TX_LOG_TABLE.NEXTVAL INTO t_objid FROM dual;

          INSERT INTO udp_tx_log_table
          (objid,
           x_dealer_username,
           x_functionname,
           x_transaction_date,
           x_app_uri,
           x_app_name,
           x_remote_ip,
           x_sim,
           x_min,
           x_esn,                      --CR31151
           x_sequence,                 --CR31151
           x_employee_id,
           x_rental_agreement_no,
           x_status,
         call_trans_objid
           )
          VALUES
          (t_objid,
           p_dealer_username,
           p_functionname,
           p_transaction_date,
           p_app_uri,
           p_app_name,
           p_remote_ip,
           p_sim,
           p_min,
           p_esn,                      --CR31151
           p_sequence,                 --CR31151
           p_employee_id,
           p_rental_agreement_no,
           'PENDING',
         p_call_trans_objid
           );


          o_txid := t_objid;
          o_err_code := '0';
          o_err_msg  := 'Success';
      END;
   END IF;

   EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
     o_err_code := SQLCODE;
     o_err_msg  := SQLERRM;
   RETURN;
END udp_log_tx_process;

-- Update transaction record
PROCEDURE udp_update_tx_process (
        p_txid                  IN NUMBER,
        p_status                IN VARCHAR2,
        p_dealer_objid          IN NUMBER,
        p_call_trans_objid      IN NUMBER, -- CR36213
        o_err_code              OUT VARCHAR2,
        o_err_msg               OUT VARCHAR2) AS
BEGIN
   IF p_txid = 0 THEN
      o_err_code := '500';
      o_err_msg  := 'Transaction ID is required';
   ELSIF p_status IS NULL THEN
      o_err_code := '501';
      o_err_msg  := 'Transaction STATUS is required';
   ELSE
      UPDATE udp_tx_log_table SET x_status = p_status, DEALER_OBJID = p_dealer_objid, call_trans_objid = p_call_trans_objid  WHERE objid = p_txid;

      o_err_code := '0';
      o_err_msg  := 'Success';
   END IF;

EXCEPTION
      WHEN OTHERS THEN
         o_err_code := SQLCODE;
         o_err_msg  := SQLERRM;
   RETURN;
END udp_update_tx_process;
--
-- Added by sethiraj on 2016/03/21 - CR37756 - Simple Mobile related changes.
--
PROCEDURE update_udp_tx_process_dealer (i_esn              IN VARCHAR2,
                                        i_sim              IN VARCHAR2,
                                        --i_min              IN VARCHAR2,
                                        i_call_trans_objid IN NUMBER,
                                        o_err_code      out VARCHAR2,
                                        o_err_msg       out VARCHAR2) AS
  --
  -- Get the latest transaction in up_tx_log for the given esn, sim or min
  CURSOR upd_tx_log_cur IS
    SELECT utl.objid AS udp_objid,
           tu.objid  AS dealer_objid
    FROM   table_user tu,
           udp_tx_log_table utl
    WHERE  1 = 1
    AND   ( (utl.x_esn = i_esn OR i_esn IS NULL )
            or    (utl.x_sim = i_sim OR i_sim IS NULL ) )
    and    utl.call_trans_objid is null
    --AND    (utl.x_min = i_min OR i_min IS NULL )
    AND    LOWER(tu.login_name) = LOWER(utl.x_dealer_username)
    AND    UPPER(x_status) = 'SUCCESS'
    ORDER BY utl.x_transaction_date DESC;
  --
  upd_tx_log_rec upd_tx_log_cur%ROWTYPE;

--
BEGIN

  -- validate input parameters
  IF i_esn IS NULL AND
     i_sim IS NULL
  THEN
    o_err_code := '100';
    o_err_msg  := 'esn, sim value is required.';
    RETURN;
  END IF;

  -- validate call trans is passed
  IF i_call_trans_objid IS NULL THEN
    o_err_code := '110';
    o_err_msg  := 'call trans is required.';
    RETURN;
  END IF;

  --

  OPEN upd_tx_log_cur;
  FETCH upd_tx_log_cur INTO upd_tx_log_rec;
  --
  IF upd_tx_log_cur%FOUND  THEN
    CLOSE upd_tx_log_cur;
    --
    UPDATE udp_tx_log_table
    SET    call_trans_objid = i_call_trans_objid,
           dealer_objid = upd_tx_log_rec.dealer_objid
    WHERE  objid = upd_tx_log_rec.udp_objid;
    --
    UPDATE table_x_call_trans
    SET    x_call_trans2user = upd_tx_log_rec.dealer_objid
    WHERE  objid = i_call_trans_objid;
    --
  ELSE
    CLOSE upd_tx_log_cur;
    o_err_code := '120';
    o_err_msg  := 'No record found for the given esn/sim';
    RETURN;
  END IF;

  --
  o_err_code := '0';
  o_err_msg  := 'Success';
  --

EXCEPTION
  WHEN OTHERS THEN
     o_err_code := '130';
     o_err_msg  := SUBSTR(SQLERRM,1,255);
END update_udp_tx_process_dealer;

END udp_tx_logging_pkg;
/