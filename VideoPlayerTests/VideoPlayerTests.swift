//
//  VideoPlayerTests.swift
//  VideoPlayerTests
//
//  Created by Ebele Nedosa on 04/02/2026.
//

import XCTest
@testable import VideoPlayer

final class VideoPlayerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    var sut: FeedViewModel!
    var mockNetwork: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkClient()
        sut = FeedViewModel(network: mockNetwork)
    }

    override func tearDown() {
        sut = nil
        mockNetwork = nil
        super.tearDown()
    }
    
    private func makeMockVideo(id: Int) -> Video {
       
        let mockFile = VideoFile(
            id: id * 10,
            quality: .hd,
            fileType: .videoMp4,
            width: 1080,
            height: 1920,
            fps: 30.0,
            link: "https://test.com/vid.mp4",
            size: 5000000
        )

        return Video(
            id: id,
            width: 1080,
            height: 1920,
            duration: 15, url: "https://pexels.com/video/nature-sunset-\(id)/",
            image: "https://test.com/img.jpg",
            user: User(id: 1, name: "Test User", url: ""),
            videoFiles: [mockFile],
            videoPictures: []
        )
    }
    
    func test_loadVideos_success() async throws {
        let expectation = XCTestExpectation(description: "Videos updated")
        let mockVideos = [makeMockVideo(id: 123)]
        mockNetwork.result = .success(mockVideos)
        
        sut.onVideosUpdated = {
            expectation.fulfill()
        }
        
        sut.load()
        
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.videos.count, 1)
        XCTAssertEqual(sut.videos.first?.id, 123)
    }
    
    func test_toggleLike_updatesState() throws {
        let video = makeMockVideo(id: 99)
        
        XCTAssertFalse(sut.isLiked(video))
        sut.toggleLike(for: video)
        XCTAssertTrue(sut.isLiked(video))
        sut.toggleLike(for: video)
    }


    func test_captionFormatting() throws {
        
        let url = "https://pexels.com/video/nature-sunset-beautiful-123/"
        let result = Video.formatCaption(from: url)
        
        XCTAssertEqual(result, "Nature Sunset Beautiful")
    }

}
