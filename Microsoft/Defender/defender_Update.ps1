# Execute os comandos em um Prompt de Comando como Administrador.

cd %ProgramFiles%\Windows Defender

# Remove definições dinâmicas existentes do Microsoft Defender.
MpCmdRun.exe -removedefinitions -dynamicsignatures

# Baixa e instala as assinaturas mais recentes do Microsoft Defender.
MpCmdRun.exe -SignatureUpdate
