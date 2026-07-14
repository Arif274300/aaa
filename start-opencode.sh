#!/bin/bash
cd "$(dirname "$0")"

# 1. Download tracking updates from your backup
echo "Syncing latest codebase from GitHub backup..."
git pull origin main 2>/dev/null

# Load environment configuration variables securely
if [ -f .env ]; then
    source .env
fi

while true; do
  clear
  
  # --- POOL 1: ROTATE GEMINI KEYS ---
  [ ! -f .gemini_idx ] && echo 0 > .gemini_idx
  G_IDX=$(cat .gemini_idx)
  var_g="GEMINI_$G_IDX"
  CURRENT_G_KEY="${!var_g}"
  echo $(( (G_IDX + 1) % 5 )) > .gemini_idx

  # --- POOL 2: ROTATE OPENROUTER KEYS ---
  [ ! -f .or_idx ] && echo 0 > .or_idx
  OR_IDX=$(cat .or_idx)
  var_or="OR_$OR_IDX"
  CURRENT_OR_KEY="${!var_or}"
  echo $(( (OR_IDX + 1) % 6 )) > .or_idx

  export GOOGLE_GENERATIVE_AI_API_KEY="$CURRENT_G_KEY"
  export GEMINI_API_KEY="$CURRENT_G_KEY"
  export GOOGLE_API_KEY="$CURRENT_G_KEY"
  export OPENROUTER_API_KEY="$CURRENT_OR_KEY"
  export OPENAI_API_KEY="$CURRENT_OR_KEY"

  echo "--------------------------------------------------------"
  echo " Workspace: ~/aaa | Production: Cloud Shell"
  echo " Current Gemini Key: #$G_IDX | OpenRouter Key: #$OR_IDX"
  echo "--------------------------------------------------------"
  
  # Launch OpenCode in manual model mode for stability
  opencode --auto

  # Codespace Backup Sync Action
  echo "💾 Syncing changes to GitHub repository..."
  git add .
  git commit -m "Codebase dynamic update sync"
  git push origin main 2>/dev/null
  
  echo "🔄 Options:"
  echo "  [ENTER] : Rotate keys and restart OpenCode"
  echo "  c       : Deploy a new GitHub Codespace backup instance"
  echo "  Ctrl+C  : Exit to terminal"
  read -p "Selection: " choice

  if [ "$choice" = "c" ] || [ "$choice" = "C" ]; then
      echo "🚀 Instructing GitHub to provision a new Codespace backup container..."
      gh codespace create -r Arif274300/aaa -b main --default
      echo "✅ Codespace successfully built on GitHub."
      sleep 3
  fi
done
