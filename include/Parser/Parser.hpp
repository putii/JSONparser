#ifndef JSONPARSER_CHARPARSER_H
#define JSONPARSER_CHARPARSER_H

#include <functional>
#include <optional>
#include <string>
#include <utility>

template<typename T>
using optParsedRestStrPair = std::optional<std::pair<T, std::string>>;

/**
 * Mr. Parser
 * It takes string, parses part of it
 * and returns optional pair of effect of parsing and rest of string
 * @tparam T
 */
template<typename T>
class Parser {
public:
  explicit Parser(std::function<optParsedRestStrPair<T>(const std::string& str)> inF) : f(inF) {};

  /**
   * I want to call Parser objects with string as parameter
   * which will delegate to f
   * @param str to be parsed string
   * @return
   */
  optParsedRestStrPair<T> operator()(const std::string& str);
private:
  /**
   * Injected dependency doing specialiazed parsing
   */
  std::function<optParsedRestStrPair<T>(const std::string& str)> f;
};

#endif // JSONPARSER_CHARPARSER_H
