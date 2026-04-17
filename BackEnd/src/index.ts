import express from "express";
import "dotenv/config";
import cors from "cors";
import Employee from "./routes/Employees/employees.route";
import Department from "./routes/Department/department.route"
import LeaveRequest from "./routes/OnLeave/LeaveRequest.route"
const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/employee", Employee);
app.use("/api/department", Department)
app.use("/api/leave_request", LeaveRequest)
app.get("/", (req, res) => {
    res.send("API running IOS...");
});

const PORT = Number(process.env.PORT) || 3001;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`);
});