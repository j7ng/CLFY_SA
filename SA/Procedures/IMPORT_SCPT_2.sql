CREATE OR REPLACE PROCEDURE sa."IMPORT_SCPT_2" (
   ip_label         IN       VARCHAR2,
   ip_id            IN       VARCHAR2,
   out_error_text   IN OUT   VARCHAR2,
   v_sourcedb       IN       VARCHAR2 DEFAULT 'APEXPRD',
   v_src_objid      IN       NUMBER DEFAULT NULL,
   v_debug_flag     IN       BOOLEAN DEFAULT FALSE
)
IS
--$RCSfile: IMPORT_SCPT_2.sql,v $
--$Revision: 1.12 $
--$Author: hcampano $
--$Date: 2014/04/25 20:43:18 $
--$ $Log: IMPORT_SCPT_2.sql,v $
--$ Revision 1.12  2014/04/25 20:43:18  hcampano
--$ CR28519 - Development change - Ability to export missing scripts to dev boxes and tag scripts w/the scripting tool's revision id.
--$
--$ Revision 1.11  2014/04/15 17:00:09  hcampano
--$ Disabled TAS link
--$
--$ Revision 1.10  2014/04/11 19:49:45  akhan
--$ Checking in for changed link
--$
--$ Revision 1.9  2014/01/13 18:55:37  akhan
--$ fixed a bug
--$
--$ Revision 1.8  2014/01/08 22:52:08  akhan
--$ Added logging
--$
--$ Revision 1.7  2013/07/16 22:35:59  akhan
--$ Modified script not to ignore SCRIPT keyword
--$
--$ Revision 1.6  2012/07/06 22:06:07  akhan
--$ CR20211
--$
--$ Revision 1.5  2011/03/28 14:47:31  akhan
--$ Added functionality to remove duplicate scripts while exporting
--$
--$ Revision 1.4  2010/06/02 19:24:14  akhan
--$ added verbage for straight talk brand in export_variables(vfix procedure)
--$
--$ Revision 1.3  2010/05/26 14:57:08  akhan
--$ took out the format line which was causing the compile error
--$
--$ Revision 1.2  2010/04/13 18:45:34  akhan
--$ Took out PVCS header and added CVS header
--$
   x_type            VARCHAR2 (30);
   x_id              VARCHAR2 (30);
   new_objid         NUMBER;
   source_string     CLOB;
   new_string        CLOB;
   str_source1       VARCHAR2 (200);
   str_target1       VARCHAR2 (200);
   scr_no            NUMBER                 := 0;
   scr_no2           NUMBER                 := 0;
   scr_no3           NUMBER                 := 0;
   str_db_name       VARCHAR2 (20);
   str_script_hint   VARCHAR2 (200);
   v_ip_id           NUMBER;
   my_bus_org        NUMBER;
   v_scr_name        VARCHAR2 (50);
   link1             VARCHAR2 (200);
   template_id       VARCHAR2 (10);
   link2             VARCHAR2 (200)         := ',';
   part_class_id     VARCHAR2 (10);
   link3             VARCHAR2 (200)         := '" target="_blank">';
   link4             VARCHAR2 (200)         := '</a>';
   c1_stmt           VARCHAR2 (2000);
   c2_stmt           VARCHAR2 (2000);
   c3_stmt           VARCHAR2 (2000);
   start_proc        NUMBER;
   start_pc          NUMBER;
   start_admin       NUMBER;
   start_gen         NUMBER;
   end_proc          NUMBER;
   time_elapsed      NUMBER;
   TYPE r1_type IS RECORD (
      rev_objid            number,
      part_num_objid       table_part_num.objid%TYPE,
      script_text          table_x_scripts.x_script_text%TYPE,
      LANGUAGE             table_x_scripts.x_language%TYPE,
      SEQUENCE             table_x_part_script.x_sequence%TYPE,
      script_type          VARCHAR2 (60),
      company              VARCHAR2 (60),
      NAME                 table_part_class.NAME%TYPE,
      script_template_id   NUMBER,
      part_class_id        table_part_class.objid%TYPE,
      channel              varchar2(60)
   );
   c1                sys_refcursor;
   r1                r1_type;
   TYPE r2_type IS RECORD (
      rev_objid            number,
      part_class_objid     table_part_class.objid%TYPE,
      script_text          VARCHAR2 (4000),
      LANGUAGE             table_x_scripts.x_language%TYPE,
      SEQUENCE             table_x_part_script.x_sequence%TYPE,
      script_type          VARCHAR2 (60),
      company              VARCHAR2 (60),
      revision_date        DATE,
      user_name            VARCHAR2 (60),
      channel              VARCHAR2 (20),
      description          VARCHAR2 (500),
      class_name           VARCHAR2 (40),
      script_template_id   NUMBER,
      part_class_id        table_part_class.objid%TYPE,
      bus_org_objid        NUMBER
   );
   c2                sys_refcursor;
   r2                r2_type;
   TYPE r3_type IS RECORD (
      rev_objid            number,
      script_text          VARCHAR2 (4000),
      LANGUAGE             table_x_scripts.x_language%TYPE,
      SEQUENCE             table_x_part_script.x_sequence%TYPE,
      script_type          VARCHAR2 (60),
      revision_date        DATE,
      user_name            VARCHAR2 (60),
      channel              VARCHAR2 (40),
      description          VARCHAR2 (500),
      script_template_id   NUMBER,
      bus_org_objid        NUMBER
   );
   c3                sys_refcursor;
   r3                r3_type;
