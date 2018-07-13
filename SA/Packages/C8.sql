CREATE OR REPLACE PACKAGE sa."C8"
AS

/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SPRINT2.sql                                                  */
/* PURPOSE:                                                                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.1.7.4 AND newer versions.                           */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO               PURPOSE                             */
/* -------  ----------  -------------  -------------------------------------- */
/* 1.0                                  Initial Revision                      */
/* 1.1      3/12/2003   MNazir		Number of rows limited to 2000	      */
/*                                      for get_deleted_lines procedure       */
/*									      */
/******************************************************************************/

    procedure get_new_lines;
    procedure get_deleted_lines;
    END ;
/