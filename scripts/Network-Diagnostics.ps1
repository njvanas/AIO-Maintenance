# Network Diagnostics Tool
# Comprehensive network troubleshooting and information gathering

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "                   NETWORK DIAGNOSTICS TOOL" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Function to test connectivity
function Test-NetworkConnectivity {
    param([string]$Target, [string]$Description)
    
    Write-Host "Testing $Description..." -ForegroundColor Yellow
    $result = Test-Connection -ComputerName $Target -Count 2 -Quiet
    if ($result) {
        Write-Host "✓ $Description: Connected" -ForegroundColor Green
    } else {
        Write-Host "✗ $Description: Failed" -ForegroundColor Red
    }
    return $result
}

# 1. Network Adapter Information
Write-Host "[1/8] Network Adapter Information" -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Format-Table Name, InterfaceDescription, LinkSpeed, Status

# 2. IP Configuration
Write-Host "[2/8] IP Configuration" -ForegroundColor Cyan
Get-NetIPConfiguration | Format-Table InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer

# 3. DNS Configuration
Write-Host "[3/8] DNS Configuration" -ForegroundColor Cyan
Get-DnsClientServerAddress | Format-Table InterfaceAlias, AddressFamily, ServerAddresses

# 4. Connectivity Tests
Write-Host "[4/8] Connectivity Tests" -ForegroundColor Cyan
$tests = @(
    @{Target="8.8.8.8"; Description="Google DNS"},
    @{Target="1.1.1.1"; Description="Cloudflare DNS"},
    @{Target="google.com"; Description="Google.com"},
    @{Target="microsoft.com"; Description="Microsoft.com"}
)

foreach ($test in $tests) {
    Test-NetworkConnectivity -Target $test.Target -Description $test.Description
}

# 5. Network Statistics
Write-Host "[5/8] Network Statistics" -ForegroundColor Cyan
Get-NetAdapterStatistics | Format-Table Name, BytesReceived, BytesSent, PacketsReceived, PacketsSent

# 6. Active Network Connections
Write-Host "[6/8] Active Network Connections" -ForegroundColor Cyan
Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} | 
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | 
    Format-Table -AutoSize

# 7. Network Troubleshooting
Write-Host "[7/8] Network Troubleshooting" -ForegroundColor Cyan
Write-Host "Flushing DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns

Write-Host "Renewing IP configuration..." -ForegroundColor Yellow
ipconfig /release
ipconfig /renew

Write-Host "Resetting Winsock..." -ForegroundColor Yellow
netsh winsock reset

# 8. Speed Test (Simple)
Write-Host "[8/8] Basic Speed Test" -ForegroundColor Cyan
Write-Host "Performing basic latency test..." -ForegroundColor Yellow

$latencyResults = @()
$targets = @("8.8.8.8", "1.1.1.1", "google.com")

foreach ($target in $targets) {
    $ping = Test-Connection -ComputerName $target -Count 5 -ErrorAction SilentlyContinue
    if ($ping) {
        $avgLatency = ($ping | Measure-Object ResponseTime -Average).Average
        $latencyResults += [PSCustomObject]@{
            Target = $target
            AverageLatency = [math]::Round($avgLatency, 2)
        }
    }
}

$latencyResults | Format-Table Target, @{Name="Avg Latency (ms)"; Expression={$_.AverageLatency}}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "                 DIAGNOSTICS COMPLETED" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Network diagnostics have been completed." -ForegroundColor Green
Write-Host "If you're experiencing issues, try running this script as administrator." -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to continue"