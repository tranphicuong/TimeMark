import cors from "cors";
import "dotenv/config";
import express from "express";
import Employee from "./routes/Employees/employees.route";

import Department from "./routes/Department/department.route";
import Position from "./routes/Department/position.route";

import LeaveBalance from "./routes/OnLeave/LeaveBalance.route";
import LeaveRequest from "./routes/OnLeave/LeaveRequest.route";
import LeaveType from "./routes/OnLeave/LeaveType.route";
import WorkSchedule from "./routes/OnLeave/WorkSchedule.route";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/employee", Employee);

app.use("/api/department", Department);
app.use("/api/position", Position);

app.use("/api/leave_request", LeaveRequest);
app.use("/api/leave_balance", LeaveBalance);
app.use("/api/leave_type", LeaveType);
app.use("/api/work_schedule", WorkSchedule);
app.get("/", (req, res) => {
  res.send("API running IOS...");
});

const PORT = Number(process.env.PORT) || 3001;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});
