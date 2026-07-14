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

  # Global Key Injection Mappings
  export GOOGLE_GENERATIVE_AI_API_KEY="$CURRENT_G_KEY"
  export GEMINI_API_KEY="$CURRENT_G_KEY"
  export GOOGLE_API_KEY="$CURRENT_G_KEY"
  export OPENROUTER_API_KEY="$CURRENT_OR_KEY"
  export OPENAI_API_KEY="$CURRENT_OR_KEY"

  # Force the application system variables to target Google first
  export PROVIDER="google"
  export AI_PROVIDER="google"

  echo "----------------------------------------"
  echo " Workspace Path: ~/aaa | Main Engine Active"
  echo " Forcing Provider: Google Gemini"
  echo "----------------------------------------"
  
  # Launch OpenCode with the exact list name string matching your screen
  opencode --model "Gemini 3 Flash Preview" --auto

  # If Google fails, clear the provider force and run OpenRouter fallback
  if [ $? -ne 0 ]; then
      echo "⚠️ Gemini limit hit. Launching OpenRouter backup..."
      unset PROVIDER
      unset AI_PROVIDER
      sleep 2
      opencode --model openrouter/openrouter/free --auto
  fi

  # Automated background backup to GitHub
  echo "💾 Syncing changes to GitHub repository..."
  git add .
  git commit -m "Auto-save sync update"
  git push origin main 2>/dev/null
  
  echo "🔄 Press [ENTER] to rotate keys, or Ctrl+C to exit."
  read tmp
done
