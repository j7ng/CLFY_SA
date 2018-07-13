CREATE OR REPLACE PROCEDURE sa."WEBCSR_SCRIPTS_SPECS"
IS
   tablexscriptobjid   VARCHAR2 (25);
   sourcesystem        VARCHAR2 (20);

   CURSOR clpartclass
   IS
      SELECT DISTINCT table_part_class.objid, table_part_class.NAME
                 FROM table_part_num, table_part_class
                WHERE table_part_num.part_num2part_class =
                                                       table_part_class.objid;

   partclass_rec       clpartclass%ROWTYPE;
   partclass_counter   NUMBER                := 0;

   CURSOR cl
   IS
      SELECT   table_x_part_script.x_sequence,
               table_x_part_script.x_script_text, table_part_class.objid,
               table_part_num.x_technology, table_part_num.x_restricted_use
          FROM table_x_part_script, table_part_class, table_part_num
         WHERE table_x_part_script.x_type = 'SPECS'
           AND table_x_part_script.x_language = 'English'
           AND table_x_part_script.part_script2part_num = table_part_num.objid
           AND table_part_num.part_num2part_class = partclass_rec.objid
           AND table_part_class.NAME = partclass_rec.NAME
           AND ROWNUM = 1
      ORDER BY x_sequence;

   v_rec               cl%ROWTYPE;
   v_counter           NUMBER                := 0;
BEGIN
   OPEN clpartclass;

   LOOP
      FETCH clpartclass
       INTO partclass_rec;

      DBMS_OUTPUT.put_line ('Enter Loop OF PARTCLASS');
      EXIT WHEN clpartclass%NOTFOUND;

      OPEN cl;

      LOOP
         FETCH cl
          INTO v_rec;

         DBMS_OUTPUT.put_line ('Enter Loop');
         EXIT WHEN cl%NOTFOUND;
         tablexscriptobjid := seq ('x_scripts');
         v_counter := v_counter + 1;
         DBMS_OUTPUT.put_line ('Counter incremented');

         IF (v_rec.x_restricted_use = 3)
         THEN
            sourcesystem := 'NETCSR';
         ELSE
            sourcesystem := 'WEBCSR';
         END IF;

         INSERT INTO mtm_part_class6_x_scripts1
                     (script2part_class, part_class2script
                     )
              VALUES (tablexscriptobjid, v_rec.objid
                     );

         INSERT INTO table_x_scripts
                     (objid, dev, x_script_id, x_script_type, x_sourcesystem,
                      x_description,
                      x_language, x_technology, x_script_text,
                      x_published_by, x_published_date
                     )
              VALUES (tablexscriptobjid, 0, 4132, 'TEC', sourcesystem,
                      'gerated BY SYSTEM. please DO NOT DELETE OR MODIFY it',
                      'ENGLISH', v_rec.x_technology, v_rec.x_script_text,
                      'testuser', SYSDATE
                     );
      END LOOP;

      COMMIT;

      CLOSE cl;
   END LOOP;

   COMMIT;

   CLOSE clpartclass;

   DBMS_OUTPUT.put_line (v_counter);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM);
      ROLLBACK;
END;
/