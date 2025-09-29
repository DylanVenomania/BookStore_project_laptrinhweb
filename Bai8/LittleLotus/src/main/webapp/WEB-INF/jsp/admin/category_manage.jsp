<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="container my-5">
    <div id="alert-container" class="mb-3"></div>

    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-primary text-white" id="form-header">Thêm Danh Mục Mới</div>
        <div class="card-body">
            <form id="categoryForm">
                <input type="hidden" id="categoryId" name="categoryId" value=""> 
                <div class="row">
                    <div class="mb-3 col-md-6">
                        <label for="name" class="form-label">Tên Danh Mục</label>
                        <input type="text" class="form-control" id="name" name="name" required>
                    </div>
                    <div class="mb-3 col-md-6">
                        <label for="images" class="form-label">URL Hình Ảnh (Tùy chọn)</label>
                        <input type="text" class="form-control" id="images" name="images">
                    </div>
                </div>
                <button type="submit" class="btn btn-success mt-2" id="submit-btn">Thêm Danh Mục</button>
                <button type="button" class="btn btn-secondary mt-2 d-none" id="cancel-edit-btn">Hủy Bỏ</button>
            </form>
        </div>
    </div>
    
    <div class="card shadow-sm">
        <div class="card-header bg-secondary text-white">Danh Sách Danh Mục</div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped" id="categoryTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Danh Mục</th>
                            <th>Hình Ảnh (URL)</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Dữ liệu được tải bằng AJAX -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript cho AJAX và GraphQL -->
