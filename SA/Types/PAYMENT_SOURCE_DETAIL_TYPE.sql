CREATE OR REPLACE TYPE sa.payment_source_detail_type  AS OBJECT
(
	payment_source_id  NUMBER,
	payment_type       VARCHAR2(50),
	payment_status     VARCHAR2(50),
	payment_src_name   VARCHAR2(30),
	is_default         VARCHAR2(50),
	user_id            VARCHAR2(50),
	first_name         VARCHAR2(100),
	last_name          VARCHAR2(100),
	email              VARCHAR2(100),
	phone_number       VARCHAR2(20) ,
	secure_date        VARCHAR2(255),
	address_info       Address_type_rec,
	cc_info            typ_creditcard_info,
	ach_info           typ_ach_info,
	aps_info           typ_aps_info,
	constructor function payment_source_detail_type  return self as result
);
/
CREATE OR REPLACE TYPE BODY sa."PAYMENT_SOURCE_DETAIL_TYPE" is
constructor function payment_source_detail_type  return self as result is
	begin
		SELF.address_info := Address_type_rec();
		SELF.cc_info      := typ_creditcard_info();
		SELF.ach_info     := typ_ach_info();
		SELF.aps_info     := typ_aps_info();
		return;
	end;
end;
/