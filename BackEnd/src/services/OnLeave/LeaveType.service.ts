import { adminDb } from "../../config/firebase.config";

export const getLeaveTypes = async () => {
  const snapshot = await adminDb.collection("leave_type").get();
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));
};
export const getLeaveTypeById = async (id: string) => {
  const snapshot = await adminDb.collection("leave_type").doc(id).get();
  return snapshot.exists ? snapshot.data() : null;
};
