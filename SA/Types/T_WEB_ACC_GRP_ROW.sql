CREATE OR REPLACE TYPE sa.t_web_acc_grp_row IS OBJECT
(
  login_name                  VARCHAR2(50) ,
  part_inst_status            VARCHAR2(30) ,
  account_group_id            NUMBER(22)   ,
  account_group_name          VARCHAR2(50) ,
  esn                         VARCHAR2(30) ,
  web_objid                   NUMBER(22)   ,
  account_group_status        VARCHAR2(30) ,
  account_group_member_status VARCHAR2(30)
);
/