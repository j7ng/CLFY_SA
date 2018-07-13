CREATE OR REPLACE PACKAGE sa."RAF_PROMO_PKG"
AS

PROCEDURE RAF_PENDING_RECS;

FUNCTION RAF_AWARD_UNITS(
        ip_esn                IN       VARCHAR2,
        ip_part_number        IN       VARCHAR2,
        op_pin_objid         OUT       VARCHAR2
        )RETURN BOOLEAN;

END RAF_PROMO_PKG;
/