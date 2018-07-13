CREATE TABLE sa.ubi_ele_glossary (
  balance_element VARCHAR2(30 BYTE),
  element_description VARCHAR2(2000 BYTE)
);
COMMENT ON COLUMN sa.ubi_ele_glossary.balance_element IS 'The element type used by both gathering the balance and displaying on the page.';
COMMENT ON COLUMN sa.ubi_ele_glossary.element_description IS 'Info about this element type';