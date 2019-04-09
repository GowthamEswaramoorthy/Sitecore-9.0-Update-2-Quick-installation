# Bring parameters into scope
. $PSScriptRoot\..\globalparameters.ps1

$uninstallArgs = @{
    Path = "$PSScriptRoot\uninstall.json"
    Prefix = $prefix
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    SqlServer = $sqlServer
}

Install-SitecoreConfiguration @uninstallArgs