$repoPath = "F:\Code\GitHub\CC-ASM";
$codePath = "$repoPath\ccasm";
$ccemuDirPath = "C:\Users\Trystan\AppData\Roaming\ccemux\computer\0";

function Delete-DirectoryIfExists($dirPath) {
    if (Test-Path -Path $dirPath) {
        Remove-Item $dirPath -Recurse -Force;
    }
}

function Copy-DirectoryToPath($fromPath, $toPath) {
    if (!(Test-Path -Path $fromPath)) {
        Write-Error "$fromPath does not exist.";
        return;
    }

    $fromDirName = Split-Path $fromPath -Leaf;
    $toDirPath = "$toPath\$fromDirName";

    Delete-DirectoryIfExists $toDirPath;
    Copy-Item $fromPath $toPath -Recurse;
}

Copy-DirectoryToPath $codePath $ccemuDirPath;
