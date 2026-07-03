param(
    [string]$Action = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $Root
$Msys2 = if ($env:MSYS2_ROOT) { $env:MSYS2_ROOT } else { "H:\msys64" }
$UsrBin = Join-Path $Msys2 "usr\bin"
$MingwBin = Join-Path $Msys2 "mingw64\bin"
$Build = Join-Path $Root "build"
$Dist = Join-Path $Root "dist"
$IsoRoot = Join-Path $Build "iso"
$KernelObj = Join-Path $Build "kernel.o"
$KernelElf = Join-Path $Build "skyos.elf"
$DiskImg = Join-Path $Build "disk0.img"
$HdBoot = Join-Path $Build "hdboot.bin"
$HdStage2 = Join-Path $Build "hdstage2.bin"
$Iso = Join-Path $Dist "skyos.iso"
$IsoNew = Join-Path $Dist "skyos-new.iso"
$SkyOsVersion = "1.0.3.0.GSOSYGP"
$SkyOsInternalVersion = "10015"
$SkyOsSystemId = "skyos-10015"

$Nasm = Join-Path $UsrBin "nasm.exe"
$Ld = Join-Path $UsrBin "ld.lld.exe"
$Xorriso = Join-Path $UsrBin "xorriso.exe"
$GrubMkrescue = Join-Path $UsrBin "grub-mkrescue.exe"
$Qemu = Join-Path $MingwBin "qemu-system-i386.exe"
$QemuImg = Join-Path $MingwBin "qemu-img.exe"

function Get-NetDeviceArg {
    if ($env:SKYOS_MAC) {
        return "e1000,netdev=net0,mac=$env:SKYOS_MAC"
    }
    return "e1000,netdev=net0"
}

function Get-QemuCommonArgs {
    return @(
        "-machine", "pc,acpi=on",
        "-rtc", "base=localtime",
        "-accel", "tcg,thread=multi"
    )
}

function Get-QemuDisplayArgs {
    $vga = if ($env:SKYOS_VGA) { $env:SKYOS_VGA } else { "virtio" }
    $display = if ($env:SKYOS_DISPLAY) { $env:SKYOS_DISPLAY } else { "gtk,zoom-to-fit=on,show-tabs=off,full-screen=on" }
    return @("-vga", $vga, "-display", $display)
}

function Get-UserNetdevArg {
    if ($env:SKYOS_NETDEV) {
        return $env:SKYOS_NETDEV
    }
    return "user,id=net0,net=10.0.2.0/24,dhcpstart=10.0.2.15,dns=10.0.2.3,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22"
}

function Get-SataDiskArgs {
    return @(
        "-device", "ich9-ahci,id=sata0",
        "-drive", "id=skyosdisk,file=$DiskImg,format=raw,if=none,media=disk",
        "-device", "ide-hd,drive=skyosdisk,bus=sata0.0"
    )
}

function Require-Tool {
    param([string]$Path, [string]$Name)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing ${Name}: $Path"
    }
}

function Ensure-Dirs {
    New-Item -ItemType Directory -Force -Path $Build, $Dist | Out-Null
}

function Invoke-External {
    param([string]$File, [string[]]$ArgsList)
    $display = @($File) + $ArgsList
    Write-Host ("+ " + ($display -join " "))
    & $File @ArgsList
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $File"
    }
}

function Convert-ToMsysPath {
    param([string]$Value)
    if ($Value -match '^([A-Za-z]):\\(.*)$') {
        $drive = $Matches[1].ToLowerInvariant()
        $rest = $Matches[2] -replace '\\', '/'
        return "/$drive/$rest"
    }
    return $Value
}

function Invoke-XorrisoOutput {
    param([string[]]$ArgsList)
    $converted = @()
    foreach ($arg in $ArgsList) {
        $converted += Convert-ToMsysPath $arg
    }
    $display = @($Xorriso) + $converted
    Write-Host ("+ " + ($display -join " "))
    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = (& $Xorriso @converted 2>&1 | ForEach-Object { "$_" }) -join [Environment]::NewLine
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    if ($exitCode -ne 0) {
        throw $output
    }
    return $output
}

function Move-FinalIso {
    if (Test-Path -LiteralPath $IsoNew) {
        try {
            Remove-Item -LiteralPath $Iso -Force -ErrorAction SilentlyContinue
            Move-Item -LiteralPath $IsoNew -Destination $Iso -Force
            Ensure-ContiguousFile $Iso
            return $Iso
        } catch {
            Write-Host "Existing ISO is busy; new ISO kept at $IsoNew"
            Ensure-ContiguousFile $IsoNew
            return $IsoNew
        }
    }
    Ensure-ContiguousFile $Iso
    return $Iso
}

function Get-FileExtentCount {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return 0
    }
    $output = & fsutil.exe file queryextents $Path 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        return 0
    }
    return @($output | Where-Object { $_ -match '^\s*VCN:' }).Count
}

function Ensure-ContiguousFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }
    $extentCount = Get-FileExtentCount $Path
    if ($extentCount -le 1) {
        if ($extentCount -eq 1) {
            Write-Host "ISO is contiguous: $Path"
        }
        return
    }

    $dir = Split-Path -Parent $Path
    $name = Split-Path -Leaf $Path
    $compact = Join-Path $dir ($name + ".compact")
    Remove-Item -LiteralPath $compact -Force -ErrorAction SilentlyContinue
    Copy-Item -LiteralPath $Path -Destination $compact -Force
    $compactExtents = Get-FileExtentCount $compact
    if ($compactExtents -le 1 -and $compactExtents -gt 0) {
        Move-Item -LiteralPath $compact -Destination $Path -Force
        Write-Host "Compacted ISO to one extent: $Path"
        return
    }

    Remove-Item -LiteralPath $compact -Force -ErrorAction SilentlyContinue
    Write-Host "ISO still has $extentCount extents; run defrag /U /V $Path if GRUB boots it from NTFS."
}

