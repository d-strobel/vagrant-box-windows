# Prepare password for new user
$plainPassword = "vagrant"
$password = $plainPassword | ConvertTo-SecureString -AsPlainText -Force

# Add vagrant user
$user = New-LocalUser `
    -Name "vagrant" `
    -FullName "vagrant" `
    -AccountNeverExpires `
    -Description "Vagrant default user" `
    -password $password `
    -PasswordNeverExpires `
    -UserMayNotChangePassword

# Add vagrant user to local administrators group
Add-LocalGroupMember `
    -Group "Administrators" `
    -Member $user
