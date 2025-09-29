<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="container my-5">
    <div id="alert-container" class="mb-3"></div>

    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-primary text-white" id="form-header">Thêm Người Dùng Mới</div>
        <div class="card-body">
            <form id="userForm">
                <input type="hidden" id="userId" name="userId" value=""> 
                <div class="row">
                    <div class="mb-3 col-md-6">
                        <label for="fullname" class="form-label">Họ và Tên</label>
                        <input type="text" class="form-control" id="fullname" name="fullname" required>
                    </div>
                    <div class="mb-3 col-md-6">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="email" name="email" required>
                    </div>
                    <div class="mb-3 col-md-6">
                        <label for="password" class="form-label">Mật khẩu</label>
                        <input type="password" class="form-control" id="password" name="password" required>
                    </div>
                    <div class="mb-3 col-md-6">
                        <label for="phone" class="form-label">Số Điện Thoại (Tùy chọn)</label>
                        <input type="text" class="form-control" id="phone" name="phone">
                    </div>
                </div>
                <button type="submit" class="btn btn-success mt-2" id="submit-btn">Thêm Người Dùng</button>
                <button type="button" class="btn btn-secondary mt-2 d-none" id="cancel-edit-btn">Hủy Bỏ</button>
            </form>
        </div>
    </div>
    
    <div class="card shadow-sm">
        <div class="card-header bg-secondary text-white">Danh Sách Người Dùng</div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped" id="userTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Họ và Tên</th>
                            <th>Email</th>
                            <th>SĐT</th>
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
    
    // --- XỬ LÝ TẢI DỮ LIỆU ---
    function fetchAllUsers() {
        const query = `
            query {
                allUsers {
                    id, fullname, email, phone
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
                const users = response.data?.allUsers || [];
                const $tableBody = $('#userTable tbody');
                $tableBody.empty(); // Xóa nội dung cũ

                if (users.length === 0) {
                    $tableBody.append('<tr><td colspan="5" class="text-center">Không có người dùng nào.</td></tr>');
                    return;
                }

                users.forEach(u => {
                    const row = `
                        <tr>
                            <td>${u.id}</td>
                            <td>${u.fullname}</td>
                            <td>${u.email}</td>
                            <td>${u.phone || '<span class="text-muted">N/A</span>'}</td>
                            <td>
                                <button class="btn btn-sm btn-warning edit-btn me-2" data-user='${JSON.stringify(u)}'>
                                    <i class="fas fa-edit"></i> Sửa
                                </button>
                                <button class="btn btn-sm btn-danger delete-btn" data-id="${u.id}">
                                    <i class="fas fa-trash"></i> Xóa
                                </button>
                            </td>
                        </tr>
                    `;
                    $tableBody.append(row);
                });
            },
            error: function(xhr) {
                showNotification('Lỗi khi tải dữ liệu người dùng. Kiểm tra console.', 'danger');
                console.error("Lỗi AJAX khi tải người dùng:", xhr.responseText);
            }
        });
    }

    // --- XỬ LÝ THÊM/SỬA (CREATE/UPDATE) ---
    $("#userForm").submit(function(e) {
        e.preventDefault();

        // 1. Xác định chế độ (Thêm/Sửa)
        const userIdVal = $('#userId').val();
        const isEdit = userIdVal !== '';
        
        const id = isEdit ? Number(userIdVal) : null; 
        
        const mutationName = isEdit ? 'updateUser' : 'createUser';
        
        // 2. Chuẩn bị biến input cho GraphQL
        let inputData = {
            fullname: $('#fullname').val(),
            email: $('#email').val(),
            password: $('#password').val(),
            phone: $('#phone').val() || null // Dùng null nếu rỗng
        };

        // Quan trọng: Chỉ thêm ID vào input data nếu đang ở chế độ sửa
        if (isEdit && id) {
             inputData.id = id; 
             // Khi sửa, nếu password rỗng thì không gửi password để tránh override.
             // (Giả định service sẽ bảo lưu mật khẩu cũ nếu không có password mới)
             if (!inputData.password) {
                delete inputData.password;
             }
        } else if (isEdit && !id) {
             showNotification('Lỗi: ID không hợp lệ cho thao tác cập nhật.', 'danger');
             return;
        }

        // 3. Chuẩn bị GraphQL Query
        const query = `
            mutation ${mutationName}($input: UserInput!) {
                ${mutationName}(input: $input) {
                    id, fullname, email, phone
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
                    showNotification(`Thao tác ${isEdit ? 'cập nhật' : 'thêm'} người dùng thất bại. ${validationMessage || error.message}`, 'danger');
                    console.error("Lỗi GraphQL:", response.errors);
                    return;
                }
                
                showNotification(`Đã ${isEdit ? 'cập nhật' : 'thêm mới'} người dùng thành công.`, 'success');
                resetFormState();
                fetchAllUsers(); // Tải lại dữ liệu
            },
            error: function(xhr) {
                showNotification(`Lỗi khi ${isEdit ? 'cập nhật' : 'thêm'} người dùng. Kiểm tra console.`, 'danger');
                console.error("Lỗi AJAX:", xhr.responseText);
            }
        });
    });

    // --- XỬ LÝ XÓA (DELETE) ---
    $(document).on('click', '.delete-btn', function() {
        if (!confirm('Bạn có chắc chắn muốn xóa người dùng này?')) {
            return;
        }

        const userId = $(this).data('id');
        
        // KIỂM TRA ID: Đảm bảo ID không phải là null hoặc undefined
        if (!userId) {
            showNotification('Lỗi: Không tìm thấy ID người dùng để xóa.', 'danger');
            console.error('Lỗi: userId không hợp lệ (null/undefined).');
            return; // Ngừng thực hiện nếu ID không hợp lệ
        }

        const query = `
            mutation deleteUser($id: ID!) {
                deleteUser(id: $id)
            }
        `;

        $.ajax({
            url: contextPath + '/graphql',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                query: query,
                variables: { id: userId }
            }),
            success: function(response) {
                const result = response.data?.deleteUser;
                if (result === true) {
                    showNotification('Đã xóa người dùng thành công.', 'success');
                    $(`button[data-id="${userId}"]`).closest('tr').fadeOut(300, function() {
                        $(this).remove();
                        fetchAllUsers(); // Tải lại dữ liệu sau khi xóa
                    });
                } else {
                    showNotification(`Không tìm thấy hoặc không thể xóa người dùng ID: ${userId}.`, 'warning');
                }
            },
            error: function(xhr) {
                showNotification('Lỗi khi xóa người dùng. Kiểm tra console.', 'danger');
                console.error("Lỗi AJAX khi xóa người dùng:", xhr.responseText);
            }
        });
    });

    // --- XỬ LÝ SỬA (EDIT) ---
    $(document).on('click', '.edit-btn', function() {
        const userData = $(this).data('user');
        
        $('#userId').val(userData.id);
        $('#fullname').val(userData.fullname);
        $('#email').val(userData.email);
        $('#phone').val(userData.phone);
        
        // Mật khẩu không bắt buộc khi sửa
        // Đặt giá trị rỗng và xóa required. Service sẽ dùng mật khẩu cũ nếu giá trị rỗng.
        $('#password').val('').removeAttr('required').attr('placeholder', 'Nhập mật khẩu mới (Nếu cần)');
        
        $('#form-header').text('Cập Nhật Người Dùng (ID: ' + userData.id + ')');
        $('#submit-btn').text('Cập Nhật Người Dùng').removeClass('btn-success').addClass('btn-warning');
        $('#cancel-edit-btn').removeClass('d-none');
        
        $('html, body').animate({ scrollTop: 0 }, 500);
    });

    // --- RESET TRẠNG THÁI FORM ---
    $('#cancel-edit-btn').click(function() { resetFormState(); });
    function resetFormState() {
        $('#userForm')[0].reset();
        $('#userId').val('');
        $('#form-header').text('Thêm Người Dùng Mới');
        // Đặt lại 'required' khi thêm mới
        $('#password').val('').attr('required', true).removeAttr('placeholder'); 
        $('#submit-btn').text('Thêm Người Dùng').removeClass('btn-warning').addClass('btn-success');
        $('#cancel-edit-btn').addClass('d-none');
        $('#alert-container').empty(); // Xóa thông báo
    }
    
    // --- KHỞI TẠO ---
    $(function() {
        fetchAllUsers();
    });
</script>
