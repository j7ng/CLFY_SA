CREATE OR REPLACE TYPE sa.ADDR_REC
IS
 object
  (
    X_BILL_ADDRESS1 VARCHAR2 (200 BYTE),
    X_BILL_ADDRESS2 VARCHAR2 (200 BYTE),
    X_BILL_CITY     VARCHAR2 (100 BYTE),
    X_BILL_STATE    VARCHAR2 (50 BYTE),
    X_BILL_ZIP      VARCHAR2 (40 BYTE),
    X_BILL_COUNTRY  VARCHAR2 (100 BYTE),
    X_SHIP_ADDRESS1 VARCHAR2 (200 BYTE),
    X_SHIP_ADDRESS2 VARCHAR2 (200 BYTE),
    X_SHIP_CITY     VARCHAR2 (30 BYTE),
    X_SHIP_STATE    VARCHAR2 (40 BYTE),
    X_Ship_Zip      Varchar2 (20 Byte),
    X_SHIP_COUNTRY  VARCHAR2 (20 BYTE),
    constructor function ADDR_REC  return self as result);
/
CREATE OR REPLACE type body sa.addr_rec  is
 constructor function addr_rec  return self as result is
 begin
    return;
 end;
end;
/