-----------------------------------------------------
   CURSOR find_scripts (
      script_type        VARCHAR2,
      script_id          VARCHAR2,
      part_class_objid   NUMBER,
      channel            VARCHAR2,
      ip_language        VARCHAR2,
      ip_company         VARCHAR2,
      bus_org_id         NUMBER
   )
   IS
      SELECT sc.objid,part_class_objid
        FROM sa.table_x_scripts sc, sa.mtm_part_class6_x_scripts1
       WHERE part_class2script = part_class_objid
         AND script2part_class = sc.objid
         AND x_script_type = script_type
         AND x_script_id = script_id
         AND sc.x_language = UPPER (ip_language)
         AND script2bus_org = bus_org_id
         AND x_sourcesystem = channel;
   find_script_rec   find_scripts%ROWTYPE;
-- AND x_sourcesystem = DECODE(ip_company, 'NET10', DECODE(channel, 'WEBCSR',
--  'NETCSR', 'WEB', 'NETWEB','HANDSET','NETHNADSET',channel), channel);
   -----------------------------------------------------
   CURSOR find_gen_script (
      script_type   VARCHAR2,
      script_id     VARCHAR2,
      channel       VARCHAR2,
      ip_language   VARCHAR2,
      bus_org_id    NUMBER
   )
   IS
      SELECT sc.objid
        FROM table_x_scripts sc
       WHERE x_script_type = script_type
         AND x_script_id = script_id
         AND sc.x_language = UPPER (ip_language)
         AND x_sourcesystem = channel
         AND script2bus_org = bus_org_id;
   find_gen_script_rec   find_gen_script%ROWTYPE;
-----------------------------------------------------
   FUNCTION checkdbl (sourcedb IN VARCHAR2)
      RETURN BOOLEAN
   IS
      ret   BOOLEAN;
   BEGIN
      EXECUTE IMMEDIATE 'select sysdate from dual@' || sourcedb;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;
--------------------------------------------------------
FUNCTION    VFIX (IN_STRING IN VARCHAR2,
            IN_COMPANY IN VARCHAR2,
            IN_LANGUAGE IN VARCHAR2,
            SOURCEDB IN VARCHAR2) RETURN VARCHAR2
