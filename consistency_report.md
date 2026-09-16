# Báo Cáo Chẩn Đoán Đồ Thị Nghiệp Vụ (Gap Analysis) - HealthSync

Bản thiết kế cơ sở dữ liệu cũ (Legacy Schema) tồn tại **3 điểm "vênh" nghiêm trọng** so với Activity Diagram của BA:

1. **Thiếu khả năng biểu diễn vòng đời lịch hẹn**: Việc sử dụng kiểu dữ liệu `BOOLEAN` (`is_active`) chỉ lưu được 2 trạng thái (Đúng/Sai). Điều này làm mất đi khả năng theo dõi tiến trình 5 bước nghiệp vụ bắt buộc (`PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` -> `CANCELLED`).
2. **Thất thoát dữ liệu tài chính và quản lý hủy lịch**: CSDL hoàn toàn thiếu các trường lưu trữ tài chính (`deposit_amount`, `penalty_fee`) và lý do hủy (`cancel_reason`). Khi bệnh nhân hủy lịch sau bước `CONFIRMED`, hệ thống không có nơi để tính toán phí phạt hay đối soát doanh thu tiền cọc với bộ phận kế toán.
3. **Thiếu hụt thực thể Đơn thuốc (`Prescriptions`)**: Nghiệp vụ quy định khi khám xong (`COMPLETED`), bác sĩ phải xuất đơn thuốc. Việc thiếu hẳn bảng này khiến luồng khám chữa bệnh bị đứt gãy hoàn toàn ở giai đoạn cuối.

**Giải pháp**: Thiết kế lại bảng `Appointments` bằng `ENUM`, bổ sung kiểu `DECIMAL` cho tài chính, tạo bảng `Prescriptions` và thiết lập Trigger ràng buộc ở tầng Database.