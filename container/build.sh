#!/bin/bash
# Build the NanoClaw agent-runner (compile TypeScript on host)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/agent-runner"

echo "Compiling agent-runner TypeScript..."
npm run build

echo ""
echo "Build complete!"
echo "Output: $SCRIPT_DIR/agent-runner/dist/"
echo ""
echo "Test with:"
echo "  echo '{\"prompt\":\"What is 2+2?\",\"groupFolder\":\"test\",\"chatJid\":\"test@g.us\",\"isMain\":false}' | guix shell -C --pure --network --no-cwd --manifest=$SCRIPT_DIR/manifest.scm --share=/tmp/test-group=/workspace/group -- node /app/dist/index.js"
