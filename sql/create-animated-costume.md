---
description: Hướng dẫn tạo Cải trang có Hoạt ảnh động (Animation)
---

# Hướng dẫn tạo Cải trang có Hoạt ảnh động (Animation)

## Tổng quan

Để tạo một cải trang có animation (ví dụ: tóc bay, mắt nhấp nháy), bạn cần thao tác với **3 bảng** trong Database:

| Bảng | Mục đích |
|------|----------|
| `part` | Chứa dữ liệu hình ảnh của từng frame (Head, Body, Leg) |
| `array_head_2_frames` | Định nghĩa nhóm các Part ID tạo thành animation cho HEAD |
| `item_template` | Định nghĩa Item cải trang, gán Head/Body/Leg ID |

---

## Cơ chế hoạt động

### Luồng dữ liệu

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATABASE                                   │
├─────────────────────────────────────────────────────────────────┤
│  item_template                                                    │
│  ┌──────────────────────────────────────────┐                    │
│  │ id=1900, head=2000, body=2003, leg=2004  │                    │
│  └──────────────────────────────────────────┘                    │
│                         │                                         │
│                         ▼                                         │
│  array_head_2_frames                                              │
│  ┌──────────────────────────────────────────┐                    │
│  │ data = '[2000, 2001, 2002]'              │ ◄── Animation!     │
│  └──────────────────────────────────────────┘                    │
│                         │                                         │
│                         ▼                                         │
│  part                                                             │
│  ┌────────────────┬────────────────┬────────────────┐            │
│  │ id=2000 (F1)   │ id=2001 (F2)   │ id=2002 (F3)   │            │
│  │ iconId=20001   │ iconId=20002   │ iconId=20003   │            │
│  └────────────────┴────────────────┴────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT                                     │
│  1. Nhận head=2000                                                │
│  2. Tra cứu array_head_2_frames → tìm thấy [2000,2001,2002]      │
│  3. Load Part 2000, 2001, 2002                                   │
│  4. Render animation: 2000 → 2001 → 2002 → 2000 → ... (lặp)     │
└─────────────────────────────────────────────────────────────────┘
```

### Giải thích

- **Item Template** chỉ gán `head = 2000` (Part ID của frame đầu tiên)
- **Bảng `array_head_2_frames`** định nghĩa: "Animation set bao gồm 2000, 2001, 2002"
- **Client** tra cứu bảng này khi render và tự động biết cần load thêm 2001, 2002

---

## Các bước thực hiện

### Bước 1: Chuẩn bị hình ảnh (Assets)

Bạn cần có các hình ảnh cho từng frame animation trong Client (thường nằm trong file res hoặc data của Client).

Ví dụ cho animation Head 3 frame:
- **Frame 1:** Icon ID `20001` (tóc bình thường)
- **Frame 2:** Icon ID `20002` (tóc bay nhẹ)
- **Frame 3:** Icon ID `20003` (tóc bay cao)

---

### Bước 2: Thêm dữ liệu vào bảng `part`

Mỗi frame cần một dòng riêng trong bảng `part`.

```sql
-- Giả sử Part ID tiếp theo khả dụng là 2000, 2001, 2002
-- HEAD (3 frame animation)
INSERT INTO `part` (`id`, `type`, `data`) VALUES 
(2000, 0, '[[20001, 0, 0], [20001, 0, 0], [20001, 0, 0]]'),  -- Frame 1
(2001, 0, '[[20002, 0, 0], [20002, 0, 0], [20002, 0, 0]]'),  -- Frame 2
(2002, 0, '[[20003, 0, 0], [20003, 0, 0], [20003, 0, 0]]');  -- Frame 3

-- BODY (1 frame, không animation)
INSERT INTO `part` (`id`, `type`, `data`) VALUES 
(2003, 1, '[[20010, 0, 0], ... 17 phần tử cho type 1 ...]]');

