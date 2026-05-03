import { adminDb } from "../../config/firebase.config";

//get All attendance in day
export const getAllAttendanceInDate = async () => {
  const thisDate = new Date();
  const snapshot = await adminDb
    .collection("attendance")
    .where("date", "==", thisDate)
    .get();
  return snapshot.docs.map((doc) => doc.data());
};
