-- a comment in local
where split_part(uri,'/',1) in (
    'cadc:VGPS',
    'cadc:VLASS',
    'cadc:WALLABY',
    'casda:RACS'
) or (
    split_part(uri,'/',1) = 'nrao:VLASS'
    and (uriBucket between '00000' and '55555' or uriBucket between 'aaaab' and 'fffff')
)
