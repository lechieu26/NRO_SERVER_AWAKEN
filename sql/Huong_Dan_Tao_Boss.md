# Hướng Dẫn Tạo Boss Mới (TOMAHOC Server)

Tài liệu này hướng dẫn chi tiết các bước để tạo một Boss mới trong source code server **TOMAHOC**. Việc tạo Boss hoàn toàn thực hiện ở phía Server (Java), Client chỉ việc hiển thị theo thông tin Server gửi về (Outfit, tên, chỉ số...).

## Tổng Quan

Để thêm một Boss mới, bạn cần thực hiện **3 bước chính**:
1.  **Khai báo ID** cho Boss mới trong `BossID.java`.
2.  **Tạo Class** xử lý logic cho Boss (extends `Boss`) trong package `boss.boss_manifest...`.
3.  **Đăng ký Boss** vào `BossManager.java` để server quản lý và spawn.

---

## Bước 1: Khai Báo ID Boss

Mở file `src/boss/BossID.java`. Đây là nơi chứa danh sách ID của tất cả các Boss. Hãy thêm một hằng số ID mới (số âm để tránh trùng với ID người chơi hoặc quái thường/NPC).

**Ví dụ:** Bạn muốn tạo Boss tên là "Siêu Nhân Vàng".

```java
// File: src/boss/BossID.java

public class BossID {
    // ... các ID cũ ...
    
    // Thêm ID mới vào cuối hoặc nhóm phù hợp
    public static final int SIEU_NHAN_VANG = -123456; // Đảm bảo ID này chưa ai dùng
}
```

---

## Bước 2: Tạo Class Cho Boss

Bạn cần tạo một file Java mới cho Boss này. Thông thường các boss được đặt trong `src/boss/boss_manifest/`. Bạn có thể tạo thư mục mới hoặc để vào thư mục có sẵn.

Boss sẽ kế thừa class `Boss` và gọi `super` để truyền `BossData` vào.

**Cấu trúc file `SieuNhanVang.java`:**

```java
package boss.boss_manifest.SieuNhanVang; // Ví dụ package

import boss.Boss;
import boss.BossData;
import boss.BossID;
import boss.BossStatus;
import consts.ConstPlayer;
import map.Zone;
import player.Player;
import skill.Skill;
import utils.Util;
import services.Service;
// Import thêm các service cần thiết nếu dùng

public class SieuNhanVang extends Boss {

    public SieuNhanVang() throws Exception {
        super(BossID.SIEU_NHAN_VANG, new BossData(
            "Siêu Nhân Vàng", // Tên hiển thị
            ConstPlayer.TRAI_DAT, // Giới tính (TRAI_DAT, NAMEC, XAYDA)
            new short[]{ 123, 124, 125, -1, -1, -1 }, // Outfit {Head, Body, Leg, Bag, Aura, Eff}
            // Head, Body, Leg: ID trang bị (lấy từ Client hoặc database)
            
            10000, // Dame (Sức đánh cơ bản)
            new long[]{ 500000000L }, // HP (Máu), có thể để mảng nhiều nấc máu
            new int[]{ 5, 10, 15 }, // Map Join: Danh sách ID map mà boss có thể xuất hiện
            
            // Skill: Mảng các skill boss sử dụng {ID Skill, Level Skill, CoolDown (ms)}
            new int[][]{
                {Skill.DRAGON, 7, 1000},       // Chưởng
                {Skill.DEMON, 7, 1000},        // Đấm demon
                {Skill.KAMEJOKO, 7, 2000},     // Kamejoko
                {Skill.THAI_DUONG_HA_SAN, 1, 30000} // Thái dương hạ san
            },
            
            // Text Chat 1: Chat khi vừa xuất hiện (trống thì ko chat)
            new String[]{"|-1|Ta đã đến đây!", "|-1|Mọi người cẩn thận"}, 
            
            // Text Chat 2: Chat khi đang đánh nhau
            new String[]{"|-1|Đau quá", "|-1|Ngươi khá lắm"},
            
            // Text Chat 3: Chat khi chết hoặc biến mất
            new String[]{"|-1|Ta sẽ quay lại!"},
            
            60 // Seconds Rest: Thời gian nghỉ trước khi respawn lại (giây)
        ));
    }

    @Override
    public void active() {
        super.active(); 
        // Logic hoạt động riêng nếu cần (mặc định super.active() là tự tìm và đánh người)
    }

    @Override
    public void joinMap() {
        super.joinMap(); // Mặc định join vào map ngẫu nhiên trong danh sách mapJoin
        st = System.currentTimeMillis();
    }
    private long st;
    
    // Xử lý khi Boss bị đánh (có thể override để kháng đòn, phản dame...)
    @Override
    public synchronized long injured(Player plAtt, long damage, boolean piercing, boolean isMobAttack) {
        if (!this.isDie()) {
             // Ví dụ: Giới hạn dame nhận vào ko quá 1% HP
            long limit = this.nPoint.hpMax / 100;
            if (damage > limit) {
                damage = limit;
            }
            
            // Gọi super để trừ máu
            return super.injured(plAtt, damage, piercing, isMobAttack);
        }
        return 0;
    }

    // Xử lý khen thưởng khi Boss chết
    @Override
    public void reward(Player plKill) {
        // Cộng điểm, rơi vật phẩm...
        if (Util.isTrue(1, 5)) { // 20% rơi cải trang
             Service.gI().dropItemMap(this.zone, Util.getInt(0, 100, 100, 100)); // Ví dụ code drop
        }
        // Gọi super để thông báo kênh thế giới
        super.reward(plKill);
    }
}
```

