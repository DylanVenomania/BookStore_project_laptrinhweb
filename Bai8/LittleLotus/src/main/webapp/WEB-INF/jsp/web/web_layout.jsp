<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Little Lotus Book Store</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        /* Styles for the footer links */
        .footer-link {
            text-decoration: none;
            color: #adb5bd;
            transition: color 0.3s;
        }
        .footer-link:hover {
            color: white;
        }
        
        /* Ensures the main content takes up remaining height to push footer to bottom */
        .min-vh-100 {
            min-height: 100vh;
        }
    </style>
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow">
        <div class="container">
            <a class="navbar-brand" href="/">Little Lotus Book Store</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="/">Trang Chủ</a>
                    </li>
                    <li class="nav-item">
                        <!-- Lưu ý: Trong môi trường production, bạn nên thay thế alert() bằng một modal hoặc thông báo không chặn -->
                        <a class="nav-link" href="#" onclick="alert('Tính năng Danh mục sẽ được triển khai chi tiết.'); return false;">Danh Mục</a>
                    </li>
                    <!-- Thêm các mục khác (Ví dụ: Giới thiệu, Liên hệ) -->
                </ul>
                <a href="/admin/product" class="btn btn-outline-warning me-2">Quản Trị Admin</a>
                <button class="btn btn-outline-info">Giỏ Hàng</button>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-grow-1">
        <div class="container my-5">
            <!-- Dynamic content will be loaded here -->
            <jsp:include page="${contentPage}" />
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-dark text-white-50 mt-auto py-4">
        <div class="container">
            <div class="row">
                <div class="col-md-4 mb-3 mb-md-0">
                    <h5>Về chúng tôi</h5>
                    <p>Little Lotus chuyên cung cấp các đầu sách chất lượng cao về khoa học, công nghệ và văn học.</p>
                </div>
                <div class="col-md-4 mb-3 mb-md-0">
                    <h5>Liên kết</h5>
                    <ul class="list-unstyled">
                        <li><a href="#" class="footer-link">Chính sách bảo mật</a></li>
                        <li><a href="#" class="footer-link">Điều khoản dịch vụ</a></li>
                        <li><a href="#" class="footer-link">Liên hệ</a></li>
                    </ul>
                </div>
                <div class="col-md-4">
                    <h5>Thông tin</h5>
                    <p class="mb-1"><i class="fas fa-map-marker-alt me-2"></i>Địa chỉ: HCMUTE, TP.HCM</p>
                    <p class="mb-1"><i class="fas fa-envelope me-2"></i>Email: contact@littlelotus.com</p>
                </div>
            </div>
            <div class="text-center pt-3 border-top border-secondary mt-4">
                © 2025 Little Lotus Book Store. All rights reserved.
            </div>
        </div>
    </footer>
    
    <!-- Font Awesome (for icons in footer) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

</body>
</html>