function Build-Kernel {
    Require-Tool $Nasm "NASM"
    Require-Tool $Ld "LLD"
    Ensure-Dirs
    Invoke-External $Nasm @("-f", "bin", "boot/hdboot.asm", "-o", $HdBoot)
    Invoke-External $Nasm @("-f", "bin", "boot/hdstage2.asm", "-o", $HdStage2)
    Invoke-External $Nasm @("-f", "elf32", "src/kernel.asm", "-o", $KernelObj)
    Invoke-External $Ld @("-m", "elf_i386", "-T", "linker.ld", "-o", $KernelElf, $KernelObj)
    Write-Host "Built $KernelElf"
}

function Build-Img {
    Require-Tool $QemuImg "qemu-img"
    Require-Tool $Nasm "NASM"
    Ensure-Dirs
    Build-Kernel
    if (-not (Test-Path -LiteralPath $DiskImg)) {
        Invoke-External $QemuImg @("create", "-f", "raw", $DiskImg, "64M")
    } else {
        Write-Host "Exists $DiskImg"
    }

    Invoke-External $Nasm @("-f", "bin", "boot/hdboot.asm", "-o", $HdBoot)
    Invoke-External $Nasm @("-f", "bin", "boot/hdstage2.asm", "-o", $HdStage2)

    $stage2Size = (Get-Item -LiteralPath $HdStage2).Length
    if ($stage2Size -gt (15 * 512)) {
        throw "hdstage2.bin is too large: $stage2Size bytes"
    }
    $kernelSize = (Get-Item -LiteralPath $KernelElf).Length
    if ($kernelSize -gt ((2048 - 16) * 512)) {
        throw "Kernel is too large for reserved boot area before partition 0: $kernelSize bytes"
    }

    $stream = [System.IO.File]::Open($DiskImg, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read)
    try {
        $bootBytes = [System.IO.File]::ReadAllBytes($HdBoot)
        $stage2Bytes = [System.IO.File]::ReadAllBytes($HdStage2)
        $kernelBytes = [System.IO.File]::ReadAllBytes($KernelElf)

        $stream.Position = 0
        $stream.Write($bootBytes, 0, $bootBytes.Length)
        $stream.Position = 512
        $stream.Write($stage2Bytes, 0, $stage2Bytes.Length)
        $stream.Position = 16 * 512
        $stream.Write($kernelBytes, 0, $kernelBytes.Length)
        $skyfsSuper = New-SkyFsSuperblockSector
        $skyfsManifest = New-FixedAsciiSector "SkyOS installed root metadata; files=/etc/os-release,/sbin/init,/bin/skysh,/etc/passwd,/etc/shadow,/etc/sudoers,/boot/loader.conf,/etc/sapp/sources.list; source=run.ps1 img; fs=SkyFS-v0"
        $skyfsFiles = @(
            [pscustomobject]@{ Path = "/etc/os-release"; Lba = 16; Data = "NAME=SkyOS`nVERSION=$SkyOsVersion`nVERSION_ID=$SkyOsVersion`nBUILD_ID=$SkyOsInternalVersion`nID=skyos`nARCH=i386`nROOTFS=skyfs`n" },
            [pscustomobject]@{ Path = "/sbin/init"; Lba = 17; Data = "#!/bin/soj`necho SkyOS init from SkyFS`nexec mount`nexec features`n" },
            [pscustomobject]@{ Path = "/bin/skysh"; Lba = 18; Data = "SkyOS builtin shell entrypoint loaded from SkyFS metadata.`n" },
            [pscustomobject]@{ Path = "/etc/passwd"; Lba = 19; Data = "root:x:0:0:root:/root:/bin/skysh`nuser:x:1000:1000:SkyOS User:/home/user:/bin/skysh`n" },
            [pscustomobject]@{ Path = "/etc/shadow"; Lba = 20; Data = "root:skyos:0:0:99999:7:::`nuser:skyuser:0:0:99999:7:::`n" },
            [pscustomobject]@{ Path = "/etc/sudoers"; Lba = 21; Data = "root ALL=(ALL) ALL`n%wheel ALL=(ALL) ALL`nuser ALL=(root) ALL`n" },
            [pscustomobject]@{ Path = "/boot/loader.conf"; Lba = 22; Data = "bootloader=skyos-hdstage2`nkernel_lba=16`nroot=/dev/disk0p0`nrootfstype=skyfs`ninit=/sbin/init`n" },
            [pscustomobject]@{ Path = "/etc/sapp/sources.list"; Lba = 23; Data = "deb http://skyapps.skyu.cc.cd skyos main`n" }
        )
        $dirEntries = @()
        foreach ($file in $skyfsFiles) {
            $dirEntries += [pscustomobject]@{
                Path = $file.Path
                Lba = $file.Lba
                Size = [System.Text.Encoding]::ASCII.GetByteCount($file.Data)
            }
        }
        $skyfsDirectory = New-SkyFsDirectorySector $dirEntries
        $stream.Position = 2048 * 512
        $stream.Write($skyfsSuper, 0, $skyfsSuper.Length)
        $stream.Position = 2049 * 512
        $stream.Write($skyfsManifest, 0, $skyfsManifest.Length)
        $stream.Position = 2050 * 512
        $stream.Write($skyfsDirectory, 0, $skyfsDirectory.Length)
        foreach ($file in $skyfsFiles) {
            $sector = New-FixedAsciiSector $file.Data
            $stream.Position = (2048 + $file.Lba) * 512
            $stream.Write($sector, 0, $sector.Length)
        }
    } finally {
        $stream.Dispose()
    }

    Write-Host "Installed hard-disk boot chain:"
    Write-Host "  MBR stage1: LBA 0"
    Write-Host "  stage2:     LBA 1..15"
    Write-Host "  kernel ELF: LBA 16"
    Write-Host "  SkyFS p0:   LBA 2048"
}

function Ensure-DiskImage {
    Require-Tool $QemuImg "qemu-img"
    Ensure-Dirs
    if (-not (Test-Path -LiteralPath $DiskImg)) {
        Invoke-External $QemuImg @("create", "-f", "raw", $DiskImg, "64M")
    } else {
        Write-Host "Exists $DiskImg"
    }
}

function New-BlankDiskImage {
    Require-Tool $QemuImg "qemu-img"
    Ensure-Dirs
    Remove-Item -LiteralPath $DiskImg -Force -ErrorAction SilentlyContinue
    Invoke-External $QemuImg @("create", "-f", "raw", $DiskImg, "64M")
    Write-Host "Created blank disk image: $DiskImg"
}

