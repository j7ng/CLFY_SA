CREATE OR REPLACE PACKAGE sa.globals_pkg IS
  g_run_my_trigger   BOOLEAN := TRUE;
  g_perform_commit   BOOLEAN := TRUE;
END;
/