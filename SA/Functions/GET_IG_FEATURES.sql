CREATE OR REPLACE FUNCTION sa."GET_IG_FEATURES" ( in_transaction_id NUMBER,
                                             i_carrier_features_objid IN NUMBER DEFAULT NULL)
  RETURN ig_features_tab
  PIPELINED IS
  ig_features ig_features_type;
  igf         ig_transaction_features_tab;

  BEGIN
  ig_features := ig_features_type();
  igf := ig_transaction_features_tab();

  --CALL IGATE FUNCTION TO GET ig_transaction_features_tab
  igf := igate.get_ig_transaction_features ( i_transaction_id         => in_transaction_id,
                                             i_carrier_features_objid => i_carrier_features_objid);


   FOR i in ( with get_ig_features as
  (select 'FEATURE_' ||
          (row_number()
           over(partition by transaction_id order by feature_value) - 1) fe_num,
          feature_value,
          'FEATURE_VALUE_' ||
          (row_number()
           over(partition by transaction_id order by feature_value) - 1) fea_val,
          decode(feature_requirement, 'ADD', 'Y', 'REM','N') feature_val,
          transaction_id,
          count(*) over(partition by transaction_id) NUMBER_OF_FEATURES
     from TABLE(igf)
   )
 SELECT transaction_id,
        number_of_features,
        MAX(DECODE(fe_num, 'FEATURE_0', feature_value)) FEATURE_0,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_0', feature_val)) FEATURE_VALUE_0,
        MAX(DECODE(fe_num, 'FEATURE_1', feature_value)) FEATURE_1,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_1', feature_val)) FEATURE_VALUE_1,
        MAX(DECODE(fe_num, 'FEATURE_2', feature_value)) FEATURE_2,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_2', feature_val)) FEATURE_VALUE_2,
        MAX(DECODE(fe_num, 'FEATURE_3', feature_value)) FEATURE_3,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_3', feature_val)) FEATURE_VALUE_3,
        MAX(DECODE(fe_num, 'FEATURE_4', feature_value)) FEATURE_4,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_4', feature_val)) FEATURE_VALUE_4,
        MAX(DECODE(fe_num, 'FEATURE_5', feature_value)) FEATURE_5,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_5', feature_val)) FEATURE_VALUE_5,
        MAX(DECODE(fe_num, 'FEATURE_6', feature_value)) FEATURE_6,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_6', feature_val)) FEATURE_VALUE_6,
        MAX(DECODE(fe_num, 'FEATURE_7', feature_value)) FEATURE_7,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_7', feature_val)) FEATURE_VALUE_7,
        MAX(DECODE(fe_num, 'FEATURE_8', feature_value)) FEATURE_8,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_8', feature_val)) FEATURE_VALUE_8,
        MAX(DECODE(fe_num, 'FEATURE_9', feature_value)) FEATURE_9,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_9', feature_val)) FEATURE_VALUE_9,
        MAX(DECODE(fe_num, 'FEATURE_10', feature_value)) FEATURE_10,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_10', feature_val)) FEATURE_VALUE_10,
        MAX(DECODE(fe_num, 'FEATURE_11', feature_value)) FEATURE_11,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_11', feature_val)) FEATURE_VALUE_11,
        MAX(DECODE(fe_num, 'FEATURE_12', feature_value)) FEATURE_12,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_12', feature_val)) FEATURE_VALUE_12,
        MAX(DECODE(fe_num, 'FEATURE_13', feature_value)) FEATURE_13,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_13', feature_val)) FEATURE_VALUE_13,
        MAX(DECODE(fe_num, 'FEATURE_14', feature_value)) FEATURE_14,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_14', feature_val)) FEATURE_VALUE_14,
        MAX(DECODE(fe_num, 'FEATURE_15', feature_value)) FEATURE_15,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_15', feature_val)) FEATURE_VALUE_15,
        MAX(DECODE(fe_num, 'FEATURE_16', feature_value)) FEATURE_16,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_16', feature_val)) FEATURE_VALUE_16,
        MAX(DECODE(fe_num, 'FEATURE_17', feature_value)) FEATURE_17,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_17', feature_val)) FEATURE_VALUE_17,
        MAX(DECODE(fe_num, 'FEATURE_18', feature_value)) FEATURE_18,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_18', feature_val)) FEATURE_VALUE_18,
        MAX(DECODE(fe_num, 'FEATURE_19', feature_value)) FEATURE_19,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_19', feature_val)) FEATURE_VALUE_19,
        MAX(DECODE(fe_num, 'FEATURE_20', feature_value)) FEATURE_20,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_20', feature_val)) FEATURE_VALUE_20,
        MAX(DECODE(fe_num, 'FEATURE_21', feature_value)) FEATURE_21,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_21', feature_val)) FEATURE_VALUE_21,
        MAX(DECODE(fe_num, 'FEATURE_22', feature_value)) FEATURE_22,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_22', feature_val)) FEATURE_VALUE_22,
        MAX(DECODE(fe_num, 'FEATURE_23', feature_value)) FEATURE_23,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_23', feature_val)) FEATURE_VALUE_23,
        MAX(DECODE(fe_num, 'FEATURE_24', feature_value)) FEATURE_24,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_24', feature_val)) FEATURE_VALUE_24,
        MAX(DECODE(fe_num, 'FEATURE_25', feature_value)) FEATURE_25,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_25', feature_val)) FEATURE_VALUE_25,
        MAX(DECODE(fe_num, 'FEATURE_26', feature_value)) FEATURE_26,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_26', feature_val)) FEATURE_VALUE_26,
        MAX(DECODE(fe_num, 'FEATURE_27', feature_value)) FEATURE_27,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_27', feature_val)) FEATURE_VALUE_27,
        MAX(DECODE(fe_num, 'FEATURE_28', feature_value)) FEATURE_28,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_28', feature_val)) FEATURE_VALUE_28,
        MAX(DECODE(fe_num, 'FEATURE_29', feature_value)) FEATURE_29,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_29', feature_val)) FEATURE_VALUE_29,
        MAX(DECODE(fe_num, 'FEATURE_30', feature_value)) FEATURE_30,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_30', feature_val)) FEATURE_VALUE_30,
        MAX(DECODE(fe_num, 'FEATURE_31', feature_value)) FEATURE_31,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_31', feature_val)) FEATURE_VALUE_31,
        MAX(DECODE(fe_num, 'FEATURE_32', feature_value)) FEATURE_32,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_32', feature_val)) FEATURE_VALUE_32,
        MAX(DECODE(fe_num, 'FEATURE_33', feature_value)) FEATURE_33,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_33', feature_val)) FEATURE_VALUE_33,
        MAX(DECODE(fe_num, 'FEATURE_34', feature_value)) FEATURE_34,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_34', feature_val)) FEATURE_VALUE_34,
        MAX(DECODE(fe_num, 'FEATURE_35', feature_value)) FEATURE_35,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_35', feature_val)) FEATURE_VALUE_35,
        MAX(DECODE(fe_num, 'FEATURE_36', feature_value)) FEATURE_36,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_36', feature_val)) FEATURE_VALUE_36,
        MAX(DECODE(fe_num, 'FEATURE_37', feature_value)) FEATURE_37,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_37', feature_val)) FEATURE_VALUE_37,
        MAX(DECODE(fe_num, 'FEATURE_38', feature_value)) FEATURE_38,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_38', feature_val)) FEATURE_VALUE_38,
        MAX(DECODE(fe_num, 'FEATURE_39', feature_value)) FEATURE_39,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_39', feature_val)) FEATURE_VALUE_39,
        MAX(DECODE(fe_num, 'FEATURE_40', feature_value)) FEATURE_40,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_40', feature_val)) FEATURE_VALUE_40,
        MAX(DECODE(fe_num, 'FEATURE_41', feature_value)) FEATURE_41,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_41', feature_val)) FEATURE_VALUE_41,
        MAX(DECODE(fe_num, 'FEATURE_42', feature_value)) FEATURE_42,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_42', feature_val)) FEATURE_VALUE_42,
        MAX(DECODE(fe_num, 'FEATURE_43', feature_value)) FEATURE_43,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_43', feature_val)) FEATURE_VALUE_43,
        MAX(DECODE(fe_num, 'FEATURE_44', feature_value)) FEATURE_44,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_44', feature_val)) FEATURE_VALUE_44,
        MAX(DECODE(fe_num, 'FEATURE_45', feature_value)) FEATURE_45,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_45', feature_val)) FEATURE_VALUE_45,
        MAX(DECODE(fe_num, 'FEATURE_46', feature_value)) FEATURE_46,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_46', feature_val)) FEATURE_VALUE_46,
        MAX(DECODE(fe_num, 'FEATURE_47', feature_value)) FEATURE_47,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_47', feature_val)) FEATURE_VALUE_47,
        MAX(DECODE(fe_num, 'FEATURE_48', feature_value)) FEATURE_48,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_48', feature_val)) FEATURE_VALUE_48,
        MAX(DECODE(fe_num, 'FEATURE_49', feature_value)) FEATURE_49,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_49', feature_val)) FEATURE_VALUE_49,
        MAX(DECODE(fe_num, 'FEATURE_50', feature_value)) FEATURE_50,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_50', feature_val)) FEATURE_VALUE_50,
        MAX(DECODE(fe_num, 'FEATURE_51', feature_value)) FEATURE_51,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_51', feature_val)) FEATURE_VALUE_51,
        MAX(DECODE(fe_num, 'FEATURE_52', feature_value)) FEATURE_52,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_52', feature_val)) FEATURE_VALUE_52,
        MAX(DECODE(fe_num, 'FEATURE_53', feature_value)) FEATURE_53,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_53', feature_val)) FEATURE_VALUE_53,
        MAX(DECODE(fe_num, 'FEATURE_54', feature_value)) FEATURE_54,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_54', feature_val)) FEATURE_VALUE_54,
        MAX(DECODE(fe_num, 'FEATURE_55', feature_value)) FEATURE_55,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_55', feature_val)) FEATURE_VALUE_55,
        MAX(DECODE(fe_num, 'FEATURE_56', feature_value)) FEATURE_56,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_56', feature_val)) FEATURE_VALUE_56,
        MAX(DECODE(fe_num, 'FEATURE_57', feature_value)) FEATURE_57,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_57', feature_val)) FEATURE_VALUE_57,
        MAX(DECODE(fe_num, 'FEATURE_58', feature_value)) FEATURE_58,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_58', feature_val)) FEATURE_VALUE_58,
        MAX(DECODE(fe_num, 'FEATURE_59', feature_value)) FEATURE_59,
        MAX(DECODE(fea_val, 'FEATURE_VALUE_59', feature_val)) FEATURE_VALUE_59
   from get_ig_features
  group by transaction_id, number_of_features) loop

  ig_features.transaction_id := i.transaction_id;
  ig_features.number_of_features := i.number_of_features;
  ig_features.feature_0	:= i.feature_0;
  ig_features.feature_value_0	:= i.feature_value_0;
  ig_features.feature_1	:= i.feature_1;
  ig_features.feature_value_1	:= i.feature_value_1;
  ig_features.feature_2	:= i.feature_2;
  ig_features.feature_value_2	:= i.feature_value_2;
  ig_features.feature_3	:= i.feature_3;
  ig_features.feature_value_3	:= i.feature_value_3;
  ig_features.feature_4	:= i.feature_4;
  ig_features.feature_value_4	:= i.feature_value_4;
  ig_features.feature_5	:= i.feature_5;
  ig_features.feature_value_5	:= i.feature_value_5;
  ig_features.feature_6	:= i.feature_6;
  ig_features.feature_value_6	:= i.feature_value_6;
  ig_features.feature_7	:= i.feature_7;
  ig_features.feature_value_7	:= i.feature_value_7;
  ig_features.feature_8	:= i.feature_8;
  ig_features.feature_value_8	:= i.feature_value_8;
  ig_features.feature_9	:= i.feature_9;
  ig_features.feature_value_9	:= i.feature_value_9;
  ig_features.feature_10	:= i.feature_10;
  ig_features.feature_value_10	:= i.feature_value_10;
  ig_features.feature_11	:= i.feature_11;
  ig_features.feature_value_11	:= i.feature_value_11;
  ig_features.feature_12	:= i.feature_12;
  ig_features.feature_value_12	:= i.feature_value_12;
  ig_features.feature_13	:= i.feature_13;
  ig_features.feature_value_13	:= i.feature_value_13;
  ig_features.feature_14	:= i.feature_14;
  ig_features.feature_value_14	:= i.feature_value_14;
  ig_features.feature_15	:= i.feature_15;
  ig_features.feature_value_15	:= i.feature_value_15;
  ig_features.feature_16	:= i.feature_16;
  ig_features.feature_value_16	:= i.feature_value_16;
  ig_features.feature_17	:= i.feature_17;
  ig_features.feature_value_17	:= i.feature_value_17;
  ig_features.feature_18	:= i.feature_18;
  ig_features.feature_value_18	:= i.feature_value_18;
  ig_features.feature_19	:= i.feature_19;
  ig_features.feature_value_19	:= i.feature_value_19;
  ig_features.feature_20	:= i.feature_20;
  ig_features.feature_value_20	:= i.feature_value_20;
  ig_features.feature_21	:= i.feature_21;
  ig_features.feature_value_21	:= i.feature_value_21;
  ig_features.feature_22	:= i.feature_22;
  ig_features.feature_value_22	:= i.feature_value_22;
  ig_features.feature_23	:= i.feature_23;
  ig_features.feature_value_23	:= i.feature_value_23;
  ig_features.feature_24	:= i.feature_24;
  ig_features.feature_value_24	:= i.feature_value_24;
  ig_features.feature_25	:= i.feature_25;
  ig_features.feature_value_25	:= i.feature_value_25;
  ig_features.feature_26	:= i.feature_26;
  ig_features.feature_value_26	:= i.feature_value_26;
  ig_features.feature_27	:= i.feature_27;
  ig_features.feature_value_27	:= i.feature_value_27;
  ig_features.feature_28	:= i.feature_28;
  ig_features.feature_value_28	:= i.feature_value_28;
  ig_features.feature_29	:= i.feature_29;
  ig_features.feature_value_29	:= i.feature_value_29;
  ig_features.feature_30	:= i.feature_30;
  ig_features.feature_value_30	:= i.feature_value_30;
  ig_features.feature_31	:= i.feature_31;
  ig_features.feature_value_31	:= i.feature_value_31;
  ig_features.feature_32	:= i.feature_32;
  ig_features.feature_value_32	:= i.feature_value_32;
  ig_features.feature_33	:= i.feature_33;
  ig_features.feature_value_33	:= i.feature_value_33;
  ig_features.feature_34	:= i.feature_34;
  ig_features.feature_value_34	:= i.feature_value_34;
  ig_features.feature_35	:= i.feature_35;
  ig_features.feature_value_35	:= i.feature_value_35;
  ig_features.feature_36	:= i.feature_36;
  ig_features.feature_value_36	:= i.feature_value_36;
  ig_features.feature_37	:= i.feature_37;
  ig_features.feature_value_37	:= i.feature_value_37;
  ig_features.feature_38	:= i.feature_38;
  ig_features.feature_value_38	:= i.feature_value_38;
  ig_features.feature_39	:= i.feature_39;
  ig_features.feature_value_39	:= i.feature_value_39;
  ig_features.feature_40	:= i.feature_40;
  ig_features.feature_value_40	:= i.feature_value_40;
  ig_features.feature_41	:= i.feature_41;
  ig_features.feature_value_41	:= i.feature_value_41;
  ig_features.feature_42	:= i.feature_42;
  ig_features.feature_value_42	:= i.feature_value_42;
  ig_features.feature_43	:= i.feature_43;
  ig_features.feature_value_43	:= i.feature_value_43;
  ig_features.feature_44	:= i.feature_44;
  ig_features.feature_value_44	:= i.feature_value_44;
  ig_features.feature_45	:= i.feature_45;
  ig_features.feature_value_45	:= i.feature_value_45;
  ig_features.feature_46	:= i.feature_46;
  ig_features.feature_value_46	:= i.feature_value_46;
  ig_features.feature_47	:= i.feature_47;
  ig_features.feature_value_47	:= i.feature_value_47;
  ig_features.feature_48	:= i.feature_48;
  ig_features.feature_value_48	:= i.feature_value_48;
  ig_features.feature_49	:= i.feature_49;
  ig_features.feature_value_49	:= i.feature_value_49;
  ig_features.feature_50	:= i.feature_50;
  ig_features.feature_value_50	:= i.feature_value_50;
  ig_features.feature_51	:= i.feature_51;
  ig_features.feature_value_51	:= i.feature_value_51;
  ig_features.feature_52	:= i.feature_52;
  ig_features.feature_value_52	:= i.feature_value_52;
  ig_features.feature_53	:= i.feature_53;
  ig_features.feature_value_53	:= i.feature_value_53;
  ig_features.feature_54	:= i.feature_54;
  ig_features.feature_value_54	:= i.feature_value_54;
  ig_features.feature_55	:= i.feature_55;
  ig_features.feature_value_55	:= i.feature_value_55;
  ig_features.feature_56	:= i.feature_56;
  ig_features.feature_value_56	:= i.feature_value_56;
  ig_features.feature_57	:= i.feature_57;
  ig_features.feature_value_57	:= i.feature_value_57;
  ig_features.feature_58	:= i.feature_58;
  ig_features.feature_value_58	:= i.feature_value_58;
  ig_features.feature_59	:= i.feature_59;
  ig_features.feature_value_59	:= i.feature_value_59;

  pipe row(ig_features);
  end loop;
 return;
 end get_ig_features;
/