<#
.SYNOPSIS
    Creates and verifies 47 fictional Active Directory lab users
    for Arx Corporation.

.DESCRIPTION
    Creates:
      - 22 DC Comics-themed users
      - 25 fictional common-name users

    Bruce Wayne, Clark Kent, and Diana Prince are intentionally
    excluded because they were created manually.

    Existing Active Directory objects:
      - Domain: arxcorp.com
      - Parent OU: _EMPLOYEES

    All 47 automated users are placed directly inside _EMPLOYEES.

    Each user receives:
      - Unique username
      - Unique random temporary password
      - Department attribute
      - Stable Employee ID
      - Departmental security-group membership

    Rerun behavior:
      - Existing users are not recreated
      - Existing users are checked for expected group membership
      - Missing group membership is repaired
      - Existing passwords are not changed

    Passwords:
      - 24 characters
      - Randomly generated using a cryptographic random-number generator
      - Different for every newly created account
      - Not stored in the script
      - Users must change the password at first logon

    A local CSV containing newly generated credentials is created
    for lab use. DO NOT upload this file to GitHub.

.NOTES
    Requires:
      - Windows Server
      - Active Directory Domain Services
      - ActiveDirectory PowerShell module
      - Elevated PowerShell session
      - Appropriate Active Directory permissions

    Intended for an isolated training/lab environment.
#>

# ============================================================
# CONFIGURATION
# ============================================================

$CompanyName   = "Arx Corporation"
$CompanyDomain = "arxcorp.com"
$BaseOUName    = "_EMPLOYEES"

$CredentialOutputPath = "$env:USERPROFILE\Desktop\Arx-Lab-User-Credentials.csv"

$Departments = @(
    "IT",
    "Finance",
    "HR"
)

# ============================================================
# VERIFY ELEVATED POWERSHELL SESSION
# ============================================================

$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()

$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentIdentity)

$IsElevated = $Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $IsElevated) {

    Write-Host ""
    Write-Host "ERROR: This script must be run from an elevated PowerShell window." `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Right-click Windows PowerShell and select:" `
        -ForegroundColor Yellow

    Write-Host "Run as administrator" -ForegroundColor Yellow
    Write-Host ""

    exit 1
}

Write-Host "Elevated PowerShell session confirmed." `
    -ForegroundColor Green

# ============================================================
# IMPORT ACTIVE DIRECTORY MODULE
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

# ============================================================
# GET CURRENT DOMAIN
# ============================================================

$Domain = Get-ADDomain -ErrorAction Stop

$DomainDN = $Domain.DistinguishedName
$CurrentDNSRoot = $Domain.DNSRoot

Write-Host ""
Write-Host "Company:          $CompanyName" -ForegroundColor Cyan
Write-Host "Domain:           $CurrentDNSRoot" -ForegroundColor Cyan
Write-Host "Domain DN:        $DomainDN" -ForegroundColor Cyan
Write-Host "Target OU:        $BaseOUName" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# VERIFY EXPECTED DOMAIN
# ============================================================

if ($CurrentDNSRoot -ne $CompanyDomain) {

    Write-Host "ERROR: Unexpected Active Directory domain." `
        -ForegroundColor Red

    Write-Host "Current domain:  $CurrentDNSRoot" `
        -ForegroundColor Red

    Write-Host "Expected domain: $CompanyDomain" `
        -ForegroundColor Red

    exit 1
}

# ============================================================
# LOCATE EXISTING _EMPLOYEES OU
# ============================================================

