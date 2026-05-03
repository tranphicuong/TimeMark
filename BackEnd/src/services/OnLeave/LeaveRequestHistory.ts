import { FieldValue } from "firebase-admin/firestore";
import { adminDb } from "../../config/firebase.config";

//tìm tat ca danh sach lich su da duyet
export async function getAllLeaveRequestHistory() {
  const snapshot = await adminDb.collection("leave_request_history").get();
  return snapshot.docs.map((doc) => doc.data());
}

//tạo lịch sữ duyêt
export async function createLeaveRequestHistory(data: {
  leave_request_id: string;
  action: string;
  approved_by: string;
  note: string | null;
}) {
  const { leave_request_id, action, approved_by, note } = data;
  if (!leave_request_id || !action) {
    throw new Error("Missing required fields");
  }

  const snapshot = await adminDb.collection("leave_request_history").add({
    leave_request_id: adminDb.doc("leave_request/" + leave_request_id),
    action,
    approved_by,
    note,
    created_at: FieldValue.serverTimestamp(),
  });
  return snapshot.id;
}
