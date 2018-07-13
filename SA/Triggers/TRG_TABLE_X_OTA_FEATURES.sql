CREATE OR REPLACE TRIGGER sa.TRG_table_x_ota_features
BEFORE INSERT OR UPDATE of x_psms_destination_addr ON sa.table_x_ota_features for each row
DISABLE when (new.x_psms_destination_addr <>'32275')

begin
  :new.x_psms_destination_addr :='32275';
end;
/