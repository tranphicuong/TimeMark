import express from "express";
import "dotenv/config";
import cors from "cors";
import Employee from "./routes/employees.route";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/employee", Employee);

app.get("/", (req, res) => {
    res.send("API running...");
});

const PORT = process.env.PORT || 3000;

app.listen(3000, "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`);
});