import express from "express";
import {
    createLeaveType,
    getLeaveTypes,
} from "../../services/OnLeave/LeaveType.service";

const router = express.Router();

router.post("/create", async (req, res) => {
  try {
    const result = await createLeaveType(req.body);
    return res.status(200).json({
      message: "create leave type success",
      data: result,
    });
  } catch (error: any) {
    return res.status(400).json({
      message: error.message,
    });
  }
});
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

export default router;
