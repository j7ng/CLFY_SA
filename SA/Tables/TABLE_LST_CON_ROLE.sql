CREATE TABLE sa.table_lst_con_role (
  objid NUMBER,
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  start_date DATE,
  end_date DATE,
  dev NUMBER,
  list_role2contact NUMBER(*,0),
  con_role2mail_list NUMBER(*,0)
);
ALTER TABLE sa.table_lst_con_role ADD SUPPLEMENTAL LOG GROUP dmtsora764069988_0 ("ACTIVE", con_role2mail_list, dev, end_date, focus_type, list_role2contact, objid, role_name, start_date) ALWAYS;