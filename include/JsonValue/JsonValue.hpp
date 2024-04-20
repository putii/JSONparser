#ifndef JSONPARSER_JSONVALUE_H
#define JSONPARSER_JSONVALUE_H

#include <string>
#include <unordered_map>
#include <vector>

enum class JsonType {
  JsonNull,
  JsonBool,
  JsonString,
  JsonNumber,
  JsonArray,
  JsonObject
};

struct JsonValue;

union JsonContent {
  bool b;
  std::string s;
  int n;
  std::vector<JsonValue> a; // TODO I may want to use std::list
  std::unordered_map<std::string, JsonValue> o;
};

struct JsonValue { // parsing tree
  JsonType t;
  JsonContent c;
};

#endif // JSONPARSER_JSONVALUE_H
