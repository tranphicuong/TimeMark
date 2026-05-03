import { Router } from "express";
import {
  approveLeave,
  getLeaveRequestByStatus,
} from "../../services/OnLeave/LeaveRequest.service";
import { getAllLeaveRequestHistory } from "../../services/OnLeave/LeaveRequestHistory";

const router = Router();

/**
 * GET list by status
 * ví dụ:
 * /leave-request?status=pending
 * /leave-request?status=approved
 */
router.get("/history", async (req, res) => {
  try {
    const data = await getAllLeaveRequestHistory();
    return res.status(200).json({
      success: true,
      data,
    });
  } catch (err: any) {
    console.error("get leave request history error:", err);
    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});
router.get("/", async (req, res) => {
  try {
    const { status } = req.query;

    if (!status || typeof status !== "string") {
      return res.status(400).json({
        success: false,
        message: "status is required",
      });
    }

    const data = await getLeaveRequestByStatus(status);

    return res.status(200).json({
      success: true,
      data,
    });
  } catch (err: any) {
    console.error("get leave request error:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

/**
 * PATCH approve / reject / cancel
 */
router.patch("/:id/status", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await approveLeave(id, req.body);

    return res.status(200).json({
      success: true,
      message: "Update leave request successfully",
      data: result,
    });
  } catch (err: any) {
    console.error("update status error:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

export default router;
