package map;

import consts.ConstMap;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;
import services.Service;
import utils.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * Map kiểu 7VNR — freeform collision (polyline), không dùng tile grid 24x24.
 * Tương thích với hệ thống Map cũ qua kế thừa.
 */
public class Map7VNR extends Map {

    /** Danh sách đoạn ground (polyline segments) */
    public List<GroundSegment> groundSegments = new ArrayList<>();

    /** Danh sách platform (one-way platforms) */
    public List<PlatformSegment> platforms = new ArrayList<>();

    /** Camera bounds */
    public int camTop, camBottom, camLeft, camRight;

    /** JSON config gốc — gửi nguyên cho client */
    public String mapConfigJson;

    /**
     * Constructor cho Map 7VNR.
     * Không cần tileMap/tileTop vì dùng freeform collision.
     */
    public Map7VNR(int mapId, String name, byte planetId,
                   int mapWidth, int mapHeight, int zones, int maxPlayer,
                   List<WayPoint> wayPoints, List<EffectMap> effMap,
                   String mapConfigJson) {
        // Gọi super với tileMap rỗng, tileId=0, bgId=0
        super(mapId, name, planetId,
                (byte) 0, (byte) 0, (byte) 0, ConstMap.MAP_7VNR,
                new int[mapHeight / 24 + 1][mapWidth / 24 + 1],
                new int[0],
                zones, maxPlayer, wayPoints, effMap);

        this.mapConfigJson = mapConfigJson;
        // Override dimensions set by super (which used tileMap)
        this.mapWidth = mapWidth;
        this.mapHeight = mapHeight;
        this.pxw = mapWidth;
        this.pxh = mapHeight;
        this.tmw = mapWidth / 24 + 1;
        this.tmh = mapHeight / 24 + 1;
        // Re-init maps/types with correct size (super() called readTileMap when tmw/tmh were wrong)
        this.maps = new int[this.tmw * this.tmh];
        this.types = new int[this.tmw * this.tmh];
    }

    /**
     * Parse mapConfigJson để lấy groundSegments, platforms, cameraBounds.
     */
    public void parseMapConfig(String configJson) {
        try {
            JSONObject config = (JSONObject) JSONValue.parse(configJson);
            if (config == null) return;

            // Parse groundPoints → groundSegments
            JSONArray groundArr = (JSONArray) config.get("groundPoints");
            if (groundArr != null && groundArr.size() >= 2) {
                for (int i = 0; i < groundArr.size() - 1; i++) {
                    JSONObject p1 = (JSONObject) groundArr.get(i);
                    JSONObject p2 = (JSONObject) groundArr.get(i + 1);
                    GroundSegment seg = new GroundSegment();
                    seg.x1 = ((Number) p1.get("x")).intValue();
                    seg.y1 = ((Number) p1.get("y")).intValue();
                    seg.x2 = ((Number) p2.get("x")).intValue();
                    seg.y2 = ((Number) p2.get("y")).intValue();
                    groundSegments.add(seg);
                }
            }

            // Parse platforms
            JSONArray platArr = (JSONArray) config.get("platforms");
            if (platArr != null) {
                for (int i = 0; i < platArr.size(); i++) {
                    JSONObject p = (JSONObject) platArr.get(i);
                    PlatformSegment plat = new PlatformSegment();
                    plat.x1 = ((Number) p.get("x1")).intValue();
                    plat.y1 = ((Number) p.get("y1")).intValue();
                    plat.x2 = ((Number) p.get("x2")).intValue();
                    plat.y2 = ((Number) p.get("y2")).intValue();
                    platforms.add(plat);
                }
            }

            // Parse cameraBounds
            JSONObject cam = (JSONObject) config.get("cameraBounds");
            if (cam != null) {
                camTop = ((Number) cam.get("top")).intValue();
                camBottom = ((Number) cam.get("bottom")).intValue();
                camLeft = ((Number) cam.get("left")).intValue();
                camRight = ((Number) cam.get("right")).intValue();
            }
        } catch (Exception e) {
            Logger.logException(Map7VNR.class, e, "Error parsing map config JSON for map " + mapId);
        }
    }

    /**
     * Tìm Y bề mặt ground gần nhất tại vị trí X.
     * Dùng linear interpolation trên polyline thay vì tile grid.
     */
    @Override
    public int yPhysicInTop(int x, int startY) {
        for (GroundSegment seg : groundSegments) {
            if (x >= seg.x1 && x <= seg.x2) {
                float t = (seg.x2 == seg.x1) ? 0 : (float) (x - seg.x1) / (seg.x2 - seg.x1);
                return (int) (seg.y1 + t * (seg.y2 - seg.y1));
            }
        }
        // Fallback: tìm segment gần nhất
        if (!groundSegments.isEmpty()) {
            GroundSegment first = groundSegments.get(0);
            GroundSegment last = groundSegments.get(groundSegments.size() - 1);
            if (x < first.x1) return first.y1;
            if (x > last.x2) return last.y2;
        }
        return startY;
    }

    /**
     * Override tileTypeAt — trong map 7VNR, kiểm tra collision bằng ground segments.
     */
    @Override
    public boolean tileTypeAt(int x, int y, int type) {
        if (type == 2) { // T_TOP check
            int groundY = yPhysicInTop(x, 0);
            // Coi vị trí là "top" nếu y nằm gần bề mặt ground (trong khoảng 24px)
            return y >= groundY && y <= groundY + 24;
        }
        return false;
    }

    /**
     * Override readTileMap — map 7VNR không đọc tile data file.
     */
    @Override
    public void readTileMap(int mapId) {
        // Không đọc tile file — map 7VNR dùng polyline collision
        // Khởi tạo maps/types rỗng (kích thước sẽ được cập nhật sau trong constructor)
        int size = Math.max(1, tmw * tmh);
        maps = new int[size];
        types = new int[size];
    }

    // ---- Data classes ----

    public static class GroundSegment {
        public int x1, y1, x2, y2;
    }

    public static class PlatformSegment {
        public int x1, y1, x2, y2;
    }
}
