CREATE OR REPLACE TYPE sa.typ_pymt_src_dtls_rec  AS OBJECT
(
    payment_source_id  NUMBER,
    payment_type       VARCHAR2(50),
    payment_status     VARCHAR2(50),
    is_default         VARCHAR2(50),
    user_id            VARCHAR2(50),
    cc_info            typ_creditcard_info,
    first_name         VARCHAR2(100),
    last_name          VARCHAR2(100),
    email              VARCHAR2(100),
    address_info       Address_type_rec,
    secure_date        VARCHAR2(255),
    ach_info           typ_ach_info,
    aps_info           typ_aps_info,
    constructor function typ_pymt_src_dtls_rec  return self as result,
	--CR47564 WFM --START
	constructor function typ_pymt_src_dtls_rec (i_payment_source_detail_rec IN payment_source_detail_type) return SELF as result
	--CR47564 WFM --END
    );
/
CREATE OR REPLACE TYPE BODY sa."TYP_PYMT_SRC_DTLS_REC" is
constructor function typ_pymt_src_dtls_rec  return self as result is
begin

    SELF.cc_info      := typ_creditcard_info();
    SELF.address_info := Address_type_rec();
	SELF.ach_info     := typ_ach_info();
	SELF.aps_info     := typ_aps_info();
    return;
end;

--CR47564 WFM --START
CONSTRUCTOR FUNCTION typ_pymt_src_dtls_rec ( i_payment_source_detail_rec IN payment_source_detail_type) RETURN SELF AS RESULT IS
BEGIN
    --
	SELF.payment_source_id := i_payment_source_detail_rec.payment_source_id;
    SELF.payment_type      := i_payment_source_detail_rec.payment_type     ;
	SELF.payment_status    := i_payment_source_detail_rec.payment_status   ;
	SELF.is_default        := i_payment_source_detail_rec.is_default       ;
	SELF.user_id           := i_payment_source_detail_rec.user_id          ;
    SELF.first_name        := i_payment_source_detail_rec.first_name       ;
	SELF.last_name         := i_payment_source_detail_rec.last_name        ;
	SELF.email             := i_payment_source_detail_rec.email            ;
	SELF.secure_date       := i_payment_source_detail_rec.secure_date      ;
    --
	SELF.address_info      := i_payment_source_detail_rec.address_info     ;
	SELF.cc_info           := i_payment_source_detail_rec.cc_info          ;
	SELF.ach_info          := i_payment_source_detail_rec.ach_info         ;
	SELF.aps_info          := i_payment_source_detail_rec.aps_info         ;

	--	Initializing
	IF SELF.address_info IS NULL
	THEN
	  SELF.address_info := Address_type_rec();
	END IF;
	--
	IF SELF.cc_info IS NULL
	THEN
	  SELF.cc_info := typ_creditcard_info();
	END IF;
    --
	IF SELF.ach_info IS NULL
	THEN
	  SELF.ach_info := typ_ach_info();
	END IF;
    --
	IF SELF.aps_info IS NULL
	THEN
	  SELF.aps_info := typ_aps_info();
	END IF;

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
    RETURN;
END;
--CR47564 WFM --END
end;
/