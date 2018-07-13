CREATE OR REPLACE PACKAGE sa.NapTable_Rebuild_pkg
/******************************************************************************/
/* Name         :  NapTableRebuild_Pkg
/* Purpose      :  Rebuilds NapTables based on master tables and mapinfo_data
/* Author       :  Gerald Pintado
/* Date         :  09/27/2005
/* Revisions    :
/* Version Date        Who            Purpose
/* ------- ----------  -------------  --------------------------
/* 1.0     09/27/2005  Gerald Pintado Initial Release
/******************************************************************************/
AS
   PROCEDURE REBUILD_CARRIERZONES
      (ip_tablename IN VARCHAR2,
        op_result  OUT VARCHAR2);

   PROCEDURE REBUILD_NPANXX2CARRIERZONES
      (ip_tablename IN VARCHAR2,
       op_result   OUT VARCHAR2);

   PROCEDURE REVERT_NAPTABLE
      (ip_tablename IN VARCHAR2,
       op_result   OUT VARCHAR2);

   PROCEDURE REVERT_NAPTABLE_MASTER
      (ip_tablename IN VARCHAR2,
       op_result   OUT VARCHAR2);

   PROCEDURE REBUILD_NPANXX2CARRIERZONES_M
      (op_result     OUT VARCHAR2);

   PROCEDURE REBUILD_CARRIERZONES_M
      (op_result     OUT VARCHAR2);

END NapTable_Rebuild_pkg;
/