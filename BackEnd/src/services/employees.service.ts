import { adminAuth, adminDb } from "../config/firebase.config";
// 🔹 tạo tài khoản (admin tạo)
export const createUserService = async (data: {
    email: string;
    password: string;
    name: string;
    phone: string;
}) => {
    const { email, password, name, phone } = data;

    const userRecord = await adminAuth.createUser({
        email,
        password,
        displayName: name,
    });

    await adminDb.collection("users").doc(userRecord.uid).set({
        email,
        name,
        phone,
        isActive: true,
        created_at: new Date(),
    });

    return {
        uid: userRecord.uid,
        email,
        name,
    };
};

// 🔹 khóa / mở tài khoản
export const toggleUserStatusService = async (uid: string, isActive: boolean) => {
    // Firebase Auth: disable user
    await adminAuth.updateUser(uid, {
        disabled: !isActive,
    });

    // Firestore: update trạng thái
    await adminDb.collection("users").doc(uid).update({
        isActive,
    });

    return {
        uid,
        isActive,
    };
};

//all in tat ca nhan su  tru admin
export const getAllUsersService = async () => {
    const snapshot = await adminDb.collection("users").get();

    const users: any[] = [];

    snapshot.forEach((doc) => {
        const data = doc.data();

        // ❌ bỏ admin
        if (data.id_role === "roles/admin") return;
        //neu da bi xoa thi bo luon
        if (data.isDeleted) return
        users.push({
            uid: doc.id,
            email: data.email,
            name: data.name,
            phone: data.phone,
            id_role: data.id_role,
            isActive: data.isActive,
        });
    });

    return users;
};
// 🔹 xóa tài khoản (chỉ xóa Auth, giữ Firestore)
export const deleteUserService = async (uid: string) => {
    // xóa bên Authentication
    await adminAuth.deleteUser(uid);

    // KHÔNG xóa Firestore
    await adminDb.collection("users").doc(uid).update({
        isDeleted: true,
        deletedAt: new Date(),
    });

    return {
        uid,
        message: "User deleted from Auth only",
    };
};