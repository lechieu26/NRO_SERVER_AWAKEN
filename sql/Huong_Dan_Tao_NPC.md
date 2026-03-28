# Tài liệu Cơ chế Hiển thị và Quản lý NPC

Tài liệu này mô tả chi tiết cách hệ thống Server (TOMAHOC) và Client (PROJECT_NRO_240_mod) phối hợp để quản lý, hiển thị NPC, cùng các công thức tính toán tọa độ và ảnh hưởng của hệ thống Scale (ZoomLevel).

---

## 1. Quản lý dữ liệu tại Server (TOMAHOC)

### Cơ sở dữ liệu
Dữ liệu gốc được lưu tại bảng `npc_template` trong Database, bao gồm các trường chính:
- `id`: Định danh loại NPC.
- `name`: Tên hiển thị.
- `head`, `body`, `leg`: ID của các bộ phận (Part ID) để ghép thành hình ảnh.
- `avatar`: ID ảnh đại diện khi đối thoại.

### Cấu trúc Code
- **Model:** `src/models/Template.java` chứa class `NpcTemplate` định nghĩa cấu trúc dữ liệu.
- **Manager:** `Manager.java` thực hiện nạp toàn bộ `npc_template` từ DB vào bộ nhớ (List `NPC_TEMPLATES`) khi khởi động server.
- **Khởi tạo:** `NpcFactory.java` chịu trách nhiệm tạo ra các đối tượng NPC cụ thể tại các bản đồ.

---

## 2. Quản lý và Vẽ tại Client (PROJECT_NRO_240_mod)

### Cấu trúc Code
- **Class NPC:** `Assets/Scripts/Npc.cs` kế thừa từ `Char.cs`. Do đó, NPC thừa hưởng toàn bộ hệ thống khung xương và trạng thái của nhân vật (Char).
- **Dữ liệu bộ phận:** Các ID `head`, `body`, `leg` từ server gửi về sẽ được Client tra cứu trong mảng `GameScr.parts` để lấy ra các đối tượng `Part`.
- **Mảnh ảnh (Path):** Mỗi `Part` chứa một danh sách `PartImage` (đây chính là dữ liệu lấy từ file `path`). Mỗi mảnh ảnh có tọa độ lệch gốc là `dx` và `dy`.

---

## 3. Hệ thống Khung xương (Skeleton System)

Client sử dụng một mảng hằng số đặc biệt trong `Char.cs` gọi là `CharInfo` để định vị các bộ phận theo từng khung hình (frame).

**Cấu trúc dữ liệu `CharInfo[frame][type]`:**
- `type = 0`: Head (Đầu)
- `type = 1`: Leg (Chân)
- `type = 2`: Body (Thân)

**Mỗi phần tử chứa 3 giá trị:** `{Index, DX_skeleton, DY_skeleton}`

---

## 4. Công thức tính toán tọa độ hiển thị

Để một NPC hiển thị hoàn chỉnh, Client thực hiện phép cộng dồn tọa độ từ 3 nguồn: **Tọa độ Map** + **Khung xương** + **Độ lệch Path**.

### Tham số định nghĩa:
- $(cx, cy)$: Tọa độ thực của NPC trên Map.
- $cf$: Chỉ số hiệu ứng khung hình (0: đứng yên, 1: thở/nhún...).
- $cdir$: Hướng quay mặt (1: Phải, -1: Trái).
- $DX_{skel}, DY_{skel}$: Độ lệch chuẩn từ `CharInfo[cf][type]`.
- $dx_{path}, dy_{path}$: Độ lệch của mảnh ảnh trong file Path (`PartImage.dx/dy`).

### Công thức tính tọa độ vẽ ($X_{draw}, Y_{draw}$):

#### A. Tọa độ Logic (Trước khi nhân Scale)

**1. Khi NPC quay mặt sang PHẢI ($cdir = 1$):**
$$X_{logic} = cx + DX_{skel} + dx_{path}$$
$$Y_{logic} = cy - DY_{skel} + dy_{path}$$

