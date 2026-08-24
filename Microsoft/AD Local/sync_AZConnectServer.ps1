Import-Module ADSync

Start-ADSyncSyncCycle -PolicyType Initial #this command will start a full sync cycle, which is useful for testing and troubleshooting

Start-ADSyncSyncCycle Delta # this command will start a delta sync cycle, which is useful for testing and troubleshooting