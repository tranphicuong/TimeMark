import express from "express";
import {
    createUserService,
    deleteUserService,
    editUserService,
    getAllUserPlayOff,
    getAllUsersService,
    toggleUserStatusService,
} from "../../services/Employees/employees.service";

const router = express.Router();

// 🔹 admin tạo user
router.post("/create", async (req, res) => {
  try {
    const result = await createUserService(req.body);
    res.status(201).json({
      message: "User created",
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({
      message: error.message,
    });
  }
});

// 🔹 khóa / mở tài khoản
router.patch("/status/:uid", async (req, res) => {
  try {
    const { uid } = req.params;
    const { isActive } = req.body;

    // ✅ validate
    if (typeof isActive !== "boolean") {
      return res.status(400).json({
        message: "isActive must be boolean",
      });
    }

    const result = await toggleUserStatusService(uid, isActive);

    return res.status(200).json({
      message: "Update status success",
      data: result,
    });
  } catch (error: any) {
    console.error("ERROR toggle status:", error);

    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
});

// 🔹 xóa tài khoản (Auth only)
router.delete("/:uid", async (req, res) => {
  try {
    const { uid } = req.params;

    const result = await deleteUserService(uid);

    res.json({
      message: result.message,
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({
      message: error.message,
    });
  }
});
// 🔹 lấy tất cả nhân sự (trừ admin)
router.get("/", async (req, res) => {
  try {
    const users = await getAllUsersService();

    res.json({
      message: "Get all users success",
      data: users,
    });
  } catch (error: any) {
    res.status(400).json({
      message: error.message,
    });
  }
});
//lay tat ca nhan su da xoa
router.get("/playoff", async (req, res) => {
  try {
    const users = await getAllUserPlayOff();

    res.json({
      message: "Get all users success",
      data: users,
    });
  } catch (error: any) {
    res.status(400).json({
      message: error.message,
    });
  }
});
router.patch("/edit/:uid", async (req, res) => {
  try {
    const { uid } = req.params;
    const { id_position, id_department } = req.body;

    const result = await editUserService(uid, { id_position, id_department });

    res.json({
      message: "Edit user success",
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({
      message: error.message,
    });
  }
});
export default router;
