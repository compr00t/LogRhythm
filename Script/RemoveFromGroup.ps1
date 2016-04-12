Import-Module ActiveDirectory
Remove-ADGroupMember -Identity $args[0] -Members $args[1] -Confirm:$false