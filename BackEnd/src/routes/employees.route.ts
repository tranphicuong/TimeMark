import express from "express";
import {
    createUserService,
    toggleUserStatusService,
    deleteUserService,
    getAllUsersService
} from "../services/employees.service";

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

        const result = await toggleUserStatusService(uid, isActive);

        res.json({
            message: "Status updated",
            data: result,
        });
    } catch (error: any) {
        res.status(400).json({
            message: error.message,
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

export default router;