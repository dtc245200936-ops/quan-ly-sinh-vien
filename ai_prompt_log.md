# Nhật Ký Sử Dụng AI (AI Prompt Log) - Dự Án HealthSync

### Prompt 1: Tìm hiểu về Anti-pattern của trạng thái Boolean
* **Prompt**: "Trong thiết kế cơ sở dữ liệu quan hệ, tại sao việc dùng một cột `is_active` (kiểu TINYINT/BOOLEAN) để theo dõi vòng đời của một Đơn hàng/Lịch hẹn lại là một thiết kế tồi (Anti-pattern)? Tôi nên thay thế bằng cấu trúc nào?"
* **Kết quả ứng dụng**: Hiểu rõ tác hại của việc dùng Boolean cho quy trình đa trạng thái và quyết định chuyển sang sử dụng kiểu dữ liệu `ENUM` với 5 trạng thái định sẵn.

### Prompt 2: Lựa chọn kiểu dữ liệu tài chính
* **Prompt**: "Khi thiết kế cột `deposit_amount` và `penalty_fee` trong MySQL phục vụ tính toán tài chính, tôi nên dùng kiểu dữ liệu FLOAT, DOUBLE hay DECIMAL? Tại sao?"
* **Kết quả ứng dụng**: Tránh được rủi ro sai số làm tròn (float precision error) trong tính toán tài chính bằng cách chọn `DECIMAL(10, 2)`.

### Prompt 3: Đảm bảo toàn vẹn dữ liệu bằng Trigger
* **Prompt**: "Hãy cho tôi cú pháp tạo Trigger trong MySQL để ngăn chặn việc chèn bản ghi vào bảng Prescriptions nếu status của bảng Appointments chưa phải là COMPLETED."
* **Kết quả ứng dụng**: Viết thành công `BEFORE INSERT TRIGGER` để bảo đảm tính toàn vẹn nghiệp vụ ngay tại tầng Database.
