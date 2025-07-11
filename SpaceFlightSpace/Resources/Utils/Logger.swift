//
//  Logger.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation
import os.log

enum LogLevel: String, CaseIterable {
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case debug = "🐛 DEBUG"
}

/// Protocol for logging functionality throughout the application.
/// Provides a consistent interface for different logging implementations
/// and allows for easy testing and configuration changes.
protocol LoggerProtocol {
    /// Logs an informational message.
    /// - Parameter message: The message to log.
    func info(_ message: String)
    
    /// Logs a warning message.
    /// - Parameter message: The warning message to log.
    func warning(_ message: String)
    
    /// Logs an error message.
    /// - Parameter message: The error message to log.
    func error(_ message: String)
    
    /// Logs a debug message (only in debug builds).
    /// - Parameter message: The debug message to log.
    func debug(_ message: String)
}

final class Logger: LoggerProtocol {
    static let shared = Logger()
    
    /// Private initializer for the singleton Logger.
    /// This initializer is private to enforce the singleton pattern,
    /// ensuring consistent logging configuration throughout the application.
    /// - Note: Access the shared instance using `Logger.shared`.
    private init() {
        // Configuration setup can be added here
    }
    
    // MARK: - LoggerProtocol Implementation
    
    func info(_ message: String) {
        log(message, level: .info)
    }
    
    func warning(_ message: String) {
        log(message, level: .warning)
    }
    
    func error(_ message: String) {
        log(message, level: .error)
    }
    
    func debug(_ message: String) {
        #if DEBUG
        log(message, level: .debug)
        #endif
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String, level: LogLevel) {
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        let fullMessage = "[LOGGER] [\(timestamp)] [\(level.rawValue)] \(message)"
        print(fullMessage)
    }
}

// MARK: - DateFormatter Extension

private extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}


