CREATE OR REPLACE PACKAGE BODY sa.COVERAGE_MAPS_PKG
AS
 /*******************************************************************************************************
 * --$RCSfile: COVERAGE_MAPS_PKG.sql,v $
  --$Revision: 1.30 $
  --$Author: skambhammettu $
  --$Date: 2017/11/07 17:10:09 $
  --$ Purpose of this package is Getting Map_id and Getting Phone models
  *
  * -----------------------------------------------------------------------------------------------------
  ********************************************************************************************************/
PROCEDURE get_coverage_maps ( i_zip         IN  VARCHAR2,
                              i_brand       IN  VARCHAR2,
                              i_device_type IN  VARCHAR2,
                              i_carrier     IN  VARCHAR2,
                              i_min         IN  VARCHAR2,
                              i_part_class  IN  VARCHAR2,
                              i_part_num  	IN  VARCHAR2, -- Added for CR43930 by Deepak
                              o_map_id      OUT VARCHAR2,
                              o_result_code OUT VARCHAR2,
                              o_result_msg  OUT VARCHAR2 ) IS

    cst customer_type := customer_type ();
    l_map_id           VARCHAR2(300);
    l_result_code      NUMBER;
    l_result_msg       VARCHAR2(100);
    carrier_part_class VARCHAR2(300);
    l_brand table_bus_org.org_id%type;
    l_part_class table_part_class.x_model_number%type;

--Added by Mayank S. to get o_map_id based on brand and zip
PROCEDURE	get_map_id
(
	i_brand			IN	VARCHAR2,
	i_zip			IN	VARCHAR2,
	i_carrier		IN	VARCHAR2,
	o_map_id		OUT	VARCHAR2,
	o_result_code	OUT	VARCHAR2,
	o_result_msg 	OUT	VARCHAR2
)
AS
l_parent_id	VARCHAR2(30);
l_zip_code_ct VARCHAR2(30);

CURSOR 	cur_coverage_map (i_brand IN VARCHAR2, i_parent_id IN VARCHAR2 )
IS
SELECT 	DISTINCT x_coverage_map x_cov_map
FROM 	mapinfo.eg_coverage_maps
WHERE 	x_parent_id	= i_parent_id
AND 	x_brand     = i_brand ;

BEGIN
--CR53217
SELECT COUNT(*)
INTO l_zip_code_ct
FROM MAPINFO.EG_ZIP2TECH
WHERE language  ='EN'
AND (SERVICE    =(DECODE(i_brand,'NET10','NT10','TRACFONE','TR','STRAIGHT_TALK','ST','TELCEL','TC',''))
OR (i_brand     = 'STRAIGHT_TALK'
AND service    IN ('HAVZW','STHA','AUDIO','STHS'))
OR ('NET10'     = i_brand
AND SERVICE    IN ('NTHS')) )
AND zip         = i_zip;
IF l_zip_code_ct=0 THEN
  o_result_code:='3';
  o_result_msg :='Invalid Zipcode';
END IF;
--CR53217


