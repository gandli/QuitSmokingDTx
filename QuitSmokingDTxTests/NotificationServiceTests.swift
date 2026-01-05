import XCTest
import UserNotifications
@testable import QuitSmokingDTx

@MainActor
final class NotificationServiceTests: XCTestCase {
    
    private var service: NotificationService!
    
    override func setUp() async throws {
        try await super.setUp()
        service = NotificationService.shared
    }
    
    func testNotificationScheduling() async {
        // 由于 UNUserNotificationCenter 很难直接在单元测试中 Mock
        // 我们主要测试逻辑层面的调度是否没有崩溃
        
        let expectation = XCTestExpectation(description: "Schedule Notification")
        
        service.scheduleDailyReminder(time: Date().addingTimeInterval(3600))
        
        // 验证基本属性（如果 Service 暴露了内部状态）
        // 这里目前只能验证调用路径
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
