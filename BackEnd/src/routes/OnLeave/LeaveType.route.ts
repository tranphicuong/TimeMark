import express from "express";
import {
  getLeaveTypeById,
  getLeaveTypes,
} from "../../services/OnLeave/LeaveType.service";

const router = express.Router();

router.get("/", async (_req, res) => {
  try {
    const result = await getLeaveTypes();
    return res.status(200).json({
      message: "get leave types success",
      data: result,
    });
  } catch (error: any) {
    return res.status(400).json({
      message: error.message,
    });
  }
});
router.get("/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await getLeaveTypeById(id);
    return res.status(200).json({
      message: "get leave type success",
      data: result,
    });
  } catch (error: any) {
    return res.status(400).json({
      message: error.message,
    });
  }
});

export default router;