**2. Khi NPC quay mặt sang TRÁI ($cdir = -1$):**
$$X_{logic} = cx - DX_{skel} - dx_{path}$$
$$Y_{logic} = cy - DY_{skel} + dy_{path}$$

#### B. Tọa độ Màn hình (Sau khi nhân Scale)
Hệ thống vẽ (`mGraphics`) sẽ tự động nhân các tọa độ logic với `zoomLevel`:
$$X_{screen} = X_{logic} \times zoomLevel$$
$$Y_{screen} = Y_{logic} \times zoomLevel$$

---

## 5. Quy trình vẽ hoàn chỉnh (Rendering Workflow)

Để NPC hiển thị đúng lớp, Client thực hiện vẽ theo thứ tự lớp (Z-index) tăng dần:

1.  **Lớp 1 (Vẽ trước):** **Head (Đầu)** - Được định vị cao nhất và xa nhất so với mặt đất.
2.  **Lớp 2 (Vẽ giữa):** **Leg (Chân)** - Điểm tựa tại tọa độ `cy`.
3.  **Lớp 3 (Vẽ sau cùng - Đè lên):** **Body (Thân)** - Phần thân thường có các mảnh ảnh đè lên phần dưới của đầu và phần trên của chân để tạo sự liền mạch.

### Vị trí Neo (Anchor & Alignment)
Hàm vẽ NPC sử dụng `anchor = 0` (Mặc định).
- **Điểm neo:** Là góc **TRÊN - TRÁI (Top-Left)** của mảnh ảnh.
- **Tọa độ tính toán:** Chính xác là vị trí pixel góc trên cùng bên trái nơi tấm ảnh sẽ được đặt vào.

---

## 6. Ảnh hưởng của tỷ lệ Scale (Zoom Level)

Hệ thống Client sử dụng một biến `zoomLevel` để thích nghi với các độ phân giải màn hình khác nhau. Giá trị này ảnh hưởng trực tiếp đến **mọi tọa độ vẽ và kích thước ảnh** trong game.

### Cách xác định `zoomLevel`
Giá trị `zoomLevel` được tính tự động trong `MotherCanvas.cs`:

| Độ phân giải (pixel²) | `zoomLevel` | Ví dụ |
|---|---|---|
| < 480.000 | **1** | Game gốc J2ME |
| < 691.200 | **2** | x2 (HD) |
| < 2.073.600 | **3** | x3 (FullHD) |
| >= 2.073.600 | **4** | x4 (2K, 4K) |

### Lưu ý quan trọng
- Server **KHÔNG** quản lý và không biết về `zoomLevel`.
- Dữ liệu `path` (dx, dy) và `CharInfo` trong code là tọa độ gốc (x1). Bạn **không cần nhân thủ công** với scale khi code logic.
- Việc nhân scale được thực hiện tự động ở lớp base (`mGraphics`).

---

## 7. Sơ đồ luồng xử lý

```
[Dữ liệu Path từ Server]
         ↓
 (dx_path, dy_path) -- Tọa độ gốc x1
         ↓
 [Kết hợp với CharInfo Skeleton]
         ↓
   (X_logic, Y_logic)
         ↓
   [mGraphics.drawRegion]
         ↓
  (X_logic * zoomLevel, Y_logic * zoomLevel)
         ↓
      [Màn hình]
```

---

## 8. Ví dụ Minh họa với Số liệu Thực

### Dữ liệu đầu vào:
*   **Vị trí NPC trên Map:** `cx = 100`, `cy = 200`
*   **Trạng thái:** Đứng yên (`cf = 0`), Quay phải (`cdir = 1`)
*   **ZoomLevel:** 4 (Màn hình 2K/4K)
*   **Path Data:**
    *   **Head (Type 0):** `[558, 2, 3]` (dx=2, dy=3)
    *   **Body (Type 1):** `[560, -2, 1]` (dx=-2, dy=1) *Lưu ý: Trong code đây là Type 1*
    *   **Leg (Type 2):** `[559, -1, 5]` (dx=-1, dy=5) *Lưu ý: Trong code đây là Type 2*
