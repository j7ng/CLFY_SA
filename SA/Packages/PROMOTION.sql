CREATE OR REPLACE PACKAGE sa."PROMOTION"
AS
   PROCEDURE rebate (
      ip_esn       IN       VARCHAR2,
      ip_status    OUT      VARCHAR2,
      op_actdate   OUT      DATE
   );PROCEDURE referral (
      ip_esn       IN       VARCHAR2,
      ip_status    OUT      VARCHAR2,
      op_actdate   OUT      DATE
   );PROCEDURE gettimecode (
      ip_sub_esn       IN       VARCHAR2,
      ip_ref_esn       IN       VARCHAR2,
      ip_promo_type    IN       NUMBER,
      ip_part_number   IN       VARCHAR2,
      op_code          OUT      VARCHAR2
   );

--Added by VAdapa on 02/18/2002 to check the technology of an ESN
   FUNCTION checkesntech (ip_esn IN VARCHAR2)
      RETURN BOOLEAN;
--
END promotion;
/