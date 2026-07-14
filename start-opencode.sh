#!/bin/bash
cd "$(dirname "$0")"

if [ -f .env ]; then
    source .env
fi

while true; do
  clear
  
  # --- ROTATE GEMINI KEYS ---
  [ ! -f .gemini_idx ] && echo 0 > .gemini_idx
  G_IDX=$(cat .gemini_idx)
  var_g="GEMINI_$G_IDX"
  CURRENT_G_KEY="${!var_g}"
  echo $(( (G_IDX + 1) % 5 )) > .gemini_idx

  # --- ROTATE OPENROUTER KEYS ---
  [ ! -f .or_idx ] && echo 0 > .or_idx
  OR_IDX=$(cat .or_idx)
  var_or="OR_$OR_IDX"
  CURRENT_OR_KEY="${!var_or}"
  echo $(( (OR_IDX + 1) % 6 )) > .or_idx

  # Inject all authentication tokens
  export GOOGLE_GENERATIVE_AI_API_KEY="$CURRENT_G_KEY"
  export GEMINI_API_KEY="$CURRENT_G_KEY"
  export GOOGLE_API_KEY="$CURRENT_G_KEY"
  export OPENROUTER_API_KEY="$CURRENT_OR_KEY"
  export OPENAI_API_KEY="$CURRENT_OR_KEY"

  echo "----------------------------------------"
  echo " Workspace: ~/aaa | Main Engine Active"
  echo " Running on Google Cloud Shell Quota"
  echo " Backup Target: GitHub Repository"
  echo "----------------------------------------"
  
  # Launch OpenCode using the exact recognized native Gemini format
  opencode --model gemini/gemini-1.5-flash --auto

  if [ $? -ne 0 ]; then
      echo "⚠️ Gemini connection hit a limit. Shifting to OpenRouter..."
      sleep 2
      opencode --model openrouter/openrouter/free --auto
  fi

  # Automatically back up code changes to GitHub for Codespace fallback
  echo "💾 Backing up changes to GitHub repository..."
  git add .
  git commit -m "Automated progress backup sync"
  git push origin main 2>/dev/null
  
  echo "🔄 Press [ENTER] to cycle keys, or Ctrl+C to exit."
  read tmp
done
