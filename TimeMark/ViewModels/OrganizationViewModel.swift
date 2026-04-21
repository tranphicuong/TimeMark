////
////  OrganizationViewModel.swift
////  TimeMark
////
////  Created by Rebel on 4/19/26.
////
//
//import Foundation
//
//class OrganizationViewModel: ObservableObject {
//    @Published var department: DepartmentData?
//
//    func fetchDepartment() {
//        DepartmentService.shared.getDepartmentUsers(
//            departmentId: "FNB2IRFA7Ak8gXISZLlI"
//        ) { data, error in
//            DispatchQueue.main.async {
//                self.department = data
//            }
//        }
//    }
//}
