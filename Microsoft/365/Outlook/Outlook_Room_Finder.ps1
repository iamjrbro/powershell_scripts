# Creating a Distribution Group to add the Room List

New-DistributionGroup -Name "Distribution_Group_Name" -RoomList

# Adding members as you would add users to a regular distribution group

Add-DistributionGroupMember -Identity "Distribution_Group_Name" -Member "room_name@domain.com"

# Adding a location, floor and city to the room

Set-Place -Identity "room_name@domain.com" -Floor "rooms_floor" -City 'rooms_city'


# The following command returns the rooms details

Get-Mailbox -RecipientTypeDetails RoomMailbox | Sort DisplayName | Get-Place | ft DisplayName,City,Building,Floor

# To remove the Room from the Room's list

Remove-DistributionGroupMember -Identity "Distribution_Group_Name" -Member "sala@domain.com" -Confirm:$false

# to find the DGs
Get-DistributionGroup



#Quando você cria com New-DistributionGroup -Name, esse Name vira basicamente o Display Name + alguns atributos internos.

#Para alterar depois, você usa o Set-DistributionGroup.

#Se a sua intenção for só mudar o nome que aparece para os usuários (o mais comum), você faz assim:

Set-DistributionGroup -Identity "Distribution_Group_Name" -DisplayName "Novo Nome Bonito"

#Agora, se você quiser mudar o nome interno (o atributo Name), você pode fazer:

Set-DistributionGroup -Identity "Distribution_Group_Name" -Name "Novo_Nome_Interno"

#Mas na prática, o que mais impacta de verdade é o e-mail (alias/SMTP). Se você quiser mudar o endereço do grupo, aí é outro comando:

Set-DistributionGroup -Identity "Distribution_Group_Name" -PrimarySmtpAddress novoemail@domain.com

#Ou só o alias:

Set-DistributionGroup -Identity "Distribution_Group_Name" -Alias novoalias


# verificar horário definido na mailbox

Get-MailboxCalendarConfiguration "sala@domain.com" | fl WorkingHoursStartTime,WorkingHoursEndTime,WorkingHoursTimeZone

# verificar Booking restriction escondida

Get-CalendarProcessing "sala@domain.com" | fl AllBookInPolicy,AllRequestInPolicy,BookInPolicy

# verificar Timezone errado

Get-MailboxCalendarConfiguration "sala@domain.com" | fl WorkingHoursTimeZone

# corrigir timezone errado para o horário de Brasília

Set-MailboxCalendarConfiguration "sala@domain.com" `
-WorkingHoursTimeZone "E. South America Standard Time"

# validar timezone no horário de Brasília

Get-MailboxCalendarConfiguration "sala@domain.com" | fl WorkingHoursTimeZone

# padronizar horário de início e fim de agendamento das salas

Get-Mailbox -RecipientTypeDetails RoomMailbox | ForEach-Object {
    Set-MailboxCalendarConfiguration $_.PrimarySmtpAddress `
    -WorkingHoursStartTime workingHoursStartTime  `
    -WorkingHoursEndTime workingHoursEndTime
}