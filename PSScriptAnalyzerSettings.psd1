@{
    # PSScriptAnalyzer Settings für SnipeIT Professional Inventory
    
    # Schweregrade die überprüft werden sollen
    Severity = @('Error', 'Warning', 'Information')
    
    # Regeln die ausgeschlossen werden sollen
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',  # Write-Host für Benutzerinteraktion erlaubt
        'PSUseShouldProcessForStateChangingFunctions'  # Nicht für alle Funktionen erforderlich
    )
    
    # Zusätzliche Regeln die eingeschlossen werden sollen
    IncludeRules = @(
        'PSUseApprovedVerbs',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingPlainTextForPassword',
        'PSUseCmdletCorrectly',
        'PSUseOutputTypeCorrectly'
    )
    
    # Pfade die analysiert werden sollen
    IncludeDefaultRules = $true
}
