# ==========================================================
# CENTRAL DE SUPORTE TI
# Versao 1.0
# Desenvolvido por: David Santos
# ==========================================================

# Forca UTF-8 no console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$DominioEmpresa = "bsb.ferreiraechagas.local"

#==========================================================
# FUNCOES AUXILIARES
#==========================================================

function Mostrar-Titulo {

    param(
        [string]$Titulo
    )

    Clear-Host

    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host (" {0}" -f $Titulo) -ForegroundColor Cyan
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host ""

}

function Voltar {

    Read-Host "`nPressione ENTER para voltar"

}

function Finalizar-Operacao {

    param(
        [bool]$Sucesso
    )

    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkGray

    if ($Sucesso) {

        Write-Host "OPERACAO CONCLUIDA COM SUCESSO." -ForegroundColor Green

    }
    else {

        Write-Host "OPERACAO FINALIZADA COM ERROS." -ForegroundColor Yellow

    }

    Write-Host "====================================================" -ForegroundColor DarkGray

    Voltar

}

function Executar-Comando {

    param(
        [string]$Descricao,
        [string]$Comando
    )

    Write-Host ""
    Write-Host $Descricao -ForegroundColor White

    try {

        $Saida = Invoke-Expression $Comando 2>&1

        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {

            Write-Host "      OK" -ForegroundColor Green
            return $true

        }
        else {

            Write-Host "      ERRO" -ForegroundColor Red

            if ($Saida) {

                Write-Host ""
                Write-Host "Mensagem do sistema:" -ForegroundColor Yellow
                $Saida | Out-Host

            }

            return $false

        }

    }
    catch {

        Write-Host "      ERRO" -ForegroundColor Red
        Write-Host ""
        Write-Host "Mensagem do sistema:" -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Red

        return $false

    }

}

#==========================================================
# REPAROS
#==========================================================

function Executar-ReparoSimples {

    Mostrar-Titulo "REPARO SIMPLES DE REDE"

    $Resultado = $true

    $Resultado = (Executar-Comando "[1/2] Limpando tickets Kerberos..." "klist purge") -and $Resultado
    $Resultado = (Executar-Comando "[2/2] Atualizando Politicas de Grupo..." "gpupdate /force") -and $Resultado

    Finalizar-Operacao $Resultado

}



function Executar-ReparoCompleto {

    Mostrar-Titulo "REPARO COMPLETO DE REDE"

    $Resultado = $true

    $Resultado = (Executar-Comando "[1/6] Limpando tickets Kerberos..." "klist purge") -and $Resultado

    $Resultado = (Executar-Comando "[2/6] Liberando Endereco IP..." "ipconfig /release") -and $Resultado

    $Resultado = (Executar-Comando "[3/6] Renovando Endereco IP..." "ipconfig /renew") -and $Resultado

    $Resultado = (Executar-Comando "[4/6] Limpando Cache DNS..." "ipconfig /flushdns") -and $Resultado

    $Resultado = (Executar-Comando "[5/6] Registrando DNS..." "ipconfig /registerdns") -and $Resultado

    $Resultado = (Executar-Comando "[6/6] Atualizando Politicas de Grupo..." "gpupdate /force") -and $Resultado

    Finalizar-Operacao $Resultado

}

function Executar-RenovarIP {

    Mostrar-Titulo "RENOVAR ENDERECO IP"

    $Resultado = $true

    $Resultado = (Executar-Comando "[1/2] Liberando Endereco IP..." "ipconfig /release") -and $Resultado

    $Resultado = (Executar-Comando "[2/2] Renovando Endereco IP..." "ipconfig /renew") -and $Resultado

    Finalizar-Operacao $Resultado

}

function Executar-AtualizarDNS {

    Mostrar-Titulo "ATUALIZAR DNS"

    $Resultado = $true

    $Resultado = (Executar-Comando "[1/2] Limpando Cache DNS..." "ipconfig /flushdns") -and $Resultado

    $Resultado = (Executar-Comando "[2/2] Registrando DNS..." "ipconfig /registerdns") -and $Resultado

    Finalizar-Operacao $Resultado

}

function Executar-SincronizarHora {

    Mostrar-Titulo "SINCRONIZAR DATA E HORA"

    $Resultado = $true

    $Resultado = (Executar-Comando "[1/2] Consultando Status..." "w32tm /query /status") -and $Resultado

    $Resultado = (Executar-Comando "[2/2] Sincronizando Horario..." "w32tm /resync") -and $Resultado

    Finalizar-Operacao $Resultado

}

function Executar-ResetRede {

    Mostrar-Titulo "RESET TCP/IP E WINSOCK"

    $Resultado = $true

    $Resultado = (Executar-Comando "[1/2] Resetando Winsock..." "netsh winsock reset") -and $Resultado

    $Resultado = (Executar-Comando "[2/2] Resetando TCP/IP..." "netsh int ip reset") -and $Resultado

    Write-Host ""
    Write-Host "IMPORTANTE: Reinicie o computador para concluir o reparo." -ForegroundColor Yellow

    Finalizar-Operacao $Resultado

}

#==========================================================
# DIAGNOSTICO DE REDE
#==========================================================


