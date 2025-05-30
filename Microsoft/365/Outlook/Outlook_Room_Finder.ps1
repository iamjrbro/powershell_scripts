# Creating a Distribution Group to add the Room List

New-DistributionGroup -Name "Distribution_Group_Name" -RoomList

# Adding members as you would add users to a regular distribution group

Add-DistributionGroupMember -Identity "Distribution_Group_Name" -Member "room_name@domain.com"

# Adding a location, floor and city to the room

Set-Place -Identity "room_name@domain.com" -Rooms_Location -Rooms_Floor -City 'Rooms_City'

# The following command returns the rooms details

Get-Mailbox -RecipientTypeDetails RoomMailbox | Sort DisplayName | Get-Place | ft DisplayName,City,Building,Floor

# To remove the Room from the Room's list

Remove-DistributionGroupMember -Identity "Distribution_Group_Name" -Member "sala@domain.com" -Confirm:$false