IF	i_carrier IS NOT NULL	--{
THEN
	BEGIN
		SELECT 	X_PARENT_ID
		INTO	l_parent_id
		FROM	table_x_parent
		WHERE	UPPER(x_parent_name) 	= UPPER(i_carrier)
		AND		x_status 				= 'ACTIVE'
		AND		rownum 					<=	1;

DBMS_OUTPUT.put_line('Carrier not null -  l_parent_id '|| l_parent_id );

	EXCEPTION
	WHEN OTHERS THEN
		l_parent_id	:=	NULL;
		o_result_code:=	'1';
		o_result_msg	:= 'Check Parend ID information.';
	END;

ELSE
	BEGIN
		SELECT 	max(X_PARENT_ID)
		INTO	l_parent_id
		FROM 	table_x_pref_tech pt,
				table_x_carrier tc,
				table_x_carrier_group cg,
				table_x_parent tp
		WHERE 	1         =	1
		AND 	tp.objid      = cg.x_carrier_group2x_parent
		AND 	cg.objid      = tc.carrier2carrier_group
		AND 	tc.objid      = pt.x_pref_tech2x_carrier
		AND 	x_technology IN ('CDMA','GSM')
		AND 	x_parent_id  IN
							(
								SELECT 	X_PREF_PARENT
								FROM 	MAPINFO.EG_ZIP2TECH
								WHERE 	language='EN'
								AND 	(SERVICE  =(DECODE(i_brand,'NET10','NT10','TRACFONE','TR','STRAIGHT_TALK','ST','TELCEL','TC',''))
								OR 		(i_brand   = 'STRAIGHT_TALK'
								AND 	service  IN ('HAVZW','STHA','AUDIO','STHS'))
								OR 		('NET10'   = i_brand
								AND 	SERVICE  IN ('NTHS')) )
								AND 	zip       = i_zip
							);
	EXCEPTION
	WHEN OTHERS THEN
		l_parent_id	:=	NULL;
		o_result_code:=	'1';
		o_result_msg	:= 'Check Parend ID information.';
	END;
DBMS_OUTPUT.put_line('Carrier is null -  l_parent_id '|| l_parent_id );

END IF;						--}

FOR rec_coverage_map IN cur_coverage_map (i_brand, l_parent_id)
LOOP
  o_map_id := rec_coverage_map.x_cov_map;
	-- return only the map id was retrieved successfully
	IF o_map_id     IS NOT NULL THEN
	  o_result_code := '0';
	  o_result_msg  := 'SUCCESS';
	  DBMS_OUTPUT.put_line('get_map_id MAP_ID '|| o_map_id );
	  RETURN;
	ELSE
		o_map_id		:=	NULL;
		o_result_code	:=	'2';
		o_result_msg	:= 'Map ID not found.';
	END IF;
END LOOP;

EXCEPTION
WHEN OTHERS THEN
	  o_map_id := NULL;
	  DBMS_OUTPUT.put_line('Exception get_map_id MAP_ID '|| o_map_id );
END	get_map_id;



      PROCEDURE proc_map_info(
          p_part_class_name IN VARCHAR2,
          p_brand           IN VARCHAR2,
          p_zip             IN VARCHAR2,
          p_parent_id       IN VARCHAR2,
          o_map_id OUT VARCHAR2,
          o_result_code OUT VARCHAR2,
          o_result_msg OUT VARCHAR2 )
      AS
  --SELECTING CURSOR map_info WHEN i_part_class IS NOT NULL
CURSOR map_info ( i_part_class IN VARCHAR2 ,
				i_brand      IN VARCHAR2 ,
				i_zip        IN VARCHAR2 ,
				i_parent_id  IN VARCHAR2 ) IS
