
[string]$Version = '6.6.2'
[string]$NssmVersion = '2.24'
[string]$Jre = 'jre1.8.0_172'
[int]$Port = 8983
[string]$HostName = 'localhost'
[ValidateScript( { Test-Path $_ -Type Container })]
[string]$DownloadPath = (Resolve-Path ~/Downloads)
[ValidateScript( { Test-Path $_ -Type Container })]
[string]$InstallPath = (Join-Path $env:SystemDrive '\')

#define parameters
$prefix = "sc901"
$XConnectCollectionService = "$prefix.xconnect"
$sitecoreSiteName = "$prefix.sc"
$SolrUrl = "https://{$HostName}:{$Port}/solr"
$SolrRoot = "C:\Solr\{$Version}"
$SolrService = "Solr-{$Version}"
$SqlServer = "CHL117109"
$SqlAdminUser = "sa"
$SqlAdminPassword = "Password"
$configsRoot = Join-Path $PSScriptRoot Configs
$packagesRoot = Join-Path $PSScriptRoot Packages
$licenseFilePath = Join-Path $PSScriptRoot license.xml