*   **Skeleton Data (CharInfo[0]):**
    *   Head (0): `DX = -13, DY = 34`
    *   Leg (1): `DX = -8, DY = 10`
    *   Body (2): `DX = -9, DY = 16`

### Bảng tính toán chi tiết:

| Bộ phận | Công thức Logic (x1) | Tọa độ Logic (X, Y) | Tọa độ Màn hình (x4) | Vị trí đặt ảnh |
| :--- | :--- | :--- | :--- | :--- |
| **Head** | X = 100 + (-13) + 2<br>Y = 200 - 34 + 3 | **(89, 169)** | **(356, 676)** | Góc Trên-Trái ảnh 558 |
| **Body** | X = 100 + (-9) + (-2)<br>Y = 200 - 16 + 1 | **(89, 185)** | **(356, 740)** | Góc Trên-Trái ảnh 560 |
| **Leg** | X = 100 + (-8) + (-1)<br>Y = 200 - 10 + 5 | **(91, 195)** | **(364, 780)** | Góc Trên-Trái ảnh 559 |

**Kết luận hiển thị:**
Trên màn hình độ phân giải cao (x4), các mảnh ảnh sẽ được phóng to gấp 4 lần và đặt chính xác vào các tọa độ cột "Tọa độ Màn hình". Nhờ tỷ lệ nhân đồng nhất, NPC hiển thị liền mạch, sắc nét và đúng vị trí mong muốn.


## 9. Cách thêm 1 NPC

Sau khi sử dụng tool để tạo NPC và lưu trong npc_template

1. Thêm vào ConstNpc: thêm const với id và tên trong đó id = id của NPC trong table npc_template
Ví dụ: public static final byte NONG_DAN = 87;

2. Thêm vào NpcFactory
Trong hàm public static Npc createNPC(int mapId, int status, int cx, int cy, int tempId)
Thêm code để tạo NPC:
      case ConstNpc.NONG_DAN ->
            new NongDan(mapId, status, cx, cy, tempId, avatar);
3. Tạo class NPC:
Trong thư mục \src\npc\npc_manifest tạo class của NPC:
Ví dụ: public class NongDan extends Npc { ... }
Trong class NPC:

``` Java
package npc.npc_manifest;

import npc.Npc;
import player.Player;
import shop.ShopService;
import consts.ConstNpc;

public class NongDan extends Npc {
    public NongDan(int mapId, int status, int cx, int cy, int tempId, int avartar) {
        super(mapId, status, cx, cy, tempId, avartar);
    }

    @Override
    public void openBaseMenu(Player player) {
        if (canOpenNpc(player)) {
            // Hiển thị menu khi người chơi click vào NPC
            createOtherMenu(player, ConstNpc.BASE_MENU,
                    "Chào cậu, tôi có bán vài món đồ hịn đây!",
                    "Cửa hàng", "Thu hoạch\nnhanh", "Gieo hạt\nnhanh", "Từ chối");
        }
    }

    @Override
    public void confirmMenu(Player player, int select) {
        if (canOpenNpc(player)) {
            if (player.iDMark.isBaseMenu()) {
                switch (select) {
                    case 0: // Khi người chơi chọn "Cửa hàng"
                        // "Hạt giống" phải khớp với tag_name trong database
                        ShopService.gI().opendShop(player, "Hạt giống", false);
                        break;
                    case 1: // Thu hoạch nhanh
                        services.FarmService.gI().harvestAllPlots(player);
                        break;
                    case 2: // Gieo hạt nhanh
                        services.FarmService.gI().openSeedSelectionMenuMass(player);
                        break;
                    default:
                        break;
                }
            }
        }
    }
}
```   




