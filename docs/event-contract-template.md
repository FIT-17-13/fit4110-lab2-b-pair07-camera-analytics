# Event Contract sơ bộ — dùng cho dependency Queue async

> File này chỉ dùng cho các cặp Queue async ở Lab 02 để ghi nhận thỏa thuận ban đầu. Đặc tả chi tiết bằng AsyncAPI sẽ chuyển sang Lab 03.

## 1. Thông tin dependency

- Dependency số: 7
- Producer: Camera Stream (A2/B2)
- Consumer: Analytics (A5/B5)
- Cơ chế: Queue async
- Event/topic dự kiến: camera.events.v1
- Người ghi: Võ Minh Quân
- Ngày: 18 tháng 5

## 2. Mục đích nghiệp vụ

Camera Stream phát event camera để Analytics aggregate motion, abnormal event và camera health.

## 3. Event name / topic

| Mục | Giá trị |
|---|---|
| Event name | camera.motion.detected, camera.frame.analyzed, camera.status.changed |
| Topic/queue | camera.events.v1 |
| Producer | camera-stream |
| Consumer | analytics |

## 4. Payload tối thiểu

```json
{
  "eventId": "uuid",
  "eventType": "camera.motion.detected",
  "occurredAt": "2026-05-10T08:30:00Z",
  "correlationId": "uuid",
  "sourceService": "camera-stream",
  "cameraId": "CAM-007",
  "detectionId": "uuid",
  "imageRef": "https://cdn.campus.local/camera/CAM-007/frame-001.jpg",
  "confidence": 0.92
}
```

Ghi chú:
- `camera.frame.analyzed` thêm `analysisSummary`.
- `camera.status.changed` thêm `status`, `reason`, `offlineSince`.

## 5. Ràng buộc cần thống nhất

| Vấn đề | Quyết định tạm thời |
|---|---|
| Event id có bắt buộc không? | Có |
| Có cần correlationId không? | Khuyến nghị có, nhưng không bắt buộc |
| Có cho phép gửi trùng event không? | Có thể, consumer phải idempotent theo `eventId` |
| Retry khi lỗi | At-least-once, chi tiết ở Lab 03 |
| Dead-letter queue | Ghi rõ ở Lab 03 |

## 6. Issue chuyển sang Lab 03

1. Quy ước ordering theo `cameraId`.
2. Chính sách retry/backoff và DLQ.
3. Schema registry/versioning cho event.
