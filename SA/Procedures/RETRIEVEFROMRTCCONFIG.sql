CREATE OR REPLACE PROCEDURE sa.RetrieveFromRTCconfig(
        in_brand_name              IN                 VARCHAR2,
        in_event_type              IN                 VARCHAR2,
        in_phone_model             IN                 VARCHAR2,
        in_service_plan            IN                 VARCHAR2,
        out_seg1                   OUT                VARCHAR2,
        out_seg2                   OUT                VARCHAR2,
        out_seg3                   OUT                VARCHAR2,
        out_udf1                   OUT                VARCHAR2,
        out_udf2                   OUT                VARCHAR2,
        out_udf3                   OUT                VARCHAR2,
        out_short_code             OUT                VARCHAR2,
        out_sms_text_template      OUT                VARCHAR2,
        out_comm_channel           OUT                VARCHAR2,
        out_campaign_cd            OUT                VARCHAR2,
        out_error_msg              OUT                VARCHAR2)
IS
        CURSOR cur_RTCconfig IS SELECT * FROM table_rtc_config
            WHERE brand_name   = in_brand_name
              AND event_type   = in_event_type
              AND phone_model  = in_phone_model
              AND service_plan = in_service_plan;
        rec_RTCconfig             table_rtc_config%ROWTYPE;
BEGIN
        OPEN cur_RTCconfig;
        FETCH cur_RTCconfig INTO rec_RTCconfig;
        IF cur_RTCconfig%NOTFOUND THEN
            out_error_msg := 'Record does not exist.';
        ELSE
            out_seg1               := rec_RTCconfig.seg1;
            out_seg2               := rec_RTCconfig.seg2;
            out_seg3               := rec_RTCconfig.seg3;
            out_udf1               := rec_RTCconfig.udf1;
            out_udf2               := rec_RTCconfig.udf2;
            out_udf3               := rec_RTCconfig.udf3;
            out_short_code         := rec_RTCconfig.short_code;
            out_sms_text_template  := rec_RTCconfig.sms_text_template;
            out_comm_channel       := rec_RTCconfig.comm_channel;
            out_campaign_cd        := rec_RTCconfig.campaign_cd;
        END IF;
        CLOSE cur_RTCconfig;
EXCEPTION
        WHEN OTHERS THEN
            out_error_msg := ('Error. ' || sqlerrm);
END RetrieveFromRTCconfig;
/