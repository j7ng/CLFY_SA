CREATE OR REPLACE PROCEDURE sa.clear_existing_code_hist (
   p_call_trans_objid   IN   NUMBER
)
IS
BEGIN
   UPDATE table_x_code_hist
      SET x_code_accepted = 'NO - TTEST'
    WHERE code_hist2call_trans = p_call_trans_objid;

   DELETE FROM table_x_code_hist_temp
         WHERE x_code_temp2x_call_trans = p_call_trans_objid;
END clear_existing_code_hist;
/