SELECT *
FROM   ( SELECT DISTINCT zip_par.zip,
				zip_par.x_carrier_name,
				zip_par.x_parent_name,
				zip_par.x_parent_id,
				bo.s_org_id brand,
				cf.x_technology,
				cf.x_data
		 FROM   ( SELECT DISTINCT zip_carr.zip,
						 tc.objid carr_obj,
						 tc.x_carrier_id,
						 cg.x_carrier_name,
						 tp.x_parent_name,
						 tp.x_parent_id
				  FROM   ( SELECT DISTINCT c.zip,
								  n.carrier_id
						   FROM   carrierzones c,
								  npanxx2carrierzones n,
								  carrierpref cp
						   WHERE  1 = 1
						   AND    cp.carrier_id = n.carrier_id
						   AND    cp.county     = c.county
						   AND    cp.st         = c.st
						   AND    n.zone        = c.zone
						   AND    n.state       = c.st
						   AND    c.ZIP_STATUS  = 'ACTIVE'
						   AND    c.zip         = i_zip
						 ) zip_carr, --zip in
						 table_x_carrier tc,
						 table_x_carrier_group cg,
						 table_x_parent tp,
						 table_x_carrierdealer dealer
				  WHERE  1 = 1
				  AND    tp.x_status             = 'ACTIVE'
				  AND    tp.objid                = cg.x_carrier_group2x_parent
				  AND    cg.x_status             = 'ACTIVE'
				  AND    cg.objid                = tc.carrier2carrier_group
				  AND    tc.x_status             = 'ACTIVE'
				  AND    tc.x_carrier_id         = zip_carr.carrier_id
				  AND    dealer.x_cd2x_carrier   = tc.objid
				  AND    dealer.x_dealer_id NOT IN ('24920', '61633')
				) zip_par,
				table_x_carrier_features cf,
				table_bus_org bo
		 WHERE  1 = 1
		 AND    bo.objid               = cf.x_features2bus_org
		 AND    cf.x_technology       IN ('GSM','CDMA')
		 AND    bo.s_org_id            = i_brand --brand in
		 AND    cf.x_feature2x_carrier = zip_par.carr_obj
	   ) carr_lst,
	   ( SELECT pc.objid part_class_objid,
				pc.name,
				dn.x_param_value display_name,
				bo.x_param_value bus_org,
				t.x_param_value tech,
				NVL(ds.x_param_value, 	(
											SELECT  a.x_param_value
											FROM    table_x_part_class_values a,
													table_x_part_class_params b
											WHERE   a.value2class_param = b.objid
											AND     b.x_param_name      = 'DATA_CAPABLE'
											AND     a.value2part_class 	= pc.objid
										)
				   ) data_speed
		 FROM   table_part_class pc,
				(SELECT  * FROM    table_x_part_class_values a, table_x_part_class_params b WHERE   a.value2class_param = b.objid AND     b.x_param_name      = 'DATA_SPEED') ds,
				(SELECT  * FROM    table_x_part_class_values a, table_x_part_class_params b WHERE   a.value2class_param = b.objid AND     b.x_param_name      = 'BUS_ORG') bo,
				(SELECT  * FROM    table_x_part_class_values a, table_x_part_class_params b WHERE   a.value2class_param = b.objid AND     b.x_param_name      = 'TECHNOLOGY') t,
				(SELECT  * FROM    table_x_part_class_values a, table_x_part_class_params b WHERE   a.value2class_param = b.objid AND     b.x_param_name      = 'DISPLAY_DESCRIPTION') dn
		 WHERE  1 = 1
		 AND    dn.value2part_class (+) = pc.objid
		 AND    t.value2part_class 	(+) = pc.objid
		 AND    bo.value2part_class (+) = pc.objid
		 AND    ds.value2part_class (+) = pc.objid
		 --AND    pc.x_model_number       = i_part_class -- part_class
		 AND    pc.name       			= i_part_class -- Changes made by Mayank S. for CR41006 to compare with name instead of x_model_number
	   ) device_lst
WHERE  1 = 1
AND    device_lst.tech       = carr_lst.x_technology
AND    device_lst.bus_org    = carr_lst.brand
AND    device_lst.data_speed = carr_lst.x_data
AND ( ( x_parent_id = i_parent_id and i_min is not null) OR (i_min is null))
AND NOT EXISTS ( SELECT 1
				 FROM   sa.TABLE_X_NOT_CERTIFY_MODELS ncm
				 WHERE  ncm.x_parent_id      	= carr_lst.x_parent_id
				 AND    ncm.x_part_class_objid 	= device_lst.part_class_objid
				)
ORDER BY x_carrier_name,
		 brand,
		 to_number(x_data),
		 to_number(x_parent_id);

cur_rec MAP_INFO%rowtype;

CURSOR cur_coverage_map (i_brand IN VARCHAR2, i_x_parent_id IN VARCHAR2 )
IS
SELECT DISTINCT x_coverage_map x_cov_map
FROM mapinfo.eg_coverage_maps
WHERE x_parent_id= i_x_parent_id
AND x_brand      = i_brand ;

BEGIN
  FOR i IN MAP_INFO (p_part_class_name, p_brand, p_zip, p_parent_id)
  LOOP
	FOR rec_coverage_map IN cur_coverage_map (p_brand, i.x_parent_id)
	LOOP
	  o_map_id := rec_coverage_map.x_cov_map;
		-- return only the map id was retrieved successfully
		IF o_map_id     IS NOT NULL THEN
		  o_result_code := '0';
		  o_result_msg  := 'SUCCESS';
		  DBMS_OUTPUT.put_line('MAP_ID '|| o_map_id );
		  RETURN;
		END IF;
	END LOOP;
  END LOOP;
