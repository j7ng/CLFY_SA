CREATE OR REPLACE FUNCTION sa.Encodemotow370unix (
   esn                IN       STRING,
   SEQUENCE           IN       DOUBLE PRECISION,
   phone_technology   IN       DOUBLE PRECISION,
   dllcode            IN       DOUBLE PRECISION,
   data1              IN       DOUBLE PRECISION,
   data2              IN       DOUBLE PRECISION,
   data3              IN       DOUBLE PRECISION,
   data4              IN       DOUBLE PRECISION,
   data5              IN       DOUBLE PRECISION,
   data6              IN       DOUBLE PRECISION,
   data7              IN       DOUBLE PRECISION,
   data8              IN       DOUBLE PRECISION,
   data9              IN       STRING,
   data10             IN       DOUBLE PRECISION,
   data11             IN       STRING,
   gcode_return       OUT      STRING
)
   RETURN PLS_INTEGER
AS
   LANGUAGE c
   LIBRARY libencodemotow370unix
   NAME "code_generator_moto_w370_Unix"
   PARAMETERS (
      esn STRING,
      SEQUENCE DOUBLE,
      phone_technology DOUBLE,
      dllcode DOUBLE,
      data1 DOUBLE,
      data2 DOUBLE,
      data3 DOUBLE,
      data4 DOUBLE,
      data5 DOUBLE,
      data6 DOUBLE,
      data7 DOUBLE,
      data8 DOUBLE,
      data9 STRING,
      data10 DOUBLE,
      data11 STRING,
      gcode_return STRING,
      RETURN INT
   );
/