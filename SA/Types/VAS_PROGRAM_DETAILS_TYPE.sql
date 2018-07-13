CREATE OR REPLACE TYPE sa.vas_program_details_type
IS
OBJECT  (
          prog_id                     NUMBER,        -- not needed for eligible
          x_program_name              VARCHAR2(100), -- needed for legacy hpp
          x_program_desc              VARCHAR2(1000),-- needed for legacy hpp
          x_retail_price              NUMBER,
          status                      VARCHAR2(100),
          part_number                 VARCHAR2(30),
          part_class                  VARCHAR2(30),
          auto_pay_enrolled           VARCHAR2(1),
          next_charge_date            DATE,         -- only for auto pay not for monthly.
          x_charge_frq_code           VARCHAR2(30),
          auto_pay_available          VARCHAR2(1),  -- only for eligbile services / enrolled monthly LNS
          enroll_expiry_date          DATE,
          is_due_flag                 VARCHAR2(1),
          x_enrolled_date             DATE,
          x_purch_hdr_objid           NUMBER,
          program_purch_hdr_objid     NUMBER,
          deductible_amount           NUMBER,
          device_price_tier           NUMBER,
          mobile_name                 VARCHAR2(30),
          mobile_description          VARCHAR2(30),
          mobile_more_info            VARCHAR2(30),
          terms_condition_link        VARCHAR2(1000),
          vas_name                    VARCHAR2(100),
          vas_category                VARCHAR2(100),
          vas_product_type            VARCHAR2(100),
          vas_description_english     VARCHAR2(100),
          vas_type                    VARCHAR2(100),
          vas_vendor                  VARCHAR2(100),
          vas_service_id              NUMBER,
          vas_subscription_id         NUMBER,
          vas_offer_expiry_date       DATE,         -- only for eligible
          transfer_eligible_flag      VARCHAR2(1),
          refund_applicable_flag      VARCHAR2(1),
          service_days                NUMBER,
          proration_applied_flag      VARCHAR2(1),  -- only for eligible, non enrolled services
          electronic_refund_days      NUMBER,
          vendor_contract_id          VARCHAR2(100),
          reason                      VARCHAR2(255), -- only for suspend status
          esn_contact_objid           NUMBER,
          program_enrolled_id         NUMBER,       -- only for enrolled services
          refund_case_id              VARCHAR2(255),
          refund_amount               NUMBER,
          refund_type                 VARCHAR2(100),
          payment_source_objid        NUMBER,
          CONSTRUCTOR  FUNCTION vas_program_details_type RETURN SELF AS  RESULT
        );
/
CREATE OR REPLACE TYPE BODY sa.vas_program_details_type IS
--
CONSTRUCTOR FUNCTION vas_program_details_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;
END;
/