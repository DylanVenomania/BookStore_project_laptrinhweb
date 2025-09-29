<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="container my-5">
    <div id="alert-container" class="mb-3"></div>

    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-primary text-white" id="form-header">Thêm Sản Phẩm Mới</div>
        <div class="card-body">
            <form id="productForm">
                <input type="hidden" id="productId" name="productId" value=""> 
                
                <div class="row">
                    <div class="mb-3 col-md-6">
                        <label for="title" class="form-label">Tên Sách</label>
                        <input type="text" class="form-control" id="title" name="title" required>
                    </div>
                    <div class="mb-3 col-md-6">
                        <label for="category" class="form-label">Danh Mục</label>
                        <select class="form-select" id="category" name="category" required>
                            <option value="">-- Chọn Danh Mục --</option>
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="mb-3 col-md-4">
                        <label for="price" class="form-label">Giá (VND)</label>
                        <input type="number" class="form-control" id="price" name="price" min="0.01" step="0.01" required>
                    </div>
                    <div class="mb-3 col-md-4">
                        <label for="quantity" class="form-label">Số Lượng</label>
                        <input type="number" class="form-control" id="quantity" name="quantity" min="0" required>
                    </div>
                    <div class="mb-3 col-md-4">
                        <label for="user" class="form-label">Người Đăng</label>
                        <select class="form-select" id="user" name="user" required>
                            <option value="">-- Chọn Người Dùng --</option>
                        </select>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label for="images" class="form-label">URL Hình Ảnh (Tùy chọn)</label>
                    <input type="text" class="form-control" id="images" name="images">
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Mô Tả</label>
                    <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                </div>

                <button type="submit" class="btn btn-success mt-2" id="submit-btn">Thêm Sản Phẩm</button>
                <button type="button" class="btn btn-secondary mt-2 d-none" id="cancel-edit-btn">Hủy Bỏ</button>
            </form>
        </div>
    </div>
    
    <div class="card shadow-sm">
        <div class="card-header bg-secondary text-white">Danh Sách Sản Phẩm</div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped" id="productTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Sách</th>
                            <th>Giá</th>
                            <th>SL</th>
                            <th>Danh Mục</th>
                            <th>Người Đăng</th>
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
    const contextPath = '${pageContext.request.contextPath}';
    
    function showNotification(message, type) {
        const alertHtml = `
            <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        `;
        $('#alert-container').html(alertHtml);
    }
    
    // Hàm tải danh sách User và Category cho dropdown
    function fetchRelatedEntities() {
        const query = `
            query {
                allUsers { id, fullname }
                allCategories { id, name }
            }
        `;
        
        $.ajax({
            url: contextPath + '/graphql',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({ query: query }),
            success: function(response) {
                const users = response.data?.allUsers || [];
                const categories = response.data?.allCategories || [];
                
                const $userSelect = $('#user');
                $userSelect.find('option:not(:first)').remove(); // Giữ lại option mặc định
                users.forEach(u => {
                    $userSelect.append(`<option value="${u.id}">${u.fullname}</option>`);
                });
                
                const $categorySelect = $('#category');
                $categorySelect.find('option:not(:first)').remove();
                categories.forEach(c => {
                    $categorySelect.append(`<option value="${c.id}">${c.name}</option>`);
                });
            },
            error: function(xhr) {
                console.error("Lỗi khi tải dữ liệu liên quan:", xhr.responseText);
            }
        });
    }

    // --- XỬ LÝ TẢI DỮ LIỆU ---
    function fetchAllProducts() {
        const query = `
            query {
                allProducts {
                    id, title, price, quantity, images, description
                    user { id, fullname }
                    category { id, name }
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
                const products = response.data?.allProducts || [];
                const $tableBody = $('#productTable tbody');
                $tableBody.empty();

                if (products.length === 0) {
                    $tableBody.append('<tr><td colspan="7" class="text-center">Không có sản phẩm nào.</td></tr>');
                    return;
                }
                
                products.forEach(p => {
                    const priceFormatted = Number(p.price).toLocaleString('vi-VN');
                    // Tạo một đối tượng đơn giản hơn cho data-product để tránh lỗi JSON.stringify quá phức tạp
                    const productData = {
                        id: p.id,
                        title: p.title,
                        price: p.price,
                        quantity: p.quantity,
                        description: p.description,
                        images: p.images,
                        userId: p.user.id,
                        categoryId: p.category.id
                    };

                    const row = `
                        <tr>
                            <td>${p.id}</td>
                            <td>${p.title}</td>
                            <td>${priceFormatted} VND</td>
                            <td>${p.quantity}</td>
                            <td>${p.category.name}</td>
                            <td>${p.user.fullname}</td>
                            <td>
                                <button class="btn btn-sm btn-warning edit-btn me-2" data-product='${JSON.stringify(productData)}'>
                                    <i class="fas fa-edit"></i> Sửa
                                </button>
                                <button class="btn btn-sm btn-danger delete-btn" data-id="${p.id}">
                                    <i class="fas fa-trash"></i> Xóa
                                </button>
                            </td>
                        </tr>
                    `;
                    $tableBody.append(row);
                });
            },
            error: function(xhr) {
                showNotification('Lỗi khi tải dữ liệu sản phẩm. Kiểm tra console.', 'danger');
                console.error("Lỗi AJAX khi tải sản phẩm:", xhr.responseText);
            }
        });
    }
    
    // --- XỬ LÝ THÊM/SỬA (CREATE/UPDATE) ---
    $("#productForm").submit(function(e) {
        e.preventDefault();

        // 1. Xác định chế độ (Thêm/Sửa)
        const productIdVal = $('#productId').val();
        const isEdit = productIdVal !== '';
        
        const id = isEdit ? Number(productIdVal) : null; 
        
        const mutationName = isEdit ? 'updateProduct' : 'createProduct';
        
        // 2. Chuẩn bị biến input cho GraphQL
        let inputData = {
            title: $('#title').val(),
            price: Number($('#price').val()),
            quantity: Number($('#quantity').val()),
            description: $('#description').val(),
            images: $('#images').val() || null,
            userId: Number($('#user').val()), 
            categoryId: Number($('#category').val()) 
        };

        // Quan trọng: Chỉ thêm ID vào input data nếu đang ở chế độ sửa
        if (isEdit && id) {
             inputData.id = id; 
        } else if (isEdit && !id) {
             showNotification('Lỗi: ID không hợp lệ cho thao tác cập nhật.', 'danger');
             return;
        }

        // 3. Chuẩn bị GraphQL Query
        const query = `
            mutation ${mutationName}($input: ProductInput!) {
                ${mutationName}(input: $input) {
                    id, title, price
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
                        validationMessage = error.extensions.validationErrors.map(e => e.message).join('<br>');
                    }
                    showNotification(`Thao tác ${isEdit ? 'cập nhật' : 'thêm'} sản phẩm thất bại. ${validationMessage || error.message}`, 'danger');
                    console.error("Lỗi GraphQL:", response.errors);
                    return;
                }
                
                showNotification(`Đã ${isEdit ? 'cập nhật' : 'thêm mới'} sản phẩm thành công.`, 'success');
                resetFormState();
                fetchAllProducts(); // Tải lại dữ liệu
            },
            error: function(xhr) {
                showNotification(`Lỗi khi ${isEdit ? 'cập nhật' : 'thêm'} sản phẩm. Kiểm tra console.`, 'danger');
                console.error("Lỗi AJAX:", xhr.responseText);
            }
        });
    });

    // --- XỬ LÝ XÓA (DELETE) ---
    $(document).on('click', '.delete-btn', function() {
        if (!confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')) {
            return;
        }

        const productId = $(this).data('id');
        
        // KIỂM TRA ID: Đảm bảo ID không phải là null hoặc undefined
        if (!productId) {
            showNotification('Lỗi: Không tìm thấy ID sản phẩm để xóa.', 'danger');
            console.error('Lỗi: productId không hợp lệ (null/undefined).');
            return; // Ngừng thực hiện nếu ID không hợp lệ
        }

        const query = `
            mutation deleteProduct($id: ID!) {
                deleteProduct(id: $id)
            }
        `;

        $.ajax({
            url: contextPath + '/graphql',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                query: query,
                variables: { id: productId }
            }),
            success: function(response) {
                const result = response.data?.deleteProduct;
                if (result === true) {
                    showNotification('Đã xóa sản phẩm thành công.', 'success');
                    $(`button[data-id="${productId}"]`).closest('tr').fadeOut(300, function() {
                        $(this).remove();
                        fetchAllProducts(); // Tải lại dữ liệu sau khi xóa
                    });
                } else {
                    showNotification(`Không tìm thấy hoặc không thể xóa sản phẩm ID: ${productId}.`, 'warning');
                }
            },
            error: function(xhr) {
                showNotification('Lỗi khi xóa sản phẩm. Kiểm tra console.', 'danger');
                console.error("Lỗi AJAX khi xóa sản phẩm:", xhr.responseText);
            }
        });
    });

    // --- XỬ LÝ SỬA (EDIT) ---
    $(document).on('click', '.edit-btn', function() {
        const p = $(this).data('product');
        
        $('#productId').val(p.id);
        $('#title').val(p.title);
        $('#price').val(p.price);
        $('#quantity').val(p.quantity);
        $('#description').val(p.description);
        $('#images').val(p.images);
        
        // Đặt giá trị cho select box
        $('#category').val(p.categoryId);
        $('#user').val(p.userId);
        
        $('#form-header').text('Cập Nhật Sản Phẩm (ID: ' + p.id + ')');
        $('#submit-btn').text('Cập Nhật Sản Phẩm').removeClass('btn-success').addClass('btn-warning');
        $('#cancel-edit-btn').removeClass('d-none');
        
        $('html, body').animate({ scrollTop: 0 }, 500);
    });

    // --- RESET TRẠNG THÁI FORM ---
    $('#cancel-edit-btn').click(function() { resetFormState(); });
    function resetFormState() {
        $('#productForm')[0].reset();
        $('#productId').val('');
        $('#form-header').text('Thêm Sản Phẩm Mới');
        $('#submit-btn').text('Thêm Sản Phẩm').removeClass('btn-warning').addClass('btn-success');
        $('#cancel-edit-btn').addClass('d-none');
        $('#alert-container').empty(); // Xóa thông báo
    }
    
    // --- KHỞI TẠO ---
    $(function() {
        fetchRelatedEntities();
        fetchAllProducts();
    });

</script>
