CREATE OR REPLACE TYPE sa.ig_features_type AS OBJECT
(
  transaction_id  NUMBER,
  number_of_features NUMBER,
  feature_0       VARCHAR2(100),
  feature_value_0 VARCHAR2(100),
  feature_1       VARCHAR2(100),
  feature_value_1 VARCHAR2(100),
  feature_2       VARCHAR2(100),
  feature_value_2 VARCHAR2(100),
  feature_3       VARCHAR2(100),
  feature_value_3 VARCHAR2(100),
  feature_4       VARCHAR2(100),
  feature_value_4 VARCHAR2(100),
  feature_5 VARCHAR2(100),
  feature_value_5 VARCHAR2(100),
  feature_6 VARCHAR2(100),
  feature_value_6 VARCHAR2(100),
  feature_7 VARCHAR2(100),
  feature_value_7 VARCHAR2(100),
  feature_8 VARCHAR2(100),
  feature_value_8 VARCHAR2(100),
  feature_9 VARCHAR2(100),
  feature_value_9 VARCHAR2(100),
  feature_10 VARCHAR2(100),
  feature_value_10 VARCHAR2(100),
  feature_11 VARCHAR2(100),
  feature_value_11 VARCHAR2(100),
  feature_12 VARCHAR2(100),
  feature_value_12 VARCHAR2(100),
  feature_13 VARCHAR2(100),
  feature_value_13 VARCHAR2(100),
  feature_14 VARCHAR2(100),
  feature_value_14 VARCHAR2(100),
  feature_15 VARCHAR2(100),
  feature_value_15 VARCHAR2(100),
  feature_16 VARCHAR2(100),
  feature_value_16 VARCHAR2(100),
  feature_17 VARCHAR2(100),
  feature_value_17 VARCHAR2(100),
  feature_18 VARCHAR2(100),
  feature_value_18 VARCHAR2(100),
  feature_19 VARCHAR2(100),
  feature_value_19 VARCHAR2(100),
  feature_20 VARCHAR2(100),
  feature_value_20 VARCHAR2(100),
  feature_21 VARCHAR2(100),
  feature_value_21 VARCHAR2(100),
  feature_22 VARCHAR2(100),
  feature_value_22 VARCHAR2(100),
  feature_23 VARCHAR2(100),
  feature_value_23 VARCHAR2(100),
  feature_24 VARCHAR2(100),
  feature_value_24 VARCHAR2(100),
  feature_25 VARCHAR2(100),
  feature_value_25 VARCHAR2(100),
  feature_26 VARCHAR2(100),
  feature_value_26 VARCHAR2(100),
  feature_27 VARCHAR2(100),
  feature_value_27 VARCHAR2(100),
  feature_28 VARCHAR2(100),
  feature_value_28 VARCHAR2(100),
  feature_29 VARCHAR2(100),
  feature_value_29 VARCHAR2(100),
  feature_30 VARCHAR2(100),
  feature_value_30 VARCHAR2(100),
  feature_31 VARCHAR2(100),
  feature_value_31 VARCHAR2(100),
  feature_32 VARCHAR2(100),
  feature_value_32 VARCHAR2(100),
  feature_33 VARCHAR2(100),
  feature_value_33 VARCHAR2(100),
  feature_34 VARCHAR2(100),
  feature_value_34 VARCHAR2(100),
  feature_35 VARCHAR2(100),
  feature_value_35 VARCHAR2(100),
  feature_36 VARCHAR2(100),
  feature_value_36 VARCHAR2(100),
  feature_37 VARCHAR2(100),
  feature_value_37 VARCHAR2(100),
  feature_38 VARCHAR2(100),
  feature_value_38 VARCHAR2(100),
  feature_39 VARCHAR2(100),
  feature_value_39 VARCHAR2(100),
  feature_40 VARCHAR2(100),
  feature_value_40 VARCHAR2(100),
  feature_41 VARCHAR2(100),
  feature_value_41 VARCHAR2(100),
  feature_42 VARCHAR2(100),
  feature_value_42 VARCHAR2(100),
  feature_43 VARCHAR2(100),
  feature_value_43 VARCHAR2(100),
  feature_44 VARCHAR2(100),
  feature_value_44 VARCHAR2(100),
  feature_45 VARCHAR2(100),
  feature_value_45 VARCHAR2(100),
  feature_46 VARCHAR2(100),
  feature_value_46 VARCHAR2(100),
  feature_47 VARCHAR2(100),
  feature_value_47 VARCHAR2(100),
  feature_48 VARCHAR2(100),
  feature_value_48 VARCHAR2(100),
  feature_49 VARCHAR2(100),
  feature_value_49 VARCHAR2(100),
  feature_50 VARCHAR2(100),
  feature_value_50 VARCHAR2(100),
  feature_51 VARCHAR2(100),
  feature_value_51 VARCHAR2(100),
  feature_52 VARCHAR2(100),
  feature_value_52 VARCHAR2(100),
  feature_53 VARCHAR2(100),
  feature_value_53 VARCHAR2(100),
  feature_54 VARCHAR2(100),
  feature_value_54 VARCHAR2(100),
  feature_55 VARCHAR2(100),
  feature_value_55 VARCHAR2(100),
  feature_56 VARCHAR2(100),
  feature_value_56 VARCHAR2(100),
  feature_57 VARCHAR2(100),
  feature_value_57 VARCHAR2(100),
  feature_58 VARCHAR2(100),
  feature_value_58 VARCHAR2(100),
  feature_59 VARCHAR2(100),
  feature_value_59 VARCHAR2(100),
  CONSTRUCTOR FUNCTION ig_features_type RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY sa."IG_FEATURES_TYPE" IS
  CONSTRUCTOR FUNCTION ig_features_type RETURN SELF AS RESULT IS
    BEGIN
      RETURN;
    END;
END;
/