### Giải thích các tham số `BossData`:
1.  **Name**: Tên Boss hiện trên đầu.
2.  **Gender**: Giới tính (dùng cho mốt số tính toán skill/HP).
3.  **Outfit**: Quan trọng. Là ID của `Head` (đầu), `Body` (áo), `Leg` (quần).
    *   *Cách lấy ID:* Bạn có thể mở tool Admin hoặc xem database client để biết ID các bộ đồ muốn boss mặc.
4.  **Dame**: Sức đánh.
5.  **HP**: Mảng HP. Boss có thể hồi sinh nhiều lần với lượng máu khác nhau nếu mảng này có nhiều phần tử (như Fide).
6.  **Map Join**: ID các map boss sẽ random spawn.
7.  **Skill Temp**: Danh sách skill boss dùng.
8.  **Text Chat**: Các câu thoại của Boss (Prefix `|-1|` là chat thường, `|-2|` chat kênh thế giới...).

---

## Bước 3: Đăng Ký Boss Vào Manager

Mở file `src/boss/BossManager.java`.

1.  Tìm method `createBoss(int bossID)`. Thêm `case` cho boss mới của bạn để manager biết cách khởi tạo class nào khi gặp ID đó.

```java
// File: src/boss/BossManager.java

public Boss createBoss(int bossID) {
    try {
        return switch (bossID) {
            // ... các case cũ ...
            
            // THÊM CASE MỚI:
            case BossID.SIEU_NHAN_VANG -> new SieuNhanVang(); // Class bạn vừa tạo
            
            default -> null;
        };
    } catch (Exception e) {
        Logger.error(e + "\n");
        return null;
    }
}
```

2.  Tìm method `loadBoss()`. Thêm dòng lệnh tạo boss này khi server khởi động.

```java
// File: src/boss/BossManager.java

public void loadBoss() {
    // ... code cũ ...
    this.createBoss(BossID.BROLY);
    
    // THÊM DÒNG NÀY:
    this.createBoss(BossID.SIEU_NHAN_VANG); // Server khởi động sẽ tạo boss này luôn
}
```

---

## Lưu ý về Client (NRO_240_mod)

Về cơ bản bạn **không cần** sửa code Client nếu chỉ dùng các resource (Head/Body/Leg) có sẵn. Client sẽ nhận thông tin từ Server: "Có một thằng tên là Siêu Nhân Vàng, Đầu X, Áo Y, Quần Z đang ở tọa độ này" và Client tự vẽ ra.

Tuy nhiên, nếu bạn muốn Boss có:
*   **Hiệu ứng Skill mới lạ**: Cần code thêm Skill Effect ở Client (khó).
*   **Thông báo Boss đặc biệt**: File `Assets_Scripts_Mod_ShowBoss.cs` ở Client chịu trách nhiệm hiển thị thông báo "Boss XX vừa xuất hiện". Nó hoạt động dựa trên việc bắt tin nhắn chat server gửi về. Nếu server gửi đúng format `Boss [Tên] vừa xuất hiện tại...` thì Client sẽ tự hiện thông báo.

### Format Chat Server để kích hoạt thông báo Client:
Trong `Boss.java` method `notifyJoinMap()` đã xử lý sẵn việc này:
`ServerNotify.gI().notify("BOSS " + this.name + " vừa xuất hiện tại " + this.zone.map.mapName + " khu: " + this.zone.zoneId);`

Nên bạn cứ dùng code server chuẩn là client sẽ tự hiện thông báo.
