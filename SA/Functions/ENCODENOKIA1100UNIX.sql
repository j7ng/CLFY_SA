CREATE OR REPLACE FUNCTION sa.Encodenokia1100unix(
ESN                     IN string,
SEQUENCE                IN DOUBLE PRECISION,
PHONE_TECHNOLOGY        IN DOUBLE PRECISION,
DLLCODE                 IN DOUBLE PRECISION,
DATA1                   IN DOUBLE PRECISION,
DATA2                   IN DOUBLE PRECISION,
DATA3                   IN DOUBLE PRECISION,
DATA4                   IN DOUBLE PRECISION,
DATA5                   IN DOUBLE PRECISION,
DATA6                   IN DOUBLE PRECISION,
DATA7                   IN DOUBLE PRECISION,
DATA8                   IN DOUBLE PRECISION,
DATA9                   IN string,
DATA10                  IN DOUBLE PRECISION,
DATA11                  IN string,
GCODE_RETURN            OUT string)
  RETURN PLS_INTEGER
  AS
     LANGUAGE C
    library libEncodeNokia1100Unix
       name "code_generator_nokia_1100_Unix"
          parameters (
          ESN              string,
          SEQUENCE         DOUBLE,
          PHONE_TECHNOLOGY DOUBLE,
          DLLCODE          DOUBLE,
          DATA1            DOUBLE,
          DATA2            DOUBLE,
          DATA3            DOUBLE,
          DATA4            DOUBLE,
          DATA5            DOUBLE,
          DATA6            DOUBLE,
          DATA7            DOUBLE,
          DATA8            DOUBLE,
          DATA9            string,
          DATA10           DOUBLE,
          DATA11           string,
          GCODE_RETURN     string,
          RETURN           INT);
/