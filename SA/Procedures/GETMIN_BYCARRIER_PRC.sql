CREATE OR REPLACE PROCEDURE sa."GETMIN_BYCARRIER_PRC" (p_esn in varchar2,
                                            p_zip in varchar2,
                                            p_carrier_id in number,
                                            p_language in varchar2 default 'English',
                                            p_commit in varchar2,
                                            p_min out varchar2,
                                            p_msg out varchar2) is
-------------------------------------------------------------------------------------------------------------------
   FUNCTION update_line_prc (p_part_serial_no IN VARCHAR2)
     RETURN BOOLEAN
   is
     CURSOR c1 IS
         SELECT phones.objid
           FROM sa.table_part_inst phones
          WHERE phones.x_domain = 'PHONES'
            AND phones.part_serial_no = p_esn;
      c1_rec                  c1%ROWTYPE;
      hold_part_inst_status   VARCHAR (200);
   BEGIN
     IF p_commit = 'YES' THEN
       OPEN c1;
         FETCH c1 INTO c1_rec;
       CLOSE c1;
       SELECT x_part_inst_status
         INTO hold_part_inst_status
         FROM table_part_inst
        WHERE part_serial_no = p_part_serial_no
          AND x_part_inst_status IN ('11', '12')
          AND x_domain = 'LINES'
          FOR UPDATE NOWAIT;
       UPDATE table_part_inst
          SET x_part_inst_status = DECODE (x_part_inst_status, '11', '37', '12', '39'),
              part_to_esn2part_inst = c1_rec.objid,
              status2x_code_table = DECODE (x_part_inst_status, '11', 969, '12', 1040),
              last_cycle_ct = SYSDATE
        WHERE part_serial_no = p_part_serial_no
          AND x_part_inst_status IN ('11', '12')
          AND x_domain = 'LINES';
     END IF;
     RETURN TRUE;
     DBMS_OUTPUT.put_line ('p_commit = ' || p_commit);
   EXCEPTION WHEN OTHERS THEN
     RETURN FALSE;
   END update_line_prc;
-------------------------------------------------------------------------------------------------------------------
   FUNCTION get_line_pref_county_fun
     RETURN BOOLEAN
   IS
     CURSOR c1 (c_carrier_objid IN NUMBER) IS
         SELECT l.part_serial_no, l.x_part_inst_status, l.last_trans_time,
                l.x_insert_date
           FROM table_part_inst l,
                (SELECT DISTINCT lt.npa, lt.nxx
                            FROM npanxx2carrierzones lt, carrierzones z
                           WHERE lt.ZONE = z.ZONE
                             AND lt.state = z.st
                             AND z.zip = p_zip) tab1
          WHERE DECODE (l.x_part_inst_status,
                        '12', NVL (x_cool_end_date, SYSDATE),
                        '11', NVL (x_cool_end_date, SYSDATE)
                       ) <=
                   DECODE (l.x_part_inst_status,
                           '12', SYSDATE,
                           '11', SYSDATE
                          )
            AND l.x_domain = 'LINES'
            AND l.x_npa = tab1.npa
            AND l.x_nxx = tab1.nxx
            AND l.x_part_inst_status = '12'
            AND l.part_inst2carrier_mkt =
                          (select objid from table_x_carrier where x_carrier_id = p_carrier_id and rownum< 2)
         UNION ALL
         SELECT l.part_serial_no, l.x_part_inst_status, l.last_trans_time,
                l.x_insert_date
           FROM table_part_inst l,
                (SELECT DISTINCT lt.npa, lt.nxx
                            FROM npanxx2carrierzones lt, carrierzones z
                           WHERE lt.ZONE = z.ZONE
                             AND lt.state = z.st
                             AND z.zip = p_zip) tab1
          WHERE DECODE (l.x_part_inst_status,
                        '12', NVL (x_cool_end_date, SYSDATE),
                        '11', NVL (x_cool_end_date, SYSDATE)
                       ) <=
                   DECODE (l.x_part_inst_status,
                           '12', SYSDATE,
                           '11', SYSDATE
                          )
            AND l.x_domain = 'LINES'
            AND l.x_npa = tab1.npa
            AND l.x_nxx = tab1.nxx
            AND l.x_part_inst_status = '11'
            AND l.part_inst2carrier_mkt =
                          (select objid from table_x_carrier where x_carrier_id = p_carrier_id and rownum< 2);
   BEGIN
     for c1_rec in c1 (p_carrier_id) loop
       if update_line_prc (c1_rec.part_serial_no) = true then
         p_min := c1_rec.part_serial_no;
      --   update_c_choice_prc (c1_rec.part_serial_no, 'B');
         IF p_language = 'English' THEN
           p_msg := 'B1 Choice: Preferred local, non-roaming, and non-long distance from Tracfone MIN.';
         ELSE
           p_msg := 'Seleccion B1: Preferible para Local, sin Roaming, y sin larga distancia de TracFone MIN';
         END IF;
         RETURN TRUE;
       END IF;
     end loop;
     RETURN FALSE;
   END get_line_pref_county_fun;
-------------------------------------------------------------------------------------------------------------------
begin
  if get_line_pref_county_fun = false then
    p_msg := 'No line found for this carrier';
  end if;
end;
/