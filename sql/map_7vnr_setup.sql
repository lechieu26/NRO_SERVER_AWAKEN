-- =====================================================
-- SQL Script: Tạo bảng và dữ liệu cho hệ thống map 7VNR
-- Chạy script này trên database game server
-- =====================================================

-- 1. Tạo bảng map_7vnr_template
CREATE TABLE IF NOT EXISTS map_7vnr_template (
  id INT PRIMARY KEY,                       -- mapId (230-255, nằm trong khoảng unsigned byte)
  name VARCHAR(100) NOT NULL,               -- Tên map
  planet_id TINYINT DEFAULT 0,              -- Hành tinh (0 = Trái Đất)
  zones TINYINT DEFAULT 1,                  -- Số zone
  max_player TINYINT DEFAULT 5,             -- Max player/zone
  map_width INT NOT NULL,                   -- Chiều rộng map (pixel)
  map_height INT NOT NULL,                  -- Chiều cao map (pixel)
  
  -- Cấu hình map JSON (ground collision, bg layers, camera bounds)
  map_config TEXT NOT NULL,
  
  -- Waypoints JSON (cùng format với map cũ)
  -- Format: [["tên",minX,minY,maxX,maxY,isEnter,isOffline,goMap,goX,goY], ...]
  waypoints TEXT DEFAULT '[]',
  
  -- Effects JSON
  effects TEXT DEFAULT '[]',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 2. Thêm map test: Rừng Khởi Đầu (dựa trên Map_0 của 7VNR)
-- Ground collision dựa trên EdgeCollider2D (x: -45 đến 45, y=1)
-- Chuyển đổi: 1 Unity unit ≈ 24 pixel → width = 90*24 = 2160px
INSERT INTO map_7vnr_template (id, name, planet_id, zones, max_player, map_width, map_height, map_config, waypoints)
VALUES (
  230,
  'Rừng Khởi Đầu',
  0,
  2,
  5,
  2160,
  720,
  '{
    "width": 2160,
    "height": 720,
    "bgLayers": ["bg_230_sky.png", "bg_230_mountain.png", "bg_230_ground.png"],
    "groundPoints": [
      {"x": 0, "y": 408},
      {"x": 200, "y": 408},
      {"x": 400, "y": 384},
      {"x": 600, "y": 384},
      {"x": 800, "y": 408},
      {"x": 1000, "y": 408},
      {"x": 1200, "y": 384},
      {"x": 1400, "y": 360},
      {"x": 1600, "y": 360},
      {"x": 1800, "y": 384},
      {"x": 2000, "y": 408},
      {"x": 2160, "y": 408}
    ],
    "platforms": [
      {"x1": 500, "y1": 288, "x2": 700, "y2": 288},
      {"x1": 1100, "y1": 264, "x2": 1300, "y2": 264}
    ],
    "cameraBounds": {
      "top": 0,
      "bottom": 720,
      "left": 0,
      "right": 2160
    }
  }',
  '[["Về Làng Kame",0,0,48,720,1,0,7,700,200],["Rừng Sâu",2112,0,2160,720,1,0,231,100,384]]'
);


-- 3. Thêm map test: Rừng Sâu (dựa trên Map_1 của 7VNR)
INSERT INTO map_7vnr_template (id, name, planet_id, zones, max_player, map_width, map_height, map_config, waypoints)
VALUES (
  231,
  'Rừng Sâu',
  0,
  2,
  5,
  2400,
  840,
  '{
    "width": 2400,
    "height": 840,
    "bgLayers": ["bg_231_sky.png", "bg_231_trees.png", "bg_231_ground.png"],
    "groundPoints": [
      {"x": 0, "y": 504},
      {"x": 300, "y": 504},
      {"x": 500, "y": 480},
      {"x": 700, "y": 456},
      {"x": 900, "y": 456},
      {"x": 1100, "y": 480},
      {"x": 1300, "y": 504},
      {"x": 1500, "y": 504},
      {"x": 1700, "y": 480},
      {"x": 1900, "y": 456},
      {"x": 2100, "y": 480},
      {"x": 2400, "y": 504}
    ],
    "platforms": [
      {"x1": 400, "y1": 360, "x2": 600, "y2": 360},
      {"x1": 800, "y1": 312, "x2": 1000, "y2": 312},
      {"x1": 1400, "y1": 360, "x2": 1600, "y2": 360}
    ],
    "cameraBounds": {
      "top": 0,
      "bottom": 840,
      "left": 0,
      "right": 2400
    }
  }',
  '[["Rừng Khởi Đầu",0,0,48,840,1,0,230,2060,408],["Thung Lũng",2352,0,2400,840,1,0,232,100,480]]'
);


-- 4. Thêm map test: Thung Lũng (dựa trên Map_6 của 7VNR)
INSERT INTO map_7vnr_template (id, name, planet_id, zones, max_player, map_width, map_height, map_config, waypoints)
VALUES (
  232,
  'Thung Lũng',
  0,
  2,
  5,
  1920,
  600,
  '{
    "width": 1920,
    "height": 600,
    "bgLayers": ["bg_232_sky.png", "bg_232_hills.png", "bg_232_ground.png"],
    "groundPoints": [
      {"x": 0, "y": 360},
      {"x": 240, "y": 360},
      {"x": 480, "y": 336},
      {"x": 720, "y": 312},
      {"x": 960, "y": 312},
      {"x": 1200, "y": 336},
      {"x": 1440, "y": 360},
      {"x": 1680, "y": 360},
      {"x": 1920, "y": 360}
    ],
    "platforms": [
      {"x1": 600, "y1": 240, "x2": 800, "y2": 240}
    ],
    "cameraBounds": {
      "top": 0,
      "bottom": 600,
      "left": 0,
      "right": 1920
    }
  }',
  '[["Rừng Sâu",0,0,48,600,1,0,231,2300,504]]'
);


-- 5. (Tùy chọn) Thêm waypoint từ map cũ sang map mới
-- Ví dụ: Từ Làng Kame (map 7) thêm waypoint đến Rừng Khởi Đầu (map 230)
-- LƯU Ý: Cần cập nhật waypoints JSON của map 7 trong bảng map_template.
-- Chạy câu lệnh dưới sau khi kiểm tra format waypoints hiện tại của map 7:
--
-- UPDATE map_template
-- SET waypoints = JSON_ARRAY_APPEND(
--   CAST(waypoints AS JSON), '$',
--   '["Rừng Mới",680,0,720,300,1,0,230,100,408]'
-- )
-- WHERE id = 7;
--
-- Hoặc nếu waypoints không phải JSON type, dùng string concatenation:
-- (Kiểm tra và điều chỉnh theo format thực tế)

SELECT '=== Map 7VNR Setup Complete ===' AS status;
SELECT id, name, map_width, map_height FROM map_7vnr_template;
