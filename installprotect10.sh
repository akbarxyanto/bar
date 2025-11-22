#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileUploadController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang Proteksi Anti Upload File Besar..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Pterodactyl\Models\Server;
use Pterodactyl\Repositories\Wings\DaemonFileRepository;
use Pterodactyl\Http\Requests\Api\Client\Servers\ServerUploadRequest;
use Illuminate\Support\Facades\Auth;

class FileUploadController
{
    public function __construct(private DaemonFileRepository $fileRepository)
    {
    }

    public function __invoke(ServerUploadRequest $request, Server $server)
    {
        $user = Auth::user();

        // Ambil ukuran file
        $fileSize = $request->file('file')->getSize();
        $limit = 15 * 1024 * 1024; // 15MB

        // Batasi upload > 15MB // hanya untuk user selain ID 1
        if ($user->id !== 1 && $fileSize > $limit) {
            abort(403, 'Upload ditolak: ukuran file maksimal 15MB.');
        }

        // ID 1 Bebas upload ukuran berapapun
        return $this->fileRepository
            ->setServer($server)
            ->setRequest($request)
            ->upload($request->all());
    }
}
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Anti Upload File Besar berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "📌 Pembatasan upload: maksimal 15MB untuk user biasa"
echo "👑 Admin (ID 1) bebas upload tanpa batas"