CREATE OR REPLACE TYPE sa.TYP_VOUCHER_ORDER IS OBJECT (
      ORDER_ID                VARCHAR2(50)
      ,ORDER_DATE             DATE
      ,ORDER_SOURCE           VARCHAR2(50)
      ,X_BRAND                VARCHAR2(100)
      ,CUSTOMER_NAME          VARCHAR2(200)
      ,CUSTOMER_ACCOUNT_ID    VARCHAR2(200)
      ,CUSTOMER_MIN           VARCHAR2(30)
      ,ORDER_AMOUNT           NUMBER		  --the order amount (thats device cost + taxes etc)
      ,X_BENEFIT_AMOUNT       NUMBER      --actual benefit amount  that has been used
      ,TAX_TOTAL              NUMBER
      ,TAX_SALES              NUMBER
      ,TAX_SALES_RATE         NUMBER
      ,TAX_E911               NUMBER
      ,TAX_E911_RATE          NUMBER
      ,TAX_USF                NUMBER
      ,TAX_USF_RATE           NUMBER
      ,TAX_RCRF               NUMBER
      ,TAX_RCRF_RATE          NUMBER
			,SHIPPING_ADDRESS_1	    VARCHAR2(500)
			,SHIPPING_ADDRESS_2	    VARCHAR2(500)
			,SHIPPING_ZIPCODE	      VARCHAR2(10)
			,SHIPPING_CITY	        VARCHAR2(500)
			,SHIPPING_STATE	        VARCHAR2(500)
			,SHIPPING_COUNTRY	      VARCHAR2(500)
      ,SHIPPING_AMOUNT        NUMBER
      ,SHIPPING_METHOD        VARCHAR2(500)
			,STATIC FUNCTION INITIALIZE RETURN  TYP_VOUCHER_ORDER
)
/
CREATE OR REPLACE TYPE BODY sa.TYP_VOUCHER_ORDER IS
	STATIC FUNCTION INITIALIZE RETURN TYP_VOUCHER_ORDER IS
	BEGIN
		RETURN  TYP_VOUCHER_ORDER (NULL,NULL,NULL,NULL,NULL
															,NULL,NULL,NULL,NULL,NULL
															,NULL,NULL,NULL,NULL,NULL
															,NULL,NULL,NULL,NULL,NULL
															,NULL,NULL,NULL,NULL,NULL
                              ,NULL
															);
	END INITIALIZE;
END;
/