import SwiftUI
import Combine
import FirebaseFirestore

enum TaskType: String, Codable {
    case work
    case todo
}

final class TaskItem: Identifiable, ObservableObject, Codable {
    let id: String // 고정된 고유 식별자 (서버에 저장됨)
    @DocumentID var firestoreId: String? // Firebase 문서 고유 키
    @Published var title: String
    @Published var isAllDay: Bool
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var location: String
    @Published var notes: String
    @Published var isCompleted: Bool
    @Published var isDeleted: Bool
    @Published var showInCalendar: Bool
    var type: TaskType
    var ownerId: String
    @Published var ownerName: String // 작성자 이름 추가
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isAllDay
        case startDate
        case endDate
        case location
        case notes
        case isCompleted
        case isDeleted
        case showInCalendar
        case type
        case ownerId
        case ownerName
    }
    
    init(title: String, isAllDay: Bool = false, startDate: Date = Date(), endDate: Date = Date().addingTimeInterval(3600), location: String = "", notes: String = "", isCompleted: Bool = false, isDeleted: Bool = false, showInCalendar: Bool = false, type: TaskType, ownerId: String = "", ownerName: String = "나") {
        self.id = UUID().uuidString // 초기 생성 시 단 한 번 부여
        self.title = title
        self.isAllDay = isAllDay
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.isCompleted = isCompleted
        self.isDeleted = isDeleted
        self.showInCalendar = showInCalendar
        self.type = type
        self.ownerId = ownerId
        self.ownerName = ownerName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // 서버에 저장된 ID가 있으면 그것을 사용, 없으면 새로 생성 (하위 호환성)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        firestoreId = try container.decodeIfPresent(String.self, forKey: .id) // @DocumentID mapping
        title = try container.decode(String.self, forKey: .title)
        isAllDay = try container.decode(Bool.self, forKey: .isAllDay)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        location = try container.decode(String.self, forKey: .location)
        notes = try container.decode(String.self, forKey: .notes)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        showInCalendar = try container.decodeIfPresent(Bool.self, forKey: .showInCalendar) ?? false
        type = try container.decode(TaskType.self, forKey: .type)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        ownerName = try container.decodeIfPresent(String.self, forKey: .ownerName) ?? "사용자"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id) // ID를 서버에 필수 저장
        try container.encode(title, forKey: .title)
        try container.encode(isAllDay, forKey: .isAllDay)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(location, forKey: .location)
        try container.encode(notes, forKey: .notes)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(showInCalendar, forKey: .showInCalendar)
        try container.encode(type, forKey: .type)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(ownerName, forKey: .ownerName)
    }
}

final class DataManager: ObservableObject {
    @Published var workTasks: [TaskItem] = []
    @Published var todoTasks: [TaskItem] = []
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 나중에 로그인한 사용자의 ID로 데이터를 필터링하여 가져오는 로직 추가 예정
    }
    
    func fetchTasks(ownerId: String) {
        db.collection("tasks")
            .whereField("ownerId", isEqualTo: ownerId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let tasks = documents.compactMap { queryDocumentSnapshot -> TaskItem? in
                    return try? queryDocumentSnapshot.data(as: TaskItem.self)
                }
                
                // 메인 스레드에서 애니메이션과 함께 업데이트하여 List 충돌 방지
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.workTasks = tasks.filter { $0.type == .work }
                        self.todoTasks = tasks.filter { $0.type == .todo }
                    }
                }
            }
    }
    
    func addTask(title: String, isAllDay: Bool, startDate: Date, endDate: Date, location: String, notes: String, showInCalendar: Bool, type: TaskType, ownerId: String, ownerName: String = "나") {
        let newTask = TaskItem(title: title, isAllDay: isAllDay, startDate: startDate, endDate: endDate, location: location, notes: notes, showInCalendar: showInCalendar, type: type, ownerId: ownerId, ownerName: ownerName)
        
        do {
            // 추가 시점에 바로 로컬 배열에 넣어 반응성 개선 가능 (선택적)
            let _ = try db.collection("tasks").addDocument(from: newTask)
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: TaskItem) {
        // firestoreId가 없으면 id(UUID)를 문서 이름으로 사용하거나 firestoreDocId를 찾음
        let documentId = task.firestoreId ?? task.id 
        
        do {
            try db.collection("tasks").document(documentId).setData(from: task)
        } catch {
            print("Error updating task: \(error.localizedDescription)")
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        let documentId = task.firestoreId ?? task.id
        db.collection("tasks").document(documentId).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleCompletion(for task: TaskItem) {
        task.isCompleted.toggle()
        updateTask(task)
    }
    
    func toggleDeletion(for task: TaskItem) {
        task.isDeleted.toggle()
        updateTask(task)
    }
}
