#include "Functor.hpp"
#include <gtest/gtest.h>
#include <iostream>
#include <ranges>

template <typename Input>
class A  {
public:
  A(const Input& t_) : t(t_) {}
  ~A() = default;
  void print() const { std::cout << t << std::endl; }
private:
  Input t;
  friend class FunctorA;
};

class FunctorA : public Functor<std::string, int, A>
{
public:
  A<int> fmap(const std::function<int(std::string)>& f, const A<std::string>& a) const override
  {
    return A{f(a.t)};
  }
  ~FunctorA() override {}
};

TEST(Functor, FunctorReconnaissanceInForce) {
  A<std::string> a{"123"};
  auto converter =
    [](const std::string& s){ return std::stoi(s); };
  FunctorA().fmap(converter, a).print();
}