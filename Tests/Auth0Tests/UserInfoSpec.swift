import Auth0ObjC // Added by Auth0toSPM
// UserInfoSpec.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

import Foundation
import Quick
import Nimble
import JWTDecode

@testable import Auth0

fileprivate let BasicProfileJWT = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhdXRoMHwxMjM0NTY3ODkiLCJuYW1lIjoic3VwcG9ydCIsIm5pY2tuYW1lIjoic3VwIiwicGljdHVyZSI6Imh0dHBzOi8vYXV0aDAuY29tL3BpY3R1cmUiLCJ1cGRhdGVkX2F0IjoiMTQ0MDAwNDY4MSJ9.TppFbhhG2or0Ygtig_7wvMWj5pj1nibZQKlhp6YA0NnEmAU5oj9KxkL9BGCAjIUQcImO3Suiur27qNRDvTY7yG61kUfVFYmcdCcYZ3tuS2glA2Ofwjv-gkgkORFaggqwT4jaZ19MViHtW71AjH-l8Q9HbbCfD3pCI-M-95oSs7sPssXw3vOMbC_iMm-0TPzwSs32rc2Rmpni3T-rjthb7ZjYxpm2RUPvlpUMev0nb_E3QbLG-ct8jWwvDAjZbTgCYBkw0pmp57T4VBQ8acTQGvOi1lryrJ6kK9O9a_h9Yxf1t4HhBhfMW6p7fXNLVMYo5su3NFqW1KMVgUW7jNzKwA"

class UserInfoSpec: QuickSpec {
    override func spec() {

        describe("init from json") {

            it("should fail with no json") {
                let userInfo = UserInfo(json: [:])
                expect(userInfo).to(beNil())
            }

            it("should fail with no subject claim") {
                let userInfo = UserInfo(json: ["name":Support])
                expect(userInfo).to(beNil())
            }

            it("should only contain sub") {
                let userInfo = UserInfo(json: ["sub": Sub])
                expect(userInfo?.sub) == Sub
                expect(userInfo?.name).to(beNil())
                expect(userInfo?.givenName).to(beNil())
                expect(userInfo?.familyName).to(beNil())
                expect(userInfo?.middleName).to(beNil())
                expect(userInfo?.nickname).to(beNil())
                expect(userInfo?.preferredUsername).to(beNil())
                expect(userInfo?.profile).to(beNil())
                expect(userInfo?.picture).to(beNil())
                expect(userInfo?.website).to(beNil())
                expect(userInfo?.email).to(beNil())
                expect(userInfo?.emailVerified).to(beNil())
                expect(userInfo?.gender).to(beNil())
                expect(userInfo?.birthdate).to(beNil())
                expect(userInfo?.zoneinfo).to(beNil())
                expect(userInfo?.locale).to(beNil())
                expect(userInfo?.phoneNumber).to(beNil())
                expect(userInfo?.phoneNumberVerified).to(beNil())
                expect(userInfo?.address).to(beNil())
                expect(userInfo?.updatedAt).to(beNil())
                expect(userInfo?.customClaims).to(beEmpty())
            }

            it("should build with basic oidc profile") {
                let userInfo = UserInfo(json: basicProfileOIDC())
                expect(userInfo?.sub) == Sub
                expect(userInfo?.name) == Support
                expect(userInfo?.nickname) == Nickname
                expect(userInfo?.picture) == PictureURL
                expect(userInfo?.updatedAt?.timeIntervalSince1970) == UpdatedAtTimestamp
                expect(userInfo?.customClaims).to(beEmpty())
            }

            it("should build with extended oidc profile") {
                var info = basicProfileOIDC()
                let optional: [String: Any] = [
                    "website": WebsiteURL.absoluteString,
                    "profile": ProfileURL.absoluteString,
                    "email_verified": true,
                    "phone_number_verified": false
                ]
                optional.forEach { key, value in info[key] = value }
                
                let userInfo = UserInfo(json: info)
                expect(userInfo?.sub) == Sub
                expect(userInfo?.name) == Support
                expect(userInfo?.nickname) == Nickname
                expect(userInfo?.picture) == PictureURL
                expect(userInfo?.website) == WebsiteURL
                expect(userInfo?.profile) == ProfileURL
                expect(userInfo?.emailVerified) == true
                expect(userInfo?.phoneNumberVerified) == false
                expect(userInfo?.updatedAt?.timeIntervalSince1970) == UpdatedAtTimestamp
                expect(userInfo?.customClaims).to(beEmpty())
            }

            it("should build with basic oidc profile with locale and zoneinfo") {
                var info = basicProfileOIDC()
                let optional: [String: Any] = [
                    "locale": LocaleUS,
                    "zoneinfo": ZoneEST
                ]
                optional.forEach { key, value in info[key] = value }
                let userInfo = UserInfo(json: info)
                expect(userInfo?.locale?.identifier) == Locale(identifier: LocaleUS).identifier
                expect(userInfo?.zoneinfo?.identifier) == TimeZone(identifier: ZoneEST)!.identifier
            }

            it("should build from jwt body") {
                let jwt = try! decode(jwt: BasicProfileJWT)
                let userInfo = UserInfo(json: jwt.body)
                expect(userInfo?.sub) == Sub
                expect(userInfo?.name) == Support
                expect(userInfo?.nickname) == Nickname
                expect(userInfo?.picture) == PictureURL
                expect(userInfo?.updatedAt?.timeIntervalSince1970) == UpdatedAtTimestamp
                expect(userInfo?.customClaims).to(beEmpty())
            }
            
        }

        describe("custom claims") {

            it("should build with basic profile and two custom claims") {
                var info = basicProfileOIDC()
                let optional: [String: Any] = [
                    "user_list":  "user1",
                    "user_active": true
                ]
                optional.forEach { key, value in info[key] = value }
                let userInfo = UserInfo(json: info)
                expect(userInfo?.customClaims?.count) == 2
                expect(userInfo?.customClaims?["sub"]).to(beNil())
            }

        }
    }
}

