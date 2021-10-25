$odLibs = Get-ChildItem -Path Registry::HKEY_CURRENT_USER\SOFTWARE\SyncEngines\Providers\OneDrive

$spLibs = $odLibs | Where-Object { $_.Name -notmatch 'personal' -and $_.Name -notmatch 'business' } | ForEach-Object { Get-ItemProperty $_.PSPath }

$spMounts = $spLibs | Where-Object { $_.LibraryType -notmatch 'mysite' }

$allSPMounts = [System.Collections.ArrayList]@()

ForEach ($spMount in $spMounts) {

    $spMountProperties = New-Object PSCustomObject

    $spMountProps = [ordered]@{
        Url = $spMount.UrlNamespace
        MountPoint = $spMount.MountPoint
        LibraryType = $spMount.LibraryType
        LastModifiedTime = $(if ($spMount.LastModifiedTime -as [DateTime]) { [datetime]::Parse($spMount.LastModifiedTime) } else { $_ })
        Path = $spMount.PSPath | Split-Path -NoQualifier
    }

    $spMountProperties | Add-Member -MemberType NoteProperty -Name Url -Value $spMountProps.Url
    $spMountProperties | Add-Member -MemberType NoteProperty -Name MountPoint -Value $spMountProps.MountPoint
    $spMountProperties | Add-Member -MemberType NoteProperty -Name LibraryType -Value (Get-Culture).TextInfo.ToTitleCase($spMountProps.LibraryType)
    $spMountProperties | Add-Member -MemberType NoteProperty -Name LastModifiedTime -Value $spMountProps.LastModifiedTime
    $spMountProperties | Add-Member -MemberType NoteProperty -Name Path -Value $spMountProps.Path

    $allSPMounts += $spMountProperties
}

$allSPMounts