function Write-TextFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.Encoding]::UTF8)
}

function Write-SkyIconPng {
    param([string]$Path, [string]$Kind)
    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $bitmap = $null
    $graphics = $null
    $black = $null
    $blackBrush = $null
    $white = $null
    $blue = $null
    $cyan = $null
    $gray = $null
    $green = $null
    $yellow = $null
    $red = $null
    $font = $null
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $bitmap = [System.Drawing.Bitmap]::new(32, 32)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $black = [System.Drawing.Pen]::new([System.Drawing.Color]::Black, 1)
        $blackBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::Black)
        $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
        $blue = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(42, 112, 210))
        $cyan = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(0, 150, 180))
        $gray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(205, 205, 205))
        $green = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(40, 160, 88))
        $yellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 190, 40))
        $red = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(210, 60, 60))
        switch ($Kind) {
            "folder" {
                $graphics.FillRectangle($yellow, 3, 9, 26, 18)
                $graphics.FillRectangle($yellow, 5, 6, 10, 5)
                $graphics.DrawRectangle($black, 3, 9, 26, 18)
            }
            "terminal" {
                $graphics.FillRectangle($blackBrush, 3, 5, 26, 22)
                $font = [System.Drawing.Font]::new("Consolas", 10)
                $graphics.DrawString(">", $font, $green, 7, 9)
                $graphics.DrawLine([System.Drawing.Pen]::new([System.Drawing.Color]::Lime, 1), 17, 20, 25, 20)
            }
            "browser" {
                $graphics.FillEllipse($cyan, 4, 4, 24, 24)
                $graphics.DrawEllipse($black, 4, 4, 24, 24)
                $graphics.DrawLine($black, 16, 5, 16, 27)
                $graphics.DrawLine($black, 5, 16, 27, 16)
            }
            "notepad" {
                $graphics.FillRectangle($white, 6, 3, 20, 26)
                $graphics.DrawRectangle($black, 6, 3, 20, 26)
                $graphics.DrawLine($black, 10, 10, 22, 10)
                $graphics.DrawLine($black, 10, 15, 22, 15)
                $graphics.DrawLine($black, 10, 20, 19, 20)
            }
            "taskmgr" {
                $graphics.FillRectangle($gray, 4, 4, 24, 24)
                $graphics.DrawRectangle($black, 4, 4, 24, 24)
                $graphics.FillRectangle($green, 8, 20, 4, 5)
                $graphics.FillRectangle($blue, 14, 14, 4, 11)
                $graphics.FillRectangle($red, 20, 9, 4, 16)
            }
            "media" {
                $graphics.FillRectangle($blue, 4, 5, 24, 20)
                $graphics.DrawRectangle($black, 4, 5, 24, 20)
                $graphics.FillPolygon($green, [System.Drawing.Point[]]@([System.Drawing.Point]::new(8, 22), [System.Drawing.Point]::new(16, 13), [System.Drawing.Point]::new(27, 22)))
                $graphics.FillEllipse($yellow, 20, 8, 5, 5)
            }
            default {
                $graphics.FillRectangle($blue, 5, 5, 22, 22)
                $graphics.DrawRectangle($black, 5, 5, 22, 22)
            }
        }
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        if ($graphics) { $graphics.Dispose() }
        if ($bitmap) { $bitmap.Dispose() }
        if ($black) { $black.Dispose() }
        if ($font) { $font.Dispose() }
        foreach ($brush in @($blackBrush, $white, $blue, $cyan, $gray, $green, $yellow, $red)) {
            if ($brush) { $brush.Dispose() }
        }
    }
}

function New-FixedAsciiSector {
    param([string]$Text)
    $sector = New-Object byte[] 512
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($Text)
    $count = [Math]::Min($bytes.Length, 511)
    [Array]::Copy($bytes, 0, $sector, 0, $count)
    return $sector
}

function New-SkyFsSuperblockSector {
    $sector = New-Object byte[] 512
    [Array]::Copy([System.Text.Encoding]::ASCII.GetBytes("SKYF"), 0, $sector, 0, 4)
    [BitConverter]::GetBytes([UInt32]1).CopyTo($sector, 4)
    [BitConverter]::GetBytes([UInt32]512).CopyTo($sector, 8)
    [BitConverter]::GetBytes([UInt32]65536).CopyTo($sector, 12)
    [BitConverter]::GetBytes([UInt32]2).CopyTo($sector, 16)
    [BitConverter]::GetBytes([UInt32]5).CopyTo($sector, 20)
    [BitConverter]::GetBytes([UInt32]16).CopyTo($sector, 24)
    $label = [System.Text.Encoding]::ASCII.GetBytes("SkyOS root disk0p0")
    [Array]::Copy($label, 0, $sector, 64, $label.Length)
    $note = [System.Text.Encoding]::ASCII.GetBytes("SkyFS v0 superblock: sector 0 super, sector 1 install manifest, data follows")
    [Array]::Copy($note, 0, $sector, 128, $note.Length)
    return $sector
}

function New-SkyFsDirectorySector {
    param([object[]]$Entries)
    $sector = New-Object byte[] 512
    for ($i = 0; $i -lt $Entries.Count -and $i -lt 8; $i++) {
        $entry = $Entries[$i]
        $offset = $i * 64
        $pathBytes = [System.Text.Encoding]::ASCII.GetBytes($entry.Path)
        $pathCount = [Math]::Min($pathBytes.Length, 47)
        [Array]::Copy($pathBytes, 0, $sector, $offset, $pathCount)
        [BitConverter]::GetBytes([UInt32]$entry.Lba).CopyTo($sector, $offset + 48)
        [BitConverter]::GetBytes([UInt32]$entry.Size).CopyTo($sector, $offset + 52)
        [BitConverter]::GetBytes([UInt32]1).CopyTo($sector, $offset + 56)
    }
    return $sector
}

function Write-TarString {
    param([byte[]]$Header, [int]$Offset, [int]$Length, [string]$Value)
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($Value)
    $count = [Math]::Min($bytes.Length, $Length)
    [Array]::Copy($bytes, 0, $Header, $Offset, $count)
}

