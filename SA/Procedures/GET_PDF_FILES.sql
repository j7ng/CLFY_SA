CREATE OR REPLACE PROCEDURE sa.get_pdf_files (i_web_user_objid   IN    NUMBER,
                                           o_refcursor        OUT   SYS_REFCURSOR,
                                           o_err_code         OUT   VARCHAR2,
                                           o_err_msg          OUT   VARCHAR2
                                          )
IS
BEGIN
  IF i_web_user_objid IS NULL
  THEN
    o_err_code := '1001';
    o_err_msg := 'INPUT WEB USER OBJID IS NOT PASSED';
    RETURN;
  END IF;

  OPEN o_refcursor
  FOR SELECT '/' || invoice_year || '/' ||invoice_month || '/' || hash_value as hash_file
            ,invoice_month as month
            ,invoice_year as year
      FROM   sa.x_wfm_hash
      WHERE  web_user_objid = i_web_user_objid;

  o_err_code := '0';
  o_err_msg  := 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    o_err_code := SQLCODE;
    o_err_msg  := SUBSTR(SQLERRM, 1, 1000);
END get_pdf_files;
/