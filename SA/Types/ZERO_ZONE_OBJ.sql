CREATE OR REPLACE Type sa.Zero_Zone_Obj As Object  (
  State         Varchar2(2 ),
  zone          varchar2(100),
  Market_Area   Varchar2(33),
  Marketid      Float(126),
  Carrier_Id   Float(126),
  Carrier_Name  Varchar2(255),
  Sid           varchar(10));
/