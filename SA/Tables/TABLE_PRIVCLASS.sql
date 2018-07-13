CREATE TABLE sa.table_privclass (
  objid NUMBER,
  class_name VARCHAR2(80 BYTE),
  s_class_name VARCHAR2(80 BYTE),
  access_mask VARCHAR2(80 BYTE),
  db_permission NUMBER,
  trans_mask VARCHAR2(255 BYTE),
  pswrd_exp_per NUMBER,
  warning_period NUMBER,
  member_type VARCHAR2(30 BYTE),
  s_member_type VARCHAR2(30 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  cs_allowed NUMBER,
  cq_allowed NUMBER,
  clfo_allowed NUMBER,
  owner_case_mod NUMBER,
  owner_sbcse_mod NUMBER,
  owner_rma_mod NUMBER,
  owner_cr_mod NUMBER,
  owner_sol_mod NUMBER,
  owner_subc_add NUMBER,
  remote_allowed NUMBER,
  sfa_allowed NUMBER,
  ccn_allowed NUMBER,
  access_type NUMBER,
  dev NUMBER,
  x_deact_blackout NUMBER
);
ALTER TABLE sa.table_privclass ADD SUPPLEMENTAL LOG GROUP dmtsora1537799222_0 (access_mask, access_type, ccn_allowed, class_name, clfo_allowed, cq_allowed, cs_allowed, db_permission, description, dev, member_type, objid, owner_case_mod, owner_cr_mod, owner_rma_mod, owner_sbcse_mod, owner_sol_mod, owner_subc_add, pswrd_exp_per, remote_allowed, sfa_allowed, s_class_name, s_description, s_member_type, trans_mask, warning_period, x_deact_blackout) ALWAYS;
COMMENT ON TABLE sa.table_privclass IS 'Defines user privilege classes; i.e., what commands and functions groups of users have/do not have access to';
COMMENT ON COLUMN sa.table_privclass.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_privclass.class_name IS 'Privilage class name';
COMMENT ON COLUMN sa.table_privclass.access_mask IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_privclass.db_permission IS 'Reserved; internal';
COMMENT ON COLUMN sa.table_privclass.trans_mask IS 'A position number in the field relates to a value of the rank field of the transition object. A value of 1 in a position enables the corresponding transition for the privclass';
COMMENT ON COLUMN sa.table_privclass.pswrd_exp_per IS 'Number of days password can remain active';
COMMENT ON COLUMN sa.table_privclass.warning_period IS 'Number of days before password will expire that warning messages should begin to be sent to user at time of login';
COMMENT ON COLUMN sa.table_privclass.member_type IS 'Type of users who can be added to the class; i.e., 0=employee, 1=contacts';
COMMENT ON COLUMN sa.table_privclass.description IS 'Description of the purpose/use of the privilege class';
COMMENT ON COLUMN sa.table_privclass.cs_allowed IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_privclass.cq_allowed IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_privclass.clfo_allowed IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_privclass.owner_case_mod IS 'Indicates if the class of user can perform non-owner mods on case';
COMMENT ON COLUMN sa.table_privclass.owner_sbcse_mod IS 'Indicates if the class of user can perform non-owner mods on subcase';
COMMENT ON COLUMN sa.table_privclass.owner_rma_mod IS 'Indicates if the class of user can perform non-owner mods on part request';
COMMENT ON COLUMN sa.table_privclass.owner_cr_mod IS 'Indicates if the class of user can perform non-owner mods on bug';
COMMENT ON COLUMN sa.table_privclass.owner_sol_mod IS 'Indicates if the class of user can perform non-owner mods on solution';
COMMENT ON COLUMN sa.table_privclass.owner_subc_add IS 'Indicates if the class of user can add subcases to cases they do not own';
COMMENT ON COLUMN sa.table_privclass.remote_allowed IS 'Indicates if the class of user can dispatch to remote queues';
COMMENT ON COLUMN sa.table_privclass.sfa_allowed IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_privclass.ccn_allowed IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_privclass.access_type IS 'Defines the type access of the privilege class: 0=online (WAN/LAN); 1=offline (remote)';
COMMENT ON COLUMN sa.table_privclass.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_privclass.x_deact_blackout IS 'Indicates a blackout period of 24 hours before deactivation of AB choices';