END;

	-- MAIN PROC BEGINS

	BEGIN
		  -- CR43930 modified logic for new requirements

          --FIRST check for min
IF i_min IS NOT NULL THEN
-- call the type to get the part class
	cst := cst.retrieve_min ( i_min => i_min );
--
	IF cst.part_class_name IS NOT NULL THEN

		proc_map_info ( cst.part_class_name, --p_part_class_name
		i_brand,                             -- p_brand
		NVL(i_zip, cst.zipcode),           -- p_zip	-- NVL added by Mayank S. for CR41006
		cst.parent_id,                       -- p_parent_id
		o_map_id , o_result_code , o_result_msg ) ;
		RETURN;
	END IF;

--If min is null check for ZIP
ELSIF i_zip     IS NOT NULL THEN

-- CR43930 - started changes for new in parameter (i_part_num)
	IF i_part_num IS NOT NULL THEN
	--Retrieve the Brand for i_part_num
		SELECT 	bo.org_id,pc.name
		INTO 	l_brand, l_part_class
		FROM 	table_part_num pn,
				table_part_class pc,
				table_bus_org bo
		WHERE 	pn.part_num2bus_org = bo.objid
		AND 	pn.part_num2part_class = pc.objid
		AND 	part_number           = i_part_num;

		proc_map_info ( l_part_class, --p_part_class_name
						l_brand,                      -- p_brand
						i_zip,                        -- p_zip
						NULL,                         -- p_parent_id
						o_map_id , o_result_code , o_result_msg ) ;
		RETURN;
	-- CR43930 end changes for new in parameter (i_part_num)
	ELSIF i_brand     IS NOT NULL THEN
			IF i_part_class IS NOT NULL THEN

				proc_map_info ( i_part_class, --p_part_class_name
				i_brand,                      -- p_brand
				i_zip,                        -- p_zip
				NULL,                         -- p_parent_id
				o_map_id , o_result_code , o_result_msg ) ;
				RETURN;
				--Below changes commented by Mayank S. No one was aware in the team why the COVERAGE_PART_CLASS_CARRIER table was created
			--ELSIF /*i_part_class IS NULL AND i_min IS NULL AND*/ i_carrier IS NOT NULL THEN
	/*			SELECT 	PART_CLASS_NAME
				INTO 	carrier_part_class
				FROM 	sa.COVERAGE_PART_CLASS_CARRIER
				WHERE 	BRAND           = i_brand
				AND 	SHORT_PARENT_NAME = i_carrier;
--  Getting part_class_name from Brand, ZIp and carrier

				IF carrier_part_class IS NOT NULL THEN

					proc_map_info	( 	carrier_part_class, --p_part_class_name
										i_brand,                           -- p_brand
										i_zip,                             -- p_zip
										NULL,                              -- p_parent_id
										o_map_id , o_result_code , o_result_msg
									) ;
					RETURN;
				END IF;*/
			ELSE
							--Below logic added by Mayank S. for CR41006 to avoid  COVERAGE_PART_CLASS_CARRIER
							get_map_id	(
											i_brand,
											i_zip,
											i_carrier,
											o_map_id,
											o_result_code,
											o_result_msg
										);
							DBMS_OUTPUT.put_line('CR41006 o_map_id = '|| o_map_id );

							RETURN;
			END IF;
	END IF; -- Added
END IF;   -- Added
          o_result_code := '0';
          o_result_msg  := 'SUCCESS';
          DBMS_OUTPUT.put_line('MAP_ID4'|| o_map_id );

        END GET_COVERAGE_MAPS;


        -- Procedure GETPHONEMODELS
        PROCEDURE GETPHONEMODELS(
            i_zip   		IN 	VARCHAR2,
            i_brand 		IN 	VARCHAR2,
            o_part_class 	OUT SYS_REFCURSOR ,
            o_result_code 	OUT VARCHAR2,
            o_result_msg 	OUT VARCHAR2
			)
        IS
          l_part_class  VARCHAR2(300);
          l_result_code NUMBER ;
          l_result_msg  VARCHAR2(100);
        BEGIN
          --  all  ALL Brands
          --  Only for tracfone (Union with above SQL)
          IF i_brand IN ('NET10', 'STRAIGHT_TALK', 'TELCEL') THEN