function Menu-DiagnosticoRede {

    do {

        Mostrar-Titulo "DIAGNOSTICO DE REDE"

        Write-Host " [1] Tracert ate o Dominio"
        Write-Host " [2] NSLookup"
        Write-Host " [3] IPConfig /all"
        Write-Host " [4] Route Print"
        Write-Host " [5] Localizar Controlador de Dominio"
        Write-Host ""
        Write-Host " [0] Voltar"
        Write-Host ""

        $OpcaoDiag = Read-Host "Escolha uma opcao"

        switch ($OpcaoDiag) {

            "1" { Executar-Tracert }

            "2" { Executar-NSLookup }

            "3" { Executar-IPConfig }

            "4" { Executar-RoutePrint }

            "5" { Executar-LocalizarDC }

        }

    } until ($OpcaoDiag -eq "0")

}

function Executar-Tracert {

    Mostrar-Titulo "TRACERT"

    tracert $DominioEmpresa

    Voltar

}

function Executar-NSLookup {

    Mostrar-Titulo "NSLOOKUP"

    $HostConsulta = Read-Host "Digite o host ou dominio"

    Write-Host ""

    nslookup $HostConsulta

    Voltar

}

function Executar-IPConfig {

    Mostrar-Titulo "IPCONFIG /ALL"

    ipconfig /all

    Voltar

}

function Executar-RoutePrint {

    Mostrar-Titulo "ROUTE PRINT"

    route print

    Voltar

}

function Executar-LocalizarDC {

    Mostrar-Titulo "CONTROLADOR DE DOMINIO"

    nltest /dsgetdc:$DominioEmpresa

    Voltar

}

#==========================================================
# WI-FI
#==========================================================

function Menu-Wifi {

    do {

        Mostrar-Titulo "WI-FI"

        Write-Host " [1] Mostrar Interfaces Wi-Fi"
        Write-Host " [2] Mostrar Senha de uma Rede"
        Write-Host ""
        Write-Host " [0] Voltar"
        Write-Host ""

        $OpcaoWifi = Read-Host "Escolha uma opcao"

        switch ($OpcaoWifi) {

            "1" { Executar-InterfacesWifi }

            "2" { Executar-SenhaWifi }

        }

    } until ($OpcaoWifi -eq "0")

}

function Executar-InterfacesWifi {

    Mostrar-Titulo "INTERFACES WI-FI"

    netsh wlan show interfaces

    Voltar

}

function Executar-SenhaWifi {

    Mostrar-Titulo "SENHA DA REDE"

    $Rede = Read-Host "Digite o nome da rede"

    Write-Host ""

    netsh wlan show profile name="$Rede" key=clear

    Voltar

}

#==========================================================
# ACTIVE DIRECTORY
#==========================================================

function Menu-ActiveDirectory {

    do {

        Mostrar-Titulo "ACTIVE DIRECTORY"

        Write-Host " [1] Consultar Usuario"
        Write-Host ""
        Write-Host " [0] Voltar"
        Write-Host ""

        $OpcaoAD = Read-Host "Escolha uma opcao"

        switch ($OpcaoAD) {

            "1" { Executar-ConsultarUsuario }

        }

    } until ($OpcaoAD -eq "0")

}

function Executar-ConsultarUsuario {

    Mostrar-Titulo "CONSULTA DE USUARIO"

    $Usuario = Read-Host "Digite o usuario"

    Write-Host ""

    net user $Usuario /domain

    Voltar

}

#==========================================================
# OUTROS
#==========================================================

function Menu-Outros {

    do {

        Mostrar-Titulo "OUTROS"

        Write-Host " [1] Sincronizar Data e Hora"
        Write-Host ""
        Write-Host " [0] Voltar"
        Write-Host ""

        $OpcaoOutros = Read-Host "Escolha uma opcao"

        switch ($OpcaoOutros) {

            "1" { Executar-SincronizarHora }

        }

    } until ($OpcaoOutros -eq "0")

}

#==========================================================
# MENU PRINCIPAL
#==========================================================



function Mostrar-Menu {

    Clear-Host

    $PC = $env:COMPUTERNAME
    $Usuario = $env:USERNAME
    $Data = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host "             CENTRAL DE SUPORTE TI" -ForegroundColor Cyan
    Write-Host "====================================================" -ForegroundColor DarkGray

    Write-Host ""
    Write-Host " Computador : $PC"
    Write-Host " Usuario    : $Usuario"
    Write-Host " Data       : $Data"

    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [1] Reparo Simples de Rede"
    Write-Host " [2] Reparo Completo de Rede"
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [3] Renovar Endereco IP"
    Write-Host " [4] Atualizar DNS"
    Write-Host " [5] Resetar TCP/IP e Winsock"
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [6] Diagnostico de Rede"
    Write-Host " [7] Wi-Fi"
    Write-Host " [8] Active Directory"
    Write-Host " [9] Outros"
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host " [0] Sair"
    Write-Host ""

}

do {

    Mostrar-Menu

    $Opcao = Read-Host "Escolha uma opcao"

    switch ($Opcao) {

        "1" { Executar-ReparoSimples }

        "2" { Executar-ReparoCompleto }

        "3" { Executar-RenovarIP }

        "4" { Executar-AtualizarDNS }

        "5" { Executar-ResetRede }

        "6" { Menu-DiagnosticoRede }

        "7" { Menu-Wifi }

        "8" { Menu-ActiveDirectory }

        "9" { Menu-Outros }

        "0" {

            Clear-Host
            Write-Host ""
            Write-Host "Obrigado por utilizar a Central de Suporte TI." -ForegroundColor Green
            Write-Host ""

        }

        default {

            Write-Host ""
            Write-Host "Opcao invalida." -ForegroundColor Red
            Start-Sleep -Seconds 1

        }

    }

} until ($Opcao -eq "0")