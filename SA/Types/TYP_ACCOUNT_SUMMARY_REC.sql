CREATE OR REPLACE TYPE sa.typ_account_summary_rec IS object
 ( MONTHLY_PLAN_CHARGES NUMBER
   ,NEW NUMBER
   ,ACTIVE NUMBER
   ,EXPIRING NUMBER
   ,EXPIRED NUMBER
 )
/