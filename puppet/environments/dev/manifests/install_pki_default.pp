include stdlib

$sslcerts = hiera(certs_for_system)
create_resources(sslmgmt::cert, $sslcerts)

$cacerts = hiera(ca_certs_for_system)
create_resources(sslmgmt::ca_dh, $cacerts)
