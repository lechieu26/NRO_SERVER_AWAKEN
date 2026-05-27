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
  
  -- Cấu hình map JSON (ground collision, bg layers, camera bounds, decorations)
  map_config TEXT NOT NULL,
  
  -- Waypoints JSON (cùng format với map cũ)
  -- Format: [["tên",minX,minY,maxX,maxY,isEnter,isOffline,goMap,goX,goY], ...]
  waypoints TEXT DEFAULT '[]',
  
  -- Effects JSON
  effects TEXT DEFAULT '[]',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Thêm map: Rừng Khởi Đầu (Map_0)
INSERT INTO map_7vnr_template (id, name, planet_id, zones, max_player, map_width, map_height, map_config, waypoints)
VALUES (
  230,
  'Rừng Khởi Đầu',
  0,
  2,
  5,
  7726,
  3026,
  '{"width": 7726, "height": 3026, "bgLayers": ["bg_230_sky.png", "bg_230_mountain.png", "bg_230_ground.png"], "groundPoints": [{"x": 0, "y": 2200}, {"x": 772, "y": 2200}, {"x": 1544, "y": 2200}, {"x": 2316, "y": 2200}, {"x": 3088, "y": 2200}, {"x": 3860, "y": 2200}, {"x": 4632, "y": 2200}, {"x": 5404, "y": 2200}, {"x": 6176, "y": 2200}, {"x": 6948, "y": 2200}, {"x": 7720, "y": 2200}, {"x": 7726, "y": 2200}], "decorations": [{"image": "spr_230_trang_tri_2.png", "x": 7186, "y": 2182, "width": 400, "height": 72, "order": -1, "flipX": false, "flipY": false, "layer": "Layer_4"}, {"image": "spr_230_cuc_da_nho.png", "x": 3024, "y": 2247, "width": 140, "height": 388, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_230_cay_cau_1.png", "x": 5630, "y": 2211, "width": 448, "height": 52, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_230_trang_tri_1.png", "x": 3530, "y": 2305, "width": 688, "height": 72, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_4"}, {"image": "spr_230_trang_tri.png", "x": 892, "y": 2247, "width": 516, "height": 44, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_4"}, {"image": "spr_230_1.png", "x": 3112, "y": 2400, "width": 480, "height": 1080, "order": 5, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_230_layer_1.png", "x": 6970, "y": 3070, "width": 792, "height": 788, "order": 5, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_230_layer_2.png", "x": 3640, "y": 3070, "width": 1520, "height": 1268, "order": 5, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_230_day_cau.png", "x": 5661, "y": 2126, "width": 552, "height": 40, "order": 6, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_230_day_cau.png", "x": 5658, "y": 2204, "width": 552, "height": 40, "order": 6, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_230_layer_3.png", "x": 1057, "y": 3070, "width": 1064, "height": 1036, "order": 6, "flipX": false, "flipY": false, "layer": "Layer_Ground"}], "cameraBounds": {"top": 0, "bottom": 3026, "left": 0, "right": 7726}, "platforms": []}',
  '[["V\u1ec1 L\u00e0ng Kame", 0, 0, 48, 3026, 1, 0, 7, 700, 200], ["R\u1eebng S\u00e2u", 7678, 0, 7726, 3026, 1, 0, 231, 100, 2200]]'
);