/*          Commented for CR#42530 - Performance issue by Mayank
			OPEN o_part_class FOR
            SELECT DISTINCT pc.name,
              pc.description
			  */
              /*+ index(pc,SA.PART_CLASS_NAME_INDEX) */
            /*FROM TABLE_PART_CLASS pc,
              table_x_part_class_values pcv,
              TABLE_PART_NUM pn,
              table_bus_org bo
            WHERE value2part_class  = pc.objid
            AND pn.part_num2bus_org = bo.objid
            AND bo.org_id           = i_brand
            AND PN.PART_NUMBER     IN
              (SELECT ITEM_NO
              FROM sa.tf_iday i
              WHERE MAT_CLASS IN ('DEVICES', 'PHONE')
              GROUP BY item_no
              HAVING SUM(available)>= 100
              )
            AND (SELECT param_value
              FROM PC_PARAMS_VIEW
              WHERE param_name         = 'AVAILABLE_ONLINE'
              AND pc_objid             = pc.objid) IN ('Y', 'N')
            AND PN.PART_NUM2PART_CLASS = PC.OBJID
            AND PN.DOMAIN              ='PHONES'
            AND PN.X_TECHNOLOGY       IN
              ( SELECT DISTINCT pt.x_technology
              FROM table_x_pref_tech pt,
                table_x_carrier tc,
                table_x_carrier_group cg,
                table_x_parent tp
              WHERE 1           =1
              AND tp.objid      = cg.x_carrier_group2x_parent
              AND cg.objid      = tc.carrier2carrier_group
              AND tc.objid      = pt.x_pref_tech2x_carrier
              AND x_technology IN ('CDMA','GSM')
              AND x_parent_id  IN
                (SELECT X_PREF_PARENT
                FROM MAPINFO.EG_ZIP2TECH
                WHERE language='EN'
                AND (SERVICE  =(DECODE(i_brand,'NET10','NT10','STRAIGHT_TALK','ST','TELCEL','TC',''))
                OR (i_brand   = 'STRAIGHT_TALK'
                AND service  IN ('HAVZW','STHA','AUDIO','STHS'))
                OR ('NET10'   = i_brand
                AND SERVICE  IN ('NTHS')) )
                AND zip       = i_zip
                )
              ) ; */

