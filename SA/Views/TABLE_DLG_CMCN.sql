CREATE OR REPLACE FORCE VIEW sa.table_dlg_cmcn (objid,dobjid,chobjid,mobjid,from_addr,to_addr_list,direction,delivery_status,subject,s_subject,bodytext,creation_time,medium_title,s_medium_title,auto_exec_ind) AS
select table_communication.objid, table_communication.communication2dialogue,
 table_channel.objid, table_medium.objid,
 table_communication.from_address, table_communication.to_list,
 table_communication.direction, table_communication.delivery_status,
 table_communication.title, table_communication.S_title, table_communication.text,
 table_communication.creation_time, table_medium.title, table_medium.S_title,
 table_communication.auto_exec_ind
 from table_communication, table_channel, table_medium
 where table_communication.communication2dialogue IS NOT NULL
 AND table_channel.objid = table_communication.communication2channel
 AND table_medium.objid = table_channel.channel2medium
 ;