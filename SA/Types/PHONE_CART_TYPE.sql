CREATE OR REPLACE TYPE sa.phone_cart_TYPE AS OBJECT
(
x_ref varchar2(30),
x_part_number varchar2(100),
x_zip varchar2(30),
x_status varchar2(30)
)
/