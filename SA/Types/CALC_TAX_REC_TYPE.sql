CREATE OR REPLACE TYPE sa.calc_tax_rec_type
IS
  OBJECT
  ( quantity          NUMBER,
    other_amt         NUMBER,--bundle/phone amt
    airtime_amt       NUMBER,
    warranty_amt      NUMBER,
    digital_goods_amt NUMBER,
    discount_amt      NUMBER,
    stax_amt          NUMBER,
    e911_amt          NUMBER,
    usf_amt           NUMBER,
    rcrf_amt          NUMBER,
    sub_total_amt     NUMBER,
    total_tax_amt     NUMBER,
    total_charges     NUMBER,
    stax_rate         NUMBER,
    e911_rate         NUMBER,
    usf_rate          NUMBER,
    rcrf_rate         NUMBER,
    RESULT            NUMBER,
    message           varchar2(60),
    dataonly_amt      NUMBER,
    taxable_discount_amt  NUMBER)
/