$BaseOU = Get-ADOrganizationalUnit `
    -Filter "Name -eq '$BaseOUName'" `
    -SearchBase $DomainDN `
    -ErrorAction SilentlyContinue

if (-not $BaseOU) {

    Write-Host ""
    Write-Host "ERROR: The _EMPLOYEES OU was not found." `
        -ForegroundColor Red

    Write-Host "Create _EMPLOYEES in AD Users and Computers before running this script." `
        -ForegroundColor Yellow

    Write-Host ""
    exit 1
}

Write-Host "Using existing OU:" -ForegroundColor Green
Write-Host "  $($BaseOU.DistinguishedName)" -ForegroundColor Green
Write-Host ""

# ============================================================
# CREATE / VERIFY DEPARTMENTAL SECURITY GROUPS
# ============================================================

foreach ($Department in $Departments) {

    $GroupName = "$Department-Users"

    $Group = Get-ADGroup `
        -Filter "SamAccountName -eq '$GroupName'" `
        -ErrorAction SilentlyContinue

    if (-not $Group) {

        Write-Host "Creating security group: $GroupName" `
            -ForegroundColor Green

        try {

            New-ADGroup `
                -Name $GroupName `
                -SamAccountName $GroupName `
                -GroupCategory Security `
                -GroupScope Global `
                -Path $DomainDN `
                -Description "$Department users for Arx Corporation IT portfolio lab" `
                -ErrorAction Stop

            Write-Host "  SUCCESS" -ForegroundColor Green
        }
        catch {

            Write-Host ""
            Write-Host "ERROR: Unable to create $GroupName" `
                -ForegroundColor Red

            Write-Host $_.Exception.Message `
                -ForegroundColor Red

            Write-Host ""
            Write-Host "User creation has been stopped to avoid creating accounts without their required security groups." `
                -ForegroundColor Yellow

            exit 1
        }
    }
    else {

        Write-Host "Security group already exists: $GroupName" `
            -ForegroundColor DarkYellow
    }
}

Write-Host ""

# ============================================================
# USER LIST
#
# Bruce Wayne
# Clark Kent
# Diana Prince
#
# are intentionally omitted because they were created manually.
# ============================================================

$Users = @(

    # ========================================================
    # DC COMICS USERS - 22
    # ========================================================

    [PSCustomObject]@{
        FirstName  = "Barry"
        LastName   = "Allen"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Arthur"
        LastName   = "Curry"
        Department = "Finance"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Victor"
        LastName   = "Stone"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Hal"
        LastName   = "Jordan"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "John"
        LastName   = "Stewart"
        Department = "Finance"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Jonn"
        LastName   = "Jonz"
        Department = "HR"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Oliver"
        LastName   = "Queen"
        Department = "Finance"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Kara"
        LastName   = "Danvers"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Lois"
        LastName   = "Lane"
        Department = "HR"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Jimmy"
        LastName   = "Olsen"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Selina"
        LastName   = "Kyle"
        Department = "Finance"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Pamela"
        LastName   = "Isley"
        Department = "HR"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Harleen"
        LastName   = "Quinzel"
        Department = "HR"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Edward"
        LastName   = "Nygma"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Harvey"
        LastName   = "Dent"
        Department = "Finance"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "James"
        LastName   = "Gordon"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Dick"
        LastName   = "Grayson"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Jason"
        LastName   = "Todd"
        Department = "Finance"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Tim"
        LastName   = "Drake"
        Department = "HR"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Barbara"
        LastName   = "Gordon"
        Department = "IT"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Stephanie"
        LastName   = "Brown"
        Department = "HR"
        Type       = "DC"
    }

    [PSCustomObject]@{
        FirstName  = "Cassandra"
        LastName   = "Cain"
        Department = "Finance"
        Type       = "DC"
    }

    # ========================================================
    # COMMON-NAME USERS - 25
    # ========================================================

    [PSCustomObject]@{
        FirstName  = "Michael"
        LastName   = "Carter"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Jennifer"
        LastName   = "Brooks"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "David"
        LastName   = "Miller"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Sarah"
        LastName   = "Thompson"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Robert"
        LastName   = "Wilson"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Jessica"
        LastName   = "Anderson"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Daniel"
        LastName   = "Martinez"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Ashley"
        LastName   = "Taylor"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Christopher"
        LastName   = "Moore"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Amanda"
        LastName   = "Jackson"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Matthew"
        LastName   = "Reed"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Emily"
        LastName   = "Bennett"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Andrew"
        LastName   = "Foster"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Lauren"
        LastName   = "Morgan"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Joshua"
        LastName   = "Phillips"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Megan"
        LastName   = "Cooper"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Ryan"
        LastName   = "Parker"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Rachel"
        LastName   = "Collins"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Anthony"
        LastName   = "Richardson"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Nicole"
        LastName   = "Ward"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Kevin"
        LastName   = "Murphy"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Samantha"
        LastName   = "Bailey"
        Department = "IT"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Brandon"
        LastName   = "Rivera"
        Department = "Finance"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Melissa"
        LastName   = "Richardson"
        Department = "HR"
        Type       = "Common"
    }

    [PSCustomObject]@{
        FirstName  = "Justin"
        LastName   = "Howard"
        Department = "IT"
        Type       = "Common"
    }
)

# ============================================================
# FUNCTION: SECURE RANDOM CHARACTER
# Compatible with Windows PowerShell 5.1
# ============================================================

function Get-SecureRandomCharacter {

    param (
        [string]$CharacterSet
    )

    $RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider

    try {

        $Byte = New-Object byte[] 1

        do {
            $RNG.GetBytes($Byte)
            $Value = $Byte[0]
        }
        while ($Value -ge (256 - (256 % $CharacterSet.Length)))

        return $CharacterSet[$Value % $CharacterSet.Length]
    }
    finally {

        $RNG.Dispose()
    }
}

# ============================================================
# FUNCTION: GENERATE SECURE RANDOM PASSWORD
# ============================================================

function New-RandomPassword {

    param (
        [int]$Length = 24
    )

    $Upper   = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    $Lower   = "abcdefghijkmnopqrstuvwxyz"
    $Numbers = "23456789"
    $Special = "!@#$%^&*()-_=+"

    $AllCharacters = $Upper + $Lower + $Numbers + $Special

    $Characters = New-Object System.Collections.Generic.List[char]

    # Guarantee complexity requirements
    $Characters.Add((Get-SecureRandomCharacter $Upper))
    $Characters.Add((Get-SecureRandomCharacter $Lower))
    $Characters.Add((Get-SecureRandomCharacter $Numbers))
    $Characters.Add((Get-SecureRandomCharacter $Special))

    # Fill remaining characters
    while ($Characters.Count -lt $Length) {

        $Characters.Add(
            (Get-SecureRandomCharacter $AllCharacters)
        )
    }

    # Securely shuffle the password characters
    for ($i = $Characters.Count - 1; $i -gt 0; $i--) {

        $RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider

        try {

            $Byte = New-Object byte[] 1

            do {
                $RNG.GetBytes($Byte)
                $Value = $Byte[0]
            }
            while ($Value -ge (256 - (256 % ($i + 1))))

            $j = $Value % ($i + 1)
        }
        finally {

            $RNG.Dispose()
        }

        $Temp = $Characters[$i]
        $Characters[$i] = $Characters[$j]
        $Characters[$j] = $Temp
    }

    return (-join $Characters)
}

# ============================================================
# FUNCTION: GENERATE UNIQUE SAM ACCOUNT NAME
# ============================================================

function Get-UniqueSamAccountName {

    param (
        [string]$FirstName,
        [string]$LastName
    )

    $CleanFirst = $FirstName -replace '[^a-zA-Z0-9]', ''
    $CleanLast  = $LastName  -replace '[^a-zA-Z0-9]', ''

    $BaseUsername = (
        $CleanFirst.Substring(0,1) + $CleanLast
    ).ToLower()

    $Username = $BaseUsername
    $Number = 1

    while (
        Get-ADUser `
            -Filter "SamAccountName -eq '$Username'" `
            -ErrorAction SilentlyContinue
    ) {

        $Username = "$BaseUsername$Number"
        $Number++
    }

    return $Username
}

# ============================================================
# PREPARE CREDENTIAL RESULTS
# ============================================================

$CredentialResults = @()

$CreatedCount = 0
$RepairedCount = 0
$SkippedCount = 0
$ErrorCount = 0

# ============================================================
# PROCESS USERS
# ============================================================

Write-Host ""
Write-Host "Beginning processing of $($Users.Count) automated users..." `
    -ForegroundColor Cyan
Write-Host ""

for ($UserIndex = 0; $UserIndex -lt $Users.Count; $UserIndex++) {

    $User = $Users[$UserIndex]

    $DisplayName = "$($User.FirstName) $($User.LastName)"

    # Stable ID based on fixed position in the list
    $EmployeeID = "LAB-$('{0:D3}' -f ($UserIndex + 1))"

    $GroupName = "$($User.Department)-Users"

    Write-Host "------------------------------------------------------------"
    Write-Host "Processing: $DisplayName" -ForegroundColor Cyan
    Write-Host "Department: $($User.Department)"
    Write-Host "Type:       $($User.Type)"
    Write-Host "EmployeeID: $EmployeeID"

    # ========================================================
    # CHECK FOR EXISTING USER
    # ========================================================

    $ExistingUser = Get-ADUser `
        -Filter "GivenName -eq '$($User.FirstName)' -and Surname -eq '$($User.LastName)'" `
        -Properties MemberOf `
        -ErrorAction SilentlyContinue

    if ($ExistingUser) {

        Write-Host "User already exists." -ForegroundColor DarkYellow

        # ----------------------------------------------------
        # REPAIR EXPECTED GROUP MEMBERSHIP IF NECESSARY
        # ----------------------------------------------------

        $ExpectedGroup = Get-ADGroup `
            -Identity $GroupName `
            -ErrorAction Stop

        $Membership = Get-ADPrincipalGroupMembership `
            -Identity $ExistingUser `
            -ErrorAction Stop

        $IsMember = $Membership |
            Where-Object { $_.SamAccountName -eq $GroupName }

        if (-not $IsMember) {

            Write-Host "Adding user to missing group: $GroupName" `
                -ForegroundColor Yellow

            try {

                Add-ADGroupMember `
                    -Identity $ExpectedGroup `
                    -Members $ExistingUser `
                    -ErrorAction Stop

                Write-Host "  GROUP MEMBERSHIP REPAIRED" `
                    -ForegroundColor Green

                $RepairedCount++
            }
            catch {

                Write-Host "  ERROR repairing group membership:" `
                    -ForegroundColor Red

                Write-Host $_.Exception.Message `
                    -ForegroundColor Red

                $ErrorCount++
            }
        }
        else {

            Write-Host "Expected group membership already exists." `
                -ForegroundColor DarkGreen
        }

        $SkippedCount++
        continue
    }

    # ========================================================
    # GENERATE USERNAME
    # ========================================================

    $SamAccountName = Get-UniqueSamAccountName `
        -FirstName $User.FirstName `
        -LastName $User.LastName

    $UserPrincipalName = "$SamAccountName@$CompanyDomain"

    # ========================================================
    # GENERATE UNIQUE RANDOM PASSWORD
    # ========================================================

    $TemporaryPassword = New-RandomPassword -Length 24

    $SecurePassword = ConvertTo-SecureString `
        $TemporaryPassword `
        -AsPlainText `
        -Force

    Write-Host "Username:   $SamAccountName"
    Write-Host "UPN:        $UserPrincipalName"

    # ========================================================
    # CREATE USER
    # ========================================================

    try {

        $NewUser = New-ADUser `
            -Name $DisplayName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -DisplayName $DisplayName `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UserPrincipalName `
            -Department $User.Department `
            -Company $CompanyName `
            -Description "Fictional user created for Arx Corporation IT portfolio lab" `
            -EmployeeID $EmployeeID `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -PasswordNeverExpires $false `
            -Path $BaseOU.DistinguishedName `
            -PassThru `
            -ErrorAction Stop

        Write-Host "  USER CREATED" -ForegroundColor Green
    }
    catch {

        Write-Host "  ERROR creating user:" `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        $ErrorCount++
        continue
    }

    # ========================================================
    # ADD USER TO DEPARTMENTAL GROUP
    # ========================================================

    try {

        Add-ADGroupMember `
            -Identity $GroupName `
            -Members $NewUser `
            -ErrorAction Stop

        Write-Host "  GROUP MEMBERSHIP ADDED: $GroupName" `
            -ForegroundColor Green
    }
    catch {

        Write-Host "  ERROR adding user to $GroupName" `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        $ErrorCount++
        continue
    }

    # ========================================================
    # SAVE CREDENTIAL INFORMATION
    # ========================================================

    $CredentialResults += [PSCustomObject]@{
        FirstName         = $User.FirstName
        LastName          = $User.LastName
        Username          = $SamAccountName
        TemporaryPassword = $TemporaryPassword
        Department        = $User.Department
        EmployeeID        = $EmployeeID
        Type              = $User.Type
    }

    $CreatedCount++

    Write-Host "  COMPLETE" -ForegroundColor Green
    Write-Host ""
}

# ============================================================
# EXPORT NEWLY CREATED CREDENTIALS
# ============================================================

if ($CredentialResults.Count -gt 0) {

    $CredentialResults |
        Export-Csv `
            -Path $CredentialOutputPath `
            -NoTypeInformation `
            -Encoding UTF8

    Write-Host ""
    Write-Host "Credential file created:" -ForegroundColor Yellow
    Write-Host "  $CredentialOutputPath" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================
# FINAL SUMMARY
# ============================================================

Write-Host ""
Write-Host "============================================================" `
    -ForegroundColor Cyan

Write-Host "ARX CORPORATION USER PROVISIONING COMPLETE" `
    -ForegroundColor Cyan

Write-Host "============================================================" `
    -ForegroundColor Cyan

Write-Host ""
Write-Host "Users defined:             $($Users.Count)"
Write-Host "New users created:         $CreatedCount"
Write-Host "Existing users processed:  $SkippedCount"
Write-Host "Group memberships repaired: $RepairedCount"
Write-Host "Errors:                    $ErrorCount"
Write-Host ""

Write-Host "All automated users belong directly to:" `
    -ForegroundColor Yellow

Write-Host "  $($BaseOU.DistinguishedName)" `
    -ForegroundColor Yellow

Write-Host ""
Write-Host "Departmental groups:" -ForegroundColor Yellow

foreach ($Department in $Departments) {

    Write-Host "  $Department-Users"
}

Write-Host ""
Write-Host "Manual administrators intentionally excluded:" `
    -ForegroundColor Yellow

Write-Host "  Bruce Wayne"
Write-Host "  Clark Kent"
Write-Host "  Diana Prince"

Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "The credential CSV contains temporary lab passwords."
Write-Host "Keep it off GitHub and delete it when it is no longer needed."
Write-Host ""
