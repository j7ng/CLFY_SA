CREATE OR REPLACE FUNCTION sa.EncodeNokia3390Unix(
ESN                     in string,
SEQUENCE                in double precision,
PHONE_TECHNOLOGY        in double precision,
DLLCODE                 in double precision,
DATA1                   in double precision,
DATA2                   in double precision,
DATA3                   in double precision,
DATA4                   in double precision,
DATA5                   in double precision,
DATA6                   in double precision,
DATA7                   in double precision,
DATA8                   in double precision,
DATA9                   in string,
DATA10                  in double precision,
DATA11                  in string,
GCODE_RETURN            out string)
  return pls_integer
  as
     language C
	library libEncodeNokia3390Unix
	   name "code_generator_nokia_3390_Unix"
	      parameters (
	      ESN              string,
	      SEQUENCE         double,
	      PHONE_TECHNOLOGY double,
	      DLLCODE          double,
	      DATA1            double,
	      DATA2            double,
	      DATA3            double,
	      DATA4            double,
	      DATA5            double,
	      DATA6            double,
	      DATA7            double,
	      DATA8            double,
	      DATA9            string,
	      DATA10           double,
	      DATA11           string,
	      GCODE_RETURN     string,
	      RETURN           int);
/