where split_part(uri,'/',1) in (
    'cadc:CGPS',
    'cadc:VGPS',
    'cadc:VLASS',
    'casda:RACS'
) or (
    split_part(uri,'/',1) = 'nrao:VLASS'
    and uriBucket between '00000' and 'aaaaa'
)
