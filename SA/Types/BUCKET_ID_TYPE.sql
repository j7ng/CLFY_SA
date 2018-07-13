CREATE OR REPLACE TYPE sa.bucket_id_type IS OBJECT
(
    bucket_id 		    Varchar2(100),
    CONSTRUCTOR  FUNCTION bucket_id_type RETURN SELF AS  RESULT
);
/