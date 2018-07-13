CREATE TABLE sa.x_bogo_channel (
  brand VARCHAR2(30 BYTE) NOT NULL,
  channel VARCHAR2(15 BYTE) NOT NULL
);
COMMENT ON TABLE sa.x_bogo_channel IS 'TF BOGO valid channel list per brand';
COMMENT ON COLUMN sa.x_bogo_channel.brand IS 'Brand or main Tracfone business entity';
COMMENT ON COLUMN sa.x_bogo_channel.channel IS 'Channel name';