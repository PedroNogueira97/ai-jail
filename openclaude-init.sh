#!/bin/bash

# configura provider
echo "/provider gemini" | openclaude

# configura modelo
echo "/model gemini-1.5-pro" | openclaude

# entra no CLI interativo
exec openclaude