IS
source_string VARCHAR2(4000);
str_source1 VARCHAR2(200);
str_target1 VARCHAR2(200);
c1_stmt varchar2(400);
c1 sys_refcursor;
type r1_ty is record(var_name varchar2(100),
                tf_value varchar2(100),
                nt_value varchar2(100),
                st_value varchar2(100),
                tf_value_sp varchar2(100),
                nt_value_sp varchar2(100),
                st_value_sp varchar2(100));
r1 r1_ty;
BEGIN
source_string:= IN_STRING;
if instr(source_string,'[') = 0 then
   return source_string;
end if;
c1_stmt := 'select var_name,tf_value,nt_value,st_value,tf_value_sp,nt_value_sp,st_value_sp '
         ||' from crm.export_variables@'||sourcedb
         ||' where id in (1,2,3)';
open c1 for c1_stmt;
  loop
      fetch c1 into r1;
      exit when c1%NOTFOUND;
      str_source1 :=r1.var_name;
      if upper(in_language) = 'ENGLISH' then
            if in_company = 'TRACFONE' then
               str_target1 := trim(r1.tf_value);
            elsif in_company = 'NET10' then
               str_target1 := r1.nt_value;
            else
               str_target1 := r1.st_value;
            end if;
      else
           if in_company = 'TRACFONE' then
              str_target1 := trim(r1.tf_value_sp);
           elsif in_company = 'NET10' then
              str_target1 := r1.nt_value_sp;
           else
              str_target1 := r1.st_value_sp;
           end if;
      end if;
      source_string := REPLACE(source_string,str_source1,str_target1);
  end loop;
return source_string;
END;
--------------------------------------------------------------------
procedure print_line(msg in varchar2) is
--------------------------------------------------------------------
line varchar2(300);
totlen number := length(msg);
len number := 0;
last_space number;
begin
    if totlen < 250 then
          dbms_output.put_line(msg);
          return;
    end if;
 dbms_output.put_line(' '||chr(10));
    while ( len < totlen)
    loop
         select instr(reverse(substr(msg,len,80)),' ')
         into last_space
         from dual;
         if last_space = 0 then
             select instr(reverse(substr(msg,len,80)),',')
             into last_space
             from dual;
         end if;
         dbms_output.put_line(substr(msg, len,80-last_space+1));
         len := len + 80-last_space +1;
    end loop;
