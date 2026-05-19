# Phân tích yêu cầu — vai Provider

- Cặp đàm phán: Pair 07 — Camera Stream ↔ Analytics
- Product: B
- Provider service: Camera Stream (producer)
- Consumer service: Analytics (consumer)
- Người viết: Võ Minh Quân
- Ngày: 18 tháng 5

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| CameraEvent | Event chung cho camera | eventId, eventType, occurredAt, cameraId, sourceService | correlationId |
| MotionDetectedEvent | Motion được phát hiện | eventId, eventType, occurredAt, cameraId, sourceService, motionType | detectionId, imageRef, confidence |
| FrameAnalyzedEvent | Frame đã phân tích | eventId, eventType, occurredAt, cameraId, sourceService, imageRef, analysisSummary | detectionId, confidence |
| CameraStatusChangedEvent | Trạng thái camera thay đổi | eventId, eventType, occurredAt, cameraId, sourceService, status | reason, offlineSince |

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
| EVENT | camera.motion.detected | Gửi event motion | Consumer xử lý khi nhận event từ queue |
| EVENT | camera.frame.analyzed | Gửi kết quả phân tích frame | Consumer xử lý khi nhận event từ queue |
| EVENT | camera.status.changed | Gửi trạng thái camera | Consumer xử lý khi nhận event từ queue |

---

## 3. Error case

Tối thiểu 5 case.

| Status | Tình huống | Response body dự kiến |
|---:|---|---|
| 400 | Payload sai định dạng | `Problem` |
| 401 | Thiếu Bearer token | `Problem` |
| 403 | Token hợp lệ nhưng không có quyền | `Problem` |
| 409 | Trùng eventId (duplicate publish) | `Problem` |
| 422 | Dữ liệu đúng JSON nhưng vi phạm nghiệp vụ | `Problem` |
| 500 | Lỗi xử lý nội bộ | `Problem` |

---

## 4. Giả định bổ sung

Ghi rõ những điểm user story chưa nói nhưng Provider cần giả định.

- Chỉ gửi `imageRef` (không gửi ảnh thật) để tránh payload lớn.
- `eventId` là duy nhất; consumer xử lý idempotent.
- `offlineSince` sinh khi không có heartbeat trong khoảng thời gian TBD.

---

## 5. Câu hỏi cho Consumer

1. Thời gian threshold để emit `camera.status.changed` khi offline là bao lâu?
2. `confidence` có bắt buộc không hay có thể null?
3. Consumer có cần đảm bảo ordering theo `cameraId` không?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Trùng event do retry | Consumer xử lý lặp | Idempotency theo `eventId` |
| Thiếu correlationId | Khó trace flow end-to-end | Bắt buộc/khuyến nghị correlationId |
| Payload lớn nếu gửi ảnh | Queue chậm hoặc lỗi | Chuẩn hóa chỉ gửi `imageRef` |
