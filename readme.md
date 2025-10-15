# Memory Match Game

Dự án Memory Match Game bao gồm backend (Node.js với Express và MongoDB) và frontend (Flutter).

## Yêu cầu hệ thống

-   Node.js (phiên bản 16 trở lên)
-   MongoDB (có thể sử dụng MongoDB Atlas hoặc cài đặt local)
-   Flutter SDK (phiên bản 3.9.2 trở lên)
-   Dart SDK (đi kèm với Flutter)

## Setup Backend

1. Di chuyển vào thư mục backend:

    ```
    cd backend
    ```

2. Cài đặt dependencies:

    ```
    npm install
    ```

3. Tạo file `.env` trong thư mục backend với nội dung sau (thay đổi giá trị theo nhu cầu):

    ```
    PORT=3000
    MONGODB_URI=mongodb://localhost:27017/memory_match_game
    JWT_SECRET=your_jwt_secret
    EMAIL_USER=your_email@gmail.com
    EMAIL_PASS=your_email_password
    ```

4. Khởi động MongoDB (nếu sử dụng local).

5. Chạy server:
    ```
    node app.js
    ```

Backend sẽ chạy trên `http://localhost:3001`.

## Setup Frontend

1. Di chuyển vào thư mục frontend:

    ```
    cd frontend
    ```

2. Cài đặt dependencies:

    ```
    flutter pub get
    ```

3. Chạy ứng dụng:
    ```
    flutter run
    ```

Ứng dụng Flutter sẽ chạy trên thiết bị hoặc emulator.

## Chạy dự án

-   Backend: Đảm bảo MongoDB đang chạy, sau đó `node app.js` trong thư mục backend.
-   Frontend: `flutter run` trong thư mục frontend.

Đảm bảo backend đang chạy trước khi chạy frontend để kết nối API.
