CREATE OR REPLACE PACKAGE sa."LOW_BALANCE_OFFER_PKG"
AS
  PROCEDURE GET_LB_QUAL_OFFER

/********************************************************************************/
/* Name         :   GET_LB_QUAL_OFFER 												 	                */
/* Copyright (r) 2009 Tracfone Wireless Inc. All rights reserved                */
/*                                                                              */
/* Purpose      :   Validate Low Balance Offers                                 */
/* Platforms    :   Oracle 10.2.0                                               */
/* Author       :   Ingrid Canavan                                              */
/* Date         :   08/13/2009                                                  */
/* Revisions    :                                                               */
/*                                                                              */
/* Version  Date        Who        Purpose                                      */
/* -------  --------    -------    --------------------------------------       */
/*  1.0	    08/13/09  ICanavan 		 New package                                  */
/*  1.2     04/09/10  ICanavan     XChange Media for Offier in GET_LB_QUAL_OFFER*/
/*                                                                              */
/*                                                                              */
/*                                                                              */
--#$Workfile: $
--$Revision: 1.3 $
--$Author: icanavan $
--$Modtime: $
--$ $Log: SA.LOW_BALANCE_OFFER_PKG.sql,v $
--$ Revision 1.3  2010/04/27 19:36:36  icanavan
--$ added firmware
--$
--$ Revision 1.2  2010/04/12 13:57:55  icanavan
--$ MOVE into CVS again after restore
--$
--$ Revision 1.1  2010/03/30 17:40:13  skuthadi
--$ To validate Offers, ESNs, Media
--$
/********************************************************************************/

    (P_ESN           IN  VARCHAR2,
     P_MSG_STR       OUT VARCHAR2,
     P_MSG_NUM       OUT VARCHAR2,
     P_MEDIA_CONTENT OUT VARCHAR2, -- 4/09/10 P_QUAL_OFFER
     P_MEDIA_OBJID   OUT NUMBER,
     P_OFFER_OBJID   OUT NUMBER) ;

  PROCEDURE PRESENTED_OFFER

/********************************************************************************/
/* Name         :   PRESENTED_OFFER   												 	                */
/* Copyright (r) 2009 Tracfone Wireless Inc. All rights reserved                */
/*                                                                              */
/* Purpose      :   Log Offer details after Presentation                        */
/* Platforms    :   Oracle 10.2.0                                               */
/* Author       :   Ingrid Canavan                                              */
/* Date         :   08/13/2009                                                  */
/* Revisions    :                                                               */
/*                                                                              */
/* Version  Date        Who             Purpose                                 */
/* -------  --------    -------         --------------------------------------  */
/*  1.0	    08/13/2009  ICanavan 		    New package                             */
/*  1.2     04/09/10    ICanavan        Pass back the trans id                  */
/*                                                                              */
/*                                                                              */
/*                                                                              */
/********************************************************************************/

     (ip_ESN            IN VARCHAR2,
     ip_QUAL_OFFER     IN VARCHAR2,
     ip_X_PRES_CHANNEL IN VARCHAR2,
     ip_MEDIA_OBJID    IN NUMBER,
     ip_OFFER_OBJID    IN NUMBER,
     ip_X_PRES_STATUS  IN VARCHAR2,
     ip_CLFY_CODE      IN VARCHAR2,
     ip_CLFY_MESSAGE   IN VARCHAR2,
     op_X_TRANS_ID     OUT VARCHAR2) ;

END;
/