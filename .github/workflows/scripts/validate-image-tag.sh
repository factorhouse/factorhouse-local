#!/bin/bash
set -e

IMAGE_TAG="$1"

if [[ "$IMAGE_TAG" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "✅ Valid tag: $IMAGE_TAG"
else
  echo "❌ Invalid tag format: $IMAGE_TAG. Expected format: X.Y.Z"
  exit 1
fi