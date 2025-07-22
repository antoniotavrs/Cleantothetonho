@echo off
chcp 65001 > nul

title Otimizacao e Reparo do Windows

echo.
echo Este script ira executar comandos de otimizacao e reparo no seu sistema Windows.
echo Voce sera perguntado antes de cada comando ser executado.
echo.

:MENU

echo ----------------------------------------------------------------------
echo                          MENU PRINCIPAL
echo ----------------------------------------------------------------------
echo 1. Executar SFC /SCANNOW (Verificador de Arquivos do Sistema)
echo 2. Executar DISM (Servico e Gerenciamento de Imagens de Implantacao)
echo 3. Executar CHKDSK (Verificador de Disco)
echo 4. Desfragmentar/Otimizar Unidades de Disco
echo 5. Limpar Arquivos Temporarios
echo 6. Executar TODOS os comandos (exceto desfragmentacao completa para HDs)
echo 7. Sair
echo ----------------------------------------------------------------------
echo.

set /p "choice=Escolha uma opcao (1-7): "

if "%choice%"=="1" goto SFC_SCAN
if "%choice%"=="2" goto DISM_SCAN
if "%choice%"=="3" goto CHKDSK_SCAN
if "%choice%"=="4" goto DEFRAG_MENU
if "%choice%"=="5" goto CLEAN_TEMP
if "%choice%"=="6" goto ALL_COMMANDS
if "%choice%"=="7" goto END
echo Opcao invalida. Por favor, escolha um numero de 1 a 7.
echo.
goto MENU

:SFC_SCAN
call :RUN_COMMAND "sfc /scannow" "Verificador de Arquivos do Sistema"
goto MENU

:DISM_SCAN
call :RUN_COMMAND "DISM /Online /Cleanup-Image /RestoreHealth" "DISM Restaurar Saude da Imagem"
goto MENU

:CHKDSK_SCAN
call :RUN_COMMAND "echo Y | chkdsk C: /f /r /x" "Verificador de Disco (CHDSK)"
echo.
echo Observacao: O CHKDSK pode exigir uma reinicializacao para ser executado.
echo Se solicitado, confirme a reinicializacao.
echo.
goto MENU

:DEFRAG_MENU
echo.
echo ----------------------------------------------------------------------
echo                  DESFRAGMENTAR/OTIMIZAR UNIDADES
echo ----------------------------------------------------------------------
echo 1. Analisar Desfragmentacao (Defrag /A) - Seguro para HDDs e SSDs
echo 2. Desfragmentar Disco Rigido (HDD) - *NAO RECOMENDADO PARA SSDs!*
echo 3. Otimizar Unidade (SSD/HDD) - Equivalente ao 'TRIM' para SSDs ou desfrag em HDDs
echo 4. Voltar ao Menu Principal
echo ----------------------------------------------------------------------
echo.

set /p "defrag_choice=Escolha uma opcao (1-4): "

if "%defrag_choice%"=="1" goto DEFRAG_ANALYZE
if "%defrag_choice%"=="2" goto DEFRAG_FULL
if "%defrag_choice%"=="3" goto DEFRAG_OPTIMIZE
if "%defrag_choice%"=="4" goto MENU
echo Opcao invalida. Por favor, escolha um numero de 1 a 4.
echo.
goto DEFRAG_MENU

:DEFRAG_ANALYZE
call :RUN_COMMAND "defrag C: /A" "Analise de Desfragmentacao da Unidade C:"
echo.
echo Para analisar outras unidades, digite 'defrag X: /A' no prompt de comando (substitua X pela letra da unidade).
goto DEFRAG_MENU

:DEFRAG_FULL
echo.
echo ========================= AVISO IMPORTANTE =========================
echo * A desfragmentacao completa (Defrag /V /U) e EXCLUSIVAMENTE para HDDs. *
echo * NUNCA execute este comando em um SSD, pois pode reduzir sua vida util. *
echo ====================================================================
echo.
set /p "confirm_defrag_full=Tem certeza que deseja desfragmentar uma unidade (S/N)? "
if /i "%confirm_defrag_full%"=="s" (
    call :RUN_COMMAND "defrag C: /V /U" "Desfragmentacao Completa da Unidade C: (HDD)"
    echo.
    echo Para desfragmentar outras unidades HDD, digite 'defrag X: /V /U' no prompt de comando (substitua X pela letra da unidade).
) else (
    echo Desfragmentacao completa ignorada.
)
goto DEFRAG_MENU

:DEFRAG_OPTIMIZE
echo.
echo Este comando e o equivalente ao 'Otimizar' no Windows,
echo executando 'TRIM' para SSDs e desfragmentacao para HDDs, se necessario.
echo E seguro para ambos os tipos de unidade.
echo.
call :RUN_COMMAND "defrag C: /O" "Otimizacao da Unidade C:"
echo.
echo Para otimizar outras unidades, digite 'defrag X: /O' no prompt de comando (substitua X pela letra da unidade).
goto DEFRAG_MENU

:CLEAN_TEMP
call :RUN_COMMAND "del /q /f /s %TEMP%\*" "Limpeza da pasta temporaria %TEMP%"
call :RUN_COMMAND "del /q /f /s C:\Windows\Temp\*" "Limpeza da pasta temporaria C:\Windows\Temp"
call :RUN_COMMAND "for /d %%p in ("%TEMP%\*") do rmdir "%%p" /s /q" "Limpeza de subpastas temporarias em %TEMP%"
call :RUN_COMMAND "for /d %%p in ("C:\Windows\Temp\*") do rmdir "%%p" /s /q" "Limpeza de subpastas temporarias em C:\Windows\Temp"
echo.
echo Pastas temporarias (temp e %%temp%%) limpas.
goto MENU

:ALL_COMMANDS
echo.
echo Voce escolheu executar TODOS os comandos.
echo (Exclui desfragmentacao completa de HDs devido aos avisos de seguranca).
echo.
call :SFC_SCAN
call :DISM_SCAN
call :CLEAN_TEMP
REM Nao inclui DEFRAG_FULL em ALL_COMMANDS devido ao aviso de seguranca.
REM O DEFRAG_OPTIMIZE e mais seguro para inclusao.
call :RUN_COMMAND "defrag C: /O" "Otimizacao da Unidade C: (seguro para SSD/HDD)"
call :CHKDSK_SCAN
echo.
echo Todos os comandos foram executados (exceto CHKDSK, que pode exigir reinicializacao, e desfragmentacao completa).
echo.
goto MENU

:RUN_COMMAND
set "command_to_run=%~1"
set "description=%~2"

echo.
echo ----------------------------------------------------------------------
echo Comando: %description%
echo Sera executado: %command_to_run%
echo ----------------------------------------------------------------------
echo.

set /p "confirm=Deseja executar este comando (S/N)? "

if /i "%confirm%"=="s" (
    echo Executando %command_to_run%...
    %command_to_run%
    echo Comando "%description%" concluido.
) else (
    echo Comando "%description%" ignorado.
)
echo.
goto :eof

:END
echo.
echo Saindo do script. Ate mais!
echo.
pause > nul
exit