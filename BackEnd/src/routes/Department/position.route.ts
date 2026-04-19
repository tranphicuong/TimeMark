import express from "express"
import { createPosition } from "../../services/Department/position.service";
const router = express.Router();


router.post("/create", async (req, res) => {
    try {
        const result = await createPosition(req.body)
        res.status(200).json({
            success: true,
            data: result
        })
    } catch (error: any) {
        res.status(400).json({
            message: error.message
        })
    }
})


export default router