CREATE OR REPLACE PROCEDURE sa."SP_RPK_ESN_REFUND" (p_esn varchar2,
                                                  p_status OUT varchar2,
                                                  p_msg OUT varchar2)
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SP_RPK_ESN_REFUND                                            */
/* PURPOSE:      Process refund by ESN                                        */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0     10/25/02   SL     Initial version                                 */
/*                                                                            */
/******************************************************************************/
IS
 l_program_name VARCHAR2(30) := 'SP_RPK_ESN_REFUND';
 l_esn VARCHAR2(30) := ltrim(rtrim(p_esn));
 CURSOR c_pi IS
  SELECT * FROM table_part_inst
  WHERE part_serial_no = l_esn;
 l_c_pi_rec c_pi%ROWTYPE;

 CURSOR c_ord_hdr IS
  SELECT hdr.*
  FROM x_republik_order_hdr hdr,
       x_republik_order_dtl dtl
  WHERE dtl.toss_order_id = hdr.toss_order_id
  AND dtl.part_serial_no = l_esn;

 l_ord_hdr_rec c_ord_hdr%ROWTYPE;
 l_dtl_cnt NUMBER := 0;

BEGIN
 IF l_esn IS NULL THEN
   p_status := 'F';
   p_msg := 'ESN is required.';
   RETURN;
 END IF;

 OPEN c_pi;
 FETCH c_pi INTO l_c_pi_rec;
 IF c_pi%NOTFOUND THEN
   CLOSE c_pi;
   p_status := 'F';
   p_msg := 'ESN '||l_esn||' does not exist in the system.';
   RETURN;
 ELSE
   CLOSE c_pi;
 END IF;

 OPEN c_ord_hdr;
 FETCH c_ord_hdr INTO l_ord_hdr_rec;
 IF c_ord_hdr%NOTFOUND THEN
   CLOSE c_ord_hdr;
   p_status := 'F';
   p_msg := 'ESN '||l_esn||' does not exist in the system.';
   RETURN;
 ELSE
   CLOSE c_ord_hdr;
 END IF;

 IF l_ord_hdr_rec.last_order_status LIKE 'REFUND%' THEN
  p_status := 'F';
  p_msg := 'Unable to process refund because refund for order ID '||l_ord_hdr_rec.toss_order_id
           ||' has been processed.';
  RETURN;
 END IF;

 SP_RPK_ORDER_REFUND (l_ord_hdr_rec.toss_order_id, p_status, p_msg);

EXCEPTION
  WHEN others THEN
   p_status := 'F';
   p_msg := l_program_name||'. Unexpected error occurred: '||substr(sqlerrm,1,100);
END;
/