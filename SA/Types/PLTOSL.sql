CREATE OR REPLACE TYPE sa."PLTOSL"                                                                          AS OBJECT
(
    esn_imei_struct         PL_ESN_IMEI_STRUCTURE,
    iccid_struct            PL_ICCID_STRUCTURE,
    seq_struct              PL_SEQUENCE_STRUCTURE,
    tech_struct             PL_TECHNOLOGY_STRUCTURE,
    phone_model_struct      PL_PHONE_MODEL_STRUCTURE,
    transID_struct          PL_TRANSID_STRUCTURE,
    marketingMsg_struct     PL_MARKETING_STRUCTURE,
    commandMsg_struct       PL_COMMAND_STRUCT_ARRAY,
    inquiryMsg_struct       PL_INQUIRY_STRUCTURE,
    sendLast_struct         PL_SENDLASTACK_STRUCTURE,
    ack_struct              PL_ACK_STRUCTURE,
    unused_struct           PL_UNUSED_STRUCTURE
)
/