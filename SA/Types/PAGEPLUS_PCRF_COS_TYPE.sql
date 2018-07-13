CREATE OR REPLACE TYPE sa.pageplus_pcrf_cos_type AS OBJECT
(
 bundle_code		  VARCHAR2(50),
 cos_value		    VARCHAR2(50),
 propagate_flag		NUMBER,
 CONSTRUCTOR FUNCTION pageplus_pcrf_cos_type ( i_bundle_code     IN VARCHAR2,
                                               i_redemption_date IN DATE DEFAULT SYSDATE ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY sa."PAGEPLUS_PCRF_COS_TYPE" IS

CONSTRUCTOR FUNCTION pageplus_pcrf_cos_type ( i_bundle_code IN VARCHAR2,
                                              i_redemption_date in DATE DEFAULT SYSDATE ) RETURN SELF AS RESULT IS

bundle_cos_mapping pageplus_pcrf_cos_table;

BEGIN
  SELECT pageplus_pcrf_cos_type ( bundle_code, cos_value, propagate_flag)
  INTO   SELF
  FROM   sa.x_pageplus_cos
  WHERE  bundle_code = UPPER(TRIM(i_bundle_code))
  AND    i_redemption_date between start_date and end_date;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
   	SELF.bundle_code 	:= i_bundle_code;
   	SELF.cos_value		:= 'PP_DEFAULT';
	  SELF.propagate_flag	:= 0;
    RETURN;
END;

END;
/