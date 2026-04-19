import { adminAuth, adminDb } from "../../config/firebase.config";
// 🔹 tạo tài khoản (admin tạo)

/*
data{
    id: uuid
    email: string
    id_department : reference
    id_position: reference
    id_role: reference
    isActive: boolean
    isDeleted: boolean
    name: string
    phone: string


    --auth
    email
    department
    position
    name
    password
    
}
*/

/*
id_member
name
email
id_position
id_department
position
department
isAcitve 
isDelted
phone
created_at

*/
export const createUserService = async (data: {
    email: string;
    password: string;
    name: string;
    id_position: string;
    id_department: string;
}) => {
    const { email, password, name, id_position, id_department } = data;

    // 🔥 validate
    if (!email || !password || !name || !id_position || !id_department) {
        throw new Error("Missing required fields");
    }

    // 🔥 tạo user Firebase Auth
    const userRecord = await adminAuth.createUser({
        email,
        password,
        displayName: name,
    });

    // 🔥 tạo id_member (TM-0001)
    const counterRef = adminDb.collection("counters").doc("member");

    const id_member = await adminDb.runTransaction(async (transaction) => {
        const doc = await transaction.get(counterRef);

        let current = 0;

        if (!doc.exists) {
            current = 1;
            transaction.set(counterRef, { value: current });
        } else {
            current = doc.data()?.value + 1;
            transaction.update(counterRef, { value: current });
        }

        return `TM-${String(current).padStart(4, "0")}`;
    });

    // 🔥 convert sang reference
    const positionRef = adminDb.doc(`position/${id_position}`);
    const departmentRef = adminDb.doc(`department/${id_department}`);
    const roleRef = adminDb.doc("roles/user");

    // 🔥 check tồn tại
    const [posSnap, depSnap] = await Promise.all([
        positionRef.get(),
        departmentRef.get(),
    ]);

    if (!posSnap.exists) throw new Error("Position not found");
    if (!depSnap.exists) throw new Error("Department not found");

    // 🔥 lưu Firestore
    await adminDb.collection("users").doc(userRecord.uid).set({
        id_member, // ✅ mã nhân viên

        email,
        name,

        id_position: positionRef,
        id_department: departmentRef,
        id_role: roleRef,
        avatarURL: null,
        phone: null,
        isActive: true,
        isDeleted: false,
        created_at: new Date(),
    });

    return {
        uid: userRecord.uid,
        id_member,
        email,
        name,
    };
};

// 🔹 khóa / mở tài khoản
export const toggleUserStatusService = async (
    uid: string,
    isActive: boolean
) => {
    try {
        // 🔥 check user tồn tại trong Firebase Auth
        await adminAuth.getUser(uid);

        // 🔥 disable / enable
        await adminAuth.updateUser(uid, {
            disabled: !isActive,
        });

        // 🔥 update Firestore
        await adminDb.collection("users").doc(uid).update({
            isActive,
        });

        return {
            uid,
            isActive,
        };
    } catch (error: any) {
        console.log("SERVICE ERROR:", error);
        throw error;
    }
};

export const getAllUsersService = async () => {
    const snapshot = await adminDb.collection("users").get();

    const users = await Promise.all(
        snapshot.docs.map(async (doc) => {
            const data = doc.data();

            // ❌ bỏ admin
            if (data.id_role?.id === "admin") return null;

            // ❌ bỏ user đã bị xóa
            if (data.isDeleted) return null;

            // 🔥 lấy position + department
            const [posSnap, depSnap] = await Promise.all([
                data.id_position?.get(),
                data.id_department?.get(),
            ]);

            return {
                uid: doc.id,
                id_member: data.id_member,
                name: data.name,
                email: data.email,
                phone: data.phone,

                // 🔥 reference id
                id_position: data.id_position?.id,
                id_department: data.id_department?.id,

                // 🔥 name thật
                position: posSnap?.data()?.name || null,
                department: depSnap?.data()?.name || null,
                avatarURL: data.avatarURL,
                isActive: data.isActive,
                isDeleted: data.isDeleted,
                created_at: data.created_at,
            };
        })
    );

    // lọc null
    return users.filter((u) => u !== null);
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