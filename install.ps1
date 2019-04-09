<#
    Install script for a Sitecore 9.0 Single instance
#>

# Installation for Prerequistes
#. $PSScriptRoot\Uninstall\Prerequisites.ps1

# Solr Setup
. $PSScriptRoot\Environment\Solr-Setup.ps1

# DB Setup
. $PSScriptRoot\Environment\Sql-Setup.ps1

# Bring parameters into scope
. $PSScriptRoot\parameters.ps1

### Run installs

# Sitecore Single Instance
Install-SitecoreConfiguration @certParams -Verbose
Install-SitecoreConfiguration @xConnectSolrParams
Install-SitecoreConfiguration @xconnectParams
Install-SitecoreConfiguration @solrParams
Install-SitecoreConfiguration @sitecoreParams