function Write-TarOctal {
    param([byte[]]$Header, [int]$Offset, [int]$Length, [Int64]$Value)
    $text = [Convert]::ToString($Value, 8).PadLeft($Length - 1, "0")
    Write-TarString $Header $Offset ($Length - 1) $text
}

function Add-TarEntry {
    param(
        [System.IO.Stream]$Stream,
        [string]$Name,
        [byte[]]$Data,
        [bool]$IsDirectory
    )
    $entryName = $Name.Replace("\", "/").TrimStart("/")
    if ($IsDirectory -and -not $entryName.EndsWith("/")) {
        $entryName += "/"
    }
    $header = New-Object byte[] 512
    Write-TarString $header 0 100 $entryName
    Write-TarOctal $header 100 8 $(if ($IsDirectory) { 493 } else { 420 })
    Write-TarOctal $header 108 8 0
    Write-TarOctal $header 116 8 0
    Write-TarOctal $header 124 12 $(if ($IsDirectory) { 0 } else { $Data.Length })
    Write-TarOctal $header 136 12 ([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
    for ($i = 148; $i -lt 156; $i++) { $header[$i] = 32 }
    $header[156] = if ($IsDirectory) { [byte][char]"5" } else { [byte][char]"0" }
    Write-TarString $header 257 6 "ustar"
    Write-TarString $header 263 2 "00"
    $sum = 0
    foreach ($b in $header) { $sum += $b }
    $check = ([Convert]::ToString($sum, 8).PadLeft(6, "0") + "`0 ")
    Write-TarString $header 148 8 $check
    $Stream.Write($header, 0, 512)
    if (-not $IsDirectory -and $Data.Length -gt 0) {
        $Stream.Write($Data, 0, $Data.Length)
        $pad = (512 - ($Data.Length % 512)) % 512
        if ($pad -gt 0) {
            $zeros = New-Object byte[] $pad
            $Stream.Write($zeros, 0, $pad)
        }
    }
}

function Write-TarGzArchive {
    param([string]$SourceDir, [string]$OutputFile)
    $outDir = Split-Path -Parent $OutputFile
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    $fileStream = [System.IO.File]::Create($OutputFile)
    try {
        $gzip = New-Object System.IO.Compression.GzipStream($fileStream, [System.IO.Compression.CompressionLevel]::Optimal)
        try {
            $sourceFull = (Resolve-Path -LiteralPath $SourceDir).Path
            $dirs = Get-ChildItem -LiteralPath $SourceDir -Directory -Recurse | Sort-Object FullName
            foreach ($dir in $dirs) {
                $name = $dir.FullName.Substring($sourceFull.Length).TrimStart("\", "/")
                Add-TarEntry $gzip $name ([byte[]]@()) $true
            }
            $files = Get-ChildItem -LiteralPath $SourceDir -File -Recurse | Sort-Object FullName
            foreach ($file in $files) {
                $name = $file.FullName.Substring($sourceFull.Length).TrimStart("\", "/")
                $data = [System.IO.File]::ReadAllBytes($file.FullName)
                Add-TarEntry $gzip $name $data $false
            }
            $zeros = New-Object byte[] 1024
            $gzip.Write($zeros, 0, $zeros.Length)
        } finally {
            $gzip.Dispose()
        }
    } finally {
        $fileStream.Dispose()
    }
}

function Initialize-IsoPayload {
    Remove-Item -LiteralPath $IsoRoot -Recurse -Force -ErrorAction SilentlyContinue
    $bootDir = Join-Path $IsoRoot "boot"
    $grubDir = Join-Path $bootDir "grub"
    New-Item -ItemType Directory -Force -Path $grubDir | Out-Null

    $rootfs = Join-Path $Build "rootfs"
    $initramfs = Join-Path $Build "initramfs"
    Remove-Item -LiteralPath $rootfs, $initramfs -Recurse -Force -ErrorAction SilentlyContinue

    $rootDirs = @(
        "bin", "sbin", "etc\sapp", "etc\systemd\system", "dev", "home\root", "home\user",
        "lib\modules\i386-skyos", "lib\firmware", "usr\bin", "usr\share\doc\skyos",
        "usr\share\icons\skyos", "usr\share\applications",
        "var\log", "tmp", "mnt", "proc", "sys", "boot"
    )
    foreach ($dir in $rootDirs) {
        New-Item -ItemType Directory -Force -Path (Join-Path $rootfs $dir) | Out-Null
    }

    Write-TextFile (Join-Path $rootfs "etc\os-release") "NAME=SkyOS`nVERSION=$SkyOsVersion`nVERSION_ID=$SkyOsVersion`nBUILD_ID=$SkyOsInternalVersion`nID=skyos`nARCH=i386`n"
    Write-TextFile (Join-Path $rootfs "etc\fstab") "ramfs / ramfs defaults 0 0`ndisk0 /mnt/disk0 raw-ide defaults 0 0`n"
    Write-TextFile (Join-Path $rootfs "etc\passwd") "root:x:0:0:root:/root:/bin/skysh`nuser:x:1000:1000:SkyOS User:/home/user:/bin/skysh`n"
    Write-TextFile (Join-Path $rootfs "etc\shadow") "root:skyos:0:0:99999:7:::`nuser:skyuser:0:0:99999:7:::`n"
    Write-TextFile (Join-Path $rootfs "etc\group") "root:x:0:`nuser:x:1000:`nwheel:x:10:root,user`n"
    Write-TextFile (Join-Path $rootfs "etc\sudoers") "root ALL=(ALL) ALL`n%wheel ALL=(ALL) ALL`nuser ALL=(root) ALL`n"
    Write-TextFile (Join-Path $rootfs "etc\sapp\sources.list") "deb http://skyapps.skyu.cc.cd skyos main`n"
    Write-TextFile (Join-Path $rootfs "boot\loader.conf") "bootloader=skyos-hdstage2`nkernel_lba=16`nroot=/dev/disk0p0`nrootfstype=skyfs`ninit=/sbin/init`n"
    Write-TextFile (Join-Path $rootfs "sbin\init") "#!/bin/soj`necho SkyOS init starting`nexec systemd list`nexec mount`n"
    Write-TextFile (Join-Path $rootfs "bin\skysh") "SkyOS builtin shell entrypoint. The current kernel executes this in-kernel until ELF exec lands.`n"
    foreach ($tool in @("ls","cat","cp","mv","rm","mkdir","chmod","grep","vi","nano","ping","ip","wget","curl","sapp","systemctl")) {
        Write-TextFile (Join-Path $rootfs "usr\bin\$tool") "SkyOS builtin command stub: $tool`n"
    }
    Write-TextFile (Join-Path $rootfs "etc\systemd\system\network.service") "[Unit]`nDescription=SkyOS network hardware manager`n"
    Write-TextFile (Join-Path $rootfs "etc\systemd\system\sapp.service") "[Unit]`nDescription=SkyOS package manager transport`n"
    Write-TextFile (Join-Path $rootfs "lib\modules\i386-skyos\e1000.driver") "driver=e1000`nclass=net`nstatus=builtin-mmio-polling`n"
    Write-TextFile (Join-Path $rootfs "lib\modules\i386-skyos\ide.driver") "driver=ide-pio`nclass=block`nstatus=builtin-sector-rw`n"
    Write-TextFile (Join-Path $rootfs "lib\modules\i386-skyos\sata.driver") "driver=ahci-sata`nclass=block`nstatus=pci-probe-compatible-path`n"
    Write-TextFile (Join-Path $rootfs "lib\modules\i386-skyos\vga.driver") "driver=vga-text`nclass=console`nstatus=builtin`n"
    Write-TextFile (Join-Path $rootfs "lib\firmware\FIRMWARE.MANIFEST") "SkyOS firmware catalogue placeholder. Real redistributable firmware blobs must be added with license metadata.`n"
    Write-TextFile (Join-Path $rootfs "var\log\boot.log") "SkyOS ISO rootfs generated by run.ps1`n"
    Write-TextFile (Join-Path $rootfs "usr\share\doc\skyos\README") "This root filesystem is staged for ISO inspection and future initramfs/rootfs mounting. Boot lands in the shell; run desktop, gui, or startx to enter the framebuffer desktop.`n"
    Write-TextFile (Join-Path $rootfs "usr\share\applications\terminal.desktop") "Name=Terminal`nExec=terminal`nIcon=terminal.png`nType=Application`n"
    Write-TextFile (Join-Path $rootfs "usr\share\applications\files.desktop") "Name=File Manager`nExec=files`nIcon=folder.png`nType=Application`n"
    Write-TextFile (Join-Path $rootfs "usr\share\applications\browser.desktop") "Name=HTML Browser`nExec=browser`nIcon=browser.png`nType=Application`n"
    Write-TextFile (Join-Path $rootfs "usr\share\applications\notepad.desktop") "Name=Notepad`nExec=notepad`nIcon=notepad.png`nType=Application`n"
    Write-SkyIconPng (Join-Path $rootfs "usr\share\icons\skyos\folder.png") "folder"
    Write-SkyIconPng (Join-Path $rootfs "usr\share\icons\skyos\terminal.png") "terminal"
    Write-SkyIconPng (Join-Path $rootfs "usr\share\icons\skyos\browser.png") "browser"
    Write-SkyIconPng (Join-Path $rootfs "usr\share\icons\skyos\notepad.png") "notepad"
    Write-SkyIconPng (Join-Path $rootfs "usr\share\icons\skyos\taskmgr.png") "taskmgr"
    Write-SkyIconPng (Join-Path $rootfs "usr\share\icons\skyos\media.png") "media"

    foreach ($dir in @("bin", "etc", "dev", "proc", "sys")) {
        New-Item -ItemType Directory -Force -Path (Join-Path $initramfs $dir) | Out-Null
    }
    Write-TextFile (Join-Path $initramfs "init") "#!/bin/soj`necho initramfs: mounting rootfs`nexec fsinfo`nexec systemd list`n"
    Write-TextFile (Join-Path $initramfs "etc\initramfs.conf") "root=/dev/disk0p1`nrootfstype=skyfs`nfallback=ramfs`n"
    Write-TextFile (Join-Path $initramfs "bin\skysh") "SkyOS initramfs shell stub`n"

    Copy-Item -Path (Join-Path $rootfs "*") -Destination $IsoRoot -Recurse -Force
    New-Item -ItemType Directory -Force -Path (Join-Path $IsoRoot "rootfs"), (Join-Path $IsoRoot "install"), (Join-Path $IsoRoot "kernel"), (Join-Path $IsoRoot "pool\main"), (Join-Path $IsoRoot "dists\skyos\main\binary-i386"), (Join-Path $IsoRoot "drivers"), (Join-Path $IsoRoot "firmware"), (Join-Path $IsoRoot "EFI\BOOT") | Out-Null
    Write-TarGzArchive $rootfs (Join-Path $IsoRoot "rootfs\rootfs.tar.gz")
    Write-TarGzArchive $initramfs (Join-Path $bootDir "initramfs.img")
    Write-TextFile (Join-Path $IsoRoot "rootfs\MANIFEST") "rootfs.tar.gz: compressed SkyOS root filesystem archive`nlayout: /bin /sbin /etc /usr /lib /var /home /dev /proc /sys`ngui: shell first, run desktop/gui/startx; icons in /usr/share/icons/skyos`n"
    Write-TextFile (Join-Path $IsoRoot "kernel\skyos-kernel.manifest") "kernel=/boot/skyos.elf`ninitramfs=/boot/initramfs.img`narch=i386`n"
    Write-TextFile (Join-Path $IsoRoot "install\install.soj") "echo SkyOS installer`nexec installer`necho Configure: sudo settings display auto; timezone set`necho Install: sudo disk select 0; sudo disk partition 4; sudo disk format 0; sudo install`necho Verify: disk verify; mount`n"
    Write-TextFile (Join-Path $IsoRoot "install\INSTALL.md") "SkyOS installer stage. Boot the ISO into the shell, run installer to review display/timezone/disk state, then use desktop to enter GUI when needed. Install path: settings display auto, timezone set, disk select 0, disk partition 4, disk format 0, install. Device names are /dev/disk0 and /dev/disk0p0..p3. The installer writes MBR stage1, stage2, kernel ELF, and SkyFS v0 root metadata. BIOS El Torito and GRUB Multiboot are generated now; EFI/BOOT is staged for BOOTIA32.EFI when the EFI loader is added. Filesystem probe covers SkyFS, FAT32, exFAT, NTFS, and ext signatures; write support remains SkyFS-focused.`n"
    Write-TextFile (Join-Path $IsoRoot "dists\skyos\Release") "Origin: SkyOS`nSuite: skyos`nCodename: skyos`nArchitectures: i386`nComponents: main`n"
    $packagesIndex = @(
        "Package: base-tools`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nFilename: pool/main/base-tools_1.0.3.0.GSOSYGP_skyos-i386.spk`nSize: 1131`nFormat: spk-binary-v2`nDescription: Base SkyOS shell tools",
        "Package: skycrt`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nFilename: pool/main/skycrt_1.0.3.0.GSOSYGP_skyos-i386.sxr`nSize: 603`nFormat: sxr-binary-v1`nRuntime: sxr`nPackageType: sxr-library`nDescription: SkyOS native runtime SXR",
        "Package: skyui`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nSXR-Depends: skycrt (>= $SkyOsInternalVersion)`nFilename: pool/main/skyui_1.0.3.0.GSOSYGP_skyos-i386.sxr`nSize: 597`nFormat: sxr-binary-v1`nRuntime: sxr`nPackageType: sxr-library`nDescription: SkyOS GUI runtime SXR",
        "Package: calc`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nSXR-Depends: skycrt (>= $SkyOsInternalVersion)`nFilename: pool/main/calc_1.0.3.0.GSOSYGP_skyos-i386.spk`nSize: 1213`nFormat: spk-binary-v2`nRuntime: native-i386`nEntryPoint: /usr/bin/calc`nCommands: calc`nPackageType: cli-app`nPermissions: {read:[/home],write:[/home/user]}`nTuringComplete: yes`nDescription: Calc for SkyOS",
        "Package: skygui-demo`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nDepends: base-tools (>= $SkyOsInternalVersion)`nSXR-Depends: skyui (>= $SkyOsInternalVersion), skycrt (>= $SkyOsInternalVersion)`nFilename: pool/main/skygui-demo_1.0.3.0.GSOSYGP_skyos-i386.spk`nSize: 1439`nFormat: spk-binary-v2`nRuntime: soj`nEntryPoint: /opt/skygui-demo/install.soj`nCommands: skygui-demo`nPackageType: installer`nPermissions: {read:[/home,/usr/share],write:[/home/user,/tmp]}`nTuringComplete: yes`nDescription: GUI installer demo package",
        "Package: editor-vi`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nDepends: base-tools (>= $SkyOsInternalVersion)`nFilename: pool/main/editor-vi_1.0.3.0.GSOSYGP_skyos-i386.spk`nSize: 1168`nFormat: spk-binary-v2`nDescription: SkyOS vi editor package",
        "Package: net-tools`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nDepends: base-tools (>= $SkyOsInternalVersion)`nFilename: pool/main/net-tools_1.0.3.0.GSOSYGP_skyos-i386.spk`nSize: 1170`nFormat: spk-binary-v2`nDescription: Network commands for SkyOS",
        "Package: sapp-utils`nVersion: $SkyOsVersion`nInternalVersion: $SkyOsInternalVersion`nArchitecture: i386`nSystem: $SkyOsSystemId`nCompatibleInternalVersion: $SkyOsInternalVersion`nDepends: base-tools (>= $SkyOsInternalVersion), net-tools (>= $SkyOsInternalVersion)`nFilename: pool/main/sapp-utils_1.0.3.0.GSOSYGP_skyos-i386.spk`nSize: 1206`nFormat: spk-binary-v2`nDescription: Sapp package manager utilities"
    ) -join "`n`n"
    Write-TextFile (Join-Path $IsoRoot "dists\skyos\main\binary-i386\Packages") ($packagesIndex + "`n")
    Write-TextFile (Join-Path $IsoRoot "pool\main\base-tools_1.0.3.0.GSOSYGP_skyos-i386.spk") "SkyOS Sapp package placeholder: base-tools`n"
    Write-TextFile (Join-Path $IsoRoot "pool\main\calc_1.0.3.0.GSOSYGP_skyos-i386.spk") "SkyOS Sapp package placeholder: calc`n"
    Write-TextFile (Join-Path $IsoRoot "pool\main\skycrt_1.0.3.0.GSOSYGP_skyos-i386.sxr") "SkyOS SXR runtime placeholder: skycrt`n"
    Write-TextFile (Join-Path $IsoRoot "pool\main\skyui_1.0.3.0.GSOSYGP_skyos-i386.sxr") "SkyOS SXR runtime placeholder: skyui`n"
    Write-TextFile (Join-Path $IsoRoot "pool\main\skygui-demo_1.0.3.0.GSOSYGP_skyos-i386.spk") "SkyOS SPK v2 GUI installer placeholder: skygui-demo`n"
    Write-TextFile (Join-Path $IsoRoot "pool\main\editor-vi_1.0.3.0.GSOSYGP_skyos-i386.spk") "SkyOS Sapp package placeholder: editor-vi`n"
    Write-TextFile (Join-Path $IsoRoot "pool\main\net-tools_1.0.3.0.GSOSYGP_skyos-i386.spk") "SkyOS Sapp package placeholder: net-tools`n"
    Write-TextFile (Join-Path $IsoRoot "pool\main\sapp-utils_1.0.3.0.GSOSYGP_skyos-i386.spk") "SkyOS Sapp package placeholder: sapp-utils`n"
    $sappRepo = Join-Path $Root "sappserver\repo"
    $sappRepoIndex = Join-Path $sappRepo "dists\skyos\main\binary-i386\Packages"
    $sappRepoPool = Join-Path $sappRepo "pool\main"
    if ((Test-Path -LiteralPath $sappRepoIndex) -and (Test-Path -LiteralPath $sappRepoPool)) {
        Copy-Item -LiteralPath $sappRepoIndex -Destination (Join-Path $IsoRoot "dists\skyos\main\binary-i386\Packages") -Force
        Get-ChildItem -Path (Join-Path $sappRepoPool "*.spk") -ErrorAction SilentlyContinue | Copy-Item -Destination (Join-Path $IsoRoot "pool\main") -Force
        Get-ChildItem -Path (Join-Path $sappRepoPool "*.sxr") -ErrorAction SilentlyContinue | Copy-Item -Destination (Join-Path $IsoRoot "pool\main") -Force
    }
    Write-TextFile (Join-Path $IsoRoot "drivers\DRIVERS.MANIFEST") "builtin: vga ps2 ide-pio sata-ahci-probe pci e1000 pc-speaker framebuffer-shadow-text`nfs-probe: skyfs fat32 exfat ntfs ext`nfuture: ahci-dma nvme rtl8139 virtio-net usb-hid virtio-gpu`n"
    Write-TextFile (Join-Path $IsoRoot "firmware\FIRMWARE.MANIFEST") "No proprietary firmware blobs are bundled. Add blobs here with license and device metadata.`n"
    Write-TextFile (Join-Path $IsoRoot "EFI\BOOT\README.txt") "UEFI directory reserved for BOOTIA32.EFI. Current ISO remains BIOS El Torito plus GRUB Multiboot compatible; EFI loader integration is the next boot-chain step.`n"
}

function Find-Bytes {
    param([byte[]]$Data, [byte[]]$Needle)
    for ($i = 0; $i -le ($Data.Length - $Needle.Length); $i++) {
        $matched = $true
        for ($j = 0; $j -lt $Needle.Length; $j++) {
            if ($Data[$i + $j] -ne $Needle[$j]) {
                $matched = $false
                break
            }
        }
        if ($matched) {
            return $i
        }
    }
    return -1
}

function Patch-CdBoot {
    param([string]$CdBoot)
    $stageIso = Join-Path $Build "skyos-stage.iso"
    Invoke-XorrisoOutput @(
        "-as", "mkisofs",
        "-R", "-J", "-V", "SKYOS",
        "-b", "boot/cdboot.bin",
        "-no-emul-boot",
        "-boot-load-size", "4",
        "-o", $stageIso,
        $IsoRoot
    ) | Out-Null

    $report = Invoke-XorrisoOutput @("-indev", $stageIso, "-find", "/boot/skyos.elf", "-exec", "report_lba", "--")
    if ($report -notmatch 'File data lba:\s*0\s*,\s*([0-9]+)') {
        throw "Could not locate /boot/skyos.elf LBA"
    }
    $kernelLba = [UInt32]$Matches[1]
    $kernelSectors = [UInt16][Math]::Ceiling((Get-Item -LiteralPath $KernelElf).Length / 2048.0)

    $data = [System.IO.File]::ReadAllBytes($CdBoot)
    $marker = [System.Text.Encoding]::ASCII.GetBytes("SKYPATCH")
    $idx = Find-Bytes $data $marker
    if ($idx -lt 0) {
        throw "Patch marker not found in cdboot.bin"
    }
    $patchAt = $idx + $marker.Length
    [Array]::Copy([BitConverter]::GetBytes($kernelLba), 0, $data, $patchAt, 4)
    [Array]::Copy([BitConverter]::GetBytes($kernelSectors), 0, $data, $patchAt + 4, 2)
    [System.IO.File]::WriteAllBytes($CdBoot, $data)
    Remove-Item -LiteralPath $stageIso -Force -ErrorAction SilentlyContinue
    return @($kernelLba, $kernelSectors)
}

function Build-Iso {
    Require-Tool $Nasm "NASM"
    Require-Tool $Xorriso "xorriso"
    Build-Kernel
    Initialize-IsoPayload

    $bootDir = Join-Path $IsoRoot "boot"
    $grubDir = Join-Path $bootDir "grub"
    New-Item -ItemType Directory -Force -Path $grubDir | Out-Null
    Copy-Item -LiteralPath $KernelElf -Destination (Join-Path $bootDir "skyos.elf") -Force
    Copy-Item -LiteralPath (Join-Path $Root "boot\grub\grub.cfg") -Destination (Join-Path $grubDir "grub.cfg") -Force
    Remove-Item -LiteralPath $IsoNew -Force -ErrorAction SilentlyContinue

    if ($env:SKYOS_USE_GRUB_ISO -and (Test-Path -LiteralPath $GrubMkrescue)) {
        Invoke-External $GrubMkrescue @("-o", $IsoNew, $IsoRoot)
        $finalIso = Move-FinalIso
        Write-Host "Built $finalIso with grub-mkrescue"
        return $finalIso
    }

    Write-Host "Using built-in El Torito BIOS installer loader."
    $cdboot = Join-Path $Build "cdboot.bin"
    Remove-Item -LiteralPath (Join-Path $Build "skyos-stage.iso") -Force -ErrorAction SilentlyContinue
    Invoke-External $Nasm @("-f", "bin", "boot/cdboot.asm", "-o", $cdboot)
    Copy-Item -LiteralPath $cdboot -Destination (Join-Path $bootDir "cdboot.bin") -Force
    $patch = Patch-CdBoot $cdboot
    Copy-Item -LiteralPath $cdboot -Destination (Join-Path $bootDir "cdboot.bin") -Force
    Invoke-XorrisoOutput @(
        "-as", "mkisofs",
        "-R", "-J", "-V", "SKYOS",
        "-b", "boot/cdboot.bin",
        "-no-emul-boot",
        "-boot-load-size", "4",
        "-o", $IsoNew,
        $IsoRoot
    ) | Out-Null
    $final = Move-FinalIso
    Write-Host "Built $final with built-in El Torito BIOS loader"
    Write-Host "Kernel LBA: $($patch[0]) sectors: $($patch[1])"
    return $final
}

function Run-Kernel {
    Require-Tool $Qemu "QEMU"
    Build-Kernel
    Build-Img
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @(
        "-m", "2G",
        "-kernel", $KernelElf,
        "-drive", "file=$DiskImg,format=raw,if=ide,index=0,media=disk",
        "-netdev", (Get-UserNetdevArg),
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Run-KernelTap {
    Require-Tool $Qemu "QEMU"
    $tapName = if ($env:SKYOS_TAP) { $env:SKYOS_TAP } else { "SkyOS-TAP" }
    Build-Kernel
    Build-Img
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @(
        "-m", "2G",
        "-kernel", $KernelElf,
        "-drive", "file=$DiskImg,format=raw,if=ide,index=0,media=disk",
        "-netdev", "tap,id=net0,ifname=$tapName,script=no,downscript=no",
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Run-Disk {
    Require-Tool $Qemu "QEMU"
    Build-Img
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @(
        "-m", "2G",
        "-drive", "file=$DiskImg,format=raw,if=ide,index=0,media=disk",
        "-boot", "c",
        "-netdev", (Get-UserNetdevArg),
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Run-DiskSata {
    Require-Tool $Qemu "QEMU"
    Build-Img
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @("-m", "2G")
    $qemuArgs += Get-SataDiskArgs
    $qemuArgs += @(
        "-boot", "c",
        "-netdev", (Get-UserNetdevArg),
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Run-DiskTap {
    Require-Tool $Qemu "QEMU"
    $tapName = if ($env:SKYOS_TAP) { $env:SKYOS_TAP } else { "SkyOS-TAP" }
    Build-Img
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @(
        "-m", "2G",
        "-drive", "file=$DiskImg,format=raw,if=ide,index=0,media=disk",
        "-boot", "c",
        "-netdev", "tap,id=net0,ifname=$tapName,script=no,downscript=no",
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Run-Iso {
    Require-Tool $Qemu "QEMU"
    $finalIso = Build-Iso
    Ensure-DiskImage
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @(
        "-m", "2G",
        "-cdrom", $finalIso,
        "-drive", "file=$DiskImg,format=raw,if=ide,index=0,media=disk",
        "-boot", "d",
        "-netdev", (Get-UserNetdevArg),
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Run-IsoSata {
    Require-Tool $Qemu "QEMU"
    $finalIso = Build-Iso
    Ensure-DiskImage
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @("-m", "2G", "-cdrom", $finalIso)
    $qemuArgs += Get-SataDiskArgs
    $qemuArgs += @(
        "-boot", "d",
        "-netdev", (Get-UserNetdevArg),
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Run-IsoTap {
    Require-Tool $Qemu "QEMU"
    $tapName = if ($env:SKYOS_TAP) { $env:SKYOS_TAP } else { "SkyOS-TAP" }
    $finalIso = Build-Iso
    Ensure-DiskImage
    $qemuArgs = @()
    $qemuArgs += Get-QemuCommonArgs
    $qemuArgs += @(
        "-m", "2G",
        "-cdrom", $finalIso,
        "-drive", "file=$DiskImg,format=raw,if=ide,index=0,media=disk",
        "-boot", "d",
        "-netdev", "tap,id=net0,ifname=$tapName,script=no,downscript=no",
        "-device", (Get-NetDeviceArg),
        "-no-reboot",
        "-no-shutdown"
    )
    $qemuArgs += Get-QemuDisplayArgs
    Invoke-External $Qemu $qemuArgs
}

function Check-Env {
    $items = @(
        @("NASM", $Nasm),
        @("LLD", $Ld),
        @("xorriso", $Xorriso),
        @("QEMU", $Qemu),
        @("qemu-img", $QemuImg)
    )
    foreach ($item in $items) {
        $state = if (Test-Path -LiteralPath $item[1]) { "OK" } else { "MISS" }
        Write-Host "[$state] $($item[0]): $($item[1])"
    }
    if (Test-Path -LiteralPath $GrubMkrescue) {
        Write-Host "[OK] grub-mkrescue: $GrubMkrescue"
    } else {
        Write-Host "[INFO] grub-mkrescue missing; ISO builder uses built-in El Torito loader"
    }
}

function Clean-Build {
    Remove-Item -LiteralPath $Build -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $Dist -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Cleaned build and dist."
}

function Show-Menu {
    while ($true) {
        Write-Host ""
        Write-Host "SkyOS Tool"
        Write-Host "1. Build kernel"
        Write-Host "2. Build disk image"
        Write-Host "3. Build bootable ISO"
        Write-Host "4. Run kernel"
        Write-Host "5. Run ISO"
        Write-Host "6. Run installed disk"
        Write-Host "7. Run installed disk with SATA/AHCI"
        Write-Host "8. Run ISO with SATA/AHCI"
        Write-Host "9. Create blank install disk"
        Write-Host "10. Check environment"
        Write-Host "11. Clean"
        Write-Host "0. Exit"
        $choice = Read-Host "Select"
        switch ($choice.Trim()) {
            "1" { Build-Kernel }
            "2" { Build-Img }
            "3" { Build-Iso | Out-Null }
            "4" { Run-Kernel }
            "5" { Run-Iso }
            "6" { Run-Disk }
            "7" { Run-DiskSata }
            "8" { Run-IsoSata }
            "9" { New-BlankDiskImage }
            "10" { Check-Env }
            "11" { Clean-Build }
            "0" { return }
            default { Write-Host "Unknown option: $choice" }
        }
    }
}

function Invoke-Action {
    param([string]$Name)
    switch ($Name) {
        "" { Show-Menu }
        "build" { Build-Kernel }
        "img" { Build-Img }
        "blank-img" { New-BlankDiskImage }
        "iso" { Build-Iso | Out-Null }
        "run" { Run-Kernel }
        "run-disk" { Run-Disk }
        "run-iso" { Run-Iso }
        "run-sata" { Run-DiskSata }
        "run-iso-sata" { Run-IsoSata }
        "run-tap" { Run-KernelTap }
        "run-disk-tap" { Run-DiskTap }
        "run-iso-tap" { Run-IsoTap }
        "check" { Check-Env }
        "clean" { Clean-Build }
        default { throw "usage: run.ps1 [build|img|blank-img|iso|run|run-disk|run-iso|run-sata|run-iso-sata|run-tap|run-disk-tap|run-iso-tap|check|clean]" }
    }
}

Invoke-Action $Action