-- Thêm map: Rừng Sâu (Map_1)
INSERT INTO map_7vnr_template (id, name, planet_id, zones, max_player, map_width, map_height, map_config, waypoints)
VALUES (
  231,
  'Rừng Sâu',
  0,
  2,
  5,
  7725,
  3724,
  '{"width": 7725, "height": 3724, "bgLayers": ["bg_231_sky.png", "bg_231_trees.png", "bg_231_ground.png"], "groundPoints": [{"x": -167, "y": 2903}, {"x": 781, "y": 2916}, {"x": 1779, "y": 3204}, {"x": 3973, "y": 3204}, {"x": 4315, "y": 3233}, {"x": 4600, "y": 3241}, {"x": 4894, "y": 3242}, {"x": 5137, "y": 3209}, {"x": 6667, "y": 2684}, {"x": 6683, "y": 3216}, {"x": 7935, "y": 2674}], "decorations": [{"image": "spr_231_1.png", "x": 9100, "y": 3661, "width": 76, "height": 124, "order": 0, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_1.png", "x": 6303, "y": 3661, "width": 76, "height": 124, "order": 0, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_dai_hoi_vt_.png", "x": 9098, "y": 3629, "width": 112, "height": 32, "order": 1, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_cuc_da_nho.png", "x": 9015, "y": 3264, "width": 140, "height": 388, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_ssau.png", "x": 4305, "y": 2911, "width": 580, "height": 824, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_cuc_da_nho.png", "x": 6218, "y": 3264, "width": 140, "height": 388, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_cuc_da_nho.png", "x": 3284, "y": 2913, "width": 140, "height": 388, "order": 4, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_1.png", "x": 3379, "y": 3065, "width": 480, "height": 1080, "order": 5, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_1.png", "x": 9110, "y": 3415, "width": 480, "height": 1080, "order": 5, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_1.png", "x": 6313, "y": 3415, "width": 480, "height": 1080, "order": 5, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4524, "y": 2005, "width": 212, "height": 556, "order": 8, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4756, "y": 2005, "width": 212, "height": 556, "order": 8, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4282, "y": 2005, "width": 212, "height": 556, "order": 8, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4992, "y": 2005, "width": 212, "height": 556, "order": 8, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4524, "y": 2895, "width": 212, "height": 556, "order": 9, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_1.png", "x": -1382, "y": 4075, "width": 1368, "height": 1520, "order": 9, "flipX": true, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4992, "y": 2895, "width": 212, "height": 556, "order": 9, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4756, "y": 2895, "width": 212, "height": 556, "order": 9, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_1.png", "x": 1346, "y": 4075, "width": 1368, "height": 1520, "order": 9, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_16.png", "x": 4282, "y": 2895, "width": 212, "height": 556, "order": 9, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_2__2_.png", "x": 1819, "y": 3240, "width": 76, "height": 121, "order": 11, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_3.png", "x": 9144, "y": 4075, "width": 1412, "height": 1272, "order": 19, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_3.png", "x": 6347, "y": 4075, "width": 1412, "height": 1272, "order": 20, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_231_layer_2.png", "x": 3828, "y": 4075, "width": 1116, "height": 1736, "order": 20, "flipX": false, "flipY": false, "layer": "Layer_Ground"}], "cameraBounds": {"top": 0, "bottom": 3724, "left": 0, "right": 7725}, "platforms": []}',
  '[["R\u1eebng Kh\u1edfi \u0110\u1ea7u", 0, 0, 48, 3724, 1, 0, 230, 7625, 3066], ["Thung L\u0169ng", 7677, 0, 7725, 3724, 1, 0, 232, 100, 1670]]'
);


-- Thêm map: Thung Lũng (Map_6)
INSERT INTO map_7vnr_template (id, name, planet_id, zones, max_player, map_width, map_height, map_config, waypoints)
VALUES (
  232,
  'Thung Lũng',
  0,
  2,
  5,
  9000,
  3000,
  '{"width": 9000, "height": 3000, "bgLayers": ["bg_232_sky.png", "bg_232_hills.png", "bg_232_ground.png"], "groundPoints": [{"x": 0, "y": 1670}, {"x": 2500, "y": 1670}, {"x": 3500, "y": 1470}, {"x": 4500, "y": 1470}, {"x": 5500, "y": 1670}, {"x": 9000, "y": 1670}], "decorations": [{"image": "spr_232_sky.png", "x": 4500, "y": 1230, "width": 64, "height": 512, "order": -10, "flipX": false, "flipY": false, "layer": "Layer_1"}, {"image": "spr_232_layer1.png", "x": 4500, "y": 1441, "width": 2048, "height": 512, "order": -5, "flipX": false, "flipY": false, "layer": "Layer_2"}, {"image": "spr_232_layer2.png", "x": 4500, "y": 1430, "width": 1024, "height": 512, "order": -3, "flipX": false, "flipY": false, "layer": "Layer_3"}, {"image": "spr_232_layer3.png", "x": 4500, "y": 1530, "width": 1024, "height": 512, "order": -1, "flipX": false, "flipY": false, "layer": "Layer_4"}, {"image": "spr_232_sky.png", "x": 4500, "y": 1770, "width": 64, "height": 512, "order": 0, "flipX": false, "flipY": false, "layer": "Layer_Ground"}, {"image": "spr_232_dattiencanh.png", "x": 4500, "y": 1970, "width": 2048, "height": 512, "order": 6, "flipX": false, "flipY": false, "layer": "Layer_Ground"}], "cameraBounds": {"top": 0, "bottom": 3000, "left": 0, "right": 9000}, "platforms": []}',
  '[["R\u1eebng S\u00e2u", 0, 0, 48, 3000, 1, 0, 231, 8900, 3000]]'
);


-- (Tùy chọn) Thêm waypoint từ map cũ sang map mới
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

SELECT '=== Map 7VNR Setup Complete ===' AS status;
