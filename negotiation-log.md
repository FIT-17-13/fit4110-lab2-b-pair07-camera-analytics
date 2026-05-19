# Biên bản đàm phán hợp đồng API

- Cặp đàm phán: Pair 07 — Camera Stream ↔ Analytics
- Product: B
- Provider: Analytics (event consumer)
- Consumer: Camera Stream (event producer)
- Phiên: v1.0
- Ngày: 18 tháng 5

---

## Issue #1

- Raised by: Consumer
- Endpoint: camera.motion.detected, camera.frame.analyzed
- Concern: Payload lớn nếu gửi ảnh thật/base64 qua queue.
- Proposal: Chỉ gửi `imageRef` (URI) + metadata.
- Resolution: Accepted
- Rationale: Giảm băng thông, dễ mock và dễ scale.
- Impact: Analytics cần quyền truy cập nơi lưu ảnh.

---

## Issue #2

- Raised by: Provider
- Endpoint: camera.motion.detected, camera.frame.analyzed
- Concern: `confidence` có bắt buộc không?
- Proposal: `confidence` là optional, range 0..1; có thể null.
- Resolution: Accepted
- Rationale: Một số model không trả confidence.
- Impact: Consumer cần handle null.

---

## Issue #3

- Raised by: Provider
- Endpoint: camera.motion.detected, camera.frame.analyzed
- Concern: Cần chuẩn hóa `eventId`, `correlationId`, `detectionId`.
- Proposal: `eventId` bắt buộc; `correlationId`/`detectionId` optional, format UUID.
- Resolution: Accepted
- Rationale: Đảm bảo trace, nhưng không ép nếu upstream chưa có.
- Impact: Consumer xử lý idempotent theo `eventId`.

---

## Issue #4

- Raised by: Consumer
- Endpoint: camera.status.changed
- Concern: Định nghĩa camera offline bao lâu thì emit status event.
- Proposal: Emit `OFFLINE` nếu mất heartbeat quá TBD phút.
- Resolution: Modified
- Rationale: Cần xác nhận với vận hành thực tế.
- Impact: Sẽ chốt lại ngưỡng cụ thể trước khi ký cuối.

---

## Issue #5

- Raised by: Provider
- Endpoint: camera.*
- Concern: Retry có thể tạo duplicate event.
- Proposal: At-least-once publish, consumer idempotent theo `eventId`.
- Resolution: Accepted
- Rationale: Queue async thường có retry.
- Impact: Consumer cần lưu `eventId` đã xử lý.

---

## Issue #6

- Raised by: Consumer
- Endpoint: camera.*
- Concern: Chuẩn hóa tên event/topic và versioning.
- Proposal: Event type: `camera.motion.detected`, `camera.frame.analyzed`, `camera.status.changed`; topic `camera.events.v1`.
- Resolution: Accepted
- Rationale: Dễ mở rộng version.
- Impact: Đổi schema sẽ bump topic/version.

---

# Chốt hợp đồng v1.0

Provider sign-off: TBD  
Consumer sign-off: TBD  
Witness (GV/TA): TBD    
Date: TBD              

---

## Ghi chú warning nếu Spectral còn cảnh báo

| Warning | Lý do chấp nhận tạm thời | Kế hoạch sửa |
|---|---|---|
|  |  |  |
