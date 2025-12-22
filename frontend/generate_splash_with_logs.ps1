Write-Host "========================================"
Write-Host "Flutter Splash Screen Generator with Logs"
Write-Host "========================================"
Write-Host ""

$logFile = "splash_generation_log.txt"

"Starting splash screen generation..." | Out-File $logFile
"Date: $(Get-Date)" | Out-File $logFile -Append
"" | Out-File $logFile -Append

$flutterPath = "C:\flutter\bin\flutter.bat"
$dartPath = "C:\flutter\bin\dart.bat"

Write-Host "Step 1: Running flutter pub get..."
"========================================" | Out-File $logFile -Append
"Step 1: $flutterPath pub get" | Out-File $logFile -Append
"========================================" | Out-File $logFile -Append
& $flutterPath pub get 2>&1 | Out-File $logFile -Append
Write-Host ""

Write-Host "Step 2: Running flutter pub run flutter_native_splash:create..."
"========================================" | Out-File $logFile -Append
"Step 2: $flutterPath pub run flutter_native_splash:create" | Out-File $logFile -Append
"========================================" | Out-File $logFile -Append
& $flutterPath pub run flutter_native_splash:create 2>&1 | Out-File $logFile -Append

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    "========================================" | Out-File $logFile -Append
    "Step 2 failed, trying alternative command..." | Out-File $logFile -Append
    "========================================" | Out-File $logFile -Append
    Write-Host "Step 2 failed! Trying alternative command..."
    Write-Host ""
    Write-Host "Step 3: Trying dart run flutter_native_splash:create..."
    "========================================" | Out-File $logFile -Append
    "Step 3: $dartPath run flutter_native_splash:create" | Out-File $logFile -Append
    "========================================" | Out-File $logFile -Append
    & $dartPath run flutter_native_splash:create 2>&1 | Out-File $logFile -Append
}

Write-Host ""
"========================================" | Out-File $logFile -Append
"Checking if splash files exist" | Out-File $logFile -Append
"========================================" | Out-File $logFile -Append

Write-Host "Step 4: Checking for generated files..."
if (Test-Path "android\app\src\main\res\drawable\launch_background.xml") {
    $msg = "[SUCCESS] Android splash screen files found!"
    Write-Host $msg -ForegroundColor Green
    $msg | Out-File $logFile -Append
} else {
    $msg = "[ERROR] Android splash screen files NOT found!"
    Write-Host $msg -ForegroundColor Red
    $msg | Out-File $logFile -Append
}

if (Test-Path "ios\Runner\Assets.xcassets\LaunchImage.imageset") {
    $msg = "[SUCCESS] iOS splash screen files found!"
    Write-Host $msg -ForegroundColor Green
    $msg | Out-File $logFile -Append
} else {
    $msg = "[WARNING] iOS splash screen files NOT found (might be expected if not building for iOS)"
    Write-Host $msg -ForegroundColor Yellow
    $msg | Out-File $logFile -Append
}

# Check if image file exists
Write-Host ""
if (Test-Path "assets\images\splash_white.png") {
    $msg = "[SUCCESS] Image file 'assets\images\splash_white.png' exists!"
    Write-Host $msg -ForegroundColor Green
    $msg | Out-File $logFile -Append
} else {
    $msg = "[ERROR] Image file 'assets\images\splash_white.png' NOT found!"
    Write-Host $msg -ForegroundColor Red
    $msg | Out-File $logFile -Append
}

Write-Host ""
"========================================" | Out-File $logFile -Append
"Process completed" | Out-File $logFile -Append
"========================================" | Out-File $logFile -Append
Write-Host ""
Write-Host "All logs saved to: splash_generation_log.txt" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please check the log file for details!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")