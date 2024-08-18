//
//  PackStreamFuture.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

enum PackStreamFuture {
    case value(PackStreamValue)
    case encoder(_PackStreamEncoder)
    case nestedList(RefList)
    case nestedDictionary(RefDictionary)

    class RefList {
        private(set) var list: [PackStreamFuture] = []

        init() {
            self.list.reserveCapacity(10)
        }

        @inline(__always) func append(_ element: PackStreamValue) {
            self.list.append(.value(element))
        }

        @inline(__always) func append(_ encoder: _PackStreamEncoder) {
            self.list.append(.encoder(encoder))
        }

        @inline(__always) func appendList() -> RefList {
            let list = RefList()
            self.list.append(.nestedList(list))
            return list
        }

        @inline(__always) func appendDictionary() -> RefDictionary {
            let dict = RefDictionary()
            self.list.append(.nestedDictionary(dict))
            return dict
        }

        var values: [PackStreamValue] {
            list.map { (future) -> PackStreamValue in
                switch future {
                case .value(let value):
                    return value
                case .nestedList(let list):
                    return .list(list.values)
                case .nestedDictionary(let dict):
                    return .dictionary(dict.values)
                case .encoder(let encoder):
                    return encoder.value ?? .dictionary([:])
                }
            }
        }
    }

    class RefDictionary {
        private(set) var dict: [String: PackStreamFuture] = [:]

        init() {
            self.dict.reserveCapacity(20)
        }

        @inline(__always) func set(_ value: PackStreamValue, for key: String) {
            self.dict[key] = .value(value)
        }

        @inline(__always) func setList(for key: String) -> RefList {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedDictionary:
                preconditionFailure("For key \"\(key)\" a keyed container has already been created.")
            case .nestedList(let list):
                return list
            case .none, .value:
                let list = RefList()
                dict[key] = .nestedList(list)
                return list
            }
        }

        @inline(__always) func setDictionary(for key: String) -> RefDictionary {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedDictionary(let dict):
                return dict
            case .nestedList:
                preconditionFailure("For key \"\(key)\" a unkeyed container has already been created.")
            case .none, .value:
                let dict = RefDictionary()
                self.dict[key] = .nestedDictionary(dict)
                return dict
            }
        }

        @inline(__always) func set(_ encoder: _PackStreamEncoder, for key: String) {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedDictionary:
                preconditionFailure("For key \"\(key)\" a keyed container has already been created.")
            case .nestedList:
                preconditionFailure("For key \"\(key)\" a unkeyed container has already been created.")
            case .none, .value:
                dict[key] = .encoder(encoder)
            }
        }

        var values: [String: PackStreamValue] {
            self.dict.mapValues { (future) -> PackStreamValue in
                switch future {
                case .value(let value):
                    return value
                case .nestedList(let array):
                    return .list(array.values)
                case .nestedDictionary(let object):
                    return .dictionary(object.values)
                case .encoder(let encoder):
                    return encoder.value ?? .dictionary([:])
                }
            }
        }
    }
}