-- LEG (1 frame, không animation)
INSERT INTO `part` (`id`, `type`, `data`) VALUES 
(2004, 2, '[[20020, 0, 0], ... 14 phần tử cho type 2 ...]]');
```

#### Giải thích cột `type` và `data`:

| Type | Bộ phận | Số phần tử trong data |
|------|---------|----------------------|
| 0 | Head | 3 phần tử |
| 1 | Body | 17 phần tử |
| 2 | Leg | 14 phần tử |

Mỗi phần tử trong mảng `data` có cấu trúc: `[iconId, dx, dy]`
- `iconId`: ID hình ảnh trong Client
- `dx`, `dy`: Offset vị trí (thường là 0)

---

### Bước 3: Đăng ký Animation trong `array_head_2_frames`

**Đây là bước quan trọng nhất để HEAD có animation!**

```sql
-- Thêm nhóm animation cho Head
-- data chứa mảng các Part ID theo thứ tự: [frame1, frame2, frame3]
INSERT INTO `array_head_2_frames` (`id`, `data`) VALUES 
(100, '[2000, 2001, 2002]');  -- ID 100 là tự chọn (auto-increment), không quan trọng
```

**Lưu ý:**
- Phần tử đầu tiên (2000) là Part ID chính được gán vào Item
- Client sẽ tự động load thêm 2001, 2002 để tạo animation
- Nếu chỉ muốn 2 frame: `'[2000, 2001]'`
- Số lượng frame có thể là 2, 3 hoặc nhiều hơn

---

### Bước 4: Tạo Item cải trang trong `item_template`

```sql
INSERT INTO `item_template` (
    `id`, `type`, `gender`, `name`, `description`, `is_up_to_up`, 
    `icon_id`, `part`, `str_require`, `gold`, `gem`, `ruby`, 
    `head`, `body`, `leg`, `level`, `isss`, `info`
) VALUES (
    1900,           -- ID item mới
    5,              -- type = 5 (Cải trang)
    3,              -- gender = 3 (Dùng cho tất cả)
    'Cải Trang ABC', 
    'Mô tả cải trang',
    1,              -- is_up_to_up
    20001,          -- icon_id (Icon hiển thị trong túi đồ)
    -1,             -- part
    0,              -- str_require
    0, 0, 0,        -- gold, gem, ruby
    2000,           -- HEAD = Part ID frame đầu tiên (2000)
    2003,           -- BODY = Part ID body
    2004,           -- LEG = Part ID leg
    0,              -- level
    1,              -- isss
    ''              -- info
);
```

---

### Bước 5: Khởi động lại Server

Sau khi thêm dữ liệu, cần **restart Server** để nạp lại data từ Database.

---

## Ví dụ thực tế từ Database

Lấy ví dụ cải trang "Supper Gohan" (Item ID 1840):

**Trong `item_template`:**
```
head = 1840, body = 1843, leg = 1844
```

**Trong `array_head_2_frames`:**
```sql
(51, '[1840,1841,1842]')
```

**Kết quả:** Head 1840 có animation 3 frame: 1840 → 1841 → 1842 → lặp lại

---

## Lưu ý quan trọng

1. **Body và Leg không cần `array_head_2_frames`**
   - Animation của Body/Leg được xử lý khác (dựa vào `type` và số phần tử trong `data`)
   - Chỉ HEAD mới sử dụng bảng `array_head_2_frames`

2. **Thứ tự Part ID trong mảng quan trọng**
   - Frame đầu tiên PHẢI là ID bạn gán vào `item_template.head`

3. **ID trong bảng `array_head_2_frames` không quan trọng**
   - Chỉ là primary key tự tăng
   - Server không sử dụng giá trị này

4. **Kiểm tra trước khi thêm**
   - Đảm bảo các Part ID và Icon ID chưa tồn tại để tránh trùng lặp
   - Query: `SELECT MAX(id) FROM part;` để biết ID tiếp theo

5. **Cải trang không animation**
   - Nếu không muốn animation, chỉ cần KHÔNG thêm vào `array_head_2_frames`
   - Client sẽ chỉ render 1 frame duy nhất

---

## Files liên quan trong Source Code

| File | Chức năng |
|------|-----------|
| `src/server/Manager.java` (dòng 499-510) | Load `array_head_2_frames` từ DB |
| `src/data/ItemData.java` (dòng 123-141) | Gửi data animation xuống Client |
| `src/models/Template.java` (dòng 222-226) | Class `ArrHead2Frames` |
