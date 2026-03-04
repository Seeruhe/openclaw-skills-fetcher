# OpenClaw Configuration Guide

This is the default configuration template for OpenClaw.

## Quick Setup

1. Copy this file to `~/.openclaw/openclaw.json`
2. Add your API keys
3. Restart OpenClaw: `openclaw gateway restart`

## Configuration Options

### Gateway

```json
"gateway": {
  "port": 5203,
  "host": "127.0.0.1",
  "authToken": "your-secure-token"
}
```

### Telegram Bot

```json
"channels": {
  "telegram": {
    "enabled": true,
    "token": "your-bot-token",
    "streaming": "partial"
  }
}
```

### AI Models

```json
"models": {
  "default": "openai/gpt-4o-mini",
  "providers": {
    "openai": { "apiKey": "sk-..." },
    "anthropic": { "apiKey": "sk-ant-..." },
    "deepseek": { "apiKey": "..." }
  }
}
```

## Need Help?

Visit https://world.je for support.
