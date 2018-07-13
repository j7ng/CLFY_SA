CREATE OR REPLACE FORCE VIEW sa.table_num_scheme (objid,"NAME","FORMAT",start_value,end_value,next_value,value_width,padded,date_order,day_format,month_format,year_format,time_format,reset_period,reset_time,last_change,jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,"DEC",dev) AS
SELECT OBJID,
   NAME,
   FORMAT,
   START_VALUE,
   END_VALUE,
   table_num_scheme_func(name) NEXT_VALUE,
   VALUE_WIDTH,
   PADDED,
   DATE_ORDER,
   DAY_FORMAT,
   MONTH_FORMAT,
   YEAR_FORMAT,
   TIME_FORMAT,
   RESET_PERIOD,
   RESET_TIME,
   LAST_CHANGE,
   JAN,
   FEB,
   MAR,
   APR,
   MAY,
   JUN,
   JUL,
   AUG,
   SEP,
   OCT,
   NOV,
   DEC,
   DEV
FROM table_num_scheme_base;
COMMENT ON TABLE sa.table_num_scheme IS 'Numbering scheme object which defines the format of auto numbering of objects; e.g., cases, change requests, sites, etc';
COMMENT ON COLUMN sa.table_num_scheme.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_num_scheme."NAME" IS 'Name of the number scheme.  Must match one of the valid number scheme names';
COMMENT ON COLUMN sa.table_num_scheme."FORMAT" IS 'String which defines the format of the auto-generated number';
COMMENT ON COLUMN sa.table_num_scheme.start_value IS 'First sequential number that should be automatically assigned';
COMMENT ON COLUMN sa.table_num_scheme.end_value IS 'Highest number that should be assigned. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.next_value IS 'The next incremental value that should be assigned';
COMMENT ON COLUMN sa.table_num_scheme.value_width IS 'Width of the number being defined';
COMMENT ON COLUMN sa.table_num_scheme.padded IS 'How number is padded; i.e., padded with zeros/not padded';
COMMENT ON COLUMN sa.table_num_scheme.date_order IS 'Order in which date elements occur; e.g., day-month-year; month-day-year; etc';
COMMENT ON COLUMN sa.table_num_scheme.day_format IS 'Format of the day element; e.g., 1,2, 01,02; etc. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.month_format IS 'Format of the month element; e.g., 1,2; i.e., 01,02; etc. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.year_format IS 'Format of the year element; e.g., 1993,1994; 93,94; etc. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.time_format IS 'Format of the time element; e.g., 12-hour, 24-hour, etc. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.reset_period IS 'Length of time interval between resetting of starting incremental value. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.reset_time IS 'Date/Time starting incremental value should be reset; e.g., 1st of each month. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.last_change IS 'Date/time the numbering format was last modified. Reserved; not used';
COMMENT ON COLUMN sa.table_num_scheme.jan IS 'Spelling of the month of January.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.feb IS 'Spelling of the month of February.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.mar IS 'Spelling of the month of March.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.apr IS 'Spelling of the month of April.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.may IS 'Spelling of the month of May.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.jun IS 'Spelling of the month of June.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.jul IS 'Spelling of the month of July.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.aug IS 'Spelling of the month of August.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.sep IS 'Spelling of the month of September.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.oct IS 'Spelling of the month of October.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.nov IS 'Spelling of the month of November.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme."DEC" IS 'Spelling of the month of December.  This is useful for internationalization';
COMMENT ON COLUMN sa.table_num_scheme.dev IS 'Row version number for mobile distribution purposes';