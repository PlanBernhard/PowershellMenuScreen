<#
    .Description
    Created by Bernhard Sumser (2020-11-28)
    This powershell script displays an interactive menu by using the passed parameters
#>

[CmdletBinding()]
param (
    # Options to show
    [Parameter(Mandatory = $true)]
    [string[]]
    $OptionsToSelect,

    # Choose between Single or Multiselect
    [Parameter(Position = $true)]
    [bool]
    $MultiSelect
)

Clear-Host

<#
    .DESCRIPTION
    This function will show a interactive menu with the passed arguments as menu options.
    .INPUTS
    $MenuDescription - String that is shown in the menu title text.
    $MenuOptions - String array with the options to chose.
    .OUTPUTS
    Outputs a integer number. The first selection starts with 0.
#>
function ShowMultiSelectMenu() {
    [CmdletBinding()]
    param (
        # Text to display in menu
        [Parameter()]
        [string]
        $MenuDescription,

        # Options to select
        [Parameter(Mandatory = $true)]
        [string[]]
        $MenuOptions
    )

    $showMenu = $true
    $menuSelection = 0
    $somethingSelected = $true
    
    if (!$MenuOptions) {
        throw "MenuOptions cannot be Null!"
        Read-Host
    }
    
    $menuObjectList = New-Object Collections.Generic.List[object]
    
    foreach ($option in $MenuOptions) {
        $menuObjectList.Add(@{
                option = $option
                state  = $false
            })
    }
    
    do {
        Clear-Host
    
        if ($somethingSelected -eq $false) {
            Write-Host -BackgroundColor Red -ForegroundColor White "You need to select at least one option!"
        }
    
        Write-Host "-------------------------------------------------"
        Write-Host "| $MenuDescription "
        Write-Host "| ↑ and ↓ arrow key to chose                    |"
        Write-Host "| [SPACE] to select the highlighted choice      |"
        Write-host "| [ENTER] to accept your choices                |"
        Write-Host "-------------------------------------------------"
            
        foreach ($option in $menuObjectList) {
            # When selected but not chosen
            if ($menuObjectList.IndexOf($option) -eq $menuSelection -and $option.state -eq $false) {
                Write-Host -BackgroundColor Yellow -ForegroundColor Black "[ ]" $option.option
            }
            # When selected and chosen
            elseif ($menuObjectList.IndexOf($option) -eq $menuSelection -and $option.state -eq $true) {
                Write-Host -BackgroundColor Yellow -ForegroundColor Black "[*]" $option.option
            }
            # When not selected and chosen
            elseif ($menuObjectList.IndexOf($option) -ne $menuSelection -and $option.state -eq $true) {
                Write-Host "[*]" $option.option
            }
            # When not selected and not chosen
            else {
                Write-Host "[ ]" $option.option
            }
        }
    
        $keyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode
    
        Switch ($keyInput) {
            # ENTER key
            13 {
                $somethingSelected = $false
                foreach ($item in $menuObjectList) {
                    if ($item.state -eq $true) {
                        $somethingSelected = $true
                    }
                }
    
                if ($somethingSelected) {
                    $showMenu = $false
                    Clear-Host
                    break
                }
            }
    
            # SPACE key
            32 {
                if ($menuObjectList[$menuSelection].state -eq $false) {
                    $menuObjectList[$menuSelection].state = $true
                }
                else {
                    $menuObjectList[$menuSelection].state = $false
                }
                Clear-Host
                break
            }
    
            # top arrow key
            38 {
                if ($menuSelection -gt 0) {
                    $menuSelection -= 1
                }
                Clear-Host
                break
            }
    
            # down arrow key
            40 {
                if ($menuSelection -lt $MenuOptions.Length - 1) {
                    $menuSelection += 1
                }
                Clear-Host
                break
            }
            Default {
                Clear-Host
            }
        }
    }
    while ($showMenu)
    
    $arrayToReturn = @()
    
    foreach ($selection in $menuObjectList) {
        if ($selection.state -eq $true) {
            $arrayToReturn += $selection.option
        }
    }
    
    return $arrayToReturn
}

if($MultiSelect -eq $true){
    $selectionToReturn = ShowMultiSelectMenu -MenuDescription "What do you want to do?" -MenuOptions $OptionsToSelect

}
else{
    $selectionToReturn = ShowMultiSelectMenu -MenuDescription "What do you want to do?" -MenuOptions $OptionsToSelect
}

Write-Host "Selected option(s): "
Write-Host $selectionToReturn
return $selectionToReturn

