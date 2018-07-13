CREATE TABLE sa.x_ntfy_link_tmplt (
  objid NUMBER,
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  link_tmplt2lng_mas NUMBER,
  link_tmplt2src_mas NUMBER,
  link_tmplt2tmplt_ma NUMBER,
  link_tmplt2cat_mas NUMBER,
  link_tmplt2cat_config NUMBER,
  x_sourcesystem VARCHAR2(30 BYTE),
  link_tmplt2bus_org NUMBER
);
ALTER TABLE sa.x_ntfy_link_tmplt ADD SUPPLEMENTAL LOG GROUP dmtsora2121128654_0 (link_tmplt2cat_config, link_tmplt2cat_mas, link_tmplt2lng_mas, link_tmplt2src_mas, link_tmplt2tmplt_ma, objid, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_link_tmplt IS 'Billing notification link template';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.link_tmplt2lng_mas IS 'Reference to objid of X_NTFY_LANG_MAS';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.link_tmplt2src_mas IS 'Reference to objid of X_NTFY_SRC_MAS';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.link_tmplt2tmplt_ma IS 'Reference to objid of X_NTFY_TMPLT_MAS ';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.link_tmplt2cat_mas IS 'Reference to objid of X_NTFY_CAT_MAS ';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.link_tmplt2cat_config IS 'Reference to objid of X_NTFY_CAT_CONFIG ';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.x_sourcesystem IS 'Source system info. web or webcsr';
COMMENT ON COLUMN sa.x_ntfy_link_tmplt.link_tmplt2bus_org IS 'bus org info. tracfone or net10';