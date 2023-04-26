# When org.opencadc.fenwick.artifactSelector=filter is specified, this config file
# specifying the included Artifacts is required. The single clause in the SQL file
# MUST begin with the WHERE keyword.
# ex:
# WHERE uri LIKE '%SOME CONDITION%'
where split_part(uri,'/',1) in (
    'cadc:VGPS',
    'cadc:VLASS',
    'cadc:WALLABY',
    'casda:RACS'
) or (
    split_part(uri,'/',1) = 'nrao:VLASS'
    and (uriBucket between '00000' and '55555' or uriBucket between 'aaaab' and 'fffff')
)
