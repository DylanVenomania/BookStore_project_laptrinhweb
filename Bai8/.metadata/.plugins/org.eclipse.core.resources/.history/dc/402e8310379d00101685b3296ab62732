package com.littlelotus.input;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;


public class InputRecords {
    
    public record UserInput(
            Long id,
            @NotBlank(message = "Họ tên không được để trống") String fullname,
            @Email(message = "Email không hợp lệ") @NotBlank(message = "Email không được để trống") String email,
            @NotBlank(message = "Mật khẩu không được để trống") String password,
            @Pattern(regexp = "^\\d{10,11}$", message = "Số điện thoại không hợp lệ") String phone
    ) {}

    public record ProductInput(
            Long id,
            @NotBlank(message = "Tiêu đề không được để trống") String title,
            @NotNull(message = "Số lượng không được để trống") @PositiveOrZero(message = "Số lượng phải lớn hơn hoặc bằng 0") Integer quantity,
            String description,
            @NotNull(message = "Giá không được để trống") @DecimalMin(value = "0.0", inclusive = false, message = "Giá phải lớn hơn 0") BigDecimal price,
            @NotNull(message = "UserID không được để trống") Long userId,
            @NotNull(message = "CategoryID không được để trống") Long categoryId
    ) {}

    public record CategoryInput(
            Long id,
            @NotBlank(message = "Tên danh mục không được để trống") String name,
            String images
    ) {}
}