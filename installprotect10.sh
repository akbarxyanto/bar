#!/bin/bash

echo "🚀 Memasang proteksi Anti Intip pada Application API (Hanya Admin ID 1)..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Application/ApiController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

# Backup file lama
if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama: $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

# Tulis ulang file dengan proteksi ID 1
cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Application;

use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;

class ApiController extends Controller
{
    /**
     * Halaman utama Application API
     */
    public function index()
    {
        // 🔒 Anti Intip – Hanya Admin ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'AkbarDev Protect - Akses ditolak');
        }

        return view('admin.api.index');
    }

    /**
     * Halaman pembuatan API key baru
     */
    public function store()
    {
        // 🔒 Anti Intip – Hanya Admin ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'AkbarDev Protect - Akses ditolak');
        }

        // Eksekusi bawaan panel
        return app(\Pterodactyl\Http\Controllers\Admin\Application\Api\StoreApplicationApiKeyController::class)
            ->__invoke();
    }

    /**
     * Hapus API key
     */
    public function delete($keyId)
    {
        // 🔒 Anti Intip – Hanya Admin ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'AkbarDev Protect - Akses ditolak');
        }

        // Eksekusi bawaan panel
        return app(\Pterodactyl\Http\Controllers\Admin\Application\Api\DeleteApplicationApiKeyController::class)
            ->__invoke($keyId);
    }
}
EOF

chmod 644 "$REMOTE_PATH"

echo "🎯 Proteksi Application API berhasil dipasang!"
echo "📂 File: $REMOTE_PATH"
echo "🗂 Backup: $BACKUP_PATH"
echo "🔒 Hanya Admin ID 1 yang bisa mengakses & membuat/menghapus API keys."