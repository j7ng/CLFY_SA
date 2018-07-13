CREATE OR REPLACE PACKAGE sa."LOAD_SIM_INV_PKG"
IS
 --********************************************************************************
 --$RCSfile: LOAD_SIM_INV_PKG.sql,v $
 --$Revision: 1.4 $
 --$Author: skota $
 --$Date: 2015/09/16 20:20:05 $
 --$ $Log: LOAD_SIM_INV_PKG.sql,v $
 --$ Revision 1.4  2015/09/16 20:20:05  skota
 --$ Added heade comments for revision
 --$
 --$ Revision 1.3  2015/09/16 19:45:25  skota
 --$ Added header comments for revision
 --$
 --$ Added header comments for revision
 --$ Revision 1.2  2015/08/28 12:18:46  skota
 --$ New procedure added for UPDATE IMSI value in TABLE SIM INV
 --$ CR37514 changes.
 --********************************************************************************
--/**************************************************************************/
/* Name         :   SA.LOAD_SIM_INV_PKG
/* Purpose      :   ICCID FILE LOAD PROCESS into STAGING TABLE
/*
/* Author       :  Gerald Pintado
/* Date         :  04/15/2004
/* Revisions    :
/* Version  Date      Who      Purpose
/* -------  --------  -------  --------------------------
/* 1.0     04/15/2003 Gpintado Initial revision
/**************************************************************************/

PROCEDURE GET_TRANS_ID(IP_DUMMY IN VARCHAR2,OP_TRANS_ID OUT NUMBER);

PROCEDURE LOAD_SIM_STG(
     IP_SIM_SERIAL_NUM IN VARCHAR2,
     IP_SIM_PO_NUM     IN VARCHAR2,
     IP_PART_NUM       IN VARCHAR2,
     IP_MANUF_SITE_ID  IN VARCHAR2,
     IP_MANUF_NAME     IN VARCHAR2,
     IP_PIN1           IN VARCHAR2,
     IP_PIN2           IN VARCHAR2,
     IP_PUK1           IN VARCHAR2,
     IP_PUK2           IN VARCHAR2,
     IP_TRANS_ID       IN NUMBER,
     IP_QTY            IN NUMBER,
     IP_USEROBJID      IN NUMBER,
     OP_RESULT        OUT NUMBER,
     OP_MSG           OUT VARCHAR2
   );

PROCEDURE LOAD_SIM_INV(IP_TRANS_ID  IN  NUMBER,
                       OP_RESULT   OUT  NUMBER,
                       OP_MSG      OUT  VARCHAR2);
--CR35154
PROCEDURE SP_UPD_IMSI_SIM_INV
  ( ip_transaction_id IN  GW1.IG_TRANSACTION.transaction_id%TYPE);


END LOAD_SIM_INV_PKG;
/