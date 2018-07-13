CREATE OR REPLACE PROCEDURE sa."UPD_2G_MIG_DBL_TRPL_MINS_PRC"
IS
/*******************************************************************************************************
  * --$RCSfile: UPD_2G_MIG_DBL_TRPL_MINS_PRC.sql,v $
  --$Revision: 1.2 $
  --$Author: nmuthukkaruppan $
  --$Date: 2016/07/14 19:41:19 $
  --$ $Log: UPD_2G_MIG_DBL_TRPL_MINS_PRC.sql,v $
  --$ Revision 1.2  2016/07/14 19:41:19  nmuthukkaruppan
  --$ CR41703 -  Modified as Parameterized Cursor to restrict the numbers of records in cursor fetch.
  --$
  --$ Revision 1.1  2016/05/25 20:20:52  nmuthukkaruppan
  --$ CR41703 - 2G Migration Must Transfer Triple Min Benefit
  --$
  --$
  --$ CR41703  - 2G Migration Must Transfer Triple Min Benefit
  * Description: This will migrate the Double & Triple benefits from Old ESN to New ESN
  *
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
    --Cursor declaration to retrieve the list of old and new ESN's
	CURSOR cur_2G_mig_esn (p_interval number)
	IS
	SELECT table_case.id_number                     ,
		   table_case.x_esn                  old_esn,
		   trim(table_x_case_detail.x_value) new_esn
	FROM   sa.table_case           ,
		   sa.table_part_num       ,
		   sa.table_part_class     ,
		   sa.table_part_inst      ,
		   sa.table_x_carrier      ,
		   sa.table_x_carrier_group,
		   sa.table_x_parent       ,
		   sa.table_x_case_detail
	WHERE  creation_time                                  >= SYSDATE -  p_interval/24
	AND    x_model                                        = table_part_num.part_number
	and    part_num2part_class                            = table_part_class.objid
	and    table_part_inst.part_serial_no                 = table_case.x_esn
	and    table_part_inst.x_domain                       = 'PHONES'
	and    table_case.x_case_type                         = 'Phone Upgrade'
	and    sa.GET_PARAM_BY_NAME_FUN(table_part_class.name,'PHONE_GEN')  = '2G'
	and    sa.GET_PARAM_BY_NAME_FUN(table_part_class.name,'TECHNOLOGY') = 'GSM'
	and    table_part_inst.x_part_inst_status             = '54'
	and    table_case.case_type_lvl2                      IN ('TRACFONE','SAFELINK')
	and    table_case.x_carrier_id                        = table_x_carrier.x_carrier_id
	and    table_x_carrier.carrier2carrier_group          = table_x_carrier_group.objid
	and    table_x_carrier_group.x_carrier_group2x_parent = table_x_parent.objid
	and    table_x_Case_detail.detail2case                = table_case.objid
	and    table_x_Case_detail.x_name                     = 'NEW_ESN';

 CURSOR double_mins_promo_cur (p_old_esn varchar2)
 IS
 SELECT tpi_esn.objid  old_pi_objid,
        tpi_esn.part_serial_no old_esn,
        xge.objid old_group2esn_objid,
        xpg.group_name old_esn_promogroup,
        xpg.group_desc old_esn_promogroupdesc
    FROM table_part_inst tpi_esn,
         table_x_group2esn xge,
         table_x_promotion_group xpg
   WHERE xge.groupesn2part_inst = tpi_esn.objid
     AND xge.groupesn2x_promo_group = xpg.objid
     AND tpi_esn.part_serial_no = p_old_esn
     AND SYSDATE BETWEEN NVL(xge.x_start_date,SYSDATE) AND NVL(xge.x_end_date,SYSDATE)
     AND xpg.group_name LIKE '%DBL%';

 CURSOR triple_mins_promo_cur (p_old_esn varchar2)
 IS
  SELECT tpi_esn.objid  old_pi_objid,
        tpi_esn.part_serial_no old_esn,
        xge.objid old_group2esn_objid,
        xpg.group_name old_esn_promogroup,
        xpg.group_desc old_esn_promogroupdesc
    FROM table_part_inst tpi_esn,
         table_x_group2esn xge,
         table_x_promotion_group xpg
   WHERE xge.groupesn2part_inst = tpi_esn.objid
     AND xge.groupesn2x_promo_group = xpg.objid
     AND tpi_esn.part_serial_no = p_old_esn
     AND SYSDATE BETWEEN NVL(xge.x_start_date,SYSDATE) AND NVL(xge.x_end_date,SYSDATE)
     AND xpg.group_name LIKE '%X3X%';

--Local Variables
o_errnum   NUMBER;
o_errstr   VARCHAR2(2000);
l_esn_counter  number:= 0;
l_double_counter number:= 0;
l_triple_counter number:= 0;
l_interval   number;

BEGIN --Main Section
	BEGIN
	  SELECT X_PARAM_VALUE
	  INTO l_interval
	  FROM sa.TABLE_X_PARAMETERS
	  WHERE X_PARAM_NAME = '2G_MIG_JOB_INTERVAL';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 l_interval  := 1.1;
    WHEN OTHERS THEN
    	 l_interval  := 1.1;
	END;

  dbms_output.put_line('l_interval                   = ' || l_interval  );

	FOR esn_rec IN cur_2G_mig_esn (l_interval)
	LOOP
    l_esn_counter := l_esn_counter + 1;

      l_double_counter := 0;
        FOR double_mins_promo_rec IN double_mins_promo_cur(esn_rec.old_esn)   --Double Mins
        LOOP
        l_double_counter := l_double_counter + 1;

        BEGIN
				 --Update table for Double minutes promotions
				 UPDATE table_x_group2esn
					SET Groupesn2part_Inst =  (SELECT objid
												 FROM table_part_inst
												WHERE part_serial_no = esn_rec.new_esn)
				  WHERE objid  = double_mins_promo_rec.old_group2esn_objid;

				  IF SQL%ROWCOUNT = 0 THEN
					o_errnum := -1;
					o_errstr := 'upd_2g_mig_dbl_trpl_mins_prc:  '||substr(sqlerrm,1,100);
					util_pkg.insert_error_tab ( i_action       => 'Update failed ; Migration of Double Mins Promotion from Old Esn: '||esn_rec.old_esn ||'New Esn: ' ||esn_rec.new_esn,
												i_key          => NULL,
												i_program_name => 'upd_2g_mig_dbl_trpl_mins_prc',
												i_error_text   => o_errstr );

				  END IF;
		    EXCEPTION
          WHEN OTHERS THEN
          o_errnum := -1;
          o_errstr := 'upd_2g_mig_dbl_trpl_mins_prc:  '||substr(sqlerrm,1,100);
          util_pkg.insert_error_tab ( i_action       => 'Migration of Double Mins Promotion from Old Esn: '||esn_rec.old_esn ||'New Esn: ' ||esn_rec.new_esn,
                        i_key          => NULL,
                        i_program_name => 'upd_2g_mig_dbl_trpl_mins_prc',
                        i_error_text   => o_errstr );
        END;
        END LOOP;

         l_triple_counter := 0;
        FOR triple_mins_promo_rec IN triple_mins_promo_cur(esn_rec.old_esn)   --Triple Mins
        LOOP
        l_triple_counter := l_triple_counter + 1;
        BEGIN
				 --Update table for Triple minutes promotions
				 UPDATE table_x_group2esn
					SET Groupesn2part_Inst =  (SELECT objid
												 FROM table_part_inst
												WHERE part_serial_no = esn_rec.new_esn)
				  WHERE objid  = triple_mins_promo_rec.old_group2esn_objid;

				  IF SQL%ROWCOUNT = 0 THEN
					o_errnum := -1;
					o_errstr := 'upd_2g_mig_dbl_trpl_mins_prc:  '||substr(sqlerrm,1,100);
					util_pkg.insert_error_tab ( i_action       => 'Update failed ; Migration of Triple Mins Promotion from Old Esn: '||esn_rec.old_esn ||'New Esn: ' ||esn_rec.new_esn,
												i_key          => NULL,
												i_program_name => 'upd_2g_mig_dbl_trpl_mins_prc',
												i_error_text   => o_errstr );

				  END IF;
        EXCEPTION
          WHEN OTHERS THEN
          o_errnum := -1;
          o_errstr := 'upd_2g_mig_dbl_trpl_mins_prc:  '||substr(sqlerrm,1,100);
          util_pkg.insert_error_tab ( i_action       => 'Migration of Triple Mins Promotion from Old Esn: '||esn_rec.old_esn ||'New Esn: ' ||esn_rec.new_esn,
                        i_key          => NULL,
                        i_program_name => 'upd_2g_mig_dbl_trpl_mins_prc',
                        i_error_text   => o_errstr );
		    END;
        END LOOP;
	END LOOP;
EXCEPTION
   WHEN OTHERS THEN
    o_errnum := -1;
    o_errstr := 'upd_2g_mig_dbl_trpl_mins_prc:  '||substr(sqlerrm,1,100);
    util_pkg.insert_error_tab ( i_action       => 'Exception ',
                                i_key          => NULL,
                                i_program_name => 'upd_2g_mig_dbl_trpl_mins_prc',
                                i_error_text   => o_errstr );
END UPD_2G_MIG_DBL_TRPL_MINS_PRC;
/