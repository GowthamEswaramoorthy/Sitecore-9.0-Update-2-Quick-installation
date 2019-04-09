# Bring parameters into scope
. $PSScriptRoot\..\globalparameters.ps1

#install client certificate for xconnect
$certParams = @{
    Path            = Join-Path $configsRoot xconnect-createcert.json
    CertificateName = "$prefix.xconnect_client"
}

#install solr cores for xdb
$xConnectSolrParams = @{
    Path        = Join-Path $configsRoot xconnect-solr.json
    SolrUrl     = $SolrUrl
    SolrRoot    = $SolrRoot
    SolrService = $SolrService
    CorePrefix  = $prefix
}

#deploy xconnect instance
$xconnectParams = @{
    Path             = Join-Path $configsRoot xconnect-xp0.json
    Package          = Join-Path $packagesRoot 'Sitecore 9.0.2 rev. 180604 (OnPrem)_xp0xconnect.scwdp.zip'
    LicenseFile      = $licenseFilePath
    Sitename         = $XConnectCollectionService
    XConnectCert     = $certParams.CertificateName
    SqlDbPrefix      = $prefix
    SqlServer        = $SqlServer
    SqlAdminUser     = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SolrCorePrefix   = $prefix
    SolrURL          = $SolrUrl
}

#install solr cores for sitecore
$solrParams = @{
    Path        = Join-Path $configsRoot sitecore-solr.json
    SolrUrl     = $SolrUrl
    SolrRoot    = $SolrRoot
    SolrService = $SolrService
    CorePrefix  = $prefix
}

#install sitecore instance
$sitecoreParams = @{
    Path                      = Join-Path $configsRoot sitecore-XP0.json
    Package                   = Join-Path $packagesRoot 'Sitecore 9.0.2 rev. 180604 (OnPrem)_single.scwdp.zip'
    LicenseFile               = $licenseFilePath
    SqlDbPrefix               = $prefix
    SqlServer                 = $SqlServer
    SqlAdminUser              = $SqlAdminUser
    SqlAdminPassword          = $SqlAdminPassword
    SolrCorePrefix            = $prefix
    SolrUrl                   = $SolrUrl
    XConnectCert              = $certParams.CertificateName
    Sitename                  = $sitecoreSiteName
    XConnectCollectionService = "https://$XConnectCollectionService"
}