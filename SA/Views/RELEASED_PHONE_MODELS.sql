CREATE OR REPLACE FORCE VIEW sa.released_phone_models (pc_objid,"NAME",description,release_date,model_type,available_online,manufacturer,sub_source_system,data_capable,technology,device_type) AS
SELECT                                                      /* ORDERED */
           pc.objid,
            pc.name,
            display_desc.description,
            rel.release_date,
            mo.model_type,
            avail.available_online,
            manu.manufacturer,
            sub_src_system.sub_source_system,
            NVL (data_capable.flag, 'N') data_capable,
            technology,
            (
              SELECT  pcv.x_param_value
              FROM    table_x_part_class_values pcv
              WHERE   pcv.value2part_class = pc.objid
              AND     pcv.value2class_param = (SELECT pcm.objid
                                                FROM  table_x_part_class_params pcm
                                                WHERE pcm.x_param_name ='DEVICE_TYPE')
            )  AS device_type
       FROM table_part_class pc,
            (SELECT DISTINCT
                    part_class,
                    TO_DATE (param_value, 'MM/DD/YYYY') release_date
               FROM pc_params_view
              WHERE     param_name = 'RELEASE_DATE'
                    AND ROWNUM = ROWNUM
                    AND ROWNUM < 1000000) rel,
            (SELECT DISTINCT part_class, param_value model_type
               FROM pc_params_view
              WHERE param_name = 'MODEL_TYPE' AND ROWNUM < 1000000) mo,
            (SELECT DISTINCT part_class, param_value available_online
               FROM pc_params_view
              WHERE param_name = 'AVAILABLE_ONLINE' AND ROWNUM < 1000000) avail,
            (SELECT DISTINCT part_class, param_value manufacturer
               FROM pc_params_view
              WHERE param_name = 'MANUFACTURER' AND ROWNUM < 1000000) manu,
            (SELECT DISTINCT part_class, param_value sub_source_system
               FROM pc_params_view
              WHERE param_name = 'BUS_ORG' AND ROWNUM < 1000000) sub_src_system,
            (SELECT DISTINCT part_class, param_value description
               FROM pc_params_view
              WHERE param_name = 'DISPLAY_DESCRIPTION' AND ROWNUM < 1000000) display_desc,
            (SELECT DISTINCT part_class, DECODE (param_value, 1, 'Y', 'N') flag
               FROM pc_params_view
              WHERE param_name = 'DATA_CAPABLE' AND ROWNUM < 1000000) data_capable,
            (SELECT DISTINCT part_class, param_value technology
               FROM pc_params_view
              WHERE param_name = 'TECHNOLOGY' AND ROWNUM < 1000000) technology
      WHERE 1 = 1
            AND EXISTS
                   (SELECT 1
                      FROM table_part_num pn
                     WHERE     active = 'Active'
                           AND pn.part_num2part_class = pc.objid
                           AND domain = 'PHONES'
                           AND x_technology IN ('GSM', 'CDMA', 'TDMA'))
            AND pc.name = rel.part_class
            AND pc.name = mo.part_class(+)
            AND pc.name = avail.part_class(+)
            AND pc.name = manu.part_class(+)
            AND pc.name = sub_src_system.part_class(+)
            AND pc.name = display_desc.part_class(+)
            AND pc.name = data_capable.part_class(+)
            AND pc.name = technology.part_class(+)
            AND release_date < SYSDATE
            AND ROWNUM < 10000000000000000
   ORDER BY RELEASE_DATE DESC;