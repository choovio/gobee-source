function OUT($s){ Write-Host $s -ForegroundColor DarkYellow }
$H='==== RESULTS BEGIN (COPY/PASTE) ===='
$F='==== RESULTS END (COPY/PASTE) ===='
OUT $H
# Placeholder for purging stale images from ECR following gobee retention rules.
# Add image selection and deletion steps before running in production.
OUT $F
