//
//  CardNumberValidatorTests.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import XCTest
import Caishen

class CardNumberValidatorTests: XCTestCase {
    
    private let validAmexNumbers = [
        "340911175774790","344498905015187","377181528611711",
        "371389712775871","344349423631619","376524623963118",
        "370567702123605","377416885469414","376584690279335",
        "343876068903839","342853139737588","375225668591555",
        "345635170374943"
    ]
    private let validChinaUnionPayNumbers = [
        "6281263666071775", "6216618744032364", "6207688951528694",
        "6246553262016057", "6231548126188602", "6229666229491402",
        "6256787225452531", "6275921608934487", "6231343519691887",
        "6202825789208058", "6239804726435477", "6286698514203507",
        "6234017862752879", "6273996009006863", "6268602610482249",
        "6201175172181186", "6205373975695173",
        ]
    private let validDinersClubNumbers = [
        "38923577957110","30014619316479","30230875312552",
        "30039434938819","30322407024993","30398292508332",
        "30147247028189","36746224896643","38091630830656",
        "30374025714224","30146715095076","30111697100492",
        "30251158698160","30060391209382","30259583510991",
        "30374773235976","36936400983931","30371767990160"
    ]
    private let validDiscoverNumbers = [
        "6011447397023414","6011647123121859","6011235471625372",
        "6011632069154643","6011735747621279","6011739607244552",
        "6011817407651471","6011787624453342","6011399075993162",
        "6011359611012505","6011393918686539","6011961487691252",
        "6011407151605848","6011140526858517","6011663378746589",
        "6011471304004762","6011932869314458","6011112520771780",
        "6011394671740604","6011701901419876","6011022763176458"
    ]
    private let validJCBNumbers = [
        "3337885694409121","3337854360022014","3088251500745102",
        "3337976099385832","3158104807740315","3096738363752985",
        "3088058742928978","3528555294996491","3158808212724793",
        "3088573150753460","3088873442267117","3337862713581396",
        "3337361770417784","3096612307200510","3528220935303983",
        "3096866102345439","3528431414280416","3528370829547409"
    ]
    private let validVisaNumbers = [
        "4485757527763750","4929401141838813","4532533472054138",
        "4532864852162179","4532130294652312","4929411137410675",
        "4393610844598667","4608962962316823","4532858679188441",
        "4485414974995077","4532617676718299","4556038297361594",
        "4916351782925806","4576172713882929","4024007180061854",
        "4539002606626214","4024007120480776","4532725602167752",
        "4532075300709459","4716793955224230","4556481214195861",
        "4556485551226429"
    ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidCards() {
        print("Validate Visa")
        self.validVisaNumbers.forEach({
            XCTAssertEqual(CardTypeRegister.sharedCardTypeRegister.cardTypeForNumber(Number(rawValue: $0)).name, Visa().name)
            XCTAssertValid(Visa().validateNumber(Number(rawValue: $0)))
        })
        
        print("Validate Amex")
        self.validAmexNumbers.forEach({
            XCTAssertEqual(CardTypeRegister.sharedCardTypeRegister.cardTypeForNumber(Number(rawValue: $0)).name, AmericanExpress().name)
            XCTAssertValid(AmericanExpress().validateNumber(Number(rawValue: $0)))
        })
        
        print("Validate China UnionPay")
        self.validChinaUnionPayNumbers.forEach({
            XCTAssertEqual(CardTypeRegister.sharedCardTypeRegister.cardTypeForNumber(Number(rawValue: $0)).name, ChinaUnionPay().name)
            XCTAssertValid(ChinaUnionPay().validateNumber(Number(rawValue: $0)))
        })
        
        print("Validate Diners Club")
        self.validDinersClubNumbers.forEach({
            XCTAssertEqual(CardTypeRegister.sharedCardTypeRegister.cardTypeForNumber(Number(rawValue: $0)).name, DinersClub().name)
            XCTAssertValid(DinersClub().validateNumber(Number(rawValue: $0)))
        })
        
        print("Validate Discover")
        self.validDiscoverNumbers.forEach({
            XCTAssertEqual(CardTypeRegister.sharedCardTypeRegister.cardTypeForNumber(Number(rawValue: $0)).name, Discover().name)
            XCTAssertValid(Discover().validateNumber(Number(rawValue: $0)))
        })
        
        print("Validate JCB")
        self.validJCBNumbers.forEach({
            XCTAssertEqual(CardTypeRegister.sharedCardTypeRegister.cardTypeForNumber(Number(rawValue: $0)).name, JCB().name, "Card number was interpreted as wrong kind: \($0)")
            XCTAssertValid(JCB().validateNumber(Number(rawValue: $0)))
        })
    }
    
    func testValidateCardLength() {
        let tooShortVisa = "411111111111111"
        let tooShortAmex = "37828224631000"
        let tooShortDiners = "3056930902590"
        let tooShortDiscover = "601111111111111"
        let tooShortJCB = "353011133330000"
        let tooShortMasterCard = "555555555555444"
        let tooShortChinaUnionPay = "628126366607177"
        
        let tooLongVisa = "41111111111111111"
        let tooLongAmex = "3782822463100000"
        let tooLongDiners = "305693090259000"
        let tooLongDiscover = "60111111111111111"
        let tooLongJCB = "35301113333000000"
        let tooLongMasterCard = "55555555555544444"
        let tooLongChinaUnionPay = "62812636660717755"
        
        XCTAssertIncompleteNumber(Visa().validateNumber(Number(rawValue: tooShortVisa)))
        XCTAssertIncompleteNumber(AmericanExpress().validateNumber(Number(rawValue: tooShortAmex)))
        XCTAssertIncompleteNumber(DinersClub().validateNumber(Number(rawValue: tooShortDiners)))
        XCTAssertIncompleteNumber(Discover().validateNumber(Number(rawValue: tooShortDiscover)))
        XCTAssertIncompleteNumber(JCB().validateNumber(Number(rawValue: tooShortJCB)))
        XCTAssertIncompleteNumber(MasterCard().validateNumber(Number(rawValue: tooShortMasterCard)))
        XCTAssertIncompleteNumber(ChinaUnionPay().validateNumber(Number(rawValue: tooShortChinaUnionPay)))
        
        XCTAssertInvalidNumberForType(Visa().validateNumber(Number(rawValue: tooLongVisa)))
        XCTAssertInvalidNumberForType(AmericanExpress().validateNumber(Number(rawValue: tooLongAmex)))
        XCTAssertInvalidNumberForType(DinersClub().validateNumber(Number(rawValue: tooLongDiners)))
        XCTAssertInvalidNumberForType(Discover().validateNumber(Number(rawValue: tooLongDiscover)))
        XCTAssertInvalidNumberForType(JCB().validateNumber(Number(rawValue: tooLongJCB)))
        XCTAssertInvalidNumberForType(MasterCard().validateNumber(Number(rawValue: tooLongMasterCard)))
        XCTAssertInvalidNumberForType(ChinaUnionPay().validateNumber(Number(rawValue: tooLongChinaUnionPay)))
    }
    
    /**
     Changes the last digit of the card number (i.e. the digit that is used for validation with the Luhn test) and tests, if the Luhn test fails.
     */
    func testInvalidLuhnTest() {
        var allValidCardNumbers = validVisaNumbers
        allValidCardNumbers.append(contentsOf: self.validAmexNumbers)
        allValidCardNumbers.append(contentsOf: self.validDinersClubNumbers)
        allValidCardNumbers.append(contentsOf: self.validDiscoverNumbers)
        allValidCardNumbers.append(contentsOf: self.validJCBNumbers)
        
        let invalidLuhnTestVisa: [String] = allValidCardNumbers.map({
            guard let intValue = Int64($0) else {
                XCTFail("The credit card number \($0) is supposed to be parseable to an Integer!")
                return ""
            }
            
            var randomNumber = arc4random() % 10
            if randomNumber == 0 {
                randomNumber = 1
            }
            
            let changedLastDigit = (intValue + Int64(randomNumber)) % 10
            let invalidValue = intValue - (intValue % 10) + changedLastDigit
            
            return "\(invalidValue)"
        })
        
        
        invalidLuhnTestVisa.forEach({
            XCTAssertLuhnTestFailed(Visa().validateNumber(Number(rawValue: $0)))
        })
    }
    
}
