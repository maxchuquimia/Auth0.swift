#if os(iOS) || os(macOS) // Added by Auth0toSPM
import Auth0ObjC // Added by Auth0toSPM
// NSURLComponents+OAuth2.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if os(iOS) || os(macOS)  // Added by Auth0toSPM(original value '#if WEB_AUTH_PLATFORM')
import Foundation

extension URLComponents {
    var a0_fragmentValues: [String: String] {
        var dict: [String: String] = [:]
        let items = fragment?.components(separatedBy: "&")
        items?.forEach { item in
            let parts = item.components(separatedBy: "=")
            guard
                parts.count == 2,
                let key = parts.first,
                let value = parts.last
                else { return }
            dict[key] = value
        }
        return dict
    }

    var a0_queryValues: [String: String] {
        var dict: [String: String] = [:]
        self.queryItems?.forEach { dict[$0.name] = $0.value }
        return dict
    }
}
#endif

#endif // Added by Auth0toSPM
