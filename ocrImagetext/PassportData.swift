//
//  PassportData.swift
//  ocrImagetext
//
//  Created by Ml Bench on 17/07/2025.
//
import Foundation

struct DocumentFields {
    var firstName: String?
    var lastName: String?
    var sex: String?
    var dateOfBirth: String?
    var documentNo: String?
    var documentType: String?
    var issuingCountry: String?
}


func extractFields(from text: String) -> DocumentFields {
    var fields = DocumentFields()
    let lines = text.components(separatedBy: .newlines).map { $0.lowercased().trimmingCharacters(in: .whitespaces) }

    for line in lines {
        // Document Number
        if fields.documentNo == nil, line.contains("passport no") || line.contains("pasaport no") || line.contains("pasaport na") {
            fields.documentNo = extractAfterColonOrSplit(line)
        }

        // Document Type
        if fields.documentType == nil, line.contains("pasaport") || line.contains("passport") {
            fields.documentType = "Passport"
        }

        // First Name
        if fields.firstName == nil, line.contains("name") || line.contains("ad") {
            fields.firstName = extractAfterColonOrSplit(line)
        }

        // Last Name
        if fields.lastName == nil, line.contains("surname") || line.contains("soyad") || line.contains("suran") {
            fields.lastName = extractAfterColonOrSplit(line)
        }

        // Date of Birth
        if fields.dateOfBirth == nil,
           line.contains("birth") || line.contains("dogum") || line.contains("data el bana") || line.contains("tarisl") {
            fields.dateOfBirth = extractDate(from: line)
        }

        // Sex
        if fields.sex == nil, line.contains("sex") || line.contains("cinsiyet") || line.contains("ses") {
            fields.sex = extractGender(from: line)
        }

        // Issuing Country
        if fields.issuingCountry == nil, line.contains("cyprus") || line.contains("republic") || line.contains("country code") {
            fields.issuingCountry = extractCountry(from: line)
        }
    }

    return fields
}

func extractAfterColonOrSplit(_ line: String) -> String? {
    if let range = line.range(of: ":") {
        return String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
    }
    let components = line.components(separatedBy: "/")
    if components.count > 1 {
        return components.last?.trimmingCharacters(in: .whitespaces)
    }
    let words = line.components(separatedBy: " ")
    return words.last
}

func extractDate(from line: String) -> String? {
    // Look for formats like 12 HAZ IJUN 1982 or 12.08.1964
    let dateRegexes = [
        #"\b\d{2}\.\d{2}\.\d{4}\b"#,                      // 12.08.1964
        #"\b\d{2} [A-ZÇĞİÖŞÜa-zçğıöşü]{3,} \d{4}\b"#,     // 12 HAZ IJUN 1982
        #"\b\d{2} [A-ZÇĞİÖŞÜa-zçğıöşü]{3} / [A-Z]{3} \d{4}\b"# // 12 HAZ / JUN 1982
    ]
    
    for regex in dateRegexes {
        if let match = line.range(of: regex, options: .regularExpression) {
            return String(line[match])
        }
    }
    return nil
}

func extractGender(from line: String) -> String? {
    if line.contains("m") || line.contains("e") {
        return "Male"
    } else if line.contains("f") || line.contains("k") {
        return "Female"
    }
    return nil
}

func extractCountry(from line: String) -> String? {
    if line.contains("cyprus") {
        return "Northern Cyprus"
    } else if let match = line.range(of: #"[A-Z]{3}"#, options: .regularExpression) {
        return String(line[match])
    }
    return nil
}
