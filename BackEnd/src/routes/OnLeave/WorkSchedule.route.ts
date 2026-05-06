import express from "express";
import { getWorkSchedule } from "../../services/OnLeave/WorkSchedule.service";

const router = express.Router();

//lây dữ liệu giờ làm
router.get("/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await getWorkSchedule(id);
    return res.status(200).json({
      message: "get office success",
      data: result,
    });
  } catch (error: any) {
    return res.status(400).json({
      message: error.message,
    });
  }
});
export default router;
