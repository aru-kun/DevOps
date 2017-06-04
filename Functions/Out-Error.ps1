function Out-Error 
{ 
    #Output an error message, then terminate script unless -nobreak specified.
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$False)]
        $ErrorRecord, # message to display.
        [Parameter(Position=1,Mandatory=$False)]
        [string]$TailMessage, #append message after error message
        [switch]$OutString, #return error message as string
        [switch]$NoBreak # do not break out of script.
    )
    if($ErrorRecord)
    {
        switch($ErrorRecord.GetType().Name)
        {
        "ErrorRecord" {$ErrorMsg = "$($ErrorRecord.InvocationInfo.MyCommand) : $($ErrorRecord.ToString())`r`n$($ErrorRecord.InvocationInfo.PositionMessage)`r`n`t + CategoryInfo`t`t`t : $($ErrorRecord.CategoryInfo)`r`n`t + FullyQualifiedErrorId : $($ErrorRecord.FullyQualifiedErrorId)"}
        "String"      {$ErrorMsg = $ErrorRecord}
        default       {$ErrorMsg = 'ErrorRecord invalid type.'}
        }
    }
    else
    {
    $ErrorMsg = 'An unspecified error occured.'
    }
    if($TailMessage)
    {
    $ErrorMsg += "`r`n$($TailMessage)"
    }
    $Host.UI.WriteErrorLine($ErrorMsg)
    if($OutString) { return $ErrorMsg }
    if (!$NoBreak) { break __outOfScript; }
}