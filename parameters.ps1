<#
    Define the parameters going to used in the project here.
    All the parameters in the Project must be refered from here.
#>
[string]$Version = '6.6.2'
[string]$NssmVersion = '2.24'
[string]$Jre = 'jre1.8.0_172'
[int]$Port = 8983
[string]$HostName = 'localhost'
[ValidateScript( { Test-Path $_ -Type Container })]
[string]$DownloadPath = (Resolve-Path ~/Downloads)
[ValidateScript( { Test-Path $_ -Type Container })]
[string]$InstallPath = (Join-Path $env:SystemDrive '\')
$prefix = "sc901"
$XConnectCollectionService = "$prefix.xconnect"
$sitecoreSiteName = "$prefix.sc"
$SolrUrl = "https://$($HostName):$Port/solr"
$SolrRoot = "C:\Solr\$Version"
$SolrService = "Solr-$Version"
$SqlServer = "localhost"
$SqlAdminUser = "sa"
$SqlAdminPassword = "Password"
$configsRoot = Join-Path $PSScriptRoot Configs
$packagesRoot = Join-Path $PSScriptRoot Packages
$licenseFilePath = Join-Path $PSScriptRoot license.xml

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