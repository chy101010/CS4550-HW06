#!/bin/bash

# Export Elixir in Production MODE
export MIX_ENV=prod
export PORT=4900
export SECRET_KEY_BASE=insecure

mix deps.get --only prod
mix compile

CFGD=$(readlink -f ~/.config/bulls)

if [ ! -d "$CFGD" ]; then
	mkdir -p $CFGD
	echo "Hello One"
fi

echo "Hello Two"

if [ ! -e "$CFGD/base" ]; then
	mix phx.gen.secret > "$CFGD/base"
	echo "Hello Three"
fi

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest

mix release

