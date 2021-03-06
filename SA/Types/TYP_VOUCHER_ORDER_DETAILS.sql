CREATE OR REPLACE TYPE sa.TYP_VOUCHER_ORDER_DETAILS IS OBJECT (
      ORDER_ID            VARCHAR2(30)
      ,X_DESCRIPTION      VARCHAR2(500)
      ,X_TYPE             VARCHAR2(50)
      ,X_PART_NUMBER      VARCHAR2(50)
      ,X_PART_SERIAL      VARCHAR2(50)
      ,X_QUANTITY         NUMBER
      ,X_MARKET_PRICE     NUMBER
      ,X_SOLD_PRICE       NUMBER
			,STATIC FUNCTION INITIALIZE RETURN TYP_VOUCHER_ORDER_DETAILS
  )
/
CREATE OR REPLACE TYPE BODY sa.TYP_VOUCHER_ORDER_DETAILS IS
	STATIC FUNCTION INITIALIZE RETURN TYP_VOUCHER_ORDER_DETAILS IS
	BEGIN
		RETURN  TYP_VOUCHER_ORDER_DETAILS (NULL,NULL,NULL,NULL,NULL
																			,NULL,NULL,NULL
																			);
	END INITIALIZE;
END;
/