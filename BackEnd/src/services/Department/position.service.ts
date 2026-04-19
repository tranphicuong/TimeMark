import { FieldValue } from "firebase-admin/firestore";
import { adminDb } from "../../config/firebase.config";

//create position
export const createPosition = async (data: {
    name: string,
    description: string
}) => {
    const { name, description } = data
    if (!name && !description) {
        throw new Error("positon and description is name required")
    }
    const result = await adminDb.collection("position").add({
        name,
        description,
        created_at: FieldValue.serverTimestamp()
    })
    return {
        id: result.id,
        message: "create position"
    }
}


export const deletePosition = async (positionId: string) => {
    if (!positionId) {
        throw new Error("Position id is required");
    }

    const positionRef = adminDb.doc(`position/${positionId}`);

    // check position có tồn tại không
    const positionSnap = await positionRef.get();

    if (!positionSnap.exists) {
        throw new Error("Position not found");
    }

    // check users còn đang liên kết không
    const userSnapshot = await adminDb
        .collection("users")
        .where("id_position", "==", positionRef)
        .get();

    if (!userSnapshot.empty) {
        throw new Error(
            `Cannot delete position. ${userSnapshot.size} user(s) are still using this position`
        );
    }

    // xóa position
    await positionRef.delete();

    return {
        success: true,
        message: "Delete position success",
    };
};