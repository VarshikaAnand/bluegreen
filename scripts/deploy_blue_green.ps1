Write-Host "Starting Blue-Green deployment..."

$activeContainer = docker ps --format "{{.Names}}" | findstr /R "blue green"

if ($activeContainer -match "blue") {
    $newEnv = "green"
    $oldEnv = "blue"
} else {
    $newEnv = "blue"
    $oldEnv = "green"
}

Write-Host "New environment: $newEnv"
Write-Host "Old environment: $oldEnv"

Write-Host "Starting new container..."
docker-compose up -d --no-deps --build $newEnv

Start-Sleep -Seconds 5

Write-Host "Updating NGINX configuration..."
$nginxConf = Get-Content ./nginx/upstream_app.conf -Raw
if ($newEnv -eq "blue") {
    $nginxConf = $nginxConf -replace "green:3000", "blue:3000"
} else {
    $nginxConf = $nginxConf -replace "blue:3000", "green:3000"
}
$nginxConf | Set-Content ./nginx/upstream_app.conf

docker exec nginx-proxy nginx -s reload

Write-Host "Checking health of $newEnv..."
$health = curl http://localhost/health -UseBasicParsing | Out-String
if ($health -match "UP") {
    Write-Host "$newEnv is healthy!"
    Write-Host "Stopping old container: $oldEnv"
    docker stop $oldEnv | Out-Null
    docker rm $oldEnv | Out-Null
    Write-Host "Deployment complete! $newEnv is now active."
} else {
    Write-Host "Health check failed! Rolling back..."
    $nginxConf = Get-Content ./nginx/upstream_app.conf -Raw
    if ($newEnv -eq "blue") {
        $nginxConf = $nginxConf -replace "blue:3000", "green:3000"
    } else {
        $nginxConf = $nginxConf -replace "green:3000", "blue:3000"
    }
    $nginxConf | Set-Content ./nginx/upstream_app.conf
    docker exec nginx-proxy nginx -s reload
    docker stop $newEnv | Out-Null
}
