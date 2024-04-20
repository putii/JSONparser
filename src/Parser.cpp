#include "Parser.hpp"

template<typename T>
optParsedRestStrPair<T> Parser<T>::operator()(const std::string& str) {
  return f(str);
}