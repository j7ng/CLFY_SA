CREATE OR REPLACE procedure sa.show_space
( p_segname in varchar2,
  p_owner   in varchar2 default user,
  p_type    in varchar2 default 'TABLE' )
as
    l_free_blks                 number;

    l_total_blocks              number;
    l_total_bytes               number;
    l_unused_blocks             number;
    l_unused_bytes              number;
    l_LastUsedExtFileId         number;
    l_LastUsedExtBlockId        number;
    l_LAST_USED_BLOCK           number;
    procedure p( p_label in varchar2, p_num in number )
    is
    begin
        dbms_output.put_line( rpad(p_label,40,'.') ||
                              p_num );
    end;
begin
    dbms_space.free_blocks
    ( segment_owner     => p_owner,
      segment_name      => p_segname,
      segment_type      => p_type,
      freelist_group_id => 0,
      free_blks         => l_free_blks );

    dbms_space.unused_space
    ( segment_owner     => p_owner,
      segment_name      => p_segname,
      segment_type      => p_type,
      total_blocks      => l_total_blocks,
      total_bytes       => l_total_bytes,
      unused_blocks     => l_unused_blocks,
      unused_bytes      => l_unused_bytes,
      LAST_USED_EXTENT_FILE_ID => l_LastUsedExtFileId,
      LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId,
      LAST_USED_BLOCK => l_LAST_USED_BLOCK );

    p( 'Free Blocks', l_free_blks );
    p( 'Total Blocks', l_total_blocks );
    p( 'Total Bytes', l_total_bytes );
    p( 'Unused Blocks', l_unused_blocks );
    p( 'Unused Bytes', l_unused_bytes );
    p( 'Last Used Ext FileId', l_LastUsedExtFileId );
    p( 'Last Used Ext BlockId', l_LastUsedExtBlockId );
    p( 'Last Used Block', l_LAST_USED_BLOCK );
end;
/