--Below query tuned for CR#42530 by Mayank. Also added 4 new fields to cursor - manufacturer, operating_sys, feature, ranking.

			OPEN 	o_part_class FOR
			WITH	cte_class AS
					(
						SELECT 	/*+ MATERIALIZE */ ITEM_NO
						FROM 	sa.tf_iday i
						WHERE 	MAT_CLASS IN ('DEVICES', 'PHONE')
						GROUP 	BY item_no
						HAVING 	SUM(available)>= 100
					),
					cte_tech AS
					(
						SELECT 	/*+ MATERIALIZE */ DISTINCT pt.x_technology
						FROM 	table_x_pref_tech pt,
								table_x_carrier tc,
								table_x_carrier_group cg,
								table_x_parent tp
						WHERE 	1           =1
						AND 	tp.objid      = cg.x_carrier_group2x_parent
						AND 	cg.objid      = tc.carrier2carrier_group
						AND 	tc.objid      = pt.x_pref_tech2x_carrier
						AND 	x_technology IN ('CDMA','GSM')
						AND 	x_parent_id  IN
						(
							SELECT 	X_PREF_PARENT
							FROM 	MAPINFO.EG_ZIP2TECH
							WHERE 	language='EN'
							AND 	(SERVICE  =(DECODE(i_brand,'NET10','NT10','STRAIGHT_TALK','ST','TELCEL','TC',''))
							OR 		(i_brand   = 'STRAIGHT_TALK'
							AND 	service  IN ('HAVZW','STHA','AUDIO','STHS'))
							OR 		('NET10'   = i_brand
							AND 	SERVICE  IN ('NTHS')) )
							AND 	zip       = i_zip
						)
					),
					cte_manufacturer AS
					(
						SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
						FROM    table_x_part_class_params a, table_x_part_class_values b
						WHERE   b.VALUE2CLASS_PARAM = a.objid
						AND     x_param_name        = 'MANUFACTURER'
					),
					cte_operating_sys AS
					(
						SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
						FROM    table_x_part_class_params a, table_x_part_class_values b
						WHERE   b.VALUE2CLASS_PARAM = a.objid
						AND     x_param_name        = 'OPERATING_SYSTEM'
					),
					cte_feature AS
					(
						SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
						FROM    table_x_part_class_params a, table_x_part_class_values b
						WHERE   b.VALUE2CLASS_PARAM = a.objid
						AND     x_param_name        = 'MODEL_TYPE'
					),
					cte_ranking AS
					(
						SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
						FROM    table_x_part_class_params a, table_x_part_class_values b
						WHERE   b.VALUE2CLASS_PARAM = a.objid
						AND     x_param_name        = 'MOST_POPULAR_RANK'
					)
			SELECT 	DISTINCT 	pc.name,
								pc.description /*+ index(pc,SA.PART_CLASS_NAME_INDEX) */,
								cte_manufacturer.X_PARAM_VALUE	manufacturer,	--
								cte_operating_sys.X_PARAM_VALUE	operating_sys,	--
								cte_feature.X_PARAM_VALUE	feature,			--
								NVL(cte_ranking.X_PARAM_VALUE, '999')	ranking			--
			FROM 	TABLE_PART_CLASS pc,
					table_x_part_class_values pcv,
					TABLE_PART_NUM pn,
					table_bus_org bo,
					cte_class, 			--
					cte_tech, 			--
					cte_manufacturer,	--
					cte_operating_sys,	--
					cte_feature,		--
					cte_ranking			--
			WHERE 	pcv.value2part_class  	= pc.objid
			AND 	pn.part_num2bus_org 	= bo.objid
			AND 	bo.org_id           	= i_brand
			AND 	PN.PART_NUMBER  		= cte_class.ITEM_NO 		--
			AND 	(	SELECT 	param_value
						FROM 	PC_PARAMS_VIEW
						WHERE 	param_name         = 'AVAILABLE_ONLINE'
						AND 	pc_objid           = pc.objid) IN ('Y', 'N')
			AND 	PN.PART_NUM2PART_CLASS 	= PC.OBJID
			AND 	PN.DOMAIN              	='PHONES'
			AND 	PN.X_TECHNOLOGY 		= cte_tech.x_technology				--
			AND		cte_manufacturer.VALUE2PART_CLASS(+) = pc.objid		--
			AND		cte_operating_sys.VALUE2PART_CLASS(+) = pc.objid	--
			AND		cte_feature.VALUE2PART_CLASS(+) = pc.objid		 	--
			AND		cte_ranking.VALUE2PART_CLASS(+) = pc.objid;		 	--

          ELSE
            OPEN o_part_class FOR
/*            Commented for CR#42530 - Performance issue by Mayank
SELECT DISTINCT pc.name,
							pc.description	 */
							/*+ index(pc,SA.PART_CLASS_NAME_INDEX) */
