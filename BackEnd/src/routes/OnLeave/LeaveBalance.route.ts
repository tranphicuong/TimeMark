import express from "express"
import { getLeaveBalanceOfUsers } from "../../services/OnLeave/LeaveBalance.service";

const router = express.Router();


router.get('/:id', async (req, res) => {
    try {
        const result = await getLeaveBalanceOfUsers(req.params.id);
        return res.status(200).json({
            message: "get users by leave banlance in time",
            data: result
        })
    }
    catch (error: any) {
        return res.status(400).json({
            message: error.message
        })
    }
})

export default router