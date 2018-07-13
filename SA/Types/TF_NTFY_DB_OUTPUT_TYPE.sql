CREATE OR REPLACE TYPE sa.TF_NTFY_DB_OUTPUT_TYPE IS OBJECT (
OP_RESULT                               NUMBER,
OP_MSG                                  VARCHAR2(2000));
/