# Check if a directory argument is provided
if (-not $args[0] -or -not $args[1]) {
    Write-Host "Usage: .\Build.ps1 <directory> <filename>"
    exit 1
}

# Assign the arguments to variables
$Dir = $args[0]
$CFile = $args[1]

# Check if the directory exists
if (-not (Test-Path -Path $Dir -PathType Container)) {
    Write-Host "Directory $Dir does not exist."
    exit 1
}

# Navigate to the specified directory
Set-Location -Path $Dir

# Assemble all .asm files in the directory
Get-ChildItem -Filter "*.asm" | ForEach-Object {
    $AsmFile = $_.Name
    $ObjFile = "$($AsmFile -replace '\.asm$', '.obj')"
    Write-Host "Assembling $AsmFile to $ObjFile"
    nasm -f elf32 -g $AsmFile -o $ObjFile
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error assembling $AsmFile"
        exit 1
    }
}

# Compile the C program
if (Test-Path -Path $CFile) {
    Write-Host "Compiling $CFile"
    gcc -c -m32 -g $CFile -o main.o
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error compiling $CFile"
        exit 1
    }
}
else {
    Write-Host "C file $CFile not found."
    exit 1
}

# Link the object files to create the executable
Write-Host "Linking object files"
$ObjFiles = (Get-ChildItem -Filter "*.obj" | ForEach-Object { $_.Name })
Write-Host "Object files: $ObjFiles"
gcc -m32 -g $ObjFiles main.o -o main.exe
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error linking object files"
    exit 1
}

Write-Host "Build successful."
exit 0
