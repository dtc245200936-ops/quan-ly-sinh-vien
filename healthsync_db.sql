-- ==========================================
-- BƯỚC 1: TẠO VÀ CẤU TRÚC LẠI CƠ SỞ DỮ LIỆU
-- ==========================================
CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- 1. Bảng Patients
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- 2. Bảng Doctors
CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- 3. Bảng Appointments (Đã tối ưu hóa nghiệp vụ)
CREATE TABLE IF NOT EXISTS Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    deposit_amount DECIMAL(10, 2) DEFAULT 0.00,
    penalty_fee DECIMAL(10, 2) DEFAULT 0.00,
    cancel_reason VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- 4. Bảng Prescriptions (Đơn thuốc)
CREATE TABLE IF NOT EXISTS Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE, -- Quan hệ 1-1 với Lịch hẹn
    medication_details TEXT NOT NULL,
    issued_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
);

-- ==========================================
-- BƯỚC 2: RÀNG BUỘC NGHIỆP VỤ (TRIGGER)
-- ==========================================
-- Chặn việc kê đơn thuốc khi lịch hẹn chưa chuyển sang COMPLETED
DELIMITER //
CREATE TRIGGER chk_prescription_status
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE app_status VARCHAR(20);
    SELECT status INTO app_status FROM Appointments WHERE appointment_id = NEW.appointment_id;
    IF app_status != 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Chỉ có thể kê đơn thuốc cho lịch hẹn đã hoàn thành (COMPLETED).';
    END IF;
END //
DELIMITER ;

-- ==========================================
-- BƯỚC 3: MÔ PHỎNG KỊCH BẢN DỮ LIỆU (DML)
-- ==========================================

-- Thêm dữ liệu mẫu ban đầu
INSERT INTO Patients (full_name, phone) VALUES 
('Nguyen Van A', '0901234567'),
('Tran Thi B', '0987654321');

INSERT INTO Doctors (full_name, specialty) VALUES 
('BS. Le Van C', 'Noi khoa'),
('BS. Pham Thi D', 'Nhi khoa');

-- --- KỊCH BẢN 1: TẠO LỊCH HẸN THÀNH CÔNG VÀ KÊ ĐƠN ---
-- 1. Đặt lịch hẹn ban đầu (PENDING, cọc 500,000)
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-09-20 09:00:00', 'PENDING', 500000.00);

-- 2. Bệnh nhân đến phòng khám (CHECKED_IN)
UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = 1;

-- 3. Khám xong (COMPLETED)
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = 1;

-- 4. Bác sĩ kê đơn thuốc cho lịch hẹn 1
INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (1, 'Paracetamol 500mg x 10 viên, uống sau ăn sáng');


-- --- KỊCH BẢN 2: HỦY LỊCH VÀ PHẠT TIỀN CỌC ---
-- 1. Đặt lịch hẹn ban đầu (CONFIRMED, cọc 300,000)
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 2, '2026-09-21 14:00:00', 'CONFIRMED', 300000.00);

-- 2. Bệnh nhân báo hủy, hệ thống ghi nhận lý do và trừ phạt 150,000
UPDATE Appointments 
SET status = 'CANCELLED', 
    cancel_reason = 'Ban viec dot xuat', 
    penalty_fee = 150000.00 
WHERE appointment_id = 2;

-- ==========================================
-- BƯỚC 4: TRUY VẤN KIỂM TRA
-- ==========================================
-- Truy vấn danh sách bệnh nhân đã hoàn tất khám kèm thông tin đơn thuốc
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.status,
    a.deposit_amount,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';