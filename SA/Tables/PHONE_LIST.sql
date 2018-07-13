CREATE TABLE sa.phone_list (
  phone NUMBER
);
ALTER TABLE sa.phone_list ADD SUPPLEMENTAL LOG GROUP dmtsora678887535_0 (phone) ALWAYS;