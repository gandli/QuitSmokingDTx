import XCTest
@testable import QuitSmokingDTx

@MainActor
final class DataStorageServiceTests: XCTestCase {
    
    private var service: DataStorageService!
    private let testUserDefaults = UserDefaults(suiteName: "TestDefaults")!
    
    override func setUp() async throws {
        try await super.setUp()
        service = DataStorageService.shared
        // 清理测试环境
        testUserDefaults.removePersistentDomain(forName: "TestDefaults")
    }
    
    func testSmokingEventPersistence() async {
        let event = SmokingEvent(
            timestamp: Date(),
            cigarettes: 1,
            context: "Test",
            resisted: false
        )
        
        service.saveSmokingEvents([event])
        let savedEvents = service.loadSmokingEvents()
        
        XCTAssertEqual(savedEvents.count, 1)
        XCTAssertEqual(savedEvents.first?.context, "Test")
    }
    
    func testCravingEventPersistence() async {
        let event = CravingEvent(
            timestamp: Date(),
            intensity: .high,
            context: "Test Craving",
            resisted: true,
            resistanceDuration: 60
        )
        
        service.saveCravingEvents([event])
        let savedEvents = service.loadCravingEvents()
        
        XCTAssertEqual(savedEvents.count, 1)
        XCTAssertEqual(savedEvents.first?.intensity, .high)
    }
    
    func testDataAnonymization() async {
        let calendar = Calendar.current
        let components = DateComponents(year: 2023, month: 10, day: 15, hour: 14, minute: 30)
        let date = calendar.date(from: components)!
        
        let event = SmokingEvent(
            timestamp: date,
            cigarettes: 1,
            context: "Sensitive Context",
            resisted: false
        )
        
        service.saveSmokingEvents([event])
        service.anonymizeData()
        
        let anonymized = service.loadSmokingEvents().first!
        
        let anonymizedComponents = calendar.dateComponents([.hour, .minute], from: anonymized.timestamp)
        let originalComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        XCTAssertEqual(anonymizedComponents.hour, originalComponents.hour)
        XCTAssertEqual(anonymizedComponents.minute, originalComponents.minute)
        // 验证日期部分已重置（默认为 2001-01-01）
        let yearComponent = calendar.component(.year, from: anonymized.timestamp)
        XCTAssertNotEqual(yearComponent, 2023)
    }
}
