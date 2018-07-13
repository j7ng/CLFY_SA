CREATE OR REPLACE FUNCTION sa."ADFCRM_RET_MIN_INFO" (ip_min in varchar2)
return adfcrm_esn_structure is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_RET_MIN_INFO.sql,v $
--$Revision: 1.2 $
--$Author: mmunoz $
--$Date: 2014/03/28 16:24:53 $
--$ $Log: ADFCRM_RET_MIN_INFO.sql,v $
--$ Revision 1.2  2014/03/28 16:24:53  mmunoz
--$ CR26941 Added carrier information
--$
--$ Revision 1.1  2013/11/05 17:43:29  mmunoz
--$ CR26018
--$
--------------------------------------------------------------------------------------------
  min_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();
begin
  begin
    /*********************************
     ***  MIN INFORMATION           **
     *********************************/
    for i in (SELECT sp.objid,
                     sp.part_status,
                     sp.x_service_id,
                     sp.x_zipcode
              FROM   sa.TABLE_SITE_PART sp
              WHERE  sp.x_min = ip_min
              AND    sp.objid = (SELECT MAX(spm.objid)
                                 FROM   sa.TABLE_SITE_PART spm
                                 where  spm.x_min = sp.x_min)
              )
    loop
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('SP_OBJID',i.objid);
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('PART_STATUS',i.part_status);
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('ESN',i.x_service_id);
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('ZIPCODE',i.x_zipcode);
    end loop;
    /*********************************
     ***  CARRIER INFORMATION       **
     *********************************/
	for x in (select pa.x_queue_name, pa.X_PARENT_NAME, Ca.X_Carrier_Id, Ca.X_Mkt_Submkt_Name
               from table_x_parent pa, table_x_carrier_group gr, table_x_carrier ca, table_part_inst pi
               where pi.part_inst2carrier_mkt = ca.objid
               and ca.carrier2carrier_group = gr.objid
               and gr.x_carrier_group2x_parent = pa.objid
               and pi.part_serial_no = ip_min
               and pi.x_domain = 'LINES'
			  )
    loop
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('PARENT_QUEUE_NAME',x.x_queue_name);
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('PARENT_NAME',x.X_PARENT_NAME);
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('CARRIER_ID',x.X_Carrier_Id);
      min_tab.extend;
      min_tab(min_tab.last) := adfcrm_esn_structure_row_type('CARRIER_NAME',x.X_Mkt_Submkt_Name);
    end loop;
  end;

  return min_tab;
end ADFCRM_RET_MIN_INFO;
/