/*
							,
							null	manufacturer,	--
							null	operating_sys,	--
							null	feature,		--
							null	ranking			--
            FROM TABLE_PART_CLASS pc,
              table_x_part_class_values pcv,
              TABLE_PART_NUM pn,
              table_bus_org bo
            WHERE value2part_class  = pc.objid
            AND pn.part_num2bus_org = bo.objid
            AND bo.org_id           = i_brand
            AND PN.PART_NUMBER     IN
              (SELECT ITEM_NO
              FROM sa.tf_iday i
              WHERE MAT_CLASS IN ('DEVICES', 'PHONE')
              GROUP BY item_no
              HAVING SUM(available)>= 100
              )
            AND (SELECT param_value
              FROM PC_PARAMS_VIEW
              WHERE param_name         = 'AVAILABLE_ONLINE'
              AND pc_objid             = pc.objid) IN ('Y', 'N')
            AND PN.PART_NUM2PART_CLASS = PC.OBJID
            AND PN.DOMAIN              ='PHONES'
            AND PN.X_TECHNOLOGY       IN
              ( SELECT DISTINCT pt.x_technology
              FROM table_x_pref_tech pt,
                table_x_carrier tc,
                table_x_carrier_group cg,
                table_x_parent tp
              WHERE 1           =1
              AND tp.objid      = cg.x_carrier_group2x_parent
              AND cg.objid      = tc.carrier2carrier_group
              AND tc.objid      = pt.x_pref_tech2x_carrier
              AND x_technology IN ('CDMA','GSM')
              AND x_parent_id  IN
                (SELECT X_PREF_PARENT
                FROM MAPINFO.EG_ZIP2TECH
                WHERE language='EN'
                AND (SERVICE  =(DECODE(i_brand,'NET10','NT10','TRACFONE','TR','STRAIGHT_TALK','ST','TELCEL','TC',''))
                OR (i_brand   = 'STRAIGHT_TALK'
                AND service  IN ('HAVZW','STHA','AUDIO','STHS'))
                OR ('NET10'   = i_brand
                AND SERVICE  IN ('NTHS')) )
                AND zip       = i_zip
                )
              )
            UNION
            --Only for tracfone (Union with above SQL)
            SELECT DISTINCT name,
							description,
							null	manufacturer,	--
							null	operating_sys,	--
							null	feature,		--
							null	ranking			--
            FROM TABLE_PART_CLASS pc,
              table_x_part_class_values pcv
            WHERE PC.X_MODEL_NUMBER IN('TFBYOPC4N', 'TF256PBYOPAPN')
            ORDER BY name DESC;
*/
--Below query tuned for CR#42530. Also added 4 new fields to cursor - manufacturer, operating_sys, feature, ranking.

		WITH   	cte_class AS
				(
					SELECT 	/*+ MATERIALIZE */ ITEM_NO
					FROM 	sa.tf_iday i
					WHERE 	MAT_CLASS IN ('DEVICES', 'PHONE')
					GROUP 	BY item_no
					HAVING 	SUM(available)>= 100
				),
				cte_tech AS
				(
					SELECT 	/*+ MATERIALIZE */ DISTINCT pt.x_technology
					FROM 	table_x_pref_tech pt,
							table_x_carrier tc,
							table_x_carrier_group cg,
							table_x_parent tp
					WHERE 	1           =1
					AND tp.objid      = cg.x_carrier_group2x_parent
					AND cg.objid      = tc.carrier2carrier_group
					AND tc.objid      = pt.x_pref_tech2x_carrier
					AND x_technology IN ('CDMA','GSM')
					AND x_parent_id  IN
										(
											SELECT 	X_PREF_PARENT
											FROM 	MAPINFO.EG_ZIP2TECH
											WHERE 	language='EN'
											AND 	(SERVICE  =(DECODE(i_brand,'NET10','NT10','TRACFONE','TR','STRAIGHT_TALK','ST','TELCEL','TC',''))
											OR 		(i_brand   = 'STRAIGHT_TALK'
											AND 	service  IN ('HAVZW','STHA','AUDIO','STHS'))
											OR 		('NET10'   = i_brand
											AND 	SERVICE  IN ('NTHS')) )
											AND 	zip       = i_zip
										)
				),
				cte_manufacturer AS
				(
					SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
					FROM    table_x_part_class_params a, table_x_part_class_values b
					WHERE   b.VALUE2CLASS_PARAM = a.objid
					AND     x_param_name        = 'MANUFACTURER'
				),
				cte_operating_sys AS
				(
					SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
					FROM    table_x_part_class_params a, table_x_part_class_values b
					WHERE   b.VALUE2CLASS_PARAM = a.objid
					AND     x_param_name        = 'OPERATING_SYSTEM'
				),
				cte_feature AS
				(
					SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
					FROM    table_x_part_class_params a, table_x_part_class_values b
					WHERE   b.VALUE2CLASS_PARAM = a.objid
					AND     x_param_name        = 'MODEL_TYPE'
				),
				cte_ranking AS
				(
					SELECT  X_PARAM_VALUE, VALUE2PART_CLASS
					FROM    table_x_part_class_params a, table_x_part_class_values b
					WHERE   b.VALUE2CLASS_PARAM = a.objid
					AND     x_param_name        = 'MOST_POPULAR_RANK'
				)
		SELECT DISTINCT pc.name,
						pc.description	/*+ index(pc,SA.PART_CLASS_NAME_INDEX) */,
						cte_manufacturer.X_PARAM_VALUE	manufacturer,	--
						cte_operating_sys.X_PARAM_VALUE	operating_sys,	--
						cte_feature.X_PARAM_VALUE	feature,			--
						NVL(cte_ranking.X_PARAM_VALUE, '999')	ranking				--
		FROM 	TABLE_PART_CLASS pc,
				table_x_part_class_values pcv,
				TABLE_PART_NUM pn,
				table_bus_org bo,
				cte_class,			--
				cte_tech, 			--
				cte_manufacturer,	--
				cte_operating_sys,	--
				cte_feature,  		--
				cte_ranking  		--
		WHERE 	pcv.value2part_class  = pc.objid
		AND 	pn.part_num2bus_org = bo.objid
		AND 	bo.org_id           = i_brand
		AND 	PN.PART_NUMBER  = cte_class.ITEM_NO 				--
		AND 	(	SELECT param_value
					FROM PC_PARAMS_VIEW
					WHERE param_name         = 'AVAILABLE_ONLINE'
					AND pc_objid             = pc.objid) IN ('Y', 'N')
		AND 	PN.PART_NUM2PART_CLASS = PC.OBJID
		AND 	PN.DOMAIN              ='PHONES'
		AND 	PN.X_TECHNOLOGY = cte_tech.x_technology				--
		AND		cte_manufacturer.VALUE2PART_CLASS(+) 	= pc.objid	--
		AND		cte_operating_sys.VALUE2PART_CLASS(+) 	= pc.objid	--
		AND		cte_feature.VALUE2PART_CLASS(+) 		= pc.objid	--
		AND		cte_ranking.VALUE2PART_CLASS(+) 		= pc.objid	--
		UNION
		--Only for tracfone (Union with above SQL)
		SELECT DISTINCT name,
						description,
						cte_manufacturer.X_PARAM_VALUE	manufacturer,	--
						cte_operating_sys.X_PARAM_VALUE	operating_sys,	--
						cte_feature.X_PARAM_VALUE		feature,
						NVL(cte_ranking.X_PARAM_VALUE, '999')	ranking			-- Defaulted to 999 if ranking is null
		FROM 	TABLE_PART_CLASS pc,
				table_x_part_class_values pcv,
				cte_manufacturer,	--
				cte_operating_sys,	--
				cte_feature,  		--
				cte_ranking  		--
		WHERE 	PC.X_MODEL_NUMBER IN('TFBYOPC4N', 'TF256PBYOPAPN')
		AND		cte_manufacturer.VALUE2PART_CLASS(+) 	= pc.objid	--
		AND		cte_operating_sys.VALUE2PART_CLASS(+) 	= pc.objid	--
		AND		cte_feature.VALUE2PART_CLASS(+) 		= pc.objid	--
		AND		cte_ranking.VALUE2PART_CLASS(+) 		= pc.objid	--
		ORDER BY name DESC;


          END IF;
          o_result_code := '0';
          o_result_msg  := 'SUCCESS';
        EXCEPTION
        WHEN no_data_found THEN
          o_result_code := '1';
          o_result_msg  := 'PART CLASS NOT FOUND';
          RETURN;
        WHEN OTHERS THEN
          o_result_code := '2';
          o_result_msg  := 'PART CLASS NOT FOUND';
          RETURN;
        END GETPHONEMODELS;
    END COVERAGE_MAPS_PKG;
/