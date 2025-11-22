#!/bin/bash

echo "🚀 Memasang proteksi API untuk Admin ID 1 only..."

# Patch 1 – Application API
REMOTE1="/var/www/pterodactyl/app/Http/Controllers/Admin/Application/ApiController.php"
BACKUP1="${REMOTE1}.bak_$(date -u +%Y-%m-%d-%H-%M-%S)"

if [ -f "$REMOTE1" ]; then
  mv "$REMOTE1" "$BACKUP1"
  echo "📦 Backup Application API => $BACKUP1"
fi

cat > "$REMOTE1" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Application;

use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;

class ApiController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Akses ditolak: hanya admin utama (ID 1) yang dapat mengakses Application API.');
        }

        return view('admin.api.index');
    }
}
EOF
chmod 644 "$REMOTE1"


# Patch 2 – API Credentials
REMOTE2="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Account/ApiClientController.php"
BACKUP2="${REMOTE2}.bak_$(date -u +%Y-%m-%d-%H-%M-%S)"

if [ -f "$REMOTE2" ]; then
  mv "$REMOTE2" "$BACKUP2"
  echo "📦 Backup API Credentials => $BACKUP2"
fi

cat > "$REMOTE2" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Account;

use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Illuminate\Http\Request;

class ApiClientController extends ClientApiController
{
    public function index(Request $request)
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Akses ditolak: hanya admin utama (ID 1) yang bisa membuka API Credentials.');
        }

        return parent::index($request);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Akses ditolak: hanya admin utama (ID 1) yang bisa membuat API Credentials.');
        }

        return parent::store($request);
    }

    public function delete(Request $request)
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Akses ditolak: hanya admin utama (ID 1) yang bisa menghapus API Credentials.');
        }

        return parent::delete($request);
    }
}
EOF
chmod 644 "$REMOTE2"

echo "🎯 PATCH SELESAI!"
echo "🔐 Hanya Admin ID 1 yang bisa buka Application API"
echo "🔐 Hanya Admin ID 1 yang bisa buka/membuat/menghapus API Credentials"