end;
--------------------------------------------------------
BEGIN
   start_proc := DBMS_UTILITY.get_time;
   SELECT db_name
     INTO str_db_name
     FROM adp_db_header;
   IF (ip_label IS NULL AND ip_id IS NULL)
   THEN
      print_line ('One of ip_label or ip_id is mandatory');
      RETURN;
   END IF;
   BEGIN
      v_ip_id := NVL (TO_NUMBER (ip_id), -1);
      v_scr_name := NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_ip_id := '-2';
         v_scr_name := ip_id;
   END;
   IF (NOT checkdbl (v_sourcedb))
   THEN
      print_line('DB Link ' || v_sourcedb || ' missing');
      print_line('Cannot continue');
      out_error_text :=
                      'DB Link ' || v_sourcedb || ' missing. Process aborted';
      RETURN;
   END IF;
   EXECUTE IMMEDIATE 'select getlink@' || v_sourcedb || ' from dual'
                INTO link1;
   start_proc := dbms_utility.get_time;
   c1_stmt := 'SELECT b.id rev_objid, d.objid part_num_objid,';
   c1_stmt := c1_stmt||'b.SCRIPT_TEXT,Initcap(c.LANGUAGE) language,';
   c1_stmt := c1_stmt||'c.SEQUENCE,c.SCRIPT_TYPE,a.COMPANY,e.NAME,';
   c1_stmt := c1_stmt||'b.SCRIPT_TEMPLATE_ID,b.part_class_id,c.channel';
   c1_stmt := c1_stmt||' FROM crm.part_classes@' || v_sourcedb || ' a,';
   c1_stmt := c1_stmt||'crm.SCRIPT_REVISIONS@' || v_sourcedb || ' b,';
   c1_stmt := c1_stmt||'crm.SCRIPT_TEMPLATES@' || v_sourcedb || ' c,';
   c1_stmt := c1_stmt||'table_part_num d, table_part_class e';
   c1_stmt := c1_stmt||' WHERE nvl(b.label,'' '') = nvl('''|| ip_label;
   c1_stmt := c1_stmt||''',nvl(b.label,'' ''))';
   c1_stmt := c1_stmt||' AND a.ID = b.PART_CLASS_ID';
   c1_stmt := c1_stmt||' AND b.SCRIPT_TEMPLATE_ID = c.ID';
   c1_stmt := c1_stmt||' AND c.db_script = ''PART_SCRIPT''';
   c1_stmt := c1_stmt||' AND a.CLASS_NAME = e.name';
   IF str_db_name = 'CLFYTST' OR str_db_name = 'CLFYTOPP' then
   c1_stmt := c1_stmt||' AND b.script_text not like ''%--- MISSING SCRIPT ---%''';
   end if;
   c1_stmt := c1_stmt||' AND e.objid = d.part_num2part_class';
   c1_stmt := c1_stmt||' AND ' || v_ip_id || ' = decode(' || v_ip_id;
   c1_stmt := c1_stmt||',''-1'',''-1'',''-2'',''-2'',b.id)';
   IF v_ip_id = -2
   THEN
      c1_stmt := c1_stmt || ' AND c.script_type = ''' || v_scr_name;
      c1_stmt := c1_stmt ||''' AND b.revision_no in (SELECT MAX(sr2.REVISION_NO)';
      c1_stmt := c1_stmt || ' FROM script_templates@'|| v_sourcedb ;
      c1_stmt := c1_stmt || ' st2, script_revisions@'|| v_sourcedb|| ' sr2';
      c1_stmt := c1_stmt || ' WHERE st2.id = sr2.script_template_id';
      c1_stmt := c1_stmt || ' and sr2.script_template_id = c.ID';
      c1_stmt := c1_stmt || ' AND st2.script_type = ''' || v_scr_name || '''';
      c1_stmt := c1_stmt || ' AND sr2.part_class_id = b.part_class_id)';
   END IF;
   IF v_debug_flag
   THEN
      print_line(c1_stmt||chr(10));
   END IF;
   start_pc := DBMS_UTILITY.get_time;
   time_elapsed := (start_pc - start_proc) / 100;
   OPEN c1 FOR c1_stmt;
   LOOP
      FETCH c1
       INTO r1;
      EXIT WHEN c1%NOTFOUND;
      template_id := r1.script_template_id;
      part_class_id := r1.part_class_id;
      --
      -- TABLE INSERT STATEMENTS
      --
      IF r1.script_type <> 'WEBCODE'
      THEN
         DELETE FROM sa.table_x_part_script
               WHERE part_script2part_num = r1.part_num_objid
                 AND x_type = r1.script_type
                 AND x_language = r1.LANGUAGE;
      ELSE
         DELETE FROM sa.table_x_part_script
               WHERE part_script2part_num = r1.part_num_objid
                 AND x_type = r1.script_type
                 AND x_sequence = r1.SEQUENCE
                 AND x_language = r1.LANGUAGE;
      END IF;
      source_string :=
                    vfix (r1.script_text, r1.company, r1.LANGUAGE, v_sourcedb);
      str_source1 := '<em>';
      str_target1 := '<span class="greenInstruction">';
      new_string := REPLACE (source_string, str_source1, str_target1);
      source_string := new_string;
      str_source1 := '</em>';
      str_target1 := '</span>';
      new_string := REPLACE (source_string, str_source1, str_target1);
      source_string := new_string;
      IF str_db_name <> 'CLFYTST' AND str_db_name <> 'CLFYTOPP' and r1.channel = 'TAS' -- and 1=2 -- DISABLE IMG URL
      then
         str_script_hint := '[RID '||r1.rev_objid||']';
         new_string := new_string||str_script_hint;
/*               '<img title="'
            || r1.script_type
            || '-'
            || r1.NAME
            || '-'
            || r1.LANGUAGE
            || '-SEQ:'
            || r1.SEQUENCE
            || '" src="http://www.tracfone.com/static/common/images/plus.gif class="TecDebugLink" />';
         new_string :=
               new_string
            || link1
            || template_id
            || link2
            || part_class_id
            || link3
            || str_script_hint
            || link4; */
      END IF;
      INSERT INTO sa.table_x_part_script
                  (objid, part_script2part_num, x_script_text,
                   x_sequence, x_type, x_language
                  )
           VALUES (sa.seq ('x_part_script'), r1.part_num_objid, new_string,
                   r1.SEQUENCE, r1.script_type, r1.LANGUAGE
                  );
      scr_no := scr_no + 1;
   END LOOP;
   start_admin := DBMS_UTILITY.get_time;
   time_elapsed := (start_admin - start_pc) / 100;
   out_error_text :=
         'Part Scripts '
      || TO_CHAR (scr_no)
      || ' added or replaced('
      || time_elapsed
      || ' secs)';
   IF scr_no = 0
   THEN
      out_error_text :=
                     'Part Scripts Not Exported(' || time_elapsed || ' secs)';
   END IF;
   print_line(out_error_text);
   close c1;
   c2_stmt := 'SELECT b.id rev_objid, e.objid part_class_objid,';
   c2_stmt := c2_stmt||'b.SCRIPT_TEXT,c.LANGUAGE,c.SEQUENCE,';
   c2_stmt := c2_stmt||'c.SCRIPT_TYPE,a.COMPANY,b.REVISION_DATE,';
   c2_stmt := c2_stmt||'b.USER_NAME,c.CHANNEL,c.DESCRIPTION,a.CLASS_NAME,';
   c2_stmt := c2_stmt||'b.SCRIPT_TEMPLATE_ID,b.part_class_id,a.bus_org_objid';
   c2_stmt := c2_stmt||' FROM crm.part_classes@'|| v_sourcedb|| ' a,';
   c2_stmt := c2_stmt||' crm.SCRIPT_REVISIONS@' || v_sourcedb || ' b,';
   c2_stmt := c2_stmt||' crm.SCRIPT_TEMPLATES@' || v_sourcedb || ' c,';
   c2_stmt := c2_stmt||' table_part_class e';
   c2_stmt := c2_stmt||' WHERE nvl(b.label,'' '') = nvl(''' || ip_label ;
   c2_stmt := c2_stmt||''',nvl(b.label,'' ''))';
   c2_stmt := c2_stmt||' AND a.ID = b.PART_CLASS_ID';
   c2_stmt := c2_stmt||' AND b.SCRIPT_TEMPLATE_ID = c.ID';
   c2_stmt := c2_stmt||' AND c.db_script = ''ADMIN_TOOL''';
   if str_db_name = 'CLFYTST' or str_db_name = 'CLFYTOPP' then
   c2_stmt := c2_stmt||' AND b.script_text not like ''%--- MISSING SCRIPT ---%''';
   end if;
   c2_stmt := c2_stmt||' AND a.CLASS_NAME = e.name';
   c2_stmt := c2_stmt||' AND ' || v_ip_id || ' = decode(' || v_ip_id;
   c2_stmt := c2_stmt||',''-1'',''-1'',''-2'',''-2'',b.id)';
   IF v_ip_id = -2
   THEN
      c2_stmt := c2_stmt ||' AND c.script_type = ''' || v_scr_name ||'''';
      c2_stmt := c2_stmt ||' AND b.revision_no in (SELECT MAX(sr2.REVISION_NO)';
      c2_stmt := c2_stmt ||' FROM script_templates@' || v_sourcedb || ' st2, ';
      c2_stmt := c2_stmt ||' script_revisions@' || v_sourcedb || ' sr2 ';
      c2_stmt := c2_stmt ||' WHERE st2.id = sr2.script_template_id ';
      c2_stmt := c2_stmt ||' and sr2.script_template_id = c.ID ';
      c2_stmt := c2_stmt ||' AND st2.script_type = '''|| v_scr_name || '''';
      c2_stmt := c2_stmt ||' AND sr2.part_class_id = b.part_class_id)';
   END IF;
   IF v_debug_flag
   THEN
      print_line(c2_stmt||chr(10));
   END IF;
   OPEN c2 FOR c2_stmt;
   LOOP
      FETCH c2
       INTO r2;
      EXIT WHEN c2%NOTFOUND;
      template_id := r2.script_template_id;
      part_class_id := r2.part_class_id;
      source_string := vfix (r2.script_text, r2.company, r2.LANGUAGE, v_sourcedb);
      str_source1 := '<em>';
      str_target1 := '<span class="greenInstruction">';
      new_string := REPLACE (source_string, str_source1, str_target1);
      source_string := new_string;
      str_source1 := '</em>';
      str_target1 := '</span>';
      new_string := replace (source_string, str_source1, str_target1);
      IF str_db_name <> 'CLFYTST' AND str_db_name <> 'CLFYTOPP' and r2.channel = 'TAS' --and 1=2 -- DISABLE IMG URL
      THEN
         str_script_hint := '[RID '||r2.rev_objid||']';
         new_string := new_string||str_script_hint;
/*
         str_script_hint :=
               '<img title="'
            || r2.script_type
            || '-'
            || r2.class_name
            || '-'
            || r2.LANGUAGE
            || '-'
            || r2.channel
            || '-SEQ:'
            || r2.SEQUENCE
            || '" src="http://www.tracfone.com/static/common/images/plus.gif" class="TecDebugLink" />';
         new_string :=
               SUBSTR (new_string, 1, 3500)
            || link1
            || template_id
            || link2
            || part_class_id
            || link3
            || str_script_hint
            || link4;
*/
      END IF;
      x_type := SUBSTR (r2.script_type, 1, INSTR (r2.script_type, '_') - 1);
      x_id := SUBSTR (r2.script_type, INSTR (r2.script_type, '_') + 1);
      OPEN find_scripts (x_type,
                         x_id,
                         r2.part_class_objid,
                         r2.channel,
                         r2.LANGUAGE,
                         r2.company,
                         r2.bus_org_objid
                        );
      FETCH find_scripts
       INTO find_script_rec;
      IF find_scripts%FOUND
      THEN
         UPDATE table_x_scripts
            SET x_script_text = SUBSTR (new_string, 1, 4000),
                x_published_date = r2.revision_date,
                x_published_by = r2.user_name
          WHERE objid = find_script_rec.objid;
         scr_no2 := scr_no2 + 1;
      ELSE
         INSERT INTO sa.table_x_scripts
                     (objid, x_script_id, x_script_type, x_sourcesystem,
                      x_description, x_language, x_technology,
                      x_script_text,
                                    --X_SCRIPT_MANAGER_LINK,
                                    x_published_date,
                      x_published_by, script2bus_org
                     )
              VALUES (sa.seq ('x_scripts'), x_id, x_type, r2.channel,
                      NULL, UPPER (r2.LANGUAGE), 'ALL',
                      SUBSTR (new_string, 1, 4000),
                                                   --new_string,
                                                   r2.revision_date,
                      r2.user_name, r2.bus_org_objid
                     )
           RETURNING objid
                INTO new_objid;
         INSERT INTO sa.mtm_part_class6_x_scripts1
                     (part_class2script, script2part_class
                     )
              VALUES (r2.part_class_objid, new_objid
                     );
         scr_no2 := scr_no2 + 1;
      END IF;
      loop
        fetch find_scripts into find_script_rec;
        exit when find_scripts%NOTFOUND;
        delete mtm_part_class6_x_scripts1
        where PART_CLASS2SCRIPT = find_script_rec.objid
        and   script2part_class = find_script_rec.part_class_objid;
        delete table_x_scripts
        where objid = find_script_rec.objid;
      end loop;
      CLOSE find_scripts;
   END LOOP;
   start_gen := DBMS_UTILITY.get_time;
   time_elapsed := (start_gen - start_admin) / 100;
   out_error_text :=
         'Admin Scripts '
      || TO_CHAR (scr_no2)
      || ' added or replaced('
      || time_elapsed
      || ' secs)';
   IF scr_no2 = 0
   THEN
      out_error_text :=
                   'Admin Console Not Exported (' || time_elapsed || ' secs)';
   END IF;
   print_line(out_error_text);
   c3_stmt := 'SELECT b.id rev_objid, b.SCRIPT_TEXT,c.LANGUAGE,';
   c3_stmt := c3_stmt||'c.SEQUENCE,c.SCRIPT_TYPE,b.REVISION_DATE,';
   c3_stmt := c3_stmt||'b.USER_NAME,c.CHANNEL,c.DESCRIPTION,';
   c3_stmt := c3_stmt||'b.SCRIPT_TEMPLATE_ID,c.bus_org_objid';
   c3_stmt := c3_stmt||' FROM crm.SCRIPT_REVISIONS@' || v_sourcedb || ' b,';
   c3_stmt := c3_stmt||' crm.SCRIPT_TEMPLATES@' || v_sourcedb || ' c';
   c3_stmt := c3_stmt||' WHERE nvl(b.label,'' '') = nvl(''' || ip_label;
   c3_stmt := c3_stmt||''',nvl(b.label,'' ''))';
   c3_stmt := c3_stmt||' AND b.PART_CLASS_ID = 0 ';
   c3_stmt := c3_stmt||' AND b.SCRIPT_TEMPLATE_ID = c.ID';
   c3_stmt := c3_stmt||' AND c.db_script = ''GENERIC''';
   if str_db_name = 'CLFYTST' or str_db_name = 'CLFYTOPP' then
   c3_stmt := c3_stmt||' AND b.script_text not like ''%--- MISSING SCRIPT ---%''';
   end if;
   c3_stmt := c3_stmt||' AND '||v_ip_id|| ' = decode('|| v_ip_id;
   c3_stmt := c3_stmt||',''-1'',''-1'',''-2'',''-2'',b.id)  ';
   IF (v_ip_id = -2)
   THEN
      c3_stmt := c3_stmt ||' AND c.script_type = ''' || v_scr_name||'''';
      c3_stmt := c3_stmt ||' AND b.revision_no in (SELECT MAX(sr2.REVISION_NO)';
      c3_stmt := c3_stmt ||' FROM script_templates@'|| v_sourcedb|| ' st2, ';
      c3_stmt := c3_stmt ||' script_revisions@' || v_sourcedb || ' sr2';
      c3_stmt := c3_stmt ||' WHERE st2.id = sr2.script_template_id';
      c3_stmt := c3_stmt ||' and sr2.script_template_id = c.ID';
      c3_stmt := c3_stmt ||' AND st2.script_type = '''|| v_scr_name || '''';
      c3_stmt := c3_stmt ||' AND sr2.part_class_id = b.part_class_id)';
   END IF;
   IF v_debug_flag
   THEN
      print_line(c3_stmt||chr(10));
   END IF;
   OPEN c3 FOR c3_stmt;
   LOOP
      FETCH c3
       INTO r3;
      EXIT WHEN c3%NOTFOUND;
      template_id := r3.script_template_id;
      source_string := r3.script_text;
      str_source1 := '<em>';
      str_target1 := '<span class="greenInstruction">';
      new_string := REPLACE (source_string, str_source1, str_target1);
      source_string := new_string;
      str_source1 := '</em>';
      str_target1 := '</span>';
      new_string := REPLACE (source_string, str_source1, str_target1);
      x_type := SUBSTR (r3.script_type, 1, INSTR (r3.script_type, '_') - 1);
      x_id := SUBSTR (r3.script_type, INSTR (r3.script_type, '_') + 1);
      OPEN find_gen_script (x_type,
                                x_id,
                                r3.channel,
                                r3.LANGUAGE,
                                r3.bus_org_objid
                               );
      FETCH find_gen_script
       into find_gen_script_rec;
      IF str_db_name <> 'CLFYTST' AND str_db_name <> 'CLFYTOPP' and r3.channel = 'TAS' --and 1=2 -- DISABLE IMG URL
      then
         str_script_hint := '[RID '||r3.rev_objid||']';
         new_string := new_string||str_script_hint;
/*
         str_script_hint :=
               '<img title="'
            || r3.script_type
            || '-'
            || r3.LANGUAGE
            || '-'
            || r3.channel
            || '-SEQ:'
            || r3.SEQUENCE
            || '" src="http://www.tracfone.com/static/common/images/plus.gif" class="TecDebugLink" />';
         new_string :=
               SUBSTR (new_string, 1, 3500)
            || link1
            || template_id
            || link2
            || part_class_id
            || link3
            || str_script_hint
            || link4;
*/
      END IF;
      IF find_gen_script%FOUND
      THEN
         UPDATE table_x_scripts
            SET x_script_text = SUBSTR (new_string, 1, 4000),
                x_published_date = r3.revision_date,
                x_published_by = r3.user_name
          WHERE objid = find_gen_script_rec.objid;
         DELETE  sa.mtm_part_class6_x_scripts1
               WHERE part_class2script = find_gen_script_rec.objid;
         scr_no3 := scr_no3 + 1;
      ELSE
         INSERT INTO sa.table_x_scripts
                     (objid, x_script_id, x_script_type, x_sourcesystem,
                      x_description, x_language, x_technology,
                      x_script_text, x_published_date,
                      x_published_by, script2bus_org
                     )
              VALUES (sa.seq ('x_scripts'), x_id, x_type, r3.channel,
                      NULL, UPPER (r3.LANGUAGE), 'ALL',
                      SUBSTR (new_string, 1, 4000), r3.revision_date,
                      r3.user_name, r3.bus_org_objid
                     );
         scr_no3 := scr_no3 + 1;
      END IF;
      loop
         fetch find_gen_script into find_gen_script_rec;
         exit when find_gen_script%NOTFOUND;
         delete table_x_scripts where objid = find_gen_script_rec.objid;
      end loop;
      CLOSE find_gen_script;
   END LOOP;
   end_proc := DBMS_UTILITY.get_time;
   time_elapsed := (end_proc - start_gen) / 100;
   out_error_text :=
         'Generic Scripts '
      || TO_CHAR (scr_no3)
      || ' added or replaced('
      || time_elapsed
      || ' secs)';
   IF scr_no3 = 0
   THEN
      out_error_text := 'Generic Not Exported (' || time_elapsed || ' secs)';
   END IF;
   print_line(out_error_text);
   out_error_text :=
         'Part:'
      || scr_no
      || ' Admin:'
      || scr_no2
      || ' Generic:'
      || scr_no3
      || '('
      || TO_CHAR ((end_proc - start_proc) / 100)
      || ' secs)';
   if v_src_objid  is not null then
     begin
         execute immediate 'update crm.export_log@'||v_sourcedb
              ||' set export_summary = :summ where id = :vobjid'
         using out_error_text,v_src_objid;
     exception
          when others then null;
     end;
   end if;

   INSERT INTO sa.scripts_export_log
              (objid,
               script_rev_id,
               label,
               export_summary,
               sourcedb,
               insert_date)
        VALUES(sa.sequ_scripts_export_log.NEXTVAL,
               ip_label,
               ip_id,
               out_error_text,
               v_sourcedb,
               SYSDATE);

END;
/