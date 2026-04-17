import { adminDb } from "../../config/firebase.config";
// tao phong ban
export const createDepartmentService = async (data: {
    name: string;
}) => {
    const { name } = data;

    // 🔥 validate
    if (!name) {
        throw new Error("Department name is required");
    }

    // 🔥 hard-code id_office (theo yêu cầu m)
    const officeRef = adminDb.doc("office/cA6fDsE87Giu9zgbEWjB");

    // 🔥 check office tồn tại
    const officeSnap = await officeRef.get();
    if (!officeSnap.exists) {
        throw new Error("Office not found");
    }

    // 🔥 tạo department
    const docRef = await adminDb.collection("department").add({
        name,
        id_office: officeRef,
        created_at: new Date(),
    });

    return {
        id: docRef.id,
        name,
    };
};
//get all user by department
export const getUsersByDepartmentService = async (
    departmentId: string
) => {
    const departmentRef = adminDb.doc(`department/${departmentId}`);

    // 🔥 id trưởng phòng
    const LEADER_POSITION_ID = "VqfJNhhuL0j4dv7SF7Rf";

    // 🔥 lấy luôn department
    const departmentSnap = await departmentRef.get();
    if (!departmentSnap.exists) {
        throw new Error("Department not found");
    }

    const departmentName = departmentSnap.data()?.name || null;

    const snapshot = await adminDb
        .collection("users")
        .where("id_department", "==", departmentRef)
        .get();

    let leader: any = null;

    const users = await Promise.all(
        snapshot.docs.map(async (doc) => {
            const data = doc.data();

            if (data.isDeleted) return null;

            const positionRef = data.id_position;

            let positionName = null;

            if (positionRef) {
                const posSnap = await positionRef.get();
                positionName = posSnap.data()?.name || null;

                if (positionRef.id === LEADER_POSITION_ID) {
                    leader = {
                        uid: doc.id,
                        name: data.name,
                        email: data.email,
                    };
                }
            }

            return {
                uid: doc.id,
                id_member: data.id_member,
                name: data.name,
                email: data.email,
                phone: data.phone,
                position: positionName,
                isActive: data.isActive,
            };
        })
    );

    const filteredUsers = users.filter(Boolean);

    return {
        department_id: departmentId,
        department_name: departmentName, // ✅ thêm cái này

        total: filteredUsers.length,
        leader,
        users: filteredUsers,
    };
};

export const updateDepartmentService = async (
    id: string,
    data: { name: string }
) => {
    const { name } = data;

    if (!id) {
        throw new Error("Department ID is required");
    }

    if (!name) {
        throw new Error("Department name is required");
    }

    const docRef = adminDb.collection("department").doc(id);

    // 🔥 check tồn tại
    const docSnap = await docRef.get();
    if (!docSnap.exists) {
        throw new Error("Department not found");
    }

    // 🔥 update
    await docRef.update({
        name,
        updated_at: new Date(), // ✅ thêm cái này
    });

    return {
        id,
        name,
    };


};

export const deleteDepartmentService = async (id: string) => {
    if (!id) {
        throw new Error("Department ID is required");
    }

    const departmentRef = adminDb.doc(`department/${id}`);

    // 🔥 check tồn tại
    const depSnap = await departmentRef.get();
    if (!depSnap.exists) {
        throw new Error("Department not found");
    }

    // 🔥 check còn user không
    const userSnapshot = await adminDb
        .collection("users")
        .where("id_department", "==", departmentRef)
        .where("isDeleted", "==", false)
        .limit(1) // 🔥 tối ưu, chỉ cần biết có hay không
        .get();

    if (!userSnapshot.empty) {
        throw new Error("Department still has users");
    }

    // 🔥 soft delete (KHÔNG xóa thật)
    await departmentRef.update({
        isDeleted: true,
        deleted_at: new Date(),
    });

    return {
        id,
        message: "Department deleted",
    };
};