<script type="text/javascript">
    // Lấy contextPath để định tuyến API
    const contextPath = '${pageContext.request.contextPath}';

    // Hàm hiển thị thông báo
    function showNotification(message, type) {
        const alertHtml = `
            <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        `;
        $('#alert-container').html(alertHtml);
    }

    // --- XỬ LÝ TẢI DỮ LIỆU ---
    function fetchAllCategories() {
        const query = `
            query {
                allCategories {
                    id, name, images
                }
            }
        `;

        $.ajax({
            url: contextPath + '/graphql',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ query: query }),
            success: function(response) {
                const categories = response.data?.allCategories || [];
                const $tableBody = $('#categoryTable tbody');
                $tableBody.empty(); // Xóa nội dung cũ

                if (categories.length === 0) {
                    $tableBody.append('<tr><td colspan="4" class="text-center">Không có danh mục nào.</td></tr>');
                    return;
                }

                categories.forEach(c => {
                    const row = `
                        <tr>
                            <td>${c.id}</td>
                            <td>${c.name}</td>
                            <td>${c.images || '<span class="text-muted">N/A</span>'}</td>
                            <td>
                                <button class="btn btn-sm btn-warning edit-btn me-2" data-category='${JSON.stringify(c)}'>
                                    <i class="fas fa-edit"></i> Sửa
                                </button>
                                <button class="btn btn-sm btn-danger delete-btn" data-id="${c.id}">
                                    <i class="fas fa-trash"></i> Xóa
                                </button>
                            </td>
                        </tr>
                    `;
                    $tableBody.append(row);
                });
            },
            error: function(xhr) {
                showNotification('Lỗi khi tải dữ liệu danh mục. Kiểm tra console.', 'danger');
                console.error("Lỗi AJAX khi tải danh mục:", xhr.responseText);
            }
        });
    }

    // --- XỬ LÝ THÊM/SỬA (CREATE/UPDATE) ---
    $("#categoryForm").submit(function(e) {
        e.preventDefault();

        // 1. Xác định chế độ (Thêm/Sửa)
        const categoryIdVal = $('#categoryId').val();
        const isEdit = categoryIdVal !== '';
        
        // Chuyển đổi ID thành số (dùng cho update).
        const id = isEdit ? Number(categoryIdVal) : null; 
        
        const mutationName = isEdit ? 'updateCategory' : 'createCategory';
        
        // 2. Chuẩn bị biến input cho GraphQL
        let inputData = {
            name: $('#name').val(),
            images: $('#images').val() || null, // Dùng null nếu rỗng
        };

        // Quan trọng: Chỉ thêm ID vào input data nếu đang ở chế độ sửa
        if (isEdit && id) {
             inputData.id = id; 
        } else if (isEdit && !id) {
             // Thêm kiểm tra ID null/NaN trong chế độ sửa
             showNotification('Lỗi: ID không hợp lệ cho thao tác cập nhật.', 'danger');
             return;
        }
        
        // 3. Chuẩn bị GraphQL Query
        const query = `
            mutation ${mutationName}($input: CategoryInput!) {
                ${mutationName}(input: $input) {
                    id, name, images
                }
            }
        `;
        
        // 4. Gửi AJAX
        $.ajax({
            url: contextPath + '/graphql',
            type: 'POST', // GraphQL luôn là POST
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                query: query,
                variables: { input: inputData }
            }),
            success: function(response) {
                if (response.errors) {
                    const error = response.errors[0];
                    let validationMessage = '';
                    if (error.extensions && error.extensions.validationErrors) {
                        // Xử lý lỗi validation từ GraphQL (nếu có)
                        validationMessage = error.extensions.validationErrors.map(e => e.message).join('<br>');
                    }
                    showNotification(`Thao tác ${isEdit ? 'cập nhật' : 'thêm'} danh mục thất bại. ${validationMessage || error.message}`, 'danger');
                    console.error("Lỗi GraphQL:", response.errors);
                    return;
                }
                
                showNotification(`Đã ${isEdit ? 'cập nhật' : 'thêm mới'} danh mục thành công.`, 'success');
                resetFormState();
                fetchAllCategories(); // Tải lại dữ liệu
            },
            error: function(xhr) {
                showNotification(`Lỗi khi ${isEdit ? 'cập nhật' : 'thêm'} danh mục. Kiểm tra console.`, 'danger');
                console.error("Lỗi AJAX:", xhr.responseText);
            }
        });
    });

    // --- XỬ LÝ XÓA (DELETE) ---
    $(document).on('click', '.delete-btn', function() {
        if (!confirm('Bạn có chắc chắn muốn xóa danh mục này?')) {
            return;
        }

        const categoryId = $(this).data('id');
        
        // KIỂM TRA ID: Đảm bảo ID không phải là null hoặc undefined
        if (!categoryId) {
            showNotification('Lỗi: Không tìm thấy ID danh mục để xóa.', 'danger');
            console.error('Lỗi: categoryId không hợp lệ (null/undefined).');
            return; // Ngừng thực hiện nếu ID không hợp lệ
        }

        const query = `
            mutation deleteCategory($id: ID!) {
                deleteCategory(id: $id)
            }
        `;

        $.ajax({
            url: contextPath + '/graphql',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                query: query,
                variables: { id: categoryId }
            }),
            success: function(response) {
                const result = response.data?.deleteCategory;
                if (result === true) {
                    showNotification('Đã xóa danh mục thành công.', 'success');
                    // Xóa dòng khỏi bảng ngay lập tức
                    $(`button[data-id="${categoryId}"]`).closest('tr').fadeOut(300, function() {
                        $(this).remove();
                        fetchAllCategories(); // Tải lại dữ liệu sau khi xóa
                    });
                } else {
                    showNotification(`Không tìm thấy hoặc không thể xóa danh mục ID: ${categoryId}.`, 'warning');
                }
            },
            error: function(xhr) {
                showNotification('Lỗi khi xóa danh mục. Kiểm tra console.', 'danger');
                console.error("Lỗi AJAX khi xóa danh mục:", xhr.responseText);
            }
        });
    });

    // --- XỬ LÝ SỬA (EDIT) ---
    $(document).on('click', '.edit-btn', function() {
        const categoryData = $(this).data('category');
        
        $('#categoryId').val(categoryData.id);
        $('#name').val(categoryData.name);
        $('#images').val(categoryData.images);
        
        $('#form-header').text('Cập Nhật Danh Mục (ID: ' + categoryData.id + ')');
        $('#submit-btn').text('Cập Nhật Danh Mục').removeClass('btn-success').addClass('btn-warning');
        $('#cancel-edit-btn').removeClass('d-none');
        
        $('html, body').animate({ scrollTop: 0 }, 500);
    });

    // --- RESET TRẠNG THÁI FORM ---\
    $('#cancel-edit-btn').click(function() { resetFormState(); });
    function resetFormState() {
        $('#categoryForm')[0].reset();
        $('#categoryId').val('');
        $('#form-header').text('Thêm Danh Mục Mới');
        $('#submit-btn').text('Thêm Danh Mục').removeClass('btn-warning').addClass('btn-success');
        $('#cancel-edit-btn').addClass('d-none');
        $('#alert-container').empty(); // Xóa thông báo
    }
    
    // --- KHỞI TẠO ---
    $(function() {
        fetchAllCategories();
    });

</script>
<!-- Đảm bảo thư viện Font Awesome đã được include trong admin_layout.jsp -->
