import express from "express";
import {
    createDepartmentService,
    deleteDepartmentService,
    getUsersByDepartmentService,
    updateDepartmentService
} from "../services/derpartment.service";

const router = express.Router();

router.post("/create", async (req, res) => {
    try {
        const result = await createDepartmentService(req.body);

        return res.status(200).json({
            message: "Create department success",
            data: result,
        });
    } catch (error: any) {
        return res.status(400).json({
            message: error.message,
        });
    }
});


//get all user in department
router.get("/:id/users", async (req, res) => {
    try {
        const result = await getUsersByDepartmentService(req.params.id);

        return res.status(200).json({
            message: "Get users by department success",
            data: result,
        });
    } catch (error: any) {
        return res.status(400).json({
            message: error.message,
        });
    }
});

//rename department
router.patch("/:id", async (req, res) => {
    try {
        const result = await updateDepartmentService(
            req.params.id,
            req.body
        );

        return res.status(200).json({
            message: "Update department success",
            data: result,
        });
    } catch (error: any) {
        return res.status(400).json({
            message: error.message,
        });
    }
});

router.delete("/:id", async (req, res) => {
    try {
        const result = await deleteDepartmentService(req.params.id);

        return res.status(200).json({
            message: result.message,
            data: result,
        });
    } catch (error: any) {
        return res.status(400).json({
            message: error.message,
        });
    }
});

export default router;