CREATE OR REPLACE TYPE sa.return_item_rec
IS
 OBJECT
  (
    esn                 VARCHAR2 (30),
    smp                 VARCHAR2 (30),
    sim                 VARCHAR2 (30), -- CR51737
	accessory_serial	VARCHAR2 (50), -- CR54805
    part_number         VARCHAR2 (50),
    line_number         NUMBER,        -- CR51737
    is_tracfone         VARCHAR2 (1),
    softpin_unit_price  NUMBER,        -- CR51737
    softpin_check       VARCHAR2 (1),  -- CR51737
    is_softpin          VARCHAR2 (1),  -- CR51737
    CONSTRUCTOR  FUNCTION return_item_rec RETURN SELF AS  RESULT  -- CR51737
  );
/