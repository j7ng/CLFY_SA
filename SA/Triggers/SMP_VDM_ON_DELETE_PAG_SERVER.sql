CREATE OR REPLACE TRIGGER sa.SMP_VDM_ON_DELETE_PAG_SERVER after delete
ON sa.SMP_VDM_NOTIFICATION_SERVICES for each row
begin
    delete from SMP_VDM_PAGING_CARRIER_INFO where paging_server_name = :old.nodename;
end;
/