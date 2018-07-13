CREATE OR REPLACE TYPE sa.Keys_obj IS OBJECT
(
    Key_Type 		    Varchar2(80),
    Key_Value   	  Varchar2(1000),
    RESULT_VALUE  	varchar2(300),
    CONSTRUCTOR  FUNCTION Keys_obj RETURN SELF AS  RESULT
);
/