//
//  SpaceFlightSpaceTests.swift
//  SpaceFlightSpaceTests
//
//  Created by Nico on 09/07/2025.
//

import XCTest
@testable import SpaceFlightSpace

// MARK: - Mocks

final class MockArticleService: ArticleServiceProtocol {
    var shouldReturnError = false
    var mockError = APIError.noData
    var mockResponse = ArticleResponse(
        results: [
            Article(id: 1, title: "Test Article 1", summary: "Summary 1", image_url: "https://image1.com", published_at: "2024-01-01T00:00:00Z", url: "https://test1.com", authors: []),
            Article(id: 2, title: "Test Article 2", summary: "Summary 2", image_url: "https://image2.com", published_at: "2024-01-02T00:00:00Z", url: "https://test2.com", authors: [])
        ],
        count: 2,
        previous: nil,
        next: "next-url"
    )
    
    private(set) var lastSearchTerm: String?
    private(set) var lastPageURL: String?
    private(set) var fetchCallCount = 0
    
    func fetchArticles(search: String?, pageURL: String?, completion: @escaping (Result<ArticleResponse, Error>) -> Void) {
        fetchCallCount += 1
        lastSearchTerm = search
        lastPageURL = pageURL
        
        DispatchQueue.main.async {
            if self.shouldReturnError {
                completion(.failure(self.mockError))
            } else {
                completion(.success(self.mockResponse))
            }
        }
    }
    
    func reset() {
        shouldReturnError = false
        lastSearchTerm = nil
        lastPageURL = nil
        fetchCallCount = 0
    }
}

final class MockAPIClient: APIClientProtocol {
    let articles: ArticleServiceProtocol
    
    init(articleService: ArticleServiceProtocol = MockArticleService()) {
        self.articles = articleService
    }
}

// MARK: - Test Suite

final class SpaceFlightSpaceTests: XCTestCase {
    
    var mockArticleService: MockArticleService!
    var mockAPIClient: MockAPIClient!
    
    override func setUpWithError() throws {
        mockArticleService = MockArticleService()
        mockAPIClient = MockAPIClient(articleService: mockArticleService)
    }

    override func tearDownWithError() throws {
        mockArticleService.reset()
        mockArticleService = nil
        mockAPIClient = nil
    }

    // MARK: - HomeViewModelDataSource Tests
    
