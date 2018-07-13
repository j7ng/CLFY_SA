CREATE OR REPLACE TYPE sa.refund_type
IS
 OBJECT
 ( esn              VARCHAR2(50),
   smp              VARCHAR2(30),
   sim              VARCHAR2(50),
   accessory_serial VARCHAR2(50),
   line_number      NUMBER,
   part_number      VARCHAR2(50),
   unit_price       NUMBER,
   quantity         NUMBER,
   sales_taxamount  NUMBER,
   e911_taxamount   NUMBER,
   usf_taxamount    NUMBER,
   rcrf_taxamount   NUMBER,
   total_taxamount  NUMBER,
   total_amount     NUMBER,
   status           VARCHAR2(50),
   CONSTRUCTOR  FUNCTION refund_type RETURN SELF AS  RESULT
 );
/