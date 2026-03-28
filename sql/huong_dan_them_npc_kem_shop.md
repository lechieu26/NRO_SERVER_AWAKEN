# Hướng dẫn thêm NPC mới kèm Cửa hàng (Shop) - Server TOMAHOC

Việc thêm một NPC có cửa hàng bao gồm 2 phần chính: Cấu hình Database và Viết code xử lý trên Server.

---

## Bước 1: Cấu hình trong Database (MySQL)

Bạn cần sử dụng các công cụ như Navicat, HeidiSQL để thêm dữ liệu vào các bảng sau:

### 1.1. Thêm NPC Template (`npc_template`)
Bảng này định nghĩa hình dáng và tên của NPC.
- **id**: ID của NPC (không được trùng với các ID đã có).
- **name**: Tên hiển thị của NPC.
- **head, body, leg**: ID các phần của NPC (lấy từ dữ liệu client).
- **avatar**: ID ảnh đại diện khi nói chuyện.

### 1.2. Thêm Cửa hàng (`shop`)
Định nghĩa một shop mới và gắn với NPC.
- **npc_id**: ID của NPC bạn vừa tạo ở bước 1.1.
- **tag_name**: Một chuỗi định danh duy nhất (Ví dụ: `MY_NEW_SHOP`).
- **type_shop**: Thường là `0` (Shop bình thường) hoặc `3` (Shop đặc biệt dùng vật phẩm đổi vật phẩm).

### 1.3. Thêm các Tab Shop (`tab_shop`)
Một shop có thể có nhiều tab (ví dụ: Tab Đồ trắng, Tab Item đặc biệt).
- **shop_id**: ID từ bảng `shop` vừa tạo.
- **tab_name**: Tên tab hiển thị trong game.
- **items**: Đây là cột quan trọng nhất, chứa dữ liệu JSON của các vật phẩm.
  - Cấu trúc JSON mẫu: `[{"temp_id": 193, "cost": 100, "type_sell": 0, "is_new": true, "is_sell": true, "options": [{"id": 50, "param": 10}], "item_spec": -1}]`
  - *Lưu ý: Bạn có thể sử dụng công cụ Shop Manager (trong ToolDrawMap) để quản lý và tạo dữ liệu item shop một cách trực quan.*

### 1.4. Đặt NPC vào Bản đồ (`map_template`)
Xác định NPC sẽ đứng ở map nào, tọa độ bao nhiêu.
- Tìm map muốn đặt NPC trong bảng `map_template`.
- Sửa cột `npcs`, thêm vào JSON array: `[npc_id, x, y]` (Ví dụ: `[[39, 500, 400]]` là NPC Santa ở tọa độ 500, 400).

---

## Bước 2: Chỉnh sửa Mã nguồn Server (Java)

### 2.1. Khai báo NPC ID (`src/consts/ConstNpc.java`)
Thêm một hằng số để dễ quản lý trong code:
```java
public static final byte MY_NEW_NPC = 120; // Thay 120 bằng ID bạn đã chọn ở DB
```

### 2.2. Tạo Class xử lý NPC (`src/npc/npc_manifest/`)
Tạo một file Java mới, ví dụ `MyNewNpc.java`:
```java
package npc.npc_manifest;

import npc.Npc;
import player.Player;
import shop.ShopService;
import consts.ConstNpc;

public class MyNewNpc extends Npc {
    public MyNewNpc(int mapId, int status, int cx, int cy, int tempId, int avartar) {
        super(mapId, status, cx, cy, tempId, avartar);
    }

    @Override
    public void openBaseMenu(Player player) {
        if (canOpenNpc(player)) {
            // Hiển thị menu khi người chơi click vào NPC
            createOtherMenu(player, ConstNpc.BASE_MENU, 
                "Chào cậu, tôi có bán vài món đồ hịn đây!", 
                "Cửa hàng", "Từ chối");
        }
    }

    @Override
    public void confirmMenu(Player player, int select) {
        if (canOpenNpc(player)) {
            if (player.iDMark.isBaseMenu()) {
                switch (select) {
                    case 0: // Khi người chơi chọn "Cửa hàng" 
                        // "MY_NEW_SHOP" phải khớp với tag_name trong database
                        ShopService.gI().opendShop(player, "MY_NEW_SHOP", false);
                        break;
                }
            }
        }
    }
}
```

### 2.3. Đăng ký NPC vào Factory (`src/npc/NpcFactory.java`)
Tìm phương thức `createNPC` và thêm NPC mới vào cấu trúc `switch`:
```java
case ConstNpc.MY_NEW_NPC:
    return new MyNewNpc(mapId, status, cx, cy, tempId, avatar);
```

---

## Bước 3: Hoàn tất

1. **Build lại project**: Sử dụng Ant hoặc công cụ build của bạn để biên dịch mã nguồn Java.
2. **Khởi động server**: Server sẽ load NPC từ Database và khởi tạo logic từ các class bạn vừa thêm.
3. **Kiểm tra**: Vào đúng Map và tọa độ đã cài đặt để thấy NPC và kiểm tra tính năng mở Shop.

---
*Hướng dẫn được soạn bởi Antigravity AI.*
