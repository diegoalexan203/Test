import Foundation
import RxSwift
#if !COCOAPODS
import Moya
#endif

#if canImport(UIKit)
import UIKit.UIImage
#elseif canImport(AppKit)
import AppKit.NSImage
#endif

/// Extension for processing raw NSData generated by network access.
public extension ObservableType where Element == Response {

    /// Filters out responses that don't fall within the given range, generating errors when others are encountered.
    func filter<R: RangeExpression>(statusCodes: R) -> Observable<Element> where R.Bound == Int {
        return flatMap { Observable.just(try $0.filter(statusCodes: statusCodes)) }
    }

    /// Filters out responses that has the specified `statusCode`.
    func filter(statusCode: Int) -> Observable<Element> {
        return flatMap { Observable.just(try $0.filter(statusCode: statusCode)) }
    }

    /// Filters out responses where `statusCode` falls within the range 200 - 299.
    func filterSuccessfulStatusCodes() -> Observable<Element> {
        return flatMap { Observable.just(try $0.filterSuccessfulStatusCodes()) }
    }

    /// Filters out responses where `statusCode` falls within the range 200 - 399
    func filterSuccessfulStatusAndRedirectCodes() -> Observable<Element> {
        return flatMap { Observable.just(try $0.filterSuccessfulStatusAndRedirectCodes()) }
    }

    /// Maps data received from the signal into an Image. If the conversion fails, the signal errors.
    func mapImage() -> Observable<Image> {
        return flatMap { Observable.just(try $0.mapImage()) }
    }

    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors.
    func mapJSON(failsOnEmptyData: Bool = true) -> Observable<Any> {
        return flatMap { Observable.just(try $0.mapJSON(failsOnEmptyData: failsOnEmptyData)) }
    }

    /// Maps received data at key path into a String. If the conversion fails, the signal errors.
    func mapString(atKeyPath keyPath: String? = nil) -> Observable<String> {
        return flatMap { Observable.just(try $0.mapString(atKeyPath: keyPath)) }
    }

    /// Maps received data at key path into a Decodable object. If the conversion fails, the signal errors.
    func map<D: Decodable>(_ type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> Observable<D> {
        return flatMap { Observable.just(try $0.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)) }
    }
}

public extension ObservableType where Element == ProgressResponse {

    /**
     Filter completed progress response and maps to actual response

     - returns: response associated with ProgressResponse object
     */
    func filterCompleted() -> Observable<Response> {
        return self
            .filter { $0.completed }
            .flatMap { progress -> Observable<Response> in
                // Just a formatlity to satisfy the compiler (completed progresses have responses).
                switch progress.response {
                case .some(let response): return .just(response)
                case .none: return .empty()
                }
            }
    }

    /**
     Filter progress events of current ProgressResponse

     - returns: observable of progress events
     */
    func filterProgress() -> Observable<Double> {
        return self.filter { !$0.completed }.map { $0.progress }
    }
}
