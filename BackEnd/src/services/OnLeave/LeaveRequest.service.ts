import { FieldValue } from "firebase-admin/firestore";
import { adminDb } from "../../config/firebase.config";

export const getAllLeaveRequest = async () => {
    const snapshot = await adminDb.collection("leave_request").get();
    const requests = await Promise.all(
        snapshot.docs.map(async (doc) => {
            const data = doc.data();

            // 👉 lấy user info
            let userData = null;
            if (data.id_user) {
                const userSnap = await data.id_user.get();
                if (userSnap.exists) {
                    const u = userSnap.data();
                    userData = {
                        id: userSnap.id,
                        email: u?.email || null,
                        name: u?.name || null,
                    };
                }
            }
            //lay approved by
            let approved_by = null
            if (data.id_approved_id !== null) {
                const approvedSnap = await data.approved_by.get();
                if (approvedSnap.exists) {
                    const u = approvedSnap.data();
                    approved_by = {
                        id: approvedSnap.id,
                        email: u?.email || null,
                        name: u?.name || null,
                    };
                }
            }
            // 👉 lấy leave type (nếu cần)
            let leaveTypeData = null;
            if (data.id_leave_type) {
                if (data.id_leave_type !== null) {
                    const leaveSnap = await data.id_leave_type.get();
                    if (leaveSnap.exists) {
                        const l = leaveSnap.data();
                        leaveTypeData = {
                            id: leaveSnap.id,
                            name: l?.name || null,
                        };
                    }
                }


            }

            return {
                id: doc.id,

                user: userData,
                leave_type: leaveTypeData,

                from_date: data.from_date,
                to_date: data.to_date,
                reason: data.reason,
                status: data.status,

                approved_by: approved_by,
                approved_at: data.approved_at,
                created_at: data.created_at,
            };
        })
    );

    return requests;
};
export const approveLeave = async (
    id: string,
    data: {
        status: string,
        approved_by: string,
    }
) => {
    const approved_by_ref = adminDb.doc(`users/${data.approved_by}`);

    await adminDb.collection("leave_request").doc(id).update({
        status: data.status,
        approved_by: approved_by_ref,
        approved_at: FieldValue.serverTimestamp()
    });

    return {
        id,
        status: data.status
    };
};