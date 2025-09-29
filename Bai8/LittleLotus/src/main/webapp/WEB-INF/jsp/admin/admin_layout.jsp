<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Admin Dashboard</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        /* Variables for layout control */
        :root {
            --sidebar-width: 220px;
            --navbar-height: 56px;
        }

        /* Sidebar positioning and styling */
        .sidebar {
            position: fixed;
            top: var(--navbar-height); /* Start below the fixed navbar */
            bottom: 0;
            left: 0;
            z-index: 1000;
            padding: 0;
            box-shadow: inset -1px 0 0 rgba(0, 0, 0, .1);
            overflow-y: auto;
            transition: all 0.3s;
        }

        /* Ensure content is pushed over for desktop view (>=md) */
        @media (min-width: 768px) {
            .content-wrapper {
                margin-left: var(--sidebar-width);
                padding-top: calc(var(--navbar-height) + 1.5rem) !important; /* Push content down */
            }
            .sidebar {
                width: var(--sidebar-width);
            }
        }

        /* Adjust content padding for mobile view (<md) */
        @media (max-width: 767.98px) {
            .content-wrapper {
                padding-top: calc(var(--navbar-height) + 1.5rem) !important;
            }
        }

        /* Custom active link style */
        .sidebar .nav-link {
            font-weight: 500;
            color: #333;
            padding: 0.75rem 1rem;
        }

        .sidebar .nav-link.active {
            color: #0d6efd;
            background-color: #f0f3ff;
            border-right: 3px solid #0d6efd;
        }
    </style>
</head>
<body class="bg-light">

    <!-- Fixed Top Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top shadow">
        <div class="container-fluid">
            <!-- Toggler for mobile sidebar (optional, but good practice) -->
            <button class="navbar-toggler d-md-none me-2" type="button" data-bs-toggle="collapse" data-bs-target="#sidebarMenu" aria-controls="sidebarMenu" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <a class="navbar-brand" href="/admin/product">Little Lotus ADMIN</a>
            <div class="d-flex ms-auto">
                 <a href="/" class="btn btn-outline-light btn-sm me-2">Xem trang bán hàng</a>
                 <button class="btn btn-outline-danger btn-sm">Đăng xuất</button>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">

            <!-- Sidebar -->
            <nav id="sidebarMenu" class="col-md-3 col-lg-2 d-md-block bg-white sidebar collapse">
                <div class="position-sticky pt-3 sidebar-sticky">
                    <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted text-uppercase">
                        <span>Quản lý</span>
                    </h6>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link <c:if test='${pageName == "product"}'>active</c:if>" href="/admin/product">
                                <i class="fas fa-box me-2"></i> Quản lý Sản Phẩm
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link <c:if test='${pageName == "category"}'>active</c:if>" href="/admin/category">
                                <i class="fas fa-tags me-2"></i> Quản lý Danh Mục
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link <c:if test='${pageName == "user"}'>active</c:if>" href="/admin/user">
                                <i class="fas fa-users me-2"></i> Quản lý Người Dùng
                            </a>
                        </li>
                        <!-- Add other management links here (e.g., Orders) -->
                    </ul>
                </div>
            </nav>

            <!-- Main Content Area -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 content-wrapper">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">${pageTitle}</h1>
                </div>

                <div class="mb-5">
                    <!-- Dynamic content will be loaded here -->
                    <jsp:include page="${contentPage}" />
                </div>

            </main>
        </div>
    </div>
    
    <!-- Font Awesome (for icons in sidebar) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

</body>
</html>
