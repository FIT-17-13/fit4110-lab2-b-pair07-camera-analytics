# Phân tích yêu cầu — vai Consumer

- Cặp đàm phán: Pair 07 — Camera Stream ↔ Analytics
- Product: B
- Consumer service: Analytics (consumer)
- Provider service: Camera Stream (producer)
- Người viết: Võ Minh Quân
- Ngày: 18 tháng 5

---

## 1. Resource Consumer cần nhận/gửi

| Resource | Consumer dùng để làm gì? | Field bắt buộc với Consumer | Field có thể tùy chọn |
|---|---|---|---|
| CameraEvent | Làm chuẩn chung để parse event | eventId, eventType, occurredAt, cameraId, sourceService | correlationId |
| MotionDetectedEvent | Thống kê motion và kích hoạt pipeline | motionType, detectionId, imageRef | confidence |
| FrameAnalyzedEvent | Tổng hợp kết quả phân tích | imageRef, analysisSummary | confidence, detectionId |
| CameraStatusChangedEvent | Theo dõi tình trạng camera | status, occurredAt | reason, offlineSince |

---

## 2. API Consumer cần gọi

| Method | Path | Lúc nào gọi? | Kỳ vọng response |
|---|---|---|---|
| EVENT | camera.motion.detected | Khi nhận event motion từ queue | Ack/commit offset |
| EVENT | camera.frame.analyzed | Khi nhận event phân tích frame | Ack/commit offset |
| EVENT | camera.status.changed | Khi nhận event trạng thái camera | Ack/commit offset |

---

## 3. Error case Consumer cần xử lý

Tối thiểu 5 case.

| Status | Consumer hiểu là gì? | Consumer sẽ xử lý thế nào? |
|---:|---|---|
| 400 | Request sai schema | Reject event + log lỗi |
| 401 | Thiếu token | Kiểm tra quyền publish/subscribe |
| 403 | Không đủ quyền | Báo lỗi quyền truy cập |
| 409 | Trùng eventId | Idempotent xử lý, bỏ qua duplicate |
| 422 | Vi phạm rule nghiệp vụ | Log và đưa vào DLQ (Lab 03) |
| 500 | Lỗi xử lý nội bộ | Retry theo policy |

---

## 4. Giả định bổ sung

- Chỉ nhận `imageRef`, không nhận ảnh thật.
- Event publish theo cơ chế at-least-once, có thể trùng.
- `correlationId` là tùy chọn nhưng khuyến nghị có.

---

## 5. Câu hỏi cho Provider

1. `confidence` có bắt buộc không và có range cố định không?
2. Camera offline bao lâu thì emit `camera.status.changed`?
3. Quy ước format `cameraId` có bắt buộc không (ví dụ CAM-007)?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Provider đổi cấu trúc event | Consumer parse lỗi | Chốt schema và versioning |
| Thiếu correlationId | Khó trace pipeline | Khuyến nghị correlationId |
| Event trùng do retry | Dữ liệu thống kê sai | Idempotent theo `eventId` |
