import { adminDb } from "../../config/firebase.config";



export const getLeaveBalanceOfUsers = async (idUser: string) => {
    const userRef = adminDb.doc(`users/${idUser}`)
    // lấy document cha theo user
    const snapshot = await adminDb
        .collection("leave_balance")
        .where("id_user", "==", userRef)
        .get();
    if (snapshot.empty) {
        return [];
    }
    const result = [];
    for (const doc of snapshot.docs) {
        const parentData = doc.data();

        // cào subcollection item
        const itemSnapshot = await doc.ref.collection("item").get();

        const items = itemSnapshot.docs.map((itemDoc) => ({
            id: itemDoc.id,
            ...itemDoc.data(),
        }));

        result.push({
            id: doc.id,
            ...parentData,
            items,
        });
    }
    return result
}