CREATE OR REPLACE FUNCTION sa."GET_PROMO_DEACT_FUN" (
   ip_esn          IN   VARCHAR2,
   ip_promo_code   IN   VARCHAR2
)
   RETURN NUMBER
AS
/*********************************************************************************/
/*    Copyright   2010 Tracfone  Wireless Inc. All rights reserved               */
/*                                                                               */
/* NAME:         GET_PROMO_DEACT_FUN                                             */
/* PURPOSE:      To get promo usage for an ESN                                   */
/* FREQUENCY:                                                                    */
/*                                                                               */
/* REVISIONS:                                                                    */
/* VERSION  DATE        WHO          PURPOSE                                     */
/* -------  ---------- -----  ---------------------------------------------      */
/*  1.0     02/02/10   YM    Initial  Revision                                  */
/*  1.2     02/15/10    YM   add logic for Upgrade                                  */
/*********************************************************************************/
l_deact_cnt NUMBER          := 0;
ESN_old   varchar2(30)      :='';
v_x_min   varchar2(30)      :='';
X_100     number := 0;
X_150     number := 0;
X_200     number := 0;
X_R5      number := 0;
REACT     number := 0;

 CURSOR deact_curs
 IS
   SELECT count(*)
     FROM
   (SELECT MIN ((DECODE (refurb_yes.is_refurb,0, nonrefurb_act_date.init_act_date,
     refurb_act_date.init_act_date))) act_date
 FROM (SELECT COUNT (1) is_refurb FROM table_site_part sp_a
 WHERE sp_a.x_service_id = ip_esn
       AND sp_a.x_refurb_flag = 1) refurb_yes,
 (SELECT MIN (install_date) init_act_date FROM table_site_part sp_b
  WHERE sp_b.x_service_id = ip_esn
         AND sp_b.part_status || '' IN ('Active','Inactive')
         AND x_refurb_flag <> 1) refurb_act_date,
 (SELECT MIN (install_date) init_act_date FROM table_site_part sp_d
   WHERE sp_d.x_service_id = ip_esn
          AND sp_d.part_status || '' IN ('Active', 'Inactive')) nonrefurb_act_date) orig_act_date,
  (SELECT x_start_date FROM table_x_promotion where x_promo_code = ip_promo_code) promo_start,
   (SELECT SYSDATE promo_transact_dt FROM DUAL) tab1,
     (SELECT  nvl(MIN (service_end_dt),sysdate+2) esn_deact_dt FROM table_site_part sp1, table_x_code_table tc
      WHERE sp1.x_service_id = ip_esn AND tc.x_code_type = 'DA' and (sp1.x_deact_reason = tc.x_code_name
        or  sp1.x_deact_reason ='Port In to TRACFONE')) tab2
 WHERE ((1<=(SELECT COUNT (1) FROM table_x_red_card rc, table_x_call_trans ct
  WHERE ct.objid = rc.red_card2call_trans AND ct.x_service_id = ip_esn AND ct.x_result = 'Completed'
  AND ct.x_transact_date >= orig_act_date.act_date))
  OR tab2.esn_deact_dt < orig_act_date.act_date)
   AND trunc(tab2.esn_deact_dt) >= trunc(tab1.promo_transact_dt);
  -- AND  tab1.promo_transact_dt  <  tab2.esn_deact_dt;

CURSOR min_curs
is
    select x_min
    from table_site_part
    where x_service_id = ip_esn and part_status = 'Active' and x_expire_dt > sysdate;

CURSOR ESN_OLD_curs ( xmin IN VARCHAR2)is
     select x_service_id
     from table_site_part
     where x_min = xmin and x_deact_reason in ('UPGRADE');

BEGIN

OPEN deact_curs;
FETCH deact_curs
INTO l_deact_cnt;
    -- dbms_output.put_line('devuelve '||to_char(l_deact_cnt));
   IF deact_curs%NOTFOUND
   THEN
      --dbms_output.put_line('not fount devuelve '||to_char(l_deact_cnt));
       CLOSE deact_curs;
      RETURN 0;
   END IF;

OPEN min_curs;
FETCH min_curs
INTO v_x_min;
     --dbms_output.put_line('return min '||to_char(v_x_min));
   IF min_curs%NOTFOUND
   THEN
      --dbms_output.put_line('not min '||to_char(v_x_min));
      CLOSE min_curs;
      RETURN 0;
   END IF;

OPEN ESN_OLD_curs (v_x_min);
FETCH ESN_OLD_curs
INTO ESN_OLD;

   IF ESN_OLD_curs%FOUND
   THEN
      --dbms_output.put_line('ESN old find');
      REACT:=1;
   END IF;

    IF REACT = 1 then

    select count(*) into X_100
    from table_x_group2esn, table_x_promotion p
    where groupesn2part_inst in (select objid from table_part_inst where part_serial_no =ESN_OLD
    and groupesn2x_promotion = p.objid and p.x_promo_code = 'RTNT100_R5');

     select count(*) into X_150
    from table_x_group2esn, table_x_promotion p
    where groupesn2part_inst in (select objid from table_part_inst where part_serial_no =ESN_OLD
    and groupesn2x_promotion = p.objid and p.x_promo_code = 'RTNT150_R5');

     select count(*) into X_200
    from table_x_group2esn, table_x_promotion p
    where groupesn2part_inst in (select objid from table_part_inst where part_serial_no =ESN_OLD
    and groupesn2x_promotion = p.objid and p.x_promo_code = 'RTNT200_R5');

    select count(*) into X_R5
    from table_x_group2esn, table_x_promotion p
    where groupesn2part_inst in (select objid from table_part_inst where part_serial_no =ESN_OLD
    and groupesn2x_promotion = p.objid and p.x_promo_code = 'RTNTDBL000');


     If ip_promo_code = 'RTNT100_R5' and x_100 > 0  and x_150 = 0 and x_200 = 0 and x_r5 = 0 then
            l_deact_cnt:=1;
      elsif  ip_promo_code = 'RTNT100_R5' and x_100 > 0 and (  x_150 > 0 or x_200 > 0 or x_r5 > 0 ) then
            l_deact_cnt:=0;
      elsif  ip_promo_code = 'RTNT150_R5' and x_150 > 0 and x_200 = 0 and x_r5 = 0 then
            l_deact_cnt:=1;
      elsif  ip_promo_code = 'RTNT150_R5' and x_150 > 0 and (x_200 > 0 or  x_r5 > 0) then
             l_deact_cnt:=0;
      elsif    ip_promo_code = 'RTNT200_R5' and x_200 > 0 and x_r5 = 0 then
            l_deact_cnt:=1;
      elsif    ip_promo_code = 'RTNT200_R5' and x_200 > 0 and x_r5 > 0 then
             l_deact_cnt:=0;
      elsif  ip_promo_code = 'RTNTDBL000' then
            l_deact_cnt :=1;
      end if;

     END IF;
   --dbms_output.put_line('final return '||to_char(l_deact_cnt));

    CLOSE ESN_OLD_curs;
    CLOSE min_curs;
    CLOSE deact_curs;

    RETURN l_deact_cnt;
EXCEPTION
   WHEN OTHERS
   THEN
     l_deact_cnt := 0;
      RETURN l_deact_cnt;
END GET_PROMO_DEACT_FUN;
/