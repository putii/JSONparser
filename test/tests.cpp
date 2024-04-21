// #include "Functor.hpp"
#include <functional>
#include <gtest/gtest.h>
#include <iostream>
#include <ranges>

/*template <typename Input>
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
  A<int> fmap(const std::function<int(std::string)>& f, const A<std::string>& a) const
override
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
}*/

//////////////////////////////////////////////////

// https://bartoszmilewski.com/2015/01/20/functors/#:~:text=of%20fmap.-,The%20List%20Functor,-To%20get%20some
/*template<class A, class B>
std::vector<B> fmap(std::function<B(A)> f, std::vector<A> v) {
  std::vector<B> w;
  std::transform(std::begin(v), std::end(v), std::back_inserter(w), f);
  return w;
}

TEST(b_milewski, TheListFunctor) {
  std::vector<int> v{ 1, 2, 3, 4 };
  auto w = fmap<int, int>([](int i) { return i * i; }, v);
  std::copy(std::begin(w), std::end(w), std::ostream_iterator<int>(std::cout, ", "));
}*/

///////////////////////////////////////////////

template<typename A>
class Functor {
public:
  Functor(const A& value_) : value(value_) {}
  void print() const { std::cout << value << '\n'; }
  // private: // do i really need the value to be private ?
  A value;
};

template<typename A, typename B, template<typename> typename Functor>
Functor<B> fmap(const std::function<B(A)>& f, const Functor<A>& functorA) {
  return Functor<B>{ f(functorA.value) };
}


TEST(FunctorWithOneTemplateParam, SimpleExamples) {
  Functor functorStr{ std::string("123") };
  functorStr.print();

  // Can I have reference to Functors of diff template parameters?
  Functor<std::string>& functorRef = functorStr;
  functorRef.print();

  const auto converterTransformer = [](const std::string& s) {
    return std::stoi(s) - 121;
  };
  /* fmap(converter, functorStr).print(); // cannot deduce proper string type - gets stuck
   * on std::string& vs const std::string& */
  auto functorInt = fmap<std::string, int>(converterTransformer, functorStr);
  functorInt.print();
  // functorRef = functorInt; // will not compile - types do not match
  auto floatCircleArea = [](int i) {
    return static_cast<float>(3.14) * static_cast<float>(i) * static_cast<float>(i);
  };
  auto functorFloat = fmap<int, float>(floatCircleArea, functorInt);
  functorFloat.print();
}