# Install command
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All

# Checking installation
Get-WindowsOptionalFeature -Online -FeatureName "NetFx3"