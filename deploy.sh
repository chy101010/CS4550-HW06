#!/bin/bash

# Export Elixir in Production MODE
export MIX_ENV=prod
export PORT=4801
export SECRET_KEY_BASE=insecure

mix deps.get --only prod
mix compile

CFGB=$(readlink -f ~/.config/bulls)

# Create CFGD if doesn't exist
if [ ! -d "$CFGD" ]; then
    mkdir -p "$CFGD"
fi

# Generate secret key if doesn't exist
if [ ! -e "$CFGD/base" ]; then
    mix phx.gen.secret > "CFGD/base"
fi

# Load Secret Base
SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest

mix release