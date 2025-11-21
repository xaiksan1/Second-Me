#!/bin/bash

set -euo pipefail

PORT=3003
APP_DIR="/home/ichigo/Second-Me/portfolio-app"

if [ ! -d "${APP_DIR}" ]; then
	echo "❌ Répertoire du portfolio introuvable: ${APP_DIR}"
	exit 1
fi

cd "${APP_DIR}"

if ! command -v pnpm >/dev/null 2>&1; then
	echo "❌ pnpm est introuvable dans le PATH. Installe-le avant de lancer le serveur."
	exit 1
fi

echo "🚀 Démarrage du serveur Next.js sur le port ${PORT}..."
echo ""
echo "📍 Pages disponibles:"
echo "   - Portfolio: http://localhost:${PORT}/portfolio"
echo "   - Alexandria Dock: http://localhost:${PORT}/alexandria-dock"
echo "   - Intégrations: http://localhost:${PORT}/integrations"
echo "   - Blog: http://localhost:${PORT}/blog"
echo "   - Contact: http://localhost:${PORT}/contact"
echo "   - À propos: http://localhost:${PORT}/about"
echo "   - Mentions Légales: http://localhost:${PORT}/legal"
echo "   - Politique de Confidentialité: http://localhost:${PORT}/privacy-policy"
echo ""

PORT="${PORT}" pnpm dev -- --port "${PORT}"
