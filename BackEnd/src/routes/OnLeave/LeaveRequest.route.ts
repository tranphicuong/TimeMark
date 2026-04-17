import { Router } from "express";
import { approveLeave, getAllLeaveRequest } from "../../services/OnLeave/LeaveRequest.service";

const router = Router();

router.get("/", async (_req: any, res: any) => {
    try {
        const data = await getAllLeaveRequest();

        res.json({
            success: true,
            data,
        });

    } catch (err: any) {
        res.status(500).json({
            success: false,
            message: err.message,
        });
    }
});
router.patch("/approved/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const result = await approveLeave(id, req.body);
        return res.status(200).json({
            message: "update status approved",
            data: result
        })
    }
    catch (err: any) {
        console.error("error update status ", err)
        return res.status(500).json({
            message: "Internal server error",
            error: err.message
        })
    }
})


export default router;