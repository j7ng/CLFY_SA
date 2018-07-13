CREATE TABLE sa.x_lease_status (
  lease_status VARCHAR2(80 BYTE) NOT NULL,
  lease_status_name VARCHAR2(20 BYTE),
  lease_status_desc VARCHAR2(300 BYTE),
  create_date TIMESTAMP,
  update_date TIMESTAMP,
  block_group_transfer_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  block_reactivation_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  remove_leased_group_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  change_master_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  lease_status_name_spanish VARCHAR2(50 BYTE),
  CONSTRAINT pk_lease_status PRIMARY KEY (lease_status)
);
COMMENT ON COLUMN sa.x_lease_status.lease_status IS 'Current Lease status';
COMMENT ON COLUMN sa.x_lease_status.lease_status_name IS 'Lease status name';
COMMENT ON COLUMN sa.x_lease_status.lease_status_desc IS 'Lease status decription';
COMMENT ON COLUMN sa.x_lease_status.create_date IS 'Date record created';
COMMENT ON COLUMN sa.x_lease_status.update_date IS 'Date record deleted';
COMMENT ON COLUMN sa.x_lease_status.block_group_transfer_flag IS 'Block Group Transfer Flag based on the Lease Status';
COMMENT ON COLUMN sa.x_lease_status.block_reactivation_flag IS 'Block Reactivation based on the Lease Status';
COMMENT ON COLUMN sa.x_lease_status.remove_leased_group_flag IS 'Flag to identify when to remove the leased group application id from the group table';
COMMENT ON COLUMN sa.x_lease_status.change_master_flag IS 'Flag to indicate change master';