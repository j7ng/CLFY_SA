CREATE OR REPLACE PROCEDURE sa.tmp_backup_script (
   p_x_type       IN       VARCHAR2,
   p_obj_id       IN       NUMBER,
   p_out_flag     OUT      NUMBER,
   p_out_msg      OUT      VARCHAR2
)
AS
   v_objid                 NUMBER            := 0;
   v_part_script2part_num  NUMBER            := 0;
   v_x_script_text         VARCHAR2 (5000);
   v_x_sequence            NUMBER            := 0;
   v_x_type                VARCHAR2(30 BYTE);
   v_x_language            VARCHAR2(12 BYTE);
   v_x_script_id           NUMBER            := 0;
BEGIN

   SELECT objid, part_script2part_num, x_script_text, x_sequence, x_type, x_language, x_script_id
   INTO v_objid, v_part_script2part_num, v_x_script_text, v_x_sequence, v_x_type, v_x_language, v_x_script_id
   FROM table_x_part_script
   WHERE part_script2part_num = p_obj_id AND x_type = p_x_type;

   INSERT INTO tmp_x_part_script_5764
   VALUES (v_objid,v_part_script2part_num, v_x_script_text,
            v_x_sequence, v_x_type, v_x_language, v_x_script_id);

   p_out_flag := 1;
   p_out_msg := NULL;

EXCEPTION
   WHEN OTHERS
   THEN
      p_out_flag := -1;
      p_out_msg := 'Ecxeption in tmp_backup_script';
      ROLLBACK;
END tmp_backup_script;
/