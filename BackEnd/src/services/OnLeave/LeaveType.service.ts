import { FieldValue } from "firebase-admin/firestore";
import { adminDb } from "../../config/firebase.config";


export const createLeaveType = async (data: {
    name: string
    daynumber: number,
    description: string,
    quantity: number
}) => {
    const { name, daynumber, description, quantity } = data
    if (!name) {
        throw new Error("Leave Type name is required")
    }
    if (!description) {
        throw new Error("Leave type description is required")
    }

    if (quantity === undefined || quantity === null) {
        throw new Error("Leave type quantity is required");
    }
    const docRef = await adminDb.collection("leave_type").add({
        name,
        daynumber,
        description,
        quantity,
        created_at: FieldValue.serverTimestamp()
    })
    return {
        id: docRef.id,
        name
    }
}