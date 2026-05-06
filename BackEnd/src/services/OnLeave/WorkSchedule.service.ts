import moment from "moment";
import { adminDb } from "../../config/firebase.config";
export const getWorkSchedule = async (id: string) => {
  const snapshot = await adminDb.collection("work_schedule").doc(id).get();
  if (!snapshot.exists) return null;

  const data = snapshot.data();

  return {
    name: data?.name,
    early_leave_minute: data?.early_leave_minute,
    late_after_minute: data?.late_after_minute,
    check_in_time: moment(data?.check_in_time.toDate()).format("HH:mm"),
    check_out_time: moment(data?.check_out_time.toDate()).format("HH:mm"),
    overtime_after: moment(data?.overtime_after.toDate()).format("HH:mm"),
  };
};
export const editTimeMark = async (id: string, data: {}) => {};
