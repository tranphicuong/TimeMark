import express from "express";
import {
  createDepartmentService,
  deleteDepartmentService,
  getAllDepartmentsService,
  getUsersByDepartmentService,
  updateDepartmentService,
} from "../../services/Department/derpartment.service";

const router = express.Router();
//create department
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

//edit department
router.patch("/:id", async (req, res) => {
  try {
    const result = await updateDepartmentService(req.params.id, req.body);

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
//remove department
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

//lay tat ca cac phong phong ban
router.get("/", async (req, res) => {
  try {
    const result = await getAllDepartmentsService();
    return res.status(200).json({
      message: "Get all departments success",
      data: result,
    });
  } catch (error: any) {
    return res.status(400).json({
      message: error.message,
    });
  }
});
export default router;
