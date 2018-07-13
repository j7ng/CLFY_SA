CREATE OR REPLACE PROCEDURE sa.add_case_notes_prc (
   p_id_number   IN       VARCHAR2,
   p_notes       IN       VARCHAR2,
   p_out_err     OUT      NUMBER,
   p_out_msg     OUT      VARCHAR2
)
AS
   v_case_history   VARCHAR2 (2000);
BEGIN
   SELECT case_history
     INTO v_case_history
     FROM table_case
    WHERE id_number = p_id_number;

   v_case_history := v_case_history || CHR (10) || p_notes;

   UPDATE table_case
      SET case_history = v_case_history
    WHERE id_number = p_id_number;

   IF SQL%ROWCOUNT >= 1
   THEN
      p_out_err := 0;
      p_out_msg := 'S';
      COMMIT;
   ELSE
      p_out_err := 1;
      p_out_msg := 'F';
   END IF;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      p_out_err := 1;
      p_out_msg := 'F';
      ROLLBACK;
END add_case_notes_prc;
/