    func testHomeViewModelDataSource_loadInitialArticles_success() throws {
        // Given
        let dataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        let expectation = expectation(description: "Load initial articles")
        var receivedArticles: [Article] = []
        
        // When
        dataSource.loadInitialArticles(text: nil, onSuccess: { articles in
            receivedArticles = articles
            expectation.fulfill()
        }, onError: { error in
            XCTFail("Expected success but got error: \(error)")
        })
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedArticles.count, 2)
        XCTAssertEqual(receivedArticles[0].title, "Test Article 1")
        XCTAssertEqual(receivedArticles[1].title, "Test Article 2")
        XCTAssertEqual(dataSource.items.count, 2)
        XCTAssertEqual(dataSource.nextPageURL, "next-url")
        XCTAssertNil(mockArticleService.lastSearchTerm)
        XCTAssertNil(mockArticleService.lastPageURL)
    }
    
    func testHomeViewModelDataSource_loadInitialArticles_withSearchText() throws {
        // Given
        let dataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        let expectation = expectation(description: "Load articles with search")
        let searchText = "space"
        
        // When
        dataSource.loadInitialArticles(text: searchText, onSuccess: { _ in
            expectation.fulfill()
        }, onError: { error in
            XCTFail("Expected success but got error: \(error)")
        })
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockArticleService.lastSearchTerm, searchText)
        XCTAssertEqual(dataSource.text, searchText)
    }
    
    func testHomeViewModelDataSource_loadInitialArticles_error() throws {
        // Given
        let dataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        mockArticleService.shouldReturnError = true
        let expectation = expectation(description: "Load articles error")
        var receivedError: Error?
        
        // When
        dataSource.loadInitialArticles(text: nil, onSuccess: { _ in
            XCTFail("Expected error but got success")
        }, onError: { error in
            receivedError = error
            expectation.fulfill()
        })
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertTrue(dataSource.items.isEmpty)
    }
    
    func testHomeViewModelDataSource_loadMoreArticles_success() throws {
        // Given
        let dataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        dataSource.nextPageURL = "next-page-url"
        dataSource.items = [Article(id: 0, title: "Existing", summary: "Existing summary", image_url: "", published_at: "", url: "", authors: [])]
        
        let expectation = expectation(description: "Load more articles")
        var receivedNewArticles: [Article] = []
        
        // When
        dataSource.loadMoreArticles(onSuccess: { articles in
            receivedNewArticles = articles
            expectation.fulfill()
        }, onError: { error in
            XCTFail("Expected success but got error: \(error)")
        })
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedNewArticles.count, 2)
        XCTAssertEqual(dataSource.items.count, 3) // 1 existing + 2 new
        XCTAssertEqual(mockArticleService.lastPageURL, "next-page-url")
    }
    
    func testHomeViewModelDataSource_loadMoreArticles_noNextPage() throws {
        // Given
        let dataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        dataSource.nextPageURL = nil
        
        let expectation = expectation(description: "No more articles to load")
        expectation.isInverted = true
        
        // When
        dataSource.loadMoreArticles(onSuccess: { _ in
            expectation.fulfill()
        }, onError: { _ in
            expectation.fulfill()
        })
        
        // Then
        waitForExpectations(timeout: 0.5)
        XCTAssertEqual(mockArticleService.fetchCallCount, 0)
    }
    
    func testHomeViewModelDataSource_initialization() throws {
        // Given & When
        let dataSource1 = HomeViewModelDataSource()
        let dataSource2 = HomeViewModelDataSource(items: [Article(id: 1, title: "Test", summary: "Test summary", image_url: "", published_at: "", url: "", authors: [])], nextPageURL: "test-url")
        
        // Then
        XCTAssertTrue(dataSource1.items.isEmpty)
        XCTAssertNil(dataSource1.nextPageURL)
        
        XCTAssertEqual(dataSource2.items.count, 1)
        XCTAssertEqual(dataSource2.nextPageURL, "test-url")
    }
    
    // MARK: - HomeViewModel Tests
    
    func testHomeViewModel_getItems() throws {
        // Given
        let mockDataSource = HomeViewModelDataSource(items: mockArticleService.mockResponse.results!, apiClient: mockAPIClient)
        let viewModel = HomeViewModel(datasource: mockDataSource)
        
        // When
        let items = viewModel.getItems()
        
        // Then
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].title, "Test Article 1")
    }
    
    func testHomeViewModel_loadInitialArticles_success() throws {
        // Given
        let mockDataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        let viewModel = HomeViewModel(datasource: mockDataSource)
        let expectation = expectation(description: "Load initial articles")
        var receivedArticles: [Article] = []
        
        // When
        viewModel.loadInitialArticles(onSuccess: { articles in
            receivedArticles = articles
            expectation.fulfill()
        }, onError: { error in
            XCTFail("Expected success but got error: \(error)")
        })
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedArticles.count, 2)
        XCTAssertEqual(viewModel.getItems().count, 2)
    }
    
    func testHomeViewModel_searchArticles_success() throws {
        // Given
        let mockDataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        let viewModel = HomeViewModel(datasource: mockDataSource)
        let expectation = expectation(description: "Search articles")
        let searchText = "rocket"
        
        // When
        viewModel.searchArticles(text: searchText, onSuccess: { _ in
            expectation.fulfill()
        }, onError: { error in
            XCTFail("Expected success but got error: \(error)")
        })
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockArticleService.lastSearchTerm, searchText)
    }
    
    func testHomeViewModel_loadMoreArticles_success() throws {
        // Given
        let mockDataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        mockDataSource.nextPageURL = "next-url"
        let viewModel = HomeViewModel(datasource: mockDataSource)
        let expectation = expectation(description: "Load more articles")
        
        // When
        viewModel.loadMoreArticles(onSuccess: { _ in
            expectation.fulfill()
        }, onError: { error in
            XCTFail("Expected success but got error: \(error)")
        })
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockArticleService.fetchCallCount, 1)
    }
    
    // MARK: - ItemDetailDataSource Tests
    
    func testItemDetailDataSource_initialization() throws {
        // Given
        let article = Article(id: 123, title: "Detail Test", summary: "Detail summary", image_url: "https://detail-image.com", published_at: "2024-01-01T00:00:00Z", url: "https://detail.com", authors: [])
        
        // When
        let dataSource = ItemDetailDataSource(item: article)
        
        // Then
        XCTAssertEqual(dataSource.item.id, 123)
        XCTAssertEqual(dataSource.item.title, "Detail Test")
        XCTAssertEqual(dataSource.item.url, "https://detail.com")
    }
    
    // MARK: - ItemDetailViewModel Tests
    
    func testItemDetailViewModel_getItem() throws {
        // Given
        let article = Article(id: 456, title: "VM Test", summary: "VM summary", image_url: "", published_at: "", url: "https://vm.com", authors: [])
        let dataSource = ItemDetailDataSource(item: article)
        let articleHelper = ArticleHelper()
        let viewModel = ItemDetailViewModel(datasource: dataSource, articleHelper: articleHelper)
        
        // When
        let item = viewModel.getItem()
        
        // Then
        XCTAssertEqual(item.id, 456)
        XCTAssertEqual(item.title, "VM Test")
        XCTAssertEqual(item.url, "https://vm.com")
    }
    
    func testItemDetailViewModel_openFullArticle() throws {
        // Given
        let article = Article(id: 789, title: "Open Test", summary: "Open summary", image_url: "", published_at: "", url: "https://open.com", authors: [])
        let dataSource = ItemDetailDataSource(item: article)
        let articleHelper = ArticleHelper()
        let viewModel = ItemDetailViewModel(datasource: dataSource, articleHelper: articleHelper)
        let mockViewController = UIViewController()
        
        // When
        // Note: En tests unitarios no verificamos la interacción de UI real
        // Solo verificamos que el método no lance excepciones
        XCTAssertNoThrow(viewModel.openFullArticle(mockViewController))
        
        // Then
        XCTAssertEqual(viewModel.getItem().url, "https://open.com")
    }
    
    func testItemDetailViewModel_openFullArticle_nilURL() throws {
        // Given
        let article = Article(id: 999, title: "Nil URL Test", summary: "Nil summary", image_url: "", published_at: "", url: nil, authors: [])
        let dataSource = ItemDetailDataSource(item: article)
        let articleHelper = ArticleHelper()
        let viewModel = ItemDetailViewModel(datasource: dataSource, articleHelper: articleHelper)
        let mockViewController = UIViewController()
        
        // When
        // Note: En tests unitarios no verificamos la interacción de UI real
        // Solo verificamos que el método no lance excepciones con URL nil
        XCTAssertNoThrow(viewModel.openFullArticle(mockViewController))
        
        // Then
        XCTAssertNil(viewModel.getItem().url)
    }
    
    // MARK: - Integration Tests
    
    func testHomeViewModel_fullFlow_loadAndSearch() throws {
        // Given
        let mockDataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        let viewModel = HomeViewModel(datasource: mockDataSource)
        let loadExpectation = expectation(description: "Load articles")
        let searchExpectation = expectation(description: "Search articles")
        
        // When - Load initial articles
        viewModel.loadInitialArticles(onSuccess: { _ in
            loadExpectation.fulfill()
        }, onError: { error in
            XCTFail("Load failed: \(error)")
        })
        
        wait(for: [loadExpectation], timeout: 1.0)
        
        // Then - Verify initial load
        XCTAssertEqual(viewModel.getItems().count, 2)
        
        // When - Search articles
        viewModel.searchArticles(text: "mars", onSuccess: { _ in
            searchExpectation.fulfill()
        }, onError: { error in
            XCTFail("Search failed: \(error)")
        })
        
        // Then - Verify search
        wait(for: [searchExpectation], timeout: 1.0)
        XCTAssertEqual(mockArticleService.lastSearchTerm, "mars")
        XCTAssertEqual(mockArticleService.fetchCallCount, 2)
    }
    
    // MARK: - Performance Tests
    
    func testHomeViewModelDataSource_loadArticles_performance() throws {
        let dataSource = HomeViewModelDataSource(apiClient: mockAPIClient)
        
        measure {
            let expectation = expectation(description: "Performance test")
            dataSource.loadInitialArticles(text: nil, onSuccess: { _ in
                expectation.fulfill()
            }, onError: { _ in
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1.0)
        }
    }
}
