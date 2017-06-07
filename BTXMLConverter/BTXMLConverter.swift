//
//  BTXMLConverter.swift
//  BTXMLConverter
//
//  Created by BaoTuan on 6/8/17.
//  Copyright © 2017 Baotuan. All rights reserved.
//

struct Stack<T> {
    var items = [T]()
    mutating func push(_ item: T) {
        self.items.append(item)
    }
    mutating func pop() -> T? {
        if self.items.count > 1 {
            return self.items.removeLast()
        }
        return nil
    }
    mutating func drop() {
        _ = pop()
    }
    mutating func removeAll() {
        self.items.removeAll(keepingCapacity: false)
    }
    
    func top() -> T? {
        if self.items.count == 0 {
            return nil
        }
        return self.items[self.items.count - 1]
    }
    
}

class OKXMLData {
    var name = ""
    var data:NSMutableDictionary?
}


class BTXMLConverter: NSObject, XMLParserDelegate {
    var data = Stack<OKXMLData>()
    var dictionary:NSDictionary?
    
    init(value:String) {
        super.init()
        let xmlParser = XMLParser(data: value.data(using: .utf8)!)
        xmlParser.delegate = self
        let parse = xmlParser.parse()
        
        if parse {
            if let data = self.data.top()?.data {
                self.dictionary = data
            }
        }
    }
    
    // MARK: - XMLParserDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if let data = self.data.top() {
            if data.name == elementName {
                
                let dataXML = OKXMLData()
                dataXML.name = elementName
                
                dataXML.data = NSMutableDictionary()
                for (key,value) in attributeDict {
                    dataXML.data?.setValue(value, forKey: key)
                }
                
                self.data.push(dataXML)
            }
            else {
                let dataXML = OKXMLData()
                dataXML.name = elementName
                
                dataXML.data = NSMutableDictionary()
                for (key,value) in attributeDict {
                    dataXML.data?.setValue(value, forKey: key)
                }
                
                self.data.push(dataXML)
            }
        }
        else {
            let dataXML = OKXMLData()
            dataXML.name = elementName
            
            dataXML.data = NSMutableDictionary()
            for (key,value) in attributeDict {
                dataXML.data?.setValue(value, forKey: key)
            }
            
            self.data.push(dataXML)
        }
        
        
        //        for (key,value) in attributeDict {
        //            (self.dictionaryData[self.listValue.last!] as! NSMutableDictionary).setValue(value, forKey: key)
        //        }
        //        self.dictionaryData[self.listValue.last!] = attributeDict as AnyObject?
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //        self.listValue.removeLast()
        if let last = self.data.pop() {
            // add child to parent
            if let top = self.data.top() {
                if let topData = top.data {
                    if let lastData = last.data {
                        if topData[last.name] == nil {
                            topData[last.name] = lastData
                        }
                        else {
                            if let dataDic = topData[last.name] as? NSDictionary {
                                let array = NSMutableArray()
                                array.addObjects(from: [dataDic,lastData])
                                topData[last.name] = array
                            }
                            else if let dataArray = topData[last.name] as? NSMutableArray {
                                dataArray.add(lastData)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.data.top()?.data?.setValue(string, forKey: "string")
    }
}
