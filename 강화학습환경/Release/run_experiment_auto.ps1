# -*- coding: utf-8 -*-
# run_experiment_auto.ps1

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   AIPilot RL Team - Automation Pipeline  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. 실험 목적/버전 입력받기
$TacticalPurpose = Read-Host "Enter experiment purpose/tag (e.g., pursuit-v1)"

if ([string]::IsNullOrEmpty($TacticalPurpose)) {
    Write-Host "[Error] Tag is empty. Process terminated." -ForegroundColor Red
    Exit
}

# 2. 공식 규칙에 맞춘 최종 자동 태그명 생성
$Algorithm = "sac"
$Network = "mlp"
$OutputTag = "$Algorithm-$Network-$TacticalPurpose"

Write-Host "`n[Target Tag] -> $OutputTag" -ForegroundColor Green

# 3. Git Commit용 작업 요약 입력받기
$CommitSummary = Read-Host "Enter Git commit message (What did you change?)"

# 4. Git 커밋 자동 가동
Write-Host "`n[Step 1] Git staging and auto-committing..." -ForegroundColor Yellow
git add student/my_reward.py

$FullCommitMessage = "feat(rl): [$OutputTag] $CommitSummary"
git commit -m $FullCommitMessage

if ($LASTEXITCODE -ne 0) {
    Write-Host "[Warning] Git commit failed or no changes. Proceeding to train..." -ForegroundColor Magenta
} else {
    Write-Host "[Success] Git commit complete!" -ForegroundColor Green
}

# 5. 로컬 실험 대장(Backlog)에 자동 누적 기록
$LogFile = "experiment_backlog.txt"
$CurrentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$LogLine = "[$CurrentTime] TAG: $OutputTag | COMMIT_MSG: $CommitSummary"

Add-Content -Path $LogFile -Value $LogLine
Write-Host "[Success] Logged to experiment_backlog.txt!" -ForegroundColor Green

# 6. 시뮬레이터 학습 자동 실행
Write-Host "`n[Step 2] Launching Fighter Simulator..." -ForegroundColor Cyan
Write-Host "Command: python train_curriculum.py --algorithm $Algorithm --reward-module student.my_reward --observation-mode tactical16 --output-name team_rl --output-tag $OutputTag`n" -ForegroundColor DarkGray

python train_curriculum.py `
    --algorithm $Algorithm `
    --reward-module student.my_reward `
    --observation-mode tactical16 `
    --output-name team_rl `
    --output-tag $OutputTag

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   Training Session Finished." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan